#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# insert.pl --- Inserts a mail message into a specific bucket
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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
# ----------------------------------------------------------------------------

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

    $POPFile->CORE_loader_init();
    $POPFile->CORE_signals();
    $POPFile->CORE_load( 1 );
    $POPFile->CORE_initialize();

    my @argv_backup = @ARGV;
    @ARGV = ();

    if ( $POPFile->CORE_config() ) {

        # Prevent the tool from finding another copy of POPFile running

        my $c = $POPFile->get_module( 'POPFile::Config' );
        my $current_piddir = $c->config_( 'piddir' );
        $c->config_( 'piddir', $c->config_( 'piddir' ) . 'insert.pl.' );

        my $multiuser_mode = ( $c->global_config_( 'single_user' ) != 1 );

        if ( $multiuser_mode && $#argv_backup < 2 ) {
            &usage;
            $code = 1;
            goto skip;
        }

        my $user   = shift @argv_backup if ( $multiuser_mode );
        my $bucket = shift @argv_backup;

        my @files;

        if ($^O =~ /linux/) {
            @files = @argv_backup[0 .. $#argv_backup];
        } else {
            @files = map { glob } @argv_backup[0 .. $#argv_backup];
        }

        $POPFile->CORE_start();

        my $b = $POPFile->get_module( 'Classifier::Bayes' );
        my $session = $b->get_administrator_session_key();

        # Check for the existence of each file first because the API
        # call we use does not care if a file is missing

        foreach my $file (@files) {
            if ( !(-e $file) ) {
                print STDERR "Error: File `$file' does not exist, insert aborted.\n";
                $code = 1;
                last;
            }
        }

        # Multiuser support

        my $for_user;
        my $user_session;

        if ( $multiuser_mode ) {
            $for_user = " for user `$user'";

            # Get user's session id

            $user_session = $b->get_session_key_from_token( $session, 'insert', $user );
            if ( !defined($user_session) ) {
                print STDERR "Error: User `$user' does not exist, insert aborted.\n";
                $code = 1;
            }
        } else {
            $for_user = '';
            $user_session = $session;
        }

        if ( $code == 0 ) {
            if ( !$b->is_bucket( $user_session, $bucket ) ) {
                print STDERR "Error: Bucket `$bucket'$for_user does not exist, insert aborted.\n";
                $code = 1;
            } else {
                $b->add_messages_to_bucket( $user_session, $bucket, @files );
                print "Added ", $#files+1, " files to `$bucket'$for_user\n";
            }
        }

        $c->config_( 'piddir', $current_piddir );
        $b->release_session_key( $user_session ) if ( $multiuser_mode && defined($user_session) );
        $b->release_session_key( $session );

skip:
        # Reload configuration file ( to avoid updating configurations )

        $c->load_configuration();

        $POPFile->CORE_stop();
    }
} else {
    &usage;
    exit 1;
}

exit $code;

sub usage
{
    print "insert.pl - insert mail messages into a specific bucket of the specific user\n\n";
    print "Usage: insert.pl [<user>] <bucket> <messages>\n";
    print "       <user>             The name of the user (multiuser mode only)\n";
    print "       <bucket>           The name of the bucket\n";
    print "       <messages>         Filename of message(s) to insert\n";
}

