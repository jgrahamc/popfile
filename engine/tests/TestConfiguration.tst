# ---------------------------------------------------------------------------------------------
#
# Tests for Configuration.pm
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

unlink 'popfile.cfg';

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
test_assert_equal( $c->global_config_( 'msgdir' ), 'messages/' );


# Check that the PID file gets created and then deleted and
# contains the correct process ID

$c->config_( 'piddir', '../tests/' );
test_assert_equal( $c->start(), 1 );
test_assert( $c->check_pid_() );
test_assert_equal( $c->get_pid_(), $$ );
open (STDERR, ">stdout.tmp");
test_assert_equal( $c->start(), 1 );
$c->stop();
test_assert( !$c->check_pid_() );

# disable logging

$c->global_config_( 'debug', 0 );

# Check instance coordination via PID file

$c->start();
$c->{pid_delay__} = 1;

my $process = fork;

if ($process != 0) {
    #parent loop
    test_assert_equal(  $c->start(), 0);
    test_assert( !defined( $c->live_check_() ) );
} elsif ($process == 0) {
    #child loop
    select(undef, undef, undef, $c->{pid_delay__});
    $c->service();
    exit(0);
}

   select(undef, undef, undef, 4 * $c->{pid_delay__});

if ($process != 0) {
    #parent loop
    select(undef, undef, undef, $c->{pid_delay__});
    $c->service();
} elsif ($process == 0) {
    #child loop
    test_assert_equal(  $c->start(), 0);
    test_assert( !defined( $c->live_check_() ) );

    exit(0);
}

close STDERR;
$c->stop();

# Check that the popfile.cfg was written

open FILE, "<popfile.cfg";
my $line = <FILE>;
test_assert_regexp( $line, 'config_piddir ../tests/' );
$line = <FILE>;
test_assert_regexp( $line, 'GLOBAL_debug 0' );
$line = <FILE>;
test_assert_regexp( $line, 'GLOBAL_download_count 0' );
$line = <FILE>;
test_assert_regexp( $line, 'GLOBAL_message_cutoff 100000' );
$line = <FILE>;
test_assert_regexp( $line, 'GLOBAL_msgdir messages/' );
$line = <FILE>;
test_assert_regexp( $line, 'GLOBAL_timeout 60' );
$line = <FILE>;
test_assert_regexp( $line, 'logger_format default' );
$line = <FILE>;
test_assert_regexp( $line, 'logger_logdir ./' );
$line = <FILE>;
test_assert_regexp( $line, 'testparam testvalue' );
$line = <FILE>;
close FILE;

# Now add a parameter and reload the configuration
# testparam2 gets defined so is kept, testparam3
# is not defined and is discarded on load

open FILE, ">>popfile.cfg";
print FILE "testparam2 testvalue2\n";
print FILE "testparam3 testvalue3\n";
close FILE;

$c->parameter( 'testparam2', 'wrong' );
$c->load_configuration();
test_assert_equal( $c->parameter( 'testparam2' ), 'testvalue2' );
test_assert_equal( $c->parameter( 'testparam3' ), '' );

# Check that parameter upgrading works

my %upgrades = (     'corpus',                   'bayes_corpus',
		     'unclassified_probability', 'bayes_unclassified_probability',
		     'piddir',                   'config_piddir',
		     'debug',                    'GLOBAL_debug',
		     'msgdir',                   'GLOBAL_msgdir',
		     'timeout',                  'GLOBAL_timeout',
		     'download_count',           'GLOBAL_download_count',
		     'logdir',                   'logger_logdir',
		     'localpop',                 'pop3_local',
		     'port',                     'pop3_port',
		     'sport',                    'pop3_secure_port',
		     'server',                   'pop3_secure_server',
		     'separator',                'pop3_separator',
		     'toptoo',                   'pop3_toptoo',
		     'archive',                  'html_archive',
		     'archive_classes',          'html_archive_classes',
		     'archive_dir',              'html_archive_dir',
		     'history_days',             'html_history_days',
		     'language',                 'html_language',
		     'last_reset',               'html_last_reset',
		     'last_update_check',        'html_last_update_check',
		     'localui',                  'html_local',
		     'page_size',                'html_page_size',
		     'password',                 'html_password',
		     'send_stats',               'html_send_stats',
		     'skin',                     'html_skin',
		     'test_language',            'html_test_language',
		     'update_check',             'html_update_check',
                     'ui_port',                  'html_port' );

foreach my $param (sort keys %upgrades) {
    test_assert_equal( $upgrades{$param}, $c->upgrade_parameter__( $param ) );
}

test_assert_equal( 'random', $c->upgrade_parameter__( 'random' ) );

# Check command line parsing
@ARGV = ( '--set', '-config_piddir=test2/' );
test_assert( $c->parse_command_line() );
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test2/' );
@ARGV = ( '--set', 'config_piddir=test3/' );
test_assert( $c->parse_command_line() );
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test3/' );
@ARGV = ( '--', '-config_piddir' );
open (STDERR, ">stdout.tmp");
test_assert( !$c->parse_command_line() );
close STDERR;
open OUTPUT, "<stdout.tmp";
<OUTPUT>;
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Missing argument for -config_piddir' );
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test3/' );
@ARGV = ( '--', '-config_foobar' );
open (STDERR, ">stdout.tmp");
test_assert( !$c->parse_command_line() );
close STDERR;
open OUTPUT, "<stdout.tmp";
<OUTPUT>;
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Unknown option -config_foobar' );
@ARGV = ( '--', '-config_piddir', 'test4/' );
test_assert( $c->parse_command_line() );
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test4/' );
@ARGV = ( '--doesnotexist', '-config_piddir', 'test4/' );
open (STDERR, ">stdout.tmp");
test_assert( !$c->parse_command_line() );
close STDERR;
open OUTPUT, "<stdout.tmp";
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Unknown option: doesnotexist' );
@ARGV = ( '--set', 'baz' );
open (STDERR, ">stdout.tmp");
test_assert( !$c->parse_command_line() );
close STDERR;
open OUTPUT, "<stdout.tmp";
<OUTPUT>;
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Bad option: baz' );
@ARGV = ( '--', 'baz' );
open (STDERR, ">stdout.tmp");
test_assert( !$c->parse_command_line() );
close STDERR;
open OUTPUT, "<stdout.tmp";
<OUTPUT>;
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Expected a command line option and got baz' );

# path_join__

test_assert_equal( $c->path_join__( 'foo', '/root' ), '/root' );
test_assert_equal( $c->path_join__( 'foo', '/' ), '/' );
test_assert_equal( $c->path_join__( 'foo', 'c:\\root' ), 'c:\\root' );
test_assert_equal( $c->path_join__( 'foo', 'c:\\' ), 'c:\\' );
test_assert_equal( $c->path_join__( '/foo', 'bar' ), '/foo/bar' );
test_assert_equal( $c->path_join__( '/foo/', 'bar' ), '/foo/bar' );
test_assert_equal( $c->path_join__( 'foo/', 'bar' ), 'foo/bar' );
test_assert_equal( $c->path_join__( 'foo', 'bar' ), 'foo/bar' );
test_assert_equal( $c->path_join__( 'foo', '\\\\bar' ), '\\\\bar' );

# get_user_path (note Makefile sets POPFILE_USER to ../tests/)

test_assert_equal( $c->get_user_path( 'foo' ), '../tests/foo' );
test_assert_equal( $c->get_user_path( '/foo' ), '/foo' );
test_assert_equal( $c->get_user_path( 'foo/' ), '../tests/foo/' );
$c->{popfile_user__} = './';
test_assert_equal( $c->get_user_path( 'foo' ), './foo' );
test_assert_equal( $c->get_user_path( '/foo' ), '/foo' );
test_assert_equal( $c->get_user_path( 'foo/' ), './foo/' );
$c->{popfile_user__} = '.';
test_assert_equal( $c->get_user_path( 'foo' ), './foo' );
test_assert_equal( $c->get_user_path( '/foo' ), '/foo' );
test_assert_equal( $c->get_user_path( 'foo/' ), './foo/' );
$c->{popfile_user__} = '../tests/';

# get_root_path (note Makefile sets POPFILE_ROOT to ../)

test_assert_equal( $c->get_root_path( 'foo' ), '../foo' );
test_assert_equal( $c->get_root_path( '/foo' ), '/foo' );
test_assert_equal( $c->get_root_path( 'foo/' ), '../foo/' );
$c->{popfile_root__} = './';
test_assert_equal( $c->get_root_path( 'foo' ), './foo' );
test_assert_equal( $c->get_root_path( '/foo' ), '/foo' );
test_assert_equal( $c->get_root_path( 'foo/' ), './foo/' );
$c->{popfile_root__} = '.';
test_assert_equal( $c->get_root_path( 'foo' ), './foo' );
test_assert_equal( $c->get_root_path( '/foo' ), '/foo' );
test_assert_equal( $c->get_root_path( 'foo/' ), './foo/' );
$c->{popfile_root__} = '../';

1;
