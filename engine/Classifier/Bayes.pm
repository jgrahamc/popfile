package Classifier::Bayes;

# ---------------------------------------------------------------------------------------------
#
# Bayes.pm --- Naive Bayes text classifier
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;
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
    
    # Set this to 1 to get scores for individual words in message detail
    $self->{wordscores}        = 1;
    
    # Matrix of buckets, words and the word counts
    $self->{matrix}            = {};         
    
    # Total number of words in each bucket
    $self->{total}             = {};          

    # Total number of unique words in each bucket
    $self->{unique}            = {};          
    
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
    
    # The magnets that cause attraction to certain buckets
    $self->{magnets}           = {};
    
    # Where the corpus is stored
    $self->{corpus}            = 'corpus';
    
    # The unclassified cutoff probability
    $self->{unclassified}      = 0.5;
    
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
        open PARAMS, ">$self->{corpus}/$bucket/params";
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
# $word     Word to get the color of
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
#
# TODO: replace the word matrix hash with Berkeley DB tie
#
# ---------------------------------------------------------------------------------------------

sub get_value
{
    my ($self, $bucket, $word) = @_;
    $word =~ /^(.)/;
    my $i = ord($1);
    
    if ( defined($self->{matrix}{$bucket}[$i]) )
    {
        if ( ( $self->{matrix}{$bucket}[$i] =~ /\|\Q$word\E L([\-\.\d]+)\|/ ) != 0 ) 
        {
            return $1;
        } 
    }
    
    if ( defined($self->{matrix}{$bucket}[$i]) )
    {
        if ( ( $self->{matrix}{$bucket}[$i] =~ /\|\Q$word\E (\d+)\|/ ) != 0 ) 
        {
            my $newvalue = log($1 / $self->{total}{$bucket});
            set_value( $self, $bucket, $word, "L$newvalue" );
            return $newvalue;
        } 
    }

    return 0;
}

sub set_value
{
    my ($self, $bucket, $word, $value) = @_;
    $word =~ /^(.)/;
    my $i = ord($1);

    if ( !defined($self->{matrix}{$bucket}[$i]) ) 
    {
        $self->{matrix}{$bucket}[$i] = '';
    }

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
    
    my @buckets = glob "$self->{corpus}/*";
    
    foreach my $bucket (@buckets)
    {
        my $color = '';

        # See if there's a color file specified
        if ( open COLOR, "<$bucket/color" )
        {
            $color = <COLOR>;
            $color =~ s/[\r\n]//g;
            close COLOR;
        }
        
        load_bucket( $self, $bucket );
        $bucket =~ /([[:alpha:]0-9-_]+)$/;
        $bucket =  $1;
        $self->{full_total} += $self->{total}{$bucket};
        
        if ( $color eq '' ) 
        {
            if ( $c < $#{$self->{possible_colors}} )
            {
                $self->{colors}{$bucket} = $self->{possible_colors}[$c];
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

        $c += 1;
    }

    update_constants($self);
    
    print "Corpus loaded with $self->{full_total} entries\n" if $self->{debug};
}

# ---------------------------------------------------------------------------------------------
#
# load_bucket
#
# Loads an individual bucket
#
# ---------------------------------------------------------------------------------------------

sub load_bucket
{
    my ($self, $bucket) = @_;

    print "Loading $bucket..." if $self->{debug};

    $bucket =~ /([[:alpha:]0-9-_]+)$/;
    $bucket =  $1;
    $self->{parameters}{$bucket}{subject} = 1;
    $self->{total}{$bucket}  = 0;
    $self->{unique}{$bucket} = 0;
    $self->{matrix}{$bucket} = ();
    $self->{magnets}{$bucket} = {};

    # See if there's a color file specified
    if ( open PARAMS, "<$self->{corpus}/$bucket/params" )
    {
        while ( <PARAMS> ) 
        {
            s/[\r\n]//g;
            if ( /^([[:lower:]]+) ([^ ]+)$/ ) 
            {
                $self->{parameters}{$bucket}{$1} = $2;
            }
        }
        close PARAMS;
    }

    # See if there are magnets defined
    if ( open MAGNETS, "<$self->{corpus}/$bucket/magnets" )
    {
        while ( <MAGNETS> ) 
        {
            s/[\r\n]//g;
            if ( /^([^ ]+) (.+)$/ ) 
            {
                $self->{magnets}{$bucket}{$1}{$2} = 1;
            } 
            else 
            {
                if ( /^(.+)$/ ) 
                {
                    $self->{magnets}{$bucket}{from}{$1} = 1;
                }
            }
        }
        close MAGNETS;
    }

    # Each line in the word table is a word and a count
    $self->{total}{$bucket} = 0;

    if ( open WORDS, "<$self->{corpus}/$bucket/table" ) 
    {
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
                if ( $value > 0 ) 
                {
                    $self->{total}{$bucket}        += $value;
                    $self->{unique}{$bucket}       += 1;
                    set_value( $self, $bucket, $word, $value );
                }
            }
        }

        close WORDS;
    }
    
    print " $self->{total}{$bucket} words\n" if $self->{debug};
}

# ---------------------------------------------------------------------------------------------
#
# save_magnets
#
# Save all the magnet definitions
#
# ---------------------------------------------------------------------------------------------

sub save_magnets
{
    my ($self) = @_;
    
    for my $bucket (keys %{$self->{total}})
    {
        open MAGNET, ">$self->{corpus}/$bucket/magnets";
        
        for my $type (keys %{$self->{magnets}{$bucket}}) 
        {        
            for my $from (keys %{$self->{magnets}{$bucket}{$type}}) 
            {
                print MAGNET "$type $from\n";
            }
        }
        
        close MAGNET;
    }
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

    # Check to see if this email should be classified based on a magnet
    print " $self->{parser}->{msg_total} words\n" if $self->{debug};

    # Get the list of buckets
    
    my @buckets = keys %{$self->{total}};

    for my $bucket (keys %{$self->{magnets}}) 
    {
        for my $type (keys %{$self->{magnets}{$bucket}})
        {
            for my $magnet (keys %{$self->{magnets}{$bucket}{$type}})
            {
                if ( $self->{parser}->{$type} =~ /\Q$magnet\E/i )
                {
                    $self->{scores} = "<b>Magnet Used</b><p>Classified to <font color=$self->{colors}{$bucket}>$bucket</font> because of magnet $type: $magnet";
                    return $bucket;
                }
            }
        }
    }

    # The score hash will contain the likelihood that the given message is in each
    # bucket, the buckets are the keys for score

    # Set up the initial score as P(bucket)
  
    my %score;
    my %wordprob;
    my %wtprob;
    my %wbprob;
    
    for my $bucket (keys %{$self->{total}})
    {
        $score{$bucket} = $self->{bucket_start}{$bucket};
    }
    
    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score
    
    my $logbuck = 1;
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
        if ($self->{wordscores}) {
            $wtprob{$word} = 0;
            $wbprob{$word} = {};
        }
        
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
            if ($self->{wordscores}) {
                $wtprob{$word} += exp($probability);
                $wbprob{$word}{$bucket} = exp($probability);
            }
        }
        
        if ($wmax > $self->{not_likely})
        {
            $correction += ($wmax - $logbuck) * $self->{parser}{words}{$word};
        }
        else
        {
            $correction += $wmax * $self->{parser}{words}{$word};
        }
        $wordprob{$word} = exp($wmax);
    }

    # Now sort the scores to find the highest and return that bucket as the classification

    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;
    my @wordrank;
    if ($self->{wordscores})
    {
        @wordrank = sort {($wordprob{$b} / $wtprob{$b}) <=> ($wordprob{$a} / $wtprob{$a})} keys %wordprob;
    }

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

    $self->{scores} = "<b>Scores</b><p><table><tr><td>Bucket<td>&nbsp;<td>Probability";
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

    if ($self->{wordscores})
    {
        $self->{scores} .= "<table><tr><td colspan=4>&nbsp;</td></tr><tr><td><b>Word</b></td><td><b>Prob</b></td><td>&nbsp;</td><td><font color=$self->{colors}{$ranking[0]}><b>$ranking[0]</b></font></td></tr>";
        my $wi = 0;
        foreach my $word (@wordrank)
        {
            if ( $wi < 20 && $wordprob{$word} / $wtprob{$word} >= 0.25 ) {
                my $wordstr = $word;
                if ( length($wordstr)>14 ) 
                {
                    $wordstr =~ /(.{12})/;
                    $wordstr = "$1...";
                }
                my $wordcolor = get_color($self, $word);
                my $wordprobstr = sprintf("%12.4f", $wordprob{$word} / $wtprob{$word});
                my $otherprobstr = sprintf("%12.4f", $wbprob{$word}{$ranking[0]} / $wtprob{$word});
                $self->{scores} .= "<tr><td><font color=$wordcolor>$wordstr</font></td>";
                $self->{scores} .= "<td><font color=$wordcolor>$wordprobstr</font></td><td>&nbsp;</td>";
                $self->{scores} .= "<td><font color=$self->{colors}{$ranking[0]}>$otherprobstr</font></td></tr>";
            }
            $wi += 1;
        }

        $self->{scores} .= "</table><p>";
    }

    # If no bucket has a probability better than 0.5, call the message "unclassified".

    if ( ( $total == 0 ) || ( $score{$ranking[0]} <= log($self->{unclassified} * $total) ) )
    {
        return "unclassified";
    }
    else
    {
        return $ranking[0];
    }
}

1;
