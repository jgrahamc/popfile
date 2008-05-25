package Config_ub;

require ExtUtils::FakeConfig;

my $SDK = '/Developer/SDKs/MacOSX10.4u.sdk';

my %params = (
    ccflags => "-Os -g -pipe -fno-common -DPERL_DARWIN -no-cpp-precomp -arch i686 -arch ppc750 -B$SDK/usr/include/gcc -B$SDK/usr/lib/gcc -isystem$SDK/usr/include -F$SDK/System/Library/Frameworks -fno-strict-aliasing -I/usr/local/include -I../kakasi-2.3.4/lib",
    ldflags => "-arch i386 -arch ppc750 -Wl,-syslibroot,$SDK -L/usr/local/lib",
    lddlflags => "-bundle -undefined dynamic_lookup -arch i386 -arch ppc750 -Wl,-syslibroot,$SDK -L/usr/local/lib -L../kakasi-2.3.4/lib/.libs -lkakasi"
);

eval 'use ExtUtils::FakeConfig %params';

1;
