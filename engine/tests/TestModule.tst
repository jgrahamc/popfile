# ---------------------------------------------------------------------------------------------
#
# Tests for Module.pm
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

# Call the null methods
$m->prefork();
$m->stop();
$m->reaper();
$m->forked();
$m->deliver();

# Check that the MQ interface functions work

my $mq = new POPFile::MQ;
$m->mq( $mq );

$m->mq_register_( 'NOTYPE', $m );
$m->mq_post_( 'DUMMY', 'msg', 'param' );

test_assert_equal( $mq->{waiters__}{NOTYPE}[0], $m );
test_assert_equal( $mq->{queue__}{DUMMY}[0][0], 'msg' );
test_assert_equal( $mq->{queue__}{DUMMY}[0][1], 'param' );

# Check that register UI item sends the right message
use Test::MQReceiver;
my $r = new Test::MQReceiver;
$m->mq_register_( 'UIREG', $r );
$m->register_configuration_item_( 'type', 'name', $c );
$mq->service();
my @messages = $r->read();
test_assert_equal( $#messages, 0 );
test_assert_equal( $messages[0][0], 'UIREG' );
test_assert_equal( $messages[0][1], 'type:name' );
test_assert_equal( $messages[0][2], $c );

# Check that the logger function works

my $l = new POPFile::Logger;
$m->logger( $l );
$l->configuration( $c );
$l->initialize();
$l->calculate_today__();
$m->global_config_( 'debug', 1 );

$m->log_( 'logmsg' );

test_assert( $l->{last_ten__}[0] =~ /logmsg/ );
test_assert_equal( $l->last_ten(), $m->last_ten_log_entries() );

# Check all the setter/getter functions

test_assert_equal( $m->mq(), $mq );
test_assert_equal( $m->configuration(), $c );
$m->forker( 'forker' );
test_assert_equal( $m->forker(), 'forker' );
test_assert_equal( $m->logger(), $l );
$m->pipeready( 'pr' );
test_assert_equal( $m->pipeready(), 'pr' );
test_assert_equal( $m->alive(), 1 );
$m->alive(0);
test_assert_equal( $m->alive(), 0 );
$m->name( 'newname' );
test_assert_equal( $m->name(), 'newname' );
$m->version( 'vt.t.t' );
test_assert_equal( $m->version(), 'vt.t.t' );
