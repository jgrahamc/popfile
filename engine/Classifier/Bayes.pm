package Classifier::Bayes;

# ---------------------------------------------------------------------------------------------
#
# Bayes.pm --- Naive Bayes text classifier
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::WordMangle;

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------

sub new
{
    my $type = shift;
    my $self;

    # Set this to 1 to get debugging information
    $self->{debug}             = 0;
    
    # Matrix of buckets, words and the word counts
    $self->{matrix}            = {};         
    
    # Total number of words in each bucket
    $self->{total}             = {};          
    
    # Total number of words in all buckets
    $self->{full_total}        = 0;     

    # The word mangler used to clean up words
    $self->{mangler}           = new Classifier::WordMangle;
   
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# load_word_matrix
#
# Fills the matrix with the word frequencies from all buckets and builds the bucket total
#
# ---------------------------------------------------------------------------------------------

sub load_word_matrix
{
    my ($self) = @_;
    
    print "Loading the corpus...\n" if $self->{debug};
    
    my @buckets = glob "corpus/*";
    
    foreach my $bucket (@buckets)
    {
        print "Loading $bucket..." if $self->{debug};
        
        open WORDS, "<$bucket/table";

        $bucket =~ /([A-Za-z0-9-_]+)$/;
        $bucket =  $1;

        # Each line in the word table is a word and a count

        while (<WORDS>)
        {
            if ( /(.+) (.+)/ )
            {
                $self->{matrix}{$bucket}{$1} = $2;
                $self->{total}{$bucket}     += $2;
                $self->{full_total}         += $2;
            }
        }

        close WORDS;
        
        print " $self->{total}{$bucket} words\n" if $self->{debug};
    }
    
    print "Corpus loaded with $self->{full_total} entries\n" if $self->{debug};
}

# ---------------------------------------------------------------------------------------------
#
# classify_file
#
# $file      The name of the file containing the text to classify
#
# Splits the mail message into valid words, then runs the Bayes algorithm to figure out
# which bucket it belongs in.  Returns the bucket name
#
# ---------------------------------------------------------------------------------------------

sub classify_file
{
    my ($self, $file) = @_;
    my %words;
    my $msg_total = 0;

    print "Parsing message '$file'..." if $self->{debug};

    open MSG, "<$file";
    
    # Read each line and find each "word" which we define as a sequence of alpha
    # characters
    
    while (<MSG>)
    {
        my $line = $_;
        
        while ( $line =~ s/([A-Za-z]{3,})// )
        {
            my $word = $self->{mangler}->mangle($1);
            
            if ( $word ne '' ) 
            {
                $words{$word} += 1;
                $msg_total += 1;
            }
        }
    }

    close MSG;

    print " $msg_total words\n" if $self->{debug};

    # The score hash will contain the likelihood that the given message is in each
    # bucket, the buckets are the keys for score
    
    my %score;
   
    # Set up the initial score as P(bucket)
    
    foreach my $bucket (keys %{$self->{total}})
    {
        $score{$bucket} = $self->{total}{$bucket} / $self->{full_total};
    }

    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score

    foreach my $word (keys %words) 
    {
        foreach my $bucket (keys %{$self->{total}}) 
        {
            my $bucket_total = $self->{total}{$bucket};
            my $not_likely   = 1 / ( 10 * $bucket_total );
        
            my $probability = $self->{matrix}{$bucket}{$word} / $bucket_total;
            
            if ( $probability == 0 ) 
            {
                $probability = $not_likely;
            }
    
            # Here we are doing the bayes calculation: P(word|bucket) is in probability
            # and we multiply by the number of times that the word occurs
    
            $score{$bucket} *= ( $probability ** $words{$word} );

            # This normalizing code is used because we may end up with probability values 
            # that cause underflow in the arithmetic system.  It figures out which bucket is
            # currently "winning" and makes sure that its values are greater than 1 by
            # shifting all scores up by a certain amount

            my $max = 0;
            
            foreach my $b (keys %{$self->{total}})
            {
                if ( $score{$b} > $max ) 
                {
                    $max = $score{$b}; 
                }
            }

            if ( ( $max < 1 ) && ( $max != 0 ) )
            {
                my $normalize = 10 ** int(log(1/$max)/log(10));

                foreach my $b (keys %{$self->{total}})
                {
                    $score{$b} *= $normalize;
                }
            }
        }
    }

    # Now sort the scores to find the highest and return that bucket as the classification
    
    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;

    if ( $self->{debug} ) 
    {
        foreach my $b (keys %{$self->{total}})
        {
            print "    Bucket $b has score $score{$b}\n";
        }
    }

    if ( $score{$ranking[0]} == 0 ) 
    {
        return "unclassified";
    } 
    else
    {
        return $ranking[0];
    }
}

1;
