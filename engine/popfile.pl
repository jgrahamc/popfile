#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# popfile.pl --- POP3 mail analyzer and sorter
#
# Acts as a POP3 server and client designed to sit between a real mail client and a real mail
# server using POP3.  Inserts an extra header X-Text-Classification: into the mail header to 
# tell the client whether the mail is spam or not based on a text classification algorithm
#
# Originally created by John Graham-Cumming starting in 2001
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;

# Use the Naive Bayes classifier
use Classifier::Bayes;

use IO::Socket;
use IO::Select;

# This is used to get the hostname of the current machine
# in a cross platform way
use Sys::Hostname;

# This version number
my $major_version = 0;
my $minor_version = 17;
my $build_version = 10;

# The name of the debug file
my $debug_filename;

# Whether we have sent the UIDL command
my $done_uidl = 0;

# A handy variable containing the value of an EOL for Unix systems
my $eol = "\015\012";

# Configuration parameters
#
# used      Count of the number of times it was used
# port      The listen port number
# messages  Count of the number of messages optimized
my %configuration;

# A handy boolean that tells us whether we are alive or not.  When this is set to 1 then the
# proxy works normally, when set to 0 (typically by the aborting() function called from a signal)
# then we will terminate gracefully
my $alive = 1;

# This will hold the handle of the actual mail server that the client is trying to reach
# we are acting as a simple proxy
my $mail;

# The classifier object
my $classifier;

# Constant used by the log rotation code
my $seconds_per_day = 60 * 60 * 24;

# Color constants
my $main_color      = '#ededca';
my $stripe_color    = '#dfdfaf';
my $tab_color       = '#ededca';
my $stab_color      = '#cccc99';
my $highlight_color = '#cccc99';

# Hash used to store form parameters
my %form = ();

# Used for creating file names for storing messages in 
my $mail_filename = '';

# Session key to make the UI safer
my $session_key = '';

# The start of today in seconds
my $today;

# The available skins
my @skins;

# The name of the last user to pass through POPFile
my $lastuser = 'none';

# Used to keep the history information around so that we don't have to reglob every time we hit the
# history page
my @history_cache;
my @from_cache;
my @subject_cache;
my @bucket_cache;
my @magnet_cache;
my @reclassified_cache;
my $downloaded_mail = 0;

# Just our hostname
my $hostname;

#
#
# USER INTERFACE
#
#

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
    my ( $client, $url ) = @_;
    
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
    my ( $client, $text, $selected ) = @_;
    my @tab = ( 'menu_standard', 'menu_standard', 'menu_standard', 'menu_standard', 'menu_standard', 'menu_standard' );
    $tab[$selected] = 'menu_selected' if ( ( $selected <= $#tab ) && ( $selected >= 0 ) );
    my $time = localtime;
    my $update_check = ''; 

    # Check to see if we've checked for updates today.  If we have not then insert a reference to an image
    # that is generated through a CGI on UseTheSource.  Also send stats to the same site if that is allowed
    if ( $today ne $configuration{last_update_check} ) {
        calculate_today();
        
        if ( $configuration{update_check} ) {
            $update_check = "<a href=http://sourceforge.net/project/showfiles.php?group_id=63137><img border=0 src=http://www.usethesource.com/cgi-bin/popfile_update.pl?ma=$major_version&mi=$minor_version&bu=$build_version></a>";
        }
        
        if ( $configuration{send_stats} ) {
            my @buckets = keys %{$classifier->{total}};
            my $bc      = $#buckets + 1;
            $update_check .= "<img border=0 src=http://www.usethesource.com/cgi-bin/popfile_stats.pl?bc=$bc&mc=$configuration{mcount}&ec=$configuration{ecount}>";
        }

        $configuration{last_update_check} = $today;
    }

    
    my $refresh = ($selected != -1)?"<META HTTP-EQUIV=Refresh CONTENT=600>":"";
    
    $text = "<html><head><title>POPFile Control Center</title><style type=text/css>H1,H2,H3,P,TD {font-family: sans-serif;}</style><link rel=stylesheet type=text/css href='skins/$configuration{skin}.css' title=main></link><META HTTP-EQUIV=Pragma CONTENT=no-cache><META HTTP-EQUIV=Expires CONTENT=0><META HTTP-EQUIV=Cache-Control CONTENT=no-cache>$refresh</head><body><table class=shell align=center width=100%><tr class=top><td class=border_topLeft></td><td class=border_top></td><td class=border_topRight></td></tr><tr><td class=border_left></td><td style='padding:0px; margin: 0px; border:none'><table class=head cellspacing=0 width=100%><tr><td>&nbsp;&nbsp;POPFile Control Center<td align=right valign=middle><a href=/shutdown>Shutdown</a>&nbsp;<tr height=3><td colspan=3></td></tr></table></td><td class=border_right></td></tr><tr class=bottom><td class=border_bottomLeft></td><td class=border_bottom></td><td class=border_bottomRight></td></tr></table><p align=center>$update_check<table class=menu cellspacing=0><tr><td class=$tab[2] align=center><a href=/history?session=$session_key&setfilter=Filter&filter=>History</a></td><td class=menu_spacer></td><td class=$tab[1] align=center><a href=/buckets?session=$session_key>Buckets</a></td><td class=menu_spacer></td><td class=$tab[4] align=center><a href=/magnets?session=$session_key>Magnets</a></td><td class=menu_spacer></td><td class=$tab[0] align=center><a href=/configuration?session=$session_key>Configuration</a></td><td class=menu_spacer></td><td class=$tab[3] align=center><a href=/security?session=$session_key>Security</a></td><td class=menu_spacer></td><td class=$tab[5] align=center><a href=/advanced?session=$session_key>Advanced</a></td></tr></table><table class=shell align=center width=100%><tr class=top><td class=border_topLeft></td><td class=border_top></td><td class=border_topRight></td></tr><tr><td class=border_left></td><td style='padding:0px; margin: 0px; border:none'>" . $text . "</td><td class=border_right></td></tr><tr class=bottom><td class=border_bottomLeft></td><td class=border_bottom></td><td class=border_bottomRight></td></tr></table><p align=center><table class=footer><tr><td>POPFile $major_version.$minor_version.$build_version - <a href=manual/manual.html>Manual</a> - <a href=http://popfile.sourceforge.net/>POPFile Home Page</a> - <a href=http://sourceforge.net/forum/forum.php?forum_id=213876>Feed Me!</a> - <a href=http://sourceforge.net/tracker/index.php?group_id=63137&atid=502959>Request Feature</a> - <a href=http://lists.sourceforge.net/lists/listinfo/popfile-announce>Mailing List</a> - ($time) - ($lastuser)</td></tr></table></body></html>";
    
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
    my ($client, $file, $type) = @_;
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
        http_error($client, 404);
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
    my ($client, $error) = @_;

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
    my ($client) = @_;
    
    my $body;
    my $port_error = '';
    my $ui_port_error = '';
    my $page_size_error = '';
    my $history_days_error = '';
    my $timeout_error = '';
    my $separator_error = '';

    $configuration{skin}    = $form{skin}      if ( defined($form{skin}) );
    $configuration{debug}   = $form{debug}-1   if ( ( defined($form{debug}) ) && ( ( $form{debug} >= 1 ) && ( $form{debug} <= 4 ) ) );
    $configuration{subject} = $form{subject}-1 if ( ( defined($form{subject}) ) && ( ( $form{subject} >= 1 ) && ( $form{subject} <= 2 ) ) );
    $configuration{xtc}     = $form{xtc}-1     if ( ( defined($form{xtc}) ) && ( ( $form{xtc} >= 1 ) && ( $form{xtc} <= 2 ) ) );
    $configuration{xpl}     = $form{xpl}-1     if ( ( defined($form{xpl}) ) && ( ( $form{xpl} >= 1 ) && ( $form{xpl} <= 2 ) ) );

    if ( defined($form{separator}) ) {
        if ( length($form{separator}) == 1 ) {
            $configuration{separator} = $form{separator};
        } else {
            $separator_error = "<blockquote><font color=red size=+1>The separator character must be a single character</font></blockquote>";
            delete $form{separator};
        }
    }

    if ( defined($form{ui_port}) ) {
        if ( ( $form{ui_port} >= 1 ) && ( $form{ui_port} < 65536 ) ) {
            $configuration{ui_port} = $form{ui_port};
        } else {
            $ui_port_error = "<blockquote><font color=red size=+1>The user interface port must be a number between 1 and 65535</font></blockquote>";
            delete $form{ui_port};
        }
    }

    if ( defined($form{port}) ) {
        if ( ( $form{port} >= 1 ) && ( $form{port} < 65536 ) ) {
            $configuration{port} = $form{port};
        } else {
            $port_error = "<blockquote><font color=red size=+1>The POP3 listen port must be a number between 1 and 65535</font></blockquote>";
            delete $form{port};
        }
    }

    if ( defined($form{page_size}) ) {
        if ( ( $form{page_size} >= 1 ) && ( $form{page_size} <= 1000 ) ) {
            $configuration{page_size} = $form{page_size};
        } else {
            $page_size_error = "<blockquote><font color=red size=+1>The page size must be a number between 1 and 1000</font></blockquote>";
            delete $form{page_size};
        }
    }

    if ( defined($form{history_days}) ) {
        if ( ( $form{history_days} >= 1 ) && ( $form{history_days} <= 366 ) ) {
            $configuration{history_days} = $form{history_days};
        } else {
            $history_days_error = "<blockquote><font color=red size=+1>The number of days in the history must be a number between 1 and 366</font></blockquote>";
            delete $form{history_days};
        }
    }

    if ( defined($form{timeout}) ) {
        if ( ( $form{timeout} >= 10 ) && ( $form{timeout} <= 300 ) ) {
            $configuration{timeout} = $form{timeout};
        } else {
            $timeout_error = "<blockquote><font color=red size=+1>The TCP timeout must be a number between 10 and 300</font></blockquote>";
            $form{update_timeout} = '';
        }
    }

    $body .= "<h2>Listen Ports</h2><p><form action=/configuration><b>POP3 listen port:</b><br><input name=port type=text value=$configuration{port}><input type=submit class=submit name=update_port value=Apply><input type=hidden name=session value=$session_key></form>$port_error";    
    $body .= "Updated port to $configuration{port}; this change will not take affect until you restart POPFile" if ( defined($form{port}) );
    $body .= "<p><form action=/configuration><b>Separator character:</b><br><input name=separator type=text value=$configuration{separator}><input type=submit class=submit name=update_separator value=Apply><input type=hidden name=session value=$session_key></form>$separator_error";
    $body .= "Updated separator to $configuration{separator}" if ( defined($form{separator}) );
    $body .= "<p><form action=/configuration><b>User interface web port:</b><br><input name=ui_port type=text value=$configuration{ui_port}><input type=submit class=submit name=update_ui_port value=Apply><input type=hidden name=session value=$session_key></form>$ui_port_error";    
    $body .= "Updated user interface web port to $configuration{ui_port}; this change will not take affect until you restart POPFile" if ( defined($form{ui_port}) );
    $body .= "<p><hr><h2>History View</h2><p><form action=/configuration><b>Number of emails per page:</b> <br><input name=page_size type=text value=$configuration{page_size}><input type=submit class=submit name=update_page_size value=Apply><input type=hidden name=session value=$session_key></form>$page_size_error";    
    $body .= "Updated number of emails per page to $configuration{page_size}" if ( defined($form{page_size}) );
    $body .= "<p><p><form action=/configuration><b>Number of days of history to keep:</b> <br><input name=history_days type=text value=$configuration{history_days}><input type=submit class=submit name=update_history_days value=Apply><input type=hidden name=session value=$session_key></form>$history_days_error";    
    $body .= "Updated number of days of history to $configuration{history_days}" if ( defined($form{history_days}) );
    $body .= "<p><hr><h2>Skins</h2><p><form action=/configuration><b>Choose skin:</b> <br><input type=hidden name=session value=$session_key><select name=skin>";

    for my $i (0..$#skins) {
        $body .= "<option value=$skins[$i]";
        $body .= " selected" if ( $skins[$i] eq $configuration{skin} );
        $body .= ">$skins[$i]</option>";
    }

    $body .= "</select><input type=submit class=submit value=Apply name=change_skin></form>";
    $body .= "<p><hr><h2>TCP Connection Timeout</h2><p><form action=/configuration><b>TCP connection timeout in seconds:</b> <br><input name=timeout type=text value=$configuration{timeout}><input type=submit class=submit name=update_timeout value=Apply><input type=hidden name=session value=$session_key></form>$timeout_error";    
    $body .= "Updated TCP connection timeout to $configuration{timeout}" if ( defined($form{timeout}) );
    $body .= "<p><hr><h2>Classification Insertion</h2><p>";
    $body .= "<table><tr><td><b>Subject line modification:</b> ";    
    if ( $configuration{subject} == 1 ) {
        $body .= "<td><b>On</b> <a href=/configuration?subject=1&session=$session_key><font color=blue>[Turn Off]</font></a> ";
    } else {
        $body .= "<td><b>Off</b> <a href=/configuration?subject=2&session=$session_key><font color=blue>[Turn On]</font></a>";
    }
    $body .= "<tr><td><b>X-Text-Classification insertion:</b> ";    
    if ( $configuration{xtc} == 1 )  {
        $body .= "<td><b>On</b> <a href=/configuration?xtc=1&session=$session_key><font color=blue>[Turn Off]</font></a> ";
    } else {
        $body .= "<td><b>Off</b> <a href=/configuration?xtc=2&session=$session_key><font color=blue>[Turn On]</font></a>";
    }
    $body .= "<tr><td><b>X-POPFile-Link insertion:</b> ";    
    if ( $configuration{xpl} == 1 )  {
        $body .= "<td><b>On</b> <a href=/configuration?xpl=1&session=$session_key><font color=blue>[Turn Off]</font></a> ";
    } else {
        $body .= "<td><b>Off</b> <a href=/configuration?xpl=2&session=$session_key><font color=blue>[Turn On]</font></a>";
    }
    $body .= "</table><hr><h2>Logging</h2><b>Logger output:</b><br><form action=/configuration><input type=hidden value=$session_key name=session><select name=debug>";
    $body .= "<option value=1";
    $body .= " selected" if ( $configuration{debug} == 0 );
    $body .= ">None</option>";
    $body .= "<option value=2";
    $body .= " selected" if ( $configuration{debug} == 1 );
    $body .= ">To File</option>";
    $body .= "<option value=3";
    $body .= " selected" if ( $configuration{debug} == 2 );
    $body .= ">To Screen</option>";
    $body .= "<option value=4";
    $body .= " selected" if ( $configuration{debug} == 3 );
    $body .= ">To Screen and File</option>";
    $body .= "</select><input type=submit class=submit name=submit_debug value=Apply></form>";
    
    http_ok($client,$body,0); 
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
    my ($client) = @_;
    
    my $body;
    my $server_error = '';
    my $port_error   = '';

    
    $configuration{password}     = $form{password}         if ( defined($form{password}) );
    $configuration{server}       = $form{server}           if ( defined($form{server}) );
    $configuration{localpop}     = $form{localpop} - 1     if ( defined($form{localpop}) );
    $configuration{localui}      = $form{localui} - 1      if ( defined($form{localui}) );
    $configuration{update_check} = $form{update_check} - 1 if ( defined($form{update_check}) );
    $configuration{send_stats}   = $form{send_stats} - 1   if ( defined($form{send_stats}) );

    if ( defined($form{sport}) ) {
        if ( ( $form{sport} >= 1 ) && ( $form{sport} < 65536 ) ) {
            $configuration{sport} = $form{sport};
        } else {
            $port_error = "<blockquote><font color=red size=+1>The secure port must be a number between 1 and 65535</font></blockquote>";
            delete $form{sport};
        }
    }

    $body .= "<p><h2>Stealth Mode/Server Operation</h2><p><b>Accept POP3 connections from remote machines:</b><br>";
    if ( $configuration{localpop} == 1 ) {
        $body .= "<b>No (Stealth Mode)</b> <a href=/security?localpop=1&session=$session_key><font color=blue>[Change to Yes]</font></a> ";
    } else {
        $body .= "<b>Yes</b> <a href=/security?localpop=2&session=$session_key><font color=blue>[Change to No (Stealth Mode)]</font></a> ";
    } 
    
    $body .= "<p><b>Accept HTTP (User Interface) connections from remote machines:</b><br>";
    if ( $configuration{localui} == 1 ) {
        $body .= "<b>No (Stealth Mode)</b> <a href=/security?localui=1&session=$session_key><font color=blue>[Change to Yes]</font></a> ";
    } else {
        $body .= "<b>Yes</b> <a href=/security?localui=2&session=$session_key><font color=blue>[Change to No (Stealth Mode)]</font></a> ";
    } 
   
    $body .= "<p><hr><h2>Automatic Update Checking</h2><p><b>Check daily for updates to POPFile:</b><br>";
    if ( $configuration{update_check} == 1 ) {
        $body .= "<b>Yes</b> <a href=/security?update_check=1&session=$session_key><font color=blue>[Change to No]</font></a> ";
    } else {
        $body .= "<b>No</b> <a href=/security?update_check=2&session=$session_key><font color=blue>[Change to Yes]</font></a> ";
    } 
    $body .= "<p><hr><h2>Reporting Statistics</h2><p><b>Send statistics back to John daily:</b><br>";
    if ( $configuration{send_stats} == 1 ) {
        $body .= "<b>Yes</b> <a href=/security?send_stats=1&session=$session_key><font color=blue>[Change to No]</font></a> ";
    } else {
        $body .= "<b>No</b> <a href=/security?send_stats=2&session=$session_key><font color=blue>[Change to Yes]</font></a> ";
    } 
    $body .= "<p>(With this turned up POPFile sends once per day the following three values to a script on www.usethesource.com: bc (the total number of buckets that you have), mc (the total number of messages that POPFile has classified) and ec (the total number of classification errors).  These get stored in a file and I will use this to publish some statistics about how people use POPFile and how well it works.  My web server keeps its log files for about 5 days and then they get deleted; I am not storing any connection between the statistics and individual IP addresses.)";

    $body .= "<p><hr><h2>User Interface Password</h2><p><form action=/security><b>Password:</b> <br><input name=password type=password value=$configuration{password}> <input type=submit class=submit name=update_server value=Apply> <input type=hidden name=session value=$session_key></form>";    
    $body .= "Updated password to $configuration{password}" if ( defined($form{password}) );
    
    $body .= "<p><hr><h2>Secure Password Authentication/AUTH</h2><p><form action=/security><b>Secure server:</b> <br><input name=server type=text value=$configuration{server}><input type=submit class=submit name=update_server value=Apply><input type=hidden name=session value=$session_key></form>";    
    $body .= "Updated secure server to $configuration{server}; this change will not take affect until you restart POPFile" if ( defined($form{server}) );
    $body .= "<p><form action=/security><b>Secure port:</b> <br><input name=sport type=text value=$configuration{sport}><input type=submit class=submit name=update_sport value=Apply><input type=hidden name=session value=$session_key></form>$port_error";    
    $body .= "Updated port to $configuration{sport}; this change will not take affect until you restart POPFile" if ( defined($form{sport}) );
    
    http_ok($client,$body,3); 
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
    my ($number) = @_;
    
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
    my ($client) = @_;
    
    my $add_message = '';
    my $delete_message = '';
    if ( defined($form{newword}) ) {
        $form{newword} = lc($form{newword});
        if ( defined($classifier->{parser}->{mangle}->{stop}{$form{newword}}) ) {
            $add_message = "<blockquote><font color=red><b>'$form{newword}' already in the stop word list</b></font></blockquote>";
        } else {
            if ( $form{newword} =~ /[^[:alpha:][0-9]\._\-@]/ ) {
                $add_message = "<blockquote><font color=red><b>Stop words can only contains alphanumeric, ., _, -, or @ characters</b></font></blockquote>";
            } else {
                $classifier->{parser}->{mangle}->{stop}{$form{newword}} = 1;
                $classifier->{parser}->{mangle}->save_stop_words();
                $add_message = "<blockquote>'$form{newword}' added to the stop word list</blockquote>";
            }
        }
    }

    if ( defined($form{word}) ) {
        $form{word} = lc($form{word});
        if ( !defined($classifier->{parser}->{mangle}->{stop}{$form{word}}) ) {
            $delete_message = "<blockquote><font color=red><b>'$form{word}' is not in the stop word list</b></font></blockquote>";
        } else {
            delete $classifier->{parser}->{mangle}->{stop}{$form{word}};
            $classifier->{parser}->{mangle}->save_stop_words();
            $delete_message = "<blockquote>'$form{word}' removed from the stop word list</blockquote>";
        }
    }

    my $body = '<h2>Stop Words</h2><p>The following words are ignored from all classifications as they occur very frequently.<p><table>';
    my $last = '';
    my $need_comma = 0;
    for my $word (sort keys %{$classifier->{parser}->{mangle}->{stop}}) {
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
    $body .= "</table><p><form action=/advanced><b>Add word:</b><br><input type=hidden name=session value=$session_key><input type=text name=newword> <input type=submit class=submit name=add value=Add></form>$add_message";
    $body .= "<p><form action=/advanced><b>Delete word:</b><br><input type=hidden name=session value=$session_key><input type=text name=word> <input type=submit class=submit name=remove value=Delete></form>$delete_message";
    http_ok($client,$body,5);
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
    my ($text) = @_;
    
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
    my ($client) = @_;
    
    my $magnet_message = '';
    if ( ( defined($form{type}) ) && ( $form{bucket} ne '' ) && ( $form{text} ne '' ) ) {
        my $found = 0;
        for my $bucket (keys %{$classifier->{magnets}}) {
            if ( defined($classifier->{magnets}{$bucket}{$form{type}}{$form{text}}) ) {
                $found  = 1;
                $magnet_message = "<blockquote><font color=red><b>Magnet '$form{type}: $form{text}' already exists in bucket '$bucket'</b></font></blockquote>";
            }
        }

        if ( $found == 0 )  {
            for my $bucket (keys %{$classifier->{magnets}}) {
                for my $from (keys %{$classifier->{magnets}{$bucket}{$form{type}}})  {
                    if ( ( $form{text} =~ /\Q$from\E/ ) || ( $from =~ /\Q$form{text}\E/ ) )  {
                        $found = 1;
                        $magnet_message = "<blockquote><font color=red><b>New magnet '$form{type}: $form{text}' clashes with magnet '$form{type}: $from' in bucket '$bucket' and could cause ambiguous results.  New magnet was not added.</b></font></blockquote>";
                    }
                }
            }
        }
        
        if ( $found == 0 ) {
            $classifier->{magnets}{$form{bucket}}{$form{type}}{$form{text}} = 1;
            $magnet_message = "<blockquote>Create new magnet '$form{type}: $form{text}' in bucket '$form{bucket}'</blockquote>";
            $classifier->save_magnets();
        }
    }

    if ( defined($form{dtype}) )  {
        delete $classifier->{magnets}{$form{bucket}}{$form{dtype}}{$form{dmagnet}};
        $classifier->save_magnets();
    }
    
    my $body = '<h2>Current Magnets</h2><p>The following magnets cause mail to always be classified into the specified bucket.';
    $body .= "<p><table width=75%><tr><td><b>Magnet</b><td><b>Bucket</b><td><b>Delete</b>";
    
    my $stripe = 0;
    for my $bucket (sort keys %{$classifier->{magnets}}) {
        for my $type (sort keys %{$classifier->{magnets}{$bucket}}) {
            for my $magnet (sort keys %{$classifier->{magnets}{$bucket}{$type}})  {
                $body .= "<tr "; 
                if ( $stripe )  {
                    $body .= " class=row_even"; 
                } else {
                    $body .= " class=row_odd"; 
                }
                $body .= "><td>$type: $magnet<td><font color=$classifier->{colors}{$bucket}>$bucket</font><td><a href=/magnets?bucket=$bucket&dtype=$type&";
                $body .= encode("dmagnet=$magnet");
                $body .= "&session=$session_key>[Delete]</a>";
                $stripe = 1 - $stripe;
            }
        }
    }
    
    $body .= "</table><p><hr><p><h2>Create New Magnet</h2><form action=/magnets><b>Three types of magnets are available: <ul><li>From address or name:</b> For example: john\@company.com to match a specific address, <br>company.com to match everyone who sends from company.com, <br>John Doe to match a specific person, John to match all Johns<li><b>To address or name:</b> Like a From: magnet but for the To: address in an email<li><b>Subject words:</b> For example: hello to match all messages with hello in the subject</ul><br><b>Magnet Type:</b><br><select name=type><option value=from>From</option><option value=to>To</option><option value=subject>Subject</option></select><input type=hidden name=session value=$session_key>";
    $body .= "<p><b>Value:</b><br><input type=text name=text><p><b>Always goes to bucket:</b><br><select name=bucket><option value=></option>";
    my @buckets = sort keys %{$classifier->{total}};
    foreach my $bucket (@buckets) {
        $body .= "<option value=$bucket>$bucket</option>";
    }
    $body .= "</select> <input type=submit class=submit name=create value=Create><input type=hidden name=session value=$session_key></form>$magnet_message";
    http_ok($client,$body,4);
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
    my ($client) = @_;
    
    my $body = "<h2>Detail for <font color=$classifier->{colors}{$form{showbucket}}>$form{showbucket}</font></h2><p><table><tr><td><b>Bucket word count</b><td>&nbsp;<td align=right>". pretty_number($classifier->{total}{$form{showbucket}});
    $body .= "<td>(" . pretty_number( $classifier->{unique}{$form{showbucket}}) . " unique)";
    $body .= "<tr><td><b>Total word count</b><td>&nbsp;<td align=right>" . pretty_number($classifier->{full_total});
    my $percent = "0%";
    if ( $classifier->{full_total} > 0 )  {
        $percent = int( 10000 * $classifier->{total}{$form{showbucket}} / $classifier->{full_total} ) / 100;
        $percent = "$percent%";
    }
    $body .= "<td><tr><td><hr><b>Percentage of total</b><td><hr>&nbsp;<td align=right><hr>$percent<td></table>";
 
    $body .= "<h2>Word Table for <font color=$classifier->{colors}{$form{showbucket}}>$form{showbucket}</font></h2><p>Starred (*) words have been used for classification in this POPFile session.  Click any word to lookup its probability for all buckets.<p><table>";
    for my $i (@{$classifier->{matrix}{$form{showbucket}}}) {
        if ( defined($i) )  {
            my $j = $i;
            $j =~ s/\|\|/, /g;
            $j =~ s/\|//g;
            $j =~ /^(.)/;
            my $first = $1;
            $j =~ s/([^ ]+) (L\-[\.\d]+)/\*$1 $2<\/font>/g;
            $j =~ s/L(\-[\.\d]+)/int( $classifier->{total}{$form{showbucket}} * exp($1) + 0.5 )/ge;
            $j =~ s/([^ ,\*]+) ([^ ,\*]+)/<a href=\/buckets\?session=$session_key\&lookup=Lookup\&word=$1#Lookup>$1<\/a> $2/g;
            $body .= "<tr><td valign=top><b>$first</b><td valign=top>$j";
        }
    }
    $body .= "</table>";
 
    http_ok($client,$body,1);
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
    my (%values) = @_;
    my $body = '';
    my $total_count = 0;
    my @xaxis = sort keys %values;

    for my $bucket (@xaxis)  {
        $total_count += $values{$bucket};
    }
    
    for my $bucket (@xaxis)  {
        my $count   = pretty_number( $values{$bucket} );
        my $percent;

        if ( $total_count == 0 ) {
            $percent = "0%";
        } else {
            $percent = int( $values{$bucket} * 10000 / $total_count ) / 100;
            $percent .= "%";
        }
        $body .= "<tr><td><font color=$classifier->{colors}{$bucket}>$bucket</font><td>&nbsp;<td align=right>$count ($percent)";
    }    

    $body .= "<tr><td colspan=3>&nbsp;<tr><td colspan=3><table width=100%><tr>";

    if ( $total_count != 0 ) {
        foreach my $bucket (@xaxis) {
            my $percent = int( $values{$bucket} * 10000 / $total_count ) / 100; 
            if ( $percent != 0 )  {
                $body .= "<td bgcolor=$classifier->{colors}{$bucket}><img src=pix.gif alt=\"$bucket ($percent%)\" height=20 width=";
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
    my ($client) = @_;
    
    if ( defined($form{reset_stats}) ) {
        $configuration{mcount} = 0;
        $configuration{ecount} = 0;
        for my $bucket (keys %{$classifier->{total}}) {
            $classifier->{parameters}{$bucket}{count} = 0;
        }
        save_configuration();
        $classifier->write_parameters();
        $configuration{last_reset} = localtime;
    }
    
    if ( defined($form{showbucket}) )  {
        bucket_page($client);
        return;
    }
    
    my $result;
    my $create_message = '';
    my $delete_message = '';
    my $rename_message = '';
    
    if ( ( defined($form{color}) ) && ( defined($form{bucket}) ) ) {
        open COLOR, ">$configuration{corpus}/$form{bucket}/color";
        print COLOR "$form{color}\n";
        close COLOR;
        $classifier->{colors}{$form{bucket}} = $form{color};
    }

    if ( ( defined($form{bucket}) ) && ( $form{subject} > 0 ) ) {
        $classifier->{parameters}{$form{bucket}}{subject} = $form{subject} - 1;
        $classifier->write_parameters();
    }
    
    if ( ( defined($form{cname}) ) && ( $form{cname} ne '' ) ) {
        if ( $form{cname} =~ /[^[:lower:]\-_]/ )  {
            $create_message = "<blockquote><font color=red size=+1>Bucket names can only contain the letters a to z in lower case plus - and _</font></blockquote>";
        } else {
            if ( $classifier->{total}{$form{cname}} > 0 )  {
                $create_message = "<blockquote><b>Bucket named $form{cname} already exists</b></blockquote>";
            } else {
                mkdir( $configuration{corpus} );
                mkdir( "$configuration{corpus}/$form{cname}" );
                open NEW, ">$configuration{corpus}/$form{cname}/table";
                print NEW "\n";
                close NEW;
                $classifier->load_word_matrix();

                $create_message = "<blockquote><b>Created bucket named $form{cname}</b></blockquote>";
            }
       }
    }

    if ( ( defined($form{delete}) ) && ( $form{name} ne '' ) ) {
        $form{name} = lc($form{name});
        unlink( "$configuration{corpus}/$form{name}/table" );
        unlink( "$configuration{corpus}/$form{name}/params" );
        unlink( "$configuration{corpus}/$form{name}/magnets" );
        unlink( "$configuration{corpus}/$form{name}/color" );
        rmdir( "$configuration{corpus}/$form{name}" );

        $delete_message = "<blockquote><b>Deleted bucket $form{name}</b></blockquote>";
        $classifier->load_word_matrix();
    }
    
    if ( ( defined($form{newname}) ) && ( $form{oname} ne '' ) ) {
        if ( $form{newname} =~ /[^[:lower:]\-_]/ )  {
            $rename_message = "<blockquote><font color=red size=+1>Bucket names can only contain the letters a to z in lower case plus - and _</font></blockquote>";
        } else {
            $form{oname} = lc($form{oname});
            $form{newname} = lc($form{newname});
            rename("$configuration{corpus}/$form{oname}" , "$configuration{corpus}/$form{newname}");
            $rename_message = "<blockquote><b>Renamed bucket $form{oname} to $form{newname}</b></blockquote>";
            $classifier->load_word_matrix();
        }
    }    
    
    my $body = "<h2>Summary</h2><table width=100% cellspacing=0 cellpadding=0><tr><td><b>Bucket Name</b><td width=10>&nbsp;<td align=right><b>Word Count</b><td width=10>&nbsp;<td align=right><b>Unique Words</b><td width=10>&nbsp;<td align=center><b>Subject Modification</b><td width=20>&nbsp;<td align=left><b>Change Color</b>";

    my @buckets = sort keys %{$classifier->{total}};
    my $stripe = 0;
    
    my $total_count = 0;
    foreach my $bucket (@buckets) {
        $total_count += $classifier->{parameters}{$bucket}{count};
    }
    
    foreach my $bucket (@buckets) {
        my $number  = pretty_number( $classifier->{total}{$bucket} );
        my $unique  = pretty_number( $classifier->{unique}{$bucket} );

        $body .= "<tr";
        if ( $stripe == 1 )  {
            $body .= " class=row_even";
        } else {
            $body .= " class=row_odd";
        }
        $stripe = 1 - $stripe;
        $body .= "><td><a href=/buckets?session=$session_key&showbucket=$bucket><font color=$classifier->{colors}{$bucket}>$bucket</font></a><td width=10>&nbsp;<td align=right>$number<td width=10>&nbsp;<td align=right>$unique<td width=10>&nbsp;";
        if ( $configuration{subject} == 1 )  {
            $body .= "<td align=center>";
            if ( $classifier->{parameters}{$bucket}{subject} == 0 )  {
                $body .= "<b>Off</b> <a href=/buckets?session=$session_key&bucket=$bucket&subject=2>[Turn On]</a>";            
            } else {
                $body .= "<b>On</b> <a href=/buckets?session=$session_key&bucket=$bucket&subject=1>[Turn Off]</a> ";
            }
        } else {
            $body .= "<td align=center>Disabled globally";
        }
        $body .= "<td>&nbsp;<td align=left><table cellpadding=0 cellspacing=1><tr>";
        my $color = $classifier->{colors}{$bucket};
        $body .= "<td width=10 bgcolor=$color><img border=0 alt='$bucket current color is $color' src=pix.gif width=10 height=20><td>&nbsp;";
        for my $i ( 0 .. $#{$classifier->{possible_colors}} ) {
            my $color = $classifier->{possible_colors}[$i];
            if ( $color ne $classifier->{colors}{$bucket} )  {
                $body .= "<td width=10 bgcolor=$color><a href=/buckets?color=$color&bucket=$bucket&session=$session_key><img border=0 alt='Set $bucket color to $color' src=pix.gif width=10 height=20></a>";
            } 
        }
        $body .= "</table>";
    }

    my $number = pretty_number( $classifier->{full_total} );
    my $pmcount = pretty_number( $configuration{mcount} );
    my $pecount = pretty_number( $configuration{ecount} );
    my $accuracy = 'Not enough data';
    my $percent = 0;
    if ( $configuration{mcount} > 0 )  {
        $percent = int( 10000 * ( $configuration{mcount} - $configuration{ecount} ) / $configuration{mcount} ) / 100;
        $accuracy = "$percent%";
    } 

    $body .= "<tr><td><hr><b>Total</b><td width=10><hr>&nbsp;<td align=right><hr><b>$number</b><td><td></table><p><hr><table width=100%><tr><td valign=top width=33%><h2>Classification Accuracy</h2><table cellspacing=0 cellpadding=0><tr><td>Emails classified:<td align=right>$pmcount<tr><td>Classification errors:<td align=right>$pecount<tr><td><hr>Accuracy:<td align=right><hr>$accuracy";
    
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
    
    $body .= "</table><form action=/buckets><input type=hidden name=session value=$session_key><input type=submit class=submit name=reset_stats value='Reset Statistics'><br>(Last reset: $configuration{last_reset})</form><td valign=top width=33%><h2>Emails Classified</h2><p><table><tr><td><b>Bucket</b><td>&nbsp;<td><b>Classification Count</b>";

    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $classifier->{parameters}{$bucket}{count};
    }

    $body .= bar_chart_100( %bar_values );
    $body .= "</table><td width=34% valign=top><h2>Word Counts</h2><p><table><tr><td><b>Bucket</b><td>&nbsp;<td align=right><b>Word Count</b>";

    for my $bucket (@buckets)  {
        $bar_values{$bucket} = $classifier->{total}{$bucket};
    }

    $body .= bar_chart_100( %bar_values );
   
    $body .= "</table></table><p><hr><h2>Maintenance</h2><p><form action=/buckets><b>Create bucket with name:</b> <br><input name=cname type=text> <input type=submit class=submit name=create value=Create><input type=hidden name=session value=$session_key></form>$create_message";
    $body .= "<p><form action=/buckets><b>Delete bucket named:</b> <br><select name=name><option value=></option>";

    foreach my $bucket (@buckets) {
        $body .= "<option value=$bucket>$bucket</option>";
    }
    $body .= "</select> <input type=submit class=submit name=delete value=Delete><input type=hidden name=session value=$session_key></form>$delete_message";

    $body .= "<p><form action=/buckets><b>Rename bucket named:</b> <br><select name=oname><option value=></option>";
    foreach my $bucket (@buckets) {
        $body .= "<option value=$bucket>$bucket</option>";
    }
    $body .= "</select> <b>to</b> <input type=text name=newname> <input type=submit class=submit name=rename value=Rename><input type=hidden name=session value=$session_key></form>$rename_message";

    $body .= "<p><hr><a name=Lookup><h2>Lookup</h2><form action=/buckets#Lookup><p><b>Lookup word in corpus: </b><br><input name=word type=text> <input type=submit class=submit name=lookup value=Lookup><input type=hidden name=session value=$session_key></form>";

    if ( ( defined($form{lookup}) ) || ( defined($form{word}) ) ) {
       my $word = $classifier->{mangler}->mangle($form{word});

        $body .= "<blockquote>";

        # Don't print the headings if there are no entries.

        my $heading = "<table cellpadding=6 cellspacing=0 border=3 bordercolor=$stab_color><tr><td><b>Lookup result for $form{word}</b><p><table><tr><td><b>Bucket</b><td>&nbsp;<td><b>Frequency</b><td>&nbsp;<td><b>Probability</b><td>&nbsp;<td><b>Score</b>";

        if ( $form{word} ne '' ) {
            my $max = 0;
            my $max_bucket = '';
            my $total = 0;
            foreach my $bucket (@buckets) {
                if ( $classifier->get_value( $bucket, $word ) != 0 ) {
                    my $prob = exp($classifier->get_value( $bucket, $word ));
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
                    $total += 0.1 / $classifier->{full_total};
                }
            }

            foreach my $bucket (@buckets) {
                if ( $classifier->get_value( $bucket, $word ) != 0 ) {
                    my $prob = exp($classifier->get_value( $bucket, $word ));
                    my $n = $prob / $total;
                    my $score = log($n)/log(@buckets)+1;
                    my $normal = sprintf("%.10f", $n);
                    $score = sprintf("%.10f", $score);
                    my $probf = sprintf("%.10f", $prob);
                    my $bold = '';
                    my $endbold = '';
                    if ( $score =~ /^[^\-]/ ) {
                        $score = "&nbsp;$score";
                    }
                    $bold = "<b>" if ( $max == $prob );
                    $endbold = "</b>" if ( $max == $prob );
                    $body .= "<tr><td>$bold<font color=$classifier->{colors}{$bucket}>$bucket</font>$endbold<td><td>$bold<tt>$probf</tt>$endbold<td><td>$bold<tt>$normal</tt>$endbold<td><td>$bold<tt>$score</tt>$endbold";
                }
            }

            if ( $max_bucket ne '' ) {
                $body .= "</table><p><b>$form{word}</b> is most likely to appear in <font color=$classifier->{colors}{$max_bucket}>$max_bucket</font></table>";
            } else {
                $body .= "<p><b>$form{word}</b> does not appear in the corpus";
            }
        } else {
            $body .= "<font color=red size=+1>Please enter a non-blank word</font>";
        }

        $body .= "</blockquote>";
    }

    http_ok($client,$body,1);
}

# ---------------------------------------------------------------------------------------------
#
# compare_mf - Compares two mailfiles, used for sorting mail into order
#
# ---------------------------------------------------------------------------------------------
sub compare_mf 
{
    my $an;
    my $bn;
    
    if ( $a =~ /popfile(.*)_(.*)\.msg/ )  {
        $an = $2;
        
        if ( $b =~ /popfile(.*)_(.*)\.msg/ ) {
            $bn = $2;
    
            return ( $bn <=> $an );
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
    my ($filter, $search) = @_;
    
    my @history          = sort compare_mf glob "messages/popfile*.msg";
    $#history_cache      = -1;
    $#bucket_cache       = -1;
    $#reclassified_cache = -1;
    $#from_cache         = -1;
    $#subject_cache      = -1;
    $#magnet_cache       = -1;
    $downloaded_mail     = 0;
    my $j = 0;

    if ( $#history == -1 )  {
        $configuration{mail_count} = 0;
        $configuration{last_count} = 0;
    }

    foreach my $i ( 0 .. $#history ) {
        $history[$i] =~ /(popfile.*\.msg)/;
        $history[$i] = $1;
        my $class_file = $history[$i];
        my $magnet     = '';
        $class_file =~ s/msg$/cls/;
        open CLASS, "<messages/$class_file";
        my $bucket       = <CLASS>;
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
        
        if ( ( $filter eq '' ) || ( $bucket eq $filter ) )  {
            my $found = 1;
            
            if ( $search ne '' ) {
                $found = 0;
                
                open MAIL, "<messages/$history[$i]";
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
                $history_cache[$j]      = $history[$i];
                $bucket_cache[$j]       = $bucket;
                $reclassified_cache[$j] = $reclassified;
                $magnet_cache[$j]       = $magnet;

                $j += 1;
            }
        }
    }

    debug( "Reloaded history cache from disk" )
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
    my ($client) = @_;

    my $filtered = '';    
    if ( !defined($form{filter}) || ( $form{filter} eq '__filter__all' ) )  {
        $form{filter} = '';
    } else {
        $filtered = " (just showing bucket <font color=$classifier->{colors}{$form{filter}}>$form{filter}</font>)" if ( $form{filter} ne '' );
    }

    $filtered .= " (searched for subject $form{search})" if ( defined($form{search}) );

    my $body = ''; 

    # Handle undo
    if ( defined($form{undo}) ) {
        my %temp_words;
        
        open WORDS, "<$configuration{corpus}/$form{badbucket}/table";
        while (<WORDS>) {
            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                if ( $1 != 1 )  {
                    print "Incompatible corpus version in $form{badbucket}\n";
                    return;
                }
                
                next;
            }
            
            $temp_words{$1} = $2 if ( /(.+) (.+)/ );
        }
        close WORDS;

        $classifier->{parser}->parse_stream("messages/$form{undo}");

        foreach my $word (keys %{$classifier->{parser}->{words}}) {
            $classifier->{full_total} -= $classifier->{parser}->{words}{$word};
            $temp_words{$word}        -= $classifier->{parser}->{words}{$word};
            
            delete $temp_words{$word} if ( $temp_words{$word} <= 0 );
        }
        
        open WORDS, ">$configuration{corpus}/$form{badbucket}/table";
        print WORDS "__CORPUS__ __VERSION__ 1\n";
        foreach my $word (keys %temp_words) {
            print WORDS "$word $temp_words{$word}\n" if ( $temp_words{$word} > 0 );
        }
        close WORDS;
        $classifier->load_bucket("$configuration{corpus}/$form{badbucket}");
        $classifier->update_constants();        
        my $classification = $classifier->classify_file("messages/$form{undo}");
        my $class_file = "messages/$form{undo}";
        $class_file =~ s/msg$/cls/;
        open CLASS, ">$class_file";
        print CLASS "$classification$eol";
        close CLASS;

        $configuration{ecount} -= 1 if ( $configuration{ecount} > 0 );
        
        $downloaded_mail = 1;
    }

    # Handle clearing the history files
    if ( ( defined($form{clear}) ) && ( $form{clear} eq 'Remove All' ) ) {
        # If the history cache is empty then we need to reload it now
        load_history_cache($form{filter}, '') if ( $#history_cache < 0 );

        foreach my $mail_file (@history_cache) {
            my $class_file = $mail_file;
            $class_file =~ s/msg$/cls/;
            unlink("messages/$mail_file");
            unlink("messages/$class_file");
            debug( "Removing $mail_file because of Remove All" );
        }

        $#history_cache = -1;        
        http_redirect($client,"/history?session=$session_key&filter=$form{filter}");
        return;
    }

    if ( ( defined($form{clear}) ) && ( $form{clear} eq 'Remove Page' ) ) {
        # If the history cache is empty then we need to reload it now
        load_history_cache($form{filter}, '') if ( $#history_cache < 0 );
        
        foreach my $i ( $form{start_message} .. $form{start_message} + $configuration{page_size} - 1 ) {
            if ( $i <= $#history_cache )  {
                my $class_file = $history_cache[$i];
                $class_file =~ s/msg$/cls/;
                if ( $class_file ne '' )  {
                    unlink("messages/$history_cache[$i]");
                    unlink("messages/$class_file");
                    debug( "Removing $history_cache[$i] because of Remove Page" );
                }
            }
        }

        $#history_cache = -1;        
        http_redirect($client,"/history?session=$session_key&filter=$form{filter}");
        return;
    }

    # If we just changed the number of mail files on the disk (deleted some or added some)
    # or the history is empty then reload the history
    load_history_cache($form{filter}, '') if ( ( remove_mail_files() ) || ( $downloaded_mail ) || ( $#history_cache < 0 ) || ( defined($form{setfilter}) ) );

    # Handle the reinsertion of a message file
    if ( ( defined($form{shouldbe} ) ) && ( $form{shouldbe} ne '' ) ) {
        my %temp_words;
        
        open WORDS, "<$configuration{corpus}/$form{shouldbe}/table";
        while (<WORDS>) {
            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                if ( $1 != 1 )  {
                    print "Incompatible corpus version in $form{shouldbe}\n";
                    return;
                }
                
                next;
            }
            
            $temp_words{$1} = $2 if ( /(.+) (.+)/ );
        }
        close WORDS;

        $classifier->{parser}->parse_stream("messages/$form{file}");

        foreach my $word (keys %{$classifier->{parser}->{words}}) {
            $classifier->{full_total} += $classifier->{parser}->{words}{$word};
            $temp_words{$word}        += $classifier->{parser}->{words}{$word};
        }
        
        open WORDS, ">$configuration{corpus}/$form{shouldbe}/table";
        print WORDS "__CORPUS__ __VERSION__ 1\n";
        foreach my $word (keys %temp_words) {
           print WORDS "$word $temp_words{$word}\n" if ( $temp_words{$word} > 0 );
        }
        close WORDS;
        
        my $class_file = "messages/$form{file}";
        $class_file =~ s/msg$/cls/;
        open CLASS, ">$class_file";
        print CLASS "RECLASSIFIED$eol$form{shouldbe}$eol";
        close CLASS;
        
        $configuration{ecount} += 1 if ( $form{shouldbe} ne $form{usedtobe} );

        $classifier->load_bucket("$configuration{corpus}/$form{shouldbe}");
        $classifier->update_constants();    
        load_history_cache($form{filter},'');
    }

    my $highlight_message = '';

    load_history_cache($form{filter}, $form{search}) if ( ( defined($form{search}) ) && ( $form{search} ne '' ) );
    
    if ( $#history_cache >= 0 )  {
        my $start_message = 0;
        $start_message = $form{start_message} if ( ( defined($form{start_message}) ) && ($form{start_message} > 0 ) );
        my $stop_message  = $start_message + $configuration{page_size} - 1;

        # Verify that a message we are being asked to view (perhaps from a /jump_to_message URL) is actually between
        # the $start_message and $stop_message, if it is not then move to that message
        if ( defined($form{view}) ) {
            my $found = 0;
            foreach my $i ($start_message ..  $stop_message) {
                if ( $form{view} eq $history_cache[$i] )  {
                    $found = 1;
                    last;
                }
            }
            
            if ( $found == 0 ) {
                foreach my $i ( 0 .. $#history_cache )  {
                    if ( $form{view} eq $history_cache[$i] ) {
                        $start_message = $i;
                        $stop_message  = $i + $configuration{page_size} - 1;
                        last;
                    }
                }
            }
        }
        
        $stop_message  = $#history_cache if ( $stop_message >= $#history_cache );

        if ( $configuration{page_size} <= $#history_cache ) {
            $body .= "<table width=100%><tr><td align=left><h2>Recent Messages$filtered</h2><td align=right>Jump to message: ";
            if ( $start_message != 0 )  {
                $body .= "<a href=/history?start_message=";
                $body .= $start_message - $configuration{page_size};
                $body .= "&session=$session_key&filter=$form{filter}>< Previous</a> ";
            }
            my $i = 0;
            while ( $i <= $#history_cache ) {
                if ( $i == $start_message )  {
                    $body .= "<b>";
                    $body .= $i+1 . "</b>";
                } else {
                    $body .= "<a href=/history?start_message=$i&session=$session_key&filter=$form{filter}>";
                    $body .= $i+1 . "</a>";
                }

                $body .= " ";
                $i += $configuration{page_size};
            }
            if ( $start_message < ( $#history_cache - $configuration{page_size} ) )  {
                $body .= "<a href=/history?start_message=";
                $body .= $start_message + $configuration{page_size};
                $body .= "&session=$session_key&filter=$form{filter}>Next ></a>";
            }
            $body .= "</table>";
        } else {
            $body .="<h2>Recent Messages$filtered</h2>"; 
        }
        
        $body .= "<table width=100%><tr valign=bottom><td></td><td><b>From</b><td><b>Subject</b><td><form action=/history><input type=hidden name=session value=$session_key><select name=filter><option value=__filter__all>&lt;Show All&gt;</option>";
        
        my @buckets = sort keys %{$classifier->{total}};
        foreach my $abucket (@buckets) {
            $body .= "<option value=$abucket";
            $body .= " selected" if ( ( defined($form{filter}) ) && ( $form{filter} eq $abucket ) );
            $body .= ">$abucket</option>";
        }
        $body .= "</select><input type=submit class=submit name=setfilter value=Filter></form><b>Classification</b><td><b>Should be</b>";            

        my $stripe = 0;

        foreach my $i ($start_message ..  $stop_message) {
            my $mail_file;
            my $from = '';
            my $subject = '';
            $mail_file = $history_cache[$i];

            if ( ( $subject_cache[$i] eq '' ) || ( $from_cache[$i] eq '' ) )  {
                open MAIL, "<messages/$mail_file";
                while (<MAIL>)  {
                    if ( /[A-Z0-9]/i )  {
                        if ( /^From:(.*)/i ) {
                            if ( $from eq '' )  {
                                $from = $1;
                                $from =~ s/<(.*)>/&lt;$1&gt;/g;
                                $from =~ s/\"(.*)\"/$1/g;
                            }
                        }
                        if ( /^Subject:(.*)/i ) {
                            if ( $subject eq '' )  {
                                $subject = $1;
                                $subject =~ s/<(.*)>/&lt;$1&gt;/g;
                                $subject =~ s/\"(.*)\"/$1/g;
                            }
                        }
                    } else {
                        last;
                    }
                    
                    last if (( $from ne '' ) && ( $subject ne '' ) );
                }
                close MAIL;

                $from    = "&lt;no from line&gt;" if ( $from eq '' );
                $subject = "&lt;no subject line&gt;" if ( !( $subject =~ /[^ \t\r\n]/ ) );

                if ( length($from)>40 )  {
                    $from =~ /(.{40})/;
                    $from = "$1...";
                }

                $from =~ s/</&lt;/g;
                $from =~ s/>/&gt;/g;

                if ( length($subject)>40 )  {
                    $subject =~ s/=20/ /g;
                    $subject =~ /(.{40})/;
                    $subject = "$1...";
                }

                $subject =~ s/</&lt;/g;
                $subject =~ s/>/&gt;/g;
                
                $from_cache[$i]    = $from;
                $subject_cache[$i] = $subject;
                debug( "Got $from and $subject from disk" );
            } else {
                $from    = $from_cache[$i];
                $subject = $subject_cache[$i]; 
                debug( "Got $from and $subject from cache" );
            }
            
            # If the user has more than 4 buckets then we'll present a drop down list of buckets, otherwise we present simple
            # links

            my $drop_down = ( $#buckets > 4 );

            $body .= "<form action=/history><input type=hidden name=filter value=$form{filter}>" if ( $drop_down );
            $body .= "<a name=$mail_file>";
            $body .= "<tr";
            if ( ( ( defined($form{view}) ) && ( $form{view} eq $mail_file ) ) || ( ( defined($form{file}) && ( $form{file} eq $mail_file ) ) ) || ( $highlight_message eq $mail_file ) ) {
                $body .= " bgcolor=$highlight_color";
            } else {
                $body .= " class="; 
                $body .= $stripe?"row_even":"row_odd"; 
            }

            $stripe = 1 - $stripe;

            $body .= "><td>";
            $body .= $i+1 . "<td>";
            my $bucket       = $bucket_cache[$i];
            my $reclassified = $reclassified_cache[$i]; 
            $mail_file =~ /popfile\d+_(\d+)\.msg/;
            my $bold = ( ( $configuration{last_count} <= $1 ) && ( $reclassified == 0 ) );
            $body .= "<b>" if $bold;
            $body .= $from;
            $body .= "</b>" if $bold;
            $body .= "<td>";
            $body .= "<b>" if $bold;
            $body .= "<a href=/history?view=$mail_file&start_message=$start_message&session=$session_key&filter=$form{filter}#$mail_file>$subject</a>";
            $body .= "</b>" if $bold;
            $body .= "<td>";
            if ( $reclassified )  {
                $body .= "<font color=$classifier->{colors}{$bucket}>$bucket</font><td>Already reclassified as <font color=$classifier->{colors}{$bucket}>$bucket</font> - <a href=/history?undo=$mail_file&session=$session_key&badbucket=$bucket&filter=$form{filter}&start_message=$start_message>[Undo]</a>";
            } else {
                if ( $bucket eq 'unclassified' )  {
                    $body .= "$bucket<td>";
                } else {
                    $body .= "<font color=$classifier->{colors}{$bucket}>$bucket</font><td>";
                }

                if ( $magnet_cache[$i] eq '' )  {
                    if ( $drop_down ) {
                        $body .= " <input type=submit class=submit name=change value=Reclassify> <input type=hidden name=usedtobe value=$bucket><select name=shouldbe>";
                    } else {
                        $body .= "Classify as: ";
                    }

                    foreach my $abucket (@buckets) {
                        if ( $drop_down )  {
                            $body .= "<option value=$abucket";
                            $body .= " selected" if ( $abucket eq $bucket );
                            $body .= ">$abucket</option>"
                        } else {
                            $body .= "<a href=/history?shouldbe=$abucket&file=$mail_file&start_message=$start_message&session=$session_key&usedtobe=$bucket&filter=$form{filter}><font color=$classifier->{colors}{$abucket}>[$abucket]</font></a> ";
                        }
                    }

                    $body .= "</select><input type=hidden name=file value=$mail_file><input type=hidden name=start_message value=$start_message><input type=hidden name=session value=$session_key>" if ( $drop_down );
                } else {
                    $body .= " (Magnet used: $magnet_cache[$i])";
                }
            }

            $body .= "</td>";
            $body .= "</form>" if ( $drop_down );

            # Check to see if we want to view a message
            if ( ( defined($form{view}) ) && ( $form{view} eq $mail_file ) ) {
                $body .= "<tr><td><td colspan=3><table border=3 bordercolor=$stab_color cellspacing=0 cellpadding=6><tr><td><p align=right><a href=/history?start_message=$start_message&session=$session_key&filter=$form{filter}><b>Close</b></a><p>";
                if ( $magnet_cache[$i] eq '' )  {
                    $classifier->{parser}->{color} = 1;
                    $classifier->{parser}->{bayes} = $classifier;
                    $body .= $classifier->{parser}->parse_stream("messages/$form{view}");
                    $classifier->{parser}->{color} = 0;
                } else {
                    $magnet_cache[$i] =~ /(.+): ([^\r\n]+)/;
                    my $header = $1;
                    my $text   = $2;
                    $body .= "<tt>";

                    open MESSAGE, "<messages/$form{view}";
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
                                debug( "$head matched against $header (checking $arg against $text)" );
                                if ( $arg =~ /$text/i )  {
                                    debug( "$arg matched against $text" );
                                    $line =~ s/($text)/<b><font color=$classifier->{colors}{$bucket_cache[$i]}>$1<\/font><\/b>/;
                                }
                            }
                        }
                        
                        $body .= $line;
                    }
                    close MESSAGE;
                    $body .= "</tt>";
                }
                $body .= "<p align=right><a href=/history?start_message=$start_message&session=$session_key&filter=$form{filter}><b>Close</b></a></table><td valign=top>";
                $classifier->classify_file("messages/$form{view}");
                $body .= $classifier->{scores};
            }

            $body .= "<tr bgcolor=$highlight_color><td><td>Changed to <font color=$classifier->{colors}{$form{shouldbe}}>$form{shouldbe}</font><td><td>" if ( ( defined($form{file}) ) && ( $form{file} eq $mail_file ) );
        }

        $body .= "</table><form action=/history><input type=hidden name=filter value=$form{filter}><b>To remove entries in the history click: <input type=submit class=submit name=clear value='Remove All'>";
        $body .= "<input type=submit class=submit name=clear value='Remove Page'><input type=hidden name=session value=$session_key><input type=hidden name=start_message value=$start_message></form><form action=/history><input type=hidden name=filter value=$form{filter}><input type=hidden name=session value=$session_key>Search Subject: <input type=text name=search> <input type=submit class=submit name=searchbutton Value=Find></form>";
    } else {
        $body .= "<h2>Recent Messages$filtered</h2><p><b>No messages.</b><p><form action=/history><input type=hidden name=session value=$session_key><select name=filter><option value=__filter__all>&lt;Show All&gt;</option>";
        
        foreach my $abucket (sort keys %{$classifier->{total}}) {
            $body .= "<option value=$abucket";
            $body .= " selected" if ( ( defined($form{filter}) ) && ( $form{filter} eq $abucket ) );
            $body .= ">$abucket</option>";
        }

        $body .= "</select><input type=submit class=submit name=setfilter value=Filter></form>";
    }
    
    http_ok($client,$body,2); 
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
    my ($client, $error) = @_;
    my $session_temp = $session_key;
    
    # Show a page asking for the password with no session key information on it
    $session_key = '';
    my $body = "<h2>Password</h2><form action=/password><b>Enter password:</b> <input type=password name=password> <input type=submit class=submit name=submit value=Go!></form>";
    $body .= "<blockquote><font color=red>Incorrect password</font></blockquote>" if ( $error == 1 );
    http_ok($client, $body, 99);
    $session_key = $session_temp;
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
    my ($client, $url) = @_;

    # See if there are any form parameters and if there are parse them into the %form hash
    %form = ();

    # Remove a # element
    $url =~ s/#.*//;

    if ( $url =~ s/\?(.*)// )  {
        my $arguments = $1;
        
        while ( $arguments =~ s/(.*?)=(.*?)(&|\r|\n|$)// ) {
            my $arg = $1;
            $form{$arg} = $2;
            
            while ( ( $form{$arg} =~ /%([0-9A-F][0-9A-F])/i ) != 0 ) {
                debug( "$1" );
                my $from = "%$1";
                my $to   = chr(hex("0x$1"));
                $to =~ s/(\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\$1/g;
                $form{$arg} =~ s/$from/$to/g;
            }

            $form{$arg} =~ s/\+/ /g;

            debug( "$arg = $form{$arg}" );
        }
    }
    
    debug( $url );

    if ( $url eq '/jump_to_message' )  {
        $form{session} = $session_key;
        $url = '/history';
    }

    if ( $url =~ /\/(.+\.gif)/ ) {
        http_file( $client, $1, 'image/gif' );
        return;
    }

    if ( $url =~ /(skins\/.+\.css)/ ) {
        http_file( $client, $1, 'text/css' );
        return;
    }

    if ( $url =~ /(manual\/.+\.html)/ ) {
        http_file( $client, $1, 'text/html' );
        return;
    }

    # Check the password 
    if ( $url eq '/password' )  {
        if ( $form{password} eq $configuration{password} )  {
            $form{session} = $session_key;
            $url = '/';
        } else {
            password_page($client, 1);
            return;
        }
    }

    # If there's a password defined then check to see if the user already knows the
    # session key, if they don't then drop to the password screen
    if ( ( (!defined($form{session})) || ( $form{session} ne $session_key ) ) && ( $configuration{password} ne '' ) ) {
        password_page($client, 0);
        return;
    }

    if ( ( $url eq '/' ) || (!defined($form{session})) || ( $form{session} ne $session_key ) ) {
        %form = ();
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
        &{$url_table{$url}}($client);
        return;
    }

    if ( $url eq '/shutdown' )  {
        $alive = 0;
        http_ok($client, "POPFile shutdown", -1);
        return;
    }

    http_error($client, 404);
}

#
#
# UTILITY FUNCTIONS
#
#

# ---------------------------------------------------------------------------------------------
#
# parse_command_line - Parse ARGV
#
# The arguments are the keys of the %configuration hash.  Any argument that is not already
# defined in the hash generates an error, there must be an even number of ARGV elements because
# each command argument has to have a value.
#
# ---------------------------------------------------------------------------------------------
sub parse_command_line  
{
    # It's ok for the command line to be blank, the values of %configuration will be drawn from
    # the default values defined at the start of the code and those read from the configuration
    # file
    
    if ( $#ARGV >= 0 )  {
        my $i = 0;
        
        while ( $i < $#ARGV )  {
            # A command line argument must start with a -
            
            if ( $ARGV[$i] =~ /^-(.+)$/ ) {
                if ( defined($configuration{$1}) ) {
                    if ( $i < $#ARGV ) {
                        $configuration{$1} = $ARGV[$i+1];
                        $i += 2;
                    } else {
                        print "Missing argument for $ARGV[$i]\n";
                        last;
                    }
                } else {
                    print "Unknown command line option $ARGV[$i]\n";
                    last;
                }
            } else {
                print "Expected a command line option and got $ARGV[$i]\n";
                last;
            }
        }
    }
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
    @skins = glob 'skins/*.css';
    
    for my $i (0..$#skins) {
        $skins[$i] =~ s/.*\/(.+)\.css/$1/;
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_configuration
#
# Loads the current configuration of popfile into the %configuration hash from a local file.  
# The format is a very simple set of lines containing a space separated name and value pair
#
# ---------------------------------------------------------------------------------------------
sub load_configuration 
{
    if ( open CONFIG, "<popfile.cfg" ) {
        while ( <CONFIG> ) {
            if ( /(\S+) (.+)/ ) {
                $configuration{$1} = $2;
            }
        }
        
        close CONFIG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# save_configuration
#
# Saves the current configuration of popfile from the %configuration hash to a local file.
#
# ---------------------------------------------------------------------------------------------
sub save_configuration 
{
    if ( open CONFIG, ">popfile.cfg" ) {
        foreach my $key (keys %configuration) {
            print CONFIG "$key $configuration{$key}\n";
        }
        
        close CONFIG;
    }

    $classifier->write_parameters();
}

# ---------------------------------------------------------------------------------------------
#
# remove_debug_files
#
# Removes popfile log files that are older than 3 days
#
# ---------------------------------------------------------------------------------------------
sub remove_debug_files 
{
    my @debug_files = glob "popfile*.log";

    calculate_today();
    
    foreach my $debug_file (@debug_files) {
        # Extract the epoch information from the popfile log file name
        
        if ( $debug_file =~ /popfile([0-9]+)\.log/ )  {
            # If older than now - 3 days then delete

            if ( $1 < (time - 3 * $seconds_per_day) )  {
                unlink($debug_file);
            }
        }
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
    my @mail_files = glob "messages/popfile*.msg";
    my $result = 0;

    calculate_today();
    
    foreach my $mail_file (@mail_files) {
        # Extract the epoch information from the popfile mail file name
        
        if ( $mail_file =~ /popfile([0-9]+)_([0-9]+)\.msg/ )  {
            # If older than now - some number of days then delete

            if ( $1 < (time - $configuration{history_days} * $seconds_per_day) )  {
                my $class_file = $mail_file;
                $class_file =~ s/msg$/cls/;
                unlink($mail_file);
                unlink($class_file);
                $result = 1;
            }
        }
    }
    
    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# debug
#
# $message    A string containing a debug message that may or may not be printed
#
# Prints the passed string if the global $debug is true
#
# ---------------------------------------------------------------------------------------------
sub debug 
{
    my ( $message ) = @_;
    
    if ( $configuration{debug} > 0 ) {
        # Check to see if we are handling the USER/PASS command and if we are then obscure the
        # account information
        if ( $message =~ /((--)?)(USER|PASS)\s+\S*(\1)/ )  {
            $message = "$`$1$3 XXXXXX$4";
        }
        
        chomp $message;
        $message .= "\n";

        my $now = localtime;
        my $msg = "$now: $message";
        
        if ( $configuration{debug} & 1 )  {
            open DEBUG, ">>$debug_filename";
            binmode DEBUG;
            print DEBUG $msg;
            close DEBUG;
        }
        
        if ( $configuration{debug} & 2 ) {
            print $msg;
        }
    }
}

# ---------------------------------------------------------------------------------------------
# 
# tee
#
# $socket   The stream (created with IO::) to send the string to
# $text     The text to output
#
# Sends $text to $socket and sends $text to debug output
#
# ---------------------------------------------------------------------------------------------
sub tee 
{
    my ( $socket, $text ) = @_;

    # Send the message to the debug output and then send it to the appropriate socket
    debug( $text ); 
    print $socket $text if $socket->connected;
}

# ---------------------------------------------------------------------------------------------
#
# get_response
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $command  The text of the command to send (we add an EOL)
#
# Send $command to $mail, receives the response and echoes it to the $client and the debug 
# output.  Returns the response
#
# ---------------------------------------------------------------------------------------------
sub get_response 
{
    my ( $mail, $client, $command ) = @_;
    
    unless ( $mail ) {
       # $mail is undefined - return an error intead of crashing
       tee( $client, "-ERR error communicating with mail server$eol" );
       return "-ERR";
    }

    # Send the command (followed by the appropriate EOL) to the mail server
    tee( $mail, $command. $eol );
    
    my $response;
    
    # Retrieve a single string containing the response
    if ( $mail->connected ) {
        $response = <$mail>;
        
        if ( $response ) {
            # Echo the response up to the mail client
            tee( $client, $response );
        } else {
            # An error has occurred reading from the mail server
            tee( $client, "-ERR no response from mail server" );
            return "-ERR";
        }
    }
    
    return $response;
}

# ---------------------------------------------------------------------------------------------
#
# echo_response
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $command  The text of the command to send (we add an EOL)
#
# Send $command to $mail, receives the response and echoes it to the $client and the debug 
# output.  Returns true if the response was +OK and false if not
#
# ---------------------------------------------------------------------------------------------
sub echo_response 
{
    my ( $mail, $client, $command ) = @_;
    
    my $response = get_response( $mail, $client, $command );
    
    # Determine whether the response began with the string +OK.  If it did then return 1
    # else return 0
    return ( $response =~ /^\+OK/ );
}

# ---------------------------------------------------------------------------------------------
#
# echo_to_dot
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
#
# echo all information from the $mail server until a single line with a . is seen
#
# ---------------------------------------------------------------------------------------------
sub echo_to_dot 
{
    my ($mail, $client) = @_;
    
    while ( <$mail> ) {
        # Check for an abort
        if ( $alive == 0 ) {
            last;
        }

        print $client $_;

        # The termination has to be a single line with exactly a dot on it and nothing
        # else other than line termination characters.  This is vital so that we do
        # not mistake a line beginning with . as the end of the block
        if ( /^\.(\r\n|\r|\n)$/ ) {   
            last;
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# verify_connected
#
# $mail        The handle of the real mail server
# $client      The handle to the mail client
# $hostname    The host name of the remote server
# $port        The port
#
# Check that we are connected to $hostname on port $port putting the open handle in $mail.
# Any messages need to be sent to $client
#
# ---------------------------------------------------------------------------------------------
sub verify_connected 
{
    my ($client, $hostname, $port) = @_;
    
    calculate_today();
    
    # Check to see if we are already connected
    if ( $mail ) {
        if ( $mail->connected )  {
            return 1;
        }
    }
    
    # Connect to the real mail server on the standard port
    $mail = IO::Socket::INET->new(
                Proto    => "tcp",
                PeerAddr => $hostname,
                PeerPort => $port );

    # Check that the connect succeeded for the remote server
    if ( $mail ) {                 
        if ( $mail->connected )  {
            # Wait 10 seconds for a response from the remote server and if 
            # there isn't one then give up trying to connect
            my $selector = new IO::Select( $mail );
            last unless () = $selector->can_read($configuration{timeout});
            
            # Read the response from the real server and say OK
            my $buf        = '';
            my $max_length = 8192;
            my $n          = sysread( $mail, $buf, $max_length, length $buf );
            
            debug( "Connection returned: $buf" );
            if ( !( $buf =~ /[\r\n]/ ) ) {
                for my $i ( 0..4 ) {
                    flush_extra( $mail, $client, 1 );
                }
            }
            return 1;
        }
    }

    # Tell the client we failed
    tee( $client, "-ERR failed to connect to $hostname:$port$eol" );
    
    return 0;
}

# ---------------------------------------------------------------------------------------------
#
# flush_extra - Read extra data from the mail server and send to client, this is to handle
#               POP servers that just send data when they shouldn't.  I've seen one that sends
#               debug messages!
#
# $mail        The handle of the real mail server
# $client      The mail client talking to us
# $discard     If 1 then the extra output is discarded
#
# ---------------------------------------------------------------------------------------------
sub flush_extra 
{
    my ($mail, $client, $discard) = @_;
    
    if ( $mail ) {
        if ( $mail->connected ) {
            my $selector   = new IO::Select( $mail );
            my $buf        = '';
            my $max_length = 8192;

            while( 1 ) {
                last unless () = $selector->can_read(0.1);
                unless( my $n = sysread( $mail, $buf, $max_length, length $buf ) ) {
                    last;
                }

                if ( $discard != 1 ) {
                    tee( $client, $buf );
                }
            }
        }
    }
}

#
#
# POP3 PROXY
#
#

# ---------------------------------------------------------------------------------------------
#
# run_popfile - a POP3 proxy server 
#
# ---------------------------------------------------------------------------------------------
sub run_popfile 
{
    # Listen for connections on our port 110 (or a user specific port)
    my $listen_port    = $configuration{port};
    my $connect_server = $configuration{server};
    my $connect_port   = $configuration{sport};
    my $ui_port        = $configuration{ui_port};
    
    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                    $configuration{localpop} == 1 ? (LocalAddr => 'localhost') : (), 
                                    LocalPort => $listen_port,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 ) or die "Couldn't open the POP3 listen port $listen_port";
    
    my $ui     = IO::Socket::INET->new( Proto     => 'tcp',
                                    $configuration{localui}  == 1 ? (LocalAddr => 'localhost') : (), 
                                     LocalPort => $ui_port,
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 ) or die "Couldn't open the GUI port $ui_port";

    # This is used to perform select calls on the $server socket so that we can decide when there is 
    # a call waiting an accept it without having to block
    my $selector   = new IO::Select( $server );
    my $uiselector = new IO::Select( $ui     );
    
    print "POPFile Engine v$major_version.$minor_version.$build_version ready\n";
    
    # Accept a connection from a client trying to use us as the mail server.  We service one client at a time
    # and all others get queued up to be dealt with later.  We check the alive boolean here to make sure we
    # are still allowed to operate
    while ( $alive ) {
        # See if there's a connection waiting on the $server by getting the list of handles with data to
        # read, if the handle is the server then we're off.  Note the 0.1 second delay here when waiting
        # around.  This means that we don't hog the processor while waiting for connections.
        my ($ready)   = $selector->can_read(0.1);
        my ($uiready) = $uiselector->can_read(0.1);

        # Handle HTTP requests for the UI
        if ( ( defined($uiready) ) && ( $uiready == $ui ) ) {
            if ( my $client = $ui->accept() ) {
                # Check that this is a connection from the local machine, if it's not then we drop it immediately
                # without any further processing.  We don't want to allow remote users to admin POPFile
                my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

                if ( ( $configuration{localui} == 0 ) || ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {
                    if ( ( defined($client) ) && ( my $request = <$client> ) ) {
                        debug( $request );
                        while ( <$client> )  {
                            if ( !/(.*): (.*)/ )  {
                                last;
                            }
                        }

                        if ( $request =~ /GET (.*) HTTP\/1\./ ) {
                            handle_url($client, $1);
                        } else {
                            http_error($client, 500);
                        }                  
                    }
                }
                
                close $client;
                
                # Check for a possible abort
                if ( $alive == 0 ) {
                    last;
                }
            }
        }
        
        # If the $server is ready then we can go ahead and accept the connection
        if ( ( defined($ready) ) && ( $ready == $server ) ) {
        if ( my $client = $server->accept() ) {
        # Check that this is a connection from the local machine, if it's not then we drop it immediately
        # without any further processing.  We don't want to act as a proxy for just anyone's email
        my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

        if  ( ( $configuration{localpop} == 0 ) || ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {
            # Tell the client that we are ready for commands and identify our version number
            tee( $client, "+OK POP3 POPFile (v$major_version.$minor_version.$build_version) server ready$eol" );
            
            my $current_count = $configuration{mail_count};

            # Retrieve commands from the client and process them until the client disconnects or
            # we get a specific QUIT command
            while  ( <$client> ) {
                my $command;

                $command = $_;
                
                # Clean up the command so that it has a nice clean $eol at the end
                $command =~ s/(\015|\012)//g;

                debug( "Command: --$command--" );
 
                # Check for a possible abort
                if ( $alive == 0 ) {
                    last;
                }

                # The USER command is a special case because we modify the syntax of POP3 a little
                # to expect that the username being passed is actually of the form host:username where
                # host is the actual remote mail server to contact and username is the username to 
                # pass through to that server and represents the account on the remote machine that we
                # will pull email from.  Doing this means we can act as a proxy for multiple mail clients
                # and mail accounts
                if ( $command =~ /USER (.+)(:(\d+))?$configuration{separator}(.+)/i ) {
                    debug( "USER command [$1] [$2] [$3] [$4]" );

                    if ( $1 ne '' )  {
                        if ( verify_connected( $client, $1, $3 || 110 ) )  {
                            $lastuser = $4;

                            # Pass through the USER command with the actual user name for this server,
                            # and send the reply straight to the client
                            echo_response( $mail, $client, 'USER ' . $4 );
                        } else {
                            last;
                        }
                    } else {
                        tee( $client, "-ERR server name not specified in USER command$eol" );
                        last;
                    }

                    flush_extra( $mail, $client, 0 );
                    next;
                }

                # User is issuing the APOP command to start a session with the remote server
                if ( $command =~ /APOP (.*):((.*):)?(.*) (.*)/i ) {
                    if ( verify_connected( $client,  $1, $3 || 110 ) )  {
                        $lastuser = $4;
                        
                        # Pass through the USER command with the actual user name for this server,
                        # and send the reply straight to the client
                        echo_response( $mail, $client, "APOP $4 $5" );
                    } else {
                        last;
                    }

                    flush_extra( $mail, $client, 0 );
                    next;
                }

                # Secure authentication
                if ( $command =~ /AUTH ([^ ]+)/ ) {
                    if ( $connect_server ne '' )  {
                        if ( verify_connected( $client,  $connect_server, $connect_port ) )  {
                            # Loop until we get -ERR or +OK
                            my $response;
                            $response = get_response( $mail, $client, $command );

                            while ( ( ! ( $response =~ /\+OK/ ) ) && ( ! ( $response =~ /-ERR/ ) ) ) {
                                # Check for an abort
                                if ( $alive == 0 ) {
                                    last;
                                }

                                my $auth;
                                $auth = <$client>;
                                $auth =~ s/(\015|\012)$//g;
                                $response = get_response( $mail, $client, $auth );
                            }
                        } else {
                            last;
                        }

                        flush_extra( $mail, $client, 0 );
                    } else {
                        tee( $client, "-ERR No secure server specified$eol" );
                    }
                    
                    next;
                }

                if ( $command =~ /AUTH/ ) {
                    if ( $connect_server ne '' )  {
                        if ( verify_connected( $client,  $connect_server, $connect_port ) )  {
                            if ( echo_response( $mail, $client, "AUTH" ) ) {
                                echo_to_dot( $mail, $client );
                            }
                        } else {
                            last;
                        }

                        flush_extra( $mail, $client, 0 );
                    } else {
                        tee( $client, "-ERR No secure server specified$eol" );
                    }

                    next;
                }

                # The client is requesting a LIST/UIDL of the messages
                if ( ( $command =~ /LIST ?(.*)?/i ) ||
                     ( $command =~ /UIDL ?(.*)?/i ) ) {
                    if ( echo_response( $mail, $client, $command ) ) {
                        if ( $1 eq '' )  {
                            echo_to_dot( $mail, $client );
                        }
                    }

                    flush_extra( $mail, $client, 0 );
                    next;
                }

                # Note the horrible hack here where we detect a command of the form TOP x 99999999 this
                # is done so that fetchmail can be used with POPFile.  
                if ( $command =~ /TOP (.*) (.*)/i ) {
                    if ( $2 ne '99999999' )  {                    
                        if ( echo_response( $mail, $client, $command ) ) {
                            echo_to_dot( $mail, $client );
                        }

                        flush_extra( $mail, $client, 0 );
                        next;
                    }
                }

                # The CAPA command
                if ( $command =~ /CAPA/i ) {
                    if ( verify_connected( $client, $connect_server, $connect_port ) )  {
                        # Perform a LIST command on the remote server
                        if ( echo_response( $mail, $client, "CAPA" ) ) {
                            echo_to_dot( $mail, $client );
                        }
                    }
                    
                    flush_extra( $mail, $client, 0 );
                    next;
                }                

                # The HELO command results in a very simple response from us.  We just echo that
                # we are ready for commands
                if ( $command =~ /HELO/i ) {
                    tee( $client, "+OK HELO POPFile Server Ready$eol" );
                    next;
                }

                # In the case of PASS, NOOP, XSENDER, STAT, DELE and RSET commands we simply pass it through to 
                # the real mail server for processing and echo the response back to the client
                if ( ( $command =~ /PASS (.*)/i )    || 
                     ( $command =~ /NOOP/i )         ||
                     ( $command =~ /STAT/i )         ||
                     ( $command =~ /XSENDER (.*)/i ) ||
                     ( $command =~ /DELE (.*)/i )    ||
                     ( $command =~ /RSET/i ) ) {
                    echo_response( $mail, $client, $command );
                    flush_extra( $mail, $client, 0 );
                    next;
                }

                # The client is requesting a specific message.  
                # Note the horrible hack here where we detect a command of the form TOP x 99999999 this
                # is done so that fetchmail can be used with POPFile.  
                if ( ( $command =~ /RETR (.*)/i ) || ( $command =~ /TOP (.*) 99999999/i ) )  {
                    # Get the message from the remote server, if there's an error then we're done, but if not then
                    # we echo each line of the message until we hit the . at the end
                    if ( echo_response( $mail, $client, $command ) ) { 
                        my $msg_subject;        # The message subject
                        my $msg_head_before;    # Store the message headers that come before Subject here
                        my $msg_head_after;     # Store the message headers that come after Subject here
                        my $msg_body;           # Store the message body here
                        my $last_timeout   = time;
                        my $timeout_count  = 0;
                        my $got_full_body  = 0;
                        my $message_size   = 0;
                        my $classification = '';

                        my $getting_headers = 1;

                        my $temp_file = "messages/$mail_filename" . "_$configuration{mail_count}.msg";
                        my $class_file = "messages/$mail_filename" . "_$configuration{mail_count}.cls";
                        $configuration{mail_count} += 1;
                        $configuration{mcount}     += 1;
                        $downloaded_mail            = 1;

                        open TEMP, ">$temp_file";

                        while ( <$mail> ) {   
                            my $line;

                            $line = $_;

                            # Check for an abort
                            if ( $alive == 0 ) {
                                last;
                            }

                            # The termination of a message is a line consisting of exactly .CRLF so we detect that
                            # here exactly
                            if ( $line =~ /^\.(\r\n|\r|\n)$/ ) {
                                $got_full_body = 1;
                                last;
                            }

                            if ( $getting_headers )  {
                                if ( $line =~ /[A-Z0-9]/i )  {
                                    $message_size += length $line;                                        
                                    print TEMP $line;

                                    if ( $configuration{subject} )  {
                                        if ( $line =~ /Subject:(.*)/i )  {
                                            $msg_subject = $1;
                                            $msg_subject =~ s/(\012|\015)//g;
                                            next;
                                        } 
                                    }

                                    # Strip out the X-Text-Classification header that is in an incoming message
                                    if ( ( $line =~ /X-Text-Classification: /i ) == 0 ) {
                                        if ( $msg_subject eq '' )  {
                                            $msg_head_before .= $line;
                                        } else {
                                            $msg_head_after  .= $line;
                                        }
                                    }
                                } else {
                                    $getting_headers = 0;
                                }
                            } else {
                                $message_size += length $line;
                                print TEMP $line;
                                $msg_body .= $line;
                            }

                            # Check to see if too much time has passed and we need to keep the mail client happy
                            if ( time > ( $last_timeout + 2 ) ) {
                                print $client "X-POPFile-TimeoutPrevention: $timeout_count$eol";
                                $timeout_count += 1;
                                $last_timeout = time;
                            }

                            if ( ( $message_size > 100000 ) && ( $getting_headers == 0 ) ) {
                                last;
                            }
                        }

                        close TEMP;

                        # Do the text classification and parse the result
                        $classification = $classifier->classify_file($temp_file);

                        if ( $classification ne 'unclassified' ) {
                            $classifier->{parameters}{$classification}{count} += 1;
                        }

                        debug ("Classification: $classification" );

                        # Add the spam header
                        if ( $configuration{subject} ) {
                            # Don't add the classification unless it is not present
                            if ( !( $msg_subject =~ /\[$classification\]/ ) && ( $classifier->{parameters}{$classification}{subject} == 1 ) )  {
                                $msg_head_before .= "Subject: [$classification]$msg_subject$eol";
                            } else {
                                $msg_head_before .= "Subject:$msg_subject$eol";
                            }
                        }

                        $msg_head_after .= "X-Text-Classification: $classification$eol" if ( $configuration{xtc} );
                        $temp_file =~ s/messages\/(.*)/$1/;
                        
                        if ( $configuration{xpl} ) {
                            $msg_head_after .= "X-POPFile-Link: http://";
                            $msg_head_after .= $configuration{localpop}?"127.0.0.1":$hostname;
                            $msg_head_after .= ":$configuration{ui_port}/jump_to_message?view=$temp_file$eol";
                        }
                        
                        $msg_head_after .= "$eol";

                        # Echo the text of the message to the client
                        print $client $msg_head_before;
                        print $client $msg_head_after;
                        print $client $msg_body;

                        if ( $got_full_body == 0 )    {   
                            echo_to_dot( $mail, $client );   
                        } else {   
                            print $client ".$eol";    
                        } 

                        open CLASS, ">$class_file";
                        if ( $classifier->{magnet_used} == 0 )  {
                            print CLASS "$classification$eol";
                        } else {
                            print CLASS "$classification MAGNET $classifier->{magnet_detail}$eol";
                        }
                        close CLASS;

                        $configuration{last_count} = $current_count;

                    flush_extra( $mail, $client, 0 );
                    next;
                    }
                }

                # The mail client wants to stop using the server, so send that message through to the
                # real mail server, echo the response back up to the client and exit the while.  We will
                # close the connection immediately
                if ( $command =~ /QUIT/i ) {
                    if ( $mail )  {
                        echo_response( $mail, $client, $command );
                        close $mail;
                    } else {
                        tee( $client, "+OK goodbye" );
                    }
                    last;
                }

                # Don't know what this is so let's just pass it through and hope for the best
                if ( $mail && $mail->connected )  {
                    if ( echo_response( $mail, $client, $command ) ) {
                        flush_extra( $mail, $client, 0 );
                        next;
                    }
                } else {
                    tee( $client, "-ERR unknown command or bad syntax$eol" );
                    last;
                }
            }
        }

        # Close the connection with the client and get ready to accept a new connection
        close $client;
        if ( $mail )  {
            close $mail;
            undef $mail;
        }

        save_configuration();
       }
    }
    }
}

# ---------------------------------------------------------------------------------------------
#
# calculate_today - set the global $today variable to the current day in seconds
#
# ---------------------------------------------------------------------------------------------
sub calculate_today 
{
    # Create the name of the debug file for the debug() function
    $today = int( time / $seconds_per_day ) * $seconds_per_day;
    $debug_filename = "popfile$today.log";
    $mail_filename  = "popfile$today";
}

# ---------------------------------------------------------------------------------------------
#
# aborting    
#
# Called if we are going to be aborted or are being asked to abort our operation. Sets the 
# alive flag to 0 that will cause us to abort at the next convenient moment
#
# ---------------------------------------------------------------------------------------------
sub aborting 
{
    debug("Aborting because of signal from operating system/user");
    $alive = 0;
}

#
#
# MAIN
#
#

print "POPFile Engine v$major_version.$minor_version.$build_version starting\n";

$SIG{ABRT}  = \&aborting;
$SIG{TERM}  = \&aborting;
$SIG{INT}   = \&aborting;

calculate_today();

# Set up reasonable defaults for the configuration parameters.  These may be 
# overwritten immediately when we read the configuration file
$configuration{debug}                       = 1;
$configuration{port}                        = 110;
$configuration{ui_port}                     = 8080;
$configuration{subject}                     = 1;
$configuration{xtc}                         = 1;
$configuration{xpl}                         = 1;
$configuration{update_check}                = 1;
$configuration{send_stats}                  = 0;
$configuration{server}                      = '';
$configuration{sport}                       = 110;
$configuration{page_size}                   = 20;
$configuration{timeout}                     = 60;
$configuration{localpop}                    = 1;
$configuration{localui}                     = 1;
$configuration{mcount}                      = 0;
$configuration{ecount}                      = 0;
$configuration{separator}                   = ':';
$configuration{skin}                        = 'default';
$configuration{history_days}                = 2;
$configuration{corpus}                      = 'corpus';
$configuration{unclassified_probability}    = 0;
$configuration{last_update_check}           = 0;
$configuration{password}                    = '';
$configuration{last_reset}                  = 'never';

# Load skins
load_skins();

# Calculate a session key
$session_key = '';
for my $i (0 .. 7) {
    $session_key .= chr(rand(1)*26+65);
}

# Ensure that the messages subdirectory exists
mkdir( 'messages' );

print "    Loading configuration\n";

# Load the current configuration from disk
load_configuration();

# Handle the command line
parse_command_line();

print "    Cleaning stale log files\n";

# Remove old log files
remove_debug_files();
remove_mail_files();

print "    Loading buckets...\n";

# Get the classifier
$classifier = new Classifier::Bayes;
if ( $configuration{unclassified_probability} != 0 )  {
    $classifier->{unclassified} = $configuration{unclassified_probability};
}
$classifier->load_word_matrix();

# Get the hostname for use in the X-POPFile-Link header
$hostname = hostname;

debug( "POPFile Engine v$major_version.$minor_version.$build_version running" );

# Run the POP server and handle requests
run_popfile();

print "    Saving configuration\n";

# Write the final configuration to disk
save_configuration();

print "POPFile Engine v$major_version.$minor_version.$build_version terminating\n";

# ---------------------------------------------------------------------------------------------
