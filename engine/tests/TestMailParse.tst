# ---------------------------------------------------------------------------------------------
#
# Tests for MailParse.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use Classifier::MailParse;

my $cl = new Classifier::MailParse;

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
test_assert_equal( $cl->parse_html( '<body bgcolor="#ffffff">hello<font color=white>invisible</font>visible</body>  ' ), 0 );
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

my @parse_tests = sort glob 'tests/TestMailParse*.msg';

for my $parse_test (@parse_tests) {
    my $words = $parse_test;
    $words    =~ s/msg/wrd/;
    
    # Parse the document and then check the words hash against the words in the
    # wrd file

    $cl->parse_file( $parse_test );

    open WORDS, "<$words";
    while ( <WORDS> ) {
        if ( /(.+) (\d+)/ ) {
            test_assert_equal( $cl->{words__}{$1}, $2, "$words $1 $2" );
        }
    }
    close WORDS;
}

# Check that from, to and subject get set correctly when parsing a message
$cl->parse_file( 'tests/TestMailParse013.msg' );
test_assert_equal( $cl->{from__},    'RN <rrr@nnnnnnnnn.com>'                        );
test_assert_equal( $cl->{to__},      '"Armlet Forum" <armlet-forum@news.palmos.com>' );
test_assert_equal( $cl->{subject__}, '(Archive Copy) RE: CW v9 and armlets...'       );
$cl->parse_file( 'tests/TestMailParse018.msg' );
$cl->{to__} =~ /(\Qbugtracker\E@\Qrelativity.com\E)/;
test_assert_equal( $1, 'bugtracker@relativity.com' );
$cl->parse_file( 'tests/TestMailParse019.msg' );
$cl->{to__} =~ /(\Qbugtracker\E@\Qrelativity.com\E)/;
test_assert_equal( $1, 'bugtracker@relativity.com' );

# Check that multi-line To: and CC: headers get handled properly
$cl->parse_file( 'tests/TestMailParse021.msg' );
$cl->{to__} =~ s/[\r\n]//g;
test_assert_equal( $cl->{to__},      'dsmith@ctaz.com, dsmith@dol.net, dsmith@dirtur.com, dsmith@dialpoint.net, dsmith@crosscountybank.com, 	<dsmith@cybersurf.net>, <dsmith@dotnet.com>, <dsmith@db.com>, <dsmith@cs.com>	, <dsmith@crossville.com>, 	<dsmith@dreamscape.com>, <dsmith@cvnc.net>, <dsmith@dmrtc.net>, <dsmith@datarecall.net>, 	<dsmith@dasia.net>' );
$cl->{cc__} =~ s/[\r\n]//g;
test_assert_equal( $cl->{cc__},      'dsmith@dmi.net, dsmith@datamine.net, dsmith@crusader.com, dsmith@datasync.com, 	<dsmith@doorpi.net>, <dsmith@dnet.net>, <dsmith@cybcon.com>, <dsmith@csonline.net>, 	<dsmith@directlink.net>, <dsmith@cvip.net>, <dsmith@dragonbbs.com>, <dsmith@crosslinkinc.com>, 	<dsmith@dccnet.com>, <dsmith@dakotacom.net>' );

