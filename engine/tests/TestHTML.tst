# ---------------------------------------------------------------------------------------------
#
# Tests for HTML.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use UI::HTML;

my $c = new UI::HTML;

test_assert_equal( $c->url_encode( ']' ), '%5d' );
test_assert_equal( $c->url_encode( '[' ), '%5b' );
test_assert_equal( $c->url_encode( '[]' ), '%5b%5d' );
test_assert_equal( $c->url_encode( '[foo]' ), '%5bfoo%5d' );

