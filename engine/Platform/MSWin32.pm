# POPFILE LOADABLE MODULE
package Platform::MSWin32;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile specifics on Windows
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
                                         'windows-trayicon-configuration.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'windows_console',
                                         'windows-console-configuration.thtml',
                                         $self );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            Name of this item
#    $templ           The loaded template that was passed as a parameter
#                     when registering
#    $language        Current language
#
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    if ( $name eq 'windows_trayicon' ) {
        $templ->param( 'windows_icon_on' => $self->config_( 'trayicon' ) );
    }

    if ( $name eq 'windows_console' ) {
        $templ->param( 'windows_console_on' => $self->config_( 'console' ) );
    }
}

# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    if ( $name eq 'windows_trayicon' ) {
        if ( defined($$form{windows_trayicon}) ) {
            $self->config_( 'trayicon', $$form{windows_trayicon} );
            $templ->param( 'feedback' => 1 );
        }
    }

    if ( $name eq 'windows_console' ) {
        if ( defined($$form{windows_console}) ) {
            $self->config_( 'console', $$form{windows_console} );
            $templ->param( 'feedback' => 1 );
        }
    }

   return '';
}

1;
