#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# pipe.pl --- Read a message in on STDIN and write out the modified version on STDOUT
#
# Copyright (c) 2001-2004 John Graham-Cumming
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

use strict;
use Classifier::Bayes;
use Classifier::WordMangle;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use UI::HTML;

# main

if ( $#ARGV == -1 ) {
    my $c = new POPFile::Configuration;
    my $mq = new POPFile::MQ;
    my $l = new POPFile::Logger;
    my $b = new Classifier::Bayes;
    my $u = new UI::HTML;
    my $w = new Classifier::WordMangle;

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

    $c->initialize();
    $l->initialize();

    $w->configuration( $c );
    $w->mq( $mq );
    $w->logger( $l );

    $w->start();

    $b->{parser__}->mangle( $w );
    $b->initialize();
    $u->initialize();

    $c->load_configuration();

    $b->start();

    my $session = $b->get_session_key( 'admin', '' );

    $b->classify_and_modify( $session, \*STDIN, \*STDOUT, 0, 0, 1, '', 1, "\n") . "'\n";

    $b->release_session_key( $session );
    $b->stop();
    $l->stop();
    $mq->stop();
    $c->stop();
    $u->stop();

    exit 0;
} else {
    print "pipe.pl - reads a message on STDIN, classifies it, outputs the modified version on STDOUT\n\n";
    print "Usage: pipe.pl\n";

    exit 1;
}
