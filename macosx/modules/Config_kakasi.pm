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

my $SDK = '/Developer/SDKs/MacOSX10.4u.sdk';

my %params = (
    ccflags => "-Os -g -pipe -fno-common -DPERL_DARWIN -no-cpp-precomp -arch i686 -arch ppc750 -B$SDK/usr/include/gcc -B$SDK/usr/lib/gcc -isystem$SDK/usr/include -F$SDK/System/Library/Frameworks -fno-strict-aliasing -I/usr/local/include -I../kakasi-2.3.4/lib",
    ldflags => "-arch i386 -arch ppc750 -Wl,-syslibroot,$SDK -L/usr/local/lib",
    lddlflags => "-bundle -undefined dynamic_lookup -arch i386 -arch ppc750 -Wl,-syslibroot,$SDK -L/usr/local/lib -L../kakasi-2.3.4/lib/.libs -lkakasi"
);

eval 'use ExtUtils::FakeConfig %params';

1;
