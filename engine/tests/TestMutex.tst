# ----------------------------------------------------------------------------
#
# Tests for Mutex.pm
#
# Copyright (c) 2003-2004 John Graham-Cumming
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
# ----------------------------------------------------------------------------

use POPFile::Mutex;

my $m1 = new POPFile::Mutex( 'first' );
my $m2 = new POPFile::Mutex( 'first' );
my $m3 = new POPFile::Mutex( 'second' );

test_assert( $m1->acquire() );
test_assert( ( -e 'popfile_mutex_first.mtx' ) );
$m1->release();
test_assert( !( -e 'popfile_mutex_first.mtx' ) );
test_assert( $m1->acquire() );
test_assert( ( -e 'popfile_mutex_first.mtx' ) );
$m1->release();
test_assert( !( -e 'popfile_mutex_first.mtx' ) );
test_assert( $m1->acquire() );
test_assert( ( -e 'popfile_mutex_first.mtx' ) );
test_assert( !$m1->acquire() );
test_assert( ( -e 'popfile_mutex_first.mtx' ) );
test_assert( $m3->acquire() );
test_assert( ( -e 'popfile_mutex_second.mtx' ) );
test_assert( !$m2->acquire(1) );
test_assert( ( -e 'popfile_mutex_first.mtx' ) );
$m1->release();
test_assert( !( -e 'popfile_mutex_first.mtx' ) );
$m2->release();
test_assert( !( -e 'popfile_mutex_first.mtx' ) );
$m3->release();
test_assert( !( -e 'popfile_mutex_second.mtx' ) );
