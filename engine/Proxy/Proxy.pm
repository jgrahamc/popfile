package Proxy::Proxy;

# ---------------------------------------------------------------------------------------------
#
# This module implements the base class for all POPFile proxy Modules
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

use POPFile::Module;
@ISA = ( "POPFile::Module" );

use IO::Handle;
use IO::Socket;
use IO::Select;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

#----------------------------------------------------------------------------
# new
#
#   Class new() function, all real work gets done by initialize and
#   the things set up here are more for documentation purposes than
#   anything so that you know that they exists
#
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = POPFile::Module->new();

    # A reference to the classifier and history

    $self->{classifier__}     = 0;
    $self->{history__}        = 0;

    # Reference to a child() method called to handle a proxy
    # connection

    $self->{child_}            = 0;

    # Holding variable for MSWin32 pipe handling

    $self->{pipe_cache__} = {};

    # This is where we keep the session with the Classifier::Bayes
    # module

    $self->{api_session__} = '';

    # This is the error message returned if the connection at any
    # time times out while handling a command
    #
    # $self->{connection_timeout_error_} = '';

    # This is the error returned (with the host and port appended)
    # if contacting the remote server fails
    #
    # $self->{connection_failed_error_}  = '';

    # This is a regular expression used by get_response_ to determine
    # if a response from the remote server is good or not (good being
    # that the last command succeeded)
    #
    # $self->{good_response_}            = '';

    # Connect Banner returned by the real server
    $self->{connect_banner__} = '';

    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the Proxy, most of this is handled by a subclass of this
# but here we set the 'enabled' flag
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    $self->config_( 'enabled', 1 );

    # The following parameters are for SOCKS proxy handling on outbound
    # connections

    $self->config_( 'socks_server', '' );
    $self->config_( 'socks_port',   1080 );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called when all configuration information has been loaded from disk.
#
# The method should return 1 to indicate that it started correctly, if it returns
# 0 then POPFile will abort loading immediately
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # Open the socket used to receive request for proxy service

    $self->{server__} = IO::Socket::INET->new( Proto     => 'tcp', # PROFILE BLOCK START
                                    ($self->config_( 'local' ) || 0) == 1 ? (LocalAddr => 'localhost') : (),
                                    LocalPort => $self->config_( 'port' ),
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 ); # PROFILE BLOCK STOP

    if ( !defined( $self->{server__} ) ) {
        my $port = $self->config_( 'port' );
        my $name = $self->name();
        print STDERR <<EOM; # PROFILE BLOCK START

\nCouldn't start the $name proxy because POPFile could not bind to the
listen port $port. This could be because there is another service
using that port or because you do not have the right privileges on
your system (On Unix systems this can happen if you are not root
and the port you specified is less than 1024).

EOM
# PROFILE BLOCK STOP
        return 0;
    }

    # This is used to perform select calls on the $server socket so that we can decide when there is
    # a call waiting an accept it without having to block

    $self->{selector__} = new IO::Select( $self->{server__} );

    # Tell the UI about the SOCKS parameters

    $self->register_configuration_item_( 'configuration',  # PROFILE BLOCK START
                                         $self->name() . '-socks-configuration',
                                         'socks-widget.thtml',
                                         $self );          # PROFILE BLOCK STOP

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called when POPFile is closing down, this is the last method that will get called before
# the object is destroyed.  There is not return value from stop().
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    if ( $self->{api_session__} ne '' ) {
        $self->{classifier__}->release_session_key( $self->{api_session__} );
    }

    # Need to close all the duplicated file handles, this include the POP3 listener
    # and all the reading ends of pipes to active children

    close $self->{server__} if ( defined( $self->{server__} ) );
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# service() is a called periodically to give the module a chance to do housekeeping work.
#
# If any problem occurs that requires POPFile to shutdown service() should return 0 and
# the top level process will gracefully terminate POPFile including calling all stop()
# methods.  In normal operation return 1.
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    # Accept a connection from a client trying to use us as the mail server.  We service one client at a time
    # and all others get queued up to be dealt with later.  We check the alive boolean here to make sure we
    # are still allowed to operate. See if there's a connection waiting on the $server by getting the list of
    # handles with data to read, if the handle is the server then we're off.

    if ( ( defined( $self->{selector__}->can_read(0) ) ) && ( $self->{alive_} ) ) {
        if ( my $client = $self->{server__}->accept() ) {

            # Check to see if we have obtained a session key yet

            if ( $self->{api_session__} eq '' ) {
                $self->{api_session__} = $self->{classifier__}->get_session_key( 'admin', '' );
	    }

            # Check that this is a connection from the local machine, if it's not then we drop it immediately
            # without any further processing.  We don't want to act as a proxy for just anyone's email

            my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

            if  ( ( ( $self->config_( 'local' ) || 0 ) == 0 ) || ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {

                # If we have force_fork turned on then we will do a fork, otherwise we will handle this
                # inline, in the inline case we need to create the two ends of a pipe that will be used
                # as if there was a child process

                binmode( $client );

                if ( $self->config_( 'force_fork' ) ) {
                    my ( $pid, $pipe ) = &{$self->{forker_}};

                    # If we fail to fork, or are in the child process then process this request

                    if ( !defined( $pid ) || ( $pid == 0 ) ) {
                        $self->{child_}( $self, $client, $self->{api_session__} );
# TODO                        $self->{flush_child_data_}( $self, $pipe );
                        exit(0) if ( defined( $pid ) );
                    }
	        } else {
                    pipe my $reader, my $writer;

                    $self->{child_}( $self, $client, $self->{api_session__} );
# TODO                    $self->{flush_child_data_}( $self, $reader );
                    close $reader;
                }
            }

            close $client;
        }
    }

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# This is called when some module forks POPFile and is within the context of the child
# process so that this module can close any duplicated file handles that are not needed.
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;

    close $self->{server__};
}

# ---------------------------------------------------------------------------------------------
#
# tee_
#
# $socket   The stream (created with IO::) to send the string to
# $text     The text to output
#
# Sends $text to $socket and sends $text to debug output
#
# ---------------------------------------------------------------------------------------------
sub tee_
{
    my ( $self, $socket, $text ) = @_;

    # Send the message to the debug output and then send it to the appropriate socket
    $self->log_( 1, $text );
    print $socket $text; # don't print if $socket undef
}

# ---------------------------------------------------------------------------------------------
#
# echo_to_regexp_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $regexp   The pattern match to terminate echoing, compile using qr/pattern/
# $log      (OPTIONAL) log output if 1, defaults to 0 if unset
# $suppress (OPTIONAL) suppress any lines that match, compile using qr/pattern/
#
# echo all information from the $mail server until a single line matching $regexp is seen
#
# ---------------------------------------------------------------------------------------------
sub echo_to_regexp_
{
    my ( $self, $mail, $client, $regexp, $log, $suppress ) = @_;

    $log = 0 if (!defined($log));

    while ( my $line = $self->slurp_( $mail ) ) {
        if (!defined($suppress) || !( $line =~ $suppress )) {
            if ( !$log ) {
                print $client $line;
            } else {
                $self->tee_( $client, $line );
            }
        } else {
            $self->log_( 2, "Suppressed: $line" );
        }

	if ( $line =~ $regexp ) {
            last;
	}
    }
}

# ---------------------------------------------------------------------------------------------
#
# echo_to_dot_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
#
# echo all information from the $mail server until a single line with a . is seen
#
# ---------------------------------------------------------------------------------------------
sub echo_to_dot_
{
    my ( $self, $mail, $client ) = @_;

    # The termination has to be a single line with exactly a dot on it and nothing
    # else other than line termination characters.  This is vital so that we do
    # not mistake a line beginning with . as the end of the block

    $self->echo_to_regexp_( $mail, $client, qr/^\.(\r\n|\r|\n)$/);
}

# ---------------------------------------------------------------------------------------------
#
# get_response_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $command  The text of the command to send (we add an EOL)
# $null_resp Allow a null response
# $suppress If set to 1 then the response does not go to the client
#
# Send $command to $mail, receives the response and echoes it to the $client and the debug
# output.  Returns the response and a failure code indicating false if there was a timeout
#
# ---------------------------------------------------------------------------------------------
sub get_response_
{
    my ( $self, $mail, $client, $command, $null_resp, $suppress ) = @_;

    $null_resp = 0 if (!defined $null_resp);
    $suppress  = 0 if (!defined $suppress);

    unless ( defined($mail) && $mail->connected ) {
       # $mail is undefined - return an error intead of crashing
       $self->tee_(  $client, "$self->{connection_timeout_error_}$eol" );
       return ( $self->{connection_timeout_error_}, 0 );
    }

    # Send the command (followed by the appropriate EOL) to the mail server
    $self->tee_( $mail, $command. $eol );

    my $response;

    # Retrieve a single string containing the response

    my $selector = new IO::Select( $mail );
    my ($ready) = $selector->can_read( (!$null_resp?$self->global_config_( 'timeout' ):.5) );

    if ( ( defined( $ready ) ) && ( $ready == $mail ) ) {
        $response = $self->slurp_( $mail );

        if ( $response ) {

            # Echo the response up to the mail client

            $self->tee_( $client, $response ) if ( !$suppress );
            return ( $response, 1 );
        }
    }

    if ( !$null_resp ) {
        # An error has occurred reading from the mail server

        $self->tee_(  $client, "$self->{connection_timeout_error_}$eol" );
        return ( $self->{connection_timeout_error_}, 0 );
    } else {
        $self->tee_($client, "");
        return ( "", 1 );
    }
}

# ---------------------------------------------------------------------------------------------
#
# echo_response_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $command  The text of the command to send (we add an EOL)
# $suppress If set to 1 then the response does not go to the client
#
# Send $command to $mail, receives the response and echoes it to the $client and the debug
# output.
#
# Returns one of three values
#
# 0 Successfully sent the command and got a positive response
# 1 Sent the command and got a negative response
# 2 Failed to send the command (e.g. a timeout occurred)
#
# ---------------------------------------------------------------------------------------------
sub echo_response_
{
    my ( $self, $mail, $client, $command, $suppress ) = @_;

    # Determine whether the response began with the string +OK.  If it did then return 1
    # else return 0

    my ( $response, $ok ) = $self->get_response_( $mail, $client, $command, 0, $suppress );

    if ( $ok == 1 ) {
        if ( $response =~ /$self->{good_response_}/ ) {
            return 0;
	} else {
            return 1;
        }
    } else {
        return 2;
    }
}

# ---------------------------------------------------------------------------------------------
#
# verify_connected_
#
# $mail        The handle of the real mail server
# $client      The handle to the mail client
# $hostname    The host name of the remote server
# $port        The port
# $ssl         If set to 1 then the connection to the remote is established using SSL
#
# Check that we are connected to $hostname on port $port putting the open handle in $mail.
# Any messages need to be sent to $client
#
# ---------------------------------------------------------------------------------------------
sub verify_connected_
{
    my ( $self, $mail, $client, $hostname, $port, $ssl ) = @_;

    $ssl = 0 if ( !defined( $ssl ) );

    # Check to see if we are already connected
    return $mail if ( $mail && $mail->connected );

    # Connect to the real mail server on the standard port, if we are using
    # SOCKS then go through the proxy server

    if ( $self->config_( 'socks_server' ) ne '' ) {
        require IO::Socket::Socks;
        $mail = IO::Socket::Socks->new( # PROFILE BLOCK START
                    ProxyAddr => $self->config_( 'socks_server' ),
                    ProxyPort => $self->config_( 'socks_port' ),
                    ConnectAddr  => $hostname,
                    ConnectPort  => $port ); # PROFILE BLOCK STOP
    } else {
        if ( $ssl ) {
            require IO::Socket::SSL;
            $mail = IO::Socket::SSL->new( # PROFILE BLOCK START
                        Proto    => "tcp",
                        PeerAddr => $hostname,
                        PeerPort => $port ); # PROFILE BLOCK STOP
	} else {
            $mail = IO::Socket::INET->new( # PROFILE BLOCK START
                        Proto    => "tcp",
                        PeerAddr => $hostname,
                        PeerPort => $port ); # PROFILE BLOCK STOP
        }
    }

    # Check that the connect succeeded for the remote server
    if ( $mail ) {
        if ( $mail->connected )  {

            $self->log_( 0, "Connected to $hostname:$port timeout " . $self->global_config_( 'timeout' ) );

            # Set binmode on the socket so that no translation of CRLF
            # occurs

            if ( !$ssl ) {
                binmode( $mail );
	    }

            # Wait 10 seconds for a response from the remote server and if
            # there isn't one then give up trying to connect

            my $selector = new IO::Select( $mail );
            last unless () = $selector->can_read($self->global_config_( 'timeout' ));

            # Read the response from the real server and say OK

            my $buf        = '';
            my $max_length = 8192;
            my $n          = sysread( $mail, $buf, $max_length, length $buf );

            if ( !( $buf =~ /[\r\n]/ ) ) {
                my $hit_newline = 0;
                my $temp_buf;

                # Read until timeout or a newline (newline _should_ be immediate)

                for my $i ( 0..($self->global_config_( 'timeout' ) * 100) ) {
                    if ( !$hit_newline ) {
                        $temp_buf = $self->flush_extra_( $mail, $client, 1 );
                        $hit_newline = ( $temp_buf =~ /[\r\n]/ );
                        $buf .= $temp_buf;
                    } else {
                        last;
                    }
                }
            }

            $self->log_( 1, "Connection returned: $buf" );

            $self->{connect_banner__} = $buf;

            # Clean up junk following a newline

            for my $i ( 0..4 ) {
                $self->flush_extra_( $mail, $client, 1 );
            }

            return $mail;
        }
    }

    # Tell the client we failed
    $self->tee_(  $client, "$self->{connection_failed_error_} $hostname:$port$eol" );

    return undef;
}

# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#
# ---------------------------------------------------------------------------------------------
sub configure_item
{
    my ( $self, $name, $templ ) = @_;

    $templ->param( 'Socks_Widget_Name' => $self->name() );
    $templ->param( 'Socks_Server'      => $self->config_( 'socks_server' ) );
    $templ->param( 'Socks_Port'        => $self->config_( 'socks_port'   ) );
}

# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        Reference to the hash holding the current language
#    $form            Hash containing all form items
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------
sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    my $me = $self->name();

    if ( defined($$form{"$me" . "_socks_port"}) ) {
        if ( ( $$form{"$me" . "_socks_port"} >= 1 ) && ( $$form{"$me" . "_socks_port"} < 65536 ) ) {
            $self->config_( 'socks_port', $$form{"$me" . "_socks_port"} );
            $templ->param( 'Socks_Widget_If_Port_Updated' => 1 );
            $templ->param( 'Socks_Widget_Port_Updated' => sprintf( $$language{Configuration_SOCKSPortUpdate}, $self->config_( 'socks_port' ) ) );
        } else {
            $templ->param( 'Socks_Widget_If_Port_Error' => 1 );
        }
    }

    if ( defined($$form{"$me" . "_socks_server"}) ) {
        $self->config_( 'socks_server', $$form{"$me" . "_socks_server"} );
        $templ->param( 'Socks_Widget_If_Server_Updated' => 1 );
        $templ->param( 'Socks_Widget_Server_Updated' => sprintf( $$language{Configuration_SOCKSServerUpdate}, $self->config_( 'socks_server' ) ) );
    }
}

# SETTERS

sub classifier
{
    my ( $self, $classifier ) = @_;

    $self->{classifier__} = $classifier;
}

sub history
{
    my ( $self, $history ) = @_;

    $self->{history__} = $history;
}

1;
