# ---------------------------------------------------------------------------------------------
#
# Tests for IMAP.pm
#
# Copyright (c) 2003-2007 John Graham-Cumming
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
use File::Copy;
use Date::Format;
use strict;
use warnings;

$SIG{CHLD} = 'IGNORE';

my $cr = "\015";
my $lf = "\012";
my $eol = "$cr$lf";
my $debug = 1;
my $spool = "imap.spool";
my $uid_file = 'imap.uids';

# if nothing happens with in $idle_timeout seconds
# we call exit.
my $idle_timeout = 60;

my @mailboxes = qw/INBOX spam personal other unclassified/;


# This is where we store all the folders' UIDNEXT values
my %uidnext;
foreach my $box ( @mailboxes ) {
    uid_next( $box, 1 );
}

# State information:
my $cur_mailbox     = '';
my $user            = '';
my $state           = 'Not Authenticated';


# Variables that tells us what to do (set via the user name used for the login)

my $drop_connection_at  = -1;
my $uidvalidity         =  1;
my $time_out_at         = -1;


# Create the spool directory
mkdir $spool;
chdir $spool;

foreach ( @mailboxes ) {
    mkdir $_;
}
chdir "..";



# The socket used for listening for incoming connections.
my $main_sock = new IO::Socket::INET ( LocalPort => 1143,
                                       Listen    => 5,
                                       Proto     => 'tcp',
                                       Reuse     => 1,
                                      );

die "Socket could not be created. Reason: $!\n" unless ($main_sock);

local $SIG{ALRM}
    = sub {
            $main_sock->shutdown(2);
            debug( "Exiting due to idle time-out." );
            die "IMAP-Test-Server timed out. Did your tests just crash?";
          };


# The endless loop that accepts incoming connections.
# It's not really endless. There are two ways to exit
# that loop:
# 1. The regular way: A client tries to login with the user
#    name 'shutdown'. In that case, we shut down the socket
#    and exit.
# 2. If the tests didn't run the way they should and the
#    testing parent dies or does something otherwise silly,
#    we keep an eye on the clock and exit if nothing happened
#    in the last $idle_timeout seconds.

while ( 1 ) {
    alarm $idle_timeout if $debug;

    debug ( "Waiting for a new client to connect." );
    my $new_sock = $main_sock->accept();
    # We set up a pipe that lets the child tell the parent that it
    # no longer needs to wait for new connections.

    pipe my $reader, my $writer;

    debug( "Trying to fork..." );
    my $pid = fork();
    die "Cannot fork: $!" unless defined( $pid );

    # child that will handle one connection.
    if ( $pid == 0 ) {
        close $reader;
        close $main_sock;
        $writer->autoflush( 1 );

        print $new_sock "* OK POPFile IMAP test server ready for testing$eol";
        debug( "Got new socket connection" );

        my $command_no = 0;

        while ( my $buf = <$new_sock> ) {

            debug( "client said: $buf" );
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
                alarm 0 if $debug;
                debug( "Going to sleep for $idle_timeout seconds" );
                sleep $idle_timeout;
                #alarm $idle_timeout if $debug;
                # The client is supposed to drop its connection
                # at that point. So we are going to do the same thing
                # here:
                debug( "Child is exiting after time out" );
                $new_sock->shutdown( 2 );
                exit 0;
            }

            # We may need to drop the connection
            if ( $command_no == $drop_connection_at ) {
                $new_sock->shutdown( 2 );
                alarm 0 if $debug;
            }
            # else we handle the command
            else {
                handle_command( $new_sock, $buf );
            }
            $command_no++;
        }
        debug( "Child is exiting: EOF from socket" );
        exit 0;
    }
    # parent
    else {
        close $writer;
        # We do a blocking read here. Therefore each child must tell us
        # something.

        my $line = <$reader>;
        debug ( "child said $line" );
        if ( $line =~ /shutdown/ ) {
            close $reader;
            last;
        }
    }
}

close $main_sock;
unlink $uid_file;
print "\nThe IMAP_test_server is exiting.\n";

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
                if ( $user =~ /^new_/ ) {
                    $user =~ /_([a-zA-Z]+)_/;
                    my $mailbox = $1;
                    while ( $user =~ /_(\d+)/g ) {
                        file_message( $mailbox, $1 );
                    }
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
            foreach ( @mailboxes ) {

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
            my $mailbox = $1;

            uid_next ( $mailbox );
            if ( exists $uidnext{ $mailbox } ) {
                $state = 'Selected';
                $cur_mailbox = $mailbox;
                select_mailbox( $client, $mailbox );

                print $client "$tag OK [READ-WRITE] SELECT complete.$eol";
            }
            else {
                print $client "$tag NO No such folder $mailbox$eol";
            }

            return;
        }

    # NOOP
        if ( $command =~ /^NOOP/ ) {
            print $client "$tag OK NOOP complete.$eol";
            return;
        }

    # EXPUNGE
        if ( $command =~ /^EXPUNGE/ && $state eq 'Selected' ) {
            print $client "$tag OK EXPUNGE complete.$eol";
            return;
        }

    # STATUS (we only need to handle STATUS commands asking for the UIDNEXT value because
            # IMAP.pm won't use any other STATUS commands)
        if ( $command =~ /^STATUS "(.+?)" \(UIDNEXT UIDVALIDITY\)$/  ) {

            my $mailbox = $1;
            uid_next( $mailbox );

            if ( exists $uidnext{ $mailbox } ) {
                my $number_of_messages = $uidnext{ $mailbox };
                print $client "* STATUS $mailbox (UIDNEXT $uidnext{ $mailbox } UIDVALIDITY $uidvalidity)$eol";
                print $client "$tag OK STATUS complete.$eol";
            }
            else {
                print $client "$tag NO No such folder $mailbox$eol";
            }

            return;
        }

    # UID FETCH
        if ( $command =~ /^UID FETCH (\d+) \(FLAGS BODY.PEEK\[(.*)\]((<\d+\.\d+>)|)\)/ && $state eq 'Selected' ) {

            my $uid = $1;
            my $part = $2;

            my $response;

            if ( $part eq 'HEADER.FIELDS (Message-id Date Subject Received)' ) {
                $response = get_header_fields( $cur_mailbox, $uid );
            }
            elsif ( $part eq '' ) {
                $response = get_message( $cur_mailbox, $uid );
            }
            elsif ( $part eq 'HEADER' ) {
                $response = get_message_header( $cur_mailbox, $uid );
            }
            elsif ( $part eq 'TEXT' ) {
                $response = get_message_text( $cur_mailbox, $uid );
            }

            if ( $response ) {
                print $client "* $uid FETCH {", length( $response ), "}$eol";
                print $client $response, ")$eol";
                print $client "$tag OK completed$eol";
            } else {
                print $client "$tag NO this command did not succeed: $command$eol";
            }

            return;
        }

    # UID COPY
        if ( $command =~ /^UID COPY (\d+) "(.+)"/ && $state eq 'Selected' ) {

            my $uid = $1;
            my $destination = $2;

            my $response = copy_message( $uid, $cur_mailbox, $destination );
            print $client "$tag $response$eol";

            return;
        }

    # UID STORE  ( eq delete )
        if ( $command =~ /^UID STORE (\d+) \+FLAGS \(\\Deleted\)/ && $state eq 'Selected' ) {

            my $uid = $1;

            if ( delete_message( $cur_mailbox, $uid ) ) {
                print $client "* $uid FETCH$eol";
                print $client "$tag OK UID STORE complete.$eol";
            } else {
                print $client "$tag NO no such message$eol";
            }

            return;
        }

    # UID SEARCH
        if ( $command =~ /^UID SEARCH UID (\d+):\* UNDELETED/ ) {

            my $uid = $1;

            my $result = search_messages_ge( $cur_mailbox, $uid );

            print $client "* SEARCH$result$eol";
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


sub select_mailbox {
    my ( $client, $mailbox ) = @_;

    local $\ = "$eol";

    my @msgs = glob "$spool/$mailbox/*";
    uid_next( $mailbox );

    print $client "* ", scalar @msgs, " EXISTS";
    print $client "* 0 RECENT";
    print $client '* FLAGS (\Deleted \Draft \Seen \Answered)';
    print $client "* OK [UIDVALIDITY $uidvalidity] UID Validity";
    print $client "* OK [UIDNEXT " , $uidnext{ $mailbox }, "] Predicted next UID";
    print $client '* OK [PERMANENTFLAGS (\Deleted \Draft \Seen \Answered)] Settable message flags';
}


sub debug {
    return unless $debug;
    my @messages = @_;
    open my $LOG, '>>', 'IMAPdebug.log';
    foreach ( @messages ) {
        s/[\r\n]//g;
        my $time = time2str( "%H:%M:%S", time );
        print $LOG "$time: $_\n";
    }
    close $LOG;
}

sub file_message {
    my ( $folder, $msg ) = @_;

    uid_next( $folder );
    my $new_uid = $uidnext{ $folder };
    uid_next( $folder, $uidnext{ $folder }+1 );
    debug( "Trying to copy TestMailParse$msg.msg to $spool/$folder/$new_uid" );
    copy "TestMailParse$msg.msg", "$spool/$folder/$new_uid";
}


sub copy_message {
    my ( $uid, $from, $to ) = @_;

    if ( -e "$spool/$from/$uid" ) {
        uid_next( $to );
        if ( exists $uidnext{ $to } ) {
            my $new_uid = $uidnext{ $to };
            uid_next( $to, $uidnext{ $to }+1 );
            copy "$spool/$from/$uid", "$spool/$to/$new_uid";
            return 'OK Completed';
        } else {
            return 'NO [TRYCREATE] Mailbox does not exist';
        }
    }
    else {
        return "NO Message '$spool/$from/$uid' does not exist";
    }
}


sub delete_message {
    my ( $folder, $uid ) = @_;

    if ( -e "$spool/$folder/$uid" ) {
        unlink "$spool/$folder/$uid";
        return 1;
    }
    else {
        return;
    }
}


sub search_messages_ge {
    my ( $folder, $uid ) = @_;

    chdir "$spool/$folder/";

    my @list;
    foreach ( glob "*" ) {
        push @list, $_ if ( /\d/ );
    }
    my $flat = '';
    foreach ( sort { $a <=> $b } @list ) {
        $flat .= " $_";
    }

    chdir "../..";

    return $flat;
}

sub get_header_fields {
    my ( $folder, $uid ) = @_;

    if ( -e "$spool/$folder/$uid" ) {
        open MSG, "$spool/$folder/$uid";
        my %header;
        my $last;
        while ( <MSG> ) {
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
        close MSG;
        my @headers = qw/message-id date subject received/;

        my $response = '';

        foreach ( @headers ) {
            if ( exists $header{ $_ } ) {
                $response .= "\u$_: ${$header{ $_ }}[0]$eol";
            }
        }

        unless ( $response ) {
            warn "Server couldn't find any header fields in message '$spool/$folder/$uid'\n";
        }

        return $response;
    }
    else {
        warn "Server could not find file '$spool/$folder/$uid'\n";
        return;
    }
}


sub get_message {
    my ( $folder, $uid ) = @_;

    if ( -e "$spool/$folder/$uid" ) {
        open MSG, "$spool/$folder/$uid";
        my $msg = '';
        while ( <MSG> ) {
            s/[\r\n]//g;
            $msg .= "$_$eol";
        }
        close MSG;

        return $msg;
    }
    else {
        return;
    }
}


sub get_message_header {
    my ( $folder, $uid ) = @_;

    if ( -e "$spool/$folder/$uid" ) {
        my $response = '';
        open MSG, "$spool/$folder/$uid";
        while ( <MSG> ) {
            last if /^$/;
            s/[\r\n]//g;
            $response .= "$_$eol";
        }
        close MSG;

        return "$response$eol";
    }
    else {
        return;
    }
}

sub get_message_text {
    my ( $folder, $uid ) = @_;

    if ( -e "$spool/$folder/$uid" ) {
        my $response = '';
        open MSG, "$spool/$folder/$uid";
        my $past_headers = 0;
        while ( <MSG> ) {
            s/[\r\n]//g;
            $response .= "$_$eol" if $past_headers;
            $past_headers = 1 if /^$/;
        }
        close MSG;
        return $response;
    }
    else {
        return;
    }
}


sub uid_next {
    my $folder  = shift;
    my $uidnext = shift;

    if ( open my $UIDS, '<', $uid_file ) {
        while ( <$UIDS> ) {
            /(.+):(.+)[\r\n]/;
            $uidnext{ $1 } = $2;
        }
    }

    if ( defined $uidnext ) {
        $uidnext{ $folder } = $uidnext;
        if ( open my $UIDS, '>', 'imap.uids' ) {
            foreach ( keys %uidnext ) {
                print $UIDS "$_:$uidnext{ $_ }\n";
            }
        }
        else {
            die "IMAP-test-server has a problem: cannot open file 'imap.uids'";
        }
    }

    return $uidnext{ $folder };
}



