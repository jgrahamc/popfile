# POPFILE LOADABLE MODULE
package Proxy::POP3;

use Proxy::Proxy;
use Digest::MD5;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the POP3 protocol for POPFile.
#
# Copyright (c) 2001-2004 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
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

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '-ERR no response from mail server';
    $self->{connection_failed_error_}  = '-ERR can\'t connect to';
    $self->{good_response_}            = '^\+OK';

    # Client requested APOP
    $self->{use_apop__} = 0;

    # APOP username
    $self->{apop_user__} = '';

    # The APOP portion of the banner sent by the POP3 server
    $self->{apop_banner__} = undef;

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

    # Enabled by default
    $self->config_( 'enabled', 1);

    # By default we don't fork on Windows
    $self->config_( 'force_fork', ($^O eq 'MSWin32')?0:1 );

    # Default ports for POP3 service and the user interface
    $self->config_( 'port', 110 );

    # There is no default setting for the secure server
    $self->config_( 'secure_server', '' );
    $self->config_( 'secure_port', 110 );

    # Only accept connections from the local machine for POP3
    $self->config_( 'local', 1 );

    # Whether to do classification on TOP as well
    $self->config_( 'toptoo', 0 );

    # The separator within the POP3 username is :
    $self->config_( 'separator', ':' );

    # The welcome string from the proxy is configurable
    $self->config_( 'welcome_string',
        "POP3 POPFile ($self->{version_}) server ready" );

    return $self->SUPER::initialize();
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # If we are not enabled then no further work happens in this module

    if ( $self->config_( 'enabled' ) == 0 ) {
        return 2;
    }

    # Tell the user interface module that we having a configuration
    # item that needs a UI component

    $self->register_configuration_item_( 'configuration',              # PROFILE BLOCK START
                                         'pop3_configuration',
                                         'pop3-configuration-panel.thtml',
                                         $self );                      # PROFILE BLOCK STOP

    $self->register_configuration_item_( 'security',                   # PROFILE BLOCK START
                                         'pop3_security',
                                         'pop3-security-panel.thtml',
                                         $self );                      # PROFILE BLOCK STOP

    $self->register_configuration_item_( 'chain',                      # PROFILE BLOCK START
                                         'pop3_chain',
                                         'pop3-chain-panel.thtml',
                                         $self );                      # PROFILE BLOCK STOP

    if ( $self->config_( 'welcome_string' ) =~ /^POP3 POPFile \(v\d+\.\d+\.\d+\) server ready$/ ) { # PROFILE BLOCK START
        $self->config_( 'welcome_string', "POP3 POPFile ($self->{version_}) server ready" );        # PROFILE BLOCK STOP
    }

    return $self->SUPER::start();
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client         - an open stream to a POP3 client
# $session        - API session key
#
# ---------------------------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $session ) = @_;

    # Hash of indexes of downloaded messages mapped to their
    # slot IDs

    my %downloaded;

    # The handle to the real mail server gets stored here

    my $mail;

    $self->{apop_banner__} = undef;
    $self->{use_apop__} = 0;
    $self->{apop_user__} = '';

    # Tell the client that we are ready for commands and identify our
    # version number

    $self->tee_( $client, "+OK " . $self->config_( 'welcome_string' ) . "$eol" );

    # Compile some configurable regexp's once

    my $transparent  = '^USER ([^:])+$';
    my $user_command = 'USER ([^:]+)(:(\d+))?' . $self->config_( 'separator' ) . '([^:]+)(:([^:]+))?';
    my $apop_command = 'APOP ([^:]+)(:(\d+))?' . $self->config_( 'separator' ) . '([^:]+) (.*?)';

    # Retrieve commands from the client and process them until the
    # client disconnects or we get a specific QUIT command

    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the
        # end

        $command =~ s/(\015|\012)//g;

        $self->log_( 2, "Command: --$command--" );

        # The USER command is a special case because we modify the
        # syntax of POP3 a little to expect that the username being
        # passed is actually of the form host:username where host is
        # the actual remote mail server to contact and username is the
        # username to pass through to that server and represents the
        # account on the remote machine that we will pull email from.
        # Doing this means we can act as a proxy for multiple mail
        # clients and mail accounts
        #
        # When the client issues the command "USER host:username:apop"
        # POPFile must acknowledge the command and be prepared to
        # compute the md5 digest of the user's password and the real
        # pop server's banner upon receipt of a PASS command.
        #
        # When the client issues the command "USER host:username:ssl"
        # POPFile will use SSL for the connection to the remote, note
        # that the user can say host:username:ssl,apop if both are
        # needed

        if ( $command =~ /$transparent/ ) {
            if ( $self->config_( 'secure_server' ) ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client,  $self->config_( 'secure_server' ), $self->config_( 'secure_port' ) ) )  {
                    last if ($self->echo_response_($mail, $client, $command) == 2 );
                } else {
                    next;
                }
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        if ( $command =~ /$user_command/io ) {
            if ( $1 ne '' )  {
                my ( $host, $port, $user, $options ) = ($1, $3, $4, $6);

                $self->mq_post_( 'LOGIN', $user );

                my $ssl = defined( $options ) && ( $options =~ /ssl/i );
                $port = 110 if ( !defined( $port ) );

                if ( $mail = $self->verify_connected_( $mail, $client, $host, $port, $ssl ) )  {

                    if ( defined( $options ) && ( $options =~ /apop/i ) ) {

                        # We want to make sure the server sent a real
                        # APOP banner, containing <>'s

                        $self->{apop_banner__} = $1 if $self->{connect_banner__} =~ /(<[^>]+>)/;
                        $self->log_( 2, "banner=" . $self->{apop_banner__} ) if defined( $self->{apop_banner__} );

                        # any apop banner is ok

                        if ( defined($self->{apop_banner__})) {
                            $self->{use_apop__} = 1; #
                            $self->log_( 2, "auth APOP" );
                            $self->{apop_user__} = $user;

                            # tell the client that username was
                            # accepted don't flush_extra, we didn't
                            # send anything to the real server

                            $self->tee_( $client, "+OK hello $user$eol" );
                            next;
                        } else {

                            # If the client asked for APOP, and the
                            # server doesn't have the correct banner,
                            # give a meaningful error instead of
                            # whatever error the server might have if
                            # we try to make up a hash

                            $self->{use_apop__} = 0;
                            $self->tee_( $client, "-ERR $host doesn't support APOP, aborting authentication$eol" );
                            next;
                        }
                    } else {

                        # Pass through the USER command with the
                        # actual user name for this server, and send
                        # the reply straight to the client

                        $self->log_( 2, "auth plaintext" );
                        $self->{use_apop__} = 0;         # signifies a non-apop connection
                        last if ($self->echo_response_( $mail, $client, 'USER ' . $user ) == 2 );
                    }

                } else {

                    # If the login fails then we want to continue in
                    # the unlogged in state so that clients can send
                    # us the QUIT command

                    next;
                }
            }

            next;
        }

        # User is issuing the APOP command to start a session with the
        # remote server

        if ( ( $command =~ /PASS (.*)/i ) ) {
            if ( $self->{use_apop__} ) {

                # Authenticate with APOP

                my $md5 = Digest::MD5->new;

                $md5->add( $self->{apop_banner__}, $1 );
                my $md5hex = $md5->hexdigest;
                $self->log_( 2, "digest='$md5hex'" );

                my ($response, $ok) =
                    $self->get_response_( $mail, $client,
                        "APOP $self->{apop_user__} $md5hex", 0, 1 );
                if ( ( $ok == 1 ) &&
                     ( $response =~ /$self->{good_response_}/ ) ) {

                    # authentication OK, toss the hello response and
                    # return password ok

                    $self->tee_( $client, "+OK password ok$eol" );
                } else {
                    $self->tee_( $client, "$response" );
                }
             } else {
               last if ($self->echo_response_($mail, $client, $command) == 2 );
             }
             next;
        }

        # User is issuing the APOP command to start a session with the
        # remote server We'd need a copy of the plaintext password to
        # support this.

        if ( $command =~ /$apop_command/io ) {
            $self->tee_( $client,
              "-ERR APOP not supported between mail client and POPFile.$eol" );

            # TODO: Consider implementing a host:port:username:secret
            # hash syntax for proxying the APOP command

            next;
        }

        # Secure authentication

        if ( $command =~ /AUTH ([^ ]+)/ ) {
            if ( $self->config_( 'secure_server' ) ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client,  $self->config_( 'secure_server' ), $self->config_( 'secure_port' ) ) )  {

                    # Loop until we get -ERR or +OK

                    my ( $response, $ok ) = $self->get_response_( $mail, $client, $command );

                    while ( ( ! ( $response =~ /\+OK/ ) ) && ( ! ( $response =~ /-ERR/ ) ) ) {
                        my $auth;
                        $auth = <$client>;
                        $auth =~ s/(\015|\012)$//g;
                        ( $response, $ok ) = $self->get_response_( $mail, $client, $auth );
                    }
                } else {
                    next;
                }
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        if ( $command =~ /AUTH/ ) {
            if ( $self->config_( 'secure_server' ) ne '' )  {
                if ( $mail = $self->verify_connected_( $mail, $client,  $self->config_( 'secure_server' ), $self->config_( 'secure_port' ) ) )  {
                    my $response = $self->echo_response_($mail, $client, "AUTH" );
                    last if ( $response == 2 );
                    if ( $response == 0 ) {
                        $self->echo_to_dot_( $mail, $client );
                    }
                } else {
                    next;
                }
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        # The client is requesting a LIST/UIDL of the messages

        if ( ( $command =~ /LIST ?(.*)?/i ) ||       # PROFILE BLOCK START
             ( $command =~ /UIDL ?(.*)?/i ) ) {      # PROFILE BLOCK STOP
            my $response = $self->echo_response_($mail, $client, $command );
            last if ( $response == 2 );
            if ( $response == 0 ) {
                $self->echo_to_dot_( $mail, $client ) if ( $1 eq '' );
            }

            next;
        }

        # TOP handling is rather special because we have three cases
        # that we handle
        #
        # 1. If the client sends TOP x 99999999 then it is most likely
        #    to be fetchmail and the intent of fetchmail is to
        #    actually get the message but for its own reasons it does
        #    not use RETR.  We use RETR as the clue to place a message
        #    in the history, so we have a hack.  If the client looks
        #    like fetchmail then TOP x 99999999 is actually
        #    implemented using RETR
        #
        # 2. The toptoo configuration controls whether email
        #    downloaded using the TOP command is classified or not (It
        #    may be downloaded and cached for bandwidth efficiency, and
        #    thus appear in the history).  There are two cases:
        #
        # 2a If toptoo is 0 then POPFile will pass a TOP from the
        #    client through as a TOP and do no classification on the
        #    message.
        #
        # 2b If toptoo is 1 then POPFile first does a RETR on the
        #    message and saves it in the history so that it can get the
        #    classification on the message which is stores in $class.
        #    Then it gets the message again by sending the TOP command
        #    and passing the result through classify_and_modify passing
        #    in the $class determined above.  This means that the message
        #    gets the right classification and the client only gets the
        #    headers requested plus so many lines of body, but they will
        #    get subject modification, and the XTC and XPL headers add.
        #    Note that TOP always returns the full headers and then n
        #    lines of the body so we are guaranteed to be able to do our
        #    header modifications.
        #
        # NOTE messages retrieved using TOPTOO are visible in the
        #      history as they are "cached" to avoid requiring repeated
        #      downloads if the client issues a RETR for the message in
        #      the same session
        #
        # NOTE using toptoo=1 on a slow link could cause
        #      performance problems, in cases where only the headers,
        #      but not classification, is required.  toptoo=1 is,
        #      however, appropriate for normal use via a mail client and
        #      won't significantly increase bandwidth unless the mail
        #      client is selectively downloading messages based on
        #      non-classification data in the TOP headers.

        if ( $command =~ /TOP (.*) (.*)/i ) {
            my $count = $1;

            if ( $2 ne '99999999' )  {
                if ( $self->config_( 'toptoo' ) == 1 ) {
                    my $response =
                        $self->echo_response_( $mail, $client, "RETR $count" );
                    last if ( $response == 2 );
                    if ( $response == 0 ) {

                        # Classify without echoing to client, saving
                        # file for later RETR's

                        my ( $class, $slot ) =
                             $self->{classifier__}->classify_and_modify(
                                 $session, $mail, $client, 0, '', 0, 0 );

                        $downloaded{$count} = $slot;

                        # Note that the 1 here indicates that
                        # echo_response_ does not send the response to
                        # the client.  The +OK has already been sent
                        # by the RETR

                        $response =
                            $self->echo_response_( $mail, $client,
                                $command, 1 );
                        last if ( $response == 2 );
                        if ( $response == 0 ) {

                            # Classify with pre-defined class, without
                            # saving, echoing to client

                            $self->{classifier__}->classify_and_modify(
                                $session, $mail, $client, 1, $class, $slot, 1 );
                        }
                    }
                } else {
                    my $response =
                        $self->echo_response_( $mail, $client, $command );
                    last if ( $response == 2 );
                    if ( $response == 0 ) {
                        $self->echo_to_dot_( $mail, $client );
		    }
                }

                next;
            }

            # Note the fall through here.  Later down the page we look
            # for TOP x 99999999 and do a RETR instead
        }

        # The CAPA command

        if ( $command =~ /CAPA/i ) {
            if ( $mail || $self->config_( 'secure_server' ) ne '' )  {
                if ( $mail || ( $mail = $self->verify_connected_( $mail, $client, $self->config_( 'secure_server' ), $self->config_( 'secure_port' ) ) ) )  {
                    my $response = $self->echo_response_($mail, $client, "CAPA" );
                    last if ( $response == 2 );
                    if ( $response == 0 ) {
                        $self->echo_to_dot_( $mail, $client );
		    }
                } else {
                    next;
                }
            } else {
                $self->tee_(  $client, "-ERR No secure server specified$eol" );
            }

            next;
        }

        # The HELO command results in a very simple response from us.
        # We just echo that we are ready for commands

        if ( $command =~ /HELO/i ) {
            $self->tee_(  $client, "+OK HELO POPFile Server Ready$eol" );
            next;
        }

        # In the case of PASS, NOOP, XSENDER, STAT, DELE and RSET
        # commands we simply pass it through to the real mail server
        # for processing and echo the response back to the client

        if ( ( $command =~ /NOOP/i )         ||                 # PROFILE BLOCK START
             ( $command =~ /STAT/i )         ||
             ( $command =~ /XSENDER (.*)/i ) ||
             ( $command =~ /DELE (.*)/i )    ||
             ( $command =~ /RSET/i ) ) {                        # PROFILE BLOCK STOP
            last if ( $self->echo_response_($mail, $client, $command ) == 2 );
            next;
        }

        # The client is requesting a specific message.  Note the
        # horrible hack here where we detect a command of the form TOP
        # x 99999999 this is done so that fetchmail can be used with
        # POPFile.

        if ( ( $command =~ /RETR (.*)/i ) || ( $command =~ /TOP (.*) 99999999/i ) )  {
            my $count = $1;
            my $class;
            my $file;

            if ( defined($downloaded{$count}) &&
                 ( $file = $self->{history__}->get_slot_file( $downloaded{$count} ) ) &&
                 (open RETRFILE, "<$file") ) {

                # act like a network stream

                binmode RETRFILE;

                # File has been fetched and classified already

                $self->log_( 1, "Printing message from cache" );

                # Give the client an +OK:

                $self->tee_( $client, "+OK " . ( -s $file ) . " bytes from POPFile cache$eol" );

                # Load the last classification

                my ( $id, $from, $to, $cc, $subject,
                    $date, $hash, $inserted, $bucket, $reclassified ) =
                    $self->{history__}->get_slot_fields( $downloaded{$count} );

                if ( $bucket ne 'unknown class' ) {

                    # echo file, inserting known classification,
                    # without saving

                    ($class, undef) = $self->{classifier__}->classify_and_modify( $session, \*RETRFILE, $client, 1, $bucket, $downloaded{$count} );
                    print $client ".$eol";

                } else {

                    # If the class wasn't saved properly, classify
                    # from disk normally

                    ($class, undef) = $self->{classifier__}->classify_and_modify( $session, \*RETRFILE, $client, 1, '', 0 );
                    print $client ".$eol";
                }

                close RETRFILE;
            } else {

                # Retrieve file directly from the server

                # Get the message from the remote server, if there's
                # an error then we're done, but if not then we echo
                # each line of the message until we hit the . at the
                # end

                my $response = $self->echo_response_($mail, $client, $command );

                last if ( $response == 2 );
                if ( $response == 0 ) {
                    my $slot;
                    ( $class, $slot ) = $self->{classifier__}->classify_and_modify( $session, $mail, $client, 0, '', 0 );

                    # Note locally that file has been retrieved if the
                    # full thing has been saved to disk

                    $downloaded{$count} = $slot;
                }
            }

            next;
        }

        # The mail client wants to stop using the server, so send that
        # message through to the real mail server, echo the response
        # back up to the client and exit the while.  We will close the
        # connection immediately

        if ( $command =~ /QUIT/i ) {
            if ( $mail )  {
                last if ( $self->echo_response_( $mail, $client, $command ) == 2 );
                close $mail;
            } else {
                $self->tee_( $client, "+OK goodbye$eol" );
            }
            last;
        }

        # Don't know what this is so let's just pass it through and
        # hope for the best

        if ( $mail && $mail->connected )  {
            last if ( $self->echo_response_($mail, $client, $command ) == 2 );
            next;
        } else {
            $self->tee_(  $client, "-ERR unknown command or bad syntax$eol" );
            next;
        }

    }

    if ( defined( $mail ) ) {
        $self->done_slurp_( $mail );
        close $mail;
    }

    close $client;
    $self->mq_post_( 'CMPLT', $$ );
    $self->log_( 0, "POP3 proxy done" );
}

# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            Name of this item
#    $templ           The loaded template that was passed as a parameter
#                     when registering
#    $language        Current language
#
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    if ( $name eq 'pop3_configuration' ) {
        $templ->param( 'POP3_Configuration_If_Force_Fork' => ( $self->config_( 'force_fork' ) == 0 ) );
        $templ->param( 'POP3_Configuration_Port'          => $self->config_( 'port' ) );
        $templ->param( 'POP3_Configuration_Separator'     => $self->config_( 'separator' ) );
    } else {
        if ( $name eq 'pop3_security' ) {
            $templ->param( 'POP3_Security_Local' => ( $self->config_( 'local' ) == 1 ) );
	} else {
            if ( $name eq 'pop3_chain' ) {
                $templ->param( 'POP3_Chain_Secure_Server' => $self->config_( 'secure_server' ) );
                $templ->param( 'POP3_Chain_Secure_Port' => $self->config_( 'secure_port' ) );
	    } else {
                $self->SUPER::configure_item( $name, $templ, $language );
	    }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    if ( $name eq 'pop3_configuration' ) {
        if ( defined($$form{pop3_port}) ) {
            if ( ( $$form{pop3_port} >= 1 ) && ( $$form{pop3_port} < 65536 ) ) {
                $self->config_( 'port', $$form{pop3_port} );
                $templ->param( 'POP3_Configuration_If_Port_Updated' => 1 );
                $templ->param( 'POP3_Configuration_Port_Updated' => sprintf( $$language{Configuration_POP3Update}, $self->config_( 'port' ) ) );
            } else {
                $templ->param( 'POP3_Configuration_If_Port_Error' => 1 );
            }
        }

        if ( defined($$form{pop3_separator}) ) {
            if ( length($$form{pop3_separator}) == 1 ) {
                $self->config_( 'separator', $$form{pop3_separator} );
                $templ->param( 'POP3_Configuration_If_Sep_Updated' => 1 );
                $templ->param( 'POP3_Configuration_Sep_Updated' => sprintf( $$language{Configuration_POP3SepUpdate}, $self->config_( 'separator' ) ) );
            } else {
                $templ->param( 'POP3_Configuration_If_Sep_Error' => 1 );
            }
        }

        if ( defined($$form{pop3_force_fork}) ) {
            $self->config_( 'force_fork', $$form{pop3_force_fork} );
        }

        return;
    }

    if ( $name eq 'pop3_security' ) {
        $self->config_( 'local', $$form{pop3_local}-1 ) if ( defined($$form{pop3_local}) );

        return;
    }

    if ( $name eq 'pop3_chain' ) {
        if ( defined( $$form{server} ) ) {
            $self->config_( 'secure_server', $$form{server} );
            $templ->param( 'POP3_Chain_If_Server_Updated' => 1 );
            $templ->param( 'POP3_Chain_Server_Updated' => sprintf( $$language{Security_SecureServerUpdate}, $self->config_( 'secure_server' ) ) );
	}

        if ( defined($$form{sport}) ) {
            if ( ( $$form{sport} >= 1 ) && ( $$form{sport} < 65536 ) ) {
                $self->config_( 'secure_port', $$form{sport} );
                $templ->param( 'POP3_Chain_If_Port_Updated' => 1 );
                $templ->param( 'POP3_Chain_Port_Updated' => sprintf( $$language{Security_SecurePortUpdate}, $self->config_( 'secure_port' ) ) );
            } else {
                $templ->param( 'POP3_Chain_If_Port_Error' => 1 );
            }
        }

        return;
    }

    $self->SUPER::validate_item( $name, $templ, $language, $form );
}

