#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# popfile-service.pl --- Message analyzer and sorter (Windows loader used with PerlSvc)
#
# Acts as a server and client designed to sit between a real mail/news client and a real mail/
# news server using POP3.  Inserts an extra header X-Text-Classification: into the header to
# tell the client which category the message belongs in and much more...
#
# Copyright (c) 2003-2004 John Graham-Cumming
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

package PerlSvc;

use strict;
use locale;

use POPFile::Loader;

# This hash is used by PerlSvc for various parameters that we need
# to tell it about

our %Config;

$Config{ServiceName} = 'POPFile';
$Config{DisplayName} = 'POPFile Automatic Email Classifier';
$Config{UserName} = 'LocalSystem';

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

our $POPFile = POPFile::Loader->new();

# ----------------------------------------------------------------------------
#
# Startup
#
# Called when the service starts
#
# ----------------------------------------------------------------------------

sub Startup
{
    # Indicate that we should NOT create output on STDOUT (the POPFile
    # load sequence) and initialize with the version

    $POPFile->debug(0);
    $POPFile->CORE_loader_init();

    # Redefine POPFile's signals

    $POPFile->CORE_signals();

    # Create the main objects that form the core of POPFile.  Consists of the configuration
    # modules, the classifier, the UI (currently HTML based), platform specific code,
    # and the POP3 proxy.  The link the components together, intialize them all, load
    # the configuration from disk, start the modules running

    $POPFile->CORE_load();
    $POPFile->CORE_link_components();
    $POPFile->CORE_initialize();
    $POPFile->CORE_config();
    $POPFile->CORE_start();

    while ( ContinueRun(0.05) ) {
        if ( !$POPFile->CORE_service(1) ) {
            last;
        }
    }

    $POPFile->CORE_stop();
}

