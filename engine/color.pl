#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# color.pl --- Used to view a colorized email message
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::MailParse;
use Classifier::Bayes;
use POPFile::Configuration;

# main

if ( $#ARGV == 0 ) 
{
    my $m = new Classifier::MailParse;
    $m->{bayes__} = new Classifier::Bayes;
    $m->{configuration__} = new POPFile::Configuration;
    $m->{configuration__}->{configuration__} = $m->{configuration__};
    $m->{bayes__}->{configuration__} = $m->{configuration__};
    
    
    if ( $m->{bayes__}->initialize() == 0 ) {
        die "Failed to start while initializing the classifier module";
    }

    $m->{bayes__}->load_word_matrix_();
    $m->{color__} = 1;
    print $m->parse_stream($ARGV[0]);
}
else
{
    print "color.pl - color an email by word bucket\n\n";
    print "Usage: color.pl <msg>\n";
    print "       <msg>    The message to color\n";
}