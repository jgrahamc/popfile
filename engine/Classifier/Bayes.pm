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

# This is used to get the hostname of the current machine
# in a cross platform way
use Sys::Hostname;

# A handy variable containing the value of an EOL for Unix systems
my $eol = "\015\012";

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

    # Just our hostname
    $self->{hostname}        = '';

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
    
    # Used to tell the caller whether a magnet was used in the last 
    # mail classification
    $self->{magnet_used}       = 0;
    $self->{magnet_detail}     = '';
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to set up the Bayes module's parameters
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;
    
    # No default unclassified probability
    $self->{configuration}->{configuration}{unclassified_probability} = 0;

    # The corpus is kept in the 'corpus' subfolder of POPFile
    $self->{configuration}->{configuration}{corpus}                   = 'corpus';
    
    # Get the hostname for use in the X-POPFile-Link header
    $self->{hostname} = hostname;

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to start the Bayes module running
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;
    
    if ( $self->{configuration}->{configuration}{unclassified_probability} != 0 )  {
        $self->{unclassified} = $self->{configuration}->{configuration}{unclassified_probability};
    }
    
    load_word_matrix( $self );
    
    return 1; 
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called when POPFile is terminating
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;
    
    write_parameters( $self );
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;
    
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# Called when someone forks POPFile
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;
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
    
    for my $bucket (keys %{$self->{total}})  {
        open PARAMS, ">$self->{corpus}/$bucket/params";
        for my $param (keys %{$self->{parameters}{$bucket}}) {
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
    
    for my $bucket (keys %{$self->{total}}) {
        my $prob = get_value( $self, $bucket, $word);
        
        if ( $prob != 0 )  {
            if ( $prob > $max )  {
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
    
    if ( defined($self->{matrix}{$bucket}[$i]) ) {
        return $1 if ( ( $self->{matrix}{$bucket}[$i] =~ /\|\Q$word\E L([\-\.\d]+)\|/ ) != 0 );
    }
    
    if ( defined($self->{matrix}{$bucket}[$i]) ) {
        if ( ( $self->{matrix}{$bucket}[$i] =~ /\|\Q$word\E (\d+)\|/ ) != 0 )  {
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

    $self->{matrix}{$bucket}[$i] = '' if ( !defined($self->{matrix}{$bucket}[$i]) );
    $self->{matrix}{$bucket}[$i] .= "|$word $value|" if ( ( $self->{matrix}{$bucket}[$i] =~ s/\|\Q$word\E (L?[\-\.\d]+)\|/\|$word $value\|/ ) == 0 );
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
    
    if ( $self->{full_total} > 0 )  {
        $self->{not_likely} = log( 1 / ( 10 * $self->{full_total} ) );
    
        foreach my $bucket (keys %{$self->{total}}) {
            if ( $self->{total}{$bucket} != 0 ) {
                $self->{bucket_start}{$bucket} = log($self->{total}{$bucket} / $self->{full_total});
            } else {
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
    $self->{magnets}    = {};
    $self->{full_total} = 0;
    
    print "Loading the corpus...\n" if $self->{debug};
    
    my @buckets = glob "$self->{corpus}/*";
    
    foreach my $bucket (@buckets) {
        my $color = '';

        # See if there's a color file specified
        if ( open COLOR, "<$bucket/color" ) {
            $color = <COLOR>;
            $color =~ s/[\r\n]//g;
            close COLOR;
        }
        
        load_bucket( $self, $bucket );
        $bucket =~ /([[:alpha:]0-9-_]+)$/;
        $bucket =  $1;
        $self->{full_total} += $self->{total}{$bucket};
        
        if ( $color eq '' )  {
            if ( $c < $#{$self->{possible_colors}} ) {
                $self->{colors}{$bucket} = $self->{possible_colors}[$c];
            } else {
                $self->{colors}{$bucket} = 'black';
            }
        } else {
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
    $self->{parameters}{$bucket}{count}   = 0;
    $self->{total}{$bucket}  = 0;
    $self->{unique}{$bucket} = 0;
    $self->{matrix}{$bucket} = ();
    $self->{magnets}{$bucket} = {};

    # See if there's a color file specified
    if ( open PARAMS, "<$self->{corpus}/$bucket/params" ) {
        while ( <PARAMS> )  {
            s/[\r\n]//g;
            if ( /^([[:lower:]]+) ([^ ]+)$/ )  {
                $self->{parameters}{$bucket}{$1} = $2;
            }
        }
        close PARAMS;
    }

    # See if there are magnets defined
    if ( open MAGNETS, "<$self->{corpus}/$bucket/magnets" ) {
        while ( <MAGNETS> )  {
            s/[\r\n]//g;
            if ( /^([^ ]+) (.+)$/ )  {
                $self->{magnets}{$bucket}{$1}{$2} = 1;
            } else {
                $self->{magnets}{$bucket}{from}{$1} = 1 if ( /^(.+)$/ );
            }
        }
        close MAGNETS;
    }

    # Each line in the word table is a word and a count
    $self->{total}{$bucket} = 0;

    if ( open WORDS, "<$self->{corpus}/$bucket/table" )  {
        while (<WORDS>) {
            if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
                if ( $1 != $self->{corpus_version} )  {
                    print "Incompatible corpus version in $bucket\n";
                    return;
                }

                next;
            }

            if ( /(.+) (.+)/ ) {
                my $word = $self->{mangler}->mangle($1);
                my $value = $2;
                $value =~ s/[\r\n]//g;
                if ( $value > 0 )  {
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
    
    for my $bucket (keys %{$self->{total}}) {
        open MAGNET, ">$self->{corpus}/$bucket/magnets";
        
        for my $type (keys %{$self->{magnets}{$bucket}})  {        
            for my $from (keys %{$self->{magnets}{$bucket}{$type}})  {
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

    $self->{magnet_used}   = 0;
    $self->{magnet_detail} = 0;

    print "Parsing message '$file'..." if $self->{debug};

    $self->{parser}->parse_stream($file);

    # Check to see if this email should be classified based on a magnet
    print " $self->{parser}->{msg_total} words\n" if $self->{debug};

    # Get the list of buckets
    
    my @buckets = keys %{$self->{total}};

    for my $bucket (sort keys %{$self->{magnets}})  {
        for my $type (sort keys %{$self->{magnets}{$bucket}}) {
            for my $magnet (sort keys %{$self->{magnets}{$bucket}{$type}}) {
                if ( $self->{parser}->{$type} =~ /\Q$magnet\E/i ) {
                    $self->{scores}        = "<b>Magnet Used</b><p>Classified to <font color=$self->{colors}{$bucket}>$bucket</font> because of magnet $type: $magnet";
                    $self->{magnet_used}   = 1;
                    $self->{magnet_detail} = "$type: $magnet";
                    
                    return $bucket;
                }
            }
        }
    }

    # If the user has not defined any buckets then we escape here return unclassified
    return "unclassified " if ( $#buckets == -1 );

    # The score hash will contain the likelihood that the given message is in each
    # bucket, the buckets are the keys for score

    # Set up the initial score as P(bucket)
  
    my %score;
    my %wordprob;
    my %wtprob;
    my %wbprob;
    
    for my $bucket (@buckets) {
        $score{$bucket} = $self->{bucket_start}{$bucket};
    }
    
    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score
    
    my $logbuck = 1;
    $logbuck = log( $#buckets + 1 ) if ( $#buckets > 0 );

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

    foreach my $word (keys %{$self->{parser}->{words}}) {
        my $wmax = -10000;
        if ($self->{wordscores})  {
            $wtprob{$word} = 0;
            $wbprob{$word} = {};
        }
        
        foreach my $bucket (@buckets) {
            my $probability = get_value( $self, $bucket, $word );

            $probability = $self->{not_likely} if ( $probability == 0 );
            $wmax = $probability if ( $wmax < $probability );

            # Here we are doing the bayes calculation: P(word|bucket) is in probability
            # and we multiply by the number of times that the word occurs

            $score{$bucket} += ( $probability * $self->{parser}{words}{$word} );
            if ($self->{wordscores})  {
                $wtprob{$word} += exp($probability);
                $wbprob{$word}{$bucket} = exp($probability);
            }
        }
        
        if ($wmax > $self->{not_likely}) {
            $correction += ($wmax - $logbuck) * $self->{parser}{words}{$word};
        } else {
            $correction += $wmax * $self->{parser}{words}{$word};
        }
        $wordprob{$word} = exp($wmax);
    }

    # Now sort the scores to find the highest and return that bucket as the classification

    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;
    my @wordrank;
    if ($self->{wordscores}) {
        @wordrank = sort {($wordprob{$b} / $wtprob{$b}) <=> ($wordprob{$a} / $wtprob{$a})} keys %wordprob;
    }

    my %raw_score;
    my $base_score = $score{$ranking[0]};
    my $total = 0;

    # Compute the total of all the scores to generate the normalized scores and probability
    # estimate.  $total is always 1 after the first loop iteration, so any additional term
    # less than 2 ** -54 is insignificant, and need not be computed.

    foreach my $b (@ranking) {
        $raw_score{$b} = $score{$b};
        $score{$b} -= $base_score;
        $total += exp($score{$b}) if ($score{$b} > 54 * log(0.5));
    }

    $self->{scores} = "<b>Scores</b><p><table><tr><td>Bucket<td>&nbsp;<td>Probability";
    print "Bucket              Raw score      Normalized     Estimated prob\n\n" if $self->{debug};
    foreach my $b (@ranking) {
         my $prob = exp($score{$b})/$total;
         my $probstr;
         if ($prob >= 0.1 || $prob == 0.0) {
             $probstr = sprintf("%12.6f", $prob);
         } else {
             $probstr = sprintf("%17.6e", $prob);
         }
         $self->{scores} .= "<tr><td><font color=$self->{colors}{$b}><b>$b</b></font><td>&nbsp;<td>$probstr";
         printf("%-15s%15.6f%15.6f %s\n", $b, ($raw_score{$b} - $correction)/$logbuck, ($score{$b} - log($total))/$logbuck + 1, $probstr) if $self->{debug};
    }
    $self->{scores} .= "</table>";

    if ($self->{wordscores}) {
        $self->{scores} .= "<table><tr><td colspan=4>&nbsp;</td></tr><tr><td><b>Word</b></td><td><b>Prob</b></td><td>&nbsp;</td><td><font color=$self->{colors}{$ranking[0]}><b>$ranking[0]</b></font></td></tr>";
        my $wi = 0;
        foreach my $word (@wordrank) {
            if ( $wi < 20 && $wordprob{$word} / $wtprob{$word} >= 0.25 ) {
                my $wordstr = $word;
                if ( length($wordstr)>14 )  {
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

    if ( ( $total == 0 ) || ( $score{$ranking[0]} <= log($self->{unclassified} * $total) ) ) {
        return "unclassified";
    } else {
        return $ranking[0];
    }
}

# ---------------------------------------------------------------------------------------------
#
# classify_and_modify
#
# This method reads an email terminated by . on a line by itself (or the end of stream)
# from a handle and creates an entry in the history, outputting the same email on another
# handle with the appropriate header modifications and insertions
#
# $mail     - an open stream to read the email from
# $client   - an open stream to write the modified email to
# $dcount   - the unique download count for this message
# $mcount   - the message count for this message
# $nosave   - indicates that the message downloaded should not be saved in the history
# $class    - if we already know the classification
#
# Returns a classification if it worked, otherwise returns an empty string
#
# ---------------------------------------------------------------------------------------------
sub classify_and_modify
{
    my ( $self, $mail, $client, $dcount, $mcount, $nosave, $class ) = @_;
    
    my $msg_subject     = '';     # The message subject
    my $msg_head_before = '';     # Store the message headers that come before Subject here
    my $msg_head_after  = '';     # Store the message headers that come after Subject here
    my $msg_body        = '';     # Store the message body here

    # These two variables are used to control the insertion of the X-POPFile-TimeoutPrevention
    # header when downloading long or slow emails
    my $last_timeout   = time;
    my $timeout_count  = 0;

    # Indicates whether the first time through the receive loop we got the full body, this
    # will happen on small emails
    my $got_full_body  = 0;

    # The size of the message downloaded so far.
    my $message_size   = 0;

    # The classification for this message
    my $classification = '';

    # Whether we are currently reading the mail headers or not
    my $getting_headers = 1;

    my $temp_file  = "messages/popfile$dcount" . "=$mcount.msg";
    my $class_file = "messages/popfile$dcount" . "=$mcount.cls";

    $self->{logger}->debug( "Writing $temp_file" );

    open TEMP, ">$temp_file";
    binmode TEMP;

    while ( <$mail> ) {   
        my $line;

        $line = $_;

        # Check for an abort
        last if ( $self->{alive} == 0 );

        # The termination of a message is a line consisting of exactly .CRLF so we detect that
        # here exactly
        if ( $line =~ /^\.(\r\n|\r|\n)$/ ) {
            $got_full_body = 1;
            last;
        }

        if ( $getting_headers )  {
            if ( $line =~ /[A-Z0-9]/i )  {
                $message_size += length $line;                                        
                print TEMP $line;

                if ( $self->{configuration}->{configuration}{subject} )  {
                    if ( $line =~ /Subject:(.*)/i )  {
                        $msg_subject = $1;
                        $msg_subject =~ s/(\012|\015)//g;
                        next;
                    } 
                }

                # Strip out the X-Text-Classification header that is in an incoming message
                if ( ( $line =~ /X-Text-Classification:/i ) == 0 ) {
                    if ( $msg_subject eq '' )  {
                        $msg_head_before .= $line;
                    } else {
                        $msg_head_after  .= $line;
                    }
                }
            } else {
                print TEMP $eol;
                $getting_headers = 0;
            }
        } else {
            $message_size += length $line;
            print TEMP $line;
            $msg_body .= $line;
        }

        # Check to see if too much time has passed and we need to keep the mail client happy
        if ( time > ( $last_timeout + 2 ) ) {
            print $client "X-POPFile-TimeoutPrevention: $timeout_count$eol" if ( !$nosave );
            $timeout_count += 1;
            $last_timeout = time;
        }

        last if ( ( $message_size > 100000 ) && ( $getting_headers == 0 ) );
    }

    close TEMP;

    # Do the text classification and update the counter for that bucket that we just downloaded
    # an email of that type
    $classification = ($class ne '')?$class:$self->classify_file($temp_file);

    # Add the Subject line modification or the original line back again
    if ( $self->{configuration}->{configuration}{subject} ) {
        # Don't add the classification unless it is not present
        if ( !( $msg_subject =~ /\[$classification\]/ ) && ( $self->{parameters}{$classification}{subject} == 1 ) )  {
            $msg_head_before .= "Subject: [$classification]$msg_subject$eol";
        } else {
            $msg_head_before .= "Subject:$msg_subject$eol";
        }
    }

    if ( $nosave ) {
        unlink( $temp_file );
    }

    # Add the XTC header
    $msg_head_after .= "X-Text-Classification: $classification$eol" if ( $self->{configuration}->{configuration}{xtc} );

    # Add the XPL header
    $temp_file =~ s/messages\/(.*)/$1/;

    if ( $self->{configuration}->{configuration}{xpl} ) {
        $msg_head_after .= "X-POPFile-Link: <http://";
        $msg_head_after .= $self->{configuration}->{configuration}{localpop}?"127.0.0.1":$self->{hostname};
        $msg_head_after .= ":$self->{configuration}->{configuration}{ui_port}/jump_to_message?view=$temp_file>$eol";
    }

    $msg_head_after .= "$eol";

    # Echo the text of the message to the client
    if ( !$nosave ) {
        print $client $msg_head_before;
        print $client $msg_head_after;
        print $client $msg_body;
    }
    
    if ( $got_full_body == 0 )    {   
        echo_to_dot( $self, $mail, $client ) if ( !$nosave );   
    } else {   
        print $client ".$eol" if ( !$nosave );    
    } 

    if ( !$nosave ) {
        open CLASS, ">$class_file";
        if ( $self->{magnet_used} == 0 )  {
            print CLASS "$classification$eol";
        } else {
            print CLASS "$classification MAGNET $self->{magnet_detail}$eol";
        }
        close CLASS;
    }
    
    return $classification;
}

# ---------------------------------------------------------------------------------------------
#
# echo_to_dot
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
#
# echo all information from the $mail server until a single line with a . is seen
#
# ---------------------------------------------------------------------------------------------
sub echo_to_dot 
{
    my ( $self, $mail, $client ) = @_;
    
    while ( <$mail> ) {
        # Check for an abort
        last if ( $self->{alive} == 0 );

        print $client $_;

        # The termination has to be a single line with exactly a dot on it and nothing
        # else other than line termination characters.  This is vital so that we do
        # not mistake a line beginning with . as the end of the block
        last if ( /^\.(\r\n|\r|\n)$/ );
    }
}

1;
