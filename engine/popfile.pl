#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# popfile.pl --- POP3 mail analyzer and sorter
#
# Acts as a POP3 server and client designed to sit between a real mail client and a real mail
# server using POP3.  Inserts an extra header X-Text-Classification: into the mail header to 
# tell the client whether the mail is spam or not based on a text classification algorithm
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;

# NOTE: POPFile is constructed from a collection of classes which all have special
# interface functions and variables:
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
# forked()     - called when a module has forked the process.  This is called within the child
#                process and should be used to clean up 
#
# reaper()     - called when a process has terminated to give a module a chance to do 
#                whatever clean up is needed
#
# name()	   - returns a simple name for the module by which other modules can get access
#				 through the %components hash.  The name returned here will be the name
#                used as the key for this module in %components
#
# pipeready    - This is a reference to the pipeready() function in this file that it used
#                to determine if a pipe if ready for reading
#
# alive        - Gets set to 1 when the parent wants to kill all the running sub modules
#
# forker       - This is a reference to a function (forker) in this file that performs a fork
#                and informs modules that a fork has occurred.
#
# The POPFile classes are stored by reference in the %components hash, the top level key is
# the type of the component (see load_modules) and then the name of the component derived from 
# calls to each loadable modules name() method and which points to the actual module

my %components;

# This is the A PIECE OF PLATFORM SPECIFIC CODE and all it does is force Windows users to have 
# v5.8.0 because that's the version with good fork() support everyone else can use whatever they
# want.  This is  probably only temporary because at some point I am going to force 5.8.0 for 
# everyone because of the better Unicode support

my $on_windows = 0;

if ( $^O eq 'MSWin32' ) {
	require v5.8.0;
	$on_windows = 1;
}

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
	foreach my $type (keys %components) {
		foreach my $name (keys %{$components{$type}}) {
			$components{$type}{$name}->{alive} = 0;
			$components{$type}{$name}->stop();
		}
    }
}

# ---------------------------------------------------------------------------------------------
#
# pipeready
#
# Returns 1 if there is data available to be read on the passed in pipe handle
#
# $pipe		Pipe handle
#
# ---------------------------------------------------------------------------------------------
sub pipeready
{
	my ( $pipe ) = @_;

	if ( $on_windows ) {
		
		# I am NOT doing a select() here because that does not work 
		# on Perl running on Windows.  -s returns the "size" of the file
		# (in this case a pipe) and will be non-zero if there is data to read
		
		return ( ( -s $pipe ) > 0 );
	} else {
		
		# Here I do a select because we are not running on Windows where
		# you can't select() on a pipe

		my $rin = '';
		vec( $rin, fileno( $pipe ), 1 ) = 1;
		my $ready = select( $rin, undef, undef, 0.01 );
		return ( $ready > 0 );
	}
}



# ---------------------------------------------------------------------------------------------
#
# reaper
#
# Called if we get SIGCHLD and asks each module to do whatever reaping is needed
#
# ---------------------------------------------------------------------------------------------
sub reaper
{
	foreach my $type (keys %components) {
		foreach my $name (keys %{$components{$type}}) {
		    $components{$type}{$name}->reaper();
		}
    }

	$SIG{CHLD} = \&reaper;
}

# ---------------------------------------------------------------------------------------------
#
# forker
#
# Called to fork POPFile.  Calls every module's forked function in the child process to give
# then a chance to clean up
#
# Returns the return value from fork() and a file handle that form a pipe in the
# direction child to parent.  There is no need to close the file handles that are unused as
# would normally be the case with a pipe and fork as forker takes care that in each process
# only one file handle is open (be it the reader or the writer)
#
# ---------------------------------------------------------------------------------------------
sub forker
{
    # Create the pipe that will be used to send data from the child to the parent process, 
    # $writer will be returned to the child process and $reader to the parent process
    
    pipe my $reader, my $writer;
    my $pid = fork();
    
    # If fork() returns an undefined value then we failed to fork and are
    # in serious trouble (probably out of resources) so we return undef
    
    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    # If fork returns a PID of 0 then we are in the child process so close the
    # reading pipe file handle, inform all modules that are fork has occurred and 
    # then return 0 as the PID so that the caller knows that we are in the child
    
    if ( $pid == 0 ) {
		foreach my $type (keys %components) {
			foreach my $name (keys %{$components{$type}}) {
	            $components{$type}{$name}->forked();
	    	}
        }
        
        close $reader;
        
        # Set autoflush on the write handle so that output goes straight through
        # to the parent without buffering it until the socket closes
        
        use IO::Handle;
        $writer->autoflush(1);
        
        return (0, $writer);
    }
    
    # Reach here because we are in the parent process, close out the writer pipe
    # file handle and return our PID (non-zero) indicating that this is the parent
    # process
    
    close $writer;
    return ($pid, $reader);
}

# ---------------------------------------------------------------------------------------------
#
# load_modules
#
# Called to load all the POPFile loadable modules (implemented as .pm files with special
# comment on first line) in a specific subdirectory
#
# $directory		The directory to search for loadable modules
# $type				The 'type' of module being loaded (e.g. proxy, core, ui) which is used
#				    below when fixing up references between modules (e.g. proxy modules all
#					need access to the classifier module)
#
#
# ---------------------------------------------------------------------------------------------
sub load_modules
{
	my ( $directory, $type ) = @_;

	# Look for all the .pm files in named directory and then see which of them
	# are POPFile modules indicated by the first line of the file being and
	# comment (# POPFILE LOADABLE MODULE) and load that module into the %components
	# hash getting the name from the module by calling name()
	
	my @modules = glob "$directory/*.pm";
	
	foreach my $module (@modules) {
		if ( open MODULE, "<$module" ) {
			my $first = <MODULE>;
			close MODULE;
			
			if ( $first =~ /^# POPFILE LOADABLE MODULE/ ) {
				require $module;

				$module =~ s/\//::/;
				$module =~ s/\.pm//;

				my $mod = new $module;
				my $name = $mod->name();

				$components{$type}{$name} = $mod;
				
				print " {$name}";
			}
		}
	}
}

#
#
# MAIN
#
#

$SIG{QUIT}  = \&aborting;
$SIG{ABRT}  = \&aborting;
$SIG{KILL}  = \&aborting;
$SIG{STOP}  = \&aborting;
$SIG{TERM}  = \&aborting;
$SIG{INT}   = \&aborting;

# Yuck.  On Windows SIGCHLD isn't calling the reaper under ActiveState 5.8.0
# so we detect Windows and ignore SIGCHLD and call the reaper code below

$SIG{CHLD}  = $on_windows?'IGNORE':\&reaper;

# Create the main objects that form the core of POPFile.  Consists of the configuration
# modules, the classifier, the UI (currently HTML based), and the POP3 proxy.

print "    Loading... ";

load_modules( 'POPFile',	'core'       );
load_modules( 'Classifier', 'classifier' );
load_modules( 'UI',         'ui'         );
load_modules( 'Proxy',      'proxy'      );

# The version number

$components{core}{config}->{major_version} = 0;
$components{core}{config}->{minor_version} = 18;
$components{core}{config}->{build_version} = 1;

print "\nPOPFile Engine v$components{core}{config}->{major_version}.$components{core}{config}->{minor_version}.$components{core}{config}->{build_version} starting";

# Link each of the main objects with the configuration object so that they can set their
# default parameters all or them also get access to the logger

foreach my $type (keys %components) {
	foreach my $name (keys %{$components{$type}}) {
		$components{$type}{$name}->{configuration} = $components{core}{config} if ( $name ne 'config' );
		$components{$type}{$name}->{logger}        = $components{core}{logger} if ( $name ne 'logger' );
	}
}

# All proxies need access to the classifier and the UI

foreach my $name (keys %{$components{proxy}}) {
	$components{proxy}{$name}->{classifier} = $components{classifier}{classifier};
	$components{proxy}{$name}->{ui}         = $components{ui}{html};
}

# All UI components need access to the classifier

foreach my $name (keys %{$components{ui}}) {
	$components{ui}{$name}->{classifier} = $components{classifier}{classifier};
}

print "\n    Initializing... ";

# Tell each module to initialize itself

foreach my $type (keys %components) {
	foreach my $name (keys %{$components{$type}}) {
		print "{$name} ";
		if ( $components{$type}{$name}->initialize() == 0 ) {
			die "Failed to start while initializing the $name module";
		}

		$components{$type}{$name}->{alive}  = 1;
		$components{$type}{$name}->{forker}    = \&forker;
		$components{$type}{$name}->{pipeready} = \&pipeready;
	}
}

# Load the configuration from disk and then apply any command line
# changes that override the saved configuration

$components{core}{config}->load_configuration();
$components{core}{config}->parse_command_line();

print "\n    Starting...     ";

# Now that the configuration is set tell each module to begin operation

foreach my $type (keys %components) {
	foreach my $name (keys %{$components{$type}}) {
		print "{$name} ";
		if ( $components{$type}{$name}->start() == 0 ) {
			die "Failed to start while starting the $name module";
		}
	}
}

print "\nPOPFile Engine v$components{core}{config}->{major_version}.$components{core}{config}->{minor_version}.$components{core}{config}->{build_version} running\n";

# MAIN LOOP - Call each module's service() method to all it to
#             handle its own requests

while ( $alive == 1 ) {
	foreach my $type (keys %components) {
		foreach my $name (keys %{$components{$type}}) {
			if ( $components{$type}{$name}->service() == 0 ) {
				$alive = 0;
				last;
			}
		}
    }
    
    # Sleep for 0.05 of a second to ensure that POPFile does not hog the machine's
    # CPU

    select(undef, undef, undef, 0.05);
    
    # If we are on Windows then reap children here

    if ( $on_windows ) {
		foreach my $type (keys %components) {
			foreach my $name (keys %{$components{$type}}) {
				$components{$type}{$name}->reaper();
			}
		}
    }
}

print "    Stopping... ";

# Shutdown all the modules

foreach my $type (keys %components) {
	foreach my $name (keys %{$components{$type}}) {
		print "{$name} ";
		$components{$type}{$name}->{alive} = 0;
		$components{$type}{$name}->stop();
	}
}

print "\n    Saving configuration\n";

# Write the final configuration to disk

$components{core}{config}->save_configuration();

print "POPFile Engine v$components{core}{config}->{major_version}.$components{core}{config}->{minor_version}.$components{core}{config}->{build_version} terminating\n";

# ---------------------------------------------------------------------------------------------
