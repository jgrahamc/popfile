#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# bayes.pl --- Classify a mail message manually
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::Bayes;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;

# main

if ( $#ARGV == 0 ) {
    my $c = new POPFile::Configuration;
    my $mq = new POPFile::MQ;
    my $l = new POPFile::Logger;
    my $b = new Classifier::Bayes;

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

    $b->initialize();

    $c->load_configuration();

$b->config_( 'corpus', 'tests/corpus' );
    $b->start();

$b->{parser__}->{color__} = 1;
$b->{parser__}->{bayes__} = $b;

    my @files   = glob $ARGV[0];
    foreach my $file (@files) {
        print "$file is '" . $b->classify($file) . "'\n";
        print $b->{parser__}->parse_file($file);

    }

    foreach my $word (sort keys %{$b->{parser__}->{words__}}) {
        print "$word $b->{parser__}->{words__}{$word}\n";
    }
}
else
{
    print "bayes.pl - output the score that a message is in each bucket\n\n";
    print "Usage: bayes.pl <messages>\n";
    print "       <messages>         Filename of message(s) to classify\n";
}
