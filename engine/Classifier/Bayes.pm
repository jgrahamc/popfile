# POPFILE LOADABLE MODULE
package Classifier::Bayes;

use POPFile::Module;
@ISA = ("POPFile::Module");

# ---------------------------------------------------------------------------------------------
#
# Bayes.pm --- Naive Bayes text classifier
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
#   Modified by              Sam Schinke    (sschinke@users.sourceforge.net)
#   Merged with db code from Scott Leighton (helphand@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;
use Classifier::MailParse;
use IO::Handle;
use DBI;
use Digest::MD5 qw( md5_hex );

# This is used to get the hostname of the current machine
# in a cross platform way

use Sys::Hostname;

# A handy variable containing the value of an EOL for networks

my $eol = "\015\012";

# Korean characters definition

my $ksc5601_sym = '(?:[\xA1-\xAC][\xA1-\xFE])';
my $ksc5601_han = '(?:[\xB0-\xC8][\xA1-\xFE])';
my $ksc5601_hanja  = '(?:[\xCA-\xFD][\xA1-\xFE])';
my $ksc5601 = "(?:$ksc5601_sym|$ksc5601_han|$ksc5601_hanja)";

my $eksc = "(?:$ksc5601|[\x81-\xC6][\x41-\xFE])"; #extended ksc

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = POPFile::Module->new();

    # Set this to 1 to get scores for individual words in message detail

    $self->{wordscores__}        = 0;

    # Choice for the format of the "word matrix" display.

    $self->{wmformat__}          = '';

    # Just our hostname

    $self->{hostname__}        = '';

    # File Handle for DBI database

    $self->{db__}                = {};

    # To save time we also 'prepare' some commonly used SQL statements and cache
    # them here, see the function db_connect__ for details

    $self->{db_get_buckets__} = 0;
    $self->{db_get_wordid__} = 0;
    $self->{db_get_word_count__} = 0;
    $self->{db_put_word_count__} = 0;
    $self->{db_get_bucket_unique_count__} = 0;
    $self->{db_get_unique_word_count__} = 0;
    $self->{db_get_bucket_word_count__} = 0;
    $self->{db_get_full_total__} = 0;
    $self->{db_get_bucket_parameter__} = 0;
    $self->{db_set_bucket_parameter__} = 0;
    $self->{db_get_bucket_parameter_default__} = 0;
    $self->{db_get_buckets_with_magnets__} = 0;

    # To save more time we keep a record of the user id for admin, and a hash of the
    # bucket ids for that user, this minimizes the complexity of the database joins
    # we have to do, and since there is a small amount of this data that is (mostly)
    # fixed its a good optimization to cache it in memory.

    $self->{db_userid__}         = 0;

    # Caches the name of each bucket and relates it to both the bucket ID in the
    # database and whether it is pseudo or not
    #
    # Subkeys used are:
    #
    # id     The bucket ID in the database
    # pseudo 1 if this is a pseudo bucket

    $self->{db_bucketid__}       = {};

    # Caches the IDs that map to parameter types

    $self->{db_parameterid__}    = {};

    # Used to parse mail messages
    $self->{parser__}            = new Classifier::MailParse;

    # The possible colors for buckets
    $self->{possible_colors__} = [ 'red',       'green',      'blue',       'brown', # PROFILE BLOCK START
                                   'orange',    'purple',     'magenta',    'gray',
                                   'plum',      'silver',     'pink',       'lightgreen',
                                   'lightblue', 'lightcyan',  'lightcoral', 'lightsalmon',
                                   'lightgrey', 'darkorange', 'darkcyan',   'feldspar' ]; # PROFILE BLOCK STOP

    # Precomputed per bucket probabilities
    $self->{bucket_start__}      = {};

    # A very unlikely word
    $self->{not_likely__}        = 0;

    # The expected corpus version
    #
    # DEPRECATED  This is only used when upgrading old flat file corpus files
    #             to the database
    $self->{corpus_version__}    = 1;

    # The unclassified cutoff this value means that the top probabilily must be n times greater than the
    # second probability, default is 100 times more likely
    $self->{unclassified__}      = log(100);

    # Used to tell the caller whether a magnet was used in the last
    # mail classification
    $self->{magnet_used__}       = 0;
    $self->{magnet_detail__}     = '';

    # This maps session keys (long strings) to user ids.  If there's an entry here then the session key
    # is valid and can be used in the POPFile API.   See the methods get_session_key and release_session_key
    # for details

    $self->{api_sessions__}      = {};

    # Must call bless before attempting to call any methods

    bless $self, $type;

    $self->name( 'bayes' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# This is called inside a child process that has just forked, since the child needs access
# to the database we open it
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;

    $self->db_connect__();
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

    # This is the name for the database

    $self->config_( 'database', 'popfile.db' );

    # This is the 'connect' string used by DBI to connect to the database, if
    # you decide to change from using SQLite to some other database (e.g. MySQL,
    # Oracle, ... ) this *should* be all you need to change.  The additional
    # parameters user and auth are needed for some databases.
    #
    # Note that the dbconnect string will be interpolated before being passed
    # to DBI and the variable $dbname can be used within it and it resolves to
    # the full path to the database named in the database parameter above.

    $self->config_( 'dbconnect', 'dbi:SQLite:dbname=$dbname' );
    $self->config_( 'dbuser',   '' );
    $self->config_( 'dbauth',   '' );

    # No default unclassified weight is the number of times more sure POPFile
    # must be of the top class vs the second class, default is 100 times more

    $self->config_( 'unclassified_weight', 100 );

    # The corpus is kept in the 'corpus' subfolder of POPFile
    #
    # DEPRECATED This is only used to find an old corpus that might need to
    # be upgraded

    $self->config_( 'corpus', 'corpus' );

    # The characters that appear before and after a subject modification

    $self->config_( 'subject_mod_left',  '[' );
    $self->config_( 'subject_mod_right', ']' );

    # Get the hostname for use in the X-POPFile-Link header

    $self->{hostname__} = hostname;

    # Allow the user to override the hostname

    $self->config_( 'hostname', $self->{hostname__} );

    # We want to hear about classification events so that we can
    # update statistics

    $self->mq_register_( 'CLASS', $self );

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

    # Pass in the current interface language for language specific parsing

    $self->{parser__}->{lang__}  = $self->module_config_( 'html', 'language' );
    $self->{unclassified__} = log( $self->config_( 'unclassified_weight' ) );

    if ( !$self->db_connect__() ) {
        return 0;
    }

    $self->upgrade_predatabase_data__();

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

    $self->db_disconnect__();
}

# ---------------------------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, $message, $parameter ) = @_;

    if ( $type eq 'CLASS' ) {
        $self->set_bucket_parameter( $message, 'count',
            $self->get_bucket_parameter( $message, 'count' ) + 1 );
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

    for my $bucket ($self->get_buckets()) {
        my $prob = get_value_( $self, $bucket, $word );

        if ( $prob != 0 )  {
            if ( $prob > $max )  {
                $max   = $prob;
                $color = $self->get_bucket_parameter( $bucket, 'color' );
            }
        }
    }

    return $color;
}

# ---------------------------------------------------------------------------------------------
#
# get_value_
#
# Returns the value for a specific word in a bucket.  The word is converted to the log value
# of the probability before return to get the raw value just hit the hash directly or call
# get_base_value_
#
# ---------------------------------------------------------------------------------------------
sub get_value_
{
    my ( $self, $bucket, $word ) = @_;

    my $value = $self->db_get_word_count__( $bucket, $word );

    if ( defined( $value ) && ( $value > 0 ) ) {

        # Profiling notes:
        #
        # I tried caching the log of the total value and then doing
        # log( $value ) - $cached and this turned out to be
        # much slower than this single log with a division in it

        return log( $value / $self->get_bucket_word_count( $bucket ) );
    } else {
        return 0;
    }
}

sub get_base_value_
{
    my ( $self, $bucket, $word ) = @_;

    my $value = $self->db_get_word_count__( $bucket, $word );

    if ( defined( $value ) ) {
        return $value;
    } else {
        return 0;
    }
}

# ---------------------------------------------------------------------------------------------
#
# set_value_
#
# Sets the value for a word in a bucket and updates the total word counts for the bucket
# and globally
#
# ---------------------------------------------------------------------------------------------
sub set_value_
{
    my ( $self, $bucket, $word, $value ) = @_;

    $self->db_put_word_count__( $bucket, $word, $value );
}

# ---------------------------------------------------------------------------------------------
#
# get_sort_value_ behaves the same as get_value_, except that it returns not_likely__ rather
# than 0 if the word is not found.  This makes its result more suitable as a sort key for bucket
# ranking.
#
# ---------------------------------------------------------------------------------------------
sub get_sort_value_
{
    my ( $self, $bucket, $word ) = @_;

    my $v = $self->get_value_( $bucket, $word );

    if ( $v == 0 ) {
        return $self->{not_likely__};
    } else {
        return $v;
    }
}

# ---------------------------------------------------------------------------------------------
#
# update_constants__
#
# Updates not_likely and bucket_start
#
# ---------------------------------------------------------------------------------------------
sub update_constants__
{
    my ($self) = @_;

    my $wc = $self->get_word_count();

    if ( $wc > 0 )  {
        $self->{not_likely__} = -log( 10 * $wc );

        foreach my $bucket ($self->get_buckets()) {
            my $total = $self->get_bucket_word_count( $bucket );

            if ( $total != 0 ) {
                $self->{bucket_start__}{$bucket} = log( $total / $wc );
            } else {
                $self->{bucket_start__}{$bucket} = 0;
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# parse_with_kakasi__
#
# Parse Japanese mail message with Kakasi
#
# Japanese needs to be parsed by language processing filter, "Kakasi"
# before it is passed to Bayes classifier because words are not splitted
# by spaces.
#
# $file           The file to parse
#
# ---------------------------------------------------------------------------------------------
sub parse_with_kakasi__
{
    my ( $self, $file, $dcount, $mcount ) = @_;

    # This is used for Japanese support
    require Encode;

    # This is used to parse Japanese
    require Text::Kakasi;

    my $temp_file  = $self->global_config_( 'msgdir' ) . "kakasi$dcount" . "=$mcount.msg";

    # Split Japanese email body into words using Kakasi Wakachigaki
    # mode(-w is passed to Kakasi as argument). The most common charset of
    # Japanese email is ISO-2022-JP, alias is jis, so -ijis and -ojis
    # are passed to tell Kakasi the input charset and the output charset
    # explicitly.
    #
    # After Kakasi processing, Encode::from_to is used to convert into UTF-8.
    #
    # Japanese email charset is assumed to be ISO-2022-JP. Needs to expand for
    # other possible charset, such as Shift_JIS, EUC-JP, UTF-8.

    Text::Kakasi::getopt_argv("kakasi", "-w -ijis -ojis");
    open KAKASI_IN, "<$file";
    open KAKASI_OUT, ">$temp_file";

    while( <KAKASI_IN> ){
        my $kakasi_out;

	$kakasi_out = Text::Kakasi::do_kakasi($_);
        Encode::from_to($kakasi_out, "iso-2022-jp", "euc-jp");
        print KAKASI_OUT $kakasi_out;
    }

    close KAKASI_OUT;
    close KAKASI_IN;
    Text::Kakasi::close_kanwadict();
    unlink( $file );
    rename( $temp_file, $file );
}

# ---------------------------------------------------------------------------------------------
#
# db_connect__
#
# Connects to the POPFile database and returns 1 if successful
#
# ---------------------------------------------------------------------------------------------
sub db_connect__
{
    my ( $self ) = @_;

    # Connect to the database, note that the database must exist for this to work,
    # to make this easy for people POPFile we will create the database automatically
    # here using the file 'popfile.sql' which should be located in the same directory
    # the Classifier/Bayes.pm module

    my $dbname = $self->get_user_path_( $self->config_( 'database' ) );
    my $dbpresent = ( -e $dbname ) || 0;

    # Now perform the connect, note that this is database independent at this point, the
    # actual database that we connect to is defined by the dbconnect parameter.

    my $dbconnect = $self->config_( 'dbconnect' );
    $dbconnect =~ s/\$dbname/$dbname/g;

    $self->log_( "Attempting to connect to $dbconnect ($dbpresent)" );

    $self->{db__} = DBI->connect( $dbconnect,
                                  $self->config_( 'dbuser' ),
                                  $self->config_( 'dbauth' ) );

    if ( !defined( $self->{db__} ) ) {
        $self->log_( "Failed to connect to database and got error $DBI::errstr" );
        return 0;
    }

    if ( !$dbpresent ) {
        if ( -e $self->get_root_path_( 'Classifier/popfile.sql' ) ) {
            my $schema = '';

            $self->log_( "Creating database schema" );

            open SCHEMA, '<' . $self->get_root_path_( 'Classifier/popfile.sql' );
            while ( <SCHEMA> ) {
                next if ( /^--/ );
                next if ( !/[a-z;]/ );
                s/--.*$//;

                $schema .= $_;

                if ( ( /end;/ ) || ( /\);/ ) ) {
                    $self->log_( "Performing SQL command: $schema" );
                    $self->{db__}->do( $schema );
                    $schema = '';
		}
	    }
            close SCHEMA;
	} else {
            $self->log_( "Can't find the database schema" );
            return 0;
	}
    }

    # Now prepare common SQL statements for use, as a matter of convention the
    # parameters to each statement always appear in the following order:
    #
    # user
    # bucket
    # word
    # parameter

    $self->{db_get_buckets__} = $self->{db__}->prepare(
   	     'select name, id, pseudo from buckets
                  where buckets.userid = ?;' );

    $self->{db_get_wordid__} = $self->{db__}->prepare(
	     'select id from words
                  where words.word = ? limit 1;' );

    $self->{db_get_userid__} = $self->{db__}->prepare(
             'select id from users where name = ?
                                     and password = ? limit 1;' );

    $self->{db_get_word_count__} = $self->{db__}->prepare(
	     'select matrix.times from matrix
                  where matrix.bucketid = ? and
                        matrix.wordid = ? limit 1;' );

    $self->{db_put_word_count__} = $self->{db__}->prepare(
	   'insert or replace into matrix ( bucketid, wordid, times ) values ( ?, ?, ? );' );

    $self->{db_get_bucket_unique_count__} = $self->{db__}->prepare(
	     'select count(*) from matrix
                  where matrix.bucketid = ?;' );

    $self->{db_get_bucket_word_count__} = $self->{db__}->prepare(
	     'select sum(matrix.times) from matrix
                  where matrix.bucketid = ?;' );

    $self->{db_get_unique_word_count__} = $self->{db__}->prepare(
	     'select count(matrix.wordid) from matrix, buckets
                  where matrix.bucketid = buckets.id and
                        buckets.userid = ?;' );

    $self->{db_get_full_total__} = $self->{db__}->prepare(
	     'select sum(matrix.times) from matrix, buckets
                  where buckets.userid = ? and
                        matrix.bucketid = buckets.id;' );

    $self->{db_get_bucket_parameter__} = $self->{db__}->prepare(
             'select bucket_params.val from bucket_params
                  where bucket_params.bucketid = ? and
                        bucket_params.btid = ?;' );

    $self->{db_set_bucket_parameter__} = $self->{db__}->prepare(
	   'insert or replace into bucket_params ( bucketid, btid, val ) values ( ?, ?, ? );' );

    $self->{db_get_bucket_parameter_default__} = $self->{db__}->prepare(
             'select bucket_template.def from bucket_template
                  where bucket_template.id = ?;' );
    $self->{db_get_buckets_with_magnets__} = $self->{db__}->prepare(
             'select buckets.name from buckets, magnets
                  where buckets.userid = ? and
                        magnets.bucketid = buckets.id group by buckets.name order by buckets.name;' );

    # Get the mapping from parameter names to ids into a local hash

    my $h = $self->{db__}->prepare( "select name, id from bucket_template;" );
    $h->execute;
    while ( my $row = $h->fetchrow_arrayref ) {
        $self->{db_parameterid__}{$row->[0]} = $row->[1];
    }
    $h->finish;

    $self->db_update_cache__();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# db_disconnect__
#
# Disconnect from the POPFile database
#
# ---------------------------------------------------------------------------------------------
sub db_disconnect__
{
    my ( $self ) = @_;

    $self->{db_get_buckets__}->finish;
    $self->{db_get_wordid__}->finish;
    $self->{db_get_userid__}->finish;
    $self->{db_get_word_count__}->finish;
    $self->{db_put_word_count__}->finish;
    $self->{db_get_bucket_unique_count__}->finish;
    $self->{db_get_bucket_word_count__}->finish;
    $self->{db_get_unique_word_count__}->finish;
    $self->{db_get_full_total__}->finish;
    $self->{db_get_bucket_parameter__}->finish;
    $self->{db_set_bucket_parameter__}->finish;
    $self->{db_get_bucket_parameter_default__}->finish;
    $self->{db_get_buckets_with_magnets__}->finish;

    if ( defined( $self->{db__} ) ) {
        $self->{db__}->disconnect;
        undef $self->{db__};
    }
}

# ---------------------------------------------------------------------------------------------
#
# db_update_cache__
#
# Updates our local cache of user and bucket ids.
#
# ---------------------------------------------------------------------------------------------
sub db_update_cache__
{
    my ( $self ) = @_;

    $self->{db_userid__} = $self->db_get_user_id__( 'admin' );

    delete $self->{db_bucketid__};
    $self->{db_get_buckets__}->execute( $self->{db_userid__} );
    while ( my $row = $self->{db_get_buckets__}->fetchrow_arrayref ) {
        $self->{db_bucketid__}{$row->[0]}{id} = $row->[1];
        $self->{db_bucketid__}{$row->[0]}{pseudo} = $row->[2];
    }

    for my $bucket (keys %{$self->{db_bucketid__}}) {
        $self->{db_get_bucket_word_count__}->execute( $self->{db_bucketid__}{$bucket}{id} );
        my $row = $self->{db_get_bucket_word_count__}->fetchrow_arrayref;
        $self->{db_bucketcount__}{$bucket} = $row->[0];
    }

    $self->update_constants__();
}

# ---------------------------------------------------------------------------------------------
#
# db_get_user_id__
#
# Returns the unique ID for a named user
#
# $name         Name of user to look up
#
# ---------------------------------------------------------------------------------------------
sub db_get_user_id__
{
    my ( $self, $name ) = @_;

    my $result = $self->{db__}->selectrow_arrayref( "select users.id from users where
                                                         users.name = '$name';" );

    return $result->[0];
}

# ---------------------------------------------------------------------------------------------
#
# db_get_word_count__
#
# Return the 'count' value for a word in a bucket.  If the word is not found in that
# bucket then returns undef.
#
# $bucket           bucket word is in
# $word             word to lookup
#
# ---------------------------------------------------------------------------------------------
sub db_get_word_count__
{
    my ( $self, $bucket, $word ) = @_;

    $self->{db_get_wordid__}->execute( $word );
    my $result = $self->{db_get_wordid__}->fetchrow_arrayref;
    if ( !defined( $result ) ) {
        return undef;
    }

    my $wordid = $result->[0];

    $self->{db_get_word_count__}->execute( $self->{db_bucketid__}{$bucket}{id}, $wordid );
    $result = $self->{db_get_word_count__}->fetchrow_arrayref;
    if ( defined( $result ) ) {
         return $result->[0];
    } else {
         return undef;
    }
}

# ---------------------------------------------------------------------------------------------
#
# db_put_word_count__
#
# Update 'count' value for a word in a bucket, if the update fails then returns 0
# otherwise is returns 1
#
# $bucket           bucket word is in
# $word             word to update
# $count            new count value
#
# ---------------------------------------------------------------------------------------------
sub db_put_word_count__
{
    my ( $self, $bucket, $word, $count ) = @_;

    # We need to have two things before we can start, the id of the word in the words
    # table (if there's none then we need to add the word), the bucket id in the buckets
    # table (which must exist)

    $word = $self->{db__}->quote($word);

    my $result = $self->{db__}->selectrow_arrayref("select words.id from words
                                                        where words.word = $word limit 1;");

    if ( !defined( $result ) ) {
        $self->{db__}->do( "insert into words ( word ) values ( $word );" );
        $result = $self->{db__}->selectrow_arrayref("select words.id from words
                                                         where words.word = $word limit 1;");
    }

    my $wordid = $result->[0];
    my $bucketid = $self->{db_bucketid__}{$bucket}{id};

    $self->{db_put_word_count__}->execute( $bucketid, $wordid, $count );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# db_delete_word__
#
# Delete a word from the database from a specific bucket, returns 1 if successful and 0
# otherwise
#
# $bucket           bucket word is in
# $word             word to delete
#
# ---------------------------------------------------------------------------------------------
sub db_delete_word__
{
    my ( $self, $bucket, $word ) = @_;

    $word = $self->{db__}->quote($word);

    return defined( $self->{db__}->do(
        "delete from corpus where bucket = '$bucket' and word = $word ;" ) );
}

# ---------------------------------------------------------------------------------------------
#
# upgrade_predatabase_data__
#
# Looks for old POPFile data (in flat files or BerkeleyDB tables) and upgrades it to the
# SQL database.   Data upgraded is removed.
#
# ---------------------------------------------------------------------------------------------
sub upgrade_predatabase_data__
{
    my ( $self ) = @_;
    my $c      = 0;

    my @buckets = glob $self->get_user_path_( $self->config_( 'corpus' ) . '/*' );

    foreach my $bucket (@buckets) {

        # A bucket directory must be lowercase

        next if ( lc($bucket) ne $bucket );

        # A bucket directory must be a directory

        next unless ( -d $bucket );
        next unless ( ( -e "$bucket/table" ) || ( -e "$bucket/table.db" ) );

        return 0 if ( !$self->upgrade_bucket__( $bucket ) );

        my $color = '';

        # See if there's a color file specified
        if ( open COLOR, '<' . "$bucket/color" ) {
            $color = <COLOR>;

            # Someone (who shall remain nameless) went in and manually created
            # empty color files in their corpus directories which would cause
            # $color at this point to be undefined and hence you'd get warnings
            # about undefined variables below.  So this little test is to deal
            # with that user and to make POPFile a little safer which is always
            # a good thing

            if ( !defined( $color ) ) {
                $color = '';
            } else {
                $color =~ s/[\r\n]//g;
            }
            close COLOR;
            unlink "$bucket/color";
        }

        $bucket =~ /([[:alpha:]0-9-_]+)$/;
        $bucket =  $1;

        $self->set_bucket_color( $bucket, ($color eq '')?$self->{possible_colors__}[$c]:$color );

        $c = ($c+1) % ($#{$self->{possible_colors__}}+1);
    }

    $self->db_update_cache__();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# upgrade_bucket__
#
# Loads an individual bucket
#
# $bucket            The bucket name
#
# ---------------------------------------------------------------------------------------------
sub upgrade_bucket__
{
    my ( $self, $bucket ) = @_;

    $bucket =~ /([[:alpha:]0-9-_]+)$/;
    $bucket =  $1;

    $self->create_bucket( $bucket );

    $self->set_bucket_parameter( $bucket, 'subject',    1 );
    $self->set_bucket_parameter( $bucket, 'count',      0 );
    $self->set_bucket_parameter( $bucket, 'quarantine', 0 );

    if ( open PARAMS, '<' . $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/params" ) ) {
        while ( <PARAMS> )  {
            s/[\r\n]//g;
            if ( /^([[:lower:]]+) ([^\r\n\t ]+)$/ )  {
                $self->set_bucket_parameter( $bucket, $1, $2 );
            }
        }
        close PARAMS;
        unlink $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/params" );
    }

    # See if there are magnets defined
    if ( open MAGNETS, '<' . $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/magnets" ) ) {
        while ( <MAGNETS> )  {
            s/[\r\n]//g;

            # Because of a bug in v0.17.9 and earlier of POPFile the text of
            # some magnets was getting mangled by certain characters having
            # a \ prepended.  Code here removes the \ in these cases to make
            # an upgrade smooth.

            if ( /^([^ ]+) (.+)$/ )  {
                my $type  = $1;
                my $value = $2;

                # Some people were accidently creating magnets with trailing whitespace
                # which really confused them later when their magnet did not match (see
                # comment in UI::HTML::magnet for more detail)

                $value =~ s/^[ \t]+//g;
                $value =~ s/[ \t]+$//g;

                $value =~ s/\\(\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/$1/g;
                $self->create_magnet( $bucket, $type, $value );
            } else {

                # This branch is used to catch the original magnets in an
                # old version of POPFile that were just there for from
                # addresses only

                if ( /^(.+)$/ ) {
                    my $value = $1;
                    $value =~ s/\\(\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/$1/g;
                    $self->create_magnet( $bucket, 'from', $value );
                }
            }
        }
        close MAGNETS;
        unlink $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/magnets" );
    }

    # If there is no existing table but there is a table file (the old style
    # flat file used by POPFile for corpus storage) then create the new
    # database from it thus performing an automatic upgrade.

    if ( -e $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/table" ) ) {
        $self->log_( "Performing automatic upgrade of $bucket corpus from flat file to DBI" );

        $self->{db__}->begin_work;

        if ( open WORDS, '<' . $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/table" ) )  {

            my $wc = 1;

            my $first = <WORDS>;
            if ( defined( $first ) && ( $first =~ s/^__CORPUS__ __VERSION__ (\d+)// ) ) {
                if ( $1 != $self->{corpus_version__} )  {
                    print STDERR "Incompatible corpus version in $bucket\n";
                    close WORDS;
                    $self->{db__}->rollback;
                    return 0;
                } else {
   	            $self->log_( "Upgrading bucket $bucket..." );

                    while ( <WORDS> ) {
		        if ( $wc % 100 == 0 ) {
                            $self->log_( "$wc" );
		        }
                        $wc += 1;
                        s/[\r\n]//g;

                        if ( /^([^\s]+) (\d+)$/ ) {
  			    if ( $2 != 0 ) {
                                $self->set_value_( $bucket, $1, $2 );
			    }
                        } else {
                            $self->log_( "Found entry in corpus for $bucket that looks wrong: \"$_\" (ignoring)" );
                        }
		    }
                }

                if ( $wc > 1 ) {
                    $self->log_( "(completed ", $wc-1, " words)" );
		}
                close WORDS;
            } else {
                close WORDS;
                $self->{db__}->rollback;
                return 0;
	    }

            $self->{db__}->commit;
            unlink $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/table" );
	}
    }

    # Now check to see if there's a BerkeleyDB-style table

    my $bdb_file = $self->get_user_path_( $self->config_( 'corpus' ) . "/$bucket/table.db" );

    if ( -e $bdb_file ) {
        $self->log_( "Performing automatic upgrade of $bucket corpus from BerkeleyDB to DBI" );

        require BerkeleyDB;

        my %h;
        tie %h, "BerkeleyDB::Hash", -Filename => $bdb_file;

        $self->log_( "Upgrading bucket $bucket..." );
        $self->{db__}->begin_work;

        my $wc = 1;

        for my $word (keys %h) {
	    if ( $wc % 100 == 0 ) {
                $self->log_( "$wc" );
            }

            next if ( $word =~ /^__POPFILE__(LOG__TOTAL|TOTAL|USER)__$/ );

	    $wc += 1;
            $self->set_value_( $bucket, $word, $h{$word} );
	}

        $self->log_( "(completed ", $wc-1, " words)" );
        $self->{db__}->commit;
        untie %h;
        unlink $bdb_file;
    }

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# magnet_match_helper__
#
# Helper the determines if a specific string matches a certain magnet type in a bucket, used
# by magnet_match_
#
# $match           The string to match
# $bucket          The bucket to check
# $type            The magnet type to check
#
# ---------------------------------------------------------------------------------------------
sub magnet_match_helper__
{
    my ( $self, $match, $bucket, $type ) = @_;

    $match = lc($match);

    # In Japanese and Korean mode, disable locale.
    # Sorting Japanese and Korean with "use locale" is memory and time consuming,
    # and may cause perl crash.

    my @magnets;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};
    my $h = $self->{db__}->prepare(
        "select magnets.val from magnets, users, buckets, magnet_types
             where buckets.id = $bucketid and
                   users.id = buckets.userid and
                   magnets.bucketid = buckets.id and
                   magnet_types.mtype = '$type' and
                   magnets.mtid = magnet_types.id order by magnets.val;" );

    $h->execute;
    while ( my $row = $h->fetchrow_arrayref ) {
        push @magnets, ($row->[0]);
    }
    $h->finish;

    for my $magnet (@magnets) {
        $magnet = lc($magnet);

        for my $i (0..(length($match)-length($magnet))) {
            if ( substr( $match, $i, length($magnet)) eq $magnet ) {
                $self->{scores__}        = '';
                $self->{magnet_used__}   = 1;
                $self->{magnet_detail__} = "$type: $magnet";

                return 1;
            }
        }
    }

    return 0;
}

# ---------------------------------------------------------------------------------------------
#
# magnet_match__
#
# Helper the determines if a specific string matches a certain magnet type in a bucket
#
# $match           The string to match
# $bucket          The bucket to check
# $type            The magnet type to check
#
# ---------------------------------------------------------------------------------------------
sub magnet_match__
{
    my ( $self, $match, $bucket, $type ) = @_;

    return $self->magnet_match_helper__( $match, $bucket, $type );
}

# ---------------------------------------------------------------------------------------------
#
# write_line__
#
# Writes a line to a file and parses it unless the classification is already known
#
# $file         File handle for file to write line to
# $line         The line to write
# $class        (optional) The current classification
#
# ---------------------------------------------------------------------------------------------
sub write_line__
{
    my ( $self, $file, $line, $class ) = @_;

    print $file $line if defined( $file );

    if ( $class eq '' ) {
        $self->{parser__}->parse_line( $line );
    }
}

# ---------------------------------------------------------------------------------------------
#
# add_words_to_bucket
#
# Takes words previously parsed by the mail parser and adds/subtracts them to/from a bucket,
# this is a helper used by add_messages_to_bucket, remove_message_from_bucket
#
# $bucket         Bucket to add to
# $subtract       Set to -1 means subtract the words, set to 1 means add
#
# ---------------------------------------------------------------------------------------------
sub add_words_to_bucket__
{
    my ( $self, $bucket, $subtract ) = @_;

    foreach my $word (keys %{$self->{parser__}->{words__}}) {
        $self->set_value_( $bucket, $word, $subtract * $self->{parser__}->{words__}{$word} + # PROFILE BLOCK START
            $self->get_base_value_( $bucket, $word ) );                                      # PROFILE BLOCK STOP
    }
}

# ---------------------------------------------------------------------------------------------
#
# echo_to_dot_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   (optional) The local mail client (created with IO::) that needs the response
# $file     (optional) A file to print the response to, caller specifies open style
# $before   (optional) String to send to client before the dot is sent
#
# echo all information from the $mail server until a single line with a . is seen
#
# NOTE Also echoes the line with . to $client but not to $file
#
# Returns 1 if there was a . or 0 if reached EOF before we hit the .
#
# ---------------------------------------------------------------------------------------------
sub echo_to_dot_
{
    my ( $self, $mail, $client, $file, $before ) = @_;

    my $hit_dot = 0;

    my $isopen = open FILE, "$file" if ( defined( $file ) );
    binmode FILE if ($isopen);

    while ( my $line = $self->slurp_( $mail ) ) {

        # Check for an abort

        last if ( $self->{alive_} == 0 );

        # The termination has to be a single line with exactly a dot on it and nothing
        # else other than line termination characters.  This is vital so that we do
        # not mistake a line beginning with . as the end of the block

        if ( $line =~ /^\.(\r\n|\r|\n)$/ ) {
            $hit_dot = 1;

            if ( defined( $before ) && ( $before ne '' ) ) {
                print $client $before if ( defined( $client ) );
                print FILE    $before if ( defined( $isopen ) );
            }

            # Note that there is no print FILE here.  This is correct because we
            # do no want the network terminator . to appear in the file version
            # of any message

            print $client $line if ( defined( $client ) );
            last;
        }

        print $client $line if ( defined( $client ) );
        print FILE    $line if ( defined( $isopen ) );

    }

    close FILE if ( $isopen );

    return $hit_dot;
}

# ---------------------------------------------------------------------------------------------
#
# substr_euc__
#
# "substr" function which supports EUC Japanese charset
#
# $pos      Start position
# $len      Word length
#
# ---------------------------------------------------------------------------------------------
sub substr_euc__
{
    my ( $str, $pos, $len ) = @_;
    my $result_str;
    my $char;
    my $count = 0;
    if ( !$pos ) {
        $pos = 0;
    }
    if ( !$len ) {
        $len = length( $str );
    }

    for ( $pos = 0; $count < $len; $pos++ ) {
        $char = substr( $str, $pos, 1 );
        if ( $char =~ /[\x80-\xff]/ ) {
            $char = substr( $str, $pos++, 2 );
        }
        $result_str .= $char;
        $count++;
    }

    return $result_str;
}

# ---------------------------------------------------------------------------------------------
#
# generate_unique_session_key__
#
# Returns a unique string based session key that can be used as a key in the api_sessions__
#
# ---------------------------------------------------------------------------------------------
sub generate_unique_session_key__
{
    my ( $self ) = @_;

    my @chars = ( 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',   # PROFILE BLOCK START
                  'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'U', 'V', 'W', 'X', 'Y',
                  'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A' ); # PROFILE BLOCK STOP

    my $session;

    do {
        $session = '';
        my $length = int( 16 + rand(4) );

        for my $i (0 .. $length) {
            my $random = $chars[int( rand(36) )];

            # Just to add spice to things we sometimes lowercase the value

            if ( rand(1) < rand(1) ) {
                $random = lc($random);
            }

            $session .= $random;
        }
    } while ( defined( $self->{api_sessions__}{$session} ) );

    return $session;
}

# ---------------------------------------------------------------------------------------------
#
# valid_session_key__
#
# $session                Session key returned by call to get_session_key
#
# Returns undef is the session key is not valid, or returns the user ID associated
# with the session key which can be used in database accesses
#
# ---------------------------------------------------------------------------------------------
sub valid_session_key__
{
    my ( $self, $session ) = @_;

    # This provides protection against someone using the XML-RPC interface and calling
    # this API directly to fish for session keys, this must be called from within this
    # module

    return undef if ( caller ne 'Classifier::Bayes' );

    # If the session key is invalid then wait 1 second.  This is done to prevent
    # people from calling a POPFile API such as get_bucket_count with random session
    # keys fishing for a valid key.  The XML-RPC API is single threaded and hence this
    # will delay all use of that API by one second.  Of course in normal use when the
    # user knows the username/password or session key then there is no delay

    if ( !defined( $self->{api_session__}{$session} ) ) {
        $self->log_( "Invalid session key $session provided" );
        select( undef, undef, undef, 1 );
    }

    return $self->{api_sessions__}{$session};
}

# ---------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
#       _____   _____   _____  _______ _____        _______     _______  _____  _____
#      |_____] |     | |_____] |______   |   |      |______     |_____| |_____]   |
#      |       |_____| |       |       __|__ |_____ |______     |     | |       __|__
#
# The method below are public and may be accessed by other modules.  All of them may be
# accessed remotely through the XMLRPC.pm module using the XML-RPC protocol
#
# Note that every API function expects to be passed a $session which is obtained by first
# calling get_session_key with a valid username and password.   Once done call the method
# release_session_key.
#
# ---------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------
#
# get_session_key
#
# $user           The name of an existing user
# $pwd            The user's password
#
# Returns a string based session key if the username and password match, or undef if not
#
# ---------------------------------------------------------------------------------------------
sub get_session_key
{
    my ( $self, $user, $pwd ) = @_;

    # The password is stored in the database as an MD5 hash of the username and
    # password concatenated and separated by the string __popfile__, so compute
    # the hash here

    my $hash = md5_hex( $user . '__popfile__' . $pwd );

    $self->{db_get_userid__}->execute( $user, $hash );
    my $result = $self->{db_get_userid__}->fetchrow_arrayref;
    if ( !defined( $result ) ) {

        # The delay of one second here is to prevent people from trying out
        # username/password combinations at high speed to determine the
        # credentials of a valid user

        $self->log_( "Attempt to login with incorrect credentials for user $user" );
        select( undef, undef, undef, 1 );
        return undef;
    }

    my $session = $self->generate_unique_session_key__();

    $self->{api_sessions__}{$session} = $result->[0];

    return $session;
}

# ---------------------------------------------------------------------------------------------
#
# release_session_key
#
# $session        A session key previously returned by get_session_key
#
# Releases and invalidates the session key
#
# ---------------------------------------------------------------------------------------------
sub release_session_key
{
    my ( $self, $session ) = @_;

    if ( defined( $self->{api_sessions__}{$session} ) ) {
        delete $self->{api_sessions__}{$session};
    }
}

# ---------------------------------------------------------------------------------------------
#
# classify
#
# $file      The name of the file containing the text to classify (or undef to use
#            the data already in the parser)
# $ui        Reference to the UI used when doing colorization
#
# Splits the mail message into valid words, then runs the Bayes algorithm to figure out
# which bucket it belongs in.  Returns the bucket name
#
# ---------------------------------------------------------------------------------------------
sub classify
{
    my ( $self, $file, $ui ) = @_;
    my $msg_total = 0;

    $self->log_( "Begin classification at " . time );

    $self->{unclassified__} = log( $self->config_( 'unclassified_weight' ) );

    # Pass language parameter to parse_file()

    $self->{magnet_used__}   = 0;
    $self->{magnet_detail__} = '';

    if ( defined( $file ) ) {
        $self->{parser__}->parse_file( $file,
                                       $self->module_config_( 'html', 'language' ),
                                       $self->global_config_( 'message_cutoff'   ) );
    }

    # Check to see if this email should be classified based on a magnet
    # Get the list of buckets

    my @buckets = $self->get_buckets();

    for my $bucket ($self->get_buckets_with_magnets())  {
        for my $type ($self->get_magnet_types_in_bucket( $bucket )) {
	    if ( $self->magnet_match__( $self->{parser__}->get_header($type), $bucket, $type ) ) {
                return $bucket;
            }
        }
    }

    # If the user has not defined any buckets then we escape here return unclassified
    return "unclassified" if ( $#buckets == -1 );

    $self->log_( "Done with bucket check at " . time );

    # The score hash will contain the likelihood that the given message is in each
    # bucket, the buckets are the keys for score

    # Set up the initial score as P(bucket)

    my %score;
    my %matchcount;

    for my $bucket (@buckets) {
        $score{$bucket} = $self->{bucket_start__}{$bucket};
        $matchcount{$bucket} = 0;
    }

    # For each word go through the buckets and calculate P(word|bucket) and then calculate
    # P(word|bucket) ^ word count and multiply to the score

    my $word_count = 0;

    # The correction value is used to generate score displays in the scores__
    # variable which are consistent with the word scores shown by the GUI's
    # word lookup feature.  It is computed to make the contribution of a word
    # which is unrepresented in a bucket zero.  This correction affects only
    # the values displayed in scores__; it has no effect on the classification
    # process.

    my $correction = 0;

    foreach my $word (keys %{$self->{parser__}->{words__}}) {
        $word_count += 2;
        my $wmax = -10000;

        foreach my $bucket (@buckets) {
            my $probability = $self->get_value_( $bucket, $word );

            $matchcount{$bucket} += $self->{parser__}{words__}{$word} if ($probability != 0);
            $probability = $self->{not_likely__} if ( $probability == 0 );
            $wmax = $probability if ( $wmax < $probability );

            # Here we are doing the bayes calculation: P(word|bucket) is in probability
            # and we multiply by the number of times that the word occurs

            $score{$bucket} += ( $probability * $self->{parser__}{words__}{$word} );
        }

        if ($wmax > $self->{not_likely__}) {
            $correction += $self->{not_likely__} * $self->{parser__}{words__}{$word};
        } else {
            $correction += $wmax * $self->{parser__}{words__}{$word};
        }
    }

    $self->log_( "Done with Bayes rule at " . time );

    # Now sort the scores to find the highest and return that bucket as the classification

    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;

    my %raw_score;
    my $base_score = $score{$ranking[0]};
    my $total = 0;

    # If the first and second bucket are too close in their probabilities, call the message
    # unclassified.  Also if there are fewer than 2 buckets.
    my $class = 'unclassified';

    if ( @buckets > 1 && $score{$ranking[0]} > ( $score{$ranking[1]} + $self->{unclassified__} ) ) {
        $class = $ranking[0];
    }

    # Compute the total of all the scores to generate the normalized scores and probability
    # estimate.  $total is always 1 after the first loop iteration, so any additional term
    # less than 2 ** -54 is insignificant, and need not be computed.

    my $ln2p_54 = -54 * log(2);

    foreach my $b (@ranking) {
        $raw_score{$b} = $score{$b};
        $score{$b} -= $base_score;

        $total += exp($score{$b}) if ($score{$b} > $ln2p_54 );
    }

    if ($self->{wordscores__} && defined($ui) ) {
        my %qm = %{$self->{parser__}->quickmagnets()};
        my $mlen = scalar(keys %{$self->{parser__}->quickmagnets()});
        my %language    = $ui->language();
        my $session_key = $ui->session_key();

        if ( $mlen >= 0 ) {
            my @buckets = $self->get_buckets();
            my $i = 0;
            $self->{scores__} .= "<form action=\"/magnets\" method=\"get\">\n";
            $self->{scores__} .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />";
            $self->{scores__} .= "<input type=\"hidden\" name=\"count\" value=\"" . ($mlen + 1) . "\" />";
            $self->{scores__} .= "<hr><b>$language{QuickMagnets}</b><p>\n<table class=\"top20Words\">\n<tr>\n<th scope=\"col\">$language{Magnet}</th>\n<th>$language{Magnet_Always}</th>\n";

            my %types = $self->get_magnet_types();

            foreach my $type ( keys %types ) {

                if (defined $qm{$type}) {
                    $i += 1;

                    $self->{scores__} .= "<tr><td scope=\"col\">$type: ";
                    $self->{scores__} .= "<select name=\"text$i\" id=\"\">\n";

                    foreach my $magnet ( @{$qm{$type}} ) {
                        $self->{scores__} .= "<option value=\"$magnet\">$magnet</option>\n";
                    }
                    $self->{scores__} .= "</select>\n";
                    $self->{scores__} .= "</td><td>";
                    $self->{scores__} .= "<input type=\"hidden\" name=\"type$i\" id=\"magnetsAddType\" value=\"$type\"/>";
                    $self->{scores__} .= "<select name=\"bucket$i\" id=\"magnetsAddBucket\">\n<option value=\"\"></option>\n";

                    foreach my $bucket (@buckets) {
                        $self->{scores__} .= "<option value=\"$bucket\">$bucket</option>\n";
                    }

                    $self->{scores__} .= "</select></td></tr>";
                }
            }

            $self->{scores__} .= "<tr><td></td><td><input type=\"submit\" class=\"submit\" name=\"create\" value=\"$language{Create}\" /></td></tr></table></form>";
        }

        $self->{scores__} .= "<a name=\"scores\">";
        $self->{scores__} .= "<hr><b>$language{Scores}</b><p>\n";

        $self->{scores__} .= "<table class=\"top20Words\">\n<tr>\n<th scope=\"col\">$language{Bucket}</th>\n<th>&nbsp;</th>\n";
        if ($self->{wmformat__} eq 'score') {
            $self->{scores__} .= "<th scope=\"col\">$language{Count}&nbsp;&nbsp;</th><th scope=\"col\" align=\"center\">$language{Score}</th><th scope=\"col\">$language{Probability}</th></tr>\n";
        } else {
            $self->{scores__} .= "<th scope=\"col\">$language{Count}&nbsp;&nbsp;</th><th scope=\"col\">$language{Probability}</th></tr>\n";
        }

        my $log10 = log(10.0);

        foreach my $b (@ranking) {
             my $prob = exp($score{$b})/$total;
             my $probstr;
             my $rawstr;

             # If the computed probability would display as 1, display it as .999999 instead.
             # We don't want to give the impression that POPFile is ever completely sure of its
             # classification.

             if ($prob >= .999999) {
                 $probstr = sprintf("%12.6f", 0.999999);
             } else {
                 if ($prob >= 0.1 || $prob == 0.0) {
                     $probstr = sprintf("%12.6f", $prob);
                 } else {
                    $probstr = sprintf("%17.6e", $prob);
                 }
             }

             my $color = $self->get_bucket_color( $b );

             if ($self->{wmformat__} eq 'score') {
                $rawstr = sprintf("%12.6f", ($raw_score{$b} - $correction)/$log10);
                $self->{scores__} .= "<tr>\n<td><font color=\"$color\"><b>$b</b></font></td>\n<td>&nbsp;</td>\n<td align=\"right\">$matchcount{$b}&nbsp;&nbsp;&nbsp;&nbsp;</td>\n<td align=right>$rawstr&nbsp;&nbsp;&nbsp;</td>\n<td>$probstr</td>\n</tr>\n";
             } else {
                $self->{scores__} .= "<tr>\n<td><font color=\"$color\"><b>$b</b></font></td>\n<td>&nbsp;</td>\n<td align=\"right\">$matchcount{$b}&nbsp;&nbsp;&nbsp;&nbsp;</td>\n<td>$probstr</td>\n</tr>\n";
             }
        }

        $self->{scores__} .= "</table><hr>";

        # We want a link to change the format here.  But only the UI knows how to build
        # that link.  So we just insert a comment which can be replaced by the UI.  There's
        # probably a better way.

        $self->{scores__} .= "<!--format--><p>";
        if ( $self->{wmformat__} ne '' ) {
            $self->{scores__} .= "<table class=\"top20Words\">\n";
            $self->{scores__} .= "<tr>\n<th scope=\"col\">$language{Word}</th><th>&nbsp;</th><th scope=\"col\">$language{Count}</th><th>&nbsp;</th>\n";

            foreach my $ix (0..($#buckets > 7? 7: $#buckets)) {
                my $bucket = $ranking[$ix];
                my $bucketcolor  = $self->get_bucket_color( $bucket );
                $self->{scores__} .= "<th><font color=\"$bucketcolor\">$bucket</font></th><th>&nbsp;</th>";
            }

            $self->{scores__} .= "</tr>";

            my %wordprobs;

            # If the word matrix is supposed to show probabilities, compute them,
            # saving the results in %wordprobs.

            if ( $self->{wmformat__} eq 'prob') {
                foreach my $word (keys %{$self->{parser__}->{words__}}) {
                    my $sumfreq = 0;
                    my %wval;
                    foreach my $bucket (@ranking) {
                        $wval{$bucket} = exp(get_sort_value_( $self, $bucket, $word ));
                        $sumfreq += $wval{$bucket};
                    }
                    foreach my $bucket (@ranking) {
                        $wordprobs{$bucket,$word} = $wval{$bucket} / $sumfreq;
                    }
                }
            }

            my @ranked_words;
            if ($self->{wmformat__} eq 'prob') {
                @ranked_words = sort {$wordprobs{$ranking[0],$b} <=> $wordprobs{$ranking[0],$a}} keys %{$self->{parser__}->{words__}};
            } else {
                @ranked_words = sort {$self->get_sort_value_( $ranking[0], $b ) <=> $self->get_sort_value_( $ranking[0], $a )} keys %{$self->{parser__}->{words__}};
            }

            foreach my $word (@ranked_words) {
                my $known = 0;

                foreach my $bucket (@ranking) {
                    if ( $self->get_base_value_( $bucket, $word ) != 0 ) {
                        $known = 1;
                        last;
                    }
                }

                if ( $known == 1 ) {
                    my $wordcolor = $self->get_color( $word );
                    my $count     = $self->{parser__}->{words__}{$word};

                    $self->{scores__} .= "<tr>\n<td><font color=\"$wordcolor\">$word</font></td><td>&nbsp;</td><td>$count</td><td>&nbsp;</td>\n";

                    my $base_probability = $self->get_value_( $ranking[0], $word );

                    foreach my $ix (0..($#buckets > 7? 7: $#buckets)) {
                        my $bucket = $ranking[$ix];
                        my $probability  = $self->get_value_( $bucket, $word );
                        my $color        = 'black';

                        if ( $probability >= $base_probability || $base_probability == 0 ) {
                            $color = $self->get_bucket_color( $bucket );
                        }

                        if ( $probability != 0 ) {
                            my $wordprobstr;
                            if ($self->{wmformat__} eq 'score') {
                                $wordprobstr  = sprintf("%12.4f", ($probability - $self->{not_likely__})/$log10 );
                            } else {
                                if ($self->{wmformat__} eq 'prob') {
                                    $wordprobstr  = sprintf("%12.4f", $wordprobs{$bucket,$word});
                                } else {
                                    $wordprobstr  = sprintf("%13.5f", exp($probability) );
                                }
                            }

                            $self->{scores__} .= "<td><font color=\"$color\">$wordprobstr</font></td>\n<td>&nbsp;</td>\n";
                        } else {
                            $self->{scores__} .= "<td>&nbsp;</td>\n<td>&nbsp;</td>\n";
                        }
                    }
                }

                $self->{scores__} .= "</tr>";
            }

            $self->{scores__} .= "</table></p>";
        }
    }

    $self->log_( "Done classification at " . time );

    return $class;
}

# ---------------------------------------------------------------------------------------------
#
# history_filename
#
# Returns a path and filename for a POPFile message based on the session count and message count
#
# $dcount   - the unique download/session count for this message
# $mcount   - the message count for this message
# $ext      - the extension for this message (defaults to .msg)
# $path     - 1 to return the path configuration info, 0 to return just the filename (default 0)
#
# ---------------------------------------------------------------------------------------------
sub history_filename
{
    my ( $self, $dcount, $mcount, $ext, $path) = @_;

    $path = 0 if (!defined($path));

    return ($path?$self->get_user_path_( $self->global_config_( 'msgdir' ) ):'') . "popfile$dcount" . "=$mcount" . (defined $ext?$ext:'.msg');
}

# ---------------------------------------------------------------------------------------------
#
# history_write_class - write the class file for a message.
#
# $filename     The name of the message to write the class for
# $reclassified Boolean, true if the message has been reclassified
# $bucket       the name of the bucket the message is in
# $usedtobe     the name of the bucket the messages used to be in
# $magnet       the magnet, if any, used to reclassify the message
#
# ---------------------------------------------------------------------------------------------
sub history_write_class
{
    my ( $self, $filename, $reclassified, $bucket, $usedtobe, $magnet ) = @_;

    $filename =~ s/msg$/cls/;
    $filename =  $self->get_user_path_( $self->global_config_( 'msgdir' ) . $filename );

    open CLASS, ">$filename";

    if ( defined( $magnet ) && ( $magnet ne '' ) ) {
        print CLASS "$bucket MAGNET $magnet\n";
    } else {
        if ( defined( $reclassified ) && ( $reclassified == 1 ) ) {
            print CLASS "RECLASSIFIED\n";
            print CLASS "$bucket\n";
            if ( defined( $usedtobe ) && ( $usedtobe ne '' ) ) {
               print CLASS "$usedtobe\n";
            }
        } else {
            print CLASS "$bucket\n";
        }
    }

    close CLASS;
}

# ---------------------------------------------------------------------------------------------
#
# history_read_class - load the class file for a message.
#
# returns: ( reclassified, bucket, usedtobe, magnet )
#   values:
#       reclassified:   boolean, true if message has been reclassified
#       bucket:         string, the bucket the message is in presently, unknown class if an error occurs
#       usedtobe:       string, the bucket the message used to be in (null if not reclassified)
#       magnet:         string, the magnet
#
# $filename     The name of the message to load the class for
#
# ---------------------------------------------------------------------------------------------
sub history_read_class
{
    my ( $self, $filename ) = @_;

    $filename =~ s/msg$/cls/;

    my $reclassified = 0;
    my $bucket = 'unknown class';
    my $usedtobe;
    my $magnet = '';

    if ( open CLASS, '<' . $self->get_user_path_( $self->global_config_( 'msgdir' ) . $filename ) ) {
        $bucket = <CLASS>;
        if ( $bucket =~ /([^ ]+) MAGNET ([^\r\n]+)/ ) {
            $bucket = $1;
            $magnet = $2;
        }

        $reclassified = 0;
        if ( $bucket =~ /RECLASSIFIED/ ) {
            $bucket       = <CLASS>;
            $usedtobe = <CLASS>;
            $reclassified = 1;
            $usedtobe =~ s/[\r\n]//g;
        }
        close CLASS;
        $bucket =~ s/[\r\n]//g;
    } else {
        $self->log_( "Error: " . $self->global_config_( 'msgdir' ) . "$filename: $!" );

        return ( undef, $bucket, undef, undef );
    }

    $bucket = 'unknown class' if ( !defined( $bucket ) );

    return ( $reclassified, $bucket, $usedtobe, $magnet );
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
# $echo     - 1 to echo to the client, 0 to supress, defaults to 1
# $crlf     - The sequence to use at the end of a line in the output, normally
#             this is left undefined and this method uses $eol (the normal network end
#             of line), but if this method is being used with real files you may wish
#             to pass in \n instead
#
# Returns a classification if it worked and the name of the file where the message
# was saved
#
# IMPORTANT NOTE: $mail and $client should be binmode
#
# ---------------------------------------------------------------------------------------------
sub classify_and_modify
{
    my ( $self, $mail, $client, $dcount, $mcount, $nosave, $class, $echo, $crlf ) = @_;

    $echo = 1    unless (defined $echo);
    $crlf = $eol unless (defined $crlf);

    my $msg_subject     = '';     # The message subject
    my $msg_head_before = '';     # Store the message headers that come before Subject here
    my $msg_head_after  = '';     # Store the message headers that come after Subject here
    my $msg_head_q      = '';     # Store questionable header lines here
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

    my $msg_file  = $self->history_filename($dcount,$mcount, ".msg",1);
    my $temp_file = "$msg_file.tmp";
    my $nopath_temp_file = $self->history_filename($dcount,$mcount,".msg",0);

    # Get the class-file info without the path, since we'd just need to strip it
    my $class_file = $self->history_filename($dcount,$mcount, ".cls",0);

    # If we don't yet know the classification then start the parser
    if ( $class eq '' ) {
        $self->{parser__}->start_parse();
    }

    # We append .TMP to the filename for the MSG file so that if we are in
    # middle of downloading a message and we refresh the history we do not
    # get class file errors

    open TEMP, ">$temp_file" unless $nosave;

    while ( my $line = $self->slurp_( $mail ) ) {
        my $fileline;

        # This is done so that we remove the network style end of line CR LF
        # and allow Perl to decide on the local system EOL which it will expand
        # out of \n when this gets written to the temp file

        $fileline = $line;
        $fileline =~ s/[\r\n]//g;
        $fileline .= "\n";

        # Check for an abort

        last if ( $self->{alive_} == 0 );

        # The termination of a message is a line consisting of exactly .CRLF so we detect that
        # here exactly

        if ( $line =~ /^\.(\r\n|\r|\n)$/ ) {
            $got_full_body = 1;
            last;
        }

        if ( $getting_headers )  {

            # Kill header lines containing only whitespace (Exim does this)

            next if ( $line =~ /^[ \t]+(\r\n|\r|\n)$/i );

            if ( !( $line =~ /^(\r\n|\r|\n)$/i ) )  {
                $message_size += length $line;
                $self->write_line__( $nosave?undef:\*TEMP, $fileline, $class );

                # If there is no echoing occuring, it doesn't matter what we do to these

                if ( $echo ) {
                    if ( $line =~ /^Subject:(.*)/i )  {
                        $msg_subject = $1;
                        $msg_subject =~ s/(\012|\015)//g;
                        next;
                    }

                    # Strip out the X-Text-Classification header that is in an incoming message

                    next if ( $line =~ /^X-Text-Classification:/i );
                    next if ( $line =~ /^X-POPFile-Link:/i );

                    # Store any lines that appear as though they may be non-header content
                    # Lines that are headers begin with whitespace or Alphanumerics and "-"
                    # followed by a colon.
                    # This prevents wierd things like HTML before the headers terminate from
                    # causing the XPL and XTC headers to be inserted in places some clients
                    # can't detect

                    if ( $line =~ /^(([ \t])|(([a-zA-Z\-])+:))/ ) {
                        if ( $msg_subject eq '' )  {
                            $msg_head_before .= $msg_head_q . $line;
                        } else {
                            $msg_head_after  .= $msg_head_q . $line;
                        }
                        $msg_head_q = '';
                    } else {

                        # Gather up any header lines that are questionable

                        $msg_head_q .= $line;
                    }
                }
            } else {
                $self->write_line__( $nosave?undef:\*TEMP, "\n", $class );
                $message_size += length $crlf;
                $getting_headers = 0;
            }
        } else {
            $message_size += length $line;
            $msg_body     .= $line;
            $self->write_line__( $nosave?undef:\*TEMP, $fileline, $class );
        }

        # Check to see if too much time has passed and we need to keep the mail client happy
        if ( time > ( $last_timeout + 2 ) ) {
            print $client "X-POPFile-TimeoutPrevention: $timeout_count$crlf" if ( $echo );
            $timeout_count += 1;
            $last_timeout = time;
        }

        last if ( ( $message_size > $self->global_config_( 'message_cutoff' ) ) && ( $getting_headers == 0 ) );
    }

    close TEMP unless $nosave;

    # If we don't yet know the classification then stop the parser
    if ( $class eq '' ) {
        $self->{parser__}->stop_parse();
    }

    # Do the text classification and update the counter for that bucket that we just downloaded
    # an email of that type

    if ( $self->module_config_( 'html', 'language' ) eq 'Nihongo' ) {

        # Parse Japanese mail message with Kakasi

        $self->parse_with_kakasi__( $temp_file, $dcount, $mcount );

        $classification = ($class ne '')?$class:$self->classify($temp_file);
    } else {
        $classification = ($class ne '')?$class:$self->classify(undef);
    }

    my $subject_modification = $self->get_bucket_parameter( $classification, 'subject'    );
    my $xtc_insertion        = $self->get_bucket_parameter( $classification, 'xtc'        );
    my $xpl_insertion        = $self->get_bucket_parameter( $classification, 'xpl'        );
    my $quarantine           = $self->get_bucket_parameter( $classification, 'quarantine' );

    my $modification = $self->config_( 'subject_mod_left' ) . $classification . $self->config_( 'subject_mod_right' );

    # Add the Subject line modification or the original line back again
    # Don't add the classification unless it is not present
    if ( !( $msg_subject =~ /\Q$modification\E/ ) &&                        # PROFILE BLOCK START
          ( $subject_modification == 1 ) &&
          ( $quarantine == 0 ) )  {                                          # PROFILE BLOCK STOP
         $msg_subject = " $modification$msg_subject";
    }

    $msg_head_before .= 'Subject:' . $msg_subject;
    $msg_head_before .= $crlf;

    # Add the XTC header
    $msg_head_after .= "X-Text-Classification: $classification$crlf" if ( ( $xtc_insertion   ) && # PROFILE BLOCK START
                                                                          ( $quarantine == 0 ) ); # PROFILE BLOCK STOP

    # Add the XPL header
    my $xpl = '';

    $xpl .= "http://";
    $xpl .= $self->module_config_( 'html', 'local' )?"127.0.0.1":$self->config_( 'hostname' );
    $xpl .= ":" . $self->module_config_( 'html', 'port' ) . "/jump_to_message?view=$nopath_temp_file$crlf";

    if ( $xpl_insertion && ( $quarantine == 0 ) ) {
        $msg_head_after .= 'X-POPFile-Link: ' . $xpl;
    }

    $msg_head_after .= $msg_head_q . "$crlf";

    # Echo the text of the message to the client

    if ( $echo ) {

        # If the bucket is quarantined then we'll treat it specially by changing the message header to contain
        # information from POPFile and wrapping the original message in a MIME encoding

       if ( $quarantine == 1 ) {
           print $client "From: " . $self->{parser__}->get_header( 'from' ) . "$crlf";
           print $client "To: " . $self->{parser__}->get_header( 'to' ) . "$crlf";
           print $client "Date: " . $self->{parser__}->get_header( 'date' ) . "$crlf";
           # Don't add the classification unless it is not present
           if ( !( $msg_subject =~ /\[\Q$classification\E\]/ ) &&             # PROFILE BLOCK START
                 ( $subject_modification == 1 ) ) {                           # PROFILE BLOCK STOP
               $msg_subject = " $modification$msg_subject";
           }
           print $client "Subject:$msg_subject$crlf";
           print $client "X-Text-Classification: $classification$crlf" if ( $xtc_insertion );
           print $client 'X-POPFile-Link: ' . $xpl if ( $xpl_insertion );
           print $client "MIME-Version: 1.0$crlf";
           print $client "Content-Type: multipart/report; boundary=\"$nopath_temp_file\"$crlf$crlf--$nopath_temp_file$crlf";
           print $client "Content-Type: text/plain$crlf$crlf";
           print $client "POPFile has quarantined a message.  It is attached to this email.$crlf$crlf";
           print $client "Quarantined Message Detail$crlf$crlf";
           print $client "Original From: " . $self->{parser__}->get_header('from') . "$crlf";
           print $client "Original To: " . $self->{parser__}->get_header('to') . "$crlf";
           print $client "Original Subject: " . $self->{parser__}->get_header('subject') . "$crlf";
           print $client "To examine the email open the attachment. ";
           print $client "To change this mail's classification go to $xpl";
           print $client "$crlf";
           print $client "The first 20 words found in the email are:$crlf$crlf";
           print $client $self->{parser__}->first20();
           print $client "$crlf--$nopath_temp_file$crlf";
           print $client "Content-Type: message/rfc822$crlf$crlf";
        }

        print $client $msg_head_before;
        print $client $msg_head_after;
        print $client $msg_body;
    }

    my $before_dot = '';

    if ( $quarantine && $echo ) {
        $before_dot = "$crlf--$nopath_temp_file--$crlf";
    }

    my $need_dot = 0;

    if ( $got_full_body ) {
        $need_dot = 1;
    } else {
        $need_dot = !$self->echo_to_dot_( $mail, $echo?$client:undef, $nosave?undef:'>>' . $temp_file, $before_dot );
    }

    if ( $need_dot ) {
        print $client $before_dot if ( $before_dot ne '' );
        print $client ".$crlf"    if ( $echo );
    }

    # In some cases it's possible (and totally illegal) to get a . in the middle of the message,
    # to cope with the we call flush_extra_ here to remove an extra stuff the POP3 server is sending
    # Make sure to supress output if we are not echoing, and to save to file if not echoing and saving

    if ( !($nosave || $echo) ) {

        # if we're saving (not nosave) and not echoing, we can safely unload this into the temp file

        if (open FLUSH, ">>$temp_file.flush") {
            binmode FLUSH;

            #TODO: Do this in a faster way (without flushing to one file then copying to another)
            # (perhaps a select on $mail to predict if there is flushable data)

            $self->flush_extra_( $mail, \*FLUSH, 0);
            close FLUSH;

            # append any data we got to the actual temp file

            if ((-s "$temp_file.flush" > 0) && open FLUSH, "<$temp_file.flush") {
                binmode FLUSH;
                if (open TEMP, ">>$temp_file") {
                    binmode TEMP;

                    # The only time we get data here is if it is after a CRLF.CRLF
                    # We have to re-create it to avoid data-loss

                    print TEMP ".$crlf";

                    print TEMP $_ while (<FLUSH>);

                    #NOTE: The last line flushed MAY be a CRLF.CRLF, which isn't actually part of the message body

                    close TEMP;
                }
                close FLUSH;
            }
            unlink("$temp_file.flush");
        }
    } else {

        # if we are echoing, the client can make sure we have no data loss
        # otherwise, the data can be discarded (not saved and not echoed)

        $self->flush_extra_( $mail, $client, $echo?0:1);
    }

    if ( !$nosave ) {
        $self->history_write_class($class_file, undef, $classification, undef, ($self->{magnet_used__}?$self->{magnet_detail__}:undef));

        # Now rename the MSG file, since the class file has been written it's safe for the mesg
        # file to have the correct name.  If the history cache is reloaded then we wont have a class
        # file error since it was already written

        unlink $msg_file;
        rename $temp_file, $msg_file;
    }

    return ( $classification, $nopath_temp_file );
}

# ---------------------------------------------------------------------------------------------
#
# get_buckets
#
# Returns a list containing all the real bucket names sorted into alphabetic order
#
# ---------------------------------------------------------------------------------------------
sub get_buckets
{
    my ( $self ) = @_;

    # Note that get_buckets does not return pseudo buckets

    my @buckets;

    for my $b (sort keys %{$self->{db_bucketid__}}) {
        if ( $self->{db_bucketid__}{$b}{pseudo} == 0 ) {
            push @buckets, ($b);
	}
    }

    return @buckets;
}

# ---------------------------------------------------------------------------------------------
#
# get_pseudo_buckets
#
# Returns a list containing all the pseudo bucket names sorted into alphabetic order
#
# ---------------------------------------------------------------------------------------------
sub get_pseudo_buckets
{
    my ( $self ) = @_;

    my @buckets;

    for my $b (sort keys %{$self->{db_bucketid__}}) {
        if ( $self->{db_bucketid__}{$b}{pseudo} == 1 ) {
            push @buckets, ($b);
	}
    }

    return @buckets;
}

# ---------------------------------------------------------------------------------------------
#
# is_pseudo_bucket
#
# Returns 1 if the named bucket is pseudo
#
# ---------------------------------------------------------------------------------------------
sub is_pseudo_bucket
{
    my ( $self, $bucket ) = @_;

    return $self->{db_bucketid__}{$bucket}{pseudo};
}

# ---------------------------------------------------------------------------------------------
#
# is_pseudo_bucket
#
# Returns 1 if the named bucket is a bucket
#
# ---------------------------------------------------------------------------------------------
sub is_bucket
{
    my ( $self, $bucket ) = @_;

    return defined($self->{db_bucketid__}{$bucket});
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_word_count
#
# Returns the total word count (including duplicates) for the passed in bucket
#
# $bucket      The name of the bucket for which the word count is desired
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_word_count
{
    my ( $self, $bucket ) = @_;

    return $self->{db_bucketcount__}{$bucket};
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_word_list
#
# Returns a list of words all with the same first character
#
# $bucket      The name of the bucket for which the word count is desired
# $prefix      The first character of the words
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_word_list
{
    my ( $self, $bucket, $prefix ) = @_;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};
    my $result = $self->{db__}->selectcol_arrayref(
        "select words.word from matrix, words
         where matrix.wordid  = words.id and
               matrix.bucketid = $bucketid and
               substr( words.word, 1, 1 ) = '$prefix';");

    return @{$result};
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_word_prefixes
#
# Returns a list of all the initial letters of words in a bucket
#
# $bucket      The name of the bucket for which the word count is desired
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_word_prefixes
{
    my ( $self, $bucket ) = @_;

    my $prev = '';

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};
    my $result = $self->{db__}->selectcol_arrayref(
        "select words.word from matrix, words
         where matrix.wordid  = words.id and
               matrix.bucketid = $bucketid;");

    # In Japanese mode, disable locale and use substr_euc, the substr function
    # which supports EUC Japanese charset.
    # Sorting Japanese with "use locale" is memory and time consuming,
    # and may cause perl crash.

    if ( $self->module_config_( 'html', 'language' ) eq 'Nihongo' ) {
        no locale;
        return grep {$_ ne $prev && ($prev = $_, 1)} sort map {substr_euc__($_,0,1)} @{$result};
    } else {
        if  ( $self->module_config_( 'html', 'language' ) eq 'Korean' ) {
    	    no locale;
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {$_ =~ /([\x20-\x80]|$eksc)/} @{$result};
        } else {
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {substr($_,0,1)}  @{$result};
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# get_word_count
#
# Returns the total word count (including duplicates)
#
# ---------------------------------------------------------------------------------------------
sub get_word_count
{
    my ( $self ) = @_;

    $self->{db_get_full_total__}->execute( $self->{db_userid__} );
    return $self->{db_get_full_total__}->fetchrow_arrayref->[0];
}

# ---------------------------------------------------------------------------------------------
#
# get_count_for_word
#
# Returns the number of times the word occurs in a bucket
#
# $bucket          The bucket we are asking about
# $word            The word we are asking about
#
# ---------------------------------------------------------------------------------------------
sub get_count_for_word
{
    my ( $self, $bucket, $word ) = @_;

    return $self->get_base_value_( $bucket, $word );
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_unique_count
#
# Returns the unique word count (excluding duplicates) for the passed in bucket
#
# $bucket      The name of the bucket for which the word count is desired
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_unique_count
{
    my ( $self, $bucket ) = @_;

    $self->{db_get_bucket_unique_count__}->execute( $self->{db_bucketid__}{$bucket}{id} );
    return $self->{db_get_bucket_unique_count__}->fetchrow_arrayref->[0];
}

# ---------------------------------------------------------------------------------------------
#
# get_unique_word_count
#
# Returns the unique word count (excluding duplicates) for the passed all buckets
#
# ---------------------------------------------------------------------------------------------
sub get_unique_word_count
{
    my ( $self, $bucket ) = @_;

    $self->{db_get_unique_word_count__}->execute( $self->{db_userid__} );
    return $self->{db_get_unique_word_count__}->fetchrow_arrayref->[0];
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_color
#
# Returns the color associated with a bucket
#
# $bucket      The name of the bucket for which the color is requested
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_color
{
    my ( $self, $bucket ) = @_;

    return $self->get_bucket_parameter( $bucket, 'color' );
}

# ---------------------------------------------------------------------------------------------
#
# set_bucket_color
#
# Returns the color associated with a bucket
#
# $bucket      The name of the bucket for which the color is requested
# $color       The new color
#
# ---------------------------------------------------------------------------------------------
sub set_bucket_color
{
    my ( $self, $bucket, $color ) = @_;

    $self->set_bucket_parameter( $bucket, 'color', $color );
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_parameter
#
# Returns the value of a per bucket parameter
#
# $bucket      The name of the bucket
# $parameter   The name of the parameter
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_parameter
{
    my ( $self, $bucket, $parameter ) = @_;

    $self->{db_get_bucket_parameter__}->execute( $self->{db_bucketid__}{$bucket}{id},
                                                 $self->{db_parameterid__}{$parameter} );
    my $result = $self->{db_get_bucket_parameter__}->fetchrow_arrayref;

    # If this parameter has not been defined for this specific bucket then
    # get the default value

    if ( !defined( $result ) ) {
        $self->{db_get_bucket_parameter_default__}->execute(
            $self->{db_parameterid__}{$parameter} );
        $result = $self->{db_get_bucket_parameter_default__}->fetchrow_arrayref;
    }

    if ( defined( $result ) ) {
        return $result->[0];
    } else {
        return undef;
    }
}

# ---------------------------------------------------------------------------------------------
#
# set_bucket_parameter
#
# Sets the value associated with a bucket specific parameter
#
# $bucket      The name of the bucket
# $parameter   The name of the parameter
# $value       The new value
#
# ---------------------------------------------------------------------------------------------
sub set_bucket_parameter
{
    my ( $self, $bucket, $parameter, $value ) = @_;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};
    my $btid     = $self->{db_parameterid__}{$parameter};

    $self->{db_set_bucket_parameter__}->execute( $bucketid, $btid, $value );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# get_html_colored_message
#
# Parser a mail message stored in a file and returns HTML representing the message
# with coloring of the words
#
# $file           The file to parse
#
# ---------------------------------------------------------------------------------------------
sub get_html_colored_message
{
    my ( $self, $file ) = @_;

    $self->{parser__}->{color__} = 1;
    $self->{parser__}->{bayes__} = bless $self;

    # Pass language parameter to parse_file()

    my $result = $self->{parser__}->parse_file( $file,
                                                $self->module_config_( 'html', 'language' ),
                                                $self->global_config_( 'message_cutoff'   ) );

    $self->{parser__}->{color__} = 0;

    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# create_bucket
#
# Creates a new bucket, returns 1 if the creation succeeded
#
# $bucket          Name for the new bucket
#
# ---------------------------------------------------------------------------------------------
sub create_bucket
{
    my ( $self, $bucket ) = @_;

    my $userid = $self->{db_userid__};
    $self->{db__}->do(
        "insert or ignore into buckets ( 'userid', 'name', 'pseudo' ) values ( $userid, '$bucket', 0 );" );
    $self->db_update_cache__();
}

# ---------------------------------------------------------------------------------------------
#
# delete_bucket
#
# Deletes a bucket, returns 1 if the delete succeeded
#
# $bucket          Name of the bucket to delete
#
# ---------------------------------------------------------------------------------------------
sub delete_bucket
{
    my ( $self, $bucket ) = @_;

    my $userid = $self->{db_userid__};
    $self->{db__}->do(
        "delete from buckets where buckets.userid = $userid and buckets.name = '$bucket';" );
    $self->db_update_cache__();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# rename_bucket
#
# Renames a bucket, returns 1 if the rename succeeded
#
# $old_bucket          The old name of the bucket
# $new_bucket          The new name of the bucket
#
# ---------------------------------------------------------------------------------------------
sub rename_bucket
{
    my ( $self, $old_bucket, $new_bucket ) = @_;

    my $userid = $self->{db_userid__};
    my $result = $self->{db__}->do(
        "update buckets set name = '$new_bucket' where buckets.userid = $userid and buckets.name = '$old_bucket';" );

    if ( !defined( $result ) || ( $result == -1 ) ) {
        return 0;
    } else {
        $self->db_update_cache__();
        return 1;
    }
}

# ---------------------------------------------------------------------------------------------
#
# add_messages_to_bucket
#
# Parses mail messages and updates the statistics in the specified bucket
#
# $bucket          Name of the bucket to be updated
# @files           List of file names to parse
#
# ---------------------------------------------------------------------------------------------
sub add_messages_to_bucket
{
    my ( $self, $bucket, @files ) = @_;

    $self->{db__}->begin_work;

    # Pass language parameter to parse_file()

    foreach my $file (@files) {
        $self->{parser__}->parse_file( $file,
                                       $self->module_config_( 'html', 'language' ),
                                       $self->global_config_( 'message_cutoff'   ) );
        $self->add_words_to_bucket__( $bucket, 1 );
    }

    $self->{db__}->commit;
    $self->db_update_cache__();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# add_message_to_bucket
#
# Parses a mail message and updates the statistics in the specified bucket
#
# $bucket          Name of the bucket to be updated
# $file            Name of file containing mail message to parse
#
# ---------------------------------------------------------------------------------------------
sub add_message_to_bucket
{
    my ( $self, $bucket, $file ) = @_;

    return $self->add_messages_to_bucket( $bucket, $file );
}

# ---------------------------------------------------------------------------------------------
#
# remove_message_from_bucket
#
# Parses a mail message and updates the statistics in the specified bucket
#
# $bucket          Name of the bucket to be updated
# $file            Name of file containing mail message to parse
#
# ---------------------------------------------------------------------------------------------
sub remove_message_from_bucket
{
    my ( $self, $bucket, $file ) = @_;

    # Pass language parameter to parse_file()

    $self->{db__}->begin_work;

    $self->{parser__}->parse_file( $file,
                                   $self->module_config_( 'html', 'language' ),
                                   $self->global_config_( 'message_cutoff'   ) );
    $self->add_words_to_bucket__( $bucket, -1 );

    $self->{db__}->commit;
    $self->db_update_cache__();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# get_buckets_with_magnets
#
# Returns the names of the buckets for which magnets are defined
#
# ---------------------------------------------------------------------------------------------
sub get_buckets_with_magnets
{
    my ( $self ) = @_;

    my @result;

    $self->{db_get_buckets_with_magnets__}->execute( $self->{db_userid__} );
    while ( my $row = $self->{db_get_buckets_with_magnets__}->fetchrow_arrayref ) {
        push @result, ($row->[0]);
    }

    return @result;
}

# ---------------------------------------------------------------------------------------------
#
# get_magnet_types_in_bucket
#
# Returns the types of the magnets in a specific bucket
#
# $bucket          The bucket to search for magnets
#
# ---------------------------------------------------------------------------------------------
sub get_magnet_types_in_bucket
{
    my ( $self, $bucket ) = @_;

    my @result;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};
    my $h = $self->{db__}->prepare( "select magnet_types.mtype from magnet_types, magnets, buckets
        where magnet_types.id = magnets.mtid and
              magnets.bucketid = buckets.id and
              buckets.id = $bucketid
              group by magnet_types.mtype
              order by magnet_types.mtype;" );

    $h->execute;
    while ( my $row = $h->fetchrow_arrayref ) {
        push @result, ($row->[0]);
    }
    $h->finish;

    return @result;
}

# ---------------------------------------------------------------------------------------------
#
# clear_bucket
#
# Removes all words from a bucket
#
# $bucket         The bucket to clear
#
# ---------------------------------------------------------------------------------------------
sub clear_bucket
{
    my ( $self, $bucket ) = @_;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};

    $self->{db__}->do( "delete from matrix where matrix.bucketid = $bucketid;" );
    $self->db_update_cache__();
}

# ---------------------------------------------------------------------------------------------
#
# clear_magnets
#
# Removes every magnet currently defined
#
# ---------------------------------------------------------------------------------------------
sub clear_magnets
{
    my ( $self ) = @_;

    for my $bucket (keys %{$self->{db_bucketid__}}) {
        my $bucketid = $self->{db_bucketid__}{$bucket}{id};
        $self->{db__}->do( "delete from magnets where magnets.bucketid = $bucketid" );
    }
}

# ---------------------------------------------------------------------------------------------
#
# get_magnets
#
# Returns the magnets of a certain type in a bucket
#
# $bucket          The bucket to search for magnets
# $type            The magnet type (e.g. from, to or subject)
#
# ---------------------------------------------------------------------------------------------
sub get_magnets
{
    my ( $self, $bucket, $type ) = @_;

    my @result;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};
    my $h = $self->{db__}->prepare( "select magnets.val from magnets, magnet_types
        where magnets.bucketid = $bucketid and
              magnet_types.id = magnets.mtid and
              magnet_types.mtype = '$type' order by magnets.val;" );

    $h->execute;
    while ( my $row = $h->fetchrow_arrayref ) {
        push @result, ($row->[0]);
    }
    $h->finish;

    return @result;
}

# ---------------------------------------------------------------------------------------------
#
# create_magnet
#
# Make a new magnet
#
# $bucket          The bucket the magnet belongs in
# $type            The magnet type (e.g. from, to or subject)
# $text            The text of the magnet
#
# ---------------------------------------------------------------------------------------------
sub create_magnet
{
    my ( $self, $bucket, $type, $text ) = @_;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};

    my $result = $self->{db__}->selectrow_arrayref("select magnet_types.id from magnet_types
                                                        where magnet_types.mtype = '$type';" );

    my $mtid = $result->[0];

    $self->{db__}->do( "insert into magnets ( bucketid, mtid, val )
                                     values ( $bucketid, $mtid, '$text' );" );
}

# ---------------------------------------------------------------------------------------------
#
# get_magnet_types
#
# Get a hash mapping magnet types (e.g. from) to magnet names (e.g. From);
#
# ---------------------------------------------------------------------------------------------
sub get_magnet_types
{
    my ( $self ) = @_;

    my %result;

    my $h = $self->{db__}->prepare( "select magnet_types.mtype, magnet_types.header from magnet_types;" );

    $h->execute;
    while ( my $row = $h->fetchrow_arrayref ) {
        $result{$row->[0]} = $row->[1];
    }
    $h->finish;

    return %result;
}

# ---------------------------------------------------------------------------------------------
#
# delete_magnet
#
# Remove a new magnet
#
# $bucket          The bucket the magnet belongs in
# $type            The magnet type (e.g. from, to or subject)
# $text            The text of the magnet
#
# ---------------------------------------------------------------------------------------------
sub delete_magnet
{
    my ( $self, $bucket, $type, $text ) = @_;

    my $bucketid = $self->{db_bucketid__}{$bucket}{id};

    my $result = $self->{db__}->selectrow_arrayref("select magnet_types.id from magnet_types
                                                        where magnet_types.mtype = '$type';" );

    my $mtid = $result->[0];

    $self->{db__}->do( "delete from magnets
                            where magnets.bucketid = $bucketid and
                                  magnets.mtid = $mtid and
                                  magnets.val  = '$text';" );
}

# ---------------------------------------------------------------------------------------------
#
# get_stopword_list
#
# Gets the complete list of stop words
#
# ---------------------------------------------------------------------------------------------
sub get_stopword_list
{
    my ( $self ) = @_;

    return $self->{parser__}->{mangle__}->stopwords();
}

# ---------------------------------------------------------------------------------------------
#
# magnet_count
#
# Gets the number of magnets that are defined
#
# ---------------------------------------------------------------------------------------------
sub magnet_count
{
    my ( $self ) = @_;

    my $userid = $self->{db_userid__};
    my $result = $self->{db__}->selectrow_arrayref( "select count(*) from magnets, buckets
        where buckets.userid = $userid and
              magnets.bucketid = buckets.id;" );

    if ( defined( $result ) ) {
        return $result->[0];
    } else {
        return 0;
    }
}

# ---------------------------------------------------------------------------------------------
#
# add_stopword, remove_stopword
#
# Adds or removes a stop word
#
# $stopword    The word to add or remove
#
# Return 0 for a bad stop word, and 1 otherwise
#
# ---------------------------------------------------------------------------------------------
sub add_stopword
{
    my ( $self, $stopword ) = @_;

    # Pass language parameter to add_stopword()

    return $self->{parser__}->{mangle__}->add_stopword( $stopword, $self->module_config_( 'html', 'language' ) );
}

sub remove_stopword
{
    my ( $self, $stopword ) = @_;

    # Pass language parameter to remove_stopword()

    return $self->{parser__}->{mangle__}->remove_stopword( $stopword, $self->module_config_( 'html', 'language' ) );
}

# GETTERS/SETTERS

sub wordscores
{
    my ( $self, $value ) = @_;

    $self->{wordscores__} = $value if (defined $value);
    return $self->{wordscores__};
}

sub scores
{
    my ( $self, $value ) = @_;

    $self->{scores__} = $value if (defined $value);
    return $self->{scores__};
}

sub wmformat
{
    my ( $self, $value ) = @_;

    $self->{wmformat__} = $value if (defined $value);
    return $self->{wmformat__};
}

1;

