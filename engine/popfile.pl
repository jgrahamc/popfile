#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# popfile.pl --- Message analyzer and sorter
#
# Acts as a server and client designed to sit between a real mail/news client and a real mail
# news server using POP3.  Inserts an extra header X-Text-Classification: into the header to
# tell the client which category the message belongs in.
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;
use POPFile::Loader;

#
#
# MAIN
#
#

my $POPFile = POPFile::Loader->new();

$POPFile->debug(1);

$POPFile->CORE_loader_init();

my ( $major_version, $minor_version, $build_version ) = ( 0, 20, 0 );

$POPFile->CORE_version($major_version, $minor_version, $build_version);

# Redefine POPFile's signals

$POPFile->CORE_signals();

# Create the main objects that form the core of POPFile.  Consists of the configuration
# modules, the classifier, the UI (currently HTML based), platform specific code,
# and the POP3 proxy.

$POPFile->CORE_load();

# Make sure each component knows about all the components it needs to know about

$POPFile->CORE_link_components();

# Initialize everything

$POPFile->CORE_initialize();

# Handle configuration options

$POPFile->CORE_config();

# Start each module

$POPFile->CORE_start();

# MAIN

$POPFile->CORE_service();

# cleanup

$POPFile->CORE_stop();
# ---------------------------------------------------------------------------------------------
