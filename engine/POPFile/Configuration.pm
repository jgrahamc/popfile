# POPFILE LOADABLE MODULE
package POPFile::Configuration;

use POPFile::Module;
@ISA = ( "POPFile::Module" );

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
    my $self = POPFile::Module->new();

    # All the current configuration parameters are stored in this hash which
    # is intended to be globally accessed by modules that make use of this module, 
    # to register a configuration default entries are made in this hash in the form
    #
    # $self->{configuration_parameters__}{parameter}
    $self->{configuration_parameters__} = {};

    bless $self, $type;

    $self->name( 'config' );

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

    # This is the location where we store the PID of POPFile in a file
    # called popfile.pid

    $self->config_( 'piddir', './' );

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

    if ( open PID, '>' . $self->config_( 'piddir' ) . 'popfile.pid' ) {
        print PID "$$\n"; 
        close PID;
    }

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

    unlink( $self->config_( 'piddir' ) . 'popfile.pid' );
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
                if ( defined($self->{configuration_parameters__}{$1}) ) {
                    if ( $i < $#ARGV ) {
                        $self->{configuration_parameters__}{$1} = $ARGV[$i+1];
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
                $self->{configuration_parameters__}{$1} = $2;
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
        foreach my $key (keys %{$self->{configuration_parameters__}}) {
            print CONFIG "$key $self->{configuration_parameters__}{$key}\n";
        }

        close CONFIG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# parameter
#
# Gets or sets a parameter
#
# $name          Name of the parameter to get or set
# $value         Optional value to set the parameter to
#
# Always returns the current value of the parameter
#
# ---------------------------------------------------------------------------------------------
sub parameter
{
  my ( $self, $name, $value ) = @_;

  if ( defined( $value ) ) {
    $self->{configuration_parameters__}{$name} = $value;
  }

  return $self->{configuration_parameters__}{$name};
}

1;
