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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::POP3;
use Classifier::Bayes;
use Classifier::WordMangle;
use IO::Handle;
use IO::Socket;
use Digest::MD5;

unlink 'popfile.db';

use POSIX ":sys_wait_h";

my $cr = "\015";
my $lf = "\012";

my $eol = "$cr$lf";

sub pipeready
{
    my ( $pipe ) = @_;

    if ( !defined( $pipe ) ) {
        return 0;
    }

    if ( $^O eq 'MSWin32' ) {
        return ( defined( fileno( $pipe ) ) && ( ( -s $pipe ) > 0 ) );
    } else {
        my $rin = '';
        vec( $rin, fileno( $pipe ), 1 ) = 1;
        my $ready = select( $rin, undef, undef, 0.01 );
        return ( $ready > 0 );
    }
}

sub server
{
    my ( $client, $apop ) = @_;
    my @messages = sort glob 'TestMailParse*.msg';
    my $goslow = 0;
    my $hang   = 0;
    my $slowlf = 0;

    my $time = time;

    my $APOPBanner = "<$time.$$\@POPFile>";
    my $APOPSecret = "secret";

    print $client "+OK Ready" . ($apop?" $APOPBanner":'') . "$eol";

    while  ( <$client> ) {
        my $command;

        $command = $_;
        $command =~ s/(\015|\012)//g;

        if ( $command =~ /^USER (.*)/i ) {
	    if ( $1 =~ /(gooduser|goslow|hang|slowlf)/ ) {
                 print $client "+OK Welcome $1$eol";
                 $goslow = ( $1 =~ /goslow/ );
                 $hang   = ( $1 =~ /hang/   );
                 $slowlf = ( $1 =~ /slowlf/ );
	    } else {
                 print $client "-ERR Unknown user $1$eol";
            }
            next;
        }

        if ( $command =~ /^APOP ([^ ]+) (.*)/i ) {

            if ($apop) {

                my $user = $1;
                my $md5_hex_client = $2;

                if ( $user =~ /(gooduser|goslow|hang|slowlf)/ ) {

                    $goslow = ( $1 =~ /goslow/ );
                    $hang   = ( $1 =~ /hang/   );
                    $slowlf = ( $1 =~ /slowlf/ );


                    my $md5 = Digest::MD5->new;
                    $md5->add( $APOPBanner, $APOPSecret );
                    my $md5hexserver = $md5->hexdigest;

                    if ($md5_hex_client eq $md5hexserver) {
                        print $client "+OK $user authenticated$eol";
                    } else {
                        print $client "-ERR bad credentials provided$eol";
                    }
                    next;

    	        } else {
                     print $client "-ERR Unknown APOP user $1$eol";
                     next;
                }
            } else {
                print $client "-ERR what is an APOP$eol";
                next;
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

                 my $slowlftemp = $slowlf;

                 open FILE, "<$messages[$index]";
                 binmode FILE;
                 while ( <FILE> ) {
                     s/\r|\n//g;

                     if ($slowlftemp) {
                        print $client "$_$cr";
                        flush $client;
                        select(undef,undef,undef, 1);
                        print $client "$lf";
                        flush $client;
                        $slowlftemp = 0;
                    } else {
                        print $client "$_$eol" ;
                    }

                     if ( $goslow ) {
                         select( undef, undef, undef, 3 );
		     }
                     if ( $hang ) {
                         select( undef, undef, undef, 30 );
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
                     my $line = $_;
                     s/\r|\n//g;
                     print $client "$_$eol";

                     if ( $line =~ /^[\r\n]+$/ ) {
                         last;
		     }
		 }
                 while ( ( my $line = <FILE> ) && ( $countdown > 0 ) ) {
                     $line =~ s/\r|\n//g;
                     print $client "$line$eol";
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

        if ( $command =~ /JOHN/ ) {
            print $client "+OK Hello John$eol";
            next;
        }

        print $client "-ERR unknown command or bad syntax$eol";
    }

    return 1;
}

test_assert( scalar(`rm -rf corpus`) == 0 );
test_assert( scalar(`cp -R corpus.base corpus`) == 0 );
test_assert( scalar(`rm -rf corpus/CVS`) == 0 );
test_assert( scalar(`rm -rf messages/*`) == 0 );

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;
my $w = new Classifier::WordMangle;

sub forker
{
    pipe my $reader, my $writer;
    $b->prefork();
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ( $pid == 0 ) {
       $b->forked();
        close $reader;

        use IO::Handle;
        $writer->autoflush(1);

        return (0, $writer);
    }

    $b->postfork();
    close $writer;
    return ($pid, $reader);
}

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

$b->initialize();
$b->module_config_( 'html', 'port', 8080 );
$b->module_config_( 'html', 'language', 'English' );
$b->config_( 'hostname', '127.0.0.1' );
$b->{parser__}->mangle( $w );
$b->start();

# some tests require this directory to be present
mkdir( 'messages' );

# This pipe is used to send signals to the child running
# the server to change its state, the following commands can
# be sent
#
# __APOPON    Enable APOP on the server
# __APOPOFF   Disable APOP on the server (default state)

pipe my $dserverreader, my $dserverwriter;
pipe my $userverreader, my $userverwriter;

$b->prefork();
my $pid = fork();

if ( $pid == 0 ) {
    $b->forked();

    # CHILD THAT WILL RUN THE POP3 SERVER

    close $dserverwriter;
    close $dserverwriter;

    $userverwriter->autoflush(1);

    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                    LocalAddr => 'localhost',
                                    LocalPort => 8110,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 );

    my $selector = new IO::Select( $server );
    
    my $apop_server = 0;

    while ( 1 ) {
        if ( defined( $selector->can_read(0) ) ) {
            if ( my $client = $server->accept() ) {
                last if !server($client, $apop_server);
                close $client;
	    }
        }
        
        #print "defined!\n" if (defined($dserverreader) && defined($dserverwriter) );

        if ( pipeready( $dserverreader ) ) {
            my $command = <$dserverreader>;

            #print "\npipe read $command\n";

            if ( $command =~ /__APOPON/ ) {
                $apop_server = 1;
                print $userverwriter "OK\n";
                next;
            }

            if ( $command =~ /__APOPOFF/ ) {
                $apop_server = 0;
                #print "\nAPOP OFF!!\n";
                print $userverwriter "OK\n";
                next;
            }
        } else {

            #print "\npipe unready\n";

            #select(undef,undef,undef, 0.5);
        }

    }

    close $server;
    exit(0);
} else {

    $b->postfork();

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
    $b->prefork();
    my $pid2 = fork();

    if ( $pid2 == 0 ) {

        $b->forked();

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
        $p->config_( 'force_fork', 1 );
        $p->global_config_( 'timeout', 1 );

        $p->config_( 'enabled', 0 );
        test_assert_equal( $p->start(), 2 );
        $p->config_( 'enabled', 1 );
        test_assert_equal( $p->start(), 1 );

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

        $b->postfork();

        # PARENT THAT WILL SEND COMMAND TO THE PROXY

        close $dreader;
        close $uwriter;
        $dwriter->autoflush(1);
        
        close $dserverreader;
        close $userverwriter;
        $dserverwriter->autoflush(1);

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => '127.0.0.1',
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
            $result =~ s/\r|\n//g;
            $line   =~ s/\r|\n//g;
            test_assert_equal( $result, $line );
	}
        close FILE;

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

       # Now get a message that has an illegal embedded CRLF.CRLF

        unlink( 'messages/popfile1=28.msg' );
        unlink( 'messages/popfile1=28.cls' );

        print $client "RETR 28$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[27] ) . "$eol" );
        $cam = $messages[27];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $b->log_( "Got $_" );
            $result = <$client>;
            my $logline = "File [$_], $client [$result]";
            $logline =~ s/[\r\n]//g;
            $b->log_( $logline );
            $result =~ s/popfile1=28/popfile0=0/;
            $result =~ s/\r|\n//g;
            $line   =~ s/\r|\n//g;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # This delay is here because Windows was having a little trouble
        # with the files created by the RETR not existing and I have a little
        # rest here while Windows wakes from its afternoon nap and writes
        # the files to disk

        select( undef, undef, undef, 0.1 );

        # TODO check for NEWFL and CLASS messages

        test_assert( -e 'messages/popfile1=28.msg' );
        test_assert( -e 'messages/popfile1=28.cls' );

        test_assert( open FILE, "<$messages[27]" );
        binmode FILE;
        test_assert( open HIST, "<messages/popfile1=28.msg" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
	}
        test_assert( !eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile1=28.msg' );
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
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
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
        $cam = $messages[6];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile1=7/popfile0=0/;
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
            test_assert_equal( $result, $line );
	}
        close FILE;

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

        ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile1=7.msg' );
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

        $result = <$client>;
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
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
            test_assert_equal( $result, $line, "[$result][$line]" );
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

        ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile2=8.msg' );
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
            $b->log_( "RETR 8 after TOP 8 got line [$line]" );
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $b->log_( "RETR 8 after TOP 8 got from client [$result]" );
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
        $cam = $messages[8];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile2=9/popfile0=0/;
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
            test_assert_equal( $result, $line );
	}
        close FILE;

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

        ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile2=9.msg' );
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

        # Test TOPTOO and caching with illegal CRLF.CRLF in message

        $countdown = 2;
        print $client "TOP 28 $countdown$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[27] ) . "$eol" );

        $cam = $messages[27];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( ( my $line = <FILE> ) && ( $countdown > 0 ) ) {
            $result = <$client>;
            $result =~ s/popfile2=28/popfile0=0/;
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
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

        test_assert( -e 'messages/popfile2=28.msg' );
        test_assert( -e 'messages/popfile2=28.cls' );

        test_assert( open FILE, "<$messages[27]" );
        binmode FILE;
        test_assert( open HIST, "<messages/popfile2=28.msg" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
	}
        test_assert( eof(FILE) );
        close FILE;
        close HIST;

        ( $reclassified, $bucket, $usedtobe, $magnet ) = $b->history_read_class( 'popfile2=28.msg' );
        test_assert( !$reclassified );
        test_assert_equal( $bucket, 'spam' );
        test_assert( !defined( $usedtobe ) );
        test_assert_equal( $magnet, '' );

        # Test RETR after TOP comes from cache with illegal CRLF.CRLF

        print $client "RETR 28$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s 'messages/popfile2=28.msg' ) . " bytes from POPFile cache$eol" );

        $cam = $messages[27];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/popfile2=28/popfile0=0/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Check insertion of the X-POPFile-Timeout headers

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:goslow$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome goslow$eol" );

        print $client "RETR 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[0] ) . "$eol" );
        $cam = $messages[0];
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
            while ( $result = <$client> ) {
                if ( $result =~ /TimeoutPrevention/ ) {
                    next;
	        } else {
                    last;
                }
	    }
            $result =~ s/popfile3=1/popfile0=0/;
            $result =~ s/\r|\n//g;
            $line   =~ s/\r|\n//g;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Test slow LF's on a CRLF

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:slowlf$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome slowlf$eol" );

        print $client "RETR 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[0] ) . "$eol" );
        $cam = $messages[0];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/popfile4=1/popfile0=0/;
            $result =~ s/\r|\n//g;
            $line   =~ s/\r|\n//g;
            test_assert_equal( $result, $line );
	}
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        close $client;

        # Test QUIT straight after connect

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test odd command straight after connect gives error

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "FOOF$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR unknown command or bad syntax$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test the APOP command

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "APOP 127.0.0.1:8111:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR APOP not supported between mail client and POPFile.$eol" );

        # Check that we can connect to the remote POP3 server (should still be waiting
        # for us)

        print $client "APOP 127.0.0.1:8110:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR APOP not supported between mail client and POPFile.$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "APOP 127.0.0.1:8111:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR APOP not supported between mail client and POPFile.$eol" );

        # Check that we can connect to the remote POP3 server (should still be waiting
        # for us)

        print $client "APOP 127.0.0.1:8110:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR APOP not supported between mail client and POPFile.$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        close $client;

        # Test POPFile->server APOP
        
        # Server that doesn't do APOP at all
        
        print $dserverwriter "__APOPOFF\n";

        $line = <$userverreader>;
        test_assert_equal( $line, "OK\n" );
        
        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser:apop$eol";

        $result = <$client>;
        test_assert_equal( $result, "-ERR 127.0.0.1 doesn't support APOP, aborting authentication$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Good user/pass

        print $dserverwriter "__APOPON\n";
        $line = <$userverreader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser:apop$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK hello gooduser$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK password ok$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;
        
        # Bad user

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:baduser:apop$eol";
        
        $result = <$client>;
        test_assert_equal( $result, "+OK hello baduser$eol" );

        print $client "PASS notsecret$eol";

        $result = <$client>;
        test_assert_equal( $result, "-ERR Unknown APOP user baduser$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;
        
        # Good user, bad pass

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result, "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser:apop$eol";
        
        $result = <$client>;
        test_assert_equal( $result, "+OK hello gooduser$eol" );

        print $client "PASS notsecret$eol";

        $result = <$client>;
        test_assert_equal( $result, "-ERR bad credentials provided$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

       # Test SPA/AUTH commands with no secure server specified

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
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
        
        
        # re-disable APOP on the server so we don't mess with anything else

        print $dserverwriter "__APOPOFF\n";
        
        $line = <$userverreader>;
        test_assert_equal( $line, "OK\n" );

        # Test SPA/AUTH with a bad server

        print $dwriter "__SECUREBAD\n";
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
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
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
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

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
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

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
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

        $b->stop();
    }
}

1;
