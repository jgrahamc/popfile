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
test_assert( !$c->check_pid_() );
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

pipe(my $child_read, my $parent_write );
pipe(my $parent_read, my $child_write);

my $process = fork();

if ( $process == 0 ) {
    #child loop

    close $parent_write;
    close $parent_read;

    while (<$child_read>) {

#        print "\n[" . $_ . "]\n";

        if ($_ =~ /^start$/) {
            my $code = $c->start() . "\n";
            print $child_write $code;
            flush $child_write;
        }

        if ($_ =~ /^stop$/) {
            $c->stop();
            print $child_write "1\n";
        }

        if ($_ =~ /^check_pid_$/) {
            my $code = $c->live_check_();

            print $child_write (defined($code)?$code:"undef") . "\n"
        }

        if ($_ =~ /^0$/) {
            print $child_write "0\n";
        }

        if ($_ =~ /^1$/) {
            print $child_write "1\n";
        }

        flush $child_write;

        if ($_ =~ /^quit$/) {
            last;
        }
    }

    exit(0);
} else {
    #parent loop

    close $child_read;
    close $child_write;

    my $return;

    # quick test of this piping techinque

    print $parent_write "0\n";
    flush $parent_write;
    $return = <$parent_read>;

    test_assert_equal($return, "0\n");

    print $parent_write "1\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "1\n");

    # test child detection of parent PID

    print $parent_write "start\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "0\n");

    print $parent_write "check_pid_\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "$$\n");

    print $parent_write "stop\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "1\n");

    test_assert(!$c->check_pid_());

    # test parent detection of child PID

    print $parent_write "start\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "1\n");

    test_assert($c->check_pid_());

    test_assert_equal($c->get_pid_(), $process);
    test_assert_equal($c->live_check_(), $process);

    print $parent_write "stop\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "1\n");

    # check deletion

    test_assert(!$c->check_pid_());

    test_assert_equal(defined($c->get_pid_()), defined(undef));
    test_assert_equal(defined($c->live_check_()), defined(undef));

    # test non-present child, eg, if child was forcibly killed
    # we would want a new process launched

    print $parent_write "start\n";
    flush $parent_write;

    $return = <$parent_read>;

    test_assert_equal($return, "1\n");

    print $parent_write "quit\n";
    flush $parent_write;

    while (kill(0, $process)) {
        wait;
    };

    test_assert( !defined( $c->live_check_() ) );

    $c->stop();

}


close STDERR;

test_assert(!$c->check_pid_());

$c->service();

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
<<<<<<< TestConfiguration.tst
$line = <FILE>;
=======
#$line = <FILE>;
#test_assert_regexp( $line, 'GLOBAL_subject 1' );
$line = <FILE>;
>>>>>>> 1.12
test_assert_regexp( $line, 'GLOBAL_timeout 60' );
#$line = <FILE>;
#test_assert_regexp( $line, 'GLOBAL_xpl 1' );
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

1;
