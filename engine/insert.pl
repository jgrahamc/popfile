#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------
#
# insert.pl --- Inserts a mail message into a specific bucket
#
# Copyright (c) 2001-2004 John Graham-Cumming
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
use lib defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';
use POPFile::Loader;

my $code = 0;

if ( $#ARGV > 0 ) {

    # POPFile is actually loaded by the POPFile::Loader object which does all
    # the work

    my $POPFile = POPFile::Loader->new();

    # Indicate that we should create not output on STDOUT (the POPFile
    # load sequence)

    $POPFile->debug(0);
    $POPFile->CORE_loader_init();
    $POPFile->CORE_signals();
    $POPFile->CORE_load( 1 );
    $POPFile->CORE_link_components();
    $POPFile->CORE_initialize();

    my $bucket = shift @ARGV;

    my @files;

    if ($^O =~ /linux/) {
        @files = @ARGV[0 .. $#ARGV];
    } else {
        @files = map { glob } @ARGV[0 .. $#ARGV];
    }

    @ARGV = ();

    if ( $POPFile->CORE_config() ) {

        # Prevent the tool from finding another copy of POPFile running

        my $c = $POPFile->{components__}{core}{config};
        $c->config_( 'piddir', $c->config_( 'piddir' ) . 'insert.pl.' );

        $POPFile->CORE_start();

        my $b = $POPFile->{components__}{classifier}{bayes};
        my $session = $b->get_session_key( 'admin', '' );

        # Check for the existence of each file first because the API
        # call we use does not care if a file is missing

        foreach my $file (@files) {
            if ( !(-e $file) ) {
                print STDERR "Error: File `$file' does not exist, insert aborted.\n";
                $code = 1;
                last;
            }
        }

        if ( $code == 0 ) {
            if ( !$b->is_bucket( $session, $bucket ) ) {
                print STDERR "Error: Bucket `$bucket' does not exist, insert aborted.\n";
                $code = 1;
            } else {
                $b->add_messages_to_bucket( $session, $bucket, @files );
                print "Added ", $#files+1, " files to `$bucket'\n";
            }
        }

        $b->release_session_key( $session );
        $POPFile->CORE_stop();
    }
} else {
    print "insert.pl - insert mail messages into a specific bucket\n\n";
    print "Usage: insert.pl <bucket> <messages>\n";
    print "       <bucket>           The name of the bucket\n";
    print "       <messages>         Filename of message(s) to insert\n";
    $code = 1;
}

exit $code;

