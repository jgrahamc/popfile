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
#   Originally created by Manni Heumann (mannih2001@users.sourceforge.net)
#
# ---------------------------------------------------------------------------------------------


use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use POPFile::History;
use Services::IMAP;
use Classifier::Bayes;
use Classifier::WordMangle;

$SIG{CHLD} = 'IGNORE';

rmtree( 'messages' );
rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
test_assert( rmtree( 'corpus/CVS' ) > 0 );

unlink 'popfile.db';
unlink 'stopwords';
test_assert( copy ( 'stopwords.base', 'stopwords' ) );

mkdir 'messages';

# This test will fork itself. The child will run
# the test server, the parent will run the tests.

my $pid = fork();
die "Cannot fork: $!" unless defined( $pid );

# child: runs the server
if ( $pid == 0 ) {
    system 'perl IMAP_test_server.pl';
    exit 0;
}
# parent: runs the tests:
else {
    # First, start POPFile.

    my $c = new POPFile::Configuration;
    my $mq = new POPFile::MQ;
    my $l = new POPFile::Logger;
    my $b = new Classifier::Bayes;
    my $w = new Classifier::WordMangle;
    my $h = new POPFile::History;
    my $im = new Services::IMAP;

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

    $h->configuration( $c );
    $h->mq( $mq );
    $h->logger( $l );

    $b->history( $h );
    $h->classifier( $b );

    $h->initialize();

    $b->module_config_( 'html', 'language', 'English' );
    $b->module_config_( 'html', 'port', '8080' );
    
    $b->{parser__}->mangle( $w );
    $b->initialize();

    test_assert( $b->start() );
    test_assert( $h->start() );

    my $session = $b->get_session_key( 'admin', '' );

    #$l->config_( 'level', 2 );
    $l->service();

    # Configure the IMAP module so it will
    # talk to the server.

    $im->configuration( $c );
    $im->mq( $mq );
    $im->logger( $l );
    $im->classifier( $b );
    $im->history ( $h );
    $im->initialize();
    $im->config_( 'enabled', 1 );
    $im->config_( 'expunge', 1 );
    $im->config_( 'hostname', '127.0.0.1' );

    $im->config_( 'password', 'password' );
    $im->config_( 'port', '1143' );
    $im->config_( 'update_interval', 10 );
    $im->config_( 'watched_folders', '' );

    $im->{last_update__} = 0;
    $im->watched_folders__( 'INBOX' );
    $im->folder_for_bucket__( 'spam', 'spam' );
    $im->folder_for_bucket__( 'personal', 'personal' );
    $im->folder_for_bucket__( 'other', 'other' );
    $im->folder_for_bucket__( 'unclassified', 'unclassified' );

    test_assert( $im->start() );

    $im->config_( 'login', 'someone' );
    $im->service();

    # Did we get the UIDVALIDITY values correctly?
    test_assert_equal( $im->uid_validity__( 'INBOX' ), 1 );
    test_assert_equal( $im->uid_validity__( 'personal' ), 1 );
    test_assert_equal( $im->uid_validity__( 'spam' ), 1 );
    test_assert_equal( $im->uid_validity__( 'other' ), 1 );

    # Did we note the correct UIDNEXT values?
    test_assert_equal( $im->uid_next__( 'INBOX' ), 1 );
    test_assert_equal( $im->uid_next__( 'personal' ), 1 );
    test_assert_equal( $im->uid_next__( 'spam' ), 1 );
    test_assert_equal( $im->uid_next__( 'other' ), 1 );

    $im->disconnect_folders__();

    # Let the INBOX have one new message, make sure it is classified correctly
    # and moved to the according folder.
    
    $im->config_( 'login', 'new_INBOX_003' );
    $im->{last_update__} = 0;
    $im->service();
    $mq->service();
    $h->service();
    
    # The message must have ended up as spam and must have been
    # moved to the spam folder
    
    test_assert( -e 'imap.spool/spam/1' );
    
    # This is a good opportunity to test reclassify-on-move:
    # we move the message from the spam folder to the
    # personal folder. The IMAP module should see this and
    # reclassify the message to that bucket. We test whether 
    # history returns the changed classification and if
    # bayes comes up with the same classification
    
    # move to folder presonal
    copy 'imap.spool/spam/1', 'imap.spool/personal/1';
    unlink 'imap.spool/spam/1';
    
    # let the IMAP module have a look
    $im->{last_update__} = 0;
    $im->service();
    $mq->service();
    $h->service();
    
    # check classification stored in history
    test_assert_equal( ($h->get_slot_fields( 1 ))[8], 'personal' );
    
    # check that a fresh classification confirms the reclassification
    test_assert_equal( $b->classify( $session, 'TestMailParse003.msg' ), 'personal' );
    
    $im->disconnect_folders__();
    
    # test magnet match
    
    
    # Make the server drop the connection and make sure we don't crash
    
    $im->config_( 'login', 'dropConnection3' );
    $im->service();

    # close the server process by logging in as user "shutdown"
    $im->config_( 'login', 'shutdown' );
    $im->{last_update__} = 0;
    $im->service();

    foreach ( $b->get_buckets( $session ) ) { print "$_\n"; }

    $mq->stop();
    $h->stop();
    $im->stop();
    $b->stop();
    
    rmtree( 'imap.spool' );
}

1;

