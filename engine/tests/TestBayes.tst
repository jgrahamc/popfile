# ---------------------------------------------------------------------------------------------
#
# Tests for Bayes.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use Classifier::Bayes;

my $b = new Classifier::Bayes;
# $b->initialize();

# getting and setting values
test_assert_equal( $b->get_value( 'bucket', 'foo' ), 0 );
$b->{total}{bucket} = 100;
$b->set_value( 'bucket', 'foo', 100 );
test_assert_equal( $b->get_value( 'bucket', 'foo' ), 0 );
$b->{total}{bucket} = 1000;
$b->set_value( 'bucket', 'foo', 100 );
test_assert_equal( $b->get_value( 'bucket', 'foo' ), -log(10) );

