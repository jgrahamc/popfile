# ---------------------------------------------------------------------------------------------
#
# Tests for Proxy.pm
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

sub forker
{
    pipe my $reader, my $writer;
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ( $pid == 0 ) {
        close $reader;

        use IO::Handle;
        $writer->autoflush(1);

        return (0, $writer);
    }

    close $writer;
    return ($pid, $reader);
}

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

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::Proxy;
use IO::Handle;
use IO::Socket;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $p = new Proxy::Proxy

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

$p->configuration( $c );
$p->mq( $mq );
$p->logger( $l );

$p->initialize();

test_assert_equal( $p->config_( 'enabled' ), 1 );

# Start a generic proxy on port 9999
my $port = 9000 + int(rand(1000));
$p->config_( 'port', $port );
test_assert_equal( $p->start(), 1 );
$p->stop();

# Exercise the classifier setter
$p->classifier( 'foo' );
test_assert_equal( $p->{classifier__}, 'foo' );

# Test the helper methods of Proxy
use Test::SimpleProxy;
my $sp = new Test::SimpleProxy;

$sp->configuration( $c );
$sp->mq( $mq );
$sp->logger( $l );

$sp->forker( \&forker );
$sp->pipeready( \&pipeready );

$sp->initialize();
$sp->config_( 'port', $port );
$sp->config_( 'force_fork', 1 );
test_assert_equal( $sp->start(), 1 );
test_assert_equal( $sp->start_server(), 1 );

# Now connect a socket to the proxy through which
# we can test it
my $client = IO::Socket::INET->new(
                Proto    => "tcp",
                PeerAddr => 'localhost',
                PeerPort => $port );
$sp->service();

test_assert( defined( $client ) );
test_assert( $client->connected );

$sp->service();
select( undef, undef, undef, 0.25 );
$sp->service_server();
select( undef, undef, undef, 0.25 );

# Basic connectivity test tell the phony
# server to send a message and we'll receive
# it through the proxy, then send a message
# and check that the phony server gets it

$sp->send( "fromserver\n" );
$sp->service_server();
my $line = <$client>;
test_assert_regexp( $line, 'fromserver' );
print $client "toserver\n";
select( undef, undef, undef, 0.25 );
$sp->service_server();
test_assert_regexp( $sp->received(), 'toserver' );

# Test the tee function, that send a line to the server
# or client and to the logger

test_assert( $client->connected );
$sp->tee_( $client, "teed\n" );
select( undef, undef, undef, 0.25 );
$sp->service_server();
test_assert_regexp( $sp->received(), 'teed' );
my @lastten = $l->last_ten();
test_assert_regexp( $lastten[$#lastten], 'teed' );

# Test the echo_to_regexp_ function

$sp->send( 'before1' );
$sp->send( 'before2' );
$sp->send( 'matchTHis' );
$sp->send( 'after' );
$sp->service_server();
open TEMP, ">temp.tmp";
$sp->echo_to_regexp_( $client, \*TEMP, qr/TH/ );
close TEMP;
open TEMP, "<temp.tmp";
my $line = <TEMP>;
test_assert_regexp( $line, 'before1' );
$line = <TEMP>;
test_assert_regexp( $line, 'before2' );
$line = <TEMP>;
test_assert_regexp( $line, 'matchTHis' );
$line = <TEMP>;
test_assert( !defined( $line ) );
close TEMP;

$line = <$client>;
test_assert_regexp( $line, 'after' );

# Test echo_to_regexp_ with suppression

$sp->send( 'before11' );
$sp->send( 'before12' );
$sp->send( 'matchTHis1' );
$sp->send( 'after1' );
$sp->service_server();
open TEMP, ">temp.tmp";
$sp->echo_to_regexp_( $client, \*TEMP, qr/TH/, 0, qr/12/ );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'before11' );
$line = <TEMP>;
test_assert_regexp( $line, 'matchTHis1' );
$line = <TEMP>;
test_assert( !defined( $line ) );
close TEMP;

$line = <$client>;
test_assert_regexp( $line, 'after1' );

# Test echo_to_regexp_ with logging

$sp->send( 'before21' );
$sp->send( 'before22' );
$sp->send( 'matchTHis2' );
$sp->send( 'after2' );
$sp->service_server();
open TEMP, ">temp.tmp";
$sp->echo_to_regexp_( $client, \*TEMP, qr/TH/, 1, qr/22/ );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'before21' );
$line = <TEMP>;
test_assert_regexp( $line, 'matchTHis2' );
$line = <TEMP>;
test_assert( !defined( $line ) );
close TEMP;

@lastten = $l->last_ten();
test_assert_regexp( $lastten[$#lastten], 'matchTHis2' );
test_assert_regexp( $lastten[$#lastten-1], 'Suppressed: before22' );
test_assert_regexp( $lastten[$#lastten-2], 'before21' );

$line = <$client>;
test_assert_regexp( $line, 'after2' );

# Test echo_to_dot_

$sp->send( 'before1' );
$sp->send( 'before2' );
$sp->send( '.' );
$sp->send( 'after' );
$sp->service_server();
open TEMP, ">temp.tmp";
$sp->echo_to_dot_( $client, \*TEMP );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'before1' );
$line = <TEMP>;
test_assert_regexp( $line, 'before2' );
$line = <TEMP>;
test_assert_regexp( $line, '\.' );
$line = <TEMP>;
test_assert( !defined( $line ) );
close TEMP;

$line = <$client>;
test_assert_regexp( $line, 'after' );

# Test flush_extra_

$sp->send( 'flush1' );
$sp->service_server();
open TEMP, ">temp.tmp";
test_assert_regexp( $sp->flush_extra_( $client, \*TEMP ), 'flush1' );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'flush1' );
close TEMP;

$sp->send( 'flush2' );
$sp->service_server();
open TEMP, ">temp.tmp";
test_assert_regexp( $sp->flush_extra_( $client, \*TEMP, 1 ), 'flush2' );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert( !defined( $line ) );
close TEMP;

# Test get_response_ with undefined mail server

$sp->{connection_timeout_error_} = 'timeout error';
open TEMP, ">temp.tmp";
my ( $r, $o ) = $sp->get_response_( undef, \*TEMP, "HELLO" );
test_assert_regexp( $r, 'timeout error' );
test_assert_equal( $o, 0 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'timeout error' );
close TEMP;

# Test get_response_ with timeout

$sp->global_config_( 'timeout', 1 );
open TEMP, ">temp.tmp";
( $r, $o ) = $sp->get_response_( $client, \*TEMP, "HELLO" );
test_assert_regexp( $r, 'timeout error' );
test_assert_equal( $o, 0 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'timeout error' );
close TEMP;

# Test get_response_ with null response not allowed

open TEMP, ">temp.tmp";
( $r, $o ) = $sp->get_response_( $client, \*TEMP, "HELLO", 1 );
test_assert_equal( $r, '' );
test_assert_equal( $o, 1 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert( !defined( $line ) );
close TEMP;

# Test get_response_ with valid response

$sp->send( 'HELLO response');
$sp->service_server();

open TEMP, ">temp.tmp";
( $r, $o ) = $sp->get_response_( $client, \*TEMP, "HELLO" );
test_assert_regexp( $r, 'HELLO response' );
test_assert_equal( $o, 1 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'HELLO response' );
close TEMP;

# Test echo_response_ with good response

$sp->send( 'GOOD');
$sp->service_server();

$sp->{good_response_} = 'GOOD';
open TEMP, ">temp.tmp";
test_assert_equal( $sp->echo_response_( $client, \*TEMP, "HOWRU?" ), 0 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'GOOD' );
close TEMP;

# Test echo_response_ with bad response

$sp->send( 'BAD');
$sp->service_server();

open TEMP, ">temp.tmp";
test_assert_equal( $sp->echo_response_( $client, \*TEMP, "HOWRU?" ), 1 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'BAD' );
close TEMP;

# Test echo_response_ with timeout

open TEMP, ">temp.tmp";
test_assert_equal( $sp->echo_response_( $client, \*TEMP, "HOWRU?" ), 2 );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'timeout error' );
close TEMP;

# Check that we receive the messages sent up the pipe

use Test::MQReceiver;
my $r = new Test::MQReceiver;

# Register three different message types

$mq->register( 'CLASS', $r );
$mq->register( 'NEWFL', $r );
$mq->register( 'LOGIN', $r );

# Close down the child process

$sp->send( '__POPFILE__ABORT__CHILD__' );
$sp->service_server();
close $client;
$sp->stop_server();
select( undef, undef, undef, 0.25 );

# Reap the children

my @kids = keys %{$sp->{children__}};
while ( $#kids >= 0 ) {
    $sp->reaper();
    select( undef, undef, undef, 0.25 );
    @kids = keys %{$sp->{children__}};
}

$sp->stop();

$mq->service();
my @messages = $r->read();
test_assert_equal( $#messages, 2 );
test_assert_equal( $messages[0][0], 'CLASS' );
test_assert_equal( $messages[0][1], 'classification' );
test_assert_equal( $messages[0][2], '' );
test_assert_equal( $messages[1][0], 'LOGIN' );
test_assert_equal( $messages[1][1], 'username' );
test_assert_equal( $messages[1][2], '' );
test_assert_equal( $messages[2][0], 'NEWFL' );
test_assert_equal( $messages[2][1], 'newfile' );
test_assert_equal( $messages[2][2], '' );

# Make sure that stop will close off the child pipes

$sp = new Test::SimpleProxy;

$sp->configuration( $c );
$sp->mq( $mq );
$sp->logger( $l );

$sp->forker( \&forker );
$sp->pipeready( \&pipeready );

$sp->initialize();
$sp->config_( 'port', $port );

test_assert_equal( $sp->start(), 1 );
test_assert_equal( $sp->start_server(), 1 );
$client = IO::Socket::INET->new(
                Proto    => "tcp",
                PeerAddr => 'localhost',
                PeerPort => $port );
$sp->service();
test_assert( defined( $client ) );
test_assert( $client->connected );
$sp->service();
select( undef, undef, undef, 0.1 );
$sp->service_server();
select( undef, undef, undef, 0.1 );
@kids = keys %{$sp->{children__}};
my %tmp = %{$sp->{children__}};
test_assert_equal( $#kids, 0 ); 
$sp->stop_server();
$sp->stop();
@kids = keys %{$sp->{children__}};
test_assert_equal( $#kids, -1 );
print $client "__POPFILE__ABORT__CHILD__\n";
close $client;

%{$sp->{children__}} = %tmp;
@kids = keys %{$sp->{children__}};
while ( $#kids >= 0 ) {
    $sp->reaper();
    select( undef, undef, undef, 0.25 );
    @kids = keys %{$sp->{children__}};
}

# Make sure that forked will close off the child pipes

$sp = new Test::SimpleProxy;

$sp->configuration( $c );
$sp->mq( $mq );
$sp->logger( $l );

$sp->forker( \&forker );
$sp->pipeready( \&pipeready );

$sp->initialize();
$sp->config_( 'port', $port );

test_assert_equal( $sp->start(), 1 );
test_assert_equal( $sp->start_server(), 1 );
$client = IO::Socket::INET->new(
                Proto    => "tcp",
                PeerAddr => 'localhost',
                PeerPort => $port );
$sp->service();
test_assert( defined( $client ) );
test_assert( $client->connected );
$sp->service();
select( undef, undef, undef, 0.1 );
$sp->service_server();
select( undef, undef, undef, 0.1 );
@kids = keys %{$sp->{children__}};
test_assert_equal( $#kids, 0 ); 
%tmp = %{$sp->{children__}};
$sp->forked();
@kids = keys %{$sp->{children__}};
test_assert_equal( $#kids, -1 );
$sp->stop_server();
$sp->stop();
print $client "__POPFILE__ABORT__CHILD__\n";
close $client;

%{$sp->{children__}} = %tmp;
@kids = keys %{$sp->{children__}};
while ( $#kids >= 0 ) {
    $sp->reaper();
    select( undef, undef, undef, 0.25 );
    @kids = keys %{$sp->{children__}};
}

# Test that verify_connected_ does what we expect

$sp = new Test::SimpleProxy;

$sp->configuration( $c );
$sp->mq( $mq );
$sp->logger( $l );

$sp->forker( \&forker );
$sp->pipeready( \&pipeready );

$sp->initialize();
$sp->config_( 'port', $port );

$sp->{connection_failed_error_} = 'failed error';

undef $client;
open TEMP, ">temp.tmp";
test_assert( !defined( $sp->verify_connected_( $client, \*TEMP, 'localhost', $port ) ) );
close TEMP;
open TEMP, "<temp.tmp";
$line = <TEMP>;
test_assert_regexp( $line, 'failed error' );
test_assert_regexp( $line, 'localhost' );
test_assert_regexp( $line, "$port" );
close TEMP;

test_assert( $sp->start() );

my $sp2 = new Test::SimpleProxy;

$sp2->configuration( $c );
$sp2->mq( $mq );
$sp2->logger( $l );

$sp2->forker( \&forker );
$sp2->pipeready( \&pipeready );

$sp2->initialize();
$sp2->config_( 'port', -1 );

open (STDERR, ">stdout.tmp");
test_assert( !$sp2->start() );
close STDERR;
open TEMP, "<stdout.tmp";
$line = <TEMP>;
$line = <TEMP>;
$line = <TEMP>;
test_assert_regexp( $line, "Couldn't start the simple proxy" );
close TEMP;

$sp->stop();
$sp2->stop();

1;
