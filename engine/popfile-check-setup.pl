#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# popfile-check-setup.pl
#
# Checks whether the modules specified in the file popfile.pck are
# installed.
#
# Copyright (c) 2005 John Graham-Cumming
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
# ----------------------------------------------------------------------------


my $packing_list = defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';
$packing_list =~ s/[\\\/]$//;
$packing_list .= '/popfile.pck';

my $fatal = 0;

if ( open PACKING, "<$packing_list" ) {
    while (<PACKING>) {
        if ( /^(REQUIRED|OPTIONAL-([^\t]+))\t([^\t]+)\t([^\r\n]+)/ ) {
            my ( $required, $why, $version, $module ) = ( $1, $2, $3, $4 );

            # Find the module and set $ver to the loaded version, or -1 if
            # the module was not found

            local $::SIG{__DIE__};
            local $::SIG{__WARN__};
            eval "require $module";
            my $ver = ${"${module}::VERSION"} || ${"${module}::Version"} || 0;
            $ver = ${"${module}::VERSION"} || ${"${module}::Version"} || 0;
            $ver = -1 if $@;

            if ( $ver eq '-1' ) {
                if ( $required eq 'REQUIRED' ) {
                    $fatal = 1;
                    print STDERR "ERROR: POPFile needs Perl module $module, please install it.\n";
                } else {
                    print STDERR "WARNING: POPFile may require Perl module $module; it is needed for \"$why\".\n";
                }
            }
        }
    }
    close PACKING;
} else {
    print STDERR "WARNING: Couldn't open POPFile packing list ($packing_list) so cannot check configuration\n";
}
