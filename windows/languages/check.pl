#----------------------------------------------------------------------------
#
# check.pl
#
# Checks language files for inconsistency against the English-pfi.nsh
# file.  Run check.pl and it will report missing, extraneous, not translated
# entries in all the *-pfi.nsh files present
#
# Copyright (c) 2003 John Graham-Cumming
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
#----------------------------------------------------------------------------

# The English-pfi.nsh file is loaded into this hash since it is
# the definitive version and is used to check against the other
# languages

my %english;

# ---------------------------------------------------------------------------------------------
#
# load_language - Load a language file into a hash
#
# $file           The msg file to load
# $hash           Reference to hash to store the values in
#
# ---------------------------------------------------------------------------------------------

sub load_language
{
    my ( $file, $hash ) = @_;

    if ( open LANG, "<$file" ) {
        while ( <LANG> ) {
            next if ( /^[ \t]*#/ );

            if ( /^!insertmacro PFI_LANG_STRING ([^ \t]+)[ \t]+"(.+)"/ ) {
                my $id  = $1;
                my $msg = $2;
                $msg =~ s/[\r\n]//g;

                $$hash{$id} = $msg;
            }
        }

        close LANG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# check_language - Verify that a language file is consistent with the English version
#
# $file           The language to check against English
#
# ---------------------------------------------------------------------------------------------

sub check_language
{
    my ( $file ) = @_;

    print "\nChecking language $file...\n";

    my %lang;

    load_language( $file, \%lang );

    # First check to see if there are any entries in the English hash
    # that are not present in the lang hash

    foreach my $key (sort keys %english) {
        if ( !defined( $lang{$key} ) ) {
            print "MISSING: $key\n";
        }
    }

    # Now check for keys that we don't need any more

    foreach my $key (sort keys %lang) {
        if ( !defined( $english{$key} ) ) {
            print "DEPRECATED: $key\n";
        }
    }

    # Now check for keys that are not translated

    if ($file ne 'English-pfi.nsh') {
        foreach my $key (sort keys %lang) {
            if ( $lang{$key} eq $english{$key} ) {
                print "NOT TRANSLATED: $key\n";
            }
        }
    }
}

# MAIN

load_language( 'English-pfi.nsh', \%english );

my @nshs;

if ( $ARGV[0] ne '' ) {
    @nshs = ( $ARGV[0] );
} else {
    @nshs = glob "*-pfi.nsh";
}

foreach $nsh (@nshs) {
   check_language( $nsh );
}
