# ---------------------------------------------------------------------------------------------
#
# Tests for POP3.pm
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
# ---------------------------------------------------------------------------------------------

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::POP3;
use Classifier::Bayes;
use IO::Handle;
use IO::Socket;

use POSIX ":sys_wait_h";

my $eol = "\015\012";

sub forker
{
    pipe my $reader, my $writer;
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ( $pid == 0 ) {
        close $reader;

        use IO::Handle;
        $writer->autoflush(1);

        return (0, $writer);
    }

    close $writer;
    return ($pid, $reader);
}

sub pipeready
{
    my ( $pipe ) = @_;

    if ( !defined( $pipe ) ) {
        return 0;
    }

    if ( $^O eq 'MSWin32' ) {
        return ( ( -s $pipe ) > 0 );
    } else {
        my $rin = '';
        vec( $rin, fileno( $pipe ), 1 ) = 1;
        my $ready = select( $rin, undef, undef, 0.01 );
        return ( $ready > 0 );
    }
}

sub server
{
    my ( $client ) = @_;
    my @messages = sort glob 'TestMailParse*.msg';
    my $goslow = 0;

    print $client "+OK Ready$eol";

    while  ( <$client> ) {
        my $command;

        $command = $_;
        $command =~ s/(\015|\012)//g;

        if ( $command =~ /^USER (.*)/i ) {
	    if ( $1 =~ /(gooduser|goslow)/ ) {
                 print $client "+OK Welcome $1$eol";
                 $goslow = ( $1 =~ /goslow/ );
	    } else {
                 print $client "-ERR Unknown user $1$eol";
            }
            next;
        }

        if ( $command =~ /PASS (.*)/i ) {
	    if ( $1 =~ /secret/ ) {
                 print $client "+OK Now logged in$eol";
	    } else {
                 print $client "-ERR Bad Password$eol";
            }
            next;
	}

        if ( ( $command =~ /LIST ?(.*)?/i ) ||
             ( $command =~ /UIDL ?(.*)?/i ) ||
             ( $command =~ /STAT/ ) ) {
            my $count = 0;
            my $size  = 0;
            for my $i (0..$#messages) {
	        if ( $messages[$i] ne '' ) {
                    $count += 1;
                    $size  += ( -s $messages[$i] );
	        }
	    }

            print $client "+OK $count $size$eol";

            if ( $command =~ /STAT/ ) {
                next;
	    }

            for my $i (0..$#messages) {
	        if ( $messages[$i] ne '' ) {
                     my $resp = ( $command =~ /LIST/ )?( -s $messages[$i] ):$messages[$i];
                     print $client ($i+1) . " $resp$eol";
	        }
	    }

            print $client ".$eol";

            next;
        }

        if ( $command =~ /^QUIT/i ) {
            print $client "+OK Bye$eol";
            last;
        }

        if ( $command =~ /__QUIT__/i ) {
            print $client "+OK Bye$eol";
            return 0;
        }

        if ( $command =~ /RSET/i ) {
            @messages = sort glob 'TestMailParse*.msg';
            print $client "+OK Reset$eol";
            next;
        }

        if ( $command =~ /HELO/i ) {
            print $client "+OK Hello$eol";
            next;
        }

        if ( $command =~ /DELE (.*)/i ) {
            my $index = $1 - 1;
	    if ( defined( $messages[$index] ) && ( $messages[$index] ne '' ) ) {
                $messages[$index] = '';
                print $client "+OK Deleted $1$eol";
	    } else {
                print $client "-ERR No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /RETR (\d+)/i ) {
            my $index = $1 - 1;
	    if ( defined( $messages[$index] ) && ( $messages[$index] ne '' ) ) {
                 print $client "+OK " . ( -s $messages[$index] ) . "$eol";

                 open FILE, "<$messages[$index]";
                 binmode FILE;
                 while ( <FILE> ) {
                     print $client $_;
                     if ( $goslow ) {
                         select( undef, undef, undef, 3 );
		     }
		 }
                 close FILE;

                 print $client ".$eol";

	    } else {
                print $client "-ERR No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /TOP (.*) (.*)/i ) {
            my $index = $1 - 1;
            my $countdown = $2;
	    if ( $messages[$index] ne '' ) {
                 print $client "+OK " . ( -s $messages[$index] ) . "$eol";

                 open FILE, "<$messages[$index]";
                 binmode FILE;
                 while ( <FILE> ) {
                     print $client $_;

                     if ( /^[\r\n]+$/ ) {
                         last;
		     }
		 }
                 while ( ( my $line = <FILE> ) && ( $countdown > 0 ) ) {
                     print $client $line;
                     $countdown -= 1;
		 }
                 close FILE;

                 print $client ".$eol";

	    } else {
                print $client "-ERR No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /AUTH ([^ ]+)/ ) {
            print $client "$1$eol";
            my $echoit = <$client>;
            print $client "Got $echoit";
            $echoit = <$client>;
            print $client "Got $echoit";
            $echoit = <$client>;
            print $client "+OK Done$eol";
            next;
        }

        if ( $command =~ /CAPA|AUTH/i ) {
            print $client "+OK I can handle$eol" . "AUTH$eol" . "USER$eol" . "APOP$eol.$eol";
            next;
        }

        if ( $command =~ /APOP (.*) (.*)/i ) {
            print $client "+OK Welcome APOPer$eol";
            next;
        }

        if ( $command =~ /JOHN/ ) {
            print $client "+OK Hello John$eol";
            next;
        }

        print $client "-ERR unknown command or bad syntax$eol";
    }

    return 1;
}

test_assert( `rm -rf corpus` == 0 );
test_assert( `cp -R corpus.base corpus` == 0 );
test_assert( `rm -rf corpus/CVS` == 0 );
test_assert( `rm -rf messages/*` == 0 );

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );

$c->initialize();

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

$b->configuration( $c );
$b->mq( $mq );
$b->logger( $l );

$b->initialize();
$b->module_config_( 'html', 'port', 8080 );
$b->config_( 'hostname', '127.0.0.1' );
$b->start();

# some tests require this directory to be present
mkdir( 'messages' );

my $pid = fork();

if ( $pid == 0 ) {

    # CHILD THAT WILL RUN THE POP3 SERVER

    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                    LocalAddr => 'localhost',
                                    LocalPort => 8110,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 );

    my $selector = new IO::Select( $server );

    while ( 1 ) {
        if ( defined( $selector->can_read(0) ) ) {
            if ( my $client = $server->accept() ) {
                last if !server($client);
                close $client;
	    }
        }
    }

    exit(0);
} else {

    my $port = 9000 + int(rand(1000));

    # This pipe is used to send signals to the child running
    # the proxy to change its state, the following commands can
    # be sent
    #
    # __QUIT      Causes the child to terminate proxy service and
    #             exit
    #
    # __TOPTOO    Causes the child to enable the toptoo option in
    #             the proxy
    #
    # __SECUREBAD Causes the child to define an incorrect secure
    #             server
    #
    # __SECUREOK  Causes the child to define the correct secure
    #             server

    pipe my $dreader, my $dwriter;
    pipe my $ureader, my $uwriter;
    my $pid2 = fork();

    if ( $pid2 == 0 ) {

        # CHILD THAT WILL RUN THE POP3 PROXY

        close $dwriter;
        close $ureader;

        $uwriter->autoflush(1);

        my $p = new Proxy::POP3;

        $p->configuration( $c );
        $p->mq( $mq );
        $p->logger( $l );
        $p->classifier( $b );

        $p->forker( \&forker );
        $p->pipeready( \&pipeready );

        $p->{version_} = 'test suite';
        $p->initialize();
        $p->config_( 'port', $port );
        $p->global_config_( 'timeout', 1 );
        $p->start();

        while ( 1 ) {
            last if !$p->service();

            if ( pipeready( $dreader ) ) {
                my $command = <$dreader>;

                if ( $command =~ /__QUIT/ ) {
		    print $uwriter "OK\n";
                    last;
		}

                if ( $command =~ /__TOPTOO/ ) {
                    $p->config_( 'toptoo', 1 );
		    print $uwriter "OK\n";
                    next;
		}

                if ( $command =~ /__SECUREBAD/ ) {
                    $p->config_( 'secure_server', '127.0.0.1' );
                    $p->config_( 'secure_port', 8111 );
		    print $uwriter "OK\n";
                    next;
		}

                if ( $command =~ /__SECUREOK/ ) {
                    $p->config_( 'secure_server', '127.0.0.1' );
                    $p->config_( 'secure_port', 8110 );
		    print $uwriter "OK\n";
                    next;
		}
	    }
	}

        close $dreader;
        close $uwriter;

        my @kids = keys %{$p->{children__}};
        while ( $#kids >= 0 ) {
            $p->reaper();
            select( undef, undef, undef, 0.25 );
            @kids = keys %{$p->{children__}};
        }

        $p->stop();

        exit(0);
    } else {

        # PARENT THAT WILL SEND COMMAND TO THE PROXY

        close $dreader;
        close $uwriter;
        $dwriter->autoflush(1);

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        # Make sure that POPFile sends an appropriate banner

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "USER 127.0.0.1:8111:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR can't connect to 127.0.0.1:8111$eol" );

        # Check that we can connect to the remote POP3 server (should still be waiting
        # for us)

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        # TODO check for LOGIN message

        # Now send a bad password

        print $client "PASS password$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR Bad Password$eol" );

        # And then a good one

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        # Test that the catch all code works for connected servers

        print $client "JOHN$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Hello John$eol" );

        # Check that we handle HELO locally

        print $client "HELO$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK HELO POPFile Server Ready$eol" );

        # Get the LIST response and verify

        print $client "LIST$eol";

        my $count = 0;
        my $size  = 0;
        my @messages = sort glob 'TestMailParse*.msg';
        for my $i (0..$#messages) {
            if ( $messages[$i] ne '' ) {
                $count += 1;
                $size  += ( -s $messages[$i] );
	    }
	}

        $result = <$client>;
        test_assert_equal( $result, "+OK $count $size$eol" );

        for my $i (0..$#messages) {
	     if ( $messages[$i] ne '' ) {
                 my $resp = ( -s $messages[$i] );
                 $result = <$client>;
                 test_assert_equal( $result, ($i+1) . " $resp$eol" );
	    }
	}

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Make such that UIDL works

        print $client "UIDL$eol";

        $result = <$client>;
        test_assert_equal( $result, "+OK $count $size$eol" );

        for my $i (0..$#messages) {
	     if ( $messages[$i] ne '' ) {
                 my $resp = $messages[$i];
                 $result = <$client>;
                 test_assert_equal( $result, ($i+1) . " $resp$eol" );
	    }
	}

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Try getting a message (first a bad message number)

        my $notexist = $count + 1;
        print $client "RETR $notexist$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR No such message $notexist$eol" );

        # Now get a message that actually exists

        unlink( 'messages/popfile1=1.msg' );
        unlink( 'messages/popfile1=1.cls' );

        print $client "RETR 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[0] ) . "$eol" );
        my $cam = $messages[0];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile1=1/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, "$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # This delay is here because Windows was having a little trouble
        # with the files created by the RETR not existing and I have a little
        # rest here while Windows wakes from its afternoon nap and writes
        # the files to disk

        select( undef, undef, undef, 0.1 );

        # TODO check for NEWFL and CLASS messages

        test_assert( -e 'messages/popfile1=1.msg' );
        test_assert( -e 'messages/popfile1=1.cls' );

        test_assert( open FILE, "<$messages[0]" );
        binmode FILE;
        test_assert( open HIST, "<messages/popfile1=1.msg" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
	}
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile1=1.msg' );
        test_assert( !$reclassified );
        test_assert_equal( $bucket, 'spam' );
        test_assert( !defined( $usedtobe ) );
        test_assert_equal( $magnet, '' );

        # Try an unsuccessful delete

        print $client "DELE $notexist$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR No such message $notexist$eol" );

        # Try a successful delete

        print $client "DELE 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Deleted 1$eol" );

        # Check that CAPA command works once we are connected

        print $client "CAPA$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK I can handle$eol" );
        $result = <$client>;
        test_assert_equal( $result, "AUTH$eol" );
        $result = <$client>;
        test_assert_equal( $result, "USER$eol" );
        $result = <$client>;
        test_assert_equal( $result, "APOP$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Check what happens when TOP fails

        print $client "TOP $notexist 22$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR No such message $notexist$eol" );

        # Check the basic TOP command

        unlink( 'messages/popfile1=5.msg' );
        unlink( 'messages/popfile1=5.cls' );

        my $countdown = 2;
        print $client "TOP 5 $countdown$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[4] ) . "$eol" );

        test_assert( open FILE, "<$messages[4]" );
        binmode FILE;
        my $headers   = 1;
        while ( ( my $line = <FILE> ) && ( $countdown > 0 ) ) {
            $result = <$client>;
            test_assert_equal( $result, $line );
            if ( $headers == 0 ) {
                $countdown -= 1;
	    }
            if ( $line =~ /^[\r\n]+$/ ) {
                $headers = 0;
	    }
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # This delay is here because Windows was having a little trouble
        # with the files created by the RETR not existing and I have a little
        # rest here while Windows wakes from its afternoon nap and writes
        # the files to disk

        select( undef, undef, undef, 0.1 );

        test_assert( !(-e 'messages/popfile1=5.msg') );
        test_assert( !(-e 'messages/popfile1=5.cls') );

        # Check that TOP x 99999999 is the same as RETR x for fetchmail
        # compatibility

        test_assert( !(-e 'messages/popfile1=7.msg') );
        test_assert( !(-e 'messages/popfile1=7.cls') );

        print $client "TOP 7 99999999$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[6] ) . "$eol" );
        my $cam = $messages[6];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile1=7/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, "$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # This delay is here because Windows was having a little trouble
        # with the files created by the RETR not existing and I have a little
        # rest here while Windows wakes from its afternoon nap and writes
        # the files to disk

        select( undef, undef, undef, 0.1 );

        # TODO check for NEWFL and CLASS messages

        test_assert( -e 'messages/popfile1=7.msg' );
        test_assert( -e 'messages/popfile1=7.cls' );

        test_assert( open FILE, "<$messages[6]" );
        binmode FILE;
        test_assert( open HIST, "<messages/popfile1=7.msg" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
	}
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile1=7.msg' );
        test_assert( !$reclassified );
        test_assert_equal( $bucket, 'spam' );
        test_assert( !defined( $usedtobe ) );
        test_assert_equal( $magnet, '' );

        # Check that we echo the remote servers QUIT response

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Test basic TOP capability with toptoo gets classification

        print $dwriter "__TOPTOO\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        $countdown = 2;
        print $client "TOP 8 $countdown$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[7] ) . "$eol" );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( ( my $line = <FILE> ) && ( $countdown > 0 ) ) {
            $result = <$client>;
            $result =~ s/popfile2=8/popfile0=0/;
            test_assert_equal( $result, $line );
            if ( $headers == 0 ) {
                $countdown -= 1;
	    }
            if ( $line =~ /^[\r\n]+$/ ) {
                $headers = 0;
	    }
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, "$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        test_assert( -e 'messages/popfile2=8.msg' );
        test_assert( -e 'messages/popfile2=8.cls' );

        test_assert( open FILE, "<$messages[7]" );
        binmode FILE;
        test_assert( open HIST, "<messages/popfile2=8.msg" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
	}
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile2=8.msg' );
        test_assert( !$reclassified );
        test_assert_equal( $bucket, 'spam' );
        test_assert( !defined( $usedtobe ) );
        test_assert_equal( $magnet, '' );

        # Test RETR after TOP comes from cache

        print $client "RETR 8$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s 'messages/popfile2=8.msg' ) . " bytes from POPFile cache$eol" );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/popfile2=8/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Test RETR after RETR returns cached copy

        print $client "RETR 9$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[8] ) . "$eol" );
        my $cam = $messages[8];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile2=9/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, "$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        select( undef, undef, undef, 0.1 );

        test_assert( -e 'messages/popfile2=9.msg' );
        test_assert( -e 'messages/popfile2=9.cls' );

        test_assert( open FILE, "<$messages[8]" );
        binmode FILE;
        test_assert( open HIST, "<messages/popfile2=9.msg" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
	}
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile2=9.msg' );
        test_assert( !$reclassified );
        test_assert_equal( $bucket, 'spam' );
        test_assert( !defined( $usedtobe ) );
        test_assert_equal( $magnet, '' );

        print $client "RETR 9$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s 'messages/popfile2=9.msg' ) . " bytes from POPFile cache$eol" );

        $cam = $messages[8];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/popfile2=9/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # TODO Test RETR after TOP/RETR with correct CLS file

        unlink( 'messages/popfile2=9.cls' );

        print $client "RETR 9$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s 'messages/popfile2=9.msg' ) . " bytes from POPFile cache$eol" );

        $cam = $messages[8];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/popfile2=9/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Check insertion of the X-POPFile-Timeout headers

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:goslow$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome goslow$eol" );

        print $client "RETR 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[0] ) . "$eol" );
        my $cam = $messages[0];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $line = <$client>;
        test_assert_equal( $line, "X-POPFile-TimeoutPrevention: 0$eol" );
        $line = <$client>;
        test_assert_equal( $line, "X-POPFile-TimeoutPrevention: 1$eol" );
        $line = <$client>;
        test_assert_equal( $line, "X-POPFile-TimeoutPrevention: 2$eol" );
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile3=1/popfile0=0/;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, "$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Test QUIT straight after connect

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test odd command straight after connect gives error

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "FOOF$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR unknown command or bad syntax$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test the APOP command

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "APOP 127.0.0.1:8111:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR can't connect to 127.0.0.1:8111$eol" );

        # Check that we can connect to the remote POP3 server (should still be waiting
        # for us)

        print $client "APOP 127.0.0.1:8110:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome APOPer$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Test SPA/AUTH commands with no secure server specified

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "CAPA$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR No secure server specified$eol" );

        print $client "AUTH$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR No secure server specified$eol" );

        print $client "AUTH username$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR No secure server specified$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test SPA/AUTH with a bad server

        print $dwriter "__SECUREBAD\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "CAPA$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR can't connect to 127.0.0.1:8111$eol" );

        print $client "AUTH$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR can't connect to 127.0.0.1:8111$eol" );

        print $client "AUTH username$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR can't connect to 127.0.0.1:8111$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test SPA/AUTH tests with good server

        print $dwriter "__SECUREOK\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "AUTH$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK I can handle$eol" );
        $result = <$client>;
        test_assert_equal( $result, "AUTH$eol" );
        $result = <$client>;
        test_assert_equal( $result, "USER$eol" );
        $result = <$client>;
        test_assert_equal( $result, "APOP$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "AUTH gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "gooduser$eol" );
        print $client "repeatthis$eol";
        $result = <$client>;
        test_assert_equal( $result, "Got repeatthis$eol" );
        print $client "repeatthat$eol";
        $result = <$client>;
        test_assert_equal( $result, "Got repeatthat$eol" );
        print $client "done$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Done$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Send the remote server a special message that makes it die

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        print $client "__QUIT__$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Tell the proxy to die

        print $dwriter "__QUIT\n";
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );
        close $dwriter;
        close $ureader;

        while ( waitpid( $pid, &WNOHANG ) != $pid ) {
        }
        while ( waitpid( $pid2, &WNOHANG ) != $pid2 ) {
        }
    }
}
