# POPFILE LOADABLE MODULE
package Proxy::NNTP;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ----------------------------------------------------------------------------
#
# This module handles proxying the NNTP protocol for POPFile.
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
# ----------------------------------------------------------------------------

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

    $self->name( 'nntp' );

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '500 no response from mail server';
    $self->{connection_failed_error_}  = '500 can\'t connect to';
    $self->{good_response_}            = '^(1|2|3)\d\d';

    return $self;
}

# ----------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the NNTP proxy module
#
# ----------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # Disabled by default

    $self->config_( 'enabled', 0);

    # By default we don't fork on Windows

    $self->config_( 'force_fork', ($^O eq 'MSWin32')?0:1 );

    # Default ports for NNTP service and the user interface

    $self->config_( 'port', 119 );

    # Only accept connections from the local machine for NNTP

    $self->config_( 'local', 1 );

    # The separator within the NNTP user name is :

    $self->config_( 'separator', ':');

    # The welcome string from the proxy is configurable

    $self->config_( 'welcome_string',
        "NNTP POPFile ($self->{version_}) server ready" );

    if ( !$self->SUPER::initialize() ) {
        return 0;
    }

    $self->config_( 'enabled', 0 );

    return 1;
}

# ----------------------------------------------------------------------------
#
# start
#
# Called to start the NNTP proxy module
#
# ----------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # If we are not enabled then no further work happens in this module

    if ( $self->config_( 'enabled' ) == 0 ) {
        return 2;
    }

    # Tell the user interface module that we having a configuration
    # item that needs a UI component

    $self->register_configuration_item_( 'configuration',
                                         'nntp_port',
                                         'nntp-port.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'nntp_force_fork',
                                         'nntp-force-fork.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'nntp_separator',
                                         'nntp-separator.thtml',
                                         $self );

    $self->register_configuration_item_( 'security',
                                         'nntp_local',
                                         'nntp-security-local.thtml',
                                         $self );

    return $self->SUPER::start();; }

# ----------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a NNTP client
# $session        - API session key
#
# ----------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $session ) = @_;

    # Number of messages downloaded in this session

    my $count = 0;

    # The handle to the real news server gets stored here

    my $news;

    # The state of the connection (username needed, password needed,
    # authenticated/connected)

    my $connection_state = 'username needed';

    # Tell the client that we are ready for commands and identify our
    # version number

    $self->tee_( $client, "201 " . $self->config_( 'welcome_string' ) .
        "$eol" );

    # Retrieve commands from the client and process them until the
    # client disconnects or we get a specific QUIT command

    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end

        $command =~ s/(\015|\012)//g;

        $self->log_( 2, "Command: --$command--" );

        # The news client wants to stop using the server, so send that
        # message through to the real news server, echo the response
        # back up to the client and exit the while.  We will close the
        # connection immediately

        if ( $command =~ /^ *QUIT/i ) {
            if ( $news )  {
                last if ( $self->echo_response_( $news, $client, $command ) ==
                         2 );
                close $news;
            } else {
                $self->tee_( $client, "205 goodbye$eol" );
            }
            last;
        }

        if ($connection_state eq 'username needed') {

            # NOTE: This syntax is ambiguous if the NNTP username is a
            # short (under 5 digit) string (eg, 32123).  If this is
            # the case, run "perl popfile.pl -nntp_separator /" and
            # change your kludged username appropriately (syntax would
            # then be server[:port][/username])

            my $user_command = '^ *AUTHINFO USER ([^:]+)(:([\d]{1,5}))?(\\' .
                $self->config_( 'separator' ) . '(.+))?';

            if ( $command =~ /$user_command/i ) {
                my $server = $1;

                # hey, the port has to be in range at least

                my $port = $3 if ( defined($3) && ($3 > 0) && ($3 < 65536) );
                my $username = $5;

                if ( $server ne '' )  {
                    if ( $news = $self->verify_connected_( $news, $client,
                        $server, $port || 119 ) )  {
                        if (defined $username) {

                            # Pass through the AUTHINFO command with
                            # the actual user name for this server, if
                            # one is defined, and send the reply
                            # straight to the client

                            $self->get_response_( $news, $client,
                                'AUTHINFO USER ' . $username );
                            $connection_state = "password needed";
                        } else {

                            # Signal to the client to send the password

                            $self->tee_($client, "381 password$eol");
                            $connection_state = "ignore password";
                        }
                    } else {
                        last;
                    }
                } else {
                    $self->tee_( $client,
                        "482 Authentication rejected server name not specified in AUTHINFO USER command$eol" );
                    last;
                }

                $self->flush_extra_( $news, $client, 0 );
                next;
            } else {

                # Issue a 480 authentication required response

                $self->tee_( $client, "480 Authorization required for this command$eol" );
                next;
            }
        } elsif ( $connection_state eq "password needed" ) {
            if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
                my ( $response, $ok ) = $self->get_response_( $news, $client,
                                            $command);

                if ($response =~ /^281 .*/) {
                    $connection_state = "connected";
                }
                next;
            } else {

                # Issue a 381 more authentication required response

                $self->tee_( $client, "381 more authentication required for this command$eol" );
                next;
            }
        } elsif ($connection_state eq "ignore password") {
            if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
                $self->tee_($client, "281 authentication accepted$eol");
                $connection_state = "connected";
                next;
            } else {

                # Issue a 480 authentication required response

                $self->tee_( $client, "381 more authentication required for this command$eol" );
                next;
            }
        } elsif ( $connection_state eq "connected" ) {

            # COMMANDS USED DIRECTLY WITH THE REMOTE NNTP SERVER GO HERE

            # The client wants to retrieve an article. We oblige, and
            # insert classification headers.

            if ( $command =~ /^ *ARTICLE (.*)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client,
                                            $command);
                if ( $response =~ /^220 (.*) (.*)$/i) {
                    $count += 1;

                    my ( $class, $history_file ) =
                        $self->{classifier__}->classify_and_modify( $session,
                            $news, $client, 0, '', 0 );
                }

                next;
            }

            # Commands expecting a code + text response

            if ( $command =~ 
                /^ *(LIST|HEAD|BODY|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|XOVER|XPAT|XROVER|XTHREAD)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news,
                                            $client, $command);

                # 2xx (200) series response indicates multi-line text
                # follows to .crlf

                if ( $response =~ /^2\d\d/ ) {
                    $self->echo_to_dot_( $news, $client, 0 );
                }
                next;
            }

            # Exceptions to 200 code above

            if ( $ command =~ /^ *(HELP)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client,
                                            $command);
                if ( $response =~ /^1\d\d/ ) {
                    $self->echo_to_dot_( $news, $client, 0 );
                }
                next;
            }

            # Commands expecting a single-line response

            if ( $command =~ 
                /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i ) {
                $self->get_response_( $news, $client, $command );
                next;
            }

            # Commands followed by multi-line client response

            if ( $command =~ /^ *(IHAVE|POST|XRELPIC)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client,
                                            $command);

                # 3xx (300) series response indicates multi-line text
                # should be sent, up to .crlf

                if ($response =~ /^3\d\d/ ) {

                    # Echo from the client to the server

                    $self->echo_to_dot_( $client, $news, 0 );

                    # Echo to dot doesn't provoke a server response
                    # somehow, we add another CRLF

                    $self->get_response_( $news, $client, "$eol" );
                }
                next;
            }
        }

        # Commands we expect no response to, such as the null command

        if ( $ command =~ /^ *$/ ) {
            if ( $news && $news->connected ) {
                $self->get_response_( $news, $client, $command, 1 );
                next;
            }
        }

        # Don't know what this is so let's just pass it through and
        # hope for the best

        if ( $news && $news->connected)  {
            $self->echo_response_($news, $client, $command );
            next;
        } else {
            $self->tee_(  $client, "500 unknown command or bad syntax$eol" );
            last;
        }
    }

    if ( defined( $news ) ) {
        $self->done_slurp_( $news );
        close $news;
    }
    close $client;
    $self->mq_post_( 'CMPLT', $$ );
    $self->log_( 0, "NNTP proxy done" );
}

# ----------------------------------------------------------------------------
#
# configure_item
#
#    $name            Name of this item
#    $templ           The loaded template that was passed as a parameter
#                     when registering
#    $language        Current language
#
# ----------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    if ( $name eq 'nntp_port' ) {
        $templ->param( 'nntp_port' => $self->config_( 'port' ) );
    }

    # Separator Character widget
    if ( $name eq 'nntp_separator' ) {
        $templ->param( 'nntp_separator' => $self->config_( 'separator' ) );
    }

    if ( $name eq 'nntp_local' ) {
        $templ->param( 'nntp_if_local' => $self->config_( 'local' ) );
     }

    if ( $name eq 'nntp_force_fork' ) {
        $templ->param( 'nntp_force_fork_on' => $self->config_( 'force_fork' ) );
    }

    #$self->SUPER::configure_item( $name, $language, $session_key );
}

# ----------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ----------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    if ( $name eq 'nntp_port' ) {
        if ( defined $$form{nntp_port} ) {
            if ( ( $$form{nntp_port} >= 1 ) && ( $$form{nntp_port} < 65536 ) ) {
                $self->config_( 'port', $$form{nntp_port} );
                $templ->param( 'nntp_port_feedback' => sprintf $$language{Configuration_NNTPUpdate}, $self->config_( 'port' ) );
             } 
             else {
                 $templ->param( 'nntp_port_feedback' => "<div class=\"error01\">$$language{Configuration_Error3}</div>" );
             }
        }
    }

    if ( $name eq 'nntp_separator' ) {
        if ( defined $$form{nntp_separator} ) {
            if ( length($$form{nntp_separator}) == 1 ) {
                $self->config_( 'separator', $$form{nntp_separator} );
                $templ->param( 'nntp_separator_feedback' => sprintf $$language{Configuration_NNTPSepUpdate}, $self->config_( 'separator' ) );
            } 
            else {
                $templ->param( 'nntp_separator_feedback' => "<div class=\"error01\">\n$$language{Configuration_Error1}</div>\n" );
            }
        }
    }

    if ( $name eq 'nntp_local' ) {
        if ( defined $$form{nntp_local} ) {
            $self->config_( 'local', $$form{nntp_local} );
        }
    }


    if ( $name eq 'nntp_force_fork' ) {
        if ( defined $$form{nntp_force_fork} ) {
            $self->config_( 'force_fork', $$form{nntp_force_fork} );
        }
    }

    # $self->SUPER::validate_item( $name, $language, $form );
}

1;
