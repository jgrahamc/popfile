# POPFILE LOADABLE MODULE 4
package Platform::MSWin32;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile specifics on Windows
#
# Copyright (c) 2001-2009 John Graham-Cumming
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
#----------------------------------------------------------------------------

use strict;
use warnings;
use locale;

use Win32::GUI qw(MB_OKCANCEL MB_OK MB_ICONASTERISK MB_ICONSTOP IDOK);

# Make Win32::GUI thread-safe

sub Win32::GUI::CLONE_SKIP {1};
sub Win32::GUI::Timer::CLONE_SKIP {1};
sub Win32::GUI::NotifyIcon::CLONE_SKIP {1};

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

    # Status of the system tray icon
    #    0 ... Disabled
    #    1 ... Enabled

    $self->{use_tray_icon__} = 0;

    # Interval for checking updates (seconds)
    #    60 * 60 * 24 = 1 day

    $self->{update_check_interval__} = 60 *60 * 24;

    # Time to check updates

    $self->{next_update_check__} = 0;

    # Whether new version of POPFile is available
    #    0 ... POPFile is up to date
    #    1 ... A new version of POPFile is available

    $self->{updated__} = 0;

    # Constants

    $self->{popfile_official_site__} = 'http://getpopfile.org/';
    $self->{popfile_download_page__} = 'http://getpopfile.org/download';
    $self->{update_check_url__} = 'http://getpopfile.org/downloads/current_release.txt';

    $self->{trayicon_filename__} = 'trayicon.ico';
    $self->{trayicon_updated_filename__} = 'trayicon_up.ico';

    $self->{update_check_dialog_title__}  = 'POPFile Update Check';
    $self->{new_version_available_text__} = 'A new version of POPFile is available.';
    $self->{open_download_page_text__}    = 'Open download page?';
    $self->{popfile_is_up_to_date_text__} = 'POPFile is up to date.';
    $self->{failed_to_check_text__}       = 'Failed to check updates.';

    return $self;
}

# ----------------------------------------------------------------------------
#
# initialize
#
# Called when we are are being set up but before starting
#
# ----------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    $self->config_( 'trayicon', 1 );
    $self->config_( 'console',  0 );

    return 1;
}

# ----------------------------------------------------------------------------
#
# start
#
# Called when all configuration information has been loaded from disk.
#
# The method should return 1 to indicate that it started correctly, if
# it returns 0 then POPFile will abort loading immediately, returns 2
# if everything OK but this module does not want to continue to be
# used.
#
# ----------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    $self->register_configuration_item_( 'configuration',
                                         'windows_trayicon_and_console',
                                         'windows-configuration.thtml',
                                         $self );

    # Now try to cleanup a mess that PerlApp/PerlTray might have left
    # behind in the $TEMP.  For some reason even though we build with
    # --clean it leaves behind empty directories in the TEMP directory
    # in the form $TEMP/pdk-USER-PID
    #
    # We try to delete everything that is in that form but does not have 
    # our PID

    my $pdk = $ENV{TEMP} . "/pdk-" . Win32::LoginName() . "-*";
    $pdk =~ s/ /?/g;

    my @temp = glob $pdk;

    foreach my $dir (@temp) {
        if ( $dir =~ /pdk\-.+\-(\d+)$/ ) {
            if ( $$ != $1 ) {
                rmdir $dir;
            }
        }
    }

    return $self->SUPER::start();
}

#----------------------------------------------------------------------------
#
# service
#
# Called periodically to check POPFile updates
#
#----------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    if ( $self->{use_tray_icon__} &&
         $self->user_module_config_( 1, 'html', 'update_check' ) &&
         ( time >= $self->{next_update_check__} ) ) {
        $self->{next_update_check__} = time + $self->{update_check_interval__};
        $self->user_module_config_( 1, 'html', 'last_update_check', time );

        if ( my $updated = ( $self->{updated__} || $self->update_check( 1 ) ) ) {
            $self->update_check_result( $updated, 0, 1 );
        }
    }

    return 1;
}

# ----------------------------------------------------------------------------
#
# prepare_trayicon
#
# Create a dummy window, a trayicon and a menu, and then set a timer to the
# window.
#
# ----------------------------------------------------------------------------
sub prepare_trayicon
{
    my $self = shift;

    $self->{use_tray_icon__} = 1;

    # Create a dummy window

    $self->{trayicon_window} = Win32::GUI::Window->new();
    if ( !defined( $self->{trayicon_window} ) ) {
        $self->log_( 0, "Couldn't create a window for the trayicon" );
        die "Couldn't create a window for the trayicon.";
    }

    # Create a trayicon

    my $icon = Win32::GUI::Icon->new(
        $self->get_root_path_( ( $self->{updated__} ?
                                 $self->{trayicon_updated_filename__} :
                                 $self->{trayicon_filename__} ) ) );

    $self->{trayicon} = $self->{trayicon_window}->AddNotifyIcon(
        -name => 'NI',
        -icon => $icon,
        -tip  => 'POPFile'
    );
    if ( !defined( $self->{trayicon} ) ) {
        $self->log_( 0, "Couldn't create a trayicon" );
    }

    # Set timer

    $self->{trayicon_window}->AddTimer( 'Poll', 250 );
}

# ----------------------------------------------------------------------------
#
# dispose_trayicon
#
# Dispose dummy window and trayicon
#
# ----------------------------------------------------------------------------
sub dispose_trayicon
{
    my ( $self ) = @_;

    if ( defined( $self->{trayicon_window} ) ) {

        # Stop timer

        if ( defined( $self->{trayicon_window}->Poll ) ) {
            $self->{trayicon_window}->Poll->Kill( 1 );
        }

        # Remove trayicon

        if ( defined( $self->{trayicon} ) ) {
            if ( $Win32::GUI::VERSION >= 1.04 ) {
                $self->{trayicon}->Remove();
            } else {
                $self->{trayicon}->Delete( -id => $self->{trayicon}->{-id} );
            }
        }

        undef $self->{trayicon};
        undef $self->{trayicon_window};
        undef $self->{trayicon_menu};
    }
}

# ----------------------------------------------------------------------------
#
# track_popup_menu
#
# Handle popup menu on the tray icon
#
# ----------------------------------------------------------------------------
sub track_popup_menu
{
    my $self = shift;

    # Create a popup menu

    $self->{trayicon_menu} = Win32::GUI::Menu->new(
        '&POPFile'                  => 'POPFile',
        ( $self->{updated__} ? (
            '> Open &Download Page' => { -name => 'Menu_Download_Page' },
            '> -'                   => 0, ) : () ),
        '> &Support'                => 0,
        '>> POPFile Official &Web'  => { -name => 'Menu_Open_PFHP' },
        '>> &Update Check'          => { -name => 'Menu_Update_Check' },
        '> -'                       => 0,
        '> POPFile &UI'             => { -name => 'Menu_Open_UI', -default => 1 },
        '> -'                       => 0,
        '> &Quit POPFile'           => { -name => 'Menu_Quit' },
    );
    if ( !defined( $self->{trayicon_menu} ) ) {
        $self->log_( 0, "Couldn't create a popup menu for the trayicon" );
    }

    $self->{trayicon_window}->TrackPopupMenu(
            $self->{trayicon_menu}->{POPFile},
            Win32::GUI::GetCursorPos() );
}

# ----------------------------------------------------------------------------
#
# update_check
#
# Check if new version of POPFile is available
#
#    $timeout        Seconds to timeout for checking updates.
#
# ----------------------------------------------------------------------------
sub update_check
{
    my ( $self ) = shift;
    my ( $timeout ) = shift || 10;

    use LWP::UserAgent;

    my ( $major_version, $minor_version, $build_version ) =
        $self->version() =~ /^v(\d+)\.(\d+)\.(\d+)$/;

    my $ua = LWP::UserAgent->new;
    $ua->timeout( $timeout );
    $ua->env_proxy;
    $ua->agent( 'POPFile/' . $self->version() );

    my $response = $ua->get( $self->{update_check_url__} );
    my $latest_release;

    $self->{next_update_check__} = time + $self->{update_check_interval__};
    $self->user_module_config_( 1, 'html', 'last_update_check' , time );

    if ( $response->is_success &&
         ( $latest_release = $response->content ) &&
         ( $latest_release =~ /^(\d+)[.](\d+)[.](\d+)$/m ) ) {

        my ( $latest_ma, $latest_mi, $latest_bu ) = ( $1, $2, $3 );

        my $cmp;
        $cmp = ( $latest_ma <=> $major_version ) * 4 +
               ( $latest_mi <=> $minor_version ) * 2 +
               ( $latest_bu <=> $build_version );

        my $updated = ( $cmp > 0 );

        $self->{updated__} = $updated;

        return $updated;
    } else {
        $self->log_( 0, "Failed to check updates: " . $response->status_line );

        return -1;
    }
}

# ----------------------------------------------------------------------------
#
# update_check_result
#
# Show result of checking updates
#
#    $updated        1 : New version of POPFile is available
#                    0 : POPFile is up to date
#                   -1 : Failed to check updates
#    $show_dialog    1 : Show update check result dialog
#    $show_balloon   1 : Show balloon tips
#
# ----------------------------------------------------------------------------
sub update_check_result
{
    my ( $self, $updated, $show_dialog, $show_balloon ) = @_;

    $self->{updated__} = ( $updated == 1 );

    if ( $show_dialog ) {
        if ( $self->{updated__} ) {
            # Found updates.

            my $result = Win32::GUI::MessageBox(
                $self->{trayicon_window},
                $self->{new_version_available_text__} . "\n" .
                    $self->{open_download_page_text__},
                $self->{update_check_dialog_title__},
                Win32::GUI::Constants::MB_OKCANCEL |
                    Win32::GUI::Constants::MB_ICONASTERISK
            );

            if ( $result eq Win32::GUI::Constants::IDOK ) {
                $self->open_url( $self->{popfile_download_page__} );
            }
        } else {
            if ( $updated == 0 ) {
                # POPFile is up to date.

                Win32::GUI::MessageBox(
                    $self->{trayicon_window},
                    $self->{popfile_is_up_to_date_text__},
                    $self->{update_check_dialog_title__},
                    Win32::GUI::Constants::MB_OK |
                        Win32::GUI::Constants::MB_ICONASTERISK
                );
            } else {
                # Failed to check updates.

                Win32::GUI::MessageBox(
                    $self->{trayicon_window},
                    $self->{failed_to_check_text__},
                    $self->{update_check_dialog_title__},
                    Win32::GUI::Constants::MB_OK |
                        Win32::GUI::Constants::MB_ICONSTOP
                );
            }
        }
    }

    if ( $self->{updated__} ) {
        # Change icon

        my $updated_icon = Win32::GUI::Icon->new(
            $self->get_root_path_( $self->{trayicon_updated_filename__} ) );

            $self->{trayicon}->Change(
                -balloon_tip     => $self->{new_version_available_text__},
                -balloon_timeout => 100,
                -balloon_icon    => 'none',
                -icon            => $updated_icon,
            );

        if ( $show_balloon ) {
            # Show balloon

            $self->{trayicon}->ShowBalloon(1);
        }
    }
}

# ----------------------------------------------------------------------------
#
# open_url
#
# Open specified URL with the default browser
#
#    $url             URL to open
#
# ----------------------------------------------------------------------------

sub open_url
{
    my ( $self, $url ) = @_;

    Win32::GUI::ShellExecute( 0, '', $url, '', '', 1 );
}

# ----------------------------------------------------------------------------
#
# configure_item
#
#    $name            Name of this item
#    $templ           The loaded template that was passed as a parameter
#                     when registering
#    $language        Current language
#
# ----------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    if ( $name eq 'windows_trayicon_and_console' ) {
        $templ->param( 'windows_icon_on' => $self->config_( 'trayicon' ) );
        $templ->param( 'windows_console_on' => $self->config_( 'console' ) );
    }
}

# ----------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ----------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    my ( $status_message );

    if ( $name eq 'windows_trayicon_and_console' ) {

        if ( defined( $$form{update_windows_configuration} ) ) {
            if ( $$form{windows_trayicon} ) {
                $self->config_( 'trayicon', 1 );
            } else {
                $self->config_( 'trayicon', 0 );
            }

            if ( $$form{windows_console} ) {
                $self->config_( 'console', 1 );
            } else {
                $self->config_( 'console', 0 );
            }

            $status_message = $$language{Windows_NextTime};
        }
    }

   return ( $status_message, undef );
}

1;
