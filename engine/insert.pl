# ---------------------------------------------------------------------------------------------
#
# insert.pl --- Inserts a mail message into a specific bucket
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;
use Classifier::MailParse;

my %words;

# ---------------------------------------------------------------------------------------------
#
# load_word_table
#
# $bucket    The name of the bucket we are loading words for
#
# Fills the words hash with the word frequencies for word loaded from the appropriate bucket
#
# ---------------------------------------------------------------------------------------------

sub load_word_table
{
    my ($bucket) = @_;
    
    # Make sure that the bucket mentioned exists, if it doesn't the create an empty
    # directory and word table

    mkdir("corpus");
    mkdir("corpus/$bucket");
    
    print "Loading word table for bucket '$bucket'...\n";
    
    open WORDS, "<corpus/$bucket/table";
    
    # Each line in the word table is a word and a count
    
    while (<WORDS>)
    {
        if ( /__CORPUS__ __VERSION__ (\d+)/ )
        {
            if ( $1 != 1 ) 
            {
                print "Incompatible corpus version in $bucket\n";
                return;
            }
            
            next;
        }
            
        if ( /(.+) (.+)/ )
        {
            $words{$1} = $2;
        }
    }
    
    close WORDS;
}

# ---------------------------------------------------------------------------------------------
#
# save_word_table
#
# $bucket    The name of the bucket we are loading words for
#
# Writes the words hash out to a bucket
#
# ---------------------------------------------------------------------------------------------

sub save_word_table
{
    my ($bucket) = @_;

    print "Saving word table for bucket '$bucket'...\n";
    
    open WORDS, ">corpus/$bucket/table";
    print WORDS "__CORPUS__ __VERSION__ 1\n";
    
    # Each line in the word table is a word and a count
    
    foreach my $word (keys %words)
    {
        print WORDS "$word $words{$word}\n";
    }
    
    close WORDS;
}

# ---------------------------------------------------------------------------------------------
#
# split_mail_message
#
# $message    The name of the file containing the mail message
#
# Splits the mail message into valid words and updated the words hash
#
# ---------------------------------------------------------------------------------------------

sub split_mail_message
{
    my ($message) = @_;
    my $parser   = new Classifier::MailParse;
    my $word;

    print "Parsing message '$message'...\n";

#    $parser->{debug} = 1;
    $parser->parse_stream($message);
    
    foreach $word (keys %{$parser->{words}})
    {
        $words{$word} += $parser->{words}{$word};
    }
}

# main

if ( $#ARGV >= 1 ) 
{
    load_word_table($ARGV[0]);

    my @files;

    if ($^O =~ /linux/)
    {
        @files = @ARGV[1 .. $#ARGV];
    }
    else
    {
        @files   = map { glob } @ARGV[1 .. $#ARGV];
    }
    
    foreach my $file (@files)
    {
        split_mail_message($file);
    }
    
    save_word_table($ARGV[0]);
    
    print "done.\n";
}
else
{
    print "insert.pl - insert mail messages into a specific bucket\n\n";
    print "Usage: insert.pl <bucket> <messages>\n";
    print "       <bucket>           The name of the bucket\n";
    print "       <messages>         Filename of message(s) to insert\n";
}