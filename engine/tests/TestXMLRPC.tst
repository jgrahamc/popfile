# ----------------------------------------------------------------------------
#
# Tests for XMLRPC.pm
#
# Copyright (c) 2001-2009 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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
#   Modified by Sam Schinke (sschinke@users.sourceforge.net)
#
# ----------------------------------------------------------------------------

use strict;
use warnings;

use POSIX ":sys_wait_h";

use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
$POPFile->{debug__} = 0;
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'POPFile/Database'      => 1,
              'POPFile/History'       => 1,
              'POPFile/Logger'        => 1,
              'POPFile/MQ'            => 1,
              'Classifier/Bayes'      => 1,
              'Classifier/WordMangle' => 1,
              'POPFile/Configuration' => 1,
              'UI/HTML'               => 1,
              'UI/XMLRPC'             => 1, );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );

my $db = $POPFile->get_module( 'POPFile::Database' );
my $b  = $POPFile->get_module( 'Classifier::Bayes' );
my $mq = $POPFile->get_module( 'POPFile::MQ'       );
my $h  = $POPFile->get_module( 'POPFile::History'  );
my $x  = $POPFile->get_module( 'UI::XMLRPC'        );
my $l  = $POPFile->get_module( 'POPFile::Logger'   );

$l->config_( 'level', 2 );

my $http_port = 18080;
$b->module_config_( 'html', 'port', $http_port );
$b->global_config_( 'language', 'English' );
$b->config_( 'hostname', '127.0.0.1' );

# To Test XMLRPC's use of MQ, we need to receive messages

use Test::MQReceiver;

my $rmq = new Test::MQReceiver;

$mq->register( 'UIREG', $rmq );

$x->config_( 'enabled', 1 );
test_assert( $x->config_( 'enabled' ), 1 );
my $xport = 12000 + int( rand( 2000 ) );
$x->config_( 'port', $xport );
$POPFile->CORE_start();

# Test dynamic UI

$mq->service();
my @messages = $rmq->read();

shift @messages if ( $^O eq 'MSWin32' );

test_assert_equal( scalar @messages, 2 );

test_assert_equal( $messages[0][0], 'UIREG' );
test_assert_equal( $#{$messages[0][1]}, 3 );
test_assert_equal( $messages[0][1][0], 'configuration' );
test_assert_equal( $messages[0][1][1], 'xmlrpc_port' );
test_assert_equal( $messages[0][1][2], 'xmlrpc-port.thtml' );
test_assert_equal( ref $messages[0][1][3], 'UI::XMLRPC' );

test_assert_equal( $messages[1][0], 'UIREG' );
test_assert_equal( $#{$messages[1][1]}, 3 );
test_assert_equal( $messages[1][1][0], 'security' );
test_assert_equal( $messages[1][1][1], 'xmlrpc_local' );
test_assert_equal( $messages[1][1][2], 'xmlrpc-local.thtml' );
test_assert_equal( ref $messages[1][1][3], 'UI::XMLRPC' );

# Test configure_item

use Test::SimpleTemplate;

my $templ = new Test::SimpleTemplate;

# nothing happens for unknown configuration item names

$x->configure_item( 'foo', $templ );
my $params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 0 );

# the right things have to happen for known configuration item names

$x->configure_item( 'xmlrpc_port', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 1 );
test_assert_equal( $templ->param( 'XMLRPC_Port' ), $x->config_( 'port' ) );

delete $templ->{params__};

$x->configure_item( 'xmlrpc_local', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 1 );
test_assert_equal( $templ->param( 'XMLRPC_local_on' ), ( $x->config_( 'local' ) == 1 ) );

delete $templ->{params__};

# test changing/validating of configuration values

my $form = {};
my $language= {};

my ($status, $error);

# xmlrpc_port

test_assert_equal( $x->config_( 'port' ), $xport );

$form->{xmlrpc_port} = 18081;
$language->{Configuration_XMLRPCUpdate} = "xmlrpc port update %s";

($status, $error) = $x->validate_item( 'xmlrpc_port', $templ, $language, $form );

test_assert_equal( $status, "xmlrpc port update 18081" );
test_assert( !defined( $error ) );
test_assert_equal( $x->config_( 'port' ), 18081 );

$form->{xmlrpc_port} = 'aaa';
$language->{Configuration_Error7} = "configuration error 7";

($status, $error) = $x->validate_item( 'xmlrpc_port', $templ, $language, $form );

test_assert( !defined( $status ) );
test_assert_equal( $error, "configuration error 7" );
test_assert_equal( $x->config_( 'port' ), 18081 );

$form->{xmlrpc_port} = 0;

($status, $error) = $x->validate_item( 'xmlrpc_port', $templ, $language, $form );

test_assert( !defined( $status ) );
test_assert_equal( $error, "configuration error 7" );
test_assert_equal( $x->config_( 'port' ), 18081 );

$x->config_( 'port', $xport );

delete $form->{xmlrpc_port};

# xmlrpc_local

test_assert_equal( $x->config_( 'local' ), 1 );

$form->{serveropt_xmlrpc} = 1;
$language->{Security_ServerModeUpdateXMLRPC} = "xmlrpc is in server mode";

($status, $error) = $x->validate_item( 'xmlrpc_local', $templ, $language, $form );

test_assert_equal( $status, "xmlrpc is in server mode" );
test_assert( !defined( $error ) );
test_assert_equal( $x->config_( 'local' ), 0 );

$form->{serveropt_xmlrpc} = 0;
$language->{Security_StealthModeUpdateXMLRPC} = "xmlrpc is in stealth mode";

($status, $error) = $x->validate_item( 'xmlrpc_local', $templ, $language, $form );

test_assert_equal( $status, "xmlrpc is in stealth mode" );
test_assert( !defined( $error ) );
test_assert_equal( $x->config_( 'local' ), 1 );

delete $form->{serveropt_xmlrpc};

# This pipe is used to send signals to the child running
# the server to change its state, the following commands can
# be sent
#
# __QUIT      Causes the child to terminate POPFile service and
#             exit

pipe my $dserverreader, my $dserverwriter;
pipe my $userverreader, my $userverwriter;

my ( $pid, $handle ) = $POPFile->CORE_forker();

if ( $pid == 0 ) {
    # CHILD THAT WILL RUN THE XMLRPC SERVER

    close $dserverwriter;
    close $userverreader;

    $userverwriter->autoflush( 1 );

    my $count = 5000;
    while ( $POPFile->CORE_service( 1 ) ) {
        select( undef, undef, undef, 0.05 );
        last if ( $count-- <= 0 );

        if ( &{$POPFile->{pipeready__}}( $dserverreader ) ) {
            my $command = <$dserverreader>;
            last if ( !defined $command );

            if ( $command =~ /__QUIT/ ) {
                print $userverwriter "OK\n";
                last;
            }
        }
    }

    close $dserverreader;
    close $userverwriter;

    sleep 2;
    exit(0);
} else {
    # PARENT -- test the XMLRPC server

    close $dserverreader;
    close $userverwriter;
    $dserverwriter->autoflush(1);

    sleep 1;
    use XMLRPC::Lite;

#    print "Testing $xport\n";

    my $xml = XMLRPC::Lite
        -> proxy( "http://127.0.0.1:$xport/RPC2" )->on_fault( sub{ } );

    test_assert( $xml );
    test_assert( ref $xml eq 'XMLRPC::Lite', ref $xml );
    goto EXIT if !$xml;

    # API.get_session_key

    my $session = $xml
        -> call( 'POPFile/API.get_session_key', 'baduser', 'badpassword' )
        -> result;

    test_assert( $session eq '' );

    $session = $xml
        -> call( 'POPFile/API.get_session_key', 'admin', '' )
        -> result;

    test_assert( $session ne '' );
    goto EXIT if !$session;

    wait_proxy();

    # API.classify

    my $file = "TestMails/TestMailParse001.msg";
    my $bucket = $xml
        -> call( 'POPFile/API.classify', $session, $file )
        -> result;

    test_assert_equal( $bucket, 'spam' );

    # API.handle_message

    my $out_file = "temp.out";
    my $handle_message = $xml
        -> call( 'POPFile/API.handle_message', $session, $file, $out_file )
        -> result;

    test_assert_equal( ref $handle_message, 'ARRAY' );

    $bucket = @{$handle_message}[0];
    my $slot = @{$handle_message}[1];
    my $magnet_used = @{$handle_message}[2];

    test_assert_equal( $bucket, 'spam' );
    test_assert_equal( $slot , 1 );
    test_assert_equal( $magnet_used, 0 );

    open CAM, "<TestMails/TestMailParse001.cam";
    open OUTPUT, "<temp.out";
    while ( <OUTPUT> ) {
        my $output_line = $_;
        next if ( $output_line =~ /^X-POPFile-TimeoutPrevention:/ );
        my $cam_line    = <CAM> || '';
        $output_line =~ s/[\r\n]//g;
        $cam_line =~ s/[\r\n]//g;
        if ( ( $output_line ne '.' ) || ( $cam_line ne '' ) ) {
            next if ( $output_line =~ /X-POPFile-Link/ );
            test_assert_equal( $output_line, $cam_line, "API.handle_message" );
        }
    }

    close CAM;
    close OUTPUT;

    unlink "temp.out";

    wait_proxy();

    # TODO: Test whether the message is correctly stored in history

    # API.handle_message with message does not exist

    $bucket = $xml
        -> call ( 'POPFile/API.handle_message', $session, "TestMails/NotExist.msg", $out_file )
        -> result;
    test_assert_equal( $bucket, "" );
    test_assert( !( -e $out_file ) );

    $bucket = $xml
        -> call ( 'POPFile/API.handle_message', "invalid session", $file, $out_file )
        -> result;
    test_assert_equal( $bucket, "" );
    test_assert( !( -e $out_file ) );

    # API.get_buckets

    my $buckets = $xml
        -> call( 'POPFile/API.get_buckets', $session )
        -> result;

    test_assert_equal( scalar @$buckets, 3 );
    test_assert_equal( @$buckets[0], 'other' );
    test_assert_equal( @$buckets[1], 'personal' );
    test_assert_equal( @$buckets[2], 'spam' );

    select( undef, undef, undef, .2 );

    sleep 5;

    # API.get_pseudo_buckets (undocumented)

    $buckets = $xml
        -> call( 'POPFile/API.get_pseudo_buckets', $session )
        -> result;

    test_assert_equal( scalar @$buckets, 1 );
    test_assert_equal( @$buckets[0], 'unclassified' );

    # API.get_all_buckets (undocumented)

    $buckets = $xml
        -> call( 'POPFile/API.get_all_buckets', $session )
        -> result;

    test_assert_equal( scalar @$buckets, 4 );
    test_assert_equal( @$buckets[0], 'other' );
    test_assert_equal( @$buckets[1], 'personal' );
    test_assert_equal( @$buckets[2], 'spam' );
    test_assert_equal( @$buckets[3], 'unclassified' );

    # API.is_bucket (undocumented)

    my $is_bucket = $xml
        -> call( 'POPFile/API.is_bucket', $session, 'personal' )
        -> result;

    test_assert( $is_bucket );

    $is_bucket = $xml
        -> call( 'POPFile/API.is_bucket', $session, 'badbucket' )
        -> result;

    test_assert( !$is_bucket );

    $is_bucket = $xml
        -> call( 'POPFile/API.is_bucket', $session, 'unclassified' )
        -> result;

    test_assert( !$is_bucket );

    # API.is_pseudo_bucket (undocumented)

    my $is_pseudo_bucket = $xml
        -> call( 'POPFile/API.is_pseudo_bucket', $session, 'unclassified' )
        -> result;

    test_assert( $is_pseudo_bucket );

    $is_pseudo_bucket = $xml
        -> call( 'POPFile/API.is_pseudo_bucket', $session, 'badbucket' )
        -> result;

    test_assert( !$is_pseudo_bucket );

    $is_pseudo_bucket = $xml
        -> call( 'POPFile/API.is_pseudo_bucket', $session, 'personal' )
        -> result;

    test_assert( !$is_pseudo_bucket );

    # API.get_bucket_word_count

    my $wc = $xml
        -> call( 'POPFile/API.get_bucket_word_count', $session, 'personal' )
        -> result;

    test_assert_equal( $wc, 103, "API.get_bucket_word_count test" );

    $wc = $xml
        -> call( 'POPFile/API.get_bucket_word_count', $session, 'badbucket' )
        -> result;

    test_assert_equal( $wc, 0 );

    # API.get_bucket_word_list

    my $word_list = $xml
        -> call( 'POPFile/API.get_bucket_word_list', $session, 'personal' )
        -> result;

    test_assert_equal( scalar @{$word_list}, 3 );
    test_assert_equal( @$word_list[0], 'foo' );
    test_assert_equal( @$word_list[1], 'bar' );
    test_assert_equal( @$word_list[2], 'baz' );

    $word_list = $xml
        -> call( 'POPFile/API.get_bucket_word_list', $session, 'personal', 'b' )
        -> result;

    test_assert_equal( scalar @{$word_list}, 2 );
    test_assert_equal( @$word_list[0], 'bar' );
    test_assert_equal( @$word_list[1], 'baz' );

    $word_list = $xml
        -> call( 'POPFile/API.get_bucket_word_list', $session, 'badbucket' )
        -> result;

    test_assert( scalar @$word_list, 1 );
    test_assert( @{$word_list}[0] eq '' );

    # API.get_bucket_word_prefixes (undocumented)

    my $word_prefixes = $xml
        -> call( 'POPFile/API.get_bucket_word_prefixes', $session, 'personal' )
        -> result;

    test_assert_equal( scalar @{$word_prefixes}, 2 );
    test_assert_equal( @{$word_prefixes}[0], 'b' );
    test_assert_equal( @{$word_prefixes}[1], 'f' );

    # API.get_count_for_word (undocumented)

    my $count_for_word = $xml
        -> call( 'POPFile/API.get_count_for_word', $session, 'personal', 'foo' )
        -> result;

    test_assert_equal( $count_for_word, 1 );

    $count_for_word = $xml
        -> call( 'POPFile/API.get_count_for_word', $session, 'personal', 'fooo' )
        -> result;

    test_assert_equal( $count_for_word, 0 );

    # API.get_word_count

    my $wc_all = $xml
        -> call( 'POPFile/API.get_word_count', $session )
        -> result;

    test_assert_equal( $wc_all, 14002 );

    # API.bucket_unique_count

    my $uc = $xml
        -> call( 'POPFile/API.get_bucket_unique_count', $session, 'personal' )
        -> result;

    test_assert_equal( $uc, 3 );

    # API.get_html_colored_message

    $file = "TestMails/TestMailParse019.msg";

    my $colored_message = $xml
        -> call( 'POPFile/API.get_html_colored_message', $session, $file )
        -> result;

    open FILE, "<TestMails/TestMailParse019.clr";
    my $check = <FILE>;
    close FILE;
    test_assert_equal( $colored_message, $check );

    my $color_test = 'get_html_colored_message';
    if ( $colored_message ne $check ) {
        open FILE, ">$color_test.expecting.html";
        print FILE $check;
        close FILE;
        open FILE, ">$color_test.got.html";
        print FILE $colored_message;
        close FILE;
    } else {
        unlink "$color_test.expecting.html";
        unlink "$color_test.got.html";
    }

    # API.set_bucket_color

    my $set_bucket_color = $xml
        -> call( 'POPFile/API.set_bucket_color', $session, 'personal', 'somecolour' )
        -> result;

    test_assert_equal( $set_bucket_color, 1 );

    select( undef, undef, undef, .2 );

    # API.get_bucket_color

    my $bucket_color = $xml
        -> call( 'POPFile/API.get_bucket_color', $session, 'personal' )
        -> result;

    test_assert_equal( $bucket_color, 'somecolour' );

    select( undef, undef, undef, .2 );

    # API.set_bucket_parameter

    my $set_bucket_parameter = $xml
        -> call( 'POPFile/API.set_bucket_parameter', $session, 'personal', 'color', 'anothercolour' )
        -> result;

    test_assert_equal( $set_bucket_parameter, 1 );

    $set_bucket_parameter = $xml
        -> call( 'POPFile/API.set_bucket_parameter', $session, 'personal', 'subject', 0 )
        -> result;

    test_assert_equal( $set_bucket_parameter, 1 );

    $set_bucket_parameter = $xml
        -> call( 'POPFile/API.set_bucket_parameter', $session, 'personal', 'xtc', 0 )
        -> result;

    test_assert_equal( $set_bucket_parameter, 1 );

    $set_bucket_parameter = $xml
        -> call( 'POPFile/API.set_bucket_parameter', $session, 'personal', 'xpl', 0 )
        -> result;

    test_assert_equal( $set_bucket_parameter, 1 );

    $set_bucket_parameter = $xml
        -> call( 'POPFile/API.set_bucket_parameter', $session, 'personal', 'quarantine', 1 )
        -> result;

    test_assert_equal( $set_bucket_parameter, 1 );

    # API.get_bucket_parameter

    $bucket_color = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'color' )
        -> result;

    test_assert_equal( $bucket_color, 'anothercolour', "API.get_bucket_parameter test 'color'" );

    my $fpcount = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'fpcount' )
        -> result;

    test_assert_equal( $fpcount, 2, "API.get_bucket_parameter test 'fpcount'" );

    my $fncount = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'fncount' )
        -> result;

    test_assert_equal( $fncount, 1, "API.get_bucket_parameter test 'fncolor'" );

    my $subject_parameter = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'subject' )
        -> result;

    test_assert_equal( $subject_parameter, 0, "API.get_bucket_parameter test 'subject'" );

    my $xtc_parameter = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'xtc' )
        -> result;

    test_assert_equal( $xtc_parameter, 0, "API.get_bucket_parameter test 'xtc'" );

    my $xpl_parameter = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'xpl' )
        -> result;

    test_assert_equal( $xpl_parameter, 0, "API.get_bucket_parameter test 'xpl'" );

    my $quarantine_parameter = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'quarantine' )
        -> result;

    test_assert_equal( $quarantine_parameter, 1, "API.get_bucket_parameter test 'quarantine'" );

    my $message_count = $xml
        -> call( 'POPFile/API.get_bucket_parameter', $session, 'personal', 'count' )
        -> result;

    test_assert_equal( $message_count, 122, "API.get_bucket_parameter test 'count'" );

    # API.create_bucket

    my $create_bucket = $xml
        -> call( 'POPFile/API.create_bucket', $session, 'newbucket' )
        -> result;

    test_assert_equal( $create_bucket, 1 );

    $create_bucket = $xml
        -> call( 'POPFile/API.create_bucket', $session, 'personal' )
        -> result;

    test_assert_equal( $create_bucket, 0 );

    $create_bucket = $xml
        -> call( 'POPFile/API.create_bucket', $session, 'unclassified' )
        -> result;

    test_assert_equal( $create_bucket, 0 );

    # TODO: bad bucket name test

    # API.rename_bucket

    my $rename_bucket = $xml
        -> call( 'POPFile/API.rename_bucket', $session, 'newbucket', 'newname' )
        -> result;

    test_assert_equal( $rename_bucket, 1 );

    $rename_bucket = $xml
        -> call( 'POPFile/API.rename_bucket', $session, 'nobucket', 'newname2' )
        -> result;

    test_assert_equal( $rename_bucket, 0 );

    $rename_bucket = $xml
        -> call( 'POPFile/API.rename_bucket', $session, 'newname', 'personal' )
        -> result;

    test_assert_equal( $rename_bucket, 0 );

    $rename_bucket = $xml
        -> call( 'POPFile/API.rename_bucket', $session, 'personal', 'unclassified' )
        -> result;

    test_assert_equal( $rename_bucket, 0 );

    # API.add_message_to_bucket

    $file = "TestMails/TestMailParse001.msg";
    my $add_message_to_bucket = $xml
        -> call( 'POPFile/API.add_message_to_bucket', $session, 'newname', $file )
        -> result;

    test_assert_equal( $add_message_to_bucket, 1 );

    $wc = $xml
        -> call( 'POPFile/API.get_bucket_word_count', $session, 'newname' )
        -> result;

    test_assert_equal( $wc, 22 );

    # API.remove_message_from_bucket

    my $remove_message_from_bucket = $xml
        -> call( 'POPFile/API.remove_message_from_bucket', $session, 'newname', $file )
        -> result;

    test_assert_equal( $remove_message_from_bucket, 1 );

    $wc = $xml
        -> call( 'POPFile/API.get_bucket_word_count', $session, 'newname' )
        -> result;

    test_assert_equal( $wc, 0 );

    # API.add_messages_to_bucket (undocumented)

    my @files = ( "TestMails/TestMailParse002.msg", "TestMails/TestMailParse003.msg" );
    my $add_messages_to_bucket = $xml
        -> call( 'POPFile/API.add_messages_to_bucket', $session, 'newname', @files )
        -> result;

    test_assert_equal( $add_messages_to_bucket, 1 );

    $wc = $xml
        -> call( 'POPFile/API.get_bucket_word_count', $session, 'newname' )
        -> result;

    test_assert_equal( $wc, 149 );

    # API.magnet_count (undocumented)

    my $magnet_count = $xml
        -> call( 'POPFile/API.magnet_count', $session )
        -> result;

    test_assert_equal( $magnet_count, 4 );

    # API.create_magnet

    my $create_magnet = $xml
        -> call( 'POPFile/API.create_magnet', $session, 'newname', 'from', 'sender' )
        -> result;

    test_assert_equal( $create_magnet, 1 );

    $magnet_count = $xml
        -> call( 'POPFile/API.magnet_count', $session )
        -> result;

    test_assert_equal( $magnet_count, 5 );

    # API.get_buckets_with_magnets

    my $buckets_with_magnets = $xml
        -> call( 'POPFile/API.get_buckets_with_magnets', $session )
        -> result;

    test_assert_equal( scalar @{$buckets_with_magnets}, 2 );
    test_assert_equal( @{$buckets_with_magnets}[0], 'newname' );
    test_assert_equal( @{$buckets_with_magnets}[1], 'personal' );

    # API.get_magnet_types_in_bucket

    my $magnet_types = $xml
        -> call( 'POPFile/API.get_magnet_types_in_bucket', $session, 'personal' )
        -> result;

    test_assert_equal( scalar @{$magnet_types}, 3 );
    test_assert_equal( @{$magnet_types}[0], 'from'    );
    test_assert_equal( @{$magnet_types}[1], 'subject' );
    test_assert_equal( @{$magnet_types}[2], 'to'      );

    # API.get_magnets

    my $magnets = $xml
        -> call( 'POPFile/API.get_magnets', $session, 'newname', 'from' )
        -> result;

    test_assert_equal( scalar @{$magnets}, 1 );
    test_assert_equal( @{$magnets}[0], 'sender' );

    # API.delete_magnet

    my $delete_magnet = $xml
        -> call( 'POPFile/API.delete_magnet', $session, 'newname', 'from', 'sender' )
        -> result;

    test_assert_equal( $delete_magnet, 1 );

    $buckets_with_magnets = $xml
        -> call( 'POPFile/API.get_buckets_with_magnets', $session )
        -> result;

    test_assert_equal( scalar @{$buckets_with_magnets}, 1 );
    test_assert_equal( @{$buckets_with_magnets}[0], 'personal' );

    $magnet_count = $xml
        -> call( 'POPFile/API.magnet_count', $session )
        -> result;

    test_assert_equal( $magnet_count, 4 );

    # API.clear_magnets

    my $clear_magnets = $xml
        -> call( 'POPFile/API.clear_magnets', $session )
        -> result;

    test_assert_equal( $clear_magnets, 1 );

    $buckets_with_magnets = $xml
        -> call( 'POPFile/API.get_buckets_with_magnets', $session )
        -> result;

    test_assert_equal( scalar @{$buckets_with_magnets}, 0 );

    $magnet_count = $xml
        -> call( 'POPFile/API.magnet_count', $session )
        -> result;

    test_assert_equal( $magnet_count, 0 );

    # API.get_magnet_types

    my %mtypes = @{$xml
        -> call( 'POPFile/API.get_magnet_types', $session )
        -> result};

    test_assert_equal( scalar keys %mtypes, 4 );
    test_assert_equal( $mtypes{to},      'To'      );
    test_assert_equal( $mtypes{cc},      'Cc'      );
    test_assert_equal( $mtypes{from},    'From'    );
    test_assert_equal( $mtypes{subject}, 'Subject' );

    # API.delete_bucket

    my $delete_bucket = $xml
        -> call( 'POPFile/API.delete_bucket', $session, 'newname' )
        -> result;

    test_assert_equal( $delete_bucket, 1 );

    $delete_bucket = $xml
        -> call( 'POPFile/API.delete_bucket', $session, 'nobucket' )
        -> result;

    test_assert_equal( $delete_bucket, 0 );

    # API.clear_bucket

    my $clear_bucket = $xml
        -> call( 'POPFile/API.clear_bucket', $session, 'personal' )
        -> result;

    test_assert_equal( $clear_bucket, 1 );

    $wc = $xml
        -> call( 'POPFile/API.get_bucket_word_count', $session, 'personal' )
        -> result;

    test_assert_equal( $wc, 0 );

    # API.get_stopword_list

    my $stopwords = $xml
        -> call( 'POPFile/API.get_stopword_list', $session )
        -> result;

    test_assert_equal( scalar @{$stopwords}, 193 );
    test_assert_equal( @{$stopwords}[0], 'strike' );

    # API.add_stopword

    my $add_stopword = $xml
        -> call( 'POPFile/API.add_stopword', $session, 'mystopword' )
        -> result;

    test_assert_equal( $add_stopword, 1 );

    $stopwords = $xml
        -> call( 'POPFile/API.get_stopword_list', $session )
        -> result;

    test_assert_equal( scalar @{$stopwords}, 194 );

    # API.remove_stopword

    my $remove_stopword = $xml
        -> call( 'POPFile/API.remove_stopword', $session, 'mystopword' )
        -> result;

    test_assert_equal( $remove_stopword, 1 );

    $stopwords = $xml
        -> call( 'POPFile/API.get_stopword_list', $session )
        -> result;

    test_assert_equal( scalar @{$stopwords}, 193 );

    # Tests for v2 APIs

    # API.reclassify

    my %messages = ( $slot => 'personal' );
    my $reclassify = $xml
        -> call ( 'POPFile/API.reclassify', $session, %messages )
        -> result;

    test_assert_equal( $reclassify, 1 );

    # check if the bucket unique count numbers up.

    my $uc2 = $xml
        -> call ( 'POPFile/API.get_bucket_unique_count', $session, 'personal' )
        -> result;

    test_assert_equal( $uc2, 19 );

    # TODO: Test whether the message is reclassified

    # API.reclassify with bad parameters

    $reclassify = $xml
        -> call ( 'POPFile/API.reclassify', $session, undef )
        -> result;

    test_assert_equal( $reclassify, '' );

    $reclassify = $xml
        -> call ( 'POPFile/API.reclassify', $session, 2, 'personal' )
        -> result;

    test_assert_equal( $reclassify, 0 );

    $reclassify = $xml
        -> call ( 'POPFile/API.reclassify', $session, 1, 'badbucket' )
        -> result;

    test_assert_equal( $reclassify, 0 );

    # TODO: Multi-user mode tests

    # API.create_user (ADMIN ONLY)

    my $create_user = $xml
        -> call ( 'POPFile/API.create_user', $session, 'newuser' )
        -> result;

    test_assert_equal( $create_user->[0], 0 ); # Success
    test_assert( $create_user->[1] );
    my $password = $create_user->[1];

    $create_user = $xml
        -> call ( 'POPFile/API.create_user', $session, 'newuser' )
        -> result;

    test_assert_equal( $create_user->[0], 1 ); # Already exists
    test_assert_equal( $create_user->[1], '' );

    $create_user = $xml
        -> call ( 'POPFile/API.create_user', $session, 'copyuser', 'newuser', 1, 1 )
        -> result;

    test_assert_equal( $create_user->[0], 0 ); # Success

    # test login as a new user

    my $session2 = $xml
        -> call ( 'POPFile/API.get_session_key', 'newuser', $password )
        -> result;

    test_assert( $session2 );

    # API.rename_user (ADMIN ONLY)

    my $rename_user = $xml
        -> call ( 'POPFile/API.rename_user', $session, 'copyuser', 'copyuser2' )
        -> result;

    test_assert_equal( $rename_user->[0], 0 ); # Success
    test_assert( $rename_user->[1] );

    $rename_user = $xml
        -> call ( 'POPFile/API.rename_user', $session, 'copyuser2', 'newuser' )
        -> result;

    test_assert_equal( $rename_user->[0], 1 ); # Already exists
    test_assert_equal( $rename_user->[1], '' );

    # API.remove_user (ADMIN ONLY)

    my $remove_user = $xml
        -> call ( 'POPFile/API.remove_user', $session, 'copyuser2' )
        -> result;

    test_assert_equal( $remove_user, 0 ); # Success

    $remove_user = $xml
        -> call ( 'POPFile/API.remove_user', $session, 'notauser' )
        -> result;

    test_assert_equal( $remove_user, 1 ); # Does not exist

    # API.set_password

    my $set_password_for_user = $xml
        -> call ( 'POPFile/API.set_password', $session2, 'password' )
        -> result;

    test_assert_equal( $set_password_for_user, 1 ); # Success

    $xml->call ( 'POPFile/API.release_session_key', $session2 );
    wait_proxy();

    # try to login using new password

    $session2 = $xml
        -> call ( 'POPFile/API.get_session_key', 'newuser', 'password' )
        -> result;

    test_assert( $session2 ne '' );

    $xml->call ( 'POPFile/API.release_session_key', $session2 );
    wait_proxy();

    # API.change_users_password (ADMIN ONLY)

    my $change_users_password = $xml
        -> call ( 'POPFile/API.change_users_password', $session, 'newuser', 'password2' )
        -> result;

    test_assert_equal( $change_users_password, 0 ); # Success

    $change_users_password = $xml
        -> call ( 'POPFile/API.change_users_password', $session, 'baduser', 'password' )
        -> result;

    test_assert_equal( $change_users_password, 1 ); # No such user

    # try to login using new password

    $session2 = $xml
        -> call ( 'POPFile/API.get_session_key', 'newuser', 'password2' )
        -> result;

    test_assert( $session2 ne '' );

    $xml->call ( 'POPFile/API.release_session_key', $session2 );
    wait_proxy();

    # API.initialize_users_password (ADMIN ONLY)

    my $initialize_users_password = $xml
        -> call ( 'POPFile/API.initialize_users_password', $session, 'newuser' )
        -> result;

    test_assert( $initialize_users_password );
    test_assert_equal( $initialize_users_password->[0], 0 );
    test_assert( $initialize_users_password->[1] );

    $password = $initialize_users_password->[1];

    # try to login using new password

    $session2 = $xml
        -> call ( 'POPFile/API.get_session_key', 'newuser', $password )
        -> result;

    test_assert( $session2 ne '' );

#    $xml->call ( 'POPFile/API.release_session_key', $session2 );

    # API.get_user_id (ADMIN ONLY)

    my $user_id = $xml
        -> call ( 'POPFile/API.get_user_id', $session, 'newuser' )
        -> result;

    test_assert( $user_id ne '' );

    $user_id = $xml
        -> call ( 'POPFile/API.get_user_id', $session, 'baduser' )
        -> result;

    test_assert( $user_id eq '' );

    # API.get_user_id_from_session

    $user_id = $xml
        -> call ( 'POPFile/API.get_user_id_from_session', $session )
        -> result;

    test_assert( $user_id ne '' );
    test_assert_equal( $user_id, 1 );

    $user_id = $xml
        -> call ( 'POPFile/API.get_user_id_from_session', $session2 )
        -> result;

    test_assert( $user_id ne '' );
    test_assert_equal( $user_id, 2 );

    # API.get_user_name_from_session

    my $user_name = $xml
        -> call ( 'POPFile/API.get_user_name_from_session', $session )
        -> result;

    test_assert_equal( $user_name, 'admin' );

    $user_name = $xml
        -> call ( 'POPFile/API.get_user_name_from_session', $session2 )
        -> result;

    test_assert_equal( $user_name, 'newuser' );

    # API.get_user_parameter_list (ADMIN ONLY)

    my $user_parameter_list = $xml
        -> call ( 'POPFile/API.get_user_parameter_list', $session )
        -> result;

    test_assert_equal( scalar @{$user_parameter_list}, 37 );
    my @params = ( 'GLOBAL_can_admin', 'GLOBAL_private_key', 'GLOBAL_public_key',
                   'bayes_subject_mod_left', 'bayes_subject_mod_pos',
                   'bayes_subject_mod_right', 'bayes_unclassified_weight',
                   'bayes_xpl_angle', 'history_history_days',
                   'html_column_characters', 'html_columns', 'html_date_format',
                   'html_language', 'html_last_reset', 'html_last_update_check',
                   'html_page_size', 'html_send_stats', 'html_session_dividers',
                   'html_show_bucket_help', 'html_show_configbars',
                   'html_show_training_help', 'html_skin', 'html_test_language',
                   'html_update_check', 'html_wordtable_format',
                   'imap_bucket_folder_mappings', 'imap_expunge', 'imap_hostname',
                   'imap_login', 'imap_password', 'imap_port',
                   'imap_training_mode', 'imap_uidnexts', 'imap_uidvalidities',
                   'imap_update_interval', 'imap_use_ssl', 'imap_watched_folders', );
    foreach my $param ( sort @{$user_parameter_list} ) {
        test_assert_equal( $param, shift @params );
    }


    # API.release_session_key

    $xml
        -> call ( 'POPFile/API.release_session_key', $session );

    $xml
        -> call ( 'POPFile/API.release_session_key', $session2 );

EXIT:
    # Tell the POPFile to die

    print $dserverwriter "__QUIT\n";
    my $line = <$userverreader>;
    test_assert_equal( $line, "OK\n" );
    close $dserverwriter;
    close $userverreader;

    $POPFile->CORE_stop();

    while ( waitpid( -1, &WNOHANG ) > 0 ) {
        sleep 1;
    }
}

sub wait_proxy
{
    my $cd = 10;
    while ( $cd-- ) {
        select( undef, undef, undef, 0.05 );
        $POPFile->CORE_service( 1 );
    }
}

1;
