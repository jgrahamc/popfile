package Test::SimpleProxy;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# A simple test proxy server for testing Proxy::Proxy
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;

use IO::Handle;
use IO::Socket;
use IO::Select;

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

    $self->name( 'simple' );

    return $self;
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
                                    LocalPort => 10000,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 );

    $self->{remote_selector__} = new IO::Select( $self->{remote_server__} );
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

        while ( $self->{send__} =~ s/(.+)[\r\n]+// ) {
            print $handle "$1$eol";
	  }

        # If there's data available to read then read it into the received

        if ( defined( $self->{remote_client_selector__}->can_read(0) ) ) {
            $self->{received__} .= <$handle>;
            $self->{received__} .= $eol;
	}
    } else {
        if ( defined( $self->{remote_selector__}->can_read(0) ) ) {
            $self->{remote_client__} = $self->{remote_server__}->accept();
            $self->{remote_client_selector__} = new IO::Select( $self->{remote_client__} );
	}
    }
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
