# ---------------------------------------------------------------------------------------------
#
# Tests for IMAP.pm
#
# Copyright (c) 2003 John Graham-Cumming
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
#   Originally created by Manni Heumann (mannih2001@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------

# This test module is supposed to test the POPFile IMAP module.
# To this end, it will fork off a server part. This "server" is
# (of course!) not a RFC-compliant IMAP server. It only implements
# the IMAP commands used in IMAP.pm and only in the exact form
# in which they are used in IMAP.pm. E.g., a regular server will
# accept the command "1 SELECT INBOX". But since IMAP.pm will prefix
# its tags with a capital A and because it will always quote the
# mailbox names, the test server will only accept "A1 SELECT "INBOX""
#
# Please note that the server child will fork off further childs that
# are needed to establish multiple connections to the IMAP module.



use IO::Socket;
use IO::Select;
use strict;
use warnings;

$SIG{CHLD} = 'IGNORE';

my $cr = "\015";
my $lf = "\012";
my $eol = "$cr$lf";



# A hash mapping all the mailboxes to the number of messages they contain.
my %mailboxes;
@mailboxes{ qw/INBOX input spam personal other misc/ } = ( 0, 0, 0, 0, 0, 0 );

# State information:
my $cur_mailbox     = '';
my $user            = '';
my $state           = 'Not Authenticated';


# Variables that tells us what to do (set via the user name used for the login)

my $drop_connection_at  = -1;
my $uidvalidity         =  1;
my $time_out_at         = -1;



# The socket used for listening for incoming connections.
my $main_sock = new IO::Socket::INET ( LocalPort => 1143,
                                       Listen    => 5,
                                       Proto     => 'tcp',
                                       Reuse     => 1,
                                      );

die "Socket could not be created. Reason: $!\n" unless ($main_sock);


# The endless loop that accepts incoming connections.

while ( 1 ) {

    my $new_sock = $main_sock->accept();

    # We set up a pipe that lets the child tell the parent that it
    # no longer needs to wait for new connections.

    pipe my $reader, my $writer;

    my $pid = fork();
    die "Cannot fork: $!" unless defined( $pid );

    # child that will handle one connection.
    if ( $pid == 0 ) {
        close $reader;
        $writer->autoflush( 1 );

        print $new_sock "* OK POPFile IMAP test server ready for testing$eol";

        my $command_no = 0;

        while ( my $buf = <$new_sock> ) {

            # Look out for the shutdown signal and tell the parent
            # that it's time to go home when we get it. Tell the
            # parent anything else each time we get a login

            if ( $buf =~ /^A\d+ LOGIN / ) {
                if ( $buf =~ /^A\d+ LOGIN "shutdown"/ ) {
                    print $writer "shutdown\n";
                    $new_sock->shutdown( 2 );
                    last;
                }
                else {
                    print $writer "keep going\n";
                }
            }

            if ( $time_out_at == $command_no ) {
                sleep 300;
            }

            # We may need to drop the connection
            if ( $command_no == $drop_connection_at ) {
                $new_sock->shutdown( 2 );
            }

            # else we handle the command
            else {
                handle_command( $new_sock, $buf );
            }
            
            $command_no++;
        }

        exit 0;
    }
    # parent
    else {
        close $writer;
        # We do a blocking read here. Therefore each child must tell us
        # something.

        my $line = <$reader>;
        if ( $line =~ /shutdown/ ) {
            close $reader;
            last;
        }
    }
}

close $main_sock;


# handle_command
# Function to decipher an IMAP command and respond to it in whatever way we need to.

sub handle_command
{
    my ( $client, $cmd ) = @_;

    if ( $cmd =~ /^(A\d+) (.+)$eol/ ) {

        my $tag = $1;
        my $command = $2;

    # LOGIN

        # This section is of special importance because the user name given
        # at login determines which stones we throw at IMAP.pm

        if ( $command =~ /^LOGIN "(.+?)" "(.*)"/ && $state eq 'Not Authenticated' ) {
            $user = $1;

            if ( $user =~ /fail/ ) {
                print $client "$tag NO Authentication failed$eol";
            }
            else {
                print $client "$tag OK Welcome $user$eol";
                $state = 'Authenticated';

                # The user name tells us what to do and what to test

                # New messages in one of the incoming mailboxes
                if ( $user =~ /^new(\w+)(\d+)$/ ) {
                    my $mailbox = $1;
                    my $number = $2;
                }
                elsif ( $user =~ /^reclass$/ ) {

                }
                elsif ( $user =~ /^dropConnection(\d+)$/ ) {
                    $drop_connection_at = $1;
                }
                elsif ( $user =~ /^changedValidity/ ) {
                    $uidvalidity = 2;
                }
                elsif ( $user =~ /^duplicateMessage/ ) {

                }
                elsif ( $user =~ /^timeOut(\d+)$/ ) {
                    $time_out_at = $1;
                }
            }

            return;
        }


    # LIST

        if ( $command =~ /^LIST "" "\*"/ && $state ne 'Not Authenticated' ) {
            foreach ( keys %mailboxes ) {

                if ( /INBOX/ ) {
                    print $client "* LIST (\\NoInferiors) \"/\" $_$eol";
                }
                else {
                    print $client "* LIST (\\HasNoChildren) \"/\" $_$eol";
                }
            }
            print $client "$tag OK complete.$eol";

            return;
        }

    # LOGOUT

        if ( $command =~ /^LOGOUT/ ) {
            print $client "* BYE bye$eol";
            print $client "$tag OK LOGOUT complete.$eol";

            $client->shutdown( 2 );

            return;
        }


    # SELECT

        if ( $command =~ /^SELECT "(.+)"$/ && ( $state eq 'Authenticated' || $state eq 'Selected' ) ) {
            my $what = $1;

            if ( exists $mailboxes{ $what } ) {
                $state = 'Selected';
                $cur_mailbox = $what;
                select_mailbox( $client, $what );

                print $client "$tag OK [READ-WRITE] SELECT complete.$eol";
            }
            else {
                print $client "$tag NO No such folder $what$eol";
            }

            return;
        }

    # NOOP
        # (we check for Selected state here because we do not want the
        # IMAP module to do a NOOP unless we are Selected

        if ( $command =~ /^NOOP/ && $state eq 'Selected' ) {

            # todo: Figure out when a new message should be signaled.

            print $client "$tag OK NOOP complete.$eol";

            return;
        }


    # EXPUNGE
        if ( $command =~ /^EXPUNGE/ && $state eq 'Selected' ) {

            print $client "$tag OK EXPUNGE complete.$eol";

            return;
        }

    # STATUS
        if ( $command =~ /^STATUS "(.+?)" \(UIDNEXT\)$/ && $state eq "Selected" ) {

            my $mailbox = $1;

            if ( exists $mailboxes{ $mailbox } ) {
                my $number_of_messages = $mailboxes{ $mailbox };
                print $client "* STATUS $mailbox (UIDNEXT ", $number_of_messages + 1 , ")$eol";
                print $client "$tag OK STATUS complete.$eol";
            }
            else {
                print $client "$tag NO No such folder $mailbox$eol";
            }

            return;
        }

    # UID FETCH
        if ( $command =~ /^UID FETCH (\d+) \(FLAGS BODY.PEEK\[(.*)\]\)/ && $state eq 'Selected' ) {

            my $uid = $1;
            my $part = $2;

            if ( $part eq 'HEADER.FIELDS (Message-id Date Subject Received)' ) {


            }
            elsif ( $part eq '' ) {

            }
            elsif ( $part eq 'HEADER' ) {

            }
            elsif ( $part eq 'TEXT' ) {

            }
            else {

            }

            print $client "$tag OK FETCH complete.$eol";

            return;
        }

    # UID COPY
        if ( $command =~ /^UID COPY (\d+) "(.+)"/ && $state eq 'Selected' ) {

            my $destination = $2;

            if ( exists $mailboxes{ $destination } ) {
                # todo: actually do something here.
                print $client "$tag OK COPY complete.$eol";
            }
            else {
                print $client "$tag NO No such folder $destination.$eol";
            }

            return;
        }

    # UID STORE
        if ( $command =~ /^UID STORE (\d+) \+FLAGS \(\\Deleted\)/ && $state eq 'Selected' ) {

            my $uid = $1;

            # todo: Check for correct UID
            print $client "* $uid FETCH$eol";
            print $client "$tag OK UID STORE complete.$eol";

            return;
        }

    # UID SEARCH
        if ( $command =~ /^UID SEARCH UID (\d+):\* UNDELETED/ ) {

            my $uid = $1;

            # todo: return some content

            print $client "* SEARCH$eol";
            print $client "$tag OK SEARCH complete.$eol";

            return;
        }



        # If we get here, we don't know the command and say so

        print $client "$tag BAD command$eol";
    }
    else {
        if ( $cmd =~ /^(.+?) / ) {
            print $client "$1 BAD command$eol";
        }
        else {
            print $client "$cmd BAD command$eol";
        }
    }
}


sub select_mailbox
{
    my ( $client, $mailbox ) = @_;

    # todo: make this more flexible. Have a defined number of messages for each
    # pre-defined folder.

    local $\ = "$eol";

    print $client "* ", $mailboxes{ $mailbox }, " EXISTS";
    print $client "* 0 RECENT";
    print $client '* FLAGS (\Deleted \Draft \Seen \Answered)';
    print $client "* OK [UIDVALIDITY $uidvalidity] UID Validity";
    print $client "* OK [UIDNEXT " , $mailboxes{ $mailbox } , "] Predicted next UID";
    print $client '* OK [PERMANENTFLAGS (\Deleted \Draft \Seen \Answered)] Settable message flags';
}

