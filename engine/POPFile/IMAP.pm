# POPFILE LOADABLE MODULE
package POPFile::IMAP;
use POPFile::Module;
@ISA = ("POPFile::Module");

# ---------------------------------------------------------------------------------------------
#
# IMAP.pm --- a module to use POPFile for an IMAP connection.
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
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
#   Originally created by   Manni Heumann (mannih2001@users.sourceforge.net)
#   Modified by             Sam Schinke (sschinke@users.sourceforge.net)
#   many helpful hints by   David Lang (davidlang@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------


use IO::Socket;
use Digest::MD5 qw( md5_hex );
use strict;
use warnings;
use locale;

my $eol = "\015\012";
my $cfg_separator = "-->";

#############################################################################################
# ToDo:
#
# * the password is stored in plain text in popfile.cfg.
# * Improve handling of errors. What shall we do with failed connections, denied logins, etc?
# * Implement forking.
# * Move hash values to db.
#############################################################################################




#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------

sub new
{
    my $type = shift;
    my $self = POPFile::Module->new();

    bless $self, $type;

    $self->name( 'imap' );

    $self->{classifier__}     = 0;

    # Here are the variables used by this module:

    # A place to store the last response that the IMAP server sent us
    $self->{last_response__} = '';

    # The tag that preceeds any command we sent, actually just a simple counter var
    $self->{tag__} = '';

    # A list of mailboxes on the server:
    $self->{mailboxes__} = [];

    # The session id for the current session:
    $self->{api_session__} = '';

    # An object var to hold our socket object
    # This will only get used in service(), start(), and stop()
    # All other functions will use their own variables/copies.
    $self->{imap__} = '';

    # A hash to map hash values of messages to buckets.
    $self->{hash_to_bucket__} = ();

    # A hash to map hash values to history file names.
    $self->{hash_to_history__} = ();

    # A hash to identify reclassified messages
    $self->{hash_to_reclassed__} = ();

    # This variable controls the amount of information that goes
    # to the logfile:
    # 0: basic information, quiet
    # 1: + commands + OK/BAD/NO responses
    # 2: + untagged server responses
    # 3: + each server response
    $self->{debug__} = 0;

    return $self;
}



# ---------------------------------------------------------------------------------------------
#
# initialize
#
# ---------------------------------------------------------------------------------------------

sub initialize
{
    my ( $self ) = @_;

    $self->config_( 'hostname', '' );
    $self->config_( 'port', 143 );
    $self->config_( 'login', '' );
    $self->config_( 'password', '' );
    $self->config_( 'update_interval', 20 );
    $self->config_( 'byte_limit', 0 );
    $self->config_( 'debug_level', $self->{debug__} );
    $self->config_( 'expunge', 0 );

    # Those next variables have getter/setter functions and should
    # not be used directly:

    $self->config_( 'watched_folders', "INBOX" );     # function watched_folders
    $self->config_( 'bucket_folder_mappings', '' );   # function folder_for_bucket
    $self->config_( 'uidvalidities', '' );            # function uid_validity
    $self->config_( 'uidnexts', '' );                 # function uid_next

    # Diabled by default
    $self->config_( 'enabled', 0 );

    # Set the time stamp for the last update to the current time
    # minus the update interval so that we will connect as soon
    # as service() is called for the first time.
    $self->{last_update__} = time - $self->config_( 'update_interval' );

    return $self->SUPER::initialize();
}




# ---------------------------------------------------------------------------------------------
#
# Start. Get's called by the loader and makes us run.
#
#   We try to connect to our IMAP server here, and get a list of
#   folders / mailboxes, so we can populate the configuration UI.
#
# ---------------------------------------------------------------------------------------------

sub start
{
    my ( $self ) = @_;

    if ( $self->config_( 'enabled' ) == 0 ) {
        return 2;
    }

    $self->register_configuration_item_( 'configuration',
                                         'imap_0_connection_details',
                                         'imap-connection-details.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_1_watch_folders',
                                         'imap-watch-folders.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_2_watch_more_folders',
                                         'imap-watch-more-folders.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_3_bucket_folders',
                                         'imap-bucket-folders.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_4_update_mailbox_list',
                                         'imap-update-mailbox-list.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_5_update_interval',
                                         'imap-update-interval.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_6_byte_limit',
                                         'imap-byte-limit.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                         'imap_7_debug_level',
                                         'imap-debug-level.thtml',
                                         $self );

    $self->register_configuration_item_( 'configuration',
                                          'imap_8_expunge',
                                          'imap-expunge.thtml',
                                          $self );

    # Read the class files for all messages in history
    # and retrieve hashes and classifications
    $self->read_cls_files__();

    $self->{imap__} = $self->connect( $self->config_( 'hostname' ), $self->config_( 'port' ) );

    if ( defined $self->{imap__} ) {
        if ( $self->login( $self->{imap__} ) ) {
            $self->get_mailbox_list( $self->{imap__} );
        }
    }
    else {
        $self->{imap__} = '';
    }

    return $self->SUPER::start();
}



# ---------------------------------------------------------------------------------------------
# stop
#
#   Not much to do here. Simply log out.
#
# ---------------------------------------------------------------------------------------------

sub stop
{
    my ( $self ) = @_;

    # Logout
    if ( $self->{imap__} ne '' ) {
        $self->say( $self->{imap__}, "LOGOUT" );
        $self->get_response( $self->{imap__} );
    }

    if ( $self->{api_session__} ne '' ) {
        $self->{classifier__}->release_session_key( $self->{api_session__} );
    }
}



# ---------------------------------------------------------------------------------------------
#
# service
#
#   This get's frequently called by the framework.
#   It checks whether our checking interval has elapsed and if it has
#   it goes to work.
#
# ---------------------------------------------------------------------------------------------

sub service
{
    my ( $self ) = @_;

    if ( time - $self->{last_update__} >= $self->config_( 'update_interval' ) ) {

        # Check to see if we have obtained a session key yet
        if ( $self->{api_session__} eq '' ) {
            $self->{api_session__} = $self->{classifier__}->get_session_key( 'admin', '' );
        }

        # Update the cached debug_level value
        $self->{debug__} = $self->config_( 'debug_level' );

        # Check whether we already have an open connection. If not, connect and login
        if ( $self->{imap__} eq '' ) {
            $self->{imap__} = $self->connect( $self->config_( 'hostname' ), $self->config_( 'port' ) );

            if ( defined $self->{imap__} ) {
                unless ( $self->login( $self->{imap__} ) ) {
                    $self->{imap__} = '';
                }
            }
            else {
                $self->{imap__} = '';
            }
        }
        # Since say() as well as get_response() can throw an exception, i.e. die if
        # they detect a lost connection, we eval the following code to be able
        # to catch the exception
        eval {
            local $SIG{'PIPE'} = 'IGNORE';
            local $SIG{'__DIE__'};
            # Do the real job now that we have a connection
            if ( $self->{imap__} ne '' ) {

                # First classfiy messages found in one of our watched folders
                $self->check_for_new_messages__( $self->{imap__} );

                # Now check for messages that might have to be reclassified.
                $self->reclassify_on_move__( $self->{imap__} );
            }
            # Or complain
            else {
                $self->log_( "No valid IMAP connection; cannot check for new messages." );
            }
        };
        if ( $@ ) {
            if ( $@ =~ /The connection to the IMAP server was lost/ ) {
                $self->log_( $@ );
            }
            else {
                die $@;
            }
        }
        # Save the current time.
        $self->{last_update__} = time;
    }

    return 1;
}



# ---------------------------------------------------------------------------------------------
#
# check_for_new_messages__
#
#   Checks whether there are any new messages in our watched folders.
#   If such messages are found, they are classified and moved to the output
#   folders if we haven't seen them before.
#
# Arguments:
#
#   $imap: The connection to the server.
#
# ---------------------------------------------------------------------------------------------

sub check_for_new_messages__
{
    my ( $self, $imap ) = @_;

    FOLDER:
    foreach my $folder ( $self->watched_folders__() ) {

        $self->log_( "Looking for new messages in folder $folder." );

        # First, check that our UIDs are valid
        unless ( $self->folder_uid_status__( $imap, $folder ) ) {
            $self->log_( "Changed UIDVALIDITY, will not check for new messages in folder $folder." );
            next;
        }

        # Change to folder and search for new messages
        my $old_next = $self->uid_next__( $folder );
        $self->say( $imap, "SELECT \"$folder\"" );
        if ( $self->get_response( $imap ) != 1 ) {
            $self->log_( "Could not SELECT folder $folder." );
            next;
        }
        my @uids = $self->get_uids_ge( $imap, $old_next );

        my $moved_a_msg = 0;

        # Now loop over each message
        MESSAGE:
        foreach my $msg ( @uids ) {

            $self->log_( "" );
            $self->log_( "Found new message $msg in folder $folder." );
            # get hash of this message
            my $hash = $self->get_hash( $imap, $msg );

            # don't touch messages that were classified before
            unless ( $self->can_classify__( $hash ) ) {
                $self->log_( "Message $msg was classified before." );
                $self->log_( "" );
                next;
            }

            # open a memory file that the classifier will
            # use to read the message in binary, read-write mode:
            my $pseudo_mailer;
            unless ( open $pseudo_mailer, "+>:bytes", undef ) {
                $self->log_( "Unable to open memory file. Nothing done to message $msg." );
                $self->log_( "" );
                next;
            }

            # We don't retrieve the complete message, but handle
            # it in different parts.
            # Currently these parts are just headers and body.
            # But there is room for improvement here.
            # E.g. we could generate a list of parts by
            # first looking at the parts the message really has.

            my @message_parts = qw/HEADER TEXT/;

            PART:
            foreach my $part ( @message_parts ) {

                my @lines = $self->fetch_message_part( $imap, $msg, $part );

                unless ( @lines ) {
                    $self->log_( "Could not fetch the $part part of message $msg." );
                    $self->log_( "" );
                    next MESSAGE;
                }

                foreach ( @lines ) {
                    print $pseudo_mailer "$_";
                }

                my ( $class, $history_file, $magnet_used );

                # If we are dealing with the headers, let the
                # classifier have a non-save go:

                if ( $part eq 'HEADER' ) {
                    seek $pseudo_mailer, 0, 0;
                    ( $class, $history_file, $magnet_used ) = $self->{classifier__}->classify_and_modify( $self->{api_session__}, $pseudo_mailer, undef, $self->global_config_( 'download_count' ), $msg, 1, '', 0 );

                    if ( $magnet_used ) {
                        $self->log_( "Message $history_file was classified as $class using a magnet." );
                        print $pseudo_mailer "\nThis message was classified based on a magnet. The body of the message was not retrieved from the server.\n";
                    }
                    else {
                        next PART;
                    }
                }

                # We will only get here if the message was magnetized or we
                # are looking at the complete message. Thus we let the classifier have
                # a look and make it save the message to history:
                seek $pseudo_mailer, 0, 0;
                ( $class, $history_file, $magnet_used ) = $self->{classifier__}->classify_and_modify( $self->{api_session__}, $pseudo_mailer, undef, $self->global_config_( 'download_count' ), $msg, 0, '', 0 );
                close $pseudo_mailer;

                if ( $magnet_used || $part eq 'TEXT' ) {

                    # Move message:

                    my $destination = $self->folder_for_bucket__( $class );
                    if ( defined $destination ) {
                        if ( $folder ne $destination ) {
                            $self->move_message( $imap, $msg, $destination );
                            $moved_a_msg = 1;
                        }
                    }
                    else {
                        $self->log_( "Message can not be moved because output folder for bucket $class is not defined." );
                    }


                    # Housekeeping:

                    # Inform the rest of POPFile about a new message in history.
                    $self->mq_post_( 'NEWFL', $history_file , '' );
                    $self->log_( "Message $history_file was classified as $class." );
                    $self->log_( "" );

                    # Update the UIDNEXT value for this folder. Since $msg contains
                    # the uid of the message we just classified, we simply set that
                    # value to $msg+1
                    $self->uid_next__( $folder, $msg + 1 );

                    # Remember hash of this message in history, etc:
                    $self->was_classified__( $hash, $class, $history_file );

                    next MESSAGE;
                }
            }
        }
        if ( $self->config_( 'expunge' ) && $moved_a_msg ) {
            $self->say( $imap, "CLOSE" );
            $self->get_response( $imap );
        }
    }
}









# ---------------------------------------------------------------------------------------------
#
# reclassify_on_move__
#
#   This function goes through each output/bucket folder and looks for new messages.
#   If there is a new message and if we already know the message, the message
#   is reclassified to the bucket corresponding to the folder the message was found in.
#   Messages we don't know are simply ignored
#
# Arguments:
#   $imap:  The connection to our server.
# ---------------------------------------------------------------------------------------------

sub reclassify_on_move__
{
    my ( $self, $imap ) = @_;

    # check whether there are any messages that the user moved
    # to one of our output folders to request reclassification:

    foreach my $bucket ( $self->{classifier__}->get_buckets( $self->{api_session__} ) ) {

        my $folder = $self->folder_for_bucket__( $bucket );

        # We have to be careful if an output folder is also a watched folder
        # Simply incrementing our UIDNEXT value for each message we
        # look at isn't good enough in this case. It might be a new
        # message that came in after check_for_new_messages had a look at the folder.
        # That's why we keep track of the number of completely new messages and
        # why we update our UIDNEXT value only after we are done with the
        # current folder.

        my $new_messages = 0;
        my $highest_uid = 0;

        # If the user has not yet configured a folder for this bucket, do nothing
        if ( ! defined $folder ) {
            next;
        }

        $self->log_( "Looking for reclassification requests in folder $folder." );

        # Check that our UIDs are valid
        unless ( $self->folder_uid_status__( $imap, $folder ) ) {
            $self->log_( "Changed UIDVALIDITY, will not check for new messages in folder $folder." );
            next;
        }

        my $old_next = $self->uid_next__( $folder );
        $self->say( $imap, "SELECT \"$folder\"" );
        unless ( $self->get_response( $imap ) == 1 ) {
            $self->log_( "Could not SELECT folder $folder!" );
            next;
        }

        # Get a list of UIDs greater than our old_next value.
        my @uids = $self->get_uids_ge( $imap, $old_next );

        if ( $#uids > -1 ) {
            $highest_uid = $uids[$#uids];
        }
        else {
            $highest_uid = $old_next;
        }

        foreach my $msg ( @uids ) {
            $self->log_( "" );
            $self->log_( "Found possible reclassification request $msg in folder $folder." );
            my $hash = $self->get_hash( $imap, $msg );

            if ( my $old_bucket = $self->can_reclassify__( $hash, $bucket ) ) {

                my @lines = $self->fetch_message_part( $imap, $msg, '' );

                # We have to write the message to a temporary file.
                # I simply use "imap.tmp" as the file name here.

                unless ( open TMP, ">imap.tmp" ) {
                    $self->log( "Cannot open temp file imap.tmp" );
                    next;
                };
                foreach ( @lines ) {
                    print TMP "$_\n";
                }
                close TMP;

                # This is copied from html.pm
                # It (hopefully) keeps our statistics up to date.
                my $count = $self->{classifier__}->get_bucket_parameter( $self->{api_session__}, $bucket, 'count' );
                $self->{classifier__}->set_bucket_parameter( $self->{api_session__}, $bucket, 'count', $count+1 );

                $count = $self->{classifier__}->get_bucket_parameter( $self->{api_session__}, $old_bucket, 'count' );
                $count -= 1;
                $count = 0 if ( $count < 0 ) ;
                $self->{classifier__}->set_bucket_parameter( $self->{api_session__}, $old_bucket, 'count', $count );

                my $fncount = $self->{classifier__}->get_bucket_parameter( $self->{api_session__}, $bucket, 'fncount' );
                $self->{classifier__}->set_bucket_parameter( $self->{api_session__}, $bucket, 'fncount', $fncount+1 );

                my $fpcount = $self->{classifier__}->get_bucket_parameter( $self->{api_session__}, $old_bucket, 'fpcount' );
                $self->{classifier__}->set_bucket_parameter( $self->{api_session__}, $old_bucket, 'fpcount', $fpcount+1 );

                $self->{classifier__}->add_message_to_bucket( $self->{api_session__}, $bucket, "imap.tmp" );
                $self->{classifier__}->remove_message_from_bucket( $self->{api_session__}, $old_bucket, "imap.tmp" );

                $self->mq_post_( 'NEWFL', $self->get_msg_file__( $hash ), '' );

                $self->log_( "Reclassified the message with UID $msg in folder $folder from bucket $old_bucket to bucket $bucket." );
                $self->log_( "" );
                unlink "imap.tmp";

                $self->was_reclassified__( $hash, $bucket );
            }
            else {
                # Perhaps this message couldn't be reclassified because it is completely
                # new and was thus never classified in the first place?
                if ( $self->can_classify__( $hash ) ) {
                    $new_messages++;
                    $self->log_( "Found a new message while looking for reclassification requests." );
                }
                $self->log_( "Did not reclassify message." );
                $self->log_( "" );
            }
        }
        # Update stored UIDNEXT value for this folder:
        if ( $new_messages ) {
            $self->log_( "Found $new_messages new messages in folder $folder" );
        }
        else {
            $self->uid_next__( $folder, $highest_uid + @uids );
        }
    }
}








# ---------------------------------------------------------------------------------------------
#
# folder_uid_status__
#
#   This function checks the UID status of a given folder on the server.
#   To this end, we query for the UIDVALIDITY and UIDNEXT values.
#   If UIDVALIDITY has changed (or there was no previous value), both
#   values are stored and the function returns undef.
#   If the UIDVALIDITY value matches the stored value, nothing is stored
#   and we return true;
#
# arguments:
#
#   $imap:          The connection to our server.
#   $folder:        The name of the folder to be inspected.
#
# ---------------------------------------------------------------------------------------------

sub folder_uid_status__
{
    my ( $self, $imap, $folder ) = @_;

    $self->log_( "Checking UIDVALIDITY of folder $folder" ) if $self->{debug__};

    $self->say( $imap, "STATUS $folder (UIDVALIDITY UIDNEXT)" );
    my $response = $self->get_response( $imap );

    if ( $response == 1 ) {

        my $old_val = $self->uid_validity__( $folder );
        my @lines = split /$eol/, $self->{last_response__};

        my $uidvalidity;
        my $uidnext;

        foreach ( @lines ) {
            my $line = $_;

            # We are only interested in untagged responses to the STATUS command
            next unless $line =~ /\* STATUS/;

            $line =~ /UIDVALIDITY (.+?)( |\))/i;
            $uidvalidity = $1;

            $line =~ /UIDNEXT (.+?)( |\))/i;
            $uidnext = $1;
        }

        # if we didn't get one of the values, we have a problem

        unless ( defined $uidvalidity && defined $uidnext ) {
            $self->log_( "Could not retrieve UID status values from server!" );
            return;
        }

        if ( defined $old_val ) {

            # we are in business only if the old and new uidvalidity values match
            # If this is not the case, we return an error and store the current
            # UIDNEXT value.
            if ( $uidvalidity != $old_val ) {
                $self->uid_next__( $folder, $uidnext );
                $self->uid_validity__( $folder, $uidvalidity );
                $self->log_( "UIDVALIDITY has changed! Expected $old_val, got $uidvalidity." );
                return;
            }
        }
        # if we haven't got a valid validity value yet, then this
        # must be a new folder for us and we simply update the value
        # we also return an error here.
        # We could also set the UIDNEXT value of this folder to 0 and
        # process everything that we find, but that doesn't sound like
        # a very good idea.
        else {
            $self->uid_next__( $folder, $uidnext );
            $self->uid_validity__( $folder, $uidvalidity );
            $self->log_( "Updated folder status (UIDVALIDITY and UIDNEXT) for folder $folder." );
            return;
        }

        return 1;
    }

    return;
}




# ---------------------------------------------------------------------------------------------
#
# connect
#
#   Get host and port from the configuration information and
#   connect.
#   Return the socket on sucess or undef on failure
#
# ---------------------------------------------------------------------------------------------

sub connect
{
    my ( $self, $hostname, $port ) = @_;

    $self->log_( "Connecting to $hostname:$port" );

    if ( $hostname ne '' && $port ne '' ) {

        my $response = '';
        my $imap = IO::Socket::INET->new(
                                Proto    => "tcp",
                                PeerAddr => $hostname,
                                PeerPort => $port,
                                Timeuut  => $self->global_config_( 'timeout' )
                                         );


        # Check that the connect succeeded for the remote server
        if ( $imap ) {
            if ( $imap->connected )  {
                $self->log_( "Connected to $hostname:$port timeout " . $self->global_config_( 'timeout' ) );

                # Set binmode on the socket so that no translation of CRLF
                # occurs

                binmode( $imap );

                # Wait for a response from the remote server and if
                # there isn't one then give up trying to connect

                my $selector = new IO::Select( $imap );
                unless ( () = $selector->can_read($self->global_config_( 'timeout' )) ) {
                    return;
                }

                # Read the response from the real server
                my $buf = $self->slurp_( $imap );

                return $imap;
            }
        }
    }
    else {
        $self->log_( "Invalid port or hostname. Will not connect to server." );
        return;
    }
}






# ---------------------------------------------------------------------------------------------
#
# login
#
#   log in to the server we are currently connected to.
#
# Arguments:
#   $imap: a valid socket object
#
# Return values:
#  0 on failure
#  1 on success
# ---------------------------------------------------------------------------------------------

sub login
{
    my ( $self, $imap ) = @_;
    my ( $login, $pass ) = ( $self->config_( 'login' ), $self->config_( 'password' ) );

    $self->log_( "logging in" );

    $self->{tag__} = 0;
    $self->say( $imap, "LOGIN \"$login\" \"$pass\"" );

    if ( $self->get_response( $imap ) == 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}





# ---------------------------------------------------------------------------------------------
#
# say
#
#   Issue a command to the server we are connected to.
#
# Arguments:
#
#   $imap: the valid socket object
#   $command: What you want to say to the server without the tag, though.
#
# The tag for the current command comes from $self->{tag__}, which get incremented
# as soon as the response is in.
# ---------------------------------------------------------------------------------------------

sub say
{
    my ( $self, $imap, $command ) = @_;

    my $cmdstr = sprintf "A%02d %s", $self->{tag__}, $command;

    unless( print $imap $cmdstr, $eol ) {
        $self->{imap__} = '';
        die( "The connection to the IMAP server was lost. Could not talk to the server." );
    }

    # Log command
    if ( $self->{debug__} ) {
        # Obfuscate login and password for logins:
        $cmdstr =~ s/ LOGIN ".+?" ".+"$/ LOGIN "xxxxx" "xxxxx"/;
        $self->log_( "<< $cmdstr" );
    }
}


# ---------------------------------------------------------------------------------------------
#
# get_response
#
#   retrieves a response from the passed in socket and then increments the tag counter
#   The response is placed in $self->{last_response__}.
#
#   Return values:
#   1: Server said OK to our last command
#   0: Server said NO to our last command
#  -1: Server said BAD to our last command
#  -2: Server said something else or reponded to another command
#  -3: Server didn't say anything
# ---------------------------------------------------------------------------------------------

sub get_response
{
    my ( $self, $imap ) = @_;

    # What is the actual tag we have to look for?
    my $actualTag = sprintf "A%02d", $self->{tag__};

    my $response = '';
    my $count_octets = 0;
    my $octet_count = 0;

    # Slurp until we find a reason to quit
    while ( my $buf = $self->slurp_( $imap ) ) {

        # Check for lost connections:
        if ( $response eq '' && ! defined $buf ) {
            $self->{imap__} = '';
            die( "The connection to the IMAP server was lost. Could not listen to the server." );
        }

        # If this is the first line of the response and
        # if we find an octet count in curlies before the
        # newline, then we will rely on the octet count

        if ( $response eq '' && $buf =~ m/{(\d+)}$eol/ ) {

            # Add the length of the first line to the
            # octet count provided by the server

            $count_octets = $1 + length( $buf );
        }

        $response .= $buf;

        if ( $count_octets ) {
            $octet_count += length $buf;

            # There doesn't seem to be a requirement for the message to end with
            # a newline. So we cannot go for equality

            if ( $octet_count >= $count_octets ) {
                $count_octets = 0;
            }
        }

        # If we aren't counting octets (anymore), we look for out tag
        # followed by BAD, NO, or OK
        if ( $count_octets == 0 ) {
            if ( $buf =~ /^$actualTag (OK|BAD|NO)/ ) {
                last;
            }
        }
    }

    # Look at what we've got.
    # Do logging and determine our return value
    if ( $response ) {

        # save result away so we can always have a look later on
        $self->{last_response__} = $response;

        # Log the result

        if ( $self->{debug__} ) {

            # RegExp that determines what to log according to the debug level
            my $re = '';

            if ( $self->{debug__} == 1 ) {
                $re = '\d (OK|BAD|NO)';
            }
            elsif ( $self->{debug__} == 2 ) {
                $re = '(\d (OK|BAD|NO))|(^*)';
            }
            elsif ( $self->{debug__} == 3 ) {
                $re = '';
            }

            foreach ( split /$eol/, $response ) {
                $self->log_( ">> $_" ) if /$re/;
            }
        }

        # Increment tag for the next command/reply sequence:
        $self->{tag__}++;

        # We got 'OK' and the correct tag.
        if ( $response =~ /^$actualTag OK/m ) {
            return 1;
        }
        # 'NO' plus correct tag
        elsif ( $response =~ /^$actualTag NO/m ) {
            $self->log_( "!!! Server said NO !!!" );
            return 0;
        }
        # 'BAD' and correct tag.
        elsif ( $response =~ /^$actualTag BAD/m ) {
            $self->log_( "!!! Server said BAD !!!" );
            return -1;
        }
        # Someting else, probably a different tag, but who knows?
        else {
            $self->log_( "!!! Server said something unexpected !!!" );
            return -2;
        }
    }
    return -3;
}






# ---------------------------------------------------------------------------------------------
#
# get_mailbox_list
#
#   Request a list of mailboxes from the server behind the passed in socket object.
#   The list is stored away in @{$self->{mailboxes__}} and returned.
#
# Arguments:
#   $imap: as usual, contains a valid connection to our IMAP server.
#
# Return value:
#
#   The list of mailboxes
# ---------------------------------------------------------------------------------------------

sub get_mailbox_list
{
    my ( $self, $imap ) = @_;

    $self->log_( "Getting mailbox list" ) if $self->{debug__};

    $self->say( $imap, "LIST \"\" \"*\"" );
    $self->get_response( $imap );

    my @lines = split /$eol/, $self->{last_response__};
    my @mailboxes;

    foreach ( @lines ) {
        next unless /^\*/;
        s/^\* LIST \(.*\) .+? (.+)$/$1/;
        s/"(.*?)"/$1/;
        push @mailboxes, $1;
    }

    @{$self->{mailboxes__}} = @mailboxes;

    return @mailboxes;
}






# ---------------------------------------------------------------------------------------------
#
# fetch_message_part
#
#   This function will fetch a specified part of a specified message from
#   the IMAP server and return the message as a list of lines.
#   It assumes that a folder is already SELECTed
#
# arguments
#
#   $imap: connection to the server
#   $msg:  UID of the message
#   $part: The part of the message you want to fetch. Could be 'HEADER' for the
#       message headers, 'TEXT' for the body (including any attachments), or '' to
#       fetch the complete message. Other values are also possible, but currently
#       not used. 'BODYSTRUCTURE' could be interesting.
#
# return value:
#
#   a list containing the lines of the retrieved message or an empty list on failure.
#
# ---------------------------------------------------------------------------------------------

sub fetch_message_part
{
    my ( $self, $imap, $msg, $part ) = @_;

    $self->log_( "Fetching $part of message $msg" );

    $self->say( $imap, "UID FETCH $msg (FLAGS BODY.PEEK[$part])" );

    my $result = $self->get_response ( $imap );
    $self->log_( "Got $part of message # $msg, result: $result." );

    if ( $result == 1 ) {
        my @lines = ();

        # The first line now MUST start with "* x FETCH" where x is a message
        # sequence number anything else indicates that something went wrong
        # or that something changed. E.g. the message we wanted
        # to fetch is no longer there.

        if ( $self->{last_response__} =~ m/\^* \d+ FETCH/ ) {

            # The first line should contain the number of octets the server send us

            if ( $self->{last_response__} =~ m/(?!$eol){(\d+)}$eol/ ) {
                my $num_octets = $1;

                # Grab the number of octets reported:

                my $pos = index $self->{last_response__}, "{$num_octets}$eol";
                $pos += length "{$num_octets}$eol";

                my $message = substr $self->{last_response__}, $pos, $num_octets;

                # Take the large chunk and chop it into single lines

                # We cannot use split here, because this would get rid of
                # trailing and leading newlines and thus omit complete lines.

                while ( $message =~ m/(.*?$eol)/g ) {
                    push @lines, $1;
                }
            }
            # No number of octets: fall back, but issue a warning
            else {
                while ( $self->{last_response__} =~ m/(.*?$eol)/g ) {
                    push @lines, $1;
                }

                # discard the first and the two last lines; these are server status responses.
                shift @lines;
                pop @lines;
                pop @lines;

                $self->log_( "!!!!! Warning: Could not find octet count in server's response !!!" );
            }
        }
        else {
            $self->log_( "!!!! Unexpected server response to the FETCH command !!!" );
        }

        return @lines;
    }
    else {
        return ();
    }
}


# ---------------------------------------------------------------------------------------------
#
# move_message
#
#   Will try to move a message on the IMAP server.
#
# arguments:
#
#   $imap:
#       connection to server
#   $msg:
#       The UID of the message
#   $destination:
#       The destination folder.
#
# ---------------------------------------------------------------------------------------------

sub move_message
{
    my ( $self, $imap, $msg, $destination ) = @_;

    $self->log_( "Moving message $msg to $destination" );

    # Copy message to destination
    $self->say( $imap, "UID COPY $msg \"$destination\"" );
    my $ok = $self->get_response( $imap );

    # If that went well, flag it as deleted
    if ( $ok == 1 ) {
        $self->say( $imap, "UID STORE $msg +FLAGS (\\Deleted)" );
        $ok = $self->get_response( $imap );
    }
    else {
        $self->log_( "!!!! Could not copy message ($ok)." );
    }

    return ( $ok ? 1 : 0 );
}


# ---------------------------------------------------------------------------------------------
#
# get_uids_ge
#
#   Will search for messages on the IMAP server that are not flagged as deleted
#   that have a UID greater than or equal to the passed in value
#
# arguments:
#
#   $imap:      connection to server
#   $uid:       An UID to compare to
#
# return value:
#
#   A list (possibly empty) of the UIDs of matching messages.
#
# ---------------------------------------------------------------------------------------------

sub get_uids_ge
{
    my ( $self, $imap, $uid ) = @_;

    $self->log_( "Getting uids ge $uid" ) if $self->{debug__};

    $self->say( $imap, "UID SEARCH UID $uid:* UNDELETED" );
    $self->get_response ( $imap );

    # The server will respond with an untagged search reply.
    # This can either be empty ("* SEARCH") or if a
    # message was found it contains the numbers of the matching
    # messages, e.g. "* SEARCH 2 5 9".
    # In the latter case, the regexp below will match and
    # capture the list of messages in $1

    my @matching = ();

    if ( $self->{last_response__} =~ /\* SEARCH (.+)$eol/ ) {

        @matching = split / /, $1;
    }

    my @return_list = ();

    # Make sure that the UIDs reported by the server are really greater
    # than or equal to our passed in comparison value

    foreach my $num ( @matching ) {
        if ( $num >= $uid ) {
            push @return_list, $num;
        }
    }

    return @return_list;

}


# ---------------------------------------------------------------------------------------------
#
# search_for_messages
#
#   Will search for messages on the IMAP server that are not flagged as deleted
#   and return a list of message numbers.
#
# arguments:
#
#   $imap:      connection to server
#   $what:      A string that tells the server what to search for, e.g. "UNSEEN"
#   $all:       If this is defined, we will also search for deleted messages
#
# return value:
#
#   A list (possibly empty) of the numbers of matching messages.
#
# ---------------------------------------------------------------------------------------------

sub search_for_messages
{
    my ( $self, $imap, $what, $all ) = @_;

    my $undeleted = 'UNDELETED';

    if ( defined $all ) {
        $undeleted = '';
        $self->log_( "Searching messages with attribute $what" );
    }
    else {
        $self->log_( "Searching undeleted messages with attribute $what" );
    }

    $self->say( $imap, "UID SEARCH $what $undeleted" );
    $self->get_response ( $imap );

    # The server will respond with an untagged search reply.
    # This can either be empty ("* SEARCH") or if a
    # message was found it contains the numbers of the matching
    # messages, e.g. "* SEARCH 2 5 9".
    # In the latter case, the regexp below will match and
    # capture the list of messages in $1

    my @matching = ();

    if ( $self->{last_response__} =~ /\* SEARCH (.+)$eol/ ) {
        @matching = split / /, $1;
    }
    return ( sort { $a <=> $b } @matching );
}


# ---------------------------------------------------------------------------------------------
#
#   (g|s)etters for configuration variables
#
#



# ---------------------------------------------------------------------------------------------
#
#   folder_for_bucket__
#
#   Pass in a bucket name only to get a corresponding folder name
#   Pass in a bucket name and a folder name to set the pair
#
#---------------------------------------------------------------------------------------------

sub folder_for_bucket__
{
    my ( $self, $bucket, $folder ) = @_;

    my $all = $self->config_( 'bucket_folder_mappings' );
    my %mapping = split /$cfg_separator/, $all;

    # set
    if ( $folder ) {
        $mapping{$bucket} = $folder;

        $all = '';
        while ( my ( $k, $v ) = each %mapping ) {
            $all .= "$k$cfg_separator$v$cfg_separator";
        }
        $self->config_( 'bucket_folder_mappings', $all );
    }
    # get
    else {
        if ( exists $mapping{$bucket} ) {
            return $mapping{$bucket};
        }
        else {
            return;
        }
    }
}


#---------------------------------------------------------------------------------------------
#
#   watched_folders__
#
#   Returns a list of watched folders when called with no arguments
#   Otherwise set the list of watched folders to whatever argument happens to be.
#
#---------------------------------------------------------------------------------------------


sub watched_folders__
{
    my ( $self, @folders ) = @_;

    my $all = $self->config_( 'watched_folders' );

    # set
    if ( @folders ) {
        $all = '';
        foreach ( @folders ) {
            $all .= "$_$cfg_separator";
        }
        $self->config_( 'watched_folders', $all );
    }
    # get
    else {
        return split /$cfg_separator/, $all;
    }
}


#---------------------------------------------------------------------------------------------
#
#   uid_validity__
#
#   Pass in a folder name only to get the stored UIDVALIDITY value for that folder
#   Pass in folder name and new UIDVALIDITY value to store the value
#
#---------------------------------------------------------------------------------------------

sub uid_validity__
{
    my ( $self, $folder, $uidval ) = @_;

    my $all = $self->config_( 'uidvalidities' );
    my %hash;

    if ( defined $all ) {
        %hash = split /$cfg_separator/, $all;
    }


    # set
    if ( defined $uidval ) {
        $hash{$folder} = $uidval;
        $all = '';
        while ( my ( $key, $value ) = each %hash ) {
            $all .= "$key$cfg_separator$value$cfg_separator";
        }
        $self->config_( 'uidvalidities', $all );
    }
    # get
    else {
        if ( exists $hash{$folder} ) {
            return $hash{$folder};
        }
        else {
            return;
        }
    }
}


#---------------------------------------------------------------------------------------------
#
#   uid_next__
#
#   Pass in a folder name only to get the stored UIDNEXT value for that folder
#   Pass in folder name and new UIDNEXT value to store the value
#
#---------------------------------------------------------------------------------------------

sub uid_next__
{
    my ( $self, $folder, $uidnext ) = @_;


    my $all = $self->config_( 'uidnexts' );
    my %hash;

    if ( defined $all ) {
        %hash = split /$cfg_separator/, $all;
    }


    # set
    if ( defined $uidnext ) {
        $hash{$folder} = $uidnext;
        $all = '';
        while ( my ( $key, $value ) = each %hash ) {
            $all .= "$key$cfg_separator$value$cfg_separator";
        }
        $self->config_( 'uidnexts', $all );
        $self->log_( "Updated UIDNEXT value for folder $folder to $uidnext." ) if ( $self->{debug__} > 1 );
    }
    # get
    else {
        if ( exists $hash{$folder} ) {
            return $hash{$folder};
        }
        return;
    }
}



# SETTER

sub classifier
{
    my ( $self, $classifier ) = @_;

    $self->{classifier__} = $classifier;
}

######################################################################################
# A temporary solution to find out about known messages.
# This will have to go one day or change or something.


#----------------------------------------------------------------------------
# read_cls_files__
#
# This function globs for .cls files in the messages directory.
# It opens each file, reads the bucket the message was classified
# to and possibly a hash value for the message
# It several hashes (Perl hashes that is)
#----------------------------------------------------------------------------

sub read_cls_files__
{
    my ( $self ) = @_;

    my @cls_files = glob( $self->get_user_path_( $self->global_config_( 'msgdir' ) . '*.cls' ) );

    foreach my $cls ( @cls_files ) {

        if ( open CLS, "<$cls" ) {

            my $bucket;
            my $hash;

            my $first = <CLS>;
            chop $first;

            # We won't remember magnetized messages. We shouldn't reclassify them anyway.
            unless ( $first =~ /MAGNET/ ) {

                if ( $first =~ /RECLASSIFIED/ ) {
                    $bucket = <CLS>;
                    chop $bucket;
                    <CLS>;  # old bucket, but we don't care.
                    $hash = <CLS>;
                    if ( defined $hash ) {
                        chop $hash;
                        $self->{hash_to_reclassed__}{$hash} = 1;
                    }
                }
                # A normal class file with only one line ( not counting the hash)
                else {
                    $bucket = $first;
                    $hash = <CLS>;
                    chop $hash if defined $hash;
                }

                if ( defined $hash ) {
                    $self->{hash_to_bucket__}{$hash} = $bucket;
                    my $histfile = $cls;
                    $histfile =~ s|.+/(.+)cls$|${1}msg|;
                    $self->{hash_to_history__}{$hash} = $histfile;
                }
            }
            close CLS;
        }
    }
}



#----------------------------------------------------------------------------
# get hash
#
# Computes a hash of the MID and Date header lines of this message.
# Note that a folder on the server needs to be selected for this to work.
#
# Arguments:
#
#   $imap:  the server connection and
#   $msg:   message UID
#
# Return value:
#   A string containing the hash value or undef on error.
#
#----------------------------------------------------------------------------

sub get_hash
{
    my ( $self, $imap, $msg ) = @_;

    $self->say( $imap, "UID FETCH $msg (FLAGS BODY.PEEK[HEADER.FIELDS (Message-id Date Subject)])" );

    if ( $self->get_response( $imap ) == 1) {

        my $date = '';
        my $mid = '';
        my $subject = '';

        foreach my $line ( split /$eol/, $self->{last_response__} ) {

            if ( $line =~ /^Message-id:/i ) {
                $mid = $line;
            }
            elsif ( $line =~ /^Date:/i ) {
                $date = $line;
            }
            elsif ( $line =~ /^Subject:/i ) {
                $subject = $line;
            }
        }

        my $hash = md5_hex( $date, $mid );

        $self->log_( "Hashed message. $subject." );
        $self->log_( "Message $msg has hash value $hash" ) if $self->{debug__};

        return $hash;
    }
    else {
        $self->log_( "Could not FETCH the header fields of message $msg!" );
        return;
    }
}



#----------------------------------------------------------------------------
#   can_classify__
#
# This function is a decider. It decides whether a message can be
# classified if found in one of our watched folders or not.
#
# arguments:
#   $hash: The hash value for this message
#
# returns true or false
#----------------------------------------------------------------------------

sub can_classify__
{
    my ( $self, $hash ) = @_;

    if ( exists $self->{hash_to_bucket__}{$hash} ) {
        $self->log_( "Message was already classified." ) if $self->{debug__};
        return 0;
    }
    else {
        return 1;
    }
}

#----------------------------------------------------------------------------
#   can_reclassify__
#
# This function is a decider. It decides whether a message can be
# reclassified if found in one of our output folders or not.
#
# arguments:
#   $hash: The hash value for this message
#
# return value:
#   undef if the message should not be reclassified
#   the current classification if a reclassification is ok
#----------------------------------------------------------------------------

sub can_reclassify__
{
    my ( $self, $hash, $new_bucket ) = @_;

    # We must know the message
    if ( exists $self->{hash_to_bucket__}{$hash} ) {
        # We must not reclassify a reclassified message
        if ( !exists $self->{hash_to_reclassed__}{$hash} ) {
            # new and old bucket must be different
            if ( $new_bucket ne $self->{hash_to_bucket__}{$hash} ) {
                return $self->{hash_to_bucket__}{$hash};
            }
            else {
                $self->log_( "Will not reclassify to same bucket ($new_bucket)." ) if $self->{debug__};
            }
        }
        else {
            $self->log_( "The message was already reclassified." ) if $self->{debug__};
        }
    }
    else {
        $self->log_( "Message is unknown and cannot be reclassified." ) if $self->{debug__};
    }

    return;
}

#----------------------------------------------------------------------------
#   was_reclassified__
#
# This function MUST be called after a message was reclassified to
# keep the internal records up to date and to change the class file
# of that message.
#
# arguments:
#   $hash:  The hash value of the message
#   $bucket: The bucket the message was classified to
# there is no return value
#----------------------------------------------------------------------------

sub was_reclassified__
{
    my ( $self, $hash, $bucket ) = @_;

    my $msg_file = $self->{hash_to_history__}{$hash};
    my $old_class = $self->{hash_to_bucket__}{$hash};

    $self->change_cls_file__( $msg_file, $hash, $bucket, $old_class );

    $self->{hash_to_reclassed__}{$hash} = 1;
    $self->{hash_to_bucket__}{$hash} = $bucket;
}




#----------------------------------------------------------------------------
# was_classified__
#
# This function MUST be called after a message was classified. It updates
# internal records and the corresponding class file
#
# arguments:
#   $hash:      The hash value of that message
#   $bucket:    The bucket the message was classified to
#   $msg_file:  The name of the message file in history (no path, just file name)
# there is no return value
#----------------------------------------------------------------------------

sub was_classified__
{
    my ( $self, $hash, $bucket, $msg_file ) = @_;

    $self->change_cls_file__( $msg_file, $hash, $bucket );
    $self->{hash_to_bucket__}{$hash} = $bucket;
    $self->{hash_to_history__}{$hash} = $msg_file;
}



#----------------------------------------------------------------------------
# change_cls_file__
#
# This gets called after a message was classified or reclassified
# by either was_classified__() or was_reclassified__().
# It rewrites the class file that belongs to the
# messages ton include our hash value
#
# arguments:
#   $msg_file:      Name of the msg file in history (no path, just file name)
#   $hash:          the hash value of this message
#   $class:         The current classification of this message
#   $oldclass:      The old classification if we were reclassifying. This may be undefined.
# there is no return value
#----------------------------------------------------------------------------

sub change_cls_file__
{
    my ( $self, $msg_file, $hash, $class, $oldclass ) = @_;

    my $cls_path = $self->get_user_path_( $self->global_config_( 'msgdir' ) . $msg_file );
    $cls_path =~ s/\.msg/.cls/;

    if ( open CLS, ">$cls_path" ) {

        # called after reclassification:
        if ( defined $oldclass ) {
            print CLS "RECLASSIFIED\n$class\n$oldclass\n$hash\n";
        }
        # called after classification:
        else {
            print CLS "$class\n$hash\n";
            $self->{hash_to_history__}{$hash} = $msg_file;
        }
        close CLS;


        $self->log_( "Updated class file $cls_path. Class: $class. Hash: $hash." );
    }
    else {
        $self->log_( "Could not open cls file $cls_path." );
    }
}


#----------------------------------------------------------------------------
# get_msg_file__
#
# Takes the hash of a message as its argument
# and returns the name of the history msg file retrieved from the internal
# hash or undef on error
#----------------------------------------------------------------------------

sub get_msg_file__
{
    my ( $self, $hash ) = @_;

    if ( exists $self->{hash_to_history__}{$hash} ) {
        my $msg_file = $self->{hash_to_history__}{$hash};
        $msg_file =~ s/\.cls/.msg/;

        return $msg_file;
    }
    else {
        return;
    }
}






# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $session_key     The current session key
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $template ) = @_;

    my $body;

    # conection details
    if ( $name eq 'imap_0_connection_details' ) {
        $template->param( 'IMAP_hostname', $self->config_( 'hostname' ) );
        $template->param( 'IMAP_port',     $self->config_( 'port' ) );
        $template->param( 'IMAP_login',    $self->config_( 'login' ) );
        $template->param( 'IMAP_password', $self->config_( 'password' ) );
    }

    # Which mailboxes/folders should we be watching?
    if ( $name eq 'imap_1_watch_folders' ) {

        # We can only configure this when we have a list of mailboxes available on the server
        if ( @{$self->{mailboxes__}} < 1 || ( ! $self->watched_folders__() ) ) {
            $template->param( IMAP_if_mailboxes => 0 );
        }
        else {
            $template->param( IMAP_if_mailboxes => 1 );

            # the following code will fill a loop containing another loop
            # The outer loop iterates over our watched folders,
            # the inner loop over all our mailboxes to fill the select form

            # Data for the outer loop, the inner loops data will be contained
            # in those data structures:

            my @loop_watched_folders = ();

            my $i = 0;

            # Loop over watched folder slot. One select form per watched folder
            # will be generated
            foreach my $folder ( $self->watched_folders__() ) {
                $i++;
                my %data_watched_folders = ();

                # inner loop data
                my @loop_mailboxes = ();

                # loop over IMAP mailboxes and generate a select element for reach one
                foreach my $mailbox ( @{$self->{mailboxes__}} ) {

                    # Populate inner loop entries:
                    my %data_mailboxes = ();

                    $data_mailboxes{IMAP_mailbox} = $mailbox;

                    # Is it currently selected?
                    if ( $folder eq $mailbox ) {
                        $data_mailboxes{IMAP_selected} = 'selected="selected"';
                    }
                    else {
                        $data_mailboxes{IMAP_selected} = '';
                    }

                    push @loop_mailboxes, \%data_mailboxes;
                }

                $data_watched_folders{IMAP_loop_mailboxes} = \@loop_mailboxes;
                $data_watched_folders{IMAP_loop_counter} = $i;
                push @loop_watched_folders, \%data_watched_folders;
            }

            $template->param( IMAP_loop_watched_folders => \@loop_watched_folders );
        }
    }

    # Give me another watched folder.
    if ( $name eq 'imap_2_watch_more_folders' ) {
        if ( @{$self->{mailboxes__}} < 1 ) {
            $template->param( IMAP_if_mailboxes => 0 );
        }
        else {
            $template->param( IMAP_if_mailboxes => 1 );
        }
    }


    # Which folder corresponds to which bucket?
    if ( $name eq 'imap_3_bucket_folders' ) {
        if ( @{$self->{mailboxes__}} < 1 ) {
            $template->param( IMAP_if_mailboxes => 0 );
        }
        else {
            $template->param( IMAP_if_mailboxes => 1 );

            # What is happening here is basically the same thing that is happening
            # above for imap_1_watch_folders
            # Just eplace "watched folders" with "buckets".

            my @buckets = $self->{classifier__}->get_all_buckets( $self->{api_session__} );

            my @outer_loop = ();

            foreach my $bucket ( @buckets ) {
                my %outer_data = ();
                my $output = $self->folder_for_bucket__( $bucket );

                $outer_data{IMAP_mailbox_defined} = (defined $output) ? 1 : 0;

                my @inner_loop = ();
                foreach my $mailbox ( @{$self->{mailboxes__}} ) {
                    my %inner_data = ();

                    $inner_data{IMAP_mailbox} = $mailbox;

                    if ( defined $output && $output eq $mailbox ) {
                        $inner_data{IMAP_selected} = 'selected="selected"';
                    }
                    else {
                        $inner_data{IMAP_selected} = '';
                    }

                    push @inner_loop, \%inner_data;
                }
                $outer_data{IMAP_loop_mailboxes} = \@inner_loop;
                $outer_data{IMAP_bucket} = $bucket;
                push @outer_loop, \%outer_data;
            }
            $template->param( IMAP_loop_buckets => \@outer_loop );
        }
    }



    # Read the list of mailboxes from the server. Now!
    if ( $name eq 'imap_4_update_mailbox_list' ) {
        if ( $self->config_( 'hostname' ) eq '' ) {
            $template->param( IMAP_if_connection_configured => 0 );
        }
        else {
            $template->param( IMAP_if_connection_configured => 1 );
        }
    }


    # update interval in seconds
    if ( $name eq 'imap_5_update_interval' ) {
        $template->param( IMAP_interval => $self->config_( 'update_interval' ) );
    }


    # How many bytes/octets do we use for the classification?
    if ( $name eq 'imap_6_byte_limit' ) {
        $template->param( IMAP_byte_limit => $self->config_( 'byte_limit' ) );
    }

    # How noisy should the log file be?
    if ( $name eq 'imap_7_debug_level' ) {
        my @loop = ();
        for my $i ( 0 .. 3 ) {
            my %data = ();

            $data{IMAP_selected} = ( $i == $self->{debug__} ) ? 'selected="selected"' : '';
            $data{IMAP_level} = $i;
            push @loop, \%data;
        }
        $template->param( IMAP_debug_levels => \@loop );
    }

    # Should we expunge after leaving a folder or not?
    if ( $name eq 'imap_8_expunge' ) {
        my $checked = $self->config_( 'expunge' ) ? 'checked="checked"' : '';
        $template->param( IMAP_expunge_is_checked => $checked );
    }
}



# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $template        The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $template, $language, $form ) = @_;

    # connection details
    if ( $name eq 'imap_0_connection_details' ) {
        if ( defined $$form{update_imap_0_connection_details} ) {
            if ( $$form{imap_hostname} ne '' ) {
                $template->param( IMAP_connection_if_hostname_error => 0 );
                $self->config_( 'hostname', $$form{imap_hostname} );
            }
            else {
                $template->param( IMAP_connection_if_hostname_error => 1 );
            }

            if ( $$form{imap_port} >= 1 && $$form{imap_port} < 65536 ) {
                $self->config_( 'port', $$form{imap_port} );
                $template->param( IMAP_connection_if_port_error => 0 );
            }
            else {
                $template->param( IMAP_connection_if_port_error => 1 );
            }

            if ( $$form{imap_login} ne '' ) {
                $self->config_( 'login', $$form{imap_login} );
                $template->param( IMAP_connection_if_login_error => 0 );
            }
            else {
                $template->param( IMAP_connection_if_login_error => 1 );
            }

            if ( $$form{imap_password} ne '' ) {
                $self->config_( 'password', $$form{imap_password} );
                $template->param( IMAP_connection_if_password_error => 0 );
            }
            else {
                $template->param( IMAP_connection_if_password_error => 1 );
            }
        }
        return;
    }

    # watched folders
    if ( $name eq 'imap_1_watch_folders' ) {
        if ( defined $$form{update_imap_1_watch_folders} ) {

            my $i = 1;
            my %folders;
            foreach ( $self->watched_folders__() ) {
                $folders{ $$form{"imap_folder_$i"} }++;
                $i++;
            }

            $self->watched_folders__( sort keys %folders );
        }
        return;
    }

    # Add a watched folder
    if ( $name eq 'imap_2_watch_more_folders' ) {
        if ( defined $$form{imap_2_watch_more_folders} ) {
            my @current = $self->watched_folders__();
            push @current, 'INBOX';
            $self->watched_folders__( @current );
        }
        return;
    }

    # map buckets to folders
    if ( $name eq 'imap_3_bucket_folders' ) {
        if ( defined $$form{imap_3_bucket_folders} ) {

            # We have to make sure that there is only one bucket per folder
            # Multiple buckets cannot map to the same folder because how
            # could we reliably reclassify on move then?

            my %bucket2folder;
            my %folders;

            foreach my $key ( keys %$form ) {
                # match bucket name:
                if ( $key =~ /^imap_folder_for_(.+)$/ ) {
                    my $bucket = $1;
                    my $folder = $$form{ $key };

                    $bucket2folder{ $bucket } = $folder;

                    # pseudo buckets are free to map wherever they like since
                    # we will never reclassify to them anyway
                    unless ( $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $bucket ) ) {
                        $folders{ $folder }++;
                    }
                }
            }

            my $bad = 0;
            while ( my ( $bucket, $folder ) = each %bucket2folder ) {

                if ( exists $folders{$folder} && $folders{ $folder } > 1 ) {
                    $bad = 1;
                }
                else {
                    $self->folder_for_bucket__( $bucket, $folder );
                }
            }
            $template->param( IMAP_buckets_to_folders_if_error => $bad );
        }
        return;
    }

    # update the list of mailboxes
    if ( $name eq 'imap_4_update_mailbox_list' ) {
        if ( defined $$form{do_imap_4_update_mailbox_list} ) {
            if ( $self->config_( 'hostname' )
                && $self->config_( 'login' )
                && $self->config_( 'login' )
                && $self->config_( 'port' )
                && $self->config_( 'password' ) ) {

                    my $imap = $self->connect( $self->config_( 'hostname' ), $self->config_( 'port' ) );
                    if ( defined $imap ) {
                        if ( $self->login( $imap ) ) {;
                            $self->get_mailbox_list( $imap );
                            $self->say( $imap, 'LOGOUT' );
                            $self->get_response( $imap );
                            $template->param( IMAP_update_list_failed => '' );
                        }
                        else {
                            $template->param( IMAP_update_list_failed => 'Could not login. Verify your login name and password, please.' );
                        }
                    }
                    else {
                        $template->param( IMAP_update_list_failed => 'Failed to connect to server. Please check the host name and port and make sure you are online.' );
                    }
            }
            else {
                $template->param( IMAP_update_list_failed => 'Please configure the connection details first.' );
            }
        }
        return;
    }

    # update interval
    if ( $name eq 'imap_5_update_interval' ) {
        if ( defined $$form{update_imap_5_update_interval} ) {
           if ( $$form{imap_5_update_interval} > 10 && $$form{imap_5_update_interval} < 60*60 ) {
                $self->config_( 'update_interval', $$form{imap_5_update_interval} );
                $template->param ( IMAP_if_interval_error => 0 );
            }
            else {
                $template->param ( IMAP_if_interval_error => 1 );
            }
        }
        return;
    }

    # byte limit for message download
    if ( $name eq 'imap_6_byte_limit' ) {
        if ( defined $$form{imap_6_byte_limit} ) {
            $self->config_( 'byte_limit', $$form{imap_6_byte_limit} );
        }
        return;
    }

    # How noisy should the log file be?
    if ( $name eq 'imap_7_debug_level' ) {
        if ( defined $$form{imap_debug_level} ) {
            $self->{debug__} = $$form{imap_debug_level};
            $self->config_( 'debug_level', $self->{debug__} );
        }
        return;
    }


    # Should we expunge after leaving a folder or not?
    if ( $name eq 'imap_8_expunge' ) {
        if ( defined $$form{update_imap_8_expunge} ) {
            if ( defined $$form{imap_expunge} ) {
                $self->config_( 'expunge', 1 );
            }
            else {
                $self->config_( 'expunge', 0 );
            }
        }
        return;
    }

    $self->SUPER::validate_item( $name, $template, $language, $form );
}



1;
