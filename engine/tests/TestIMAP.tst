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

$SIG{CHLD} = 'IGNORE';

rmtree( 'messages' );
rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
rmtree( 'corpus/CVS' );

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
    my $debug_server = ''; #'debug';
    system "perl IMAP_test_server.pl $debug_server";
    exit 0;
}
# parent: runs the tests:
else {
    # First, start POPFile.

    use POPFile::Loader;
    my $POPFile = POPFile::Loader->new();
    $POPFile->CORE_loader_init();
    $POPFile->CORE_signals();

    my %valid = ( 'POPFile/Database' => 1,
                  'POPFile/Logger' => 1,
                  'POPFile/MQ'     => 1,
                  'POPFile/History'     => 1,
                  'Classifier/Bayes'     => 1,
                  'Classifier/WordMangle'     => 1,
                  'POPFile/Configuration' => 1,
                  'Services/IMAP' => 1 );

    $POPFile->CORE_load( 0, \%valid );
    $POPFile->CORE_initialize();
    $POPFile->CORE_config( 1 );
    my $im = $POPFile->get_module( 'Services/IMAP' );
    $im->module_config_( 'enabled', 1 );

    $POPFile->CORE_start();


    my $b = $POPFile->get_module( 'Classifier/Bayes' );
    my $h = $POPFile->get_module( 'POPFile/History' );
    my $l = $POPFile->get_module( 'POPFile/Logger' );
    my $mq = $POPFile->get_module( 'POPFile/MQ' );

    $im->user_module_config_( 1, 'html', 'language', 'English' );
    $im->module_config_( 'html', 'port', '8080' );

    my $session = $b->get_session_key( 'admin', '' );

    $l->module_config_( 'level', 2 );
    $l->service();

    # Configure the IMAP module so it will
    # talk to the server.

    $im->user_config_( 1, 'expunge', 1 );
    $im->user_config_( 1, 'hostname', '127.0.0.1' );

    $im->user_config_( 1, 'password', 'password' );
    $im->user_config_( 1, 'port', '1143' );
    $im->user_config_( 1, 'update_interval', 10 );
    $im->user_config_( 1, 'watched_folders', '' );

    $im->{last_update__} = 0;
    $im->watched_folders__( 'INBOX' );
    $im->folder_for_bucket__( 'spam', 'spam' );
    $im->folder_for_bucket__( 'personal', 'personal' );
    $im->folder_for_bucket__( 'other', 'other' );
    $im->folder_for_bucket__( 'unclassified', 'unclassified' );

    test_assert( $im->start() );

    $im->user_config_( 1, 'login', 'someone' );
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

    $im->user_config_( 1, 'login', 'new_INBOX_003' );
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

   $im->user_config_( 1, 'login', 'dropConnection3' );
    $im->service();

    # close the server process by logging in as user "shutdown"
    $im->user_config_( 1, 'login', 'shutdown' );
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

