#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# coverage.pl - Calculate coverage data from LNE files
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;

# This hash will store a count of the number of times each line is executed # in each file,
# it is in fact a hash of hashes used as
# $count{filename}{linenumber}

my %count;

# This hash will map file names of POPFile modules to coverage
my %files;

# Now look for LNE files containing code coverage information

my @line_files = glob '*.lne';

foreach my $file (@line_files) {

    # Each LNE has a file name of ModuleName.PID.lne and the ModuleName has had
    # / or :: converted to #

    $file =~ /^(.+)\.pm\.(-?\d+)\.lne$/;

    my $module = $1;
    my $pid    = $2;

    $module =~ s/-/\//g;

    open SOURCE_FILE, "<../$module.pm";
    open LINE_DATA, "<$file";
    #$module = $file;

    my $current_line = 0;
    $count{$module}{executed} = [];


    $count{$module}{total_executable_lines} = 0;
    $count{$module}{total_lines} = 0;

    while ( <SOURCE_FILE> ) {
        # Keep count of the total number of lines in this file

        $current_line                += 1;
        $count{$module}{total_lines} += 1;

   	my $state = <LINE_DATA>;

        if ( $state =~ /1/ ) {
            $count{$module}{total_executable_lines} += 1;
            $count{$module}{executed}[$current_line] = 1;
        } elsif ( $state =~ /0/ ) {
            $count{$module}{total_executable_lines} += 1;
        } else {
        }
    }

    close LINE_DATA;
    close SOURCE_FILE;

    unlink $file;
}

foreach my $module ( keys( %count ) )
{
    my $total_executed = 0;
    foreach my $line ( 0 .. $#{$count{$module}{executed}} ) {
        $total_executed++ if ($count{$module}{executed}[$line]);
    }

    $files{$module} = int(100 * $total_executed / $count{$module}{total_executable_lines}) unless ( $count{$module}{total_executable_lines} == 0 );
}


foreach my $file (sort {$files{$b} <=> $files{$a}} keys %files) {

    my $clean = $file;
    $clean =~ s/^\.\.\/\///;

    print sprintf( "Coverage of %-32s %d%%\n", "$clean...", $files{$file});
}

