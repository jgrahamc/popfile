#----------------------------------------------------------------------------
#
# This is POPFile's top level Module object.
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
#----------------------------------------------------------------------------

package POPFile::Module;

use strict;
use IO::Select;

# ---------------------------------------------------------------------------------------------
#
# This module implements the base class for all POPFile Loadable Modules and
# contains collection of methods that are common to all POPFile modules and only
# selected ones need be overriden by subclasses
#
# POPFile is constructed from a collection of classes which all have special
# PUBLIC interface functions:
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
# prefork()    - called when a module has requested a fork, but before the fork happens
#
# forked()     - called when a module has forked the process.  This is called within the child
#                process and should be used to clean up
#
# postfork()   - called in the parent process to tell it that the fork has occurred.  This is
#                like forked but in the parent
#
# reaper()     - called when a process has terminated to give a module a chance to do
#                whatever clean up is needed
#
# name()       - returns a simple name for the module by which other modules can get access
#                through the %components hash.  The name returned here will be the name
#                used as the key for this module in %components
#
# deliver()    - called by the message queue to deliver a message
#
# The following methods are PROTECTED and should be accessed by sub classes:
#
# log_()       - sends a string to the logger
#
# config_()    - gets or sets a configuration parameter for this module
#
# mq_post_()   - post a message to the central message queue
#
# mq_register_() register for messages from the message queue
#
# slurp_()       Reads a line up to CR, CRLF or LF
#
# register_configuration_item_() register a UI configuration item
#
# A note on the naming
#
# A method or variable that ends with an underscore is PROTECTED and should not be accessed
# from outside the class (or subclass; in C++ its protected), to access a PROTECTED variable
# you will find an equivalent getter/setter method with no underscore.
#
# Truly PRIVATE variables are indicated by a double underscore at the end of the name and
# should not be accessed outside the class without going through a getter/setter and may
# not be directly accessed by a subclass.
#
# For example
#
# $c->foo__() is a private method
# $c->{foo__} is a private variable
# $c->foo_() is a protected method
# $c->{foo_} is a protected variable
# $c->foo() is a public method that modifies $c->{foo_} it always returns the current
# value of the variable it is referencing and if passed a value sets that corresponding
# variable
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

# This variable is CLASS wide, not OBJECT wide and is used as temporary storage
# for the slurp_ methods below.  It needs to be class wide because different objects
# may call slurp on the same handle as the handle gets passed from object to
# object.

my %slurp_data__;

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

    $self->{configuration__} = 0; # PRIVATE

    # A reference to the POPFile::Logger module

    $self->{logger__}        = 0; # PRIVATE

    # A reference to the POPFile::MQ module

    $self->{mq__}            = 0;

    # The name of this module

    $self->{name__}          = ''; # PRIVATE

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
# 0 then POPFile will abort loading immediately, returns 2 if everything OK but this
# module does not want to continue to be used.
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
# prefork
#
# This is called when some module is about to fork POPFile
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub prefork
{
    my ( $self ) = @_;
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

# ---------------------------------------------------------------------------------------------
#
# postfork
#
# This is called when some module has just forked POPFile.  It is called in the parent
# process.
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub postfork
{
    my ( $self ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, $message, $parameter ) = @_;
}

# ---------------------------------------------------------------------------------------------
#
# log_
#
# Called by a subclass to send a message to the logger, the logged message will be prefixed
# by the name of the module in use
#
# $message           The message to log
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub log_
{
    my ( $self, $message ) = @_;

    $self->{logger__}->debug( $self->{name__} . ': ' . $message );
}

# ---------------------------------------------------------------------------------------------
#
# config_
#
# Called by a subclass to get or set a configuration parameter
#
# $name              The name of the parameter (e.g. 'port')
# $value             (optional) The value to set
#
# If called with just a $name then config_() will return the current value
# of the configuration parameter.
#
# ---------------------------------------------------------------------------------------------
sub config_
{
    my ( $self, $name, $value ) = @_;

    return $self->module_config_( $self->{name__}, $name, $value );
}

# ---------------------------------------------------------------------------------------------
#
# mq_post_
#
# Called by a subclass to post a message to the message queue
#
# $type              Type of message to send
# $message           Message to send
# $parameter         Message parameters
#
# ---------------------------------------------------------------------------------------------
sub mq_post_
{
    my ( $self, $type, $message, $parameter ) = @_;

    return $self->{mq__}->post( $type, $message, $parameter );
}

# ---------------------------------------------------------------------------------------------
#
# mq_register_
#
# Called by a subclass to register with the message queue for messages
#
# $type              Type of message to send
# $object            Callback object
#
# ---------------------------------------------------------------------------------------------
sub mq_register_
{
    my ( $self, $type, $object ) = @_;

    return $self->{mq__}->register( $type, $object );
}

# ---------------------------------------------------------------------------------------------
#
# global_config_
#
# Called by a subclass to get or set a global (i.e. not module specific) configuration parameter
#
# $name              The name of the parameter (e.g. 'port')
# $value             (optional) The value to set
#
# If called with just a $name then global_config_() will return the current value
# of the configuration parameter.
#
# ---------------------------------------------------------------------------------------------
sub global_config_
{
    my ( $self, $name, $value ) = @_;

    return $self->module_config_( 'GLOBAL', $name, $value );
}

# ---------------------------------------------------------------------------------------------
#
# module_config_
#
# Called by a subclass to get or set a module specific configuration parameter
#
# $module            The name of the module that owns the parameter (e.g. 'pop3')
# $name              The name of the parameter (e.g. 'port')
# $value             (optional) The value to set
#
# If called with just a $module and $name then module_config_() will return the current value
# of the configuration parameter.
#
# ---------------------------------------------------------------------------------------------
sub module_config_
{
    my ( $self, $module, $name, $value ) = @_;

    return $self->{configuration__}->parameter( $module . "_" . $name, $value );
}

# ---------------------------------------------------------------------------------------------
#
# register_configuration_item_
#
# Called by a subclass to register a UI element
#
# $type, $name, $object     See register_configuration_item in UI::HTML
#
# ---------------------------------------------------------------------------------------------
sub register_configuration_item_
{
    my ( $self, $type, $name, $object ) = @_;

    return $self->mq_post_( 'UIREG', "$type:$name", $object );
}

# ---------------------------------------------------------------------------------------------
#
# get_user_path_, get_root_path_
#
# Wrappers for POPFile::Configuration get_user_path and get_root_path
#
# $path             The path to modify
#
# ---------------------------------------------------------------------------------------------
sub get_user_path_
{
    my ( $self, $path ) = @_;

    return $self->{configuration__}->get_user_path( $path );
}

sub get_root_path_
{
    my ( $self, $path ) = @_;

    return $self->{configuration__}->get_root_path( $path );
}

# ---------------------------------------------------------------------------------------------
#
# flush_slurp_data__
#
# Helper function for slurp_ that returns an empty string if the slurp buffer doesn't
# contain a complete line, or returns a complete line.
#
# $handle            Handle to read from, which should be in binmode
#
# ---------------------------------------------------------------------------------------------
sub flush_slurp_data__
{
    my ( $self, $handle ) = @_;

    # The acceptable line endings are CR, CRLF or LF.  So we look for
    # them using these regexps.

    # Look for LF

    if ( $slurp_data__{"$handle"}{data} =~ s/^([^\015\012]*\012)// ) {
        return $1;
    }

    # Look for CRLF

    if ( $slurp_data__{"$handle"}{data} =~ s/^([^\015\012]*\015\012)// ) {
        return $1;
    }

    # Look for CR, here we have to be careful because of the fact that the current
    # total buffer could be ending with CR and there could actually be an LF to
    # read, so we check for that situation if we find CR

    if ( $slurp_data__{"$handle"}{data} =~ s/^([^\015\012]*\015)// ) {
        my $cr = $1;

        # If we have removed everything from the buffer then see if there's
        # another character available to read, if there is then get it and check
        # to see if it is LF (in which case this is a line ending CRLF), otherwise
        # just save it

        if ( $slurp_data__{"$handle"}{data} eq '' ) {

            # This unpleasant boolean is to handle the case where we are slurping
            # a non-socket stream under Win32

            if ( ( ( $handle !~ /socket/i ) && ( $^O eq 'MSWin32' ) ) ||        # PROFILE BLOCK START
                 defined( $slurp_data__{"$handle"}{select}->can_read(0.1) ) ) { # PROFILE BLOCK STOP
                                                                               
                my $c;
                my $retcode = sysread( $handle, $c, 1 );
                if ( $retcode == 1 ) {
                    if ( $c eq "\012" ) {
                        $cr .= $c;
                    } else {
                        $slurp_data__{"$handle"}{data} = $c;
		    }
		}
	    }
	}

        return $cr;
    }

    return '';
}

# ---------------------------------------------------------------------------------------------
#
# slurp_data_size__
#
# $handle          A connection handle previously used with slurp_
#
# Returns the length of data currently buffered for the passed in handle
#
# ---------------------------------------------------------------------------------------------

sub slurp_data_size__
{
    my ( $self, $handle ) = @_;

    return defined($slurp_data__{"$handle"}{data})?length($slurp_data__{"$handle"}{data}):0;
}

# ---------------------------------------------------------------------------------------------
#
# slurp_buffer_
#
# $handle                     Handle to read from, which should be in binmode
# $length                     The amount of data to read
#
# Reads up to $length bytes from $handle and returns it, if there is nothing
# to return because the buffer is empty and the handle is at eof then this
# will return undef
#
# ---------------------------------------------------------------------------------------------

sub slurp_buffer_
{
    my ( $self, $handle, $length ) = @_;

    while ( $self->slurp_data_size__( $handle ) < $length ) {
        my $c;
        if ( sysread( $handle, $c, $length ) > 0 ) {
            $slurp_data__{"$handle"}{data} .= $c;
	} else {
            last;
	}
    }

    my $result = '';

    if ( $self->slurp_data_size__( $handle ) < $length ) {
        $result = $slurp_data__{"$handle"}{data};
        $slurp_data__{"$handle"}{data} = '';
    } else {
        $result = substr( $slurp_data__{"$handle"}{data}, 0, $length );
        $slurp_data__{"$handle"}{data} = substr( $slurp_data__{"$handle"}{data}, $length );
    }

    return ($result ne '')?$result:undef;
}

# ---------------------------------------------------------------------------------------------
#
# slurp_
#
# A replacement for Perl's <> operator on a handle that reads a line until CR, CRLF or LF
# is encountered.  Returns the line if read (with the CRs and LFs), or undef if at the EOF,
# blocks waiting for something to read.
#
# IMPORTANT NOTE: If you don't read to the end of the stream using slurp_ then there may be
#                 a small memory leak caused by slurp_'s buffering of data in the Module's
#                 hash.   To flush it make a call to slurp_ when you know that the handle is
#                 at the end of the stream, or call done_slurp_ on the handle.
#
# $handle            Handle to read from, which should be in binmode
#
# ---------------------------------------------------------------------------------------------
sub slurp_
{
    my ( $self, $handle ) = @_;

    if ( !defined( $slurp_data__{"$handle"}{data} ) ) {
        $slurp_data__{"$handle"}{select} = new IO::Select( $handle );
        $slurp_data__{"$handle"}{data}   = '';
    }

    my $result = $self->flush_slurp_data__( $handle );

    if ( $result ne '' ) {
        return $result;
    }

    my $c;

    while ( sysread( $handle, $c, 160 ) > 0 ) {
        $slurp_data__{"$handle"}{data} .= $c;

        $result = $self->flush_slurp_data__( $handle );

        if ( $result ne '' ) {
            return $result;
        }
    }

    # If we get here with something in line then the file ends without any
    # CRLF so return the line, otherwise we are reading at the end of the
    # stream/file so return undef

    my $remaining = $slurp_data__{"$handle"}{data};
    $self->done_slurp_( $handle );

    if ( $remaining eq '' ) {
        return undef;
    } else {
        return $remaining;
    }
}

# ---------------------------------------------------------------------------------------------
#
# done_slurp_
#
# Call this when have finished calling slurp_ on a handle and need to clean up temporary
# buffer space used by slurp_
#
# ---------------------------------------------------------------------------------------------

sub done_slurp_
{
    my ( $self, $handle ) = @_;

    delete $slurp_data__{"$handle"}{select};
    delete $slurp_data__{"$handle"}{data};
    delete $slurp_data__{"$handle"};
}

# ---------------------------------------------------------------------------------------------
#
# flush_extra_ - Read extra data from the mail server and send to client, this is to handle
#               POP servers that just send data when they shouldn't.  I've seen one that sends
#               debug messages!
#
#               Returns the extra data flushed
#
# $mail        The handle of the real mail server
# $client      The mail client talking to us
# $discard     If 1 then the extra output is discarded
#
# ---------------------------------------------------------------------------------------------
sub flush_extra_
{
    my ( $self, $mail, $client, $discard ) = @_;

    $discard = 0 if ( !defined( $discard ) );

    # If slurp has any data, we want it
    if ( $self->slurp_data_size__($mail) ) {

        print $client $slurp_data__{"$mail"}{data} if ( $discard != 1 );
        $slurp_data__{"$mail"}{data} = '';
    }

    # Do we always attempt to read?

    my $always_read = 0;
    my $selector;

    if (($^O eq 'MSWin32') && !($mail =~ /socket/i) ) {
        # select only works reliably on IO::Sockets in Win32, so we always read files
        # on MSWin32 (sysread returns 0 for eof)
                          
        $always_read = 1; # PROFILE PLATFORM START MSWin32
                          # PROFILE PLATFORM STOP
    } else {

        # in all other cases, a selector is used to decide whether to read

        $selector    = new IO::Select( $mail );
        $always_read = 0;
    }

    my $ready;

    my $buf        = '';
    my $full_buf   = '';
    my $max_length = 8192;
    my $n;

    while ( $always_read || defined( $selector->can_read(0.01) ) ) {
        $n = sysread( $mail, $buf, $max_length, length $buf );

        if ( $n > 0 ) {
            print $client $buf if ( $discard != 1 );
            $full_buf .= $buf;
        } else {
            if ($n == 0) {
                last;
	    }
        }
    }

   return $full_buf;
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

sub mq
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{mq__} = $value;
    }

    return $self->{mq__};
}

sub configuration
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{configuration__} = $value;
    }

    return $self->{configuration__};
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
        $self->{logger__} = $value;
    }

    return $self->{logger__};
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

sub name
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{name__} = $value;
    }

    return $self->{name__};
}

sub version
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{version_} = $value;
    }

    return $self->{version_};
}

sub last_ten_log_entries
{
    my ( $self ) = @_;

    return $self->{logger__}->last_ten();
}

1;

