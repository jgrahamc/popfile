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
$b->config_( 'corpus', 'tests/corpus' );
$b->start();

# getting and setting values
test_assert_equal( $b->get_value_( 'personal', 'foo' ), log(1/103) );
$b->{total__}{personal} = 100;
$b->set_value_( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value_( 'personal', 'foo' ), 0 );
$b->{total__}{personal} = 1000;
$b->set_value_( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value_( 'personal', 'foo' ), -log(10) );

# test the API functions
my @buckets = $b->get_buckets();
test_assert_equal( $buckets[0], '' );
test_assert_equal( $buckets[1], '' );
test_assert_equal( $buckets[2], '' );

# glob the tests directory for files called TestMailParse\d+.msg which consist of messages 
# to be parsed with the resulting classification in TestMailParse.cls

my @class_tests = sort glob 'tests/TestMailParse*.msg';

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

$b->global_config_( 'msgdir', 'tests/' );
$b->module_config_( 'html', 'port', 8080 );
$b->module_config_( 'html', 'local', 1 );
$b->global_config_( 'xtc',  1 );
$b->global_config_( 'xpl',  1 );
$b->module_config_( 'pop3', 'local', 1 );
$b->global_config_( 'subject',  1 );
$b->set_bucket_parameter( 'spam', 'subject', 1 );

my @modify_tests = sort glob 'tests/TestMailParse*.msg';

for my $modify_file (@modify_tests) {
    if ( ( open MSG, "<$modify_file" ) && ( open OUTPUT, ">tests/temp.out" ) ) {
	    $b->classify_and_modify( \*MSG, \*OUTPUT, 0, 0, 0, '' );
	    close MSG;
		close OUTPUT;

		my $output_file = $modify_file;
		$output_file    =~ s/msg/cam/;

		open CAM, "<$output_file";
		open OUTPUT, "<tests/temp.out";
		while ( <OUTPUT> ) {
		    my $output_line = $_;
			my $cam_line    = <CAM>;
			$output_line =~ s/[\r\n]//g;
			$cam_line =~ s/[\r\n]//g;
			test_assert_equal( $output_line, $cam_line, $modify_file );
		}
		
		close CAM;
		close OUTPUT;
		unlink( 'tests/popfile0=0.msg' );
		unlink( 'tests/popfile0=0.cls' );
		unlink( 'tests/temp.out' );
    }
}
