#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# pipe.pl --- Read a message in on STDIN and write out the modified version on STDOUT
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
# ----------------------------------------------------------------------------

use strict;
use lib defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';
use POPFile::Loader;

# main

if ( $#ARGV == -1 ) {

    # POPFile is actually loaded by the POPFile::Loader object which does all
    # the work

    my $POPFile = POPFile::Loader->new();

    # Indicate that we should create not output on STDOUT (the POPFile
    # load sequence)

    $POPFile->debug(0);
    $POPFile->CORE_loader_init();
    $POPFile->CORE_signals();
    $POPFile->CORE_load( 1 );
    $POPFile->CORE_initialize();

    # Ugly hack which is needed because Bayes::classify_and_modify looks up
    # the UI port and whether we are allowing remote connections or not
    # to set the XPL link in the header.  If we don't have these predefined
    # then they'll be discarded when the configuration is loaded, and since
    # we are not loading the UI, they are not defined at this point

    my $c = $POPFile->get_module('POPFile::Config');
    $c->module_config_( 'html', 'local', 1 );
    $c->module_config_( 'html', 'port',  8080 );

    if ( $POPFile->CORE_config() ) {

        # Prevent the tool from finding another copy of POPFile running

        $c->config_( 'piddir', $c->config_( 'piddir' ) . 'pipe.pl.' );

        # TODO: interface violation
        $c->{save_needed__} = 0;

        $POPFile->CORE_start();

        my $b = $POPFile->get_module('Classifier::Bayes');
        my $session = $b->get_session_key( 'admin', '' );

        $b->classify_and_modify( $session, \*STDIN, \*STDOUT, 1, '', 0, 1, "\n" );
        $b->release_session_key( $session );
        $POPFile->CORE_stop();
    }

    exit 0;
} else {
    print "pipe.pl - reads a message on STDIN, classifies it, outputs the modified version on STDOUT\n\n";
    print "Usage: pipe.pl\n";

    exit 1;
}
