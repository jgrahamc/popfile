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

# main

if ( $#ARGV == 0 ) 
{
    my $m = new Classifier::MailParse;
    
    $m->{bayes} = new Classifier::Bayes;
    $m->{bayes}->load_word_matrix();
    $m->{color} = 1;
    print $m->parse_stream($ARGV[0]);
}
else
{
    print "color.pl - color an email by word bucket\n\n";
    print "Usage: color.pl <msg>\n";
    print "       <msg>    The message to color\n";
}