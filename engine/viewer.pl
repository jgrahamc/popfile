# ---------------------------------------------------------------------------------------------
#
# viewer.pl --- Used to view information about bucket probabilities
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::WordMangle;

# main

if ( ( $#ARGV == 0 ) || ( $#ARGV == -1 ) )
{
    my $m = new Classifier::WordMangle;
    my $test_word;
  
    if ( $#ARGV == 0 ) 
    {
        $test_word = $ARGV[0];
    } 
    else
    {
        $test_word = "";
    }
  
    my @files = glob "corpus/*";

    foreach my $file (@files)
    {
        my %words;
        my $total;
        
        open WORDS, "<$file/table";

        # Each line in the word table is a word and a count

        $total = 0;

        while (<WORDS>)
        {
            if ( /__CORPUS__ __VERSION__ (\d+)/ )
            {
                if ( $1 != 1 ) 
                {
                    print "Incompatible corpus version in $file\n";
                    return;
                }
                
                next;
            }
            
            if ( /(.+) (.+)/ )
            {
                my $word = $m->mangle($1);
                
                if ( $word ne '' ) 
                {
                    $words{$word} = $2;
                    $total       += $2;
                }
            }
        }

        close WORDS;

        if ( $test_word ne '' ) 
        {
            if ( $words{$test_word} ) 
            {
                printf("\n%20s (%f)", $file, $words{$test_word} / $total );
            }
        }
        else
        {
            print "\n\nBucket $file... ";
        
            my @ranking = sort {$words{$b} <=> $words{$a}} keys %words;

            for my $i ( 0.. 19 )
            {
                printf("\n%20s (%d)", $ranking[$i], int($words{$ranking[$i]}));
            }
        }
    }

    print "\n";
}
else
{
    print "viewer.pl - get information about the current corpus\n\n";
    print "Usage: viewer.pl (<word>)\n";
    print "       <word>    Outputs the likelihood of this word appearing in each bucket";
}