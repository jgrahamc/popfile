# POPFILE LOADABLE MODULE
package Platform::MSWin32;

use POPFile::Module;
@ISA = ("POPFile::Module");

use Win32::API;

#----------------------------------------------------------------------------
#
# This module handles POPFile specifics on Windows
#
# Copyright (c) 2001-2003 John Graham-Cumming
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
# prefork
#
# Called when a fork is about to occur
#
# ---------------------------------------------------------------------------------------------
sub prefork
{
    my ( $self ) = @_;

    # If the fork occurs and the DLL handling the icon is still present then
    # there's going to be a problem because the DLL will get unloaded and we'll
    # still have a pointer into it, so here we unload the DLL, it will get reloaded
    # automatically later

    undef $self->{getmessage__};
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# Called to handle interface requests
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    if ( !defined( $self->{getmessage__} ) ) {
        $self->{getmessage__} = Win32::API->new( "Platform/POPFileIcon.dll", "int GetMenuMessage()" );
    }

    my $event = $self->{getmessage__}->Call();

    # Double click icon, or select Open option in menu results in
    # navigating to the UI

    if ( $event == 2 ) {

        # Get the port that the UI is running on and then use the
        # windows start function to start the browser running

        my $url = 'http://127.0.0.1:' . $self->module_config_( 'html', 'port' );

        system( "start $url" );
    }

    # Exit action from try context menu - return 0, to cause exit

    if ( $event == 1 ) {
         return 0;
    }

    return 1;
}

1;
