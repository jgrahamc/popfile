#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# traintest.pl - Simulate training on errors using a saved archive.
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::Bayes;
use POPFile::Configuration;

my $debug = 0;

my $DEFAULT_XCNT = '10';
my $DEFAULT_CSV = 'auto';
my $DEFAULT_STOP = 1;
my $DEFAULT_CLASSIFIER = "bayes";
my $DEFAULT_ARCHIVE = "archive";
my $DEFAULT_DUMP = "0";
my $DEFAULT_CORPUS = "archive_corpus";

$| = 1;
$, = ", ";
my %wordtab;


sub initialize
{
    my ($config) = @_;

    $config->parameter("xcnt",$DEFAULT_XCNT);    
    $config->parameter("csv",$DEFAULT_CSV);
    $config->parameter("stopwords",$DEFAULT_STOP);
    $config->parameter("classifier",$DEFAULT_CLASSIFIER);
    $config->parameter("archive_dir",$DEFAULT_ARCHIVE);
    $config->parameter("dump",$DEFAULT_DUMP);
    $config->parameter("corpus_out",$DEFAULT_CORPUS);


}

sub cvs_out
{
    my ($config, $file, @log) = @_;    
 
    if ($file eq 'auto') {
        
        $file = "x_validate";        
        
        if ( $config->parameter('stopwords') ne $DEFAULT_STOP ) {
            $file .= "_";
            if ($config->parameter('stopwords') != 1) {                
                $file .= "no";
            }
            $file .= "stop";                
        }        
        
        $file .= ".csv";
    }
    
    print STDERR "Printing data to $file\n";
    
    open CSV, ">$file";
    
    $, = ",";

    print CSV sort keys %{ @log[1] };
    foreach my $message (0 .. $#log) {
        $message = @log[$message];
        foreach my $item (sort keys %{$message}) {
			my $value = $message->{$item};
			$value =~ s/\"/'/g;
            print CSV "\"$value\",";
        }
        print CSV "\n";
    }
    
    print STDERR "Data saved to $file\n";
    
    $, = "";
    
}

sub reclassify_file
{
    my ($b,$bucket) = @_;

    foreach my $word (keys %{ $b->{parser__}->{words__} }) {
        my $wordvalue = $wordtab{$bucket."|".$word};
        $wordtab{$bucket."|".$word} += $b->{parser__}->{words__}{$word};
        $b->set_value_($bucket,$word, $wordtab{$bucket."|".$word});
        $b->{total__}{$bucket}        += $b->{parser__}->{words__}{$word};
        $b->{unique__}{$bucket}       += 1 if ($wordvalue == 0);
    }
    $b->{full_total__} += $b->{parser__}{msg_total__};
    $b->update_constants_();
}

sub reclassify_folder
{
    my ($b,$folder,$bucket) = @_;
    
    my @file_array = glob "$folder/*";
    foreach my $amessage (@file_array) {
    }    
}



sub dump_corpus
{
    my ($self) = @_;

    my $dir = $self->{configuration__}->parameter('corpus_out');
    mkdir($dir);
    
    foreach my $abucket ( keys %{$self->{total__}} ) {
        
        print "saving $abucket corpus.\n";
        
        my $subdir = $dir;
        $subdir .= "/$abucket";

        mkdir($subdir);

        open CORPUS, ">$dir/$abucket/table";
        print CORPUS "__CORPUS__ __VERSION__ 1\n";
        for my $ord ( @{$self->get_bucket_word_list($abucket)} ) {
            if ( defined($ord) ) {
                while ($ord =~ s/\|([^ ]+) (\d+)\|//) {
                    print CORPUS "$1 $2\n";
                }
            }
        }        
    }    
}


sub find_messages
{

    my ( $archive ) = @_;

    my $messages = {};

    my @buckets_array = glob "$archive/*";

    foreach my $abucket (@buckets_array) {
        $abucket =~ s/.*\/(.*)$/$1/;
        print "saved bucket $abucket opening\n" if ($debug);

        my @dir_messages;

        my $subdirs = 1;
        my $locations = 0;

        #$messages->{messages}{$abucket} = {};


        my @subdirectories = glob "$archive/$abucket/*";

        foreach my $dir (@subdirectories) {

            $dir =~ s/.*\/(.*)$/$1/;

            print "$abucket subdirectory $dir opening..." if ($debug);
            if ( opendir(DIR,"$archive/$abucket/$dir") ) {
                print "(open):\n" if ($debug);
                $messages->{buckets}{$abucket}{subdirs}{$dir} = {};

                $messages->{locations}[$locations] = "$archive/$abucket/$dir";
                $locations++;

                $subdirs = 1;

                closedir(DIR);
                foreach my $message ( glob( "$archive/$abucket/$dir/*.msg" ) ) {
                    my $shortname = $message;
                    $shortname =~ s/.*\/(.*)$/$1/;

                    $messages->{messages}{$shortname}{bucket} = $abucket;
                    $messages->{messages}{$shortname}{long} = $message;

                    $messages->{buckets}{$abucket}{messages}{$shortname} = $abucket;
                    $messages->{buckets}{$abucket}{subdirs}{$dir}{$shortname} = $abucket;
                }
            } else {
                print ":" if ($debug);
                $subdirs = 0;
                last;
            }
        }
        if ($subdirs == 0) {
            print "$abucket root dir opening messages:\n" if $debug;
            foreach my $message ( glob( "$archive/$abucket/*.msg") ) {
                my $shortname = $message;
                $shortname =~ s/.*\/(.*)$/$1/;

                $messages->{messages}{$shortname}{bucket} = $abucket;
                $messages->{messages}{$shortname}{long} = $message;
                $messages->{buckets}{$abucket}{messages}{$shortname} = $abucket;
            }
            $messages->{locations}[$locations] = "$archive/$abucket";
            $locations++;
        }
    }
    return $messages;
}

sub flush_bayes 
{
    my ($self) = @_;
    
    # Set this to 1 to get scores for individual words in message detail
    $self->{wordscores__}        = 0;

    # Just our hostname
    $self->{hostname__}        = '';

    # Matrix of buckets, words and the word counts
    $self->{matrix__}            = {};

    # Total number of words in each bucket
    $self->{total__}             = {};

    # Total number of unique words in each bucket
    $self->{unique__}            = {};

    # Total number of words in all buckets
    $self->{full_total__}        = 0;

    # Used to mangle the corpus when loaded
    $self->{mangler__}           = new Classifier::WordMangle;

    # Used to parse mail messages
    $self->{parser__}            = new Classifier::MailParse;

    # Colors assigned to each bucket
    $self->{colors__}            = {};

    # The possible colors for buckets
    $self->{possible_colors__} = [ 'red',  'green',      'blue',      'brown',     'orange',     'purple',      'magenta',  'gray',        'plum',     'silver',
                   'pink', 'lightgreen', 'lightblue', 'lightcyan', 'lightcoral', 'lightsalmon', 'lightgrey', 'darkorange', 'darkcyan', 'feldspar' ];

    # Precomputed per bucket probabilities
    $self->{bucket_start__}      = {};

    # A very unlikely word
    $self->{not_likely__}        = 0;

    # The expected corpus version
    $self->{corpus_version__}    = 1;

    # Per bucket parameters
    $self->{parameters__}        = {};

    # The magnets that cause attraction to certain buckets
    $self->{magnets__}           = {};
    $self->{magnet_count__}      = 0;

    # The unclassified cutoff probability
    $self->{unclassified__}      = 0.5;

    # Used to tell the caller whether a magnet was used in the last
    # mail classification
    $self->{magnet_used__}       = 0;
    $self->{magnet_detail__}     = '';
}


my $self = {};

# main

if ( @ARGV[0] ne "-usage")
{
    my $b = new Classifier::Bayes;
    my $c = new POPFile::Configuration;

    $b->configuration( $c );
    $c->configuration( $c );

    $c->initialize();
    $b->initialize();
    initialize( $c );

    $c->load_configuration();

    $c->parse_command_line();

    $b->{debug} = 0;
    $b->{parser__}->{debug} = 0;

    my $archive = $c->parameter("html_archive_dir");

    #load the messages

    $self->{messages} = find_messages($archive);    
        
    foreach my $exclude_fraction (0 .. ( $c->parameter("xcnt") - 1) ) {
        
        print "excluding grouping $exclude_fraction\n" if $debug;
        
        # Clean up our bayes object
        flush_bayes($b);
        
        $b->{unclassified__} = log($c->parameter("bayes_unclassified_probability") || 0.5);

        # test with or without stop-words    
         if ( $c->parameter("stopwords") eq 0 ) {
            $b->{parser__}->{mangle__}->{stop__} = {};
            $b->{mangler__}->{stop__} = {};
        }
    
        # build a bucket skeleton
        foreach my $abucket ( keys %{ $self->{messages}->{buckets} } ) {

            $b->{total__}{$abucket} = 0;
            $b->{colors__}{$abucket} = "black";
            
            if ($abucket ne 'unclassified') {
                foreach my $current_fraction ( sort keys( %{ $self->{messages}->{buckets}{$abucket}{subdirs}} )) {
        
                    # Do the hippy-hippy corpus-building shake
                    if ($current_fraction ne $exclude_fraction) {
                        
                        print "training on $abucket/$current_fraction\n" if ($debug);
                        
                        #my $dir = $self->{messages}->{messages}{each( $self->{messages}->{buckets}{$abucket}{subdirs}{$current_fraction}) }{long};
                        
                        #$dir =~ s/(.*)\/[^/]*$/$1/;
                        #print "$dir:\n";
                        #reclassify_folder($b,$dir,$abucket);
                        
                        foreach my $amessage ( keys %{$self->{messages}->{buckets}{$abucket}{subdirs}{$current_fraction}} ) {
                            $b->{parser__}->parse_stream($self->{messages}->{messages}{$amessage}{long});                      
                            reclassify_file($b,$abucket);                            
                        }                        
                    }
                }
            }
        }
        
        # classify all messages in the selected bunch
        
        my $class;
        my $total = 0;
        my $errors = 0;
        
        foreach my $abucket ( keys %{ $self->{messages}->{buckets} } ) {
            print "classifying messages in $abucket/$exclude_fraction\n" if $debug;
            
            foreach my $amessage ( keys %{$self->{messages}->{buckets}{$abucket}{subdirs}{$exclude_fraction}} ) {
                $class = $b->classify_file($self->{messages}->{messages}{$amessage}{long});
                if ($class ne $abucket) {
                    $errors++;
                    print "$class ne $abucket\n" if $debug;
                }
                $total++;
            }
        }
        
        my $accuracy = (($total - $errors) / $total) * 100;
        
        print "batch $exclude_fraction: $errors out of $total wrong. $accuracy% accurate\n";
        $exclude_fraction++;
    }
} else {

    print "xval.pl - perform cross-validation tests on archived messages\n\n";
    print "Usage: traintest.pl [-usage] [-parameter value [-parameter value] ...]\n";
    print "     -usage:         Displays this screen\n";
    print "  Other Parameters     Use\n";
    print "     -archive_dir:   Location to seek an archive\n";
    print "     -stopwords:     Use stop-words, defaults to $DEFAULT_STOP\n";
    print "     -dump:          Outputs accumulated corpus, defaults to $DEFAULT_DUMP\n";
    print "     -corpus_out:    Location to save output corpus, defaults to $DEFAULT_CORPUS\n";
}

