#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# make_packing_list.pl
#
# Builds the POPFile packing list of required modules
#
# Copyright (c) 2001-2004 John Graham-Cumming
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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ----------------------------------------------------------------------------

use strict;

# Hash that maps a module name (e.g. Foo::Bar) to either REQUIRED
# or optional.  A module is REQUIRED if it is in a use statement and
# OPTIONAL if it is in a require.

my %modules;

# ARGV should contain the name of the packing list to generate
# followed by a list of files to search for use statements.

my $output = shift @ARGV;

foreach my $file (@ARGV) {
    scan_file( $file );
}

open PACKAGE, ">$output";
foreach my $module (sort keys %modules) {
    if ( $module !~ /^Classifier|POPFile|Proxy/ ) {
        print PACKAGE "$modules{$module}\t0.0.0\t$module\n";
    }
}
close PACKAGE;

# ---------------------------------------------------------------------------
#
# scan_file
#
# Look in a file for require and use statements and update the %modules
# hash
#
# ---------------------------------------------------------------------------
sub scan_file
{
    my ( $file ) = @_;

    if ( open FILE, "<$file" ) {
        while ( <FILE> ) {
            if ( /^[ \t]*require[ \t]+([^ \t]+::[^ \t\r\n;]+)/ ) {
                $modules{$1} = 'OPTIONAL-TODO';
                next;
            }
            if ( /^[ \t]*use[ \t]+([^ \t]+::[^ \t\r\n;]+)/ ) {
                $modules{$1} = 'REQUIRED';
                next;
            }
        }
        close FILE;
    }
}

