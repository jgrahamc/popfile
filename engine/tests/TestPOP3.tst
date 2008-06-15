# ----------------------------------------------------------------------------
#
# Tests for POP3.pm
#
# Copyright (c) 2003-2006 John Graham-Cumming
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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ----------------------------------------------------------------------------


use IO::Handle;
use IO::Socket;
use Digest::MD5;
use strict;

unlink 'popfile.db';
unlink 'popfile.cfg';
unlink 'popfile.pid';

use POSIX ":sys_wait_h";

my $cr = "\015";
my $lf = "\012";

my $eol = "$cr$lf";

rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
rmtree( 'corpus/.svn' );
rmtree( 'messages' );

use POSIX ":sys_wait_h";

use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
# $POPFile->{debug__} = 1;
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'POPFile/Logger'        => 1,
              'POPFile/MQ'            => 1,
              'POPFile/Configuration' => 1,
              'POPFile/Database'      => 1,
              'POPFile/History'       => 1,
              'UI/HTML'               => 1,
              'Proxy/POP3'            => 1,
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

$l->config_( 'level', 1 );
# $l->global_config_( 'debug', 3 ); # uncomment to debug to console

my $http_port = 18080;
$b->module_config_( 'html', 'port', $http_port );
$b->global_config_( 'language', 'English' );
$b->config_( 'hostname', '127.0.0.1' );

# To test POP3's use of MQ, we need to receive messages
use Test::MQReceiver;

my $rmq = new Test::MQReceiver;

$mq->register( 'UIREG', $rmq );

#use Proxy::POP3;
# my $p = new Proxy::POP3;

# $p->loader( $POPFile );
my $p = $POPFile->get_module( 'Proxy::POP3' );

$p->forker( \&forker );
$p->pipeready( $POPFile->{pipeready__} );
$p->setchildexit( $POPFile->{childexit__} );

$p->{version_} = 'test suite';
$p->initialize();

my $port = 9000 + int( rand( 1000 ) );

$p->config_( 'port', $port );
$p->config_( 'force_fork', 0 );
$p->global_config_( 'timeout', 1 );

$p->config_( 'enabled', 0 );
test_assert_equal( $p->start(), 2 );
$p->config_( 'enabled', 1 );

$POPFile->CORE_start();
#test_assert_equal( $p->start(), 1 );
test_assert_equal( $p->{server__}, $p->{selector__}->exists( $p->{server__} ) );



# Test dynamic UI

# $p->start() should send UIREG messages:

$mq->service();
my @messages = $rmq->read();

shift @messages if ( $^O eq 'MSWin32' );

test_assert_equal( $#messages, 3 );


test_assert_equal( $messages[0][0], 'UIREG' );
test_assert_equal( $#{$messages[0][1]}, 3 );
test_assert_equal( $messages[0][1][0], 'configuration' );
test_assert_equal( $messages[0][1][1], 'pop3_configuration' );
test_assert_equal( $messages[0][1][2], 'pop3-configuration-panel.thtml' );
test_assert_equal( ref $messages[0][1][3], 'Proxy::POP3' );

test_assert_equal( $messages[1][0], 'UIREG' );
test_assert_equal( $#{$messages[1][1]}, 3 );
test_assert_equal( $messages[1][1][0], 'security' );
test_assert_equal( $messages[1][1][1], 'pop3_security' );
test_assert_equal( $messages[1][1][2], 'pop3-security-panel.thtml' );
test_assert_equal( ref $messages[1][1][3], 'Proxy::POP3' );

test_assert_equal( $messages[2][0], 'UIREG' );
test_assert_equal( $#{$messages[2][1]}, 3 );
test_assert_equal( $messages[2][1][0], 'chain' );
test_assert_equal( $messages[2][1][1], 'pop3_chain' );
test_assert_equal( $messages[2][1][2], 'pop3-chain-panel.thtml' );
test_assert_equal( ref $messages[2][1][3], 'Proxy::POP3' );

test_assert_equal( $messages[3][0], 'UIREG' );
test_assert_equal( $#{$messages[3][1]}, 3 );
test_assert_equal( $messages[3][1][0], 'configuration' );
test_assert_equal( $messages[3][1][1], 'pop3_socks_configuration' );
test_assert_equal( $messages[3][1][2], 'socks-widget.thtml' );
test_assert_equal( ref $messages[3][1][3], 'Proxy::POP3' );


# Test configure_item

use Test::SimpleTemplate;

my $templ = new Test::SimpleTemplate;

# nothing happens for unknown configuration item names

$p->configure_item( 'foo', $templ );
my $params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 0 );

# the right things have to happen for known configuration item names

$p->configure_item( 'pop3_socks_configuration', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 3 );
test_assert_equal( $templ->param( 'Socks_Widget_Name' ), 'pop3' );
test_assert_equal( $templ->param( 'Socks_Server' ), $p->config_( 'socks_server' ) );
test_assert_equal( $templ->param( 'Socks_Port'   ), $p->config_( 'socks_port'   ) );
$templ->{params__} = {};

$p->configure_item( 'pop3_configuration', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 3 );
test_assert_equal( $templ->param( 'POP3_Configuration_If_Force_Fork' ), ( $p->config_( 'force_fork' ) == 1 ) );
test_assert_equal( $templ->param( 'POP3_Configuration_Port'          ),  $p->config_( 'port'       ) );
test_assert_equal( $templ->param( 'POP3_Configuration_Separator'     ),  $p->config_( 'separator'  ) );

delete $templ->{params__};

$p->configure_item( 'pop3_security', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 1 );
test_assert_equal( $templ->param( 'POP3_Security_Local' ), ( $p->config_( 'local' ) == 1 ) );

delete $templ->{params__};

$p->configure_item( 'pop3_chain', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 3 );
test_assert_equal( $templ->param( 'POP3_Chain_Secure_Server' ), $p->config_( 'secure_server' ) );
test_assert_equal( $templ->param( 'POP3_Chain_Secure_Port'   ), $p->config_( 'secure_port'   ) );
test_assert_equal( $templ->param( 'POP3_Chain_Secure_SSL'    ), ( $p->config_( 'secure_ssl' ) == 1 ) );

delete $templ->{params__};


# test changing/validating of configuration values

my $form = {};
my $language= {};

my ($status, $error);

test_assert_equal( $p->config_( 'socks_port' ), 1080 );

$form->{pop3_socks_port} = 10080;
$language->{Configuration_SOCKSPortUpdate} = "socks port update %s";

($status, $error) = $p->validate_item( 'pop3_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks port update 10080" );
test_assert( !defined( $error) );
test_assert_equal( $p->config_( 'socks_port' ), 10080 );

$p->config_( 'socks_port', 1080 );

$form->{pop3_socks_port} = 'aaa';
$language->{Configuration_Error8} = "configuration error 8";

($status, $error) = $p->validate_item( 'pop3_socks_configuration', $templ, $language, $form );

test_assert_equal( $error, "configuration error 8" );
test_assert( !defined( $status) );
test_assert_equal( $p->config_( 'socks_port' ), 1080 );

$form->{pop3_socks_server} = 'example.com';
$language->{Configuration_SOCKSServerUpdate} = 'socks server update %s';
delete $form->{pop3_socks_port};

($status, $error) = $p->validate_item( 'pop3_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks server update example.com" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'socks_server' ), 'example.com' );

$form->{pop3_socks_port} = '10081';
$form->{pop3_socks_server} = 'subdomain.example.com';

($status, $error) = $p->validate_item( 'pop3_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks port update 10081\nsocks server update subdomain.example.com" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'socks_server' ), 'subdomain.example.com' );
test_assert_equal( $p->config_( 'socks_port' ), 10081 );

$p->config_( 'socks_server', '' );


test_assert_equal( $p->config_( 'port' ), $port );

$language->{Configuration_POP3Update} = "pop3 port update %s";
$form->{pop3_port} = $port + 1;

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );

test_assert_equal( $status, "pop3 port update " . ( $port + 1 ) . "\n" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_('port'), $port + 1 );

$p->config_( 'port', $port );

$form->{pop3_port} = 'aaa';
$language->{Configuration_Error3} = "configuration error 3";

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3\n" );
test_assert( !defined( $status ) );
test_assert_equal( $p->config_( 'port' ), $port );

delete $form->{pop3_port};

test_assert_equal( $p->config_("separator"), ':' );

$language->{'Configuration_POP3SepUpdate'} = "pop3 separator update %s";
$form->{pop3_separator} = "'";

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );
test_assert_equal( $status, "pop3 separator update '\n" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'separator' ), "'" );

$p->config_( 'separator', ':' );

$form->{pop3_separator} = "aaaaa";
$language->{'Configuration_Error1'} = "configuration error 1";

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );

test_assert_equal( $error, "configuration error 1\n" );
test_assert( !defined( $status ) );
test_assert_equal( $p->config_( 'separator' ), ':' );

delete $form->{pop3_separator};

test_assert_equal( $p->config_( 'force_fork' ), 0);
$form->{update_pop3_configuration} = 1;
$form->{pop3_force_fork} = 1;
$language->{'Configuration_POPForkEnabled'} = "use pop3 forking";
$language->{'Configuration_POPForkDisabled'} = "don't use pop3 forking";

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );
test_assert_equal( $status, "use pop3 forking" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'force_fork' ), 1 );

$form->{pop3_force_fork} = 'aaaaa';

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );
test_assert( !defined( $status ) );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'force_fork' ), 1 );

$form->{pop3_force_fork} = '';

($status, $error) = $p->validate_item( 'pop3_configuration', $templ, $language, $form );
test_assert_equal( $status, "don't use pop3 forking" );
test_assert( !defined($error) );
test_assert_equal( $p->config_( 'force_fork' ), 0 );

delete $form->{pop3_force_fork};
delete $form->{update_pop3_configuration};
$p->config_( 'force_fork', 0 );

test_assert_equal( $p->config_( 'local' ), 1 );

$form->{serveropt_pop3} = 1;
($status, $error) = $p->validate_item( 'pop3_security', $templ, $language, $form );
test_assert( !defined( $status ) );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'local' ), 0 );

$form->{serveropt_pop3} = 0;
($status, $error) = $p->validate_item( 'pop3_security', $templ, $language, $form );
test_assert( !defined( $status ) );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'local' ), 1 );

$p->config_( 'local', 1 );

my $old_config_value = $p->config_( 'secure_server' );

$form->{server} = "www.example.com";
$language->{Security_SecureServerUpdate} = "secure server update %s";

($status, $error) = $p->validate_item( 'pop3_chain', $templ, $language, $form );
test_assert_equal( $status, "secure server update www.example.com\n" );
test_assert_equal( defined( $error ), defined( undef ) );
test_assert_equal( $p->config_( 'secure_server' ), 'www.example.com' );

delete $form->{server};
$p->config_( 'secure_server', $old_config_value );

$old_config_value = $p->config_( 'secure_port' );

$form->{sport} = "10110";
$language->{Security_SecurePortUpdate} = "secure port update %s";

($status, $error) = $p->validate_item( 'pop3_chain', $templ, $language, $form );
test_assert_equal( $status, "secure port update 10110\n" );
test_assert_equal( defined( $error ), defined( undef ) );
test_assert_equal( $p->config_( 'secure_port' ), 10110 );

$form->{sport} = 'aaaaaaa';

$language->{Security_Error1} = "security error 1";
($status, $error) = $p->validate_item( 'pop3_chain', $templ, $language, $form );
test_assert_equal( defined( $status ), defined( undef ) );
test_assert_equal( $error, "security error 1" );
test_assert_equal( $p->config_( 'secure_port' ), 10110 );

delete $form->{sport};
$p->config_('secure_port', $old_config_value );

$old_config_value = $p->config_( 'secure_ssl' );

$form->{sssl} = "1";
$form->{update_server} = 1;

$language->{Security_SecureServerUseSSLOn} = "use SSL connections";
$language->{Security_SecureServerUseSSLOff} = "not use SSL connections";

($status, $error) = $p->validate_item( 'pop3_chain', $templ, $language, $form );
test_assert_equal( $status, "use SSL connections\n" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'secure_ssl' ), 1 );

$form->{sssl} = '';

($status, $error) = $p->validate_item( 'pop3_chain', $templ, $language, $form );
test_assert_equal( $status, "not use SSL connections\n" );
test_assert( !defined( $error ) );
test_assert_equal( $p->config_( 'secure_ssl' ), 0 );

delete $form->{sssl};
delete $form->{update_server};
$p->config_('secure_ssl', $old_config_value );

# create user and account for the multiuser mode tests

my $session = $b->get_administrator_session_key();
test_assert( defined( $session ) );

my ( $result, $password ) = $b->create_user( $session, 'transparent' );
test_assert( $b->add_account( $session, 1, 'pop3', '127.0.0.1:gooduser' ) == 1 );

$b->release_session_key( $session );

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

my ( $pid, $pipe ) = forker();

if ( $pid == 0 ) {

    # CHILD THAT WILL RUN THE POP3 SERVER

    close $dserverwriter;
    close $userverreader;

    $userverwriter->autoflush( 1 );

    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                    LocalAddr => 'localhost',
                                    LocalPort => 8110,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 );

    my $selector = new IO::Select( $server );

    my $apop_server = 0;

    while ( 1 ) {
        if ( defined( $selector->can_read( 0 ) ) ) {
            if ( my $client = $server->accept() ) {
                last if !server( $client, $apop_server );
                close $client;
            }
        }

        if ( &{$POPFile->{pipeready__}}( $dserverreader ) ) {
            my $command = <$dserverreader>;

            if ( $command =~ /__APOPON/ ) {
                $apop_server = 1;
                print $userverwriter "OK\n";
                next;
            }

            if ( $command =~ /__APOPOFF/ ) {
                $apop_server = 0;
                print $userverwriter "OK\n";
                next;
            }
        }
        select ( undef, undef, undef, 0.05 );
    }

    close $server;
    sleep(1);
    exit(0);
} else {

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

    my ( $pid2, $pipe ) = forker();

    if ( $pid2 == 0 ) {

        # CHILD THAT WILL RUN THE POP3 PROXY

        $p->log_( 0, "I am the POP3 proxy on port " . $p->config_( 'port' ) );

        close $dwriter;
        close $ureader;

        $uwriter->autoflush(1);

        while ( 1 ) {
            last if !$p->service();
#            $p->log_(2, "POP3 proxy loop instance");

            if ( &{$POPFile->{pipeready__}}( $dreader ) ) {
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

                if ( $command =~ /__SEPCHANGE (.)/ ) {
                    $p->config_( 'separator', $1 );
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

                if ( $command =~ /__MULTIUSERMODE/ ) {
                    $p->global_config_( 'single_user', 0 );
                    print $uwriter "OK\n";
                    next;
                }

                if ( $command =~ /__SINGLEUSERMODE/ ) {
                    $p->global_config_( 'single_user', 1 );
                    print $uwriter "OK\n";
                    next;
                }

            }
            select ( undef, undef, undef, 0.05 );
        }

        close $dreader;
        close $uwriter;

        $mq->reaper();
        $p->stop();

        $POPFile->CORE_stop();

        sleep(1);
        exit(0);
    } else {

        # PARENT THAT WILL SEND COMMAND TO THE PROXY

        close $dreader;
        close $uwriter;
        $dwriter->autoflush(1);

        close $dserverreader;
        close $userverwriter;
        $dserverwriter->autoflush(1);

        my $session = $b->get_administrator_session_key();

        select( undef, undef, undef, 5 );

        my $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => '127.0.0.1',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
            $b->service();
        }

        # Make sure that POPFile sends an appropriate banner

        my $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "USER 127.0.0.1:8111:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR can't connect to 127.0.0.1:8111$eol" );

        # Try a failed transparent proxying

        print $client "USER gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR Transparent proxying not configured: set secure server/port ( command you sent: 'USER gooduser' )$eol" );

        # Check that we can connect to the remote POP3 server
        # (should still be waiting for us)

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        # Now send a bad password

        print $client "PASS password$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR Bad Password$eol" );

        # And then a good one

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
            $b->service();
        }

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
        my @messages = sort glob 'TestMails/TestMailParse*.msg';
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
            $result =~ s/view=1/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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

        my $slot_file = $h->get_slot_file( 1 );
        $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
            $b->service();
        }

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[0]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
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

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) = $h->get_slot_fields( 1, $session );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $hdr_from, 'blank' );
        test_assert_equal( $magnet, '' );

        # Now get a message that has an illegal embedded CRLF.CRLF

        print $client "RETR 28$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[27] ) . "$eol" );
        $cam = $messages[27];
        $cam =~ s/msg$/cam/;

        test_assert( open RESULT, ">$messages[27]_testpop3-got.cam" );
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            print RESULT $result;
            my $logline = "File [$_], $client [$result]";
            $logline =~ s/[\r\n]//g;
            $result =~ s/view=2/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
            $result =~ s/\r|\n//g;
            $line   =~ s/\r|\n//g;
            test_assert_equal( $result, $line );
        }
        close FILE;
        close RESULT;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # This delay is here because Windows was having a little trouble
        # with the files created by the RETR not existing and I have a little
        # rest here while Windows wakes from its afternoon nap and writes
        # the files to disk

        select( undef, undef, undef, 0.1 );

        $slot_file = $h->get_slot_file( 2 );
        $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[27]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        my $fl;
        while ( ( $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
        }
        test_assert( eof(FILE) ); # TODO check
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) = $h->get_slot_fields( 2, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
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

        # Check that TOP x 99999999 is the same as RETR x for fetchmail
        # compatibility

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
            $result =~ s/view=3/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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

        $slot_file = $h->get_slot_file( 3 );
        $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[6]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
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

        ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) = $h->get_slot_fields( 3, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # Check that we echo the remote servers QUIT response

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Test basic TOP capability with toptoo gets classification

        print $dwriter "__TOPTOO\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
            $result =~ s/view=4/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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

        my $slot_file = $h->get_slot_file( 4 );
        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[7]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
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

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) = $h->get_slot_fields( 4, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # Test RETR after TOP comes from cache

        print $client "RETR 8$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[7] ) .
            " bytes from POPFile cache$eol" ) if ( $^O ne 'MSWin32' );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/view=4/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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
            $result =~ s/view=5/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        select( undef, undef, undef, 0.1 );

        my $slot_file = $h->get_slot_file( 5 );
        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[8]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
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

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) = $h->get_slot_fields( 5, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        print $client "RETR 9$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[8] ) .
            " bytes from POPFile cache$eol" ) if ( $^O ne 'MSWin32' );

        $cam = $messages[8];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/view=5/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "RETR 9$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $messages[8] ) .
            " bytes from POPFile cache$eol" ) if ( $^O ne 'MSWin32' );

        $cam = $messages[8];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/view=5/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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
            $result =~ s/view=6/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
            test_assert( $result =~ /\015/ );
            $result =~ s/\015//;
            $line =~ s/\015//;
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

        my $slot_file = $h->get_slot_file( 6 );
        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[27]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[\r\n]//g;
            $ml =~ s/[\r\n]//g;
            test_assert_equal( $fl, $ml );
        }
        test_assert( eof(FILE) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) = $h->get_slot_fields( 6, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # Test RETR after TOP comes from cache with illegal CRLF.CRLF

        print $client "RETR 28$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK " . ( -s $slot_file )
            . " bytes from POPFile cache$eol" ) if ( $^O ne 'MSWin32' );

        $cam = $messages[27];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        $headers   = 1;
        while ( my $line = <FILE> ) {
            $line =~ s/[\r\n]//g;
            $result = <$client>;
            $result =~ s/[\r\n]//g;
            $result =~ s/view=6/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Check insertion of the X-POPFile-Timeout headers

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:goslow$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome goslow$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
            $result =~ s/view=7/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Test slow LF's on a CRLF

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:slowlf$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome slowlf$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
            $result =~ s/view=8/view=popfile0=0.msg/;
            $result =~ s/127\.0\.0\.1:$http_port/127.0.0.1:8080/;
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

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Test QUIT straight after connect

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Test odd command straight after connect gives error

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "FOOF$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR unknown command or bad syntax$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Test the APOP command

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "APOP 127.0.0.1:8111:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR APOP not supported between mail client and POPFile.$eol" );

        # Check that we can connect to the remote POP3 server
        # (should still be waiting for us)

        print $client "APOP 127.0.0.1:8110:gooduser md5$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR APOP not supported between mail client and POPFile.$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser:apop$eol";

        $result = <$client>;
        test_assert_equal( $result,
          "-ERR 127.0.0.1 doesn't support APOP, aborting authentication$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser:apop$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK hello gooduser$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK password ok$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Bad user

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:baduser:apop$eol";

        $result = <$client>;
        test_assert_equal( $result, "+OK hello baduser$eol" );

        print $client "PASS notsecret$eol";

        $result = <$client>;
        test_assert_equal( $result, "-ERR Unknown APOP user baduser$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Good user, bad pass

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser:apop$eol";

        $result = <$client>;
        test_assert_equal( $result, "+OK hello gooduser$eol" );

        print $client "PASS notsecret$eol";

        $result = <$client>;
        test_assert_equal( $result, "-ERR bad credentials provided$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

       # Test SPA/AUTH commands with no secure server specified

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

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

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "CAPA$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR can't connect to 127.0.0.1:8111$eol" );

        print $client "AUTH$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR can't connect to 127.0.0.1:8111$eol" );

        print $client "AUTH username$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "-ERR can't connect to 127.0.0.1:8111$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK goodbye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

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
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

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

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

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

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Test successful transparent proxying, we have a test
        # for the failure case above

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Make sure that changing the separator doesn't break
        # anything

        print $dwriter "__SEPCHANGE Q\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

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
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1Q8110Qgooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        print $dwriter "__SEPCHANGE \$\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1\$8110\$gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # Restore the separater

        print $dwriter "__SEPCHANGE :\n";
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $b->release_session_key( $session );

        # Multiuser mode tests

        print $dwriter "__MULTIUSERMODE :\n";
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );

        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # transparent proxy

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );

        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:transparent$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome transparent$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        # bad account

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );

        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:noaccount$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome noaccount$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "-ERR Unknown account 127.0.0.1:noaccount$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        close $client;

        print $dwriter "__SINGLEUSERMODE :\n";
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        # Send the remote server a special message that makes it die

        $client = IO::Socket::INET->new(
                        Proto    => "tcp",
                        PeerAddr => 'localhost',
                        PeerPort => $port );

        test_assert( defined( $client ) );

        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "+OK POP3 POPFile (test suite) server ready$eol" );

        print $client "USER 127.0.0.1:8110:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Welcome gooduser$eol" );

        print $client "PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Now logged in$eol" );

        my $cd = 10;
        while ( $cd-- ) {
            select( undef, undef, undef, 0.1 );
            $mq->service();
            $h->service();
        }

        print $client "__QUIT__$eol";
        $result = <$client>;
        test_assert_equal( $result, "+OK Bye$eol" );

        close $client;

        # Tell the proxy to die

        print $dwriter "__QUIT\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );
        close $dwriter;
        close $ureader;

        while ( waitpid( -1, WNOHANG ) > 0 ) {
            select( undef, undef, undef, 0.1 );
        }

    }
}

1;


sub server
{
    my ( $client, $apop ) = @_;
    my @messages = sort glob 'TestMails/TestMailParse*.msg';
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
            if ( $1 =~ /(gooduser|goslow|hang|slowlf|transparent|noaccount)/ ) {
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

                    if ( $md5_hex_client eq $md5hexserver ) {
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

            for my $i ( 0..$#messages ) {
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
            @messages = sort glob 'TestMails/TestMailParse*.msg';
            print $client "+OK Reset$eol";
            next;
        }

        if ( $command =~ /HELO/i ) {
            print $client "+OK Hello$eol";
            next;
        }

        if ( $command =~ /DELE (.*)/i ) {
            my $index = $1 - 1;
            if ( defined( $messages[$index] ) &&
                 ( $messages[$index] ne '' ) ) {
                $messages[$index] = '';
                print $client "+OK Deleted $1$eol";
            } else {
                print $client "-ERR No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /RETR (\d+)/i ) {
            my $index = $1 - 1;
            if ( defined( $messages[$index] ) &&
                ( $messages[$index] ne '' ) ) {
                print $client "+OK " . ( -s $messages[$index] ) . "$eol";

                my $slowlftemp = $slowlf;

                open FILE, "<$messages[$index]";
                binmode FILE;
                while ( <FILE> ) {
                    s/\r|\n//g;

                    if ($slowlftemp) {
                        print $client "$_$cr";
                        flush $client;
                        select( undef, undef, undef, 1 );
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
            print $client "+OK I can handle$eol" . "AUTH$eol" .
                "USER$eol" . "APOP$eol.$eol";
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

sub forker
{
    pipe my $reader, my $writer;
    $l->log_( 2, "Created pipe pair $reader and $writer" );
    $b->prefork();
    $mq->prefork();
    $h->prefork();
    $db->prefork();
    $p->prefork();
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return ( undef, undef );
    }

    if ( $pid == 0 ) {
        $b->forked( $writer );
        $mq->forked( $writer );
        $h->forked( $writer );
        $db->forked( $writer );
#        $p->forked( $writer );
        close $reader;

        use IO::Handle;
        $writer->autoflush( 1 );

        return ( 0, $writer );
    }

    $l->log_( 2, "Child process has pid $pid" );

    $b->postfork( $pid, $reader );
    $mq->postfork( $pid, $reader );
    $h->postfork( $pid, $reader );
    $db->postfork( $pid, $reader );
    $p->postfork( $pid, $reader );
    close $writer;
    return ($pid, $reader);
}

