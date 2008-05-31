# ----------------------------------------------------------------------------
#
# Tests for Random.pm
#
# Copyright (c) 2003-2008 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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

use POPFile::Random;
use POSIX ":sys_wait_h";

my @random_modules = (
        POPFile::Random->new( 'Crypt::Random' ),
        POPFile::Random->new( 'Crypt::OpenSSL::Random' ),
        POPFile::Random->new( 'Crypt::CBC' ),
);

foreach my $random_module ( @random_modules ) {
    my $has_module = 0;

    $has_module = eval "require $random_module->{module__}; 1;";

    if ( $has_module ) {
        my $rand_string = $random_module->generate_random_string(
                128 );

        test_assert( defined( $rand_string ) );
        test_assert_equal( length( $rand_string ), 128 );

        if ( $random_module->{module__} eq 'Crypt::Random' ) {
            $rand_string = $random_module->generate_random_string(
                    128,
                    1,
                    '' );

            test_assert( defined( $rand_string ) );
            test_assert_equal( length( $rand_string ), 128 );
        };

        if ( $random_module->{module__} eq 'Crypt::OpenSSL::Random' ) {
            $random_module->rand_seed( time );

            my $rand_string = $random_module->generate_random_string(
                    128 );

            test_assert( defined( $rand_string ) );
            test_assert_equal( length( $rand_string ), 128 );
        }
    } else {
        print "Warning: skipping $$random_module->{module__} test since the module is not installed\n";
    }
}
