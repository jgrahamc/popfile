# POPFILE LOADABLE MODULE
package UI::HTML;

#----------------------------------------------------------------------------
#
# This package contains an HTML UI for POPFile
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#----------------------------------------------------------------------------

use UI::HTTP;
@ISA = ("UI::HTTP");

use strict;
use warnings;
use locale;

use IO::Socket;
use IO::Select;

# A handy variable containing the value of an EOL for the network

my $eol = "\015\012";

# Constant used by the history deletion code

my $seconds_per_day = 60 * 60 * 24;

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = UI::HTTP->new();

    # The classifier (Classifier::Bayes)

    $self->{classifier__}      = 0;

    # Session key to make the UI safer

    $self->{session_key__}     = '';

    # The available skins

    $self->{skins__}           = ();

    # Used to keep the history information around so that we don't have to reglob every time we hit the
    # history page
    #
    # The history hash contains information about ALL the files stored in the history
    # folder (by default messages/) and is updated by the load_history_cache__ method
    #
    # Access to the history cache is formatted $self->{history}{file}{subkey} where
    # the file is the name of the file that is related to this history entry.
    #
    # The subkeys are
    #
    #   cull            Used internally by load_history_cache__ (see there for details)
    #   from            The address the email was from
    #   short_from      Version of from with max 40 characters
    #   subject         The subject of the email
    #   short_subject   Version of subject with max 40 characters
    #   magnet          If a magnet was used to classify the mail contains the magnet string
    #   bucket          The classification of the mail
    #   reclassified    1 if the mail has already been reclassified
    #
    # The history_keys array stores the list of keys in the history hash and are a
    # (perhaps strict) subset of the keys of $self->{history} set by calls to
    # sory_filter_history.  history_keys references the elements on history that are
    # in the current filter, sort or search set.
    #
    # history_invalid is set to cause the history cache to be reloaded by a call to
    # load_history_cache__, and is set by a call to invalidate_history_cache

    $self->{history__}         = {};
    $self->{history_keys__}    = ();
    $self->{history_invalid__} = 0;

    # A hash containing a mapping between alphanumeric identifiers and appropriate strings used
    # for localization.  The string may contain sprintf patterns for use in creating grammatically
    # correct strings, or simply be a string

    $self->{language__}        = {};

    # This is the list of available languages

    $self->{languages__}       = ();

    # Must call bless before attempting to call any methods

    bless $self, $type;

    # This is the HTML module which we know as the HTML module

    $self->name( 'html' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the interface
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    $self->config_( 'port', 8080 );

    # Checking for updates if off by default
    $self->config_( 'update_check', 0 );

    # Sending of statistics is off
    $self->config_( 'send_stats', 0 );

    # The size of a history page
    $self->config_( 'page_size', 20 );

    # Only accept connections from the local machine for the UI
    $self->config_( 'local', 1 );

    # Use the default skin
    $self->config_( 'skin', 'SimplyBlue' );

    # Keep the history for two days
    $self->config_( 'history_days', 2 );

    # The last time we checked for an update using the local epoch
    $self->config_( 'last_update_check', 0 );

    # The user interface password
    $self->config_( 'password', '' );

    # The last time (textual) that the statistics were reset
    $self->config_( 'last_reset', localtime );

    # We start by assuming that the user speaks English like the
    # perfidious Anglo-Saxons that we are... :-)
    $self->config_( 'language', 'English' );

    # If this is 1 then when the language is loaded we will use the language string identifier as the
    # string shown in the UI.  This is used to test whether which identifiers are used where.
    $self->config_( 'test_language', 0 );

    # If 1, Messages are saved to an archive when they are removed or expired from the history cache
    $self->config_( 'archive', 0, 1 );

    # The directory where messages will be archived to, in sub-directories for each bucket
    $self->config_( 'archive_dir', 'archive' );

    # This is an advanced setting which will save archived files to a randomly numbered
    # sub-directory, if set to greater than zero, otherwise messages will be saved in the
    # bucket directory
    # 0 <= directory name < archive_classes
    $self->config_( 'archive_classes', 0 );

    # Load skins
    load_skins($self);

    # Load the list of available user interface languages
    load_languages($self);

    # Calculate a session key
    change_session_key($self);

    # The parent needs a reference to the url handler function
    $self->{url_handler_} = \&url_handler__;

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to start the HTML interface running
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # This needs to occur at launch, but after initialization
    
    $self->remove_mail_files();
    $self->calculate_today();

    # Ensure that the messages subdirectory exists

    mkdir( 'messages' );

    # Load the current configuration from disk and then load up the
    # appropriate language, note that we always load English first
    # so that any extensions to the user interface that have not yet
    # been translated will still appear

    load_language( $self, 'English' );
    load_language( $self, $self->config_( 'language' ) ) if ( $self->config_( 'language' ) ne 'English' );

    # We need to force a history cache reload, note that this needs
    # to come after loading the language since we might need History_NoFrom
    # or History_NoSubject in while loading the cache

    $self->invalidate_history_cache();
    $self->load_history_cache__();
    $self->sort_filter_history( '', '', '' );

    return $self->SUPER::start();
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# Called to handle interface requests
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    $self->remove_mail_files();

    return $self->SUPER::service();
}

# ---------------------------------------------------------------------------------------------
#
# url_handler__ - Handle a URL request
#
# $client     The web browser to send the results to
# $url        URL to process
# $command    The HTTP command used (GET or POST)
# $content    Any non-header data in the HTTP command
#
# Checks the session
# key and refuses access unless it matches.  Serves up a small set of specific urls that are
# the main UI pages and then any GIF file in the POPFile directory and CSS files in the skins
# subdirectory
#
# ---------------------------------------------------------------------------------------------
sub url_handler__
{
    my ( $self, $client, $url, $command, $content ) = @_;

    # See if there are any form parameters and if there are parse them into the %form hash

    delete $self->{form_};

    # Remove a # element

    $url =~ s/#.*//;

    # If the URL was passed in through a GET then it may contain form arguments
    # separated by & signs, which we parse out into the $self->{form_} where the
    # key is the argument name and the value the argument value, for example if
    # you have foo=bar in the URL then $self->{form_}{foo} is bar.

    if ( $command =~ /GET/i ) {
        if ( $url =~ s/\?(.*)// )  {
            $self->parse_form__( $1 );
        }
    }

    # If the URL was passed in through a POST then look for the POST data
    # and parse it filling the $self->{form_} in the same way as for GET
    # arguments

    if ( $command =~ /POST/i ) {
        $content =~ s/[\r\n]//g;
        $self->parse_form__( $content );
    }

    if ( $url eq '/jump_to_message' )  {
        my $found = 0;
        my $file = $self->{form_}{view};
        foreach my $akey ( keys %{ $self->{history__} } ) {
            if ($akey eq $file) {
                $found = 1;
                last;
            }
        }

        #Reset any filters
        $self->{form_}{filter}    = '';
        $self->{form_}{search}    = '';
        $self->{form_}{setsearch} = 1;

        # Force a history_reload if we did not find this file in the history cache
        # but we do find it on disk using perl's -e file test operator (returns
        # true if the file exists).

        $self->invalidate_history_cache() if ( !$found && ( -e ($self->global_config_( 'msgdir' ) . "$file") ) );
        $self->http_redirect_( $client, "/history?session=$self->{session_key__}&start_message=0&view=$self->{form_}{view}#$self->{form_}{view}" );
        return 1;
    }

    if ( $url =~ /\/(.+\.gif)/ ) {
        $self->http_file_( $client, $1, 'image/gif' );
        return 1;
    }

    if ( $url =~ /(skins\/.+\.css)/ ) {
        $self->http_file_( $client, $1, 'text/css' );
        return 1;
    }

    if ( $url =~ /(manual\/.+\.html)/ ) {
        $self->http_file_( $client, $1, 'text/html' );
        return 1;
    }

    # Check the password
    if ( $url eq '/password' )  {
        if ( $self->{form_}{password} eq $self->config_( 'password' ) )  {
            change_session_key( $self );
            delete $self->{form_}{password};
            $self->{form_}{session} = $self->{session_key__};
            if ( defined( $self->{form_}{redirect} ) ) {
                $url = $self->{form_}{redirect};
            } else {
                $url = '/';
            }
        } else {
            password_page( $self, $client, 1, '/' );
            return 1;
        }
    }

    # If there's a password defined then check to see if the user already knows the
    # session key, if they don't then drop to the password screen
    if ( ( (!defined($self->{form_}{session})) || ($self->{form_}{session} eq '' ) || ( $self->{form_}{session} ne $self->{session_key__} ) ) && ( $self->config_( 'password' ) ne '' ) ) {
        password_page( $self, $client, 0, $url );
        return 1;
    }

    if ( ( defined($self->{form_}{session}) ) && ( $self->{form_}{session} ne $self->{session_key__} ) ) {
        session_page( $self, $client, 0, $url );
        return 1;
    }

    if ( ( $url eq '/' ) || (!defined($self->{form_}{session})) ) {
        delete $self->{form_};
    }

    if ( $url eq '/shutdown' )  {
        http_ok( $self, $client, "POPFile shutdown", -1 );
        return 0;
    }

    my %url_table = (   '/security'      => \&security_page,
                        '/configuration' => \&configuration_page,
                        '/buckets'       => \&corpus_page,
                        '/magnets'       => \&magnet_page,
                        '/advanced'      => \&advanced_page,
                        '/history'       => \&history_page,
                        '/'              => \&history_page );

    # Any of the standard pages can be found in the url_table, the other pages are probably
    # files on disk
    if ( defined($url_table{$url}) )  {
        &{$url_table{$url}}($self, $client);
        return 1;
    }

    http_error_($self, $client, 404);
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# http_ok - Output a standard HTTP 200 message with a body of data
#
# $client    The web browser to send result to
# $text      The body of the page
# $selected  Which tab is to be selected
#
# Returns an HTTP 200 message with a body of data passed in $text wrapping it with the standard
# header and footer.  The header is updated with the appropriate tab selected, and the
# various elements in the footer are updated.  This function also checks whether POPFile is
# up to date and if it is not it inserts the appropriate image to tell the user to update.
#
# ---------------------------------------------------------------------------------------------
sub http_ok
{
    my ( $self, $client, $text, $selected ) = @_;

    my @tab = ( 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard' );
    $tab[$selected] = 'menuSelected' if ( ( $selected <= $#tab ) && ( $selected >= 0 ) );
    my $update_check = '';

    # Check to see if we've checked for updates today.  If we have not then insert a reference to an image
    # that is generated through a CGI on UseTheSource.  Also send stats to the same site if that is allowed
    if ( $self->{today} ne $self->config_( 'last_update_check' ) ) {
        calculate_today( $self );

        if ( $self->config_( 'update_check' ) ) {
            $update_check = "<a href=\"http://sourceforge.net/project/showfiles.php?group_id=63137\">\n";
            $update_check .= "<img border=\"0\" alt=\"\" src=\"http://www.usethesource.com/cgi-bin/popfile_update.pl?ma=$self->{configuration}{major_version}&amp;mi=$self->{configuration}{minor_version}&amp;bu=$self->{configuration}{build_version}\" />\n</a>\n";
        }

        if ( $self->config_( 'send_stats' ) ) {
            my @buckets = $self->{classifier__}->get_buckets();
            my $bc      = $#buckets + 1;
            $update_check .= "<img border=\"0\" alt=\"\" src=\"http://www.usethesource.com/cgi-bin/popfile_stats.pl?bc=$bc&amp;mc=" . $self->global_config_( 'mcount' ) . "&amp;ec=" . $self->global_config_( 'ecount' ) . "\" />\n";
        }

        $self->config_( 'last_update_check', $self->{today}, 1 );
    }

    # Build the full page of HTML by preprending the standard header and append the standard
    # footer
    $text =  html_common_top($self, $selected) . html_common_middle($self, $text, $update_check, @tab)
        . html_common_bottom($self);

    # Build an HTTP header for standard HTML
    my $http_header = "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nContent-Length: ";
    $http_header .= length($text);
    $http_header .= "$eol$eol";

    print $client $http_header . $text;
}

# ---------------------------------------------------------------------------------------------
#
# html_common_top - Creates a string containing the standard header for each POPFile page
#                   as HTML.   This is the title portion of the page and the META tags that
#                   inform the browser of various information including the style sheet that
#                   is used for the current skin.
#
# $selected  Which tab is to be selected
#
# Returns a string of HTML
#
# ---------------------------------------------------------------------------------------------

sub html_common_top
{
    my ($self, $selected) = @_;

    # The returned string contains the HEAD portion of an HTML page with the title, a link
    # to the skin CSS file and information about caching (we do not want to be cached as
    # every page is dynamically generated) and a Content-Type header that this is HTML

    my $result = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" ";
    $result .= "\"http://www.w3.org/TR/html4/loose.dtd\">\n";
    $result .= "<html lang=\"$self->{language__}{LanguageCode}\">\n<head>\n<title>$self->{language__}{Header_Title}</title>\n";

    # If we are handling the shutdown page, then send the CSS along with the
    # page to avoid a request back from the browser _after_ we've shutdown,
    # otherwise, send the link to the CSS file so it is cached by the browser.

    if ( $selected == -1 ) {
        $result .= "<style type=\"text/css\">\n";
        if ( open FILE, '<skins/' . $self->config_( 'skin' ) . '.css' ) {
            while (<FILE>) {
                $result .= $_;
            }
            close FILE;
        }
        $result .= "</style>\n";
    } else {
        $result .= "<link rel=\"stylesheet\" type=\"text/css\" ";
        $result .= "href=\"skins/" . $self->config_( 'skin' ) . ".css\" title=\"" . $self->config_( 'skin' ) . "\">\n";
    }

    $result .= "<meta http-equiv=\"Pragma\" content=\"no-cache\">\n";
    $result .= "<meta http-equiv=\"Expires\" content=\"0\">\n";

    $result .= "<meta http-equiv=\"Cache-Control\" content=\"no-cache\">\n";
    $result .= "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$self->{language__}{LanguageCharset}\">\n</head>\n";

    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# html_common_middle - Called from http_ok to build the common middle part of an html page
#                      that consists of the title at the top of the page and the tabs for
#                       selecting parts of the program
#
# $text      The body of the page
# $update_check      Contains html for updating, as required
# @tab      Array of interface tabs -- one of which is selected
#
# Returns a string of html
#
# ---------------------------------------------------------------------------------------------

sub html_common_middle
{
    my ($self, $text, $update_check, @tab) = @_;

    # The returned string consists of the BODY portion of the page with the header
    # tabs and the passed in $text.  Note that the BODY is not closed as the standard
    # footer created by html_common_bottom takes care of that.

    my $result = "<body>\n<table class=\"shellTop\" align=\"center\" width=\"100%\" summary=\"\">\n";

    # upper whitespace
    $result .= "<tr class=\"shellTopRow\">\n<td class=\"shellTopLeft\"></td>\n<td class=\"shellTopCenter\"></td>\n";
    $result .= "<td class=\"shellTopRight\"></td>\n</tr>\n";

    # logo
    $result .= "<tr>\n<td class=\"shellLeft\"></td>\n";
    $result .= "<td class=\"naked\">\n";
    $result .= "<table class=\"head\" cellspacing=\"0\" summary=\"\">\n<tr>\n";
    $result .= "<td class=\"head\">$self->{language__}{Header_Title}</td>\n";

    # shutdown
    $result .= "<td align=\"right\" valign=\"bottom\">\n";
    $result .= "<a class=\"shutdownLink\" href=\"/shutdown\">$self->{language__}{Header_Shutdown}</a>&nbsp;\n";

    $result .= "</td>\n</tr>\n<tr>\n";
    $result .= "<td height=\"1%\" colspan=\"3\"></td>\n</tr>\n";
    $result .= "</table>\n</td>\n"; # colspan 2 ?? srk
    $result .= "<td class=\"shellRight\"></td>\n</tr>\n<tr class=\"shellBottomRow\">\n";

    $result .= "<td class=\"shellBottomLeft\"></td>\n<td class=\"shellBottomCenter\"></td>\n";
    $result .= "<td class=\"shellBottomRight\"></td>\n</tr>\n</table>\n";

    # update check
    $result .= "<table align=\"center\" summary=\"\">\n<tr>\n<td class=\"logo2menuSpace\">$update_check</td></tr></table>\n";

    # menu start
    $result .= "<table class=\"menu\" cellspacing=\"0\" summary=\"$self->{language__}{Header_MenuSummary}\">\n";
    $result .= "<tr>\n";

    # blank menu item for indentation
    $result .= "<td class=\"menuIndent\">&nbsp;</td>";

    # History menu item
    $result .= "<td class=\"$tab[2]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/history?session=$self->{session_key__}&amp;setfilter=\">";
    $result .= "\n$self->{language__}{Header_History}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Buckets menu item
    $result .= "<td class=\"$tab[1]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/buckets?session=$self->{session_key__}\">";
    $result .= "\n$self->{language__}{Header_Buckets}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Magnets menu item
    $result .= "<td class=\"$tab[4]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/magnets?session=$self->{session_key__}\">";
    $result .= "\n$self->{language__}{Header_Magnets}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Configuration menu item
    $result .= "<td class=\"$tab[0]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/configuration?session=$self->{session_key__}\">";
    $result .= "\n$self->{language__}{Header_Configuration}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Security menu item
    $result .= "<td class=\"$tab[3]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/security?session=$self->{session_key__}\">";
    $result .= "\n$self->{language__}{Header_Security}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Advanced menu item
    $result .= "<td class=\"$tab[5]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/advanced?session=$self->{session_key__}\">";
    $result .= "\n$self->{language__}{Header_Advanced}</a>\n";
    $result .= "</td>\n";

    # blank menu item for indentation
    $result .= "<td class=\"menuIndent\">&nbsp;</td>";

    # finish up the menu
    $result .= "</tr>\n</table>\n";

    # main content area
    $result .= "<table class=\"shell\" align=\"center\" width=\"100%\" summary=\"\">\n<tr class=\"shellTopRow\">\n";
    $result .= "<td class=\"shellTopLeft\"></td>\n<td class=\"shellTopCenter\"></td>\n";
    $result .= "<td class=\"shellTopRight\"></td>\n</tr>\n<tr>\n";
    $result .= "<td class=\"shellLeft\"></td>\n";
    $result .= "<td align=\"left\" class=\"naked\">\n" . $text . "\n</td>\n";

    $result .= "<td class=\"shellRight\"></td>\n</tr>\n";
    $result .= "<tr class=\"shellBottomRow\">\n<td class=\"shellBottomLeft\"></td>\n";
    $result .= "<td class=\"shellBottomCenter\"></td>\n<td class=\"shellBottomRight\"></td>\n";
    $result .= "</tr>\n</table>\n";

    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# html_common_bottom - Called from http_ok to build the common bottom part of an html page
#
# Returns a string of html
#
# ---------------------------------------------------------------------------------------------

sub html_common_bottom
{
    my ($self) = @_;

    my $time = localtime;

    # The returned string has the standard footer that appears on every HTML page in
    # POPFile with links to the POPFile home page and other information and closes
    # both the BODY and the complete page

    my $result = "<table class=\"footer\" summary=\"\">\n<tr>\n";
    $result .= "<td class=\"footerBody\">\n";
    $result .= "POPFile $self->{version_} - \n";
    $result .= "<a class=\"bottomLink\" href=\"";

    # To save space on the download of POPFile only the English language manual
    # is shipped and available locally, all other languages are referenced through
    # the POPFile home page on SourceForge

    if ( $self->{language__}{ManualLanguage} eq 'en' ) {
        $result .= 'manual/en';
    } else {
        $result .= "http://popfile.sourceforge.net/manual/$self->{language__}{ManualLanguage}";
    }

    $result .= "/manual.html\">\n";
    $result .= "$self->{language__}{Footer_Manual}</a> - \n";

    $result .= "<a class=\"bottomLink\" href=\"http://sourceforge.net/docman/display_doc.php?docid=14421&amp;group_id=63137\">FAQ</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://popfile.sourceforge.net/\">$self->{language__}{Footer_HomePage}</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://sourceforge.net/forum/forum.php?forum_id=213876\">$self->{language__}{Footer_FeedMe}</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://sourceforge.net/tracker/index.php?group_id=63137&amp;atid=502959\">$self->{language__}{Footer_RequestFeature}</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://lists.sourceforge.net/lists/listinfo/popfile-announce\">$self->{language__}{Footer_MailingList}</a> - \n";
    $result .= "($time)\n";

    # comment out these next 3 lines prior to shipping code
    # enable them during development to check validation
    #
    # TODO: these should not be commented out but they should be enabled
    # when we are running in developer mode
    #
    # my $validationLinks = "Validate: <a href=\"http://validator.w3.org/check/referer\">HTML 4.01</a> - \n";
    # $validationLinks .= "<a href=\"http://jigsaw.w3.org/css-validator/check/referer\">CSS-1</a>";
    # $result .= " - $validationLinks\n";

    $result .= "</td>\n</tr>\n</table>\n</body>\n</html>\n";

    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# configuration_page - get the configuration options
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub configuration_page
{
    my ( $self, $client ) = @_;

    my $body;
    my $port_error = '';
    my $ui_port_error = '';
    my $page_size_error = '';
    my $history_days_error = '';
    my $timeout_error = '';
    my $separator_error = '';

    $self->config_( 'skin', $self->{form_}{skin} )      if ( defined($self->{form_}{skin}) );
    $self->global_config_( 'debug', $self->{form_}{debug}-1 )   if ( ( defined($self->{form_}{debug}) ) && ( ( $self->{form_}{debug} >= 1 ) && ( $self->{form_}{debug} <= 4 ) ) );
    $self->global_config_( 'subject', $self->{form_}{subject}-1 ) if ( ( defined($self->{form_}{subject}) ) && ( ( $self->{form_}{subject} >= 1 ) && ( $self->{form_}{subject} <= 2 ) ) );
    $self->global_config_( 'xtc', $self->{form_}{xtc}-1 )     if ( ( defined($self->{form_}{xtc}) ) && ( ( $self->{form_}{xtc} >= 1 ) && ( $self->{form_}{xtc} <= 2 ) ) );
    $self->global_config_( 'xpl', $self->{form_}{xpl}-1 )     if ( ( defined($self->{form_}{xpl}) ) && ( ( $self->{form_}{xpl} >= 1 ) && ( $self->{form_}{xpl} <= 2 ) ) );

    for my $name (keys %{$self->{dynamic_ui__}{configuration}}) {
        $body .= $self->{dynamic_ui__}{configuration}{$name}->validate_item( $name,
                                                                             \%{$self->{language__}},
                                                                             \%{$self->{form_}} );
    }

    if ( defined($self->{form_}{language}) ) {
        if ( $self->config_( 'language' ) ne $self->{form_}{language} ) {
            $self->config_( 'language', $self->{form_}{language} );
            load_language( $self,  $self->config_( 'language' ) );
        }
    }

    if ( defined($self->{form_}{ui_port}) ) {
        if ( ( $self->{form_}{ui_port} >= 1 ) && ( $self->{form_}{ui_port} < 65536 ) ) {
            $self->config_( 'port', $self->{form_}{ui_port} );
        } else {
            $ui_port_error = "<blockquote>\n<div class=\"error01\">\n";
            $ui_port_error .= "$self->{language__}{Configuration_Error2}</div>\n</blockquote>\n";
            delete $self->{form_}{ui_port};
        }
    }

    if ( defined($self->{form_}{page_size}) ) {
        if ( ( $self->{form_}{page_size} >= 1 ) && ( $self->{form_}{page_size} <= 1000 ) ) {
            $self->config_( 'page_size', $self->{form_}{page_size} );
        } else {
            $page_size_error = "<blockquote><div class=\"error01\">$self->{language__}{Configuration_Error4}</div></blockquote>";
            delete $self->{form_}{page_size};
        }
    }

    if ( defined($self->{form_}{history_days}) ) {
        if ( ( $self->{form_}{history_days} >= 1 ) && ( $self->{form_}{history_days} <= 366 ) ) {
            $self->config_( 'history_days', $self->{form_}{history_days} );
        } else {
            $history_days_error = "<blockquote><div class=\"error01\">$self->{language__}{Configuration_Error5}</div></blockquote>";
            delete $self->{form_}{history_days};
        }
    }

    if ( defined($self->{form_}{timeout}) ) {
        if ( ( $self->{form_}{timeout} >= 10 ) && ( $self->{form_}{timeout} <= 300 ) ) {
            $self->global_config_( 'timeout', $self->{form_}{timeout} );
        } else {
            $timeout_error = "<blockquote><div class=\"error01\">$self->{language__}{Configuration_Error6}</div></blockquote>";
            $self->{form_}{update_timeout} = '';
        }
    }

    # User Interface panel
    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language__}{Configuration_MainTableSummary}\">\n";
    $body .= "<tr>\n<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language__}{Configuration_UserInterface}</h2>\n";
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configSkin\">$self->{language__}{Configuration_SkinsChoose}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "<select name=\"skin\" id=\"configSkin\">\n";

    # Create three groupings for skins

    # Normal skins
    $body .= "<optgroup label=\"$self->{language__}{Configuration_GeneralSkins}\">\n";
    for my $i (0..$#{$self->{skins__}}) {
        if ( !( $self->{skins__}[$i] =~ /^(small|tiny)/i  ) ) {
            $body .= "<option value=\"$self->{skins__}[$i]\"";
            $body .= " selected=\"selected\"" if ( $self->{skins__}[$i] eq $self->config_( 'skin' ) );
            $body .= ">$self->{skins__}[$i]</option>\n";
        }
    }
    $body .= "</optgroup>\n";

    # Small skins
    $body .= "<optgroup label=\"$self->{language__}{Configuration_SmallSkins}\">\n";
    for my $i (0..$#{$self->{skins__}}) {
        if ( $self->{skins__}[$i] =~ /^small/i  ) {
            $body .= "<option value=\"$self->{skins__}[$i]\"";
            $body .= " selected=\"selected\"" if ( $self->{skins__}[$i] eq $self->config_( 'skin' ) );
            $body .= ">$self->{skins__}[$i]</option>\n";
        }
    }
    $body .= "</optgroup>\n";

    # Tiny skins
    $body .= "<optgroup label=\"$self->{language__}{Configuration_TinySkins}\">\n";
    for my $i (0..$#{$self->{skins__}}) {
        if ( $self->{skins__}[$i] =~ /^tiny/i  ) {
            $body .= "<option value=\"$self->{skins__}[$i]\"";
            $body .= " selected=\"selected\"" if ( $self->{skins__}[$i] eq $self->config_( 'skin' ) );
            $body .= ">$self->{skins__}[$i]</option>\n";
        }
    }
    $body .= "</optgroup>\n";

    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"change_skin\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "</form>\n";

    # Choose Language widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configLanguage\">$self->{language__}{Configuration_LanguageChoose}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "<select name=\"language\" id=\"configLanguage\">\n";
    for my $i (0..$#{$self->{languages__}}) {
        $body .= "<option value=\"$self->{languages__}[$i]\"";
        $body .= " selected=\"selected\"" if ( $self->{languages__}[$i] eq $self->config_( 'language' ) );
        $body .= ">$self->{languages__}[$i]</option>\n";
    }
    $body .= "</select>\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"change_language\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "</form>\n</td>\n";

    # History View panel
    $body .= "<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language__}{Configuration_HistoryView}</h2>\n";

    # Emails per Page widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configPageSize\">$self->{language__}{Configuration_History}:</label><br />\n";
    $body .= "<input name=\"page_size\" id=\"configPageSize\" type=\"text\" value=\"" . $self->config_( 'page_size' ) . "\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_page_size\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n$page_size_error\n";
    $body .= sprintf( $self->{language__}{Configuration_HistoryUpdate}, $self->config_( 'page_size' ) ) if ( defined($self->{form_}{page_size}) );

    # Days of History to Keep widget
    $body .= "\n<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configHistoryDays\">$self->{language__}{Configuration_Days}:</label> <br />\n";
    $body .= "<input name=\"history_days\" id=\"configHistoryDays\" type=\"text\" value=\"" . $self->config_( 'history_days' ) . "\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_history_days\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "</form>\n$history_days_error\n";
    $body .= sprintf( $self->{language__}{Configuration_DaysUpdate}, $self->config_( 'history_days' ) ) if ( defined($self->{form_}{history_days}) );

    # Classification Insertion panel
    $body .= "</td>\n<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language__}{Configuration_ClassificationInsertion}</h2>\n";

    # Subject line modification widget
    $body .= "<table width=\"100%\" summary=\"$self->{language__}{Configuration_InsertionTableSummary}\">\n<tr>\n";
    $body .= "<th valign=\"baseline\" scope=\"row\">\n<span class=\"configurationLabel\">$self->{language__}{Configuration_SubjectLine}:</span>\n</th>\n";
    if ( $self->global_config_( 'subject' ) == 1 ) {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOn\">$self->{language__}{On}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"configSubjectOff\" name=\"toggle\" value=\"$self->{language__}{TurnOff}\" />\n";
        $body .= "<input type=\"hidden\" name=\"subject\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n</td>\n";
    } else {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOff\">$self->{language__}{Off}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"configSubjectOn\" name=\"toggle\" value=\"$self->{language__}{TurnOn}\" />\n";
        $body .= "<input type=\"hidden\" name=\"subject\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n</td>\n";
    }

    # X-Text-Classification insertion widget
    $body .= "</tr>\n<tr>\n<th valign=\"baseline\" scope=\"row\">\n<span class=\"configurationLabel\">$self->{language__}{Configuration_XTCInsertion}:</span></th>\n";
    if ( $self->global_config_( 'xtc' ) == 1 ) {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOn\">$self->{language__}{On}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"configXTCOff\" name=\"toggle\" value=\"$self->{language__}{TurnOff}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xtc\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n</td>\n";
    } else {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOff\">$self->{language__}{Off}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"configXTCOn\" name=\"toggle\" value=\"$self->{language__}{TurnOn}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xtc\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n</td>\n";
    }

    # X-POPFile-Link insertion widget
    $body .= "</tr>\n<tr>\n<th valign=\"baseline\" scope=\"row\">\n<span class=\"configurationLabel\">$self->{language__}{Configuration_XPLInsertion}:</span></th>\n";
    if ( $self->global_config_( 'xpl' ) == 1 ) {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOn\">$self->{language__}{On}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"configXPLOff\" name=\"toggle\" value=\"$self->{language__}{TurnOff}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xpl\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n</td>\n";
    } else {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOff\">$self->{language__}{Off}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"configXPLOn\" name=\"toggle\" value=\"$self->{language__}{TurnOn}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xpl\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n</td>\n";
    }
    $body .= "</tr>\n</table>\n<br />\n";

    # Listen Ports panel
    $body .= "</td>\n</tr>\n<tr>\n<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language__}{Configuration_ListenPorts}</h2>\n";

    # Insert all the items that are dynamically created from the modules that are loaded

    for my $name (sort keys %{$self->{dynamic_ui__}{configuration}}) {
        $body .= $self->{dynamic_ui__}{configuration}{$name}->configure_item( $name,
                                                                              \%{$self->{language__}},
                                                                              $self->{session_key__} );
    }


    # User Interface Port widget
    $body .= "\n<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configUIPort\">$self->{language__}{Configuration_UI}:</label><br />\n";
    $body .= "<input name=\"ui_port\" id=\"configUIPort\" type=\"text\" value=\"" . $self->config_( 'port' ) . "\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_ui_port\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n$ui_port_error";
    $body .= sprintf( $self->{language__}{Configuration_UIUpdate}, $self->config_( 'port' ) ) if ( defined($self->{form_}{ui_port}) );
    $body .= "<br />\n</td>\n";

    # TCP Connection Timeout panel
    $body .= "<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language__}{Configuration_TCPTimeout}</h2>\n";

    # TCP Conn TO widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configTCPTimeout\">$self->{language__}{Configuration_TCPTimeoutSecs}:</label><br />\n";
    $body .= "<input name=\"timeout\" type=\"text\" id=\"configTCPTimeout\" value=\"" . $self->global_config_( 'timeout' ) . "\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_timeout\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n$timeout_error";
    $body .= sprintf( $self->{language__}{Configuration_TCPTimeoutUpdate}, $self->global_config_( 'timeout' ) ) if ( defined($self->{form_}{timeout}) );
    $body .= "</td>\n";

    # Logging panel
    $body .= "<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language__}{Configuration_Logging}</h2>\n";
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configLogging\">$self->{language__}{Configuration_LoggerOutput}:</label>\n";
    $body .= "<input type=\"hidden\" value=\"$self->{session_key__}\" name=\"session\" />\n";
    $body .= "<select name=\"debug\" id=\"configLogging\">\n";
    $body .= "<option value=\"1\"";
    $body .= " selected=\"selected\"" if ( $self->global_config_( 'debug' ) == 0 );
    $body .= ">$self->{language__}{Configuration_None}</option>\n";
    $body .= "<option value=\"2\"";
    $body .= " selected=\"selected\"" if ( $self->global_config_( 'debug' ) == 1 );
    $body .= ">$self->{language__}{Configuration_ToFile}</option>\n";
    $body .= "<option value=\"3\"";
    $body .= " selected=\"selected\"" if ( $self->global_config_( 'debug' ) == 2 );
    $body .= ">$self->{language__}{Configuration_ToScreen}</option>\n";
    $body .= "<option value=\"4\"";
    $body .= " selected=\"selected\"" if ( $self->global_config_( 'debug' ) == 3 );
    $body .= ">$self->{language__}{Configuration_ToScreenFile}</option>\n";
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"submit_debug\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "</form>\n</td>\n</tr>\n</table>\n";

    http_ok($self, $client,$body,0);
}

# ---------------------------------------------------------------------------------------------
#
# security_page - get the security configuration page
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub security_page
{
    my ( $self, $client ) = @_;

    my $body;
    my $server_error = '';
    my $port_error   = '';

    $self->config_( 'password', $self->{form_}{password} )         if ( defined($self->{form_}{password}) );
    $self->config_( 'local', $self->{form_}{localui}-1 )      if ( defined($self->{form_}{localui}) );
    $self->config_( 'update_check', $self->{form_}{update_check}-1 ) if ( defined($self->{form_}{update_check}) );
    $self->config_( 'send_stats', $self->{form_}{send_stats}-1 )   if ( defined($self->{form_}{send_stats}) );

    for my $name (keys %{$self->{dynamic_ui__}{security}}) {
        $body .= $self->{dynamic_ui__}{security}{$name}->validate_item( $name,
                                                                             \%{$self->{language__}},
                                                                             \%{$self->{form_}} );
    }

    for my $name (keys %{$self->{dynamic_ui__}{chain}}) {
        $body .= $self->{dynamic_ui__}{chain}{$name}->validate_item( $name,
                                                                             \%{$self->{language__}},
                                                                             \%{$self->{form_}} );
    }

    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language__}{Security_MainTableSummary}\">\n<tr>\n";

    # Stealth Mode / Server Operation panel
    $body .= "<td class=\"settingsPanel\" width=\"50%\" valign=\"top\">\n";
    $body .= "<h2 class=\"security\">$self->{language__}{Security_Stealth}</h2>\n";

    for my $name (sort keys %{$self->{dynamic_ui__}{security}}) {
        $body .= $self->{dynamic_ui__}{security}{$name}->configure_item( $name,
                                                                              \%{$self->{language__}},
                                                                              $self->{session_key__} );
    }

    # Accept HTTP from Remote Machines widget
    $body .= "<span class=\"securityLabel\">$self->{language__}{Security_UI}:</span><br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td>\n";
    if ( $self->config_( 'local' ) == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language__}{Security_NoStealthMode}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityAcceptHTTPOn\" name=\"toggle\" value=\"$self->{language__}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"localui\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language__}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityAcceptHTTPOff\" name=\"toggle\" value=\"$self->{language__}{ChangeToNo} (Stealth Mode)\" />\n";
        $body .= "<input type=\"hidden\" name=\"localui\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";

    # Secure Password Authentication/AUTH panel
    $body .= "<hr><h2 class=\"security\">$self->{language__}{Security_AUTHTitle}</h2>\n";

    # optional widgets placement
    $body .= "<div class=\"securityAuthWidgets\">\n";

    for my $name (sort keys %{$self->{dynamic_ui__}{chain}}) {
        $body .= $self->{dynamic_ui__}{chain}{$name}->configure_item( $name,
                                                                              \%{$self->{language__}},
                                                                              $self->{session_key__} );
    }

    # end optional widgets placement
    $body .= "</div>\n</td>\n";

    # User Interface Password panel
    $body .= "<td class=\"settingsPanel\" width=\"50%\" valign=\"top\" >\n";
    $body .= "<h2 class=\"security\">$self->{language__}{Security_PasswordTitle}</h2>\n";

    # optional widget placement
    $body .= "<div class=\"securityPassWidget\">\n";

    # Password widget
    $body .= "<form action=\"/security\" method=\"post\">\n";
    $body .= "<label class=\"securityLabel\" for=\"securityPassword\">$self->{language__}{Security_Password}:</label> <br />\n";
    $body .= "<input type=\"password\" id=\"securityPassword\" name=\"password\" value=\"" . $self->config_( 'password' ) . "\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_server\" value=\"$self->{language__}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    $body .= sprintf( $self->{language__}{Security_PasswordUpdate}, $self->config_( 'password' ) ) if ( defined($self->{form_}{password}) );

   # end optional widget placement
   $body .= "</div>\n";

    # Automatic Update Checking panel
    $body .= "<hr><h2 class=\"security\">$self->{language__}{Security_UpdateTitle}</h2>\n";

    # Check Daily for Updates widget
    $body .= "<span class=\"securityLabel\">$self->{language__}{Security_Update}:</span><br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td>\n";
    if ( $self->config_( 'update_check' ) == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language__}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityUpdateCheckOff\" name=\"toggle\" value=\"$self->{language__}{ChangeToNo}\" />\n";
        $body .= "<input type=\"hidden\" name=\"update_check\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language__}{No}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityUpdateCheckOn\" name=\"toggle\" value=\"$self->{language__}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"update_check\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";

    # explanation of same
    $body .= "<div class=\"securityExplanation\">$self->{language__}{Security_ExplainUpdate}</div>\n";

    # Reporting Statistics panel
    $body .= "<hr><h2 class=\"security\">$self->{language__}{Security_StatsTitle}</h2>\n";

    # Send Statistics Daily widget
    $body .= "<span class=\"securityLabel\">$self->{language__}{Security_Stats}:</span>\n<br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td>\n";
    if ( $self->config_( 'send_stats' ) == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language__}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securitySendStatsOff\" name=\"toggle\" value=\"$self->{language__}{ChangeToNo}\" />\n";
        $body .= "<input type=\"hidden\" name=\"send_stats\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language__}{No}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securitySendStatsOn\" name=\"toggle\" value=\"$self->{language__}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"send_stats\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";
    # explanation of same
    $body .= "<div class=\"securityExplanation\">$self->{language__}{Security_ExplainStats}</div>\n</td>\n</tr>\n";

    $body .= "</table>\n";

    http_ok($self, $client,$body,3);
}

# ---------------------------------------------------------------------------------------------
#
# pretty_number - format a number with ,s every 1000
#
# $number       The number to format
#
# TODO: replace this with something that uses locale information to format numbers in a way
# that is specific to the locale since not everyone likes ,s every 1000.
#
# ---------------------------------------------------------------------------------------------
sub pretty_number
{
    my ( $self, $number ) = @_;

    $number = reverse $number;
    $number =~ s/(\d{3})/$1,/g;
    $number = reverse $number;
    $number =~ s/^,(.*)/$1/;

    return $number;
}

# ---------------------------------------------------------------------------------------------
#
# advanced_page - very advanced configuration options
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub advanced_page
{
    my ( $self, $client ) = @_;

    my $add_message = '';
    my $deletemessage = '';
    if ( defined($self->{form_}{newword}) ) {
        my $result = $self->{classifier__}->add_stopword( $self->{form_}{newword} );
        if ( $result == 0 ) {
            $add_message = "<blockquote><div class=\"error02\"><b>$self->{language__}{Advanced_Error2}</b></div></blockquote>";
        }
    }

    if ( defined($self->{form_}{word}) ) {
      $self->log_($self->{form_}{word} );
        my $result = $self->{classifier__}->remove_stopword( $self->{form_}{word} );
        if ( $result == 0 ) {
            $deletemessage = "<blockquote><div class=\"error02\"><b>$self->{language__}{Advanced_Error2}</b></div></blockquote>";
        }
    }

    # title and heading
    my $body = "<h2 class=\"advanced\">$self->{language__}{Advanced_StopWords}</h2>\n";
    $body .= "$self->{language__}{Advanced_Message1}\n<br /><br />\n<table summary=\"$self->{language__}{Advanced_MainTableSummary}\">\n";

    # the word census
    my $last = '';
    my $need_comma = 0;
    my $groupCounter = 0;
    my $groupSize = 5;
    my $firstRow = 1;
    for my $word (sort keys %{$self->{classifier__}->get_stop_word_list()}) {
        $word =~ /^(.)/;
        if ( $1 ne $last )  {
            if (! $firstRow) {
                $body .= "</td></tr>\n";
            } else {
                $firstRow = 0;
            }
            $body .= "<tr><th scope=\"row\" class=\"advancedAlphabet";
            if ($groupCounter == $groupSize) {
                $body .= "GroupSpacing";
            }
            $body .= "\"><b>$1</b></th>\n";
            $body .= "<td class=\"advancedWords";
            if ($groupCounter == $groupSize) {
                $body .= "GroupSpacing";
                $groupCounter = 0;
            }
            $body .= "\">";


            $last = $1;
            $need_comma = 0;
            $groupCounter += 1;
        }
        if ( $need_comma == 1 ) {
            $body .= ", $word";
        } else {
            $body .= $word;
            $need_comma = 1;
        }
    }
    $body .= "</td></tr>\n</table>\n";

    # optional widget placement
    $body .= "<div class=\"advancedWidgets\">\n";

    # Add Word widget
    $body .= "<form action=\"/advanced\">\n";
    $body .= "<label class=\"advancedLabel\" for=\"advancedAddWordText\">$self->{language__}{Advanced_AddWord}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "<input type=\"text\" id=\"advancedAddWordText\" name=\"newword\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"add\" value=\"$self->{language__}{Add}\" />\n";
    $body .= "</form>\n$add_message\n";

    # Remove Word widget
    $body .= "<form action=\"/advanced\">\n";
    $body .= "<label class=\"advancedLabel\" for=\"advancedRemoveWordText\">$self->{language__}{Advanced_RemoveWord}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "<input type=\"text\" id=\"advancedRemoveWordText\" name=\"word\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"remove\" value=\"$self->{language__}{Remove}\" />\n";
    $body .= "</form>\n$deletemessage\n";

    # end optional widget placement
    $body .= "</div>\n";

    http_ok($self, $client,$body,5);
}

# ---------------------------------------------------------------------------------------------
#
# magnet_page - the list of bucket magnets
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub magnet_page
{
    my ( $self, $client ) = @_;

    my $magnet_message = '';
    if ( ( defined($self->{form_}{type}) ) && ( $self->{form_}{bucket} ne '' ) && ( $self->{form_}{text} ne '' ) ) {
        my $found = 0;
        for my $bucket ($self->{classifier__}->get_buckets_with_magnets()) {
            my %magnets = $self->{classifier__}->get_magnets( $bucket, $self->{form_}{type} );
            if ( defined( $magnets{$self->{form_}{text}}) ) {
                $found  = 1;
                $magnet_message = "<blockquote>\n<div class=\"error02\">\n<b>";
                $magnet_message .= sprintf( $self->{language__}{Magnet_Error1}, "$self->{form_}{type}: $self->{form_}{text}", $bucket );
                $magnet_message .= "</b>\n</div>\n</blockquote>\n";
            }
        }

        if ( $found == 0 )  {
            for my $bucket ($self->{classifier__}->get_buckets_with_magnets()) {
            my %magnets = $self->{classifier__}->get_magnets( $bucket, $self->{form_}{type} );
                for my $from (keys %magnets)  {
                    if ( ( $self->{form_}{text} =~ /\Q$from\E/ ) || ( $from =~ /\Q$self->{form_}{text}\E/ ) )  {
                        $found = 1;
                        $magnet_message = "<blockquote><div class=\"error02\"><b>" . sprintf( $self->{language__}{Magnet_Error2}, "$self->{form_}{type}: $self->{form_}{text}", "$self->{form_}{type}: $from", $bucket ) . "</b></div></blockquote>";
                    }
                }
            }
        }

        if ( $found == 0 ) {

            # It is possible to type leading or trailing white space in a magnet definition
            # which can later cause mysterious failures because the whitespace is eaten by
            # the browser when the magnet is displayed but is matched in the regular expression
            # that does the magnet matching and will cause failures... so strip off the whitespace

            $self->{form_}{text} =~ s/^[ \t]+//;
            $self->{form_}{text} =~ s/[ \t]+$//;

            $self->{classifier__}->create_magnet( $self->{form_}{bucket}, $self->{form_}{type}, $self->{form_}{text});
            $magnet_message = "<blockquote>" . sprintf( $self->{language__}{Magnet_Error3}, "$self->{form_}{type}: $self->{form_}{text}", $self->{form_}{bucket} ) . "</blockquote>";
        }
    }

    if ( defined($self->{form_}{dtype}) )  {
        $self->{classifier__}->delete_magnet( $self->{form_}{bucket}, $self->{form_}{dtype}, $self->{form_}{dmagnet});
    }

    # Current Magnets panel
    my $body = "<h2 class=\"magnets\">$self->{language__}{Magnet_CurrentMagnets}</h2>\n";

    # magnet listing headings
    $body .= "<table width=\"75%\" class=\"magnetsTable\" summary=\"$self->{language__}{Magnet_MainTableSummary}\">\n";
    $body .= "<caption>$self->{language__}{Magnet_Message1}</caption>\n";
    $body .= "<tr>\n<th class=\"magnetsLabel\" scope=\"col\">$self->{language__}{Magnet}</th>\n";
    $body .= "<th class=\"magnetsLabel\" scope=\"col\">$self->{language__}{Bucket}</th>\n";
    $body .= "<th class=\"magnetsLabel\" scope=\"col\">$self->{language__}{Delete}</th>\n</tr>\n";

    # magnet listing
    my $stripe = 0;
    for my $bucket ($self->{classifier__}->get_buckets_with_magnets()) {
        for my $type ($self->{classifier__}->get_magnet_types_in_bucket($bucket)) {
            for my $magnet ($self->{classifier__}->get_magnets( $bucket, $type))  {
                $body .= "<tr ";
                if ( $stripe )  {
                    $body .= "class=\"rowEven\"";
                } else {
                    $body .= "class=\"rowOdd\"";
                }
                # to validate, must replace & with &amp;
                # stan todo note: come up with a smarter regex, this one's a bludgeon
                my $validatingMagnet = $magnet;
                $validatingMagnet =~ s/&/&amp;/g;
                $validatingMagnet =~ s/</&lt;/g;
                $validatingMagnet =~ s/>/&gt;/g;

                $body .= ">\n<td>$type: $validatingMagnet</td>\n";
                $body .= "<td><font color=\"" . $self->{classifier__}->get_bucket_color($bucket) . "\">$bucket</font></td>\n";

                # Remove magnet button

                $body .= "<td>\n<form class=\"magnetsDelete\" style=\"margin: 0\" action=\"/magnets\">\n";
                $body .= "<input type=\"submit\" class=\"deleteButton\" name=\"deleteMagnet\" value=\"$self->{language__}{Delete}\" />\n";
                $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
                $body .= "<input type=\"hidden\" name=\"dtype\" value=\"$type\" />\n";
                $body .= "<input type=\"hidden\" name=\"dmagnet\" value=\"$validatingMagnet\" />\n";
                $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
                $body .= "</form>\n</td>\n";
                $body .= "</tr>";
                $stripe = 1 - $stripe;
            }
        }
    }

    $body .= "</table>\n<br /><br />\n<hr />\n";

    # Create New Magnet panel
    $body .= "<h2 class=\"magnets\">$self->{language__}{Magnet_CreateNew}</h2>\n";
    $body .= "<table cellspacing=\"0\" summary=\"\">\n<tr>\n<td>\n";
    $body .= "<b>$self->{language__}{Magnet_Explanation}\n";
    $body .= "</td>\n</tr>\n</table>\n";

    # optional widget placement
    $body .= "<div class=\"magnetsNewWidget\">\n";

    # New Magnets form
    $body .= "<form action=\"/magnets\">\n";

    # Magnet Type widget
    $body .= "<label class=\"magnetsLabel\" for=\"magnetsAddType\">$self->{language__}{Magnet_MagnetType}:</label><br />\n";
    $body .= "<select name=\"type\" id=\"magnetsAddType\">\n<option value=\"from\">\n$self->{language__}{From}</option>\n";
    $body .= "<option value=\"to\">\n$self->{language__}{To}</option>\n";
    $body .= "<option value=\"subject\">\n$self->{language__}{Subject}</option>\n</select>\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n<br /><br />\n";

    # Value widget
    $body .= "<label class=\"magnetsLabel\" for=\"magnetsAddText\">$self->{language__}{Magnet_Value}:</label><br />\n";
    $body .= "<input type=\"text\" name=\"text\" id=\"magnetsAddText\" />\n<br /><br />\n";

    # Always Goes to Bucket widget
    $body .= "<label class=\"magnetsLabel\" for=\"magnetsAddBucket\">$self->{language__}{Magnet_Always}:</label><br />\n";
    $body .= "<select name=\"bucket\" id=\"magnetsAddBucket\">\n<option value=\"\"></option>\n";

    my @buckets = $self->{classifier__}->get_buckets();
    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"create\" value=\"$self->{language__}{Create}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n$magnet_message\n";
    $body .="<br />\n";

    # end optional widget placement
    $body .= "</div>\n";

    http_ok($self, $client,$body,4);
}

# ---------------------------------------------------------------------------------------------
#
# bucket_page - information about a specific bucket
#
# $client     The web browser to send the results to
# ---------------------------------------------------------------------------------------------
sub bucket_page
{
    my ( $self, $client ) = @_;

    my $bucket_count = $self->{classifier__}->get_bucket_word_count( $self->{form_}{showbucket} );

    my $body = "<h2 class=\"buckets\">";
    $body .= sprintf( $self->{language__}{SingleBucket_Title}, "<font color=\"" . $self->{classifier__}->get_bucket_color($self->{form_}{showbucket}) . "\">$self->{form_}{showbucket}</font>");
    $body .= "</h2>\n<table summary=\"\">\n<tr>\n<th scope=\"row\" class=\"bucketsLabel\">$self->{language__}{SingleBucket_WordCount}</th>\n";
    $body .= "<td>&nbsp;</td>\n<td align=\"right\">\n";
    $body .= pretty_number( $self, $bucket_count);
    $body .= "</td>\n<td>\n(" . sprintf( $self->{language__}{SingleBucket_Unique}, pretty_number( $self,  $self->{classifier__}->get_bucket_unique_count($self->{form_}{showbucket})) ). ")";
    $body .= "</td>\n</tr>\n<tr>\n<th scope=\"row\" class=\"bucketsLabel\">$self->{language__}{SingleBucket_TotalWordCount}</th>\n";
    $body .= "<td>&nbsp;</td>\n<td align=\"right\">\n" . pretty_number( $self, $self->{classifier__}->get_word_count());

    my $percent = "0%";
    if ( $self->{classifier__}->get_word_count() > 0 )  {
        $percent = int( 10000 * $bucket_count / $self->{classifier__}->get_word_count() ) / 100;
        $percent = "$percent%";
    }
    $body .= "</td>\n<td></td>\n</tr>\n<tr><td colspan=\"3\"><hr /></td></tr>\n";
    $body .= "<tr>\n<th scope=\"row\" class=\"bucketsLabel\">$self->{language__}{SingleBucket_Percentage}</th>\n";
    $body .= "<td></td>\n<td align=\"right\">$percent</td>\n<td></td>\n</tr>\n</table>\n";

    $body .= "<h2 class=\"buckets\">";
    $body .= sprintf( $self->{language__}{SingleBucket_WordTable},  "<font color=\"" . $self->{classifier__}->get_bucket_color($self->{form_}{showbucket}) . "\">$self->{form_}{showbucket}" ) ;
    $body .= "</font>\n</h2>\n$self->{language__}{SingleBucket_Message1}\n<br /><br />\n<table summary=\"$self->{language__}{Bucket_WordListTableSummary}\">\n";
    $body .= "<tr><td colspan=2>";

    for my $i (@{$self->{classifier__}->get_bucket_word_list($self->{form_}{showbucket})}) {
        if ( defined($i) ) {
            my $j = $i;
            $j =~ /^\|(.)/;
            my $first = $1;

            if ( defined( $self->{form_}{showletter} ) && ( $first eq $self->{form_}{showletter} ) ) {
                # Split the entries on the double bars

                my %temp;

                while ( $j =~ m/\G\|(.*?) L?\-?[\.\d]+\|/g ) {
                    my $word = $1;
                    $temp{$word} = int( exp( $self->{classifier__}->get_value_( $self->{form_}{showbucket}, $word ) ) * $bucket_count + 1 );
		}

                $body .= "</td></tr><tr><td colspan=2>&nbsp;</td></tr><tr>\n<td valign=\"top\">\n<b>$first</b>\n</td>\n<td valign=\"top\">\n<table><tr valign=\"top\">";

                my $count = 0;

                for my $word (sort { $temp{$b} <=> $temp{$a} } keys %temp) {
		    $body .= "</tr><tr valign=\"top\">" if ( ( $count % 6 ) ==  0 );
                    $body .= "<td><a class=\"wordListLink\" href=\"\/buckets\?session=$self->{session_key__}\&amp;lookup=Lookup\&amp;word=$word#Lookup\"><b>$word</b><\/a></td><td>$temp{$word}</td><td>&nbsp;</td>";
                    $count += 1;
		}

                $body .= "</tr></table></td>\n</tr>\n<tr><td colspan=2>&nbsp;</td></tr><tr><td colspan=2>";

	    } else {
                $j = '';

                $body .= "<a href=/buckets?session=$self->{session_key__}\&amp;showbucket=$self->{form_}{showbucket}\&amp;showletter=$first><b>$first</b></a>\n";
            }
        }
    }

    $body .= "</td></tr>";
    $body .= "</table>\n";

    http_ok($self, $client,$body,1);
}

# ---------------------------------------------------------------------------------------------
#
# bar_chart_100 - Output an HTML bar chart
#
# %values       A hash of bucket names with values in series 0, 1, 2, ...
#
# ---------------------------------------------------------------------------------------------
sub bar_chart_100
{
    my ( $self, %values ) = @_;
    my $body = '';
    my $total_count = 0;
    my @xaxis = sort keys %values;
    my @series = sort keys %{$values{$xaxis[0]}};

    for my $bucket (@xaxis)  {
        $total_count += $values{$bucket}{0};
    }

    for my $bucket (@xaxis)  {
        $body .= "<tr>\n<td align=\"left\"><font color=\"". $self->{classifier__}->get_bucket_color($bucket) . "\">$bucket</font></td>\n<td>&nbsp;</td>";

        for my $s (@series) {
            my $value = $values{$bucket}{$s} || 0;
            my $count   = $self->pretty_number( $value );
            my $percent = '';

            if ( $s == 0 ) {
                if ( $total_count == 0 ) {
                    $percent = " (0%)";
                } else {
                   $percent = " ( " . int( $value * 10000 / $total_count ) / 100;
                    $percent .= "%)";
                }
	    }

            $body .= "\n<td align=\"right\">$count$percent</td>";
	}
        $body .= "\n</tr>\n";
    }

    my $colspan = 3;

    $body .= "<tr>\n<td colspan=\"$colspan\">&nbsp;</td>\n</tr>\n<tr>\n<td colspan=\"$colspan\">\n";

    if ( $total_count != 0 ) {
        $body .= "<table class=\"barChart\" width=\"100%\" summary=\"$self->{language__}{Bucket_BarChartSummary}\">\n<tr>\n";
        foreach my $bucket (@xaxis) {
            my $percent = int( $values{$bucket}{0} * 10000 / $total_count ) / 100;
            if ( $percent != 0 )  {
                $body .= "<td bgcolor=\"" . $self->{classifier__}->get_bucket_color($bucket) . "\" title=\"$bucket ($percent%)\" width=\"";
                $body .= (int($percent)<1)?1:int($percent);
                $body .= "%\"><img src=\"pix.gif\" alt=\"\" height=\"20\" width=\"1\" /></td>\n";
            }
        }
        $body .= "</tr>\n</table>";
    }

    $body .= "</td>\n</tr>\n";

    if ( $total_count != 0 )  {
        $body .= "<tr>\n<td colspan=\"$colspan\" align=\"right\"><span class=\"graphFont\">100%</span></td>\n</tr>\n";
    }

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# corpus_page - the corpus management page
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub corpus_page
{
    my ( $self, $client ) = @_;

    if ( defined($self->{form_}{reset_stats}) ) {
        $self->global_config_( 'mcount', 0 );
        $self->global_config_( 'ecount', 0 );
        for my $bucket ($self->{classifier__}->get_buckets()) {
            $self->{classifier__}->set_bucket_parameter( $bucket, 'count', 0 );
            $self->{classifier__}->set_bucket_parameter( $bucket, 'fpcount', 0 );
            $self->{classifier__}->set_bucket_parameter( $bucket, 'fncount', 0 );
        }
        $self->{classifier__}->write_parameters();
        my $lasttime = localtime;
        $self->config_( 'last_reset', $lasttime );
        $self->{configuration__}->save_configuration();
    }

    if ( defined($self->{form_}{showbucket}) )  {
        bucket_page( $self, $client);
        return;
    }

    my $result;
    my $create_message = '';
    my $deletemessage = '';
    my $rename_message = '';

    if ( ( defined($self->{form_}{color}) ) && ( defined($self->{form_}{bucket}) ) ) {
        open COLOR, '>' . $self->module_config_( 'bayes', 'corpus' ) . "/$self->{form_}{bucket}/color";
        print COLOR "$self->{form_}{color}\n";
        close COLOR;
        $self->{classifier__}->set_bucket_color($self->{form_}{bucket}, $self->{form_}{color});
    }

    if ( ( defined($self->{form_}{bucket}) ) && ( defined($self->{form_}{subject}) ) && ( $self->{form_}{subject} > 0 ) ) {
        $self->{classifier__}->set_bucket_parameter( $self->{form_}{bucket}, 'subject', $self->{form_}{subject} - 1 );
    }

    if ( ( defined($self->{form_}{bucket}) ) &&  ( defined($self->{form_}{quarantine}) ) && ( $self->{form_}{quarantine} > 0 ) ) {
        $self->{classifier__}->set_bucket_parameter( $self->{form_}{bucket}, 'quarantine', $self->{form_}{quarantine} - 1 );
    }

    if ( ( defined($self->{form_}{cname}) ) && ( $self->{form_}{cname} ne '' ) ) {
        if ( $self->{form_}{cname} =~ /[^[:lower:]\-_]/ )  {
            $create_message = "<blockquote><div class=\"error01\">$self->{language__}{Bucket_Error1}</div></blockquote>";
        } else {
            if ( ( defined($self->{classifier__}->get_bucket_word_count($self->{form_}{cname})) ) && ( $self->{classifier__}->get_bucket_word_count($self->{form_}{cname}) > 0 ) )  {
                $create_message = "<blockquote><b>" . sprintf( $self->{language__}{Bucket_Error2}, $self->{form_}{cname} ) . "</b></blockquote>";
            } else {
                $self->{classifier__}->create_bucket( $self->{form_}{cname} );
                $create_message = "<blockquote><b>" . sprintf( $self->{language__}{Bucket_Error3}, $self->{form_}{cname} ) . "</b></blockquote>";
            }
       }
    }

    if ( ( defined($self->{form_}{delete}) ) && ( $self->{form_}{name} ne '' ) ) {
        $self->{form_}{name} = lc($self->{form_}{name});
    $self->{classifier__}->delete_bucket( $self->{form_}{name} );
        $deletemessage = "<blockquote><b>" . sprintf( $self->{language__}{Bucket_Error6}, $self->{form_}{name} ) . "</b></blockquote>";
    }

    if ( ( defined($self->{form_}{newname}) ) && ( $self->{form_}{oname} ne '' ) ) {
        if ( $self->{form_}{newname} =~ /[^[:lower:]\-_]/ )  {
            $rename_message = "<blockquote><div class=\"error01\">$self->{language__}{Bucket_Error1}</div></blockquote>";
        } else {
            $self->{form_}{oname} = lc($self->{form_}{oname});
            $self->{form_}{newname} = lc($self->{form_}{newname});
        $self->{classifier__}->rename_bucket( $self->{form_}{oname}, $self->{form_}{newname} );            
            $rename_message = "<blockquote><b>" . sprintf( $self->{language__}{Bucket_Error5}, $self->{form_}{oname}, $self->{form_}{newname} ) . "</b></blockquote>";
        }
    }

    # Summary panel
    my $body = "<h2 class=\"buckets\">$self->{language__}{Bucket_Title}</h2>\n";

    # column headings
    $body .= "<table class=\"bucketsTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" summary=\"$self->{language__}{Bucket_MaintenanceTableSummary}\">\n<tr>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\">$self->{language__}{Bucket_BucketName}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language__}{Bucket_WordCount}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language__}{Bucket_UniqueWords}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"center\">$self->{language__}{Bucket_SubjectModification}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"center\">$self->{language__}{Bucket_Quarantine}</th>\n";
    $body .= "<th width=\"2%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"left\">$self->{language__}{Bucket_ChangeColor}</th>\n</tr>\n";

    my @buckets = $self->{classifier__}->get_buckets();
    my $stripe = 0;

    my $total_count = 0;
    foreach my $bucket (@buckets) {
        $total_count += $self->{classifier__}->get_bucket_parameter( $bucket, 'count' );
    }

    foreach my $bucket (@buckets) {
        my $number  = pretty_number( $self,  $self->{classifier__}->get_bucket_word_count($bucket) );
        my $unique  = pretty_number( $self,  $self->{classifier__}->get_bucket_unique_count($bucket) );

        $body .= "<tr";
        if ( $stripe == 1 )  {
            $body .= " class=\"rowEven\"";
        } else {
            $body .= " class=\"rowOdd\"";
        }
        $stripe = 1 - $stripe;
        $body .= "><td><a href=\"/buckets?session=$self->{session_key__}&amp;showbucket=$bucket\">\n";
        $body .= "<font color=\"" . $self->{classifier__}->get_bucket_color($bucket) . "\">$bucket</font></a></td>\n";
        $body .= "<td width=\"1%\">&nbsp;</td><td align=\"right\">$number</td><td width=\"1%\">&nbsp;</td>\n";
        $body .= "<td align=\"right\">$unique</td><td width=\"1%\">&nbsp;</td>";

        if ( $self->global_config_( 'subject' ) == 1 )  {

            # Subject Modification on/off widget

            $body .= "<td align=\"center\">\n";
            if ( $self->{classifier__}->get_bucket_parameter( $bucket, 'subject' ) == 0 ) {
                $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
                $body .= "<span class=\"bucketsWidgetStateOff\">$self->{language__}{Off} </span>\n";
                $body .= "<input type=\"submit\" class=\"toggleOn\" name=\"toggle\" value=\"$self->{language__}{TurnOn}\" />\n";
                $body .= "<input type=\"hidden\" name=\"subject\" value=\"2\" />\n";
                $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
                $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" /></form></td>\n";
            } else {
                $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
                $body .= "<span class=\"bucketsWidgetStateOn\">$self->{language__}{On} </span>\n";
                $body .= "<input type=\"submit\" class=\"toggleOff\" name=\"toggle\" value=\"$self->{language__}{TurnOff}\" />\n";
                $body .= "<input type=\"hidden\" name=\"subject\" value=\"1\" />\n";
                $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
                $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" /></form></td>\n";
            }
        } else {
            $body .= "<td align=\"center\">\n$self->{language__}{Bucket_DisabledGlobally}\n</td>\n";
        }

        # Quarantine on/off widget

        $body .= "<td width=\"1%\">&nbsp;</td><td align=\"center\">\n";
        if ( $self->{classifier__}->get_bucket_parameter( $bucket, 'quarantine' ) == 0 ) {
            $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
            $body .= "<span class=\"bucketsWidgetStateOff\">$self->{language__}{Off} </span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" name=\"toggle\" value=\"$self->{language__}{TurnOn}\" />\n";
            $body .= "<input type=\"hidden\" name=\"quarantine\" value=\"2\" />\n";
            $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" /></form></td>\n";
        } else {
            $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
            $body .= "<span class=\"bucketsWidgetStateOn\">$self->{language__}{On} </span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOff\" name=\"toggle\" value=\"$self->{language__}{TurnOff}\" />\n";
            $body .= "<input type=\"hidden\" name=\"quarantine\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" /></form></td>\n";
        }

        # Change Color widget

        $body .= "<td>&nbsp;</td>\n<td align=\"left\">\n<table class=\"colorChooserTable\" cellpadding=\"0\" cellspacing=\"1\" summary=\"\">\n<tr>\n";
        my $color = $self->{classifier__}->get_bucket_color($bucket);
        $body .= "<td bgcolor=\"$color\">\n<img class=\"colorChooserImg\" border=\"0\" alt='" . sprintf( $self->{language__}{Bucket_CurrentColor}, $bucket, $color ) . "' src=\"pix.gif\" width=\"10\" height=\"20\" /></td>\n<td>&nbsp;</td>\n";
        for my $i ( 0 .. $#{$self->{classifier__}->{possible_colors__}} ) {
            my $color = $self->{classifier__}->{possible_colors__}[$i];
            if ( $color ne $self->{classifier__}->get_bucket_color($bucket) )  {
                $body .= "<td bgcolor=\"$color\" title=\"". sprintf( $self->{language__}{Bucket_SetColorTo}, $bucket, $color ) . "\">\n";
                $body .= "<a class=\"colorChooserLink\" href=\"/buckets?color=$color&amp;bucket=$bucket&amp;session=$self->{session_key__}\">\n";
                $body .= "<img class=\"colorChooserImg\" border=\"0\" alt=\"". sprintf( $self->{language__}{Bucket_SetColorTo}, $bucket, $color ) . "\" src=\"pix.gif\" width=\"10\" height=\"20\" /></a>\n";
                $body .= "</td>\n";
            }
        }
        $body .= "</tr></table></td>\n";
        # Close odd/even row
        $body .= "</tr>\n";
    }

    # figure some performance numbers

    my $number = pretty_number( $self,  $self->{classifier__}->get_word_count() );
    my $pmcount = pretty_number( $self,  $self->global_config_( 'mcount' ) );
    my $pecount = pretty_number( $self,  $self->global_config_( 'ecount' ) );
    my $accuracy = $self->{language__}{Bucket_NotEnoughData};
    my $percent = 0;
    if ( $self->global_config_( 'mcount' ) > 0 )  {
        $percent = int( 10000 * ( $self->global_config_( 'mcount' ) - $self->global_config_( 'ecount' ) ) / $self->global_config_( 'mcount' ) ) / 100;
        $accuracy = "$percent%";
    }

     # finish off Summary panel

    $body .= "<tr>\n<td colspan=\"3\"><hr /></td>\n</tr>\n";
    $body .= "<tr>\n<th class=\"bucketsLabel\" scope=\"row\">$self->{language__}{Total}</th>\n<td width=\"1%\"></td>\n";
    $body .= "<td align=\"right\">$number</td>\n<td></td>\n<td></td>\n</tr>\n</table>\n<br />\n";

    # middle panel group
    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language__}{Bucket_StatisticsTableSummary}\">\n";

    # Classification Accuracy panel
    $body .= "<tr>\n<td class=\"settingsPanel\" valign=\"top\" width=\"33%\" align=\"center\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language__}{Bucket_ClassificationAccuracy}</h2>\n";

    $body .= "<table summary=\"\">\n";
    # emails classified line
    $body .= "<tr>\n<th scope=\"row\" align=\"left\">$self->{language__}{Bucket_EmailsClassified}:</th>\n";
    $body .= "<td align=\"right\">$pmcount</td>\n</tr>\n";
    # classification errors line
    $body .= "<tr>\n<th scope=\"row\" align=\"left\">$self->{language__}{Bucket_ClassificationErrors}:</th>\n";
    $body .= "<td align=\"right\">$pecount</td>\n</tr>\n";
    # rules
    $body .= "<tr>\n<td colspan=\"2\"><hr /></td>\n</tr>\n";

    # $body .= "<tr>\n<td colspan=\"2\"><hr /></td></tr>\n";
    $body .= "<tr>\n<th scope=\"row\" align=\"left\">";
    $body .= "$self->{language__}{Bucket_Accuracy}:</th>\n<td align=\"right\">$accuracy</td>\n</tr>\n";

    if ( $percent > 0 )  {
        $body .= "<tr>\n<td colspan=\"2\">&nbsp;</td>\n</tr>\n<tr>\n<td colspan=\"2\">\n";
        $body .= "<table class=\"barChart\" id=\"accuracyChart\" width=\"100%\" cellspacing=\"0\"";
        $body .= " cellpadding=\"0\" border=\"0\" summary=\"$self->{language__}{Bucket_AccuracyChartSummary}\">\n";
        $body .= "<tr>\n";

        for my $i ( 0..49 ) {
            $body .= "<td valign=\"middle\" class=";
            $body .= "\"accuracy0to49\"" if ( $i < 25 );
            $body .= "\"accuracy50to93\"" if ( ( $i > 24 ) && ( $i < 47 ) );
            $body .= "\"accuracy94to100\"" if ( $i > 46 );
            $body .= ">";
            if ( ( $i * 2 ) < $percent ) {
                $body .= "<img class=\"lineImg\" src=\"black.gif\" height=\"4\" width=\"6\" alt=\"\" />";
            } else {
                $body .= "<img src=\"pix.gif\" height=\"4\" width=\"6\" alt=\"\" />";
            }
            $body .= "</td>\n";
        }

        # Extra td to hold the vertical spacer gif

        $body .= "<td><img src=\"pix.gif\" height=\"10\" width=\"1\" alt=\"\" /></td>";
        $body .= "</tr>\n<tr>\n";
        $body .= "<td colspan=\"25\" align=\"left\"><span class=\"graphFont\">0%</span></td>\n";
        $body .= "<td colspan=\"26\" align=\"right\"><span class=\"graphFont\">100%</span></td>\n</tr></table>\n";
    }


    $body .= "</td></tr>\n</table>\n";
    $body .= "<form action=\"/buckets\">\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"reset_stats\" value=\"$self->{language__}{Bucket_ResetStatistics}\" />\n";

    if ( $self->config_( 'last_reset' ) ne '' ) {
        $body .= "<br />\n($self->{language__}{Bucket_LastReset}: " . $self->config_( 'last_reset' ) . ")\n";
    }

    # Emails Classified panel
    $body .= "</form>\n</td>\n<td class=\"settingsPanel\" valign=\"top\" width=\"33%\" align=\"center\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language__}{Bucket_EmailsClassifiedUpper}</h2>\n";

    $body .= "<table summary=\"\">\n<tr>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"left\">$self->{language__}{Bucket}</th>\n<th>&nbsp;</th>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language__}{Bucket_ClassificationCount}</th>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language__}{Bucket_ClassificationFP}</th>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language__}{Bucket_ClassificationFN}</th>\n</tr>\n";


    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket}{0} = $self->{classifier__}->get_bucket_parameter( $bucket, 'count' );
        $bar_values{$bucket}{1} = $self->{classifier__}->get_bucket_parameter( $bucket, 'fpcount' );
        $bar_values{$bucket}{2} = $self->{classifier__}->get_bucket_parameter( $bucket, 'fncount' );
    }

    $body .= bar_chart_100( $self, %bar_values );

    # Word Counts panel
    $body .= "</table>\n</td>\n<td class=\"settingsPanel\" width=\"34%\" valign=\"top\" align=\"center\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language__}{Bucket_WordCounts}</h2>\n<table summary=\"\">\n<tr>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"left\">$self->{language__}{Bucket}</th>\n<th>&nbsp;</th>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language__}{Bucket_WordCount}</th>\n</tr>\n";

    for my $bucket (@buckets)  {
        $bar_values{$bucket}{0} = $self->{classifier__}->get_bucket_word_count($bucket);
        delete $bar_values{$bucket}{1};
        delete $bar_values{$bucket}{2};
    }

    $body .= bar_chart_100( $self, %bar_values );

    $body .= "</table>\n</td>\n</tr>\n</table>\n<br />\n";

    # bottom panel group
    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language__}{Bucket_MaintenanceTableSummary}\">\n";

    # Maintenance panel
    $body .= "<tr>\n<td class=\"settingsPanel\" valign=\"top\" width=\"50%\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language__}{Bucket_Maintenance}</h2>\n";

    # optional widget placement
    $body .= "<div class=\"bucketsMaintenanceWidget\">\n";

    $body .= "<form action=\"/buckets\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsCreateBucket\">$self->{language__}{Bucket_CreateBucket}:</label><br />\n";
    $body .= "<input name=\"cname\" id=\"bucketsCreateBucket\" type=\"text\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"create\" value=\"$self->{language__}{Create}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "</form>\n$create_message\n";
    $body .= "<form action=\"/buckets\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsDeleteBucket\">$self->{language__}{Bucket_DeleteBucket}:</label><br />\n";
    $body .= "<select name=\"name\" id=\"bucketsDeleteBucket\">\n<option value=\"\"></option>\n";

    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"delete\" value=\"$self->{language__}{Delete}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n$deletemessage\n";

    $body .= "<form action=\"/buckets\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsRenameBucketFrom\">$self->{language__}{Bucket_RenameBucket}:</label><br />\n";
    $body .= "<select name=\"oname\" id=\"bucketsRenameBucketFrom\">\n<option value=\"\"></option>\n";

    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<label class=\"bucketsLabel\" for=\"bucketsRenameBucketTo\">$self->{language__}{Bucket_To}</label>\n";
    $body .= "<input type=\"text\" id=\"bucketsRenameBucketTo\" name=\"newname\" /> \n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"rename\" value=\"$self->{language__}{Rename}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "</form>\n$rename_message\n<br />\n";

    # end optional widget placement
    $body .= "</div>\n</td>\n";

    # Lookup panel
    $body .= "<td class=\"settingsPanel\" valign=\"top\" width=\"50%\">\n<a name=\"Lookup\"></a>\n";
    $body .= "<h2 class=\"buckets\">$self->{language__}{Bucket_Lookup}</h2>\n";

    # optional widget placement
    $body .= "<div class=\"bucketsLookupWidget\">\n";

    $body .= "<form action=\"/buckets#Lookup\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsLookup\">$self->{language__}{Bucket_LookupMessage}:</label><br />\n";
    $body .= "<input name=\"word\" id=\"bucketsLookup\" type=\"text\" /> \n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"lookup\" value=\"$self->{language__}{Lookup}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n</form>\n<br />\n";

    # end optional widget placement
    $body .= "</div>\n";

    if ( ( defined($self->{form_}{lookup}) ) || ( defined($self->{form_}{word}) ) ) {
       my $word = $self->{classifier__}->{mangler__}->mangle($self->{form_}{word}, 1);

        $body .= "<blockquote>\n";

        # Don't print the headings if there are no entries.

        my $heading = "<table class=\"lookupResultsTable\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language__}{Bucket_LookupResultsSummary}\">\n";
        $heading .= "<tr>\n<td>\n";
        $heading .= "<table summary=\"\">\n";
        $heading .= "<caption><strong>$self->{language__}{Bucket_LookupMessage2} $self->{form_}{word}</strong><br /><br /></caption>";
        $heading .= "<tr>\n<th scope=\"col\">$self->{language__}{Bucket}</th>\n<th>&nbsp;</th>\n";
        $heading .= "<th scope=\"col\">$self->{language__}{Frequency}</th>\n<th>&nbsp;</th>\n";
        $heading .= "<th scope=\"col\">$self->{language__}{Probability}</th>\n<th>&nbsp;</th>\n";
        $heading .= "<th scope=\"col\">$self->{language__}{Score}</th>\n</tr>\n";

        if ( $self->{form_}{word} ne '' ) {
            my $max = 0;
            my $max_bucket = '';
            my $total = 0;
            foreach my $bucket (@buckets) {
                if ( $self->{classifier__}->get_value_( $bucket, $word ) != 0 ) {
                    my $prob = exp( $self->{classifier__}->get_value_( $bucket, $word ) );
                    $total += $prob;
                    if ( $max_bucket eq '' ) {
                        $body .= $heading;
                    }
                    if ( $prob > $max ) {
                        $max = $prob;
                        $max_bucket = $bucket;
                    }
                }
                # Take into account the probability the Bayes calculation applies
                # for the buckets in which the word is not found.
                else {
                    if ( $self->{classifier__}->get_word_count() > 0 ) {
                        $total += 0.1 / $self->{classifier__}->get_word_count();
                    }
                }
            }

            foreach my $bucket (@buckets) {
                if ( $self->{classifier__}->get_value_( $bucket, $word ) != 0 ) {
                    my $prob    = exp( $self->{classifier__}->get_value_( $bucket, $word ) );
                    my $n       = ($total > 0)?$prob / $total:0;
                    my $score   = ($#buckets >= 0)?log($n)/log(@buckets)+1:0;
                    my $normal  = sprintf("%.10f", $n);
                    $score      = sprintf("%.10f", $score);
                    my $probf   = sprintf("%.10f", $prob);
                    my $bold    = '';
                    my $endbold = '';
                    if ( $score =~ /^[^\-]/ ) {
                        $score = "&nbsp;$score";
                    }
                    $bold    = "<b>"  if ( $max == $prob );
                    $endbold = "</b>" if ( $max == $prob );
                    $body .= "<tr>\n<td>$bold<font color=\"" . $self->{classifier__}->get_bucket_color($bucket) . "\">$bucket</font>$endbold</td>\n";
                    $body .= "<td></td>\n<td>$bold<tt>$probf</tt>$endbold</td>\n<td></td>\n";
                    $body .= "<td>$bold<tt>$normal</tt>$endbold</td>\n<td></td>\n<td>$bold<tt>$score</tt>$endbold</td>\n</tr>\n";
                }
            }

            if ( $max_bucket ne '' ) {
                $body .= "</table>\n<br /><br />";
                $body .= sprintf( $self->{language__}{Bucket_LookupMostLikely}, $self->{form_}{word}, $self->{classifier__}->get_bucket_color($max_bucket), $max_bucket);
                $body .= "</td>\n</tr>\n</table>";
            } else {
                $body .= sprintf( $self->{language__}{Bucket_DoesNotAppear}, $self->{form_}{word} );
            }
        } else {
            $body .= "<div class=\"error01\">$self->{language__}{Bucket_Error4}</div>";
        }

        $body .= "\n</blockquote>\n";
    }

    $body .= "</td>\n</tr>\n</table>";

    http_ok($self, $client,$body,1);
}

# ---------------------------------------------------------------------------------------------
#
# compare_mf - Compares two mailfiles, used for sorting mail into order
#
# ---------------------------------------------------------------------------------------------
sub compare_mf
{
    my $ad;
    my $bd;
    my $am;
    my $bm;

    if ( $a =~ /popfile(.+)=(.+)\.msg/ )  {
        $ad = $1;
        $am = $2;

        if ( $b =~ /popfile(.+)=(.+)\.msg/ ) {
            $bd = $1;
            $bm = $2;

            if ( $ad == $bd ) {
                return ( $bm <=> $am );
            } else {
                return ( $bd <=> $ad );
            }
        }
    }

    return 0;
}

# ---------------------------------------------------------------------------------------------
#
# invalidate_history_cache
#
# Called to notify the module that new files have been added to the history cache on disk
# and the cache needs to be reloaded.
#
# ---------------------------------------------------------------------------------------------
sub invalidate_history_cache
{
    my ( $self ) = @_;

    $self->{history_invalid__} = 1;
}

# ---------------------------------------------------------------------------------------------
#
# sort_filter_history
#
# Called to set up the history_keys array with the appropriate order set of keys from the
# history based on the passed in filter, search and sort settings
#
# $filter       Name of bucket to filter on
# $search       From/Subject line to search for
# $sort         The field to sort on (from, subject, bucket)
#
# ---------------------------------------------------------------------------------------------
sub sort_filter_history
{
    my ( $self, $filter, $search, $sort ) = @_;

    # Place entries in the history_keys array based on three critera:
    #
    # 1. Whether the bucket they are classified in matches the $filter
    # 2. Whether their from/subject matches the $search
    # 3. In the order of $sort which can be from, subject or bucket

    delete $self->{history_keys__};

    if ( ( $filter ne '' ) || ( $search ne '' ) ) {
        foreach my $file (sort compare_mf keys %{$self->{history__}}) {
            if ( ( $filter eq '' ) ||
                 ( $self->{history__}{$file}{bucket} eq $filter ) ||
                 ( ( $filter eq '__filter__magnet' ) && ( $self->{history__}{$file}{magnet} ne '' ) ) ) {
                if ( ( $search eq '' ) ||
                   ( $self->{history__}{$file}{from}    =~ /\Q$search\E/i ) ||
                   ( $self->{history__}{$file}{subject} =~ /\Q$search\E/i ) ) {
                           if ( defined( $self->{history_keys__} ) ) {
                            @{$self->{history_keys__}} = (@{$self->{history_keys__}}, $file);
                        } else {
                            @{$self->{history_keys__}} = ($file);
                        }
                   }
            }
        }
    } else {
        @{$self->{history_keys__}} = keys %{$self->{history__}};
    }

    # If a sort is specified then use it to sort the history items by an a subkey
    # (from, subject or bucket) otherwise use compare_mf to give the history back
    # in the order the messages were received.  Note that when sorting on a alphanumeric
    # field we ignore all punctuation characters so that "John and 'John and John
    # all sort next to each other

    # Ascending or Descending? Ascending is noted by /-field/

    my $descending = 0;
    if ($sort =~ s/^\-//) {
        $descending = 1;
    }

    if ( ( $sort ne '' ) &&

         # If the filter had no messages, this will be undefined
         # and there are no ways to sort nothing

         defined @{$self->{history_keys__}} ) {

        @{$self->{history_keys__}} = sort {
                                            my ($a1,$b1) = ($self->{history__}{$a}{$sort},
                                              $self->{history__}{$b}{$sort});
                                              $a1 =~ s/[^A-Z0-9]//ig;
                                              $b1 =~ s/[^A-Z0-9]//ig;
                                              return ( $a1 cmp $b1 );
                                          } @{$self->{history_keys__}};
    } else {

        # Here's a quick shortcut so that we don't have to iterate
        # if there's no work for us to do

        if ( $self->history_size() > 0 ) {
            @{$self->{history_keys__}} = sort compare_mf @{$self->{history_keys__}};
        }
    }

    @{$self->{history_keys__}} = reverse @{$self->{history_keys__}} if ($descending);
}

# ---------------------------------------------------------------------------------------------
#
# load_history_cache__
#
# Forces a reload of the history cache from disk.  This works by globbing the history
# directory and then checking for new files that need to be loaded into the history cache
# and culling any files that have been removed without telling us
#
# ---------------------------------------------------------------------------------------------
sub load_history_cache__
{
    my ( $self ) = @_;

    # First we mark every entry in the history cache with cull set to one, after we have
    # looked through the messages directory for message we will delete any of the entries
    # in the hash that have cull still set to 1.  cull gets set to 0 everytime we see an
    # existing history cache entry that is still on the disk, or when we create a new
    # entry.  Strictly speaking this should not be necessary because when files are deleted
    # their corresponding history entry is meant to be deleted, but since disk is not 100%
    # reliable we do this check so that the history cache is in sync with the disk at all
    # times

    foreach my $key (keys %{$self->{history__}}) {
        $self->{history__}{$key}{cull} = 1;
    }

    # Now get all the names of files from the appropriate history subdirectory and run
    # through them looking for existing entries in the history which must be marked
    # for non-culling and new entries that need to be added to the end

    my @history_files = sort compare_mf glob( $self->global_config_( 'msgdir' ) . "popfile*=*.msg" );

    foreach my $i ( 0 .. $#history_files ) {

        # Strip any directory portion of the name in the current file so that we
        # just get the base name of the file that we are dealing with

        $history_files[$i] =~ /(popfile\d+=\d+\.msg)$/;
        $history_files[$i] = $1;

        # If this file already exists in the history cache then just mark it not
        # to be culled and move on.

        if ( defined( $self->{history__}{$history_files[$i]} ) ) {
            $self->{history__}{$history_files[$i]}{cull} = 0;
            $self->{history__}{$history_files[$i]}{index}         = $i;
        } else {

            # Find the class information for this file using the history_load_class helper
            # function, and then parse the MSG file for the From and Subject information

            my ( $reclassified, $bucket, $usedtobe, $magnet ) = $self->history_load_class( $history_files[$i] );
            my $from    = '';
            my $subject = '';

            if ( open MAIL, '<'. $self->global_config_( 'msgdir' ) . "$history_files[$i]" ) {
                while ( <MAIL> )  {
                    last          if ( /^(\r\n|\r|\n)/ );
                    $from = $1    if ( /^From:(.*)/i );
                    $subject = $1 if ( /^Subject:(.*)/i );
                    last if ( ( $from ne '' ) && ( $subject ne '' ) );
                }
                close MAIL;
            }

            $from    = "<$self->{language__}{History_NoFrom}>"    if ( $from eq '' );
            $subject = "<$self->{language__}{History_NoSubject}>" if ( !( $subject =~ /[^ \t\r\n]/ ) );

            $from    =~ s/\"(.*)\"/$1/g;
            $subject =~ s/\"(.*)\"/$1/g;

# TODO            $from    = $self->{classifier__}->{parser}->decode_string( $from );
# TODO            $subject = $self->{classifier__}->{parser}->decode_string( $subject );

            my ( $short_from, $short_subject ) = ( $from, $subject );

            if ( length($short_from)>40 )  {
                $short_from =~ /(.{40})/;
                $short_from = "$1...";
            }

            if ( length($short_subject)>40 )  {
               $short_subject =~ s/=20/ /g;
                $short_subject =~ /(.{40})/;
                $short_subject = "$1...";
            }

            $from =~ s/&/&amp;/g;
            $from =~ s/</&lt;/g;
            $from =~ s/>/&gt;/g;

            $short_from =~ s/&/&amp;/g;
            $short_from =~ s/</&lt;/g;
            $short_from =~ s/>/&gt;/g;

            $subject =~ s/&/&amp;/g;
            $subject =~ s/</&lt;/g;
            $subject =~ s/>/&gt;/g;

            $short_subject =~ s/&/&amp;/g;
            $short_subject =~ s/</&lt;/g;
            $short_subject =~ s/>/&gt;/g;

            $self->{history__}{$history_files[$i]}{bucket}        = $bucket;
            $self->{history__}{$history_files[$i]}{reclassified}  = $reclassified;
            $self->{history__}{$history_files[$i]}{magnet}        = $magnet;
            $self->{history__}{$history_files[$i]}{subject}       = $subject;
            $self->{history__}{$history_files[$i]}{from}          = $from;
            $self->{history__}{$history_files[$i]}{short_subject} = $short_subject;
            $self->{history__}{$history_files[$i]}{short_from}    = $short_from;
            $self->{history__}{$history_files[$i]}{cull}          = 0;
            $self->{history__}{$history_files[$i]}{index}         = $i;
        }
    }

    # Remove any entries from the history that have been removed from disk, see the big
    # comment at the start of this function for more detail

    foreach my $key (keys %{$self->{history__}}) {
        if ( $self->{history__}{$key}{cull} == 1 ) {
            delete $self->{history__}{$key};
        }
    }

    $self->{history_invalid__} = 0;
    $self->sort_filter_history( '', '', '' );
}

# ---------------------------------------------------------------------------------------------
#
# history_cache_empty
#
# Returns whether the cache is empty or not
#
# ---------------------------------------------------------------------------------------------
sub history_cache_empty
{
    my ( $self ) = @_;

    return ( $self->history_size() == 0 );
}

# ---------------------------------------------------------------------------------------------
#
# history_size
#
# Returns the size of the history cache, note that this is actually the size of the
# history_keys array since that is used to access selected entries in the history cache
# itself
#
# ---------------------------------------------------------------------------------------------
sub history_size
{
    my ( $self ) = @_;

    if ( defined( $self->{history_keys__} ) ) {
        my @keys = @{$self->{history_keys__}};

        return ($#keys + 1);
    } else {
        return 0;
    }
}

# ---------------------------------------------------------------------------------------------
#
# get_history_navigator
#
# Return the HTML for the Next, Previous and page numbers for the history navigation
#
# $start_message        - The number of the first message displayed
# $stop_message         - The number of the last message displayed
#
# ---------------------------------------------------------------------------------------------
sub get_history_navigator
{
    my ( $self, $start_message, $stop_message ) = @_;

    my $body = "$self->{language__}{History_Jump}: ";
    if ( $start_message != 0 )  {
        $body .= "[<a href=\"/history?start_message=";
        $body .= $start_message - $self->config_( 'page_size' );
        $body .= "&amp;session=$self->{session_key__}&amp;sort=$self->{form_}{sort}&amp;search=$self->{form_}{search}&amp;filter=$self->{form_}{filter}\">< $self->{language__}{Previous}</a>] ";
    }
    my $i = 0;
    while ( $i < $self->history_size() ) {
        if ( $i == $start_message )  {
            $body .= "<b>";
            $body .= $i+1 . "</b>";
        } else {
            $body .= "[<a href=\"/history?start_message=$i&amp;session=$self->{session_key__}&amp;search=$self->{form_}{search}&amp;sort=$self->{form_}{sort}&amp;filter=$self->{form_}{filter}\">";
            $body .= $i+1 . "</a>]";
        }

        $body .= " ";
        $i += $self->config_( 'page_size' );
    }
    if ( $start_message < ( $self->history_size() - $self->config_( 'page_size' ) ) )  {
        $body .= "[<a href=\"/history?start_message=";
        $body .= $start_message + $self->config_( 'page_size' );
        $body .= "&amp;session=$self->{session_key__}&amp;sort=$self->{form_}{sort}&amp;search=$self->{form_}{search}&amp;filter=$self->{form_}{filter}\">$self->{language__}{Next} ></a>]";
    }

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# history_write_class - write the class file for a message.
#
# $filename     The name of the message to write the class for
# $reclassified Boolean, true if the message has been reclassified
# $bucket       the name of the bucket the message is in
# $usedtobe     the name of the bucket the messages used to be in
# $magnet       the magnet, if any, used to reclassify the message
#
# ---------------------------------------------------------------------------------------------
sub history_write_class {

    my ( $self, $filename, $reclassified, $bucket, $usedtobe, $magnet ) = @_;

    $filename =~ s/msg$/cls/;

    open CLASS, '>' . $self->global_config_( 'msgdir' ) . $filename;

    if ( defined( $magnet ) && ( $magnet ne '' ) ) {
        print CLASS "$bucket MAGNET $magnet\n";
    } elsif (defined $reclassified && $reclassified == 1) {
        print CLASS "RECLASSIFIED\n";
        print CLASS "$bucket\n";
        if ( defined( $usedtobe ) && ( $usedtobe ne '' ) ) {
            print CLASS "$usedtobe\n";
        }
    } else {
        print CLASS "$bucket\n";
    }

    close CLASS;
}

# ---------------------------------------------------------------------------------------------
#
# history_load_class - load the class file for a message.
#
# returns: ( reclassified, bucket, usedtobe, magnet )
#   values:
#       reclassified:   boolean, true if message has been reclassified
#       bucket:         string, the bucket the message is in presently, unknown class if an error occurs
#       usedtobe:       string, the bucket the message used to be in (null if not reclassified)
#       magnet:         string, the magnet
#
# $filename     The name of the message to load the class for
#
# ---------------------------------------------------------------------------------------------
sub history_load_class {

    my ( $self, $filename ) = @_;
    $filename =~ s/msg$/cls/;

    my $reclassified = 0;
    my $bucket = "unknown class";
    my $usedtobe;
    my $magnet = '';

    if ( open CLASS, '<' . $self->global_config_( 'msgdir' ) . $filename ) {
        $bucket = <CLASS>;
        if ( $bucket =~ /([^ ]+) MAGNET (.+)/ ) {
            $bucket = $1;
            $magnet = $2;
        }

        $reclassified = 0;
        if ( $bucket =~ /RECLASSIFIED/ ) {
            $bucket       = <CLASS>;
            $usedtobe = <CLASS>;
            $reclassified = 1;
            $usedtobe =~ s/[\r\n]//g;
        }
        close CLASS;
        $bucket =~ s/[\r\n]//g;
    } else {
        print "Error: " . $self->global_config_( 'msgdir' ) . "$filename: $!\n";
    }
    return ( $reclassified, $bucket, $usedtobe, $magnet );
}

# ---------------------------------------------------------------------------------------------
#
# history_reclassify - handle the reclassification of messages on the history page
#
# ---------------------------------------------------------------------------------------------
sub history_reclassify
{
    my ( $self ) = @_;

    if ( defined( $self->{form_}{change} ) ) {

        # This hash will map filenames of MSG files in the history to the
        # new classification that they should be, it is built by iterating
        # through the $self->{form_} looking for entries with the message number
        # of each message that is displayed and then creating an entry in
        # %messages if there is a corresponding entry in $self->{form_} for
        # that message number

        my %messages;

        foreach my $i ( $self->{form_}{start_message}  .. $self->{form_}{start_message} + $self->config_( 'page_size' ) - 1) {
            my $mail_file = $self->{history_keys__}[$i];

            # The first check makes sure we didn't run off the end of the history table
            # the second that there is something defined for this message number and the
            # third that this message number has a value (i.e. a bucket name)

            if ( defined( $mail_file ) && defined( $self->{form_}{$i} ) && ( $self->{form_}{$i} ne '' ) ) {
                $messages{$mail_file} = $self->{form_}{$i};
            }
        }

        # At this point %messages maps that files that need reclassifying to their
        # new bucket classification

        while ( my ($mail_file, $newbucket) = each %messages ) {

            # Get the current classification for this message

            my ( $reclassified, $bucket, $usedtobe, $magnet) = $self->history_load_class( $mail_file );

            # Only reclassify messages that havn't been reclassified before

            if ( !$reclassified ) {
                $self->{classifier__}->add_message_to_bucket( $self->global_config_( 'msgdir' ) . $mail_file, $newbucket );

                $self->log_( "Reclassifying $mail_file from $bucket to $newbucket" );

                if ( $bucket ne $newbucket ) {
                    my $ecount = $self->global_config_( 'ecount' ) + 1;
                    $self->global_config_( 'ecount', $ecount );

                    my $count = $self->{classifier__}->get_bucket_parameter( $newbucket, 'count' );
                    $self->{classifier__}->set_bucket_parameter( $newbucket, 'count', $count+1 );

                    $count = $self->{classifier__}->get_bucket_parameter( $bucket, 'count' );
                    $count -= 1;
                    $count = 0 if ( $count < 0 ) ;
                    $self->{classifier__}->set_bucket_parameter( $bucket, 'count', $count );

                    my $fncount = $self->{classifier__}->get_bucket_parameter( $newbucket, 'fncount' );
                    $self->{classifier__}->set_bucket_parameter( $newbucket, 'fncount', $fncount+1 );

                    my $fpcount = $self->{classifier__}->get_bucket_parameter( $bucket, 'fpcount' );
                    $self->{classifier__}->set_bucket_parameter( $bucket, 'fpcount', $fpcount+1 );
		}

                # Update the class file

                $self->history_write_class( $mail_file, 1, $newbucket, ( $bucket || "unclassified" ) , '');

                # Since we have just changed the classification of this file and it has
                # now been reclassified and has a new bucket name then we need to update the
                # history cache to reflect that

                $self->{history__}{$mail_file}{reclassified} = 1;
                $self->{history__}{$mail_file}{bucket}       = $newbucket;

                # Add message feedback

                $self->{feedback}{$mail_file} = sprintf( $self->{language__}{History_ChangedTo}, $self->{classifier__}->get_bucket_color($newbucket), $newbucket );

                $self->{configuration__}->save_configuration();
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# history_undo - handle undoing of reclassifications of messages on the history page
#
# ---------------------------------------------------------------------------------------------
sub history_undo
{
    my( $self ) = @_;

    foreach my $key (keys %{$self->{form_}}) {
        if ( $key =~ /^undo_([0-9]+)$/ ) {
            my $mail_file = $self->{history_keys__}[$1];
            my %temp_corpus;

            # Load the class file

            my ( $reclassified, $bucket, $usedtobe, $magnet ) = $self->history_load_class( $mail_file );

            # Only undo if the message has been classified...

            if ( defined( $usedtobe ) ) {
                $self->{classifier__}->remove_message_from_bucket($self->global_config_( 'msgdir' ) . $mail_file, $bucket);

                $self->log_( "Undoing $mail_file from $bucket to $usedtobe" );

                if ( $bucket ne $usedtobe ) {
                    my $ecount = $self->global_config_( 'ecount' ) - 1;
                    $ecount = 0 if ( $ecount < 0 );
                    $self->global_config_( 'ecount', $ecount );

                    my $count = $self->{classifier__}->get_bucket_parameter( $bucket, 'count' ) - 1;
                    $count = 0 if ( $count < 0 );
                    $self->{classifier__}->set_bucket_parameter( $bucket, 'count', $count );

		    $count = $self->{classifier__}->get_bucket_parameter( $usedtobe, 'count' ) + 1;
                    $self->{classifier__}->set_bucket_parameter( $usedtobe, 'count', $count );

                    my $fncount = $self->{classifier__}->get_bucket_parameter( $bucket, 'fncount' ) - 1;
                    $fncount = 0 if ( $fncount < 0 );
                    $self->{classifier__}->set_bucket_parameter( $bucket, 'fncount', $fncount );

                    my $fpcount = $self->{classifier__}->get_bucket_parameter( $usedtobe, 'fpcount' ) - 1;
                    $fpcount = 0 if ( $fpcount < 0 );
                    $self->{classifier__}->set_bucket_parameter( $usedtobe, 'fpcount', $fpcount );
		}

                # Since we have just changed the classification of this file and it has
                # not been reclassified and has a new bucket name then we need to update the
                # history cache to reflect that

                $self->{history__}{$mail_file}{reclassified} = 0;
                $self->{history__}{$mail_file}{bucket}       = $usedtobe;

                # Update the class file

                $self->history_write_class( $mail_file, 0, ( $usedtobe || "unclassified" ), '', '');

                # Add message feedback

                $self->{feedback}{$mail_file} = sprintf( $self->{language__}{History_ChangedTo}, ($self->{classifier__}->get_bucket_color($usedtobe) || ''), $usedtobe );

                $self->{configuration__}->save_configuration();
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# get_search_filter_widget
#
# Returns the form that contains the fields for searching and filtering the history
# page
#
# ---------------------------------------------------------------------------------------------
sub get_search_filter_widget
{
    my ( $self ) = @_;

    my $body = "<form action=\"/history\">\n";
    $body .= "<label class=\"historyLabel\" for=\"historySearch\">$self->{language__}{History_SearchMessage}:</label>\n";
    $body .= "<input type=\"text\" id=\"historySearch\" name=\"search\" ";
    $body .= "value=\"$self->{form_}{search}\"" if (defined $self->{form_}{search});
    $body .= " />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"setsearch\" value=\"$self->{language__}{Find}\" />\n";
    $body .= "&nbsp;&nbsp;<label class=\"historyLabel\" for=\"historyFilter\">$self->{language__}{History_FilterBy}:</label>\n";
    $body .= "<input type=\"hidden\" name=\"sort\" value=\"$self->{form_}{sort}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
    $body .= "<select name=\"filter\" id=\"historyFilter\">\n<option value=\"\"></option>";
    my @buckets = $self->{classifier__}->get_buckets();
    foreach my $abucket (@buckets) {
        $body .= "<option value=\"$abucket\"";
        $body .= " selected" if ( ( defined($self->{form_}{filter}) ) && ( $self->{form_}{filter} eq $abucket ) );
        $body .= ">$abucket</option>\n";
    }
    $body .= "<option value=\"__filter__magnet\"" . ($self->{form_}{filter} eq '__filter__magnet'?' selected':'') . ">&lt;$self->{language__}{History_ShowMagnet}&gt;</option>\n";
    $body .= "<option value=\"unclassified\"" . ($self->{form_}{filter} eq 'unclassified'?' selected':'') . ">&lt;unclassified&gt;</option>\n";
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"setfilter\" value=\"$self->{language__}{Filter}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"reset_filter_search\" value=\"$self->{language__}{History_ResetSearch}\" />\n";
    $body .= "</form>\n";

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# history_page - get the message classification history page
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub history_page
{
    my ( $self, $client ) = @_;

    # Set up default values for various form elements that have been passed
    # in or not so that we don't have to worry about undefined values later
    # on in the function

    $self->{form_}{sort}   = '' if ( !defined( $self->{form_}{sort}   ) );
    $self->{form_}{search} = '' if ( !defined( $self->{form_}{search} ) );
    $self->{form_}{filter} = '' if ( !defined( $self->{form_}{filter} ) );

    # Information from submit buttons isn't always preserved if the buttons aren't
    # pressed. This compares values in some fields and sets the button-values as
    # though they had been pressed

    # Set setsearch if search changed and setsearch is undefined
    $self->{form_}{setsearch} = 'on' if ( ( ( !defined($self->{old_search__}) && ($self->{form_}{search} ne '') ) || ( defined($self->{old_search__}) && ( $self->{old_search__} ne $self->{form_}{search} ) ) ) && !defined($self->{form_}{setsearch} ) );
    $self->{old_search__} = $self->{form_}{search};


    # If the user is asking for a new sort option then it needs to get
    # stored in the sort form variable so that it can be used for subsequent
    # page views of the History to keep the sort in place

    $self->{form_}{sort} = $self->{form_}{setsort} if ( defined( $self->{form_}{setsort} ) );

    # If the user hits the Reset button on a search then we need to clear
    # the search value but make it look as though they hit the search button
    # so that sort_filter_history will get called below to get the right values
    # in history_keys

    if ( defined( $self->{form_}{reset_filter_search} ) ) {
        $self->{form_}{filter}    = '';
        $self->{form_}{search}    = '';
        $self->{form_}{setsearch} = 1;
    }

    # Set up the text that will appear at the top of the history page
    # indicating the current filter and search settings

    my $filtered = '';
    if ( !( $self->{form_}{filter} eq '' ) ) {
        if ( $self->{form_}{filter} eq '__filter__magnet' ) {
            $filtered .= $self->{language__}{History_Magnet};
        } else {
            $filtered = sprintf( $self->{language__}{History_Filter}, $self->{classifier__}->get_bucket_color($self->{form_}{filter}), $self->{form_}{filter} ) if ( $self->{form_}{filter} ne '' );
        }
    }

    $filtered .= sprintf( $self->{language__}{History_Search}, $self->{form_}{search} ) if ( $self->{form_}{search} ne '' );

    # Handle the reinsertion of a message file or the user hitting the
    # undo button

    $self->history_reclassify();
    $self->history_undo();

    # Handle removal of one or more items from the history page, the remove_array form will contain
    # all the indexes into history_keys that need to be deleted.  We pass each file that needs
    # deleting into the history_delete_file helper

    if ( defined( $self->{form_}{deletemessage} ) ) {

        # Remove the list of marked messages using the array of "remove" checkboxes, the fact
        # that deletemessage is defined will later on cause a call to sort_filter_history
        # that will reload the history_keys with the appropriate messages that now exist
        # in the cache.  Note that there is no need to invalidate the history cache since
        # we are in control of deleting messages

        for my $i ( 0 .. $#{$self->{form_}{remove_array}} ) {
            $self->history_delete_file( $self->{history_keys__}[$self->{form_}{remove_array}[$i] - 1], 0);
        }
    }

    # Handle clearing the history files, there are two options here, clear the current page
    # or clear all the files in the cache

    if ( defined( $self->{form_}{clearall} ) ) {
        foreach my $i (0 .. $self->history_size()-1 ) {
            $self->history_delete_file( $self->{history_keys__}[$i],
                                        $self->config_( 'archive' ) );
        }
    }

    if ( defined($self->{form_}{clearpage}) ) {
        foreach my $i ( $self->{form_}{start_message} .. $self->{form_}{start_message} + $self->config_( 'page_size' ) - 1 ) {
            if ( defined( $self->{history_keys__}[$i] ) ) {
                $self->history_delete_file( $self->{history_keys__}[$i],
                                            $self->config_( 'archive' ) );
            }
        }
    }

    # If the history cache is invalid then we need to reload it and then if
    # any of the sort, search or filter options have changed they must be
    # applied.  The watch word here is to avoid doing work

    $self->load_history_cache__() if ( $self->{history_invalid__} == 1 );
    $self->sort_filter_history( $self->{form_}{filter},
                                $self->{form_}{search},
                                $self->{form_}{sort} ) if ( ( defined( $self->{form_}{setfilter}     ) ) ||
                                                            ( defined( $self->{form_}{setsort}       ) ) ||
                                                            ( defined( $self->{form_}{setsearch}     ) ) ||
                                                            ( defined( $self->{form_}{deletemessage} ) ) ||
                                                            ( defined( $self->{form_}{clearall}      ) ) ||
                                                            ( defined( $self->{form_}{clearpage}     ) ) );
    my $body = '';

    if ( !$self->history_cache_empty() )  {
        my $highlight_message = '';
        my $start_message = 0;

        $start_message = $self->{form_}{start_message} if ( ( defined($self->{form_}{start_message}) ) && ($self->{form_}{start_message} > 0 ) );
        my $stop_message  = $start_message + $self->config_( 'page_size' ) - 1;

        # Verify that a message we are being asked to view (perhaps from a /jump_to_message URL) is actually between
        # the $start_message and $stop_message, if it is not then move to that message

        if ( defined($self->{form_}{view}) ) {
            my $found = 0;
            foreach my $i ($start_message ..  $stop_message) {
                if ( defined ( $self->{history_keys__}[$i] ) ) {
                    my $mail_file = $self->{history_keys__}[$i];
                    if ( $self->{form_}{view} eq $mail_file )  {
                        $found = 1;
                        last;
                    }
                }
            }

            if ( $found == 0 ) {
                foreach my $i ( 0 .. ( $self->history_size() - 1 ) )  {
                    my $mail_file = $self->{history_keys__}[$i];
                    if ( $self->{form_}{view} eq $mail_file ) {
                        $start_message = $i;
                        $stop_message  = $i + $self->config_( 'page_size' ) - 1;
                        last;
                    }
                }
            }
        }

        $stop_message = $self->history_size() - 1 if ( $stop_message >= $self->history_size() );

        if ( $self->config_( 'page_size' ) <= $self->history_size() ) {
            $body .= "<table width=\"100%\" summary=\"\">\n<tr>\n<td align=\"left\">\n";
            # title
            $body .= "<h2 class=\"history\">$self->{language__}{History_Title}$filtered</h2>\n</td>\n";
            # navigator
            $body .= "<td class=\"historyNavigatorTop\">\n";
            $body .= get_history_navigator( $self, $start_message, $stop_message );
            $body .= "</td>\n</tr>\n</table>\n";
        } else {
            $body .="<h2 class=\"history\">$self->{language__}{History_Title}$filtered</h2>\n";
        }

        # History widgets top
        $body .= "<table class=\"historyWidgetsTop\" summary=\"\">\n<tr>\n";

        # Search From/Subject widget
        my @buckets = $self->{classifier__}->get_buckets();
        $body .= "<td colspan=\"5\" valign=middle>\n";
        $body .= $self->get_search_filter_widget();
        $body .= "</td>\n</tr>\n</table>\n";

        # History page main form

        $body .= "<form id=\"HistoryMainForm\" action=\"/history\" method=\"POST\">\n";
        $body .= "<input type=\"hidden\" name=\"search\" value=\"$self->{form_}{search}\" />\n";
        $body .= "<input type=\"hidden\" name=\"sort\" value=\"$self->{form_}{sort}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
        $body .= "<input type=\"hidden\" name=\"start_message\" value=\"$start_message\" />\n";
        $body .= "<input type=\"hidden\" name=\"filter\" value=\"$self->{form_}{filter}\" />\n";

        # History messages
        $body .= "<table class=\"historyTable\" width=\"100%\" summary=\"$self->{language__}{History_MainTableSummary}\">\n";

        # Column headers

        my %headers_table = ( '',        'ID',
                              'from',    'From',
                              'subject', 'Subject',
                              'bucket',  'Classification');

        $body .= "<tr valign=\"bottom\">\n";

        # It would be tempting to do keys %headers_table here but there is not guarantee that
        # they will come back in the right order

        foreach my $header ('', 'from', 'subject', 'bucket') {
            $body .= "<th class=\"historyLabel\" scope=\"col\">\n";
            $body .= "<a href=\"/history?session=$self->{session_key__}&amp;filter=$self->{form_}{filter}&amp;setsort=" . ($self->{form_}{sort} eq "$header"?"-":"");
            $body .= "$header\">";

            my $label = '';
            if ( defined $self->{language__}{ $headers_table{$header} }) {
                $label = $self->{language__}{ $headers_table{$header} };
            } else {
                $label = $headers_table{$header};
            }

            if ( $self->{form_}{sort} =~ /^\-?\Q$header\E$/ ) {
                $body .= "<em class=\"historyLabelSort\">" . ($self->{form_}{sort} =~ /^-/ ? "&lt;" : "&gt;") . "$label</em>";
            } else {
                $body .= "$label";
            }
            $body .= "</a>\n</th>\n";
        }


        $body .= "<th class=\"historyLabel\" scope=\"col\">$self->{language__}{History_ShouldBe}</th>\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">$self->{language__}{Remove}</th>\n</tr>\n";

        my $stripe = 0;

        foreach my $i ($start_message ..  $stop_message) {
            my $mail_file     = $self->{history_keys__}[$i];
            my $from          = $self->{history__}{$mail_file}{from};
            my $subject       = $self->{history__}{$mail_file}{subject};
            my $short_from    = $self->{history__}{$mail_file}{short_from};
            my $short_subject = $self->{history__}{$mail_file}{short_subject};
            my $bucket        = $self->{history__}{$mail_file}{bucket};
            my $reclassified  = $self->{history__}{$mail_file}{reclassified};
            my $index         = $self->{history__}{$mail_file}{index} + 1;

            $body .= "<tr";
            if ( ( ( defined($self->{form_}{view}) ) && ( $self->{form_}{view} eq $mail_file ) ) || ( ( defined($self->{form_}{file}) && ( $self->{form_}{file} eq $mail_file ) ) ) || ( $highlight_message eq $mail_file ) ) {
                $body .= " class=\"rowHighlighted\"";
            } else {
                $body .= " class=\"";
                $body .= $stripe?"rowEven\"":"rowOdd\"";
            }

            $stripe = 1 - $stripe;

            $body .= ">\n<td>";
            $body .= "<a name=\"$mail_file\"></a>";
            $body .= $index . "</td>\n<td>";
            $mail_file =~ /popfile\d+=(\d+)\.msg$/;
            $body .= "<a title=\"$from\">$short_from</a></td>\n";
            $body .= "<td><a class=\"messageLink\" title=\"$subject\" href=\"/history?view=$mail_file&amp;start_message=$start_message&amp;session=$self->{session_key__}&amp;sort=$self->{form_}{sort}&amp;filter=$self->{form_}{filter}&amp;search=$self->{form_}{search}#$mail_file\">";
            $body .= "$short_subject</a></td>\n<td>";
            if ( $reclassified )  {
                $body .= "<font color=\"" . $self->{classifier__}->get_bucket_color($bucket) . "\">$bucket</font></td>\n<td>";
                $body .= sprintf( $self->{language__}{History_Already}, ($self->{classifier__}->get_bucket_color($bucket) || ''), ($bucket || '') );
                $body .= " <input type=\"submit\" class=\"undoButton\" name=\"undo_$i\" value=\"$self->{language__}{Undo}\">\n";
            } else {
                if ( !defined($self->{classifier__}->get_bucket_color($bucket)))  {
                    $body .= "$bucket</td>\n<td>";
                } else {
                    $body .= "<font color=\"" . $self->{classifier__}->get_bucket_color($bucket) . "\">$bucket</font></td>\n<td>";
                }

                if ( $self->{history__}{$mail_file}{magnet} eq '' )  {
                    $body .= "\n<select name=\"$i\">\n";

                    # Show a blank bucket field
                    $body .= "<option selected=\"selected\"></option>\n";

                    foreach my $abucket (@buckets) {
                        $body .= "<option value=\"$abucket\">$abucket</option>\n";
                    }
                    $body .= "</select>\n";

                    if ( ( defined($self->{form_}{view}) ) && ( $self->{form_}{view} eq $mail_file ) ) {
                        $body .= "<input type=\"submit\" class=\"reclassifyButton\" name=\"change\" value=\"$self->{language__}{Reclassify}\" />";
                    }
                } else {
                    $body .= " ($self->{language__}{History_MagnetUsed}: $self->{history__}{$mail_file}{magnet})";
                }
            }

            $body .= "</td>\n<td>\n";
            $body .= "<label class=\"removeLabel\" for=\"remove_" . ( $i+1 ) . "\">$self->{language__}{Remove}</label>\n";
            $body .= "<input type=\"checkbox\" id=\"remove_" . ( $i+1 ) . "\" class=\"checkbox\" name=\"remove\" value=\"" . ( $i+1 ) . "\" />\n";
            $body .= "</td>\n</tr>\n";


            # Check to see if we want to view a message
            if ( ( defined($self->{form_}{view}) ) && ( $self->{form_}{view} eq $mail_file ) ) {
                $body .= "<tr>\n<td></td>\n<td colspan=\"5\" valign=\"top\">\n";
                $body .= "<table class=\"openMessageTable\" cellpadding=\"10%\" cellspacing=\"0\" width=\"100%\" summary=\"$self->{language__}{History_OpenMessageSummary}\">\n";

                # Close button
                $body .= "<tr>\n<td class=\"openMessageCloser\">\n";
                $body .= "<a class=\"messageLink\" href=\"/history?start_message=$start_message&amp;session=$self->{session_key__}&amp;sort=$self->{form_}{sort}&amp;search=$self->{form_}{search}&amp;filter=$self->{form_}{filter}\">\n";
                $body .= "<span class=\"historyLabel\">$self->{language__}{Close}</span></a>\n";
                $body .= "<br /><br />\n</td>\n</tr>\n";

                # Message body
                $body .= "<tr>\n<td class=\"openMessageBody\">";

                if ( $self->{history__}{$mail_file}{magnet} eq '' )  {
                    $body .= $self->{classifier__}->get_html_colored_message($self->global_config_( 'msgdir' ) . $self->{form_}{view});
                } else {
                    $self->{history__}{$mail_file}{magnet} =~ /(.+): ([^\r\n]+)/;
                    my $header = $1;
                    my $text   = $2;
                    $body .= "<tt>";

                    open MESSAGE, '<' . $self->global_config_( 'msgdir' ) . "$self->{form_}{view}";
                    my $line;
                    # process each line of the message
                    while ($line = <MESSAGE>) {
                        $line =~ s/</&lt;/g;
                        $line =~ s/>/&gt;/g;

                        $line =~ s/([^\r\n]{100,150} )/$1<br \/>/g;
                        $line =~ s/([^ \r\n]{150})/$1<br \/>/g;
                        $line =~ s/[\r\n]+/<br \/>/g;

                        if ( $line =~ /^([A-Za-z-]+): ?([^\n\r]*)/ ) {
                            my $head = $1;
                            my $arg  = $2;

                            if ( $head =~ /\Q$header\E/i )  {
                                if ( $arg =~ /\Q$text\E/i )  {
                                    my $new_color = $self->{classifier__}->get_bucket_color($self->{history__}{$mail_file}{bucket});
                                    $line =~ s/(\Q$text\E)/<b><font color=\"$new_color\">$1<\/font><\/b>/;
                                }
                            }
                        }

                        $body .= $line;
                    }
                    close MESSAGE;
                    $body .= "</tt>\n";
                }

                $body .= "</td>\n</tr>\n";

                # Close button
                $body .= "<tr>\n<td class=\"openMessageCloser\">";
                $body .= "<a class=\"messageLink\" href=\"/history?start_message=$start_message&amp;session=$self->{session_key__}&amp;sort=$self->{form_}{sort}&amp;search=$self->{form_}{search}&amp;filter=$self->{form_}{filter}\">\n";
                $body .= "<span class=\"historyLabel\">$self->{language__}{Close}</span>\n</a>\n";
                $body .= "</td>\n</tr>\n</table>\n";

                $body .= "<table><tr><td class=\"top20\" valign=\"top\">\n";
                $self->{classifier__}->classify_file($self->global_config_( 'msgdir' ) . "$self->{form_}{view}", $self);
                $body .= $self->{classifier__}->{scores__};
                $body .= "</tr></table></td>\n</tr>\n";
            }

            if ( defined $self->{feedback}{$mail_file} ) {
                $body .= "<tr class=\"rowHighlighted\"><td>&nbsp;</td><td>$self->{feedback}{$mail_file}</td>\n";
                delete $self->{feedback}{$mail_file};
            }

            # $body .= "<tr class=\"rowHighlighted\"><td><td>" . sprintf( $self->{language__}{History_ChangedTo}, " . $self->{classifier__}->get_bucket_color($self->{form_}{shouldbe}) . ", $self->{form_}{shouldbe} ) if ( ( defined($self->{form_}{file}) ) && ( $self->{form_}{file} eq $mail_file ) );
        }

        $body .= "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td><input type=\"submit\" class=\"reclassifyButton\" name=\"change\" value=\"$self->{language__}{Reclassify}\" />\n</td><td><input type=\"submit\" class=\"deleteButton\" name=\"deletemessage\" value=\"$self->{language__}{Remove}\" />\n</td></tr>\n";

        $body .= "</table>\n";

        #END main history form

        $body .= "</form>\n";

        # History buttons bottom
        $body .= "<table class=\"historyWidgetsBottom\" summary=\"\">\n<tr>\n<td>\n";
        $body .= "<form action=\"/history\">\n<input type=\"hidden\" name=\"filter\" value=\"$self->{form_}{filter}\" />\n";
        $body .= "<input type=\"hidden\" name=\"sort\" value=\"$self->{form_}{sort}\" />\n";
        $body .= "<span class=\"historyLabel\">$self->{language__}{History_Remove}:&nbsp;</span>\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"clearall\" value=\"$self->{language__}{History_RemoveAll}\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"clearpage\" value=\"$self->{language__}{History_RemovePage}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key__}\" />\n";
        $body .= "<input type=\"hidden\" name=\"start_message\" value=\"$start_message\" />\n</form>\n";
        $body .= "</td>\n</tr>\n</table>\n";

        # navigator
        $body .= "<table width=\"100%\" summary=\"\">\n<tr>\n<td class=\"historyNavigatorBottom\">\n";
        $body .= get_history_navigator( $self, $start_message, $stop_message ) if ( $self->config_( 'page_size' ) <= $self->history_size() );
        $body .= "\n</td>\n</tr>\n</table>\n";
    } else {
        $body .= "<h2 class=\"history\">$self->{language__}{History_Title}$filtered</h2><br /><br /><span class=\"bucketsLabel\">$self->{language__}{History_NoMessages}.</span><br /><br />";
        $body .= $self->get_search_filter_widget();
    }

    http_ok($self, $client,$body,2);
}

# ---------------------------------------------------------------------------------------------
#
# password_page - Simple page asking for the POPFile password
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub password_page
{
    my ( $self, $client, $error, $redirect ) = @_;
    my $session_temp = $self->{session_key__};

    # Show a page asking for the password with no session key information on it
    $self->{session_key__} = '';
    my $body = "<h2 class=\"password\">$self->{language__}{Password_Title}</h2>\n<form action=\"/password\" method=\"post\">\n";
    $body .= "<label class=\"passwordLabel\" for=\"thePassword\">$self->{language__}{Password_Enter}: </label>\n";
    $body .= "<input type=\"hidden\" name=\"redirect\" value=\"$redirect\" />\n";
    $body .= "<input type=\"password\" id=\"thePassword\" name=\"password\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"submit\" value=\"$self->{language__}{Password_Go}\" />\n</form>\n";
    $body .= "<blockquote>\n<div class=\"error02\">$self->{language__}{Password_Error1}</div>\n</blockquote>" if ( $error == 1 );
    http_ok($self, $client, $body, 99);
    $self->{session_key__} = $session_temp;
}

# ---------------------------------------------------------------------------------------------
#
# session_page - Simple page information the user of a bad session key
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub session_page
{
    my ( $self, $client ) = @_;
    http_ok($self, $client, "<h2 class=\"session\">$self->{language__}{Session_Title}</h2><br /><br />$self->{language__}{Session_Error}", 99);
}

# ---------------------------------------------------------------------------------------------
#
# load_skins
#
# Gets the names of all the CSS files in the skins subdirectory and loads them into the skins
# array.  The directory and .css portion of the file name is removed to give a simple name
#
# ---------------------------------------------------------------------------------------------
sub load_skins
{
    my ( $self ) = @_;

    @{$self->{skins__}} = glob 'skins/*.css';

    for my $i (0..$#{$self->{skins__}}) {
        $self->{skins__}[$i] =~ s/.*\/(.+)\.css/$1/;
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_languages
#
# Get the names of the available languages for the user interface
#
# ---------------------------------------------------------------------------------------------
sub load_languages
{
    my ( $self ) = @_;

    @{$self->{languages__}} = glob 'languages/*.msg';

    for my $i (0..$#{$self->{languages__}}) {
        $self->{languages__}[$i] =~ s/.*\/(.+)\.msg$/$1/;
    }
}

# ---------------------------------------------------------------------------------------------
#
# change_session_key
#
# Changes the session key
#
# ---------------------------------------------------------------------------------------------
sub change_session_key
{
    my ( $self ) = @_;

    $self->{session_key__} = '';
    for my $i (0 .. 7) {
        $self->{session_key__} .= chr(rand(1)*26+65);
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_language
#
# Fill the language hash with the language strings that are from the named language file
#
# $lang    - The language to load (no .msg extension)
#
# ---------------------------------------------------------------------------------------------
sub load_language
{
    my ( $self, $lang ) = @_;

    if ( open LANG, "<languages/$lang.msg" ) {
        while ( <LANG> ) {
            next if ( /[ \t]*#/ );

            if ( /([^ ]+)[ \t]+(.+)/ ) {
                my $id  = $1;
                my $msg = ($self->config_( 'test_language' ))?$1:$2;
                $msg =~ s/[\r\n]//g;

                $self->{language__}{$id} = $msg;
            }
        }
        close LANG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# remove_mail_files - Remove old popfile saved mail files
#
# Removes the popfile*.msg files that are older than a number of days configured as
# history_days.
#
# ---------------------------------------------------------------------------------------------
sub remove_mail_files
{
    my ( $self ) = @_;
    my $yesterday = defined($self->{today})?$self->{today}:0;
    $self->calculate_today();

    if ( $self->{today} > $yesterday ) {
        my @mail_files = glob( $self->global_config_( 'msgdir' ) . "popfile*=*.msg" );

        foreach my $mail_file (@mail_files) {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($mail_file);

            if ( $ctime < (time - $self->config_( 'history_days' ) * $seconds_per_day) )  {
                $self->history_delete_file( $mail_file, $self->config_( 'archive' ) );
            }
        }

         # Clean up old style msg/cls files

        @mail_files = glob( $self->global_config_( 'msgdir' ) . "popfile*_*.???" );

        foreach my $mail_file (@mail_files) {
            unlink($mail_file);
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# calculate_today - set the global $self->{today} variable to the current day in seconds
#
# ---------------------------------------------------------------------------------------------
sub calculate_today
{
    my ( $self ) = @_;

    $self->{today} = int( time / $seconds_per_day ) * $seconds_per_day;
}

# ---------------------------------------------------------------------------------------------
#
# history_delete_file   - Handle the deletion of archived message files. Deletes .cls
#                           files related to any .msg file.
#
# $mail_file    - The filename to delete with or without the directory prefix
# $archive      - Boolean, whether or not to save the file as part of an archive
#
# ---------------------------------------------------------------------------------------------
sub history_delete_file
{
    my ( $self, $mail_file, $archive ) = @_;

    $mail_file =~ /(popfile.+\=.+\.msg)$/;
    $mail_file = $1;
    $self->log_( "delete: $mail_file" );

    if ( $archive ) {
        my $path = $self->config_( 'archive_dir' );

        mkdir( $path );

        my ($reclassified, $bucket, $usedtobe, $magnet) = $self->history_load_class( $mail_file );

        if ( ( $bucket ne 'unclassified' ) && ( $bucket ne 'unknown class' ) ) {
            $path .= "\/" . $bucket;
            mkdir( $path );

            if ( $self->config_( 'archive_classes' ) > 0) {
                # archive to a random sub-directory of the bucket archive
                my $subdirectory = int( rand( $self->config_( 'archive_classes' ) ) );
                $path .= "\/" . $subdirectory;
                mkdir( $path );
            }

            # TODO This may be UNSAFE, please write a better comment that explains
            # why this might be unsafe.  What does unsafe mean in this context?

            $self->history_copy_file( $self->global_config_( 'msgdir' ) . "$mail_file", $path, $mail_file );
        }
    }

    # Before deleting the file make sure that the appropriate entry in the
    # history cache is also remove

    delete $self->{history__}{$mail_file};

    # Now remove the files from the disk, remove both the msg file containing
    # the mail message and its associated CLS file

    unlink( $self->global_config_( 'msgdir' ) . $mail_file );
    $mail_file =~ s/msg$/cls/;
    unlink( $self->global_config_( 'msgdir' ) . $mail_file );
}

# ---------------------------------------------------------------------------------------------
#
# history_copy_file     - Copies a file to a specified location and filename
#
#   $from       - The source file. May be relative or absolute.
#   $to_dir     - The destination directory. May be relative or absolute.
#                   Will not be created if non-existent.
#   $to_name    - The destination filename.
#
# ---------------------------------------------------------------------------------------------
sub history_copy_file
{
    my ( $self, $from, $to_dir, $to_name ) = @_;

    if ( open( FROM, "<$from") ) {
        if ( open( TO, ">$to_dir\/$to_name") ) {
            binmode FROM;
            binmode TO;

            while (<FROM>) {
                print TO $_;
            }

            close TO;
        }

        close FROM;
    }
}

# ---------------------------------------------------------------------------------------------
# register_configuration_item
#
#     $type            The type of item (configuration, security or chain)
#     $name            The name of the item
#     $object          Reference to the object calling this method
#
# This seemingly innocent method disguises a lot.  It is called by modules that wish to
# register that they have specific elements of UI that need to be dynamically added to the
# Configuration and Security screens of POPFile.  This is done so that the HTML module does
# not need to know about the modules that are loaded, their individual configuration elements
# or how to do validation
#
# A module calls this method for each separate UI element (normally an HTML form that handles
# a single configuration option) and passes in three pieces of information:
#
# The type is the position in the UI where the element is to be displayed. configuration means
# on the Configuration screen under "Module Options"; security means on the Security page
# and is used exclusively for stealth mode operation right now; chain is also on the security
# page and is used for identifying chain servers (in the case of SMTP the chained server and
# for POP3 the SPA server)
#
# The name (this is usually the name of the configuration option this registration is for, but
# any unique ID is acceptable).
#
# A reference to itself.
#
# When this module needs to display an element of UI it will call the object's configure_item
# public method passing in the name of the element required, a reference to the hash containing
# the current language strings and the session ID.  configure_item must return the complete
# HTML for the item
#
# When the module needs to validate it will call the object's validate_item interface passing
# in the name of the element, a reference to the language hash and a reference to the form
# hash which has been parsed.  validate_item returns HTML if it desires containing a
# confirmation or error message, or may return nothing if there was nothing in the form of
# interest to that specific module
#
# Example the module foo has a configuration item called bar which it needs a UI for, and
# so it calls
#
#    register_configuration_item( 'configuration', 'foo_bar', $self )
#
# later it will receive a call to its
#
#    configure_item( 'foo_bar', language hash, session key )
#
# and needs to return the HTML for the foo_bar item.  Then it will may receive a call to its
#
#    validate_item( 'foo_bar', language hash, form hash )
#
# and needs to check the form for information from any form it created and returned from the
# call to configure_item and update its own state.  It can optionally return HTML that
# will be displayed at the top of the page
#
# ---------------------------------------------------------------------------------------------
sub register_configuration_item
{
   my ( $self, $type, $name, $object ) = @_;

   $self->{dynamic_ui__}{$type}{$name} = $object;
}

# GETTERS/SETTERS

sub classifier
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{classifier__} = $value;
    }

    return $self->{classifier__};
}

sub language
{
    my ( $self ) = @_;

    return %{$self->{language__}};
}

sub session_key
{
    my ( $self ) = @_;

    return $self->{session_key__};
}

1;
