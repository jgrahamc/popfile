# ---------------------------------------------------------------------------------------------
#
# Tests for Proxy.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

sub forker
{
    pipe my $reader, my $writer;
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ( $pid == 0 ) {
        close $reader;

        use IO::Handle;
        $writer->autoflush(1);

        return (0, $writer);
    }

    close $writer;
    return ($pid, $reader);
}

sub pipeready
{
    my ( $pipe ) = @_;

    if ( !defined( $pipe ) ) {
        return 0;
    }

    if ( $^O eq 'MSWin32' ) {
        return ( ( -s $pipe ) > 0 );
    } else {
        my $rin = '';
        vec( $rin, fileno( $pipe ), 1 ) = 1;
        my $ready = select( $rin, undef, undef, 0.01 );
        return ( $ready > 0 );
    }
}

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::Proxy;
use IO::Socket;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $p = new Proxy::Proxy

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );

$c->initialize();

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

$p->configuration( $c );
$p->mq( $mq );
$p->logger( $l );

# Start a generic proxy on port 9999
$p->config_( 'port', 9999 );
test_assert_equal( $p->start(), 1 );
$p->stop();

# Exercise the classifier setter
$p->classifier( 'foo' );
test_assert_equal( $p->{classifier__}, 'foo' );

# Test the helper methods of Proxy
use Test::SimpleProxy;
my $sp = new Test::SimpleProxy;

$sp->configuration( $c );
$sp->mq( $mq );
$sp->logger( $l );

$sp->forker( \&forker );
$sp->pipeready( \&pipeready );

$sp->initialize();
$sp->config_( 'port', 9999 );
test_assert_equal( $sp->start(), 1 );
test_assert( $sp->start_server() );

# Now connect a socket to the proxy through which
# we can test it
my $client = IO::Socket::INET->new(
                Proto    => "tcp",
                PeerAddr => 'localhost',
                PeerPort => 9999 );
$sp->service();

test_assert( defined( $client ) );
test_assert( $client->connected );

$sp->service();
select( undef, undef, undef, 0.25 );
$sp->service_server();
select( undef, undef, undef, 0.25 );

# Basic connectivity test tell the phony
# server to send a message and we'll receive
# it through the proxy, then send a message
# and check that the phony server gets it

$sp->send( "fromserver\n" );
$sp->service_server();
my $line = <$client>;
test_assert_regexp( $line, 'fromserver' );
print $client "toserver\n";
select( undef, undef, undef, 0.25 );
$sp->service_server();
test_assert_regexp( $sp->received(), 'toserver' );

# Close down the child process

close $client;
$sp->stop_server();
select( undef, undef, undef, 0.25 );
