#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# pipe.pl --- Read a message in on STDIN and write out the modified version on STDOUT
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::Bayes;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use UI::HTML;

# main

if ( $#ARGV == -1 ) 
{
    my $c = new POPFile::Configuration;
    my $mq = new POPFile::MQ;
    my $l = new POPFile::Logger;
    my $b = new Classifier::Bayes;
    my $u = new UI::HTML;

    $u->configuration( $c );
    $u->mq( $mq );
    $u->logger( $l );

    $l->configuration( $c );
    $l->mq( $mq );
    $l->logger( $l );

    $mq->configuration( $c );
    $mq->mq( $mq );
    $mq->logger( $l );

    $b->configuration( $c );
    $b->mq( $mq );
    $b->logger( $l );

    $c->configuration( $c );
    $c->mq( $mq );
    $c->logger( $l );

    $l->initialize();
    $c->initialize();
    $b->initialize();
    $u->initialize();

    $b->start();

    $b->classify_and_modify(\*STDIN, \*STDOUT, 0, 0, 1, '', 1) . "'\n";
}
else
{
    print "pipe.pl - reads a message on STDIN, classifies it, outputs the modified version on STDOUT\n\n";
    print "Usage: pipe.pl\n";
}