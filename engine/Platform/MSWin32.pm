# POPFILE LOADABLE MODULE
package Platform::MSWin32;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile specifics on Windows
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
#----------------------------------------------------------------------------

use strict;
use warnings;
use locale;

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $class = ref($type) || $type;
    my $self = POPFile::Module->new();

    bless $self, $type;

    $self->name( 'windows' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called when we are are being set up but before starting
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    $self->config_( 'trayicon', 1 );
    $self->config_( 'console',  0 );

    $self->register_configuration_item_( 'configuration',
                                         'windows_trayicon',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'windows_console',
                                         $self );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $session_key     The current session key
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $language, $session_key ) = @_;

    my $body;

    # Tray icon widget
    if ( $name eq 'windows_trayicon' ) {
        $body .= "<span class=\"configurationLabel\">$$language{Windows_TrayIcon}:</span><br />\n";
        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";

        if ( $self->config_( 'trayicon' ) == 0 ) {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{No}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowTrayIconOn\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"windows_trayicon\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowTrayIconOff\" name=\"toggle\" value=\"$$language{ChangeToNo}\" />\n";
            $body .= "<input type=\"hidden\" name=\"windows_trayicon\" value=\"0\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        }
        $body .= "</td></tr></table>\n";
    }

    if ( $name eq 'windows_console' ) {
        $body .= "<span class=\"configurationLabel\">$$language{Windows_Console}:</span><br />\n";
        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";

        if ( $self->config_( 'console' ) == 0 ) {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{No}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowConsoleOn\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"windows_console\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowConsoleOff\" name=\"toggle\" value=\"$$language{ChangeToNo}\" />\n";
            $body .= "<input type=\"hidden\" name=\"windows_console\" value=\"0\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        }
        $body .= "</td></tr></table>\n";
    }

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $form            Hash containing all form items
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $language, $form ) = @_;

    if ( $name eq 'windows_trayicon' ) {
        if ( defined($$form{windows_trayicon}) ) {
            $self->config_( 'trayicon', $$form{windows_trayicon} );
            return $$language{Windows_NextTime};
        }
    }

    if ( $name eq 'windows_console' ) {
        if ( defined($$form{windows_console}) ) {
            $self->config_( 'console', $$form{windows_console} );
            return $$language{Windows_NextTime};
        }
    }

   return '';
}

1;
