#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# insert.pl --- Inserts a mail message into a specific bucket
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

my $code = 0;

if ( $#ARGV > 0 ) {
    my $c = new POPFile::Configuration;
    my $mq = new POPFile::MQ;
    my $l = new POPFile::Logger;
    my $b = new Classifier::Bayes;
    my $w = new Classifier::WordMangle;

    $c->configuration( $c );
    $c->mq( $mq );
    $c->logger( $l );

    $c->initialize();

    $l->configuration( $c );
    $l->mq( $mq );
    $l->logger( $l );

    $l->initialize();

    $w->configuration( $c );
    $w->mq( $mq );
    $w->logger( $l );

    $w->start();

    $mq->configuration( $c );
    $mq->mq( $mq );
    $mq->logger( $l );

    $b->configuration( $c );
    $b->mq( $mq );
    $b->logger( $l );

    $b->{parser__}->mangle( $w );
    $b->initialize();

    $c->load_configuration();

    $b->start();
    my $session = $b->get_session_key( 'admin', '' );

    my @files;

    if ($^O =~ /linux/) {
        @files = @ARGV[1 .. $#ARGV];
    } else {
        @files = map { glob } @ARGV[1 .. $#ARGV];
    }

    # Check for the existence of each file first because the API
    # call we use does not care if a file is missing

    foreach my $file (@files) {
        if ( !(-e $file) ) {
            print STDERR "Error: File `$file' does not exist, insert aborted.\n";
            $code = 1;
            last;
        }
    }

    if ( $code == 0 ) {
        if ( !$b->is_bucket( $session, $ARGV[0]) ) {
            print STDERR "Error: Bucket `$ARGV[0]' does not exist, insert aborted.\n";
            $code = 1;
        } else {
            $b->add_messages_to_bucket( $session, $ARGV[0], @files );
            print "Added ", $#files+1, " files to `$ARGV[0]'\n";
        }
    }

    $b->release_session_key( $session );
    $b->stop();
    $l->stop();
    $mq->stop();
    $c->stop();
} else {
    print "insert.pl - insert mail messages into a specific bucket\n\n";
    print "Usage: insert.pl <bucket> <messages>\n";
    print "       <bucket>           The name of the bucket\n";
    print "       <messages>         Filename of message(s) to insert\n";
    $code = 1;
}

exit $code;

