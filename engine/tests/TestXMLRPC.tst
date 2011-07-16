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

#use UI::XMLRPC;
#my $x = new UI::XMLRPC;
#$x->loader( $POPFile );

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

#$x->initialize();
$x->config_( 'enabled', 1 );
test_assert( $x->config_( 'enabled' ), 1 );
my $xport = 12000 + int( rand( 2000 ) );
$x->config_( 'port', $xport );
$POPFile->CORE_start();

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

    # TODO : test v2 APIs

    # API.reclassify

    my %messages = ( $slot => 'personal' );
    my $reclassify = $xml
        -> call ( 'POPFile/API.reclassify', $session, %messages )
        -> result;

    test_assert_equal( $reclassify, 1 );

    # Check if the bucket unique count numbers up.

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

    # API.create_user

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

    # API.rename_user

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

    # API.remove_user

    my $remove_user = $xml
        -> call ( 'POPFile/API.remove_user', $session, 'copyuser2' )
        -> result;

    test_assert_equal( $remove_user, 0 ); # Success

    $remove_user = $xml
        -> call ( 'POPFile/API.remove_user', $session, 'notauser' )
        -> result;

    test_assert_equal( $remove_user, 1 ); # Does not exist


    # API.release_session_key

    $xml
        -> call('POPFile/API.release_session_key', $session );


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
        select( undef, undef, undef, 0.1 );
        $POPFile->CORE_service( 1 );
    }
}

1;
