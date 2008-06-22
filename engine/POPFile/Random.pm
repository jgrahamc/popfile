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
# $module       The module to use to generate the random string
#
#----------------------------------------------------------------------------
sub new
{
    my ( $type, $module ) = @_;
    my $self;

    $self->{name__} = "random";
    $self->{module__} = 'Crypt::Random';

    if ( defined( $module ) ) {
        $module = 'Crypt::' . $module if ( $module !~ /^Crypt::/ );

        if ( ( $module eq 'Crypt::Random' ) ||          # PROFILE BLOCK START
             ( $module eq 'Crypt::OpenSSL::Random' ) ||
             ( $module eq 'Crypt::CBC' ) ) {            # PROFILE BLOCK STOP
            $self->{module__} = $module;
        }
    }

    my $has_module = eval "require $module; 1;";

    if ( $has_module ) {
        return bless $self, $type;
    } else {
        return "could not find required module $module.";
    }
}

#----------------------------------------------------------------------------
#
# generate_random_string
#
#   Returns length $length of random string.
#
# $length       Length of the string
# $strength     The Strength value ( valid only if using Crypt::Random )
# $device       The Device value ( valid only if using Crypt::Random )
#
#----------------------------------------------------------------------------
sub generate_random_string
{
    my ( $self, $length, $strength, $device ) = @_;

    return undef if ( !defined( $self->{module__} ) );
    return undef if ( !defined( $length ) );

    $strength = 0 if ( !defined( $strength ) );
    $device = '' if ( !defined( $device ) );

    if ( $self->{module__} eq 'Crypt::Random' ) {
        require Crypt::Random;

        return Crypt::Random::makerandom_octet(   # PROFILE BLOCK START
                    Length   => $length,
                    Strength => $strength,
                    Device   => $device,
               );                                 # PROFILE BLOCK STOP
    }
    elsif ( $self->{module__} eq 'Crypt::OpenSSL::Random' ) {
        require Crypt::OpenSSL::Random;

        return Crypt::OpenSSL::Random::random_bytes( $length );
    }
    elsif ( $self->{module__} eq 'Crypt::CBC' ) {
        require Crypt::CBC;

        return Crypt::CBC->random_bytes( $length );
    }

    warn "No random module found. Something is wrong";

    return;
}

#----------------------------------------------------------------------------
#
# rand_seed
#
#   Give a random seed to the module
#
#   $seed       A seed
#
#----------------------------------------------------------------------------
sub rand_seed
{
    my ( $self, $seed ) = @_;

    return undef if ( !defined( $self->{module__} ) );

    if ( $self->{module__} eq 'Crypt::OpenSSL::Random' ) {
        require Crypt::OpenSSL::Random;

        Crypt::OpenSSL::Random::random_seed( $seed );
    }
}

1;
