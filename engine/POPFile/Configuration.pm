#----------------------------------------------------------------------------
#
# This module handles POPFile's configuration parameters.  It is used to
# load and save from the popfile.cfg file and individual POPFile modules
# register specific parameters with this module.  This module also handles
# POPFile's command line parsing
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#----------------------------------------------------------------------------
package POPFile::Configuration;

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
    my $self;
    
    # All the current configuration parameters are stored in this hash which
    # is intended to be globally accessed by modules that make use of this module, 
    # to register a configuration default entries are made in this hash in the form
    #
    # $self->{configuration}{parameter}
    $self->{configuration} = {};
    
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
# parse_command_line - Parse ARGV
#
# The arguments are the keys of the configuration hash.  Any argument that is not already
# defined in the hash generates an error, there must be an even number of ARGV elements because
# each command argument has to have a value.
#
# ---------------------------------------------------------------------------------------------
sub parse_command_line  
{
    my ( $self ) = @_;

    # It's ok for the command line to be blank, the values of configuration will be drawn from
    # the default values defined at the start of the code and those read from the configuration
    # file
    
    if ( $#ARGV >= 0 )  {
        my $i = 0;
        
        while ( $i < $#ARGV )  {
            # A command line argument must start with a -
            
            if ( $ARGV[$i] =~ /^-(.+)$/ ) {
                if ( defined($self->{configuration}{$1}) ) {
                    if ( $i < $#ARGV ) {
                        $self->{configuration}{$1} = $ARGV[$i+1];
                        $i += 2;
                    } else {
                        print "Missing argument for $ARGV[$i]\n";
                        last;
                    }
                } else {
                    print "Unknown command line option $ARGV[$i]\n";
                    last;
                }
            } else {
                print "Expected a command line option and got $ARGV[$i]\n";
                last;
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_configuration
#
# Loads the current configuration of popfile into the configuration hash from a local file.  
# The format is a very simple set of lines containing a space separated name and value pair
#
# ---------------------------------------------------------------------------------------------
sub load_configuration 
{
    my ( $self ) = @_;
    
    if ( open CONFIG, "<popfile.cfg" ) {
        while ( <CONFIG> ) {
            s/(\015|\012)//g; 
            if ( /(\S+) (.+)/ ) {
                $self->{configuration}{$1} = $2;
            }
        }
        
        close CONFIG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# save_configuration
#
# Saves the current configuration of popfile from the configuration hash to a local file.
#
# ---------------------------------------------------------------------------------------------
sub save_configuration 
{
    my ( $self ) = @_;

    if ( open CONFIG, ">popfile.cfg" ) {
        foreach my $key (keys %{$self->{configuration}}) {
            print CONFIG "$key $self->{configuration}{$key}\n";
        }
        
        close CONFIG;
    }

    # TODO work out where this actually needs to be called
    # $classifier->write_parameters();
}

1;
