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

# This queue contains events that have been activated by using the
# tray icon, menu or by the associated timer.

my @event_queue;

# These constants are the valid events

my $EVENT_LEFT_DBLCLICK = 1;
my $EVENT_RIGHT_CLICK   = 2;
my $EVENT_MENU_OPEN     = 3;
my $EVENT_MENU_SHUTDOWN = 4;

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

    $self->{windows__} = {};
    $self->{windows__}->{window} = undef;  # Win32::GUI handle to the main window object
    $self->{windows__}->{icon}   = undef;  # Win32::GUI handle to the icon
    $self->{windows__}->{menu}   = undef;  # Win32::GUI handle tray icon context menu

    bless $self, $type;

    $self->name( 'windows' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called when the interface must shutdown
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    # Remove the tray icon
    # Shouldn't need to do this, as the class destructor should do it for us.
    # but it seems to be needed

    if ( defined( $self->{windows__}->{window} ) ) {
        Win32::GUI::NotifyIcon::Delete( $self->{windows__}->{window}, -id => 1 );
    }
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

    # You may be wondering why I do this here and not in an overriden start()
    # method, unfortunately if we do that then POPFile's perl process can fault
    # almost at once because any events that the icon receives before we are
    # calling DoEvents on a regular basis get queued up and eventually the 
    # process faults

    if ( !defined( $self->{windows__}->{window} ) ) {
        $self->{windows__}->{icon} = new Win32::GUI::Icon('popfile.ico');

        # Define our main window - although we'll never show it

        $self->{windows__}->{window} = Win32::GUI::Window->new
           ( -title   => 'POPFile',
             -name    => 'Platform::MSWin32::_window' );

        # Put the icon into the systray

        $self->{windows__}->{window}->AddNotifyIcon
            ( -icon => $self->{windows__}->{icon},
              -id   => 1,
              -name => 'Platform::MSWin32::_systray',
              -tip  => 'POPFile');

        # Build the hash for the menu:

        my $menu  = '"trayMenu Functions"     => "trayMenu",';
           $menu .= '"> Open POPFile UI"      => { -name => "Platform::MSWin32::_trayMenuOpen", -default => 1 },';
           $menu .= '"> -"                    => 0,';
           $menu .= '"> Shutdown POPFile"     => { -name => "Platform::MSWin32::_trayMenuShutdown" },';

        #  Define the menu that we'll use in the systray
        $menu = 'Win32::GUI::Menu->new( '.$menu.')';
        $self->{windows__}->{menu} = eval $menu;

	return 1;
    }

    my $rval = 1;

    # (1) Check and process all the outstanding Windows events

    Win32::GUI::DoEvents();

    # (2) Process the events that have happened

    return $self->processEvents();
}

# ---------------------------------------------------------------------------------------------
# Helper methods
# ---------------------------------------------------------------------------------------------

  # ---------------------------------------------------------------------------------------------
  #
  # navigate
  #
  # Called to open a web browser to POPFile UI page
  #
  # ---------------------------------------------------------------------------------------------

  sub navigate
  {
      my ( $self ) = @_;

      # Get the port that the UI is running on and then use the
      # windows start function to start the browser running

      my $url = 'http://127.0.0.1:' . $self->module_config_( 'html', 'port' );

      system( "start $url" );
  }

  # ---------------------------------------------------------------------------------------------
  #
  # processEvents()
  #
  # takes specific action, depending on windows event that happened
  #
  # ---------------------------------------------------------------------------------------------
  sub processEvents
  {
      my ( $self ) = @_;
      my $rval = 1;

      # Remove all events from the queue and process them in FIFO order
      # Note that we use PUSH and SHIFT to implement the FIFO buffer

      while ( $#event_queue >= 0 ) {
          my $event = shift @event_queue;

          # right click on tray icon - show context menu

          if ( $event == $EVENT_RIGHT_CLICK ) {

              # get the x and y coords of the mouse to display the menu at.

              my ( $x, $y ) = Win32::GUI::GetCursorPos();

              # make the popup menu visible at the cursor
              # Unfortunately this blocks while the popup menu is displayed
              # (Although it seems that timer events still happen, so it's presumably implementing its own
              # message loop)
              # Also appears to have problems (returns error) once we have performed a fork!

              $self->{windows__}->{window}->TrackPopupMenu( $self->{windows__}->{menu}->{trayMenu}, $x, $y );
          }

          # Double click icon, or select Open option in menu results in 
          # navigating to the UI

          if ( ( $event == $EVENT_MENU_OPEN ) || ( $event == $EVENT_LEFT_DBLCLICK ) ) {
              $self->navigate();
          }

          # Exit action from try context menu - return 0, to cause exit

          if ( $event == $EVENT_MENU_SHUTDOWN ) {
              $rval = 0;
          }
      }

      return $rval;
  }

# ---------------------------------------------------------------------------------------------
# Event Handler functions: all start with _, and are for use by the GUI.  They should
#                          not be called externally.
# ---------------------------------------------------------------------------------------------

  # ---------------------------------------------------------------------------------------------
  # SysTray Icon Event Handler functions:
  # ---------------------------------------------------------------------------------------------

    # ---------------------------------------------------------------------------------------------
    #
    # _systray_RightClick
    #
    # Callback from systray icon right click
    #
    # ---------------------------------------------------------------------------------------------
    sub _systray_RightClick
    {
        push @event_queue, ($EVENT_RIGHT_CLICK);
        return 1;
    }

    # ---------------------------------------------------------------------------------------------
    #
    # _systray_MouseEvent
    #
    # Callback from systray icon for all mouse events
    #
    # ---------------------------------------------------------------------------------------------
    sub _systray_MouseEvent
    {
        my $event = shift;
        # event is one of seven: 512 => 'Mouse Move', 514 => 'Left Click',
        # 515 => 'Left DoubleClick', 517 => 'Right Click', 518 =>
        # 'Right DoubleClick',519 => 'Middle Down', and 520 => 'Middle Up'.

        if ( $event == 515 ) {
            push @event_queue, ($EVENT_LEFT_DBLCLICK);
        }

        return 1;
    }

  # ---------------------------------------------------------------------------------------------
  # Tray Icon Menu Event Handler functions:
  # ---------------------------------------------------------------------------------------------

    # ---------------------------------------------------------------------------------------------
    #
    # _trayMenuOpen_Click
    #
    # Callback from systray menu
    #
    # ---------------------------------------------------------------------------------------------
    sub _trayMenuOpen_Click
    {
        push @event_queue, ($EVENT_MENU_OPEN);
        return 1;
    }

    # ---------------------------------------------------------------------------------------------
    #
    # _trayMenuExit_Click
    #
    # Callback from systray menu
    #
    # ---------------------------------------------------------------------------------------------
    sub _trayMenuShutdown_Click
    {
        push @event_queue, ($EVENT_MENU_SHUTDOWN);
        return 1;
    }

1;
