#----------------------------------------------------------------------------
#
# This module handles POPFile's logger.  It is used to save debugging 
# information to disk or to send it to the screen.
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#----------------------------------------------------------------------------
package POPFile::Logger;

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
    my $type = shift;
    my $self;

    # The name of the debug file
    $self->{debug_filename} = '';
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the interface
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # Start with debugging to file
    $self->{configuration}->{configuration}{debug} = 1;

    # The default location for log files
    $self->{configuration}->{configuration}{logdir} = './';

    calculate_today( $self );
    
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to start this module
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called to shutdown this module
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# service
#
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    remove_debug_files( $self );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# Called when someone forks POPFile
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# remove_debug_files
#
# Removes popfile log files that are older than 3 days
#
# ---------------------------------------------------------------------------------------------
sub remove_debug_files 
{
    my ( $self ) = @_;
    
    my $yesterday = defined($self->{today})?$self->{today}:0;
    calculate_today( $self );

    if ( $self->{today} > $yesterday ) {    
        my @debug_files = glob "$self->{configuration}->{configuration}{logdir}popfile*.log";

        foreach my $debug_file (@debug_files) {
            # Extract the epoch information from the popfile log file name
            if ( $debug_file =~ /popfile([0-9]+)\.log/ )  {
                # If older than now - 3 days then delete
                unlink($debug_file) if ( $1 < (time - 3 * $seconds_per_day) );
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# calculate_today - set the global $self->{today} variable to the current day in seconds
#
# ---------------------------------------------------------------------------------------------
sub calculate_today 
{
    my ( $self ) = @_;
    
    # Create the name of the debug file for the debug() function
    $self->{today} = int( time / $seconds_per_day ) * $seconds_per_day;
    $self->{debug_filename} = "$self->{configuration}->{configuration}{logdir}popfile$self->{today}.log";
}

# ---------------------------------------------------------------------------------------------
#
# debug
#
# $message    A string containing a debug message that may or may not be printed
#
# Prints the passed string if the global $debug is true
#
# ---------------------------------------------------------------------------------------------
sub debug 
{
    my ( $self, $message ) = @_;
    
    if ( $self->{configuration}->{configuration}{debug} > 0 ) {
        # Check to see if we are handling the USER/PASS command and if we are then obscure the
        # account information
        $message = "$`$1$3 XXXXXX$4" if ( $message =~ /((--)?)(USER|PASS)\s+\S*(\1)/ );
        chomp $message;
        $message .= "\n";

        my $now = localtime;
        my $msg = "$now ($$): $message";
        
        if ( $self->{configuration}->{configuration}{debug} & 1 )  {
            open DEBUG, ">>$self->{debug_filename}";
            binmode DEBUG;
            print DEBUG $msg;
            close DEBUG;
        }
        
        print $msg if ( $self->{configuration}->{configuration}{debug} & 2 );
    }
}

1;
