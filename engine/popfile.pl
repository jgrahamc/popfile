#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# popfile.pl --- Message analyzer and sorter
#
# Acts as a server and client designed to sit between a real mail/news client and a real mail/
# news server using POP3.  Inserts an extra header X-Text-Classification: into the header to
# tell the client which category the message belongs in and much more...
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;

use POPFile::Loader;

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

my $POPFile = POPFile::Loader->new();

# Indicate that we should create output on STDOUT (the POPFile
# load sequence) and initialize with the version

$POPFile->debug(1);
$POPFile->CORE_loader_init();
$POPFile->CORE_version(0, 20, 0);

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

# This is the main POPFile loop that services requests, it will exit only when we
# need to exit

$POPFile->CORE_service();

# Shutdown every POPFile module

$POPFile->CORE_stop();

# END
