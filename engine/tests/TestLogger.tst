# ---------------------------------------------------------------------------------------------
#
# Tests for Logger.pm
#
# Copyright (c) 2003 John Graham-Cumming
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

# Check that control character transformation works

$l->debug( 0, "\rtest1\t\n" );

@last_ten = $l->last_ten();

test_assert_equal( $#last_ten, 0 );
test_assert_regexp( $last_ten[0], '\[0d\]test1\[09\]\[0a\]' );

$l->debug( 0,  'test2' );

@last_ten = $l->last_ten();

test_assert_equal( $#last_ten, 1 );
test_assert_regexp( $last_ten[0], '\[0d\]test1\[09\]\[0a\]' );
test_assert_regexp( $last_ten[1], 'test2' );

# test size limiting on last ten, note the test
# of log level here as well
$l->config_( 'level', 1 );
$l->debug( 0,  'test3' );
$l->debug( 0,  'test4' );
$l->debug( 0,  'test5' );
$l->debug( 0,  'test6' );
$l->debug( 1,  'test7' );
$l->debug( 2,  'fail'  );
$l->debug( 0,  'test8' );
$l->debug( 0,  'test9' );
$l->debug( 0,  'test10' );
$l->debug( 0,  'test11' );

@last_ten = $l->last_ten();

test_assert_equal( $#last_ten, 9 );
test_assert_regexp( $last_ten[0], 'test2' );
test_assert_regexp( $last_ten[1], 'test3' );
test_assert_regexp( $last_ten[2], 'test4' );
test_assert_regexp( $last_ten[3], 'test5' );
test_assert_regexp( $last_ten[4], 'test6' );
test_assert_regexp( $last_ten[5], 'test7' );
test_assert_regexp( $last_ten[6], 'test8' );
test_assert_regexp( $last_ten[7], 'test9' );
test_assert_regexp( $last_ten[8], 'test10' );
test_assert_regexp( $last_ten[9], 'test11' );

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
$l->{last_tickd__} -= 86400;
$l->service();

test_assert( defined( $mq->{queue__}{TICKD}[0] ), "checking TICKD message" );

# Move the date ahead three days and check that the debug
# file gets deleted, this relies on the GNU date program

if ( getlogin() eq 'root' ) {
    my $file = $l->debug_filename();
    `date --set='2 days'`;
    $l->service();
    $mq->service();
    my $exists = ( -e $file );
    test_assert( $exists, "checking that debug file was deleted" );
    `date --set='1 day'`;
    $l->service();
    $mq->service();
    $exists = ( -e $file );
    test_assert( !$exists, "checking that debug file was deleted" );
    `date --set='3 days ago'`;
} else {
    print "Warning: skipping clean up tests because you are not root\n";
}

1;
