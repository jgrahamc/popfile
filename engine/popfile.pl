# ---------------------------------------------------------------------------------------------
#
# popfile.pl --- POP3 mail analyzer and sorter
#
# Acts as a POP3 server and client designed to sit between a real mail client and a real mail
# server using POP3.  Inserts an extra header X-Text-Classification: into the mail header to 
# tell the client whether the mail is spam or not based on a text classification algorithm
#
# Copyright (c) 2001-2002 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;

# We need the Win32 GUI module to put an icon in the system tray
use Win32::GUI;

# We need to be able to start subprocesses
use Win32::Process;

# This version number
my $major_version = 0;
my $minor_version = 7;

# A list of the messages currently on the server, each entry in this list
# is a hash containing the following items
#
# server_number  The number of this message on the server
# size           The size of this messag
# deleted        Whether this message has been deleted
# nag        Whether this message is a special nag message
my @messages;

# A mapping between the message numbers that we will provide and message
# numbers on the server
my @message_map;

# The total number of messages that are available for download
my $message_count = 0;

# The total size of all the messages available for download
my $total_size = 0;

# The number of the highest message
my $highest_message = 0;

# 1 if we want debug messages
my $debug = 1;

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

# Boolean to determine whether we have checked registration
# And flag to see whether we are registered or not
my $registration_checked = 0;
my $registered           = 0;

# The nag message
my $nag_message;

# A handy boolean that tells us whether we are alive or not.  When this is set to 1 then the
# proxy works normally, when set to 0 (typically by the aborting() function called from a signal)
# then we will terminate gracefully
my $alive = 1;

# This will hold the handle of the actual mail server that the client is trying to reach
# we are acting as a simple proxy
my $mail;

# Handle to the rainbow process
my $rainbow_process;

# All used for the systray icon
my $main;
my $ni;
my $icon;
    
# ---------------------------------------------------------------------------------------------
#
# load_configuration -  Loads the current configuration of popfile into the %configuration
#           hash from a local file.  The format is a very simple set of lines
#           containing a space separated name and value pair
#
# ---------------------------------------------------------------------------------------------
sub load_configuration
{
    if ( open CONFIG, "<popfile.cfg" )
    {
        while ( <CONFIG> )
        {
            if ( /(\S+) (\S+)/ )
            {
                $configuration{$1} = $2;
            }
        }
        
        close CONFIG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# unregistered_version
#
# Determines whether the user is using an unregistered version of the software.  Returns 1
# if the software is not registered
#
# ---------------------------------------------------------------------------------------------
sub unregistered_version
{
    # If we've already checked then just return the flag
    if ( $registration_checked == 0 )
    {
        $registered = 0;
        
        # Open the license file and check its validity
        if ( open LICENSE, "<popfile.lic" )
        {
            my $key      = <LICENSE>;
            $key =~ s/\s//go;
            close LICENSE;

            if ( length($key) == 12 )
            {
                my $odds;
                my $evens;
                my $product;
                
                $odds  = substr($key,0,1) + substr($key,2,1) + substr($key,4,1) + substr($key,6,1) + substr($key,8,1) + substr($key,10,1);
                $evens = substr($key,1,1) + substr($key,3,1) + substr($key,5,1) + substr($key,7,1) + substr($key,9,1);
                
                $product = ($odds * 3 + $evens) % 10;
                
                if ( $product == substr($key,11,1) )
                {
                    $registered = 1;
                }
            }
        }
        else
        {
            $registered = 1;
        }
        
        $registration_checked = 1;
    }
    
    return $registered;
}

# ---------------------------------------------------------------------------------------------
#
# save_configuration -  Saves the current configuration of popfile from the %configuration
#           hash to a local file.
#
# ---------------------------------------------------------------------------------------------
sub save_configuration
{
    if ( open CONFIG, ">popfile.cfg" )
    {
        foreach my $key (keys %configuration)
        {
            print CONFIG "$key $configuration{$key}\n";
        }
        
        close CONFIG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# debug - print debug messages
#
# $_    A string containing a debug message that may or may not be printed
#
# Prints the passed string if the global $debug is true
#
# ---------------------------------------------------------------------------------------------
sub debug
{
    my ( $message ) = @_;
    
    if ( $debug )
    {
        # Check to see if we are handling the USER/PASS command and if we are then obscure the
        # account information
        if ( $message =~ /(USER|PASS)/ ) 
        {
            $message = "$1 XXXXXX\n";
        }
        
        open DEBUG, ">>popfile.log";
        binmode DEBUG;
        my $now = localtime;
        print DEBUG $now;
        print DEBUG ": ";
        print DEBUG $message;
        close DEBUG;
    }
}

# ---------------------------------------------------------------------------------------------
# 
# tee - outputs a string to a stream and the debug
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
# get_response - send a message to a remote server and echo the response to a local client
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
    
    # Send the command (followed by the appropriate EOL) to the mail server
    tee( $mail, "$command$eol" );
    
    my $response;
    
    # Retrieve a single string containing the response
    if ( $mail->connected )
    {
        $response = <$mail>;
        
        if ( $response )
        {
            # Echo the response up to the mail client
            tee( $client, $response );
        }
        else
        {
            # An error has occurred reading from the mail server
            tee( $client, "-ERR error communicating with mail server" );
            return 0;
        }
    }
    
    return $response;
}

# ---------------------------------------------------------------------------------------------
#
# echo_response - send a message to a remote server and echo the response to a local client
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
# echo_to_dot - echo all information from the $mail server until a single line with a . is seen
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
#
# ---------------------------------------------------------------------------------------------
sub echo_to_dot
{
    my ($mail, $client) = @_;
    
    while ( <$mail> )
    {
        # Check for an abort
        if ( $alive == 0 )
        {
            last;
        }

        debug( "etd: $_" ); 

        print $client $_;

        if ( /^\.\r\n/ )
        {   
            last;
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# add_mail_message - Called to add a mail message to the list of available messages
#
# $number       The message number from the remote server
# $size         The size of the message
# $nag          1 if this is the nag message, 0 for a normail message
#
# ---------------------------------------------------------------------------------------------
sub add_mail_message
{
    my ( $number, $size, $nag ) = @_;
    
    $message_count   += 1;
    $total_size      += $size;
    $highest_message += 1;

    $messages[$message_count]{'server_number'} = $number;
    $messages[$message_count]{'size'}          = $size + 90; 
    $messages[$message_count]{'deleted'}       = 0;
    $messages[$message_count]{'nag'}           = $nag;
    $messages[$message_count]{'uidl'}          = "popfile-uidl";
    $message_map[$message_count]               = $message_count;
}

# ---------------------------------------------------------------------------------------------
#
# verify_have_list - Called to check that we have downloaded the list of messages from the mail
#          server and done the sort on them.  In addition if we are using an 
#          unregistered version of the software then we insert a nag message into the
#          list of messages
#
# $mail        The handle of the real mail server
# $client      The mail client talking to us
#
# ---------------------------------------------------------------------------------------------
sub verify_have_list
{
    my ( $mail, $client ) = @_;
    
    if ( $message_count == 0 )
    {
        # Perform a LIST command on the remote server
        tee( $mail, "LIST$eol" );
    
        $highest_message = 0;
        $total_size      = 0;

        # Start reading each line of the response to the LIST command up to the .       
        while ( <$mail> )
        {
            debug( $_ );
            
            # The first line should be a +OK with the information about the number of messages
            # We don't need this and we simply ignore it
            if ( /\+OK/i )
            {
                next;
            }
            
            # If we get a -ERR then we stop right here since something has gone wrong
            if ( /\-ERR/i )
            {
                print $client $_;
                return 0;
            }

            
            # When we find the . on its own then we are at the end of the list and so we check
            # to see whether we need to be adding the nag message so that people buy the software
            # and exit the loop
            if ( /^\./ )
            {   
                # If we are running and unregistered version then add the magic nag message
                if ( unregistered_version() )
                {
                    # If unregistered then we keep track of how many messages we've optimized so that the user
                    # is impressed when we send them an email outlining how much they've used the software.  That's
                    # the $nag_message
                    $configuration{'messages'} += $message_count;
                    
                    # Only nag the user if they've got mail otherwise they'll go insane
                    # with too many messages.
                    if ( $message_count > 0 )
                    {
                        $nag_message      = "From: popfile\@jgc.org$eol" . "Subject: POPFile used $configuration{'used'} times$eol$eol" . "Please consider registering POPFile.  POPFile has optimized $configuration{'messages'} messages.$eol$eol.$eol";
                        
                        add_mail_message( 0, length $nag_message, 1 );
                    }
                }
                
                last;
            }
            
            # If the message is of the form one number followed by another then its a message with its
            # length and so we add it to the list of messages and continue
            if ( /(\d+) (\d+)/ )
            {
                add_mail_message( $1, $2, 0 );
            }
        }
        
        # Sort the message_map using the sizes of the messages stored in @messages.  The sort is
        # done in ascending order so that messages will be retrieved in ascending order by size
        @message_map = sort {$messages[$a]{'size'} <=> $messages[$b]{'size'} } @message_map;
    }
    
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# verify_have_uidl - Called to check that we have downloaded the list of UIDLs
#
# $mail        The handle of the real mail server
# $client      The mail client talking to us
#
# ---------------------------------------------------------------------------------------------
sub verify_have_uidl
{
    my ( $mail, $client ) = @_;

    if ( $done_uidl ) 
    {
        return 1;
    }

    if ( verify_have_list( $mail, $client ) )
    {
        # Perform a UIDL command, get the UIDLs for each message and store them in the
        # list of messages
        tee( $mail, "UIDL$eol" );
    
        # Start reading each line of the response to the LIST command up to the .       
        while ( <$mail> )
        {
            debug( $_ );
            
            # The first line should be a +OK with the information about the number of messages
            # We don't need this and we simply ignore it
            if ( /\+OK/i )
            {
                next;
            }
            
            # If we get a -ERR then we stop right here since something has gone wrong
            if ( /\-ERR/i )
            {
                print $client $_;
                return 0;
            }
            
            if ( /^\./ )
            {   
                last;
            }

            # This gets the UIDL for a message            
            if ( /(\d+) (.+)/ )
            {
                for ( my $i = 0; $i <= $highest_message; $i++ )
                {
                    if ( $messages[$message_map[$i]]{'server_number'} == $1 )
                    {
                        $messages[$message_map[$i]]{'uidl'} = $2;
                        last;
                    }
                }
            }
        }
        
        $done_uidl = 1;
        
        return 1;
    }
    
    return 0;
}

# ---------------------------------------------------------------------------------------------
#
# verify_connected - Called to check that we are connected
#
# $mail        The handle of the real mail server
# $hostname    The host name of the remote server
# $port        The port
#
# ---------------------------------------------------------------------------------------------
sub verify_connected
{
    my ($client, $hostname, $port) = @_;
    
    # Check to see if we are already connected
    if ( $mail)
    {
        if ( $mail->connected ) 
        {
            return 1;
        }
    }
    
    # Connect to the real mail server on the standard port
    $mail = IO::Socket::INET->new(
                Proto    => "tcp",
                PeerAddr => $hostname,
                PeerPort => $port );

    # Check that the connect succeeded for the remote server
    if ( $mail )
    {
        if ( $mail->connected ) 
        {
            start_rainbow();
            
            # Read the response from the real server and say OK
            my $line = <$mail>;
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
#
# ---------------------------------------------------------------------------------------------
sub flush_extra
{
    my ($mail, $client) = @_;
    
    if ( $mail )
    {
        if ( $mail->connected )
        {
            my $selector = new IO::Select( $mail );
            
            my ($ready) = $selector->can_read(0.01);
            
            while ( $ready == $mail ) 
            {
                my $line;
                $line = <$mail>;
                print $client $line;
                ($ready) = $selector->can_read(0.01);
            }
        }
    }
}

sub start_rainbow
{
    if ( !$rainbow_process )
    {
        Win32::Process::Create($rainbow_process,
                                        "rainbow.exe",
                                        "rainbow -d model --verbosity=0 --skip-html --query-server=2408",
                                        CREATE_NO_WINDOW,
                                        NORMAL_PRIORITY_CLASS,
                                    ".");
    }
}

sub stop_rainbow
{
    if ( $rainbow_process )
    {
        $rainbow_process->Kill( 0 );
        undef $rainbow_process;
    }
}

# ---------------------------------------------------------------------------------------------
#
# run_popfile - a POP3 proxy server 
#
# $listen_port    (optional) the port to listen on
#
# ---------------------------------------------------------------------------------------------
sub run_popfile
{
    # Listen for connections on our port 110 (or a user specific port)
    use IO::Socket;
    use IO::Select;
    
    my $listen_port    = shift;
    my $connect_server = shift;
    my $connect_port   = shift;
    
    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                        LocalPort => $listen_port,
                                        Listen    => SOMAXCONN,
                                        Reuse     => 1 );

    # This is used to perform select calls on the $server socket so that we can decide when there is 
    # a call waiting an accept it without having to block
    my $selector         = new IO::Select( $server  );
    
    # Accept a connection from a client trying to use us as the mail server.  We service one client at a time
    # and all others get queued up to be dealt with later.  We check the alive boolean here to make sure we
    # are still allowed to operate
    while ( $alive )
    {
        # Let Windows do event processing on us.  We need to do this for the system tray icon so that
        # it can receive events
        Win32::GUI::DoEvents();
        
        # See if there's a connection waiting on the $server by getting the list of handles with data to
        # read, if the handle is the server then we're off.  Note the 0.1 second delay here when waiting
        # around.  This means that we don't hog the processor while waiting for connections.
        my ($ready) = $selector->can_read(0.1);
        
        # If the $server is ready then we can go ahead and accept the connection
        if ( $ready == $server )
        {
        if ( my $client = $server->accept() )
        {
        # Check that this is a connection from the local machine, if it's not then we drop it immediately
        # without any further processing.  We don't want to act as a proxy for just anyone's email
        my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

        if ( $remote_host == inet_aton( "127.0.0.1" ) )
        {
            # Tell the client that we are ready for commands and identify our version number
            tee( $client, "+OK POP3 popfile (v$major_version.$minor_version) server ready$eol" );

            # Retrieve commands from the client and process them until the client disconnects or
            # we get a specific QUIT command
            while  ( <$client> )
            {
                my $command;
                
                $command = $_;
                
                # Clean up the command so that it has a nice clean $eol at the end
                $command =~ s/(\015|\012)//g;

                debug( "Command: --$command--$eol" );
 
                # Check for a possible abort
                if ( $alive == 0 )
                {
                    last;
                }

                # The HELO command results in a very simple response from us.  We just echo that
                # we are ready for commands
                if ( $command =~ /HELO/i )
                {
                    tee( $client, "+OK HELO popfile Server Ready $message_count $total_size$eol" );
                    next;
                }

                # In the case of a PASS or NOOP command we simply pass it through the the real
                # mail server for processing and echo the response back to the client
                if ( ( $command =~ /PASS (.*)/i ) || ( $command =~ /NOOP/i ) )
                {
                    echo_response( $mail, $client, $command );

                    flush_extra( $mail, $client );
                    next;
                }

                # The USER command is a special case because we modify the syntax of POP3 a little
                # to expect that the username being passed is actually of the form host:username where
                # host is the actual remote mail server to contact and username is the username to 
                # pass through to that server and represents the account on the remote machine that we
                # will pull email from.  Doing this means we can act as a proxy for multiple mail clients
                # and mail accounts
                if ( $command =~ /USER (.*):((.*):)?(.*)/i )
                {
                    if ( verify_connected( $client, $1, $3 || 110 ) ) 
                    {
                        # Pass through the USER command with the actual user name for this server,
                        # and send the reply straight to the client
                        echo_response( $mail, $client, "USER $4" );

                        # Keep a count of the number of times used when we are unregistered
                        if ( unregistered_version() )
                        {
                            $configuration{'used'} += 1;
                        }
                    }

                    flush_extra( $mail, $client );
                    next;
                }

                # User is issuing the APOP command to start a session with the remote server
                if ( $command =~ /APOP (.*):((.*):)?(.*) (.*)/i )
                {
                    if ( verify_connected( $client,  $1, $3 || 110 ) ) 
                    {
                        # Pass through the USER command with the actual user name for this server,
                        # and send the reply straight to the client
                        echo_response( $mail, $client, "APOP $4 $5" );

                        # Keep a count of the number of times used when we are unregistered
                        if ( unregistered_version() )
                        {
                            $configuration{'used'} += 1;
                        }
                    }

                    flush_extra( $mail, $client );
                    next;
                }

                
                # Secure authentication
                if ( $command =~ /AUTH ([^ ]+)/ )
                {
                    if ( verify_connected( $client,  $connect_server, $connect_port ) ) 
                    {
                        # Loop until we get -ERR or +OK
                        my $response;
                        $response = get_response( $mail, $client, $command );
                        
                        while ( ( ! ( $response =~ /\+OK/ ) ) && ( ! ( $response =~ /-ERR/ ) ) )
                        {
                            # Check for an abort
                            if ( $alive == 0 )
                            {
                                last;
                            }
                                
                            my $auth;
                            $auth = <$client>;
                            $auth =~ s/(\015|\012)$//g;
                            $response = get_response( $mail, $client, $auth );
                        }
                    }
                    
                    flush_extra( $mail, $client );
                    next;
                }

                if ( $command =~ /AUTH/ )
                {
                    if ( verify_connected( $client,  $connect_server, $connect_port ) ) 
                    {
                        if ( echo_response( $mail, $client, "AUTH" ) )
                        {
                            echo_to_dot( $mail, $client );
                        }
                    }
                    
                    flush_extra( $mail, $client );
                    next;
                }

                # The STAT command returns the number of available messages and the total size in octets
                if ( $command =~ /STAT/i )
                {
                    # Make sure that we have at least once downloaded the list of available messages from
                    # the remote mail server
                    if ( verify_have_list( $mail, $client ) )
                    {
                        # Return the number of messages that have not been deleted and the total number of
                        # bytes available
                        tee( $client, "+OK $message_count $total_size$eol" );
                    }
                
                    flush_extra( $mail, $client );
                    next;
                }

                # The client is requesting a LIST of the messages
                if ( $command =~ /LIST ?(.*)?/i )
                {
                    # Check that we have at least got the list from the remote server
                    if ( verify_have_list( $mail, $client ) )
                    {
                        if ( $1 eq '' ) 
                        {
                            # The response is in the form of a +OK with the number of available messages and the total
                            # size in bytes followed by a sequence of lines each with the message number and length and
                            # then finally a . on a line on its own
                            tee( $client, "+OK $message_count $total_size$eol" );

                            for ( my $i = 1; $i <= $highest_message; $i++ )
                            {
                                if ( $messages[$message_map[$i]]{'deleted'} == 0 )
                                {
                                    tee( $client, "$i $messages[$message_map[$i]]{'size'}$eol" );
                                }
                            }

                            tee( $client, ".$eol" );
                         }
                         else
                         {
                            # The user has asked for information on a single mail message so return it
                            if ( $message_map[$1] )
                            {
                               tee( $client, "+OK $1 $messages[$message_map[$1]]{'size'}$eol" );
                            }
                            else
                            {
                                tee( $client, "-ERR no such message$eol" );
                            }
                         }
                    }

                    flush_extra( $mail, $client );
                    next;
                }

                # The client is requesting a UIDL list of the messages
                if ( $command =~ /UIDL ?(.*)?/i )
                {
                    my $message;
                    
                    $message = $1;
                    
                    debug( "UIDL command for message $message" );
                    
                    # Check that we have at least got the list from the remote server
                    if ( verify_have_uidl( $mail, $client ) )
                    {
                        if ( $message eq '' ) 
                        {
                            # The response is in the form of a +OK with the number of available messages and the total
                            # size in bytes followed by a sequence of lines each with the message number and length and
                            # then finally a . on a line on its own
                            tee( $client, "+OK $message_count $total_size$eol" );

                            for ( my $i = 1; $i <= $highest_message; $i++ )
                            {
                                if ( $messages[$message_map[$i]]{'deleted'} == 0 )
                                {
                                    tee( $client, "$i $messages[$message_map[$i]]{'uidl'}$eol" );
                                }
                            }

                            tee( $client, ".$eol" );
                         }
                         else
                         {
                            # The user has asked for information on a single mail message so return it
                            if ( $message_map[$message] )
                            {
                               tee( $client, "+OK $message $messages[$message_map[$message]]{'uidl'}$eol" );
                            }
                            else
                            {
                                tee( $client, "-ERR no such message$eol" );
                            }
                         }
                    }

                    flush_extra( $mail, $client );
                    next;
                }

                # The client is requesting a specific message.  It could be the nag message, in which case we return it
                # or a geniune message in which case we make the mapping to the actual message number and then echo that
                # message from the remote mail server.
                if ( $command =~ /TOP (.*) (.*)/i )
                {
                    if ( verify_have_list( $mail, $client ) )
                    {
                        # Check to see if we are being asked for the nag message, if so then return it
                        if ( $messages[$message_map[$1]]{'nag'} )
                        {
                            tee( $client, "+OK $messages[$message_map[$1]]{'size'}$eol" );
                            print $client $nag_message;
                        }
                        else
                        {
                            # Get the message from the remote server, if there's an error then we're done, but if not then
                            # we echo each line of the message until we hit the . at the end
                            if ( echo_response( $mail, $client, "TOP $messages[$message_map[$1]]{'server_number'} $2" ) )
                            { 
                                while ( <$mail> )
                                {
                                    print $client $_;
                                    
                                    # The termination of a message is a line consisting of exactly .CRLF so we detect that
                                    # here exactly
                                    if ( $_ =~  /^\.\r\n$/ )
                                    {
                                        last;
                                    }
                                }
                            }
                        }
                    }
                    
                    flush_extra( $mail, $client );
                    next;
                }

                # The XSENDER command
                if ( $command =~ /XSENDER (.*)/i )
                {
                    if ( verify_have_list( $mail, $client ) )
                    {
                        # Check to see if we are being asked for the nag message, if so then return it
                        if ( $messages[$message_map[$1]]{'nag'} )
                        {
                            tee( $client, "+OK <popfile\@jgc.org>$eol" );
                        }
                        else
                        {
                            echo_response( $mail, $client, "XSENDER $messages[$message_map[$1]]{'server_number'}" );
                        }
                    }
                    
                    flush_extra( $mail, $client );
                    next;
                }
                
                # The CAPA command
                if ( $command =~ /CAPA/i )
                {
                    if ( verify_connected( $client, $connect_server, $connect_port ) ) 
                    {
                        # Perform a LIST command on the remote server
                        if ( echo_response( $mail, $client, "CAPA" ) )
                        {
                            echo_to_dot( $mail, $client );
                        }
                    }
                    
                    flush_extra( $mail, $client );
                    next;
                }                

                # The client is requesting a specific message.  It could be the nag message, in which case we return it
                # or a geniune message in which case we make the mapping to the actual message number and then echo that
                # message from the remote mail server.
                if ( $command =~ /RETR (.*)/i )
                {
                    if ( verify_have_list( $mail, $client ) )
                    {
                        # Check to see if we are being asked for the nag message, if so then return it
                        if ( $messages[$message_map[$1]]{'nag'} )
                        {
                            tee( $client, "+OK $messages[$message_map[$1]]{'size'}$eol" );
                            print $client $nag_message;
                        }
                        else
                        {
                            # Get the message from the remote server, if there's an error then we're done, but if not then
                            # we echo each line of the message until we hit the . at the end
                            if ( echo_response( $mail, $client, "RETR $messages[$message_map[$1]]{'server_number'}" ) )
                            { 
                                my $msg_subject;        # The message subject
                                my $msg_headers;        # Store the message headers here (will add X-Spam to end)
                                my $msg_body;           # Store the message body here
                                my $got_full_body = 0;  # Did we get the full body

                                my $rainbow = IO::Socket::INET->new( Proto     => 'tcp',
                                                                    PeerPort => 2408,
                                                                    PeerAddr => 'localhost' );
                                
                                my $getting_headers = 1;
                                
                                while ( <$mail> )
                                {   
                                    my $line;
                                    
                                    $line = $_;
                                    
                                    # Check for an abort
                                    if ( $alive == 0 )
                                    {
                                        last;
                                    }

                                    Win32::GUI::DoEvents();

                                    # The termination of a message is a line consisting of exactly .CRLF so we detect that
                                    # here exactly
                                    if ( $line =~ /^\.\r\n$/ )
                                    {
                                        print $rainbow "$eol.$eol";
                                        $got_full_body = 1;
                                        last;
                                    }

                                    if ( $getting_headers ) 
                                    {
                                        if ( $line =~ /[A-Z0-9]/i ) 
                                        {
                                            print $rainbow "$line$eol";
                                         
                                            if ( $line =~ /Subject: (.*)/ ) 
                                            {
                                                $msg_subject = $1;
                                                $msg_subject =~ s/(\012|\015)//g;
                                            } 
                                            else 
                                            {
                                                if ( $line =~ /X-Text-Classification: / == 0 )
                                                {
                                                    $msg_headers .= $line;
                                                }
                                            }
                                        }
                                        else
                                        {
                                            $getting_headers = 0;
                                        }
                                    }
                                    else
                                    {
                                        # If this is a base64 encoded message line then don't send it to rainbow
                                        # since it doesn't help.  Also filter out additional headers
                                        if ( ( !( $line =~ /^[^ ]+: / ) ) && ( !( $line =~ /^[^ ]{70}/ ) ) )
                                        {
                                            print $rainbow $line;
                                        }

                                        $msg_body .= $line;

                                        # If we hit a base64 line then stop downloading and classify
                                        if ( $line =~ /^[^ ]{70}/ ) 
                                        {
                                            print $rainbow "$eol.$eol";
                                            last;
                                        }
                                    }
                                }
                               
                                # Do the text classification and parse the result
                                my $classification = '';
                                if ( $rainbow->connected )
                                {
                                    while ( $classification eq '' ) {
                                        $classification .= <$rainbow>;
                                        debug( $classification );
                                    }
                                    
                                    $classification =~ s/[0-9\012\015\. ]//g;
                                }
                                else
                                {
                                    $classification = 'failed';
                                }

                                debug ("Classification: $classification" );
                                undef $rainbow;

                                debug("Subject modification is $configuration{subject}");                    
                                # Add the spam header
                                if ( $configuration{subject} ) 
                                {
                                    $msg_headers .= "Subject: [$classification] $msg_subject$eol";
                                }
                                else
                                {
                                    $msg_headers .= "Subject: $msg_subject$eol";
                                }
                                    
                                $msg_headers .= "X-Text-Classification: $classification";
                                $msg_headers .= "$eol$eol";

                                # Echo the text of the message to the client
                                print $client $msg_headers;
                                print $client $msg_body;
                                
                                # Retrieve any more of the body
                                if ( !$got_full_body )
                                {
                                    debug( "Echoing rest of message" );
                                    echo_to_dot( $mail, $client );
                                }
                                else
                                {
                                    debug( "Full message was received" );
                                    print $client ".$eol";
                                }
                            } 
                        }

                        flush_extra( $mail, $client );
                        next;
                    }
                }

                # Handle the deletion of a message, if it's the nag message then we pretend we've deleted it.  If it is not
                # then we pass the delete on to the remote server and see if it works.  If it does work then we mark the
                # message as deleted.  Throughout we ensure that $total_size and $message_count are kept accurate
                if ( $command =~ /DELE (.*)/i )
                {
                if ( verify_have_list( $mail, $client ) )
                {
                    # Check to see if we are deleting the nag message
                    if ( $messages[$message_map[$1]]{'nag'} )
                    {
                        # Just say that we've deleted it and mark it as deleted.  
                        tee( $client, "+OK message deleted$eol" );
                        $messages[$message_map[$1]]{'deleted'}  = 1;
                        $total_size              -= $messages[$message_map[$1]]{'size'};
                        $message_count           -= 1;
                    }
                    else
                    {
                        # Try the delete on the real server and if it successful then mark it as deleted
                        # locally
                        if ( echo_response( $mail, $client, "DELE $messages[$message_map[$1]]{'server_number'}" ) )
                        {
                            if ( $messages[$message_map[$1]]{'deleted'} == 0 )
                            {
                                $messages[$message_map[$1]]{'deleted'}  = 1;
                                $total_size              -= $messages[$message_map[$1]]{'size'};
                                $message_count           -= 1;
                            }
                        }
                    }

                    flush_extra( $mail, $client );
                    next;
                }
                }

                # The mail client wants to stop using the server, so send that message through to the
                # real mail server, echo the response back up to the client and exit the while.  We will
                # close the connection immediately
                if ( $command =~ /QUIT/i )
                {
                    if ( $mail ) 
                    {
                        echo_response( $mail, $client, $command );
                        close $mail;
                    }
                    else
                    {
                        tee( $client, "+OK goodbye" );
                    }
                    
                    stop_rainbow();
                    last;
                }

                # The mail client wants to restart and so we mark all messages as undeleted and recalculate the
                # size of all the messages $total_size and the number $message_count
                if ( $command =~ /RSET/i )
                {
                    if ( echo_response( $mail, $client, $command ) ) 
                    {
                        $total_size    = 0;
                        $message_count = $highest_message;

                        for ( my $i = 1; $i <= $highest_message; $i++ )
                        {
                            $messages[$i]{'deleted'}  = 0;
                            $total_size              += $messages[$i]{'size'};
                        }
                    }

                    flush_extra( $mail, $client );
                    next;
                }

                # Don't know what this is so let's just pass it through and hope for the best
                # Perform a LIST command on the remote server
                if ( echo_response( $mail, $client, $command ) )
                {
                    flush_extra( $mail, $client );
                    next;
                }
            }
        }

        # Close the connection with the client and get ready to accept a new connection
        close $client;
        if ( $mail ) 
        {
            close $mail;
            undef $mail;
        }

        # Clear out the counters that say the number of messages available, everything to zero
        # to prepare for the next connection
        $message_count   = 0;
        $total_size      = 0;
        $highest_message = 0;
        $#messages       = 0;
        $#message_map    = 0;
        $done_uidl       = 0;

        stop_rainbow();
        save_configuration();
       }
    }
    }
}

# ---------------------------------------------------------------------------------------------
#
# aborting    Called if we are going to be aborted or are being asked to abort our operation
#         Sets the alive flag to 0 that will cause us to abort at the next convenient
#         moment
#
# ---------------------------------------------------------------------------------------------
sub aborting
{
    debug("Forced to abort via signal");
    $alive = 0;
}

sub Main_Terminate 
{
        -1;
}

# ---------------------------------------------------------------------------------------------
#
# NI_RightClick Called when someone right clicks on the tray icon.  When this happens we
#               display the menu that contains the single option "Exit"
#
# ---------------------------------------------------------------------------------------------

sub NI_RightClick 
{
    $alive = 0;
    1;
}

# ---------------------------------------------------------------------------------------------

$SIG{BREAK} = \&aborting;
$SIG{ABRT}  = \&aborting;
$SIG{TERM}  = \&aborting;
$SIG{INT}   = \&aborting;

# Set up reasonable defaults for the configuration parameters.  These may be 
# overwritten immediately when we read the configuration file
$configuration{used}     = 0;
$configuration{messages} = 0;
$configuration{port}     = 110;
$configuration{subject}  = 1;
$configuration{server}   = $ARGV[1];
$configuration{sport}    = $ARGV[2];

# Load the current configuration from disk
load_configuration();

# Try to locate the model folder and check for the file format-version
open MODEL, "<model/format-version" or die "POPFile Error\n\nCan't find the email model.  \n\nPlease create model first.  Run bucket.exe";
close MODEL;

# Set up the system tray icon
$main = Win32::GUI::Window->new(-name => 'traywindow', -text => 'Perl',-width => 200, -height => 200 );
$icon = new Win32::GUI::Icon('popfile.ico');
$ni = $main->AddNotifyIcon(-name => "NI", -id => 1, -icon => $icon, -tip => "POPFile running; right click icon to terminate");

# Run the POP server and handle requests
run_popfile($ARGV[0] || $configuration{port}, $configuration{server}, $configuration{sport});

# Remove the tray icon
$main->NI->Delete(-id => 1);
Win32::GUI::DoEvents();

# Write the final configuration to disk
save_configuration();

# ---------------------------------------------------------------------------------------------
