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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;
use Classifier::MailParse;
use Classifier::WordMangle;
use IO::Handle;

# This is used to get the hostname of the current machine
# in a cross platform way

use Sys::Hostname;

# A handy variable containing the value of an EOL for networks

my $eol = "\015\012";

# The corpus is stored in BerkeleyDB hashes called table.db in each
# of the corpus/* subdirectories.  The db files are tied to Perl
# hashes for simple access

use BerkeleyDB;

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

    # Matrix of buckets, words and the word counts
    $self->{matrix__}            = {};
    $self->{db__}                = {};

    # Total number of words in all buckets
    $self->{full_total__}        = 0;

    # Used to mangle the corpus when loaded
    $self->{mangler__}           = new Classifier::WordMangle;

    # Used to parse mail messages
    $self->{parser__}            = new Classifier::MailParse;

    # Colors assigned to each bucket
    $self->{colors__}            = {};

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
    $self->{corpus_version__}    = 1;

    # Per bucket parameters
    $self->{parameters__}        = {};

    # The magnets that cause attraction to certain buckets
    $self->{magnets__}           = {};
    $self->{magnet_count__}      = 0;

    # The unclassified cutoff this value means that the top probabilily must be n times greater than the
    # second probability, default is 100 times more likely
    $self->{unclassified__}      = log(100);

    # Used to tell the caller whether a magnet was used in the last
    # mail classification
    $self->{magnet_used__}       = 0;
    $self->{magnet_detail__}     = '';

    # Must call bless before attempting to call any methods

    bless $self, $type;

    $self->name( 'bayes' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# prefork
#
# POPFile is about to fork, because the BerkeleyDB interface doesn't support multiple
# threads accessing the database we will get a nasty failure if the database is tied to
# the hashes when the fork occurs (actually when the child exits).  So here we untie from
# the database
#
# ---------------------------------------------------------------------------------------------
sub prefork
{
    my ( $self ) = @_;

    $self->close_database__();
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# This is called inside a child process that has just forked, since the child needs access
# to the database we reopen it
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;

    $self->load_word_matrix_();
}

# ---------------------------------------------------------------------------------------------
#
# postfork
#
# This is called inside the parent process that has just forked, since the parent needs access
# to the database we reopen it
#
# ---------------------------------------------------------------------------------------------
sub postfork
{
    my ( $self ) = @_;

    $self->load_word_matrix_();
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

    # No default unclassified weight is the number of times more sure POPFile
    # must be of the top class vs the second class, default is 100 times more

    $self->config_( 'unclassified_weight', 100 );

    # The corpus is kept in the 'corpus' subfolder of POPFile

    $self->config_( 'corpus', 'corpus' );

    # The characters that appear before and after a subject modification

    $self->config_( 'subject_mod_left',  '[' );
    $self->config_( 'subject_mod_right', ']' );

    # Get the hostname for use in the X-POPFile-Link header

    $self->{hostname__} = hostname;

    # Allow the user to override the hostname

    $self->config_( 'hostname', $self->{hostname__} );

    # The default size for the BerkeleyDB cache

    $self->config_( 'db_cache_size', 65536 );

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
    $self->load_word_matrix_();

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

    $self->write_parameters();
    $self->close_database__();
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
        $self->set_bucket_parameter( $message, 'count', $self->get_bucket_parameter( $message, 'count' ) + 1 );
        $self->write_parameters();
    }
}

# ---------------------------------------------------------------------------------------------
#
# write_parameters
#
# Save the parameters hash
#
# ---------------------------------------------------------------------------------------------
sub write_parameters
{
    my ($self) = @_;

    for my $bucket (keys %{$self->{matrix__}})  {
        open PARAMS, '>' . $self->config_( 'corpus' ) . "/$bucket/params";
        for my $param (keys %{$self->{parameters__}{$bucket}}) {
            print PARAMS "$param $self->{parameters__}{$bucket}{$param}\n";
        }
        close PARAMS;
    }
}

# ---------------------------------------------------------------------------------------------
#
# close_database__
#
# Close all the database connections
#
# ---------------------------------------------------------------------------------------------
sub close_database__
{
    my ( $self ) = @_;

    for my $bucket (keys %{$self->{matrix__}})  {
        $self->untie_bucket__( $bucket );
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

    for my $bucket (keys %{$self->{matrix__}}) {
        my $prob = get_value_( $self, $bucket, $word );

        if ( $prob != 0 )  {
            if ( $prob > $max )  {
                $max   = $prob;
                $color = $self->{colors__}{$bucket};
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

    my $value = $self->{matrix__}{$bucket}{$word};

    if ( defined( $value ) ) {

        # Profiling notes:
        #
        # I tried caching the log of the total value and then doing
        # log( $value ) - $cached and this turned out to be
        # much slower than this single log with a division in it

        return log( $value / $self->{matrix__}{$bucket}{__POPFILE__TOTAL__} );
    } else {
        return 0;
    }
}

sub get_base_value_
{
    my ( $self, $bucket, $word ) = @_;

    my $value = $self->{matrix__}{$bucket}{$word};

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

    # If there's an existing value then remove it and keep the total up to date
    # then add the new value, this is a little complicated but by keeping the
    # total in a value in the database it avoids us doing any sort of query
    # or full table scan

    my $oldvalue = $self->{matrix__}{$bucket}{$word};

    if ( !defined( $oldvalue ) ) {
        $oldvalue = 0;
        $self->{matrix__}{$bucket}{$word} = $oldvalue;
        if ( defined( $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__} ) ) {
            $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__} += 1;
	} else {
            $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__} = 1;
        }
    }

    my $total = $self->get_bucket_word_count( $bucket );

    $total                                              -= $oldvalue;
    $self->{full_total__}                               -= $oldvalue;
    $self->{matrix__}{$bucket}{$word}                    = $value;
    $total                                              += $value;
    $self->{matrix__}{$bucket}{__POPFILE__TOTAL__}       = $total;
    $self->{full_total__}                          += $value;

    if ( $self->{matrix__}{$bucket}{$word} <= 0 ) {
        $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__} -= 1;
        delete $self->{matrix__}{$bucket}{$word};
    }
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
# update_constants_
#
# Updates not_likely and bucket_start
#
# ---------------------------------------------------------------------------------------------
sub update_constants_
{
    my ($self) = @_;

    if ( $self->{full_total__} > 0 )  {
        $self->{not_likely__} = -log( 10 * $self->{full_total__} );

        foreach my $bucket (keys %{$self->{matrix__}}) {
            my $total = $self->get_bucket_word_count( $bucket );

            if ( $total != 0 ) {
                $self->{bucket_start__}{$bucket} = log( $total / $self->{full_total__} );
            } else {
                $self->{bucket_start__}{$bucket} = 0;
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_word_matrix_
#
# Fills the matrix with the word frequencies from all buckets and builds the bucket total
#
# ---------------------------------------------------------------------------------------------
sub load_word_matrix_
{
    my ($self) = @_;
    my $c      = 0;

    $self->close_database__();

    $self->{magnets__}      = {};
    $self->{full_total__}   = 0;

    my @buckets = glob $self->config_( 'corpus' ) . '/*';

    foreach my $bucket (@buckets) {

        next if ( lc($bucket) ne $bucket );

        # Look for the delete file that indicates that this bucket
        # is no longer needed

        if ( -e "$bucket/delete" ) {
            $self->delete_bucket_files__( $bucket );
            next;
	}

        my $color = '';

        # See if there's a color file specified
        if ( open COLOR, '<' . "$bucket/color" ) {
            $color = <COLOR>;

            # Someone (who shall remain nameless) went in an manually created
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
        }

        $self->load_bucket_( $bucket );

        $bucket =~ /([[:alpha:]0-9-_]+)$/;
        $bucket =  $1;

        if ( $color eq '' )  {
            $self->{colors__}{$bucket} = $self->{possible_colors__}[$c];
        } else {
            $self->{colors__}{$bucket} = $color;
        }

        $c = ($c+1) % $#{$self->{possible_colors__}};
    }

    $self->update_constants_();

    # unclassified will always have the color black, note that unclassified is not
    # actually a bucket

    $self->{colors__}{unclassified} = 'black';
    $self->{colors__}{unsure}       = 'black';

    # SLM for unclassified "bucket" will always match the global setting

    $self->{parameters__}{unclassified}{subject} = $self->global_config_('subject');
    $self->{parameters__}{unsure}{subject}       = $self->global_config_('subject');

    # Quarantine for unclassified will be off:

    $self->{parameters__}{unclassified}{quarantine} = 0;
    $self->{parameters__}{unsure}{quarantine}       = 0;
}

# ---------------------------------------------------------------------------------------------
#
# tie_bucket__
#
# Ties an individual bucket (creating it if necessary to a BerkeleyDB file called
# table.db.  This function has the side effect of creating entries in $self->{db__}
# and $self->{matrix__} for the bucket.
#
# $bucket            The bucket name
#
# ---------------------------------------------------------------------------------------------
sub tie_bucket__
{
    my ( $self, $bucket ) = @_;

    $self->{db__}{$bucket} = tie %{$self->{matrix__}{$bucket}}, "BerkeleyDB::Hash",              # PROFILE BLOCK START
                                 -Cachesize => $self->config_( 'db_cache_size' ),
                                 -Filename  => $self->config_( 'corpus' ) . "/$bucket/table.db",
                                 -Flags     => DB_CREATE;                                        # PROFILE BLOCK STOP

    # Check to see if the tie worked, if it failed then POPFile is about to fail
    # badly

    if ( !defined( $self->{db__}{$bucket} ) ) {
        $self->log_( "Failed to tie database hash for bucket $bucket" );
        die "Database tie failed for $bucket";
    }

    if ( !defined( $self->{matrix__}{$bucket}{__POPFILE__TOTAL__} ) ) {
        $self->{matrix__}{$bucket}{__POPFILE__TOTAL__}      = 0;
        $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__}     = 0;
    }

    if ( !defined( $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__} ) ) {
        $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__}     = 0;
    }
}

# ---------------------------------------------------------------------------------------------
#
# untie_bucket__
#
# Unties the matrix__ hash from the BerkeleyDB
#
# $bucket            The bucket name
#
# ---------------------------------------------------------------------------------------------
sub untie_bucket__
{
    my ( $self, $bucket ) = @_;

    undef $self->{db__}{$bucket};
    delete $self->{db__}{$bucket};
    untie %{$self->{matrix__}{$bucket}};
    delete $self->{matrix__}{$bucket};
}

# ---------------------------------------------------------------------------------------------
#
# load_bucket_
#
# Loads an individual bucket
#
# $bucket            The bucket name
#
# ---------------------------------------------------------------------------------------------
sub load_bucket_
{
    my ( $self, $bucket ) = @_;

    $bucket =~ /([[:alpha:]0-9-_]+)$/;
    $bucket =  $1;

    $self->{parameters__}{$bucket}{subject}    = 1;
    $self->{parameters__}{$bucket}{count}      = 0;
    $self->{parameters__}{$bucket}{quarantine} = 0;

    $self->{magnets__}{$bucket} = {};

    # See if there's a color file specified
    if ( open PARAMS, '<' . $self->config_( 'corpus' ) . "/$bucket/params" ) {
        while ( <PARAMS> )  {
            s/[\r\n]//g;
            if ( /^([[:lower:]]+) ([^\r\n\t ]+)$/ )  {
                $self->{parameters__}{$bucket}{$1} = $2;
            }
        }
        close PARAMS;
    } else {
        $self->write_parameters();
    }

    # See if there are magnets defined
    if ( open MAGNETS, '<' . $self->config_( 'corpus' ) . "/$bucket/magnets" ) {
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
                $self->{magnets__}{$bucket}{$type}{$value} = 1;
            } else {

                # This branch is used to catch the original magnets in an
                # old version of POPFile that were just there for from
                # addresses only

                if ( /^(.+)$/ ) {
                    my $value = $1;
                    $value =~ s/\\(\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/$1/g;
                    $self->{magnets__}{$bucket}{from}{$1} = 1;
                }
            }
        }
        close MAGNETS;
    }

    # This code performs two tasks:
    #
    # If there is an existing table.db in the bucket directory then simply
    # tie it to the appropriate hash.
    #
    # If there is no existing table but there is a table file (the old style
    # flat file used by POPFile for corpus storage) then create the new
    # tied hash from it thus performing an automatic upgrade.

    $self->tie_bucket__( $bucket );

    if ( -e $self->config_( 'corpus' ) . "/$bucket/table" ) {
        $self->log_( "Performing automatic upgrade of $bucket corpus from flat file to BerkeleyDB" );

        my $ft = $self->{full_total__};

        if ( open WORDS, '<' . $self->config_( 'corpus' ) . "/$bucket/table" )  {

            my $wc = 1;

            my $first = <WORDS>;
            if ( defined( $first ) && ( $first =~ s/^__CORPUS__ __VERSION__ (\d+)// ) ) {
                if ( $1 != $self->{corpus_version__} )  {
                    print STDERR "Incompatible corpus version in $bucket\n";
                    close WORDS;
                    return 0;
                } else {
   	            print "\nUpgrading bucket $bucket...";
                    flush STDOUT;

                    while ( <WORDS> ) {
		        if ( $wc % 100 == 0 ) {
                            print "$wc ";
                            flush STDOUT;
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

                print "(completed ", $wc-1, " words)";
                close WORDS;
            } else {
                close WORDS;
                return 0;
	    }
	}

        $self->untie_bucket__( $bucket );
        $self->tie_bucket__( $bucket );

        if ( open WORDS, '<' . $self->config_( 'corpus' ) . "/$bucket/table" )  {
            my $wc = 1;
            my $bucket_total   = 0;
            my $bucket_unique  = 0;
            my $upgrade_failed = 0;

            my $first = <WORDS>;
            if ( defined( $first ) && ( $first =~ s/^__CORPUS__ __VERSION__ (\d+)// ) ) {
                if ( $1 != $self->{corpus_version__} )  {
                    print STDERR "Incompatible corpus version in $bucket\n";
                    close WORDS;
                    return 0;
                } else {
   	            print "\nVerifying successful bucket upgrade of $bucket...";
                    flush STDOUT;

                    while ( <WORDS> ) {
		        if ( $wc % 100 == 0 ) {
                            print "$wc ";
                            flush STDOUT;
		        }
                        $wc += 1;
                        s/[\r\n]//g;

                        if ( /^([^\s]+) (\d+)$/ ) {
  			    if ( $2 != 0 ) {
    			        if ( $self->get_base_value_( $bucket, $1 ) != $2 ) {
                                    print "\nUpgrade error for word $1 in bucket $bucket.\nShutdown POPFile and rerun.\n";
                                    $upgrade_failed = 1;
                                    last;
			        }
                                $bucket_total  += $2;
                                $bucket_unique += 1;
			    }
                        } else {
                            $self->log_( "Found entry in corpus for $bucket that looks wrong: \"$_\" (ignoring)" );
                        }
		    }
                }

                close WORDS;

                if ( $bucket_total != $self->get_bucket_word_count( $bucket ) ) {
                    print "\nUpgrade error bucket $bucket word count is incorrect.\nShutdown POPFile and rerun.\n";
                    $upgrade_failed = 1;
		}
                if ( $bucket_unique != $self->get_bucket_unique_count( $bucket ) ) {
                    print "\nUpgrade error bucket $bucket unique count is incorrect.\nShutdown POPFile and rerun.\n";
                    $upgrade_failed = 1;
		}

                if ( $upgrade_failed ) {
                    $self->untie_bucket__( $bucket );
                    unlink( $self->config_( 'corpus' ) . "/$bucket/table.db" );
                    return 0;
		}

                print "(successfully verified ", $wc-1, " words)";
            } else {
                close WORDS;
                return 0;
	    }
	}

        unlink( $self->config_( 'corpus' ) . "/$bucket/table" );

        $self->{full_total__} = $ft;
    }

    $self->{full_total__} += $self->get_bucket_word_count( $bucket );

    $self->calculate_magnet_count__();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# calculate_magnet_count__
#
# Count the number of magnets currently defined and store in the magnet_count__
# variable for retrievable through magnet_count()
#
# ---------------------------------------------------------------------------------------------
sub calculate_magnet_count__
{
    my ($self) = @_;

    $self->{magnet_count__} = 0;

    for my $bucket (keys %{$self->{matrix__}}) {
        for my $type (keys %{$self->{magnets__}{$bucket}})  {
            for my $from (keys %{$self->{magnets__}{$bucket}{$type}})  {
                $self->{magnet_count__} += 1;
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# save_magnets__
#
# Save all the magnet definitions
#
# ---------------------------------------------------------------------------------------------
sub save_magnets__
{
    my ($self) = @_;

    for my $bucket (keys %{$self->{matrix__}}) {
        open MAGNET, '>' . $self->config_( 'corpus' ). "/$bucket/magnets";

        for my $type (keys %{$self->{magnets__}{$bucket}})  {
            for my $from (keys %{$self->{magnets__}{$bucket}{$type}})  {
                print MAGNET "$type $from\n";
            }
        }

        close MAGNET;
    }
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
    if ( $self->module_config_( 'html', 'language' ) =~ /^Nihongo|Korean$/ ) {
        no locale;
        @magnets = sort keys %{$self->{magnets__}{$bucket}{$type}};
    } else {
        @magnets = sort keys %{$self->{magnets__}{$bucket}{$type}};
    }

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

    # Pass language parameter to parse_file()

    $self->{magnet_used__}   = 0;
    $self->{magnet_detail__} = '';

    if ( defined( $file ) ) {
        $self->{parser__}->parse_file( $file, $self->module_config_( 'html', 'language' ) );
    }

    # Check to see if this email should be classified based on a magnet
    # Get the list of buckets

    my @buckets = keys %{$self->{matrix__}};

    for my $bucket (sort keys %{$self->{magnets__}})  {
        for my $type (sort keys %{$self->{magnets__}{$bucket}}) {
	    if ( $self->magnet_match__( $self->{parser__}->get_header($type), $bucket, $type ) ) {
                return $bucket;
            }
        }
    }

    # If the user has not defined any buckets then we escape here return unclassified
    return "unclassified" if ( $#buckets == -1 );

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

            my %types = get_magnet_types();

            foreach my $type ( keys %types ) {

                if (defined $qm{$type}) {
                    $i += 1;

                    $self->{scores__} .= "<tr><td scope=\"col\">$type: ";
                    $self->{scores__} .= "<select name=\"text$i\" id=\"\">\n";

                    foreach my $magnet ( @{$qm{$type}} ) {
                        $self->{scores__} .= "<option>$magnet</option>\n";
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

             if ($self->{wmformat__} eq 'score') {
                $rawstr = sprintf("%12.6f", ($raw_score{$b} - $correction)/$log10);
                $self->{scores__} .= "<tr>\n<td><font color=\"$self->{colors__}{$b}\"><b>$b</b></font></td>\n<td>&nbsp;</td>\n<td align=\"right\">$matchcount{$b}&nbsp;&nbsp;&nbsp;&nbsp;</td>\n<td align=right>$rawstr&nbsp;&nbsp;&nbsp;</td>\n<td>$probstr</td>\n</tr>\n";
             } else {
                $self->{scores__} .= "<tr>\n<td><font color=\"$self->{colors__}{$b}\"><b>$b</b></font></td>\n<td>&nbsp;</td>\n<td align=\"right\">$matchcount{$b}&nbsp;&nbsp;&nbsp;&nbsp;</td>\n<td>$probstr</td>\n</tr>\n";
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

    return ($path?$self->global_config_( 'msgdir' ):'') . "popfile$dcount" . "=$mcount" . (defined $ext?$ext:'.msg');
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

    open CLASS, '>' . $self->global_config_( 'msgdir' ) . $filename;

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

    if ( open CLASS, '<' . $self->global_config_( 'msgdir' ) . $filename ) {
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

    while ( <$mail> ) {
        my $line;
        my $fileline;

        $line = $_;

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

        last if ( ( $message_size > 100000 ) && ( $getting_headers == 0 ) );
    }

    close TEMP unless $nosave;

    # Parse Japanese mail message with Kakasi

    if ( $self->module_config_( 'html', 'language' ) eq 'Nihongo' ) {
        parse_with_kakasi( $self, $temp_file, $dcount, $mcount );
    }

    # If we don't yet know the classification then stop the parser
    if ( $class eq '' ) {
        $self->{parser__}->stop_parse();
    }

    # Do the text classification and update the counter for that bucket that we just downloaded
    # an email of that type

    $classification = ($class ne '')?$class:$self->classify(undef);
    my $modification = $self->config_( 'subject_mod_left' ) . $classification . $self->config_( 'subject_mod_right' );

    # Add the Subject line modification or the original line back again
    if ( ( $classification ne 'unclassified' ) && ( $classification ne 'unsure' ) ) {
        if ( $self->global_config_( 'subject' ) ) {
            # Don't add the classification unless it is not present
            if ( !( $msg_subject =~ /\Q$modification\E/ ) &&                        # PROFILE BLOCK START
                 ( $self->{parameters__}{$classification}{subject} == 1 ) &&
                 ( $self->{parameters__}{$classification}{quarantine} == 0 ) )  {   # PROFILE BLOCK STOP
                $msg_subject = " $modification$msg_subject";
            }
        }
    }

    $msg_head_before .= 'Subject:' . $msg_subject;
    $msg_head_before .= $crlf;

    # Add the XTC header
    $msg_head_after .= "X-Text-Classification: $classification$crlf" if ( ( $self->global_config_( 'xtc' ) ) && # PROFILE BLOCK START
                                                                         ( $self->{parameters__}{$classification}{quarantine} == 0 ) ); # PROFILE BLOCK STOP

    # Add the XPL header
    my $xpl = '';

    $xpl .= "http://";
    $xpl .= $self->module_config_( 'html', 'local' )?"127.0.0.1":$self->config_( 'hostname' );
    $xpl .= ":" . $self->module_config_( 'html', 'port' ) . "/jump_to_message?view=$nopath_temp_file$crlf";

    if ( $self->global_config_( 'xpl' ) && ( $self->{parameters__}{$classification}{quarantine} == 0 ) && ( !$nosave ) ) {
        $msg_head_after .= 'X-POPFile-Link: ' . $xpl;
    }

    $msg_head_after .= $msg_head_q . "$crlf";

    # Echo the text of the message to the client

    if ( $echo ) {

        # If the bucket is quarantined then we'll treat it specially by changing the message header to contain
        # information from POPFile and wrapping the original message in a MIME encoding

        if ( ( $classification ne 'unclassified' ) && ( $classification ne 'unsure' ) ) {
            if ( $self->{parameters__}{$classification}{quarantine} == 1 ) {
                print $client "From: " . $self->{parser__}->get_header( 'from' ) . "$crlf";
                print $client "To: " . $self->{parser__}->get_header( 'to' ) . "$crlf";
                print $client "Date: " . $self->{parser__}->get_header( 'date' ) . "$crlf";
                if ( $self->global_config_( 'subject' ) ) {
                    # Don't add the classification unless it is not present
                    if ( !( $msg_subject =~ /\[\Q$classification\E\]/ ) &&             # PROFILE BLOCK START
                         ( $self->{parameters__}{$classification}{subject} == 1 ) ) {  # PROFILE BLOCK STOP
                        $msg_subject = " $modification$msg_subject";
                    }
                }
                print $client "Subject:$msg_subject$crlf";
                print $client "X-Text-Classification: $classification$crlf" if ( $self->global_config_( 'xtc' ) );
                print $client 'X-POPFile-Link: ' . $xpl if ( $self->global_config_( 'xpl' ) && !$nosave );
                print $client "MIME-Version: 1.0$crlf";
                print $client "Content-Type: multipart/report; boundary=\"$nopath_temp_file\"$crlf$crlf--$nopath_temp_file$crlf";
                print $client "Content-Type: text/plain$crlf$crlf";
                print $client "POPFile has quarantined a message.  It is attached to this email.$crlf$crlf";
                print $client "Quarantined Message Detail$crlf$crlf";
                print $client "Original From: " . $self->{parser__}->get_header('from') . "$crlf";
                print $client "Original To: " . $self->{parser__}->get_header('to') . "$crlf";
                print $client "Original Subject: " . $self->{parser__}->get_header('subject') . "$crlf";
                print $client "To examine the email open the attachment. ";
                print $client "To change this mail's classification go to $xpl" unless $nosave;
                print $client "$crlf";
                print $client "The first 20 words found in the email are:$crlf$crlf";
                print $client $self->{parser__}->first20();
                print $client "$crlf--$nopath_temp_file$crlf";
                print $client "Content-Type: message/rfc822$crlf$crlf";
            }
        }

        print $client $msg_head_before;
        print $client $msg_head_after;
        print $client $msg_body;
    }

    my $before_dot = '';

    if ( ( $classification ne 'unclassified' ) && ( $classification ne 'unsure' ) ) {
        if ( ( $self->{parameters__}{$classification}{quarantine} == 1 ) && $echo ) {
            $before_dot = "$crlf--$nopath_temp_file--$crlf";
        }
    }

    if ( !$got_full_body ) {
        $self->echo_to_dot_( $mail, $echo?$client:undef, $nosave?undef:'>>' . $temp_file, $before_dot );
    } else {
        print $client $before_dot if ( $before_dot ne '' );
    }

    if ( $echo && $got_full_body ) {
        print $client "$crlf.$crlf";
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
# Returns a list containing all the bucket names sorted into alphabetic order
#
# ---------------------------------------------------------------------------------------------
sub get_buckets
{
    my ( $self ) = @_;

    return sort keys %{$self->{matrix__}};
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

    my $total = $self->{matrix__}{$bucket}{__POPFILE__TOTAL__};

    return defined( $total )?$total:0;
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

    return grep {/^$prefix/} grep {!/^__POPFILE__/} keys %{$self->{matrix__}{$bucket}};
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

    # In Japanese mode, disable locale and use substr_euc, the substr function
    # which supports EUC Japanese charset.
    # Sorting Japanese with "use locale" is memory and time consuming,
    # and may cause perl crash.

    if ( $self->module_config_( 'html', 'language' ) eq 'Nihongo' ) {
        no locale;
        return grep {$_ ne $prev && ($prev = $_, 1)} sort map {substr_euc($_,0,1)} grep {!/^__POPFILE__/} keys %{$self->{matrix__}{$bucket}};
    } else {
        if  ( $self->module_config_( 'html', 'language' ) eq 'Korean' ) {
    	    no locale;
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {$_ =~ /([\x20-\x80]|$eksc)/} grep {!/^__POPFILE__/} keys %{$self->{matrix__}{$bucket}};
        } else {
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {substr($_,0,1)} grep {!/^__POPFILE__/} keys %{$self->{matrix__}{$bucket}};
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# substr_euc
#
# "substr" function which supports EUC Japanese charset
#
# $pos      Start position
# $len      Word length
#
# ---------------------------------------------------------------------------------------------
sub substr_euc {
    my ($str, $pos, $len) = @_;
    my $result_str;
    my $char;
    my $count=0;
    if(!$pos) { $pos=0; }
    if(!$len) { $len=length($str); }
    for ($pos = 0; $count<$len; $pos++) {
        $char = substr($str, $pos, 1);
        if ($char =~ /[\x80-\xff]/) { $char = substr($str, $pos++, 2); }
        $result_str .= $char;
        $count++;
    }
    return $result_str;
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

    return $self->{full_total__};
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

    return $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__};
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

    my $color = $self->{colors__}{$bucket};

    return defined( $color )?$color:'black';
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

    $self->{colors__}{$bucket} = $color;
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

    my $param = $self->{parameters__}{$bucket}{$parameter};

    if ( !defined( $param ) ) {
        $param = 0;
    }

    return $param;
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

    $self->{parameters__}{$bucket}{$parameter} = $value;
    $self->write_parameters();
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

    my $result = $self->{parser__}->parse_file( $file, $self->module_config_( 'html', 'language' ) );

    $self->{parser__}->{color__} = 0;

    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# create_bucket
#
# Creates a new bucket
#
# $bucket          Name for the new bucket
#
# ---------------------------------------------------------------------------------------------
sub create_bucket
{
    my ( $self, $bucket ) = @_;

    mkdir( $self->config_( 'corpus' ) );
    mkdir( $self->config_( 'corpus' ) . "/$bucket" );

    $self->tie_bucket__( $bucket );
    $self->untie_bucket__( $bucket );
    $self->load_word_matrix_();
}

# ---------------------------------------------------------------------------------------------
#
# delete_bucket
#
# Deletes a bucket
#
# $bucket          Name of the bucket to delete
#
# ---------------------------------------------------------------------------------------------
sub delete_bucket
{
    my ( $self, $bucket ) = @_;

    if ( !defined( $self->{matrix__}{$bucket} ) ) {
        return 0;
    }

    $self->close_database__();
    $self->delete_bucket_files__( $bucket );
    $self->load_word_matrix_();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# delete_bucket_files__
#
# Helper that removes the files associated with a bucket
#
# $bucket          The bucket to tidy up
#
# ---------------------------------------------------------------------------------------------
sub delete_bucket_files__
{
    my ( $self, $bucket ) = @_;
    my $bucket_directory = $self->config_( 'corpus' ) . "/$bucket";

    unlink( "$bucket_directory/table.db" );
    unlink( "$bucket_directory/table" );
    unlink( "$bucket_directory/color" );
    unlink( "$bucket_directory/params" );
    unlink( "$bucket_directory/magnets" );
    unlink( "$bucket_directory/delete" );
    rmdir( $bucket_directory );

    # If the bucket directory still exists then it indicates that the
    # table was open in another process.  We create a special file
    # called 'delete' which if present will cause the loader to try
    # to delete the bucket

    if ( -e $bucket_directory ) {
        open DELETER, ">$bucket_directory/delete";
        print DELETER "Special file used by POPFile to indicate that this bucket is to be deleted\n";
        close DELETER;
    }
}

# ---------------------------------------------------------------------------------------------
#
# rename_bucket
#
# Renames a bucket
#
# $old_bucket          The old name of the bucket
# $new_bucket          The new name of the bucket
#
# ---------------------------------------------------------------------------------------------
sub rename_bucket
{
    my ( $self, $old_bucket, $new_bucket ) = @_;

    if ( !defined( $self->{matrix__}{$old_bucket} ) ) {
        return 0;
    }

    $self->close_database__();

    rename($self->config_( 'corpus' ) . "/$old_bucket" , $self->config_( 'corpus' ) . "/$new_bucket");

    $self->load_word_matrix_();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# add_messages_to_bucket
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

    # Verify that the bucket exists.  You must call create_bucket before this
    # when making a new bucket.

    if ( !defined( $self->{matrix__}{$bucket} ) ) {
        return 0;
    }

    # Pass language parameter to parse_file()

    foreach my $file (@files) {
        $self->{parser__}->parse_file( $file, $self->module_config_( 'html', 'language' ) );
        $self->add_words_to_bucket__( $bucket, 1 );
    }

    $self->load_word_matrix_();

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

    # Verify that the bucket exists.  You must call create_bucket before this
    # when making a new bucket.

    if ( !defined( $self->{matrix__}{$bucket} ) ) {
        return 0;
    }

    # Pass language parameter to parse_file()

    $self->{parser__}->parse_file( $file, $self->module_config_( 'html', 'language' ) );

    $self->add_words_to_bucket__( $bucket, -1 );
    $self->load_word_matrix_();

    return 1;
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
# ---------------------------------------------------------------------------------------------
sub echo_to_dot_
{
    my ( $self, $mail, $client, $file, $before ) = @_;

    my $isopen = open FILE, "$file" if ( defined( $file ) );

    while ( <$mail> ) {

        # Check for an abort

        last if ( $self->{alive_} == 0 );

        # The termination has to be a single line with exactly a dot on it and nothing
        # else other than line termination characters.  This is vital so that we do
        # not mistake a line beginning with . as the end of the block

        if ( /^\.(\r\n|\r|\n)$/ ) {
            if ( defined( $before ) && ( $before ne '' ) ) {
                print $client $before if ( defined( $client ) );
                print FILE    $before if ( defined( $isopen ) );
            }

            # Note that there is no print FILE here.  This is correct because we
            # do no want the network terminator . to appear in the file version
            # of any message

            print $client $_ if ( defined( $client ) );
            last;
        }

        print $client $_ if ( defined( $client ) );
        print FILE    $_ if ( defined( $isopen ) );

    }

    close FILE if ( $isopen );
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

    my @buckets;

    foreach my $b (sort keys %{$self->{magnets__}}) {
        my @keys = keys %{$self->{magnets__}{$b}};

        if ( $#keys >= 0 ) {
            push @buckets, ($b);
        }
    }

    return @buckets;
}

# ---------------------------------------------------------------------------------------------
#
# get_magnet_types_in_bucket
#
# Returns the types of the magnetsd in a specific bucket
#
# $bucket          The bucket to search for magnets
#
# ---------------------------------------------------------------------------------------------
sub get_magnet_types_in_bucket
{
    my ( $self, $bucket ) = @_;

    return sort keys %{$self->{magnets__}{$bucket}};
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

    foreach my $word (keys %{$self->{matrix__}{$bucket}}) {
        delete $self->{matrix__}{$bucket}{$word};
    }

    $self->{matrix__}{$bucket}{__POPFILE__TOTAL__}      = 0;
    $self->{matrix__}{$bucket}{__POPFILE__UNIQUE__}     = 0;

    $self->load_word_matrix_();
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

    delete $self->{magnets__};
    $self->calculate_magnet_count__();
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

    # In Japanese mode, disable locale.
    # Sorting Japanese with "use locale" is memory and time consuming,
    # and may cause perl crash.

    # Disable the locale in Korean mode, too.

    if ( $self->module_config_( 'html', 'language' ) =~ /^Nihongo|Korean$/ ) {
        no locale;
        return sort keys %{$self->{magnets__}{$bucket}{$type}};
    } else {
        return sort keys %{$self->{magnets__}{$bucket}{$type}};
    }
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

    $self->{magnets__}{$bucket}{$type}{$text} = 1;
    $self->save_magnets__();
    $self->calculate_magnet_count__();
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
    return ( 'from'    => 'From',  # PROFILE BLOCK START
             'to'      => 'To',
             'subject' => 'Subject',
             'cc'      => 'Cc' );  # PROFILE BLOCK STOP
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

    delete $self->{magnets__}{$bucket}{$type}{$text};

    # Now check to see if there are any magnets left of that type

    my @keys = keys %{$self->{magnets__}{$bucket}{$type}};
    if ( $#keys == -1 ) {
        delete $self->{magnets__}{$bucket}{$type};

        # Now check to see if this bucket has any magnets

        @keys = keys %{$self->{magnets__}{$bucket}};

        if ( $#keys == -1 ) {
            delete $self->{magnets__}{$bucket};
	}
    }

    $self->save_magnets__();
    $self->calculate_magnet_count__();
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

sub magnet_count
{
    my ( $self ) = @_;

    return $self->{magnet_count__};
}

# ---------------------------------------------------------------------------------------------
#
# parse_with_kakasi
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
sub parse_with_kakasi
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

sub wmformat
{
    my ( $self, $value ) = @_;

    $self->{wmformat__} = $value if (defined $value);
    return $self->{wmformat__};
}

1;

