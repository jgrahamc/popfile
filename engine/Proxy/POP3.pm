# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the POP3 protocol for POPFile. 
#
# ---------------------------------------------------------------------------------------------
package Proxy::POP3;

use IO::Socket;
use IO::Select;

use strict;
use warnings;
use locale;

# This is used to get the hostname of the current machine
# in a cross platform way
use Sys::Hostname;

# A handy variable containing the value of an EOL for Unix systems
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
    $self->{configuration}  = 0;

    # A reference to the classifier
    $self->{classifier}     = 0;
    
    # The name of the debug file
    $self->{debug_filename} = '';
    
    # The name of the last user to pass through POPFile
    $self->{lastuser}       = 'none';

    # Used to tell any loops to terminate
    $self->{alive}          = 1;
    
    # Just our hostname
    $self->{hostname}        = '';
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the POP3 proxy module
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # Start with debugging to file
    $self->{configuration}->{configuration}{debug}     = 1;
    
    # Default ports for POP3 service and the user interface
    $self->{configuration}->{configuration}{port}      = 110;
    
    # Subject modification (global setting is on)
    $self->{configuration}->{configuration}{subject}   = 1;
    
    # Adding the X-Text-Classification on
    $self->{configuration}->{configuration}{xtc}       = 1;
    
    # Adding the X-POPFile-Link is no
    $self->{configuration}->{configuration}{xpl}       = 1;

    # There is no default setting for the secure server
    $self->{configuration}->{configuration}{server}    = '';
    $self->{configuration}->{configuration}{sport}     = 110;

    # The default timeout in seconds for POP3 commands
    $self->{configuration}->{configuration}{timeout}   = 60;

    # Only accept connections from the local machine for POP3
    $self->{configuration}->{configuration}{localpop}  = 1;

    # Whether to do classification on TOP as well
    $self->{configuration}->{configuration}{toptoo}    = 0;

    # Start with no messages downloaded and no error
    $self->{configuration}->{configuration}{mcount}    = 0;
    $self->{configuration}->{configuration}{ecount}    = 0;

    # This counter is used when creating unique IDs for message stored
    # in the history.  The history message files have the format
    #
    # popfile{download_count}_{message_count}.msg
    #
    # Where the download_count is derived from this value and the 
    # message_count is a local counter within that download, for sorting
    # purposes must sort on download_count and then message_count
    $self->{configuration}->{configuration}{download_count} = 0;

    # The separator within the POP3 username is :
    $self->{configuration}->{configuration}{separator} = ':';

    calculate_today( $self );
    
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called when the POP3 interface is allowed to start up
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;
    
    # Ensure that the messages subdirectory exists
    mkdir( 'messages' );

    # Get the hostname for use in the X-POPFile-Link header
    $self->{hostname} = hostname;

    # Open the socket used to receive request for POP3 service
    $self->{server} = IO::Socket::INET->new( Proto     => 'tcp',
                                    $self->{configuration}->{configuration}{localpop} == 1 ? (LocalAddr => 'localhost') : (), 
                                    LocalPort => $self->{configuration}->{configuration}{port},
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 ) or return 0;

    # This is used to perform select calls on the $server socket so that we can decide when there is 
    # a call waiting an accept it without having to block
    $self->{selector} = new IO::Select( $self->{server} );
    
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called when the POP3 interface must terminate
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
# Called to handle POP3 requests
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    # Accept a connection from a client trying to use us as the mail server.  We service one client at a time
    # and all others get queued up to be dealt with later.  We check the alive boolean here to make sure we
    # are still allowed to operate. See if there's a connection waiting on the $server by getting the list of 
    # handles with data to read, if the handle is the server then we're off. 
    my ($ready)   = $self->{selector}->can_read(0);

    # If the $server is ready then we can go ahead and accept the connection
    if ( ( defined($ready) ) && ( $ready == $self->{server} ) ) {
        if ( my $client = $self->{server}->accept() ) {
            # Check that this is a connection from the local machine, if it's not then we drop it immediately
            # without any further processing.  We don't want to act as a proxy for just anyone's email
            my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

            if  ( ( $self->{configuration}->{configuration}{localpop} == 0 ) || ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {
                # Now that we have a good connection to the client fork a subprocess to handle the communication
                $self->{configuration}->{configuration}{download_count} += 1;
                my $pid = fork();
                
                if ( !defined( $pid ) ) {
                    debug( "Could not fork!" );
                    close $client;
                    return 1;
                }
                
                if ( $pid == 0 ) {
                    close $self->{server};  # Not needed in the child process
                    child( $self, $client, $self->{configuration}->{configuration}{download_count} );
                    exit(0);
                }
            }

            close $client;
        }
    }
    
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# child
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a POP3 client
# $download_count - The unique download count for this session
#
# ---------------------------------------------------------------------------------------------
sub child
{
    my ( $self, $client, $download_count ) = @_;

    # Number of messages downloaded in this session
    my $count = 0;

    # The handle to the real mail server gets stored here
    my $mail;
            
    # Tell the client that we are ready for commands and identify our version number
    tee( $self,  $client, "+OK POP3 POPFile (v$self->{configuration}->{major_version}.$self->{configuration}->{minor_version}.$self->{configuration}->{build_version}) server ready$eol" );

    # Retrieve commands from the client and process them until the client disconnects or
    # we get a specific QUIT command
    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end
        $command =~ s/(\015|\012)//g;

        debug( $self, "Command: --$command--" );

        # Check for a possible abort
        last if ( $self->{alive} == 0 );

        # The USER command is a special case because we modify the syntax of POP3 a little
        # to expect that the username being passed is actually of the form host:username where
        # host is the actual remote mail server to contact and username is the username to 
        # pass through to that server and represents the account on the remote machine that we
        # will pull email from.  Doing this means we can act as a proxy for multiple mail clients
        # and mail accounts
        if ( $command =~ /USER (.+)(:(\d+))?$self->{configuration}->{configuration}{separator}(.+)/i ) {
            if ( $1 ne '' )  {
                if ( $mail = verify_connected( $self, $mail, $client, $1, $3 || 110 ) )  {
                    $self->{lastuser} = $4;

                    # Pass through the USER command with the actual user name for this server,
                    # and send the reply straight to the client
                    echo_response( $self, $mail, $client, 'USER ' . $4 );
                } else {
                    last;
                }
            } else {
                tee( $self,  $client, "-ERR server name not specified in USER command$eol" );
                last;
            }

            flush_extra( $self, $mail, $client, 0 );
            next;
        }

        # User is issuing the APOP command to start a session with the remote server
        if ( $command =~ /APOP (.*):((.*):)?(.*) (.*)/i ) {
            if ( $mail = verify_connected( $self, $mail, $client,  $1, $3 || 110 ) )  {
                $self->{lastuser} = $4;

                # Pass through the USER command with the actual user name for this server,
                # and send the reply straight to the client
                echo_response( $self, $mail, $client, "APOP $4 $5" );
            } else {
                last;
            }

            flush_extra( $self, $mail, $client, 0 );
            next;
        }

        # Secure authentication
        if ( $command =~ /AUTH ([^ ]+)/ ) {
            if ( $self->{configuration}->{configuration}{server} ne '' )  {
                if ( $mail = verify_connected( $self, $mail, $client,  $self->{configuration}->{configuration}{server}, $self->{configuration}->{configuration}{sport} ) )  {
                    # Loop until we get -ERR or +OK
                    my $response;
                    $response = get_response( $self, $mail, $client, $command );

                    while ( ( ! ( $response =~ /\+OK/ ) ) && ( ! ( $response =~ /-ERR/ ) ) ) {
                        # Check for an abort
                        if ( $self->{alive} == 0 ) {
                            last;
                        }

                        my $auth;
                        $auth = <$client>;
                        $auth =~ s/(\015|\012)$//g;
                        $response = get_response( $self, $mail, $client, $auth );
                    }
                } else {
                    last;
                }

                flush_extra( $self, $mail, $client, 0 );
            } else {
                tee( $self,  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        if ( $command =~ /AUTH/ ) {
            if ( $self->{configuration}->{configuration}{server} ne '' )  {
                if ( $mail = verify_connected( $self, $mail, $client,  $self->{configuration}->{configuration}{server}, $self->{configuration}->{configuration}{sport} ) )  {
                    if ( echo_response( $self, $mail, $client, "AUTH" ) ) {
                        echo_to_dot( $self, $mail, $client );
                    }
                } else {
                    last;
                }

                flush_extra( $self, $mail, $client, 0 );
            } else {
                tee( $self,  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        # The client is requesting a LIST/UIDL of the messages
        if ( ( $command =~ /LIST ?(.*)?/i ) ||
             ( $command =~ /UIDL ?(.*)?/i ) ) {
            if ( echo_response( $self, $mail, $client, $command ) ) {
                echo_to_dot( $self, $mail, $client ) if ( $1 eq '' );
            }

            flush_extra( $self, $mail, $client, 0 );
            next;
        }

        # Note the horrible hack here where we detect a command of the form TOP x 99999999 this
        # is done so that fetchmail can be used with POPFile.  
        if ( $command =~ /TOP (.*) (.*)/i ) {
            if ( $2 ne '99999999' )  {                    
                if ( $self->{configuration}->{configuration}{toptoo} ) {
                    if ( echo_response( $self, $mail, $client, "RETR $1" ) ) {
                        my $class = classify_and_modify( $self, $mail, $client, $download_count, $count, 1, '' );
                        if ( echo_response( $self, $mail, $client, $command ) ) {
                            classify_and_modify( $self, $mail, $client, $download_count, $count, 0, $class );
                        }
                    }
                } else {
                    echo_to_dot( $self, $mail, $client ) if ( echo_response( $self, $mail, $client, $command ) );
                }
                flush_extra( $self, $mail, $client, 0 );
                next;
            }

            # Note the fall through here.  Later down the page we look for TOP x 99999999 and
            # do a RETR instead
        }

        # The CAPA command
        if ( $command =~ /CAPA/i ) {
            if ( $mail = verify_connected( $self, $mail, $client, $self->{configuration}->{configuration}{server}, $self->{configuration}->{configuration}{sport} ) )  {
                echo_to_dot( $self, $mail, $client ) if ( echo_response( $self, $mail, $client, "CAPA" ) );
            } else {
                tee( $self,  $client, "-ERR No secure server specified$eol" );
            }

            flush_extra( $self, $mail, $client, 0 );
            next;
        }                

        # The HELO command results in a very simple response from us.  We just echo that
        # we are ready for commands
        if ( $command =~ /HELO/i ) {
            tee( $self,  $client, "+OK HELO POPFile Server Ready$eol" );
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
            echo_response( $self, $mail, $client, $command );
            flush_extra( $self, $mail, $client, 0 );
            next;
        }

        # The client is requesting a specific message.  
        # Note the horrible hack here where we detect a command of the form TOP x 99999999 this
        # is done so that fetchmail can be used with POPFile.  
        if ( ( $command =~ /RETR (.*)/i ) || ( $command =~ /TOP (.*) 99999999/i ) )  {
            # Get the message from the remote server, if there's an error then we're done, but if not then
            # we echo each line of the message until we hit the . at the end
            if ( echo_response( $self, $mail, $client, $command ) ) {
                $count += 1;
                classify_and_modify( $self, $mail, $client, $download_count, $count, 0, '' );
                flush_extra( $self, $mail, $client, 0 );
                next;
            }
        }

        # The mail client wants to stop using the server, so send that message through to the
        # real mail server, echo the response back up to the client and exit the while.  We will
        # close the connection immediately
        if ( $command =~ /QUIT/i ) {
            if ( $mail )  {
                echo_response( $self, $mail, $client, $command );
                close $mail;
            } else {
                tee( $self,  $client, "+OK goodbye" );
            }
            last;
        }

        # Don't know what this is so let's just pass it through and hope for the best
        if ( $mail && $mail->connected )  {
            echo_response( $self, $mail, $client, $command );
            flush_extra( $self, $mail, $client, 0 );
            next;
        } else {
            tee( $self,  $client, "-ERR unknown command or bad syntax$eol" );
            last;
        }
    }

    close $mail if ( $mail );
}

# ---------------------------------------------------------------------------------------------
#
# classify_and_modify
#
# This method reads an email terminated by . on a line by itself (or the end of stream)
# from a handle and creates an entry in the history, outputting the same email on another
# handle with the appropriate header modifications and insertions
#
# $mail     - an open stream to read the email from
# $client   - an open stream to write the modified email to
# $dcount   - the unique download count for this message
# $mcount   - the message count for this message
# $nosave   - indicates that the message downloaded should not be saved in the history
# $class    - if we already know the classification
#
# ---------------------------------------------------------------------------------------------
sub classify_and_modify
{
    my ( $self, $mail, $client, $dcount, $mcount, $nosave, $class ) = @_;
    
    my $msg_subject     = '';     # The message subject
    my $msg_head_before = '';     # Store the message headers that come before Subject here
    my $msg_head_after  = '';     # Store the message headers that come after Subject here
    my $msg_body        = '';     # Store the message body here

    # These two variables are used to control the insertion of the X-POPFile-TimeoutPrevention
    # header when downloading long or slow emails
    my $last_timeout   = time;
    my $timeout_count  = 0;

    # Indicates whether the first time through the receive loop we got the full body, this
    # will happen on small emails
    my $got_full_body  = 0;

    # The size of the message downloaded so far.
    my $message_size   = 0;

    # The classification for this message
    my $classification = '';

    # Whether we are currently reading the mail headers or not
    my $getting_headers = 1;

    my $temp_file  = "messages/popfile$dcount" . "_$mcount.msg";
    my $class_file = "messages/popfile$dcount" . "_$mcount.cls";
    $self->{configuration}->{configuration}{mcount}     += 1 if ( !$nosave );
    $self->{ui}->{history_invalid}                       = 1 if ( !$nosave );

    open TEMP, ">$temp_file";
    binmode TEMP;

    while ( <$mail> ) {   
        my $line;

        $line = $_;

        # Check for an abort
        last if ( $self->{alive} == 0 );

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

                if ( $self->{configuration}->{configuration}{subject} )  {
                    if ( $line =~ /Subject:(.*)/i )  {
                        $msg_subject = $1;
                        $msg_subject =~ s/(\012|\015)//g;
                        next;
                    } 
                }

                # Strip out the X-Text-Classification header that is in an incoming message
                if ( ( $line =~ /X-Text-Classification:/i ) == 0 ) {
                    if ( $msg_subject eq '' )  {
                        $msg_head_before .= $line;
                    } else {
                        $msg_head_after  .= $line;
                    }
                }
            } else {
                print TEMP $eol;
                $getting_headers = 0;
            }
        } else {
            $message_size += length $line;
            print TEMP $line;
            $msg_body .= $line;
        }

        # Check to see if too much time has passed and we need to keep the mail client happy
        if ( time > ( $last_timeout + 2 ) ) {
            print $client "X-POPFile-TimeoutPrevention: $timeout_count$eol" if ( !$nosave );
            $timeout_count += 1;
            $last_timeout = time;
        }

        last if ( ( $message_size > 100000 ) && ( $getting_headers == 0 ) );
    }

    close TEMP;

    # Do the text classification and update the counter for that bucket that we just downloaded
    # an email of that type
    $classification = ($class ne '')?$class:$self->{classifier}->classify_file($temp_file);
    if ( !$nosave ) {
        $self->{classifier}->{parameters}{$classification}{count} += 1 if ( $classification ne 'unclassified' );
    }

    # Add the Subject line modification or the original line back again
    if ( $self->{configuration}->{configuration}{subject} && ( $msg_subject ne '' ) ) {
        # Don't add the classification unless it is not present
        if ( !( $msg_subject =~ /\[$classification\]/ ) && ( $self->{classifier}->{parameters}{$classification}{subject} == 1 ) )  {
            $msg_head_before .= "Subject: [$classification]$msg_subject$eol";
        } else {
            $msg_head_before .= "Subject:$msg_subject$eol";
        }
    }

    if ( $nosave ) {
        unlink( $temp_file );
    }

    # Add the XTC header
    $msg_head_after .= "X-Text-Classification: $classification$eol" if ( $self->{configuration}->{configuration}{xtc} );

    # Add the XPL header
    $temp_file =~ s/messages\/(.*)/$1/;

    if ( $self->{configuration}->{configuration}{xpl} ) {
        $msg_head_after .= "X-POPFile-Link: <http://";
        $msg_head_after .= $self->{configuration}->{configuration}{localpop}?"127.0.0.1":$self->{hostname};
        $msg_head_after .= ":$self->{configuration}->{configuration}{ui_port}/jump_to_message?view=$temp_file>$eol";
    }

    $msg_head_after .= "$eol";

    # Echo the text of the message to the client
    if ( !$nosave ) {
        print $client $msg_head_before;
        print $client $msg_head_after;
        print $client $msg_body;
    }
    
    if ( $got_full_body == 0 )    {   
        echo_to_dot( $self, $mail, $client ) if ( !$nosave );   
    } else {   
        print $client ".$eol" if ( !$nosave );    
    } 

    if ( !$nosave ) {
        open CLASS, ">$class_file";
        if ( $self->{classifier}->{magnet_used} == 0 )  {
            print CLASS "$classification$eol";
        } else {
            print CLASS "$classification MAGNET $self->{classifier}->{magnet_detail}$eol";
        }
        close CLASS;
    }
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
    my ( $self, $message ) = @_;
    
    if ( $self->{configuration}->{configuration}{debug} > 0 ) {
        # Check to see if we are handling the USER/PASS command and if we are then obscure the
        # account information
        $message = "$`$1$3 XXXXXX$4" if ( $message =~ /((--)?)(USER|PASS)\s+\S*(\1)/ );
        chomp $message;
        $message .= "\n";

        my $now = localtime;
        my $msg = "$now ($$): $message";
        
        if ( $self->{configuration}->{configuration}{debug} & 1 )  {
            open DEBUG, ">>$self->{debug_filename}";
            binmode DEBUG;
            print DEBUG $msg;
            close DEBUG;
        }
        
        print $msg if ( $self->{configuration}->{configuration}{debug} & 2 );
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
    my ( $self, $socket, $text ) = @_;

    # Send the message to the debug output and then send it to the appropriate socket
    debug( $self, $text ); 
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
    my ( $self, $mail, $client, $command ) = @_;
    
    unless ( $mail ) {
       # $mail is undefined - return an error intead of crashing
       tee( $self,  $client, "-ERR error communicating with mail server$eol" );
       return "-ERR";
    }

    # Send the command (followed by the appropriate EOL) to the mail server
    tee( $self, $mail, $command. $eol );
    
    my $response;
    
    # Retrieve a single string containing the response
    if ( $mail->connected ) {
        $response = <$mail>;
        
        if ( $response ) {
            # Echo the response up to the mail client
            tee( $self,  $client, $response );
        } else {
            # An error has occurred reading from the mail server
            tee( $self,  $client, "-ERR no response from mail server" );
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
    my ( $self, $mail, $client, $command ) = @_;
    
    # Determine whether the response began with the string +OK.  If it did then return 1
    # else return 0
    return ( get_response( $self, $mail, $client, $command ) =~ /^\+OK/ );
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
    my ( $self, $mail, $client ) = @_;
    
    while ( <$mail> ) {
        # Check for an abort
        last if ( $self->{alive} == 0 );

        print $client $_;

        # The termination has to be a single line with exactly a dot on it and nothing
        # else other than line termination characters.  This is vital so that we do
        # not mistake a line beginning with . as the end of the block
        last if ( /^\.(\r\n|\r|\n)$/ );
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
    my ( $self, $mail, $client, $hostname, $port ) = @_;
    
    calculate_today( $self );
    
    # Check to see if we are already connected
    return $mail if ( $mail && $mail->connected );
    
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
            last unless () = $selector->can_read($self->{configuration}->{configuration}{timeout});
            
            # Read the response from the real server and say OK
            my $buf        = '';
            my $max_length = 8192;
            my $n          = sysread( $mail, $buf, $max_length, length $buf );
            
            debug( $self, "Connection returned: $buf" );
            if ( !( $buf =~ /[\r\n]/ ) ) {
                for my $i ( 0..4 ) {
                    flush_extra( $self, $mail, $client, 1 );
                }
            }
            return $mail;
        }
    }

    # Tell the client we failed
    tee( $self,  $client, "-ERR failed to connect to $hostname:$port$eol" );
    
    return undef;
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
    my ( $self, $mail, $client, $discard ) = @_;
    
    if ( $mail ) {
        if ( $mail->connected ) {
            my $selector   = new IO::Select( $mail );
            my $buf        = '';
            my $max_length = 8192;

            while( 1 ) {
                last unless () = $selector->can_read(0.1);
                last unless ( my $n = sysread( $mail, $buf, $max_length, length $buf ) );

                tee( $self,  $client, $buf ) if ( $discard != 1 );
            }
        }
    }
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
    my ( $self ) = @_;
    
    my @debug_files = glob "popfile*.log";

    calculate_today( $self );
    
    foreach my $debug_file (@debug_files) {
        # Extract the epoch information from the popfile log file name
        if ( $debug_file =~ /popfile([0-9]+)\.log/ )  {
            # If older than now - 3 days then delete
            unlink($debug_file) if ( $1 < (time - 3 * $seconds_per_day) );
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
    
    # Create the name of the debug file for the debug() function
    $self->{today} = int( time / $seconds_per_day ) * $seconds_per_day;
    $self->{mail_filename}  = "popfile$self->{today}";
    $self->{debug_filename} = "popfile$self->{today}.log";
}
1;
