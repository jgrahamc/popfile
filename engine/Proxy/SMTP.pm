# POPFILE LOADABLE MODULE
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
    my $self = Proxy::Proxy->new();

    # Must call bless before attempting to call any methods

    bless $self, $type;

    $self->name( 'smtp' );

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '554 Transaction failed';
    $self->{connection_failed_error_}  = '554 Transaction failed, can\'t connect to';
    $self->{good_response_}            = '^[23]';

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

    # Default port for SMTP service

    $self->config_( 'port', 25 );

    # Where to forward on to

    $self->config_( 'chain_server', '' );
    $self->config_( 'chain_port', 25 );

    # Only accept connections from the local machine for smtp

    $self->config_( 'local', 1 );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a SMTP client
# $download_count - The unique download count for this session
#
# ---------------------------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $download_count, $pipe ) = @_;

    # Number of messages downloaded in this session
    my $count = 0;

    # The handle to the real mail server gets stored here
    my $mail;

    # Tell the client that we are ready for commands and identify our version number
    $self->tee_(  $client, "220 SMTP POPFile (vTODO.TODO.TODO) server ready$eol" );

    # Retrieve commands from the client and process them until the client disconnects or
    # we get a specific QUIT command
    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end
        $command =~ s/(\015|\012)//g;

        $self->log_( "Command: --$command--" );

        if ( $command =~ /HELO|EHLO/i ) {
            if ( $self->config_( 'chain_server' ) )  {
                if ( $mail = $self->verify_connected_( $mail, $client, $self->config_( 'chain_server' ),  $self->config_( 'chain_port' ) ) )  {
                    
                    $self->smtp_echo_response_( $mail, $client, $command );

                    
                } else {
                    last;
                }

                $self->flush_extra_( $mail, $client, 0 );
            } else {
                $self->tee_(  $client, "421 service not available$eol" );
            }

            next;
        }

        if ( ( $command =~ /MAIL FROM:/i )    ||
             ( $command =~ /RCPT TO:/i )      ||
             ( $command =~ /VRFY/i )          ||
             ( $command =~ /EXPN/i )          ||
             ( $command =~ /NOOP/i )          ||
             ( $command =~ /HELP/i )          ||
             ( $command =~ /RSET/i ) ) {
            $self->smtp_echo_response_( $mail, $client, $command );
            $self->flush_extra_( $mail, $client, 0 );
            next;
        }

        if ( $command =~ /DATA/i ) {
            # Get the message from the remote server, if there's an error then we're done, but if not then
            # we echo each line of the message until we hit the . at the end
            if ( $self->smtp_echo_response_( $mail, $client, $command ) ) {
                $count += 1;

		my $class = $self->{classifier__}->classify_and_modify( $client, $mail, $download_count, $count, 0, '' );

		# Tell the parent that we just handled a mail
		print $pipe "$class$eol";

		my $response = <$mail>;
                $self->tee_( $client, $response );
                $self->flush_extra_( $mail, $client, 0 );
                next;
            }
        }

        # The mail client wants to stop using the server, so send that message through to the
        # real mail server, echo the response back up to the client and exit the while.  We will
        # close the connection immediately
        if ( $command =~ /QUIT/i ) {
            if ( $mail )  {
                $self->smtp_echo_response_( $mail, $client, $command );
                close $mail;
            } else {
                $self->tee_(  $client, "221 goodbye$eol" );
            }
            last;
        }

        # Don't know what this is so let's just pass it through and hope for the best
        if ( $mail && $mail->connected )  {
            $self->smtp_echo_response_( $mail, $client, $command );
            $self->flush_extra_( $mail, $client, 0 );
            next;
        } else {
            $self->tee_(  $client, "500 unknown command or bad syntax$eol" );
            last;
        }
    }

    close $mail if defined( $mail );
    close $client;
}

# ---------------------------------------------------------------------------------------------
#
# smtp_echo_response_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $command  The text of the command to send (we add an EOL)
#
# Send $command to $mail, receives the response and echoes it to the $client and the debug
# output.
#
# This subroutine returns responses from the server as defined in appendix E of
# RFC 821, allowing multi-line SMTP responses.
#
# Returns true if the initial response is a 2xx or 3xx series (as defined by {good_response_}
#
# ---------------------------------------------------------------------------------------------



sub smtp_echo_response_
{
    my ($self, $mail, $client, $command) = @_;
    my $response = $self->get_response_( $mail, $client, $command );
    
    if ( $response =~ /^[23]\d\d-/ ) {
        $self->echo_to_regexp_($mail, $client, qr/^\d\d\d /, 1);
    }
    return ( $response =~ /$self->{good_response_}/ );
}

                

1;
