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
my $last_spin     = '';
my $last_symbol   = 0;

# ---------------------------------------------------------------------------------------------
#
# clear_spin - Clear the last spinner drawn with spin
#
# ---------------------------------------------------------------------------------------------

sub clear_spin
{
    for my $i (1..length($last_spin)) {
        print "\b";
    }
}

# ---------------------------------------------------------------------------------------------
#
# spin - Output a simple spinner on the screen with a message after it
#
# $msg                  The message to output
#
# ---------------------------------------------------------------------------------------------

sub spin
{
    my ( $msg ) = @_;

    $msg = '' unless ( defined($msg) );

    my @symbols = ('-','/','|','\\');

    clear_spin();

    print $symbols[$last_symbol % 4] . " " . $msg;

    $last_symbol++;

    $last_spin = "  " . $msg;
}

# ---------------------------------------------------------------------------------------------
#
# test_report__   -        Report whether a test passed or not
#
# $ok                   Boolean indicating whether the test passed
# $test                 String containing the test executed
# $context              (Optional) String containing extra context information
#
# DON'T call this from inside a test script, call one of the other test_assert functions
#
# ---------------------------------------------------------------------------------------------

sub test_report__
{
    my ( $ok, $test, $context ) = @_;

    # The actual tests were included using the 'do' statement and test_report__
    # has been called from at least one other test_X function, so we need to
    # get the stack frame one level up from where we are now (i.e. the caller of
    # our caller).

    my ( $package, $file, $line ) = caller(4);  

    spin( $line );

    $test_count += 1;

    if ( !$ok ) {
        $fail_messages .= "\n    $file:$line failed '$test'";
        if ( defined( $context ) ) {
            $fail_messages .= " ($context)";
        }
        $test_failures += 1;
#        print "Test fail at $file:$line ($test) ($context)\n";
    } else {
#       print "Test pass at $file:$line ($test) ($context)\n";
    }

    flush STDOUT;
}

# ---------------------------------------------------------------------------------------------
#
# test_assert   -        Perform a test and assert that its result must be true
#
# $test                 String containing the test to be executed
# $context              (Optional) String containing extra context information
#
# Example: test_assert( 'function(parameter) == 1' ) YOU DO NOT NEED TO GIVE THE
# $file and $line parameters as this script supplies them automatically
#
# ---------------------------------------------------------------------------------------------

sub test_assert
{
    my ( $test, $context ) = @_;

    test_report__( eval( $test ), $test, $context );
}

# ---------------------------------------------------------------------------------------------
#
# test_assert_equal     -        Perform a test and assert that its result is equal an expected result
#
# $test                 The result of the test that was just run
# $expected             The expected result
# $context              (Optional) String containing extra context information
#
# Example: test_assert_equal( function(parameter), 'result' )
# Example: test_assert_equal( function(parameter), 3, 'Banana wumpus subsystem' )
#
# ---------------------------------------------------------------------------------------------

sub test_assert_equal
{
    my ( $test, $expected, $context ) = @_;
    my $result;

    $test = '' unless (defined($test));
    $expected = '' unless (defined($expected));

    if ( !( $expected =~ /[^0-9]/ ) && !( $test =~ /[^0-9]/ )) {

        # This int() and is so that we don't get bitten by odd
        # floating point problems

        my $scale = 1e10;
        $result = ( int( $test * $scale ) == int( $expected * $scale ) );
    } else {
        $result = ( $test eq $expected );
    }

    test_report__( $result, "expecting [$expected] and got [$test]", $context );
}

# ---------------------------------------------------------------------------------------------
#
# test_assert_regexp    -  Perform a test and assert that its result matches a regexp
# test_assert_not_regexp - Perform a test and assert that the regexp does not match
#
# $test                 The result of the test that was just run
# $expected             The expected result in the form of a regexp
# $context              (Optional) String containing extra context information
#
# Example: test_assert_regexp( function(parameter), '^result' )
# Example: test_assert_regexp( function(parameter), 3, 'Banana.+subsystem' )
# ---------------------------------------------------------------------------------------------

sub test_assert_regexp
{
    my ( $test, $expected, $context ) = @_;
    my $result = ( $test =~ /$expected/m );

    test_report__( $result, "expecting to match [$expected] and got [$test]", $context );
}

sub test_assert_not_regexp
{
    my ( $test, $expected, $context ) = @_;
    my $result = !( $test =~ /$expected/m );

    test_report__( $result, "unexpected match of [$expected]", $context );
}

# MAIN

my @tests = sort { $b cmp $a } glob '*.tst';

# Either match all the possible tests, or take the first argument
# on the command line and use it as a regular expression that must
# match the name of the TST file for the test suite in that file
# to be run

my @patterns= ( '.*' );
@patterns = split( /,/, $ARGV[0] ) if ( $#ARGV == 0 );

my $code = 0;

foreach my $test (@tests) {

    my $runit = 0;

    foreach my $pattern (@patterns) {
        if ( $test =~ /$pattern/ ) {
            $runit = 1;
            last;
	  }
     }

     if ( $runit ) {
        my $current_test_count  = $test_count;
        my $current_error_count = $test_failures;

        print "\nRunning $test... at line: ";
        flush STDOUT;
        $fail_messages = '';
        my $ran = do $test;

        clear_spin();

        if ( !defined( $ran ) ) {
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
