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
    	close CLASS;
    }
    
    test_assert_equal( $b->classify_file( $class_test ), $class, $class_test );
}
