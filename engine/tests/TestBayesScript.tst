# ----------------------------------------------------------------------------
#
# Tests for bayes.pl
#
# Copyright (c) 2003-2005 John Graham-Cumming
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
# ----------------------------------------------------------------------------

rmtree( 'messages' );
rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
rmtree( 'corpus/CVS' );
test_assert( `rm popfile.db` == 0 );

unlink 'stopwords';
test_assert( copy ( 'stopwords.base', 'stopwords' ) );

my $bayes = 'perl -I ../ ../bayes.pl';

my @stdout;

# One or no command line arguments

@stdout = `$bayes`;

$code = ($? >> 8);

test_assert( $code != 0 );
my $line = shift @stdout;
test_assert_regexp( $line, 'output the classification of a message' );

# Bad file name
open STDERR, ">temp.tmp";
`$bayes doesnotexist`;
close STDERR;
$code = ($? >> 8);
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: File `doesnotexist\' does not exist, classification aborted' );

# Check the output

my %words;

open WORDS, "<TestMailParse021.wrd";
while ( <WORDS> ) {
    if ( /(.+) (\d+)/ ) {
        $words{$1} = $2;
    }
}
close WORDS;

@stdout = `$bayes TestMailParse021.msg`;# 2> temp.tmp 1> temp2.tmp" );

$code = ($? >> 8);
test_assert( $code == 0 );
$line = shift @stdout;
test_assert_regexp( $line, '`TestMailParse021.msg\' is `spam\'' );

my %output;

while ( $_ = shift @stdout ) {
    if ( /(.+) (\d+)/ ) {
        $output{$1} = $2;
    }
}

foreach my $word (keys %words) {
    test_assert_equal( $words{$word}, $output{$word}, $word );
}
foreach my $word (keys %output) {
    test_assert_equal( $words{$word}, $output{$word}, $word );
}

1;
