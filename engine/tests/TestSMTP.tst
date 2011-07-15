# ----------------------------------------------------------------------------
#
# Tests for SMTP.pm
#
# Copyright (c) 2001-2010 John Graham-Cumming
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
# ----------------------------------------------------------------------------

use strict;
use warnings;
no warnings qw(redefine);

use IO::Handle;
use IO::Socket;

use POSIX ":sys_wait_h";

my $cr = "\015";
my $lf = "\012";

my $eol = "$cr$lf";
my $timeout = 2;

rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
rmtree( 'corpus/.svn' );
rmtree( 'messages' );

use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
#$POPFile->{debug__} = 1;
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'POPFile/Logger'        => 1,
              'POPFile/MQ'            => 1,
              'POPFile/Configuration' => 1,
              'POPFile/Database'      => 1,
              'POPFile/History'       => 1,
              'Proxy/SMTP'            => 1,
              'Classifier/Bayes'      => 1,
              'Classifier/WordMangle' => 1 );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );

my $l  = $POPFile->get_module( 'POPFile::Logger'   );
my $mq = $POPFile->get_module( 'POPFile::MQ'       );
my $b  = $POPFile->get_module( 'Classifier::Bayes' );
my $h  = $POPFile->get_module( 'POPFile::History'  );
my $db = $POPFile->get_module( 'POPFile::Database' );

$l->config_( 'level', 2 );

$b->module_config_( 'html', 'port', 8080 );
$b->global_config_( 'language', 'English' );
$b->config_( 'hostname', '127.0.0.1' );

# To test NNTP's use of MQ, we need to receive messages
use Test::MQReceiver;

my $rmq = new Test::MQReceiver;

$mq->register( 'UIREG', $rmq );

my $s = $POPFile->get_module( 'Proxy::SMTP' );
$s->forker( \&forker );
$s->pipeready( $POPFile->{pipeready__} );
$s->setchildexit( $POPFile->{childexit__} );

$s->{version_} = 'test suite';
$s->initialize();

my $port = 9000 + int(rand(1000));
my $port2 = $port + 1;

$s->config_( 'port', $port );
$s->config_( 'force_fork', 0 );
$s->config_( 'chain_server', 'localhost' );
$s->config_( 'chain_port', $port2 );
$s->global_config_( 'timeout', 1 );

$s->config_( 'enabled', 0 );
test_assert_equal( $s->start(), 2 );
$s->config_( 'enabled', 1 );

$POPFile->CORE_start();

# Test dynamic UI

$mq->service();
my @messages = $rmq->read();

shift @messages if ( $^O eq 'MSWin32' );

test_assert_equal( $#messages, 3 );

test_assert_equal( $messages[0][0], 'UIREG' );
test_assert_equal( $#{$messages[0][1]}, 3 );
test_assert_equal( $messages[0][1][0], 'configuration' );
test_assert_equal( $messages[0][1][1], 'smtp_fork_and_port' );
test_assert_equal( $messages[0][1][2], 'smtp-configuration.thtml' );
test_assert_equal( ref $messages[0][1][3], 'Proxy::SMTP' );

test_assert_equal( $messages[1][0], 'UIREG' );
test_assert_equal( $#{$messages[1][1]}, 3 );
test_assert_equal( $messages[1][1][0], 'security' );
test_assert_equal( $messages[1][1][1], 'smtp_local' );
test_assert_equal( $messages[1][1][2], 'smtp-security-local.thtml' );
test_assert_equal( ref $messages[1][1][3], 'Proxy::SMTP' );

test_assert_equal( $messages[2][0], 'UIREG' );
test_assert_equal( $#{$messages[2][1]}, 3 );
test_assert_equal( $messages[2][1][0], 'chain' );
test_assert_equal( $messages[2][1][1], 'smtp_server' );
test_assert_equal( $messages[2][1][2], 'smtp-chain-server.thtml' );
test_assert_equal( ref $messages[2][1][3], 'Proxy::SMTP' );

# Test configure_item

use Test::SimpleTemplate;

my $templ = new Test::SimpleTemplate;

# nothing happens for unknown configuration item names

$s->configure_item( 'foo', $templ );
my $params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 0 );

# the right things have to happen for known configuration item names

$s->configure_item( 'smtp_fork_and_port', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 2 );
test_assert_equal( $templ->param( 'smtp_port'          ), $s->config_( 'port'      ) );
test_assert_equal( $templ->param( 'smtp_force_fork_on' ), ( $s->config_( 'force_fork' ) == 1 ) );

delete $templ->{params__};

$s->configure_item( 'smtp_local', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 1 );
test_assert_equal( $templ->param( 'smtp_local_on' ), ( $s->config_( 'local' ) == 1 ) );

delete $templ->{params__};

$s->configure_item( 'smtp_server', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 2 );
test_assert_equal( $templ->param( 'smtp_chain_server' ), $s->config_( 'chain_server' ) );
test_assert_equal( $templ->param( 'smtp_chain_port' ), $s->config_( 'chain_port' ) );

delete $templ->{params__};

# test changing/validating of configuration values

my $form = {};
my $language= {};
my ( $status, $error );

test_assert_equal( $s->config_( 'socks_port' ), 1080 );

$form->{smtp_socks_port} = 10080;
$language->{Configuration_SOCKSPortUpdate} = "socks port update %s";

( $status, $error ) = $s->validate_item( 'smtp_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks port update 10080" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'socks_port' ), 10080 );

$s->config_( 'socks_port', 1080 );

$form->{smtp_socks_port} = 'aaa';
$language->{Configuration_Error8} = "configuration error 8";

( $status, $error ) = $s->validate_item( 'smtp_socks_configuration', $templ, $language, $form );

test_assert_equal( $error, "configuration error 8" );
test_assert( !defined( $status), $status );
test_assert_equal( $s->config_( 'socks_port' ), 1080 );

delete $form->{smtp_socks_port};

$form->{smtp_socks_server} = 'example.com';
$language->{Configuration_SOCKSServerUpdate} = 'socks server update %s';

( $status, $error ) = $s->validate_item( 'smtp_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks server update example.com" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'socks_server' ), 'example.com' );

$form->{smtp_socks_port} = '10081';
$form->{smtp_socks_server} = 'subdomain.example.com';

( $status, $error ) = $s->validate_item( 'smtp_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks port update 10081\nsocks server update subdomain.example.com" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'socks_server' ), 'subdomain.example.com' );
test_assert_equal( $s->config_( 'socks_port' ), 10081 );

delete $form->{smtp_socks_port};
delete $form->{smtp_socks_server};

$s->config_( 'socks_server', '' );

test_assert_equal( $s->config_( 'port' ), $port );

$language->{Configuration_SMTPUpdate} = "smtp port update %s";
$form->{smtp_port} = $port + 1;

( $status, $error ) = $s->validate_item( 'smtp_fork_and_port', $templ, $language, $form );

test_assert_equal( $status, "smtp port update " . ( $port + 1 ) );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_('port'), $port + 1 );

$s->config_( 'port', $port );

$form->{smtp_port} = 'aaa';
$language->{Configuration_Error3} = "configuration error 3";

( $status, $error ) = $s->validate_item( 'smtp_fork_and_port', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3" );
test_assert( !defined( $status ), $status );
test_assert_equal( $s->config_( 'port' ), $port );

$form->{smtp_port} = 0;

( $status, $error ) = $s->validate_item( 'smtp_fork_and_port', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3" );
test_assert( !defined( $status ), $status );
test_assert_equal( $s->config_( 'port' ), $port );

$form->{smtp_port} = 65536;

( $status, $error ) = $s->validate_item( 'smtp_fork_and_port', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3" );
test_assert( !defined( $status ), $status );
test_assert_equal( $s->config_( 'port' ), $port );

delete $form->{smtp_port};

test_assert_equal( $s->config_( 'force_fork' ), 0 );

$language->{'Configuration_SMTPForkEnabled'} = "smtp fork on";
$language->{'Configuration_SMTPForkDisabled'} = "smtp fork off";
$form->{smtp_force_fork} = 1;

( $status, $error ) = $s->validate_item( 'smtp_fork_and_port', $templ, $language, $form );

test_assert_equal( $status, "smtp fork on\n" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'force_fork' ), 1 );

$form->{smtp_force_fork} = 0;

( $status, $error ) = $s->validate_item( 'smtp_fork_and_port', $templ, $language, $form );

test_assert_equal( $status, "smtp fork off\n" );
test_assert( !defined( $error ) );
test_assert_equal( $s->config_( 'force_fork' ), 0 );

delete $form->{smtp_force_fork};
$s->config_( 'force_fork', 0 );

test_assert_equal( $s->config_( 'local' ), 1 );

$language->{'Security_ServerModeUpdateSMTP'} = "smtp is in server mode";
$language->{'Security_StealthModeUpdateSMTP'} = "smtp is in stealth mode";
$form->{serveropt_smtp} = 1; # Server mode

( $status, $error ) = $s->validate_item( 'smtp_local', $templ, $language, $form );

test_assert_equal( $status, "smtp is in server mode" );
test_assert( !defined( $error ) );
test_assert_equal( $s->config_( 'local' ), 0 );

$form->{serveropt_smtp} = 0; # Stealth mode

( $status, $error ) = $s->validate_item( 'smtp_local', $templ, $language, $form );

test_assert_equal( $status, "smtp is in stealth mode" );
test_assert( !defined( $error ) );
test_assert_equal( $s->config_( 'local' ), 1 );

delete $form->{serveropt_smtp};
$s->config_( 'local', 1 );

test_assert_equal( $s->config_( 'chain_port' ), $port2 );

$form->{smtp_chain_server_port} = 10025;
$language->{Security_SMTPPortUpdate} = "smtp chain port update %s";

( $status, $error ) = $s->validate_item( 'smtp_server', $templ, $language, $form );

test_assert_equal( $status, "smtp chain port update 10025" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'chain_port' ), 10025 );

$s->config_( 'chain_port', $port2 );

$form->{smtp_chain_server_port} = 'aaa';
$language->{Security_Error1} = "security error 1";

( $status, $error ) = $s->validate_item( 'smtp_server', $templ, $language, $form );

test_assert_equal( $error, "security error 1" );
test_assert( !defined( $status), $status );
test_assert_equal( $s->config_( 'chain_port' ), $port2 );

delete $form->{smtp_chain_server_port};

$form->{smtp_chain_server} = 'example.com';
$language->{Security_SMTPServerUpdate} = 'smtp chain server update %s';

( $status, $error ) = $s->validate_item( 'smtp_server', $templ, $language, $form );

test_assert_equal( $status, "smtp chain server update example.com\n" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'chain_server' ), 'example.com' );

$form->{smtp_chain_server_port} = '10025';
$form->{smtp_chain_server} = 'subdomain.example.com';

( $status, $error ) = $s->validate_item( 'smtp_server', $templ, $language, $form );

test_assert_equal( $status, "smtp chain server update subdomain.example.com\nsmtp chain port update 10025" );
test_assert( !defined( $error ), $error );
test_assert_equal( $s->config_( 'chain_server' ), 'subdomain.example.com' );
test_assert_equal( $s->config_( 'chain_port' ), 10025 );

delete $form->{smtp_chain_server_port};
delete $form->{smtp_chain_server};

$s->config_( 'chain_server', 'localhost' );
$s->config_( 'chain_port', $port2 );


# some tests require this directory to be present

mkdir( 'messages' );

# This pipe is used to send signals to the child running
# the server to change its state, the following commands can
# be sent

pipe my $dserverreader, my $dserverwriter;
pipe my $userverreader, my $userverwriter;

my ( $pid, $pipe ) = forker();

if ( $pid == 0 ) {

    # CHILD THAT WILL RUN THE SMTP SERVER

    close $dserverwriter;
    close $userverreader;

    $userverwriter->autoflush(1);

    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                        LocalAddr => 'localhost',
                                        LocalPort => $port2,
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

        if ( pipeready( $dserverreader ) ) {
            my $command = <$dserverreader>;
        }
        select undef, undef, undef, 0.01;
    }

    close $server;
    $b->stop();
    $db->stop();
    exit 0;
} else {

    # This pipe is used to send signals to the child running
    # the proxy to change its state, the following commands can
    # be sent
    #
    # __QUIT      Causes the child to terminate proxy service and
    #             exit

    pipe my $dreader, my $dwriter;
    pipe my $ureader, my $uwriter;

    my ( $pid2, $pipe ) = forker();

    if ( $pid2 == 0 ) {

        # CHILD THAT WILL RUN THE SMTP PROXY

        close $dwriter;
        close $ureader;

        $uwriter->autoflush(1);

        while ( 1 ) {
            last if !$s->service();

            if ( pipeready( $dreader ) ) {
                my $command = <$dreader>;

                if ( $command =~ /__QUIT/ ) {
                    print $uwriter "OK$eol";
                    last;
                }
            }
            select undef, undef, undef, 0.01;
        }

        close $dreader;
        close $uwriter;
        $b->stop();
        $db->stop();
        exit 0;
    } else {

        # PARENT THAT WILL SEND COMMAND TO THE PROXY

        close $dreader;
        close $uwriter;
        $dwriter->autoflush(1);

        close $dserverreader;
        close $userverwriter;
        $dserverwriter->autoflush(1);

        sleep 5;

        my $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        wait_proxy();

        # Make sure that POPFile sends an appropriate banner

        my $result = <$client>;
        test_assert_equal( $result,
            "220 SMTP POPFile (test suite) welcome$eol" );

        wait_proxy();

        # Some commands before HELO

        print $client "NOOP$eol";
        $result = <$client>;
        test_assert_equal( $result, "554 Transaction failed$eol" );

        print $client "BAD COMMAND$eol";
        $result = <$client>;
        test_assert_equal( $result, "500 unknown command or bad syntax$eol" );

        close $client;

        $client = connect_proxy();
        wait_proxy();

        $result = <$client>;
        test_assert_equal( $result,
            "220 SMTP POPFile (test suite) welcome$eol" );

        # HELO and several commands

        print $client "HELO example.com$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 Simple SMTP Server ready$eol" );

        print $client "VRFY <test\@example.com>$eol";
        $result = <$client>;
        test_assert_equal( $result, "502 Command not implemented$eol" );

        print $client "EXPN Test-Mail-List$eol";
        $result = <$client>;
        test_assert_equal( $result, "502 Command not implemented$eol" );

        print $client "NOOP$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 OK$eol" );

        print $client "HELP$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 Some HELP message$eol" );

        print $client "MAIL FROM:<sender\@example.com>$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 Sender OK$eol" );

        print $client "RCPT TO:<receiver\@example.com>$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 Recipient OK$eol" );

        print $client "RCPT TO:<nouser\@example.com>$eol";
        $result = <$client>;
        test_assert_equal( $result, "550 No such user$eol" );

        print $client "RSET$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 OK$eol" );

        print $client "BAD COMMAND$eol";
        $result = <$client>;
        test_assert_equal( $result, "500 unknown command or bad syntax$eol" );

        # Relaying a message

        my @messages = sort glob 'TestMails/TestMailParse*.msg';

        print $client "MAIL FROM:<sender1\@example.com>$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 Sender OK$eol" );

        print $client "RCPT TO:<recipient1\@example.com>$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 Recipient OK$eol" );

        print $client "DATA$eol";
        $result = <$client>;
        test_assert_equal( $result, "354 Start mail input; end with <CRLF>.<CRLF>$eol" );

        test_assert( open FILE, "<$messages[0]" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $line =~ s/[$cr$lf]+/$cr$lf/g;
            print $client $line;
        }
        close FILE;

        print $client ".$eol";
        $result = <$client>;
        test_assert_equal( $result, "250 OK$eol" );

        wait_proxy();

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "221 Bye$eol" );

        close $client;
        sleep 1;

        # EHLO command test

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        wait_proxy();

        $result = <$client>;
        test_assert_equal( $result,
            "220 SMTP POPFile (test suite) welcome$eol" );

        wait_proxy();

        print $client "EHLO example.com$eol";
        $result = <$client>;
        test_assert_equal( $result, "250-Simple SMTP Server ready$eol" );
        $result = <$client>;
        test_assert_equal( $result, "250-HELP$eol" );
        $result = <$client>;
        test_assert_equal( $result, "250 8BITMIME$eol" );

        # Tell the test server to die

        my $line;

        print $client "__QUIT__$eol";
        $result = <$client>;
        test_assert_equal( $result, "221 Bye$eol" );

        close $client;
        sleep 1;

        # Tell the proxy to die

        print $dwriter "__QUIT$eol";
        $line = <$ureader>;
        test_assert_equal( $line, "OK$eol" );
        close $dwriter;
        close $ureader;

        $s->stop();
        $POPFile->CORE_stop();

        while ( waitpid( -1, 0 ) != -1 ) { }

        $mq->reaper();
    }
}

sub connect_proxy
{
    my $client = IO::Socket::INET->new(
                    Proto    => "tcp",
                    PeerAddr => 'localhost',
                    PeerPort => $port );

    return $client;
}

sub wait_proxy
{
    my $cd = 10;
    while ( $cd-- ) {
        select( undef, undef, undef, 0.1 );
        $mq->service();
        $h->service();
    }
}

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
    my ( $client ) = @_;
    my @messages = sort glob 'TestMails/TestMailParse*.msg';
    my $msg_num = 0;
    my $sender = '';
    my @recipients = ();

    my $time = time;

    print $client "220 Ready$eol";

    while  ( <$client> ) {
        my $command;

        $command = $_;
        $command =~ s/($cr|$lf)//g;

        if ( $command =~ /^HELO (.*)/i ) {
            print $client "250 Simple SMTP Server ready$eol";
            next;
        }

        if ( $command =~ /^EHLO (.*)/i ) {
            print $client "250-Simple SMTP Server ready$eol";
            print $client "250-CHUNKING$eol";  # Suppressed
            print $client "250-XEXCH50$eol";   # Suppressed
            print $client "250-HELP$eol";
            print $client "250 8BITMIME$eol";
            next;
        }

        if ( $command =~ /^(VRFY|EXPN) (.*)/i ) {
            print $client "502 Command not implemented$eol";
            next;
        }

        if ( $command =~ /^NOOP$/i ) {
            print $client "250 OK$eol";
            next;
        }

        if ( $command =~ /^HELP *(.*)/i ) {
            print $client "211 Some HELP message$eol";
            next;
        }

        if ( $command =~ /^RSET$/i ) {
            $sender = '';
            @recipients = ();
            print $client "250 OK$eol";
            next;
        }

        if ( $command =~ /^MAIL FROM: *(.*)/i ) {
            $sender = $1;
            print $client "250 Sender OK$eol";
            $msg_num = $1 if ( $sender =~ /sender([\d]+)/ );
            next;
        }

        if ( $command =~ /^RCPT TO: *(.*)/i ) {
            my $user = $1;
            if ( $user =~ /nouser/ ) {
                print $client "550 No such user$eol";
            } else {
                push @recipients, $user;
                print $client "250 Recipient OK$eol";
            }
            next;
        }

        if ( $command =~ /^DATA$/i ) {
            print $client "354 Start mail input; end with <CRLF>.<CRLF>$eol";

            my $cam = $messages[$msg_num - 1];
            $cam =~ s/msg$/cam/;

            test_assert( open FILE, "<$cam" );
            binmode FILE;

            while ( <FILE> ) {
                my $line = $_;
                my $result = <$client>;

                $result =~ s/view=1/view=popfile0=0.msg/;
                $result =~ s/[$cr$lf]+//g;
                $line   =~ s/[$cr$lf]+//g;
                test_assert_equal( $result, $line );
            }
            close FILE;

            my $result = <$client>;
            test_assert_equal( $result, ".$eol" );

            print $client "250 OK$eol";
            next;
        }

        if ( $command =~ /^QUIT/i ) {
            print $client "221 Bye$eol";
            last;
        }

        if ( $command =~ /__QUIT__/i ) {
            print $client "221 Bye$eol";
            return 0;
        }

        if ( $command =~ /^[ \t]*$/i ) {
            next;
        }

        print $client "500 unknown command or bad syntax$eol";
    }

    return 1;
}

sub forker
{
    pipe my $reader, my $writer;
    $l->log_( 2, "Created pipe pair $reader and $writer" );
    $b->prefork();
    $mq->prefork();
    $h->prefork();
    $db->prefork();
    $s->prefork();
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ( $pid == 0 ) {
        $db->forked( $writer );
        $b->forked( $writer );
        $mq->forked( $writer );
        $h->forked( $writer );
        close $reader;

        use IO::Handle;
        $writer->autoflush(1);

        return (0, $writer);
    }

    $l->log_( 2, "Child process has pid $pid" );

    $b->postfork( $pid, $reader );
    $mq->postfork( $pid, $reader );
    $h->postfork( $pid, $reader );
    $db->postfork( $pid, $reader );
    $s->postfork( $pid, $reader );
    close $writer;
    return ($pid, $reader);
}

1;
