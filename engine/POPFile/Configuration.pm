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

    # This counter is used when creating unique IDs for message stored
    # in the history.  The history message files have the format
    #
    # popfile{download_count}={message_count}.msg
    #
    # Where the download_count is derived from this value and the
    # message_count is a local counter within that download, for sorting
    # purposes must sort on download_count and then message_count

    $self->global_config_( 'download_count', 0 );

    # Subject modification (global setting is on)
    $self->global_config_( 'subject', 1 );

    # Adding the X-Text-Classification on
    $self->global_config_( 'xtc', 1 );

    # Adding the X-POPFile-Link is no
    $self->global_config_( 'xpl', 1 );

    # The default location for the message files
    $self->global_config_( 'msgdir', 'messages/' );

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
	        my $parameter = $self->upgrade_parameter__($1);
                if ( defined($self->{configuration_parameters__}{$parameter}) ) {
                    if ( $i < $#ARGV ) {
                        $self->{configuration_parameters__}{$parameter} = $ARGV[$i+1];
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
# upgrade_parameter__
#
# Given a parameter from either command line or from the configuration file return the
# upgraded version (e.g. the old port parameter becomes pop3_port
#
# ---------------------------------------------------------------------------------------------

sub upgrade_parameter__
{
    my ( $self, $parameter ) = @_;

    # This table maps from the old parameter to the new one, for example the old
    # xpl parameter which controls insertion of the X-POPFile-Link header in email
    # is now called GLOBAL_xpl and is accessed through POPFile::Module::global_config_
    # The old piddir parameter is now config_piddir and is accessed through either config_
    # if accessed from the config module or through module_config_ from outside

    my %upgrades = ( 

		     # Parameters that are now handled by Classifier::Bayes

		     'corpus',                   'bayes_corpus corpus',
		     'unclassified_probability', 'bayes_unclassified_probability',

		     # Parameters that are now handled by POPFile::Configuration

		     'piddir',                   'config_piddir',

		     # Parameters that are now global to POPFile

		     'debug',                    'GLOBAL_debug',
		     'ecount',                   'GLOBAL_ecount',
		     'mcount',                   'GLOBAL_mcount',
		     'msgdir',                   'GLOBAL_msgdir',
		     'subject',                  'GLOBAL_subject',
		     'imeout',                   'GLOBAL_timeout',
		     'xpl',                      'GLOBAL_xpl',
		     'xtc',                      'GLOBAL_xtc',

		     # Parameters that are now handled by POPFile::Logger

		     'logdir',                   'logger_logdir',

		     # Parameters that are now handled by Proxy::POP3

		     'download_count',           'pop3_download_count',
		     'localpop',                 'pop3_local',
		     'port',                     'pop3_port',
		     'sport',                    'pop3_secure_port',
		     'server',                   'pop3_secure_server',
		     'separator',                'pop3_separator',
		     'optoo',                    'pop3_toptoo',

		     # Parameters that are now handled by UI::HTML

		     'archive',                  'ui_archive',
		     'archive_classes',          'ui_archive_classes',
		     'archive_dir',              'ui_archive_dir',
		     'history_days',             'ui_history_days',
		     'language',                 'ui_language',
		     'last_reset',               'ui_last_reset',
		     'last_update_check',        'ui_last_update_check',
		     'localui',                  'ui_local',
		     'page_size',                'ui_page_size',
		     'password',                 'ui_password',
		     'send_stats',               'ui_send_stats',
		     'skin',                     'ui_skin',
		     'test_language',            'ui_test_language',
		     'update_check',             'ui_update_check'
    );

    if ( defined( $upgrades{$parameter} ) ) {
        return $upgrades{$parameter};
    } else {
        return $parameter;
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
	        my $parameter = $1;
		my $value     = $2;

		$parameter = $self->upgrade_parameter__($parameter);

                $self->{configuration_parameters__}{$parameter} = $value;
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
        foreach my $key (sort keys %{$self->{configuration_parameters__}}) {
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
