#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# insert.pl --- Inserts a mail message into a specific bucket
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
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

    while (<WORDS>) {
        if ( /__CORPUS__ __VERSION__ (\d+)/ ) {
            if ( $1 != 1 ) {
                print "Incompatible corpus version in $bucket\n";
                return;
            }

            next;
        }

        if ( /(.+) (.+)/ ) {
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

    foreach my $word (keys %words) {
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

    $parser->parse_file($message);

    foreach $word (keys %{$parser->{words__}}) {
        $words{$word} += $parser->{words__}{$word};
    }
}

# main

if ( $#ARGV >= 1 )
{
    load_word_table($ARGV[0]);

    my @files;

    if ($^O =~ /linux/) {
        @files = @ARGV[1 .. $#ARGV];
    } else {
        @files   = map { glob } @ARGV[1 .. $#ARGV];
    }

    foreach my $file (@files) {
        split_mail_message($file);
    }

    save_word_table($ARGV[0]);

    print "done.\n";
} else {
    print "insert.pl - insert mail messages into a specific bucket\n\n";
    print "Usage: insert.pl <bucket> <messages>\n";
    print "       <bucket>           The name of the bucket\n";
    print "       <messages>         Filename of message(s) to insert\n";
}
