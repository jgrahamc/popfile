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
$c->config_( 'piddir', '../tests/' );
test_assert_equal( $c->start(), 1 );
test_assert( ( -e 'popfile.pid' ) );
open PIDFILE, '<popfile.pid';
my $pid = <PIDFILE>;
close PIDFILE;
test_assert_equal( $pid, $$ );
open (STDERR, ">stdout.tmp");
test_assert_equal( $c->start(), 0 );
close STDERR;
$c->stop();
test_assert( !( -e 'popfile.pid' ) );

# Check that parameter upgrading works

my %upgrades = (     'corpus',                   'bayes_corpus',
		     'unclassified_probability', 'bayes_unclassified_probability',
		     'piddir',                   'config_piddir',
		     'debug',                    'GLOBAL_debug',
		     'msgdir',                   'GLOBAL_msgdir',
		     'subject',                  'GLOBAL_subject',
		     'timeout',                  'GLOBAL_timeout',
		     'xpl',                      'GLOBAL_xpl',
		     'xtc',                      'GLOBAL_xtc',
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
@ARGV = ( '-config_piddir', 'test2/' );
$c->parse_command_line();
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test2/' );
@ARGV = ( 'config_piddir', 'test3/' );
open (STDERR, ">stdout.tmp");
$c->parse_command_line();
close STDERR;
open OUTPUT, "<stdout.tmp";
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Expected a command line option and got config_piddir' );
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test2/' );
@ARGV = ( '-config_piddir' );
open (STDERR, ">stdout.tmp");
$c->parse_command_line();
close STDERR;
open OUTPUT, "<stdout.tmp";
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Missing argument for -config_piddir' );
test_assert_equal( $c->module_config_( 'config', 'piddir' ), 'test2/' );
@ARGV = ( '-config_foobar' );
open (STDERR, ">stdout.tmp");
$c->parse_command_line();
close STDERR;
open OUTPUT, "<stdout.tmp";
my $line = <OUTPUT>;
close OUTPUT;
test_assert_regexp( $line, 'Unknown command line option -config_foobar' );

