# POPFILE LOADABLE MODULE 4
package Proxy::NNTP;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ----------------------------------------------------------------------------
#
# This module handles proxying the NNTP protocol for POPFile.
#
# Copyright (c) 2001-2009 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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

    $self->config_( 'enabled', 0 );

    # By default we don't fork on Windows

    $self->config_( 'force_fork', ($^O eq 'MSWin32')?0:1 );

    # Default ports for NNTP service and the user interface

    $self->config_( 'port', 119 );

    # Only accept connections from the local machine for NNTP

    $self->config_( 'local', 1 );

    # Whether to do classification on HEAD as well

    $self->config_( 'headtoo', 0 );

    # The separator within the NNTP user name is :

    $self->config_( 'separator', ':');

    # The welcome string from the proxy is configurable

    $self->config_( 'welcome_string',                      # PROFILE BLOCK START
        "NNTP POPFile ($self->{version_}) server ready" ); # PROFILE BLOCK STOP

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

    $self->register_configuration_item_( 'configuration',   # PROFILE BLOCK START
                                         'nntp_config',
                                         'nntp-configuration.thtml',
                                         $self );           # PROFILE BLOCK STOP
    
    $self->register_configuration_item_( 'security',        # PROFILE BLOCK START
                                         'nntp_local',
                                         'nntp-security-local.thtml',
                                         $self );           # PROFILE BLOCK STOP 

    if ( $self->config_( 'welcome_string' ) =~                # PROFILE BLOCK START
         /^NNTP POPFile \(v\d+\.\d+\.\d+\) server ready$/ ) { # PROFILE BLOCK STOP
        $self->config_( 'welcome_string',                                  # PROFILE BLOCK START
                        "NNTP POPFile ($self->{version_}) server ready" ); # PROFILE BLOCK STOP
    }

    return $self->SUPER::start();;
}

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
    my ( $self, $client, $admin_session ) = @_;

    # Hash of indexes of downloaded messages mapped to their
    # slot IDs

    my %downloaded;

    # The handle to the real news server gets stored here

    my $news;

    # Will hold the session key for the API, $token contains the
    # string for the AUTHINFO USER command that is used to get the key

    my $session = undef;
    my $token;

    # The state of the connection (username needed, password needed,
    # authenticated/connected)

    my $connection_state = 'username needed';

    # Tell the client that we are ready for commands and identify our
    # version number

    $self->tee_( $client, "201 " . $self->config_( 'welcome_string' ) .  # PROFILE BLOCK START
                          "$eol" );                                      # PROFILE BLOCK STOP

    # Retrieve commands from the client and process them until the
    # client disconnects or we get a specific QUIT command

    while  ( <$client> ) {
        my $command;
        my ( $response, $ok );

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
                last if ( $self->echo_response_( $news, $client, $command ) == # PROFILE BLOCK START
                         2 );                                                  # PROFILE BLOCK STOP
                close $news;
            } else {
                $self->tee_( $client, "205 goodbye$eol" );
            }
            last;
        }

        if ( $connection_state eq 'username needed' ) {

            # NOTE: This syntax is ambiguous if the NNTP username is a
            # short (under 5 digit) string (eg, 32123).  If this is
            # the case, run "perl popfile.pl -nntp_separator /" and
            # change your kludged username appropriately (syntax would
            # then be server[:port][/username])

            my $separator = $self->config_( 'separator' );
            my $user_command = "^ *AUTHINFO USER ([^:]+)(:([\\d]{1,5}))?(\Q$separator\E(.+))?";

            if ( $command =~ /$user_command/i ) {
                my $server = $1;

                # hey, the port has to be in range at least

                my $port = $3 if ( defined($3) && ($3 > 0) && ($3 < 65536) );
                my $username = $5;

                if ( $server ne '' )  {
                    if ( $news = $self->verify_connected_( $news, $client,    # PROFILE BLOCK START
                                                           $server,
                                                           $port || 119 ) ) { # PROFILE BLOCK STOP
                        if ( defined $username ) {

                            # Pass through the AUTHINFO command with
                            # the actual user name for this server, if
                            # one is defined, and send the reply
                            # straight to the client

                            $self->get_response_( $news, $client,  # PROFILE BLOCK START
                                                  'AUTHINFO USER ' .
                                                  $username );     # PROFILE BLOCK STOP
                            $connection_state = "password needed";
                            $token = "$server:$username";
                        } else {

                            # Signal to the client to send the password

                            $self->tee_($client, "381 password$eol");
                            $connection_state = "ignore password";
                            $token = "$server:";
                        }
                    } else {
                        last;
                    }
                } else {
                    $self->tee_( $client,                                                                       # PROFILE BLOCK START
                        "482 Authentication rejected server name not specified in AUTHINFO USER command$eol" ); # PROFILE BLOCK STOP
                    last;
                }

                $self->flush_extra_( $news, $client, 0 );
            } else {

                # Issue a 480 authentication required response

                $self->tee_( $client, "480 Authorization required for this command$eol" );
            }
            next;
        }

        if ( $connection_state eq "password needed" ) {
            if ( $command =~ /^ *AUTHINFO PASS (.*)/i ) {
                ( $response, $ok ) =                                  # PROFILE BLOCK START
                    $self->get_response_( $news, $client, $command ); # PROFILE BLOCK STOP

                if ( $response =~ /^281 .*/ ) {
                    $connection_state = "connected";
                    $session = $self->get_session_key_( $token );
                }
            } else {

                # Issue a 381 more authentication required response

                $self->tee_( $client, "381 more authentication required for this command$eol" );
            }
            next;
        }

        if ( $connection_state eq "ignore password" ) {
            if ( $command =~ /^ *AUTHINFO PASS (.*)/i ) {
                $self->tee_( $client, "281 authentication accepted$eol" );
                $connection_state = "connected";
                $session = $self->get_session_key_( $token );
            } else {

                # Issue a 480 authentication required response

                $self->tee_( $client, "381 more authentication required for this command$eol" );
            }
            next;
        }

        if ( $connection_state eq "connected" ) {
            my $message_id;

            # COMMANDS USED DIRECTLY WITH THE REMOTE NNTP SERVER GO HERE

            # The client wants to retrieve an article. We oblige, and
            # insert classification headers.

            if ( $command =~ /^ *ARTICLE ?(.*)?/i ) {
                my $file;

                if ( $1 =~ /^\d*$/ ) {
                    ( $message_id, $response ) =                            # PROFILE BLOCK START
                        $self->get_message_id_( $news, $client, $command ); # PROFILE BLOCK STOP
                    if ( !defined( $message_id ) ) {
                        $self->tee_( $client, $response );
                        next;
                    }
                } else {
                    $message_id = $1;
                }

                if ( defined($downloaded{$message_id}) &&  # PROFILE BLOCK START
                     ( $file = $self->history_()->get_slot_file(
                            $downloaded{$message_id}{slot} ) ) &&
                     ( open RETRFILE, "<$file" ) ) {       # PROFILE BLOCK STOP

                    # Act like a network stream

                    binmode RETRFILE;

                    # File has been fetched and classified already

                    $self->log_( 1, "Printing message from cache" );

                    # Give the client 220 (ok)

                    $self->tee_( $client, "220 0 $message_id$eol" );

                    # Echo file, inserting known classification,
                    # without saving

                    ( my $class, undef ) =                          # PROFILE BLOCK START
                        $self->classifier_()->classify_and_modify(
                            $session, \*RETRFILE, $client, 1,
                            $downloaded{$message_id}{class},
                            $downloaded{$message_id}{slot} );           # PROFILE BLOCK STOP
                    print $client ".$eol";

                    close RETRFILE;
                } else {

                    ( $response, $ok ) =                                  # PROFILE BLOCK START
                        $self->get_response_( $news, $client, $command ); # PROFILE BLOCK STOP
                    if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                        $message_id = $2;

                        my ( $class, $history_file ) =                  # PROFILE BLOCK START
                            $self->classifier_()->classify_and_modify(
                                $session, $news, $client, 0, '', 0 );   # PROFILE BLOCK STOP

                        $downloaded{$message_id}{slot}  = $history_file;
                        $downloaded{$message_id}{class} = $class;
                    }
                }

                next;
            }

            if ( $command =~ /^ *HEAD ?(.*)?/i ) {
                if ( $1 =~ /^\d*$/ ) {
                    ( $message_id, $response ) =                            # PROFILE BLOCK START
                        $self->get_message_id_( $news, $client, $command ); # PROFILE BLOCK STOP
                    if ( !defined( $message_id ) ) {
                        $self->tee_( $client, $response );
                        next;
                    }
                } else {
                    $message_id = $1;
                }

                if ( $self->config_( 'headtoo' ) ) {
                    my ( $class, $history_file );
                    my $cached = 0;

                    if ( defined($downloaded{$message_id}) ) {
                        # Already cached

                        $cached = 1;
                        $class = $downloaded{$message_id}{class};
                        $history_file = $downloaded{$message_id}{slot};
                    } else {

                        # Send ARTICLE command to server

                        my $article_command = $command;
                        $article_command =~ s/^ *HEAD/ARTICLE/i;
                        ( $response, $ok ) =                             # PROFILE BLOCK START
                            $self->get_response_( $news, $client,
                                                  $article_command, 0, 1 ); # PROFILE BLOCK STOP
                        if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                            $message_id = $2;
                            $response =~ s/^220/221/;
                            $self->tee_( $client, "$response" );

                            # Classify without sending to client

                            ( $class, $history_file ) =                     # PROFILE BLOCK START
                                $self->classifier_()->classify_and_modify(
                                    $session, $news, undef, 0, '', 0, 0 );  # PROFILE BLOCK STOP

                            $downloaded{$message_id}{slot}  = $history_file;
                            $downloaded{$message_id}{class} = $class;
                        } else {
                            $self->tee_( $client, "$response" );
                            next;
                        }
                    }

                    # Send header to client from server

                    ( $response, $ok ) =                                # PROFILE BLOCK START
                        $self->get_response_( $news, $client, $command,
                                              0, ( $cached ? 0 : 1 ) ); # PROFILE BLOCK STOP
                    if ( $response =~ /^221 +(\d+) +([^ ]+)/i ) {
                        $self->classifier_()->classify_and_modify(  # PROFILE BLOCK START
                            $session, $news, $client, 1, $class,
                            $history_file, 1 );                     # PROFILE BLOCK STOP
                    }
                    next;
                }
            }

            if ( $command =~ /^ *BODY ?(.*)?/i ) {
                my $file;

                if ( $1 =~ /^\d*$/ ) {
                    ( $message_id, $response ) =                            # PROFILE BLOCK START
                        $self->get_message_id_( $news, $client, $command ); # PROFILE BLOCK STOP
                    if ( !defined( $message_id ) ) {
                        $self->tee_( $client, $response );
                        next;
                    }
                } else {
                    $message_id = $1;
                }

                if ( defined($downloaded{$message_id}) &&  # PROFILE BLOCK START
                     ( $file = $self->history_()->get_slot_file(
                            $downloaded{$message_id}{slot} ) ) &&
                     ( open RETRFILE, "<$file" ) ) {       # PROFILE BLOCK STOP
                    
                    # Act like a network stream

                    binmode RETRFILE;

                    # File has been fetched and classified already

                    $self->log_( 1, "Printing message from cache" );

                    # Give the client 222 (ok)

                    $self->tee_( $client, "222 0 $message_id$eol" );

                    # Skip header

                    while ( my $line = $self->slurp_( \*RETRFILE ) ) {
                        last if ( $line =~ /^[\015\012]+$/ );
                    }

                    # Echo file to client

                    $self->echo_to_dot_( \*RETRFILE, $client );
                    print $client ".$eol";

                    close RETRFILE;
                } else {
                    # Send ARTICLE command to server

                    my $article_command = $command;
                    $article_command =~ s/^ *BODY/ARTICLE/i;
                    ( $response, $ok ) =                                        # PROFILE BLOCK START
                        $self->get_response_( $news, $client, $article_command,
                                              0, 1 );                           # PROFILE BLOCK STOP
                    if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                        $message_id = $2;
                        $response =~ s/^220/222/;
                        $self->tee_( $client, "$response" );

                        # Classify without sending to client

                        my ( $class, $history_file ) =                  # PROFILE BLOCK START
                            $self->classifier_()->classify_and_modify(
                                $session, $news, undef, 0, '', 0, 0 );  # PROFILE BLOCK STOP

                        $downloaded{$message_id}{slot}  = $history_file;
                        $downloaded{$message_id}{class} = $class;

                        # Send body to client from server

                        ( $response, $ok ) =                                # PROFILE BLOCK START
                            $self->get_response_( $news, $client, $command,
                                                  0, 1 );                   # PROFILE BLOCK STOP
                        if ( $response =~ /^222 +(\d+) +([^ ]+)/i ) {
                            $self->echo_to_dot_( $news, $client, 0 );
                        }
                    } else {
                        $self->tee_( $client, "$response" );
                    }
                }
                next;
            }

            # Commands expecting a code + text response

            if ( $command =~                                 # PROFILE BLOCK START
                /^[ ]*(LIST|HEAD|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|
                     XOVER|XPAT|XROVER|XTHREAD)/ix ) {       # PROFILE BLOCK STOP
                my ( $response, $ok ) = $self->get_response_( $news, $client, # PROFILE BLOCK START
                                                              $command);      # PROFILE BLOCK STOP

                # 2xx (200) series response indicates multi-line text
                # follows to .crlf

                if ( $response =~ /^2\d\d/ ) {
                    $self->echo_to_dot_( $news, $client, 0 );
                }
                next;
            }

            # Exceptions to 200 code above

            if ( $ command =~ /^ *(HELP)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client, # PROFILE BLOCK START
                                                              $command);      # PROFILE BLOCK STOP
                if ( $response =~ /^1\d\d/ ) {
                    $self->echo_to_dot_( $news, $client, 0 );
                }
                next;
            }

            # Commands expecting a single-line response

            if ( $command =~                                            # PROFILE BLOCK START
                /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i ) { # PROFILE BLOCK STOP
                $self->get_response_( $news, $client, $command );
                next;
            }

            # Commands followed by multi-line client response

            if ( $command =~ /^ *(IHAVE|POST|XRELPIC)/i ) {
                my ( $response, $ok ) = $self->get_response_( $news, $client, # PROFILE BLOCK START
                                                              $command);      # PROFILE BLOCK STOP

                # 3xx (300) series response indicates multi-line text
                # should be sent, up to .crlf

                if ( $response =~ /^3\d\d/ ) {

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

        if ( $news && $news->connected )  {
            $self->echo_response_( $news, $client, $command );
            next;
        } else {
            $self->tee_( $client, "500 unknown command or bad syntax$eol" );
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
# Returns 1 if nntp_local is 1
#
# ----------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    if ( $name eq 'nntp_config' ) {
        $templ->param( 'nntp_port'          => $self->config_( 'port' ) );
        $templ->param( 'nntp_separator'     => $self->config_( 'separator' ) );
        $templ->param( 'nntp_force_fork_on' => ( $self->config_( 'force_fork' ) == 1 ) );
    }
    
    if ( $name eq 'nntp_local' ) {
        $templ->param( 'nntp_if_local' => $self->config_( 'local' ) );
        return $self->config_( 'local' );
    }

    $self->SUPER::configure_item( $name, $templ, $language);
}

# ----------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by
#                     the call to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ----------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    my ( $status, $error );

    if ( $name eq 'nntp_config' ) {
        
        if ( defined $$form{nntp_port} ) {
            if ( $self->is_valid_port_( $$form{nntp_port} ) ) {
                if ( $self->config_( 'port' ) ne $$form{nntp_port} ) {
                    $self->config_( 'port', $$form{nntp_port} );
                    $status = sprintf(                         # PROFILE BLOCK START
                            $$language{Configuration_NNTPUpdate},
                            $self->config_( 'port' ) ) . "\n"; # PROFILE BLOCK STOP
                }
            } else {
                $error = $$language{Configuration_Error3} . "\n";
            }
        }

        if ( defined $$form{nntp_separator} ) {
            if ( length($$form{nntp_separator}) == 1 ) {
                if ( $self->config_( 'separator' ) ne $$form{nntp_separator} ) {
                    $self->config_( 'separator', $$form{nntp_separator} );
                    $status .= sprintf(                             # PROFILE BLOCK START
                            $$language{Configuration_NNTPSepUpdate},
                            $self->config_( 'separator' ) ) . "\n"; # PROFILE BLOCK STOP
                }
            } else {
                $error .= $$language{Configuration_Error1} . "\n";
            }
        }

        if ( defined $$form{nntp_force_fork} ) {
            if ( $$form{nntp_force_fork} ) {
                if ( $self->config_( 'force_fork' ) ne 1 ) {
                    $self->config_( 'force_fork', 1 );
                    $status .= $$language{Configuration_NNTPForkEnabled};
                }
            } else {
                if ( $self->config_( 'force_fork' ) ne 0 ) {
                    $self->config_( 'force_fork', 0 );
                    $status .= $$language{Configuration_NNTPForkDisabled};
                }
            }
        }
        
        return( $status, $error );
    }
    
    if ( $name eq 'nntp_local' ) {
        if ( $form->{serveropt_nntp} ) {
            if ( $self->config_( 'local' ) ne 0 ) {
                $self->config_( 'local', 0 );
                $status = $$language{Security_ServerModeUpdateNNTP};
            }
        } else {
            if ( $self->config_( 'local' ) ne 1 ) {
                $self->config_( 'local', 1 );
                $status = $$language{Security_StealthModeUpdateNNTP};
            }
        }
        return( $status, $error );
    }    

    return $self->SUPER::validate_item( $name, $templ, $language, $form );
}

# ----------------------------------------------------------------------------
#
# get_message_id_
#
# Get message_id of the article to retrieve
#
#    $news            A connection to the news server
#    $client          A connection from the news client
#    $command         A command sent from the news client
#
# ----------------------------------------------------------------------------

sub get_message_id_
{
    my ( $self, $news, $client, $command ) = @_;

    # Send STAT command to get the message_id

    $command =~ s/^ *(ARTICLE|HEAD|BODY)/STAT/i;
    my ( $response, $ok ) =                                     # PROFILE BLOCK START
        $self->get_response_( $news, $client, $command, 0, 1 ); # PROFILE BLOCK STOP
    if ( $response =~ /^223 +(\d+) +([^ \015]+)/i ) {
        return ( $2, $response );
    } else {
        return ( undef, $response );
    }
}

1;
