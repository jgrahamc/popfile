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

    # The possible colors for buckets
    $self->{possible_colors} = [ 'red',  'green',      'blue',      'brown',     'orange',     'purple',      'magenta',  'gray',        'plum',     'silver', 
                   'pink', 'lightgreen', 'lightblue', 'lightcyan', 'lightcoral', 'lightsalmon', 'lightgrey', 'darkorange', 'darkcyan', 'feldspar' ];

    # Precomputed per bucket probabilities
    $self->{bucket_start}      = {};

    # A very unlikely word
    $self->{not_likely}        = 0;

    # The expected corpus version
    $self->{corpus_version}    = 1;

    # Per bucket parameters
    $self->{parameters}        = {};
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# write_parameters
#
# Save the parameters hash
#
# ---------------------------------------------------------------------------------------------

sub write_parameters
{
    my ($self) = @_;
    
    for my $bucket (keys %{$self->{total}}) 
    {
        open PARAMS, ">corpus/$bucket/params";
        for my $param (keys %{$self->{parameters}{$bucket}})
        {
            print PARAMS "$param $self->{parameters}{$bucket}{$param}\n";
        }
        close PARAMS;
    }
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
    
    my $max   = -10000;
    my $color = 'black';
    
    for my $bucket (keys %{$self->{total}})
    {
        my $prob = get_value( $self, $bucket, $word);
        
        if ( $prob != 0 ) 
        {
            if ( $prob > $max ) 
            {
                $max   = $prob;
                $color = $self->{colors}{$bucket};
            }
        }
    }
    
    return $color;
}

# ---------------------------------------------------------------------------------------------
#
# Perl hashes are a memory hog.  The original implementation was a Perl hash for the word
# matrix, but instead we use a a set of nested array and some regexps magic.
#
# The word paradise in the bucket spam will be found in the array element
#   matrix{spam}[p] with an entry of the form "|paradise 1234|".
# ---------------------------------------------------------------------------------------------

sub get_value
{
    my ($self, $bucket, $word) = @_;
    $word =~ /^(.)/;
    my $i = ord($1);
    if ( ( $self->{matrix}{$bucket}[$i] =~ /\|\Q$word\E L([\-\.\d]+)\|/ ) != 0 ) 
    {
        return $1;
    } 

    if ( ( $self->{matrix}{$bucket}[$i] =~ /\|\Q$word\E (\d+)\|/ ) != 0 ) 
    {
        my $newvalue = log($1 / $self->{total}{$bucket});
        set_value( $self, $bucket, $word, "L$newvalue" );
        return $newvalue;
    } 
    else
    {
        return 0;
    }
}

sub set_value
{
    my ($self, $bucket, $word, $value) = @_;
    $word =~ /^(.)/;
    my $i = ord($1);

    if ( ( $self->{matrix}{$bucket}[$i] =~ s/\|\Q$word\E (L?[\-\.\d]+)\|/\|$word $value\|/ ) == 0 ) 
    {
        $self->{matrix}{$bucket}[$i] .= "|$word $value|";
    }
}

# ---------------------------------------------------------------------------------------------
#
# update_constants
#
# Updates not_likely and bucket_start
#
# ---------------------------------------------------------------------------------------------

sub update_constants
{
    my ($self) = @_;
    
    if ( $self->{full_total} > 0 ) 
    {
        $self->{not_likely} = log( 1 / ( 10 * $self->{full_total} ) );
    
        foreach my $bucket (keys %{$self->{total}})
        {
            if ( $self->{total}{$bucket} != 0 )
            {
                $self->{bucket_start}{$bucket} = log($self->{total}{$bucket} / $self->{full_total});
            }
            else
            {
                $self->{bucket_start}{$bucket} = 0;
            }
        }
    }
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
        $color =~ s/[\r\n]//g;
        close COLOR;

        $self->{parameters}{$bucket}{subject} = 1;

        # See if there's a color file specified
        open PARAMS, "<corpus/$bucket/params";
        while ( <PARAMS> ) 
        {
            s/[\r\n]//g;
            if ( /^([a-z]+) ([^ ]+)$/ ) 
            {
                $self->{parameters}{$bucket}{$1} = $2;
            }
        }
        close PARAMS;

        if ( $color eq '' ) 
        {
            if ( $c < $#{$self->{possible_colors}} )
            {
                $self->{colors}{$bucket} = $self->{possible_colors}[$c];
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
            if ( /__CORPUS__ __VERSION__ (\d+)/ )
            {
                if ( $1 != $self->{corpus_version} ) 
                {
                    print "Incompatible corpus version in $bucket\n";
                    return;
                }
                
                next;
            }
            
            if ( /(.+) (.+)/ )
            {
                my $word = $self->{mangler}->mangle($1);
                my $value = $2;
                $value =~ s/[\r\n]//g;
                $self->{total}{$bucket}        += $value;
                $self->{full_total}            += $value;
                set_value( $self, $bucket, $word, $value );
            }
        }

        close WORDS;

        print " $self->{total}{$bucket} words\n" if $self->{debug};
    }

    update_constants($self);
    
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

    # Set up the initial score as P(bucket)
  
    my %score;
    
    for my $bucket (keys %{$self->{total}})
    {
        $score{$bucket} = $self->{bucket_start}{$bucket};
    }
    
    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score
    
    # Get the list of buckets
    
    my @buckets = keys %{$self->{total}};

    my $logbuck = 0;
    if ( $#buckets > 0 )
    {
       $logbuck = log( $#buckets + 1 );
    }

    # Ideally, the "raw score" in the score display would reflect the sum of the
    # scores for the individual words, as shown by the lookup GUI.  Actually
    # doing this requires a fair amount of computation to compute the sum of the
    # probabilities.  If we assume that only the most probable choice is significant
    # (that is, that the max probability and the sum of the probabilities are the
    # same), we do much less computation, and still end up with results that are
    # "close enough for jazz".  Note that this makes *no* difference for
    # classification - it only matters for the debug (bayes.pl) display.

    my $correction = -$logbuck;

    # Switching from using *= to += and using the log of every probability instead

    foreach my $word (keys %{$self->{parser}->{words}})
    {
        my $wmax = -10000;

        foreach my $bucket (@buckets)
        {
            my $probability = get_value( $self, $bucket, $word );

            if ( $probability == 0 )
            {
                $probability = $self->{not_likely};
            }

            if ( $wmax < $probability )
            {
               $wmax = $probability;
            }

            # Here we are doing the bayes calculation: P(word|bucket) is in probability
            # and we multiply by the number of times that the word occurs

            $score{$bucket} += ( $probability * $self->{parser}{words}{$word} );
        }
        
        if ($wmax > $self->{not_likely})
        {
            $correction += ($wmax - $logbuck) * $self->{parser}{words}{$word};
        }
        else
        {
            $correction += $wmax * $self->{parser}{words}{$word};
        }
    }

    # Now sort the scores to find the highest and return that bucket as the classification

    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;

    my %raw_score;
    my $base_score = $score{$ranking[0]};
    my $total = 0;

    # Compute the total of all the scores to generate the normalized scores and probability
    # estimate.  $total is always 1 after the first loop iteration, so any additional term
    # less than 2 ** -54 is insignificant, and need not be computed.

    foreach my $b (@ranking)
    {
        $raw_score{$b} = $score{$b};
        $score{$b} -= $base_score;
        if ($score{$b} > 54 * log(0.5))
        {
           $total += exp($score{$b});
        }
    }

    $self->{scores} = "<table><tr><td>Bucket<td>&nbsp;<td>Probability";
    print "Bucket              Raw score      Normalized     Estimated prob\n\n" if $self->{debug};
    foreach my $b (@ranking)
    {
         my $prob = exp($score{$b})/$total;
         my $probstr;
         if ($prob >= 0.1 || $prob == 0.0)
         {
             $probstr = sprintf("%12.6f", $prob);
         }
         else
         {
             $probstr = sprintf("%17.6e", $prob);
         }
         $self->{scores} .= "<tr><td><font color=$self->{colors}{$b}><b>$b</b></font><td>&nbsp;<td>$probstr";
         printf("%-15s%15.6f%15.6f %s\n", $b, ($raw_score{$b} - $correction)/$logbuck, ($score{$b} - log($total))/$logbuck + 1, $probstr) if $self->{debug};
    }
    $self->{scores} .= "</table>";

    # If no bucket has a probability better than 0.5, call the message "unclassified".

    if ( ( $total == 0 ) || ( $score{$ranking[0]} <= log(0.5 * $total) ) )
    {
        return "unclassified";
    }
    else
    {
        return $ranking[0];
    }
}

1;
