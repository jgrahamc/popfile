# ---------------------------------------------------------------------------------------------
#
# Tests for POP3.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::POP3;
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
    my $client;
    my @messages = glob '*.msg';

    while  ( <$client> ) {
        my $command;

        $command = $_;
        $command =~ s/(\015|\012)//g;

        if ( $command =~ /USER (.*)/i ) {
	    if ( $1 =~ /gooduser/ ) {
                 print $client "+OK Welcome $1$eol";
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

        if ( $command =~ /QUIT/i ) {
            print $client "+OK Bye$eol";
            next;
        }

        if ( $command =~ /__QUIT__/i ) {
            print $client "+OK Bye$eol";
            last;
        }

        if ( $command =~ /RSET/i ) {
            @messages = glob '*.msg';
            print $client "+OK Reset$eol";
            next;
        }

        if ( $command =~ /HELO/i ) {
            print $client "+OK Hello$eol";
            next;
        }

        if ( $command =~ /DELE (.*)/i ) {
            $messages[$1] = '';
            print $client "+OK Deleted $1$eol";
            next;
        }

        if ( $command =~ /RETR (.*)/i ) {
	    if ( $messages[$1] ne '' ) {
                 print $client "+OK " . ( -s $messages[$1] ) . "$eol";

                 open FILE, "<$messages[$1]";
                 while ( <FILE> ) {
                     print $client $_;
		 }
                 close FILE;

                 print $client ".$eol";

	    } else {
                print $client "-ERR No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /TOP (.*) (.*)/i ) {
	    if ( $messages[$1] ne '' ) {
                 print $client "+OK " . ( -s $messages[$1] ) . "$eol";

                 open FILE, "<$messages[$1]";
                 while ( <FILE> ) {
                     print $client $_;

                     if ( !/[^ \t\r\n]/ ) {
                         last;
		     }
		 }
                 my $countdown = $2;
                 while ( <FILE> && ( $countdown > 0 ) ) {
                     print $client $_;
                     $countdown -= 1;
		 }
                 close FILE;

                 print $client ".$eol";

	    } else {
                print $client "-ERR No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /CAPA/i ) {
            next;
        }

        if ( $command =~ /APOP (.*):((.*):)?(.*) (.*)/i ) {
            next;
        }

        if ( $command =~ /AUTH ([^ ]+)/ ) {
            next;
        }

        if ( $command =~ /AUTH/ ) {
            next;
        }

        print $client "-ERR unknown command or bad syntax$eol";
    }
}

my $pid = fork();

if ( $pid == 0 ) {

    # CHILD THAT WILL RUN THE POP3 SERVER

    exit(0);
} else {

    my $port = 9000 + int(rand(1000));
    my $pid2 = fork();

    if ( $pid2 == 0 ) {

        # CHILD THAT WILL RUN THE POP3 PROXY

        my $c = new POPFile::Configuration;
        my $mq = new POPFile::MQ;
        my $l = new POPFile::Logger;
        my $p = new Proxy::POP3

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

        $p->configuration( $c );
        $p->mq( $mq );
        $p->logger( $l );

        $p->forker( \&forker );
        $p->pipeready( \&pipeready );

        $p->{version_} = 'test suite';
        $p->initialize();
        $p->config_( 'port', $port );
        test_assert_equal( $p->start(), 1 );

        my $now = time;

        while ( $p->service() && ( ( $now + 5 ) > time ) ) {
	}

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

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        close $client;

        while ( waitpid( $pid, &WNOHANG ) != $pid ) {
        }
        while ( waitpid( $pid2, &WNOHANG ) != $pid2 ) {
        }
    }
}
