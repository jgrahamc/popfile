package POPFile::Module;

# ---------------------------------------------------------------------------------------------
#
# This module implements the base class for all POPFile Loadable Modules and
# contains collection of methods that are common to all POPFile modules and only
# selected ones need be overriden by subclasses
#
# POPFile is constructed from a collection of classes which all have special
# interface functions:
#
# initialize() - called after the class is created to set default values for internal
#                variables and global configuration information
#
# start()      - called once all configuration has been read and POPFile is ready to start
#                operating
#
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
# name()       - returns a simple name for the module by which other modules can get access
#                through the %components hash.  The name returned here will be the name
#                used as the key for this module in %components
#
# A note on the naming
#
# A method or variable that ends with an underscore is PRIVATE and should not be accessed
# from outside the class (or subclass; in C++ its protected), to access a PRIVATE variable
# you will find an equivalent getter/setter method with no underscore.
#
# For example
#
# $c->foo_() is a private method
# $c->{foo_} is a private variable
# $c->foo() is a public method that modifies $c->{foo_} it always returns the current
# value of the variable it is referencing and if passed a value sets that corresponding
# variable
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------
# new
#
#   Class new() function, all real work gets done by initialize and 
#   the things set up here are more for documentation purposes than
#   anything so that you know that they exists
#
#----------------------------------------------------------------------------
sub new 
{
    my $type = shift;
    my $self;
    
    # A reference to the POPFile::Configuration module, every module is
    # able to get configuration information through this, note that it
    # is valid when initialize is called, however, the configuration is not
    # read from disk until after initialize has been called
    
    $self->{configuration_}  = 0;

    # A reference to the POPFile::Logger module
    
    $self->{logger_}         = 0;

    # Used to tell any loops to terminate
    
    $self->{alive_}          = 1;

    # This is a reference to the pipeready() function in popfile.pl that it used
    # to determine if a pipe is ready for reading in a cross platform way

    $self->{pipeready_}      = 0;

    # This is a reference to a function (forker) in popfile.pl that performs a fork
    # and informs modules that a fork has occurred
    
    $self->{forker_}         = 0;
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the module, the main task that this function should perform is
# setting up the default values of the configuration options for this object.  This is done
# through the configuration_ hash value that will point the configuration module.
#
# Note that the configuration is not loaded from disk until after every module's initialize
# has been called, so do not use any of these values until start() is called as they may
# change
#
# The method should return 1 to indicate that it initialized correctly, if it returns
# 0 then POPFile will abort loading immediately
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
# Called when all configuration information has been loaded from disk.
#
# The method should return 1 to indicate that it started correctly, if it returns
# 0 then POPFile will abort loading immediately
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
# Called when POPFile is closing down, this is the last method that will get called before
# the object is destroyed.  There is not return value from stop().
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# name
#
# Called to get the simple name for this module, this is the name use to hook various
# module's together in popfile.pl and should be a simple lower case name.  This is the only
# pure abstract function in POPFile::Module and will abort POPFile immediately if ever
# called.
#
# It should return a string containing the proposed name
#
# ---------------------------------------------------------------------------------------------
sub name
{
    my ( $self ) = @_;

    # Pure virtual

    print "\nPOPFile::Module::name called; this function is pure virtual";
    exit(1);
}

# ---------------------------------------------------------------------------------------------
#
# reaper
#
# Called when a child process terminates somewhere in POPFile.  The object should check
# to see if it was one of its children and do any necessary processing by calling waitpid()
# on any child handles it has
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub reaper
{
    my ( $self ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# service() is a called periodically to give the module a chance to do housekeeping work.
#
# If any problem occurs that requires POPFile to shutdown service() should return 0 and
# the top level process will gracefully terminate POPFile including calling all stop()
# methods.  In normal operation return 1.
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
# This is called when some module forks POPFile and is within the context of the child
# process so that this module can close any duplicated file handles that are not needed. 
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;
}

# GETTER/SETTER methods.  Note that I do not expect documentation of these unless they
# are non-trivial since the documentation would be a waste of space
#
# The only thing to note is the idiom used, stick to that and there's no need to
# document these
#
#   sub foo
#   {
#       my ( $self, $value ) = @_;
#       
#       if ( defined( $value ) ) {
#           $self->{foo_} = $value;
#       }
#       
#       return $self->{foo_};
#   }
#
# This method access the foo_ variable for reading or writing, $c->foo() read foo_ and
# $c->foo( 'foo' ) writes foo_

sub configuration
{
    my ( $self, $value ) = @_;
    
    if ( defined( $value ) ) {
        $self->{configuration_} = $value;
    }
    
    return $self->{configuration_};
}

sub forker
{
    my ( $self, $value ) = @_;
    
    if ( defined( $value ) ) {
        $self->{forker_} = $value;
    }
    
    return $self->{forker_};
}

sub logger
{
    my ( $self, $value ) = @_;
    
    if ( defined( $value ) ) {
        $self->{logger_} = $value;
    }
    
    return $self->{logger_};
}

sub pipeready
{
    my ( $self, $value ) = @_;
    
    if ( defined( $value ) ) {
        $self->{pipeready_} = $value;
    }
    
    return $self->{pipeready_};
}

sub alive
{
    my ( $self, $value ) = @_;
    
    if ( defined( $value ) ) {
        $self->{alive_} = $value;
    }
    
    return $self->{alive_};
}

1;
