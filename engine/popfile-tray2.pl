#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# popfile-tray2.pl --- Message analyzer and sorter (Windows loader used with
#                                                   Win32::GUI)
#
# Acts as a server and client designed to sit between a real mail/news client
# and a real mail/news server using POP3.  Inserts an extra header
# X-Text-Classification: into the header to tell the client which category the
# message belongs in and much more...
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
use warnings;
use locale;
use lib defined( $ENV{POPFILE_ROOT} ) ? $ENV{POPFILE_ROOT} : '.';
use POPFile::Loader;

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

my $POPFile = POPFile::Loader->new();

# Indicate that we should create output on STDOUT (the POPFile
# load sequence) and initialize with the version

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

# UI Port and localhost name

my $h = $POPFile->get_module( 'UI::HTML' );
my $b = $POPFile->get_module( 'Classifier::Bayes' );
my $w = $POPFile->get_module( 'platform::windows' );
my $port = $h->config_( 'port' );
my $host = $b->config_( 'localhostname' ) || 'localhost';

my $ui_url = "http://$host:$port/";

# Start POPFile

$POPFile->CORE_start();

# Prepare tray icon

$w->prepare_trayicon();

# Main Loop

Win32::GUI::Dialog();

# Stop POPFile

$POPFile->CORE_stop();

exit 0;


# ----------------------------------------------------------------------------
#
# NI_Click
#
# Called by Win32::GUI when the user click on the Tray icon
#
# ----------------------------------------------------------------------------

sub NI_Click {

    # Show Download dialog if a new version of POPFile is available.

    if ( $w->{updated__} ) {
        $w->update_check_result( 1, 1, 0 );
    }

    return 1;
}

# ----------------------------------------------------------------------------
#
# NI_DblClick
#
# Called by Win32::GUI when the user double click on the Tray icon
#
# ----------------------------------------------------------------------------

sub NI_DblClick {
    # Open POPFile UI

    return Menu_Open_UI_Click();
}

# ----------------------------------------------------------------------------
#
# NI_RightClick
#
# Called by Win32::GUI when the user right click the Tray icon
#
# ----------------------------------------------------------------------------

sub NI_RightClick {
    # Track popup menu

    $w->track_popup_menu();
    return 1;
}

# ----------------------------------------------------------------------------
#
# Poll_Timer
#
# Called by Win32::GUI when the timer times out
#
# ----------------------------------------------------------------------------

sub Poll_Timer {
    # If CORE_service returns 0, exit Win32::GUI::Dialog() loop

    return $POPFile->CORE_service(1) ? 1 : -1;
}

# ----------------------------------------------------------------------------
#
# Event handler for Popup menu items
#
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
#
# Menu_Open_UI_Click
#
# Called by Win32::GUI when the user click 'POPFile UI' on the popup menu
#
# ----------------------------------------------------------------------------

sub Menu_Open_UI_Click {
    # Open POPFile UI url using Win32::GUI::ShellExecute

    $w->open_url( $ui_url );
    return 1;
}

# ----------------------------------------------------------------------------
#
# Menu_Quit_Click
#
# Called by Win32::GUI when the user click 'Quit POPFile' on the popup menu
#
# ----------------------------------------------------------------------------

sub Menu_Quit_Click {
    # Exit from Win32::GUI::Dialog() loop

    return -1;
}

# ----------------------------------------------------------------------------
#
# Menu_Open_PFHP_Click
#
# Called by Win32::GUI when the user click 'POPFile Official Web' on the popup
# menu
#
# ----------------------------------------------------------------------------

sub Menu_Open_PFHP_Click {
    # Open POPFile Official webpage url using Win32::GUI::ShellExecute

    $w->open_url( $w->{popfile_official_site__} );
    return 1;
}

# ----------------------------------------------------------------------------
#
# Menu_Update_Check_Click
#
# Called by Win32::GUI when the user click 'Update Check' on the popup menu
#
# ----------------------------------------------------------------------------

sub Menu_Update_Check_Click {
    # Check update

    my $updated = $w->{updated__} || $w->update_check( 10 );
    $w->update_check_result( $updated, 1, 0 );

    return 1;
}

# ----------------------------------------------------------------------------
#
# Menu_Download_Page_Click
#
# Called by Win32::GUI when the user click 'POPFile Download Page' on the
# popup menu
#
# ----------------------------------------------------------------------------

sub Menu_Download_Page_Click {
    # Open POPFile Download page url using Win32::GUI::ShellExecute

    $w->open_url( $w->{popfile_download_page__} );
    return 1;
}

1;
