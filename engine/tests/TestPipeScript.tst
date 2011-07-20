# ----------------------------------------------------------------------------
#
# Tests for pipe.pl
#
# Copyright (c) 2001-2011 John Graham-Cumming
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
# ----------------------------------------------------------------------------


my $pipe = 'perl -I ../ ../pipe.pl';

# Should have no command line options

# grab STDOUT into @stdout
my @stdout  = `$pipe foo bar baz`;

# our return code is recoverable here
$code = ($? >> 8);

test_assert( $code != 0 );

# pretend we are <>'s across STDOUT
my $line = shift @stdout;

test_assert_regexp( $line, 'reads a message on STDIN, classifies it, outputs the modified version on STDOUT' );

# Try classifying a message

my $modify_file = 'TestMails/TestMailParse021.msg';
$code = system( "$pipe < $modify_file > temp.tmp" ); # Done once to force the bucket upgrade
$code = system( "$pipe < $modify_file > temp.tmp" );
test_assert( $code == 0 );
my $output_file = $modify_file;
$output_file    =~ s/msg/cam/;

open TEMP, "<temp.tmp";
open CAM, "<$output_file";
while ( <TEMP> ) {
    my $output_line = $_;
    my $cam_line    = <CAM>;
    $cam_line =~ s/[\r\n]+/\n/g; # This tests that the network EOL has been removed
    next if ( $output_line =~ /X\-POPFile\-TimeoutPrevention/ );
    $output_line =~ s/view=\d+/view=popfile0=0.msg/;
    $output_line =~ s/[\r\n]+/\n/g if ( $^O eq 'MSWin32' );
    test_assert_equal( $output_line, $cam_line, $modify_file );
}

close CAM;
close TEMP;

unlink 'temp.tmp';

1;
