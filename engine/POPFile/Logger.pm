# POPFILE LOADABLE MODULE 1
package POPFile::Logger;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile's logger.  It is used to save debugging
# information to disk or to send it to the screen.
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

# Constant used by the log rotation code
my $seconds_per_day = 60 * 60 * 24;

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

    # The name of the debug file

    $self->{debug_filename__} = '';

    # The last ten lines sent to the logger

    $self->{last_ten__} = ();

    $self->{initialize_called__} = 0;

    bless($self, $class);

    $self->name( 'logger' );

    return $self;
}

#----------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the interface
#
# ---------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    $self->{initialize_called__} = 1;

    # Start with debugging to file

    $self->global_config_( 'debug', 1 );

    # The default location for log files

    $self->config_( 'logdir', './' );

    # The output format for log files, can be default, tabbed or csv

    $self->config_( 'format', 'default' );

    # The log level.  There are three levels of log:
    #
    # 0   Critical log messages
    # 1   Verbose logging
    # 2   Maximum verbosity

    $self->config_( 'level', 0 );

    $self->{last_tickd__} = time;

    $self->mq_register_( 'TICKD', $self );

    return 1;
}

# ---------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, @message ) = @_;

    # If a day has passed then clean up log files

    if ( $type eq 'TICKD' ) {
        $self->remove_debug_files();
    }
}

#----------------------------------------------------------------------------
#
# start
#
# Called to start the logger running
#
#----------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    $self->calculate_today__();

    return 1;
}

# ---------------------------------------------------------------------------
#
# service
#
# ---------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    $self->calculate_today__();

    # We send out a TICKD message every hour so that other modules
    # can do clean up tasks that need to be done regularly but not
    # often

    if ( time > ( $self->{last_tickd__} + 3600 ) ) {
        $self->mq_post_( 'TICKD' );
        $self->{last_tickd__} = time;
    }

    return 1;
}

# ---------------------------------------------------------------------------
#
# calculate_today
#
# Set the global $self->{today} variable to the current day in seconds
#
# ---------------------------------------------------------------------------
sub calculate_today__
{
    my ( $self ) = @_;

    # Create the name of the debug file for the debug() function
    $self->{today__} = int( time / $seconds_per_day ) * $seconds_per_day;

    # Note that 0 parameter than allows the logdir to be outside the user
    # sandbox

    $self->{debug_filename__} = $self->get_user_path_(
        $self->config_( 'logdir' ) . "popfile$self->{today__}.log", 0 );
}

# ---------------------------------------------------------------------------
#
# remove_debug_files
#
# Removes popfile log files that are older than 3 days
#
# ---------------------------------------------------------------------------
sub remove_debug_files
{
    my ( $self ) = @_;

    my @debug_files = glob( $self->get_user_path_(
                          $self->config_( 'logdir' ) . 'popfile*.log', 0 ) );

    foreach my $debug_file (@debug_files) {
        # Extract the epoch information from the popfile log file name
        if ( $debug_file =~ /popfile([0-9]+)\.log/ )  {
            # If older than now - 3 days then delete
            unlink($debug_file) if ( $1 < (time - 3 * $seconds_per_day) );
        }
    }
}

# ----------------------------------------------------------------------------
#
# debug
#
# $level      The level of this message
# $message    A string containing a debug message that may or may not be 
#             printed
#
# Prints the passed string if the global $debug is true
#
# ----------------------------------------------------------------------------
sub debug
{
    my ( $self, $level, $message ) = @_;

    if ( $self->{initialize_called__} == 0 ) {
        return;
    }

    if ( $level > $self->config_( 'level' ) ) {
        return;
    }

    if ( $self->{debug_filename__} eq '' ) {
        return;
    }

    if ( $self->global_config_( 'debug' ) > 0 ) {

        # Check to see if we are handling the USER/PASS command and if
        # we are then obscure the account information

        if ( $message =~ /((--)?)(USER|PASS)\s+\S*(\1)/i ) {
            $message = "$`$1$3 XXXXXX$4";
        }

        $message =~ s/([\x00-\x1f])/sprintf("[%2.2x]", ord($1))/eg;

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
            localtime;
        $year += 1900;
        $mon  += 1;

        $min  = "0$min"  if ( $min  < 10 );
        $hour = "0$hour" if ( $hour < 10 );
        $sec  = "0$sec"  if ( $sec  < 10 );

        my $delim = ' ';
        $delim = "\t" if ( $self->config_( 'format' ) eq 'tabbed' );
        $delim = ',' if ( $self->config_( 'format' ) eq 'csv' );

        my $msg =
            "$year/$mon/$mday$delim$hour:$min:$sec$delim$$:$delim$message\n";

        if ( $self->global_config_( 'debug' ) & 1 )  {
              if ( open DEBUG, ">>$self->{debug_filename__}" ) {
                print DEBUG $msg;
                close DEBUG;
            }
        }

        print $msg if ( $self->global_config_( 'debug' ) & 2 );

        # Add the line to the in memory collection of the last ten
        # logger entries and then remove the first one if we now have
        # more than 10

        push @{$self->{last_ten__}}, ($msg);

        if ( $#{$self->{last_ten__}} > 9 ) {
            shift @{$self->{last_ten__}};
        }
    }
}

# GETTERS/SETTERS

sub debug_filename
{
    my ( $self ) = @_;

    return $self->{debug_filename__};
}

sub last_ten
{
    my ( $self ) = @_;

    if ( $#{$self->{last_ten__}} >= 0 ) {
        return @{$self->{last_ten__}};
    } else {
        my @temp = ( 'log empty' );
        return @temp;
    }
}

1;
