# ---------------------------------------------------------------------------------------------
#
# autotest.pl --- Used to test classification accuracy
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;
use Classifier::Bayes;

# main

if ( $#ARGV == -1 )
{
    my $total = 0;
    my $ok    = 0;
    my $fail  = 0;
    
    my $b = new Classifier::Bayes;
    $b->load_word_matrix();
    
    my @tests = glob "test/*";

    foreach my $test (@tests)
    {
        $test =~ /([[:alpha:]0-9-_]+)$/;
        my $class = $1;
        my @files = glob "$test/*";
        
        for my $file (@files )
        {
            $total += 1;
            my $classification = $b->classify_file($file);
            
            if ( $classification eq $class ) 
            {
                $ok   += 1;
            }
            else
            {
                print "\n$file should be in $class but is in $classification..."; 
                $fail += 1;
            }
        }   
    }
    
    print "\nTotal tests: $total, successful: $ok, failed: $fail\n";
}
else
{
    print "autotest.pl - test classification accuracy\n\n";
    print "Usage: autotest.pl\n";
}