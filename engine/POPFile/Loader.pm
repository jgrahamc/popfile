package POPFile::Loader;

# ---------------------------------------------------------------------------------------------
#
# Loader.pm --- API for loading POPFile loadable modules and encapsulating POPFile application
#               tasks
#
# Subroutine names beginning with CORE indicate a subroutine designed for exclusive use of
# POPFile's core application (popfile.pl).
#
# Subroutines not so marked are suitable for use by POPFile-based utilities to assist in loading
# and executing modules
#
# Copyright (c) 2001-2003 John Graham-Cumming
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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self;

    # The POPFile classes are stored by reference in the components hash, the top level key is
    # the type of the component (see CORE_load_directory_modules) and then the name of the
    # component derived from calls to each loadable modules name() method and which points to
    # the actual module

    $self->{components__} = {};

    # A handy boolean that tells us whether we are alive or not.  When this is set to 1 then the
    # proxy works normally, when set to 0 (typically by the aborting() function called from a signal)
    # then we will terminate gracefully

    $self->{alive__} = 1;

    # This must be 1 for POPFile::Loader to create any output on STDOUT

    $self->{debug__} = 1;

    # This stuff lets us do some things in a way that tolerates some window-isms

    $self->{on_windows__} = 0;

    if ( $^O eq 'MSWin32' ) {
        require v5.8.0;
        $self->{on_windows__} = 1;
    }

    # See CORE_loader_init below for an explanation of these

    $self->{aborting__}     = '';
    $self->{pipeready__}    = '';
    $self->{forker__}       = '';
    $self->{reaper__}       = '';

    # POPFile's version number as individual numbers and as
    # string

    $self->{major_version__}  = '?';
    $self->{minor_version__}  = '?';
    $self->{build_version__}  = '?';
    $self->{version_string__} = '';

    # Where POPFile is installed

    $self->{popfile_root__} = './';

    bless $self, $type;

    return $self;
}

#---------------------------------------------------------------------------------------------
#
# CORE_loader_init
#
# Initialize things only needed in CORE
#
#---------------------------------------------------------------------------------------------
sub CORE_loader_init
{
    my ( $self ) = @_;

    if ( defined( $ENV{POPFILE_ROOT} ) ) {
        $self->{popfile_root__} = $ENV{POPFILE_ROOT};
    }

    # These anonymous subroutine references allow us to call these important
    # functions from anywhere using the reference, granting internal access
    # to $self, without exposing $self to the unwashed. No reference to
    # POPFile::Loader is needed by the caller

    $self->{aborting__} = sub { $self->CORE_aborting(@_) };
    $self->{pipeready__} = sub { $self->pipeready(@_) };
    $self->{forker__} = sub { $self->CORE_forker(@_) };
    $self->{reaper__} = sub { $self->CORE_reaper(@_) };

    # See if there's a file named popfile_version that contains the
    # POPFile version number

    my $version_file = $self->root_path__( 'POPFile/popfile_version' );

    if ( -e $version_file ) {
        open VER, "<$version_file";
        my $major = int(<VER>);
        my $minor = int(<VER>);
        my $rev   = int(<VER>);
        close VER;
        $self->CORE_version( $major, $minor, $rev );
    }

    print "\nPOPFile Engine loading\n" if $self->{debug__};
}

#---------------------------------------------------------------------------------------------
#
# CORE_aborting
#
# Called if we are going to be aborted or are being asked to abort our operation. Sets the
# alive flag to 0 that will cause us to abort at the next convenient moment
#
#---------------------------------------------------------------------------------------------
sub CORE_aborting
{
    my ( $self ) = @_;

    $self->{alive__} = 0;
    foreach my $type (keys %{$self->{components__}}) {
        foreach my $name (keys %{$self->{components__}{$type}}) {
            $self->{components__}{$type}{$name}->alive(0);
            $self->{components__}{$type}{$name}->stop();
        }
    }
}

#---------------------------------------------------------------------------------------------
#
# pipeready
#
# Returns 1 if there is data available to be read on the passed in pipe handle
#
# $pipe        Pipe handle
#
#---------------------------------------------------------------------------------------------
sub pipeready
{
    my ( $self, $pipe ) = @_;

    # Check that the $pipe is still a valid handle

    if ( !defined( $pipe ) ) {
        return 0;
    }

    if ( $self->{on_windows__} ) {

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

#---------------------------------------------------------------------------------------------
#
# CORE_reaper
#
# Called if we get SIGCHLD and asks each module to do whatever reaping is needed
#
#---------------------------------------------------------------------------------------------
sub CORE_reaper
{
    my ( $self ) = @_;

    foreach my $type (keys %{$self->{components__}}) {
        foreach my $name (keys %{$self->{components__}{$type}}) {
            $self->{components__}{$type}{$name}->reaper();
        }
    }

    $SIG{CHLD} = $self->{reaper__};
}

#---------------------------------------------------------------------------------------------
#
# CORE_forker
#
# Called to fork POPFile.  Calls every module's forked function in the child process to give
# then a chance to clean up
#
# Returns the return value from fork() and a file handle that form a pipe in the
# direction child to parent.  There is no need to close the file handles that are unused as
# would normally be the case with a pipe and fork as forker takes care that in each process
# only one file handle is open (be it the reader or the writer)
#
#---------------------------------------------------------------------------------------------
sub CORE_forker
{
    my ( $self ) = @_;

    # Tell all the modules that a fork is about to happen

    foreach my $type (keys %{$self->{components__}}) {
        foreach my $name (keys %{$self->{components__}{$type}}) {
            $self->{components__}{$type}{$name}->prefork();
        }
    }

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
          foreach my $type (keys %{$self->{components__}}) {
               foreach my $name (keys %{$self->{components__}{$type}}) {
                 $self->{components__}{$type}{$name}->forked();
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

    foreach my $type (keys %{$self->{components__}}) {
        foreach my $name (keys %{$self->{components__}{$type}}) {
            $self->{components__}{$type}{$name}->postfork();
        }
    }

    close $writer;
    return ($pid, $reader);
}

#---------------------------------------------------------------------------------------------
#
# CORE_load_directory_modules
#
# Called to load all the POPFile Loadable Modules (implemented as .pm files with special
# comment on first line) in a specific subdirectory and loads them into a structured
# components hash
#
# $directory        The directory to search for loadable modules
# $type             The 'type' of module being loaded (e.g. proxy, core, ui) which is used
#                   when fixing up references between modules (e.g. proxy modules all need
#                   access to the classifier module) and for structuring components hash
#
#---------------------------------------------------------------------------------------------
sub CORE_load_directory_modules
{
    my ( $self, $directory, $type ) = @_;

    print "\n         {$type:" if $self->{debug__};

    # Look for all the .pm files in named directory and then see which of them
    # are POPFile modules indicated by the first line of the file being and
    # comment (# POPFILE LOADABLE MODULE) and load that module into the %{$self->{components__}}
    # hash getting the name from the module by calling name()

    opendir MODULES, $self->root_path__( $directory );

    while ( my $entry = readdir MODULES ) {
        if ( $entry =~ /\.pm$/ ) {
            $self->CORE_load_module( "$directory/$entry", $type );
	}
    }

    closedir MODULES;

    print '} ' if $self->{debug__};
}

#---------------------------------------------------------------------------------------------
#
# CORE_load_module
#
# Called to load a single POPFile Loadable Module (implemented as .pm files with special
# comment on first line) and add it to the components hash.
#
# Returns a handle to the module
#
# $module           The path of the module to load
# $type             The 'type' of module being loaded (e.g. proxy, core, ui)
#
#---------------------------------------------------------------------------------------------
sub CORE_load_module
{
    my ( $self, $module, $type ) = @_;

    my $mod = $self->load_module_($module);

    if ( defined( $mod ) ) {
        my $name = $mod->name();
        print " $name" if $self->{debug__};
        $self->{components__}{$type}{$name} = $mod;
    }
    return $mod;
}

#---------------------------------------------------------------------------------------------
#
# load_module_
#
# Called to load a single POPFile Loadable Module (implemented as .pm files with special
# comment on first line. Returns a handle to the module, undef if the module failed to load.
# No internal side-effects.
#
# $module           The path of the module to load
#
#---------------------------------------------------------------------------------------------
sub load_module_
{
    my ( $self, $module ) = @_;

    my $mod;

    if ( open MODULE, '<' . $self->root_path__( $module ) ) {
        my $first = <MODULE>;
        close MODULE;

        if ( $first =~ /^# POPFILE LOADABLE MODULE/ ) {
            require $module;
       
            $module =~ s/\//::/;
            $module =~ s/\.pm//;

            $mod = $module->new();
        }
    }
    return $mod;
}

#---------------------------------------------------------------------------------------------
#
# CORE_signals
#
# Sets signals to ensure that POPFile handles OS and IPC events
#
# TODO: Figure out why windows POPFile doesn't seem to get SIGTERM when windows shuts down
#
#---------------------------------------------------------------------------------------------
sub CORE_signals
{
    my ( $self ) = @_;

    # Redefine POPFile's signals

    $SIG{QUIT}  = $self->{aborting__};
    $SIG{ABRT}  = $self->{aborting__};
    $SIG{KILL}  = $self->{aborting__};
    $SIG{STOP}  = $self->{aborting__};
    $SIG{TERM}  = $self->{aborting__};
    $SIG{INT}   = $self->{aborting__};

    # Yuck.  On Windows SIGCHLD isn't calling the reaper under ActiveState 5.8.0
    # so we detect Windows and ignore SIGCHLD and call the reaper code below

    $SIG{CHLD}  = $self->{on_windows__}?'IGNORE':$self->{reaper__};

    # I've seen spurious ALRM signals happen on Windows so here we for safety
    # say that we want to ignore them

    $SIG{ALRM}  = 'IGNORE';

    return $SIG;
}

#---------------------------------------------------------------------------------------------
#
# CORE_platform_
#
# Loads POPFile's platform-specific code
#
#---------------------------------------------------------------------------------------------
sub CORE_platform_
{
    my ( $self ) = @_;

    # Look for a module called Platform::<platform> where <platform> is the value of $^O
    # and if it exists then load it as a component of POPFile.  IN this way we can have
    # platform specific code (or not) encapsulated.  Note that such a module needs to be
    # a POPFile Loadable Module and a subclass of POPFile::Module to operate correctly

    my $platform = $^O;

    if ( -e "Platform/$platform.pm" ) {
        print "\n         {core:" if $self->{debug__};

        $self->CORE_load_module( "Platform/$platform.pm",'core');

        print "}" if $self->{debug__};
    }
}

#---------------------------------------------------------------------------------------------
#
# CORE_load
#
# Loads POPFile's modules
#
#---------------------------------------------------------------------------------------------
sub CORE_load
{
    my ( $self ) = @_;

    # Create the main objects that form the core of POPFile.  Consists of the configuration
    # modules, the classifier, the UI (currently HTML based), and the POP3 proxy.

    print "\n    Loading... " if $self->{debug__};

    # Do our platform-specific stuff
    $self->CORE_platform_();

    # populate our components hash
    $self->CORE_load_directory_modules( 'POPFile',    'core'       );
    $self->CORE_load_directory_modules( 'Classifier', 'classifier' );
    $self->CORE_load_directory_modules( 'UI',         'interface' );
    $self->CORE_load_directory_modules( 'Proxy',      'proxy'      );
}

#---------------------------------------------------------------------------------------------
#
# CORE_link_components
#
# Links POPFile's modules together to allow them to make use of each-other as objects
#
#---------------------------------------------------------------------------------------------
sub CORE_link_components
{
    my ( $self ) = @_;

    print "\n\nPOPFile Engine $self->{version_string__} starting" if $self->{debug__};

    # Link each of the main objects with the configuration object so that they can set their
    # default parameters all or them also get access to the logger, version, and message-queue

    foreach my $type (keys %{$self->{components__}}) {
        foreach my $name (keys %{$self->{components__}{$type}}) {
            $self->{components__}{$type}{$name}->version(       scalar($self->CORE_version())                    );
            $self->{components__}{$type}{$name}->configuration( $self->{components__}{core}{config} );
            $self->{components__}{$type}{$name}->logger(        $self->{components__}{core}{logger} ) if ( $name ne 'logger' );
            $self->{components__}{$type}{$name}->mq(            $self->{components__}{core}{mq}     );
        }
    }

    # All interface components need access to the classifier

    foreach my $name (keys %{$self->{components__}{interface}}) {
        $self->{components__}{interface}{$name}->classifier( $self->{components__}{classifier}{bayes} );
    }

    foreach my $name (keys %{$self->{components__}{proxy}}) {
        $self->{components__}{proxy}{$name}->classifier( $self->{components__}{classifier}{bayes} );
    }

    # TODO Clean this up so that the Loader doesn't have to know so much about
    # Bayes.

    $self->{components__}{classifier}{bayes}->{parser__}->mangle( 
        $self->{components__}{classifier}{wordmangle} );
}

#---------------------------------------------------------------------------------------------
#
# CORE_initialize
#
# Loops across POPFile's modules and initializes them
#
#---------------------------------------------------------------------------------------------
sub CORE_initialize
{
    my ( $self ) = @_;

    print "\n\n    Initializing... " if $self->{debug__};

    # Tell each module to initialize itself

    foreach my $type (keys %{$self->{components__}}) {
        print "\n         {$type:" if $self->{debug__};
        foreach my $name (keys %{$self->{components__}{$type}}) {
            print " $name" if $self->{debug__};
            flush STDOUT;

            my $code = $self->{components__}{$type}{$name}->initialize();

            if ( $code == 0 ) {
                die "Failed to start while initializing the $name module";
            }

            if ( $code == 1 ) {
                 $self->{components__}{$type}{$name}->alive(     1 );

                 $self->{components__}{$type}{$name}->forker(    $self->{forker__} );
                 $self->{components__}{$type}{$name}->pipeready( $self->{pipeready__} );
	    }
        }
        print '} ' if $self->{debug__};
    }
    print "\n";
}

#---------------------------------------------------------------------------------------------
#
# CORE_config
#
# Loads POPFile's configuration and command-line settings
#
#---------------------------------------------------------------------------------------------
sub CORE_config
{
    my ( $self ) = @_;

    # Load the configuration from disk and then apply any command line
    # changes that override the saved configuration

    $self->{components__}{core}{config}->load_configuration();
    return $self->{components__}{core}{config}->parse_command_line();
}

#---------------------------------------------------------------------------------------------
#
# CORE_start
#
# Loops across POPFile's modules and starts them
#
#---------------------------------------------------------------------------------------------
sub CORE_start
{
    my ( $self ) = @_;

    print "\n    Starting...     " if $self->{debug__};

    # Now that the configuration is set tell each module to begin operation

    foreach my $type (keys %{$self->{components__}}) {
        print "\n         {$type:" if $self->{debug__};
        foreach my $name (keys %{$self->{components__}{$type}}) {
            my $code = $self->{components__}{$type}{$name}->start();

            if ( $code == 0 ) {
                die "Failed to start while starting the $name module";
            }

            # If the module said that it didn't want to be loaded then
            # unload it.

            if ( $code == 2 ) {
                delete $self->{components__}{$type}{$name};
	    } else {
                print " $name" if $self->{debug__};
                flush STDOUT;
            }
        }
        print '} ' if $self->{debug__};
    }

    print "\n\nPOPFile Engine ", scalar($self->CORE_version()), " running\n" if $self->{debug__};
    flush STDOUT;
}

#---------------------------------------------------------------------------------------------
#
# CORE_service
#
# This is POPFile. Loops across POPFile's modules and executes their service subroutines then
# sleeps briefly
#
# $nowait            If 1 then don't sleep and don't loop
#
#---------------------------------------------------------------------------------------------
sub CORE_service
{
    my ( $self, $nowait ) = @_;

    $nowait = 0 if ( !defined( $nowait ) );

    # MAIN LOOP - Call each module's service() method to all it to
    #             handle its own requests

    while ( $self->{alive__} == 1 ) {
        foreach my $type (keys %{$self->{components__}}) {
            foreach my $name (keys %{$self->{components__}{$type}}) {
                if ( $self->{components__}{$type}{$name}->service() == 0 ) {
                    $self->{alive__} = 0;
                    last;
                }
            }
        }

        # Sleep for 0.05 of a second to ensure that POPFile does not hog the machine's
        # CPU

        select(undef, undef, undef, 0.05) if !$nowait;

        # If we are on Windows then reap children here

        if ( $self->{on_windows__} ) {
            foreach my $type (keys %{$self->{components__}}) {
                foreach my $name (keys %{$self->{components__}{$type}}) {
                        $self->{components__}{$type}{$name}->reaper();
                }
            }
        }

        last if $nowait;
    }

    return $self->{alive__};
}

#---------------------------------------------------------------------------------------------
#
# CORE_stop
#
# Loops across POPFile's modules and stops them
#
#---------------------------------------------------------------------------------------------
sub CORE_stop
{
    my ( $self ) = @_;

    print "\n\nPOPFile Engine $self->{version_string__} stopping\n" if $self->{debug__};
    flush STDOUT;

    print "\n    Stopping... " if $self->{debug__};

    # Shutdown all the modules

    foreach my $type (keys %{$self->{components__}}) {
        print "\n         {$type:" if $self->{debug__};
        foreach my $name (keys %{$self->{components__}{$type}}) {
            print " $name" if $self->{debug__};
            flush STDOUT;
            $self->{components__}{$type}{$name}->alive(0);
            $self->{components__}{$type}{$name}->stop();
        }

        print '} ' if $self->{debug__};
    }
    print "\n\nPOPFile Engine $self->{version_string__} terminated\n" if $self->{debug__};
}

#---------------------------------------------------------------------------------------------
#
# CORE_version
#
# Gets and Sets POPFile's version data. Returns string in scalar context, or (major, minor, build)
# triplet in list context
#
# $major_version        The major version number
# $minor_version        The minor version number
# $build_version        The build version number
#
#---------------------------------------------------------------------------------------------
sub CORE_version
{
    my ( $self, $major_version, $minor_version, $build_version ) = @_;

    if (!defined($major_version)) {
        if (wantarray) {
            return ($self->{major_version__},$self->{minor_version__},$self->{build_version__});
        } else {
            return $self->{version_string__};
        }
    } else {
        ($self->{major_version__}, $self->{minor_version__}, $self->{build_version__}) = ($major_version, $minor_version, $build_version);
        $self->{version_string__} = "v$major_version.$minor_version.$build_version"
    }
}

#---------------------------------------------------------------------------------------------
#
# get_module
#
# Gets a module from components hash. Returns a handle to a module.
#
# May be called either as:
#
# $name     Module name in scoped format (eg, Classifier::Bayes)
#
# Or:
#
# $name     Name of the module
# $type     The type of module
#
#---------------------------------------------------------------------------------------------
sub get_module
{
    my ( $self, $name, $type ) = @_;

    if (!defined($type) && $name =~ /^(.*)::(.*)$/ ) {
        $type = lc($1);
        $name = lc($2);

        $type =~ s/^POPFile$/core/
    }

    return $self->{components__}{$type}{$name};
}

#---------------------------------------------------------------------------------------------
#
# set_module
#
# Inserts a module into components hash.
#
# $name     Name of the module
# $type     The type of module
# $module   A handle to a module
#
#---------------------------------------------------------------------------------------------
sub set_module
{
    my ($self, $type, $name, $module) = @_;

    $self->{components__}{$type}{$name} = $module;
}

#---------------------------------------------------------------------------------------------
#
# remove_module
#
# removes a module from components hash.
#
# $name     Name of the module
# $type     The type of module
# $module   A handle to a module
#
#---------------------------------------------------------------------------------------------
sub remove_module
{
    my ($self, $type, $name) = @_;

    $self->{components__}{$type}{$name}->stop();

    delete($self->{components__}{$type}{$name});
}

# ---------------------------------------------------------------------------------------------
#
# root_path__
#
# Joins the path passed in with the POPFile root
#
# $path             RHS of path
#
# ---------------------------------------------------------------------------------------------
sub root_path__
{
    my ( $self, $path ) = @_;

    $self->{popfile_root__}  =~ s/[\/\\]$//;
    $path                    =~ s/^[\/\\]//;

    return "$self->{popfile_root__}/$path";
}

# GETTER/SETTER

sub debug
{
    my ( $self, $debug ) = @_;

    $self->{debug__} = $debug;
}

sub module_config
{
    my ( $self, $module, $item, $value ) = @_;

    return $self->{components__}{core}{config}->module_config_( $module, $item, $value );
}

1;

