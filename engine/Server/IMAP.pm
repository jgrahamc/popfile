# POPFILE LOADABLE MODULE
package Server::IMAP;
use POPFile::Module;
@ISA = ("POPFile::Module");

# ---------------------------------------------------------------------------------------------
#
# IMAP.pm --- a module to use POPFile for an IMAP connection.
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
#   Originally created by   Manni Heumann (mannih2001@users.sourceforge.net)
#   Modified by             Sam Schinke (sschinke@users.sourceforge.net)
#   Patches by              David Lang (davidlang@users.sourceforge.net)
#   Moved location by       John Graham-Cumming (jgrahamc@users.sf.net)
#
#   The documentation for this module can be found on
#   http://popfile.sf.net/cgi-bin/wiki.pl?ExperimentalModules/Imap
#
# ---------------------------------------------------------------------------------------------

use IO::Socket;
use Digest::MD5 qw( md5_hex );
use strict;
use warnings;
use locale;

my $eol = "\015\012";
my $cfg_separator = "-->";

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

    $self->{classifier__} = 0;

    # Here are the variables used by this module:

    # A place to store the last response that the IMAP server sent us
    $self->{last_response__} = '';

    # A place to store the last command we sent to the server
    $self->{last_command__} = '';

    # The tag that preceeds any command we sent, actually just a simple counter var
    $self->{tag__} = 0;

    # A list of mailboxes on the server:
    $self->{mailboxes__} = [];

    # The session id for the current session:
    $self->{api_session__} = '';

    # A hash to hold per-folder data (watched and output flag + socket connection)
    # This data structure is extremely important to the work done by this
    # module, so don't mess with it!
    # The hash contains one key per service folder.
    # This key will return another hash. This time the keys are fixed and
    # can be {output} for an output folder
    # {watched} for a watched folder.
    # {imap} will hold a valid socket object for the connection of this folder.
    $self->{folders__} = ();

    # A flag that tells us that the folder list has changed
    $self->{folder_change_flag__} = 0;

    # A hash containing the hash values of messages that we encountered
    # during a single run through service().
    # If you provide a hash as a key and if that key exists, the value
    # will be the folder where the original message was placed (or left) in.
    $self->{hash_values__} = ();

    $self->{history__} = 0;

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
    $self->config_( 'expunge', 0 );
    $self->config_( 'use_ssl', 0 );

    # Those next variables have getter/setter functions and should
    # not be used directly:

    $self->config_( 'watched_folders', "INBOX" );     # function watched_folders
    $self->config_( 'bucket_folder_mappings', '' );   # function folder_for_bucket
    $self->config_( 'uidvalidities', '' );            # function uid_validity
    $self->config_( 'uidnexts', '' );                 # function uid_next

    # Diabled by default
    $self->config_( 'enabled', 0 );

    # Training mode is disabled by default:
    $self->config_( 'training_mode', 0 );

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
                                         'imap_5_options',
                                         'imap-options.thtml',
                                         $self );

    return $self->SUPER::start();
}



# ---------------------------------------------------------------------------------------------
# stop
#
#   Not much to do here.
#
# ---------------------------------------------------------------------------------------------

sub stop
{
    my ( $self ) = @_;

    if ( $self->{api_session__} ne '' ) {
        $self->{classifier__}->release_session_key( $self->{api_session__} );
    }

    foreach ( keys %{$self->{folders__}} ) {
        if ( exists $self->{folders__}{$_}{imap} ) {
            $self->{folders__}{$_}{imap}->shutdown( 2 );
            delete $self->{folders__}{$_}{imap};
        }
    }
}



# ---------------------------------------------------------------------------------------------
#
# service
#
#   This get's frequently called by the framework.
#   It checks whether our checking interval has elapsed and if it has,
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

        # Since say__() as well as get_response__() can throw an exception, i.e. die if
        # they detect a lost connection, we eval the following code to be able
        # to catch the exception. We also tell Perl to ignore broken pipes.

        eval {
            local $SIG{'PIPE'} = 'IGNORE';
            local $SIG{'__DIE__'};

            if ( $self->config_( 'training_mode' ) == 1 ) {

                $self->train_on_archive__();

            }
            else {

                # If we haven't yet set up a list of serviced folders,
                # or if the list was changed by the user, build up a
                # list of folder in $self->{folders__}

                if ( ( keys %{$self->{folders__}} == 0 ) || ( $self->{folder_change_flag__} == 1 ) ) {
                    $self->build_folder_list__();
                }

                # Try to establish connections, log in, and select for
                # all of our folders
                $self->connect_folders__();

                # Now do the real job

                foreach my $folder ( keys %{$self->{folders__}} ) {

                    if ( exists $self->{folders__}{$folder}{imap} ) {

                        $self->scan_folder( $folder );

                    }
                }

                # Reset the hash containing the hash values we have just seen.
                $self->{hash_values__} = ();
            }

        };
        # if an exception occurred, we try to catch it here
        if ( $@ ) {
            # say__() and get_response__() will die with this message:
            if ( $@ =~ /The connection to the IMAP server was lost/ ) {
                $self->log_( 0, $@ );
            }
            # If we didn't die but somebody else did, we have empathy.
            else {
                die $@;
            }
        }
        # Save the current time.
        $self->{last_update__} = time;
    }

    return 1;
}


#----------------------------------------------------------------------------
# build_folder_list__
#
#   This function builds a list of all the folders that we have to care
#   about. This list consists of the folders we are watching for new mail
#   and of the folders that we are watching for reclassification requests.
#   The complete list is stored in a hash: $self->{folders__}.
#   The keys in this hash are the names of our folders, the values represent
#   flags. Currently, the flags can be
#       {watched} for watched folders and
#       {output} for output/bucket folders.
#   The function connect_folders__() will later add an {imap} key that will
#   hold the connection for that folder.
#
# arguments:
#   none.
#
# return value:
#   none.
#----------------------------------------------------------------------------

sub build_folder_list__
{
    my ( $self ) = @_;

    $self->log_( 1, "Building list of serviced folders." );

    # At this point, we simply reset the folders hash.
    # This isn't really elegant because it will leave dangling connections
    # if we have already been connected. But I trust in Perl's garbage collection
    # and keep my fingers crossed.

    %{$self->{folders__}} = ();

    # watched folders
    foreach ( $self->watched_folders__() ) {
        $self->{folders__}{$_}{watched} = 1;
    }

    # output folders
    foreach my $bucket ( $self->{classifier__}->get_all_buckets( $self->{api_session__} ) ) {

        my $folder = $self->folder_for_bucket__( $bucket );

        if ( defined $folder ) {
            $self->{folders__}{$folder}{output} = $bucket;
        }
    }

    # If this is a new POPFile installation that isn't yet
    # configured, our hash will have exactly one key now
    # which will point to the INBOX. Since this isn't enough
    # to do anything meaningful, we simply reset the hash:

    if ( ( keys %{$self->{folders__}} ) == 1 ) {
        %{$self->{folders__}} = ();
    }

    # Reset the folder change flag
    $self->{folder_change_flag__} = 0;
}



#----------------------------------------------------------------------------
# connect_folders__
#
#   This function will iterate over each folder found in the %{$self->{folders__}}
#   hash. For each folder it will try to establish a connection, log in, and select
#   the folder.
#   The corresponding socket object, will be stored in
#   $self->{folders__}{$folder}{imap}
#
# arguments:
#   none.
#
# return value:
#   none.
#----------------------------------------------------------------------------

sub connect_folders__
{
    my ( $self ) = @_;

    # Establish a connection for each folder in the hash

    foreach my $folder ( keys %{$self->{folders__}} ) {

        # We may already have a valid connection for this folder:
        if ( exists $self->{folders__}{$folder}{imap} ) {
            next;
        }

        $self->{folders__}{$folder}{server} = 1;
        $self->{folders__}{$folder}{tag} = 0;

        # The folder may be write-only:
        if ( exists $self->{folders__}{$folder}{output}
                &&
            ! exists $self->{folders__}{$folder}{watched}
                &&
            $self->{classifier__}->is_pseudo_bucket( $self->{api_session__},
                                    $self->{folders__}{$folder}{output} ) ) {
                next;
        }

        $self->log_( 1, "Trying to connect to ". $self->config_( 'hostname' ) . " for folder $folder." );
        $self->{folders__}{$folder}{imap} = $self->connect( $self->config_( 'hostname' ), $self->config_( 'port' ) );

        # Did the connection succeed?
        if ( defined $self->{folders__}{$folder}{imap} ) {

            if ( $self->login( $folder ) ) {

                # Build a list of IMAP mailboxes if we haven't already got one:
                unless ( @{$self->{mailboxes__}} ) {
                    $self->get_mailbox_list( $self->{folders__}{$folder}{imap} );
                }

                # Change to / SELECT the folder
                $self->say__( $folder, "SELECT \"$folder\"" );
                if ( $self->get_response__( $folder ) != 1 ) {

                    $self->log_( 0, "Could not SELECT folder $folder." );
                    $self->say__( $folder, "LOGOUT" );
                    $self->get_response__( $folder );
                    delete $self->{folders__}{$folder}{imap};
                }
                else {
                    # And now check that our UIDs are valid
                    unless ( $self->folder_uid_status__( $folder ) ) {
                        $self->log_( 0, "Changed UIDVALIDITY for folder $folder. Some new messages might have been skipped." );
                    }
                }
            }
            else {
                $self->log_( 0, "Could not LOGIN for folder $folder." );
                delete $self->{folders__}{$folder}{imap};
            }
        }
        else {
            $self->log_( 0, "Could not CONNECT for folder $folder." );
            delete $self->{folders__}{$folder}{imap};
        }
    }
}



# ---------------------------------------------------------------------------------------------
#
# disconnect_folders__
#
#   The test suite needs a way to disconnect all the folders after one test is
#   done and the next test needs to be done with different settings.
#
# ---------------------------------------------------------------------------------------------

sub disconnect_folders__
{
    my ( $self ) = @_;

    foreach my $folder ( keys %{$self->{folders__}} ) {

        # We may already have a valid connection for this folder:
        if ( exists $self->{folders__}{$folder}{imap} ) {
            $self->logout( $folder );
        }
    }
    %{$self->{folders__}} = ();
}


# ---------------------------------------------------------------------------------------------
#
# scan_folder
#
#   This function scans a folder on the IMAP server.
#   According to the attributes of a folder (watched, output), and the attributes
#   of the message (new, classified, etc) it then decides what to do with the
#   messages.
#   There are currently three possible actions:
#       1. Classify the message and move to output folder
#       2. Reclassify message
#       3. Ignore message (if you want to call that an action)
#
# Arguments:
#
#   $folder: The folder to scan.
#
# ---------------------------------------------------------------------------------------------

sub scan_folder
{
    my ( $self, $folder) = @_;

    # make the flags more accessible.
    my $is_watched = ( exists $self->{folders__}{$folder}{watched} ) ? 1 : 0;
    my $is_output = ( exists $self->{folders__}{$folder}{output} ) ? $self->{folders__}{$folder}{output} : '';

    $self->log_( 1, "Looking for new messages in folder $folder." );

    # Do a NOOP first. Certain implementations won't tell us about
    # new messages while we are connected and selected otherwise:

    $self->say__( $folder, "NOOP" );
    my $result = $self->get_response__( $folder );
    if ( $result != 1 ) {
        $self->log_( 0, "NOOP failed (return value $result)" );
    }

    my $moved_message = 0;
    my @uids = $self->get_new_message_list( $folder );

    # We now have a list of messages with UIDs greater than or equal
    # to our last stored UIDNEXT value (of course, the list might be
    # empty). Let's iterate over that list.

    foreach my $msg ( @uids ) {
        $self->log_( 1, "Found new message in folder $folder (UID: $msg)" );

        my $hash = $self->get_hash( $folder, $msg );

        $self->uid_next__( $folder, $msg + 1 );

        # Watch our for those pesky duplicate and triplicate spam messages:

        if ( exists $self->{hash_values__}{$hash} ) {

            my $destination = $self->{hash_values__}{$hash};
            if ( $destination ne $folder ) {
                $self->log_( 0, "Found duplicate hash value: $hash. Moving the message to $destination." );
                $self->move_message( $folder, $msg, $destination );
                $moved_message++;
            }
            else {
                $self->log_( 0, "Found duplicate hash value: $hash. Ignoring duplicate in folder $folder." );
            }

            next;
        }

        # Find out what we are dealing with here:

        if ( $is_watched ) {
            if ( $self->can_classify__( $hash ) ) {

                my $result = $self->classify_message( $msg, $hash, $folder );

                if ( defined $result ) {
                    if ( $result ne '' ) {
                        $moved_message++;
                        $self->{hash_values__}{$hash} = $result;
                    }
                    else {
                        $self->{hash_values__}{$hash} = $folder;
                    }
                }
                next;
            }
        }

        if ( my $bucket = $is_output ) {
            if ( my $old_bucket = $self->can_reclassify__( $hash, $bucket ) ) {

                my $result = $self->reclassify_message( $folder, $msg, $old_bucket, $hash );

                next;
            }
        }

        # If we get here despite all those next statements, we do nothing and say so
        $self->log_( 1, "Ignoring message $msg" );
    }

    # After we are done with the folder, we issue an EXPUNGE command
    # if we were told to do so.

    if ( $moved_message && $self->config_( 'expunge' ) ) {
        $self->say__( $folder, "EXPUNGE" );
        $self->get_response__( $folder );
    }
}



# ---------------------------------------------------------------------------------------------
#
# classify_message
#
#   This function takes a message UID and then tries to classify the corresponding
#   message to a POPFile bucket. It delegates all the house-keeping that keeps
#   the POPFile statistics up to date to helper functions, but the house-keeping
#   is done. The caller need not worry about this.
#
# Arguments:
#
#   $msg:    UID of the message (the IMAP folder must be SELECTed)
#   $hash:   The hash of the message as computed by get_hash()
#   $folder: The name of the folder on the server in which this message was found
#
# Return value:
#
#   undef on error
#   The name of the destination folder if the message was moved
#   The emtpy string if the message was not moved
#
# ---------------------------------------------------------------------------------------------

sub classify_message
{
    my ( $self, $msg, $hash, $folder ) = @_;

    my $moved_a_msg = '';

    # open a temporary file that the classifier will
    # use to read the message in binary, read-write mode:
    my $pseudo_mailer;
    unless ( open $pseudo_mailer, "+>imap.tmp" ) {
        $self->log_( 0, "Unable to open temporary file. Nothing done to message $msg." );

        return;
    }
    binmode $pseudo_mailer;

    # We don't retrieve the complete message, but handle
    # it in different parts.
    # Currently these parts are just headers and body.
    # But there is room for improvement here.
    # E.g. we could generate a list of parts by
    # first looking at the parts the message really has.

    my @message_parts = qw/HEADER TEXT/;

    PART:
    foreach my $part ( @message_parts ) {

        my ($ok, @lines ) = $self->fetch_message_part__( $folder, $msg, $part );

        unless ( $ok ) {
            $self->log_( 0, "Could not fetch the $part part of message $msg." );

            return;
        }

        foreach ( @lines ) {
            print $pseudo_mailer "$_";
        }

        my ( $class, $slot, $magnet_used );

        # If we are dealing with the headers, let the
        # classifier have a non-save go:

        if ( $part eq 'HEADER' ) {
            seek $pseudo_mailer, 0, 0;
            ( $class, $slot, $magnet_used ) = $self->{classifier__}->classify_and_modify( $self->{api_session__}, $pseudo_mailer, undef, 1, '', 0 );

            if ( $magnet_used ) {
                $self->log_( 0, "Message was classified as $class using a magnet." );
                print $pseudo_mailer "\nThis message was classified based on a magnet.\nThe body of the message was not retrieved from the server.\n";
            }
            else {
                next PART;
            }
        }

        # We will only get here if the message was magnetized or we
        # are looking at the complete message. Thus we let the classifier have
        # a look and make it save the message to history:
        seek $pseudo_mailer, 0, 0;

        ( $class, $slot, $magnet_used ) = $self->{classifier__}->classify_and_modify( $self->{api_session__}, $pseudo_mailer, undef, 0, '', 0 );

        close $pseudo_mailer;
        unlink "imap.tmp";

        if ( $magnet_used || $part eq 'TEXT' ) {

            # Move message:

            my $destination = $self->folder_for_bucket__( $class );
            if ( defined $destination ) {
                if ( $folder ne $destination ) {
                    $self->move_message( $folder, $msg, $destination );
                    $moved_a_msg = $destination;
                }
            }
            else {
                $self->log_( 0, "Message cannot be moved because output folder for bucket $class is not defined." );
            }

            $self->log_( 0, "Message was classified as $class." );

            last PART;
        }
    }

    return $moved_a_msg;
}



# ---------------------------------------------------------------------------------------------
#
# reclassify_message
#
#   This function takes a message UID and then tries to reclassify the corresponding
#   message from one POPFile bucket to another POPFile bucket. It delegates all the
#   house-keeping that keeps the POPFile statistics up to date to helper functions,
#   but the house-keeping
#   is done. The caller need not worry about this.
#
# Arguments:
#
#   $folder:     The folder that has received a reclassification request
#   $msg:        UID of the message (the IMAP folder must be SELECTed)
#   $old_bucket: The previous classification of the message
#   $hash:       The hash of the message as computed by get_hash()
#
# Return value:
#
#   undef on error
#   true if things went allright
#
# ---------------------------------------------------------------------------------------------

sub reclassify_message
{
    my ( $self, $folder, $msg, $old_bucket, $hash ) = @_;

    my $new_bucket = $self->{folders__}{$folder}{output};
    my ( $ok, @lines ) = $self->fetch_message_part__( $folder, $msg, '' );

    unless ( $ok ) {
        $self->log_( 0, "Could not fetch message $msg!" );

        return;
    }

    # We have to write the message to a temporary file.
    # I simply use "imap.tmp" as the file name here.

    unless ( open TMP, ">imap.tmp" ) {
        $self->log_( 0, "Cannot open temp file imap.tmp" );

        return;
    };

    foreach ( @lines ) {
        print TMP "$_\n";
    }
    close TMP;

    my $slot = $self->{history__}->get_slot_from_hash( $hash );

    $self->{classifier__}->add_message_to_bucket( $self->{api_session__}, $new_bucket, "imap.tmp" );

    $self->{classifier__}->reclassified( $self->{api_session__}, $old_bucket, $new_bucket, 0 );
    $self->{history__}->change_slot_classification( $slot, $new_bucket, $self->{api_session__}, 0);

    $self->log_( 0, "Reclassified the message with UID $msg from bucket $old_bucket to bucket $new_bucket." );

    unlink "imap.tmp";
}


# ---------------------------------------------------------------------------------------------
#
# folder_uid_status__
#
#   This function checks the UID status of a given folder on the server.
#   To this end, we look at $self->{last_response} and look for an untagged
#   OK response containing UIDVALIDITY information.
#   Such a response must be send be the server in response to the SELECT
#   command. Thus, this function must only be called after SELECTing a folder.
#
# arguments:
#
#   $folder:        The name of the folder to be inspected.
#
# return value:
#   undef on error (changed uidvalidity)
#   true otherwise
# ---------------------------------------------------------------------------------------------

sub folder_uid_status__
{
    my ( $self, $folder ) = @_;

    # Save old UIDVALIDITY value (if we have one)
    my $old_val = $self->uid_validity__( $folder );

    # Extract current UIDVALIDITY value from server response
    my @lines = split /$eol/, $self->{folders__}{$folder}{last_response};
    my $uidvalidity;
    foreach ( @lines ) {
        if ( /^\* OK \[UIDVALIDITY (\d+)\]/ ) {
            $uidvalidity = $1;
            last;
        }
    }


    # if we didn't get the value, we have a problem
    unless ( defined $uidvalidity ) {
        $self->log_( 0, "Could not extract UIDVALIDITY status from server response!" );
        return;
    }

    # Check whether the old value is still valid
    if ( defined $old_val ) {
        if ( $uidvalidity != $old_val ) {
            $self->log_( 0, "UIDVALIDITY has changed! Expected $old_val, got $uidvalidity." );
            undef $old_val;
        }
    }

    # If we haven't got a valid validity value yet, then this
    # must be a new folder for us.
    # In that case, we do an extra STATUS command to get the current value
    # for UIDNEXT.
    unless ( defined $old_val ) {

        $self->say__( $folder, "STATUS \"$folder\" (UIDNEXT)" );
        my $response = $self->get_response__( $folder );

        if ( $response == 1 ) {

            @lines = split /$eol/, $self->{folders__}{$folder}{last_response};

            my $uidnext;

            foreach ( @lines ) {
                my $line = $_;

                # We are only interested in untagged responses to the STATUS command
                next unless $line =~ /\* STATUS/;

                $line =~ /UIDNEXT (.+?)( |\))/i;
                $uidnext = $1;

                unless ( defined $uidnext ) {
                    $self->log_( 0, "Could not extract UIDNEXT value from server response!!" );
                    return;
                }

                $self->uid_next__( $folder, $uidnext );
                $self->uid_validity__( $folder, $uidvalidity );
                $self->log_( 1, "Updated folder status (UIDVALIDITY and UIDNEXT) for folder $folder." );
            }
        }
        else {
            $self->log_( 0, "Could not STATUS folder $folder!!" );
            return;
        }
    }
    return 1;
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

    $self->log_( 1, "Connecting to $hostname:$port" );

    if ( $hostname ne '' && $port ne '' ) {

        my $response = '';

        my $imap;

        if ( $self->config_( 'use_ssl' ) ) {
            require IO::Socket::SSL;
            $imap = IO::Socket::SSL->new (
                                Proto    => "tcp",
                                PeerAddr => $hostname,
                                PeerPort => $port,
                                Timeout  => $self->global_config_( 'timeout' )
                                          );
        }
        else {
            $imap = IO::Socket::INET->new(
                                Proto    => "tcp",
                                PeerAddr => $hostname,
                                PeerPort => $port,
                                Timeout  => $self->global_config_( 'timeout' )
                                         );
        }


        # Check that the connect succeeded for the remote server
        if ( $imap ) {
            if ( $imap->connected )  {

                # Set binmode on the socket so that no translation of CRLF
                # occurs

                if ( $self->config_( 'use_ssl' ) == 0 ) {
                    binmode( $imap );
                }

                # Wait for a response from the remote server and if
                # there isn't one then give up trying to connect

                my $selector = new IO::Select( $imap );
                unless ( () = $selector->can_read( $self->global_config_( 'timeout' ) ) ) {
                    $self->log_( 0, "Connection timed out for $hostname:$port" );
                    return;
                }

                $self->log_( 0, "Connected to $hostname:$port timeout " . $self->global_config_( 'timeout' ) );

                # Read the response from the real server
                my $buf = $self->slurp_( $imap );
                $self->log_( 1, ">> $buf" );
                return $imap;
            }
        }
    }
    else {
        $self->log_( 0, "Invalid port or hostname. Will not connect to server." );
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
#   $imap: a valid socket object or the name of a folder.
#
# Return values:
#   0 on failure
#   1 on success
# ---------------------------------------------------------------------------------------------

sub login
{
    my ( $self, $imap ) = @_;
    my ( $login, $pass ) = ( $self->config_( 'login' ), $self->config_( 'password' ) );

    $self->log_( 1, "Logging in" );

    $self->say__( $imap, "LOGIN \"$login\" \"$pass\"" );

    if ( $self->get_response__( $imap ) == 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}


# ---------------------------------------------------------------------------------------------
#
# logout
#
#   log out of the the server we are currently connected to.
#
# Arguments:
#   $imap_or_folder: a valid socket object or the name of a folder
#
# Return values:
#   0 on failure
#   1 on success
# ---------------------------------------------------------------------------------------------

sub logout
{
    my ( $self, $imap_or_folder ) = @_;

    $self->log_( 1, "Logging out" );

    $self->say__( $imap_or_folder, "LOGOUT" );

    if ( $self->get_response__( $imap_or_folder ) == 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}

# ---------------------------------------------------------------------------------------------
#
# raw_say
#
#   The worker function for say__. You should normally not need to call this
#   function directly.
#
# Arguments:
#
#   $imap:      A valid socket object
#   $tag:       A numeric value that will be used to tag the commmand
#   $command:   What you want to say to the server
#
# Return value:
#   undef on error. True on success.
#
# ---------------------------------------------------------------------------------------------

sub raw_say
{
    my ( $self, $imap, $tag, $command ) = @_;

    my $cmdstr = sprintf "A%05d %s%s", $tag, $command, $eol;

    # Talk to the server
    unless( print $imap $cmdstr ) {
        $imap->shutdown( 2 );
        return;
    }

    # Log command
    # Obfuscate login and password for logins:
    $cmdstr =~ s/^(A\d+) LOGIN ".+?" ".+"(.+)/$1 LOGIN "xxxxx" "xxxxx"$2/;
    $self->log_( 1, "<< $cmdstr" );

    return 1;
}



# ---------------------------------------------------------------------------------------------
#
# say__
#
#   Issue a command to the server we are connected to.
#
# Arguments:
#
#   $imap_or_folder:
#       This can be either a valid socket object or the name of a
#       folder in the $self->{folders__} hash
#   $command:
#       What you want to say to the server without the tag, though.
#
# Return value:
#   None. Will die on error, though.
#
# ---------------------------------------------------------------------------------------------

sub say__
{
    my ( $self, $imap_or_folder, $command ) = @_;

    # Did we get a socket object?
    if ( ref( $imap_or_folder ) eq 'IO::Socket::INET' || ref( $imap_or_folder ) eq 'IO::Socket::SSL' ) {

        $self->{last_command__} = $command;

        unless ( $self->raw_say ( $imap_or_folder, $self->{tag__}, $command ) ) {
            die( "The connection to the IMAP server was lost. Could not talk to the server." );
        }
    }
    # or a folder?
    else {

        $self->{folders__}{$imap_or_folder}{last_command} = $command;

        # Is there a socket connection in the folders hash?

        unless ( exists $self->{folders__}{$imap_or_folder}{imap} ) {
            # No! commit suicide.
            $self->log_( 0, "Got a folder ($imap_or_folder) with no attached socket in say!" );
            die( "The connection to the IMAP server was lost. Could not talk to the server." );
        }

        unless ( $self->raw_say( $self->{folders__}{$imap_or_folder}{imap},
                                 $self->{folders__}{$imap_or_folder}{tag},
                                 $command ) ) {
            # If we failed to talk to the server, delete socket object, and die.
            delete $self->{folders__}{$imap_or_folder}{imap};
            die( "The connection to the IMAP server was lost. Could not talk to the server (folder $imap_or_folder)." );
        }
    }
}


# ---------------------------------------------------------------------------------------------
#
# raw_get_response
#
#   Get a response from our server. You should normally not need to call this function
#   directly. Use get_response__ instead.
#
# Arguments:
#
#   $imap:         A valid socket object
#   $last_command: The command we are issued before.
#   $tag_ref:      A reference to a scalar that will receive tag value that can be
#                  used to tag the next command
#   $response_ref: A reference to a scalar that will receive the servers response.
#
# Return value:
#   undef   lost connection
#   1       Server answered OK
#   0       Server answered NO
#   -1      Server answered BAD
#   -2      Server gave unexpected tagged answer
#   -3      Server didn't say anything, but the connection is still valid (I guess this cannot happen)
#
# ---------------------------------------------------------------------------------------------

sub raw_get_response
{
    my ( $self, $imap, $last_command, $tag_ref, $response_ref ) = @_;

    # What is the actual tag we have to look for?
    my $actual_tag = sprintf "A%05d", $$tag_ref;

    my $response = '';
    my $count_octets = 0;
    my $octet_count = 0;

    # Slurp until we find a reason to quit
    while ( my $buf = $self->slurp_( $imap ) ) {

        # Check for lost connections:
        if ( $response eq '' && ! defined $buf ) {
            $imap->shutdown( 2 );
            return;
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
            $self->log_( 2, ">> $buf" );
        }

        # If we aren't counting octets (anymore), we look out for tag
        # followed by BAD, NO, or OK and we also keep an eye open
        # for untagged responses that the server might send us unsolicited
        if ( $count_octets == 0 ) {
            if ( $buf =~ /^$actual_tag (OK|BAD|NO)/ ) {

                if ( $1 ne 'OK' ) {
                    $self->log_( 0, ">> $buf" );
                }
                else {
                    $self->log_( 1, ">> $buf" );
                }

                last;
            }

            # Here we look for untagged responses and decide whether they are
            # solicited or not based on the last command we gave the server.

            if ( $buf =~ /^\* (.+)/ ) {
                my $untagged_response = $1;

                $self->log_( 1, ">> $buf" );

                # This should never happen, but under very rare circumstances,
                # we might get a change of the UIDVALIDITY value while we
                # are connected
                if ( $untagged_response =~ /UIDVALIDITY/
                        && $last_command !~ /^SELECT/ ) {
                    $self->log_( 0, "Got unsolicited UIDVALIDITY response from server while reading response for $last_command." );
                }

                # This could happen, but will be caught by the eval in service().
                # Nevertheless, we look out for unsolicited bye-byes here.
                if ( $untagged_response =~ /^BYE/
                        && $last_command !~ /^LOGOUT/ ) {
                    $self->log_( 0, "Got unsolicited BYE response from server while reading response for $last_command." );
                }
            }
        }
    }

    # save result away so we can always have a look later on
    $$response_ref = $response;

    # Increment tag for the next command/reply sequence:
    $$tag_ref++;

    if ( $response ) {

        # determine our return value

        # We got 'OK' and the correct tag.
        if ( $response =~ /^$actual_tag OK/m ) {
            return 1;
        }
        # 'NO' plus correct tag
        elsif ( $response =~ /^$actual_tag NO/m ) {
            return 0;
        }
        # 'BAD' and correct tag.
        elsif ( $response =~ /^$actual_tag BAD/m ) {
            return -1;
        }
        # Someting else, probably a different tag, but who knows?
        else {
            $self->log_( 0, "!!! Server said something unexpected !!!" );
            return -2;
        }
    }
    else {
        $imap->shutdown( 2 );
        return;
    }
}



# ---------------------------------------------------------------------------------------------
#
# get_response__
#
# Use this function to get a response from the server. The response will be stored in
# $self->{last_response__} if you pass in a socket object or in
# $self->{folders}{$folder}{last_response} if you pass in a folder name
#
# Arguments:
#   $imap_or_folder:
#       Either a valid socket object or the name of a folder that is stored in the
#       folders hash.
#
#   Return values:
#      1: Server said OK to our last command
#      0: Server said NO to our last command
#     -1: Server said BAD to our last command
#     -2: Server said something else or reponded to another command
#     -3: Server didn't say anything
#   Will die on lost connections!
# ---------------------------------------------------------------------------------------------

sub get_response__
{
    my ( $self, $imap_or_folder ) = @_;

    my $result;

    # Are we dealing with a socket object?
    if ( ref( $imap_or_folder ) eq 'IO::Socket::INET' ||  ref( $imap_or_folder ) eq 'IO::Socket::SSL' ) {
        $result = $self->raw_get_response( $imap_or_folder,
                                              $self->{last_command__},
                                              \$self->{tag__},
                                              \$self->{last_response__} );
        unless ( defined $result ) {
            die "The connection to the IMAP server was lost. Could not listen to the server.";
        }
    }
    # Or did we get a folder name?
    else {

        # Is there a socket object stored in the folders hash?
        unless ( exists $self->{folders__}{$imap_or_folder}{imap} ) {
            $self->log_( 0, "Got a folder with no attached socket in get_response!" );
            die( "The connection to the IMAP server was lost. Could not listen to the server." );
        }

        $result = $self->raw_get_response ( $self->{folders__}{$imap_or_folder}{imap},
                                               $self->{folders__}{$imap_or_folder}{last_command},
                                              \$self->{folders__}{$imap_or_folder}{tag},
                                              \$self->{folders__}{$imap_or_folder}{last_response} );

        # die if we didn't succeed.
        unless ( defined $result ) {
            delete $self->{folders__}{$imap_or_folder}{imap};
            die "The connection to the IMAP server was lost. Could not listen to the server.";
        }

    }

    # return what raw_get_response gave us.
    return $result;
}



# ---------------------------------------------------------------------------------------------
#
# get_mailbox_list
#
#   Request a list of mailboxes from the server behind the passed in socket object.
#   The list is stored away in @{$self->{mailboxes__}} and returned.
#
# Arguments:
#   $imap: contains a valid connection to our IMAP server.
#
# Return value:
#
#   The list of mailboxes
# ---------------------------------------------------------------------------------------------

sub get_mailbox_list
{
    my ( $self, $imap ) = @_;

    $self->log_( 1, "Getting mailbox list" );

    $self->say__( $imap, "LIST \"\" \"*\"" );
    my $result = $self->get_response__( $imap );
    if ( $result != 1 ) {
        $self->log_( 0, "LIST command failed (return value $result)." );
    }

    my @lines = split /$eol/, $self->{last_response__};
    my @mailboxes;

    foreach ( @lines ) {
        next unless /^\*/;
        s/^\* LIST \(.*\) .+? (.+)$/$1/;
        s/"(.*?)"/$1/;
        push @mailboxes, $1;
    }

    @{$self->{mailboxes__}} = sort @mailboxes;

    return @{$self->{mailboxes__}};
}






# ---------------------------------------------------------------------------------------------
#
# fetch_message_part__
#
#   This function will fetch a specified part of a specified message from
#   the IMAP server and return the message as a list of lines.
#   It assumes that a folder is already SELECTed
#
# arguments:
#
#   $folder:    the currently selected folder
#   $msg:       UID of the message
#   $part:      The part of the message you want to fetch. Could be 'HEADER' for the
#               message headers, 'TEXT' for the body (including any attachments), or '' to
#               fetch the complete message. Other values are also possible, but currently
#               not used. 'BODYSTRUCTURE' could be interesting.
#
# return values:
#
#       a boolean value indicating success/fallure and
#       a list containing the lines of the retrieved message (part).
#
# ---------------------------------------------------------------------------------------------

sub fetch_message_part__
{
    my ( $self, $folder, $msg, $part ) = @_;

    if ( $part ne '' ) {
        $self->log_( 1, "Fetching $part of message $msg" );
    }
    else {
        $self->log_( 1, "Fetching message $msg" );
    }

    $self->say__( $folder, "UID FETCH $msg (FLAGS BODY.PEEK[$part])" );

    my $result = $self->get_response__( $folder );

    if ( $part ne '' ) {
        $self->log_( 1, "Got $part of message # $msg, result: $result." );
    }
    else {
        $self->log_( 1, "Got message # $msg, result: $result." );
    }

    if ( $result == 1 ) {
        my @lines = ();

        # The first line now MUST start with "* x FETCH" where x is a message
        # sequence number anything else indicates that something went wrong
        # or that something changed. E.g. the message we wanted
        # to fetch is no longer there.

        if ( $self->{folders__}{$folder}{last_response} =~ m/\^* \d+ FETCH/ ) {

            # The first line should contain the number of octets the server send us

            if ( $self->{folders__}{$folder}{last_response} =~ m/(?!$eol){(\d+)}$eol/ ) {
                my $num_octets = $1;

                # Grab the number of octets reported:

                my $pos = index $self->{folders__}{$folder}{last_response}, "{$num_octets}$eol";
                $pos += length "{$num_octets}$eol";

                my $message = substr $self->{folders__}{$folder}{last_response}, $pos, $num_octets;

                # Take the large chunk and chop it into single lines

                # We cannot use split here, because this would get rid of
                # trailing and leading newlines and thus omit complete lines.

                while ( $message =~ m/(.*?$eol)/g ) {
                    push @lines, $1;
                }
            }
            # No number of octets: fall back, but issue a warning
            else {
                while ( $self->{folders__}{$folder}{last_response} =~ m/(.*?$eol)/g ) {
                    push @lines, $1;
                }

                # discard the first and the two last lines; these are server status responses.
                shift @lines;
                pop @lines;
                pop @lines;

                $self->log_( 0, "Could not find octet count in server's response!" );
            }
        }
        else {
            $self->log_( 0, "Unexpected server response to the FETCH command!" );
        }

        return 1, @lines;
    }
    else {
        return 0;
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
    my ( $self, $folder, $msg, $destination ) = @_;

    $self->log_( 1, "Moving message $msg to $destination" );

    my $ok = 0;

    if ( $self->{folders__}{$folder}{server} == $self->{folders__}{$destination}{server} ) {

        # Copy message to destination
        $self->say__( $folder, "UID COPY $msg \"$destination\"" );
        my $ok = $self->get_response__( $folder );

        # If that went well, flag it as deleted
        if ( $ok == 1 ) {
            $self->say__( $folder, "UID STORE $msg +FLAGS (\\Deleted)" );
            $ok = $self->get_response__( $folder );
        }
        else {
            $self->log_( 0, "Could not copy message ($ok)!" );
        }
    }
    else {
        $self->log_( 0, "We don't yet know how to move messages between servers" );
    }

    return ( $ok ? 1 : 0 );
}


# ---------------------------------------------------------------------------------------------
#
# get_new_message_list
#
#   Will search for messages on the IMAP server that are not flagged as deleted
#   that have a UID greater than or equal to the value stored for the passed in folder.
#
# arguments:
#
#   $folder:       Name of the folder we are looking at.
#
# return value:
#
#   A list (possibly empty) of the UIDs of matching messages.
#
# ---------------------------------------------------------------------------------------------

sub get_new_message_list
{
    my ( $self, $folder ) = @_;

    my $uid = $self->uid_next__( $folder );

    $self->log_( 1, "Getting uids ge $uid" );

    $self->say__( $folder, "UID SEARCH UID $uid:* UNDELETED" );
    my $result = $self->get_response__( $folder );
    if ( $result != 1 ) {
        $self->log_( 0, "SEARCH command failed (return value: $result)!" );
    }

    # The server will respond with an untagged search reply.
    # This can either be empty ("* SEARCH") or if a
    # message was found it contains the numbers of the matching
    # messages, e.g. "* SEARCH 2 5 9".
    # In the latter case, the regexp below will match and
    # capture the list of messages in $1

    my @matching = ();

    if ( $self->{folders__}{$folder}{last_response} =~ /\* SEARCH (.+)$eol/ ) {

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

    return ( sort { $a <=> $b } @return_list );
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
        $self->log_( 1, "Updated UIDVALIDITY value for folder $folder to $uidval." );
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
        $self->log_( 1, "Updated UIDNEXT value for folder $folder to $uidnext." );
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


sub history
{
    my ( $self, $history ) = @_;

    $self->{history__} = $history;
}


#----------------------------------------------------------------------------
# get hash
#
# Computes a hash of the MID and Date header lines of this message.
# Note that a folder on the server needs to be selected for this to work.
#
# Arguments:
#
#   $folder:    Name of the folder we are currently servicing.
#   $msg:       message UID
#
# Return value:
#   A string containing the hash value or undef on error.
#
#----------------------------------------------------------------------------

sub get_hash
{
    my ( $self, $folder, $msg ) = @_;

    my ( $ok, @lines ) = $self->fetch_message_part__( $folder, $msg, "HEADER.FIELDS (Message-id Date Subject Received)" );

    if ( $ok ) {

        my %header;
        my $last;

        foreach ( @lines ) {

            s/[\r\n]//g;

            last if /^$/;

            if ( /^([^ \t]+):[ \t]*(.*)$/ ) {
                $last = lc $1;
                push @{$header{$last}}, $2;
            }
            else {
                if ( defined $last ) {
                    ${$header{$last}}[$#{$header{$last}}] .= $_;
                }
            }
        }

        my $mid      = ${$header{'message-id'}}[0];
        my $date     = ${$header{'date'}}[0];
        my $subject  = ${$header{'subject'}}[0];
        my $received = ${$header{'received'}}[0];

        my $hash = $self->{history__}->get_message_hash( $mid, $date, $subject, $received );

        $self->log_( 1, "Hashed message: $subject." );
        $self->log_( 1, "Message $msg has hash value $hash" );

        return $hash;
    }
    else {
        $self->log_( 0, "Could not FETCH the header fields of message $msg!" );
        return;
    }
}



#----------------------------------------------------------------------------
#   can_classify__
#
#   This function is a decider. It decides whether a message can be
#   classified if found in one of our watched folders or not.
#
# arguments:
#   $hash: The hash value for this message
#
# returns true or false
#----------------------------------------------------------------------------

sub can_classify__
{
    my ( $self, $hash ) = @_;

    my $slot = $self->{history__}->get_slot_from_hash( $hash );

    if ( $slot  ne '' ) {
        $self->log_( 1, "Message was already classified (slot $slot)." );
        return 0;
    }
    else {
        $self->log_( 1, "The message is not yet in history." );
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

    # We must already know the message

    my $slot = $self->{history__}->get_slot_from_hash( $hash );

    if ( $slot ne '' ) {

        my ( $id, $from, $to, $cc, $subject, $date, $hash, $inserted, $bucket, $reclassified ) =
                    $self->{history__}->get_slot_fields( $slot );

        $self->log_( 2, "get_slot_fields returned the following information:" );
        $self->log_( 2, "id:            $id" );
        $self->log_( 2, "from:          $from" );
        $self->log_( 2, "to:            $to" );
        $self->log_( 2, "cc:            $cc" );
        $self->log_( 2, "subject:       $subject");
        $self->log_( 2, "date:          $date" );
        $self->log_( 2, "hash:          $hash" );
        $self->log_( 2, "inserted:      $inserted" );
        $self->log_( 2, "bucket:        $bucket" );
        $self->log_( 2, "reclassified:  $reclassified" );

        # We must not reclassify a reclassified message
        if ( ! $reclassified ) {

            # new and old bucket must be different
            if ( $new_bucket ne $bucket ) {
                return $bucket;
            }
            else {
                $self->log_( 1, "Will not reclassify to same bucket ($new_bucket)." );
            }
        }
        else {
            $self->log_( 1, "The message was already reclassified." );
        }
    }
    else {
        $self->log_( 1, "Message is unknown and cannot be reclassified." );
    }

    return;
}





# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            Name of this item
#    $templ           The loaded template that was passed as a parameter
#                     when registering
#    $language        Current language
#
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    # conection details
    if ( $name eq 'imap_0_connection_details' ) {
        $templ->param( 'IMAP_hostname', $self->config_( 'hostname' ) );
        $templ->param( 'IMAP_port',     $self->config_( 'port' ) );
        $templ->param( 'IMAP_login',    $self->config_( 'login' ) );
        $templ->param( 'IMAP_password', $self->config_( 'password' ) );
    }

    # Which mailboxes/folders should we be watching?
    if ( $name eq 'imap_1_watch_folders' ) {

        # We can only configure this when we have a list of mailboxes available on the server
        if ( @{$self->{mailboxes__}} < 1 || ( ! $self->watched_folders__() ) ) {
            $templ->param( IMAP_if_mailboxes => 0 );
        }
        else {
            $templ->param( IMAP_if_mailboxes => 1 );

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
                $data_watched_folders{IMAP_WatchedFolder_Msg} = $$language{Imap_WatchedFolder};

                push @loop_watched_folders, \%data_watched_folders;
            }

            $templ->param( IMAP_loop_watched_folders => \@loop_watched_folders );
        }
    }

    # Give me another watched folder.
    if ( $name eq 'imap_2_watch_more_folders' ) {
        if ( @{$self->{mailboxes__}} < 1 ) {
            $templ->param( IMAP_if_mailboxes => 0 );
        }
        else {
            $templ->param( IMAP_if_mailboxes => 1 );
        }
    }


    # Which folder corresponds to which bucket?
    if ( $name eq 'imap_3_bucket_folders' ) {
        if ( @{$self->{mailboxes__}} < 1 ) {
            $templ->param( IMAP_if_mailboxes => 0 );
        }
        else {
            $templ->param( IMAP_if_mailboxes => 1 );

            my @buckets = $self->{classifier__}->get_all_buckets( $self->{api_session__} );

            my @outer_loop = ();

            foreach my $bucket ( @buckets ) {
                my %outer_data = ();
                my $output = $self->folder_for_bucket__( $bucket );

                $outer_data{IMAP_mailbox_defined} = (defined $output) ? 1 : 0;
                $outer_data{IMAP_Bucket_Header} = sprintf( $$language{Imap_Bucket2Folder}, $bucket );

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
            $templ->param( IMAP_loop_buckets => \@outer_loop );
        }
    }



    # Read the list of mailboxes from the server. Now!
    if ( $name eq 'imap_4_update_mailbox_list' ) {
        if ( $self->config_( 'hostname' ) eq '' ) {
            $templ->param( IMAP_if_connection_configured => 0 );
        }
        else {
            $templ->param( IMAP_if_connection_configured => 1 );
        }
    }


    # Various options for the IMAP module
    if ( $name eq 'imap_5_options' ) {

        # Are we expunging after moving messages?
        my $checked = $self->config_( 'expunge' ) ? 'checked="checked"' : '';
        $templ->param( IMAP_expunge_is_checked => $checked );

        # Update interval in seconds
        $templ->param( IMAP_interval => $self->config_( 'update_interval' ) );

        # How many bytes should we use for classification?
        $templ->param( IMAP_byte_limit => $self->config_( 'byte_limit' ) );
    }
}



# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    # connection details
    if ( $name eq 'imap_0_connection_details' ) {
        if ( defined $$form{update_imap_0_connection_details} ) {
            if ( $$form{imap_hostname} ne '' ) {
                $templ->param( IMAP_connection_if_hostname_error => 0 );
                $self->config_( 'hostname', $$form{imap_hostname} );
            }
            else {
                $templ->param( IMAP_connection_if_hostname_error => 1 );
            }

            if ( $$form{imap_port} >= 1 && $$form{imap_port} < 65536 ) {
                $self->config_( 'port', $$form{imap_port} );
                $templ->param( IMAP_connection_if_port_error => 0 );
            }
            else {
                $templ->param( IMAP_connection_if_port_error => 1 );
            }

            if ( $$form{imap_login} ne '' ) {
                $self->config_( 'login', $$form{imap_login} );
                $templ->param( IMAP_connection_if_login_error => 0 );
            }
            else {
                $templ->param( IMAP_connection_if_login_error => 1 );
            }

            if ( $$form{imap_password} ne '' ) {
                $self->config_( 'password', $$form{imap_password} );
                $templ->param( IMAP_connection_if_password_error => 0 );
            }
            else {
                $templ->param( IMAP_connection_if_password_error => 1 );
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
            $self->{folder_change_flag__} = 1;
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

                    $self->{folder_change_flag__} = 1;
                }
            }
            $templ->param( IMAP_buckets_to_folders_if_error => $bad );
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
                            $self->logout( $imap );
                            $templ->param( IMAP_update_list_failed => '' );
                        }
                        else {
                            $templ->param( IMAP_update_list_failed => 'Could not login. Verify your login name and password, please.' );
                            # should be language__{Imap_UpdateError1}
                        }
                    }
                    else {
                        $templ->param( IMAP_update_list_failed => 'Failed to connect to server. Please check the host name and port and make sure you are online.' );
                        # should be language__{Imap_UpdateError2}
                    }
            }
            else {
                $templ->param( IMAP_update_list_failed => 'Please configure the connection details first.' );
                # should be language__{Imap_UpdateError3}
            }
        }
        return;
    }


    # various options
    if ( $name eq 'imap_5_options' ) {

        if ( defined $$form{update_imap_5_options} ) {

            # expunge or not?
            if ( defined $$form{imap_options_expunge} ) {
                $self->config_( 'expunge', 1 );
            }
            else {
                $self->config_( 'expunge', 0 );
            }

            # update interval
            my $form_interval = $$form{imap_options_update_interval};
            if ( defined $form_interval ) {
                if ( $form_interval > 10 && $form_interval < 60*60 ) {
                    $self->config_( 'update_interval', $form_interval );
                    $templ->param( IMAP_if_interval_error => 0 );
                }
                else {
                    $templ->param( IMAP_if_interval_error => 1 );
                }
            }
            else {
                $templ->param( IMAP_if_interval_error => 1 );
            }

            # byte limit
            if ( defined $$form{imap_options_byte_limit} && $$form{imap_options_byte_limit} =~ m/^\d+\s*$/ ) {
                $self->config_( 'byte_limit', $$form{imap_options_byte_limit} );
                $templ->param( IMAP_if_bytelimit_error => 0 );
            }
            else {
                $templ->param( IMAP_if_bytelimit_error => 1 );
            }
        }
        return;
    }


    $self->SUPER::validate_item( $name, $templ, $language, $form );
}


sub train_on_archive__
{
    my ( $self ) = @_;

    $self->log_( 0, "Training on existing archive." );

    # Reset the folders hash and build it again.

    %{$self->{folders__}} = ();
    $self->build_folder_list__();

    # eliminate all watched folders
    foreach my $folder ( keys %{$self->{folders__}} ) {
        if ( exists $self->{folders__}{$folder}{watched} ) {
            delete $self->{folders__}{$folder};
        }
    }

    # Connect to server
    $self->connect_folders__();

    foreach my $folder ( keys %{$self->{folders__}} ) {

        # Set uidnext value to 0. We will train on all messages.
        $self->uid_next__( $folder, 0 );
        my @uids = $self->get_new_message_list( $folder );
        my $bucket = $self->{folders__}{$folder}{output};

        # Skip pseudobuckets and the INBOX
        next if $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $bucket );
        next if $folder eq 'INBOX';

        $self->log_( 0, "Training on messages in folder $folder to bucket $bucket." );

        foreach my $msg ( @uids ) {

            my ( $ok, @lines ) = $self->fetch_message_part__( $folder, $msg, '' );

            $self->uid_next__( $folder, $msg );

            unless ( $ok ) {
                $self->log_( 0, "Could not fetch message $msg!" );
                next;
            }

            unless ( open TMP, ">imap.tmp" ) {
                $self->log_( 0, "Cannot open temp file imap.tmp" );
                next;
            };

            foreach ( @lines ) {
                print TMP "$_\n";
            }
            close TMP;

            $self->{classifier__}->add_message_to_bucket( $self->{api_session__}, $bucket, "imap.tmp" );

            $self->log_( 0, "Training on the message with UID $msg to bucket $bucket." );

            unlink "imap.tmp";

        }
    }
    # Again, reset folders__ hash.
    %{$self->{folders__}} = ();

    # And disable training mode so we won't do this again the next time service is called.
    $self->config_( 'training_mode', 0 );
}


1;

