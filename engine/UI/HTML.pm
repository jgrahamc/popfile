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

# A handy variable containing the value of an EOL for Unix systems
my $eol = "\015\012";

# Constant used by the log rotation code
my $seconds_per_day = 60 * 60 * 24;

my $highlight_color = "black";

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
    
    $self->{history}         = {};
    $self->{history_keys}    = ();
    $self->{history_invalid} = 0;

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
    $self->{configuration}->{configuration}{skin}              = 'default';

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

    # Load skins
    load_skins($self);

    # Load the list of available user interface languages
    load_languages($self);

    # Calculate a session key
    change_session_key($self);

    calculate_today( $self );
    
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
    
    $self->{server} = IO::Socket::INET->new( Proto     => 'tcp',
                                    $self->{configuration}->{configuration}{localui}  == 1 ? (LocalAddr => 'localhost') : (), 
                                     LocalPort => $self->{configuration}->{configuration}{ui_port},
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 ) or return 0;

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
            if ( ( $self->{configuration}->{configuration}{localui} == 0 ) || ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {
            
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
                        $code = $self->handle_url($client, $2, $1, $content);
                    } else {
                        http_error( $self, $client, 500 );
                    }                  
                }
            }

            close $client;
        }
    }
    
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
    $tab[$selected]  = 'menuSelected' if ( ( $selected <= $#tab ) && ( $selected >= 0 ) );
    my $update_check = ''; 

    # Check to see if we've checked for updates today.  If we have not then insert a reference to an image
    # that is generated through a CGI on UseTheSource.  Also send stats to the same site if that is allowed

    if ( $self->{today} ne $self->{configuration}->{configuration}{last_update_check} ) {
        calculate_today( $self );
        
        if ( $self->{configuration}->{configuration}{update_check} ) {
            $update_check = "<a href=\"http://sourceforge.net/project/showfiles.php?group_id=63137\">\n" ;
            $update_check .= "<img border=\"0\" alt=\"\" src=\"http://www.usethesource.com/cgi-bin/popfile_update.pl?ma=$self->{configuration}{major_version}&mi=$self->{configuration}{minor_version}&bu=$self->{configuration}{build_version}\">\n</a>\n";
        }
        
        if ( $self->{configuration}->{configuration}{send_stats} ) {
            my @buckets = keys %{$self->{classifier}->{total}};
            my $bc      = $#buckets + 1;
            $update_check .= "<img border=\"0\" alt=\"\" src=\"http://www.usethesource.com/cgi-bin/popfile_stats.pl?bc=$bc&mc=$self->{configuration}->{configuration}{mcount}&ec=$self->{configuration}->{configuration}{ecount}\">\n";
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
    
    my $result = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n\t" ;
    $result .= "\"http://www.w3.org/TR/html4/loose.dtd\">\n" ;
    $result .= "<html>\n\t<head>\n\t\t<title>$self->{language}{Header_Title}</title>\n\t\t" ;
    
    $result .= "<link rel=\"stylesheet\" type=\"text/css\" " ;
    $result .= "href=\"skins/$self->{configuration}->{configuration}{skin}.css\" title=\"main\">\n\t\t" ;
    $result .= "<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">\n\t\t" ;
    $result .= "<META HTTP-EQUIV=\"Expires\" CONTENT=\"0\">\n\t\t" ;
    
    $result .= "<META HTTP-EQUIV=\"Cache-Control\" CONTENT=\"no-cache\">\n\t\t" ;
    $result .= "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; CHARSET=ISO-8859-1\">\n\t\t</head>\n\t" ;

    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# html_common_middle - Called from http_ok to build the common middle part of an html page
#                      that consists of the title at the top of the page and the tabs for
#                       selecting parts of the program
#
# $text              The body of the page
# $update_check      Contains html for updating, as required
# @tab               Array of interface tabs -- one of which is selected
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
    
    my $result = "<body>\n\t<table class=\"shell\" align=\"center\" width=\"100%\">\n\t\t" ;
    $result .= "<tr class=\"top\">\n<td class=\"border_topLeft\"></td>\n<td class=\"border_top\"></td>\n" ;
    $result .= "<td class=\"border_topRight\"></td>\n</tr>\n<tr>\n<td class=\"border_left\"></td>\n" ;
    $result .= "<td class=\"naked\">\n" ;
    $result .= "<table class=\"head\" cellspacing=\"0\" width=\"100%\">\n<tr>\n" ;
    
    $result .= "<td>&nbsp;&nbsp;$self->{language}{Header_Title}\n" ;
    $result .= "<td align=\"right\" valign=\"middle\">\n" ;
    $result .= "<a href=\"/shutdown\">$self->{language}{Header_Shutdown}</a>&nbsp;\n" ;
    $result .= "<tr>\n<td height=\"3\" colspan=\"3\"></td>\n</tr>\n</table>\n</td>\n" ;
    $result .= "<td class=\"border_right\"></td>\n</tr><tr class=\"bottom\">\n" ;
    
    $result .= "<td class=\"border_bottomLeft\"></td>\n<td class=\"border_bottom\"></td>\n" ;
    $result .= "<td class=\"border_bottomRight\"></td>\n</tr>\n</table>\n" ;
    $result .= "<p align=\"center\">$update_check\n<table class=\"menu\" cellspacing=\"0\">\n" ;
    $result .= "<tr align=\"center\">\n<td class=\"$tab[2]\" align=\"center\">\n" ;
    $result .= "<a href=\"/history?setfilter=&amp;session=$self->{session_key}&amp;filter=\">" ;
    
    $result .= "\n$self->{language}{Header_History}</a>\n" ;
    $result .= "</td>\n<td class=\"menu_spacer\"></td>\n<td class=\"$tab[1]\" align=\"center\">\n" ;
    $result .= "<a href=\"/buckets?session=$self->{session_key}\">\n$self->{language}{Header_Buckets}</a>\n</td>\n" ;
    $result .= "<td class=\"menu_spacer\"></td>\n<td class=\"$tab[4]\" align=\"center\">\n" ;
    $result .= "<a href=\"/magnets?session=$self->{session_key}\">$self->{language}{Header_Magnets}</a>\n</td>\n" ;
    
    $result .= "<td class=\"menu_spacer\"></td>\n<td class=\"$tab[0]\" align=\"center\">\n" ;
    $result .= "<a href=\"/configuration?session=$self->{session_key}\">" ;
    $result .= "$self->{language}{Header_Configuration}</a>\n</td>\n" ;
    $result .= "<td class=\"menu_spacer\"></td>\n<td class=\"$tab[3]\" align=\"center\">\n" ;
    $result .= "<a href=\"/security?session=$self->{session_key}\">$self->{language}{Header_Security}</a>\n</td>\n" ;
    $result .= "<td class=\"menu_spacer\"></td>\n<td class=\"$tab[5]\" align=\"center\">\n" ;
    
    $result .= "<a href=\"/advanced?session=$self->{session_key}\">$self->{language}{Header_Advanced}</a>\n" ;
    $result .= "</td>\n</tr>\n</table>\n<table class=\"shell\" align=\"center\" width=\"100%\">\n<tr class=\"top\">\n" ;
    $result .= "<td class=\"border_topLeft\"></td>\n<td class=\"border_top\"></td>\n" ;
    $result .= "<td class=\"border_topRight\">\n</td>\n</tr>\n<tr>\n<td class=\"border_left\"></td>\n" ;
    $result .= "<td align=\"left\" class=\"naked\">" . $text . "</td>\n" ;
    
    $result .= "<td class=\"border_right\"></td>\n</tr>\n<tr class=\"bottom\">\n<td class=\"border_bottomLeft\"></td>\n" ;
    $result .= "<td class=\"border_bottom\"></td>\n<td class=\"border_bottomRight\"></td>\n" ;
    $result .= "</tr>\n</table>\n<p align=\"center\">\n" ;
    
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
    
    my $result = "\n\t\t<table class=\"footer\">\n\t\t\t<tr>\n\t\t\t\t<td align=\"left\">\n\t\t\t\t\t" ;
    $result .= "POPFile v$self->{configuration}{major_version}.$self->{configuration}{minor_version}." ;
    $result .= "$self->{configuration}{build_version} - \n\t\t\t\t\t" ;
    $result .= "<a href=\"manual/$self->{language}{LanguageCode}/manual.html\">\n\t\t\t\t\t\t" ;
    $result .= "$self->{language}{Footer_Manual}</a> - \n\t\t\t\t\t" ;
    
    $result .= "<a href=\"http://popfile.sourceforge.net/\">$self->{language}{Footer_HomePage}</a> - \n\t\t\t\t\t" ;
    $result .= "<a href=\"http://sourceforge.net/forum/forum.php?forum_id=213876\">$self->{language}{Footer_FeedMe}</a> - \n\t\t\t\t" ;
    $result .= "<a href=\"http://sourceforge.net/tracker/index.php?group_id=63137&amp;atid=502959\">$self->{language}{Footer_RequestFeature}</a> - \n\t\t\t\t\t" ;
    $result .= "<a href=\"http://lists.sourceforge.net/lists/listinfo/popfile-announce\">$self->{language}{Footer_MailingList}</a> - \n\t\t\t\t\t" ;
    $result .= "($time)\n\t\t\t\t\t" ;
    
    # Comment out this next line prior to shipping code
    # enable it during development to check validation
    # my $validationLinks = "Validate: <a href=\"http://validator.w3.org/check/referer\">HTML 4.01</a> - \n\t\t\t\t" ;
    # $validationLinks .= "<a href=\"http://jigsaw.w3.org/css-validator/check/referer\">CSS-1</a>" ;
    # $result .= " - $validationLinks\n\t\t\t\t\t" ;
    
    $result .= "</td>\n\t\t\t\t</tr>\n\t\t\t</table>\n\t\t</body>\n\t</html>" ;

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
            $separator_error = "<blockquote>\n<font color=\"red\" size=+1>\n" ;
            $separator_error .= "$self->{language}{Configuration_Error1}</font>\n</blockquote>\n" ;
            delete $self->{form}{separator};
        }
    }

    if ( defined($self->{form}{ui_port}) ) {
        if ( ( $self->{form}{ui_port} >= 1 ) && ( $self->{form}{ui_port} < 65536 ) ) {
            $self->{configuration}->{configuration}{ui_port} = $self->{form}{ui_port};
        } else {
            $ui_port_error = "<blockquote>\n<font color=\"red\" size=+1>\n" ;
            $ui_port_error .= "$self->{language}{Configuration_Error2}</font>\n</blockquote>\n";
            delete $self->{form}{ui_port};
        }
    }

    if ( defined($self->{form}{port}) ) {
        if ( ( $self->{form}{port} >= 1 ) && ( $self->{form}{port} < 65536 ) ) {
            $self->{configuration}->{configuration}{port} = $self->{form}{port};
        } else {
            $port_error = "<blockquote><font color=\"red\" size=+1>$self->{language}{Configuration_Error3}</font></blockquote>";
            delete $self->{form}{port};
        }
    }

    if ( defined($self->{form}{page_size}) ) {
        if ( ( $self->{form}{page_size} >= 1 ) && ( $self->{form}{page_size} <= 1000 ) ) {
            $self->{configuration}->{configuration}{page_size} = $self->{form}{page_size};
        } else {
            $page_size_error = "<blockquote><font color=\"red\" size=+1>$self->{language}{Configuration_Error4}</font></blockquote>";
            delete $self->{form}{page_size};
        }
    }

    if ( defined($self->{form}{history_days}) ) {
        if ( ( $self->{form}{history_days} >= 1 ) && ( $self->{form}{history_days} <= 366 ) ) {
            $self->{configuration}->{configuration}{history_days} = $self->{form}{history_days};
        } else {
            $history_days_error = "<blockquote><font color=\"red\" size=+1>$self->{language}{Configuration_Error5}</font></blockquote>";
            delete $self->{form}{history_days};
        }
    }

    if ( defined($self->{form}{timeout}) ) {
        if ( ( $self->{form}{timeout} >= 10 ) && ( $self->{form}{timeout} <= 300 ) ) {
            $self->{configuration}->{configuration}{timeout} = $self->{form}{timeout};
        } else {
            $timeout_error = "<blockquote><font color=\"red\" size=+1>$self->{language}{Configuration_Error6}</font></blockquote>";
            $self->{form}{update_timeout} = '';
        }
    }

    # User Interface panel
    $body .= "<table class=\"stabColor01\" width=\"100%\" cellpadding=\"10\" cellspacing=\"0\" >\n" ;
    $body .= "<tr>\n<td class=\"stabColor01\" width=\"33%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Configuration_UserInterface}</h2>\n" ;
    $body .= "<p>\n<form action=\"/configuration\" method=\"post\">\n" ;
    $body .= "<b>$self->{language}{Configuration_SkinsChoose}:</b> <br>\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n<select name=\"skin\">\n" ;

    for my $i (0..$#{$self->{skins}}) {
        $body .= "<option value=\"$self->{skins}[$i]\"";
        $body .= " selected" if ( $self->{skins}[$i] eq $self->{configuration}->{configuration}{skin} );
        $body .= ">$self->{skins}[$i]</option>";
    }

    $body .= "</select>\n<input type=\"submit\" class=\"submit\" value=\"$self->{language}{Apply}\" name=\"change_skin\">\n" ;
    $body .= "</form>\n<p>\n<form action=\"/configuration\">\n" ;
    $body .= "<b>$self->{language}{Configuration_LanguageChoose}:</b> <br>\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n<select name=\"language\">\n";

    for my $i (0..$#{$self->{languages}}) {
        $body .= "<option value=\"$self->{languages}[$i]\"";
        $body .= " selected" if ( $self->{languages}[$i] eq $self->{configuration}->{configuration}{language} );
        $body .= ">$self->{languages}[$i]</option>";
    }

    $body .= "</select>\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" value=\"$self->{language}{Apply}\" name=\"change_language\">\n" ;
    $body .= "</form>\n";
    
    # History View panel
    $body .= "<td class=\"stabColor01\" width=\"33%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Configuration_HistoryView}</h2>\n" ;
    $body .= "<p>\n<form action=\"/configuration\">\n" ;
    $body .= "<b>$self->{language}{Configuration_History}:</b> <br>\n" ;
    $body .= "<input name=\"page_size\" type=\"text\" value=\"$self->{configuration}->{configuration}{page_size}\">\n" ;

    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_page_size\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n$page_size_error\n" ; 
    $body .= sprintf( $self->{language}{Configuration_HistoryUpdate}, $self->{configuration}->{configuration}{page_size} ) if ( defined($self->{form}{page_size}) );
    $body .= "\n<p>\n<p>\n<form action=\"/configuration\">\n<b>$self->{language}{Configuration_Days}:</b> <br>\n" ;
    $body .= "<input name=\"history_days\" type=\"text\" value=\"$self->{configuration}->{configuration}{history_days}\">\n" ;

    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_history_days\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
    $body .= "</form>\n$history_days_error\n" ;
    $body .= sprintf( $self->{language}{Configuration_DaysUpdate}, $self->{configuration}->{configuration}{history_days} ) if ( defined($self->{form}{history_days}) );

    # Classification Insertion panel
    $body .= "\n<td class=\"stabColor01\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Configuration_ClassificationInsertion}</h2>\n<p>\n" ;
    $body .= "<table>\n<tr>\n<td><b>$self->{language}{Configuration_SubjectLine}:</b> \n"; 
    if ( $self->{configuration}->{configuration}{subject} == 1 ) {
        $body .= "<td>\n<b>$self->{language}{On}</b> \n" ;
        $body .= "<a href=\"/configuration?subject=1&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{TurnOff}]</font>\n</a> \n" ;
    } else {
        $body .= "<td>\n$self->{language}{Off} \n" ;
        $body .= "<a href=\"/configuration?subject=2&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{TurnOn}]</font></a> \n" ;
    }
    $body .= "<tr>\n<td>\n<b>$self->{language}{Configuration_XTCInsertion}:</b> \n";    
    if ( $self->{configuration}->{configuration}{xtc} == 1 )  {
        $body .= "<td><b>$self->{language}{On}</b> <a href=\"/configuration?xtc=1&amp;session=$self->{session_key}\"><font color=\"blue\">[$self->{language}{TurnOff}]</font></a> ";
    } else {
        $body .= "<td>$self->{language}{Off} <a href=\"/configuration?xtc=2&amp;session=$self->{session_key}\"><font color=\"blue\">[$self->{language}{TurnOn}]</font></a>";
    }
    $body .= "<tr>\n<td>\n<b>$self->{language}{Configuration_XPLInsertion}:</b> \n";    
    if ( $self->{configuration}->{configuration}{xpl} == 1 )  {
        $body .= "<td><b>$self->{language}{On}</b> <a href=\"/configuration?xpl=1&amp;session=$self->{session_key}\"><font color=\"blue\">[$self->{language}{TurnOff}]</font></a> ";
    } else {
        $body .= "<td>$self->{language}{Off} <a href=\"/configuration?xpl=2&amp;session=$self->{session_key}\"><font color=\"blue\">[$self->{language}{TurnOn}]</font></a>";
    }
    $body .= "</table>";
    
    # Listen Ports panel
    $body .= "<tr>\n<td class=\"stabColor01\" width=\"33%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Configuration_ListenPorts}</h2>\n" ;
    $body .= "<p>\n<form action=\"/configuration\">\n" ;
    $body .= "<b>$self->{language}{Configuration_POP3Port}:</b><br>\n" ;
    $body .= "<input name=\"port\" type=\"text\" value=\"$self->{configuration}->{configuration}{port}\">\n" ;

    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_port\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n$port_error\n"; 
    $body .= sprintf( $self->{language}{Configuration_POP3Update}, $self->{configuration}->{configuration}{port} ) if ( defined($self->{form}{port}) );
    $body .= "<p>\n<form action=\"/configuration\">\n" ;
    $body .= "<b>$self->{language}{Configuration_Separator}:</b><br>\n" ;

    $body .= "<input name=\"separator\" type=\"text\" value=\"$self->{configuration}->{configuration}{separator}\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_separator\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n$separator_error\n";
    $body .= sprintf( $self->{language}{Configuration_SepUpdate}, $self->{configuration}->{configuration}{separator} ) if ( defined($self->{form}{separator}) );
    $body .= "<p><form action=\"/configuration\"><b>$self->{language}{Configuration_UI}:</b><br>\n" ;
    $body .= "<input name=\"ui_port\" type=\"text\" value=\"$self->{configuration}->{configuration}{ui_port}\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_ui_port\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\"></form>$ui_port_error";    
    $body .= sprintf( $self->{language}{Configuration_UIUpdate}, $self->{configuration}->{configuration}{ui_port} ) if ( defined($self->{form}{ui_port}) );

    # TCP Connection Timeout panel
    $body .= "<td class=\"stabColor01\" width=\"33%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Configuration_TCPTimeout}</h2>\n" ;
    $body .= "<p><form action=\"/configuration\">\n" ;
    $body .= "<b>$self->{language}{Configuration_TCPTimeoutSecs}:</b> <br>\n" ;
    $body .= "<input name=\"timeout\" type=\"text\" value=\"$self->{configuration}->{configuration}{timeout}\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_timeout\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n$timeout_error" ;
    $body .= sprintf( $self->{language}{Configuration_TCPTimeoutUpdate}, $self->{configuration}->{configuration}{timeout} ) if ( defined($self->{form}{timeout}) );
    
    # Logging panel
    $body .= "<td class=\"stabColor01\" width=\"33%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Configuration_Logging}</h2>\n" ;
    $body .= "<b>$self->{language}{Configuration_LoggerOutput}:</b><br>\n" ;
    $body .= "<form action=\"/configuration\">\n" ;
    $body .="<input type=\"hidden\" value=\"$self->{session_key}\" name=\"session\"><select name=\"debug\">";
    $body .= "<option value=\"1\"";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 0 );
    $body .= ">$self->{language}{Configuration_None}</option>";
    $body .= "<option value=\"2\"";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 1 );
    $body .= ">$self->{language}{Configuration_ToFile}</option>";
    $body .= "<option value=\"3\"";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 2 );
    $body .= ">$self->{language}{Configuration_ToScreen}</option>";
    $body .= "<option value=\"4\"";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 3 );
    $body .= ">$self->{language}{Configuration_ToScreenFile}</option>";
    $body .= "</select><input type=\"submit\" class=\"submit\" name=\"submit_debug\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "</form>\n</table>\n";
    
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
            $port_error = "<blockquote><font color=\"red\" size=+1>$self->{language}{Security_Error1}</font></blockquote>";
            delete $self->{form}{sport};
        }
    }

    $body .= "<table class=\"stabColor01\" width=\"100%\" cellpadding=\"10\" cellspacing=\"0\" >\n<tr>\n" ;

    # Stealth Mode / Server Operation panel
    $body .= "<td class=\"stabColor01\" width=\"50%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Security_Stealth}</h2>\n" ;
    $body .= "<p><b>$self->{language}{Security_POP3}:</b><br>\n";
    
    if ( $self->{configuration}->{configuration}{localpop} == 1 ) {
        $body .= "<b>$self->{language}{Security_NoStealthMode}</b>\n" ;
        $body .= " <a href=\"/security?localpop=1&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{ChangeToYes}]</font></a>\n" ;
    } else {
        $body .= "<b>$self->{language}{Yes}</b>\n" ;
        $body .= " <a href=\"/security?localpop=2&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{ChangeToNo} (Stealth Mode)]</font></a>\n" ;
    } 
    
    $body .= "<p><b>$self->{language}{Security_UI}:</b><br>\n";
    if ( $self->{configuration}->{configuration}{localui} == 1 ) {
        $body .= "<b>$self->{language}{Security_NoStealthMode}</b>\n" ;
        $body .= "<a href=\"/security?localui=1&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{ChangeToYes}]</font></a>\n ";
    } else {
        $body .= "<b>$self->{language}{Yes}</b> " ;
        $body .= "<a href=\"/security?localui=2&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{ChangeToNo} (Stealth Mode)]</font></a>\n ";
    } 

    # User Interface Password panel
    $body .= "<td class=\"stabColor01\" width=\"50%\" valign=\"top\" >\n" ;
    $body .= "<h2>$self->{language}{Security_PasswordTitle}</h2>\n" ;
    $body .= "<p><form action=\"/security\"><b>$self->{language}{Security_Password}:</b> <br>\n" ;
    $body .= "<input name=\"password\" type=\"password\" value=\"$self->{configuration}->{configuration}{password}\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_server\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n";
    $body .= sprintf( $self->{language}{Security_PasswordUpdate}, $self->{configuration}->{configuration}{password} ) if ( defined($self->{form}{password}) );
   
    # Automatic Update Checking panel
    $body .= "\n<tr>\n<td class=\"stabColor01\" width=\"50%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Security_UpdateTitle}</h2>\n" ;
    $body .= "<p><b>$self->{language}{Security_Update}:</b><br>\n";
    
    if ( $self->{configuration}->{configuration}{update_check} == 1 ) {
        $body .= "<b>$self->{language}{Yes}</b>\n" ;
        $body .= "<a href=\"/security?update_check=1&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{ChangeToNo}]</font>\n</a>\n" ;
    } else {
        $body .= "<b>$self->{language}{No}</b>\n" ;
        $body .= "<a href=\"/security?update_check=2&amp;session=$self->{session_key}\">\n" ;
        $body .= "<font color=\"blue\">[$self->{language}{ChangeToYes}]</font>\n</a>\n" ;
    } 
    
    $body .= "<p>$self->{language}{Security_ExplainUpdate}";
    
    # Reporting Statistics panel
    $body .= "<td class=\"stabColor01\" width=\"50%\" valign=\"top\">\n" ;
    $body .= "<h2>$self->{language}{Security_StatsTitle}</h2>\n" ;
    $body .= "<p>\n<b>$self->{language}{Security_Stats}:</b>\n<br>\n";
    
    if ( $self->{configuration}->{configuration}{send_stats} == 1 ) {
        $body .= "<b>$self->{language}{Yes}</b> <a href=\"/security?send_stats=1&amp;session=$self->{session_key}\"><font color=\"blue\">[$self->{language}{ChangeToNo}]</font></a> ";
    } else {
        $body .= "<b>$self->{language}{No}</b> <a href=\"/security?send_stats=2&amp;session=$self->{session_key}\"><font color=\"blue\">[$self->{language}{ChangeToYes}]</font></a> ";
    } 
    $body .= "<p>$self->{language}{Security_ExplainStats}";
    
    # Secure Password Authentication/AUTH panel
    $body .= "<tr>\n<td class=\"stabColor01\" width=\"100%\" valign=\"top\" colspan=\"2\">\n" ;
    $body .= "<h2>$self->{language}{Security_AUTHTitle}</h2>\n" ;
    $body .= "<p>\n<form action=\"/security\">\n<b>$self->{language}{Security_SecureServer}:</b> <br>\n" ;
    $body .= "<input name=\"server\" type=\"text\" value=\"$self->{configuration}->{configuration}{server}\">\n" ;
    
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_server\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n";
    $body .= sprintf( $self->{language}{Security_SecureServerUpdate}, $self->{configuration}->{configuration}{server} ) if ( defined($self->{form}{server}) );
    $body .= "<p><form action=\"/security\"><b>$self->{language}{Security_SecurePort}:</b> <br>\n" ;
    $body .= "<input name=\"sport\" type=\"text\" value=\"$self->{configuration}->{configuration}{sport}\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"update_sport\" value=\"$self->{language}{Apply}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\"></form>\n$port_error";    
    
    $body .= sprintf( $self->{language}{Security_SecurePortUpdate}, $self->{configuration}->{configuration}{sport} ) if ( defined($self->{form}{sport}) );
    $body .= "\n</table>\n";
    
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
    my $delete_message = '';
    if ( defined($self->{form}{newword}) ) {
        $self->{form}{newword} = lc($self->{form}{newword});
        if ( defined($self->{classifier}->{parser}->{mangle}->{stop}{$self->{form}{newword}}) ) {
            $add_message = "<blockquote><font color=\"red\"><b>". sprintf( $self->{language}{Advanced_Error1}, $self->{form}{newword} ) . "</b></font></blockquote>";
        } else {
            if ( $self->{form}{newword} =~ /[^[:alpha:][0-9]\._\-@]/ ) {
                $add_message = "<blockquote><font color=\"red\"><b>$self->{language}{Advanced_Error2}</b></font></blockquote>";
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
            $delete_message = "<blockquote><font color=\"red\"><b>" . sprintf( $self->{language}{Advanced_Error4} , $self->{form}{word} ) . "</b></font></blockquote>";
        } else {
            delete $self->{classifier}->{parser}->{mangle}->{stop}{$self->{form}{word}};
            $self->{classifier}->{parser}->{mangle}->save_stop_words();
            $delete_message = "<blockquote>" . sprintf( $self->{language}{Advanced_Error5}, $self->{form}{word} ) . "</blockquote>";
        }
    }

    my $body = "<h2>$self->{language}{Advanced_StopWords}</h2><p>$self->{language}{Advanced_Message1}<p><table>";
    my $last = '';
    my $need_comma = 0;
    for my $word (sort keys %{$self->{classifier}->{parser}->{mangle}->{stop}}) {
        $word =~ /^(.)/;
        if ( $1 ne $last )  {
            $body .= "<tr><td><b>$1</b><td>";
            $last = $1;
            $need_comma = 0;
        }
        if ( $need_comma == 1 ) {
            $body .= ", $word";
        } else {
            $body .= $word;
            $need_comma = 1;
        }
    }
    $body .= "</table>\n<p>\n<form action=\"/advanced\">\n" ;
    $body .= "<b>$self->{language}{Advanced_AddWord}:</b><br>\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
    $body .= "<input type=\"text\" name=\"newword\">\n" ; 
    $body .= "<input type=\"submit\" class=\"submit\" name=\"add\" value=\"$self->{language}{Add}\">\n" ;
    $body .= "</form>\n$add_message\n";
    $body .= "<p>\n<form action=\"/advanced\">\n" ;
    $body .= "<b>$self->{language}{Advanced_RemoveWord}:</b><br>\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
    $body .= "<input type=\"text\" name=\"word\">\n" ; 
    $body .= "<input type=\"submit\" class=\"submit\" name=\"remove\" value=\"$self->{language}{Remove}\">\n" ;
    $body .= "</form>\n$delete_message\n";
    
    http_ok($self, $client,$body,5);
}

# ---------------------------------------------------------------------------------------------
#
# encode
#
# $text     Text to encode for URL safety
#
# Encode a URL so that it can be safely passed in a URL
#
# ---------------------------------------------------------------------------------------------
sub encode 
{
    my ( $self, $text ) = @_;
    
    $text =~ s/ /\+/;
    
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
                $magnet_message = "<blockquote>\n<font color=\"red\">\n<b>" ;
                $magnet_message .= sprintf( $self->{language}{Magnet_Error1}, "$self->{form}{type}: $self->{form}{text}", $bucket ) ;
                $magnet_message .= "</b>\n</font>\n</blockquote>\n";
            }
        }

        if ( $found == 0 )  {
            for my $bucket (keys %{$self->{classifier}->{magnets}}) {
                for my $from (keys %{$self->{classifier}->{magnets}{$bucket}{$self->{form}{type}}})  {
                    if ( ( $self->{form}{text} =~ /\Q$from\E/ ) || ( $from =~ /\Q$self->{form}{text}\E/ ) )  {
                        $found = 1;
                        $magnet_message = "<blockquote><font color=\"red\"><b>" . sprintf( $self->{language}{Magnet_Error2}, "$self->{form}{type}: $self->{form}{text}", "$self->{form}{type}: $from", $bucket ) . "</b></font></blockquote>";
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
    
    my $body = "<h2>$self->{language}{Magnet_CurrentMagnets}</h2>\n" ;
    $body .= "<p>\n$self->{language}{Magnet_Message1}\n";
    $body .= "<p>\n<table width=\"75%\">\n<tr>\n<td><b>$self->{language}{Magnet}</b>\n" ;
    $body .= "<td><b>$self->{language}{Bucket}</b>\n<td><b>$self->{language}{Delete}</b>\n";
    
    my $stripe = 0;
    for my $bucket (sort keys %{$self->{classifier}->{magnets}}) {
        for my $type (sort keys %{$self->{classifier}->{magnets}{$bucket}}) {
            for my $magnet (sort keys %{$self->{classifier}->{magnets}{$bucket}{$type}})  {
                $body .= "<tr "; 
                if ( $stripe )  {
                    $body .= " class=\"rowEven\""; 
                } else {
                    $body .= " class=\"rowOdd\""; 
                }
                
                # to validate, must replace & with &amp;
                # stan todo note: come up with a smarter regex, this one's a bludgeon
                
                my $validatingMagnet = $magnet ;
                $validatingMagnet =~ s/&/&amp;/g ;
                $validatingMagnet =~ s/</&lt;/g ;
                $validatingMagnet =~ s/>/&gt;/g ;
                
                $body .= "><td>$type: $validatingMagnet\n" ;
                $body .= "<td><font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font><td>\n" ;
                $body .= "<a href=\"/magnets?bucket=$bucket&amp;dtype=$type&amp;";
                $body .= encode($self, "dmagnet=$validatingMagnet");
                $body .= "&amp;session=$self->{session_key}\">\n[$self->{language}{Delete}]</a>\n";
                $stripe = 1 - $stripe;
            }
        }
    }
    
    $body .= "</table>\n<p><hr>\n<h2>$self->{language}{Magnet_CreateNew}</h2>\n" ;
    $body .= "<table cellspacing=\"0\">\n<tr>\n<td>\n" ;
    $body .= "<b>$self->{language}{Magnet_Explanation}\n" ;
    $body .= "</td>\n</tr>\n</table>\n" ;
    
    # New Magnets form
    $body .= "<form action=\"/magnets\">\n" ;

    # Magnet Type widget
    $body .= "<b>$self->{language}{Magnet_MagnetType}:</b><br>\n" ;
    $body .= "<select name=\"type\">\n<option value=\"from\">\n$self->{language}{From}</option>\n" ;
    $body .= "<option value=\"to\">\n$self->{language}{To}</option>\n" ;
    $body .= "<option value=\"subject\">\n$self->{language}{Subject}</option>\n</select>\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n";
    
    # Value widget
    $body .= "<p><b>$self->{language}{Magnet_Value}:</b><br>\n" ;
    $body .= "<input type=\"text\" name=\"text\">\n" ;
    
    # Always Goes to Bucket widget
    $body .= "<p><b>$self->{language}{Magnet_Always}:</b><br>\n" ;
    $body .= "<select name=\"bucket\">\n<option value=\"\"></option>\n";
    
    my @buckets = sort keys %{$self->{classifier}->{total}};
    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>";
    }
    $body .= "</select> <input type=\"submit\" class=\"submit\" name=\"create\" value=\"$self->{language}{Create}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n$magnet_message";
    
    http_ok($self, $client,$body,4);
}

#
# ---------------------------------------------------------------------------------------------
#
# bucket_page - information about a specific bucket
#
# $client     The web browser to send the results to
# ---------------------------------------------------------------------------------------------
sub bucket_page  
{
    my ( $self, $client ) = @_;
    
    my $body = "<h2>" ;
    $body .= sprintf( $self->{language}{SingleBucket_Title}, "<font color=\"$self->{classifier}->{colors}{$self->{form}{showbucket}}\">$self->{form}{showbucket}</font>") ;
    $body .= "</h2>\n<p>\n<table>\n<tr>\n<td><b>$self->{language}{SingleBucket_WordCount}</b>\n" ;
    $body .= "<td>&nbsp;\n<td align=\"right\">\n" ;
    $body .= pretty_number( $self, $self->{classifier}->{total}{$self->{form}{showbucket}});
    $body .= "<td>\n(" . sprintf( $self->{language}{SingleBucket_Unique}, pretty_number( $self,  $self->{classifier}->{unique}{$self->{form}{showbucket}}) ). ")";
    $body .= "<tr>\n<td>\n<b>$self->{language}{SingleBucket_TotalWordCount}</b>\n" ;
    $body .= "<td>&nbsp;\n<td align=\"right\">\n" . pretty_number( $self, $self->{classifier}->{full_total});

    my $percent = "0%";
    if ( $self->{classifier}->{full_total} > 0 )  {
        $percent = int( 10000 * $self->{classifier}->{total}{$self->{form}{showbucket}} / $self->{classifier}->{full_total} ) / 100;
        $percent = "$percent%";
    }
    $body .= "<td><tr><td><hr><b>$self->{language}{SingleBucket_Percentage}</b><td><hr>&nbsp;<td align=\"right\"><hr>$percent<td></table>";
 
    $body .= "<h2>" ;
    $body .= sprintf( $self->{language}{SingleBucket_WordTable},  "<font color=\"$self->{classifier}->{colors}{$self->{form}{showbucket}}\">$self->{form}{showbucket}" )  ;
    $body .= "</font>\n</h2>\n<p>\n$self->{language}{SingleBucket_Message1}\n<p>\n<table>\n";
    
    for my $i (@{$self->{classifier}->{matrix}{$self->{form}{showbucket}}}) {
        if ( defined($i) )  {
            my $j = $i;
            $j =~ s/\|\|/, /g;
            $j =~ s/\|//g;
            $j =~ /^(.)/;
            my $first = $1;
            $j =~ s/([^ ]+) (L\-[\.\d]+)/\*$1 $2<\/font>/g;
            $j =~ s/L(\-[\.\d]+)/int( $self->{classifier}->{total}{$self->{form}{showbucket}} * exp($1) + 0.5 )/ge;
            $j =~ s/([^ ,\*]+) ([^ ,\*]+)/<a href=\/buckets\?session=$self->{session_key}\&amp;lookup=Lookup\&amp;word=$1#Lookup>$1<\/a> $2/g;
            $body .= "<tr><td valign=\"top\"><b>$first</b><td valign=\"top\">$j";
        }
    }
    $body .= "</table>";
 
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
        $body .= "<tr>\n<td align=\"left\"><font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font>\n" ;
        $body .= "<td>&nbsp;\n<td align=\"right\">$count ($percent)\n";
    }    

    $body .= "<tr>\n<td colspan=\"3\">&nbsp;\n<tr>\n<td colspan=\"3\">\n";

    if ( $total_count != 0 ) {
        $body .= "<table width=\"100%\">\n<tr>\n";
        foreach my $bucket (@xaxis) {
            my $percent = int( $values{$bucket} * 10000 / $total_count ) / 100; 
            if ( $percent != 0 )  {
                $body .= "<td bgcolor=$self->{classifier}->{colors}{$bucket}>\n" ;
                $body .= "<img src=\"pix.gif\" alt=\"$bucket ($percent%)\" height=\"20\" width=\"";
                $body .= 2 * int($percent);
                $body .= "\">\n</td>\n";
            }
        }
        $body .= "</table>";
    }

    if ( $total_count != 0 )  {
        $body .= "<tr><td colspan=\"3\" align=\"right\"><font size=\"1\">100%</font>";
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
    my $delete_message = '';
    my $rename_message = '';
    
    if ( ( defined($self->{form}{color}) ) && ( defined($self->{form}{bucket}) ) ) {
        open COLOR, ">$self->{configuration}->{configuration}{corpus}/$self->{form}{bucket}/color";
        print COLOR "$self->{form}{color}\n";
        close COLOR;
        $self->{classifier}->{colors}{$self->{form}{bucket}} = $self->{form}{color};
    }

    if ( ( defined($self->{form}{bucket}) ) && ( $self->{form}{subject} > 0 ) ) {
        $self->{classifier}->{parameters}{$self->{form}{bucket}}{subject} = $self->{form}{subject} - 1;
        $self->{classifier}->write_parameters();
    }

    if ( ( defined($self->{form}{bucket}) ) && ( $self->{form}{quarantine} > 0 ) ) {
        $self->{classifier}->{parameters}{$self->{form}{bucket}}{quarantine} = $self->{form}{quarantine} - 1;
        $self->{classifier}->write_parameters();
    }
    
    if ( ( defined($self->{form}{cname}) ) && ( $self->{form}{cname} ne '' ) ) {
        if ( $self->{form}{cname} =~ /[^[:lower:]\-_]/ )  {
            $create_message = "<blockquote><font color=\"red\" size=+1>$self->{language}{Bucket_Error1}</font></blockquote>";
        } else {
            if ( $self->{classifier}->{total}{$self->{form}{cname}} > 0 )  {
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

        $delete_message = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error6}, $self->{form}{name} ) . "</b></blockquote>";
        $self->{classifier}->load_word_matrix();
    }
    
    if ( ( defined($self->{form}{newname}) ) && ( $self->{form}{oname} ne '' ) ) {
        if ( $self->{form}{newname} =~ /[^[:lower:]\-_]/ )  {
            $rename_message = "<blockquote><font color=\"red\" size=+1>$self->{language}{Bucket_Error1}</font></blockquote>";
        } else {
            $self->{form}{oname} = lc($self->{form}{oname});
            $self->{form}{newname} = lc($self->{form}{newname});
            rename("$self->{configuration}->{configuration}{corpus}/$self->{form}{oname}" , "$self->{configuration}->{configuration}{corpus}/$self->{form}{newname}");
            $rename_message = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error5}, $self->{form}{oname}, $self->{form}{newname} ) . "</b></blockquote>";
            $self->{classifier}->load_word_matrix();
        }
    }    
    
    my $body = "<h2>$self->{language}{Bucket_Title}</h2>\n" ;
    $body .= "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">\n<tr>\n" ;
    $body .= "<td><b>$self->{language}{Bucket_BucketName}</b>\n" ;
    $body .= "<td width=\"10\">&nbsp;\n<td align=\"right\">\n<b>$self->{language}{Bucket_WordCount}</b>\n" ;
    $body .= "<td width=\"10\">&nbsp;\n<td align=\"right\">\n<b>$self->{language}{Bucket_UniqueWords}</b>\n" ;
    $body .= "<td width=\"10\">&nbsp;\n<td align=\"center\"><b>$self->{language}{Bucket_SubjectModification}</b>\n" ;
    $body .= "<td width=\"10\">&nbsp;\n<td align=\"center\"><b>$self->{language}{Bucket_Quarantine}</b>\n" ;
    $body .= "<td width=\"20\">&nbsp;\n<td align=\"left\"><b>$self->{language}{Bucket_ChangeColor}</b>\n";

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
        $body .= "<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font></a>\n";
        $body .= "<td width=\"10\">&nbsp;<td align=\"right\">$number<td width=\"10\">&nbsp;\n";
        $body .= "<td align=\"right\">$unique<td width=\"10\">&nbsp;";
        
        if ( $self->{configuration}->{configuration}{subject} == 1 )  {
            $body .= "<td align=\"center\">\n";
            if ( $self->{classifier}->{parameters}{$bucket}{subject} == 0 )  {
                $body .= "$self->{language}{Off}\n" ; 
                $body .= "<a href=\"/buckets?session=$self->{session_key}&amp;bucket=$bucket&amp;subject=2\">\n" ;
                $body .= "[$self->{language}{TurnOn}]</a>\n" ;
            } else {
                $body .= "<b>$self->{language}{On}</b> \n" ;
                $body .= "<a href=\"/buckets?session=$self->{session_key}&amp;bucket=$bucket&amp;subject=1\">\n" ;
                $body .= "[$self->{language}{TurnOff}]</a>\n ";
            }
        } else {
            $body .= "<td align=\"center\">\n$self->{language}{Bucket_DisabledGlobally}\n";
        }

        $body .= "<td width=\"10\">&nbsp;<td align=\"center\">\n";
        if ( $self->{classifier}->{parameters}{$bucket}{quarantine} == 0 )  {
            $body .= "$self->{language}{Off}\n" ; 
            $body .= "<a href=\"/buckets?session=$self->{session_key}&amp;bucket=$bucket&amp;quarantine=2\">\n" ;
            $body .= "[$self->{language}{TurnOn}]</a>\n" ;
        } else {
            $body .= "<b>$self->{language}{On}</b> \n" ;
            $body .= "<a href=\"/buckets?session=$self->{session_key}&amp;bucket=$bucket&amp;quarantine=1\">\n" ;
            $body .= "[$self->{language}{TurnOff}]</a>\n ";
        }
        $body .= "<td>&nbsp;\n<td align=\"left\">\n<table cellpadding=\"0\" cellspacing=\"1\">\n<tr>\n";
        my $color = $self->{classifier}->{colors}{$bucket};
        $body .= "<td width=\"10\" bgcolor=\"$color\">\n<img border=\"0\" alt='" . sprintf( $self->{language}{Bucket_CurrentColor}, $bucket, $color ) . "' src=\"pix.gif\" width=\"10\" height=\"20\">\n<td>&nbsp;\n";
        for my $i ( 0 .. $#{$self->{classifier}->{possible_colors}} ) {
            my $color = $self->{classifier}->{possible_colors}[$i];
            if ( $color ne $self->{classifier}->{colors}{$bucket} )  {
                $body .= "<td width=\"10\" bgcolor=\"$color\">\n" ;
                $body .= "<a href=\"/buckets?color=$color&amp;bucket=$bucket&amp;session=$self->{session_key}\">\n" ;
                $body .= "<img border=\"0\" alt='". sprintf( $self->{language}{Bucket_SetColorTo}, $bucket, $color ) . "' src=\"pix.gif\" width=\"10\" height=\"20\"></a>\n";
            } 
        }
        $body .= "</table>\n";
    }

    my $number = pretty_number( $self,  $self->{classifier}->{full_total} );
    my $pmcount = pretty_number( $self,  $self->{configuration}->{configuration}{mcount} );
    my $pecount = pretty_number( $self,  $self->{configuration}->{configuration}{ecount} );
    my $accuracy = $self->{language}{Bucket_NotEnoughData};
    my $percent = 0;
    if ( $self->{configuration}->{configuration}{mcount} > 0 )  {
        $percent = int( 10000 * ( $self->{configuration}->{configuration}{mcount} - $self->{configuration}->{configuration}{ecount} ) / $self->{configuration}->{configuration}{mcount} ) / 100;
        $accuracy = "$percent%";
    } 

    $body .= "<tr>\n<td><hr><b>$self->{language}{Total}</b>\n<td width=\"10\"><hr>&nbsp;" ;
    $body .= "<td align=\"right\"><hr><b>$number</b>\n<td>\n<td>\n</table>\n<p>\n" ;

    # middle panel group
    $body .= "<table class=\"stabColor01\" width=\"100%\" cellpadding=\"10\" cellspacing=\"0\" >\n" ;

    # Classification Accuracy panel
    $body .= "<tr>\n<td class=\"stabColor01\" valign=\"top\" width=\"33%\" align=\"center\">\n" ;
    $body .= "<h2>$self->{language}{Bucket_ClassificationAccuracy}</h2>\n" ;
    $body .= "<table cellspacing=\"0\" cellpadding=\"0\">\n" ;
    # emails classified line
    $body .= "<tr>\n<td align=\"left\">$self->{language}{Bucket_EmailsClassified}:\n" ;
    $body .= "<td align=\"right\">$pmcount\n" ;
    # classification errors line
    $body .= "<tr>\n<td align=\"left\">\n$self->{language}{Bucket_ClassificationErrors}:\n" ;
    $body .= "<td align=\"right\">$pecount\n</td></tr>" ;
    # rules
    
    
    # $body .= "<tr>\n<td colspan=\"2\"><hr></td></tr>\n" ;
    $body .= "<tr>\n<td align=\"left\"><hr>" ;
    $body .= "$self->{language}{Bucket_Accuracy}:<td align=\"right\"><hr>$accuracy";
    
    if ( $percent > 0 )  {
        $body .= "<tr ><td height=\"10\" colspan=\"2\">&nbsp;<tr><td colspan=\"2\">\n" ;
        $body .= "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">\n";
        $body .= "<tr>";  #height=\"5\"

        for my $i ( 0..49 ) {
            $body .= "<td valign=\"middle\" height=\"10\" width=\"6\" bgcolor=";
            $body .= "red" if ( $i < 25 );
            $body .= "yellow" if ( ( $i > 24 ) && ( $i < 47 ) );
            $body .= "green" if ( $i > 46 );
            $body .= ">";
            if ( ( $i * 2 ) < $percent ) {
                $body .= " <img src=\"black.gif\" height=\"4\" width=\"6\" alt=\"\">";
            } else {
                $body .= " <img src=\"pix.gif\" height=\"4\" width=\"6\" alt=\"\">";
            }
            $body .= "</td>";
        }
        $body .= "</tr><tr><td colspan=\"25\" align=\"left\"><font size=\"1\">0%</font><td colspan=\"25\" align=\"right\"><font size=\"1\">100%</font></table>";
    }
    
    
    $body .= "</table>\n<form action=\"/buckets\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"reset_stats\" value=\"$self->{language}{Bucket_ResetStatistics}\">\n";
    
    if ( $self->{configuration}->{configuration}{last_reset} ne '' ) {
        $body .= "<br>\n($self->{language}{Bucket_LastReset}: $self->{configuration}->{configuration}{last_reset})\n";
    }
    
    # Emails Classified panel
    $body .= "</form>\n<td class=\"stabColor01\" valign=\"top\" width=\"33%\" align=\"center\">\n" ;
    $body .= "<h2>$self->{language}{Bucket_EmailsClassifiedUpper}</h2>\n<p>\n" ;
    $body .= "<table>\n<tr>\n<td align=\"left\"><b>$self->{language}{Bucket}</b>\n" ;
    $body .= "<td>&nbsp;\n<td><b>$self->{language}{Bucket_ClassificationCount}</b>\n";

    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $self->{classifier}->{parameters}{$bucket}{count};
    }

    $body .= bar_chart_100( $self, %bar_values );
    
    # Word Counts panel
    $body .= "</table>\n<td class=\"stabColor01\" width=\"34%\" valign=\"top\" align=\"center\">\n" ;
    $body .= "<h2>$self->{language}{Bucket_WordCounts}</h2>\n<p>\n<table>\n<tr>\n" ;
    $body .= "<td align=\"left\">\n<b>$self->{language}{Bucket}</b>\n" ;
    $body .= "<td>&nbsp;\n<td align=\"right\">\n<b>$self->{language}{Bucket_WordCount}</b>\n";

    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $self->{classifier}->{total}{$bucket};
    }

    $body .= bar_chart_100( $self, %bar_values );
   
    $body .= "</table>\n</table>\n<p>\n" ;
    
    # bottom panel group
    $body .= "<table class=\"stabColor01\" width=\"100%\" cellpadding=\"10\" cellspacing=\"0\" >\n" ;
    
    # Maintenance panel
    $body .= "<tr>\n<td class=\"stabColor01\"valign=\"top\" width=\"50%\">\n" ;
    $body .= "<h2>$self->{language}{Bucket_Maintenance}</h2>\n" ;
    $body .= "<p>\n<form action=\"/buckets\">\n" ;
    $body .= "<b>$self->{language}{Bucket_CreateBucket}:</b><br>\n" ;
    $body .= "<input name=\"cname\" type=\"text\">\n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"create\" value=\"$self->{language}{Create}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
    $body .= "</form>\n$create_message\n<p>\n";
    $body .= "<form action=\"/buckets\">\n<b>$self->{language}{Bucket_DeleteBucket}:</b> <br>\n" ;
    $body .= "<select name=\"name\"><option value=\"\">\n</option>\n";

    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>";
    }
    $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"delete\" value=\"$self->{language}{Delete}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n$delete_message\n";

    $body .= "<p>\n<form action=\"/buckets\">\n" ;
    $body .= "<b>$self->{language}{Bucket_RenameBucket}:</b> <br>\n" ;
    $body .= "<select name=\"oname\">\n<option value=\"\">\n</option>\n";
    
    foreach my $bucket (@buckets) {
        $body .= "<option value=\"$bucket\">$bucket</option>\n";
    }
    $body .= "</select>\n<b>$self->{language}{Bucket_To}</b>\n" ;
    $body .= "<input type=\"text\" name=\"newname\"> \n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"rename\" value=\"$self->{language}{Rename}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
    $body .= "</form>\n$rename_message\n";

    # Lookup panel
    $body .= "<td class=\"stabColor01\" valign=\"top\" width=\"50%\">\n<a name=\"Lookup\"></a>\n" ;
    $body .= "<h2>$self->{language}{Bucket_Lookup}</h2>\n" ;
    $body .= "<form action=\"/buckets#Lookup\">\n" ;
    $body .= "<p><b>$self->{language}{Bucket_LookupMessage}: </b><br>\n" ;
    $body .= "<input name=\"word\" type=\"text\"> \n" ;
    $body .= "<input type=\"submit\" class=\"submit\" name=\"lookup\" value=\"$self->{language}{Lookup}\">\n" ;
    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n</form>\n";

    if ( ( defined($self->{form}{lookup}) ) || ( defined($self->{form}{word}) ) ) {
       my $word = $self->{classifier}->{mangler}->mangle($self->{form}{word});

        $body .= "<blockquote>";

        # Don't print the headings if there are no entries.

        my $heading = "<table class=\"stabColor03\" cellpadding=\"6\" cellspacing=\"0\" >\n" ;
        $heading .= "<tr><td><b>$self->{language}{Bucket_LookupMessage2}  $self->{form}{word}</b>" ;
        $heading .= "<p><table><tr><td><b>$self->{language}{Bucket}</b><td>&nbsp;" ;
        $heading .= "<td><b>$self->{language}{Frequency}</b><td>&nbsp;" ;
        $heading .= "<td><b>$self->{language}{Probability}</b><td>&nbsp;" ;
        $heading .= "<td><b>$self->{language}{Score}</b>";

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
                    $body .= "<tr><td>$bold<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font>\n" ;
                    $body .= "$endbold<td>\n<td>$bold<tt>$probf</tt>$endbold\n<td>\n" ;
                    $body .= "<td>$bold<tt>$normal</tt>$endbold<td>\n<td>$bold<tt>$score</tt>$endbold \n";
                }
            }

            if ( $max_bucket ne '' ) {
                $body .= "</table><p>" . sprintf( $self->{language}{Bucket_LookupMostLikely}, $self->{form}{word}, $self->{classifier}->{colors}{$max_bucket}, $max_bucket) . "</table>";
            } else {
                $body .= sprintf( $self->{language}{Bucket_DoesNotAppear}, $self->{form}{word} );
            }
        } else {
            $body .= "<font color=\"red\" size=+1>$self->{language}{Bucket_Error4}</font>";
        }

        $body .= "</blockquote>";
    }
    
    $body .= "</table>";

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
# load_history_cache
#
# Reloads the history cache filtering based on the passed in filter
#
# $filter       Name of bucket to filter on
# $search       From/Subject line to search for
# $sort         The field to sort on (from, subject, bucket)
#
# ---------------------------------------------------------------------------------------------
sub load_history_cache 
{
    my ( $self, $filter, $search, $sort ) = @_;

    $sort = '' if ( !defined( $sort ) );
    
    my @history_files = sort compare_mf glob "$self->{configuration}->{configuration}{msgdir}popfile*=*.msg";
    $self->{history}         = {};
    $self->{history_invalid} = 0;
    my $j = 0;

    foreach my $i ( 0 .. $#history_files ) {
        $history_files[$i] =~ /(popfile.*\.msg)/;
        $history_files[$i] = $1;
        my $class_file = $history_files[$i];
        my $magnet     = '';
        $class_file =~ s/msg$/cls/;
        
        my $bucket;
        my $reclassified;
        
        # Something may have happened to the class file, this avoids errors

        if ( open CLASS, "<$self->{configuration}->{configuration}{msgdir}$class_file" ) {
            $bucket = <CLASS>;
            if ( $bucket =~ /([^ ]+) MAGNET (.+)/ ) {
                $bucket = $1;
                $magnet = $2;
            } else {
                $magnet = '';
            }
        
            $reclassified = 0;
            if ( $bucket =~ /RECLASSIFIED/ ) {
                $bucket       = <CLASS>;
                $reclassified = 1;
            }
            close CLASS;
            $bucket =~ s/[\r\n]//g;
        } else {

            # This means the CLASS file failed to open -- we don't know what to do with this file
            # Give it the "classfileerror" bucket for now
            
            $bucket = "classfileerror";
        }
        
        if ( ( $filter eq '' ) || ( $bucket eq $filter ) || ( ( $filter eq '__filter__magnet' ) && ( $magnet ne '' ) ) ) {
            my $found   = 1;
            my $from    = '';
            my $subject = '';
            
            if ( ( $search ne '' ) || ( $sort ne '' ) ) {
                $found = ( $search eq '' );
                
                open MAIL, "<$self->{configuration}->{configuration}{msgdir}$history_files[$i]";
                while (<MAIL>)  {
                    if ( /[A-Z0-9]/i )  {
                        if ( /^From:(.*)/i ) {
                            $from = $1;
                            if ( ( $search ne '' ) && ( $from =~ /\Q$search\E/i ) ) {
                                $found = 1;
                                last;
                            }
                        }
                        if ( /^Subject:(.*)/i ) {
                            $subject = $1;
                            if ( ( $search ne '' ) && ( $subject =~ /\Q$search\E/i ) ) {
                                $found = 1;
                                last;
                            }
                        }
                    } else {
                        last;
                    }
                }
                close MAIL;
            }
            
            if ( $found == 1 ) {
                $self->{history}{$j}{file}         = $history_files[$i];
                $self->{history}{$j}{bucket}       = $bucket;
                $self->{history}{$j}{reclassified} = $reclassified;
                $self->{history}{$j}{magnet}       = $magnet;
                $self->{history}{$j}{subject}      = $subject;
                $self->{history}{$j}{from}         = $from;

                $j += 1;
            }
        }
    }
    
    if ( $sort ne '' ) {
        @{$self->{history_keys}} = sort { my ($a1,$b1) = ($self->{history}{$a}{$sort}, $self->{history}{$b}{$sort}); $a1 =~ s/[^A-Z]//ig; $b1 =~ s/[^A-Z]//ig; return ( $a1 cmp $b1 ); } keys %{$self->{history}};
    } else {
        @{$self->{history_keys}} = sort { $a <=> $b } keys %{$self->{history}};
    }
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
    
    return ( history_size( $self ) == 0 );
}

# ---------------------------------------------------------------------------------------------
#
# history_size
#
# Returns the size of the history cache
#
# ---------------------------------------------------------------------------------------------
sub history_size
{
    my ( $self ) = @_;

    my @cache = keys %{$self->{history}};
    
    return ($#cache + 1);
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
        $body .= "<a href=\"/history?start_message=";
        $body .= $start_message - $self->{configuration}->{configuration}{page_size};
        $body .= "&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}\">< $self->{language}{Previous}</a> ";
    }
    my $i = 0;
    while ( $i < history_size( $self ) ) {
        if ( $i == $start_message )  {
            $body .= "<b>";
            $body .= $i+1 . "</b>";
        } else {
            $body .= "<a href=\"/history?start_message=$i&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}\">";
            $body .= $i+1 . "</a>";
        }

        $body .= " ";
        $i += $self->{configuration}->{configuration}{page_size};
    }
    if ( $start_message < ( history_size( $self ) - $self->{configuration}->{configuration}{page_size} ) )  {
        $body .= "<a href=\"/history?start_message=";
        $body .= $start_message + $self->{configuration}->{configuration}{page_size};
        $body .= "&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}\">$self->{language}{Next} ></a>";
    }
    
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

    if ( !defined($self->{form}{sort}) ) {
        $self->{form}{sort} = ''; 
    }
    
    my $filtered = '';    
    if ( !defined($self->{form}{filter}) || ( $self->{form}{filter} eq '__filter__all' ) )  {
        $self->{form}{filter} = '';
    } else {
        if ( $self->{form}{filter} eq '__filter__magnet' ) {
            $filtered .= $self->{language}{History_Magnet};
        } else {
            $filtered = sprintf( $self->{language}{History_Filter}, $self->{classifier}->{colors}{$self->{form}{filter}}, $self->{form}{filter} ) if ( $self->{form}{filter} ne '' );
        }
    }

    $filtered .= sprintf( $self->{language}{History_Search}, $self->{form}{search} ) if ( defined($self->{form}{search}) );

    my $body = ''; 

    # Handle undo
    if ( defined($self->{form}{undo}) ) {
        my %temp_words;
        
        open WORDS, "<$self->{configuration}->{configuration}{corpus}/$self->{form}{badbucket}/table";
        while (<WORDS>) {
            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                if ( $1 != 1 )  {
                    print "Incompatible corpus version in $self->{form}{badbucket}\n";
                    return;
                }
                
                next;
            }
            
            $temp_words{$1} = $2 if ( /(.+) (.+)/ );
        }
        close WORDS;

        $self->{classifier}->{parser}->parse_stream("$self->{configuration}->{configuration}{msgdir}$self->{form}{undo}");

        foreach my $word (keys %{$self->{classifier}->{parser}->{words}}) {
            $self->{classifier}->{full_total} -= $self->{classifier}->{parser}->{words}{$word};
            $temp_words{$word}                -= $self->{classifier}->{parser}->{words}{$word};
            
            delete $temp_words{$word} if ( $temp_words{$word} <= 0 );
        }
        
        open WORDS, ">$self->{configuration}->{configuration}{corpus}/$self->{form}{badbucket}/table";
        print WORDS "__CORPUS__ __VERSION__ 1\n";
        foreach my $word (keys %temp_words) {
            print WORDS "$word $temp_words{$word}\n" if ( $temp_words{$word} > 0 );
        }
        close WORDS;
        
        $self->{classifier}->load_bucket("$self->{configuration}->{configuration}{corpus}/$self->{form}{badbucket}");
        $self->{classifier}->update_constants();
        
        my $class_file = "$self->{configuration}->{configuration}{msgdir}$self->{form}{undo}";
        $class_file =~ s/msg$/cls/;
        
        # The bucket the message was reclassified to

        my $usedtobe;

        # The bucket the message was classified from

        my $classification;
        
        # Load the class file to compare the old classification

        open CLASS, "<$class_file";        

        my $bucket = <CLASS>;
        if ( ( defined( $bucket ) ) && ( $bucket =~ /RECLASSIFIED/ ) ) {
            $bucket   = <CLASS>;
            $usedtobe = <CLASS>;
            $bucket   =~ s/[\r\n]//g; 
            $usedtobe =~ s/[\r\n]//g; 
        }
        close CLASS;
        
        $classification = $usedtobe;

        if ( $bucket ne $usedtobe ) {
            $self->{configuration}->{configuration}{ecount} -= 1 if ( $self->{configuration}->{configuration}{ecount} > 0 );
            $self->{classifier}->{parameters}{$bucket}{count}   -= 1;
            $self->{classifier}->{parameters}{$usedtobe}{count} += 1;
            $self->{classifier}->write_parameters();
        }
          
        open CLASS, ">$class_file";
        print CLASS "$classification$eol";
        close CLASS;
        
        $self->{history_invalid} = 1;
        http_redirect( $self, $client,"/history?session=$self->{session_key}&sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}#$self->{form}{undo}");
        return;
    }

    if ( defined($self->{form}{remove}) ) {
        my $mail_file = $self->{form}{remove};
        my $class_file = $mail_file;
        $class_file =~ s/msg$/cls/;
        unlink("$self->{configuration}->{configuration}{msgdir}$mail_file");
        unlink("$self->{configuration}->{configuration}{msgdir}$class_file");
        $self->{history_invalid} = 1;        
        http_redirect( $self, $client,"/history?session=$self->{session_key}&sort=$self->{form}{sort}&filter=$self->{form}{filter}");
        return;
    }
    
    # Handle clearing the history files

    if ( defined($self->{form}{clearall}) ) {

        # If the history cache is empty then we need to reload it now

        load_history_cache( $self, $self->{form}{filter}, '', $self->{form}{sort}) if ( history_cache_empty( $self ) );

        foreach my $i (0..history_size($self)-1) {
            my $mail_file = $self->{history}{$self->{history_keys}[$i]}{file};
            my $class_file = $mail_file;
            $class_file =~ s/msg$/cls/;
            unlink("$self->{configuration}->{configuration}{msgdir}$mail_file");
            unlink("$self->{configuration}->{configuration}{msgdir}$class_file");
        }

        $self->{history_invalid} = 1;        
        http_redirect( $self, $client,"/history?session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}");
        return;
    }

    if ( defined($self->{form}{clearpage}) ) {

        # If the history cache is empty then we need to reload it now

        load_history_cache( $self, $self->{form}{filter}, '', $self->{form}{sort}) if ( history_cache_empty( $self ) );
        
        foreach my $i ( $self->{form}{start_message} .. $self->{form}{start_message} + $self->{configuration}->{configuration}{page_size} - 1 ) {
            $i = $self->{history_keys}[$i];
            if ( $i <= history_size( $self ) )  {
                my $class_file = $self->{history}{$i}{file};
                $class_file =~ s/msg$/cls/;
                if ( $class_file ne '' )  {
                    unlink("$self->{configuration}->{configuration}{msgdir}$self->{history}{$i}{file}");
                    unlink("$self->{configuration}->{configuration}{msgdir}$class_file");
                }
            }
        }

        $self->{history_invalid} = 1;        
        http_redirect( $self, $client,"/history?session=$self->{session_key}&sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}&start_message=$self->{form}{start_message}");
        return;
    }

    # If we just changed the number of mail files on the disk (deleted some or added some)
    # or the history is empty then reload the history

    if ( defined( $self->{form}{setsort} ) ) {
        $self->{form}{sort} = $self->{form}{setsort}; 
    }

    load_history_cache( $self, $self->{form}{filter}, '', $self->{form}{sort}) if ( ( remove_mail_files( $self ) ) || ( $self->{history_invalid} == 1 ) || ( history_cache_empty( $self ) ) || ( defined($self->{form}{setfilter}) ) || ( defined($self->{form}{setsort}) ) );

    # Handle the reinsertion of a message file

    if ( ( defined($self->{form}{shouldbe} ) ) && ( $self->{form}{shouldbe} ne '' ) ) {
        my %temp_words;
        
        open WORDS, "<$self->{configuration}->{configuration}{corpus}/$self->{form}{shouldbe}/table";
        while (<WORDS>) {
            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                if ( $1 != 1 )  {
                    print "Incompatible corpus version in $self->{form}{shouldbe}\n";
                    return;
                }
                
                next;
            }
            
            $temp_words{$1} = $2 if ( /(.+) (.+)/ );
        }
        close WORDS;

        $self->{classifier}->{parser}->parse_stream("$self->{configuration}->{configuration}{msgdir}$self->{form}{file}");

        foreach my $word (keys %{$self->{classifier}->{parser}->{words}}) {
            $self->{classifier}->{full_total} += $self->{classifier}->{parser}->{words}{$word};
            $temp_words{$word}                += $self->{classifier}->{parser}->{words}{$word};
        }
        
        open WORDS, ">$self->{configuration}->{configuration}{corpus}/$self->{form}{shouldbe}/table";
        print WORDS "__CORPUS__ __VERSION__ 1\n";
        foreach my $word (keys %temp_words) {
           print WORDS "$word $temp_words{$word}\n" if ( $temp_words{$word} > 0 );
        }
        close WORDS;
        
        my $class_file = "$self->{configuration}->{configuration}{msgdir}$self->{form}{file}";
        $class_file =~ s/msg$/cls/;
        open CLASS, ">$class_file";
        print CLASS "RECLASSIFIED$eol$self->{form}{shouldbe}$eol$self->{form}{usedtobe}$eol";
        close CLASS;
        
        $self->{configuration}->{configuration}{ecount} += 1 if ( $self->{form}{shouldbe} ne $self->{form}{usedtobe} );
        $self->{classifier}->{parameters}{$self->{form}{shouldbe}}{count} += 1; 
        $self->{classifier}->{parameters}{$self->{form}{usedtobe}}{count} -= 1; 
        $self->{classifier}->write_parameters();

        $self->{classifier}->load_bucket("$self->{configuration}->{configuration}{corpus}/$self->{form}{shouldbe}");
        $self->{classifier}->update_constants();    
        load_history_cache( $self, $self->{form}{filter},'',$self->{form}{sort});
        
        http_redirect( $self, $client,"/history?session=$self->{session_key}&sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}#$self->{form}{file}");
        return;
    }

    my $highlight_message = '';

    load_history_cache( $self, $self->{form}{filter}, $self->{form}{search}, $self->{form}{sort}) if ( ( defined($self->{form}{search}) ) && ( $self->{form}{search} ne '' ) );
    
    if ( !history_cache_empty( $self ) )  {
        my $start_message = 0;
        $start_message = $self->{form}{start_message} if ( ( defined($self->{form}{start_message}) ) && ($self->{form}{start_message} > 0 ) );
        my $stop_message  = $start_message + $self->{configuration}->{configuration}{page_size} - 1;

        # Verify that a message we are being asked to view (perhaps from a /jump_to_message URL) is actually between
        # the $start_message and $stop_message, if it is not then move to that message

        if ( defined($self->{form}{view}) ) {
            my $found = 0;
            foreach my $i ($start_message ..  $stop_message) {
                $i = $self->{history_keys}[$i];
                if ( $self->{form}{view} eq $self->{history}{$i}{file} )  {
                    $found = 1;
                    last;
                }
            }
            
            if ( $found == 0 ) {
                foreach my $i ( 0 .. history_size( $self ) )  {
                    $i = $self->{history_keys}[$i];
                    if ( $self->{form}{view} eq $self->{history}{$i}{file} ) {
                        $start_message = $i;
                        $stop_message  = $i + $self->{configuration}->{configuration}{page_size} - 1;
                        last;
                    }
                }
            }
        }
        
        $stop_message = history_size( $self ) - 1 if ( $stop_message >= history_size( $self ) );

        if ( $self->{configuration}->{configuration}{page_size} <= history_size( $self ) ) {
            $body .= "<table width=\"100%\">\n<tr>\n<td align=\"left\">\n" ;
            $body .= "<h2>$self->{language}{History_Title}$filtered</h2>\n<td align=\"right\">\n"; 
            $body .= get_history_navigator( $self, $start_message, $stop_message );
            $body .= "</table>";
        } else {
            $body .="<h2>$self->{language}{History_Title}$filtered</h2>\n"; 
        }
        
        $body .= "<table width=\"100%\">\n";
        
        $body .= "<tr valign=\"bottom\"><td></td><td colspan=\"2\"><form action=\"/history\">";
		$body .= "<input type=hidden name=filter value=\"$self->{form}{filter}\">";
		$body .= "<input type=hidden name=sort value=\"$self->{form}{sort}\">";
		$body .= "<input type=hidden name=session value=\"$self->{session_key}\">";
		$body .= "<b>$self->{language}{History_SearchMessage}:&nbsp;</b>";
		$body .= "<input type=\"text\" name=\"search\"> ";
        $body .= "<input type=submit class=submit name=searchbutton value=\"$self->{language}{Find}\"></form>\n
        </td><td colspan=\"3\">\n<form action=\"/history\">\n" ;
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">\n" ;
        $body .= "<select name=\"filter\"><option value=\"__filter__all\">&lt;$self->{language}{History_ShowAll}&gt;</option>\n";
        
        my @buckets = sort keys %{$self->{classifier}->{total}};
        foreach my $abucket (@buckets) {
            $body .= "<option value=\"$abucket\"";
            $body .= " selected" if ( ( defined($self->{form}{filter}) ) && ( $self->{form}{filter} eq $abucket ) );
            $body .= ">$abucket</option>";
        }
        $body .= "<option value=\"__filter__magnet\">&lt;$self->{language}{History_ShowMagnet}&gt;</option>\n" ;
        $body .= "</select>\n<input type=\"submit\" class=\"submit\" name=\"setfilter\" value=\"$self->{language}{Filter}\">\n" ;
        $body .= "</form>";
        
        $body .= "<tr valign=\"bottom\"><td><a href=/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=>";
        if ( $self->{form}{sort} eq '' ) {
            $body .= "<b>ID</b>";
        } else {
            $body .= "ID";
        }
        $body .= "</a></td>\n" ;
        $body .= "<td>\n<a href=/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=from>";
        
        if ( $self->{form}{sort} eq 'from' ) {
            $body .= "<b>$self->{language}{From}</b>";
        } else {
            $body .= "$self->{language}{From}";
        }
        
        $body .="</a>\n<td>\n<a href=/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=subject>";
        
        if ( $self->{form}{sort} eq 'subject' ) {
            $body .= "<b>$self->{language}{Subject}</b>";
        } else {
            $body .= "$self->{language}{Subject}";
        }
        
        $body .= "</a>\n<td>\n<a href=/history?session=$self->{session_key}&amp;filter=$self->{form}{filter}&amp;setsort=bucket>";
        
        if ( $self->{form}{sort} eq 'bucket' ) {
            $body .= "<b>$self->{language}{Classification}</b>";
        } else {
            $body .= "$self->{language}{Classification}";
        }

        $body .= "</b></a>\n<td>\n<b>$self->{language}{History_ShouldBe}</b>\n<td><b>$self->{language}{Remove}</b>" ;

        my $stripe = 0;

        foreach my $i ($start_message ..  $stop_message) {
            $i = $self->{history_keys}[$i];
            my $mail_file;
            my $from          = '';
            my $short_from    = '';
            my $subject       = '';
            my $short_subject = '';
            $mail_file = $self->{history}{$i}{file};

            if ( ( $self->{history}{$i}{subject} eq '' ) || ( $self->{history}{$i}{from} eq '' ) )  {
                open MAIL, "<$self->{configuration}->{configuration}{msgdir}$mail_file";
                while (<MAIL>)  {
                    if ( /[A-Z0-9]/i )  {
                        if ( /^From:(.*)/i ) {
                            if ( $from eq '' )  {
                                $from = $1;
                            }
                        }
                        if ( /^Subject:(.*)/i ) {
                            if ( $subject eq '' )  {
                                $subject = $1;
                            }
                        }
                    } else {
                        last;
                    }
                    
                    last if (( $from ne '' ) && ( $subject ne '' ) );
                }
                close MAIL;

                $self->{history}{$i}{from}          = $from;
                $self->{history}{$i}{subject}       = $subject;
                $self->{history}{$i}{short_from} = $short_from;
                $self->{history}{$i}{short_subject} = $short_subject;
            } else {
                $from          = $self->{history}{$i}{from};
                $subject       = $self->{history}{$i}{subject}; 
                $short_from    = $self->{history}{$i}{short_from}; 
                $short_subject = $self->{history}{$i}{short_subject}; 
            }

            $from    = "&lt;$self->{language}{History_NoFrom}&gt;" if ( $from eq '' );
            $subject = "&lt;$self->{language}{History_NoSubject}&gt;" if ( !( $subject =~ /[^ \t\r\n]/ ) );

            $from =~ s/\"(.*)\"/$1/g;
            $subject =~ s/\"(.*)\"/$1/g;

            $short_from    = $from;
            $short_subject = $subject;

            if ( length($short_from)>40 )  {
                $short_from =~ /(.{40})/;
                $short_from = "$1...";
            }

            if ( length($short_subject)>40 )  {
                $short_subject =~ s/=20/ /g;
                $short_subject =~ /(.{40})/;
                $short_subject = "$1...";
            }

            $from =~ s/</&lt;/g;
            $from =~ s/>/&gt;/g;

            $short_from =~ s/</&lt;/g;
            $short_from =~ s/>/&gt;/g;

            $subject =~ s/</&lt;/g;
            $subject =~ s/>/&gt;/g;

            $short_subject =~ s/</&lt;/g;
            $short_subject =~ s/>/&gt;/g;
            
            # If the user has more than 4 buckets then we'll present a drop down list of buckets, otherwise we present simple
            # links

            my $drop_down = ( $#buckets > 4 );

            $body .= "<form action=\"/history\">\n<input type=\"hidden\" name=\"filter\" value=\"$self->{form}{filter}\">" if ( $drop_down );
            $body .= "<tr";
            if ( ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) || ( ( defined($self->{form}{file}) && ( $self->{form}{file} eq $mail_file ) ) ) || ( $highlight_message eq $mail_file ) ) {
                $body .= " bgcolor=$highlight_color";
            } else {
                $body .= " class="; 
                $body .= $stripe?"rowEven":"rowOdd"; 
            }

            $stripe = 1 - $stripe;

            $body .= "><td>";
            $body .= "<a name=\"$mail_file\"></a>";
            $body .= $i+1 . "<td>";
            my $bucket       = $self->{history}{$i}{bucket};
            my $reclassified = $self->{history}{$i}{reclassified}; 
            $mail_file =~ /popfile\d+=(\d+)\.msg/;
            $body .= "<a title=\"$from\">$short_from</a>";
            $body .= "<td>\n<a title=\"$subject\" href=\"/history?view=$mail_file&amp;start_message=$start_message&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}#$mail_file\">\n" ;
            $body .= "$short_subject</a><td>";
            if ( $reclassified )  {
                $body .= "<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font><td>" . sprintf( $self->{language}{History_Already}, $self->{classifier}->{colors}{$bucket}, $bucket ) . " - <a href=\"/history?undo=$mail_file&amp;session=$self->{session_key}&amp;badbucket=$bucket&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}&amp;start_message=$start_message#$mail_file\">[$self->{language}{Undo}]</a>";
            } else {
                if ( $bucket eq 'unclassified' || !defined $self->{classifier}->{colors}{$bucket})  {
                    $body .= "$bucket<td>";
                } else {
                    $body .= "<font color=\"$self->{classifier}->{colors}{$bucket}\">$bucket</font><td>";
                }

                if ( $self->{history}{$i}{magnet} eq '' )  {
                    if ( $drop_down ) {
                        $body .= " <input type=submit class=submit name=change value=\"$self->{language}{Reclassify}\">\n" ;
                        $body .= "<input type=hidden name=usedtobe value=\"$bucket\"><select name=shouldbe>\n";
                    } else {
                        $body .= "$self->{language}{History_ClassifyAs}: ";
                    }

                    foreach my $abucket (@buckets) {
                        if ( $drop_down )  {
                            $body .= "<option value=\"$abucket\"";
                            $body .= " selected" if ( $abucket eq $bucket );
                            $body .= ">$abucket</option>"
                        } else {
                            $body .= "<a href=\"/history?shouldbe=$abucket&amp;file=$mail_file&amp;start_message=$start_message&amp;session=$self->{session_key}&amp;usedtobe=$bucket&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}#$mail_file\">\n" ;
                            $body .= "<font color=$self->{classifier}->{colors}{$abucket}>[$abucket]</font></a> ";
                        }
                    }

                    $body .= "<input type=\"hidden\" name=\"file\" value=\"$mail_file\">\n" ;
                    $body .= "<input type=\"hidden\" name=\"start_message\" value=\"$start_message\">\n" ;
                    $body .= "<input type=\"hidden\" name=\"session\" value=\"$self->{session_key}\">" if ( $drop_down );
                } else {
                    $body .= " ($self->{language}{History_MagnetUsed}: $self->{history}{$i}{magnet})";
                }
            }

            $body .= "</td><td><a href=/history?session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}&amp;start_message=$start_message&amp;remove=$mail_file&amp;start_message=$start_message>[$self->{language}{Remove}]</a></td>";
            $body .= "</form>" if ( $drop_down );

            # Check to see if we want to view a message
            if ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) {
                $body .= "<tr>\n<td>\n<td colspan=\"3\">\n" ;
                $body .= "<table class=\"stabColor03\" cellpadding=\"6\" cellspacing=\"0\">\n" ;
                $body .= "<tr>\n<td>\n<p align=\"right\">\n" ;
                $body .= "<a href=\"/history?start_message=$start_message&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}\">\n" ;
                $body .= "<b>$self->{language}{Close}</b></a>\n<p>\n";
                
                if ( $self->{history}{$i}{magnet} eq '' )  {
                    $self->{classifier}->{parser}->{color} = 1;
                    $self->{classifier}->{parser}->{bayes} = $self->{classifier};
                    $body .= $self->{classifier}->{parser}->parse_stream("$self->{configuration}->{configuration}{msgdir}$self->{form}{view}");
                    $self->{classifier}->{parser}->{color} = 0;
                } else {
                    $self->{history}{$i}{magnet} =~ /(.+): ([^\r\n]+)/;
                    my $header = $1;
                    my $text   = $2;
                    $body .= "<tt>";

                    open MESSAGE, "<$self->{configuration}->{configuration}{msgdir}$self->{form}{view}";
                    my $line;
                    while ($line = <MESSAGE>) {
                        $line =~ s/</&lt;/g;
                        $line =~ s/>/&gt;/g;
                        
                        $line =~ s/([^\r\n]{100,150} )/$1<br>/g;
                        $line =~ s/([^ \r\n]{150})/$1<br>/g;
                        $line =~ s/[\r\n]+/<br>/g;
                        
                        if ( $line =~ /^([A-Za-z-]+): ?([^\n\r]*)/ ) {
                            my $head = $1;
                            my $arg  = $2;
                            
                            if ( $head =~ /$header/i )  {
                                if ( $arg =~ /$text/i )  {
                                    $line =~ s/($text)/<b><font color=\"$self->{classifier}->{colors}{$self->{history}{$i}{bucket}}\">$1<\/font><\/b>/;
                                }
                            }
                        }
                        
                        $body .= $line;
                    }
                    close MESSAGE;
                    $body .= "</tt>";
                }
                $body .= "<p align=right><a href=\"/history?start_message=$start_message&amp;session=$self->{session_key}&amp;sort=$self->{form}{sort}&amp;filter=$self->{form}{filter}\"><b>$self->{language}{Close}</b></a></table><td valign=top>";
                $self->{classifier}->classify_file("$self->{configuration}->{configuration}{msgdir}$self->{form}{view}");
                $body .= $self->{classifier}->{scores};
            }

            $body .= "<tr bgcolor=$highlight_color><td><td>" . sprintf( $self->{language}{History_ChangedTo}, $self->{classifier}->{colors}{$self->{form}{shouldbe}}, $self->{form}{shouldbe} ) if ( ( defined($self->{form}{file}) ) && ( $self->{form}{file} eq $mail_file ) );
        }

        $body .= "</table>\n<form action=\"/history\">\n<input type=hidden name=filter value=\"$self->{form}{filter}\">\n<input type=hidden name=sort value=\"$self->{form}{sort}\">" ;
        $body .= "<b>$self->{language}{History_Remove}:&nbsp;</b>\n" ;
        $body .= "<input type=submit class=submit name=clearall value=\"$self->{language}{History_RemoveAll}\">\n";
        $body .= "<input type=submit class=submit name=clearpage value=\"$self->{language}{History_RemovePage}\">\n" ;
        $body .= "<input type=hidden name=session value=\"$self->{session_key}\">\n" ;
        $body .= "<input type=hidden name=start_message value=\"$start_message\">\n</form>\n" ;
        $body .= "<table width=\"100%\">\n<tr>\n<td align=\"left\"></td>" ;
        $body .= "<td align=right>";
        $body .= get_history_navigator( $self, $start_message, $stop_message ) if ( $self->{configuration}->{configuration}{page_size} <= history_size( $self ) );
        $body .= "</table>";
    } else {
        $body .= "<h2>$self->{language}{History_Title}$filtered</h2><p><b>$self->{language}{History_NoMessages}.</b><p><form action=\"/history\"><input type=hidden name=session value=\"$self->{session_key}\"><input type=hidden name=sort value=\"$self->{form}{sort}\"><select name=filter><option value=__filter__all>&lt;$self->{language}{History_ShowAll}&gt;</option>";
        
        foreach my $abucket (sort keys %{$self->{classifier}->{total}}) {
            $body .= "<option value=\"$abucket\"";
            $body .= " selected" if ( ( defined($self->{form}{filter}) ) && ( $self->{form}{filter} eq $abucket ) );
            $body .= ">$abucket</option>";
        }

        $body .= "<option value=__filter__magnet>\n&lt;$self->{language}{History_ShowMagnet}&gt;\n" ;
        $body .= "</option>\n</select>\n" ;
        $body .="<input type=submit class=submit name=setfilter value=\"$self->{language}{Filter}\">\n</form>\n";
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
    my $body = "<h2>$self->{language}{Password_Title}</h2><form action=\"/password\">" ;
    $body .= "<input type=hidden name=redirect value=\"$redirect\"><b>$self->{language}{Password_Enter}:</b> " ;
    $body .= "<input type=password name=password> " ;
    $body .= "<input type=submit class=submit name=submit value=\"$self->{language}{Password_Go}\">\n</form>\n";
    $body .= "<blockquote>\n<font color=\"red\">$self->{language}{Password_Error1}</font>\n</blockquote>" if ( $error == 1 );
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
    http_ok($self, $client, "<h2>$self->{language}{Session_Title}</h2><p>$self->{language}{Session_Error}", 99);
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

        while ( ( $self->{form}{$arg} =~ /%([0-9A-F][0-9A-F])/i ) != 0 ) {
            my $from = "%$1";
            my $to   = chr(hex("0x$1"));
            $self->{form}{$arg} =~ s/$from/$to/g;
        }

        $self->{form}{$arg} =~ s/\+/ /g;
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
    
    my @mail_files = glob "$self->{configuration}->{configuration}{msgdir}popfile*=*.???";
    my $result = 0;

    calculate_today( $self );
    
    foreach my $mail_file (@mail_files) {
        
        # Extract the epoch information from the popfile mail file name
        
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($mail_file);          
        if ( $ctime < (time - $self->{configuration}->{configuration}{history_days} * $seconds_per_day) )  {
            unlink($mail_file);
            $result = 1;
        }
    }
    
     # Clean up old style msg/cls files
    
    @mail_files = glob "$self->{configuration}->{configuration}{msgdir}popfile*_*.???";
    foreach my $mail_file (@mail_files) {
        unlink($mail_file);
    }
    
       return $result;
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
    $self->{mail_filename}  = "popfile$self->{today}";
}

1;
