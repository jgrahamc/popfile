# POPFILE LOADABLE MODULE
package Proxy::POP3;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the POP3 protocol for POPFile.
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

    $self->name( 'pop3' );

    $self->{child_}            = \&child__;
    $self->{flush_child_data_} = \&flush_child_data__;

    return $self;
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

    # Default ports for POP3 service and the user interface
    $self->config_( 'port', 110 );

    # Subject modification (global setting is on)
    $self->config_( 'subject', 1 );

    # Adding the X-Text-Classification on
    $self->config_( 'xtc', 1 );

    # Adding the X-POPFile-Link is no
    $self->config_( 'xpl', 1 );

    # There is no default setting for the secure server
    $self->config_( 'server', '' );
    $self->config_( 'sport', 110 );

    # The default timeout in seconds for POP3 commands
    $self->config_( 'timeout', 60 );

    # Only accept connections from the local machine for POP3
    $self->config_( 'local', 1 ); # TODO localpop

    # Whether to do classification on TOP as well
    $self->config_( 'toptoo', 0 );

    # Start with no messages downloaded and no error
    $self->config_( 'mcount', 0 );
    $self->config_( 'ecount', 0 );

    # This counter is used when creating unique IDs for message stored
    # in the history.  The history message files have the format
    #
    # popfile{download_count}={message_count}.msg
    #
    # Where the download_count is derived from this value and the
    # message_count is a local counter within that download, for sorting
    # purposes must sort on download_count and then message_count
    $self->config_( 'download_count', 0 );

    # The separator within the POP3 username is :
    $self->config_( 'separator', ':' );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# flush_child_data__
#
# Called to flush data from the pipe of each child as we go, I did this because there
# appears to be a problem on Windows where the pipe gets a lot of read data in it and
# then causes the child not to be terminated even though we are done.  Also this is nice
# because we deal with the statistics as we go
#
# $kid      PID of a child of POP3.pm
# $handle   The handle of the child's pipe
#
# ---------------------------------------------------------------------------------------------
sub flush_child_data__
{
    my ( $self, $kid, $handle ) = @_;

    my $stats_changed = 0;

    while ( &{$self->{pipeready_}}($handle) )
    {
        my $class = <$handle>;

        if ( defined( $class ) ) {
            $class =~ s/[\r\n]//g;

# TODO            $self->{classifier__}->{parameters}{$class}{count} += 1;
            $self->config_( 'mcount' )  += 1;
            $stats_changed                                    = 1;

            $self->log_( "Incrementing $class for $kid" );
        } else {
            # This is here so that we get in errorneous position where the pipeready
            # function is returning that there's data, but there is none, in fact the
            # pipe is dead then we break the cycle here.  This was happening to me when
            # I tested POPFile running under cygwin.

            last;
        }
    }

    if ( $stats_changed ) {
        $self->{ui}->invalidate_history_cache();
        $self->{configuration}->save_configuration();
        $self->{classifier__}->write_parameters();
    }
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a POP3 client
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
    $self->tee_( $client, "+OK POP3 POPFile (vTODO.TODO.TODO) server ready$eol" );

    # Retrieve commands from the client and process them until the client disconnects or
    # we get a specific QUIT command
    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end
        $command =~ s/(\015|\012)//g;

        $self->log_( "Command: --$command--" );

        # The USER command is a special case because we modify the syntax of POP3 a little
        # to expect that the username being passed is actually of the form host:username where
        # host is the actual remote mail server to contact and username is the username to
        # pass through to that server and represents the account on the remote machine that we
        # will pull email from.  Doing this means we can act as a proxy for multiple mail clients
        # and mail accounts
	my $user_command = 'USER (.+)(:(\d+))?' . $self->config_( 'separator' ) . '(.+)';
        if ( $command =~ /$user_command/i ) { 
            if ( $1 ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client, $1, $3 || 110 ) )  {
                    # Pass through the USER command with the actual user name for this server,
                    # and send the reply straight to the client
                    $self->echo_response_($mail, $client, 'USER ' . $4 );
                } else {
                    last;
                }
            } else {
                $self->tee_(  $client, "-ERR server name not specified in USER command$eol" );
                last;
            }

            $self->flush_extra_( $mail, $client, 0 );
            next;
        }

        # User is issuing the APOP command to start a session with the remote server
        if ( $command =~ /APOP (.*):((.*):)?(.*) (.*)/i ) {
            if ( $mail = $self->verify_connected_( $mail, $client,  $1, $3 || 110 ) )  {
                # Pass through the USER command with the actual user name for this server,
                # and send the reply straight to the client
                $self->echo_response_($mail, $client, "APOP $4 $5" );
            } else {
                last;
            }

            $self->flush_extra_( $mail, $client, 0 );
            next;
        }

        # Secure authentication
        if ( $command =~ /AUTH ([^ ]+)/ ) {
            if ( $self->config_( 'server' ) ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client,  $self->config_( 'server' ), $self->config_( 'sport' ) ) )  {
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

                $self->flush_extra_( $mail, $client, 0 );
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        if ( $command =~ /AUTH/ ) {
            if ( $self->config_( 'server' ) ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client,  $self->config_( 'server' ), $self->config_( 'sport' ) ) )  {
                    if ( $self->echo_response_($mail, $client, "AUTH" ) ) {
                        $self->echo_to_dot_( $mail, $client );
                    }
                } else {
                    last;
                }

                $self->flush_extra_( $mail, $client, 0 );
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        # The client is requesting a LIST/UIDL of the messages
        if ( ( $command =~ /LIST ?(.*)?/i ) ||
             ( $command =~ /UIDL ?(.*)?/i ) ) {
            if ( $self->echo_response_($mail, $client, $command ) ) {
                $self->echo_to_dot_( $mail, $client ) if ( $1 eq '' );
            }

            $self->flush_extra_( $mail, $client, 0 );
            next;
        }

        # TOP handling is rather special because we have three cases that we handle
        #
        # 1. If the client sends TOP x 99999999 then it is most likely to be
        #    fetchmail and the intent of fetchmail is to actually get the message
        #    but for its own reasons it does not use RETR.  We use RETR as the clue
        #    to place a message in the history, so we have a hack.  If the client
        #    looks like fetchmail then TOP x 99999999 is actually implemented
        #    using RETR
        #
        # 2. The toptoo configuration controls whether email downloaded using the
        #    TOP command is classified or not (note that it is *never* placed in
        #    the history; with the expection of (1) above).  There are two cases:
        #
        # 2a If toptoo is 0 then POPFile will pass a TOP from the client through
        #    as a TOP and do no classification on the message.
        #
        # 2b If toptoo is 1 then POPFile first does a RETR on the message without
        #    saving it in the history so that it can get the classification on the
        #    message which is stores in $class.  Then it gets the message again
        #    by sending the TOP command and passing the result through
        #    classify_and_modify passing in the $class determined above.  This means
        #    that the message gets the right classification and the client only
        #    gets the headers requested plus so many lines of body, but they will
        #    get subject modification, and the XTC and XPL headers add.  Note that
        #    TOP always returns the full headers and then n lines of the body so
        #    we are guaranteed to be able to do our header modifications.
        #
        #    NOTE using toptoo=1 on a slow link could cause performance problems,
        #    it is only intended for use where there is high bandwidth between
        #    POPFile and the POP3 server.

        if ( $command =~ /TOP (.*) (.*)/i ) {
            if ( $2 ne '99999999' )  {
                if ( $self->config_( 'toptoo' ) ) {
                    if ( $self->echo_response_($mail, $client, "RETR $1" ) ) {
                        my $class = $self->{classifier__}->classify_and_modify( $mail, $client, $download_count, $count, 1, '' );
                        if ( $self->echo_response_($mail, $client, $command ) ) {
                            $self->{classifier__}->classify_and_modify( $mail, $client, $download_count, $count, 0, $class );

                            # Tell the parent that we just handled a mail
                            print $pipe "$class$eol";
                        }
                    }
                } else {
                    $self->echo_to_dot_( $mail, $client ) if ( $self->echo_response_($mail, $client, $command ) );
                }
                $self->flush_extra_( $mail, $client, 0 );
                next;
            }

            # Note the fall through here.  Later down the page we look for TOP x 99999999 and
            # do a RETR instead
        }

        # The CAPA command
        if ( $command =~ /CAPA/i ) {
            if ( $self->config_( 'server' ) ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client, $self->config_( 'server' ), $self->config_( 'sport' ) ) )  {
                    $self->echo_to_dot_( $mail, $client ) if ( $self->echo_response_($mail, $client, "CAPA" ) );
                } else {
                    last;
                }
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            $self->flush_extra_( $mail, $client, 0 );
            next;
        }

        # The HELO command results in a very simple response from us.  We just echo that
        # we are ready for commands
        if ( $command =~ /HELO/i ) {
            $self->tee_(  $client, "+OK HELO POPFile Server Ready$eol" );
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
            $self->echo_response_($mail, $client, $command );
            $self->flush_extra_( $mail, $client, 0 );
            next;
        }

        # The client is requesting a specific message.
        # Note the horrible hack here where we detect a command of the form TOP x 99999999 this
        # is done so that fetchmail can be used with POPFile.
        if ( ( $command =~ /RETR (.*)/i ) || ( $command =~ /TOP (.*) 99999999/i ) )  {
            # Get the message from the remote server, if there's an error then we're done, but if not then
            # we echo each line of the message until we hit the . at the end
            if ( $self->echo_response_($mail, $client, $command ) ) {
                $count += 1;
                my $class = $self->{classifier__}->classify_and_modify( $mail, $client, $download_count, $count, 0, '' );

                # Tell the parent that we just handled a mail
                print $pipe "$class$eol";

                $self->flush_extra_( $mail, $client, 0 );
                next;
            }
        }

        # The mail client wants to stop using the server, so send that message through to the
        # real mail server, echo the response back up to the client and exit the while.  We will
        # close the connection immediately
        if ( $command =~ /QUIT/i ) {
            if ( $mail )  {
                $self->echo_response_($mail, $client, $command );
                close $mail;
            } else {
                $self->tee_(  $client, "+OK goodbye$eol" );
            }
            last;
        }

        # Don't know what this is so let's just pass it through and hope for the best
        if ( $mail && $mail->connected )  {
            $self->echo_response_($mail, $client, $command );
            $self->flush_extra_( $mail, $client, 0 );
            next;
        } else {
            $self->tee_(  $client, "-ERR unknown command or bad syntax$eol" );
            last;
        }
    }

    close $mail if defined( $mail );
    close $client;
    close $pipe;

    $self->log_( "POP3 forked child done" );
}

# TODO echo_response_ that calls echo_response_ with the extra parameters
# required et al.
