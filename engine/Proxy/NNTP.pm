# POPFILE LOADABLE MODULE
package Proxy::NNTP;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the NNTP protocol for POPFile.
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

    $self->name( 'nntp' );

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '500 no response from mail server';
    $self->{connection_failed_error_}  = '500 can\'t connect to';
    $self->{good_response_}            = '^(1|2|3)\d\d';

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the NNTP proxy module
#
# ---------------------------------------------------------------------------------------------
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
    $self->config_( 'welcome_string', "NNTP POPFile ($self->{version_}) server ready" );

    return $self->SUPER::initialize();;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to start the NNTP proxy module
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

    $self->register_configuration_item_( 'configuration',
                                         'nntp_port',
                                         $self );

    $self->register_configuration_item_( 'configuration',              # PROFILE BLOCK START
                                         'nntp_force_fork',
                                         $self );                      # PROFILE BLOCK STOP

    $self->register_configuration_item_( 'configuration',
                                         'nntp_separator',
                                         $self );

    $self->register_configuration_item_( 'security',
                                         'nntp_local',
                                         $self );

    return $self->SUPER::start();;
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a NNTP client
# $download_count - The unique download count for this session
#
# ---------------------------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $download_count, $pipe, $ppipe, $pid ) = @_;

    # Number of messages downloaded in this session
    my $count = 0;

    # The handle to the real news server gets stored here
    my $news;

    # The state of the connection (username needed, password needed, authenticated/connected)
    my $connection_state = 'username needed';

    # Tell the client that we are ready for commands and identify our version number
    $self->tee_( $client, "201 " . $self->config_( 'welcome_string' ) . "$eol" );

    # Retrieve commands from the client and process them until the client disconnects or
    # we get a specific QUIT command
    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end
        $command =~ s/(\015|\012)//g;

        $self->log_( "Command: --$command--" );

        # The news client wants to stop using the server, so send that message through to the
        # real news server, echo the response back up to the client and exit the while.  We will
        # close the connection immediately
        if ( $command =~ /^ *QUIT/i ) {
            if ( $news )  {
                last if ( $self->echo_response_( $news, $client, $command ) == 2 );
                close $news;
            } else {
                $self->tee_( $client, "205 goodbye$eol" );
            }
            last;
        }

        if ($connection_state eq 'username needed') {

            # NOTE: This syntax is ambiguous if the NNTP username is a short (under 5 digit) string (eg, 32123).
            # If this is the case, run "perl popfile.pl -nntp_separator /" and change your kludged username
            # appropriately (syntax would then be server[:port][/username])
            my $user_command = '^ *AUTHINFO USER ([^:]+)(:([\d]{1,5}))?(\\' . $self->config_( 'separator' ) . '(.+))?';

            if ( $command =~ /$user_command/i ) {
                my $server   = $1;
                # hey, the port has to be in range at least
                my $port     = $3 if ( defined($3) && ($3 > 0) && ($3 < 65536) );
                my $username = $5;

                if ( $server ne '' )  {
                    if ( $news = $self->verify_connected_( $news, $client, $server, $port || 119 ) )  {
                        if (defined $username) {

                            # Pass through the AUTHINFO command with the actual user name for this server,
                            # if one is defined, and send the reply straight to the client

                            $self->get_response_($news, $client, 'AUTHINFO USER ' . $username );
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
                    $self->tee_( $client, "482 Authentication rejected server name not specified in AUTHINFO USER command$eol" );
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
                my ( $response, $ok ) = $self->get_response_($news, $client, $command);

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

            # The client wants to retrieve an article. We oblige, and insert classification headers.

            if ( $command =~ /^ *ARTICLE (.*)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client, $command);
                if ( $response =~ /^220 (.*) (.*)$/i) {
                    $count += 1;

                    my ( $class, $history_file ) = $self->{classifier__}->classify_and_modify( $news, $client, $download_count, $count, 0, '' );

                    # Tell the parent that we just handled a mail

                    print $pipe "CLASS:$class$eol";
                    print $pipe "NEWFL:$history_file$eol";
                    flush $pipe;
                    $self->yield_( $ppipe, $pid );
                }

                next;
            }

            # Commands expecting a code + text response

            if ( $command =~ /^ *(LIST|HEAD|BODY|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|XOVER|XPAT|XROVER|XTHREAD)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client, $command);

                # 2xx (200) series response indicates multi-line text follows to .crlf

                $self->echo_to_dot_( $news, $client, 0 ) if ( $response =~ /^2\d\d/ );
                next;
            }

            # Exceptions to 200 code above

            if ( $ command =~ /^ *(HELP)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client, $command);
                $self->echo_to_dot_( $news, $client, 0 ) if ( $response =~ /^1\d\d/ );
                next;
            }

            # Commands expecting a single-line response

            if ( $command =~ /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i ) {
                $self->get_response_( $news, $client, $command );
                next;
            }

            # Commands followed by multi-line client response

            if ( $command =~ /^ *(IHAVE|POST|XRELPIC)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client, $command);

                # 3xx (300) series response indicates multi-line text should be sent, up to .crlf

                if ($response =~ /^3\d\d/ ) {

                    # Echo from the client to the server

                    $self->echo_to_dot_( $client, $news, 0 );

                    # Echo to dot doesn't provoke a server response somehow, we add another CRLF

                    $self->get_response_( $news, $client, "$eol" );
                }
                next;
            }
        }

        # Commands we expect no response to, such as the null command

        if ( $ command =~ /^ *$/ ) {
            if ( $news && $news->connected ) {
                $self->get_response_($news, $client, $command, 1);
                next;
            }
        }

        # Don't know what this is so let's just pass it through and hope for the best

        if ( $news && $news->connected)  {
            $self->echo_response_($news, $client, $command );
            next;
        } else {
            $self->tee_(  $client, "500 unknown command or bad syntax$eol" );
            last;
        }
    }

    close $news if defined( $news );
    close $client;
    print $pipe "CMPLT$eol";
    flush $pipe;
    $self->yield_( $ppipe, $pid );
    close $pipe;

    $self->log_( "NNTP forked child done" );
}

# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $session_key     The current session key
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $language, $session_key ) = @_;

    my $body;

    if ( $name eq 'nntp_port' ) {
        $body .= "<form action=\"/configuration\">\n";
        $body .= "<label class=\"configurationLabel\" for=\"configPopPort\">$$language{Configuration_NNTPPort}:</label><br />\n";
        $body .= "<input name=\"nntp_port\" type=\"text\" id=\"configPopPort\" value=\"" . $self->config_( 'port' ) . "\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"update_nntp_port\" value=\"$$language{Apply}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
    }

    # Separator Character widget
    if ( $name eq 'nntp_separator' ) {
        $body .= "\n<form action=\"/configuration\">\n";
        $body .= "<label class=\"configurationLabel\" for=\"configSeparator\">$$language{Configuration_NNTPSeparator}:</label><br />\n";
        $body .= "<input name=\"nntp_separator\" id=\"configSeparator\" type=\"text\" value=\"" . $self->config_( 'separator' ) . "\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"update_nntp_separator\" value=\"$$language{Apply}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
    }

    if ( $name eq 'nntp_local' ) {
        $body .= "<span class=\"securityLabel\">$$language{Security_NNTP}:</span><br />\n";

        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";
        if ( $self->config_( 'local' ) == 1 ) {
            $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{Security_NoStealthMode}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityAcceptPOP3On\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"nntp_local\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityAcceptPOP3Off\" name=\"toggle\" value=\"$$language{ChangeToNo} (Stealth Mode)\" />\n";
            $body .= "<input type=\"hidden\" name=\"nntp_local\" value=\"2\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        }
        $body .= "</td></tr></table>\n";
     }

    if ( $name eq 'nntp_force_fork' ) {
        $body .= "<span class=\"configurationLabel\">$$language{Configuration_NNTPFork}:</span><br />\n";
        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";

        if ( $self->config_( 'force_fork' ) == 0 ) {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{No}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowTrayIconOn\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"nntp_force_fork\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowTrayIconOff\" name=\"toggle\" value=\"$$language{ChangeToNo}\" />\n";
            $body .= "<input type=\"hidden\" name=\"nntp_force_fork\" value=\"0\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        }
        $body .= "</td></tr></table>\n";
    }

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $form            Hash containing all form items
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $language, $form ) = @_;

    if ( $name eq 'nntp_port' ) {
        if ( defined($$form{nntp_port}) ) {
            if ( ( $$form{nntp_port} >= 1 ) && ( $$form{nntp_port} < 65536 ) ) {
                $self->config_( 'port', $$form{nntp_port} );
                return '<blockquote>' . sprintf( $$language{Configuration_NNTPUpdate} . '</blockquote>' , $self->config_( 'port' ) );
             } else {
                 return "<blockquote><div class=\"error01\">$$language{Configuration_Error3}</div></blockquote>";
             }
        }
    }

    if ( $name eq 'nntp_separator' ) {
        if ( defined($$form{nntp_separator}) ) {
            if ( length($$form{nntp_separator}) == 1 ) {
                $self->config_( 'separator', $$form{separator} );
                return '<blockquote>' . sprintf( $$language{Configuration_NNTPSepUpdate} . '</blockquote>' , $self->config_( 'separator' ) );
            } else {
                return "<blockquote>\n<div class=\"error01\">\n$$language{Configuration_Error1}</div>\n</blockquote>\n";
            }
        }
    }

    if ( $name eq 'nntp_local' ) {
        $self->config_( 'local', $$form{nntp_local}-1 ) if ( defined($$form{nntp_local}) );
    }


    if ( $name eq 'nntp_force_fork' ) {
        if ( defined($$form{nntp_force_fork}) ) {
            $self->config_( 'force_fork', $$form{nntp_force_fork} );
        }
    }

    return '';
}

1;
