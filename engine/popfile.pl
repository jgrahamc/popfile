#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# popfile.pl --- POP3 mail analyzer and sorter
#
# Acts as a POP3 server and client designed to sit between a real mail client and a real mail
# server using POP3.  Inserts an extra header X-Text-Classification: into the mail header to 
# tell the client whether the mail is spam or not based on a text classification algorithm
#
# Originally created by John Graham-Cumming starting in 2001
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;

# NOTE: POPFile is constructed from a collection of classes which all have four special
# interface functions:
#
# initialize() - called after the class is created to set default values for internal
#                variables and global configuration information
# start()      - called once all configuration has been read and POPFile is ready to start
#                operating
# stop()       - called when POPFile is shutting down
#
# service()    - called by the main POPFile process to allow a submodule to do its own
#                work (this is optional for modules that do not need to perform any service)
#
# alive        - Gets set to 1 when the parent wants to kill all the running sub modules
#
# The POPFile classes are stored by reference in the %components hash
my %components;

use Classifier::Bayes;          # Use the Naive Bayes classifier
use UI::HTML;                   # Load the POPFile HTML user interface
use POPFile::Configuration;     # POPFile's configuration is handled by this module
use Proxy::POP3;                # The POP3 proxy engine

# A handy boolean that tells us whether we are alive or not.  When this is set to 1 then the
# proxy works normally, when set to 0 (typically by the aborting() function called from a signal)
# then we will terminate gracefully
my $alive = 1;

# ---------------------------------------------------------------------------------------------
#
# aborting    
#
# Called if we are going to be aborted or are being asked to abort our operation. Sets the 
# alive flag to 0 that will cause us to abort at the next convenient moment
#
# ---------------------------------------------------------------------------------------------
sub aborting 
{
    $alive = 0;
    for my $c (keys %components) {
        $components{$c}->{alive} = 0;
    }
}

#
#
# MAIN
#
#

$SIG{QUIT}  = \&aborting;
$SIG{ABRT}  = \&aborting;
$SIG{TERM}  = \&aborting;
$SIG{INT}   = \&aborting;

# Create the main objects that form the core of POPFile.  Consists of the configuration
# modules, the classifier, the UI (currently HTML based), and the POP3 proxy.
$components{config}     = new POPFile::Configuration;
$components{classifier} = new Classifier::Bayes;
$components{ui}         = new UI::HTML;
$components{pop3}       = new Proxy::POP3;

# This version number
$components{config}->{major_version} = 0;
$components{config}->{minor_version} = 17;
$components{config}->{build_version} = 10;

print "POPFile Engine v$components{config}->{major_version}.$components{config}->{minor_version}.$components{config}->{build_version} starting\n";

# Link each of the main objects with the configuration object so that they can set their
# default parameters.
$components{classifier}->{configuration} = $components{config};
$components{ui}->{configuration}         = $components{config};
$components{pop3}->{configuration}       = $components{config};

# The POP3 proxy and UI need to know about the classifier
$components{pop3}->{classifier}          = $components{classifier};
$components{ui}->{classifier}            = $components{classifier};

# The proxy needs to talk to the ui
$components{pop3}->{ui}                  = $components{ui};

# Tell each module to initialize itself
for my $c (keys %components) {
    if ( $components{$c}->initialize() == 0 ) {
        die "Failed to start while initializing the $c module";
    }
    
    $components{$c}->{alive} = 1;
}

print "    Loading configuration\n";

# Load the configuration from disk and then apply any command line
# changes that override the saved configuration
$components{config}->load_configuration();
$components{config}->parse_command_line();

# Now that the configuration is set tell each module to begin operation
for my $c (keys %components) {
    if ( $components{$c}->start() == 0 ) {
        die "Failed to start while starting the $c module";
    }
}

print "    Cleaning stale log files\n";

# Remove old log files
$components{pop3}->remove_debug_files();
$components{ui}->remove_mail_files();

print "POPFile Engine v$components{config}->{major_version}.$components{config}->{minor_version}.$components{config}->{build_version} running\n";

# MAIN LOOP - Call each module's service() method to all it to
#             handle its own requests
while ( $alive == 1 ) {
    for my $c (keys %components) {
        if ( $components{$c}->service() == 0 ) {
            $alive = 0;
            last;
        }
    }
    
    # Sleep for 0.1 of a second to ensure that POPFile does not hog the machine's
    # CPU
    sleep(0.1);
}

# Shutdown all the modules
for my $c (keys %components) {
    $components{$c}->{alive} = 0;
    $components{$c}->stop();
}

print "    Saving configuration\n";

# Write the final configuration to disk
$components{config}->save_configuration();

print "POPFile Engine v$components{config}->{major_version}.$components{config}->{minor_version}.$components{config}->{build_version} terminating\n";

# ---------------------------------------------------------------------------------------------
