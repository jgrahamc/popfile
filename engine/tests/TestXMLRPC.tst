# ---------------------------------------------------------------------------------------------
#
# Tests for XMLRPC.pm
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
#   Modified by Sam Schinke (sschinke@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------


use Classifier::MailParse;
use Classifier::Bayes;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use UI::XMLRPC;

# Load the test corpus
my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;
my $x = new UI::XMLRPC;

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

$x->configuration( $c );
$x->mq( $mq );
$x->logger( $l );
$x->{classifier__} = $b;

$b->initialize();
test_assert( $b->start() );

$x->initialize();
$x->config_('enabled',1);
#$x->start();



# TODO: make this work
# similar code fails in all tests
# Test XMLRPC startup

# $x->config_("port", "aaa");

#open STDERR, ">stdout.tmp";
#test_assert(!$x->start());
#close STDERR;

#open TEMP, "<stdout.tmp";

#my $line = <TEMP>;
#$line = <TEMP>;
#$line = <TEMP>;
#$line = <TEMP>;
#test_assert_regexp($line,"Couldn't start the XMLRPC HTTP interface because POPFile could not bind to the");

#close TEMP;
#unlink "stdout.tmp";

my $xport = 12000 + int(rand(2000));

$x->config_("port", $xport);

$b->prefork();

my $pid = fork();

if ($pid == 0) {
    # CHILD THAT WILL RUN THE XMLRPC SERVER
    if ($x->start() == 1) {

        $b->forked();

        test_assert(1, "start passed\n");

        while ( $x->service() && $b->alive()) {
            select(undef,undef,undef, 0.1);
        }
        $x->stop();
        $b->stop();
    } else {
        test_assert(0,"start failed\n");
    }

    exit(0);
} else {
    # PARENT -- test the XMLRPC server

    $b->postfork();

    select(undef,undef,undef,1);
    use XMLRPC::Lite;

    my $set_bucket_color = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('Classifier/Bayes.set_bucket_color','foobarbaz', 'somecolour')
    -> result;

    select(undef,undef,undef,.2);

    my $bucket_color = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('Classifier/Bayes.get_bucket_color','foobarbaz')
    -> result;

    test_assert_equal($bucket_color,"somecolour");

    select(undef,undef,undef,.2);

    my $alive = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('Classifier/Bayes.alive')
    -> result;

    test_assert($alive);

    select(undef,undef,undef,.2);

    $alive = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('Classifier/Bayes.alive',0)
    -> result;

    test_assert(!$alive);

    select(undef,undef,undef,1);
}


