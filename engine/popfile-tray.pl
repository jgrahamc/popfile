#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# popfile-tray.pl --- Message analyzer and sorter (Windows loader used with PerlTray)
#
# Acts as a server and client designed to sit between a real mail/news client and a real mail/
# news server using POP3.  Inserts an extra header X-Text-Classification: into the header to
# tell the client which category the message belongs in and much more...
#
# Copyright (c) 2001-2003 John Graham-Cumming
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
# ---------------------------------------------------------------------------------------------

use strict;
use locale;

use POPFile::Loader;

use PerlTray;

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

our $POPFile = POPFile::Loader->new();

# ---------------------------------------------------------------------------------------------
#
# PopupMenu
#
# Called by PerlTray when it needs the content of the popup menu
#
# ---------------------------------------------------------------------------------------------

sub PopupMenu
{
    my $url = 'http://127.0.0.1:' . $POPFile->module_config( 'html', 'port' );

    return [ [ "*POPFile UI", "Execute '$url'"          ],
             [ "--------"                               ],
             [ "Shutdown POPFile", \&popfile_shutdown   ] ];
}

# ---------------------------------------------------------------------------------------------
#
# ToolTip
#
# Called by PerlTray when it needs the to show a tool tip on the tray icon
#
# ---------------------------------------------------------------------------------------------

sub ToolTip
{
    return "POPFile";
}

# ---------------------------------------------------------------------------------------------
#
# Timer
#
# Called by PerlTray when the timer expires
#
# ---------------------------------------------------------------------------------------------

sub Timer
{
    SetTimer( 0 );

    if ( !$POPFile->CORE_service(1) ) {
        popfile_shutdown();
    }

    SetTimer( 50 );
}

# ---------------------------------------------------------------------------------------------
#
# popfile_shutdown
#
# Called by PerlTray when the user click Shutdown on the pop up menu
#
# ---------------------------------------------------------------------------------------------

sub popfile_shutdown
{
    $POPFile->CORE_stop();

    exit(0);
}

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

# We terminate here because that lets PerlTray start and it will call the Timer
# function above

Timer();

