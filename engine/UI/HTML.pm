# POPFILE LOADABLE MODULE
package UI::HTML;

#----------------------------------------------------------------------------
#
# This package contains an HTML UI for POPFile
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#----------------------------------------------------------------------------
package UI::HTML;

use strict;
use warnings;
use locale;

use IO::Socket;
use IO::Select;

# A handy variable containing the value of an EOL for the network
my $eol = "\015\012";

# Constant used by the log rotation code
my $seconds_per_day = 60 * 60 * 24;

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self;

    # A reference to the POPFile::Configuration module

    $self->{configuration}   = 0;

    # The classifier (Classifier::Bayes)

    $self->{classifier}      = 0;

    # Hash used to store form parameters

    $self->{form}            = {};

    # Session key to make the UI safer

    $self->{session_key}     = '';

    # The available skins

    $self->{skins}           = ();

    # Used to keep the history information around so that we don't have to reglob every time we hit the
    # history page
    #
    # The history hash contains information about ALL the files stored in the history
    # folder (by default messages/) and is updated by the load_history_cache method
    #
    # Access to the history cache is formatted $self->{history}{file}{subkey} where
    # the file is the name of the file that is related to this history entry.
    #
    # The subkeys are
    #
    #   cull            Used internally by load_history_cache (see there for details)
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
    # load_history_cache, and is set by a call to invalidate_history_cache
    
    $self->{history_}         = {};
    $self->{history_keys_}    = ();
    $self->{history_invalid_} = 0;

    # A hash containing a mapping between alphanumeric identifiers and appropriate strings used
    # for localization.  The string may contain sprintf patterns for use in creating grammatically
    # correct strings, or simply be a string

    $self->{language}        = {};

    # This is the list of available languages

    $self->{languages}       = ();

    return bless $self, $type;
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

    $self->{configuration}->{configuration}{ui_port}           = 8080;

    # Checking for updates if off by default
    $self->{configuration}->{configuration}{update_check}      = 0;

    # Sending of statistics is off
    $self->{configuration}->{configuration}{send_stats}        = 0;

    # The size of a history page
    $self->{configuration}->{configuration}{page_size}         = 20;

    # Only accept connections from the local machine for the UI
    $self->{configuration}->{configuration}{localui}           = 1;

    # The default location for the message files
    $self->{configuration}->{configuration}{msgdir}            = 'messages/';

    # Use the default skin
    $self->{configuration}->{configuration}{skin}              = 'SimplyBlue';

    # Keep the history for two days
    $self->{configuration}->{configuration}{history_days}      = 2;

    # The last time we checked for an update using the local epoch
    $self->{configuration}->{configuration}{last_update_check} = 0;

    # The user interface password
    $self->{configuration}->{configuration}{password}          = '';

    # The last time (textual) that the statistics were reset
    $self->{configuration}->{configuration}{last_reset}        = localtime;

    # We start by assuming that the user speaks English like the
    # perfidious Anglo-Saxons that we are... :-)
    $self->{configuration}->{configuration}{language}          = 'English';

    # If this is 1 then when the language is loaded we will use the language string identifier as the
    # string shown in the UI.  This is used to test whether which identifiers are used where.
    $self->{configuration}->{configuration}{test_language}     = 0;

    # If 1, Messages are saved to an archive when they are removed or expired from the history cache
    $self->{configuration}->{configuration}{archive}            = 0;

    # The directory where messages will be archived to, in sub-directories for each bucket
    $self->{configuration}->{configuration}{archive_dir}        = "archive";

    # This is an advanced setting which will save archived files to a randomly numbered
    # sub-directory, if set to greater than zero, otherwise messages will be saved in the
    # bucket directory
    # 0 <= directory name < archive_classes
    $self->{configuration}->{configuration}{archive_classes}    = 0;

    # Load skins
    load_skins($self);

    # Load the list of available user interface languages
    load_languages($self);

    # Calculate a session key
    change_session_key($self);

    $self->remove_mail_files();
    $self->calculate_today();

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

    # Load the current configuration from disk and then load up the
    # appropriate language, note that we always load English first
    # so that any extensions to the user interface that have not yet
    # been translated will still appear

    load_language( $self, 'English' );
    load_language( $self, $self->{configuration}->{configuration}{language} ) if ( $self->{configuration}->{configuration}{language} ne 'English' );

    # We need to force a history cache reload, note that this needs
    # to come after loading the language since we might need History_NoFrom
    # or History_NoSubject in while loading the cache

    $self->invalidate_history_cache();
    $self->load_history_cache();
    $self->sort_filter_history( '', '', '' );

    $self->{server} = IO::Socket::INET->new( Proto     => 'tcp',
                                    $self->{configuration}->{configuration}{localui}  == 1 ? (LocalAddr => 'localhost') : (),
                                     LocalPort => $self->{configuration}->{configuration}{ui_port},
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 );

    if ( !defined( $self->{server} ) ) {
        print <<EOM;

\nCouldn't start the HTTP interface because POPFile could not bind to the
HTTP port $self->{configuration}->{configuration}{ui_port}. This could be because there is another service
using that port or because you do not have the right privileges on
your system (On Unix systems this can happen if you are not root
and the port you specified is less than 1024).

EOM

    return 0;
    }

    $self->{selector} = new IO::Select( $self->{server} );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called when the interface must shutdown
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    close $self->{server} if ( defined( $self->{server} ) );
}

# ---------------------------------------------------------------------------------------------
#
# name
#
# Called to get the simple name for this module
#
# ---------------------------------------------------------------------------------------------
sub name
{
    my ( $self ) = @_;

    return 'html';
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

    my $code = 1;

    # See if there's a connection waiting for us, if there is we accept it handle a single
    # request and then exit
    my ( $uiready ) = $self->{selector}->can_read(0);

    # Handle HTTP requests for the UI
    if ( ( defined($uiready) ) && ( $uiready == $self->{server} ) ) {
        if ( my $client = $self->{server}->accept() ) {
            # Check that this is a connection from the local machine, if it's not then we drop it immediately
            # without any further processing.  We don't want to allow remote users to admin POPFile
            my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

            if ( ( $self->{configuration}->{configuration}{localui} == 0 ) || 
                 ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {

                # Read the request line (GET or POST) from the client and if we manage to do that
                # then read the rest of the HTTP headers grabbing the Content-Length and using
                # it to read any form POST content into $content

                if ( ( defined($client) ) && ( my $request = <$client> ) ) {
                    my $content_length = 0;
                    my $content;

                    while ( <$client> )  {
                        $content_length = $1 if ( /Content-Length: (\d+)/i );
                        last                 if ( !/[A-Z]/i );
                    }

                    if ( $content_length > 0 ) {
                        $content = '';
                        $client->read( $content, $content_length, length( $content ) );
                    }

                    if ( $request =~ /^(GET|POST) (.*) HTTP\/1\./i ) {
                        $client->autoflush(1);
                        $code = $self->handle_url($client, $2, $1, $content);
                    } else {
                        http_error( $self, $client, 500 );
                    }
                }
            }

            close $client;
        }
    }

    $self->remove_mail_files();

    return $code;
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# Called when someone forks POPFile
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;

    close $self->{server};
}

# ---------------------------------------------------------------------------------------------
#
# reaper
#
# Called to reap our dead children
#
# ---------------------------------------------------------------------------------------------
sub reaper
{
    my ( $self ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# http_redirect - tell the browser to redirect to a url
#
# $client   The web browser to send redirect to
# $url      Where to go
#
# Return a valid HTTP/1.0 header containing a 302 redirect message to the passed in URL
#
# ---------------------------------------------------------------------------------------------
sub http_redirect
{
    my ( $self, $client, $url ) = @_;

    my $header = "HTTP/1.0 302 Found\r\nLocation: ";
    $header .= $url;
    $header .= "$eol$eol";
    print $client $header;
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
    if ( $self->{today} ne $self->{configuration}->{configuration}{last_update_check} ) {
        calculate_today( $self );

        if ( $self->{configuration}->{configuration}{update_check} ) {
            $update_check = "<a href=\"http://sourceforge.net/project/showfiles.php?group_id=63137\">\n";
            $update_check .= "<img border=\"0\" alt=\"\" src=\"http://www.usethesource.com/cgi-bin/popfile_update.pl?ma=$self->{configuration}{major_version}&amp;mi=$self->{configuration}{minor_version}&amp;bu=$self->{configuration}{build_version}\" />\n</a>\n";
        }

        if ( $self->{configuration}->{configuration}{send_stats} ) {
            my @buckets = keys %{$self->{classifier}->{total}};
            my $bc      = $#buckets + 1;
            $update_check .= "<img border=\"0\" alt=\"\" src=\"http://www.usethesource.com/cgi-bin/popfile_stats.pl?bc=$bc&amp;mc=$self->{configuration}->{configuration}{mcount}&amp;ec=$self->{configuration}->{configuration}{ecount}\" />\n";
        }

        $self->{configuration}->{configuration}{last_update_check} = $self->{today};
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
    $result .= "<html lang=\"$self->{language}{LanguageCode}\">\n<head>\n<title>$self->{language}{Header_Title}</title>\n";

    # If we are handling the shutdown page, then send the CSS along with the
    # page to avoid a request back from the browser _after_ we've shutdown,
    # otherwise, send the link to the CSS file so it is cached by the browser.

    if ( $selected == -1 ) {
        $result .= "<style type=\"text/css\">\n";
        if ( open FILE, "<skins/$self->{configuration}->{configuration}{skin}.css" ) {
            while (<FILE>) {
                $result .= $_;
            }
            close FILE;
        }
        $result .= "</style>\n";
    } else {
        $result .= "<link rel=\"stylesheet\" type=\"text/css\" ";
        $result .= "href=\"skins/$self->{configuration}->{configuration}{skin}.css\" title=\"$self->{configuration}->{configuration}{skin}\">\n";
    }

    $result .= "<meta http-equiv=\"Pragma\" content=\"no-cache\">\n";
    $result .= "<meta http-equiv=\"Expires\" content=\"0\">\n";

    $result .= "<meta http-equiv=\"Cache-Control\" content=\"no-cache\">\n";
    $result .= "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$self->{language}{LanguageCharset}\">\n</head>\n";

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
    $result .= "<td class=\"head\">$self->{language}{Header_Title}</td>\n";

    # shutdown
    $result .= "<td align=\"right\" valign=\"bottom\">\n";
    $result .= "<a class=\"shutdownLink\" href=\"/shutdown\">$self->{language}{Header_Shutdown}</a>&nbsp;\n";

    $result .= "</td>\n</tr>\n<tr>\n";
    $result .= "<td height=\"1%\" colspan=\"3\"></td>\n</tr>\n";
    $result .= "</table>\n</td>\n"; # colspan 2 ?? srk
    $result .= "<td class=\"shellRight\"></td>\n</tr>\n<tr class=\"shellBottomRow\">\n";

    $result .= "<td class=\"shellBottomLeft\"></td>\n<td class=\"shellBottomCenter\"></td>\n";
    $result .= "<td class=\"shellBottomRight\"></td>\n</tr>\n</table>\n";

    # update check
    $result .= "<table align=\"center\" summary=\"\">\n<tr>\n<td class=\"logo2menuSpace\">$update_check</td></tr></table>\n";

    # menu start
    $result .= "<table class=\"menu\" cellspacing=\"0\" summary=\"$self->{language}{Header_MenuSummary}\">\n";
    $result .= "<tr>\n";

    # blank menu item for indentation
    $result .= "<td class=\"menuIndent\">&nbsp;</td>";

    # History menu item
    $result .= "<td class=\"$tab[2]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/history?session=$self->{session_key}&amp;setfilter=\">";
    $result .= "\n$self->{language}{Header_History}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Buckets menu item
    $result .= "<td class=\"$tab[1]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/buckets?session=$self->{session_key}\">";
    $result .= "\n$self->{language}{Header_Buckets}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Magnets menu item
    $result .= "<td class=\"$tab[4]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/magnets?session=$self->{session_key}\">";
    $result .= "\n$self->{language}{Header_Magnets}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Configuration menu item
    $result .= "<td class=\"$tab[0]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/configuration?session=$self->{session_key}\">";
    $result .= "\n$self->{language}{Header_Configuration}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Security menu item
    $result .= "<td class=\"$tab[3]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/security?session=$self->{session_key}\">";
    $result .= "\n$self->{language}{Header_Security}</a>\n";
    $result .= "</td>\n<td class=\"menuSpacer\"></td>\n";

    # Advanced menu item
    $result .= "<td class=\"$tab[5]\" align=\"center\">\n";
    $result .= "<a class=\"menuLink\" href=\"/advanced?session=$self->{session_key}\">";
    $result .= "\n$self->{language}{Header_Advanced}</a>\n";
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
    $result .= "POPFile $self->{configuration}{major_version}.$self->{configuration}{minor_version}.";
    $result .= "$self->{configuration}{build_version} - \n";
    $result .= "<a class=\"bottomLink\" href=\""; 
    
    # To save space on the download of POPFile only the English language manual
    # is shipped and available locally, all other languages are referenced through
    # the POPFile home page on SourceForge
    
    if ( $self->{language}{ManualLanguage} eq 'en' ) {
        $result .= 'manual/en';
    } else {
        $result .= "http://popfile.sourceforge.net/manual/$self->{language}{ManualLanguage}";
    }

    $result .= "/manual.html\">\n";
    $result .= "$self->{language}{Footer_Manual}</a> - \n";

    $result .= "<a class=\"bottomLink\" href=\"http://sourceforge.net/docman/display_doc.php?docid=14421&group_id=63137\">FAQ</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://popfile.sourceforge.net/\">$self->{language}{Footer_HomePage}</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://sourceforge.net/forum/forum.php?forum_id=213876\">$self->{language}{Footer_FeedMe}</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://sourceforge.net/tracker/index.php?group_id=63137&amp;atid=502959\">$self->{language}{Footer_RequestFeature}</a> - \n";
    $result .= "<a class=\"bottomLink\" href=\"http://lists.sourceforge.net/lists/listinfo/popfile-announce\">$self->{language}{Footer_MailingList}</a> - \n";
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
# http_file - Read a file from disk and send it to the other end
#
# $client     The web browser to send the results to
# $file       The file to read (always assumed to be a GIF right now)
# $type       Set this to the HTTP return type (e.g. text/html or image/gif)
#
# Returns the contents of a file formatted into an HTTP 200 message or an HTTP 404 if the
# file does not exist
#
# ---------------------------------------------------------------------------------------------
sub http_file
{
    my ( $self, $client, $file, $type ) = @_;
    my $contents = '';
    if ( open FILE, "<$file" ) {
        binmode FILE;
        while (<FILE>) {
            $contents .= $_;
        }
        close FILE;

        my $header = "HTTP/1.0 200 OK\r\nContent-Type: $type\r\nContent-Length: ";
        $header .= length($contents);
        $header .= "$eol$eol";
        print $client $header . $contents;
    } else {
        http_error( $self, $client, 404 );
    }
}

# ---------------------------------------------------------------------------------------------
#
# http_error - Output a standard HTTP error message
#
# $client     The web browser to send the results to
# $error      The error number
#
# Return a simple HTTP error message in HTTP 1/0 format
#
# ---------------------------------------------------------------------------------------------
sub http_error
{
    my ( $self, $client, $error ) = @_;

    print $client "HTTP/1.0 $error Error$eol$eol";
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

    $self->{configuration}->{configuration}{skin}    = $self->{form}{skin}      if ( defined($self->{form}{skin}) );
    $self->{configuration}->{configuration}{debug}   = $self->{form}{debug}-1   if ( ( defined($self->{form}{debug}) ) && ( ( $self->{form}{debug} >= 1 ) && ( $self->{form}{debug} <= 4 ) ) );
    $self->{configuration}->{configuration}{subject} = $self->{form}{subject}-1 if ( ( defined($self->{form}{subject}) ) && ( ( $self->{form}{subject} >= 1 ) && ( $self->{form}{subject} <= 2 ) ) );
    $self->{configuration}->{configuration}{xtc}     = $self->{form}{xtc}-1     if ( ( defined($self->{form}{xtc}) ) && ( ( $self->{form}{xtc} >= 1 ) && ( $self->{form}{xtc} <= 2 ) ) );
    $self->{configuration}->{configuration}{xpl}     = $self->{form}{xpl}-1     if ( ( defined($self->{form}{xpl}) ) && ( ( $self->{form}{xpl} >= 1 ) && ( $self->{form}{xpl} <= 2 ) ) );

    if ( defined($self->{form}{language}) ) {
        if ( $self->{configuration}->{configuration}{language} ne $self->{form}{language} ) {
            $self->{configuration}->{configuration}{language} = $self->{form}{language};
            load_language( $self,  $self->{configuration}->{configuration}{language} );
        }
    }

    if ( defined($self->{form}{separator}) ) {
        if ( length($self->{form}{separator}) == 1 ) {
            $self->{configuration}->{configuration}{separator} = $self->{form}{separator};
        } else {
            $separator_error = "<blockquote>\n<div class=\"error01\">\n";
            $separator_error .= "$self->{language}{Configuration_Error1}</div>\n</blockquote>\n";
            delete $self->{form}{separator};
        }
    }

    if ( defined($self->{form}{ui_port}) ) {
        if ( ( $self->{form}{ui_port} >= 1 ) && ( $self->{form}{ui_port} < 65536 ) ) {
            $self->{configuration}->{configuration}{ui_port} = $self->{form}{ui_port};
        } else {
            $ui_port_error = "<blockquote>\n<div class=\"error01\">\n";
            $ui_port_error .= "$self->{language}{Configuration_Error2}</div>\n</blockquote>\n";
            delete $self->{form}{ui_port};
        }
    }

    if ( defined($self->{form}{port}) ) {
        if ( ( $self->{form}{port} >= 1 ) && ( $self->{form}{port} < 65536 ) ) {
            $self->{configuration}->{configuration}{port} = $self->{form}{port};
        } else {
            $port_error = "<blockquote><div class=\"error01\">$self->{language}{Configuration_Error3}</div></blockquote>";
            delete $self->{form}{port};
        }
    }

    if ( defined($self->{form}{page_size}) ) {
        if ( ( $self->{form}{page_size} >= 1 ) && ( $self->{form}{page_size} <= 1000 ) ) {
            $self->{configuration}->{configuration}{page_size} = $self->{form}{page_size};
        } else {
            $page_size_error = "<blockquote><div class=\"error01\">$self->{language}{Configuration_Error4}</div></blockquote>";
            delete $self->{form}{page_size};
        }
    }

    if ( defined($self->{form}{history_days}) ) {
        if ( ( $self->{form}{history_days} >= 1 ) && ( $self->{form}{history_days} <= 366 ) ) {
            $self->{configuration}->{configuration}{history_days} = $self->{form}{history_days};
        } else {
            $history_days_error = "<blockquote><div class=\"error01\">$self->{language}{Configuration_Error5}</div></blockquote>";
            delete $self->{form}{history_days};
        }
    }

    if ( defined($self->{form}{timeout}) ) {
        if ( ( $self->{form}{timeout} >= 10 ) && ( $self->{form}{timeout} <= 300 ) ) {
            $self->{configuration}->{configuration}{timeout} = $self->{form}{timeout};
        } else {
            $timeout_error = "<blockquote><div class=\"error01\">$self->{language}{Configuration_Error6}</div></blockquote>";
            $self->{form}{update_timeout} = '';
        }
    }

    # User Interface panel
    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language}{Configuration_MainTableSummary}\">\n";
    $body .= "<tr>\n<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language}{Configuration_UserInterface}</h2>\n";
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configSkin\">$self->{language}{Configuration_SkinsChoose}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "<select name=\"skin\" id=\"configSkin\">\n";

    # Create three groupings for skins

    # Normal skins
    $body .= "<optgroup label=\"$self->{language}{Configuration_GeneralSkins}\">\n";
    for my $i (0..$#{$self->{skins}}) {
        if ( !( $self->{skins}[$i] =~ /^(small|tiny)/i  ) ) {
            $body .= "<option value=\"$self->{skins}[$i]\"";
            $body .= " selected=\"selected\"" if ( $self->{skins}[$i] eq $self->{configuration}->{configuration}{skin} );
            $body .= ">$self->{skins}[$i]</option>\n";
        }
    }
    $body .= "</optgroup>\n";

    # Small skins
    $body .= "<optgroup label=\"$self->{language}{Configuration_SmallSkins}\">\n";
    for my $i (0..$#{$self->{skins}}) {
        if ( $self->{skins}[$i] =~ /^small/i  ) {
            $body .= "<option value=\"$self->{skins}[$i]\"";
            $body .= " selected=\"selected\"" if ( $self->{skins}[$i] eq $self->{configuration}->{configuration}{skin} );
            $body .= ">$self->{skins}[$i]</option>\n";
        }
    }
    $body .= "</optgroup>\n";

    # Tiny skins
    $body .= "<optgroup label=\"$self->{language}{Configuration_TinySkins}\">\n";
    for my $i (0..$#{$self->{skins}}) {
        if ( $self->{skins}[$i] =~ /^tiny/i  ) {
            $body .= "<option value=\"$self->{skins}[$i]\"";
            $body .= " selected=\"selected\"" if ( $self->{skins}[$i] eq $self->{configuration}->{configuration}{skin} );
            $body .= ">$self->{skins}[$i]</option>\n";
        }
    }
    $body .= "</optgroup>\n";

    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"change_skin\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "</form>\n";

    # Choose Language widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configLanguage\">$self->{language}{Configuration_LanguageChoose}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "<select name=\"language\" id=\"configLanguage\">\n";
    for my $i (0..$#{$self->{languages}}) {
        $body .= "<option value=\"$self->{languages}[$i]\"";
        $body .= " selected=\"selected\"" if ( $self->{languages}[$i] eq $self->{configuration}->{configuration}{language} );
        $body .= ">$self->{languages}[$i]</option>\n";
    }
    $body .= "</select>\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"change_language\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "</form>\n</td>\n";

    # History View panel
    $body .= "<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language}{Configuration_HistoryView}</h2>\n";

    # Emails per Page widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configPageSize\">$self->{language}{Configuration_History}:</label><br />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_page_size\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input name=\"page_size\" id=\"configPageSize\" type=\"text\" value=\"$self->{configuration}->{configuration}{page_size}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$page_size_error\n";
    $body .= sprintf( $self->{language}{Configuration_HistoryUpdate}, $self->{configuration}->{configuration}{page_size} ) if ( defined($self->{form}{page_size}) );

    # Days of History to Keep widget
    $body .= "\n<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configHistoryDays\">$self->{language}{Configuration_Days}:</label> <br />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_history_days\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input name=\"history_days\" id=\"configHistoryDays\" type=\"text\" value=\"$self->{configuration}->{configuration}{history_days}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "</form>\n$history_days_error\n";
    $body .= sprintf( $self->{language}{Configuration_DaysUpdate}, $self->{configuration}->{configuration}{history_days} ) if ( defined($self->{form}{history_days}) );

    # Classification Insertion panel
    $body .= "</td>\n<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language}{Configuration_ClassificationInsertion}</h2>\n";

    # Subject line modification widget
    $body .= "<table width=\"100%\" summary=\"$self->{language}{Configuration_InsertionTableSummary}\">\n<tr>\n";
    $body .= "<th valign=\"baseline\" scope=\"row\">\n<span class=\"configurationLabel\">$self->{language}{Configuration_SubjectLine}:</span>\n</th>\n";
    if ( $self->{configuration}->{configuration}{subject} == 1 ) {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOn\">$self->{language}{On}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"configSubjectOff\" name=\"toggle\" value=\"$self->{language}{TurnOff}\" />\n";
        $body .= "<input type=\"hidden\" name=\"subject\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n</td>\n";
    } else {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOff\">$self->{language}{Off}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"configSubjectOn\" name=\"toggle\" value=\"$self->{language}{TurnOn}\" />\n";
        $body .= "<input type=\"hidden\" name=\"subject\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n</td>\n";
    }

    # X-Text-Classification insertion widget
    $body .= "</tr>\n<tr>\n<th valign=\"baseline\" scope=\"row\">\n<span class=\"configurationLabel\">$self->{language}{Configuration_XTCInsertion}:</span></th>\n";
    if ( $self->{configuration}->{configuration}{xtc} == 1 ) {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOn\">$self->{language}{On}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"configXTCOff\" name=\"toggle\" value=\"$self->{language}{TurnOff}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xtc\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n</td>\n";
    } else {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOff\">$self->{language}{Off}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"configXTCOn\" name=\"toggle\" value=\"$self->{language}{TurnOn}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xtc\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n</td>\n";
    }

    # X-POPFile-Link insertion widget
    $body .= "</tr>\n<tr>\n<th valign=\"baseline\" scope=\"row\">\n<span class=\"configurationLabel\">$self->{language}{Configuration_XPLInsertion}:</span></th>\n";
    if ( $self->{configuration}->{configuration}{xpl} == 1 ) {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOn\">$self->{language}{On}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"configXPLOff\" name=\"toggle\" value=\"$self->{language}{TurnOff}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xpl\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n</td>\n";
    } else {
        $body .= "<td valign=\"baseline\" align=\"right\">\n";
        $body .= "<form class=\"configSwitch\" style=\"margin: 0\" action=\"/configuration\">\n";
        $body .= "<span class=\"configWidgetStateOff\">$self->{language}{Off}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"configXPLOn\" name=\"toggle\" value=\"$self->{language}{TurnOn}\" />\n";
        $body .= "<input type=\"hidden\" name=\"xpl\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n</td>\n";
    }
    $body .= "</tr>\n</table>\n<br />\n";

    # Listen Ports panel
    $body .= "</td>\n</tr>\n<tr>\n<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language}{Configuration_ListenPorts}</h2>\n";

    # POP3 Listen Port widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configPopPort\">$self->{language}{Configuration_POP3Port}:</label><br />\n";
    $body .= "<input name=\"port\" type=\"text\" id=\"configPopPort\" value=\"$self->{configuration}->{configuration}{port}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_port\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$port_error\n";
    $body .= sprintf( $self->{language}{Configuration_POP3Update}, $self->{configuration}->{configuration}{port} ) if ( defined($self->{form}{port}) );

    # Separator Character widget
    $body .= "\n<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configSeparator\">$self->{language}{Configuration_Separator}:</label><br />\n";
    $body .= "<input name=\"separator\" id=\"configSeparator\" type=\"text\" value=\"$self->{configuration}->{configuration}{separator}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_separator\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$separator_error\n";
    $body .= sprintf( $self->{language}{Configuration_SepUpdate}, $self->{configuration}->{configuration}{separator} ) if ( defined($self->{form}{separator}) );

    # User Interface Port widget
    $body .= "\n<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configUIPort\">$self->{language}{Configuration_UI}:</label><br />\n";
    $body .= "<input name=\"ui_port\" id=\"configUIPort\" type=\"text\" value=\"$self->{configuration}->{configuration}{ui_port}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_ui_port\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$ui_port_error";
    $body .= sprintf( $self->{language}{Configuration_UIUpdate}, $self->{configuration}->{configuration}{ui_port} ) if ( defined($self->{form}{ui_port}) );
    $body .= "<br />\n</td>\n";

    # TCP Connection Timeout panel
    $body .= "<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language}{Configuration_TCPTimeout}</h2>\n";

    # TCP Conn TO widget
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configTCPTimeout\">$self->{language}{Configuration_TCPTimeoutSecs}:</label><br />\n";
    $body .= "<input name=\"timeout\" type=\"text\" id=\"configTCPTimeout\" value=\"$self->{configuration}->{configuration}{timeout}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_timeout\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$timeout_error";
    $body .= sprintf( $self->{language}{Configuration_TCPTimeoutUpdate}, $self->{configuration}->{configuration}{timeout} ) if ( defined($self->{form}{timeout}) );
    $body .= "</td>\n";

    # Logging panel
    $body .= "<td class=\"settingsPanel\" width=\"33%\" valign=\"top\">\n";
    $body .= "<h2 class=\"configuration\">$self->{language}{Configuration_Logging}</h2>\n";
    $body .= "<form action=\"/configuration\">\n";
    $body .= "<label class=\"configurationLabel\" for=\"configLogging\">$self->{language}{Configuration_LoggerOutput}:</label>\n";
    $body .= "<input type=\"hidden\" value=\"$self->{session_key}\" name=\"session\" />\n";
    $body .= "<select name=\"debug\" id=\"configLogging\">\n";
    $body .= "<option value=\"1\"";
    $body .= " selected=\"selected\"" if ( $self->{configuration}->{configuration}{debug} == 0 );
    $body .= ">$self->{language}{Configuration_None}</option>\n";
    $body .= "<option value=\"2\"";
    $body .= " selected=\"selected\"" if ( $self->{configuration}->{configuration}{debug} == 1 );
    $body .= ">$self->{language}{Configuration_ToFile}</option>\n";
    $body .= "<option value=\"3\"";
    $body .= " selected=\"selected\"" if ( $self->{configuration}->{configuration}{debug} == 2 );
    $body .= ">$self->{language}{Configuration_ToScreen}</option>\n";
    $body .= "<option value=\"4\"";
    $body .= " selected=\"selected\"" if ( $self->{configuration}->{configuration}{debug} == 3 );
    $body .= ">$self->{language}{Configuration_ToScreenFile}</option>\n";
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"submit_debug\" value=\"$self->{language}{Apply}\" />\n";
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


    $self->{configuration}->{configuration}{password}     = $self->{form}{password}         if ( defined($self->{form}{password}) );
    $self->{configuration}->{configuration}{server}       = $self->{form}{server}           if ( defined($self->{form}{server}) );
    $self->{configuration}->{configuration}{localpop}     = $self->{form}{localpop} - 1     if ( defined($self->{form}{localpop}) );
    $self->{configuration}->{configuration}{localui}      = $self->{form}{localui} - 1      if ( defined($self->{form}{localui}) );
    $self->{configuration}->{configuration}{update_check} = $self->{form}{update_check} - 1 if ( defined($self->{form}{update_check}) );
    $self->{configuration}->{configuration}{send_stats}   = $self->{form}{send_stats} - 1   if ( defined($self->{form}{send_stats}) );

    if ( defined($self->{form}{sport}) ) {
        if ( ( $self->{form}{sport} >= 1 ) && ( $self->{form}{sport} < 65536 ) ) {
            $self->{configuration}->{configuration}{sport} = $self->{form}{sport};
        } else {
            $port_error = "<blockquote><div class=\"error01\">$self->{language}{Security_Error1}</div></blockquote>";
            delete $self->{form}{sport};
        }
    }

    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language}{Security_MainTableSummary}\">\n<tr>\n";

    # Stealth Mode / Server Operation panel
    $body .= "<td class=\"settingsPanel\" width=\"50%\" valign=\"top\">\n";
    $body .= "<h2 class=\"security\">$self->{language}{Security_Stealth}</h2>\n";

    # Accept POP3 from Remote Machines widget
    $body .= "<span class=\"securityLabel\">$self->{language}{Security_POP3}:</span><br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";
    if ( $self->{configuration}->{configuration}{localpop} == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language}{Security_NoStealthMode}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityAcceptPOP3On\" name=\"toggle\" value=\"$self->{language}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"localpop\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityAcceptPOP3Off\" name=\"toggle\" value=\"$self->{language}{ChangeToNo} (Stealth Mode)\" />\n";
        $body .= "<input type=\"hidden\" name=\"localpop\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";

    # Accept HTTP from Remote Machines widget
    $body .= "<span class=\"securityLabel\">$self->{language}{Security_UI}:</span><br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td>\n";
    if ( $self->{configuration}->{configuration}{localui} == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language}{Security_NoStealthMode}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityAcceptHTTPOn\" name=\"toggle\" value=\"$self->{language}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"localui\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityAcceptHTTPOff\" name=\"toggle\" value=\"$self->{language}{ChangeToNo} (Stealth Mode)\" />\n";
        $body .= "<input type=\"hidden\" name=\"localui\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";
    $body .= "</td>\n";

    # User Interface Password panel
    $body .= "<td class=\"settingsPanel\" width=\"50%\" valign=\"top\" >\n";
    $body .= "<h2 class=\"security\">$self->{language}{Security_PasswordTitle}</h2>\n";

    # optional widget placement
    $body .= "<div class=\"securityPassWidget\">\n";

    # Password widget
    $body .= "<form action=\"/security\" method=\"post\">\n";
    $body .= "<label class=\"securityLabel\" for=\"securityPassword\">$self->{language}{Security_Password}:</label> <br />\n";
    $body .= "<input type=\"password\" id=\"securityPassword\" name=\"password\" value=\"$self->{configuration}->{configuration}{password}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_server\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    $body .= sprintf( $self->{language}{Security_PasswordUpdate}, $self->{configuration}->{configuration}{password} ) if ( defined($self->{form}{password}) );

   # end optional widget placement
   $body .= "</div>\n</td>\n</tr>\n";

    # Automatic Update Checking panel
    $body .= "<tr>\n<td class=\"settingsPanel\" width=\"50%\" valign=\"top\">\n";
    $body .= "<h2 class=\"security\">$self->{language}{Security_UpdateTitle}</h2>\n";

    # Check Daily for Updates widget
    $body .= "<span class=\"securityLabel\">$self->{language}{Security_Update}:</span><br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td>\n";
    if ( $self->{configuration}->{configuration}{update_check} == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityUpdateCheckOff\" name=\"toggle\" value=\"$self->{language}{ChangeToNo}\" />\n";
        $body .= "<input type=\"hidden\" name=\"update_check\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language}{No}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityUpdateCheckOn\" name=\"toggle\" value=\"$self->{language}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"update_check\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";

    # explanation of same
    $body .= "<div class=\"securityExplanation\">$self->{language}{Security_ExplainUpdate}</div>\n</td>\n";

    # Reporting Statistics panel
    $body .= "<td class=\"settingsPanel\" width=\"50%\" valign=\"top\">\n";
    $body .= "<h2 class=\"security\">$self->{language}{Security_StatsTitle}</h2>\n";

    # Send Statistics Daily widget
    $body .= "<span class=\"securityLabel\">$self->{language}{Security_Stats}:</span>\n<br />\n";

    $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td>\n";
    if ( $self->{configuration}->{configuration}{send_stats} == 1 ) {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOn\">$self->{language}{Yes}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securitySendStatsOff\" name=\"toggle\" value=\"$self->{language}{ChangeToNo}\" />\n";
        $body .= "<input type=\"hidden\" name=\"send_stats\" value=\"1\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    } else {
        $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
        $body .= "<span class=\"securityWidgetStateOff\">$self->{language}{No}</span>\n";
        $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securitySendStatsOn\" name=\"toggle\" value=\"$self->{language}{ChangeToYes}\" />\n";
        $body .= "<input type=\"hidden\" name=\"send_stats\" value=\"2\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    }
    $body .= "</td></tr></table>\n";
    # explanation of same
    $body .= "<div class=\"securityExplanation\">$self->{language}{Security_ExplainStats}</div>\n</td>\n</tr>\n";

    # Secure Password Authentication/AUTH panel
    $body .= "<tr>\n<td class=\"settingsPanel\" width=\"100%\" valign=\"top\" colspan=\"2\">\n";
    $body .= "<h2 class=\"security\">$self->{language}{Security_AUTHTitle}</h2>\n";

    # optional widgets placement
    $body .= "<div class=\"securityAuthWidgets\">\n";

    # Secure Server widget
    $body .= "<form action=\"/security\">\n";
    $body .= "<label class=\"securityLabel\" for=\"securitySecureServer\">$self->{language}{Security_SecureServer}:</label><br />\n";
    $body .= "<input type=\"text\" name=\"server\" id=\"securitySecureServer\" value=\"$self->{configuration}->{configuration}{server}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_server\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n";
    $body .= sprintf( $self->{language}{Security_SecureServerUpdate}, $self->{configuration}->{configuration}{server} ) if ( defined($self->{form}{server}) );

    # Secure Port widget
    $body .= "<form action=\"/security\">\n";
    $body .= "<label class=\"securityLabel\" for=\"securitySecurePort\">$self->{language}{Security_SecurePort}:</label><br />\n";
    $body .= "<input type=\"text\" name=\"sport\" id=\"securitySecurePort\" value=\"$self->{configuration}->{configuration}{sport}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_sport\" value=\"$self->{language}{Apply}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$port_error";
    $body .= sprintf( $self->{language}{Security_SecurePortUpdate}, $self->{configuration}->{configuration}{sport} ) if ( defined($self->{form}{sport}) );

    # end optional widgets placement
    $body .= "</div>\n</td>\n</tr>\n";

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
    if ( defined($self->{form}{newword}) ) {
        $self->{form}{newword} = lc($self->{form}{newword});
        if ( defined($self->{classifier}->{parser}->{mangle}->{stop}{$self->{form}{newword}}) ) {
            $add_message = "<blockquote><div class=\"error02\"><b>". sprintf( $self->{language}{Advanced_Error1}, $self->{form}{newword} ) . "</b></div></blockquote>";
        } else {
            if ( $self->{form}{newword} =~ /[^[:alpha:][0-9]\._\-@]/ ) {
                $add_message = "<blockquote><div class=\"error02\"><b>$self->{language}{Advanced_Error2}</b></div></blockquote>";
            } else {
                $self->{classifier}->{parser}->{mangle}->{stop}{$self->{form}{newword}} = 1;
                $self->{classifier}->{parser}->{mangle}->save_stop_words();
                $add_message = "<blockquote>" . sprintf( $self->{language}{Advanced_Error3}, $self->{form}{newword} ) . "</blockquote>";
            }
        }
    }

    if ( defined($self->{form}{word}) ) {
        $self->{form}{word} = lc($self->{form}{word});
        if ( !defined($self->{classifier}->{parser}->{mangle}->{stop}{$self->{form}{word}}) ) {
            $deletemessage = "<blockquote><div class=\"error02\"><b>" . sprintf( $self->{language}{Advanced_Error4} , $self->{form}{word} ) . "</b></div></blockquote>";
        } else {
            delete $self->{classifier}->{parser}->{mangle}->{stop}{$self->{form}{word}};
            $self->{classifier}->{parser}->{mangle}->save_stop_words();
            $deletemessage = "<blockquote>" . sprintf( $self->{language}{Advanced_Error5}, $self->{form}{word} ) . "</blockquote>";
        }
    }

    # title and heading
    my $body = "<h2 class=\"advanced\">$self->{language}{Advanced_StopWords}</h2>\n";
    $body .= "$self->{language}{Advanced_Message1}\n<br /><br />\n<table summary=\"$self->{language}{Advanced_MainTableSummary}\">\n";

    # the word census
    my $last = '';
    my $need_comma = 0;
    my $groupCounter = 0;
    my $groupSize = 5;
    my $firstRow = 1;
    for my $word (sort keys %{$self->{classifier}->{parser}->{mangle}->{stop}}) {
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
    $body .= "<label class=\"advancedLabel\" for=\"advancedAddWordText\">$self->{language}{Advanced_AddWord}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "<input type=\"text\" id=\"advancedAddWordText\" name=\"newword\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"add\" value=\"$self->{language}{Add}\" />\n";
    $body .= "</form>\n$add_message\n";

    # Remove Word widget
    $body .= "<form action=\"/advanced\">\n";
    $body .= "<label class=\"advancedLabel\" for=\"advancedRemoveWordText\">$self->{language}{Advanced_RemoveWord}:</label><br />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "<input type=\"text\" id=\"advancedRemoveWordText\" name=\"word\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"remove\" value=\"$self->{language}{Remove}\" />\n";
    $body .= "</form>\n$deletemessage\n";

    # end optional widget placement
    $body .= "</div>\n";

    http_ok($self, $client,$body,5);
}

# ---------------------------------------------------------------------------------------------
#
# url_encode
#
# $text     Text to encode for URL safety
#
# Encode a URL so that it can be safely passed in a URL as per RFC2396
#
# ---------------------------------------------------------------------------------------------

sub url_encode
{
    my ( $self, $text ) = @_;

    $text =~ s/ /\+/;
    $text =~ s/([^a-zA-Z0-9_\-.+])/sprintf("%%%02x",ord($1))/eg;

    return $text;
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
    if ( ( defined($self->{form}{type}) ) && ( $self->{form}{bucket} ne '' ) && ( $self->{form}{text} ne '' ) ) {
        my $found = 0;
        for my $bucket (keys %{$self->{classifier}->{magnets}}) {
            if ( defined($self->{classifier}->{magnets}{$bucket}{$self->{form}{type}}{$self->{form}{text}}) ) {
                $found  = 1;
                $magnet_message = "<blockquote>\n<div class=\"error02\">\n<b>";
                $magnet_message .= sprintf( $self->{language}{Magnet_Error1}, "$self->{form}{type}: $self->{form}{text}", $bucket );
                $magnet_message .= "</b>\n</div>\n</blockquote>\n";
            }
        }

        if ( $found == 0 )  {
            for my $bucket (keys %{$self->{classifier}->{magnets}}) {
                for my $from (keys %{$self->{classifier}->{magnets}{$bucket}{$self->{form}{type}}})  {
                    if ( ( $self->{form}{text} =~ /\Q$from\E/ ) || ( $from =~ /\Q$self->{form}{text}\E/ ) )  {
                        $found = 1;
                        $magnet_message = "<blockquote><div class=\"error02\"><b>" . sprintf( $self->{language}{Magnet_Error2}, "$self->{form}{type}: $self->{form}{text}", "$self->{form}{type}: $from", $bucket ) . "</b></div></blockquote>";
                    }
                }
            }
        }

        if ( $found == 0 ) {
            $self->{classifier}->{magnets}{$self->{form}{bucket}}{$self->{form}{type}}{$self->{form}{text}} = 1;
            $magnet_message = "<blockquote>" . sprintf( $self->{language}{Magnet_Error3}, "$self->{form}{type}: $self->{form}{text}", $self->{form}{bucket} ) . "</blockquote>";
            $self->{classifier}->save_magnets();
        }
    }

    if ( defined($self->{form}{dtype}) )  {
        delete $self->{classifier}->{magnets}{$self->{form}{bucket}}{$self->{form}{dtype}}{$self->{form}{dmagnet}};
        $self->{classifier}->save_magnets();
    }

    # Current Magnets panel
    my $body = "<h2 class=\"magnets\">$self->{language}{Magnet_CurrentMagnets}</h2>\n";

    # magnet listing headings
    $body .= "<table width=\"75%\" class=\"magnetsTable\" summary=\"$self->{language}{Magnet_MainTableSummary}\">\n";
    $body .= "<caption>$self->{language}{Magnet_Message1}</caption>\n";
    $body .= "<tr>\n<th class=\"magnetsLabel\" scope=\"col\">$self->{language}{Magnet}</th>\n";
    $body .= "<th class=\"magnetsLabel\" scope=\"col\">$self->{language}{Bucket}</th>\n";
    $body .= "<th class=\"magnetsLabel\" scope=\"col\">$self->{language}{Delete}</th>\n</tr>\n";

    # magnet listing
    my $stripe = 0;
    for my $bucket (sort keys %{$self->{classifier}->{magnets}}) {
        for my $type (sort keys %{$self->{classifier}->{magnets}{$bucket}}) {
            for my $magnet (sort keys %{$self->{classifier}->{magnets}{$bucket}{$type}})  {
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
                $body .= "<td><font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font></td>\n";

                # Remove magnet button

                $body .= "<td>\n<form class=\"magnetsDelete\" style=\"margin: 0\" action=\"/magnets\">\n";
                $body .= "<input type=\"submit\" class=\"deleteButton\" name=\"deleteMagnet\" value=\"$self->{language}{Delete}\" />\n";
                $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
                $body .= "<input type=\"hidden\" name=\"dtype\" value=\"$type\" />\n";
                $body .= "<input type=\"hidden\" name=\"dmagnet\" value=\"$validatingMagnet\" />\n";
                $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
                $body .= "</form>\n</td>\n";
                $body .= "</tr>";
                $stripe = 1 - $stripe;
            }
        }
    }

    $body .= "</table>\n<br /><br />\n<hr />\n";

    # Create New Magnet panel
    $body .= "<h2 class=\"magnets\">$self->{language}{Magnet_CreateNew}</h2>\n";
    $body .= "<table cellspacing=\"0\" summary=\"\">\n<tr>\n<td>\n";
    $body .= "<b>$self->{language}{Magnet_Explanation}\n";
    $body .= "</td>\n</tr>\n</table>\n";

    # optional widget placement
    $body .= "<div class=\"magnetsNewWidget\">\n";

    # New Magnets form
    $body .= "<form action=\"/magnets\">\n";

    # Magnet Type widget
    $body .= "<label class=\"magnetsLabel\" for=\"magnetsAddType\">$self->{language}{Magnet_MagnetType}:</label><br />\n";
    $body .= "<select name=\"type\" id=\"magnetsAddType\">\n<option value=\"from\">\n$self->{language}{From}</option>\n";
    $body .= "<option value=\"to\">\n$self->{language}{To}</option>\n";
    $body .= "<option value=\"subject\">\n$self->{language}{Subject}</option>\n</select>\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n<br /><br />\n";

    # Value widget
    $body .= "<label class=\"magnetsLabel\" for=\"magnetsAddText\">$self->{language}{Magnet_Value}:</label><br />\n";
    $body .= "<input type=\"text\" name=\"text\" id=\"magnetsAddText\" />\n<br /><br />\n";

    # Always Goes to Bucket widget
    $body .= "<label class=\"magnetsLabel\" for=\"magnetsAddBucket\">$self->{language}{Magnet_Always}:</label><br />\n";
    $body .= "<select name=\"bucket\" id=\"magnetsAddBucket\">\n<option value=\"\"></option>\n";

    my @buckets = sort keys %{$self->{classifier}->{total}};
    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"create\" value=\"$self->{language}{Create}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$magnet_message\n";
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

    my $body = "<h2 class=\"buckets\">";
    $body .= sprintf( $self->{language}{SingleBucket_Title}, "<font color=\"$self->{classifier}->{colors}{$self->{form}{showbucket}}\">$self->{form}{showbucket}</font>");
    $body .= "</h2>\n<table summary=\"\">\n<tr>\n<th scope=\"row\" class=\"bucketsLabel\">$self->{language}{SingleBucket_WordCount}</th>\n";
    $body .= "<td>&nbsp;</td>\n<td align=\"right\">\n";
    $body .= pretty_number( $self, $self->{classifier}->{total}{$self->{form}{showbucket}});
    $body .= "</td>\n<td>\n(" . sprintf( $self->{language}{SingleBucket_Unique}, pretty_number( $self,  $self->{classifier}->{unique}{$self->{form}{showbucket}}) ). ")";
    $body .= "</td>\n</tr>\n<tr>\n<th scope=\"row\" class=\"bucketsLabel\">$self->{language}{SingleBucket_TotalWordCount}</th>\n";
    $body .= "<td>&nbsp;</td>\n<td align=\"right\">\n" . pretty_number( $self, $self->{classifier}->{full_total});

    my $percent = "0%";
    if ( $self->{classifier}->{full_total} > 0 )  {
        $percent = int( 10000 * $self->{classifier}->{total}{$self->{form}{showbucket}} / $self->{classifier}->{full_total} ) / 100;
        $percent = "$percent%";
    }
    $body .= "</td>\n<td></td>\n</tr>\n<tr><td colspan=\"3\"><hr /></td></tr>\n";
    $body .= "<tr>\n<th scope=\"row\" class=\"bucketsLabel\">$self->{language}{SingleBucket_Percentage}</th>\n";
    $body .= "<td></td>\n<td align=\"right\">$percent</td>\n<td></td>\n</tr>\n</table>\n";

    $body .= "<h2 class=\"buckets\">";
    $body .= sprintf( $self->{language}{SingleBucket_WordTable},  "<font color=\"$self->{classifier}->{colors}{$self->{form}{showbucket}}\">$self->{form}{showbucket}" ) ;
    $body .= "</font>\n</h2>\n$self->{language}{SingleBucket_Message1}\n<br /><br />\n<table summary=\"$self->{language}{Bucket_WordListTableSummary}\">\n";

    for my $i (@{$self->{classifier}->{matrix}{$self->{form}{showbucket}}}) {
        if ( defined($i) )  {
            my $j = $i;

            # Split the entries on the double bars, get rid of any extra bars, then grab a copy of the first char

            $j =~ s/\|\|/, /g;
            $j =~ s/\|//g;
            $j =~ /^(.)/;
            my $first = $1;

            # Highlight any words used this session

            $j =~ s/([^ ]+) (L\-[\.\d]+)/\*$1 $2<\/font>/g;
            $j =~ s/L(\-[\.\d]+)/int( $self->{classifier}->{total}{$self->{form}{showbucket}} * exp($1) + 0.5 )/ge;

            # Add the link to the corpus lookup

            $j =~ s/([^ ,\*]+) ([^ ,\*]+)/"<a class=\"wordListLink\" href=\"\/buckets\?session=$self->{session_key}\&amp;lookup=Lookup\&amp;word=" . url_encode($self,$1) . "#Lookup\">$1<\/a> $2"/ge;

            # Add the bucket color if this word was used this session. IMPORTANT: this regex relies
            # on the fact that Classifier::WordMangle (mangle) removes astericks from all corpus words
            # and therefore assumes that any asterick was placed the by the highlight regex several
            # lines above.

            $j =~ s/([\*])/<font color=\"$self->{classifier}->{colors}{$self->{form}{showbucket}}\">$1/g;
            $body .= "<tr>\n<td valign=\"top\">\n<b>$first</b>\n</td>\n<td valign=\"top\">\n$j</td>\n</tr>\n";
        }
    }
    $body .= "</table>\n";

    http_ok($self, $client,$body,1);
}

# ---------------------------------------------------------------------------------------------
#
# bar_chart_100 - Output an HTML bar chart
#
# %values       A hash of bucket names with values
#
# ---------------------------------------------------------------------------------------------
sub bar_chart_100
{
    my ( $self, %values ) = @_;
    my $body = '';
    my $total_count = 0;
    my @xaxis = sort keys %values;

    for my $bucket (@xaxis)  {
        $total_count += $values{$bucket};
    }

    for my $bucket (@xaxis)  {
        my $count   = pretty_number( $self,  $values{$bucket} );
        my $percent;

        if ( $total_count == 0 ) {
            $percent = "0%";
        } else {
            $percent = int( $values{$bucket} * 10000 / $total_count ) / 100;
            $percent .= "%";
        }
        $body .= "<tr>\n<td align=\"left\"><font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font></td>\n";
        $body .= "<td>&nbsp;</td>\n<td align=\"right\">$count ($percent)</td>\n</tr>\n";
    }

    $body .= "<tr>\n<td colspan=\"3\">&nbsp;</td>\n</tr>\n<tr>\n<td colspan=\"3\">\n";

    if ( $total_count != 0 ) {
        $body .= "<table class=\"barChart\" width=\"100%\" summary=\"$self->{language}{Bucket_BarChartSummary}\">\n<tr>\n";
        foreach my $bucket (@xaxis) {
            my $percent = int( $values{$bucket} * 10000 / $total_count ) / 100;
            if ( $percent != 0 )  {
                $body .= "<td bgcolor=\"$self->{classifier}->{colors}{$bucket}\" title=\"$bucket ($percent%)\" width=\"";
                $body .= (int($percent)<1)?1:int($percent);
                $body .= "%\"><img src=\"pix.gif\" alt=\"\" height=\"20\" width=\"1\" /></td>\n";
            }
        }
        $body .= "</tr>\n</table>";
    }

    $body .= "</td>\n</tr>\n";

    if ( $total_count != 0 )  {
        $body .= "<tr>\n<td colspan=\"3\" align=\"right\"><span class=\"graphFont\">100%</span></td>\n</tr>\n";
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

    if ( defined($self->{form}{reset_stats}) ) {
        $self->{configuration}->{configuration}{mcount} = 0;
        $self->{configuration}->{configuration}{ecount} = 0;
        for my $bucket (keys %{$self->{classifier}->{total}}) {
            $self->{classifier}->{parameters}{$bucket}{count} = 0;
        }
        $self->{classifier}->write_parameters();
        $self->{configuration}->{configuration}{last_reset} = localtime;
        $self->{configuration}->save_configuration();
    }

    if ( defined($self->{form}{showbucket}) )  {
        bucket_page( $self, $client);
        return;
    }

    my $result;
    my $create_message = '';
    my $deletemessage = '';
    my $rename_message = '';

    if ( ( defined($self->{form}{color}) ) && ( defined($self->{form}{bucket}) ) ) {
        open COLOR, ">$self->{configuration}->{configuration}{corpus}/$self->{form}{bucket}/color";
        print COLOR "$self->{form}{color}\n";
        close COLOR;
        $self->{classifier}->{colors}{$self->{form}{bucket}} = $self->{form}{color};
    }

    if ( ( defined($self->{form}{bucket}) ) && ( defined($self->{form}{subject}) ) && ( $self->{form}{subject} > 0 ) ) {
        $self->{classifier}->{parameters}{$self->{form}{bucket}}{subject} = $self->{form}{subject} - 1;
        $self->{classifier}->write_parameters();
    }

    if ( ( defined($self->{form}{bucket}) ) &&  ( defined($self->{form}{quarantine}) ) && ( $self->{form}{quarantine} > 0 ) ) {
        $self->{classifier}->{parameters}{$self->{form}{bucket}}{quarantine} = $self->{form}{quarantine} - 1;
        $self->{classifier}->write_parameters();
    }

    if ( ( defined($self->{form}{cname}) ) && ( $self->{form}{cname} ne '' ) ) {
        if ( $self->{form}{cname} =~ /[^[:lower:]\-_]/ )  {
            $create_message = "<blockquote><div class=\"error01\">$self->{language}{Bucket_Error1}</div></blockquote>";
        } else {
            if ( ( defined($self->{classifier}->{total}{$self->{form}{cname}}) ) && ( $self->{classifier}->{total}{$self->{form}{cname}} > 0 ) )  {
                $create_message = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error2}, $self->{form}{cname} ) . "</b></blockquote>";
            } else {
                mkdir( $self->{configuration}->{configuration}{corpus} );
                mkdir( "$self->{configuration}->{configuration}{corpus}/$self->{form}{cname}" );
                open NEW, ">$self->{configuration}->{configuration}{corpus}/$self->{form}{cname}/table";
                print NEW "\n";
                close NEW;
                $self->{classifier}->load_word_matrix();

                $create_message = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error3}, $self->{form}{cname} ) . "</b></blockquote>";
            }
       }
    }

    if ( ( defined($self->{form}{delete}) ) && ( $self->{form}{name} ne '' ) ) {
        $self->{form}{name} = lc($self->{form}{name});
        unlink( "$self->{configuration}->{configuration}{corpus}/$self->{form}{name}/table" );
        unlink( "$self->{configuration}->{configuration}{corpus}/$self->{form}{name}/params" );
        unlink( "$self->{configuration}->{configuration}{corpus}/$self->{form}{name}/magnets" );
        unlink( "$self->{configuration}->{configuration}{corpus}/$self->{form}{name}/color" );
        rmdir( "$self->{configuration}->{configuration}{corpus}/$self->{form}{name}" );

        $deletemessage = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error6}, $self->{form}{name} ) . "</b></blockquote>";
        $self->{classifier}->load_word_matrix();
    }

    if ( ( defined($self->{form}{newname}) ) && ( $self->{form}{oname} ne '' ) ) {
        if ( $self->{form}{newname} =~ /[^[:lower:]\-_]/ )  {
            $rename_message = "<blockquote><div class=\"error01\">$self->{language}{Bucket_Error1}</div></blockquote>";
        } else {
            $self->{form}{oname} = lc($self->{form}{oname});
            $self->{form}{newname} = lc($self->{form}{newname});
            rename("$self->{configuration}->{configuration}{corpus}/$self->{form}{oname}" , "$self->{configuration}->{configuration}{corpus}/$self->{form}{newname}");
            $rename_message = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error5}, $self->{form}{oname}, $self->{form}{newname} ) . "</b></blockquote>";
            $self->{classifier}->load_word_matrix();
        }
    }

    # Summary panel
    my $body = "<h2 class=\"buckets\">$self->{language}{Bucket_Title}</h2>\n";

    # column headings
    $body .= "<table class=\"bucketsTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" summary=\"$self->{language}{Bucket_MaintenanceTableSummary}\">\n<tr>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\">$self->{language}{Bucket_BucketName}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language}{Bucket_WordCount}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language}{Bucket_UniqueWords}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"center\">$self->{language}{Bucket_SubjectModification}</th>\n";
    $body .= "<th width=\"1%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"center\">$self->{language}{Bucket_Quarantine}</th>\n";
    $body .= "<th width=\"2%\">&nbsp;</th>\n<th class=\"bucketsLabel\" scope=\"col\" align=\"left\">$self->{language}{Bucket_ChangeColor}</th>\n</tr>\n";

    my @buckets = sort keys %{$self->{classifier}->{total}};
    my $stripe = 0;

    my $total_count = 0;
    foreach my $bucket (@buckets) {
        $total_count += $self->{classifier}->{parameters}{$bucket}{count};
    }

    foreach my $bucket (@buckets) {
        my $number  = pretty_number( $self,  $self->{classifier}->{total}{$bucket} );
        my $unique  = pretty_number( $self,  $self->{classifier}->{unique}{$bucket} );

        $body .= "<tr";
        if ( $stripe == 1 )  {
            $body .= " class=\"rowEven\"";
        } else {
            $body .= " class=\"rowOdd\"";
        }
        $stripe = 1 - $stripe;
        $body .= "><td><a href=\"/buckets?session=$self->{session_key}&amp;showbucket=$bucket\">\n";
        $body .= "<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font></a></td>\n";
        $body .= "<td width=\"1%\">&nbsp;</td><td align=\"right\">$number</td><td width=\"1%\">&nbsp;</td>\n";
        $body .= "<td align=\"right\">$unique</td><td width=\"1%\">&nbsp;</td>";

        if ( $self->{configuration}->{configuration}{subject} == 1 )  {

            # Subject Modification on/off widget

            $body .= "<td align=\"center\">\n";
            if ( $self->{classifier}->{parameters}{$bucket}{subject} == 0 ) {
                $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
                $body .= "<span class=\"bucketsWidgetStateOff\">$self->{language}{Off} </span>\n";
                $body .= "<input type=\"submit\" class=\"toggleOn\" name=\"toggle\" value=\"$self->{language}{TurnOn}\" />\n";
                $body .= "<input type=\"hidden\" name=\"subject\" value=\"2\" />\n";
                $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
                $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" /></form></td>\n";
            } else {
                $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
                $body .= "<span class=\"bucketsWidgetStateOn\">$self->{language}{On} </span>\n";
                $body .= "<input type=\"submit\" class=\"toggleOff\" name=\"toggle\" value=\"$self->{language}{TurnOff}\" />\n";
                $body .= "<input type=\"hidden\" name=\"subject\" value=\"1\" />\n";
                $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
                $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" /></form></td>\n";
            }
        } else {
            $body .= "<td align=\"center\">\n$self->{language}{Bucket_DisabledGlobally}\n</td>\n";
        }

        # Quarantine on/off widget

        $body .= "<td width=\"1%\">&nbsp;</td><td align=\"center\">\n";
        if ( $self->{classifier}->{parameters}{$bucket}{quarantine} == 0 ) {
            $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
            $body .= "<span class=\"bucketsWidgetStateOff\">$self->{language}{Off} </span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" name=\"toggle\" value=\"$self->{language}{TurnOn}\" />\n";
            $body .= "<input type=\"hidden\" name=\"quarantine\" value=\"2\" />\n";
            $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" /></form></td>\n";
        } else {
            $body .= "<form class=\"bucketsSwitch\" style=\"margin: 0\" action=\"/buckets\">\n";
            $body .= "<span class=\"bucketsWidgetStateOn\">$self->{language}{On} </span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOff\" name=\"toggle\" value=\"$self->{language}{TurnOff}\" />\n";
            $body .= "<input type=\"hidden\" name=\"quarantine\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"bucket\" value=\"$bucket\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" /></form></td>\n";
        }

        # Change Color widget

        $body .= "<td>&nbsp;</td>\n<td align=\"left\">\n<table class=\"colorChooserTable\" cellpadding=\"0\" cellspacing=\"1\" summary=\"\">\n<tr>\n";
        my $color = $self->{classifier}->{colors}{$bucket};
        $body .= "<td bgcolor=\"$color\">\n<img class=\"colorChooserImg\" border=\"0\" alt='" . sprintf( $self->{language}{Bucket_CurrentColor}, $bucket, $color ) . "' src=\"pix.gif\" width=\"10\" height=\"20\" /></td>\n<td>&nbsp;</td>\n";
        for my $i ( 0 .. $#{$self->{classifier}->{possible_colors}} ) {
            my $color = $self->{classifier}->{possible_colors}[$i];
            if ( $color ne $self->{classifier}->{colors}{$bucket} )  {
                $body .= "<td bgcolor=\"$color\" title=\"". sprintf( $self->{language}{Bucket_SetColorTo}, $bucket, $color ) . "\">\n";
                $body .= "<a class=\"colorChooserLink\" href=\"/buckets?color=$color&amp;bucket=$bucket&amp;session=$self->{session_key}\">\n";
                $body .= "<img class=\"colorChooserImg\" border=\"0\" alt=\"". sprintf( $self->{language}{Bucket_SetColorTo}, $bucket, $color ) . "\" src=\"pix.gif\" width=\"10\" height=\"20\" /></a>\n";
                $body .= "</td>\n";
            }
        }
        $body .= "</tr></table></td>\n";
        # Close odd/even row
        $body .= "</tr>\n";
    }

    # figure some performance numbers

    my $number = pretty_number( $self,  $self->{classifier}->{full_total} );
    my $pmcount = pretty_number( $self,  $self->{configuration}->{configuration}{mcount} );
    my $pecount = pretty_number( $self,  $self->{configuration}->{configuration}{ecount} );
    my $accuracy = $self->{language}{Bucket_NotEnoughData};
    my $percent = 0;
    if ( $self->{configuration}->{configuration}{mcount} > 0 )  {
        $percent = int( 10000 * ( $self->{configuration}->{configuration}{mcount} - $self->{configuration}->{configuration}{ecount} ) / $self->{configuration}->{configuration}{mcount} ) / 100;
        $accuracy = "$percent%";
    }

     # finish off Summary panel

    $body .= "<tr>\n<td colspan=\"3\"><hr /></td>\n</tr>\n";
    $body .= "<tr>\n<th class=\"bucketsLabel\" scope=\"row\">$self->{language}{Total}</th>\n<td width=\"1%\"></td>\n";
    $body .= "<td align=\"right\">$number</td>\n<td></td>\n<td></td>\n</tr>\n</table>\n<br />\n";

    # middle panel group
    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language}{Bucket_StatisticsTableSummary}\">\n";

    # Classification Accuracy panel
    $body .= "<tr>\n<td class=\"settingsPanel\" valign=\"top\" width=\"33%\" align=\"center\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language}{Bucket_ClassificationAccuracy}</h2>\n";

    $body .= "<table summary=\"\">\n";
    # emails classified line
    $body .= "<tr>\n<th scope=\"row\" align=\"left\">$self->{language}{Bucket_EmailsClassified}:</th>\n";
    $body .= "<td align=\"right\">$pmcount</td>\n</tr>\n";
    # classification errors line
    $body .= "<tr>\n<th scope=\"row\" align=\"left\">$self->{language}{Bucket_ClassificationErrors}:</th>\n";
    $body .= "<td align=\"right\">$pecount</td>\n</tr>\n";
    # rules
    $body .= "<tr>\n<td colspan=\"2\"><hr /></td>\n</tr>\n";

    # $body .= "<tr>\n<td colspan=\"2\"><hr /></td></tr>\n";
    $body .= "<tr>\n<th scope=\"row\" align=\"left\">";
    $body .= "$self->{language}{Bucket_Accuracy}:</th>\n<td align=\"right\">$accuracy</td>\n</tr>\n";

    if ( $percent > 0 )  {
        $body .= "<tr>\n<td colspan=\"2\">&nbsp;</td>\n</tr>\n<tr>\n<td colspan=\"2\">\n";
        $body .= "<table class=\"barChart\" id=\"accuracyChart\" width=\"100%\" cellspacing=\"0\"";
        $body .= " cellpadding=\"0\" border=\"0\" summary=\"$self->{language}{Bucket_AccuracyChartSummary}\">\n";
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
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"reset_stats\" value=\"$self->{language}{Bucket_ResetStatistics}\" />\n";

    if ( $self->{configuration}->{configuration}{last_reset} ne '' ) {
        $body .= "<br />\n($self->{language}{Bucket_LastReset}: $self->{configuration}->{configuration}{last_reset})\n";
    }

    # Emails Classified panel
    $body .= "</form>\n</td>\n<td class=\"settingsPanel\" valign=\"top\" width=\"33%\" align=\"center\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language}{Bucket_EmailsClassifiedUpper}</h2>\n";

    $body .= "<table summary=\"\">\n<tr>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"left\">$self->{language}{Bucket}</th>\n<th>&nbsp;</th>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language}{Bucket_ClassificationCount}</th>\n</tr>\n";

    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $self->{classifier}->{parameters}{$bucket}{count};
    }

    $body .= bar_chart_100( $self, %bar_values );

    # Word Counts panel
    $body .= "</table>\n</td>\n<td class=\"settingsPanel\" width=\"34%\" valign=\"top\" align=\"center\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language}{Bucket_WordCounts}</h2>\n<table summary=\"\">\n<tr>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"left\">$self->{language}{Bucket}</th>\n<th>&nbsp;</th>\n";
    $body .= "<th class=\"bucketsLabel\" scope=\"col\" align=\"right\">$self->{language}{Bucket_WordCount}</th>\n</tr>\n";

    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $self->{classifier}->{total}{$bucket};
    }

    $body .= bar_chart_100( $self, %bar_values );

    $body .= "</table>\n</td>\n</tr>\n</table>\n<br />\n";

    # bottom panel group
    $body .= "<table class=\"settingsTable\" width=\"100%\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language}{Bucket_MaintenanceTableSummary}\">\n";

    # Maintenance panel
    $body .= "<tr>\n<td class=\"settingsPanel\" valign=\"top\" width=\"50%\">\n";
    $body .= "<h2 class=\"buckets\">$self->{language}{Bucket_Maintenance}</h2>\n";

    # optional widget placement
    $body .= "<div class=\"bucketsMaintenanceWidget\">\n";

    $body .= "<form action=\"/buckets\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsCreateBucket\">$self->{language}{Bucket_CreateBucket}:</label><br />\n";
    $body .= "<input name=\"cname\" id=\"bucketsCreateBucket\" type=\"text\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"create\" value=\"$self->{language}{Create}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "</form>\n$create_message\n";
    $body .= "<form action=\"/buckets\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsDeleteBucket\">$self->{language}{Bucket_DeleteBucket}:</label><br />\n";
    $body .= "<select name=\"name\" id=\"bucketsDeleteBucket\">\n<option value=\"\"></option>\n";

    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"delete\" value=\"$self->{language}{Delete}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n$deletemessage\n";

    $body .= "<form action=\"/buckets\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsRenameBucketFrom\">$self->{language}{Bucket_RenameBucket}:</label><br />\n";
    $body .= "<select name=\"oname\" id=\"bucketsRenameBucketFrom\">\n<option value=\"\"></option>\n";

    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<label class=\"bucketsLabel\" for=\"bucketsRenameBucketTo\">$self->{language}{Bucket_To}</label>\n";
    $body .= "<input type=\"text\" id=\"bucketsRenameBucketTo\" name=\"newname\" /> \n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"rename\" value=\"$self->{language}{Rename}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "</form>\n$rename_message\n<br />\n";

   # end optional widget placement
   $body .= "</div>\n</td>\n";

    # Lookup panel
    $body .= "<td class=\"settingsPanel\" valign=\"top\" width=\"50%\">\n<a name=\"Lookup\"></a>\n";
    $body .= "<h2 class=\"buckets\">$self->{language}{Bucket_Lookup}</h2>\n";

    # optional widget placement
    $body .= "<div class=\"bucketsLookupWidget\">\n";

    $body .= "<form action=\"/buckets#Lookup\">\n";
    $body .= "<label class=\"bucketsLabel\" for=\"bucketsLookup\">$self->{language}{Bucket_LookupMessage}:</label><br />\n";
    $body .= "<input name=\"word\" id=\"bucketsLookup\" type=\"text\" /> \n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"lookup\" value=\"$self->{language}{Lookup}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n</form>\n<br />\n";

    # end optional widget placement
   $body .= "</div>\n";

    if ( ( defined($self->{form}{lookup}) ) || ( defined($self->{form}{word}) ) ) {
       my $word = $self->{classifier}->{mangler}->mangle($self->{form}{word}, 1);

        $body .= "<blockquote>\n";

        # Don't print the headings if there are no entries.

        my $heading = "<table class=\"lookupResultsTable\" cellpadding=\"10%\" cellspacing=\"0\" summary=\"$self->{language}{Bucket_LookupResultsSummary}\">\n";
        $heading .= "<tr>\n<td>\n";
        $heading .= "<table summary=\"\">\n";
        $heading .= "<caption><strong>$self->{language}{Bucket_LookupMessage2} $self->{form}{word}</strong><br /><br /></caption>";
        $heading .= "<tr>\n<th scope=\"col\">$self->{language}{Bucket}</th>\n<th>&nbsp;</th>\n";
        $heading .= "<th scope=\"col\">$self->{language}{Frequency}</th>\n<th>&nbsp;</th>\n";
        $heading .= "<th scope=\"col\">$self->{language}{Probability}</th>\n<th>&nbsp;</th>\n";
        $heading .= "<th scope=\"col\">$self->{language}{Score}</th>\n</tr>\n";

        if ( $self->{form}{word} ne '' ) {
            my $max = 0;
            my $max_bucket = '';
            my $total = 0;
            foreach my $bucket (@buckets) {
                if ( $self->{classifier}->get_value( $bucket, $word ) != 0 ) {
                    my $prob = exp( $self->{classifier}->get_value( $bucket, $word ) );
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
                    if ( $self->{classifier}->{full_total} > 0 ) {
                        $total += 0.1 / $self->{classifier}->{full_total};
                    }
                }
            }

            foreach my $bucket (@buckets) {
                if ( $self->{classifier}->get_value( $bucket, $word ) != 0 ) {
                    my $prob    = exp( $self->{classifier}->get_value( $bucket, $word ) );
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
                    $body .= "<tr>\n<td>$bold<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font>$endbold</td>\n";
                    $body .= "<td></td>\n<td>$bold<tt>$probf</tt>$endbold</td>\n<td></td>\n";
                    $body .= "<td>$bold<tt>$normal</tt>$endbold</td>\n<td></td>\n<td>$bold<tt>$score</tt>$endbold</td>\n</tr>\n";
                }
            }

            if ( $max_bucket ne '' ) {
                $body .= "</table>\n<br /><br />";
                $body .= sprintf( $self->{language}{Bucket_LookupMostLikely}, $self->{form}{word}, $self->{classifier}->{colors}{$max_bucket}, $max_bucket);
                $body .= "</td>\n</tr>\n</table>";
            } else {
                $body .= sprintf( $self->{language}{Bucket_DoesNotAppear}, $self->{form}{word} );
            }
        } else {
            $body .= "<div class=\"error01\">$self->{language}{Bucket_Error4}</div>";
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

    if ( $a =~ /popfile(.*)=(.*)\.msg/ )  {
        $ad = $1;
        $am = $2;

        if ( $b =~ /popfile(.*)=(.*)\.msg/ ) {
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
    
    $self->{history_invalid_} = 1;
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

    delete $self->{history_keys_};
    
    if ( ( $filter ne '' ) || ( $search ne '' ) ) {
        foreach my $file (sort compare_mf keys %{$self->{history_}}) {
            if ( ( $filter eq '' ) || 
                 ( $self->{history_}{$file}{bucket} eq $filter ) || 
                 ( ( $filter eq '__filter__magnet' ) && ( $self->{history_}{$file}{magnet} ne '' ) ) ) {
                if ( ( $search eq '' ) || 
                   ( $self->{history_}{$file}{from}    =~ /\Q$search\E/i ) ||
                   ( $self->{history_}{$file}{subject} =~ /\Q$search\E/i ) ) {
                           if ( defined( $self->{history_keys_} ) ) {
                            @{$self->{history_keys_}} = (@{$self->{history_keys_}}, $file);
                        } else {
                            @{$self->{history_keys_}} = ($file);
                        }
                   }
            }
        }
    } else {
        @{$self->{history_keys_}} = keys %{$self->{history_}};
    }

    # If a sort is specified then use it to sort the history items by an a subkey
    # (from, subject or bucket) otherwise use compare_mf to give the history back
    # in the order the messages were received.  Note that when sorting on a alphanumeric
    # field we ignore all punctuation characters so that "John and 'John and John
    # all sort next to each other

    if ( $sort ne '' ) {
        @{$self->{history_keys_}} = sort { 
                                            my ($a1,$b1) = ($self->{history_}{$a}{$sort}, 
                                              $self->{history_}{$b}{$sort}); 
                                              $a1 =~ s/[^A-Z0-9]//ig; 
                                              $b1 =~ s/[^A-Z0-9]//ig; 
                                              return ( $a1 cmp $b1 ); 
                                          } @{$self->{history_keys_}};
    } else {
        # Here's a quick shortcut so that we don't have to iterate
        # if there's no work for us to do

        if ( $self->history_size() > 0 ) {
            @{$self->{history_keys_}} = sort compare_mf @{$self->{history_keys_}};
        }
    }    
}

# ---------------------------------------------------------------------------------------------
#
# load_history_cache
#
# Forces a reload of the history cache from disk.  This works by globbing the history 
# directory and then checking for new files that need to be loaded into the history cache
# and culling any files that have been removed without telling us
#
# ---------------------------------------------------------------------------------------------
sub load_history_cache
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

    foreach my $key (keys %{$self->{history_}}) {
        $self->{history_}{$key}{cull} = 1;
    }

    # Now get all the names of files from the appropriate history subdirectory and run
    # through them looking for existing entries in the history which must be marked
    # for non-culling and new entries that need to be added to the end

    my @history_files = sort compare_mf glob "$self->{configuration}->{configuration}{msgdir}popfile*=*.msg";

    foreach my $i ( 0 .. $#history_files ) {

        # Strip any directory portion of the name in the current file so that we
        # just get the base name of the file that we are dealing with
    
        $history_files[$i] =~ /(popfile.*\.msg)/;
        $history_files[$i] = $1;

        # If this file already exists in the history cache then just mark it not 
        # to be culled and move on. 
        
        if ( defined( $self->{history_}{$history_files[$i]} ) ) {
            $self->{history_}{$history_files[$i]}{cull} = 0;
        } else {
        
            # Find the class information for this file using the history_load_class helper
            # function, and then parse the MSG file for the From and Subject information

            my ( $reclassified, $bucket, $usedtobe, $magnet ) = $self->history_load_class( $history_files[$i] );
            my $from    = '';
            my $subject = '';
            
            if ( open MAIL, "<$self->{configuration}->{configuration}{msgdir}$history_files[$i]" ) {
                while ( <MAIL> )  {
                    last          if ( /^(\r\n|\r|\n)/ );
                    $from = $1    if ( /^From:(.*)/i );
                    $subject = $1 if ( /^Subject:(.*)/i );
                    last if ( ( $from ne '' ) && ( $subject ne '' ) );
                }
                close MAIL;
            }

            $from    = "&lt;$self->{language}{History_NoFrom}&gt;"    if ( $from eq '' );
            $subject = "&lt;$self->{language}{History_NoSubject}&gt;" if ( !( $subject =~ /[^ \t\r\n]/ ) );

            $from    =~ s/\"(.*)\"/$1/g;
            $subject =~ s/\"(.*)\"/$1/g;

            $from    = $self->{classifier}->{parser}->decode_string( $from );
            $subject = $self->{classifier}->{parser}->decode_string( $subject );

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

            $self->{history_}{$history_files[$i]}{bucket}        = $bucket;
            $self->{history_}{$history_files[$i]}{reclassified}  = $reclassified;
            $self->{history_}{$history_files[$i]}{magnet}        = $magnet;
            $self->{history_}{$history_files[$i]}{subject}       = $subject;
            $self->{history_}{$history_files[$i]}{from}          = $from;
            $self->{history_}{$history_files[$i]}{short_subject} = $short_subject;
            $self->{history_}{$history_files[$i]}{short_from}    = $short_from;
            $self->{history_}{$history_files[$i]}{cull}          = 0;
        }
    }

    # Remove any entries from the history that have been removed from disk, see the big
    # comment at the start of this function for more detail

    foreach my $key (keys %{$self->{history_}}) {
        if ( $self->{history_}{$key}{cull} == 1 ) {
            delete $self->{history_}{$key};
        }
    }

    $self->{history_invalid_} = 0;
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

    if ( defined( $self->{history_keys_} ) ) {
        my @keys = @{$self->{history_keys_}};

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

    my $body = "$self->{language}{History_Jump}: ";
    if ( $start_message != 0 )  {
        $body .= "[<a href=\"/history?start_message=";
        $body .= $start_message - $self->{configuration}->{configuration}{page_size};
        $body .= "&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;search=$self->{form}{search}&amp;filter=$self->{form}{filter}\">< $self->{language}{Previous}</a>] ";
    }
    my $i = 0;
    while ( $i < $self->history_size() ) {
        if ( $i == $start_message )  {
            $body .= "<b>";
            $body .= $i+1 . "</b>";
        } else {
            $body .= "[<a href=\"/history?start_message=$i&amp;session=$self->{session_key}&amp;search=$self->{form}{search}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}\">";
            $body .= $i+1 . "</a>]";
        }

        $body .= " ";
        $i += $self->{configuration}->{configuration}{page_size};
    }
    if ( $start_message < ( $self->history_size() - $self->{configuration}->{configuration}{page_size} ) )  {
        $body .= "[<a href=\"/history?start_message=";
        $body .= $start_message + $self->{configuration}->{configuration}{page_size};
        $body .= "&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;search=$self->{form}{search}&amp;filter=$self->{form}{filter}\">$self->{language}{Next} ></a>]";
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

    open CLASS, ">$self->{configuration}->{configuration}{msgdir}$filename";

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

    if ( open CLASS, "<$self->{configuration}->{configuration}{msgdir}$filename" ) {
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
        print "Error: $self->{configuration}->{configuration}{msgdir}$filename: $!\n";
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

    if ( defined( $self->{form}{change} ) ) {

        # This hash will map filenames of MSG files in the history to the
        # new classification that they should be, it is built by iterating
        # through the $self->{form} looking for entries with the message number
        # of each message that is displayed and then creating an entry in
        # %messages if there is a corresponding entry in $self->{form} for
        # that message number

        my %messages;

        foreach my $i ( $self->{form}{start_message}  .. $self->{form}{start_message} + $self->{configuration}->{configuration}{page_size} - 1) {
            my $mail_file = $self->{history_keys_}[$i];

            # The first check makes sure we didn't run off the end of the history table
            # the second that there is something defined for this message number and the
            # third that this message number has a value (i.e. a bucket name)

            if ( defined( $mail_file ) && defined( $self->{form}{$i} ) && ( $self->{form}{$i} ne '' ) ) {
                $messages{$mail_file} = $self->{form}{$i};
            }
        }

        # The temp_corpus hash has two levels of keys: $temp_corpus{bucket}{word}
        # where bucket is the name of one of the current buckets and word is a word
        # in that bucket.  The value stored in the hash is the word count.
        #
        # TODO: this needs factoring out of here and into Classifier::Bayes

        my %temp_corpus;

        # At this point %messages maps that files that need reclassifying to their
        # new bucket classification

        while ( my ($mail_file, $newbucket) = each %messages ) {

            # Get the current classification for this message

            my ( $reclassified, $bucket, $usedtobe, $magnet) = $self->history_load_class( $mail_file );

            # Only reclassify messages that havn't been reclassified before

            if ( !$reclassified ) {

                # load the bucket corpus once

                if (!defined( $temp_corpus{$newbucket} ) ) {
                    if ( open WORDS, "<$self->{configuration}->{configuration}{corpus}/$newbucket/table" ) {
                        while (<WORDS>) {
                            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                                if ( $1 != 1 )  {
                                    print "Incompatible corpus version in $newbucket\n";
                                    return;
                                }

                                next;
                            }
                            
                            $temp_corpus{$newbucket}{$1} = $2 if ( /([^\s]+) (\d+)/ );
                        }
                        close WORDS;
                    }
                }

                # Parse the messages and tally the word-count

                $self->{classifier}->{parser}->parse_stream( "$self->{configuration}->{configuration}{msgdir}$mail_file" );

                foreach my $word (keys %{$self->{classifier}->{parser}->{words}}) {
                    $self->{classifier}->{full_total}   += $self->{classifier}->{parser}->{words}{$word};
                    $temp_corpus{$newbucket}{$word}     += $self->{classifier}->{parser}->{words}{$word};
                }

                # Update statistics

                $self->{configuration}->{configuration}{ecount} += 1 if ( $newbucket ne $bucket );
                
                $self->{logger}->debug( "Reclassifying $mail_file from $bucket to $newbucket" );
                
                $self->{classifier}->{parameters}{$newbucket}{count} += 1;
                $self->{classifier}->{parameters}{$bucket}{count}    -= 1;

                # Update the class file

                $self->history_write_class( $mail_file, 1, $newbucket, ( $bucket || "unclassified" ) , '');
                
                # Since we have just changed the classification of this file and it has
                # now been reclassified and has a new bucket name then we need to update the
                # history cache to reflect that
                
                $self->{history_}{$mail_file}{reclassified} = 1;
                $self->{history_}{$mail_file}{bucket}       = $newbucket;

                # Add message feedback

                $self->{feedback}{$mail_file} = sprintf( $self->{language}{History_ChangedTo}, $self->{classifier}->{colors}{$newbucket}, $newbucket )
            }
        }

        # Commit the buckets

        $self->{classifier}->update_constants();
        $self->{classifier}->write_parameters();

        foreach my $abucket ( keys %temp_corpus ) {
            if ( open WORDS, ">$self->{configuration}->{configuration}{corpus}/$abucket/table" ) {
                print WORDS "__CORPUS__ __VERSION__ 1\n";
                foreach my $word ( keys %{$temp_corpus{$abucket}} ) {
                    print WORDS "$word $temp_corpus{$abucket}{$word}\n" if ( $temp_corpus{$abucket}{$word} > 0 );
                }
                close WORDS;
            }
            
            $self->{classifier}->load_bucket("$self->{configuration}->{configuration}{corpus}/$abucket");
        }

        $self->{configuration}->save_configuration();
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

    foreach my $key (keys %{$self->{form}}) {
        if ( $key =~ /^undo_([0-9]+)$/ ) {
            my $mail_file = $self->{history_keys_}[$1];
            my %temp_corpus;

            # Load the class file

            my ( $reclassified, $bucket, $usedtobe, $magnet ) = $self->history_load_class( $mail_file );

            # Only undo if the message has been classified...

            if ( defined( $usedtobe ) ) {
                if (!defined( $temp_corpus{bucket} ) ) {
                    if ( open WORDS, "<$self->{configuration}->{configuration}{corpus}/$bucket/table" ) {
                        while (<WORDS>) {
                            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                                if ( $1 != 1 )  {
                                    print "Incompatible corpus version in $bucket\n";
                                    return;
                                }

                                next;
                            }

                            $temp_corpus{$bucket}{$1} = $2 if ( /([^\s]+) (\d+)/ );
                        }
                        close WORDS;
                    }
                }

                $self->{classifier}->{parser}->parse_stream("$self->{configuration}->{configuration}{msgdir}$mail_file");

                # Tally the words

                foreach my $word (keys %{$self->{classifier}->{parser}->{words}}) {
                    $self->{classifier}->{full_total} -= $self->{classifier}->{parser}->{words}{$word};
                    $temp_corpus{$bucket}{$word}      -= $self->{classifier}->{parser}->{words}{$word};

                    delete $temp_corpus{$bucket}{$word} if ( $temp_corpus{$bucket}{$word} <= 0 );
                }

                # Update statistics

                $self->{logger}->debug( "Undoing $mail_file from $bucket to $usedtobe" );

                if ( $bucket ne $usedtobe ) {
                    $self->{configuration}->{configuration}{ecount} -= 1 if ( $self->{configuration}->{configuration}{ecount} > 0 );
                    $self->{classifier}->{parameters}{$bucket}{count}   -= 1;
                    $self->{classifier}->{parameters}{$usedtobe}{count} += 1;
                }

                # Since we have just changed the classification of this file and it has
                # not been reclassified and has a new bucket name then we need to update the
                # history cache to reflect that

                $self->{history_}{$mail_file}{reclassified} = 0;
                $self->{history_}{$mail_file}{bucket}       = $usedtobe;

                # Update the class file

                $self->history_write_class( $mail_file, 0, ( $usedtobe || "unclassified" ), '', '');

                # Add message feedback

                $self->{feedback}{$mail_file} = sprintf( $self->{language}{History_ChangedTo}, ($self->{classifier}->{colors}{$usedtobe} || ''), $usedtobe );
            }

            # Commit the buckets

            $self->{classifier}->write_parameters();
            $self->{configuration}->save_configuration();

            foreach my $abucket ( keys %temp_corpus ) {
                if ( open WORDS, ">$self->{configuration}->{configuration}{corpus}/$abucket/table" ) {
                    print WORDS "__CORPUS__ __VERSION__ 1\n";
                    foreach my $word ( keys %{$temp_corpus{$abucket}} ) {
                        print WORDS "$word $temp_corpus{$abucket}{$word}\n" if ( $temp_corpus{$abucket}{$word} > 0 );
                    }
                    close WORDS;
                }

                $self->{classifier}->load_bucket("$self->{configuration}->{configuration}{corpus}/$abucket");
            }

            $self->{classifier}->update_constants();
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
    $body .= "<label class=\"historyLabel\" for=\"historySearch\">$self->{language}{History_SearchMessage}:</label>\n";
    $body .= "<input type=\"text\" id=\"historySearch\" name=\"search\" ";
    $body .= "value=\"$self->{form}{search}\"" if (defined $self->{form}{search});
    $body .= " />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"setsearch\" value=\"$self->{language}{Find}\" />\n";
    $body .= "&nbsp;&nbsp;<label class=\"historyLabel\" for=\"historyFilter\">$self->{language}{History_FilterBy}:</label>\n";
    $body .= "<input type=\"hidden\" name=\"sort\" value=\"$self->{form}{sort}\" />\n";
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
    $body .= "<select name=\"filter\" id=\"historyFilter\">\n<option value=\"\"></option>";
    my @buckets = sort keys %{$self->{classifier}->{total}};
    foreach my $abucket (@buckets) {
        $body .= "<option value=\"$abucket\"";
        $body .= " selected" if ( ( defined($self->{form}{filter}) ) && ( $self->{form}{filter} eq $abucket ) );
        $body .= ">$abucket</option>\n";
    }
    $body .= "<option value=\"__filter__magnet\"" . ($self->{form}{filter} eq '__filter__magnet'?' selected':'') . ">&lt;$self->{language}{History_ShowMagnet}&gt;</option>\n";
    $body .= "<option value=\"unclassified\"" . ($self->{form}{filter} eq 'unclassified'?' selected':'') . ">&lt;unclassified&gt;</option>\n";
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"setfilter\" value=\"$self->{language}{Filter}\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"reset_filter_search\" value=\"$self->{language}{History_ResetSearch}\" />\n";
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

    $self->{form}{sort}   = '' if ( !defined( $self->{form}{sort}   ) );
    $self->{form}{search} = '' if ( !defined( $self->{form}{search} ) );
    $self->{form}{filter} = '' if ( !defined( $self->{form}{filter} ) );
    
    # If the user is asking for a new sort option then it needs to get
    # stored in the sort form variable so that it can be used for subsequent
    # page views of the History to keep the sort in place
    
    $self->{form}{sort} = $self->{form}{setsort} if ( defined( $self->{form}{setsort} ) );

    # If the user hits the Reset button on a search then we need to clear
    # the search value but make it look as though they hit the search button
    # so that sort_filter_history will get called below to get the right values
    # in history_keys
    
    if ( defined( $self->{form}{reset_filter_search} ) ) {
        $self->{form}{filter}    = '';
        $self->{form}{search}    = '';
        $self->{form}{setsearch} = 1;
    }

    # Set up the text that will appear at the top of the history page
    # indicating the current filter and search settings

    my $filtered = '';
    if ( !( $self->{form}{filter} eq '' ) ) {
        if ( $self->{form}{filter} eq '__filter__magnet' ) {
            $filtered .= $self->{language}{History_Magnet};
        } else {
            $filtered = sprintf( $self->{language}{History_Filter}, $self->{classifier}->{colors}{$self->{form}{filter}}, $self->{form}{filter} ) if ( $self->{form}{filter} ne '' );
        }
    }

    $filtered .= sprintf( $self->{language}{History_Search}, $self->{form}{search} ) if ( $self->{form}{search} ne '' );

    # Handle the reinsertion of a message file or the user hitting the
    # undo button

    $self->history_reclassify();
    $self->history_undo();

    # Handle removal of one or more items from the history page, the remove_array form will contain
    # all the indexes into history_keys that need to be deleted.  We pass each file that needs
    # deleting into the history_delete_file helper

    if ( defined( $self->{form}{deletemessage} ) ) {

        # Remove the list of marked messages using the array of "remove" checkboxes, the fact
        # that deletemessage is defined will later on cause a call to sort_filter_history
        # that will reload the history_keys with the appropriate messages that now exist
        # in the cache.  Note that there is no need to invalidate the history cache since
        # we are in control of deleting messages

        for my $i ( 0 .. $#{$self->{form}{remove_array}} ) {
            $self->history_delete_file( $self->{history_keys_}[$self->{form}{remove_array}[$i] - 1], 0);
        }
    }

    # Handle clearing the history files, there are two options here, clear the current page
    # or clear all the files in the cache

    if ( defined( $self->{form}{clearall} ) ) {
        foreach my $i (0 .. $self->history_size()-1 ) {
            $self->history_delete_file( $self->{history_keys_}[$i], 
                                        $self->{configuration}->{configuration}{archive} );
        }
    }

    if ( defined($self->{form}{clearpage}) ) {
        foreach my $i ( $self->{form}{start_message} .. $self->{form}{start_message} + $self->{configuration}->{configuration}{page_size} - 1 ) {
            if ( defined( $self->{history_keys_}[$i] ) ) {
                $self->history_delete_file( $self->{history_keys_}[$i], 
                                            $self->{configuration}->{configuration}{archive} );
            }
        }
    }

    # If the history cache is invalid then we need to reload it and then if
    # any of the sort, search or filter options have changed they must be
    # applied.  The watch word here is to avoid doing work
    
    $self->load_history_cache() if ( $self->{history_invalid_} == 1 );
    $self->sort_filter_history( $self->{form}{filter}, 
                                $self->{form}{search}, 
                                $self->{form}{sort} ) if ( ( defined( $self->{form}{setfilter}     ) ) || 
                                                            ( defined( $self->{form}{setsort}       ) ) ||
                                                            ( defined( $self->{form}{setsearch}     ) ) ||
                                                            ( defined( $self->{form}{deletemessage} ) ) || 
                                                            ( defined( $self->{form}{clearall}      ) ) || 
                                                            ( defined( $self->{form}{clearpage}     ) ) );
    my $body = '';

    if ( !$self->history_cache_empty() )  {
        my $highlight_message = '';
        my $start_message = 0;
        
        $start_message = $self->{form}{start_message} if ( ( defined($self->{form}{start_message}) ) && ($self->{form}{start_message} > 0 ) );
        my $stop_message  = $start_message + $self->{configuration}->{configuration}{page_size} - 1;

        # Verify that a message we are being asked to view (perhaps from a /jump_to_message URL) is actually between
        # the $start_message and $stop_message, if it is not then move to that message

        if ( defined($self->{form}{view}) ) {
            my $found = 0;
            foreach my $i ($start_message ..  $stop_message) {
                if ( defined ( $self->{history_keys_}[$i] ) ) {
                    my $mail_file = $self->{history_keys_}[$i];
                    if ( $self->{form}{view} eq $mail_file )  {
                        $found = 1;
                        last;
                    }
                }
            }

            if ( $found == 0 ) {
                foreach my $i ( 0 .. ( $self->history_size() - 1 ) )  {
                    my $mail_file = $self->{history_keys_}[$i];
                    if ( $self->{form}{view} eq $mail_file ) {
                        $start_message = $i;
                        $stop_message  = $i + $self->{configuration}->{configuration}{page_size} - 1;
                        last;
                    }
                }
            }
        }

        $stop_message = $self->history_size() - 1 if ( $stop_message >= $self->history_size() );

        if ( $self->{configuration}->{configuration}{page_size} <= $self->history_size() ) {
            $body .= "<table width=\"100%\" summary=\"\">\n<tr>\n<td align=\"left\">\n";
            # title
            $body .= "<h2 class=\"history\">$self->{language}{History_Title}$filtered</h2>\n</td>\n";
            # navigator
            $body .= "<td class=\"historyNavigatorTop\">\n";
            $body .= get_history_navigator( $self, $start_message, $stop_message );
            $body .= "</td>\n</tr>\n</table>\n";
        } else {
            $body .="<h2 class=\"history\">$self->{language}{History_Title}$filtered</h2>\n";
        }

        # History widgets top
        $body .= "<table class=\"historyWidgetsTop\" summary=\"\">\n<tr>\n";

        # Search From/Subject widget
        my @buckets = sort keys %{$self->{classifier}->{total}};
        $body .= "<td colspan=\"5\" valign=middle>\n";
        $body .= $self->get_search_filter_widget();
        $body .= "</td>\n</tr>\n</table>\n";

        # History page main form

        $body .= "<form id=\"HistoryMainForm\" action=\"/history\" method=\"get\">\n";
        $body .= "<input type=\"hidden\" name=\"search\" value=\"$self->{form}{search}\" />\n";
        $body .= "<input type=\"hidden\" name=\"sort\" value=\"$self->{form}{sort}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
        $body .= "<input type=\"hidden\" name=\"start_message\" value=\"$start_message\" />\n";
        $body .= "<input type=\"hidden\" name=\"filter\" value=\"$self->{form}{filter}\" />\n";

        # History messages
        $body .= "<table class=\"historyTable\" width=\"100%\" summary=\"$self->{language}{History_MainTableSummary}\">\n";
        # column headers
        $body .= "<tr valign=\"bottom\">\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">\n";
        $body .= "<a href=\"/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=\">";
        if ( $self->{form}{sort} eq '' ) {
            $body .= "<em class=\"historyLabelSort\">ID</em>";
        } else {
            $body .= "ID";
        }
        $body .= "</a>\n</th>\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">\n";
        $body .= "<a href=\"/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=from\">";

        if ( $self->{form}{sort} eq 'from' ) {
            $body .= "<em class=\"historyLabelSort\">$self->{language}{From}</em>";
        } else {
            $body .= "$self->{language}{From}";
        }

        $body .= "</a>\n</th>\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">\n";
        $body .= "<a href=\"/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=subject\">";

        if ( $self->{form}{sort} eq 'subject' ) {
            $body .= "<em class=\"historyLabelSort\">$self->{language}{Subject}</em>";
        } else {
            $body .= "$self->{language}{Subject}";
        }

        $body .= "</a>\n</th>\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">\n";
        $body .= "<a href=\"/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=bucket\">";

        if ( $self->{form}{sort} eq 'bucket' ) {
            $body .= "<em class=\"historyLabelSort\">$self->{language}{Classification}</em>";
        } else {
            $body .= "$self->{language}{Classification}";
        }

        $body .= "</a>\n</th>\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">$self->{language}{History_ShouldBe}</th>\n";
        $body .= "<th class=\"historyLabel\" scope=\"col\">$self->{language}{Remove}</th>\n</tr>\n";

        my $stripe = 0;

        foreach my $i ($start_message ..  $stop_message) {
            my $mail_file     = $self->{history_keys_}[$i];
            my $from          = $self->{history_}{$mail_file}{from};
            my $subject       = $self->{history_}{$mail_file}{subject};
            my $short_from    = $self->{history_}{$mail_file}{short_from};
            my $short_subject = $self->{history_}{$mail_file}{short_subject};
            my $bucket        = $self->{history_}{$mail_file}{bucket};
            my $reclassified  = $self->{history_}{$mail_file}{reclassified};

            $body .= "<tr";
            if ( ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) || ( ( defined($self->{form}{file}) && ( $self->{form}{file} eq $mail_file ) ) ) || ( $highlight_message eq $mail_file ) ) {
                $body .= " class=\"rowHighlighted\"";
            } else {
                $body .= " class=\"";
                $body .= $stripe?"rowEven\"":"rowOdd\"";
            }

            $stripe = 1 - $stripe;

            $body .= ">\n<td>";
            $body .= "<a name=\"$mail_file\"></a>";
            $body .= $i+1 . "</td>\n<td>";
            $mail_file =~ /popfile\d+=(\d+)\.msg/;
            $body .= "<a title=\"$from\">$short_from</a></td>\n";
            $body .= "<td><a class=\"messageLink\" title=\"$subject\" href=\"/history?view=$mail_file&amp;start_message=$start_message&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}&amp;search=$self->{form}{search}#$mail_file\">";
            $body .= "$short_subject</a></td>\n<td>";
            if ( $reclassified )  {
                $body .= "<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font></td>\n<td>";
                $body .= sprintf( $self->{language}{History_Already}, ($self->{classifier}->{colors}{$bucket} || ''), ($bucket || '') );
                $body .= " <input type=\"submit\" class=\"undoButton\" name=\"undo_$i\" value=\"$self->{language}{Undo}\">\n";
            } else {
                if ( !defined $self->{classifier}->{colors}{$bucket})  {
                    $body .= "$bucket</td>\n<td>";
                } else {
                    $body .= "<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font></td>\n<td>";
                }

                if ( $self->{history_}{$mail_file}{magnet} eq '' )  {
                    $body .= "\n<select name=\"$i\">\n";

                    # Show a blank bucket field
                    $body .= "<option selected=\"selected\"></option>\n";

                    foreach my $abucket (@buckets) {
                        $body .= "<option value=\"$abucket\">$abucket</option>\n";
                    }
                    $body .= "</select>\n";
                    
                    if ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) {
                        $body .= "<input type=\"submit\" class=\"reclassifyButton\" name=\"change\" value=\"$self->{language}{Reclassify}\" />";
                    }
                } else {
                    $body .= " ($self->{language}{History_MagnetUsed}: $self->{history_}{$mail_file}{magnet})";
                }
            }

            $body .= "</td>\n<td>\n";
            $body .= "<label class=\"removeLabel\" for=\"remove_" . ( $i+1 ) . "\">$self->{language}{Remove}</label>\n";
            $body .= "<input type=\"checkbox\" id=\"remove_" . ( $i+1 ) . "\" class=\"checkbox\" name=\"remove\" value=\"" . ( $i+1 ) . "\" />\n";
            $body .= "</td>\n</tr>\n";


            # Check to see if we want to view a message
            if ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) {
                $body .= "<tr>\n<td></td>\n<td colspan=\"3\" valign=\"top\">\n";
                $body .= "<table class=\"openMessageTable\" cellpadding=\"10%\" cellspacing=\"0\" width=\"100%\" summary=\"$self->{language}{History_OpenMessageSummary}\">\n";

                # Close button
                $body .= "<tr>\n<td class=\"openMessageCloser\">\n";
                $body .= "<a class=\"messageLink\" href=\"/history?start_message=$start_message&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;search=$self->{form}{search}&amp;filter=$self->{form}{filter}\">\n";
                $body .= "<span class=\"historyLabel\">$self->{language}{Close}</span></a>\n";
                $body .= "<br /><br />\n</td>\n</tr>\n";

                # Message body
                $body .= "<tr>\n<td class=\"openMessageBody\">";

                if ( $self->{history_}{$mail_file}{magnet} eq '' )  {
                    $self->{classifier}->{parser}->{color} = 1;
                    $self->{classifier}->{parser}->{bayes} = $self->{classifier};
                    $body .= $self->{classifier}->{parser}->parse_stream("$self->{configuration}->{configuration}{msgdir}$self->{form}{view}");
                    $self->{classifier}->{parser}->{color} = 0;
                } else {
                    $self->{history_}{$mail_file}{magnet} =~ /(.+): ([^\r\n]+)/;
                    my $header = $1;
                    my $text   = $2;
                    $body .= "<tt>";

                    open MESSAGE, "<$self->{configuration}->{configuration}{msgdir}$self->{form}{view}";
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
                                    $line =~ s/(\Q$text\E)/<b><font color\"$self->{classifier}->{colors}{$self->{history_}{$mail_file}{bucket}}\">$1<\/font><\/b>/;
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
                $body .= "<a class=\"messageLink\" href=\"/history?start_message=$start_message&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;search=$self->{form}{search}&amp;filter=$self->{form}{filter}\">\n";
                $body .= "<span class=\"historyLabel\">$self->{language}{Close}</span>\n</a>\n";
                $body .= "</td>\n</tr>\n</table>\n</td>\n";

                $body .= "<td class=\"top20\" valign=\"top\">\n";
                $self->{classifier}->classify_file("$self->{configuration}->{configuration}{msgdir}$self->{form}{view}");
                $body .= $self->{classifier}->{scores};
                $body .= "</td>\n</tr>\n";
            }

            if ( defined $self->{feedback}{$mail_file} ) {
                $body .= "<tr class=\"rowHighlighted\"><td>&nbsp;</td><td>$self->{feedback}{$mail_file}</td>\n";
                delete $self->{feedback}{$mail_file};
            }

            # $body .= "<tr class=\"rowHighlighted\"><td><td>" . sprintf( $self->{language}{History_ChangedTo}, $self->{classifier}->{colors}{$self->{form}{shouldbe}}, $self->{form}{shouldbe} ) if ( ( defined($self->{form}{file}) ) && ( $self->{form}{file} eq $mail_file ) );
        }

        $body .= "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td><input type=\"submit\" class=\"reclassifyButton\" name=\"change\" value=\"$self->{language}{Reclassify}\" />\n</td><td><input type=\"submit\" class=\"deleteButton\" name=\"deletemessage\" value=\"$self->{language}{Remove}\" />\n</td></tr>\n";

        $body .= "</table>\n";

        #END main history form

        $body .= "</form>\n";

        # History buttons bottom
        $body .= "<table class=\"historyWidgetsBottom\" summary=\"\">\n<tr>\n<td>\n";
        $body .= "<form action=\"/history\">\n<input type=\"hidden\" name=\"filter\" value=\"$self->{form}{filter}\" />\n";
        $body .= "<input type=\"hidden\" name=\"sort\" value=\"$self->{form}{sort}\" />\n";
        $body .= "<span class=\"historyLabel\">$self->{language}{History_Remove}:&nbsp;</span>\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"clearall\" value=\"$self->{language}{History_RemoveAll}\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"clearpage\" value=\"$self->{language}{History_RemovePage}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\" />\n";
        $body .= "<input type=\"hidden\" name=\"start_message\" value=\"$start_message\" />\n</form>\n";
        $body .= "</td>\n</tr>\n</table>\n";

        # navigator
        $body .= "<table width=\"100%\" summary=\"\">\n<tr>\n<td class=\"historyNavigatorBottom\">\n";
        $body .= get_history_navigator( $self, $start_message, $stop_message ) if ( $self->{configuration}->{configuration}{page_size} <= $self->history_size() );
        $body .= "\n</td>\n</tr>\n</table>\n";
    } else {
        $body .= "<h2 class=\"history\">$self->{language}{History_Title}$filtered</h2><br /><br /><span class=\"bucketsLabel\">$self->{language}{History_NoMessages}.</span><br /><br />";
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
    my $session_temp = $self->{session_key};

    # Show a page asking for the password with no session key information on it
    $self->{session_key} = '';
    my $body = "<h2 class=\"password\">$self->{language}{Password_Title}</h2>\n<form action=\"/password\" method=\"post\">\n";
    $body .= "<label class=\"passwordLabel\" for=\"thePassword\">$self->{language}{Password_Enter}: </label>\n";
    $body .= "<input type=\"hidden\" name=\"redirect\" value=\"$redirect\" />\n";
    $body .= "<input type=\"password\" id=\"thePassword\" name=\"password\" />\n";
    $body .= "<input type=\"submit\" class=\"submit\" name=\"submit\" value=\"$self->{language}{Password_Go}\" />\n</form>\n";
    $body .= "<blockquote>\n<div class=\"error02\">$self->{language}{Password_Error1}</div>\n</blockquote>" if ( $error == 1 );
    http_ok($self, $client, $body, 99);
    $self->{session_key} = $session_temp;
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
    http_ok($self, $client, "<h2 class=\"session\">$self->{language}{Session_Title}</h2><br /><br />$self->{language}{Session_Error}", 99);
}

# ---------------------------------------------------------------------------------------------
#
# parse_form    - parse form data and fill in $self->{form}
#
# $form         The text of the form arguments (e.g. foo=bar&baz=fou)
#
# ---------------------------------------------------------------------------------------------
sub parse_form
{
    my ( $self, $arguments ) = @_;

    # Normally the browser should have done &amp; to & translation on
    # URIs being passed onto us, but there was a report that someone
    # was having a problem with form arguments coming through with
    # something like http://127.0.0.1/history?session=foo&amp;filter=bar
    # which would mess things up in the argument splitter so this code
    # just changes &amp; to & for safety

    $arguments =~ s/&amp;/&/g;

    while ( $arguments =~ m/\G(.*?)=(.*?)(&|\r|\n|$)/g ) {
        my $arg = $1;
        $self->{form}{$arg} = $2;

        # Expand %7E (hex) escapes in the form data

        $self->{form}{$arg} =~ s/%([0-9A-F][0-9A-F])/chr hex $1/gie;

        $self->{form}{$arg} =~ s/\+/ /g;

        # Push the value onto an array to allow for multiple values of the same name

        push( @{ $self->{form}{$arg . "_array"} }, $self->{form}{$arg} );
    }
}

# ---------------------------------------------------------------------------------------------
#
# handle_url - Handle a URL request
#
# $client     The web browser to send the results to
# $url        URL to process
# $command    The HTTP command used (GET or POST)
# $content    Any non-header data in the HTTP command
#
# Takes a URL and splits it into the URL portion and form arguments specified in the command
# filling out the %form hash with the form elements and their values.  Checks the session
# key and refuses access unless it matches.  Serves up a small set of specific urls that are
# the main UI pages and then any GIF file in the POPFile directory and CSS files in the skins
# subdirectory
#
# ---------------------------------------------------------------------------------------------
sub handle_url
{
    my ( $self, $client, $url, $command, $content ) = @_;

    # See if there are any form parameters and if there are parse them into the %form hash

    delete $self->{form};

    # Remove a # element

    $url =~ s/#.*//;

    # If the URL was passed in through a GET then it may contain form arguments
    # separated by & signs, which we parse out into the $self->{form} where the
    # key is the argument name and the value the argument value, for example if
    # you have foo=bar in the URL then $self->{form}{foo} is bar.

    if ( $command =~ /GET/i ) {
        if ( $url =~ s/\?(.*)// )  {
            $self->parse_form( $1 );
        }
    }

    # If the URL was passed in through a POST then look for the POST data
    # and parse it filling the $self->{form} in the same way as for GET
    # arguments

    if ( $command =~ /POST/i ) {
        $content =~ s/[\r\n]//g;
        $self->parse_form( $content );
    }

    if ( $url eq '/jump_to_message' )  {
        my $found = 0;
        my $file = $self->{form}{view};
        foreach my $akey ( keys %{ $self->{history_} } ) {
            if ($akey eq $file) {
                $found = 1;
                last;
            }
        }

        # Force a history_reload if we did not find this file in the history cache
        # but we do find it on disk using perl's -e file test operator (returns
        # true if the file exists).

        $self->invalidate_history_cache() if ( !$found && ( -e ("$self->{configuration}->{configuration}{msgdir}$file") ) );
        $self->http_redirect( $client, "/history?session=$self->{session_key}&start_message=0&view=$self->{form}{view}#$self->{form}{view}" );
        return 1;
    }

    if ( $url =~ /\/(.+\.gif)/ ) {
        http_file( $self,  $client, $1, 'image/gif' );
        return 1;
    }

    if ( $url =~ /(skins\/.+\.css)/ ) {
        http_file( $self,  $client, $1, 'text/css' );
        return 1;
    }

    if ( $url =~ /(manual\/.+\.html)/ ) {
        http_file( $self,  $client, $1, 'text/html' );
        return 1;
    }

    # Check the password
    if ( $url eq '/password' )  {
        if ( $self->{form}{password} eq $self->{configuration}->{configuration}{password} )  {
            change_session_key( $self );
            delete $self->{form}{password};
            $self->{form}{session} = $self->{session_key};
            if ( defined( $self->{form}{redirect} ) ) {
                $url = $self->{form}{redirect};
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
    if ( ( (!defined($self->{form}{session})) || ($self->{form}{session} eq '' ) || ( $self->{form}{session} ne $self->{session_key} ) ) && ( $self->{configuration}->{configuration}{password} ne '' ) ) {
        password_page( $self, $client, 0, $url );
        return 1;
    }

    if ( ( defined($self->{form}{session}) ) && ( $self->{form}{session} ne $self->{session_key} ) ) {
        session_page( $self, $client, 0, $url );
        return 1;
    }

    if ( ( $url eq '/' ) || (!defined($self->{form}{session})) ) {
        delete $self->{form};
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

    http_error($self, $client, 404);
    return 1;
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

    @{$self->{skins}} = glob 'skins/*.css';

    for my $i (0..$#{$self->{skins}}) {
        $self->{skins}[$i] =~ s/.*\/(.+)\.css/$1/;
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

    @{$self->{languages}} = glob 'languages/*.msg';

    for my $i (0..$#{$self->{languages}}) {
        $self->{languages}[$i] =~ s/.*\/(.+)\.msg/$1/;
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

    $self->{session_key} = '';
    for my $i (0 .. 7) {
        $self->{session_key} .= chr(rand(1)*26+65);
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
                my $msg = ($self->{configuration}->{configuration}{test_language})?$1:$2;
                $msg =~ s/[\r\n]//g;

                $self->{language}{$id} = $msg;
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
        my @mail_files = glob "$self->{configuration}->{configuration}{msgdir}popfile*=*.msg";

        foreach my $mail_file (@mail_files) {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($mail_file);

            if ( $ctime < (time - $self->{configuration}->{configuration}{history_days} * $seconds_per_day) )  {
                $self->history_delete_file( $mail_file, $self->{configuration}->{configuration}{archive} );
            }
        }

         # Clean up old style msg/cls files

        @mail_files = glob "$self->{configuration}->{configuration}{msgdir}popfile*_*.???";

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
    
    $mail_file =~ /(popfile.+\=.+\.msg)/;
    $mail_file = $1;

    if ( $archive ) {
        my $path = $self->{configuration}->{configuration}{archive_dir};
        
        mkdir( $path );

        my ($reclassified, $bucket, $usedtobe, $magnet) = $self->history_load_class( $mail_file );

        if ( ( $bucket ne 'unclassified' ) && ( $bucket ne 'unknown class' ) ) {
            $path .= "\/" . $bucket;
            mkdir( $path );

            if ( $self->{configuration}->{configuration}{archive_classes} > 0) {
                # archive to a random sub-directory of the bucket archive
                my $subdirectory = int( rand( $self->{configuration}->{configuration}{archive_classes} ) );
                $path .= "\/" . $subdirectory;
                mkdir( $path );
            }

            # TODO This may be UNSAFE, please write a better comment that explains
            # why this might be unsafe.  What does unsafe mean in this context?

            $self->history_copy_file( "$self->{configuration}->{configuration}{msgdir}$mail_file", $path, $mail_file );
        }
    }

    # Before deleting the file make sure that the appropriate entry in the
    # history cache is also remove

    delete $self->{history_}{$mail_file};

    # Now remove the files from the disk, remove both the msg file containing
    # the mail message and its associated CLS file

    unlink( "$self->{configuration}->{configuration}{msgdir}$mail_file" );
    $mail_file =~ s/msg$/cls/;
    unlink( "$self->{configuration}->{configuration}{msgdir}$mail_file" );
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
            while (<FROM>) {
                print TO $_;
            }
        close FROM;
        }
        close TO;
    }
}

1;
