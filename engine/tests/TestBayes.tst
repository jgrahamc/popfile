# ---------------------------------------------------------------------------------------------
#
# Tests for Bayes.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

test_assert( `rm -rf corpus` == 0 );
test_assert( `cp -R corpus.base corpus` == 0 );

unlink 'stopwords';
test_assert( `cp stopwords.base stopwords` == 0 );

use Classifier::Bayes;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;

# Load the test corpus
my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;

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

$b->configuration( $c );
$b->mq( $mq );
$b->logger( $l );

$b->initialize();
test_assert( $b->start() );

# Test the unclassifier_probability parameter

test_assert_equal( $b->{unclassified__}, log(0.5) );
$b->config_( 'unclassified_probability', 0.42 );
test_assert( $b->start() );
test_assert_equal( $b->{unclassified__}, log(0.42) );
$b->config_( 'unclassified_probability', 0.5 );
test_assert( $b->start() );
test_assert_equal( $b->{unclassified__}, log(0.5) );

# test the API functions

# get_buckets

my @buckets = $b->get_buckets();
test_assert_equal( $#buckets, 2 );
test_assert_equal( $buckets[0], 'other' );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam' );

# get_bucket_word_count

test_assert_equal( $b->get_bucket_word_count($buckets[0]), 1785 );
test_assert_equal( $b->get_bucket_word_count($buckets[1]), 103 );
test_assert_equal( $b->get_bucket_word_count($buckets[2]), 12114 );

# get_bucket_word_list

my @words = $b->get_bucket_word_list( 'personal' );
test_assert_equal( $#words, 1 );
test_assert_equal( $words[0], '|bar 2||baz 100|' );
test_assert_equal( $words[1], '|foo 1|' );

# get_word_count

test_assert_equal( $b->get_word_count(), 14002 );

# get_count_for_word

test_assert_equal( $b->get_count_for_word($buckets[0], 'foo'), 0 );
test_assert_equal( $b->get_count_for_word($buckets[1], 'foo'), 1 );
test_assert_equal( $b->get_count_for_word($buckets[2], 'foo'), 0 );

# get_bucket_unique_count

test_assert_equal( $b->get_bucket_unique_count($buckets[0]), 656 );
test_assert_equal( $b->get_bucket_unique_count($buckets[1]), 3 );
test_assert_equal( $b->get_bucket_unique_count($buckets[2]), 3353 );

# get_bucket_color

test_assert_equal( $b->get_bucket_color($buckets[0]), 'red' );
test_assert_equal( $b->get_bucket_color($buckets[1]), 'green' );
test_assert_equal( $b->get_bucket_color($buckets[2]), 'blue' );

# set_bucket_color

test_assert_equal( $b->get_bucket_color($buckets[0]), 'red' );
$b->set_bucket_color( $buckets[0], 'yellow' );
test_assert_equal( $b->get_bucket_color($buckets[0]), 'yellow' );
$b->set_bucket_color( $buckets[0], 'red' );
test_assert_equal( $b->get_bucket_color($buckets[0]), 'red' );

# get_bucket_parameter

test_assert_equal( $b->get_bucket_parameter( $buckets[0], 'dummy' ), 0 );
test_assert_equal( $b->get_bucket_parameter( $buckets[0], 'quarantine' ), 0 );
test_assert_equal( $b->get_bucket_parameter( $buckets[0], 'subject' ), 1 );

# set_bucket_parameter

test_assert_equal( $b->get_bucket_parameter( $buckets[0], 'dummy2' ), 0 );
$b->set_bucket_parameter( $buckets[0], 'dummy2', 'value' );
test_assert_equal( $b->get_bucket_parameter( $buckets[0], 'dummy2' ), 'value' );
my $found = 0;
open FILE, "<corpus/$buckets[0]/params";
while( <FILE> ) {
    if ( /dummy2 value/ ) {
        $found = 1;
        last;
    }
}
close FILE;
test_assert( $found );
$b->set_bucket_parameter( $buckets[0], 'dummy2', 0 );
test_assert_equal( $b->get_bucket_parameter( $buckets[0], 'dummy2' ), 0 );

# get_html_colored_message

my $html = $b->get_html_colored_message( 'TestMailParse019.msg' );
open FILE, "<TestMailParse019.clr";
my $check = <FILE>;
close FILE;
# TODO test_assert_equal( $html, $check );

if ( $html ne $check ) {
    my $color_test = 'get_html_colored_message';
    open FILE, ">$color_test.expecting.html";
    print FILE $check;
    close FILE;
    open FILE, ">$color_test.got.html";
    print FILE $html;
    close FILE;
}

# create_bucket

$b->create_bucket( 'zebra' );

@buckets = $b->get_buckets();
test_assert_equal( $#buckets, 3 );
test_assert_equal( $buckets[0], 'other' );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam' );
test_assert_equal( $buckets[3], 'zebra' );

test_assert_equal( $b->get_bucket_parameter( 'zebra', 'count' ), 0 );
test_assert_equal( $b->get_bucket_parameter( 'zebra', 'subject' ), 1 );
test_assert_equal( $b->get_bucket_parameter( 'zebra', 'quarantine' ), 0 );

test_assert_equal( $b->get_bucket_word_count( 'zebra' ), 0 );
test_assert_equal( $b->get_bucket_unique_count( 'zebra' ), 0 );

test_assert_equal( $b->get_word_count(), 14002 );

test_assert( -e 'corpus/zebra' );
test_assert( -e 'corpus/zebra/table' );

open FILE, "<corpus/zebra/table";
my $line = <FILE>;
test_assert_regexp( $line, '__CORPUS__ __VERSION__ 1' );
close FILE;

# rename_bucket

test_assert( !$b->rename_bucket( 'none', 'some' ) );
test_assert( $b->rename_bucket( 'zebra', 'zeotrope' ) );

@buckets = $b->get_buckets();
test_assert_equal( $#buckets, 3 );
test_assert_equal( $buckets[0], 'other' );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam' );
test_assert_equal( $buckets[3], 'zeotrope' );

test_assert_equal( $b->get_bucket_parameter( 'zeotrope', 'count' ), 0 );
test_assert_equal( $b->get_bucket_parameter( 'zeotrope', 'subject' ), 1 );
test_assert_equal( $b->get_bucket_parameter( 'zeotrope', 'quarantine' ), 0 );

test_assert_equal( $b->get_bucket_word_count( 'zeotrope' ), 0 );
test_assert_equal( $b->get_bucket_unique_count( 'zeotrope' ), 0 );

test_assert_equal( $b->get_word_count(), 14002 );

test_assert( -e 'corpus/zeotrope' );
test_assert( -e 'corpus/zeotrope/table' );

open FILE, "<corpus/zeotrope/table";
$line = <FILE>;
test_assert_regexp( $line, '__CORPUS__ __VERSION__ 1' );
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

# add_message_to_bucket

my %words;

open WORDS, "<TestMailParse021.wrd";
while ( <WORDS> ) {
    if ( /(.+) (\d+)/ ) {
        $words{$1} = $2;
    }
}
close WORDS;

test_assert( !$b->add_message_to_bucket( 'none', 'TestMailParse021.msg' ) );
test_assert( $b->add_message_to_bucket( 'zeotrope', 'TestMailParse021.msg' ) );
open FILE, "<corpus/zeotrope/table";
$line = <FILE>;
test_assert_regexp( $line, '__CORPUS__ __VERSION__ 1' );
while ( <FILE> ) {
    if ( /(.+) (\d+)/ ) {
        test_assert_equal( $words{$1}, $2, "zeotrope: $1 $2 $words{$1}" );
    }
}
close FILE;

test_assert( $b->add_message_to_bucket( 'zeotrope', 'TestMailParse021.msg' ) );

open FILE, "<corpus/zeotrope/table";
$line = <FILE>;
test_assert_regexp( $line, '__CORPUS__ __VERSION__ 1' );
while ( <FILE> ) {
    if ( /(.+) (\d+)/ ) {
        test_assert_equal( ($words{$1}*2), $2, "zeotrope: $1 $2 $words{$1}" );
    }
}
close FILE;

# remove_message_from_bucket

test_assert( !$b->remove_message_from_bucket( 'none', 'TestMailParse021.msg' ) );
test_assert( $b->remove_message_from_bucket( 'zeotrope', 'TestMailParse021.msg' ) );
test_assert( $b->remove_message_from_bucket( 'zeotrope', 'TestMailParse021.msg' ) );

open FILE, "<corpus/zeotrope/table";
$line = <FILE>;
test_assert_regexp( $line, '__CORPUS__ __VERSION__ 1' );
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

# add_messages_to_bucket

test_assert( $b->add_message_to_bucket( 'zeotrope', [ 'TestMailParse021.msg', 'TestMailParse021.msg' ] ) );

open FILE, "<corpus/zeotrope/table";
$line = <FILE>;
test_assert_regexp( $line, '__CORPUS__ __VERSION__ 1' );
while ( <FILE> ) {
    if ( /(.+) (\d+)/ ) {
        test_assert_equal( ($words{$1}*2), $2, "zeotrope: $1 $2 $words{$1}" );
    }
}
close FILE;

# Test corrupting the corpus

open FILE, ">corpus/zeotrope/table";
print FILE "__CORPUS__ __VERSION__ 2\n";
close FILE;

open STDERR, ">temp.tmp";
test_assert( !$b->add_message_to_bucket( 'zeotrope', 'TestMailParse021.msg' ) );
close STDERR;
open FILE, "<temp.tmp";
$line = <FILE>;
test_assert_regexp( $line, 'Incompatible corpus version in zeotrope' );
close FILE;

open STDERR, ">temp.tmp";
test_assert( !$b->remove_message_from_bucket( 'zeotrope', 'TestMailParse021.msg' ) );
close STDERR;
open FILE, "<temp.tmp";
$line = <FILE>;
test_assert_regexp( $line, 'Incompatible corpus version in zeotrope' );
close FILE;

open STDERR, ">temp.tmp";
test_assert( !$b->load_bucket_( 'zeotrope' ) );
close STDERR;
open FILE, "<temp.tmp";
$line = <FILE>;
test_assert_regexp( $line, 'Incompatible corpus version in zeotrope' );
close FILE;

open FILE, ">corpus/zeotrope/table";
close FILE;

open STDERR, ">temp.tmp";
test_assert( !$b->load_bucket_( 'zeotrope' ) );
close STDERR;
open FILE, "<temp.tmp";
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

# create_magnet

test_assert_equal( $b->magnet_count(), 4 );
$b->create_magnet( 'zeotrope', 'from', 'francis' );
test_assert_equal( $b->magnet_count(), 5 );

# get_buckets_with_magnets

my @mags = $b->get_buckets_with_magnets();
test_assert_equal( $#mags, 1 );
test_assert_equal( $mags[0], 'personal' );
test_assert_equal( $mags[1], 'zeotrope' );

# get_magnet_type_in_bucket

my @types = $b->get_magnet_types_in_bucket( 'zeotrope' );
test_assert_equal( $#types, 0 );
test_assert_equal( $types[0], 'from' );

@types = $b->get_magnet_types_in_bucket( 'personal' );
test_assert_equal( $#types, 2 );
test_assert_equal( $types[0], 'from' );
test_assert_equal( $types[1], 'subject' );
test_assert_equal( $types[2], 'to' );

# get_magnets

my @magnets = $b->get_magnets( 'zeotrope', 'from' );
test_assert_equal( $#magnets, 0 );
test_assert_equal( $magnets[0], 'francis' );

@magnets = $b->get_magnets( 'personal', 'from' );
test_assert_equal( $#magnets, 1 );
test_assert_equal( $magnets[0], 'foo' );
test_assert_equal( $magnets[1], 'oldstyle' );
@magnets = $b->get_magnets( 'personal', 'to' );
test_assert_equal( $#magnets, 0 );
test_assert_equal( $magnets[0], 'baz@baz.com' );
@magnets = $b->get_magnets( 'personal', 'subject' );
test_assert_equal( $#magnets, 0 );
test_assert_equal( $magnets[0], 'bar' );

# get_magnet_types

my %mtypes = $b->get_magnet_types();
my @mkeys = keys %mtypes;
test_assert_equal( $#mkeys, 3 );
test_assert_equal( $mtypes{from}, 'From' );
test_assert_equal( $mtypes{to}, 'To' );
test_assert_equal( $mtypes{subject}, 'Subject' );
test_assert_equal( $mtypes{cc}, 'Cc' );

# delete_magnet

$b->delete_magnet( 'zeotrope', 'from', 'francis' );
test_assert_equal( $b->magnet_count(), 4 );

@mags = $b->get_buckets_with_magnets();
test_assert_equal( $#mags, 0 );
test_assert_equal( $mags[0], 'personal' );

# send a message through the mq

test_assert_equal( $b->get_bucket_parameter( 'zeotrope', 'count' ), 0 );
$b->mq_post_( 'CLASS', 'zeotrope' );
$mq->service();
test_assert_equal( $b->get_bucket_parameter( 'zeotrope', 'count' ), 1 );

# clear_bucket

$b->clear_bucket( 'zeotrope' );
test_assert( !( -e 'corpus/zeotrope/table' ) );
test_assert_equal( $b->get_bucket_word_count('zeotrope'), 0 );

# classify a message using a magnet

$b->create_magnet( 'zeotrope', 'from', 'cxcse231@yahoo.com' );
test_assert_equal( $b->classify( 'TestMailParse021.msg' ), 'zeotrope' );
test_assert_equal( $b->{magnet_detail__}, 'from: cxcse231@yahoo.com' );
test_assert( $b->{magnet_used__} );

# clear_magnets

$b->clear_magnets();
test_assert_equal( $b->magnet_count(), 0 );
@mags = $b->get_buckets_with_magnets();
test_assert_equal( $#mags, -1 );

# delete_bucket

test_assert( !$b->delete_bucket( 'zebrazerba' ) );
test_assert( $b->delete_bucket( 'zeotrope' ) );
test_assert( !( -e 'corpus/zeotrope/table' ) );
test_assert( !( -e 'corpus/zeotrope' ) );

@buckets = $b->get_buckets();
test_assert_equal( $#buckets, 2 );
test_assert_equal( $buckets[0], 'other' );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam' );

# getting and setting values

test_assert_equal( $b->get_value_( 'personal', 'foo' ), log(1/103) );
test_assert_equal( $b->get_sort_value_( 'personal', 'foo' ), log(1/103) );
$b->{total__}{personal} = 100;
$b->set_value_( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value_( 'personal', 'foo' ), 0 );
test_assert_equal( $b->get_sort_value_( 'personal', 'foo' ), $b->{not_likely__} );
$b->{total__}{personal} = 1000;
$b->set_value_( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value_( 'personal', 'foo' ), -log(10) );
test_assert_equal( $b->get_sort_value_( 'personal', 'foo' ), -log(10) );

# glob the tests directory for files called TestMailParse\d+.msg which consist of messages
# to be parsed with the resulting classification in TestMailParse.cls

my @class_tests = sort glob 'TestMailParse*.msg';

for my $class_test (@class_tests) {
    my $class_file = $class_test;
    $class_file    =~ s/msg/cls/;
	my $class;

    if ( open CLASS, "<$class_file" ) {
    	$class = <CLASS>;
    	$class =~ s/[\r\n]//g;
    	close CLASS;
    }

    test_assert_equal( $b->classify( $class_test ), $class, $class_test );
}

# glob the tests directory for files called TestMailParse\d+.msg which consist of messages 
# to be sent through classify_and_modify

$b->global_config_( 'msgdir', '../tests/' );
$b->module_config_( 'html', 'port', 8080 );
$b->module_config_( 'html', 'local', 1 );
$b->global_config_( 'xtc',  1 );
$b->global_config_( 'xpl',  1 );
$b->module_config_( 'pop3', 'local', 1 );
$b->global_config_( 'subject',  1 );
$b->set_bucket_parameter( 'spam', 'subject', 1 );

my @modify_tests = sort glob 'TestMailParse*.msg';

for my $modify_file (@modify_tests) {
    if ( ( open MSG, "<$modify_file" ) && ( open OUTPUT, ">temp.out" ) ) {
	    $b->classify_and_modify( \*MSG, \*OUTPUT, 0, 0, 0, '' );
	    close MSG;
		close OUTPUT;

		my $output_file = $modify_file;
		$output_file    =~ s/msg/cam/;

		open CAM, "<$output_file";
		open OUTPUT, "<temp.out";
		while ( <OUTPUT> ) {
		    my $output_line = $_;
			my $cam_line    = <CAM>;
			$output_line =~ s/[\r\n]//g;
			$cam_line =~ s/[\r\n]//g;
			test_assert_equal( $output_line, $cam_line, $modify_file );
		}
		
		close CAM;
		close OUTPUT;
		unlink( 'popfile0=0.msg' );
		unlink( 'popfile0=0.cls' );
		unlink( 'temp.out' );
    }
}

# tests for stopwords API

unlink 'stopwords';
open FILE, ">stopwords";
print FILE "notthis\nandnotthat\n";
close FILE;

$b->{parser__}->{mangle__}->load_stopwords();

# get_stopword_list

my @stopwords = $b->get_stopword_list();
test_assert_equal( $#stopwords, 1 );
test_assert_equal( $stopwords[0], 'notthis' );
test_assert_equal( $stopwords[1], 'andnotthat' );

# add_stopword

test_assert( $b->add_stopword( 'northat' ) );
@stopwords = $b->get_stopword_list();
test_assert_equal( $#stopwords, 2 );
test_assert_equal( $stopwords[0], 'northat' );
test_assert_equal( $stopwords[1], 'notthis' );
test_assert_equal( $stopwords[2], 'andnotthat' );

# remove_stopword

test_assert( $b->remove_stopword( 'northat' ) );
@stopwords = $b->get_stopword_list();
test_assert_equal( $#stopwords, 1 );
test_assert_equal( $stopwords[0], 'notthis' );
test_assert_equal( $stopwords[1], 'andnotthat' );

# Test history class file reading and writing

unlink( 'messages/*' );

$b->history_write_class( 'one.msg', 0, 'zeotrope' );
my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'one.msg' );
test_assert( !$reclassified );
test_assert_equal( $bucket, 'zeotrope' );
test_assert( !defined( $usedtobe ) );
test_assert_equal( $magnet, '' );

$b->history_write_class( 'one.msg', 1, 'zeotrope', 'spam' );
my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'one.msg' );
test_assert( $reclassified );
test_assert_equal( $bucket, 'zeotrope' );
test_assert_equal( $usedtobe, 'spam' );
test_assert_equal( $magnet, '' );

$b->history_write_class( 'one.msg', 0, 'zeotrope', undef, 'from: margit' );
my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'one.msg' );
test_assert( !$reclassified );
test_assert_equal( $bucket, 'zeotrope' );
test_assert( !defined( $usedtobe ) );
test_assert_equal( $magnet, 'from: margit' );

my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'two.msg' );
test_assert( !defined( $reclassified ) );
test_assert( !defined( $bucket ) );
test_assert( !defined( $usedtobe ) );
test_assert( !defined( $magnet ) );

# echo_to_dot_

open FILE, ">messages/one.msg";
print FILE "From: test\@test.com\n";
print FILE "Subject: Your attention please\n\n";
print FILE "This is the body\n.\n";
close FILE;

# Four possibilities for echo_to_dot_ depending on whether we give
# it a client handle, a file handle, both or neither

# neither

open MAIL, "<messages/one.msg";
$b->echo_to_dot_( \*MAIL );
test_assert( eof( MAIL ) );
close MAIL;

# to a handle

open TEMP, ">temp.tmp";
open MAIL, "<messages/one.msg";
$b->echo_to_dot_( \*MAIL, \*TEMP );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP;

open TEMP, "<temp.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# to a file (no dot)

open TEMP, ">temp.tmp";
open MAIL, "<messages/one.msg";
$b->echo_to_dot_( \*MAIL, undef, \*TEMP );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP;

open TEMP, "<temp.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    last if ( $mail =~ /^./ );
    test_assert_regexp( $temp, $mail );
}
test_assert( !eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# both

open TEMP, ">temp.tmp";
open TEMP2, ">temp2.tmp";
open MAIL, "<messages/one.msg";
$b->echo_to_dot_( \*MAIL, \*TEMP2, \*TEMP );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP;

open TEMP, "<temp.tmp";
open TEMP2, "<temp2.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) && !eof( TEMP2 ) ) {
    my $temp = <TEMP>;
    my $temp2 = <TEMP>;
    my $mail = <MAIL>;
    test_assert_regexp( $temp2, $mail );
    last if ( $mail =~ /^./ );
    test_assert_regexp( $temp, $mail );
}
test_assert( !eof( MAIL ) );
test_assert( eof( TEMP ) );
test_assert( !eof( TEMP2 ) );
close MAIL;
close TEMP;
close TEMP2;

# to a file (no dot) with before string

open TEMP, ">temp.tmp";
open MAIL, "<messages/one.msg";
$b->echo_to_dot_( \*MAIL, undef, \*TEMP, "before\n" );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP;

open TEMP, "<temp.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    if ( $mail =~ /^./ ) {
        test_assert_regexp( $temp, 'before' );
        last;
    }
    test_assert_regexp( $temp, $mail );
}
test_assert( !eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# TODO test that stop writes the parameters to disk

$b->stop();
