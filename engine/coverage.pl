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

foreach my $file (sort @line_files) {

    # Each LNE has a file name of ModuleName.PID.lne and the ModuleName has had
    # / or :: converted to #

    $file =~ /^(.+)\.pm\.(-?\d+)\.lne$/;

    my $module = $1;
    my $pid    = $2;

    $module =~ s/-/\//g;

    open SOURCE_FILE, "<../$module.pm";
    open LINE_DATA, "<$file";

    my $current_line = 0;

    while ( <SOURCE_FILE> ) {
        $current_line += 1;

   	my $state = <LINE_DATA>;

        if ( $state =~ /1/ ) {
            $count{$module}{executed}{$current_line} = 1;
        } elsif ( $state =~ /0/ ) {
	    if ( $count{$module}{executed}{$current_line} != 1 ) {
                $count{$module}{executed}{$current_line} = 0;
	    }
        }
    }

    close LINE_DATA;
    close SOURCE_FILE;

    unlink $file;
}

foreach my $module ( keys( %count ) )
{
    my $total_executed     = 0;
    my $total_not_executed = 0;

    foreach my $line ( keys %{$count{$module}{executed}} ) {
        if ($count{$module}{executed}{$line} == 1) {
            $total_executed += 1;
	} else {
            $total_not_executed += 1;
        }
    }

    $files{$module} = int(100 * $total_executed / ( $total_executed + $total_not_executed ));
}


foreach my $file (sort {$files{$b} <=> $files{$a}} keys %files) {

    my $clean = $file;
    $clean =~ s/^\.\.\/\///;

    print sprintf( "Coverage of %-32s %d%%\n", "$clean...", $files{$file});
}

print "\nCreating HTML coverage files...\n\n";

foreach my $file (sort {$files{$b} <=> $files{$a}} keys %files) {

    my $clean = $file;
    $clean    =~ s/^\.\.\/\///;

    open HTML, ">../$clean.html";
    open FILE, "<../$clean.pm";

    print HTML "<html><head><title>$clean.pm</title></head><body><pre>";

    my $line = 0;

    while ( <FILE> ) {
        $line += 1;
        my $color = (defined($count{$file}{executed}{$line}) && ($count{$file}{executed}{$line}==0))?"red":"green";
        my $block = ($color eq 'red')?"red":"white";
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
        print HTML "<font color=$color>";
        my $length = 5 - length("$line");
        while ( $length > 0 ) {
             print HTML " ";
             $length -= 1;
	}
        print HTML "$line </font>";
        print HTML "<span style=\"background: $block\">&nbsp;</span><font color=$color>$_</font>";
    }

    print HTML "</pre></body></html>";

    close FILE;
    close HTML;

    print "Saved coverage view for $clean.pm in $clean.html\n";
}

