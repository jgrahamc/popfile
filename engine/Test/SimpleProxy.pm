package Test::SimpleProxy;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# A simple test proxy server for testing Proxy::Proxy
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
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;

use IO::Handle;
use IO::Socket;
use IO::Select;

# A handy variable containing the value of an EOL for networks
my $eol = "\n";

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

    $self->{child_} = \&child__;
    $self->name( 'simple' );

    $self->{send__} = '';
    $self->{received__} = '';

    $self->{server_port__} = 10000 + int(rand(2000));

    return $self;
}

#----------------------------------------------------------------------------
# stop_server
#
#   Stops the phony server
#----------------------------------------------------------------------------
sub stop_server
{
    my ( $self ) = @_;

    if ( defined( $self->{remote_server__} ) ) {
        close $self->{remote_server__};
        close $self->{remote_client__} if ( defined( $self->{remote_client__} ) );
        undef $self->{remote_server__};
        undef $self->{remote_selector__};
    }
}

#----------------------------------------------------------------------------
# start_server
#
#   Starts a phony remote server for the proxy to connect to
#----------------------------------------------------------------------------
sub start_server
{
    my ( $self ) = @_;

    # This socket will act as the server that the proxy is connecting to,
    # SimpleProxy is used to connect to this server and proxy to and from
    # it.  The data sent to this socket is appended to {received__} and the
    # data to be made available is appended to {send__}

    $self->{remote_server__} = IO::Socket::INET->new( Proto     => 'tcp',
                                    LocalAddr => 'localhost',
                                    LocalPort => $self->{server_port__},
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 );

    $self->{remote_selector__} = new IO::Select( $self->{remote_server__} );

    return defined( $self->{remote_server__} ) && defined( $self->{remote_selector__} );
}

#----------------------------------------------------------------------------
# service_server
#
#   Called regularly to service connections to the phony server
#----------------------------------------------------------------------------
sub service_server
{
    my ( $self ) = @_;

    # If we have already accepted a connection then service it, otherwise
    # check for connections

    if ( defined( $self->{remote_client__} ) ) {
        my $handle = $self->{remote_client__};

        # If there's data in the send pipe then write it out line by line

        while ( $self->{send__} =~ s/^([^\r\n]+)[\r\n]+// ) {
            $self->tee_( $handle, "$1$eol" );
            select( undef, undef, undef, 0.15 );
        }

        # If there's data available to read then read it into the received

        if ( defined( $self->{remote_client_selector__}->can_read(0) ) ) {
            my $line = <$handle>;
            if ( defined( $line ) ) {
                $self->{received__} .= $line;
            }
        }
    } else {
        $self->log_( "service_server: remote client is not connected" );

        if ( defined( $self->{remote_selector__}->can_read(0) ) ) {
            $self->{remote_client__} = $self->{remote_server__}->accept();
            $self->{remote_client_selector__} = new IO::Select( $self->{remote_client__} );
            my $handle = $self->{remote_client__};
            if ( defined( $handle ) ) {
                $self->tee_( $handle, "Welcome" );
                $self->tee_( $handle, "To The Jungle$eol" );

            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client all this
# does is proxy without ANY change between client and server
#
# $client   - an open stream to a client
# $download_count - The unique download count for this session
#
# ---------------------------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $download_count, $pipe ) = @_;

    $self->log_( "Child started" );

    # Used to test that we get pipe messages

    print $pipe "CLASS:classification$eol";
    print $pipe "NEWFL:newfile$eol";
    print $pipe "LOGIN:username$eol";

    # Connect to the simple server that

    my $remote = $self->verify_connected_( 0, $client, 'localhost', $self->{server_port__} );

    # Create two selectors so that we can see if the client or the remote
    # have something to send and can echo between the two

    my $remote_selector = new IO::Select( $remote );
    my $client_selector = new IO::Select( $client );

    while ( defined($client) && $client->connected ) {
        if ( defined( $remote_selector->can_read(0) ) ) {
            my $line = <$remote>;
            if ( defined( $line ) ) {
                last if ( $line =~ /__POPFILE__ABORT__CHILD__/ );
                print $client $line;
            } else {
                last;
            }
        }
        if ( defined( $client_selector->can_read(0) ) ) {
            my $line = <$client>;
            last if ( $line =~ /__POPFILE__ABORT__CHILD__/ );
            print $remote $line;
        }
    }

    close $remote if ( defined( $remote ) );
    close $pipe;

    $self->log_( "Child stopped" );
}

# Getter/setter

sub received
{
    my ( $self ) = @_;
    my $received = $self->{received__};

    $self->{received__} = '';

    return $received;
}

sub send
{
    my ( $self, $line ) = @_;

    $self->{send__} .= $line;
    $self->{send__} .= $eol;
}
