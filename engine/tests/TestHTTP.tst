# ---------------------------------------------------------------------------------------------
#
# Tests for HTTP.pm
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

sub my_handler
{
    my ( $self, $client, $url, $command, $content ) = @_;

    my $code = 1;

    if ( $url =~ /\/stop/ ) {
        $code = 0;
    }

    $self->http_error_( $client, "$url $command $content" );

    return $code;
}

use IO::Handle;
use POSIX ":sys_wait_h";

use UI::HTTP;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $h = new UI::HTTP;

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

$h->configuration( $c );
$h->mq( $mq );
$h->logger( $l );

$h->initialize();

my $port = 9000 + int(rand(1000));
$h->config_( 'port', $port );
$h->config_( 'local', 1 );
test_assert( $h->start() );

my $eol = "\015\012";

# parse_form_ tests

delete $h->{form_};
$h->parse_form_( 'foo=bar' );
my @keys = keys %{$h->{form_}};
test_assert_equal( $#keys, 0 );
test_assert_equal( $h->{form_}{foo}, 'bar' );

delete $h->{form_};
$h->parse_form_( 'answer=%2A' );
my @keys = keys %{$h->{form_}};
test_assert_equal( $#keys, 0 );
test_assert_equal( $h->{form_}{answer}, '*' );

delete $h->{form_};
$h->parse_form_( 'foo=bar&' );
my @keys = keys %{$h->{form_}};
test_assert_equal( $#keys, 0 );
test_assert_equal( $h->{form_}{foo}, 'bar' );

delete $h->{form_};
$h->parse_form_( 'foo=bar&bar=baz' );
my @keys = keys %{$h->{form_}};
test_assert_equal( $#keys, 1 );
test_assert_equal( $h->{form_}{foo}, 'bar' );
test_assert_equal( $h->{form_}{bar}, 'baz' );

delete $h->{form_};
$h->parse_form_( 'foo=bar&amp;bar=baz' );
my @keys = keys %{$h->{form_}};
test_assert_equal( $#keys, 1 );
test_assert_equal( $h->{form_}{foo}, 'bar' );
test_assert_equal( $h->{form_}{bar}, 'baz' );

delete $h->{form_};
$h->parse_form_( 'foo=bar&foo=baz' );
my @keys = keys %{$h->{form_}};
test_assert_equal( $#keys, 1 );
test_assert_equal( $h->{form_}{foo}, 'baz' );
test_assert_equal( $h->{form_}{foo_array}[0], 'bar' );
test_assert_equal( $h->{form_}{foo_array}[1], 'baz' );

# url_encode_ tests

test_assert_equal( $h->url_encode_( 'nochange' ), 'nochange' );
my $allowed = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_.+!*\'()';
test_assert_equal( $h->url_encode_( $allowed ), $allowed );
test_assert_equal( $h->url_encode_( chr(0) ), '%00' );
test_assert_equal( $h->url_encode_( chr(127) ), '%7f' );
test_assert_equal( $h->url_encode_( chr(255) ), '%ff' );
test_assert_equal( $h->url_encode_( 'thealmighty$' ), 'thealmighty%24' );
test_assert_equal( $h->url_encode_( 'youcan"me' ), 'youcan%22me' );
test_assert_equal( $h->url_encode_( '{start' ), '%7bstart' );

# http_redirect_ tests

open FILE, ">temp.tmp";
$h->http_redirect_( \*FILE, 'http://www.usethesource.com/' );
close FILE;
open FILE, "<temp.tmp";
my $line = <FILE>;
test_assert_equal( $line, "HTTP/1.0 302 Found$eol" );
$line = <FILE>;
test_assert_equal( $line, "Location: http://www.usethesource.com/$eol" );
$line = <FILE>;
test_assert( defined( $line ) );
test_assert( $line =~ /^$eol$/ );
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

# http_error_ tests

open FILE, ">temp.tmp";
$h->http_error_( \*FILE, 404 );
close FILE;
open FILE, "<temp.tmp";
my $line = <FILE>;
test_assert_equal( $line, "HTTP/1.0 404 Error$eol" );
$line = <FILE>;
test_assert( defined( $line ) );
test_assert( $line =~ /^$eol$/ );
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

# http_file_ tests

open FILE, ">temp.tmp";
$h->http_file_( \*FILE, 'doesnotexist.fil' );
close FILE;
open FILE, "<temp.tmp";
my $line = <FILE>;
test_assert_equal( $line, "HTTP/1.0 404 Error$eol" );
$line = <FILE>;
test_assert( defined( $line ) );
test_assert( $line =~ /^$eol$/ );
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

open FILE, ">send.tmp";
print FILE "somechars\n";
close FILE;

open FILE, ">temp.tmp";
$h->http_file_( \*FILE, 'send.tmp', 'text/plain' );
close FILE;
open FILE, "<temp.tmp";
my $line = <FILE>;
test_assert_equal( $line, "HTTP/1.0 200 OK$eol" );
$line = <FILE>;
test_assert_equal( $line, "Content-Type: text/plain$eol" );

my @day   = ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' );
my @month = ( 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' );
my $zulu = time;
$zulu += 60 * 60; # 1 hour
my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime( $zulu );
my $expires = sprintf( "%s, %02d %s %04d %02d:%02d:%02d GMT",
                       $day[$wday], $mday, $month[$mon], $year+1900,
                       $hour, 59, 0);
$line = <FILE>;
test_assert_equal( $line, "Expires: $expires$eol" );
$line = <FILE>;
test_assert_equal( $line, "Content-Length: " . ( -s 'send.tmp' ) . "$eol" );
$line = <FILE>;
test_assert( defined( $line ) );
test_assert( $line =~ /^$eol$/ );
$line = <FILE>;
test_assert_equal( $line, "somechars$eol" );
$line = <FILE>;
test_assert( !defined( $line ) );
close FILE;

# Test what happens when we fail to open the server socket

my $h2 = new UI::HTTP;

$h2->configuration( $c );
$h2->mq( $mq );
$h2->logger( $l );

$h2->initialize();
$h2->name( 'simple' );
$h2->config_( 'port', -1 );

open (STDERR, ">stdout.tmp");
test_assert( !$h2->start() );
close STDERR;
open TEMP, "<stdout.tmp";
$line = <TEMP>;
$line = <TEMP>;
$line = <TEMP>;
$line = <TEMP>;
test_assert_regexp( $line, "Couldn't start the simple HTTP interface" );
close TEMP;

$h2->stop();

# Fork into a subprocess that keeps calling service() on the HTTP
# module to handle requests and a top level process that sends down
# requests and receives a replies

my $pid = fork();

if ( $pid == 0 ) {

    # CHILD

    $h->{url_handler_} = \&my_handler;

    while ( $h->service() ) {
    }

    $h->stop();

    exit(0);
} else {

    # PARENT

    $h->forked();

    # Get a valid result

    my $client = IO::Socket::INET->new(
                    Proto    => "tcp",
                    PeerAddr => 'localhost',
                    PeerPort => $port );

    select( undef, undef, undef, 0.1 );

    test_assert( defined( $client ) );
    test_assert( $client->connected );

    print $client "GET / HTTP/1.0$eol" . "Header: Mine$eol" . "~~~~~~: ~~~~~~~$eol$eol";
    select( undef, undef, undef, 0 );
    $line = <$client>;
    test_assert_equal( $line, "HTTP/1.0 / GET  Error$eol" );
    close $client;

    # Get a protocol error

    my $client = IO::Socket::INET->new(
                    Proto    => "tcp",
                    PeerAddr => 'localhost',
                    PeerPort => $port );

    select( undef, undef, undef, 0.1 );

    test_assert( defined( $client ) );
    test_assert( $client->connected );

    print $client "GET / HTTP/2.0$eol$eol";
    select( undef, undef, undef, 0 );
    $line = <$client>;
    test_assert_equal( $line, "HTTP/1.0 500 Error$eol" );
    close $client;

    # Send body data

    my $client = IO::Socket::INET->new(
                    Proto    => "tcp",
                    PeerAddr => 'localhost',
                    PeerPort => $port );

    select( undef, undef, undef, 0.1 );

    test_assert( defined( $client ) );
    test_assert( $client->connected );

    print $client "POST /body HTTP/1.0$eol" . "Content-Length: 12$eol$eol" . "1234567890$eol$eol";
    select( undef, undef, undef, 0 );
    $line = <$client>;
    test_assert_equal( $line, "HTTP/1.0 /body POST 1234567890$eol" );
    close $client;

    # kill child

    my $client = IO::Socket::INET->new(
                    Proto    => "tcp",
                    PeerAddr => 'localhost',
                    PeerPort => $port );

    select( undef, undef, undef, 0.1 );

    test_assert( defined( $client ) );
    test_assert( $client->connected );

    # Get a valid result

    print $client "GET /stop HTTP/1.0$eol$eol";
    select( undef, undef, undef, 0.1 );
    $line = <$client>;
    test_assert_equal( $line, "HTTP/1.0 /stop GET  Error$eol" );
    close $client;

    while ( waitpid( $pid, &WNOHANG ) != $pid ) {
    }

    $h->stop();
}

