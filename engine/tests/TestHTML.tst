# ---------------------------------------------------------------------------------------------
#
# Tests for HTML.pm
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

use POSIX ":sys_wait_h";

sub pipeready
{
    my ( $pipe ) = @_;

    if ( !defined( $pipe ) ) {
        return 0;
    }

    if ( $^O eq 'MSWin32' ) {
        return ( ( -s $pipe ) > 0 );
    } else {
        my $rin = '';
        vec( $rin, fileno( $pipe ), 1 ) = 1;
        my $ready = select( $rin, undef, undef, 0.01 );
        return ( $ready > 0 );
    }
}

test_assert( `rm -rf messages` == 0 );

use Classifier::Bayes;
use UI::HTML;
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
$c->initialize();

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

$b->initialize();

my $h = new UI::HTML;

$h->configuration( $c );
$h->mq( $mq );
$h->logger( $l );
$h->classifier( $b );
$h->initialize();

test_assert_equal( $h->url_encode_( ']' ), '%5d' );
test_assert_equal( $h->url_encode_( '[' ), '%5b' );
test_assert_equal( $h->url_encode_( '[]' ), '%5b%5d' );
test_assert_equal( $h->url_encode_( '[foo]' ), '%5bfoo%5d' );

my $port = 9000 + int(rand(1000));
pipe my $dreader, my $dwriter;
pipe my $ureader, my $uwriter;
my $pid = fork();

if ( $pid == 0 ) {

    # CHILD THAT WILL RUN THE HTML INTERFACE

    close $dwriter;
    close $ureader;

    $h->version( 'testsuite' );
    $h->config_( 'port', $port );
    $h->start();

    while ( 1 ) {
        last if !$h->service();

        if ( pipeready( $dreader ) ) {
            my $command = <$dreader>;

            if ( $command =~ /__QUIT/ ) {
                print $uwriter "OK\n";
                last;
	    }
	}
    }

    close $dreader;
    close $uwriter;

    exit(0);
} else {

    # PARENT THAT WILL SEND COMMANDS TO THE WEB INTERFACE

    close $dreader;
    close $uwriter;
    $dwriter->autoflush(1);

    use LWP::Simple;
    use URI::URL;

    # Test the simplest functionality of the HTML interface

    my $url = url( "http://127.0.0.1:$port" );
    my $content = get($url);

    # TODO Look for elements that should appear at the TOP and BOTTOM
    # of every page

    test_assert_regexp( $content, "<title>POPFile Control Center</title>" );

    # TODO Validate every page in the interface against the W3C HTML 4.01
    # validation service

    print $dwriter "__QUIT\n";
    $content = <$ureader>;
    test_assert_equal( $content, "OK\n" );
    close $dwriter;
    close $ureader;

    while ( waitpid( $pid, &WNOHANG ) != $pid ) {
    }
}


