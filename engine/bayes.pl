#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# bayes.pl --- Classify a mail message manually
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::Bayes;

# main

if ( $#ARGV == 0 ) 
{
    my $b = new Classifier::Bayes;
    
    $b->{debug} = 1; 
    $b->{parser}->{debug} = 1;
    $b->load_word_matrix();

    my @files   = glob $ARGV[0];
    foreach my $file (@files)
    {
        print "$file is '" . $b->classify_file($file) . "'\n";
    }
}
else
{
    print "bayes.pl - output the score that a message is in each bucket\n\n";
    print "Usage: bayes.pl <messages>\n";
    print "       <messages>         Filename of message(s) to classify\n";
}