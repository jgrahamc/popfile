#!/usr/bin/perl
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
# test_report	-	 Report whether a test passed or not
#
# $ok           Boolean indicating whether the test passed
# $test			String containing the test executed
# $file			The name of the file invoking the test
# $line			The line in the $file where the test can be found
# $context		(Optional) String containing extra context information
#
# ---------------------------------------------------------------------------------------------

sub test_report
{
	my ( $ok, $test, $file, $line, $context ) = @_;
	
 	$test_count += 1;
 	
 	if ( !$ok ) {
 		print "\nTest $test_count failed: $test at line $line of $file";
 		if ( defined( $context ) ) {
 			print " ($context)";
 		}
 		$test_failures += 1;
 	}
}

# ---------------------------------------------------------------------------------------------
#
# test_assert	-	 Perform a test and assert that its result must be true
#
# $file			The name of the file invoking the test
# $line			The line in the $file where the test can be found
# $test			String containing the test to be executed
# $context		(Optional) String containing extra context information
#
# Example: test_assert( 'function(parameter) == 1' ) YOU DO NOT NEED TO GIVE THE
# $file and $line parameters as this script supplies them automatically
#
# ---------------------------------------------------------------------------------------------

sub test_assert
{
	my ( $file, $line,  $test, $context ) = @_;
	
	test_report( eval( $test ), $test, $file, $line );
}

# ---------------------------------------------------------------------------------------------
#
# test_assert_equal	-	 Perform a test and assert that its result is equal an expected result
#
# $file			The name of the file invoking the test
# $line			The line in the $file where the test can be found
# $test			The result of the test that was just run
# $expected		The expected result
# $context		(Optional) String containing extra context information
#
# Example: test_assert_equal( function(parameter), 'result' )
# Example: test_assert_equal( function(parameter), 3, 'Banana wumpus subsystem' )
#
# YOU DO NOT NEED TO GIVE THE $file and $line parameters as this script supplies them 
# automatically
# ---------------------------------------------------------------------------------------------

sub test_assert_equal
{
	my ( $file, $line, $test, $expected, $context ) = @_;
	my $result;

	if ( $expected =~ /[^0-9]/ ) {
	
		# This int() and is so that we don't get bitten by odd
		# floating point problems
		my $scale = 1e10;	
		$result = ( int( $test * $scale ) == int( $expected * $scale ) );
	} else {	
		$result = ( $test eq $expected );
	}

	test_report( $result, "expecting $expected and got $test", $file, $line );
}

# MAIN

my @tests = glob 'tests/*.tst';

foreach my $test (@tests) {

	# This works by reading the entire suite into the $suite variable
	# and then changing calls to test_assert_equal so that they include 
	# the line number and the file they are from, then the $suite is 
	# evaluated
	
	print "\nRunning $test...";
	my $suite;
	my $ln   = 0;
	open SUITE, "<$test";
	while (<SUITE>) {
		my $line = $_;
		$ln += 1;
		$line =~ s/(test_assert_equal\()/$1 '$test', $ln,/g;
		$line =~ s/(test_assert\()/$1 '$test', $ln,/g;
		$suite .= $line;
	}
	close SUITE;
	eval $suite;
}

print "\n$test_count tests, $test_failures failed\n\n";