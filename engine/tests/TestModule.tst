# ---------------------------------------------------------------------------------------------
#
# Tests for Module.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use POPFile::Module;
use POPFile::MQ;
use POPFile::Configuration;
use POPFile::Logger;

my $m = new POPFile::Module;

# Check that base functions return good values

test_assert_equal( $m->initialize(), 1 );
test_assert_equal( $m->start(),      1 );
test_assert_equal( $m->service(),    1 );

# Set and get a name

$m->name( 'test' );
test_assert_equal( $m->name(), 'test' );

# Check that the configuration functions work

my $c = new POPFile::Configuration;
$m->configuration( $c );

$m->config_( 'parameter', 'value' );
test_assert_equal( $m->config_( 'parameter' ), 'value' );
$m->module_config_( 'module', 'mparameter', 'mvalue' );
test_assert_equal( $m->module_config_( 'module', 'mparameter' ), 'mvalue' );
$m->global_config_( 'gparameter', 'gvalue' );
test_assert_equal( $m->global_config_( 'gparameter' ), 'gvalue' );

# Check that the MQ interface functions work

my $mq = new POPFile::MQ;
$m->mq( $mq );

$m->mq_register_( 'NOTYPE', $m );
$m->mq_post_( 'DUMMY', 'msg', 'param' );

test_assert_equal( $mq->{waiters__}{NOTYPE}[0], $m );
test_assert_equal( $mq->{queue__}{DUMMY}[0][0], 'msg' );
test_assert_equal( $mq->{queue__}{DUMMY}[0][1], 'param' );

# Check that the logger function works

my $l = new POPFile::Logger;
$m->logger( $l );
$l->configuration( $c );
$l->calculate_today__();
$m->global_config_( 'debug', 1 );

$m->log_( 'logmsg' );

test_assert( $l->{last_ten__}[0] =~ /logmsg/ );
test_assert_equal( $l->last_ten(), $m->last_ten_log_entries() );
