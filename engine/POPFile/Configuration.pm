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

    # Name of the PID file that we created

    $self->{pid_file__} = '';

    # The time to delay checking of the PID file

    $self->{pid_delay__} = 5;

    # The last time the PID was checked

    $self->{pid_check__} = time;

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
    #
    # download_count is incremented every time POPFile forks to
    # start a session for downloading messages (see Proxy::Proxy::service
    # for details)

    $self->global_config_( 'download_count', 0 );

    # The default timeout in seconds for POP3 commands
    $self->global_config_( 'timeout', 60 );

    # Subject modification (global setting is on)
    $self->global_config_( 'subject', 1 );

    # Adding the X-Text-Classification on
    $self->global_config_( 'xtc', 1 );

    # Adding the X-POPFile-Link is on
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

    # Check to see if the PID file is present, if it is then another POPFile
    # may be running, warn the user and terminate

    $self->{pid_file__} = $self->config_( 'piddir' ) . 'popfile.pid';

    if (defined($self->live_check_())) {
        return 0;
    }

    $self->write_pid_();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# service() is a called periodically to give the module a chance to do housekeeping work.
#
# If any problem occurs that requires POPFile to shutdown service() should return 0 and
# the top level process will gracefully terminate POPFile including calling all stop()
# methods.  In normal operation return 1.#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    my $time = time;

    if ( $self->{pid_check__} <= ( $time - $self->{pid_delay__})) {

        $self->{pid_check__} = $time;

        if ( !$self->check_pid_() ) {
            $self->write_pid_();
            $self->log_("New POPFile instance detected and signalled")
        }
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

    $self->save_configuration();

    $self->delete_pid_();
}


# ---------------------------------------------------------------------------------------------
#
# live_check_
#
# Checks if an instance of POPFile is currently running. Takes 10 seconds.
# Returns the process-ID of the currently running POPFile, undef if none.
#
# ---------------------------------------------------------------------------------------------
sub live_check_
{
    my ( $self ) = @_;

    if ( $self->check_pid_() ) {

        my $error = "\n\nA copy of POPFile appears to be running.\n Attempting to signal the previous copy.\n Waiting " . ($self->{pid_delay__} * 2) . " seconds for a reply.\n";

        $self->delete_pid_();

        print STDERR $error;

        select(undef, undef, undef, ($self->{pid_delay__} * 2));

        my $pid = $self->get_pid_();

        if (defined($pid)) {
            $error = "\n A copy of POPFile is running.\n It has signalled that it is alive with proccess ID: $pid\n";
            print STDERR $error;
            return $pid;
        }
    }
    return undef;
}


# ---------------------------------------------------------------------------------------------
#
# check_pid_
#
# returns 1 if the pid file exists, 0 otherwise
#
# ---------------------------------------------------------------------------------------------

sub check_pid_
{
    my ( $self ) = @_;
    return (-e $self->{pid_file__});
}


# ---------------------------------------------------------------------------------------------
#
# get_pid_
#
# returns the pidfile proccess ID if a pid file is present, undef otherwise (0 might be a valid PID)
#
# ---------------------------------------------------------------------------------------------
sub get_pid_
{
    my ( $self ) = @_;

    if (open PID, $self->{pid_file__}) {
        my $pid = <PID>;
        $pid =~ s/[\r\n]//g;
        close PID;
        return $pid;
    }

    return undef;
}

# ---------------------------------------------------------------------------------------------
#
# write_pid_
#
# writes the current process-ID into the pid file
#
# ---------------------------------------------------------------------------------------------
sub write_pid_
{
    my ( $self ) = @_;

    if ( open PID, ">$self->{pid_file__}" ) {
        print PID "$$\n";
        close PID;
    }
}

# ---------------------------------------------------------------------------------------------
#
# delete_pid_
#
# deletes the pid file
#
# ---------------------------------------------------------------------------------------------
sub delete_pid_
{
    my ( $self ) = @_;

    unlink( $self->{pid_file__} );
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

        while ( $i <= $#ARGV )  {
            # A command line argument must start with a -

            if ( $ARGV[$i] =~ /^-(.+)$/ ) {
                my $parameter = $self->upgrade_parameter__($1);

                if ( defined($self->{configuration_parameters__}{$parameter}) ) {
                    if ( $i < $#ARGV ) {
                        $self->{configuration_parameters__}{$parameter} = $ARGV[$i+1];
                        $i += 2;
                    } else {
                        print STDERR "Missing argument for $ARGV[$i]\n";
                        last;
                    }
                } else {
                    print STDERR "Unknown command line option $ARGV[$i]\n";
                    last;
                }
            } else {
                print STDERR "Expected a command line option and got $ARGV[$i]\n";
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

    my %upgrades = ( # PROFILE BLOCK START

                     # Parameters that are now handled by Classifier::Bayes

                     'corpus',                   'bayes_corpus',
                     'unclassified_probability', 'bayes_unclassified_probability',

                     # Parameters that are now handled by POPFile::Configuration

                     'piddir',                   'config_piddir',

                     # Parameters that are now global to POPFile

                     'debug',                    'GLOBAL_debug',
                     'msgdir',                   'GLOBAL_msgdir',
                     'subject',                  'GLOBAL_subject',
                     'timeout',                  'GLOBAL_timeout',
                     'xpl',                      'GLOBAL_xpl',
                     'xtc',                      'GLOBAL_xtc',
                     'download_count',           'GLOBAL_download_count',

                     # Parameters that are now handled by POPFile::Logger

                     'logdir',                   'logger_logdir',

                     # Parameters that are now handled by Proxy::POP3

                     'localpop',                 'pop3_local',
                     'port',                     'pop3_port',
                     'sport',                    'pop3_secure_port',
                     'server',                   'pop3_secure_server',
                     'separator',                'pop3_separator',
                     'toptoo',                   'pop3_toptoo',

                     # Parameters that are now handled by UI::HTML

                     'archive',                  'html_archive',
                     'archive_classes',          'html_archive_classes',
                     'archive_dir',              'html_archive_dir',
                     'history_days',             'html_history_days',
                     'language',                 'html_language',
                     'last_reset',               'html_last_reset',
                     'last_update_check',        'html_last_update_check',
                     'localui',                  'html_local',
                     'page_size',                'html_page_size',
                     'password',                 'html_password',
                     'send_stats',               'html_send_stats',
                     'skin',                     'html_skin',
                     'test_language',            'html_test_language',
                     'update_check',             'html_update_check',
                     'ui_port',                  'html_port',
    ); # PROFILE BLOCK STOP

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

# GETTER

sub configuration_parameters
{
    my ( $self ) = @_;

    return sort keys %{$self->{configuration_parameters__}};
}

1;
