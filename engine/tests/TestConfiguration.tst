# ---------------------------------------------------------------------------------------------
#
# Tests for Configuration.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;

$c->configuration( $c );

# Check that we can get and set a parameter
$c->parameter( 'testparam', 'testvalue' );
test_assert_equal( $c->parameter( 'testparam' ), 'testvalue' );

# Check that we can get the full hash of parameters
my @all = $c->configuration_parameters();
test_assert_equal( $#all, 0 );
test_assert_equal( $all[0], 'testparam' );

$c->mq( $mq );
$c->logger( $l );

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

# Basic tests
test_assert_equal( $c->name(), 'config' );

# Parameters
test_assert_equal( $c->initialize(), 1 );
test_assert_equal( $c->config_( 'piddir' ), './' );
test_assert_equal( $c->global_config_( 'download_count' ), 0 );
test_assert_equal( $c->global_config_( 'timeout' ), 60 );
test_assert_equal( $c->global_config_( 'xtc' ), 1 );
test_assert_equal( $c->global_config_( 'xpl' ), 1 );
test_assert_equal( $c->global_config_( 'subject' ), 1 );
test_assert_equal( $c->global_config_( 'msgdir' ), 'messages/' );

# Check that the PID file gets created and then deleted and
# contains the correct process ID
$c->config_( 'piddir', 'tests/' );
test_assert_equal( $c->start(), 1 );
test_assert( ( -e 'tests/popfile.pid' ) );
open PIDFILE, '<tests/popfile.pid';
my $pid = <PIDFILE>;
close PIDFILE;
test_assert_equal( $pid, $$ );
$c->stop();
test_assert( !( -e 'tests/popfile.pid' ) );


