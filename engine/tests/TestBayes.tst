# ---------------------------------------------------------------------------------------------
#
# Tests for Bayes.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

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

# TODO

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
close FILE;

# add_message_to_bucket

# remove_message_from_bucket

# add_messages_to_bucket

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
$b->{total__}{personal} = 100;
$b->set_value_( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value_( 'personal', 'foo' ), 0 );
$b->{total__}{personal} = 1000;
$b->set_value_( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value_( 'personal', 'foo' ), -log(10) );

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

# TODO test that stop writes the parameters to disk

$b->stop();

