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

my $DEFAULT_CSV = 'auto';
my $DEFAULT_TOE = 1;
my $DEFAULT_WINDOW1 = 100;
my $DEFAULT_WINDOW2 = 500;
my $DEFAULT_CLASSIFIER = "bayes";
my $DEFAULT_ARCHIVE = "archive";

$| = 1;
$, = ", ";
my %wordtab;

# ---------------------------------------------------------------------------------------------
#
# compare_mf - Compares two mailfiles, used for sorting mail into order
#
# ---------------------------------------------------------------------------------------------

# NB, wasn't able to get this to work as part of HTML.pm
sub compare_mf
{
    my $ad;
    my $bd;
    my $am;
    my $bm;

    if ( $a =~ /popfile(.*)=(.*)\.msg/ )  {
        $ad = $1;
        $am = $2;

        if ( $b =~ /popfile(.*)=(.*)\.msg/ ) {
            $bd = $1;
            $bm = $2;

            if ( $ad == $bd ) {
                return ( $bm <=> $am );
            } else {
                return ( $bd <=> $ad );
            }
        }
    }

    return 0;
}

sub initialize
{
    my ($config) = @_;
    
    $config->parameter("csv",$DEFAULT_CSV);
    $config->parameter("toe",$DEFAULT_TOE);
    $config->parameter("window1",$DEFAULT_WINDOW1);
    $config->parameter("window2",$DEFAULT_WINDOW2);
    $config->parameter("classifier",$DEFAULT_CLASSIFIER);
    $config->parameter("archive_dir",$DEFAULT_ARCHIVE);

}

sub cvs_out
{
    my ($config, $file, @log) = @_;    
 
    if ($file eq 'auto') {
        if ($config->parameter('toe') == 1) {
            $file = "toe";
        } else {
            $file = "te";
        }
        if ( ( $config->parameter('window1') ne $DEFAULT_WINDOW1 ) && \
             ( $config->parameter('window2') ne $DEFAULT_WINDOW2 ) ) {
            $file .= "$config->parameter('window1')and$config->parameter('window2')";
                
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

sub reclassify
{
    my ($b,$bucket) = @_;

    foreach my $word (keys %{ $b->{parser__}->{words__} }) {
        my $wordvalue = $wordtab{$bucket."|".$word};
        $wordtab{$bucket."|".$word} += $b->{parser__}->{words__}{$word};
#        my $wordvalue = $b->get_value($bucket, $word);
#        $b->set_value($bucket,$word, $wordvalue + $b->{parser}->{words}{$word} );
#        $b->set_value($bucket,$word, $wordtab{$bucket."|".$word});
        $b->{total__}{$bucket}        += $b->{parser__}->{words__}{$word};
        $b->{unique__}{$bucket}       += 1 if ($wordvalue == 0);
    }
    $b->{full_total__} += $b->{parser__}{msg_total__};
    foreach my $word (keys %wordtab) {
        if ( $word =~ /^\Q$bucket\E\|(.*)$/ ) {
           $b->set_value_($bucket,$1, $wordtab{$word});
        }
    }
    $b->update_constants_();
}





sub retrain_decider
{
    my ($toe,$predicted,$actual) = @_;
    
    if ($toe == 1) {
        return ($predicted ne $actual);
    } elsif ($toe == 0) {
        return 1;
    } elsif ($toe == 2) {
        return (rand > .5);
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
    
#    $b->{unclassified} = ($c->parameter('unclassified_probability') || 0.0001);
    $b->{unclassified__} = ($c->parameter("bayes_unclassified_probability") || 0.5);
    

    my $archive = $c->parameter("ui_archive_dir");


    #load the messages

    $self->{messages} = find_messages($archive);

    #some debug output to verify bucket structure

    if ($debug) {
        foreach my $abucket ( keys %{ $self->{messages}->{buckets} } ) {
            print "$abucket:" . (keys %{ $self->{messages}->{buckets}{$abucket}{messages} }). "\n";
            #print keys %{$self->{messages}->{$abucket}};
            foreach my $message (keys %{ $self->{messages}->{buckets}{$abucket}{messages} } ) {
               print "\t$message $self->{messages}->{buckets}{$abucket}{messages}{$message}\n";
            }
        }
    }

    # build a bucket skeleton

    foreach my $abucket ( keys %{ $self->{messages}->{buckets} } ) {
        $b->{total__}{$abucket} = 0;
        $b->{colors__}{$abucket} = "black";
    }

    $self->{messages}->{buckets}{unclassified} = {};


    #sort the messages

    my @sorted_messages = sort compare_mf keys %{$self->{messages}{messages}};
    #   my @sorted_messages = keys %{$self->{messages}{messages}};

    #more debug output

    if ($debug) {
        print "sorted " . $#sorted_messages . ": ";
        foreach my $index (0 .. $#sorted_messages ) {
            print " " . @sorted_messages[$index];
        }
        print "\n\n";
    }

    $b->{debug} = 0;
    $b->{parser__}->{debug} = 0;

    my ($bucket_class, $bucket_true, $correct);
    my $error_count = 0;
    my @errors;
    my @clog;

    #loop through all saved messages, classify

    my $start_time = time;
    my $total_size = 0;

    foreach my $index (0 .. $#sorted_messages ) {
        $correct = 1;
        my $message_count = $index + 1;
        $index = $#sorted_messages - $index;
        print "\n$self->{messages}->{messages}{ @sorted_messages[$index] }{long}:" if ($debug);        
        $bucket_class = $b->classify_file( $self->{messages}->{messages}{ @sorted_messages[$index] }{long});
        $bucket_true = $self->{messages}->{messages}{ @sorted_messages[$index] }{bucket};

         if ($bucket_class ne $bucket_true) {
            @errors[$error_count] = {};
            @errors[$error_count]->{index}= $message_count;
            @errors[$error_count]->{subject} = $b->{parser}->{subject};
            @errors[$error_count]->{shouldbe} = $bucket_true;
            @errors[$error_count]->{classified_as} = $bucket_class;
            $error_count++;
            $correct = 0;
            if ($bucket_class eq 'unclassified') {
                print STDERR "/";
            } else {
                print STDERR "+";
            }
        } else {
            print STDERR ".";
        }

        if ( retrain_decider($c->parameter('toe'),$bucket_class, $bucket_true) ) {
            print STDERR "Reclassifying $message_count $bucket_class => $bucket_true.\n" if ($debug);
            reclassify($b,$bucket_true);
        }

        @clog[$message_count] = {};
        @clog[$message_count]->{count} = $message_count;
        @clog[$message_count]->{correct} = $correct;
        @clog[$message_count]->{error_count} = $error_count;
        @clog[$message_count]->{accuracy} = int( 10000 * ( $message_count - $error_count ) / $message_count ) / 100;
        @clog[$message_count]->{subject} = $b->{parser}->{subject};
        @clog[$message_count]->{from} = $b->{parser}->{from};
        @clog[$message_count]->{shouldbe} = $bucket_true;
        @clog[$message_count]->{classified_as} = $bucket_class;
        @clog[$message_count]->{filename} = @sorted_messages[$index];

        foreach my $abucket (keys %{ $self->{messages}->{buckets} } ) {
            if ($message_count != 1) {
                if ( ( $abucket eq $bucket_class ) && ( $bucket_class ne $bucket_true ) ) {
                    @clog[$message_count]->{"misclassified_count_$abucket"} = $clog[($message_count - 1)]->{"misclassified_count_$abucket"} + 1;
                } else {
                    @clog[$message_count]->{"misclassified_count_$abucket"} = $clog[($message_count - 1)]->{"misclassified_count_$abucket"};
                }
            } else {
                @clog[$message_count]->{"misclassified_count_$abucket"} = ((($bucket_true ne $bucket_class) && ($bucket_class eq $abucket))?1:0);
            }

        }

        my $window_size = $c->parameter("window2");
        my $window_errors = 0;

        foreach my $error (0 .. $#errors) {
            if ( @errors[$error]->{index} > ($message_count - $window_size) ) {
                $window_errors++;
            }
        }

        @clog[$message_count]->{window_errors} = $window_errors;

        $window_size = (($window_size > $message_count)?$message_count:$window_size);

        @clog[$message_count]->{moving_accuracy} = int( 10000 * ( $window_size - $window_errors ) / $window_size ) / 100;
    }
    print STDERR "\n";

    my $end_time = time;

    my $total_messages = $#sorted_messages + 1;

    my $accuracy = int( 10000 * ( $total_messages - $error_count ) / $total_messages ) / 100;
    print STDERR "process took " . ($end_time - $start_time) .  " seconds\n";
    print STDERR "$error_count out of " . $total_messages . " incorrect\n";
    print STDERR "that's $accuracy% accurate\n";
    cvs_out($c, $c->parameter('csv'), @clog) if ($c->parameter('csv') ne "none");

} else {

    print "traintest.pl - perform classification tests on archived messages\n\n";
    print "Usage: traintest.pl [-usage] [-csv auto|filename] [-parameter value [-parameter value] ...]\n";
    print "     -usage:         Displays this screen\n";
    print "  Other Parameters     Use\n";
    print "     -archive_dir:   Location to seek an archive\n";
    print "     -csv:           Filename to save CSV log to, \"auto\" generates a filename\n";
    print "     -toe:           Train Only Errors, defaults to $DEFAULT_TOE";
}

