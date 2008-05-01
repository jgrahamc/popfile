# ----------------------------------------------------------------------------
#
# Tests for XMLRPC.pm
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
#   Modified by Sam Schinke (sschinke@users.sourceforge.net)
#
# ----------------------------------------------------------------------------

rmtree( 'messages' );
rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
rmtree( 'corpus/CVS' );

unlink 'popfile.db';
unlink 'popfile.pid';
unlink 'stopwords';
test_assert( copy ( 'stopwords.base', 'stopwords' ) );

use POSIX ":sys_wait_h";

use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
$POPFile->{debug__} = 1;
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'POPFile/Database' => 1,
              'POPFile/Logger' => 1,
              'POPFile/MQ'     => 1,
              'Classifier/Bayes'     => 1,
#              'UI/XMLRPC'     => 1,
              'POPFile/Configuration' => 1 );

use UI::XMLRPC;
my $x = new UI::XMLRPC;
$x->loader( $POPFile );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );
#my $x = $POPFile->get_module( 'POPFile/MQ' );
$x->initialize();
$x->config_( 'enabled', 1 );
my $xport = 12000 + int( rand( 2000 ) );
$x->config_( 'port', $xport );
$POPFile->CORE_start();

my ( $pid, $handle ) = $POPFile->CORE_forker();

if ( $pid == 0 ) {
    # CHILD THAT WILL RUN THE XMLRPC SERVER

    if ( $x->start() == 1 ) {
        my $count = 50;
        while ( $x->service() && $POPFile->CORE_service( 1 ) ) {
            select( undef, undef, undef, 0.1 );
            last if ( $count-- <= 0 );
        }
        $x->stop();
    } else {
        test_assert( 0, "start failed\n" );
    }

    $x->stop();
    $POPFile->CORE_stop();

    exit(0);
} else {
    # PARENT -- test the XMLRPC server

    select( undef, undef, undef, 1 );
    use XMLRPC::Lite;

    print "Testing $xport\n";

    my $session = XMLRPC::Lite 
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('POPFile/API.get_session_key','admin', '')
    -> result;
 
    test_assert( $session ne '' );

    my $set_bucket_color = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('POPFile/API.set_bucket_color', $session, 'personal', 'somecolour')
    -> result;

    test_assert_equal( $set_bucket_color, 1 );

    select( undef, undef, undef, .2 );

    my $bucket_color = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('POPFile/API.get_bucket_color', $session, 'personal')
    -> result;

    test_assert_equal( $bucket_color, 'somecolour' );

    select( undef, undef, undef, .2 );

    my $buckets = XMLRPC::Lite
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('POPFile/API.get_buckets', $session )
    -> result;

    test_assert_equal( @$buckets[0], 'other' );
    test_assert_equal( @$buckets[1], 'personal' );
    test_assert_equal( @$buckets[2], 'spam' );

    select( undef, undef, undef, .2 );

    XMLRPC::Lite 
    -> proxy("http://127.0.0.1:" . $xport . "/RPC2")
    -> call('POPFile/API.release_session_key', $session );

    sleep(3);

    while ( waitpid( $pid, WNOHANG ) > 0 ) {
        select( undef, undef, undef, 0.1 );
    }
}

1;
