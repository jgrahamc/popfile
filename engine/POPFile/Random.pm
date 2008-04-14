package POPFile::Random;

#----------------------------------------------------------------------------
#
# This is a module to generate random strings using the Crypt::Random or
# the Crypt::OpenSSL::Random Perl modules.
#
# Copyright (c) 2001-2008 John Graham-Cumming
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
#----------------------------------------------------------------------------

use strict;

#----------------------------------------------------------------------------
# new
#
#   Returns the module itself
#
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self;

    $self->{name__} = "random";

    return bless $self, $type;
}

#----------------------------------------------------------------------------
#
# generate_random_string
#
#   Returns length $length of random string.
#
# $length       Length of the string
# $module       The module to use to generate the random string
# $strength     The Strength value ( used only if using Crypt::Random )
# $device       The Device value ( used only if using Crypt::Random )
#
#----------------------------------------------------------------------------
sub generate_random_string
{
    my ( $self, $module, $length, $strength, $device    ) = @_;

    if ( defined($module) && ( $module eq 'Crypt::Random' ) ) {
        require Crypt::Random;

        return Crypt::Random::makerandom_octet(
                    Length   => $length,
                    Strength => $strength,
                    Device   => $device,
               );
    }

    if ( defined($module) && ( $module eq 'Crypt::OpenSSL::Random' ) ) {
        require Crypt::OpenSSL::Random;

        return Crypt::OpenSSL::Random::random_bytes( $length );
    }

    my $result = '';

    for (1 .. $length) {
        my $random = chr( int( rand(255) ) + 1 );

        $result .= $random;
    }
    return $result;
}

#----------------------------------------------------------------------------
#
# rand_seed
#
#   Give a random seed to the module
#
#----------------------------------------------------------------------------
sub rand_seed
{
    my ( $self,
         $seed ) = @_;

    my $module = $self->global_config_( 'random_module' );

    if ( defined($module) && $module eq 'Crypt::OpenSSL::Random' ) {
        require Crypt::OpenSSL::Random;

        Crypt::OpenSSL::Random::random_seed( $seed );
    }
}

1;
