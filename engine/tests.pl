# ---------------------------------------------------------------------------------------------
#
# tests.pl  - Unit tests for POPFile
#
# ---------------------------------------------------------------------------------------------

use Test;

BEGIN { plan tests => 1, todo => [0,0] }

# ---------------------------------------------------------------------------------------------
#
# Tests for MailParse.pm
#
# ---------------------------------------------------------------------------------------------

use Classifier::MailParse;

my $cl = new Classifier::MailParse;

# map_color()
ok( $cl->map_color( 'red' ),     'ff0000' ); 
ok( $cl->map_color( 'ff0000' ),  'ff0000' ); 
ok( $cl->map_color( 'FF0000' ),  'ff0000' ); 
ok( $cl->map_color( '#fF0000' ), 'ff0000' ); 
ok( $cl->map_color( '#Ff0000' ), 'ff0000' ); 
ok( $cl->map_color( 'white' ),   'ffffff' ); 
ok( $cl->map_color( 'fFfFFf' ),  'ffffff' ); 
ok( $cl->map_color( 'FFFFFF' ),  'ffffff' ); 
ok( $cl->map_color( '#ffffff' ), 'ffffff' ); 
ok( $cl->map_color( '#FFfFFF' ), 'ffffff' ); 

# Check line splitting into words
$cl->{htmlbackcolor} = $cl->map_color( 'white' );
$cl->{htmlfontcolor} = $cl->map_color( 'black' );
$cl->{words}         = {};
$cl->add_line( 'this is a test of,adding words: from a line of text!', 0, '' );
ok( $cl->{words}{test},   1 );
ok( $cl->{words}{adding}, 1 );
ok( $cl->{words}{words},  1 );
ok( $cl->{words}{line},   1 );
ok( $cl->{words}{text},   1 );
$cl->add_line( 'adding', 0, '' );
ok( $cl->{words}{adding}, 2 );

# Check that we correctly handle spaced out and dotted word
$cl->{words}         = {};
$cl->add_line( 'T H I S  T E X T  I S  S P A C E D alot', 0, '' );
ok( $cl->{words}{text},   1 );
ok( $cl->{words}{spaced}, 1 );
ok( $cl->{words}{alot},   1 );
$cl->{words}         = {};
$cl->add_line( 'offer a full 90 day m.oney b.ack g.uarantee.  If any customer is not. C.lick b.elow f.or m.ore i.nformation, it\'s f.r.e.e.', 0, '' );
ok( $cl->{words}{offer},     1 );
ok( $cl->{words}{full},      1 );
ok( $cl->{words}{money},     1 );
ok( $cl->{words}{back},      1 );
ok( $cl->{words}{customer},  1 );
ok( $cl->{words}{'trick:dottedwords'}, 6 );
ok( $cl->{words}{click},     1 );
ok( $cl->{words}{below},     1 );
ok( $cl->{words}{more},      1 );

# Check discovery of font color
$cl->{htmlfontcolor} = '';
ok( $cl->parse_html( '<font color="white">' ), 0 );
ok( $cl->{htmlfontcolor}, $cl->map_color( 'white' ) );
$cl->{htmlfontcolor} = '';
ok( $cl->parse_html( '<font color=red>' ), 0 );
ok( $cl->{htmlfontcolor}, $cl->map_color( 'red' ) );
$cl->{htmlfontcolor} = '';
ok( $cl->parse_html( '<font color=#00ff00>' ), 0 );
ok( $cl->{htmlfontcolor}, $cl->map_color( 'green' ) );
$cl->{htmlfontcolor} = '';
ok( $cl->parse_html( '<font color=#00ff00></font>' ), 0 );
ok( $cl->{htmlfontcolor}, $cl->map_color( 'black' ) );

# Check comment detection
$cl->{words}         = {};
ok( $cl->parse_html( '<!-- foo -->' ), 0 );
ok( $cl->parse_html( '<!-- -->' ), 0 );
ok( $cl->parse_html( '<!---->' ), 0 );
ok( $cl->{words}{'html:comment'}, 3 );

# Check invisible ink detection
$cl->{htmlfontcolor} = '';
$cl->{words}         = {};
$cl->{in_html_tag}   = 0;
ok( $cl->parse_html( '<body bgcolor="#ffffff">hello<font color=white>invisible</font>visible</body>  ' ), 0 );
ok( $cl->{words}{hello},     1 );
ok( $cl->{words}{visible},   1 );
ok( defined( $cl->{words}{invisible} ), '' );
$cl->{htmlfontcolor} = '';
$cl->{words}         = {};
$cl->{in_html_tag}   = 0;
ok( $cl->parse_html( '   <body bgcolor="#ffffff">  hello<font color=white>' ), 0 );
ok( $cl->parse_html( '  invisible </font>'                                ), 0 );
ok( $cl->parse_html( 'visible</body>'                                  ), 0 );
ok( $cl->{words}{hello},     1 );
ok( $cl->{words}{visible},   1 );
ok( defined( $cl->{words}{invisible} ), '' );
$cl->{htmlfontcolor} = '';
$cl->{words}         = {};
$cl->{in_html_tag}   = 0;
ok( $cl->parse_html( '<body bgcolor="#ffffff">hello  <font' ), 1 );
ok( $cl->parse_html( 'color=white>invisible </font>'       ), 0 );
ok( $cl->parse_html( 'visible    </body>'                     ), 0 );
ok( $cl->{words}{hello},     1 );
ok( $cl->{words}{visible},   1 );
ok( defined( $cl->{words}{invisible} ), '' );

# glob the tests directory for files called TestMailParse\d+.tst which consist of messages 
# to be parsed with the resulting values for the words hash in TestMailParse\d+.wrd

my @parse_tests = sort glob 'tests/TestMailParse*.tst';

for my $parse_test (@parse_tests) {
    my $words = $parse_test;
    $words    =~ s/tst/wrd/;
    
    # Parse the document and then check the words hash against the words in the
    # wrd file
    
    print "Running $parse_test... ";
    $cl->parse_stream( $parse_test );
    
    open WORDS, "<$words";
    my $passed = 1;
    while ( <WORDS> ) {
        if ( /(.+) (\d+)/ ) {
            if ( $cl->{words}{$1} ne $2 ) {
                print "fail [$1] [$2] [$cl->{words}{$1}] ";
                $passed = 0;
            }
        }
    }
    close WORDS;
    
    if ( $passed ) {
        print "ok";
    }
    
    print "\n";
}
