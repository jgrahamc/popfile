#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# popfile-windows.pl --- Message analyzer and sorter (Windows loader)
#
# Figures out which is four executables to run based on windows options
#
# popfileif.exe       Run POPFile in foreground with a tray icon
# popfileib.exe       Run POPFile in background with a tray icon
# popfilef.exe        Run POPFile in the foreground
# popfileb.exe        Run POPFile in the background
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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

use strict;
use locale;
use lib defined( $ENV{POPFILE_ROOT} ) ? $ENV{POPFILE_ROOT} : '.';
use POPFile::Loader;

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

my $POPFile = POPFile::Loader->new();

# Load the minimal amount of POPFile to get reliable access to the
# configuration options and then figure out which popfileXX.exe to run

$POPFile->CORE_loader_init();

# Redefine POPFile's signals

$POPFile->CORE_signals();

# Create the main objects that form the core of POPFile.  Consists of the
# configuration modules, the classifier, the UI (currently HTML based),
# platform specific code, and the POP3 proxy.  The link the components
# together, intialize them all, load the configuration from disk, start the
# modules running

$POPFile->CORE_load();
$POPFile->CORE_initialize();
$POPFile->CORE_config();

my $w = $POPFile->get_module( 'platform::windows' );

my $i = $w->config_( 'trayicon' )?'i':'';
my $f = $w->config_( 'console' )?'f':'b';

# Take into account the possible setting of POPFILE_ROOT to 
# find the other EXEs

my $root = defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';   

if ( $root !~ /[\/\\]$/ ) {
    $root .= '/';
}

my $popfile_exe = $root . "popfile$i$f.exe";

exec $popfile_exe, @ARGV;
