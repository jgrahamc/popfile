# ---------------------------------------------------------------------------------------------
#
# Tests for Bayes.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use Classifier::Bayes;
use POPFile::Configuration;

# Load the test corpus
my $c = new POPFile::Configuration;
my $b = new Classifier::Bayes;
$b->{configuration} = $c;
$b->initialize();
$b->{configuration}->{configuration}{corpus} = 'tests/corpus';
$b->start();

# getting and setting values
test_assert_equal( $b->get_value( 'personal', 'foo' ), log(1/103) );
$b->{total}{personal} = 100;
$b->set_value( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value( 'personal', 'foo' ), 0 );
$b->{total}{personal} = 1000;
$b->set_value( 'personal', 'foo', 100 );
test_assert_equal( $b->get_value( 'personal', 'foo' ), -log(10) );

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
    
    test_assert_equal( $b->classify_file( $class_test ), $class, $class_test );
}

# glob the tests directory for files called TestMailParse\d+.msg which consist of messages 
# to be sent through classify_and_modify

$b->{configuration}->{configuration}{msgdir}  = 'tests/';
$b->{configuration}->{configuration}{ui_port} = '8080';
$b->{configuration}->{configuration}{xtc} = 1;
$b->{configuration}->{configuration}{xpl} = 1;
$b->{configuration}->{configuration}{localpop} = 1;
$b->{configuration}->{configuration}{subject} = 1;
$b->{parameters}{spam}{subject} = 1;

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
			test_assert_equal( $cam_line, $output_line, $modify_file );
		}
		
		close CAM;
		close OUTPUT;
		unlink( 'tests/popfile0=0.msg' );
		unlink( 'tests/popfile0=0.cls' );
		unlink( 'tests/temp.out' );
    }
}
