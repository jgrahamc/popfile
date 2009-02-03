# ----------------------------------------------------------------------------
#
# Tests for NNTP.pm
#
# Copyright (c) 2001-2009 John Graham-Cumming
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

use IO::Handle;
use IO::Socket;
use Digest::MD5;
use POSIX ":sys_wait_h";
use strict;


my $cr = "\015";
my $lf = "\012";

my $eol = "$cr$lf";

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
              'Proxy/NNTP'            => 1,
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

my $n = $POPFile->get_module( 'Proxy::NNTP' );
$n->forker( \&forker );
$n->pipeready( $POPFile->{pipeready__} );
$n->setchildexit( $POPFile->{childexit__} );

$n->{version_} = 'test suite';
$n->initialize();

my $port = 9000 + int(rand(1000));

$n->config_( 'port', $port );
$n->config_( 'force_fork', 0 );
$n->global_config_( 'timeout', 1 );

$n->config_( 'enabled', 0 );
test_assert_equal( $n->start(), 2 );
$n->config_( 'enabled', 1 );

$POPFile->CORE_start();

# Test dynamic UI

$mq->service();
my @messages = $rmq->read();

#shift @messages if ( $^O eq 'MSWin32' );

test_assert_equal( $#messages, 2 );

test_assert_equal( $messages[0][0], 'UIREG' );
test_assert_equal( $#{$messages[0][1]}, 3 );
test_assert_equal( $messages[0][1][0], 'configuration' );
test_assert_equal( $messages[0][1][1], 'nntp_config' );
test_assert_equal( $messages[0][1][2], 'nntp-configuration.thtml' );
test_assert_equal( ref $messages[0][1][3], 'Proxy::NNTP' );

test_assert_equal( $messages[1][0], 'UIREG' );
test_assert_equal( $#{$messages[1][1]}, 3 );
test_assert_equal( $messages[1][1][0], 'security' );
test_assert_equal( $messages[1][1][1], 'nntp_local' );
test_assert_equal( $messages[1][1][2], 'nntp-security-local.thtml' );
test_assert_equal( ref $messages[1][1][3], 'Proxy::NNTP' );

# Test configure_item

use Test::SimpleTemplate;

my $templ = new Test::SimpleTemplate;

# nothing happens for unknown configuration item names

$n->configure_item( 'foo', $templ );
my $params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 0 );

# the right things have to happen for known configuration item names

$n->configure_item( 'nntp_config', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 3 );
test_assert_equal( $templ->param( 'nntp_port'          ), $n->config_( 'port'      ) );
test_assert_equal( $templ->param( 'nntp_separator'     ), $n->config_( 'separator' ) );
test_assert_equal( $templ->param( 'nntp_force_fork_on' ), ( $n->config_( 'force_fork' ) == 1 ) );

delete $templ->{params__};

$n->configure_item( 'nntp_local', $templ );
$params = $templ->{params__};
test_assert_equal( scalar( keys( %{$params} ) ), 1 );
test_assert_equal( $templ->param( 'nntp_if_local' ), ( $n->config_( 'local' ) == 1 ) );

delete $templ->{params__};

# test changing/validating of configuration values

my $form = {};
my $language= {};
my ( $status, $error );

test_assert_equal( $n->config_( 'socks_port' ), 1080 );

$form->{nntp_socks_port} = 10080;
$language->{Configuration_SOCKSPortUpdate} = "socks port update %s";

( $status, $error ) = $n->validate_item( 'nntp_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks port update 10080" );
test_assert( !defined( $error) );
test_assert_equal( $n->config_( 'socks_port' ), 10080 );

$n->config_( 'socks_port', 1080 );

$form->{nntp_socks_port} = 'aaa';
$language->{Configuration_Error8} = "configuration error 8";

( $status, $error ) = $n->validate_item( 'nntp_socks_configuration', $templ, $language, $form );

test_assert_equal( $error, "configuration error 8" );
test_assert( !defined( $status) );
test_assert_equal( $n->config_( 'socks_port' ), 1080 );

delete $form->{nntp_socks_port};

$form->{nntp_socks_server} = 'example.com';
$language->{Configuration_SOCKSServerUpdate} = 'socks server update %s';

( $status, $error ) = $n->validate_item( 'nntp_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks server update example.com" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'socks_server' ), 'example.com' );

$form->{nntp_socks_port} = '10081';
$form->{nntp_socks_server} = 'subdomain.example.com';

( $status, $error ) = $n->validate_item( 'nntp_socks_configuration', $templ, $language, $form );

test_assert_equal( $status, "socks port update 10081\nsocks server update subdomain.example.com" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'socks_server' ), 'subdomain.example.com' );
test_assert_equal( $n->config_( 'socks_port' ), 10081 );

delete $form->{nntp_socks_port};
delete $form->{nntp_socks_server};

$n->config_( 'socks_server', '' );

test_assert_equal( $n->config_( 'port' ), $port );

$language->{Configuration_NNTPUpdate} = "nntp port update %s";
$form->{nntp_port} = $port + 1;

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $status, "nntp port update " . ( $port + 1 ) . "\n" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_('port'), $port + 1 );

$n->config_( 'port', $port );

$form->{nntp_port} = 'aaa';
$language->{Configuration_Error3} = "configuration error 3";

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3\n" );
test_assert( !defined( $status ) );
test_assert_equal( $n->config_( 'port' ), $port );

$form->{nntp_port} = 0;

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3\n" );
test_assert( !defined( $status ) );
test_assert_equal( $n->config_( 'port' ), $port );

$form->{nntp_port} = 65536;

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $error, "configuration error 3\n" );
test_assert( !defined( $status ) );
test_assert_equal( $n->config_( 'port' ), $port );

delete $form->{nntp_port};

test_assert_equal( $n->config_( 'separator' ), ':' );

$form->{nntp_separator} = '\'';
$language->{'Configuration_NNTPSepUpdate'} = "nntp separator update %s";
$language->{'Configuration_Error1'} = "configuration error 1";

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $status, "nntp separator update \'\n" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'separator' ), '\'' );

$form->{nntp_separator} = 'aaaaa';

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $error, "configuration error 1\n" );
test_assert( !defined( $status ) );
test_assert_equal( $n->config_( 'separator' ), '\'' );

delete $form->{nntp_separator};
$n->config_( 'separator', ':' );

test_assert_equal( $n->config_( 'force_fork' ), 0 );

$language->{'Configuration_NNTPForkEnabled'} = "nntp fork on";
$language->{'Configuration_NNTPForkDisabled'} = "nntp fork off";
$form->{nntp_force_fork} = 1;

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $status, "nntp fork on" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'force_fork' ), 1 );

$form->{nntp_force_fork} = 0;

( $status, $error ) = $n->validate_item( 'nntp_config', $templ, $language, $form );

test_assert_equal( $status, "nntp fork off" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'force_fork' ), 0 );

delete $form->{nntp_force_fork};
$n->config_( 'force_fork', 0 );

test_assert_equal( $n->config_( 'local' ), 1 );

$language->{'Security_ServerModeUpdateNNTP'} = "nntp is in server mode";
$language->{'Security_StealthModeUpdateNNTP'} = "nntp is in stealth mode";
$form->{serveropt_nntp} = 1; # Server mode

( $status, $error ) = $n->validate_item( 'nntp_local', $templ, $language, $form );

test_assert_equal( $status, "nntp is in server mode" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'local' ), 0 );

$form->{serveropt_nntp} = 0; # Stealth mode

( $status, $error ) = $n->validate_item( 'nntp_local', $templ, $language, $form );

test_assert_equal( $status, "nntp is in stealth mode" );
test_assert( !defined( $error ) );
test_assert_equal( $n->config_( 'local' ), 1 );

delete $form->{serveropt_nntp};
$n->config_( 'local', 1 );

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

    # CHILD THAT WILL RUN THE NNTP SERVER

    close $dserverwriter;
    close $userverreader;

    $userverwriter->autoflush(1);

    my $server = IO::Socket::INET->new( Proto     => 'tcp',
                                        LocalAddr => 'localhost',
                                        LocalPort => 8119,
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
        sleep 1;
    }

    close $server;
    $b->stop();
    $db->stop();
    exit(0);
} else {

    # This pipe is used to send signals to the child running
    # the proxy to change its state, the following commands can
    # be sent
    #
    # __QUIT      Causes the child to terminate proxy service and
    #             exit
    #
    # __HEADTOO   Causes the child to enable the toptoo option in
    #             the proxy

    pipe my $dreader, my $dwriter;
    pipe my $ureader, my $uwriter;

    my ( $pid2, $pipe ) = forker();

    if ( $pid2 == 0 ) {

        # CHILD THAT WILL RUN THE NNTP PROXY

        close $dwriter;
        close $ureader;

        $uwriter->autoflush(1);

        while ( 1 ) {
            last if !$n->service();

            if ( pipeready( $dreader ) ) {
                my $command = <$dreader>;

                if ( $command =~ /__QUIT/ ) {
                    print $uwriter "OK\n";
                    last;
                }

                if ( $command =~ /__HEADTOO/ ) {
                    $n->config_( 'headtoo', 1 );
                    print $uwriter "OK\n";
                    next;
                }

                if ( $command =~ /__SEPCHANGE (.)/ ) {
                    $n->config_( 'separator', $1 );
                    print $uwriter "OK\n";
                    next;
                }
            }
        }

        close $dreader;
        close $uwriter;
        $b->stop();
        $db->stop();
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

        my $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        wait_proxy();

        # Make sure that POPFile sends an appropriate banner

        my $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        # Try a connection to a server that does not exist

        print $client "AUTHINFO USER 127.0.0.1:8111:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result,
            "500 can't connect to 127.0.0.1:8111$eol" );

        close $client;

        select( undef, undef, undef, 5 );

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        wait_proxy();

        # Make sure that POPFile sends an appropriate banner

        my $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        # Check that we can connect to the remote NNTP server

        print $client "AUTHINFO USER 127.0.0.1:8119:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 Welcome gooduser. Password required$eol" );

        # Now send a bad password

        print $client "AUTHINFO PASS password$eol";
        $result = <$client>;
        test_assert_equal( $result, "481 Bad Password$eol" );

        # Next send GROUP before authentication

        print $client "GROUP test1.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 more authentication required for this command$eol" );

        # And then a good one

        print $client "AUTHINFO PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "281 Now logged in$eol" );

        wait_proxy();

        # Test that the catch all code works for connected servers

        print $client "JOHN$eol";
        $result = <$client>;
        test_assert_equal( $result, "500 unknown command or bad syntax$eol" );

        # HELP command

        print $client "HELP$eol";
        $result = <$client>;
        test_assert_equal( $result, "100 Help text follows$eol" );
        $result = <$client>;
        test_assert_equal( $result, "This is some help text.$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # null command (just ingnored)

        print $client " $eol";

        my $history_count = 0;
        my $count = 0;
        my $size  = 0;
        my @messages = sort glob 'TestMails/TestMailParse*.msg';
        for my $i (0..$#messages) {
            if ( $messages[$i] ne '' ) {
                $count += 1;
                $size  += ( -s $messages[$i] );
            }
        }
        my $message_count = scalar @messages;
        my $notexist = $message_count + 1;

        # Group list (LIST ACTIVE)

        print $client "LIST ACTIVE$eol";
        $result = <$client>;
        test_assert_equal( $result, "215 list of newsgroups follows$eol" );
        $result = <$client>;
        test_assert_equal( $result, ( sprintf "empty.group %010d %010d n$eol", 0, 0 ) );
        $result = <$client>;
        test_assert_equal( $result, ( sprintf "test1.group %010d %010d n$eol", 1, $message_count ) );
        $result = <$client>;
        test_assert_equal( $result, ( sprintf "test2.group %010d %010d n$eol", 1, $message_count ) );
        $result = <$client>;
        test_assert_equal( $result, ( sprintf "writable.group %010d %010d y$eol", 0, 0 ) );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # ARTICLE/HEAD/BODY/STAT before choosing GROUP

        print $client "ARTICLE 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "412 No newsgroup selected$eol" );

        print $client "HEAD 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "412 No newsgroup selected$eol" );

        print $client "BODY 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "412 No newsgroup selected$eol" );

        print $client "STAT 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "412 No newsgroup selected$eol" );

        print $client "STAT <nntp0\@test1.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 0 <nntp0\@test1.group>$eol" );

        # Group descriptions (LIST NEWSGROUPS)

        print $client "LIST NEWSGROUPS$eol";
        $result = <$client>;
        test_assert_equal( $result, "215 information follows$eol" );
        $result = <$client>;
        test_assert_equal( $result, "empty.group Empty group$eol" );
        $result = <$client>;
        test_assert_equal( $result, "test1.group Test group 1$eol" );
        $result = <$client>;
        test_assert_equal( $result, "test2.group Test group 2$eol" );
        $result = <$client>;
        test_assert_equal( $result, "writable.group Writable group$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Choose group (GROUP)

        print $client "GROUP test1.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 $message_count 1 $message_count test1.group$eol" );

        print $client "GROUP empty.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 0 0 0 empty.group$eol" );

        print $client "GROUP not.exist.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "411 No such newsgroup$eol" );

        print $client "GROUP test2.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 $message_count 1 $message_count test2.group$eol" );

        # List messages in the group (LISTGROUP)

        print $client "LISTGROUP$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 $message_count 1 $message_count test2.group list follows$eol" );
        for my $i ( 1 .. $message_count ) {
            $result = <$client>;
            test_assert_equal( $result, "$i$eol" );
        }
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "LISTGROUP empty.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 0 0 0 empty.group list follows$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "GROUP test2.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 $message_count 1 $message_count test2.group$eol" );

        # STAT command

        print $client "STAT 1$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 1 <nntp0\@test2.group>$eol" );

        print $client "STAT <nntp0\@test1.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 0 <nntp0\@test1.group>$eol" );

        print $client "STAT $notexist$eol";
        $result = <$client>;
        test_assert_equal( $result, "423 No such message $notexist$eol" );

        # NEXT/LAST commands

        print $client "LAST$eol";
        $result = <$client>;
        test_assert_equal( $result, "422 No previous article in this group$eol" );

        print $client "NEXT$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 2 <nntp1\@test2.group>$eol" );

        print $client "NEXT$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 3 <nntp2\@test2.group>$eol" );

        print $client "LAST$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 2 <nntp1\@test2.group>$eol" );

        print $client "GROUP empty.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 0 0 0 empty.group$eol" );

        print $client "NEXT$eol";
        $result = <$client>;
        test_assert_equal( $result, "420 Current article number is invalid$eol" );

        print $client "LAST$eol";
        $result = <$client>;
        test_assert_equal( $result, "420 Current article number is invalid$eol" );

        print $client "GROUP test2.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 $message_count 1 $message_count test2.group$eol" );

        # STAT with no parameters

        print $client "STAT$eol";
        $result = <$client>;
        test_assert_equal( $result, "223 1 <nntp0\@test2.group>$eol" );

        # Now get the current message

        print $client "ARTICLE$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "220 1 <nntp0\@test2.group>$eol" );
        my $cam = $messages[0];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            $result =~ s/[$cr$lf]+//g;
            $line   =~ s/[$cr$lf]+//g;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # This delay is here because Windows was having a little trouble
        # with the files created by the RETR not existing and I have a little
        # rest here while Windows wakes from its afternoon nap and writes
        # the files to disk

        my $slot_file = $h->get_slot_file( $history_count );
        wait_proxy();

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[0]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[$cr$lf]+//g;
            $ml =~ s/[$cr$lf]+//g;
            test_assert_equal( $fl, $ml );
        }
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) =
            $h->get_slot_fields( $history_count, $session );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $hdr_from, 'blank' );
        test_assert_equal( $magnet, '' );

        print $client "ARTICLE <nntp27\@not.exist.goup>$eol";
        $result = <$client>;
        test_assert_equal( $result, "430 No article with that message-id$eol" );

       # Now get a message that has an illegal embedded CRLF.CRLF

        print $client "ARTICLE <nntp27\@test2.group>$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "220 28 <nntp27\@test2.group>$eol" );
        $cam = $messages[27];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( my $line = <FILE> ) {
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            $result =~ s/[$cr$lf]+//g;
            $line   =~ s/[$cr$lf]+//g;
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

        my $slot_file = $h->get_slot_file( $history_count );
        wait_proxy();

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[27]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[$cr$lf]+//g;
            $ml =~ s/[$cr$lf]+//g;
            test_assert_equal( $fl, $ml );
        }
        # Why should the original be longer than the slot file?
        # test_assert( !eof(FILE) );
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) =
            $h->get_slot_fields( $history_count, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # Check what happens when HEAD fails

        print $client "HEAD $notexist$eol";
        $result = <$client>;
        test_assert_equal( $result, "423 No such message $notexist$eol" );

        # Check the basic HEAD command

        print $client "HEAD 5$eol";
        $result = <$client>;
        test_assert_equal( $result, "221 5 <nntp4\@test2.group>$eol" );

        test_assert( open FILE, "<$messages[4]" );
        binmode FILE;
        while ( ( my $line = <FILE> ) ) {
            last if ( $line =~ /^[$cr$lf]+$/ );
            $result = <$client>;
            test_assert( $result =~ /$cr/ );
            $result =~ s/[$cr$lf]//g;
            $line   =~ s/[$cr$lf]//g;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Check the BODY command

        print $client "BODY 5$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "222 5 <nntp4\@test2.group>$eol" );

        test_assert( open FILE, "<$messages[4]" );
        binmode FILE;
        while ( ( my $line = <FILE> ) ) {
            $line   =~ s/[$cr$lf]+//g;
            last if ( $line eq '' );
        }
        while ( ( my $line = <FILE> ) ) {
            $result = <$client>;
            test_assert( $result =~ /$cr/ );
            $result =~ s/[$cr$lf]+//g;
            $line   =~ s/[$cr$lf]+//g;
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

        my $slot_file = $h->get_slot_file( $history_count );
        wait_proxy();

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[4]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[$cr$lf]+//g;
            $ml =~ s/[$cr$lf]+//g;
            test_assert_equal( $fl, $ml );
        }
        # Why should the original be longer than the slot file?
        # test_assert( !eof(FILE) );
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) =
            $h->get_slot_fields( $history_count, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # POST command (fail)

        print $client "POST$eol";
        $result = <$client>;
        test_assert_equal( $result, "340 Input article; end with <CR-LF>.<CR-LF>$eol" );
        print $client "From: \"Test user\" <test\@example.com>$eol";
        print $client "Newsgroups: test1.group$eol";
        print $client "Subject: This post will fail$eol";
        print $client "$eol";
        print $client "This is a test article.$eol";
        print $client ".$eol";
        $result = <$client>;
        test_assert_equal( $result, "441 Posting failed$eol" );

        # POST command (success)

        print $client "POST$eol";
        $result = <$client>;
        test_assert_equal( $result, "340 Input article; end with <CR-LF>.<CR-LF>$eol" );
        print $client "From: \"Test user\" <test\@example.com>$eol";
        print $client "Newsgroups: writable.group$eol";
        print $client "Subject: This post will success$eol";
        print $client "$eol";
        print $client "This is a test article.$eol";
        print $client ".$eol";
        $result = <$client>;
        test_assert_equal( $result, "240 Article received OK$eol" );

         # Check that we echo the remote servers QUIT response

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 Bye$eol" );

        wait_proxy();

        close $client;

        # Test basic TOP capability with toptoo gets classification

        print $dwriter "__HEADTOO\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        # AUTHINFO without username

        print $client "AUTHINFO USER 127.0.0.1:8119:$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 password$eol" );

        print $client "GROUP test1.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 more authentication required for this command$eol" );

        print $client "AUTHINFO PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "281 authentication accepted$eol" );

        wait_proxy();

        print $client "GROUP test2.group$eol";
        $result = <$client>;
        test_assert_equal( $result, "211 $message_count 1 $message_count test2.group$eol" );

        # Check what happens when HEAD fails

        print $client "HEAD $notexist$eol";
        $result = <$client>;
        test_assert_equal( $result, "423 No such message $notexist$eol" );

        # HEAD (HEADTOO)

        print $client "HEAD 8$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "221 8 <nntp7\@test2.group>$eol" );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( ( my $line = <FILE> ) ) {
            last if ( $line =~ /^[$cr$lf]+$/ );
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert( $result =~ /$cr/ );
            $result =~ s/[$cr$lf]//g;
            $line   =~ s/[$cr$lf]//g;
            test_assert_equal( $result, $line, "[$result][$cam][$line]" );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        my $slot_file = $h->get_slot_file( $history_count );
        wait_proxy();

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[7]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[$cr$lf]+//g;
            $ml =~ s/[$cr$lf]+//g;
            test_assert_equal( $fl, $ml );
        }
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) =
            $h->get_slot_fields( $history_count, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # Test ARTICLE <message-id> after HEAD comes from cache

        print $client "ARTICLE <nntp7\@test2.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "220 0 <nntp7\@test2.group>$eol" );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( my $line = <FILE> ) {
            $line =~ s/[$cr$lf]+//g;
            $result = <$client>;
            $result =~ s/[$cr$lf]+//g;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Test HEAD <message-id> after HEAD comes from cache

        print $client "HEAD <nntp7\@test2.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "221 8 <nntp7\@test2.group>$eol" );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( ( my $line = <FILE> ) ) {
            last if ( $line =~ /^[$cr$lf]+$/ );
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert( $result =~ /$cr/ );
            $result =~ s/[$cr$lf]//g;
            $line   =~ s/[$cr$lf]//g;
            test_assert_equal( $result, $line, "[$result][$cam][$line]" );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Test BODY <message-id> after HEAD comes from cache

        print $client "BODY <nntp7\@test2.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "222 0 <nntp7\@test2.group>$eol" );

        $cam = $messages[7];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        # skip message header
        while ( <FILE> ) {
            last if ( /^[$cr$lf]+$/ );
        }
        # read message body
        while ( my $line = <FILE> ) {
            $line =~ s/[$cr$lf]+//g;
            $result = <$client>;
            $result =~ s/[$cr$lf]+//g;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Test ARTICLE after ARTICLE returns cached copy

        print $client "ARTICLE <nntp8\@test2.group>$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "220 9 <nntp8\@test2.group>$eol" );
        $cam = $messages[8];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert( $result =~ /$cr/ );
            $result =~ s/[$cr$lf]//g;
            $line   =~ s/[$cr$lf]//g;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        select( undef, undef, undef, 0.1 );

        my $slot_file = $h->get_slot_file( $history_count );
        wait_proxy();

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[8]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[$cr$lf]+//g;
            $ml =~ s/[$cr$lf]+//g;
            test_assert_equal( $fl, $ml );
        }
        test_assert( eof(FILE) );
        test_assert( eof(HIST) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) =
            $h->get_slot_fields( $history_count, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        print $client "ARTICLE <nntp8\@test2.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "220 0 <nntp8\@test2.group>$eol" );

        $cam = $messages[8];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( my $line = <FILE> ) {
            $line =~ s/[$cr$lf]+//g;
            $result = <$client>;
            $result =~ s/[$cr$lf]+//g;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "ARTICLE <nntp8\@test2.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "220 0 <nntp8\@test2.group>$eol" );

        $cam = $messages[8];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( my $line = <FILE> ) {
            $line =~ s/[$cr$lf]+//g;
            $result = <$client>;
            $result =~ s/[$cr$lf]+//g;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        # Test HEADTOO and caching with illegal CRLF.CRLF in message

        print $client "HEAD 28$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "221 28 <nntp27\@test2.group>$eol" );

        $cam = $messages[27];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( ( my $line = <FILE> ) ) {
            last if ( $line =~ /^[$cr$lf]+$/ );
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert( $result =~ /$cr/ );
            $result =~ s/$cr//;
            $line =~ s/$cr//;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        my $slot_file = $h->get_slot_file( $history_count );
        wait_proxy();

        test_assert( -e $slot_file );

        test_assert( open FILE, "<$messages[27]" );
        binmode FILE;
        test_assert( open HIST, "<$slot_file" );
        binmode HIST;
        while ( ( my $fl = <FILE> ) && ( my $ml = <HIST> ) ) {
            $fl =~ s/[$cr$lf]+//g;
            $ml =~ s/[$cr$lf]+//g;
            test_assert_equal( $fl, $ml );
        }
        test_assert( eof(FILE) );
        close FILE;
        close HIST;

        my ( $id, $hdr_from, $hdr_to, $hdr_cc, $hdr_subject, $hdr_date, $hash, $inserted, $bucket, $usedtobe, $bucketid, $magnet ) =
            $h->get_slot_fields( $history_count, $session );
        test_assert_equal( $bucket, 'spam' );
        test_assert_equal( $usedtobe, 0 );
        test_assert_equal( $magnet, '' );

        # Test ARTICLE after HEAD comes from cache with illegal CRLF.CRLF

        print $client "ARTICLE <nntp27\@test2.group>$eol";
        $result = <$client>;
        test_assert_equal( $result, "220 0 <nntp27\@test2.group>$eol" );

        $cam = $messages[27];
        $cam =~ s/msg$/cam/;
        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( my $line = <FILE> ) {
            $line =~ s/[$cr$lf]+//g;
            $result = <$client>;
            $result =~ s/[$cr$lf]+//g;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );
        $result = <$client>;
        test_assert_equal( $result, ".$eol" ); # TODO

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 Bye$eol" );

        wait_proxy();

        close $client;

        # Check insertion of the X-POPFile-Timeout headers

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "AUTHINFO USER 127.0.0.1:8119:goslow$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 Welcome goslow. Password required$eol" );

        print $client "AUTHINFO PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "281 Now logged in$eol" );

        wait_proxy();

        # ARTICLE before selecting group

        print $client "ARTICLE <nntp0\@test2.group>$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "220 1 <nntp0\@test2.group>$eol" );
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
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            $result =~ s/[$cr$lf]+//g;
            $line   =~ s/[$cr$lf]+//g;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 Bye$eol" );

        wait_proxy();

        close $client;

        # Test slow LF's on a CRLF

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "AUTHINFO USER 127.0.0.1:8119:slowlf$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 Welcome slowlf. Password required$eol" );

        print $client "AUTHINFO PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "281 Now logged in$eol" );

        wait_proxy();

        print $client "ARTICLE <nntp0\@test2.group>$eol";
        $history_count++;
        $result = <$client>;
        test_assert_equal( $result, "220 1 <nntp0\@test2.group>$eol" );
        $cam = $messages[0];
        $cam =~ s/msg$/cam/;

        test_assert( open FILE, "<$cam" );
        binmode FILE;
        while ( <FILE> ) {
            my $line = $_;
            $result = <$client>;
            $result =~ s/view=$history_count/view=popfile0=0.msg/;
            $result =~ s/[$cr$lf]+//g;
            $line   =~ s/[$cr$lf]+//g;
            test_assert_equal( $result, $line );
        }
        close FILE;

        $result = <$client>;
        test_assert_equal( $result, ".$eol" );

        wait_proxy();

        close $client;

        # Test QUIT straight after connect

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 goodbye$eol" );

        wait_proxy();

        close $client;

        # Test odd command straight after connect gives error

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "FOOF$eol";
        $result = <$client>;
        test_assert_equal( $result, "480 Authorization required for this command$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 goodbye$eol" );

        wait_proxy();

        close $client;

        # Make sure that changing the separator doesn't break
        # anything

        print $dwriter "__SEPCHANGE Q\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "AUTHINFO USER 127.0.0.1:8119Qgooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 Welcome gooduser. Password required$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 Bye$eol" );

        wait_proxy();

        close $client;

        print $dwriter "__SEPCHANGE \$\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "AUTHINFO USER 127.0.0.1:8119\$gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 Welcome gooduser. Password required$eol" );

        print $client "QUIT$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 Bye$eol" );

        wait_proxy();

        close $client;

        # Send the remote server a special message that makes it die
        print $dwriter "__SEPCHANGE :\n";
        my $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );

        $client = connect_proxy();

        test_assert( defined( $client ) );
        test_assert( $client->connected );

        $result = <$client>;
        test_assert_equal( $result,
            "201 NNTP POPFile (test suite) server ready$eol" );

        print $client "AUTHINFO USER 127.0.0.1:8119:gooduser$eol";
        $result = <$client>;
        test_assert_equal( $result, "381 Welcome gooduser. Password required$eol" );

        print $client "AUTHINFO PASS secret$eol";
        $result = <$client>;
        test_assert_equal( $result, "281 Now logged in$eol" );

        wait_proxy();

        print $client "__QUIT__$eol";
        $result = <$client>;
        test_assert_equal( $result, "205 Bye$eol" );

        close $client;

        # Tell the proxy to die

        print $dwriter "__QUIT\n";
        $line = <$ureader>;
        test_assert_equal( $line, "OK\n" );
        close $dwriter;
        close $ureader;

        $b->release_session_key( $session );

        $n->stop();
        $POPFile->CORE_stop();

        while ( waitpid( -1, &WNOHANG ) > 0 ) {
            sleep 1;
        }

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
    my $goslow = 0;
    my $hang   = 0;
    my $slowlf = 0;
    my $group  = '';
    my $current_message = '';
    my %groups = ( 'test1.group'    => scalar @messages,
                   'test2.group'    => scalar @messages,
                   'empty.group'    => 0,
                   'writable.group' => 0, );
    my %descriptions = ( 'test1.group'    => 'Test group 1',
                         'test2.group'    => 'Test group 2',
                         'empty.group'    => 'Empty group',
                         'writable.group' => 'Writable group' );

    my $time = time;

    print $client "201 Ready$eol";

    while  ( <$client> ) {
        my $command;

        $command = $_;
        $command =~ s/($cr|$lf)//g;

        if ( $command =~ /^AUTHINFO USER (.*)/i ) {
            if ( $1 =~ /(gooduser|goslow|hang|slowlf)/ ) {
                 print $client "381 Welcome $1. Password required$eol";
                 $goslow = ( $1 =~ /goslow/ );
                 $hang   = ( $1 =~ /hang/   );
                 $slowlf = ( $1 =~ /slowlf/ );
            } else {
                 print $client "481 Unknown user $1$eol";
            }
            next;
        }

        if ( $command =~ /^AUTHINFO PASS (.*)/i ) {
            if ( $1 =~ /secret/ ) {
                 print $client "281 Now logged in$eol";
            } else {
                 print $client "481 Bad Password$eol";
            }
            next;
        }

        if ( $command =~ /^QUIT/i ) {
            $group = '';
            print $client "205 Bye$eol";
            last;
        }

        if ( $command =~ /__QUIT__/i ) {
            print $client "205 Bye$eol";
            return 0;
        }

        if ( $command =~ /^HELP/i ) {
            print $client "100 Help text follows$eol";
            print $client "This is some help text.$eol";
            print $client ".$eol";
            next;
        }

        if ( $command =~ /^LIST ACTIVE ?(.*)?/i ) {
            # TODO : searching groups is not supported yet
            print $client "215 list of newsgroups follows$eol";
            foreach my $g ( sort keys %groups ) {
                printf $client "%s %010d %010d %s$eol",
                               $g,
                               ( $groups{$g} > 0 ? 1 : 0 ),
                               $groups{$g},
                               ( $g =~ /writable/ ? 'y' : 'n' );
            }
            print $client ".$eol";
            next;
        }

        if ( $command =~ /^LIST NEWSGROUPS/i ) {
            print $client "215 information follows$eol";
            foreach my $g ( sort keys %groups ) {
                print $client "$g $descriptions{$g}$eol";
            }
            print $client ".$eol";
            next;
        }

        if ( $command =~ /^GROUP (.*)/i ) {
            my $parameter = $1;
            if ( exists $groups{$parameter} ) {
                $group = $parameter;
                if ( $groups{$group} > 0 ) {
                    $current_message = 0;
                    print $client "211 $groups{$group} 1 $groups{$group} $group$eol";
                } else {
                    # empty group
                    $current_message = '';
                    print $client "211 0 0 0 $group$eol";
                }
            } else {
                # group not found
                print $client "411 No such newsgroup$eol";
            }
            next;
        }

        if ( $command =~ /^LISTGROUP ?([^ ]*)?/i ) {
            # TODO : range is not supported yet
            my $parameter = $1;
            $parameter = $group if ( $parameter eq '' );
            if ( exists $groups{$parameter} ) {
                if ( $groups{$parameter} > 0 ) {
                    print $client "211 $groups{$parameter} 1 $groups{$parameter} $parameter list follows$eol";
                    for my $i ( 1 .. $groups{$parameter} ) {
                        print $client "$i$eol";
                    }
                    print $client ".$eol";
                } else {
                    print $client "211 0 0 0 $parameter list follows$eol";
                    print $client ".$eol";
                }
            } else {
                if ( $group eq '' ) {
                    print $client "412 No newsgroup selected$eol";
                } else {
                    print $client "411 No such newsgroup$eol";
                }
            }
            next;
        }

        if ( $command =~ /^ARTICLE ?(?=(\d+)|(.*))?/i ) {
            my ( $err, $index, $g ) = get_group_and_index( $1, $2, $group, $current_message, {%groups} );
            if ( $err ne '' ) {
                print $client $err;
                next;
            }

            if ( ( $groups{$g} >= $index ) &&
                 defined( $messages[$index] ) && ( $messages[$index] ne '' ) ) {
                 print $client "220 " . ( $index + 1 ) . " <nntp$index\@$g>$eol";

                 my $slowlftemp = $slowlf;

                 open FILE, "<$messages[$index]";
                 binmode FILE;
                 while ( <FILE> ) {
                     s/[$cr$lf]+//g;

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
                print $client "423 No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /^HEAD ?(?=(\d+)|(.*))?/i ) {
            my ( $err, $index, $g ) = get_group_and_index( $1, $2, $group, $current_message, {%groups} );
            if ( $err ne '' ) {
                print $client $err;
                next;
            }

            if ( ( $groups{$g} >= $index ) && ( $messages[$index] ne '' ) ) {
                 print $client "221 " . ( $index + 1 ) . " <nntp$index\@$g>$eol";

                 open FILE, "<$messages[$index]";
                 binmode FILE;
                 while ( <FILE> ) {
                     last if ( /^[$cr$lf]+$/ );
                     s/[$cr$lf]+//g;
                     print $client "$_$eol";
                 }
                 close FILE;

                 print $client ".$eol";

            } else {
                print $client "423 No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /^BODY ?(?=(\d+)|(.*))?/i ) {
            my ( $err, $index, $g ) = get_group_and_index( $1, $2, $group, $current_message, {%groups} );
            if ( $err ne '' ) {
                print $client $err;
                next;
            }

            if ( ( $groups{$g} >= $index ) && ( $messages[$index] ne '' ) ) {
                 print $client "222 " . ( $index + 1 ) . " <nntp$index\@$g>$eol";

                 open FILE, "<$messages[$index]";
                 binmode FILE;
                 # skip message header
                 while ( <FILE> ) {
                     last if ( /^[$cr$lf]+$/ );
                 }
                 # return message body
                 while ( <FILE> ) {
                     my $line = $_;
                     $line =~ s/[$cr$lf]+//g;
                     print $client "$line$eol";
                 }
                 close FILE;

                 print $client ".$eol";

            } else {
                print $client "423 No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /^STAT ?(?=(\d+)|(.*))?/i ) {
            my ( $err, $index, $g ) = get_group_and_index( $1, $2, $group, $current_message, {%groups} );
            if ( $err ne '' ) {
                print $client $err;
                next;
            }

            if ( ( $groups{$g} > $index ) && defined( $messages[$index] ) ) {
                if ( $g eq $group ) {
                    print $client "223 " . ( $index + 1 ) . " <nntp$index\@$g>$eol";
                    $current_message = $index;
                } else {
                    print $client "223 0 <nntp$index\@$g>$eol";
                }
            } else {
                print $client "423 No such message $1$eol";
            }
            next;
        }

        if ( $command =~ /^LAST/i ) {
            if ( $group eq '' ) {
                print $client "412 No newsgroup selected$eol";
            } else {
                if ( $current_message eq '' ) {
                    print $client "420 Current article number is invalid$eol";
                } elsif ( $current_message <= 0 ) {
                    print $client "422 No previous article in this group$eol";
                } else {
                    $current_message--;
                    print $client "223 " . ( $current_message + 1 ) . " <nntp$current_message\@$group>$eol";
                }
            }
            next;
        }

        if ( $command =~ /^NEXT/i ) {
            if ( $group eq '' ) {
                print $client "412 No newsgroup selected$eol";
            } else {
                if ( $current_message eq '' ) {
                    print $client "420 Current article number is invalid$eol";
                } elsif ( $current_message >= $groups{$group} - 1 ) {
                    print $client "422 No next article in this group$eol";
                } else {
                    $current_message++;
                    print $client "223 " . ( $current_message + 1 ) . " <nntp$current_message\@$group>$eol";
                }
            }
            next;
        }

        if ( $command =~ /^POST/i ) {
            print $client "340 Input article; end with <CR-LF>.<CR-LF>$eol";
            my $g;
            select( undef, undef, undef, 0.1 );
            while ( 1 ) {
                my $line = <$client>;
                $line =~ s/[$cr$lf]+//g;
                last if $line eq '.';
                if ( $line =~ /^Newsgroups: (.+)/ ) {
                    $g = $1;
                }
            }
            if ( exists $groups{$g} && $g =~ /writable/ ) {
                print $client "240 Article received OK$eol";
            } else {
                print $client "441 Posting failed$eol";
            }
            next;
        }

        if ( $command =~ /^[ \t]*$/i ) {
            next;
        }

        print $client "500 unknown command or bad syntax$eol";
    }

    return 1;
}

sub get_group_and_index
{
    my ( $index, $message_id, $group, $current_message, $groups ) = @_;

    my $g;
    if ( $message_id ) {
        # message_id is specified
        $message_id =~ m/^<nntp(\d+)\@([^>]*)/;
        $index = $1;
        $g = $2;
        if ( !exists $$groups{$g} ) {
            return "430 No article with that message-id$eol";
        }
    } else {
        # message number is specified
        if ( $group eq '' ) {
            return "412 No newsgroup selected$eol";
        }
        $g = $group;
        if ( !defined($index) ) {
            $index = $current_message;
        } else {
            $index--;
        }
    }

    return ( '', $index, $g );
}


sub forker
{
    pipe my $reader, my $writer;
    $l->log_( 2, "Created pipe pair $reader and $writer" );
    $b->prefork();
    $mq->prefork();
    $h->prefork();
    $db->prefork();
    $n->prefork();
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
    $n->postfork( $pid, $reader );
    close $writer;
    return ($pid, $reader);
}

1;
