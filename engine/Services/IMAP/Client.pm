# ----------------------------------------------------------------------------
#
# Services::IMAP::Client--- Helper module for the POPFile IMAP module
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   $Revision$
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
#   Originally created by   Manni Heumann (mannih2001@users.sourceforge.net)
#   Modified by             Sam Schinke (sschinke@users.sourceforge.net)
#   Patches by              David Lang (davidlang@users.sourceforge.net)
#
# ----------------------------------------------------------------------------

package Services::IMAP::Client;
use base qw/ POPFile::Module /;

use strict;
use warnings;

use IO::Socket;
use Carp;

my $eol = "\015\012";
my $cfg_separator = "-->";

# ----------------------------------------------------------------------------
#
# new - Create a new IMAP client object
#
# IN: two subroutine refs and an integer
#      config        -> reference to the config_ sub
#      log           -> reference to logger module
#      global_config -> reference to the global_config_ sub
#
# OUT: a blessed object or undef if the config hash was incomplete
# ----------------------------------------------------------------------------

sub new {
    my $class         = shift;
    my $config        = shift;
    my $log           = shift;
    my $global_config = shift;

    my $self = bless {}, $class;

    # This is needed when the client module is run in POPFile 0.22.2 context
    $self->{logger__} = $log or return;
    # And this one is for the 0.23 (aka 2.0) context:
    $self->{modules__}{logger} = $log;

    $self->{config__} = $config or return;
    $self->{global_config__} = $global_config or return;

    $self->{host}  = $self->config_( 'hostname' );
    $self->{port}  = $self->config_( 'port' );
    $self->{login} = $self->config_( 'login' );
    $self->{pass}  = $self->config_( 'password' );
    $self->{ssl}   = $self->config_( 'use_ssl' );

    $self->{timeout} = $self->global_config_( 'timeout' );
    $self->{cutoff}  = $self->global_config_( 'message_cutoff' );


    $self->{socket} = undef;
    $self->{folder} = undef;
    $self->{tag}    = 0;
    $self->{name__} = 'IMAP-Client';

    return $self;
}


# ----------------------------------------------------------------------------
#
# config_ - Replacement for POPFile::Module::config_
# ----------------------------------------------------------------------------

sub config_ {
    my $self = shift;
    return &{$self->{config__}}( @_ );
}


# ----------------------------------------------------------------------------
#
# global_config_ - Replacement for POPFile::Module::global_config_
# ----------------------------------------------------------------------------

sub global_config_ {
    my $self = shift;
    return &{$self->{global_config__}}( @_ );
}


# ----------------------------------------------------------------------------
#
# connect - Connect to the IMAP server.
#
# IN:  -
# OUT: true on success
#      undef on error
# ----------------------------------------------------------------------------

sub connect {
    my $self = shift;

    my $hostname = $self->{host};
    my $port     = $self->{port};
    my $use_ssl  = $self->{ssl};
    my $timeout  = $self->{timeout};

    $self->log_( 1, "Connecting to $hostname:$port" );

    if ( $hostname ne '' && $port ne '' ) {
        my $response = '';
        my $imap;

        if ( $use_ssl ) {
            require IO::Socket::SSL;
            $imap = IO::Socket::SSL->new (
                                Proto    => "tcp",
                                PeerAddr => $hostname,
                                PeerPort => $port,
                                Timeout  => $timeout,
                                Domain   => AF_INET,
                    )
                    or $self->log_(0, "IO::Socket::SSL error: $@");
        }
        else {
            $imap = IO::Socket::INET->new(
                                Proto    => "tcp",
                                PeerAddr => $hostname,
                                PeerPort => $port,
                                Timeout  => $timeout,
                    )
                    or $self->log_(0, "IO::Socket::INET error: $@");
        }


        # Check that the connect succeeded for the remote server
        if ( $imap ) {
            if ( $imap->connected )  {
                # Set binmode on the socket so that no translation of CRLF
                # occurs
                binmode( $imap ) if $use_ssl == 0;

                # Wait for a response from the remote server and if
                # there isn't one then give up trying to connect
                my $selector = IO::Select->new( $imap );
                unless ( () = $selector->can_read( $timeout ) ) {
                    $self->log_( 0, "Connection timed out for $hostname:$port" );
                    return;
                }

                $self->log_( 0, "Connected to $hostname:$port timeout $timeout" );

                # Read the response from the real server
                my $buf = $self->slurp_( $imap );
                $self->log_( 1, ">> $buf" );
                $self->{socket} = $imap;
                return 1;
            }
        }
    }
    else {
        $self->log_( 0, "Invalid port or hostname. Will not connect to server." );
        return;
    }
}


# ----------------------------------------------------------------------------
#
# login - Login on the IMAP server.
#
# IN:  -
# OUT: true on success
#      undef on error
# ----------------------------------------------------------------------------

sub login {
    my $self = shift;

    my $login = $self->{login};
    my $pass  = $self->{pass};

    $self->log_( 1, "Logging in" );

    $self->say( 'LOGIN "' . $login . '" "' . $pass . '"' );

    if ( $self->get_response() == 1 ) {
        return 1;
    }
    else {
        return;
    }
}

# ----------------------------------------------------------------------------
#
# noop - Do a NOOP on the server. Whatever that might be good for.
#
# IN:  -
# OUT: see get_response()
# ----------------------------------------------------------------------------

sub noop {
    my $self = shift;

    $self->say( 'NOOP' );
    my $result = $self->get_response();
    $self->log_( 0, "NOOP failed (return value $result)" ) unless $result == 1;

    return $result;
}

# ----------------------------------------------------------------------------
#
# status - Do a STATUS on the server, asking for UIDNEXT and UIDVALIDITY
#          information.
#
# IN:  $folder - name of the mailbox to be STATUSed
# OUT: hashref with the keys UIDNEXT and UIDVALIDITY
# ----------------------------------------------------------------------------

sub status {
    my $self   = shift;
    my $folder = shift;
    my $ret    = { UIDNEXT => undef, UIDVALIDITY => undef };

    $self->say( "STATUS \"$folder\" (UIDNEXT UIDVALIDITY)" );
    if ( $self->get_response() == 1 ) {
        my @lines = split /$eol/, $self->{last_response};

        foreach ( @lines ) {
            if ( /^\* STATUS/ ) {
                if ( /UIDNEXT (\d+)/ ) {
                    $ret->{UIDNEXT} = $1;
                }
                if ( /UIDVALIDITY (\d+)/ ) {
                    $ret->{UIDVALIDITY} = $1;
                }
            }
            last;
        }
    }
    else {
        # TODO: what now?
    }

    foreach ( keys %$ret ) {
        if ( ! defined $ret->{$_}) {
            $self->log_( 0, "Could not get $_ STATUS for folder $folder." );
        }
    }
    return $ret;
}

# ----------------------------------------------------------------------------
#
# DESTROY - Destructor called by Perl
#
#  Will close the socket if it's connected.
#  TODO: This method could be friendly and try to logout first. OTOH, we
#        might no longer be logged in.
#
# ----------------------------------------------------------------------------

sub DESTROY {
    my $self = shift;
    $self->log_( 1, "IMAP-Client is exiting" );
    $self->{socket}->shutdown( 2 ) if defined $self->{socket};
}


# ----------------------------------------------------------------------------
#
# expunge - Issue an EXPUNGE command. We need to be in a SELECTED state for
#           this to work.
#
# IN:  -
# OUT: see get_response()
# ----------------------------------------------------------------------------

sub expunge {
    my $self = shift;
    $self->say( 'EXPUNGE' );
    $self->get_response();
}


# ----------------------------------------------------------------------------
#
# say - Say something to the server. This method will also provide a valid
#       tag and a nice line ending.
#
# IN:  $command - String containing the command
# OUT: true und success, undef on error
# ----------------------------------------------------------------------------

sub say {
    my $self    = shift;
    my $command = shift;

    $self->{last_command} = $command;
    my $tag = $self->{tag};

    my $cmdstr = sprintf "A%05d %s%s", $tag, $command, $eol;

    # Talk to the server
    unless( print {$self->{socket}} $cmdstr ) {
        $self->bail_out( "Lost connection while I tried to say '$cmdstr'." );
    }

    # Log command
    # Obfuscate login and password for logins:
    $cmdstr =~ s/^(A\d+) LOGIN ".+?" ".+"(.+)/$1 LOGIN "xxxxx" "xxxxx"$2/;
    $self->log_( 1, "<< $cmdstr" );

    return 1;
}


# ----------------------------------------------------------------------------
#
# get_response
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
# ----------------------------------------------------------------------------

sub get_response {
    my $self = shift;
    my $imap = $self->{socket};

    local $SIG{ALRM}
        = sub {
                  alarm 0;
                  $self->bail_out( "The connection to the IMAP server timed out while we waited for a response." );
              };
    alarm $self->global_config_( 'timeout' );

    # What is the actual tag we have to look for?
    my $actual_tag = sprintf "A%05d", $self->{tag};

    my $response = '';
    my $count_octets = 0;
    my $octet_count = 0;

    # Slurp until we find a reason to quit
    while ( my $buf = $self->slurp_( $imap ) ) {

        # Check for lost connections:
        if ( $response eq '' && ! defined $buf ) {
            $self->bail_out( "The connection to the IMAP server was lost while trying to get a response to command '$self->{last_command}'." );
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
                        && ( $self->{last_command} !~ /^SELECT/ && $self->{last_command} !~ /^STATUS/ ) ) {
                    $self->log_( 0, "Got unsolicited UIDVALIDITY response from server while reading response for $self->{last_command}." );
                }

                # This could happen, but will be caught by the eval in service().
                # Nevertheless, we look out for unsolicited bye-byes here.
                if ( $untagged_response =~ /^BYE/
                        && $self->{last_command} !~ /^LOGOUT/ ) {
                    $self->log_( 0, "Got unsolicited BYE response from server while reading response for $self->{last_command}." );
                }
            }
        }
    }

    # save result away so we can always have a look later on
    $self->{last_response} = $response;

    alarm 0;

    # Increment tag for the next command/reply sequence:
    $self->{tag}++;

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
        $self->bail_out( "The connection to the IMAP server was lost while trying to get a response to command '$self->{last_command}'" );
    }
}


# ----------------------------------------------------------------------------
#
# select
#
#   Do a SELECT on the passed-in folder. Returns the result of get_response()
#
# Arguments:
#   $folder: The name of a mailbox on the server
#
# Return value:
#
#   INT 1 is ok, everything else is an error
# ----------------------------------------------------------------------------

sub select {
    my $self = shift;
    my $folder = shift;

    $self->say( "SELECT \"$folder\"" );
    my $result = $self->get_response();

    if  ( $result == 1 ) {
        $self->{folder} = $folder;
    }

    return $result
}


# ----------------------------------------------------------------------------
#
# get_mailbox_list
#
#   Request a list of mailboxes from the server behind the passed in socket object.
#   The list is sorted and returned
#
# Arguments: none
#
# Return value: list of mailboxes, possibly emtpy (or error)
# ----------------------------------------------------------------------------

sub get_mailbox_list {
    my $self = shift;

    $self->log_( 1, "Getting mailbox list" );

    $self->say( 'LIST "" "*"' );
    my $result = $self->get_response();

    if ( $result != 1 ) {
        $self->log_( 0, "LIST command failed (return value [$result])." );
        return;
    }

    my @lines = split /$eol/, $self->{last_response};
    my @mailboxes;

    foreach ( @lines ) {
        next unless /^\*/;
        s/^\* LIST \(.*\) .+? (.+)$/$1/;
        s/"(.*?)"/$1/;
        push @mailboxes, $1;
    }

    return sort @mailboxes;
}


# ----------------------------------------------------------------------------
#
# logout
#
#   log out of the the server we are currently connected to.
#
# Arguments: none
#
# Return values:
#   0 on failure
#   1 on success
# ----------------------------------------------------------------------------

sub logout {
    my $self = shift;

    $self->log_( 1, "Logging out" );

    $self->say( 'LOGOUT' );

    if ( $self->get_response() == 1 ) {
        $self->{socket}->shutdown( 2 );
        $self->{folder} = undef;
        $self->{socket} = undef;
        return 1;
    }
    else {
        return 0;
    }
}


# ----------------------------------------------------------------------------
#
# move_message
#
#   Will try to move a message on the IMAP server.
#
# arguments:
#
#   $msg:
#       The UID of the message
#   $destination:
#       The destination folder.
#
# ----------------------------------------------------------------------------

sub move_message {
    my $self = shift;
    my $msg  = shift;
    my $destination = shift;

    $self->log_( 1, "Moving message $msg to $destination" );

    # Copy message to destination
    $self->say( "UID COPY $msg \"$destination\"" );
    my $ok = $self->get_response();

    # If that went well, flag it as deleted
    if ( $ok == 1 ) {
        $self->say( "UID STORE $msg +FLAGS (\\Deleted)" );
        $ok = $self->get_response();
    }
    else {
        $self->log_( 0, "Could not copy message ($ok)!" );
    }

    return ( $ok ? 1 : 0 );
}


# ----------------------------------------------------------------------------
#
# get_new_message_list
#
#   Will search for messages on the IMAP server that are not flagged as deleted
#   that have a UID greater than or equal to the value stored as UIDNEXTfor
#   the currently SELECTed folder.
#
# arguments: none
#
# return value:
#
#   A sorted list (possibly empty) of the UIDs of matching messages.
#
# ----------------------------------------------------------------------------

sub get_new_message_list {
    my $self   = shift;

    my $folder = $self->{folder};
    my $uid    = $self->uid_next( $folder );

    $self->log_( 1, "Getting uids ge $uid in folder $folder" );

    $self->say( "UID SEARCH UID $uid:* UNDELETED" );
    my $result = $self->get_response();

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

    if ( $self->{last_response} =~ /\* SEARCH (.+)$eol/ ) {
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


# ----------------------------------------------------------------------------
#
# get_new_message_list_unselected
#
# If we are not in the selected state, you can use this routine to get a list
# of new messages on the server in a specific mailbox.
# The routine will do a STATUS (UIDNEXT) and compare our old
# UIDNEXT value to the new one.
# If it turns out that the new value is larger than the old, the mailbox
# is selected and the list of new UIDs gets retrieved. In that case,
# we will remain in a selected state.
#
# arguments: $folder - the folder that should be examined
# returns:   see get_new_message_list
# ----------------------------------------------------------------------------

sub get_new_message_list_unselected {
    my $self   = shift;
    my $folder = shift;

    my $last_known = $self->uid_next( $folder );

    my $info = $self->status( $folder );

    if ( ! defined $info ) {
        $self->bail_out( "Could not get a valid response to the STATUS command." );
    }
    else {
        my $new_next = $info->{UIDNEXT};
        my $new_vali = $info->{UIDVALIDITY};

        if ( $new_vali != $self->uid_validity( $folder ) ) {
            $self->log_( 0, "The folder $folder has a new UIDVALIDTIY value! Skipping new messages (if any)." );
            $self->uid_validity( $folder, $new_vali );
            return;
        }

        if ( $last_known < $new_next ) {
            $self->select( $folder );
            return $self->get_new_message_list();
        }
    }

    return;
}


# ----------------------------------------------------------------------------
#
# fetch_message_part
#
#   This function will fetch a specified part of a specified message from
#   the IMAP server and return the message as a list of lines.
#   It assumes that a folder is already SELECTed
#
# arguments:
#
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
# ----------------------------------------------------------------------------

sub fetch_message_part {
    my $self = shift;
    my $msg  = shift;
    my $part = shift;

    my $folder = $self->{folder};

    if ( $part ne '' ) {
        $self->log_( 1, "Fetching $part of message $msg" );
    }
    else {
        $self->log_( 1, "Fetching message $msg" );
    }

    if ( $part eq 'TEXT' || $part eq '' ) {
        my $limit = $self->{cutoff} || 0;
        $self->say( "UID FETCH $msg (FLAGS BODY.PEEK[$part]<0.$limit>)" );
    }
    else {
        $self->say( "UID FETCH $msg (FLAGS BODY.PEEK[$part])" );
    }

    my $result = $self->get_response();

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

        my $last_response = $self->{last_response};

        if ( $last_response =~ m/\^* \d+ FETCH/ ) {

            # The first line should contain the number of octets the server send us

            if ( $last_response =~ m/(?!$eol){(\d+)}$eol/ ) {
                my $num_octets = $1;

                # Grab the number of octets reported:

                my $pos = index $last_response, "{$num_octets}$eol";
                $pos += length "{$num_octets}$eol";

                my $message = substr $last_response, $pos, $num_octets;

                # Take the large chunk and chop it into single lines

                # We cannot use split here, because this would get rid of
                # trailing and leading newlines and thus omit complete lines.

                while ( $message =~ m/(.*?(?:$eol|\012|\015))/g ) {
                    push @lines, $1;
                }
            }
            # No number of octets: fall back, but issue a warning
            else {
                while ( $last_response =~ m/(.*?(?:$eol|\012|\015))/g ) {
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



#---------------------------------------------------------------------------------------------
#
#   uid_validity
#
#   Get the stored UIDVALIDITY value for the passed-in folder
#   or pass in new UIDVALIDITY value to store the value
#
# arguments: $folder [, $new_uidvalidity_value]
# returns: the stored UIDVALIDITY value or undef if no value was stored previously
#---------------------------------------------------------------------------------------------

sub uid_validity {
    my $self   = shift;
    my $folder = shift or confess "gimme a folder!";
    my $uidval = shift;

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
            return undef;
        }
    }
}


#---------------------------------------------------------------------------------------------
#
#   uid_next
#
#   Get the stored UIDNEXT value for the passed-in folder
#   or pass in a new UIDNEXT value to store the value
#
#  arguments: $folder [, $new_uidnext_value]
#  returns:   the stored UIDVALIDITY value or undef if no value was stored previously
#---------------------------------------------------------------------------------------------

sub uid_next {
    my $self    = shift;
    my $folder  = shift or confess "I need a folder";
    my $uidnext = shift;

    my $all = $self->config_( 'uidnexts' );
    my %hash = ();

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


# ----------------------------------------------------------------------------
#
# check_uidvalidity - Compare the stored UIDVALIDITY value to the passed-in
#                     value
#
# IN:  $folder, $uidvalidity_value
# OUT: true if the values are equal, undef otherwise
# ----------------------------------------------------------------------------
sub check_uidvalidity {
    my $self    = shift;
    my $folder  = shift;
    my $new_val = shift;

    confess "check_uidvalidity needs a new uidvalidity!" unless defined $new_val;
    confess "check_uidvalidity needs a folder name!" unless defined $folder;

    # Save old UIDVALIDITY value (if we have one)
    my $old_val = $self->uid_validity( $folder );

    # Check whether the old value is still valid
    if ( defined $old_val && $old_val ne '' && $new_val == $old_val ) {
        return 1;
    }
    else {
        return;
    }
}


sub connected {
    my $self = shift;
    return $self->{socket} ? 1 : undef;
}


sub bail_out {
    my $self = shift;
    my $msg  = shift;

    $self->{socket}->shutdown( 2 ) if defined $self->{socket};
    $self->{socket} = undef;
    my ( $package, $filename, $line, $subroutine ) = caller();
    $self->log_( 0, $msg );
    die "POPFILE-IMAP-EXCEPTION: $msg ($filename ($line))";
}


1;
