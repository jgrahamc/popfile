# ---------------------------------------------------------------------------------------------
#
# tests.pl  - Unit tests for POPFile
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

# Look for all the TST files in the tests/ subfolder and run
# each of them by including them in this file with the use statement

# This is the total number of tests executed and the total failures

my $test_count    = 0;
my $test_failures = 0;

# ---------------------------------------------------------------------------------------------
#
# test_assert	-	 Report whether a test passed or not
#
# $ok           Boolean indicating whether the test passed
# $test			String containing the test executed
#
# ---------------------------------------------------------------------------------------------

sub test_report
{
	my ( $ok, $test ) = @_;
	
 	$test_count += 1;
 	
 	if ( !$ok ) {
 		print "\nTest $test_count failed: $test";
 		$test_failures += 1;
 	} else {
 		print '.';
 	}
}

# ---------------------------------------------------------------------------------------------
#
# test_assert	-	 Perform a test and assert that its result must be true
#
# $test			String containing the test to be executed
#
# Example: test_assert( 'function(parameter) == 1' )
#
# ---------------------------------------------------------------------------------------------

sub test_assert
{
	my ( $test ) = @_;
	
	test_report( eval( $test ), $test );
}

# ---------------------------------------------------------------------------------------------
#
# test_assert_equal	-	 Perform a test and assert that its result is equal an expected result
#
# $test			The result of the test that was just run
# $expected		The expected result
#
# Example: test_assert_equal( function(parameter), 'result' )
# Example: test_assert_equal( function(parameter), 3 )
#
# ---------------------------------------------------------------------------------------------

sub test_assert_equal
{
	my ( $test, $expected ) = @_;
	my $result;

	if ( $expected =~ /[^0-9]/ ) {
		$result = ( $test == $expected );
	} else {	
		$result = ( $test eq $expected );
	}

	test_report( $result, "expecting $expected and got $test" );
}

# MAIN

my @tests = glob 'tests/*.tst';

foreach my $test (@tests) {
	print "\nRunning $test...";
	require $test;
}

print "\n$test_count tests, $test_failures failed\n\n";