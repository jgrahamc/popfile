# ---------------------------------------------------------------------------------------------
#
# Tests for pipe.pl
#
# Copyright (c) 2003 John Graham-Cumming
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
# ---------------------------------------------------------------------------------------------

test_assert( `rm -rf messages` == 0 );
test_assert( `rm -rf corpus` == 0 );
test_assert( `cp -R corpus.base corpus` == 0 );
unlink 'popfile.db';
unlink 'popfile.cfg';
test_assert( `rm -rf corpus/CVS` == 0 );

unlink 'stopwords';
test_assert( `cp stopwords.base stopwords` == 0 );

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

my $modify_file = 'TestMailParse021.msg';
$code = system( "cat TestMailParse021.msg | $pipe > temp.tmp" ); # Done once to force the bucket upgrade
$code = system( "cat TestMailParse021.msg | $pipe > temp.tmp" );
test_assert( $code == 0 );
my $output_file = $modify_file;
$output_file    =~ s/msg/cam/;

open TEMP, "<temp.tmp";
open CAM, "<$output_file";
while ( <TEMP> ) {
    my $output_line = $_;
    my $cam_line    = <CAM>;
    $cam_line =~ s/[\r\n]+/\n/g; # This tests that the network EOL has been removed
    next if ( $output_line =~ /X\-POPFile\-Timeout\-Prevention/ );
    test_assert_equal( $output_line, $cam_line, $modify_file );
}

close CAM;
close TEMP;

1;
