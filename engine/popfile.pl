#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# popfile.pl --- Message analyzer and sorter
#
# Acts as a server and client designed to sit between a real mail/news
# client and a real mail/ news server using POP3.  Inserts an extra
# header X-Text-Classification: into the header to tell the client
# which category the message belongs in and much more...
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

# Check the packing list of POPFile to ensure that all the required
# modules are present.

my $packing_list = defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';
$packing_list =~ s/[\\\/]$//;
$packing_list .= '/popfile.pck';

my $fatal = 0;
my $log = '';

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
                    $log .= "WARNING: POPFile may require Perl module $module; it is needed for \"$why\".\n";
                }
            }
        }
    }
    close PACKING;
} else {
    $log .= "WARNING: Couldn't open POPFile packing list ($packing_list) so cannot check configuration\n";
}

use strict;
use locale;
use lib defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';
use POPFile::Loader;

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

my $POPFile = POPFile::Loader->new();

$POPFile->CORE_loader_init();

# Redefine POPFile's signals

$POPFile->CORE_signals();

# Create the main objects that form the core of POPFile.  Consists of
# the configuration modules, the classifier, the UI (currently HTML
# based), platform specific code, and the POP3 proxy.  The link the
# components together, intialize them all, load the configuration from
# disk, start the modules running

$POPFile->CORE_load();
$POPFile->CORE_initialize();
if ( $POPFile->CORE_config() ) {
    $POPFile->CORE_start();

    # If there were any log messages from the packing list check then
    # log them now

    if ( $log ne '' ) {
        $POPFile->get_module( 'POPFile::Logger' )->debug( 0, $log );
    }

    # This is the main POPFile loop that services requests, it will
    # exit only when we need to exit

    $POPFile->CORE_service();

    # Shutdown every POPFile module

    $POPFile->CORE_stop();
}

# END
