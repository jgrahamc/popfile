package POPFile::Mutex;

#----------------------------------------------------------------------------
#
# This is a mutex object that uses mkdir() to provide exclusive access
# to a region on a per thread or per process basis.
#
# Copyright (c) 2001-2004 John Graham-Cumming
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

use strict;

#----------------------------------------------------------------------------
# new
#
#   Create a new Mutex object (which may refer to a file referred to by
#   other mutexes) with a specific name generated from the name passed
#   in.
#
#----------------------------------------------------------------------------
sub new
{
    my ( $type, $name ) = @_;
    my $self;

    $self->{name__} = "popfile_mutex_${name}.mtx";
    release( $self );

    return bless $self, $type;
}

#----------------------------------------------------------------------------
#
# acquire
#
#   Returns 1 if it manages to grab the mutex (and will block if necessary)
#   and 0 if it fails.
#
#----------------------------------------------------------------------------
sub acquire
{
    my ( $self,             # Reference to this object
         $timeout ) = @_;   # Timeout in seconds to wait (undef = infinite)

    # If acquire() has been called without a matching release() then
    # fail at once

    if ( defined( $self->{locked__} ) ) {
        return 0;
    }

    # Wait a very long time if no timeout is specified

    $timeout = 0xFFFFFFFF if ( !defined( $timeout ) );
    my $now = time;

    # Try to create a directory during the timeout period

    do {
        if ( mkdir( $self->{name__}, 0755 ) ) { # Create a directory
            $self->{locked__} = 1;
            return 1;
        }
        select( undef, undef, undef, 0.01 );
    } while ( time < ( $now + $timeout ) );

    # Timed out so return 0
    return 0;
}

#----------------------------------------------------------------------------
#
# release
#
#   Release the lock if we acquired it with a call to acquire()
#
#----------------------------------------------------------------------------
sub release
{
    my ( $self ) = @_;

    rmdir( $self->{name__} ); # Delete the Mutex directory
    $self->{locked__} = undef;
}

1;
