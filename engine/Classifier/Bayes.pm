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
    $self->{top10value}        = {};
    $self->{top10html}         = {};
    
    # Precomputed per bucket probabilities
    $self->{bucket_start}      = {};

    # A very unlikely word
    $self->{not_likely}        = 0;
    
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
    
    for my $bucket (keys %{$self->{total}})
    {
        my $prob  = get_value( $self, $bucket, $word);
        
        if ( $prob != 0 ) 
        {
            $prob = 1 / ( -$prob );
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
    if ( ( $self->{matrix}{$bucket}[$i] =~ /\|$word L([\-\.\d]+)\|/ ) != 0 ) 
    {
        return $1;
    } 

    if ( ( $self->{matrix}{$bucket}[$i] =~ /\|$word (\d+)\|/ ) != 0 ) 
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
    if ( ( $self->{matrix}{$bucket}[$i] =~ s/\|$word (L?[\-\.\d]+)\|/\|$word $value\|/ ) == 0 ) 
    {
        $self->{matrix}{$bucket}[$i] .= "|$word $value|";
    }
}

sub compute_top10
{
    my ($self, $bucket, $word, $value) = @_;
    my @values = keys %{$self->{top10value}{$bucket}};

    if ( $#values == 9 ) 
    {
        for my $i ( 0 .. 9 )
        {
            if ( $self->{top10value}{$bucket}{$i} < $value )
            {
                my $j = 9;
                while ( $i < $j )
                {
                    $self->{top10value}{$bucket}{$j} = $self->{top10value}{$bucket}{$j-1};
                    $self->{top10}{$bucket}{$j}      = $self->{top10}{$bucket}{$j-1};
                    $j -= 1;
                }
                
                $self->{top10value}{$bucket}{$i} = $value;
                $self->{top10}{$bucket}{$i}      = $word;
                last;
            }
        }
    }
    else
    {
        my $i = 0;
        if ( $#values >= 0 ) 
        {
            $i = $#values+1;
        }
        $self->{top10value}{$bucket}{$i} = $value;
        $self->{top10}{$bucket}{$i}      = $word;
        
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
    my @colors = ( 'red', 'green', 'blue', 'brown', 'orange', 'purple', 'magenta', 'gray' );
    my $c      = 0;

    $self->{matrix}     = {};
    $self->{total}      = {};
    $self->{full_total} = 0;
    $self->{top10}      = {};
    $self->{top10value} = {};
    $self->{top10html}  = {};
    
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
        $self->{top10bottom}{$bucket} = 0;
    
        while (<WORDS>)
        {
            if ( /(.+) (.+)/ )
            {
                my $word = $self->{mangler}->mangle($1);
                my $value = $2;
                $value =~ s/[\r\n]//g;
                $self->{total}{$bucket}        += $value;
                $self->{full_total}            += $value;
                set_value( $self, $bucket, $word, $value );
                compute_top10( $self, $bucket, $word, $value );
            }
        }

        close WORDS;

        my $number = $self->{total}{$bucket};
        $number = reverse $number;
        $number =~ s/(\d{3})/\1,/g;
        $number = reverse $number;
        $number =~ s/^,(.*)/\1/;
        $self->{top10html}{$bucket} = "<tr><td><font color=$self->{colors}{$bucket}>$bucket</font><td align=right>$number<td>&nbsp;<td align=center><table cellpadding=0 cellspacing=0><tr>";
        for $color (@colors)
        {
            $self->{top10html}{$bucket} .= "<td width=20 bgcolor=$color><a href=/buckets?color=$color&bucket=$bucket><img border=0 alt='Set $bucket color to $color' src=http://www.usethesource.com/images/pix.gif width=20 height=20></a></font>";
        }
        $self->{top10html}{$bucket} .= "</table></td><td><td>";

        for my $i ( 0 .. 9 )
        {
            if ( $self->{top10}{$bucket}{$i} ne '' ) 
            {
                $self->{top10html}{$bucket} .= $self->{top10}{$bucket}{$i};

                if ( $i != 9 ) 
                {
                    $self->{top10html}{$bucket} .= ', ';
                }
            }
        }
        
        print " $self->{total}{$bucket} words\n" if $self->{debug};
    }


    foreach my $bucket (keys %{$self->{total}})
    {
        $self->{bucket_start}{$bucket} = log( $self->{total}{$bucket} / $self->{full_total} );
    }

    # The probability used for words that are not present in the corpus

    $self->{not_likely} = log( 1 / ( 10 * $self->{full_total} ) );

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
  
    my %score = %{$self->{bucket_start}};
    
    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score
    
    # Get the list of buckets
    
    my @buckets = keys %{$self->{total}};

    # Switching from using *= to += and using the log of every probability instead

    foreach my $word (keys %{$self->{parser}->{words}}) 
    {
        foreach my $bucket (@buckets)
        {
            my $probability = get_value( $self, $bucket, $word );
            
            if ( $probability == 0 ) 
            {
                $probability = $self->{not_likely};
            }
    
            # Here we are doing the bayes calculation: P(word|bucket) is in probability
            # and we multiply by the number of times that the word occurs

            $score{$bucket} += ( $probability * $self->{parser}{words}{$word} );
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
