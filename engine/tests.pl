#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# tests.pl  - Unit tests for POPFile
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
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
# ---------------------------------------------------------------------------------------------

use strict;

require IO::Handle;

# Look for all the TST files in the tests/ subfolder and run
# each of them by including them in this file with the use statement

# This is the total number of tests executed and the total failures

my $test_count    = 0;
my $test_failures = 0;
my $fail_messages = '';

# ---------------------------------------------------------------------------------------------
#
# test_report   -        Report whether a test passed or not
#
# $ok           Boolean indicating whether the test passed
# $test                 String containing the test executed
# $file                 The name of the file invoking the test
# $line                 The line in the $file where the test can be found
# $context              (Optional) String containing extra context information
#
# ---------------------------------------------------------------------------------------------

sub test_report
{
        my ( $ok, $test, $file, $line, $context ) = @_;
        
        $test_count += 1;
        
        if ( !$ok ) {
                $fail_messages .= "\n    $file:$line failed '$test'";
                if ( defined( $context ) ) {
                        $fail_messages .= " ($context)";
                }
                $test_failures += 1;
#            print "Test fail at $file:$line\n";
        } else {
#            print "Test pass at $file:$line\n";
        }
        
        flush STDOUT;
}

# ---------------------------------------------------------------------------------------------
#
# test_assert   -        Perform a test and assert that its result must be true
#
# $file                 The name of the file invoking the test
# $line                 The line in the $file where the test can be found
# $test                 String containing the test to be executed
# $context              (Optional) String containing extra context information
#
# Example: test_assert( 'function(parameter) == 1' ) YOU DO NOT NEED TO GIVE THE
# $file and $line parameters as this script supplies them automatically
#
# ---------------------------------------------------------------------------------------------

sub test_assert
{
        my ( $file, $line,  $test, $context ) = @_;
        
        test_report( eval( $test ), $test, $file, $line, $context );
}

# ---------------------------------------------------------------------------------------------
#
# test_assert_equal     -        Perform a test and assert that its result is equal an expected result
#
# $file                 The name of the file invoking the test
# $line                 The line in the $file where the test can be found
# $test                 The result of the test that was just run
# $expected             The expected result
# $context              (Optional) String containing extra context information
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

        if ( !( $expected =~ /[^0-9]/ ) ) {
        
                # This int() and is so that we don't get bitten by odd
                # floating point problems
                my $scale = 1e10;       
                $result = ( int( $test * $scale ) == int( $expected * $scale ) );
        } else {        
                $result = ( $test eq $expected );
        }

        test_report( $result, "expecting [$expected] and got [$test]", $file, $line, $context );
}

# ---------------------------------------------------------------------------------------------
#
# test_assert_regexp    -  Perform a test and assert that its result matches a regexp
# test_assert_not_regexp - Perform a test and assert that the regexp does not match
#
# $file                 The name of the file invoking the test
# $line                 The line in the $file where the test can be found
# $test                 The result of the test that was just run
# $expected             The expected result in the form of a regexp
# $context              (Optional) String containing extra context information
#
# Example: test_assert_regexp( function(parameter), '^result' )
# Example: test_assert_regexp( function(parameter), 3, 'Banana.+subsystem' )
#
# YOU DO NOT NEED TO GIVE THE $file and $line parameters as this script supplies them
# automatically
# ---------------------------------------------------------------------------------------------

sub test_assert_regexp
{
    my ( $file, $line, $test, $expected, $context ) = @_;
    my $result = ( $test =~ /$expected/m );

    test_report( $result, "expecting to match [$expected] and got [$test]", $file, $line, $context );
}

sub test_assert_not_regexp
{
    my ( $file, $line, $test, $expected, $context ) = @_;
    my $result = !( $test =~ /$expected/m );

    test_report( $result, "unexpected to match of [$expected]", $file, $line, $context );
}

# MAIN

my @tests = glob '*.tst';

# Either match all the possible tests, or take the first argument
# on the command line and use it as a regular expression that must
# match the name of the TST file for the test suite in that file
# to be run

my $pattern = '.*';
$pattern = "$ARGV[0].*" if ( $#ARGV == 0 );

my $code = 0;

foreach my $test (@tests) {

    if ( $test =~ /$pattern/ ) {

        # This works by reading the entire suite into the $suite variable
        # and then changing calls to test_assert_equal so that they include
        # the line number and the file they are from, then the $suite is
        # evaluated
        my $current_test_count  = $test_count;
        my $current_error_count = $test_failures;
        
        print "\nRunning $test... ";
        flush STDOUT;
        $fail_messages = '';
        my $suite;
        my $ln   = 0;
        open SUITE, "<$test";
        while (<SUITE>) {
                my $line = $_;
                $ln += 1;
                $line =~ s/(test_assert_not_regexp\()/$1 '$test', $ln,/g;
                $line =~ s/(test_assert_regexp\()/$1 '$test', $ln,/g;
                $line =~ s/(test_assert_equal\()/$1 '$test', $ln,/g;
                $line =~ s/(test_assert\()/$1 '$test', $ln,/g;
                $suite .= $line;
        }
        close SUITE;
        if ( !defined( eval $suite ) ) {
            print "Error in $test: $@";
            $code = 1;
        }
        
        if ( $test_failures > $current_error_count ) {
                print "failed (" . ( $test_count - $current_test_count ) . " ok, " . ( $test_failures - $current_error_count ) . " failed)\n";
                print $fail_messages . "\n";
                $code = 1;
        } else {
                print "ok (" . ( $test_count - $current_test_count ) . " ok)";
        }
    }
}

print "\n\n$test_count tests, " . ( $test_count - $test_failures ) . " ok, $test_failures failed\n\n";
exit $code;
