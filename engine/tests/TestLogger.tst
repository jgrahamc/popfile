# ---------------------------------------------------------------------------------------------
#
# Tests for Logger.pm
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
$c->mq( $mq );
$c->logger( $l );

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

# Test basic setup, name of the module, debug file location
# logging option
test_assert_equal( $l->name(), 'logger' );
test_assert_equal( $l->config_('logdir'), './' );
test_assert_equal( $l->global_config_('debug'), 1 );

# Change the log locatioin
$l->config_( 'logdir', '../tests/' );
test_assert_equal( $l->config_('logdir'), '../tests/' );
$l->calculate_today__();
test_assert_regexp( $l->debug_filename(), '../tests/' );
unlink( $l->debug_filename() );

# Test that the last ten functionality works
my @last_ten = $l->last_ten();

test_assert_equal( $#last_ten, 0 );
test_assert_equal( $last_ten[0], 'log empty' );

$l->debug( 'test1' );

@last_ten = $l->last_ten();

test_assert_equal( $#last_ten, 0 );
test_assert_regexp( $last_ten[0], 'test1' );

$l->debug( 'test2' );

@last_ten = $l->last_ten();

test_assert_equal( $#last_ten, 1 );
test_assert_regexp( $last_ten[0], 'test1' );
test_assert_regexp( $last_ten[1], 'test2' );

# Check the time function is working to generate times to the nearest day
test_assert_equal( $l->{today__},  int( time / 86400 ) * 86400 );

# Read the debug file and check that it contains what we expect
open DEBUG, '<' . $l->debug_filename();
my $line = <DEBUG>;
test_assert_regexp( $line, 'test1' );
$line = <DEBUG>;
test_assert_regexp( $line, 'test2' );
close DEBUG;

# Check that we get a tick when a day passes
$l->{today__} -= 86400;
$l->service();

test_assert( defined( $mq->{queue__}{TICKD}[0][0] ), "checking TICKD message" );
test_assert( defined( $mq->{queue__}{TICKD}[0][1] ), "checking TICKD message" );

# Move the date ahead three days and check that the debug
# file gets deleted, this relies on the GNU date program
my $file = $l->debug_filename();
`date --set='2 days'`; 
$l->service();
my $exists = ( -e $file );
test_assert( $exists, "checking that debug file was deleted" );
`date --set='1 day'`; 
$l->service();
$exists = ( -e $file );
test_assert( !$exists, "checking that debug file was deleted" );
`date --set='3 days ago'`;

