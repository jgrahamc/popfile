# ---------------------------------------------------------------------------------------------
#
# Tests for MailParse.pm
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

use Classifier::MailParse;
use Classifier::Bayes;
use Classifier::WordMangle;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;

# Load the test corpus
my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;
my $w = new Classifier::WordMangle;

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );

$c->initialize();

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$w->configuration( $c );
$w->mq( $mq );
$w->logger( $l );

$w->start();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

$b->configuration( $c );
$b->mq( $mq );
$b->logger( $l );

$b->{parser__}->mangle( $w );
$b->initialize();
test_assert( $b->start() );

my $cl = new Classifier::MailParse;

$cl->mangle( $w );
# map_color()
test_assert_equal( $cl->map_color( 'red' ),     'ff0000' );
test_assert_equal( $cl->map_color( 'ff0000' ),  'ff0000' );
test_assert_equal( $cl->map_color( 'FF0000' ),  'ff0000' );
test_assert_equal( $cl->map_color( '#fF0000' ), 'ff0000' );
test_assert_equal( $cl->map_color( '#Ff0000' ), 'ff0000' );
test_assert_equal( $cl->map_color( 'white' ),   'ffffff' );
test_assert_equal( $cl->map_color( 'fFfFFf' ),  'ffffff' );
test_assert_equal( $cl->map_color( 'FFFFFF' ),  'ffffff' );
test_assert_equal( $cl->map_color( '#ffffff' ), 'ffffff' );
test_assert_equal( $cl->map_color( '#FFfFFF' ), 'ffffff' );

# Check line splitting into words
$cl->{htmlbackcolor__} = $cl->map_color( 'white' );
$cl->{htmlfontcolor__} = $cl->map_color( 'black' );
$cl->{words__}       = {};
$cl->add_line( 'this is a test of,adding words: from a line of text!', 0, '' );
test_assert_equal( $cl->{words__}{test},   1 );
test_assert_equal( $cl->{words__}{adding}, 1 );
test_assert_equal( $cl->{words__}{words},  1 );
test_assert_equal( $cl->{words__}{line},   1 );
test_assert_equal( $cl->{words__}{text},   1 );
$cl->add_line( 'adding', 0, '' );
test_assert_equal( $cl->{words__}{adding}, 2 );

# Check that we correctly handle spaced out and dotted word
$cl->{words__}         = {};
$cl->add_line( 'T H I S  T E X T  I S  S P A C E D alot', 0, '' );
test_assert_equal( $cl->{words__}{text},   1 );
test_assert_equal( $cl->{words__}{spaced}, 1 );
test_assert_equal( $cl->{words__}{alot},   1 );
$cl->{words__}         = {};
$cl->add_line( 'offer a full 90 day m.oney b.ack g.uarantee.  If any customer is not. C.lick b.elow f.or m.ore i.nformation, it\'s f.r.e.e.', 0, '' );
test_assert_equal( $cl->{words__}{offer},     1 );
test_assert_equal( $cl->{words__}{full},      1 );
test_assert_equal( $cl->{words__}{money},     1 );
test_assert_equal( $cl->{words__}{back},      1 );
test_assert_equal( $cl->{words__}{customer},  1 );
test_assert_equal( $cl->{words__}{'trick:dottedwords'}, 6 );
test_assert_equal( $cl->{words__}{click},     1 );
test_assert_equal( $cl->{words__}{below},     1 );
test_assert_equal( $cl->{words__}{more},      1 );

# Check discovery of font color
$cl->{htmlfontcolor__} = '';
test_assert_equal( $cl->parse_html( '<font color="white">' ), 0 );
test_assert_equal( $cl->{htmlfontcolor__}, $cl->map_color( 'white' ) );
$cl->{htmlfontcolor__} = '';
test_assert_equal( $cl->parse_html( '<font color=red>' ), 0 );
test_assert_equal( $cl->{htmlfontcolor__}, $cl->map_color( 'red' ) );
$cl->{htmlfontcolor__} = '';
test_assert_equal( $cl->parse_html( '<font color=#008000>' ), 0 );
test_assert_equal( $cl->{htmlfontcolor__}, $cl->map_color( 'green' ) );
$cl->{htmlfontcolor__} = '';
test_assert_equal( $cl->parse_html( '<font color=#00ff00></font>' ), 0 );
test_assert_equal( $cl->{htmlfontcolor__}, $cl->map_color( 'black' ) );

# Check comment detection
$cl->{words__}         = {};
test_assert_equal( $cl->parse_html( '<!-- foo -->' ), 0 );
test_assert_equal( $cl->parse_html( '<!-- -->' ), 0 );
test_assert_equal( $cl->parse_html( '<!---->' ), 0 );
test_assert_equal( $cl->{words__}{'html:comment'}, 3 );
# Check that we don't think the DOCTYPE is a comment
test_assert_equal( $cl->parse_html( '<!DOCTYPE >' ), 0 );
# test_assert_equal( $cl->{words__}{'html:comment'}, 3 );

# Check invisible ink detection
$cl->{htmlfontcolor__} = '';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;
test_assert_equal( $cl->parse_html( '<body bgcolor="#ffffff">hello <font color=white>invisible</font>visible</body>  ' ), 0 );
test_assert_equal( $cl->{words__}{hello},     1 );
test_assert_equal( $cl->{words__}{visible},   1 );
test_assert_equal( defined( $cl->{words__}{invisible} ), '' );
$cl->{htmlfontcolor__} = '';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;
test_assert_equal( $cl->parse_html( '   <body bgcolor="#ffffff">  hello<font color=white>' ), 0 );
test_assert_equal( $cl->parse_html( '  invisible </font>'                                ), 0 );
test_assert_equal( $cl->parse_html( 'visible</body>'                                  ), 0 );
test_assert_equal( $cl->{words__}{hello},     1 );
test_assert_equal( $cl->{words__}{visible},   1 );
test_assert_equal( defined( $cl->{words__}{invisible} ), '' );
$cl->{htmlfontcolor__} = '';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;
test_assert_equal( $cl->parse_html( '<body bgcolor="#ffffff">hello  <font' ), 1 );
test_assert_equal( $cl->parse_html( 'color=white>invisible </font>'       ), 0 );
test_assert_equal( $cl->parse_html( 'visible    </body>'                     ), 0 );
test_assert_equal( $cl->{words__}{hello},     1 );
test_assert_equal( $cl->{words__}{visible},   1 );
test_assert_equal( defined( $cl->{words__}{invisible} ), '' );

# glob the tests directory for files called TestMailParse\d+.msg which consist of messages
# to be parsed with the resulting values for the words hash in TestMailParse\d+.wrd

my @parse_tests = sort glob 'TestMailParse*.msg';

for my $parse_test (@parse_tests) {
    my $words = $parse_test;
    $words    =~ s/msg/wrd/;

    # Parse the document and then check the words hash against the words in the
    # wrd file

    $cl->parse_file( $parse_test );

    open WORDS, "<$words";
    while ( <WORDS> ) {
        if ( /^(.+) (\d+)/ ) {
            my ( $word, $value ) = ( $1, $2 );
            test_assert_equal( $cl->{words__}{$word}, $value, "$words $word $value" );
            delete $cl->{words__}{$word};
        }
    }
    close WORDS;

    foreach my $missed (keys %{$cl->{words__}}) {
        test_assert( 0, "$missed $cl->{words__}{$missed} missing in $words" );
        delete $cl->{words__}{$missed};
    }
}

# Check that from, to and subject get set correctly when parsing a message
$cl->parse_file( 'TestMailParse013.msg' );
test_assert_equal( $cl->{from__},    'RN <rrr@nnnnnnnnn.com>'                        );
test_assert_equal( $cl->{to__},      '"Armlet Forum" <armlet-forum@news.palmos.com>' );
test_assert_equal( $cl->{subject__}, '(Archive Copy) RE: CW v9 and armlets...'       );
$cl->parse_file( 'TestMailParse018.msg' );
$cl->{to__} =~ /(\Qbugtracker\E@\Qrelativity.com\E)/;
test_assert_equal( $1, 'bugtracker@relativity.com' );
$cl->parse_file( 'TestMailParse019.msg' );
$cl->{to__} =~ /(\Qbugtracker\E@\Qrelativity.com\E)/;
test_assert_equal( $1, 'bugtracker@relativity.com' );

# Check that multi-line To: and CC: headers get handled properly
$cl->parse_file( 'TestMailParse021.msg' );
$cl->{to__} =~ s/[\r\n]//g;
test_assert_equal( $cl->{to__},      'dsmith@ctaz.com, dsmith@dol.net, dsmith@dirtur.com, dsmith@dialpoint.net, dsmith@crosscountybank.com, 	<dsmith@cybersurf.net>, <dsmith@dotnet.com>, <dsmith@db.com>, <dsmith@cs.com>	, <dsmith@crossville.com>, 	<dsmith@dreamscape.com>, <dsmith@cvnc.net>, <dsmith@dmrtc.net>, <dsmith@datarecall.net>, 	<dsmith@dasia.net>' );
$cl->{cc__} =~ s/[\r\n]//g;
test_assert_equal( $cl->{cc__},      'dsmith@dmi.net, dsmith@datamine.net, dsmith@crusader.com, dsmith@datasync.com, 	<dsmith@doorpi.net>, <dsmith@dnet.net>, <dsmith@cybcon.com>, <dsmith@csonline.net>, 	<dsmith@directlink.net>, <dsmith@cvip.net>, <dsmith@dragonbbs.com>, <dsmith@crosslinkinc.com>, 	<dsmith@dccnet.com>, <dsmith@dakotacom.net>' );

# Test colorization

my @color_tests = ( 'TestMailParse015.msg', 'TestMailParse019.msg' );

for my $color_test (@color_tests) {
    my $colored = $color_test;
    $colored    =~ s/msg/clr/;

    $cl->{color__} = 1;
    $cl->{bayes__} = $b;
    my $html = $cl->parse_file( $color_test );

    open HTML, "<$colored";
    my $check = <HTML>;
    $check =~ s/[\r\n]*//g;
    close HTML;
    test_assert_equal( $check, $html, $color_test );

    if ( $check ne $html ) {
        open FILE, ">$color_test.expecting.html";
        print FILE $check;
        close FILE;
        open FILE, ">$color_test.got.html";
        print FILE $html;
        close FILE;
    }
}

$cl->{color__} = 0;

# test decode_string

test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo?="), "foo");
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo_bar?="), "foo bar");
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo=20bar?="), "foo bar");
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo_bar?= =?ISO-8859-1?Q?foo_bar?="), "foo bar foo bar");
test_assert_equal($cl->decode_string("=?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= =?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?="), "Aladdin:open sesame Aladdin:open sesame");

# test get_header

$cl->parse_file( 'TestMailParse022.msg' );
test_assert_equal( $cl->get_header( 'from', 'test@test.com' ) );
test_assert_equal( $cl->get_header( 'to', 'someone@somewhere.com' ) );
test_assert_equal( $cl->get_header( 'cc', 'someoneelse@somewhere.com' ) );
test_assert_equal( $cl->get_header( 'subject', 'test for various HTML parts' ) );

# test quickmagnets

my %qm = %{$cl->quickmagnets()};
my @from = @{$qm{from}};
my @to = @{$qm{to}};
my @cc = @{$qm{cc}};
my @subject = @{$qm{subject}};
test_assert_equal( $#from, 1 );
test_assert_equal( $from[0], 'test@test.com' );
test_assert_equal( $from[1], 'test.com' );
test_assert_equal( $#to, 1 );
test_assert_equal( $to[0], 'someone@somewhere.com' );
test_assert_equal( $to[1], 'somewhere.com' );
test_assert_equal( $#cc, 1 );
test_assert_equal( $cc[0], 'someoneelse@somewhere.com' );
test_assert_equal( $cc[1], 'somewhere.com' );
test_assert_equal( $#subject, 2 );
test_assert_equal( $subject[0], 'test' );
test_assert_equal( $subject[1], 'various' );
test_assert_equal( $subject[2], 'parts' );

# test first20

$cl->parse_file( 'TestMailParse022.msg' );
test_assert_equal( $cl->first20(), ' This is the title image' );
$cl->parse_file( 'TestMailParse021.msg' );
test_assert_equal( $cl->first20(), ' Take Control of Your Computer With This Top of the Line Software Norton SystemWorks Software Suite Professional Edition Includes Six' );

# test splitline quoted-printable handling

test_assert_equal( $cl->splitline( '=3Chtml=3E', 'quoted-Printable' ), '&lt;html&gt;' );
test_assert_equal( $cl->splitline( '=3Chtml=3E', '' ), '=3Chtml=3E' );

# Test the CRLF is preserved in QP encoding

open FILE, ">temp.tmp";
print FILE "From: John\n\n<img width=42\nheight=41>\n";
close FILE;
$cl->parse_file( 'temp.tmp' );
test_assert_equal( $cl->{words__}{'html:imgwidth42'}, 1 );
test_assert_equal( $cl->{words__}{'html:imgheight41'}, 1 );

open FILE, ">temp.tmp";
print FILE "From: John\nContent-Type: multipart/alternative;\n\tboundary=\"247C6_.5B._4\"\n\n--247C6_.5B._4\nContent-Type: text/html;\nContent-Transfer-Encoding: quoted-printable\n\n<img width=3D42\nheight=3D41>\n\n--247C6_.5B._4--\n";
close FILE;
$cl->parse_file( 'temp.tmp' );
test_assert_equal( $cl->{words__}{'html:imgwidth42'}, 1 );
test_assert_equal( $cl->{words__}{'html:imgheight41'}, 1 );

$b->stop();
