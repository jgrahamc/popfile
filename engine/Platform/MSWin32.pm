# POPFILE LOADABLE MODULE
package Platform::MSWin32;

use POPFile::Module;
@ISA = ("POPFile::Module");

use Win32::GUI;

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
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = POPFile::Module->new();

    bless($self, $class);

    $self->name( 'platform' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# service
#
#    Give Windows a chance to process messages about the tray icon
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    Win32::GUI::DoEvents();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Add an icon to the system tray
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    $self->{window__}  = Win32::GUI::Window->new(
                            -name   => 'traywindow',
                            -text   => 'POPFile',
                            -width  => 200,
                            -height => 200 );
    $self->{icon__}    = new Win32::GUI::Icon('popfile.ico');
    $self->{notify__}  = $self->{window__}->AddNotifyIcon(
                            -name => "NI",
                            -id   => 1,
                            -icon => $self->{icon__},
                            -tip  => "POPFile running; right click icon to terminate" );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Remove the tray icon
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    $self->{window__}->NI->Delete( -id => 1 );
    Win32::GUI::DoEvents();
}

# ---------------------------------------------------------------------------------------------
#
# NI_RightClick Called when someone right clicks on the tray icon.  When this happens we
#               display the menu that contains the single option "Exit"
#
# ---------------------------------------------------------------------------------------------

sub NI_RightClick
{
    1;
}

1;
