package Classifier::Bayes;

# ---------------------------------------------------------------------------------------------
#
# Bayes.pm --- Naive Bayes text classifier
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::MailParse;
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

    # Used to mangle the corpus when loaded
    $self->{mangler}           = new Classifier::WordMangle;

    # Used to parse mail messages
    $self->{parser}            = new Classifier::MailParse;

    # Colors assigned to each bucket
    $self->{colors}            = {};

    # Precomputed top 10 words in each bucket
    $self->{top10}             = {};
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# get_color
#
# Retrieves the color for a specific word, color is the most likely bucket
#
# ---------------------------------------------------------------------------------------------

sub get_color
{
    my ($self, $word) = @_;
    
    my $max   = 0;
    my $color = 'black';
    
    for my $bucket (keys %{$self->{matrix}})
    {
        my $prob  = ( $self->{matrix}{$bucket}{$word} / $self->{total}{$bucket} );
        
        if ( $prob > $max ) 
        {
            $max   = $prob;
            $color = $self->{colors}{$bucket};
        }
    }
    
    return $color;
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
    my @colors = ( 'red', 'green', 'blue', 'brown', 'orange', 'purple', 'magenta', 'gray' );
    my $c      = 0;

    $self->{matrix}     = {};
    $self->{total}      = {};
    $self->{full_total} = 0;
    
    print "Loading the corpus...\n" if $self->{debug};
    
    my @buckets = glob "corpus/*";
    
    foreach my $bucket (@buckets)
    {
        print "Loading $bucket..." if $self->{debug};

        open WORDS, "<$bucket/table";

        # See if there's a color file specified
        open COLOR, "<$bucket/color";
        $bucket =~ /([A-Za-z0-9-_]+)$/;
        $bucket =  $1;
        my $color = <COLOR>;
        close COLOR;

        if ( $color eq '' ) 
        {
            if ( $c < $#colors )
            {
                $self->{colors}{$bucket} = $colors[$c];
                $c += 1;
            } 
            else 
            {
                $self->{colors}{$bucket} = 'black';
            }
        }
        else 
        {
                $self->{colors}{$bucket} = $color;
        }


        # Each line in the word table is a word and a count
        $self->{total}{$bucket} = 0;
    
        while (<WORDS>)
        {
            if ( /(.+) (.+)/ )
            {
                my $word = $self->{mangler}->mangle($1);
                $self->{matrix}{$bucket}{$word} = $2;
                $self->{total}{$bucket}        += $2;
                $self->{full_total}            += $2;
            }
        }

        close WORDS;

        # Now adjust the values in the table so that they are probabilities
        
        for my $word (keys %{$self->{matrix}{$bucket}})
        {
            $self->{matrix}{$bucket}{$word} /= $self->{total}{$bucket};
        }

        $self->{top10}{$bucket} = "<tr><td><font color=$self->{colors}{$bucket}>$bucket</font><td>$self->{total}{$bucket}<td><table cellpadding=0 cellspacing=0><tr>";
        for $color (@colors)
        {
            $self->{top10}{$bucket} .= "<td width=20 bgcolor=$color><a href=/corpus?color=$color&bucket=$bucket><img border=0 alt='Set $bucket color to $color' src=http://www.usethesource.com/images/pix.gif width=20 height=20></a></font>";
        }
        $self->{top10}{$bucket} .= "</table></td><td><td>";
        my @ranking = sort {$self->{matrix}{$bucket}{$b} <=> $self->{matrix}{$bucket}{$a}} keys %{$self->{matrix}{$bucket}};
        for my $i ( 0.. 9 )
        {
            if ( $ranking[$i] ne '' ) 
            {
                $self->{top10}{$bucket} .= "$ranking[$i]";

                if ( $i != 9 ) 
                {
                    $self->{top10}{$bucket} .= ', ';
                }
            }
        }
        
        print " $self->{total}{$bucket} words\n" if $self->{debug};
    }
    
    print "Corpus loaded with $self->{full_total} entries\n" if $self->{debug};
    
    print "    ... $self->{full_total} words\n";
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
    my $msg_total = 0;

    print "Parsing message '$file'..." if $self->{debug};

    $self->{parser}->parse_stream($file);

    print " $self->{parser}->{msg_total} words\n" if $self->{debug};

    # The score hash will contain the likelihood that the given message is in each
    # bucket, the buckets are the keys for score
    
    my %score;
   
    # Set up the initial score as P(bucket)
    
    foreach my $bucket (keys %{$self->{total}})
    {
        $score{$bucket} = $self->{total}{$bucket} / $self->{full_total};
    }

    # The probability used for words that are not present in the corpus

    my $not_likely   = 1 / ( 10 * $self->{full_total} );
    
    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score
    
    # Get the list of buckets
    
    my @buckets = keys %{$self->{total}};

    foreach my $word (keys %{$self->{parser}->{words}}) 
    {
        foreach my $bucket (@buckets)
        {
            my $probability  = $self->{matrix}{$bucket}{$word};
            
            if ( $probability == 0 ) 
            {
                $probability = $not_likely;
            }
    
            # Here we are doing the bayes calculation: P(word|bucket) is in probability
            # and we multiply by the number of times that the word occurs

            for my $i (1 .. $self->{parser}->{words}{$word})
            {
                my $max;
                
                $score{$bucket} *= $probability;

                # This normalizing code is used because we may end up with probability values 
                # that cause underflow in the arithmetic system.  It figures out which bucket is
                # currently "winning" and makes sure that its values are greater than 1 by
                # shifting all scores up by a certain amount

                $max = 0;
                
                foreach my $b (@buckets)
                {
                    if ( $score{$b} > $max ) 
                    {
                        $max = $score{$b}; 
                    }
                }

                if ( ( $max < 1 ) && ( $max != 0 ) )
                {
                    my $normalize = 10 ** int(log(1/$max)/log(10) + 0.5);

                    foreach my $b (@buckets)
                    {
                        $score{$b} *= $normalize;
                    }
                }
            }
        }
    }

    # Now sort the scores to find the highest and return that bucket as the classification
    
    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;

    if ( $self->{debug} ) 
    {
        foreach my $b (@ranking)
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
