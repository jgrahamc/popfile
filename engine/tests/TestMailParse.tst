# ----------------------------------------------------------------------------
#
# Tests for MailParse.pm
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

use strict;
use warnings;
use utf8;

use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'Classifier/Bayes' => 1,
              'Classifier/WordMangle' => 1,
              'POPFile/Logger' => 1,
              'POPFile/MQ'     => 1,
              'POPFile/Database'     => 1,
              'POPFile/Configuration' => 1 );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );
$POPFile->CORE_start();

use Classifier::MailParse;
my $cl = new Classifier::MailParse;

$cl->{mangle__} = $POPFile->get_module( 'Classifier/WordMangle' );
$cl->{lang__} = "English";

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

test_assert_equal( $cl->map_color( '#F0F0F0' ), 'f0f0f0' );
test_assert_equal( $cl->map_color( 'F0F0F0' ), 'f0f0f0' );

# flex-hex
test_assert_equal( $cl->map_color( '#FyFyFy' ), 'f0f0f0' );
test_assert_equal( $cl->map_color( 'FtFtFt' ), 'f0f0f0' );

test_assert_equal( $cl->map_color( '#F0F0F' ), 'f0f0f0' );
test_assert_equal( $cl->map_color( 'F0F0F' ), 'f0f0f0' );
test_assert_equal( $cl->map_color( '#FtFuF' ), 'f0f0f0' );
test_assert_equal( $cl->map_color( 'FhFgF' ), 'f0f0f0' );

test_assert_equal( $cl->map_color( '#F0F0' ), 'f0f000' );
test_assert_equal( $cl->map_color( 'F0F0' ), 'f0f000' );
test_assert_equal( $cl->map_color( '#FoFp' ), 'f0f000' );
test_assert_equal( $cl->map_color( 'F&F*' ), 'f0f000' );

# odd size flex-hex (per internet explorer parsing)
test_assert_equal( $cl->map_color( 'f' ), '0f0000' );
test_assert_equal( $cl->map_color( 'ff' ), '0f0f00' );
test_assert_equal( $cl->map_color( 'fff' ), '0f0f0f' );
test_assert_equal( $cl->map_color( 'aa5cfd0c69af132b3e4f' ), 'aac62b' );
test_assert_equal( $cl->map_color( '6db6ec49efd278cd0bc92d1e5e072d68'), '6ecde0' );

test_assert_equal( $cl->{words__}{'trick:flexhex:f'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:fyfyfy'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:f0f0'}, 2 );
test_assert_equal( $cl->{words__}{'trick:flexhex:aa5cfd0c69af132b3e4f'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:fhfgf'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:ftfuf'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:ff'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:fff'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:f0f0f'}, 2 );
test_assert_equal( $cl->{words__}{'trick:flexhex:fofp'}, 1 );
test_assert_equal( $cl->{words__}{'trick:flexhex:f&f*'}, 1 );

# Check line splitting into words
$cl->{htmlbackcolor__} = $cl->map_color( 'white' );
$cl->{htmlfontcolor__} = $cl->map_color( 'black' );
$cl->{words__}       = {};
$cl->{first20count__} = 0;
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
test_assert_equal( $cl->parse_html( '<font color=#00FF00>foo</font>' ), 0 );
test_assert_equal( $cl->{htmlfontcolor__}, $cl->map_color( 'black' ) );
$cl->{htmlfontcolor__} = '';
test_assert_equal( $cl->parse_html( '<font color=#00FF00></font>' ), 0 ); # test for empty tag removal interacting with font tags
test_assert_equal( $cl->{htmlfontcolor__}, '' );

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
$cl->{htmlfontcolor__} = '000000';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;
test_assert_equal( $cl->parse_html( '<body bgcolor="#ffffff">hello <font color=white>invisible</font>visible</body>  ' ), 0 );
test_assert_equal( $cl->{words__}{hello},     1 );
test_assert_equal( $cl->{words__}{visible},   1 );
test_assert_equal( defined( $cl->{words__}{invisible} ), '' );
$cl->{htmlfontcolor__} = '000000';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;
test_assert_equal( $cl->parse_html( '   <body bgcolor="#ffffff">  hello<font color=white>' ), 0 );
test_assert_equal( $cl->parse_html( '  invisible </font>'                                ), 0 );
test_assert_equal( $cl->parse_html( 'visible</body>'                                  ), 0 );
test_assert_equal( $cl->{words__}{hello},     1 );
test_assert_equal( $cl->{words__}{visible},   1 );
test_assert_equal( defined( $cl->{words__}{invisible} ), '' );
$cl->{htmlfontcolor__} = '000000';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;
test_assert_equal( $cl->parse_html( '<body bgcolor="#ffffff">hello  <font' ), 1 );
test_assert_equal( $cl->parse_html( 'color=white>invisible </font>'       ), 0 );
test_assert_equal( $cl->parse_html( 'visible    </body>'                     ), 0 );
test_assert_equal( $cl->{words__}{hello},     1 );
test_assert_equal( $cl->{words__}{visible},   1 );
test_assert_equal( defined( $cl->{words__}{invisible} ), '' );

# CSS tests
$cl->{htmlfontcolor__} = '000000';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;

my $style = $cl->parse_css_style('color: #ff00ff; background: red' );

test_assert_equal( $style->{'color'}, '#ff00ff' );
test_assert_equal( scalar( $cl->parse_css_color($style->{'color'}) ), 'ff00ff' );

test_assert_equal( $style->{'background'}, 'red' );
test_assert_equal( scalar($cl->parse_css_color($style->{'background'})), 'ff0000' );

$style = $cl->parse_css_style( '{ color: #ff00ff ; background : red }', 1 );

test_assert_equal( $style->{'color'}, '#ff00ff' );
test_assert_equal( scalar( $cl->parse_css_color($style->{'color'}) ), 'ff00ff' );

test_assert_equal( $style->{'background'}, 'red' );
test_assert_equal( scalar($cl->parse_css_color($style->{'background'})), 'ff0000' );

my ( $red, $green, $blue ) = $cl->parse_css_color( '#ff00ff' );

test_assert_equal( $red, 255   );
test_assert_equal( $green, 0   );
test_assert_equal( $blue, 255  );

( $red, $green, $blue ) = $cl->parse_css_color( '#f0f' );

test_assert_equal( $red, 255  );
test_assert_equal( $green, 0  );
test_assert_equal( $blue, 255 );

( $red, $green, $blue ) = $cl->parse_css_color( '#ff00f' );

test_assert_equal( $red, -1 );
test_assert_equal( $green, -1 );
test_assert_equal( $blue, -1 );

( $red, $green, $blue ) = $cl->parse_css_color( 'rgb(255,255,255)' );

test_assert_equal( $red, 255 );
test_assert_equal( $green, 255 );
test_assert_equal( $blue, 255 );

( $red, $green, $blue ) = $cl->parse_css_color( 'rgb(300,300,300)' );

test_assert_equal( $red, 255 );
test_assert_equal( $green, 255 );
test_assert_equal( $blue, 255 );

( $red, $green, $blue ) = $cl->parse_css_color( 'rgb(-1,-1,-1)' );

test_assert_equal( $red, 0 );
test_assert_equal( $green, 0 );
test_assert_equal( $blue, 0 );

( $red, $green, $blue ) = $cl->parse_css_color( 'rgb( 0% , 100% , 0% )' );

test_assert_equal( $red, 0 );
test_assert_equal( $green, 255 );
test_assert_equal( $blue, 0 );

( $red, $green, $blue ) = $cl->parse_css_color( 'rgb( 110% , 110% , 110% )' );

test_assert_equal( $red, 255 );
test_assert_equal( $green, 255 );
test_assert_equal( $blue, 255 );

test_assert_equal( scalar( $cl->parse_css_color( 'rgb(1,1,1%)') ), 'error' );

test_assert_equal( scalar( $cl->parse_css_color( 'foo' ) ), 'error' );

( $red, $green, $blue ) = $cl->parse_css_color( 'foo' );

test_assert_equal( $red, -1 );
test_assert_equal( $green, -1 );
test_assert_equal( $blue, -1 );

$cl->parse_html( '<body style="color:#ffffff;background: white">' );
test_assert_equal( $cl->{words__}{'html:cssfontcolorffffff'}, 1 );
test_assert_equal( $cl->{words__}{'html:cssbackcolorffffff'}, 1 );

test_assert_equal( $cl->{cssfontcolortag__}, 'body' );
test_assert_equal( $cl->{cssbackcolortag__}, 'body' );
test_assert_equal( $cl->{htmlfontcolor__}, 'ffffff' );
test_assert_equal( $cl->{htmlbackcolor__}, 'ffffff' );
test_assert_equal( $cl->{htmlbodycolor__}, 'ffffff' );
test_assert_equal( $cl->{htmlcolordistance__}, 0 );

test_assert_equal( $cl->{cssfontcolortag__}, 'body');
test_assert_equal( $cl->{cssbackcolortag__}, 'body');

$cl->parse_html( 'aaaa<a style="visibility:hidden">' );
test_assert_equal( $cl->{words__}{'html:cssvisibilityhidden'}, 1 );
test_assert_equal( $cl->{words__}{'trick:invisibleink'}, 1 );

$cl->parse_html( '</a><div style="display:none">' );
test_assert_equal( $cl->{words__}{'html:cssdisplaynone'}, 1 );

$cl->parse_html( '</div></body>' );

test_assert_equal( $cl->{htmlcolordistance__},  441 );

test_assert_equal( $cl->{cssfontcolortag__}, '' );
test_assert_equal( $cl->{cssbackcolortag__}, '' );
test_assert_equal( $cl->{htmlfontcolor__}, '000000' );
test_assert_equal( $cl->{htmlbackcolor__}, 'ffffff' );
test_assert_equal( $cl->{htmlbodycolor__}, 'ffffff' );

$cl->parse_html( '<P style="color: rgb(0,0,0);background: #010101">' );

test_assert_equal( $cl->{cssfontcolortag__}, 'p' );
test_assert_equal( $cl->{cssbackcolortag__}, 'p' );
test_assert_equal( $cl->{words__}{'html:cssfontcolor000000'}, 1 );
test_assert_equal( $cl->{words__}{'html:cssbackcolor010101'}, 1 );
test_assert_equal( $cl->{htmlcolordistance__}, 1 );
test_assert_equal( $cl->{htmlfontcolor__}, '000000' );
test_assert_equal( $cl->{htmlbackcolor__}, '010101' );

$cl->parse_html( '</P>');

test_assert_equal( $cl->{cssfontcolortag__}, '' );
test_assert_equal( $cl->{cssbackcolortag__}, '' );
test_assert_equal( $cl->{htmlcolordistance__}, 441 );
test_assert_equal( $cl->{htmlfontcolor__}, '000000' );
test_assert_equal( $cl->{htmlbackcolor__}, 'ffffff' );
test_assert_equal( $cl->{htmlbodycolor__}, 'ffffff' );

$cl->{htmlfontcolor__} = '';
$cl->{words__}         = {};
$cl->{in_html_tag}   = 0;

$cl->parse_html( '<img src="popfile.sourceforge.net/foo.gif">' );
test_assert_equal( $cl->{words__}{'popfile.sourceforge.net'}, 1 );

# make sure we don't crash for some stupid html things like
# invalid tags passed to update_tag

$cl->update_tag( "faketag(|", "foo", 0, 0 );
$cl->update_tag( "faketag(|", "foo", 1, 0 );

# glob the tests directory for files called TestMails/TestMailParse\d+.msg which consist of messages
# to be parsed with the resulting values for the words hash in TestMails/TestMailParse\d+.wrd

# Since the [[:alpha:]] regular expression is affected by the system locale, fix the
# locale to 'C'.

#use POSIX qw( locale_h );
#my $current_locale = setlocale( LC_CTYPE );
#setlocale( LC_CTYPE, 'C' );
#binmode STDOUT, ":utf8";

my @parse_tests = sort glob 'TestMails/TestMailParse*.msg';

for my $parse_test (@parse_tests) {
#            no warnings 'utf8';
    my $words = $parse_test;
    $words    =~ s/msg/wrd/;

    # Parse the document and then check the words hash against the words in the
    # wrd file

    $cl->parse_file( $parse_test );

    open WORDS, "<:utf8", "$words";
    while ( <WORDS> ) {
        if ( /^(.+) (\d+)/ ) {
            my ( $word, $value ) = ( $1, $2 );
            test_assert_equal( $cl->{words__}{$word}, $value, "$words: $cl->{words__}{$word} $word $value" );
            delete $cl->{words__}{$word};
        }
    }
    close WORDS;

    foreach my $missed ( sort( keys %{$cl->{words__}} ) ) {
        test_assert( 0, "$missed $cl->{words__}{$missed} missing in $words" );

        # Only use this if once you KNOW FOR CERTAIN that it's
        # not going to update the WRD files with bogus entries
        # First manually check the test failures and then switch the
        # 0 to 1 and run once

        if ( 0 ) {
             open UPDATE, ">>:utf8", "$words";
             print UPDATE "$missed $cl->{words__}{$missed}\n";
             close UPDATE;
        }
        delete $cl->{words__}{$missed};
    }
}

# Check that from, to and subject get set correctly when parsing a message
$cl->parse_file( 'TestMails/TestMailParse013.msg' );
test_assert_equal( $cl->{from__},    'RN <rrr@nnnnnnnnn.com>'                        );
test_assert_equal( $cl->{to__},      '"Armlet Forum" <armlet-forum@news.palmos.com>' );
test_assert_equal( $cl->{subject__}, '(Archive Copy) RE: CW v9 and armlets...'       );
$cl->parse_file( 'TestMails/TestMailParse018.msg' );
$cl->{to__} =~ /(\Qbugtracker\E@\Qrltvty.com\E)/;
test_assert_equal( $1, 'bugtracker@rltvty.com' );
$cl->parse_file( 'TestMails/TestMailParse019.msg' );
$cl->{to__} =~ /(\Qbugtracker\E@\Qrltvty.com\E)/;
test_assert_equal( $1, 'bugtracker@rltvty.com' );

# Check that multi-line To: and CC: headers get handled properly
$cl->parse_file( 'TestMails/TestMailParse021.msg' );
#$cl->{to__} =~ s/[\r\n]//g;
test_assert_equal( $cl->{to__},      'dsmith@ctaz.com, dsmith@dol.net, dsmith@dirtur.com, dsmith@dialpoint.net, dsmith@crosscountybank.com,<dsmith@cybersurf.net>, <dsmith@dotnet.com>, <dsmith@db.com>, <dsmith@cs.com>, <dsmith@crossville.com>,<dsmith@dreamscape.com>, <dsmith@cvnc.net>, <dsmith@dmrtc.net>, <dsmith@datarecall.net>,<dsmith@dasia.net>' );
#$cl->{cc__} =~ s/[\r\n]//g;
test_assert_equal( $cl->{cc__},      'dsmith@dmi.net, dsmith@datamine.net, dsmith@crusader.com, dsmith@datasync.com,<dsmith@doorpi.net>, <dsmith@dnet.net>, <dsmith@cybcon.com>, <dsmith@csonline.net>,<dsmith@directlink.net>, <dsmith@cvip.net>, <dsmith@dragonbbs.com>, <dsmith@crosslinkinc.com>,<dsmith@dccnet.com>, <dsmith@dakotacom.net>' );

# Test colorization

my @color_tests = ( 'TestMails/TestMailParse015.msg', 'TestMails/TestMailParse019.msg' );

my $b = $POPFile->get_module( 'Classifier/Bayes' );
my $session = $b->get_session_key( 'admin', '' );

for my $color_test (@color_tests) {
    my $colored = $color_test;
    $colored    =~ s/msg/clr/;

    $cl->{color__} = $session;
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

$cl->{color__} = '';

# test decode_string

test_assert_equal($cl->decode_string(undef), '');
test_assert_equal($cl->decode_string("=?UNKNOWN?B??="), '');
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo?="), "foo");
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo_bar?="), "foo bar");
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo=20bar?="), "foo bar");
test_assert_equal($cl->decode_string("=?ISO-8859-1?Q?foo_bar?= =?ISO-8859-1?Q?foo_bar?="), "foo barfoo bar");
test_assert_equal($cl->decode_string("=?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= =?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?="), "Aladdin:open sesameAladdin:open sesame");
test_assert_equal($cl->decode_string("=?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= =?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= aaa"), "Aladdin:open sesameAladdin:open sesame aaa");
test_assert_equal($cl->decode_string("abba =?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= =?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= aaa"), "abba Aladdin:open sesameAladdin:open sesame aaa");
test_assert_equal($cl->decode_string("=?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= a =?ISO-8859-1?B?QWxhZGRpbjpvcGVuIHNlc2FtZQ==?= aaa"), "Aladdin:open sesame a Aladdin:open sesame aaa");

# test get_header

$cl->parse_file( 'TestMails/TestMailParse022.msg' );
test_assert_equal( $cl->get_header( 'from' ), 'test@test.com'  );
test_assert_equal( $cl->get_header( 'to' ), 'someone@somewhere.com'  );
test_assert_equal( $cl->get_header( 'cc' ), '<someoneelse@somewhere.com>'  );
test_assert_equal( $cl->get_header( 'subject'), 'test for various HTML parts' );

# test quickmagnets

my %qm = %{$cl->quickmagnets()};
my @from = @{$qm{from}};
my @to = @{$qm{to}};
my @cc = @{$qm{cc}};
my @subject = @{$qm{subject}};
test_assert_equal( $#from, 2 );
test_assert_equal( $from[0], 'test@test.com' );
test_assert_equal( $from[1], 'test.com' );
test_assert_equal( $from[2], '.com' );
test_assert_equal( $#to, 2 );
test_assert_equal( $to[0], 'someone@somewhere.com' );
test_assert_equal( $to[1], 'somewhere.com' );
test_assert_equal( $to[2], '.com' );
test_assert_equal( $#cc, 2 );
test_assert_equal( $cc[0], 'someoneelse@somewhere.com' );
test_assert_equal( $cc[1], 'somewhere.com' );
test_assert_equal( $cc[2], '.com' );
test_assert_equal( $#subject, 2 );
test_assert_equal( $subject[0], 'test' );
test_assert_equal( $subject[1], 'various' );
test_assert_equal( $subject[2], 'parts' );

# test file_extension

my ( $name, $ext ) = $cl->file_extension( 'test.txt' );
test_assert_equal( $name, 'test' );
test_assert_equal( $ext,  'txt'  );
( $name, $ext ) = $cl->file_extension( 'test.test.txt' );
test_assert_equal( $name, 'test.test' );
test_assert_equal( $ext,  'txt'       );
( $name, $ext ) = $cl->file_extension( '.txt' );
test_assert_equal( $name, '' );
test_assert_equal( $ext,  'txt'     );
( $name, $ext ) = $cl->file_extension( 'test.' );
test_assert_equal( $name, 'test' );
test_assert_equal( $ext,  ''     );
( $name, $ext ) = $cl->file_extension( 'testtxt' );
test_assert_equal( $name, 'testtxt' );
test_assert_equal( $ext,  ''        );
( $name, $ext ) = $cl->file_extension( '' );
test_assert_equal( $name, '' );
test_assert_equal( $ext,  '' );
( $name, $ext ) = $cl->file_extension( '.' );
test_assert_equal( $name, '' );
test_assert_equal( $ext,  '' );
( $name, $ext ) = $cl->file_extension( '..' );
test_assert_equal( $name, '.' );
test_assert_equal( $ext,  '' );

# test add_attchment_filename

$cl->add_attachment_filename( 'test.txt' );
test_assert_equal( $cl->{words__}{'mimename:test'},     1 );
test_assert_equal( $cl->{words__}{'mimeextension:txt'}, 1 );
$cl->add_attachment_filename( 'test2.tar.gz' );
test_assert_equal( $cl->{words__}{'mimename:test2.tar'}, 1 );
test_assert_equal( $cl->{words__}{'mimeextension:gz'},   1 );
$cl->add_attachment_filename( 'test3.' );
test_assert_equal( $cl->{words__}{'mimename:test3'}, 1 );
test_assert( !exists $cl->{words__}{'mimeextension:'} );
$cl->add_attachment_filename( '.bashrc' );
test_assert( !exists $cl->{words__}{'mimename:'} );
test_assert_equal( $cl->{words__}{'mimeextension:bashrc'}, 1 );
$cl->add_attachment_filename( '.' );
test_assert( !exists $cl->{words__}{'mimename:'} );
test_assert( !exists $cl->{words__}{'mimeextension:'} );
$cl->add_attachment_filename( '' );
test_assert( !exists $cl->{words__}{'mimename:'} );
test_assert( !exists $cl->{words__}{'mimeextension:'} );
$cl->add_attachment_filename( undef );
test_assert( !exists $cl->{words__}{'mimename:'} );
test_assert( !exists $cl->{words__}{'mimeextension:'} );

# test first20

$cl->parse_file( 'TestMails/TestMailParse022.msg' );
test_assert_equal( $cl->first20(), ' This is the title image tag ALT string' );
$cl->parse_file( 'TestMails/TestMailParse021.msg' );
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

# Test Japanese mode

my $have_text_kakasi = 0;

foreach my $prefix (@INC) {
    my $realfilename = "$prefix/Text/Kakasi.pm";
    if (-f $realfilename) {
        $have_text_kakasi = 1;
        last;
    }
}

if ( $have_text_kakasi ) {
    $b->global_config_( 'language', 'Nihongo' );
    $b->initialize();
    test_assert( $b->start() );
    $cl->{lang__} = 'Nihongo';

    if ( $^O eq 'Win32' ) {
        binmode STDOUT, ":encoding(cp932)";
    } else {
        binmode STDOUT, ":utf8";
    }

    my $nihongo_parser = $cl->setup_nihongo_parser( 'kakasi' );
    test_assert_equal( $nihongo_parser, 'kakasi' );

    # Test decode_string
    my $original_string = "POPFileは自動メール振り分けツールです";

    test_assert_equal( $cl->decode_string('=?ISO-2022-JP?B?UE9QRmlsZRskQiRPPCtGMCVhITwlaz82JGpKLCQxJUQhPCVrJEckORsoQg==?='), $original_string );
    test_assert_equal( $cl->decode_string('=?SHIFT_JIS?B?UE9QRmlsZYLNjqmTroOBgVuDi5BVguiVqoKvg2OBW4OLgsWCtw==?='), $original_string );
    test_assert_equal( $cl->decode_string('=?UTF-8?B?UE9QRmlsZeOBr+iHquWLleODoeODvOODq+aMr+OCiuWIhuOBkeODhOODvOODq+OBp+OBmQ==?='), $original_string );
    test_assert_equal( $cl->decode_string('=?ISO-2022-JP?Q?POPFile=1B$B$O<+F0%a!<%k?6$jJ,$1%D!<%k$G$9=1B(B?='), $original_string );
    test_assert_equal( $cl->decode_string('=?SHIFT_JIS?Q?POPFile=82=CD=8E=A9=93=AE=83=81=81[=83=8B=90U=82=E8=95=AA=82=AF=83c=81[=83=8B=82=C5=82=B7?='), $original_string );
    test_assert_equal( $cl->decode_string('=?UTF-8?Q?POPFile=E3=81=AF=E8=87=AA=E5=8B=95=E3=83=A1=E3=83=BC=E3=83=AB=E6=8C=AF=E3=82=8A=E5=88=86=E3=81=91=E3=83=84=E3=83=BC=E3=83=AB=E3=81=A7=E3=81=99?='), $original_string );

    test_assert_equal( $cl->decode_string('=?UNKNOWN?B?UE9QRmlsZRskQiRPPCtGMCVhITwlaz82JGpKLCQxJUQhPCVrJEckORsoQg==?='), $original_string );
    test_assert_equal( $cl->decode_string('=?ISO-2022-JP?B?UE9QRmlsZYLNjqmTroOBgVuDi5BVguiVqoKvg2OBW4OLgsWCtw==?='), $original_string );

    test_assert_equal( $cl->decode_string('=?ISO-2022-JP?B?UE9QRmlsZRskQiRPPCtGMCVhITwlaxsoQg==?= =?ISO-2022-JP?B?GyRCPzYkakosJDElRCE8JWskRyQ5GyhC?='), $original_string );
    test_assert_equal( $cl->decode_string('=?UTF-8?B?UE9QRmlsZeOBr+iHquWLleODoeODvOODqw==?= =?ISO-2022-JP?Q?=1B$B?6$jJ,$1%D!<%k$G$9=1B(B?='), $original_string );
    test_assert_equal( $cl->decode_string('=?UTF-8?Q?POPFile=E3=81=AF=E8=87=AA=E5=8B=95=E3=83=A1=E3=83=BC=E3=83=AB?= =?UTF-8?B?5oyv44KK5YiG44GR44OE44O844Or44Gn44GZ?='), $original_string );

    # Test kakasi wakachi-gaki

    $cl->{nihongo_parser__}{init}($cl);

    my $wakati_string = "POPFile は 自動 メール 振り分け ツール です";
    test_assert_equal( $cl->{nihongo_parser__}{parse}($cl, $original_string), $wakati_string );

    $original_string = "POPFile は自\x0a動\x09メール振\x09り\x0d分   けツールです";
    $wakati_string = "POPFile は 自動\x0a\x09メール 振り分け\x09\x0d   ツール です";
    test_assert_equal( $cl->{nihongo_parser__}{parse}($cl, $original_string), $wakati_string );

    $cl->{nihongo_parser__}{close}($cl);

    # Tests for parsing Japanese e-mails.

    require POPFile::Mutex;
    $cl->{kakasi_mutex__} = new POPFile::Mutex( 'mailparse_kakasi' );
    $cl->{need_kakasi_mutex__} = 1;

    #$cl->{debug__} = 1;
    my @parse_tests = sort glob 'TestMails/TestNihongo*.msg';

    for my $parse_test (@parse_tests) {

        my $words = $parse_test;
        $words    =~ s/msg/wrd/;

        # Parse the document and then check the words hash against the words in the
        # wrd file

        $cl->parse_file( $parse_test );

        open WORDS, "<:encoding(euc-jp)", $words;
        while ( <WORDS> ) {
            if ( /^(.+) (\d+)/ ) {
                my ( $word, $value ) = ( $1, $2 );
                $word = lc $word if ( $word !~ /:/ );
                test_assert_equal( $cl->{words__}{$word}, $value, "$words $word $value" );
                delete $cl->{words__}{$word};
            }
        }
        close WORDS;

        foreach my $missed ( sort( keys %{$cl->{words__}} ) ) {
            test_assert( 0, "$missed $cl->{words__}{$missed} missing in $words" );

            # Only use this if once you KNOW FOR CERTAIN that it's
            # not going to update the WRD files with bogus entries
            # First manually check the test failures and then switch the
            # 0 to 1 and run once

            if ( 0 ) {
                 open UPDATE, ">>$words";
                 print UPDATE "$missed $cl->{words__}{$missed}\n";
                 close UPDATE;
            }
            delete $cl->{words__}{$missed};
        }
    }

    # Test for the internal parser

    $nihongo_parser = $cl->setup_nihongo_parser( 'internal' );
    test_assert_equal( $nihongo_parser, 'internal' );

    $cl->{nihongo_parser__}{init}($cl);

    $original_string = "POPFileは自動メール振り分けツールです";
    $wakati_string = "POPFile は 自動 メール 振 り 分 け ツール です ";
    test_assert_equal( $cl->{nihongo_parser__}{parse}($cl, $original_string), $wakati_string );

    $original_string = "適当に云々とか＠！％とか半角ｶﾀｶﾅとかも試してみます";
    $wakati_string = "適当 に 云々 とか ＠ ！ ％ とか 半角 ｶﾀｶﾅ とかも 試 してみます ";
    test_assert_equal( $cl->{nihongo_parser__}{parse}($cl, $original_string), $wakati_string );

    $cl->{nihongo_parser__}{close}($cl);

    # Test for MeCab

    my $have_mecab = 0;

    foreach my $prefix (@INC) {
        my $realfilename = "$prefix/MeCab.pm";
        if (-f $realfilename) {
            $have_mecab = 1;
            last;
        }
    }

    $nihongo_parser = $cl->setup_nihongo_parser( 'mecab' );
    if ( $have_mecab ) {
        test_assert_equal( $nihongo_parser, 'mecab' );

        $cl->{nihongo_parser__}{init}($cl);

        $original_string = pack( "H*", "504f5046696c65a4cfbcabc6b0a5e1a1bca5ebbfb6a4eacaaca4b1a5c4a1bca5eba4c7a4b9" );
#        $original_string = "POPFileは自動メール振り分けツールです";
        $wakati_string = pack( "H*", "504f5046696c6520a4cf20bcabc6b020a5e1a1bca5eb20bfb6a4eacaaca4b120a5c4a1bca5eb20a4c7a4b9200a" );
#        $wakati_string = "POPFile は 自動 メール 振り分け ツール で す \x0a";
        test_assert_equal( $cl->{nihongo_parser__}{parse}($cl, $original_string), $wakati_string );

        $cl->{nihongo_parser__}{close}($cl);

    } else {
        print "\nWarning: MeCab tests skipped because MeCab was not found\n";

        test_assert_equal( $nihongo_parser, 'kakasi' );
    }

} else {
    print "\nWarning: Japanese tests skipped because Text::Kakasi was not found\n";
}

$POPFile->CORE_stop();

1;
