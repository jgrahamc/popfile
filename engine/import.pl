#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# import.pl --- Imports the old database into the new database
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
use File::Copy;
use lib defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';

my $code = 0;

if ( $#ARGV > 0 ) {
    my ( $user_dir, $username, $newusername ) = @ARGV;

    $newusername = $username if ( !defined($newusername) );

    if ( $newusername eq 'admin' ) {
        print STDERR "Error : Bad new user name '$newusername', import aborted\n";
        exit 1;
    }

#    $user_dir = "../corpus_import";
#    $username = "admin";
#    $newusername = "test_dummy3";

    use POPFile::Loader;
    my $POPFile = POPFile::Loader->new();
#    $POPFile->{debug__} = 1;
    $POPFile->CORE_loader_init();
    $POPFile->CORE_signals();

    my %valid = ( 'POPFile/Database'       => 1,
                  'POPFile/Logger'         => 1,
                  'POPFile/MQ'             => 1,
                  'Classifier/Bayes'       => 1,
                  'POPFile/Configuration'  => 1 );

    $POPFile->CORE_load( 0, \%valid );
    $POPFile->CORE_initialize();
    $POPFile->CORE_config( 1 );

    my $b = $POPFile->get_module( 'Classifier/Bayes' );
    my $c = $POPFile->get_module( 'POPFile/Configuration' );
    my $l = $POPFile->get_module( 'POPFile/Logger' );

    $c->{popfile_user__} = $user_dir;
    $c->load_configuration();
#    $l->config_( 'level' ,2 );

    # Backup the database and the setting file

    copy ( $c->get_user_path( 'popfile.cfg' ),
           $c->get_user_path( 'popfile.cfg.bak' ) );
    copy ( $c->get_user_path( 'popfile.db' ),
           $c->get_user_path( 'popfile.db.bak' ) );

    # Convert the database

    $POPFile->CORE_start();

    my $POPFile2 = POPFile::Loader->new();
#    $POPFile2->{debug__} = 1;
    $POPFile2->CORE_loader_init();
    $POPFile2->CORE_signals();

    $POPFile2->CORE_load( 0, \%valid );
    $POPFile2->CORE_initialize();
    $POPFile2->CORE_config( 1 );

    my $b2 = $POPFile2->get_module( 'Classifier/Bayes' );
    my $c2 = $POPFile2->get_module( 'POPFile/Configuration' );

    use POSIX qw(locale_h);
    if ( $^O eq 'MSWin32' && setlocale(LC_COLLATE) eq 'Japanese_Japan.932' ) {
        setlocale(LC_COLLATE,'C');
    }

    $POPFile2->CORE_start();

    # Fetch the database version

    my $h = $b->db_()->prepare( "select version from popfile;" );
    $h->execute;
    my $row = $h->fetchrow_arrayref;
    my $version = $row->[0];
    $h->finish;

    my $import_db = $c->get_user_path( 'popfile.db' );
    print "Import from database '$import_db'\n";

    # Fetch the old user

    $h = $b->db_()->prepare( "select id from users where name = ?;" );
    $h->execute( $username );
    $row = $h->fetchrow_arrayref;
    my $userid = $row->[0];
    $h->finish;
    undef $h;

    if ( !defined( $userid) ) {

        $c2->load_configuration();
        $c->load_configuration();

        $POPFile2->CORE_stop();
        $POPFile->CORE_stop();
        print STDERR "Error : User '$username' does not exist, import aborted\n";
        exit 1 ;
    }

    # Create a new user

    my $session = $b2->get_administrator_session_key();
    my ( $result, $password ) = $b2->create_user( $session, $newusername );

    if ( defined($result) && ( $result eq 0 ) && defined($password ) ) {
        my $user_session = $b2->get_session_key( $newusername, $password );
        my $newuserid = $b2->get_user_id_from_session( $user_session );

        print "  New user '$newusername' is created. The user's initial password is '$password'\n";

        # Fetch the parameters for the user

        my %user_params;
        $h = $b->db_()->prepare(
             "select user_template.name, user_params.val
                     from user_template, user_params
                     where user_template.id = user_params.utid and
                           user_params.userid = ?;" );
        $h->execute( $userid );
        while ( my $row = $h->fetchrow_arrayref ) {
            # Should not copy the admin flag

            next if ( $row->[0] eq 'GLOBAL_can_admin' );

            my $parameter = $row->[0];
            $parameter =~ m/^([^_]+)_(.*)$/;
            my $module = $1;
            my $config = $2;

            $c2->user_module_config_( $newuserid, $module, $config, $row->[1] );
        }

        # Fetch the buckets for the user

        my %buckets;
        $b->{db_get_buckets__}->execute( $userid );
        while ( my $row = $b->{db_get_buckets__}->fetchrow_arrayref ) {
            $buckets{$row->[0]}{id} = $row->[1];
            $buckets{$row->[0]}{pseudo} = $row->[2];
        }

        # Create buckets for the new user

        foreach my $bucket ( keys %buckets ) {
            next if ( $buckets{$bucket}{pseudo} );

            $b2->create_bucket( $user_session, $bucket );
            print "  Created a bucket '$bucket'\n";
        }

        # Fetch the bucket parameters for user

        my %bucket_params;
        $h = $b->db_()->prepare(
             "select bucket_template.name, bucket_params.val 
                     from bucket_template, bucket_params 
                     where bucket_params.btid = bucket_template.id and 
                           bucket_params.bucketid = ?;" );
        foreach my $bucket ( keys %buckets ) {
            $h->execute( $buckets{$bucket}{id} );

            while ( my $row = $h->fetchrow_arrayref ) {
                $b2->set_bucket_parameter( $user_session, $bucket, $row->[0], $row->[1] );
            }
        }
        $h->finish;

        # Fetch the magnets for user

        my %magnets;
        $h = $b->db_()->prepare( "select magnet_types.mtype, magnets.val
                                         from magnet_types, magnets
                                         where magnet_types.id = magnets.mtid and
                                               magnets.bucketid = ?;" );
        foreach my $bucket ( keys %buckets ) {
            $h->execute( $buckets{$bucket}{id} );

            while ( my $row = $h->fetchrow_arrayref ) {
                $b2->create_magnet( $user_session, $bucket, $row->[0], $row->[1] );
            }
        }
        $h->finish;

        # Fetch the words in the bucket

        $h = $b->db_()->prepare( "select words.word, matrix.times from words, matrix
                                         where words.id = matrix.wordid and
                                               matrix.bucketid = ?;" );
        foreach my $bucket ( keys %buckets ) {
            next if ( $buckets{$bucket}{pseudo} );

            # Word list

            $b2->{parser__}->{words__} = {};

            $h->execute( $buckets{$bucket}{id} );

            while ( my $row = $h->fetchrow_arrayref ) {
                $b2->{parser__}->{words__}{$row->[0]} = $row->[1];
            }

            print "  Importing words into the bucket '$bucket'...\n";
            $b2->add_words_to_bucket__( $user_session, $bucket, 1 );
        }
        $h->finish;
        undef $h;

        print "Imported the database successfully\n";

    } else {
        print STDERR "Error : Failed to create a user '$newusername', import aborted\n";
        $code = 1;
    }

    $c2->load_configuration();
    $c->load_configuration();

    $POPFile2->CORE_stop();
    $POPFile->CORE_stop();

} else {
    print "import.pl - import user data into the new database\n\n";
    print "Usage: import.pl <old_user_dir> <user> [<newuser>]\n";
    print "       <old_user_dir>     The path to the user data to import\n";
    print "       <user>             The name of the user to import from\n";
    print "                          Use 'admin' when upgrading from v1\n";
    print "       <newuser>          The name of the user to import into (optional)\n";
    print "                          If not specified, assume newuser=user\n";
    $code = 1;
}

exit $code;
