# ---------------------------------------------------------------------------------------------
#
# Tests for insert.pl
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
test_assert( `rm -rf corpus/CVS` == 0 );

unlink 'stopwords';
test_assert( `cp stopwords.base stopwords` == 0 );

my $insert = 'perl -I ../ ../insert.pl';

# One or no command line arguments

$code = system( "$insert > temp.tmp" );
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
my $line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'insert mail messages into' );

$code = system( "$insert personal > temp.tmp" );
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'insert mail messages into' );

# Bad bucket name

$code = system( "$insert none temp.tmp 2> temp.tmp 1> temp2.tmp" );
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: Bucket `none\' does not exist, insert aborted' );

# Bad file name

$code = system( "$insert personal doesnotexist 2> temp.tmp 1> temp2.tmp" );
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: File `doesnotexist\' does not exist, insert aborted' );

# Check that insertion actually works

my %words;

open WORDS, "<TestMailParse021.wrd";
while ( <WORDS> ) {
    if ( /(.+) (\d+)/ ) {
        $words{$1} = $2;
    }
}
close WORDS;

$code = system( "$insert personal TestMailParse021.msg 2> temp.tmp 1> temp2.tmp" );
test_assert( $code == 0 );
open TEMP, "<temp2.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Added 1 files to `personal\'' );

use Classifier::Bayes;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

$b->configuration( $c );
$b->mq( $mq );
$b->logger( $l );

$b->module_config_( 'html', 'language', 'English' );

$b->initialize();

test_assert( $b->start() );

foreach my $word (keys %words) {
    test_assert_equal( $b->get_base_value_( 'personal', $word ), $words{$word}, "personal: $word $words{$word}" );
}

$b->stop();



