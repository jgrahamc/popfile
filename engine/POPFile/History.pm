# POPFILE LOADABLE MODULE 3
package POPFile::History;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile's history.  It manages entries in the POPFile
# database and on disk that store messages previously classified by POPFile.
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
#----------------------------------------------------------------------------

use strict;
use warnings;
use locale;

use Date::Parse;
use Digest::MD5 qw( md5_hex );

my $fields_slot = 'history.id, hdr_from, hdr_to, hdr_cc, hdr_subject,
hdr_date, hash, inserted, buckets.name, usedtobe, history.bucketid, magnets.val, size';

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = POPFile::Module->new();

    # List of committed history items waiting to be committed
    # into the database, it consists of lists containing three
    # elements: the slot id, the bucket classified to and the
    # magnet if used

    $self->{commit_list__} = ();

    # Contains queries started with start_query and consists
    # of a mapping between unique IDs and quadruples containing
    # a reference to the SELECT and a cache of already fetched
    # rows and a total row count.  These quadruples are implemented
    # as a sub-hash with keys query, count, cache, fields

    $self->{queries__} = ();

    $self->{firsttime__} = 1;

    bless($self, $class);

    $self->name( 'history' );

    return $self;
}

#----------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the history module
#
#----------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # If 1, Messages are saved to an archive when they are removed or expired
    # from the history cache

    $self->config_( 'archive', 0 );

    # The directory where messages will be archived to, in sub-directories for
    # each bucket

    $self->config_( 'archive_dir', 'archive' );

    # This is an advanced setting which will save archived files to a
    # randomly numbered sub-directory, if set to greater than zero, otherwise
    # messages will be saved in the bucket directory
    #
    # 0 <= directory name < archive_classes

    $self->config_( 'archive_classes', 0 );

    # Need TICKD message for history clean up, COMIT when a message
    # is committed to the history

    $self->mq_register_( 'TICKD', $self );
    $self->mq_register_( 'COMIT', $self );

    return 1;
}

#----------------------------------------------------------------------------
#
# stop
#
# Called to stop the history module
#
#----------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    # Commit any remaining history items.  This is needed because it's
    # possible that we get called with a stop after things have been
    # added to the queue and before service() is called

    $self->commit_history__();
}

#----------------------------------------------------------------------------
#
# service
#
# Called periodically so that the module can do its work
#
#----------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    if ( $self->{firsttime__} ) {
        $self->upgrade_history_files__();
        $self->{firsttime__} = 0;
    }

    # Note when we go to multiuser POPFile we'll need to change this call
    # so that we are sure that the session IDs that it is using are still
    # valid.  The easiest way will be to call it in deliver() when we get
    # a COMIT message.

    $self->commit_history__();

    return 1;
}

#----------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
#----------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, @message ) = @_;

    # If a day has passed then clean up the history

    if ( $type eq 'TICKD' ) {
        $self->cleanup_history();
    }

    if ( $type eq 'COMIT' ) {
        push ( @{$self->{commit_list__}}, \@message );
    }
}

#----------------------------------------------------------------------------
#
# ADDING TO THE HISTORY
#
# To add a message to the history the following sequence of calls
# is made:
#
# 1. Obtain a unique ID and filename for the new message by a call
#    to reserve_slot
#
# 2. Write the message into the filename returned
#
# 3. Call commit_slot with the bucket into which the message was
#    classified
#
# If an error occurs after #1 and the slot is unneeded then call
# release_slot
#
#----------------------------------------------------------------------------
#
# FINDING A HISTORY ENTRY
#
# 1. If you know the slot id then call get_slot_file to obtain
#    the full path where the file is stored
#
# 2. If you know the message hash then call get_slot_from hash
#    to get the slot id
#
# 3. If you know the message headers then use get_message_hash
#    to get the hash
#
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#
# reserve_slot
#
# Called to reserve a place in the history for a message that is in the
# process of being received.  It returns a unique ID for this slot and
# the full path to the file where the message should be stored.  The
# caller is expected to later call either release_slot (if the slot is not
# going to be used) or commit_slot (if the file has been written and the
# entry should be added to the history).
#
#----------------------------------------------------------------------------
sub reserve_slot
{
    my ( $self ) = @_;

    my $r;

    while (1) {
        $r = int(rand( 1000000000 )+2);

        $self->log_( 2, "reserve_slot selected random number $r" );

        # TODO Replace the hardcoded user ID 1 with the looked up
        # user ID from the session key

        my $test = $self->db_()->selectrow_arrayref(
                 "select id from history where committed = $r limit 1;");

        if ( defined( $test ) ) {
            next;
        }

        # Get the date/time now which will be stored in the database
        # so that we can sort on the Date: header in the message and
        # when we received it

        my $now = time;
        $self->db_()->do(
            "insert into history ( userid, committed, inserted ) values ( 1, $r, $now );" );
        last;
    }

    my $result = $self->db_()->selectrow_arrayref(
                 "select id from history where committed = $r limit 1;");

    my $slot = $result->[0];

    $self->log_( 2, "reserve_slot returning slot id $slot" );

    return ( $slot, $self->get_slot_file( $slot ) );
}

#----------------------------------------------------------------------------
#
# release_slot
#
# See description with reserve_slot; release_slot releases a history slot
# previously allocated with reserve_slot and discards it.
#
# id              Unique ID returned by reserve_slot
#
#----------------------------------------------------------------------------
sub release_slot
{
    my ( $self, $slot ) = @_;

    # Remove the entry from the database and delete the file
    # if present

    my $delete = "delete from history where history.id = $slot;";

    $self->db_()->do( $delete );

    my $file = $self->get_slot_file( $slot );

    unlink $file;

    # It's not possible that the directory for the slot file is empty
    # and we want to delete it so that things get cleaned up automatically

    $file =~ s/popfile[a-f0-9]{2}\.msg$//i;

    my $depth = 3;

    while ( $depth > 0 ) {
        my @files = glob( $file . '*' );

        if ( $#files == -1 ) {
            if ( !( rmdir( $file ) ) ) {
                last;
            }
            $file =~ s![a-f0-9]{2}/$!!i;
        } else {
            last;
        }

        $depth--;
    }
}

#----------------------------------------------------------------------------
#
# commit_slot
#
# See description with reserve_slot; commit_slot commits a history
# slot to the database and makes it part of the history.  Before this
# is called the full message should have been written to the file
# returned by reserve_slot.  Note that commit_slot queues the message
# for insertion and does not commit it until some (short) time later
#
# session         User session with Classifier::Bayes API
# slot            Unique ID returned by reserve_slot
# bucket          Bucket classified to
# magnet          Magnet if used
#
#----------------------------------------------------------------------------
sub commit_slot
{
    my ( $self, $session, $slot, $bucket, $magnet ) = @_;

    $self->mq_post_( 'COMIT', $session, $slot, $bucket, $magnet );
}

#----------------------------------------------------------------------------
#
# change_slot_classification
#
# Used to 'reclassify' a message by changing its classification in the
# database.
#
# slot         The slot to update
# class        The new classification
# session      A valid API session
# undo         If set to 1 then indicates an undo operation
#
#----------------------------------------------------------------------------
sub change_slot_classification
{
    my ( $self, $slot, $class, $session, $undo ) = @_;

    $self->log_( 0, "Change slot classification of $slot to $class" );

    # Get the bucket ID associated with the new classification
    # then retrieve the current classification for this slot
    # and update the database

    my $bucketid = $self->classifier_()->get_bucket_id(
                           $session, $class );

    my $oldbucketid = 0;
    if ( !$undo ) {
        my @fields = $self->get_slot_fields( $slot );
        $oldbucketid = $fields[10];
    }

    $self->db_()->do( "update history set bucketid = $bucketid,
                                           usedtobe = $oldbucketid
                                       where id = $slot;" );
    $self->force_requery__();
}

#----------------------------------------------------------------------------
#
# revert_slot_classification
#
# Used to undo a 'reclassify' a message by changing its classification
# in the database.
#
# slot         The slot to update
#
#----------------------------------------------------------------------------
sub revert_slot_classification
{
    my ( $self, $slot ) = @_;

    my @fields = $self->get_slot_fields( $slot );
    my $oldbucketid = $fields[9];

    $self->db_()->do( "update history set bucketid = $oldbucketid,
                                           usedtobe = 0
                                       where id = $slot;" );
    $self->force_requery__();
}

#---------------------------------------------------------------------------
#
# get_slot_fields
#
# Returns the fields associated with a specific slot.  We return the
# same collection of fields as get_query_rows.
#
# slot           The slot id
#
#---------------------------------------------------------------------------
sub get_slot_fields
{
    my ( $self, $slot ) = @_;

    return $self->db_()->selectrow_array(
        "select $fields_slot from history, buckets, magnets
             where history.id = $slot and
                   buckets.id = history.bucketid and
                   magnets.id = magnetid;" );
}

#---------------------------------------------------------------------------
#
# is_valid_slot
#
# Returns 1 if the slot ID passed in is valid
#
# slot           The slot id
#
#---------------------------------------------------------------------------
sub is_valid_slot
{
    my ( $self, $slot ) = @_;

    my @row = $self->db_()->selectrow_array(
        "select id from history where history.id = $slot;" );

    return ( ( @row ) && ( $row[0] == $slot ) );
}

#---------------------------------------------------------------------------
#
# commit_history__
#
# (private) Used internally to commit messages that have been committed
# with a call to commit_slot to the database
#
#----------------------------------------------------------------------------
sub commit_history__
{
    my ( $self ) = @_;

    if ( $#{$self->{commit_list__}} == -1 ) {
        return;
    }

    foreach my $entry (@{$self->{commit_list__}}) {
        my ( $session, $slot, $bucket, $magnet ) = @{$entry};

        my $file = $self->get_slot_file( $slot );

        # Committing to the history requires the following steps
        #
        # 1. Parse the message to extract the headers
        # 2. Compute MD5 hash of Message-ID, Date and Subject
        # 3. Update the related row with the headers and
        #    committed set to 1

        my %header;

        if ( open FILE, "<$file" ) {
            my $last;
            while ( <FILE> ) {
                s/[\r\n]//g;

                if ( /^$/ ) {
                    last;
                }

                if ( /^([^ \t]+):[ \t]*(.*)$/ ) {
                    $last = lc $1;
                    push @{$header{$last}}, $2;

                } else {
                    if ( defined $last ) {
                        ${$header{$last}}[$#{$header{$last}}] .= $_;
                    }
                }
            }
            close FILE;
        }
        else {
            $self->log_( 0, "Could not open history message file $file for reading." );
        }

        my $hash = $self->get_message_hash( ${$header{'message-id'}}[0],
                                            ${$header{'date'}}[0],
                                            ${$header{'subject'}}[0],
                                            ${$header{'received'}}[0] );
        $hash = $self->db_()->quote( $hash );

        # For sorting purposes the From, To and CC headers have special
        # cleaned up versions of themselves in the database.  The idea
        # is that case and certain characters should be ignored when
        # sorting these fields
        #
        # "John Graham-Cumming" <spam@jgc.org> maps to
        #     john graham-cumming spam@jgc.org

        my @sortable = ( 'from', 'to', 'cc' );
        my %sort_headers;

        foreach my $h (@sortable) {
            $sort_headers{$h} =
                 $self->classifier_()->{parser__}->decode_string(
                     ${$header{$h}}[0] );
            $sort_headers{$h} = lc($sort_headers{$h} || '');
            $sort_headers{$h} =~ s/[\"<>]//g;
            $sort_headers{$h} =~ s/^[ \t]+//g;
            $sort_headers{$h} =~ s/\0//g;
            $sort_headers{$h} = $self->db_()->quote(
                $sort_headers{$h} );
        }

        # Make sure that the headers we are going to insert into
        # the database have been defined and are suitably quoted

        my @required = ( 'from', 'to', 'cc', 'subject' );

        foreach my $h (@required) {

            ${$header{$h}}[0] =
                 $self->classifier_()->{parser__}->decode_string(
                     ${$header{$h}}[0] );
            
            if ( !defined ${$header{$h}}[0] || ${$header{$h}}[0] =~ /^\s*$/ ) {
                if ( $h ne 'cc' ) {
                    ${$header{$h}}[0] = "<$h header missing>";
                } else {
                    ${$header{$h}}[0] = '';
                }
            }
            
            ${$header{$h}}[0] =~ s/\0//g;
            ${$header{$h}}[0] = $self->db_()->quote( ${$header{$h}}[0] );
        }

        # If we do not have a date header then set the date to
        # 0 (start of the Unix epoch), otherwise parse the string
        # using Date::Parse to interpret it and turn it into the
        # Unix epoch.

        if ( !defined( ${$header{date}}[0] ) ) {
            ${$header{date}}[0] = 0;
        } else {
            ${$header{date}}[0] = str2time( ${$header{date}}[0] ) || 0;
        }

        # Figure out the ID of the bucket this message has been
        # classified into (and the same for the magnet if it is
        # defined)

        my $bucketid = $self->classifier_()->get_bucket_id(
                           $session, $bucket );

        my $msg_size = -s $file;

        # If we can't get the bucket ID because the bucket doesn't exist
        # which could happen when we are upgrading the history which
        # has old bucket names in it then we will remove the entry from the
        # history and log the failure

        if ( defined( $bucketid ) ) {
            my $result = $self->db_()->do(
                "update history set hdr_from    = ${$header{from}}[0],
                                    hdr_to      = ${$header{to}}[0],
                                    hdr_date    = ${$header{date}}[0],
                                    hdr_cc      = ${$header{cc}}[0],
                                    hdr_subject = ${$header{subject}}[0],
                                    sort_from   = $sort_headers{from},
                                    sort_to     = $sort_headers{to},
                                    sort_cc     = $sort_headers{cc},
                                    committed   = 1,
                                    bucketid    = $bucketid,
                                    usedtobe    = 0,
                                    magnetid    = $magnet,
                                    hash        = $hash,
                                    size        = $msg_size
                                    where id = $slot;" );
        } else {
            $self->log_( 0, "Couldn't find bucket ID for bucket $bucket when committing $slot" );
            $self->release_slot( $slot );
        }
    }

    $self->{commit_list__} = ();
    $self->force_requery__();
}

# ---------------------------------------------------------------------------
#
# delete_slot
#
# Deletes an entry from the database and disk, optionally archiving it
# if the archive parameters have been set
#
# $slot              The slot ID
# $archive           1 if it's OK to archive this entry
#
# ---------------------------------------------------------------------------
sub delete_slot
{
    my ( $self, $slot, $archive ) = @_;

    my $file = $self->get_slot_file( $slot );
    $self->log_( 2, "delete_slot called for slot $slot, file $file" );

    if ( $archive && $self->config_( 'archive' ) ) {
        my $path = $self->get_user_path_( $self->config_( 'archive_dir' ), 0 );

        $self->make_directory__( $path );

        my @b = $self->db_()->selectrow_array(
            "select buckets.name from history, buckets
                 where history.bucketid = buckets.id and
                       history.id = $slot;" );

        my $bucket = $b[0];

        if ( ( $bucket ne 'unclassified' ) &&
             ( $bucket ne 'unknown class' ) ) {
            $path .= "\/" . $bucket;
            $self->make_directory__( $path );

            if ( $self->config_( 'archive_classes' ) > 0) {

                # Archive to a random sub-directory of the bucket archive

                my $subdirectory = int( rand(
                    $self->config_( 'archive_classes' ) ) );
                $path .= "\/" . $subdirectory;
                $self->make_directory__( $path );
            }

            # Previous comment about this potentially being unsafe
            # (may have placed messages in unusual places, or
            # overwritten files) no longer applies. Files are now
            # placed in the user directory, in the archive_dir
            # subdirectory

            $self->copy_file__( $file, $path, "popfile$slot.msg" );
        }
    }

    # Now remove the entry from the database, and the file from disk,
    # and also invalidate the caches of any open queries since they
    # may have been affected

    $self->release_slot( $slot );
    $self->force_requery__();
}

#----------------------------------------------------------------------------
#
# start_deleting
#
# Called before doing a block of calls to delete_slot.  This will call
# back into the Classifier::Bayes to tweak the database performance to
# make this quick.
#
#----------------------------------------------------------------------------
sub start_deleting
{
    my ( $self ) = @_;

    $self->database_()->tweak_sqlite( 1, 1, $self->db_() );
}

#----------------------------------------------------------------------------
#
# stop_deleting
#
# Called after doing a block of calls to delete_slot.  This will call
# back into the Classifier::Bayes to untweak the database performance.
#
#----------------------------------------------------------------------------
sub stop_deleting
{
    my ( $self ) = @_;

    $self->database_()->tweak_sqlite( 1, 0, $self->db_() );
}

#----------------------------------------------------------------------------
#
# get_slot_file
#
# Used to map a slot ID to the full path of the file will contain
# the message associated with the slot
#
#----------------------------------------------------------------------------
sub get_slot_file
{
    my ( $self, $slot ) = @_;

    # The mapping between the slot and the file goes as follows:
    #
    # 1. Convert the file to an 8 digit hex number (with leading
    #    zeroes).
    # 2. Call that number aabbccdd
    # 3. Build the path aa/bb/cc
    # 4. Name the file popfiledd.msg
    # 5. Add the msgdir location to obtain
    #        msgdir/aa/bb/cc/popfiledd.msg
    #
    # Hence each directory can have up to 256 entries

    my $hex_slot = sprintf( '%8.8x', $slot );
    my $path = $self->get_user_path_(
                   $self->global_config_( 'msgdir' ) .
                       substr( $hex_slot, 0, 2 ) . '/', 0 );

    $self->make_directory__( $path );
    $path .= substr( $hex_slot, 2, 2 ) . '/';
    $self->make_directory__( $path );
    $path .= substr( $hex_slot, 4, 2 ) . '/';
    $self->make_directory__( $path );

    my $file = 'popfile' .
               substr( $hex_slot, 6, 2 ) . '.msg';

    return $path . $file;
}

#----------------------------------------------------------------------------
#
# get_message_hash
#
# Used to compute an MD5 hash of the headers of a message
# so that the same message can later me identified by a
# call to get_slot_from_hash
#
# messageid              The message id header
# date                   The date header
# subject                The subject header
# received               First Received header line
#
# Note that the values passed in are everything after the : in
# header without the trailing \r or \n.  If a header is missing
# then pass in the empty string
#
#----------------------------------------------------------------------------
sub get_message_hash
{
    my ( $self, $messageid, $date, $subject, $received ) = @_;

    $messageid = '' if ( !defined( $messageid ) );
    $date      = '' if ( !defined( $date      ) );
    $subject   = '' if ( !defined( $subject   ) );
    $received  = '' if ( !defined( $received  ) );

    return md5_hex( "[$messageid][$date][$subject][$received]" );
}

#----------------------------------------------------------------------------
#
# get_slot_from_hash
#
# Given a hash value (returned by get_message_hash), find any
# corresponding message in the database and return its slot
# id.   If the message does not exist then return the empty
# string.
#
# hash                 The hash value
#
#----------------------------------------------------------------------------
sub get_slot_from_hash
{
    my ( $self, $hash ) = @_;

    $hash = $self->db_()->quote( $hash );
    my $result = $self->db_()->selectrow_arrayref(
        "select id from history where hash = $hash limit 1;" );

    return defined( $result )?$result->[0]:'';
}

#----------------------------------------------------------------------------
#
# QUERYING THE HISTORY
#
# 1. Start a query session by calling start_query and obtain a unique
#    ID
#
# 2. Set the query parameter (i.e. sort, search and filter) with a call
#    to set_query
#
# 3. Obtain the number of history rows returned by calling get_query_size
#
# 4. Get segments of the history returned by calling get_query_rows with
#    the start and end rows needed
#
# 5. When finished with the query call stop_query
#
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#
# start_query
#
# Used to start a query session, returns a unique ID for this
# query.  When the caller is done with the query they return
# stop_query.
#
#----------------------------------------------------------------------------
sub start_query
{
    my ( $self ) = @_;

    # Think of a large random number, make sure that it hasn't
    # been used and then return it

    while (1) {
        my $id = sprintf( '%8.8x', int(rand(4294967295)) );

        if ( !defined( $self->{queries__}{$id} ) ) {
            $self->{queries__}{$id}{query} = 0;
            $self->{queries__}{$id}{count} = 0;
            $self->{queries__}{$id}{cache} = ();
            return $id
        }
    }
}

#----------------------------------------------------------------------------
#
# stop_query
#
# Used to clean up after a query session
#
# id                The ID returned by start_query
#
#----------------------------------------------------------------------------
sub stop_query
{
    my ( $self, $id ) = @_;

    # If the cache size hasn't grown to the row
    # count then we didn't fetch everything and so
    # we fill call finish to clean up

    my $q = $self->{queries__}{$id}{query};

    if ( ( defined $q ) && ( $q != 0 ) ) {
        if ( $#{$self->{queries__}{$id}{cache}} !=
             $self->{queries__}{$id}{count} ) {
           $q->finish;
        }
    }

    delete $self->{queries__}{$id};
}

#----------------------------------------------------------------------------
#
# set_query
#
# Called to set up a query with sort, filter and search options
#
# id            The ID returned by start_query
# filter        Name of bucket to filter on
# search        From/Subject line to search for
# sort          The field to sort on (from, subject, to, cc, bucket, date)
#               (optional leading - for descending sort)
# not           If set to 1 negates the search
#
#----------------------------------------------------------------------------
sub set_query
{
    my ( $self, $id, $filter, $search, $sort, $not ) = @_;

    # If this query has already been done and is in the cache
    # then do no work here

    if ( defined( $self->{queries__}{$id}{fields} ) &&
         ( $self->{queries__}{$id}{fields} eq
             "$filter:$search:$sort:$not" ) ) {
        return;
    }

    $self->{queries__}{$id}{fields} = "$filter:$search:$sort:$not";

    # We do two queries, the first to get the total number of rows that
    # would be returned and then we start the real query.  This is done
    # so that we know the size of the resulting data without having
    # to retrieve it all

    $self->{queries__}{$id}{base} = 'select XXX from
        history, buckets, magnets where history.userid = 1 and committed = 1';

    $self->{queries__}{$id}{base} .= ' and history.bucketid = buckets.id';
    $self->{queries__}{$id}{base} .= ' and magnets.id = magnetid';

    # If there's a search portion then add the appropriate clause
    # to find the from/subject header

    my $not_word  = $not?'not':'';
    my $not_equal = $not?'!=':'=';
    my $equal     = $not?'=':'!=';

    if ( $search ne '' ) {
        $search = $self->db_()->quote( '%' . $search . '%' );
        $self->{queries__}{$id}{base} .= " and $not_word ( hdr_from like $search or hdr_subject like $search )";
    }

    # If there's a filter option then we'll need to get the bucket
    # id for the filtered bucket and add the appropriate clause

    if ( $filter ne '' ) {
        if ( $filter eq '__filter__magnet' ) {
            $self->{queries__}{$id}{base} .=
                " and history.magnetid $equal 0";
        } else {
            my $session = $self->classifier_()->get_session_key(
                              'admin', '' );
            my $bucketid = $self->classifier_()->get_bucket_id(
                               $session, $filter );
            $self->classifier_()->release_session_key( $session );
            $self->{queries__}{$id}{base} .=
                " and history.bucketid $not_equal $bucketid";
        }
    }

    # Add the sort option (if there is one)

    if ( $sort ne '' ) {
        $sort =~ s/^(\-)//;
        my $direction = defined($1)?'desc':'asc';
        if ( $sort eq 'bucket' ) {
            $sort = 'buckets.name';
        } else {
            if ( $sort =~ /from|to|cc/ ) {
                $sort = "sort_$sort";
            } else {
                if ( $sort ne 'inserted' && $sort ne 'size' ) {
                    $sort = "hdr_$sort";
                }
            }
        }
        $self->{queries__}{$id}{base} .= " order by $sort $direction;";
    } else {
        $self->{queries__}{$id}{base} .= ' order by inserted desc;';
    }

    my $count = $self->{queries__}{$id}{base};
    $self->log_( 2, "Base query is $count" );
    $count =~ s/XXX/COUNT(*)/;

    $self->{queries__}{$id}{count} =
        $self->db_()->selectrow_arrayref( $count )->[0];

    my $select = $self->{queries__}{$id}{base};
    $select =~ s/XXX/$fields_slot/;
    $self->{queries__}{$id}{query} = $self->db_()->prepare( $select );
    $self->{queries__}{$id}{query}->execute;
    $self->{queries__}{$id}{cache} = ();
}

#----------------------------------------------------------------------------
#
# delete_query
#
# Called to delete all the rows returned in a query
#
# id            The ID returned by start_query
#
#----------------------------------------------------------------------------
sub delete_query
{
    my ( $self, $id ) = @_;

    $self->start_deleting();

    my $delete = $self->{queries__}{$id}{base};
    $delete =~ s/XXX/history.id/;
    my $d = $self->db_()->prepare( $delete );
    $d->execute;
    my @row;
    my @ids;
    while ( @row = $d->fetchrow_array ) {
        push ( @ids, $row[0] );
    }
    foreach my $id (@ids) {
        $self->delete_slot( $id, 1 );
    }

    $self->stop_deleting();
}

#----------------------------------------------------------------------------
#
# get_query_size
#
# Called to return the number of elements in the query.
# Should only be called after a call to set_query.
#
# id            The ID returned by start_query
#
#----------------------------------------------------------------------------
sub get_query_size
{
    my ( $self, $id ) = @_;

    return $self->{queries__}{$id}{count};
}

#----------------------------------------------------------------------------
#
# get_query_rows
#
# Returns the rows in the range [$start, $end) from a query that has
# already been set up with a call to set_query.  The first row is row 1.
#
# id            The ID returned by start_query
# start         The first row to return
# count         Number of rows to return
#
# Each row contains the fields:
#
#    id (0), from (1), to (2), cc (3), subject (4), date (5), hash (6),
#    inserted date (7), bucket name (8), reclassified id (9), bucket id (10),
#    magnet value (11), size (12)
#----------------------------------------------------------------------------
sub get_query_rows
{
    my ( $self, $id, $start, $count ) = @_;

    # First see if we have already retrieved these rows from the query
    # if we have then we can just return them from the cache.  Otherwise
    # fetch the rows from the database and then return them

    my $size = $#{$self->{queries__}{$id}{cache}}+1;

    $self->log_( 2, "Request for rows $start ($count), current size $size" );

    if ( ( $size < ( $start + $count - 1 ) ) ) {
        my $rows = $start + $count - $size;
        $self->log_( 2, "Getting $rows rows from database" );
        push ( @{$self->{queries__}{$id}{cache}},
            @{$self->{queries__}{$id}{query}->fetchall_arrayref(
                undef, $start + $count - $size )} );
    }

    my ( $from, $to ) = ( $start-1, $start+$count-2 );

    $self->log_( 2, "Returning $from..$to" );

    return @{$self->{queries__}{$id}{cache}}[$from..$to];
}

# ---------------------------------------------------------------------------
#
# make_directory__
#
# Wrapper for mkdir that ensures that the path we are making doesn't end in
# / or \ (Done because your can't do mkdir 'foo/' on NextStep.
#
# $path        The directory to make
#
# Returns whatever mkdir returns
#
# ---------------------------------------------------------------------------
sub make_directory__
{
    my ( $self, $path ) = @_;

    $path =~ s/[\\\/]$//;

    return 1 if ( -d $path );
    return mkdir( $path );
}

# ---------------------------------------------------------------------------
#
# compare_mf__
#
# Compares two mailfiles, used for sorting mail into order
#
# ---------------------------------------------------------------------------
sub compare_mf__
{
    $a =~ /popfile(\d+)=(\d+)\.msg/;
    my ( $ad, $am ) = ( $1, $2 );

    $b =~ /popfile(\d+)=(\d+)\.msg/;
    my ( $bd, $bm ) = ( $1, $2 );

    if ( $ad == $bd ) {
        return ( $bm <=> $am );
    } else {
        return ( $bd <=> $ad );
    }
}

# ---------------------------------------------------------------------------
#
# upgrade_history_files__
#
# Looks for old .MSG/.CLS history entries and sticks them in the database
#
# ---------------------------------------------------------------------------
sub upgrade_history_files__
{
    my ( $self ) = @_;

    # See if there are any .MSG files in the msgdir, and if there are
    # upgrade them by placing them in the database

    my @msgs = sort compare_mf__ glob $self->get_user_path_(
        $self->global_config_( 'msgdir' ) . 'popfile*.msg', 0 );

    if ( $#msgs != -1 ) {
        my $session = $self->classifier_()->get_session_key( 'admin', '' );

        print "\nFound old history files, moving them into database\n    ";

        my $i = 0;
        $self->db_()->begin_work;
        foreach my $msg (@msgs) {
            if ( ( ++$i % 100 ) == 0 ) {
                print "[$i]";
                flush STDOUT;
            }

            # NOTE.  We drop the information in $usedtobe, so that
            # reclassified messages will no longer appear reclassified
            # in upgraded history.  Also the $magnet is ignored so
            # upgraded history will have no magnet information.

            my ( $reclassified, $bucket, $usedtobe, $magnet ) =
                $self->history_read_class__( $msg );

            if ( $bucket ne 'unknown_class' ) {
                my ( $slot, $file ) = $self->reserve_slot();
                rename $msg, $file;
                my @message = ( $session, $slot, $bucket, 0 );
                push ( @{$self->{commit_list__}}, \@message );
            }
        }
        $self->db_()->commit;

        print "\nDone upgrading history\n";

        $self->commit_history__();
        $self->classifier_()->release_session_key( $session );

        unlink $self->get_user_path_(
            $self->global_config_( 'msgdir' ) . 'history_cache', 0 );
    }
}

# ---------------------------------------------------------------------------
#
# history_read_class__ - load and delete the class file for a message.
#
# returns: ( reclassified, bucket, usedtobe, magnet )
#   values:
#       reclassified:   boolean, true if message has been reclassified
#       bucket:         string, the bucket the message is in presently,
#                       unknown class if an error occurs
#       usedtobe:       string, the bucket the message used to be in
#                       (null if not reclassified)
#       magnet:         string, the magnet
#
# $filename     The name of the message to load the class for
#
# ---------------------------------------------------------------------------
sub history_read_class__
{
    my ( $self, $filename ) = @_;

    $filename =~ s/msg$/cls/;

    my $reclassified = 0;
    my $bucket = 'unknown class';
    my $usedtobe;
    my $magnet = '';

    if ( open CLASS, "<$filename" ) {
        $bucket = <CLASS>;
        if ( defined( $bucket ) &&
           ( $bucket =~ /([^ ]+) MAGNET ([^\r\n]+)/ ) ) {
            $bucket = $1;
            $magnet = $2;
        }

        $reclassified = 0;
        if ( defined( $bucket ) && ( $bucket =~ /RECLASSIFIED/ ) ) {
            $bucket       = <CLASS>;
            $usedtobe = <CLASS>;
            $reclassified = 1;
            $usedtobe =~ s/[\r\n]//g;
        }
        close CLASS;
        $bucket =~ s/[\r\n]//g if defined( $bucket );
        unlink $filename;
    } else {
        return ( undef, $bucket, undef, undef );
    }

    $bucket = 'unknown class' if ( !defined( $bucket ) );

    return ( $reclassified, $bucket, $usedtobe, $magnet );
}

#----------------------------------------------------------------------------
#
# cleanup_history
#
# Removes the popfile*.msg files that are older than a number of days
# configured as history_days.
#
#----------------------------------------------------------------------------
sub cleanup_history
{
    my ( $self ) = @_;

    my $seconds_per_day = 24 * 60 * 60;
    my $old = time - $self->user_config_( 1, 'history_days' ) * $seconds_per_day;
    my $d = $self->db_()->prepare( "select id from history
                                         where inserted < $old;" );
    $d->execute;
    my @row;
    my @ids;
    while ( @row = $d->fetchrow_array ) {
        push ( @ids, $row[0] );
    }
    foreach my $id (@ids) {
        $self->delete_slot( $id, 1 );
    }
}

# ---------------------------------------------------------------------------
#
# copy_file__
#
# Utility to copy a file and ensure that the path it is going to
# exists
#
# $from               Where to copy from
# $to_dir             The directory it will be copied to
# $to_name            The name of the destination (without the directory)
#
# ---------------------------------------------------------------------------
sub copy_file__
{
    my ( $self, $from, $to_dir, $to_name ) = @_;

    if ( open( FROM, "<$from") ) {
        if ( open( TO, ">$to_dir\/$to_name") ) {
            binmode FROM;
            binmode TO;
            while (<FROM>) {
                print TO $_;
            }
            close TO;
        }

        close FROM;
    }
}

# ---------------------------------------------------------------------------
#
# force_requery__
#
# Called when the database has changed to invalidate any queries that are
# open so that cached data is not returned and the database is requeried
#
# ---------------------------------------------------------------------------
sub force_requery__
{
    my ( $self ) = @_;
    # Force requery since the messages have changed

    foreach my $id (keys %{$self->{queries__}}) {
        $self->{queries__}{$id}{fields} = '';
    }
}

1;
