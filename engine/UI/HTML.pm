#----------------------------------------------------------------------------
#
# This package contains an HTML UI for POPFile
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

my $stab_color = 'black';
my $highlight_color = 'black';

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
    
    # The classifier
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
    $self->{session_key} = '';

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
                if ( ( defined($client) ) && ( my $request = <$client> ) ) {
                    while ( <$client> )  {
                        last if ( !/(.*): (.*)/ );
                    }

                    if ( $request =~ /GET (.*) HTTP\/1\./ ) {
                        $code = handle_url($self, $client, $1);
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
    my @tab = ( 'menu_standard', 'menu_standard', 'menu_standard', 'menu_standard', 'menu_standard', 'menu_standard' );
    $tab[$selected] = 'menu_selected' if ( ( $selected <= $#tab ) && ( $selected >= 0 ) );
    my $time = localtime;
    my $update_check = ''; 

    # Check to see if we've checked for updates today.  If we have not then insert a reference to an image
    # that is generated through a CGI on UseTheSource.  Also send stats to the same site if that is allowed
    if ( $self->{today} ne $self->{configuration}->{configuration}{last_update_check} ) {
        calculate_today( $self );
        
        if ( $self->{configuration}->{configuration}{update_check} ) {
            $update_check = "<a href=http://sourceforge.net/project/showfiles.php?group_id=63137><img border=0 src=http://www.usethesource.com/cgi-bin/popfile_update.pl?ma=$self->{configuration}{major_version}&mi=$self->{configuration}{minor_version}&bu=$self->{configuration}{build_version}></a>";
        }
        
        if ( $self->{configuration}->{configuration}{send_stats} ) {
            my @buckets = keys %{$self->{classifier}->{total}};
            my $bc      = $#buckets + 1;
            $update_check .= "<img border=0 src=http://www.usethesource.com/cgi-bin/popfile_stats.pl?bc=$bc&mc=$self->{configuration}->{configuration}{mcount}&ec=$self->{configuration}->{configuration}{ecount}>";
        }

        $self->{configuration}->{configuration}{last_update_check} = $self->{today};
    }

    
    my $refresh = ($selected != -1)?"<META HTTP-EQUIV=Refresh CONTENT=600>":"";
    
    my $lastuser = 'TODO';
    
    $text = "<html><head><title>$self->{language}{Header_Title}</title><style type=text/css>H1,H2,H3,P,TD {font-family: sans-serif;}</style><link rel=stylesheet type=text/css href='skins/$self->{configuration}->{configuration}{skin}.css' title=main></link><META HTTP-EQUIV=Pragma CONTENT=no-cache><META HTTP-EQUIV=Expires CONTENT=0><META HTTP-EQUIV=Cache-Control CONTENT=no-cache>$refresh</head><body><table class=shell align=center width=100%><tr class=top><td class=border_topLeft></td><td class=border_top></td><td class=border_topRight></td></tr><tr><td class=border_left></td><td style='padding:0px; margin: 0px; border:none'><table class=head cellspacing=0 width=100%><tr><td>&nbsp;&nbsp;$self->{language}{Header_Title}<td align=right valign=middle><a href=/shutdown>$self->{language}{Header_Shutdown}</a>&nbsp;<tr height=3><td colspan=3></td></tr></table></td><td class=border_right></td></tr><tr class=bottom><td class=border_bottomLeft></td><td class=border_bottom></td><td class=border_bottomRight></td></tr></table><p align=center>$update_check<table class=menu cellspacing=0><tr><td class=$tab[2] align=center><a href=/history?setfilter=&session=$self->{session_key}&filter=>$self->{language}{Header_History}</a></td><td class=menu_spacer></td><td class=$tab[1] align=center><a href=/buckets?session=$self->{session_key}>$self->{language}{Header_Buckets}</a></td><td class=menu_spacer></td><td class=$tab[4] align=center><a href=/magnets?session=$self->{session_key}>$self->{language}{Header_Magnets}</a></td><td class=menu_spacer></td><td class=$tab[0] align=center><a href=/configuration?session=$self->{session_key}>$self->{language}{Header_Configuration}</a></td><td class=menu_spacer></td><td class=$tab[3] align=center><a href=/security?session=$self->{session_key}>$self->{language}{Header_Security}</a></td><td class=menu_spacer></td><td class=$tab[5] align=center><a href=/advanced?session=$self->{session_key}>$self->{language}{Header_Advanced}</a></td></tr></table><table class=shell align=center width=100%><tr class=top><td class=border_topLeft></td><td class=border_top></td><td class=border_topRight></td></tr><tr><td class=border_left></td><td style='padding:0px; margin: 0px; border:none'>" . $text . "</td><td class=border_right></td></tr><tr class=bottom><td class=border_bottomLeft></td><td class=border_bottom></td><td class=border_bottomRight></td></tr></table><p align=center><table class=footer><tr><td>POPFile $self->{configuration}{major_version}.$self->{configuration}{minor_version}.$self->{configuration}{build_version} - <a href=manual/$self->{language}{LanguageCode}/manual.html>$self->{language}{Footer_Manual}</a> - <a href=http://popfile.sourceforge.net/>$self->{language}{Footer_HomePage}</a> - <a href=http://sourceforge.net/forum/forum.php?forum_id=213876>$self->{language}{Footer_FeedMe}</a> - <a href=http://sourceforge.net/tracker/index.php?group_id=63137&atid=502959>$self->{language}{Footer_RequestFeature}</a> - <a href=http://lists.sourceforge.net/lists/listinfo/popfile-announce>$self->{language}{Footer_MailingList}</a> - ($time) - ($lastuser)</td></tr></table></body></html>";
    
    my $http_header = "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nContent-Length: ";
    $http_header .= length($text);
    $http_header .= "$eol$eol";
    print $client $http_header . $text;
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
            $separator_error = "<blockquote><font color=red size=+1>$self->{language}{Configuration_Error1}</font></blockquote>";
            delete $self->{form}{separator};
        }
    }

    if ( defined($self->{form}{ui_port}) ) {
        if ( ( $self->{form}{ui_port} >= 1 ) && ( $self->{form}{ui_port} < 65536 ) ) {
            $self->{configuration}->{configuration}{ui_port} = $self->{form}{ui_port};
        } else {
            $ui_port_error = "<blockquote><font color=red size=+1>$self->{language}{Configuration_Error2}</font></blockquote>";
            delete $self->{form}{ui_port};
        }
    }

    if ( defined($self->{form}{port}) ) {
        if ( ( $self->{form}{port} >= 1 ) && ( $self->{form}{port} < 65536 ) ) {
            $self->{configuration}->{configuration}{port} = $self->{form}{port};
        } else {
            $port_error = "<blockquote><font color=red size=+1>$self->{language}{Configuration_Error3}</font></blockquote>";
            delete $self->{form}{port};
        }
    }

    if ( defined($self->{form}{page_size}) ) {
        if ( ( $self->{form}{page_size} >= 1 ) && ( $self->{form}{page_size} <= 1000 ) ) {
            $self->{configuration}->{configuration}{page_size} = $self->{form}{page_size};
        } else {
            $page_size_error = "<blockquote><font color=red size=+1>$self->{language}{Configuration_Error4}</font></blockquote>";
            delete $self->{form}{page_size};
        }
    }

    if ( defined($self->{form}{history_days}) ) {
        if ( ( $self->{form}{history_days} >= 1 ) && ( $self->{form}{history_days} <= 366 ) ) {
            $self->{configuration}->{configuration}{history_days} = $self->{form}{history_days};
        } else {
            $history_days_error = "<blockquote><font color=red size=+1>$self->{language}{Configuration_Error5}</font></blockquote>";
            delete $self->{form}{history_days};
        }
    }

    if ( defined($self->{form}{timeout}) ) {
        if ( ( $self->{form}{timeout} >= 10 ) && ( $self->{form}{timeout} <= 300 ) ) {
            $self->{configuration}->{configuration}{timeout} = $self->{form}{timeout};
        } else {
            $timeout_error = "<blockquote><font color=red size=+1>$self->{language}{Configuration_Error6}</font></blockquote>";
            $self->{form}{update_timeout} = '';
        }
    }

    $body .= "<table width=100% cellpadding=10 cellspacing=0 border=1 bordercolor=$stab_color><tr><td width=33% valign=top><h2>$self->{language}{Configuration_UserInterface}</h2><p><form action=/configuration><b>$self->{language}{Configuration_SkinsChoose}:</b> <br><input type=hidden name=session value=$self->{session_key}><select name=skin>";

    for my $i (0..$#{$self->{skins}}) {
        $body .= "<option value=$self->{skins}[$i]";
        $body .= " selected" if ( $self->{skins}[$i] eq $self->{configuration}->{configuration}{skin} );
        $body .= ">$self->{skins}[$i]</option>";
    }

    $body .= "</select><input type=submit class=submit value='$self->{language}{Apply}' name=change_skin></form>";

    $body .= "<p><form action=/configuration><b>$self->{language}{Configuration_LanguageChoose}:</b> <br><input type=hidden name=session value=$self->{session_key}><select name=language>";

    for my $i (0..$#{$self->{languages}}) {
        $body .= "<option value=$self->{languages}[$i]";
        $body .= " selected" if ( $self->{languages}[$i] eq $self->{configuration}->{configuration}{language} );
        $body .= ">$self->{languages}[$i]</option>";
    }

    $body .= "</select><input type=submit class=submit value='$self->{language}{Apply}' name=change_language></form>";
    $body .= "<td width=33% valign=top><h2>$self->{language}{Configuration_HistoryView}</h2><p><form action=/configuration><b>$self->{language}{Configuration_History}:</b> <br><input name=page_size type=text value=$self->{configuration}->{configuration}{page_size}><input type=submit class=submit name=update_page_size value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$page_size_error";    
    $body .= sprintf( $self->{language}{Configuration_HistoryUpdate}, $self->{configuration}->{configuration}{page_size} ) if ( defined($self->{form}{page_size}) );
    $body .= "<p><p><form action=/configuration><b>$self->{language}{Configuration_Days}:</b> <br><input name=history_days type=text value=$self->{configuration}->{configuration}{history_days}><input type=submit class=submit name=update_history_days value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$history_days_error";    
    $body .= sprintf( $self->{language}{Configuration_DaysUpdate}, $self->{configuration}->{configuration}{history_days} ) if ( defined($self->{form}{history_days}) );

    $body .= "<td width=33% valign=top><h2>$self->{language}{Configuration_ClassificationInsertion}</h2><p>";
    $body .= "<table><tr><td><b>$self->{language}{Configuration_SubjectLine}:</b> ";    
    if ( $self->{configuration}->{configuration}{subject} == 1 ) {
        $body .= "<td><b>$self->{language}{On}</b> <a href=/configuration?subject=1&session=$self->{session_key}><font color=blue>[$self->{language}{TurnOff}]</font></a> ";
    } else {
        $body .= "<td><b>$self->{language}{Off}</b> <a href=/configuration?subject=2&session=$self->{session_key}><font color=blue>[$self->{language}{TurnOn}]</font></a>";
    }
    $body .= "<tr><td><b>$self->{language}{Configuration_XTCInsertion}:</b> ";    
    if ( $self->{configuration}->{configuration}{xtc} == 1 )  {
        $body .= "<td><b>$self->{language}{On}</b> <a href=/configuration?xtc=1&session=$self->{session_key}><font color=blue>[$self->{language}{TurnOff}]</font></a> ";
    } else {
        $body .= "<td><b>$self->{language}{Off}</b> <a href=/configuration?xtc=2&session=$self->{session_key}><font color=blue>[$self->{language}{TurnOn}]</font></a>";
    }
    $body .= "<tr><td><b>$self->{language}{Configuration_XPLInsertion}:</b> ";    
    if ( $self->{configuration}->{configuration}{xpl} == 1 )  {
        $body .= "<td><b>$self->{language}{On}</b> <a href=/configuration?xpl=1&session=$self->{session_key}><font color=blue>[$self->{language}{TurnOff}]</font></a> ";
    } else {
        $body .= "<td><b>$self->{language}{Off}</b> <a href=/configuration?xpl=2&session=$self->{session_key}><font color=blue>[$self->{language}{TurnOn}]</font></a>";
    }
    $body .= "</table>";
    
    $body .= "<tr><td width=33% valign=top><h2>$self->{language}{Configuration_ListenPorts}</h2><p><form action=/configuration><b>$self->{language}{Configuration_POP3Port}:</b><br><input name=port type=text value=$self->{configuration}->{configuration}{port}><input type=submit class=submit name=update_port value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$port_error";    
    $body .= sprintf( $self->{language}{Configuration_POP3Update}, $self->{configuration}->{configuration}{port} ) if ( defined($self->{form}{port}) );
    $body .= "<p><form action=/configuration><b>$self->{language}{Configuration_Separator}:</b><br><input name=separator type=text value=$self->{configuration}->{configuration}{separator}><input type=submit class=submit name=update_separator value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$separator_error";
    $body .= sprintf( $self->{language}{Configuration_SepUpdate}, $self->{configuration}->{configuration}{separator} ) if ( defined($self->{form}{separator}) );
    $body .= "<p><form action=/configuration><b>$self->{language}{Configuration_UI}:</b><br><input name=ui_port type=text value=$self->{configuration}->{configuration}{ui_port}><input type=submit class=submit name=update_ui_port value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$ui_port_error";    
    $body .= sprintf( $self->{language}{Configuration_UIUpdate}, $self->{configuration}->{configuration}{ui_port} ) if ( defined($self->{form}{ui_port}) );
    $body .= "<td width=33% valign=top><h2>$self->{language}{Configuration_TCPTimeout}</h2><p><form action=/configuration><b>$self->{language}{Configuration_TCPTimeoutSecs}:</b> <br><input name=timeout type=text value=$self->{configuration}->{configuration}{timeout}><input type=submit class=submit name=update_timeout value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$timeout_error";    
    $body .= sprintf( $self->{language}{Configuration_TCPTimeoutUpdate}, $self->{configuration}->{configuration}{timeout} ) if ( defined($self->{form}{timeout}) );
    $body .= "<td width=33% valign=top><h2>$self->{language}{Configuration_Logging}</h2><b>$self->{language}{Configuration_LoggerOutput}:</b><br><form action=/configuration><input type=hidden value=$self->{session_key} name=session><select name=debug>";
    $body .= "<option value=1";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 0 );
    $body .= ">$self->{language}{Configuration_None}</option>";
    $body .= "<option value=2";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 1 );
    $body .= ">$self->{language}{Configuration_ToFile}</option>";
    $body .= "<option value=3";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 2 );
    $body .= ">$self->{language}{Configuration_ToScreen}</option>";
    $body .= "<option value=4";
    $body .= " selected" if ( $self->{configuration}->{configuration}{debug} == 3 );
    $body .= ">$self->{language}{Configuration_ToScreenFile}</option>";
    $body .= "</select><input type=submit class=submit name=submit_debug value='$self->{language}{Apply}'></form></table>";
    
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
            $port_error = "<blockquote><font color=red size=+1>$self->{language}{Security_Error1}</font></blockquote>";
            delete $self->{form}{sport};
        }
    }

    $body .= "<table width=100% cellpadding=10 cellspacing=0 border=1 bordercolor=$stab_color><tr><td width=50% valign=top><h2>$self->{language}{Security_Stealth}</h2><p><b>$self->{language}{Security_POP3}:</b><br>";
    if ( $self->{configuration}->{configuration}{localpop} == 1 ) {
        $body .= "<b>$self->{language}{Security_NoStealthMode}</b> <a href=/security?localpop=1&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToYes}]</font></a> ";
    } else {
        $body .= "<b>$self->{language}{Yes}</b> <a href=/security?localpop=2&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToNo} (Stealth Mode)]</font></a> ";
    } 
    
    $body .= "<p><b>$self->{language}{Security_UI}:</b><br>";
    if ( $self->{configuration}->{configuration}{localui} == 1 ) {
        $body .= "<b>$self->{language}{Security_NoStealthMode}</b> <a href=/security?localui=1&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToYes}]</font></a> ";
    } else {
        $body .= "<b>$self->{language}{Yes}</b> <a href=/security?localui=2&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToNo} (Stealth Mode)]</font></a> ";
    } 

    $body .= "<td width=50% valign=top><h2>$self->{language}{Security_PasswordTitle}</h2><p><form action=/security><b>$self->{language}{Security_Password}:</b> <br><input name=password type=password value=$self->{configuration}->{configuration}{password}> <input type=submit class=submit name=update_server value='$self->{language}{Apply}'> <input type=hidden name=session value=$self->{session_key}></form>";    
    $body .= sprintf( $self->{language}{Security_PasswordUpdate}, $self->{configuration}->{configuration}{password} ) if ( defined($self->{form}{password}) );
   
    $body .= "<tr><td width=50% valign=top><h2>$self->{language}{Security_UpdateTitle}</h2><p><b>$self->{language}{Security_Update}:</b><br>";
    if ( $self->{configuration}->{configuration}{update_check} == 1 ) {
        $body .= "<b>$self->{language}{Yes}</b> <a href=/security?update_check=1&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToNo}]</font></a> ";
    } else {
        $body .= "<b>$self->{language}{No}</b> <a href=/security?update_check=2&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToYes}]</font></a> ";
    } 
    $body .= "<p>$self->{language}{Security_ExplainUpdate}";
    $body .= "<td width=50% valign=top><h2>$self->{language}{Security_StatsTitle}</h2><p><b>$self->{language}{Security_Stats}:</b><br>";
    if ( $self->{configuration}->{configuration}{send_stats} == 1 ) {
        $body .= "<b>$self->{language}{Yes}</b> <a href=/security?send_stats=1&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToNo}]</font></a> ";
    } else {
        $body .= "<b>$self->{language}{No}</b> <a href=/security?send_stats=2&session=$self->{session_key}><font color=blue>[$self->{language}{ChangeToYes}]</font></a> ";
    } 
    $body .= "<p>$self->{language}{Security_ExplainStats}";

    
    $body .= "<tr><td width=100% valign=top colspan=2><h2>$self->{language}{Security_AUTHTitle}</h2><p><form action=/security><b>$self->{language}{Security_SecureServer}:</b> <br><input name=server type=text value=$self->{configuration}->{configuration}{server}><input type=submit class=submit name=update_server value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>";    
    $body .= sprintf( $self->{language}{Security_SecureServerUpdate}, $self->{configuration}->{configuration}{server} ) if ( defined($self->{form}{server}) );
    $body .= "<p><form action=/security><b>$self->{language}{Security_SecurePort}:</b> <br><input name=sport type=text value=$self->{configuration}->{configuration}{sport}><input type=submit class=submit name=update_sport value='$self->{language}{Apply}'><input type=hidden name=session value=$self->{session_key}></form>$port_error";    
    $body .= sprintf( $self->{language}{Security_SecurePortUpdate}, $self->{configuration}->{configuration}{sport} ) if ( defined($self->{form}{sport}) );
    
    $body .= "</table>";
    
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
            $add_message = "<blockquote><font color=red><b>". sprintf( $self->{language}{Advanced_Error1}, $self->{form}{newword} ) . "</b></font></blockquote>";
        } else {
            if ( $self->{form}{newword} =~ /[^[:alpha:][0-9]\._\-@]/ ) {
                $add_message = "<blockquote><font color=red><b>$self->{language}{Advanced_Error2}</b></font></blockquote>";
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
            $delete_message = "<blockquote><font color=red><b>" . sprintf( $self->{language}{Advanced_Error4} , $self->{form}{word} ) . "</b></font></blockquote>";
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
    $body .= "</table><p><form action=/advanced><b>$self->{language}{Advanced_AddWord}:</b><br><input type=hidden name=session value=$self->{session_key}><input type=text name=newword> <input type=submit class=submit name=add value='$self->{language}{Add}'></form>$add_message";
    $body .= "<p><form action=/advanced><b>$self->{language}{Advanced_RemoveWord}:</b><br><input type=hidden name=session value=$self->{session_key}><input type=text name=word> <input type=submit class=submit name=remove value='$self->{language}{Remove}'></form>$delete_message";
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
                $magnet_message = "<blockquote><font color=red><b>" . sprintf( $self->{language}{Magnet_Error1}, "$self->{form}{type}: $self->{form}{text}", $bucket ) . "</b></font></blockquote>";
            }
        }

        if ( $found == 0 )  {
            for my $bucket (keys %{$self->{classifier}->{magnets}}) {
                for my $from (keys %{$self->{classifier}->{magnets}{$bucket}{$self->{form}{type}}})  {
                    if ( ( $self->{form}{text} =~ /\Q$from\E/ ) || ( $from =~ /\Q$self->{form}{text}\E/ ) )  {
                        $found = 1;
                        $magnet_message = "<blockquote><font color=red><b>" . sprintf( $self->{language}{Magnet_Error2}, "$self->{form}{type}: $self->{form}{text}", "$self->{form}{type}: $from", $bucket ) . "</b></font></blockquote>";
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
    
    my $body = "<h2>$self->{language}{Magnet_CurrentMagnets}</h2><p>$self->{language}{Magnet_Message1}";
    $body .= "<p><table width=75%><tr><td><b>$self->{language}{Magnet}</b><td><b>$self->{language}{Bucket}</b><td><b>$self->{language}{Delete}</b>";
    
    my $stripe = 0;
    for my $bucket (sort keys %{$self->{classifier}->{magnets}}) {
        for my $type (sort keys %{$self->{classifier}->{magnets}{$bucket}}) {
            for my $magnet (sort keys %{$self->{classifier}->{magnets}{$bucket}{$type}})  {
                $body .= "<tr "; 
                if ( $stripe )  {
                    $body .= " class=row_even"; 
                } else {
                    $body .= " class=row_odd"; 
                }
                $body .= "><td>$type: $magnet<td><font color=$self->{classifier}->{colors}{$bucket}>$bucket</font><td><a href=/magnets?bucket=$bucket&dtype=$type&";
                $body .= encode($self, "dmagnet=$magnet");
                $body .= "&session=$self->{session_key}>[$self->{language}{Delete}]</a>";
                $stripe = 1 - $stripe;
            }
        }
    }
    
    $body .= "</table><p><hr><p><h2>$self->{language}{Magnet_CreateNew}</h2><form action=/magnets><b>$self->{language}{Magnet_Explanation}<br><b>$self->{language}{Magnet_MagnetType}:</b><br><select name=type><option value=from>$self->{language}{From}</option><option value=to>$self->{language}{To}</option><option value=subject>$self->{language}{Subject}</option></select><input type=hidden name=session value=$self->{session_key}>";
    $body .= "<p><b>$self->{language}{Magnet_Value}:</b><br><input type=text name=text><p><b>$self->{language}{Magnet_Always}:</b><br><select name=bucket><option value=></option>";
    my @buckets = sort keys %{$self->{classifier}->{total}};
    foreach my $bucket (@buckets) {
        $body .= "<option value=$bucket>$bucket</option>";
    }
    $body .= "</select> <input type=submit class=submit name=create value='$self->{language}{Create}'><input type=hidden name=session value=$self->{session_key}></form>$magnet_message";
    http_ok($self, $client,$body,4);
}

# ---------------------------------------------------------------------------------------------
#
# bucket_page - information about a specific bucket
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub bucket_page  
{
    my ( $self, $client ) = @_;
    
    my $body = "<h2>" . sprintf( $self->{language}{SingleBucket_Title}, "<font color=$self->{classifier}->{colors}{$self->{form}{showbucket}}>$self->{form}{showbucket}</font>") . "</h2><p><table><tr><td><b>$self->{language}{SingleBucket_WordCount}</b><td>&nbsp;<td align=right>". pretty_number( $self, $self->{classifier}->{total}{$self->{form}{showbucket}});
    $body .= "<td>(" . sprintf( $self->{language}{SingleBucket_Unique}, pretty_number( $self,  $self->{classifier}->{unique}{$self->{form}{showbucket}}) ). ")";
    $body .= "<tr><td><b>$self->{language}{SingleBucket_TotalWordCount}</b><td>&nbsp;<td align=right>" . pretty_number( $self, $self->{classifier}->{full_total});
    my $percent = "0%";
    if ( $self->{classifier}->{full_total} > 0 )  {
        $percent = int( 10000 * $self->{classifier}->{total}{$self->{form}{showbucket}} / $self->{classifier}->{full_total} ) / 100;
        $percent = "$percent%";
    }
    $body .= "<td><tr><td><hr><b>$self->{language}{SingleBucket_Percentage}</b><td><hr>&nbsp;<td align=right><hr>$percent<td></table>";
 
    $body .= "<h2>" . sprintf( $self->{language}{SingleBucket_WordTable},  "<font color=$self->{classifier}->{colors}{$self->{form}{showbucket}}>$self->{form}{showbucket}" ) . "</font></h2><p>$self->{language}{SingleBucket_Message1}<p><table>";
    for my $i (@{$self->{classifier}->{matrix}{$self->{form}{showbucket}}}) {
        if ( defined($i) )  {
            my $j = $i;
            $j =~ s/\|\|/, /g;
            $j =~ s/\|//g;
            $j =~ /^(.)/;
            my $first = $1;
            $j =~ s/([^ ]+) (L\-[\.\d]+)/\*$1 $2<\/font>/g;
            $j =~ s/L(\-[\.\d]+)/int( $self->{classifier}->{total}{$self->{form}{showbucket}} * exp($1) + 0.5 )/ge;
            $j =~ s/([^ ,\*]+) ([^ ,\*]+)/<a href=\/buckets\?session=$self->{session_key}\&lookup=Lookup\&word=$1#Lookup>$1<\/a> $2/g;
            $body .= "<tr><td valign=top><b>$first</b><td valign=top>$j";
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
        $body .= "<tr><td><font color=$self->{classifier}->{colors}{$bucket}>$bucket</font><td>&nbsp;<td align=right>$count ($percent)";
    }    

    $body .= "<tr><td colspan=3>&nbsp;<tr><td colspan=3><table width=100%><tr>";

    if ( $total_count != 0 ) {
        foreach my $bucket (@xaxis) {
            my $percent = int( $values{$bucket} * 10000 / $total_count ) / 100; 
            if ( $percent != 0 )  {
                $body .= "<td bgcolor=$self->{classifier}->{colors}{$bucket}><img src=pix.gif alt=\"$bucket ($percent%)\" height=20 width=";
                $body .= 2 * int($percent);
                $body .= "></td>";
            }
        }
    }

    $body .= "</table>";

    if ( $total_count != 0 )  {
        $body .= "<tr><td colspan=3 align=right><font size=1>100%</font>";
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
        # TODO save_configuration();
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
    
    if ( ( defined($self->{form}{cname}) ) && ( $self->{form}{cname} ne '' ) ) {
        if ( $self->{form}{cname} =~ /[^[:lower:]\-_]/ )  {
            $create_message = "<blockquote><font color=red size=+1>$self->{language}{Bucket_Error1}</font></blockquote>";
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
            $rename_message = "<blockquote><font color=red size=+1>$self->{language}{Bucket_Error1}</font></blockquote>";
        } else {
            $self->{form}{oname} = lc($self->{form}{oname});
            $self->{form}{newname} = lc($self->{form}{newname});
            rename("$self->{configuration}->{configuration}{corpus}/$self->{form}{oname}" , "$self->{configuration}->{configuration}{corpus}/$self->{form}{newname}");
            $rename_message = "<blockquote><b>" . sprintf( $self->{language}{Bucket_Error5}, $self->{form}{oname}, $self->{form}{newname} ) . "</b></blockquote>";
            $self->{classifier}->load_word_matrix();
        }
    }    
    
    my $body = "<h2>$self->{language}{Bucket_Title}</h2><table width=100% cellspacing=0 cellpadding=0><tr><td><b>$self->{language}{Bucket_BucketName}</b><td width=10>&nbsp;<td align=right><b>$self->{language}{Bucket_WordCount}</b><td width=10>&nbsp;<td align=right><b>$self->{language}{Bucket_UniqueWords}</b><td width=10>&nbsp;<td align=center><b>$self->{language}{Bucket_SubjectModification}</b><td width=20>&nbsp;<td align=left><b>$self->{language}{Bucket_ChangeColor}</b>";

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
            $body .= " class=row_even";
        } else {
            $body .= " class=row_odd";
        }
        $stripe = 1 - $stripe;
        $body .= "><td><a href=/buckets?session=$self->{session_key}&showbucket=$bucket><font color=$self->{classifier}->{colors}{$bucket}>$bucket</font></a><td width=10>&nbsp;<td align=right>$number<td width=10>&nbsp;<td align=right>$unique<td width=10>&nbsp;";
        if ( $self->{configuration}->{configuration}{subject} == 1 )  {
            $body .= "<td align=center>";
            if ( $self->{classifier}->{parameters}{$bucket}{subject} == 0 )  {
                $body .= "<b>$self->{language}{Off}</b> <a href=/buckets?session=$self->{session_key}&bucket=$bucket&subject=2>[$self->{language}{TurnOn}]</a>";            
            } else {
                $body .= "<b>$self->{language}{On}</b> <a href=/buckets?session=$self->{session_key}&bucket=$bucket&subject=1>[$self->{language}{TurnOff}]</a> ";
            }
        } else {
            $body .= "<td align=center>$self->{language}{Bucket_DisabledGlobally}";
        }
        $body .= "<td>&nbsp;<td align=left><table cellpadding=0 cellspacing=1><tr>";
        my $color = $self->{classifier}->{colors}{$bucket};
        $body .= "<td width=10 bgcolor=$color><img border=0 alt='" . sprintf( $self->{language}{Bucket_CurrentColor}, $bucket, $color ) . "' src=pix.gif width=10 height=20><td>&nbsp;";
        for my $i ( 0 .. $#{$self->{classifier}->{possible_colors}} ) {
            my $color = $self->{classifier}->{possible_colors}[$i];
            if ( $color ne $self->{classifier}->{colors}{$bucket} )  {
                $body .= "<td width=10 bgcolor=$color><a href=/buckets?color=$color&bucket=$bucket&session=$self->{session_key}><img border=0 alt='". sprintf( $self->{language}{Bucket_SetColorTo}, $bucket, $color ) . "' src=pix.gif width=10 height=20></a>";
            } 
        }
        $body .= "</table>";
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

    $body .= "<tr><td><hr><b>$self->{language}{Total}</b><td width=10><hr>&nbsp;<td align=right><hr><b>$number</b><td><td></table><p><table width=100% cellspacing=0 cellpadding=10 bordercolor=$stab_color border=1><tr><td valign=top width=33% align=center><h2>$self->{language}{Bucket_ClassificationAccuracy}</h2><table cellspacing=0 cellpadding=0><tr><td>$self->{language}{Bucket_EmailsClassified}:<td align=right>$pmcount<tr><td>$self->{language}{Bucket_ClassificationErrors}:<td align=right>$pecount<tr><td><hr>$self->{language}{Bucket_Accuracy}:<td align=right><hr>$accuracy";
    
    if ( $percent > 0 )  {
        $body .= "<tr height=10><td colspan=2>&nbsp;<tr><td colspan=2><table width=100% cellspacing=0 cellpadding=0 border=0>";
        $body .= "<tr height=5>";

        for my $i ( 0..49 ) {
            $body .= "<td valign=middle height=10 width=6 bgcolor=";
            $body .= "red" if ( $i < 25 );
            $body .= "yellow" if ( ( $i > 24 ) && ( $i < 47 ) );
            $body .= "green" if ( $i > 46 );
            $body .= ">";
            if ( ( $i * 2 ) < $percent ) {
                $body .= " <img src=black.gif height=4 width=6>";
            } else {
                $body .= " <img src=pix.gif width=6 height=4>";
            }
            $body .= "</td>";
        }
        $body .= "<tr><td colspan=25 align=left><font size=1>0%<td colspan=25 align=right><font size=1>100%</table>";
    }
    
    $body .= "</table><form action=/buckets><input type=hidden name=session value=$self->{session_key}><input type=submit class=submit name=reset_stats value='$self->{language}{Bucket_ResetStatistics}'>";
    
    if ( $self->{configuration}->{configuration}{last_reset} ne '' ) {
        $body .= "<br>($self->{language}{Bucket_LastReset}: $self->{configuration}->{configuration}{last_reset})";
    }
    
    $body .= "</form><td valign=top width=33% align=center><h2>$self->{language}{Bucket_EmailsClassifiedUpper}</h2><p><table><tr><td><b>$self->{language}{Bucket}</b><td>&nbsp;<td><b>$self->{language}{Bucket_ClassificationCount}</b>";

    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $self->{classifier}->{parameters}{$bucket}{count};
    }

    $body .= bar_chart_100( $self, %bar_values );
    $body .= "</table><td width=34% valign=top align=center><h2>$self->{language}{Bucket_WordCounts}</h2><p><table><tr><td><b>$self->{language}{Bucket}</b><td>&nbsp;<td align=right><b>$self->{language}{Bucket_WordCount}</b>";

    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $self->{classifier}->{total}{$bucket};
    }

    $body .= bar_chart_100( $self, %bar_values );
   
    $body .= "</table></table><p><table width=100% cellspacing=0 cellpadding=10 bordercolor=$stab_color border=1><tr><td valign=top width=50%><h2>$self->{language}{Bucket_Maintenance}</h2><p><form action=/buckets><b>$self->{language}{Bucket_CreateBucket}:</b> <br><input name=cname type=text> <input type=submit class=submit name=create value='$self->{language}{Create}'><input type=hidden name=session value=$self->{session_key}></form>$create_message";
    $body .= "<p><form action=/buckets><b>$self->{language}{Bucket_DeleteBucket}:</b> <br><select name=name><option value=></option>";

    foreach my $bucket (@buckets) {
        $body .= "<option value=$bucket>$bucket</option>";
    }
    $body .= "</select> <input type=submit class=submit name=delete value='$self->{language}{Delete}'><input type=hidden name=session value=$self->{session_key}></form>$delete_message";

    $body .= "<p><form action=/buckets><b>$self->{language}{Bucket_RenameBucket}:</b> <br><select name=oname><option value=></option>";
    foreach my $bucket (@buckets) {
        $body .= "<option value=$bucket>$bucket</option>";
    }
    $body .= "</select> <b>$self->{language}{Bucket_To}</b> <input type=text name=newname> <input type=submit class=submit name=rename value='$self->{language}{Rename}'><input type=hidden name=session value=$self->{session_key}></form>$rename_message";

    $body .= "<td valign=top width=50%><a name=Lookup><h2>$self->{language}{Bucket_Lookup}</h2><form action=/buckets#Lookup><p><b>$self->{language}{Bucket_LookupMessage}: </b><br><input name=word type=text> <input type=submit class=submit name=lookup value='$self->{language}{Lookup}'><input type=hidden name=session value=$self->{session_key}></form>";

    if ( ( defined($self->{form}{lookup}) ) || ( defined($self->{form}{word}) ) ) {
       my $word = $self->{classifier}->{mangler}->mangle($self->{form}{word});

        $body .= "<blockquote>";

        # Don't print the headings if there are no entries.

        my $heading = "<table cellpadding=6 cellspacing=0 border=3 bordercolor=$stab_color><tr><td><b>$self->{language}{Bucket_LookupMessage2}  $self->{form}{word}</b><p><table><tr><td><b>$self->{language}{Bucket}</b><td>&nbsp;<td><b>$self->{language}{Frequency}</b><td>&nbsp;<td><b>$self->{language}{Probability}</b><td>&nbsp;<td><b>$self->{language}{Score}</b>";

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
                    $body .= "<tr><td>$bold<font color=$self->{classifier}->{colors}{$bucket}>$bucket</font>$endbold<td><td>$bold<tt>$probf</tt>$endbold<td><td>$bold<tt>$normal</tt>$endbold<td><td>$bold<tt>$score</tt>$endbold";
                }
            }

            if ( $max_bucket ne '' ) {
                $body .= "</table><p>" . sprintf( $self->{language}{Bucket_LookupMostLikely}, $self->{form}{word}, $self->{classifier}->{colors}{$max_bucket}, $max_bucket) . "</table>";
            } else {
                $body .= sprintf( $self->{language}{Bucket_DoesNotAppear}, $self->{form}{word} );
            }
        } else {
            $body .= "<font color=red size=+1>$self->{language}{Bucket_Error4}</font>";
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
# $search       Subject line to search for
#
# ---------------------------------------------------------------------------------------------
sub load_history_cache 
{
    my ( $self, $filter, $search ) = @_;
    
    my @history_files = sort compare_mf glob "messages/popfile*=*.msg";
    $self->{history}         = {};
    $self->{history_invalid} = 0;
    my $j = 0;

    print "Reloading history cache...";

    foreach my $i ( 0 .. $#history_files ) {
        $history_files[$i] =~ /(popfile.*\.msg)/;
        $history_files[$i] = $1;
        my $class_file = $history_files[$i];
        my $magnet     = '';
        $class_file =~ s/msg$/cls/;
        open CLASS, "<messages/$class_file";
        my $bucket = <CLASS>;
        if ( $bucket =~ /([^ ]+) MAGNET (.+)/ ) {
            $bucket = $1;
            $magnet = $2;
        } else {
            $magnet = '';
        }
        my $reclassified = 0;
        if ( $bucket =~ /RECLASSIFIED/ ) {
            $bucket       = <CLASS>;
            $reclassified = 1;
        }
        $bucket =~ s/[\r\n]//g;
        
        if ( ( $filter eq '' ) || ( $bucket eq $filter ) || ( ( $filter eq '__filter__magnet' ) && ( $magnet ne '' ) ) ) {
            my $found = 1;
            
            if ( $search ne '' ) {
                $found = 0;
                
                open MAIL, "<messages/$history_files[$i]";
                while (<MAIL>)  {
                    if ( /[A-Z0-9]/i )  {
                        if ( /^Subject:(.*)/i ) {
                            my $subject = $1;
                            if ( $subject =~ /\Q$search\E/i )  {
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
                $self->{history}{$j}{subject}      = '';
                $self->{history}{$j}{from}         = '';

                $j += 1;
            }
        }
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
        $body .= "<a href=/history?start_message=";
        $body .= $start_message - $self->{configuration}->{configuration}{page_size};
        $body .= "&session=$self->{session_key}&filter=$self->{form}{filter}>< $self->{language}{Previous}</a> ";
    }
    my $i = 0;
    while ( $i < history_size( $self ) ) {
        if ( $i == $start_message )  {
            $body .= "<b>";
            $body .= $i+1 . "</b>";
        } else {
            $body .= "<a href=/history?start_message=$i&session=$self->{session_key}&filter=$self->{form}{filter}>";
            $body .= $i+1 . "</a>";
        }

        $body .= " ";
        $i += $self->{configuration}->{configuration}{page_size};
    }
    if ( $start_message < ( history_size( $self ) - $self->{configuration}->{configuration}{page_size} ) )  {
        $body .= "<a href=/history?start_message=";
        $body .= $start_message + $self->{configuration}->{configuration}{page_size};
        $body .= "&session=$self->{session_key}&filter=$self->{form}{filter}>$self->{language}{Next} ></a>";
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

        $self->{classifier}->{parser}->parse_stream("messages/$self->{form}{undo}");

        foreach my $word (keys %{$self->{classifier}->{parser}->{words}}) {
            $self->{classifier}->{full_total} -= $self->{classifier}->{parser}->{words}{$word};
            $temp_words{$word}        -= $self->{classifier}->{parser}->{words}{$word};
            
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
        my $classification = $self->{classifier}->classify_file("messages/$self->{form}{undo}");
        my $class_file = "messages/$self->{form}{undo}";
        $class_file =~ s/msg$/cls/;
        open CLASS, ">$class_file";
        print CLASS "$classification$eol";
        close CLASS;

        $self->{configuration}->{configuration}{ecount} -= 1 if ( $self->{configuration}->{configuration}{ecount} > 0 );
        $self->{classifier}->{parameters}{$self->{form}{badbucket}}{count} -= 1; 
        
        $self->{history_invalid} = 1;
    }

    # Handle clearing the history files
    if ( ( defined($self->{form}{clear}) ) && ( $self->{form}{clear} eq 'Remove All' ) ) {
        # If the history cache is empty then we need to reload it now
        load_history_cache( $self, $self->{form}{filter}, '') if ( history_cache_empty( $self ) );

        foreach my $i (keys %{$self->{history}}) {
            my $mail_file = $self->{history}{$i}{file};
            my $class_file = $mail_file;
            $class_file =~ s/msg$/cls/;
            unlink("messages/$mail_file");
            unlink("messages/$class_file");
        }

        $self->{history_invalid} = 1;        
        http_redirect( $self, $client,"/history?session=$self->{session_key}&filter=$self->{form}{filter}");
        return;
    }

    if ( ( defined($self->{form}{clear}) ) && ( $self->{form}{clear} eq 'Remove Page' ) ) {
        # If the history cache is empty then we need to reload it now
        load_history_cache( $self, $self->{form}{filter}, '') if ( history_cache_empty( $self ) );
        
        foreach my $i ( $self->{form}{start_message} .. $self->{form}{start_message} + $self->{configuration}->{configuration}{page_size} - 1 ) {
            if ( $i <= history_size( $self ) )  {
                my $class_file = $self->{history}{$i}{file};
                $class_file =~ s/msg$/cls/;
                if ( $class_file ne '' )  {
                    unlink("messages/$self->{history}{$i}{file}");
                    unlink("messages/$class_file");
                }
            }
        }

        $self->{history_invalid} = 1;        
        http_redirect( $self, $client,"/history?session=$self->{session_key}&filter=$self->{form}{filter}");
        return;
    }

    # If we just changed the number of mail files on the disk (deleted some or added some)
    # or the history is empty then reload the history
    load_history_cache( $self, $self->{form}{filter}, '') if ( ( remove_mail_files( $self ) ) || ( $self->{history_invalid} ) || ( history_cache_empty( $self ) ) || ( defined($self->{form}{setfilter}) ) );

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

        $self->{classifier}->{parser}->parse_stream("messages/$self->{form}{file}");

        foreach my $word (keys %{$self->{classifier}->{parser}->{words}}) {
            $self->{classifier}->{full_total} += $self->{classifier}->{parser}->{words}{$word};
            $temp_words{$word}        += $self->{classifier}->{parser}->{words}{$word};
        }
        
        open WORDS, ">$self->{configuration}->{configuration}{corpus}/$self->{form}{shouldbe}/table";
        print WORDS "__CORPUS__ __VERSION__ 1\n";
        foreach my $word (keys %temp_words) {
           print WORDS "$word $temp_words{$word}\n" if ( $temp_words{$word} > 0 );
        }
        close WORDS;
        
        my $class_file = "messages/$self->{form}{file}";
        $class_file =~ s/msg$/cls/;
        open CLASS, ">$class_file";
        print CLASS "RECLASSIFIED$eol$self->{form}{shouldbe}$eol";
        close CLASS;
        
        $self->{configuration}->{configuration}{ecount} += 1 if ( $self->{form}{shouldbe} ne $self->{form}{usedtobe} );
        $self->{classifier}->{parameters}{$self->{form}{shouldbe}}{count} += 1; 
        $self->{classifier}->{parameters}{$self->{form}{usedtobe}}{count} -= 1; 

        $self->{classifier}->load_bucket("$self->{configuration}->{configuration}{corpus}/$self->{form}{shouldbe}");
        $self->{classifier}->update_constants();    
        load_history_cache( $self, $self->{form}{filter},'');
    }

    my $highlight_message = '';

    load_history_cache( $self, $self->{form}{filter}, $self->{form}{search}) if ( ( defined($self->{form}{search}) ) && ( $self->{form}{search} ne '' ) );
    
    if ( !history_cache_empty( $self ) )  {
        my $start_message = 0;
        $start_message = $self->{form}{start_message} if ( ( defined($self->{form}{start_message}) ) && ($self->{form}{start_message} > 0 ) );
        my $stop_message  = $start_message + $self->{configuration}->{configuration}{page_size} - 1;

        # Verify that a message we are being asked to view (perhaps from a /jump_to_message URL) is actually between
        # the $start_message and $stop_message, if it is not then move to that message
        if ( defined($self->{form}{view}) ) {
            my $found = 0;
            foreach my $i ($start_message ..  $stop_message) {
                if ( $self->{form}{view} eq $self->{history}{$i}{file} )  {
                    $found = 1;
                    last;
                }
            }
            
            if ( $found == 0 ) {
                foreach my $i ( 0 .. history_size( $self ) )  {
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
            $body .= "<table width=100%><tr><td align=left><h2>$self->{language}{History_Title}$filtered</h2><td align=right>"; 
            $body .= get_history_navigator( $self, $start_message, $stop_message );
            $body .= "</table>";
        } else {
            $body .="<h2>$self->{language}{History_Title}$filtered</h2>"; 
        }
        
        $body .= "<table width=100%><tr valign=bottom><td></td><td><b>$self->{language}{From}</b><td><b>$self->{language}{Subject}</b><td><form action=/history><input type=hidden name=session value=$self->{session_key}><select name=filter><option value=__filter__all>&lt;$self->{language}{History_ShowAll}&gt;</option>";
        
        my @buckets = sort keys %{$self->{classifier}->{total}};
        foreach my $abucket (@buckets) {
            $body .= "<option value=$abucket";
            $body .= " selected" if ( ( defined($self->{form}{filter}) ) && ( $self->{form}{filter} eq $abucket ) );
            $body .= ">$abucket</option>";
        }
        $body .= "<option value=__filter__magnet>&lt;$self->{language}{History_ShowMagnet}&gt;</option></select><input type=submit class=submit name=setfilter value='$self->{language}{Filter}'></form><b>$self->{language}{Classification}</b><td><b>$self->{language}{History_ShouldBe}</b>";            

        my $stripe = 0;

        foreach my $i ($start_message ..  $stop_message) {
            my $mail_file;
            my $from          = '';
            my $subject       = '';
            my $short_subject = '';
            $mail_file = $self->{history}{$i}{file};

            if ( ( $self->{history}{$i}{subject} eq '' ) || ( $self->{history}{$i}{from} eq '' ) )  {
                open MAIL, "<messages/$mail_file";
                while (<MAIL>)  {
                    if ( /[A-Z0-9]/i )  {
                        if ( /^From:(.*)/i ) {
                            if ( $from eq '' )  {
                                $from = $1;
                                $from =~ s/\"(.*)\"/$1/g;
                            }
                        }
                        if ( /^Subject:(.*)/i ) {
                            if ( $subject eq '' )  {
                                $subject = $1;
                                $subject =~ s/\"(.*)\"/$1/g;
                            }
                        }
                    } else {
                        last;
                    }
                    
                    last if (( $from ne '' ) && ( $subject ne '' ) );
                }
                close MAIL;

                $from    = "&lt;$self->{language}{History_NoFrom}&gt;" if ( $from eq '' );
                $subject = "&lt;$self->{language}{History_NoSubject}&gt;" if ( !( $subject =~ /[^ \t\r\n]/ ) );

                $short_subject = $subject;

                if ( length($from)>40 )  {
                    $from =~ /(.{40})/;
                    $from = "$1...";
                }

                if ( length($short_subject)>40 )  {
                    $short_subject =~ s/=20/ /g;
                    $short_subject =~ /(.{40})/;
                    $short_subject = "$1...";
                }

                $from =~ s/</&lt;/g;
                $from =~ s/>/&gt;/g;

                $subject =~ s/</&lt;/g;
                $subject =~ s/>/&gt;/g;

                $short_subject =~ s/</&lt;/g;
                $short_subject =~ s/>/&gt;/g;
                
                $self->{history}{$i}{from}          = $from;
                $self->{history}{$i}{subject}       = $subject;
                $self->{history}{$i}{short_subject} = $short_subject;
            } else {
                $from          = $self->{history}{$i}{from};
                $subject       = $self->{history}{$i}{subject}; 
                $short_subject = $self->{history}{$i}{short_subject}; 
            }
            
            # If the user has more than 4 buckets then we'll present a drop down list of buckets, otherwise we present simple
            # links

            my $drop_down = ( $#buckets > 4 );

            $body .= "<form action=/history><input type=hidden name=filter value=$self->{form}{filter}>" if ( $drop_down );
            $body .= "<a name=$mail_file>";
            $body .= "<tr";
            if ( ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) || ( ( defined($self->{form}{file}) && ( $self->{form}{file} eq $mail_file ) ) ) || ( $highlight_message eq $mail_file ) ) {
                $body .= " bgcolor=$highlight_color";
            } else {
                $body .= " class="; 
                $body .= $stripe?"row_even":"row_odd"; 
            }

            $stripe = 1 - $stripe;

            $body .= "><td>";
            $body .= $i+1 . "<td>";
            my $bucket       = $self->{history}{$i}{bucket};
            my $reclassified = $self->{history}{$i}{reclassified}; 
            $mail_file =~ /popfile\d+=(\d+)\.msg/;
            $body .= $from;
            $body .= "<td><a title='$subject' href=/history?view=$mail_file&start_message=$start_message&session=$self->{session_key}&filter=$self->{form}{filter}#$mail_file>$short_subject</a><td>";
            if ( $reclassified )  {
                $body .= "<font color=$self->{classifier}->{colors}{$bucket}>$bucket</font><td>" . sprintf( $self->{language}{History_Already}, $self->{classifier}->{colors}{$bucket}, $bucket ) . " - <a href=/history?undo=$mail_file&session=$self->{session_key}&badbucket=$bucket&filter=$self->{form}{filter}&start_message=$start_message#$mail_file>[$self->{language}{Undo}]</a>";
            } else {
                if ( $bucket eq 'unclassified' )  {
                    $body .= "$bucket<td>";
                } else {
                    $body .= "<font color=$self->{classifier}->{colors}{$bucket}>$bucket</font><td>";
                }

                if ( $self->{history}{$i}{magnet} eq '' )  {
                    if ( $drop_down ) {
                        $body .= " <input type=submit class=submit name=change value='$self->{language}{Reclassify}'> <input type=hidden name=usedtobe value=$bucket><select name=shouldbe>";
                    } else {
                        $body .= "$self->{language}{History_ClassifyAs}: ";
                    }

                    foreach my $abucket (@buckets) {
                        if ( $drop_down )  {
                            $body .= "<option value=$abucket";
                            $body .= " selected" if ( $abucket eq $bucket );
                            $body .= ">$abucket</option>"
                        } else {
                            $body .= "<a href=/history?shouldbe=$abucket&file=$mail_file&start_message=$start_message&session=$self->{session_key}&usedtobe=$bucket&filter=$self->{form}{filter}#$mail_file><font color=$self->{classifier}->{colors}{$abucket}>[$abucket]</font></a> ";
                        }
                    }

                    $body .= "</select><input type=hidden name=file value=$mail_file><input type=hidden name=start_message value=$start_message><input type=hidden name=session value=$self->{session_key}>" if ( $drop_down );
                } else {
                    $body .= " ($self->{language}{History_MagnetUsed}: $self->{history}{$i}{magnet})";
                }
            }

            $body .= "</td>";
            $body .= "</form>" if ( $drop_down );

            # Check to see if we want to view a message
            if ( ( defined($self->{form}{view}) ) && ( $self->{form}{view} eq $mail_file ) ) {
                $body .= "<tr><td><td colspan=3><table border=3 bordercolor=$stab_color cellspacing=0 cellpadding=6><tr><td><p align=right><a href=/history?start_message=$start_message&session=$self->{session_key}&filter=$self->{form}{filter}><b>$self->{language}{Close}</b></a><p>";
                if ( $self->{history}{$i}{magnet} eq '' )  {
                    $self->{classifier}->{parser}->{color} = 1;
                    $self->{classifier}->{parser}->{bayes} = $self->{classifier};
                    $body .= $self->{classifier}->{parser}->parse_stream("messages/$self->{form}{view}");
                    $self->{classifier}->{parser}->{color} = 0;
                } else {
                    $self->{history}{$i}{magnet} =~ /(.+): ([^\r\n]+)/;
                    my $header = $1;
                    my $text   = $2;
                    $body .= "<tt>";

                    open MESSAGE, "<messages/$self->{form}{view}";
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
                                    $line =~ s/($text)/<b><font color=$self->{classifier}->{colors}{$self->{history}{$i}{bucket}}>$1<\/font><\/b>/;
                                }
                            }
                        }
                        
                        $body .= $line;
                    }
                    close MESSAGE;
                    $body .= "</tt>";
                }
                $body .= "<p align=right><a href=/history?start_message=$start_message&session=$self->{session_key}&filter=$self->{form}{filter}><b>$self->{language}{Close}</b></a></table><td valign=top>";
                $self->{classifier}->classify_file("messages/$self->{form}{view}");
                $body .= $self->{classifier}->{scores};
            }

            $body .= "<tr bgcolor=$highlight_color><td><td>" . sprintf( $self->{language}{History_ChangedTo}, $self->{classifier}->{colors}{$self->{form}{shouldbe}}, $self->{form}{shouldbe} ) if ( ( defined($self->{form}{file}) ) && ( $self->{form}{file} eq $mail_file ) );
        }

        $body .= "</table><form action=/history><input type=hidden name=filter value=$self->{form}{filter}><b>$self->{language}{History_Remove}: <input type=submit class=submit name=clear value='$self->{language}{History_RemoveAll}'>";
        $body .= "<input type=submit class=submit name=clear value='$self->{language}{History_RemovePage}'><input type=hidden name=session value=$self->{session_key}><input type=hidden name=start_message value=$start_message></form><table width=100%><tr><td align=left><form action=/history><input type=hidden name=filter value=$self->{form}{filter}><input type=hidden name=session value=$self->{session_key}>$self->{language}{History_SearchMessage}: <input type=text name=search> <input type=submit class=submit name=searchbutton value='$self->{language}{Find}'></form><td align=right>";
        $body .= get_history_navigator( $self, $start_message, $stop_message ) if ( $self->{configuration}->{configuration}{page_size} <= history_size( $self ) );
        $body .= "</table>";
    } else {
        $body .= "<h2>$self->{language}{History_Title}$filtered</h2><p><b>$self->{language}{History_NoMessages}.</b><p><form action=/history><input type=hidden name=session value=$self->{session_key}><select name=filter><option value=__filter__all>&lt;$self->{language}{History_ShowAll}&gt;</option>";
        
        foreach my $abucket (sort keys %{$self->{classifier}->{total}}) {
            $body .= "<option value=$abucket";
            $body .= " selected" if ( ( defined($self->{form}{filter}) ) && ( $self->{form}{filter} eq $abucket ) );
            $body .= ">$abucket</option>";
        }

        $body .= "<option value=__filter__magnet>&lt;$self->{language}{History_ShowMagnet}&gt;</option></select><input type=submit class=submit name=setfilter value='$self->{language}{Filter}'></form>";
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
    my $body = "<h2>$self->{language}{Password_Title}</h2><form action=/password><input type=hidden name=redirect value=$redirect><b>$self->{language}{Password_Enter}:</b> <input type=password name=password> <input type=submit class=submit name=submit value=$self->{language}{Password_Go}></form>";
    $body .= "<blockquote><font color=red>$self->{language}{Password_Error1}</font></blockquote>" if ( $error == 1 );
    http_ok($self, $client, $body, 99);
    $self->{session_key} = $session_temp;
}

# ---------------------------------------------------------------------------------------------
#
# handle_url - Handle a URL request
#
# $client     The web browser to send the results to
# $url         URL to process
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
    my ( $self, $client, $url ) = @_;

    # See if there are any form parameters and if there are parse them into the %form hash
    delete $self->{form};
    
    # Remove a # element
    $url =~ s/#.*//;

    print $url . $eol;

    if ( $url =~ s/\?(.*)// )  {
        my $arguments = $1;
        
        while ( $arguments =~ s/(.*?)=(.*?)(&|\r|\n|$)// ) {
            my $arg = $1;
            $self->{form}{$arg} = $2;
            
            while ( ( $self->{form}{$arg} =~ /%([0-9A-F][0-9A-F])/i ) != 0 ) {
                my $from = "%$1";
                my $to   = chr(hex("0x$1"));
                $to =~ s/(\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\$1/g;
                $self->{form}{$arg} =~ s/$from/$to/g;
            }

            $self->{form}{$arg} =~ s/\+/ /g;
        }
    }

    if ( $url eq '/jump_to_message' )  {
        $self->{form}{session} = $self->{session_key};
        $url = '/history';
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

    if ( ( $url eq '/' ) || (!defined($self->{form}{session})) || ( $self->{form}{session} ne $self->{session_key} ) ) {
        delete $self->{form};
    }

    # Change the session key now that it has been checked.  This has the effect of changing the key for every
    # page and preventing the repeated submission of forms
    change_session_key( $self );

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
    
    my @mail_files = glob "messages/popfile*=*.???";
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
    
    @mail_files = glob "messages/popfile*_*.???";
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
