# POPFILE LOADABLE MODULE
package POPFile::Logger;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile's logger.  It is used to save debugging 
# information to disk or to send it to the screen.
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

    bless($self, $class);

    $self->name( 'logger' );

    return $self;
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
    $self->global_config_( 'debug', 1 );

    # The default location for log files
    $self->config_( 'logdir', './' );

    remove_debug_files( $self );

    return 1;
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
# remove_debug_files
#
# Removes popfile log files that are older than 3 days
#
# ---------------------------------------------------------------------------------------------
sub remove_debug_files 
{
    my ( $self ) = @_;

    my $yesterday = defined($self->{today__})?$self->{today__}:0;
    calculate_today__( $self );

    if ( $self->{today__} > $yesterday ) {
        my @debug_files = glob( $self->config_( 'logdir' ) . 'popfile*.log' );

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
sub calculate_today__
{
    my ( $self ) = @_;

    # Create the name of the debug file for the debug() function
    $self->{today__} = int( time / $seconds_per_day ) * $seconds_per_day;
    $self->{debug_filename__} = $self->config_( 'logdir' ) . "popfile$self->{today__}.log";
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

    if ( $self->global_config_( 'debug' ) > 0 ) {
        # Check to see if we are handling the USER/PASS command and if we are then obscure the
        # account information
        $message = "$`$1$3 XXXXXX$4" if ( $message =~ /((--)?)(USER|PASS)\s+\S*(\1)/ );
        chomp $message;
        $message .= "\n";

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime;
        $year += 1900;
        my $msg = "$year/$mon/$mday $hour:$min:$sec $$: $message";

        if ( $self->global_config_( 'debug' ) & 1 )  {
            open DEBUG, ">>$self->{debug_filename__}";
            binmode DEBUG;
            print DEBUG $msg;
            close DEBUG;
        }

        print $msg if ( $self->global_config_( 'debug' ) & 2 );
    }
}

# GETTERS/SETTERS

sub debug_filename
{
    my ( $self ) = @_;

    return $self->{debug_filename__};
}

1;
