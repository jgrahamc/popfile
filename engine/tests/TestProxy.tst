# ---------------------------------------------------------------------------------------------
#
# Tests for Proxy.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::Proxy;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $p = new Proxy::Proxy

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );

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

$sp->initialize();
$sp->config_( 'port', 9999 );
test_assert_equal( $sp->start(), 1 );
$sp->start_server();
