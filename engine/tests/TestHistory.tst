# ---------------------------------------------------------------------------------------------
#
# Tests for History.pm
#
# Copyright (c) 2004 John Graham-Cumming
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

test_assert( `rm -rf messages` == 0 );
test_assert( `rm -rf corpus` == 0 );
test_assert( `cp -R corpus.base corpus` == 0 );
test_assert( `rm -rf corpus/CVS` == 0 );

unlink 'popfile.db';
unlink 'stopwords';
test_assert( `cp stopwords.base stopwords` == 0 );

mkdir 'messages';

use Classifier::Bayes;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Classifier::WordMangle;
use POPFile::History;

# Load the test corpus
my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;
my $w = new Classifier::WordMangle;
my $h = new POPFile::History;

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );

$c->initialize();

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$w->configuration( $c );
$w->mq( $mq );
$w->logger( $l );

$w->start();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

$b->configuration( $c );
$b->mq( $mq );
$b->logger( $l );

$h->configuration( $c );
$h->mq( $mq );
$h->logger( $l );

$b->history( $h );
$h->classifier( $b );

$h->initialize();

$b->module_config_( 'html', 'language', 'English' );
$b->{parser__}->mangle( $w );
$b->initialize();

test_assert( $b->start() );
test_assert( $h->start() );

$l->config_( 'level', 2 );

# Check the behaviour of reserve_slot.  It should return a valid
# number and create the associated path (but not the file), check
# that get_slot_file returns the same file as reserve_slot

my ( $slot, $file ) = $h->reserve_slot();

test_assert( defined( $slot ) );
test_assert( !( -e $file ) );
test_assert_equal( $file, $h->get_slot_file( $slot ) );

my $path = $file;
$path =~ s/popfile..\.msg//;
test_assert( ( -e $path ) );
test_assert( ( -d $path ) );

open FILE, ">$file";
print FILE "test\n";
close FILE;

# Check that there is an entry and that it has not yet
# been committed

my @result = $h->{db__}->selectrow_array( "select committed from history where id = $slot;" );
test_assert_equal( $#result, 0 );
test_assert( $result[0] != 1 );

# Check that release_slot removes the entry from the database
# and deletes the file, but does not clean up the directory

$h->release_slot( $slot );

test_assert( !( -e $file ) );
test_assert( ( -e $path ) );
test_assert( ( -d $path ) );

@result = $h->{db__}->selectrow_array( "select committed from history where id = $slot;" );
test_assert_equal( $#result, -1 );

# Now try actually adding an element to the history.  Reserve a slot
# then commit it and call service to get it added.  Ensure that the
# slot is now committed and has the right fields

( $slot, $file ) = $h->reserve_slot();

open FILE, ">$file";
print FILE <<EOF;
From: John Graham-Cumming <nospam\@jgc.org>
To: Everyone <nospam-everyone\@jgc.org>
Cc: People <no-spam-people\@jgc.org>
Subject: this is the subject line
Date: Sun, 25 Jul 2020 03:46:32 -0700
Message-ID: 1234

This is the message body
EOF
close FILE;

my $slot1 = $slot;

( $slot, $file ) = $h->reserve_slot();
open FILE, ">$file";
print FILE <<EOF;
From: Evil Spammer <nospam\@jgc.org>
To: Someone Else <nospam-everyone\@jgc.org>
Subject: hot teen mortgage enlargers
Date: Sat, 24 Jul 2020 03:46:32 -0700
Message-ID: 12345

This is the message body
EOF
close FILE;

$h->commit_slot( $slot, 'spam', 0 );
$h->commit_slot( $slot1, 'personal', 0 );
$mq->service();
$h->service();

# Check that the message hash mechanism works

my $hash = $h->get_message_hash( '1234', 
    'Sun, 25 Jul 2020 03:46:32 -0700', 
    'this is the subject line' );

test_assert_equal( $hash, 'bd9ff908e7f4925637c263e8e355f69a' );
test_assert_equal( $slot1, $h->get_slot_from_hash( $hash ) );

# Check that the two messages were correctly inserted into
# the database

@result = $h->{db__}->selectrow_array( "select * from history where id = 1;" );
test_assert_equal( $#result, 12 );
test_assert_equal( $result[0], 1 ); # id
test_assert_equal( $result[1], 1 ); # userid
test_assert_equal( $result[2], 1 ); # committed
test_assert_equal( $result[3], 'John Graham-Cumming <nospam@jgc.org>' ); # From
test_assert_equal( $result[4], 'Everyone <nospam-everyone@jgc.org>' ); # To
test_assert_equal( $result[5], 'People <no-spam-people@jgc.org>' ); # Cc
test_assert_equal( $result[6], 'this is the subject line' ); # Subject
test_assert_equal( $result[7], 1595673992 );
test_assert_equal( $result[10], 3 ); # bucketid
test_assert_equal( $result[11], 0 ); # usedtobe

@result = $h->{db__}->selectrow_array( "select * from history where id = 2;" );
test_assert_equal( $#result, 12 );
test_assert_equal( $result[0], 2 ); # id
test_assert_equal( $result[1], 1 ); # userid
test_assert_equal( $result[2], 1 ); # committed
test_assert_equal( $result[3], 'Evil Spammer <nospam@jgc.org>' ); # From
test_assert_equal( $result[4], 'Someone Else <nospam-everyone@jgc.org>' ); # To
test_assert_equal( $result[5], '' ); # Cc
test_assert_equal( $result[6], 'hot teen mortgage enlargers' ); # Subject
test_assert_equal( $result[7], 1595587592 );
test_assert_equal( $result[10], 4 ); # bucketid
test_assert_equal( $result[11], 0 ); # usedtobe

# Now that we've got some data in the history test the query
# interface

my $q = $h->start_query();

test_assert( defined( $q ) );
test_assert_regexp( $q, '[0-9a-f]{8}' );
test_assert( defined( $h->{queries__}{$q} ) );

# Unsorted returns in ID order

$h->set_query( $q, '', '', '' );

test_assert_equal( $h->get_query_size( $q ), 2 );

my @rows = $h->get_query_rows( $q, 1, 2 );

test_assert_equal( $#rows, 1 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );
test_assert_equal( $rows[1][1], 'Evil Spammer <nospam@jgc.org>' );

my @slot_row = $h->get_slot_fields( $rows[0][0] );
test_assert_equal( join(':',@{$rows[0]}), join(':',@slot_row) );

# Start with the most basic, give me everything query
# sorted by from/to address

$h->set_query( $q, '', '', 'from' );
test_assert_equal( $h->get_query_size( $q ), 2 );
@rows = $h->get_query_rows( $q, 1, 2 );
test_assert_equal( $#rows, 1 );
test_assert_equal( $rows[0][1], 'Evil Spammer <nospam@jgc.org>' );
test_assert_equal( $rows[1][1], 'John Graham-Cumming <nospam@jgc.org>' );

$h->set_query( $q, '', '', 'to' );
@rows = $h->get_query_rows( $q, 1, 2 );
test_assert_equal( $h->get_query_size( $q ), 2 );
test_assert_equal( $#rows, 1 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );
test_assert_equal( $rows[1][1], 'Evil Spammer <nospam@jgc.org>' );

$h->set_query( $q, '', '', 'from' );
test_assert_equal( $h->get_query_size( $q ), 2 );
@rows = $h->get_query_rows( $q, 1, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'Evil Spammer <nospam@jgc.org>' );

$h->set_query( $q, '', '', 'to' );
test_assert_equal( $h->get_query_size( $q ), 2 );
@rows = $h->get_query_rows( $q, 2, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'Evil Spammer <nospam@jgc.org>' );

# Now try unsorted and filtered on a specific bucket

$h->set_query( $q, 'spam', '', '' );
test_assert_equal( $h->get_query_size( $q ), 1 );
@rows = $h->get_query_rows( $q, 1, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'Evil Spammer <nospam@jgc.org>' );
test_assert_equal( $rows[0][8], 'spam' );

$h->set_query( $q, 'personal', '', '' );
test_assert_equal( $h->get_query_size( $q ), 1 );
@rows = $h->get_query_rows( $q, 1, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );
test_assert_equal( $rows[0][8], 'personal' );

# Now try a search 

$h->set_query( $q, '', 'john', '' );
test_assert_equal( $h->get_query_size( $q ), 1 );
@rows = $h->get_query_rows( $q, 1, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );

$h->set_query( $q, '', 's', '' );
test_assert_equal( $h->get_query_size( $q ), 2 );
@rows = $h->get_query_rows( $q, 1, 2 );
test_assert_equal( $#rows, 1 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );
test_assert_equal( $rows[1][1], 'Evil Spammer <nospam@jgc.org>' );

# Now try cases that return nothing

$h->set_query( $q, '', 'zzz', '' );
test_assert_equal( $h->get_query_size( $q ), 0 );

$h->set_query( $q, 'other', '', '' );
test_assert_equal( $h->get_query_size( $q ), 0 );

# Make sure that we don't requery unless necessary

$h->set_query( $q, '', 's', '' );
test_assert_equal( $h->get_query_size( $q ), 2 );
@rows = $h->get_query_rows( $q, 1, 2 );
$h->set_query( $q, '', 's', '' );
test_assert_equal( $#{$h->{queries__}{$q}{cache}}, 1 );
$h->set_query( $q, '', 't', '' );
test_assert_equal( $#{$h->{queries__}{$q}{cache}}, -1 );

# Make sure that we can upgrade an existing file with a specific
# classification

open MSG, '>' . $h->get_user_path_( $h->global_config_( 'msgdir' ) . 'popfile1=1.msg' );
print MSG <<EOF;
From: Another Person
To: Someone Else
Subject: Something
Date: Sun, 25 Jul 2000 03:46:31 -0700

This is the body of the message
EOF
close MSG;
open CLS, '>' . $h->get_user_path_( $h->global_config_( 'msgdir' ) . 'popfile1=1.cls' );
print CLS <<EOF;
RECLASSIFIED
other
personal
EOF
close CLS;

$h->upgrade_history_files__();

test_assert( !(-e $h->get_user_path_( $h->global_config_( 'msgdir' ) . 'popfile1=1.cls' ) ) );
test_assert( !(-e $h->get_user_path_( $h->global_config_( 'msgdir' ) . 'popfile1=1.msg' ) ) );

$mq->service();
$h->service();

$h->set_query( $q, '', '', '' );
test_assert_equal( $h->get_query_size( $q ), 3 );

$h->set_query( $q, 'other', '', '' );
test_assert_equal( $h->get_query_size( $q ), 1 );

@rows = $h->get_query_rows( $q, 1, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'Another Person' );
test_assert_equal( $rows[0][2], 'Someone Else' );
test_assert_equal( $rows[0][4], 'Something' );
test_assert_equal( $rows[0][5], 964521991 );

# Now check that deletion works

$h->set_query( $q, '', '', '' );
test_assert_equal( $h->get_query_size( $q ), 3 );

$file = $h->get_slot_file( 2 );
test_assert( ( -e $file ) );
$h->delete_slot( 2 );
test_assert( !( -e $file ) );

$h->set_query( $q, '', '', '' );
test_assert_equal( $h->get_query_size( $q ), 2 );

@rows = $h->get_query_rows( $q, 1, 2 );
test_assert_equal( $#rows, 1 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );
test_assert_equal( $rows[1][1], 'Another Person' );

# Now try history cleanup, should just leave one entry

$h->cleanup_history__();
$h->set_query( $q, '', '', '' );
test_assert_equal( $h->get_query_size( $q ), 1 );

@rows = $h->get_query_rows( $q, 1, 1 );
test_assert_equal( $#rows, 0 );
test_assert_equal( $rows[0][1], 'John Graham-Cumming <nospam@jgc.org>' );

$h->stop_query( $q );
test_assert( !defined( $h->{queries__}{$q} ) );

$h->stop();
$b->stop();

1;
