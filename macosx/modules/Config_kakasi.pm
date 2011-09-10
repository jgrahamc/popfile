package Config_ub;

# Copyright (c) John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

require ExtUtils::FakeConfig;

my $PERL_VERSION = $];

my ( $SDK, $MIN_VERSION, $ARCH );

if ( $PERL_VERSION ge '5.010000' ) {
    if ( $PERL_VERSION ge '5.012000' ) {
        # Mac OS X 10.7 or later

        $SDK = '/Developer/SDKs/MacOSX10.7.sdk';
        $MIN_VERSION = '-mmacosx-version-min=10.7';
        $ARCH = '-arch i386 -arch x86_64';
    } else {
        # Mac OS X 10.6 or later

        $SDK = '/Developer/SDKs/MacOSX10.6.sdk';
        $MIN_VERSION = '-mmacosx-version-min=10.6';
        $ARCH = '-arch i386 -arch ppc7400 -arch x86_64';
    }
} else {
    # Mac OS X 10.5.x or earlier

    $SDK = '/Developer/SDKs/MacOSX10.4u.sdk';
    $MIN_VERSION = '-mmacosx-version-min=10.3';
    $ARCH = '-arch i386 -arch ppc750 -arch ppc7400';

}

my %params = (
    ccflags => "-g -pipe -fno-common -DPERL_DARWIN $MIN_VERSION -no-cpp-precomp $ARCH -isysroot $SDK -fno-strict-aliasing -I../kakasi-2.3.4/lib",
    ld => "cc $MIN_VERSION",
    ldflags => "$ARCH -isysroot $SDK -L/usr/local/lib",
    lddlflags => "-bundle -undefined dynamic_lookup $ARCH -isysroot $SDK -L../kakasi-2.3.4/lib/.libs -lkakasi"
);

eval 'use ExtUtils::FakeConfig %params';

1;
