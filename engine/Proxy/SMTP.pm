# DISABLED POPFILE LOADABLE MODULE
package Proxy::SMTP;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the SMTP protocol for POPFile.
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self;

    # Must call bless before attempting to call any methods

    bless $self, $type;

    $self->name( 'smtp' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the SMTP proxy module
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # Default ports for SMTP
    $self->{configuration}->{configuration}{smtp_port} = 25;

    # Where to forward on to
    $self->{configuration}->{configuration}{smtp_chain_server} = '';
    $self->{configuration}->{configuration}{smtp_chain_port}   = 25;

    # Only accept connections from the local machine for smtp
    $self->{configuration}->{configuration}{smtp}  = 1;

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# child
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a SMTP client
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
    tee( $self,  $client, "220 SMTP POPFile (v$self->{configuration}->{major_version}.$self->{configuration}->{minor_version}.$self->{configuration}->{build_version}) server ready$eol" );

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

        if ( $command =~ /HELO/ ) {
            if ( $self->{configuration}->{configuration}{smtp_chain_server} ne '' )  {
                if ( $mail = verify_connected( $self, $mail, $client,  $self->{configuration}->{configuration}{smtp_chain_server}, $self->{configuration}->{configuration}{smtp_chain_port} ) )  {
                    echo_response( $self, $mail, $client, $command );
                } else {
                    last;
                }

                flush_extra( $self, $mail, $client, 0 );
            } else {
                tee( $self,  $client, "421 service not available$eol" );
            }

            next;
        }

        if ( ( $command =~ /MAIL FROM:/i )    ||
             ( $command =~ /RCPT TO:/i )      ||
             ( $command =~ /VRFY/i )          ||
             ( $command =~ /EXPN/i )            ||
             ( $command =~ /NOOP/i )          ||
             ( $command =~ /HELP/i )          ||
             ( $command =~ /RSET/i ) ) {
            echo_response( $self, $mail, $client, $command );
            flush_extra( $self, $mail, $client, 0 );
            next;
        }

        if ( $command =~ /DATA/i ) {
            # Get the message from the remote server, if there's an error then we're done, but if not then
            # we echo each line of the message until we hit the . at the end
            if ( echo_response( $self, $mail, $client, $command ) ) {
                $count += 1;
                $self->{pop3}->classify_and_modify( $self, $mail, $client, $download_count, $count, 0, '' );
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
                tee( $self,  $client, "221 goodbye$eol" );
            }
            last;
        }

        # Don't know what this is so let's just pass it through and hope for the best
        if ( $mail && $mail->connected )  {
            echo_response( $self, $mail, $client, $command );
            flush_extra( $self, $mail, $client, 0 );
            next;
        } else {
            tee( $self,  $client, "500 unknown command or bad syntax$eol" );
            last;
        }
    }

    close $mail if defined( $mail );
    close $client;
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
       tee( $self,  $client, "554 Transaction failed$eol" );
       return "554";
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
            tee( $self,  $client, "554 Transaction failed$eol" );
            return "554";
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
    return ( get_response( $self, $mail, $client, $command ) < 400 );
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
    tee( $self,  $client, "554 Transaction failed failed to connect to $hostname:$port$eol" );

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
                last unless () = $selector->can_read(0.01);
                last unless ( my $n = sysread( $mail, $buf, $max_length, length $buf ) );

                tee( $self,  $client, $buf ) if ( $discard != 1 );
            }
        }
    }
}

1;
