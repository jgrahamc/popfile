# ----------------------------------------------------------------------------
#
# Tests for Bayes.pm
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
# ----------------------------------------------------------------------------


use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'POPFile/Database'       => 1,
              'POPFile/Logger'         => 1,
              'POPFile/MQ'             => 1,
              'POPFile/History'        => 1,
              'Classifier/Bayes'       => 1,
              'Classifier/WordMangle'  => 1,
              'Proxy/POP3'             => 1,
              'POPFile/Configuration'  => 1 );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );

my $b = $POPFile->get_module( 'Classifier/Bayes' );
my $h = $POPFile->get_module( 'POPFile/History'  );
my $l = $POPFile->get_module( 'POPFile/Logger'   );

$l->config_( 'level', 1 );
$b->module_config_( 'pop3', 'port', 9110 );

$POPFile->CORE_start();

# Test the unclassified_probability parameter

test_assert_equal( $b->user_config_( 1, 'unclassified_weight' ), 100 );

$b->user_config_( 1, 'unclassified_weight', 9 );
#test_assert( $b->start() );
test_assert_equal( $b->user_config_( 1, 'unclassified_weight' ),   9 );

$b->user_config_( 1, 'unclassified_weight', 5 );
#test_assert( $b->start() );
test_assert_equal( $b->user_config_( 1, 'unclassified_weight' ),   5 );

# test the API functions

# Test getting and releasing a session key

my $session;
$session = $b->get_session_key( 'baduser', 'badpassword' );
test_assert( !defined( $session ) );
$session = $b->get_session_key( 'admin',   'badpassword' );
test_assert( !defined( $session ) );

$session = $b->get_session_key( 'admin',   ''            );
test_assert(  defined( $session ) );
test_assert( $session ne '' );
$b->release_session_key( $session );
$session = $b->get_session_key( 'admin',   ''            );
test_assert( $session ne '' );

# Test for validating session

test_assert(  defined($b->valid_session_key__( $session )) );
test_assert( !defined($b->valid_session_key__(       -1 )) );

# Test for is_admin_session

test_assert( $b->is_admin_session( $session ) );
test_assert( !defined($b->is_admin_session( -1 )) );

# Test for getting and setting the session key from an associated
# account

# create_user

my ( $success,  $password  ) = $b->create_user( $session, 'testuser'  );
test_assert_equal( $success, 0 );
test_assert( $password ne '' );

my ( $success2, $password2 ) = $b->create_user( $session, 'testuser2' );
test_assert_equal( $success2, 0 );
test_assert( $password2 ne '' );

my ( $success3, $password3 ) = $b->create_user( $session, 'testuser'  );
test_assert_equal( $success3, 1 );
test_assert( !defined( $password3 ) );

# get_user_list

my @users = sort values %{$b->get_user_list( $session )};

test_assert( $#users == 2 );
test_assert( $users[0] eq 'admin'     );
test_assert( $users[1] eq 'testuser'  );
test_assert( $users[2] eq 'testuser2' );

# remove_user

test_assert( $b->remove_user( $session, 'testuser3' ) == 1 );
test_assert( $b->remove_user( $session, 'testuser2' ) == 0 );

@users = sort values %{$b->get_user_list( $session )};

test_assert( $#users == 1 );
test_assert( $users[0] eq 'admin'    );
test_assert( $users[1] eq 'testuser' );

$b->global_config_( 'single_user', 1 );

# get_session_key_from_token

my $session2 = $b->get_session_key_from_token( $session, 'smtp', 'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );
$session2    = $b->get_session_key_from_token( $session, 'nntp', 'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );
$session2    = $b->get_session_key_from_token( $session, 'pop',  'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );
$session2    = $b->get_session_key_from_token( $session, 'pop3', 'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );

# Multi user mode

$b->global_config_( 'single_user', 0 );

$session2 = $b->get_session_key_from_token( $session, 'smtp', 'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );
$session2 = $b->get_session_key_from_token( $session, 'nntp', 'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );
$session2 = $b->get_session_key_from_token( $session, 'pop',  'token' );
test_assert( $b->is_admin_session( $session2 ) );
$b->release_session_key( $session2 );
$session2 = $b->get_session_key_from_token( $session, 'pop3', 'token' );
test_assert( !defined( $session2 ) );

my $id2 = $b->get_user_id( $session, 'testuser2' );
test_assert( !defined( $id2 ) );
my $id1 = $b->get_user_id( $session, 'testuser'  );
test_assert(  defined( $id1 ) );

test_assert( $b->add_account( $session, $id1, 'pop3', 'foo:bar' ) ==  1 );
test_assert( $b->add_account( $session, $id1, 'pop3', 'foo:bar' ) == -1 );

my $session1 = $b->get_session_key_from_token( $session, 'pop3', 'fooz:bar' );
test_assert( !defined( $session1 ) );
$session1    = $b->get_session_key_from_token( $session, 'pop3', 'foo:bar'  );
test_assert(  defined( $session1 ) );
$b->release_session_key( $session1 );

# transparent proxy

$session1 = $b->get_session_key_from_token( $session, 'pop3', 'example.com:testuser' );
test_assert( !defined( $session1 ) );

$b->module_config_( 'pop3', 'secure_server', 'example.com' );
$b->module_config_( 'pop3', 'secure_port', '110' );

$session1 = $b->get_session_key_from_token( $session, 'pop3', 'example.com:testuser' );
test_assert(  defined( $session1 ) );
$b->release_session_key( $session1 );

$session1 = $b->get_session_key_from_token( $session, 'pop3', 'fooz:bar' );
test_assert( !defined( $session1 ) );

$session1 = $b->get_session_key_from_token( $session, 'pop3', 'foo:bar'  );
test_assert(  defined( $session1 ) );
$b->release_session_key( $session1 );

$b->module_config_( 'pop3', 'secure_server', '' );

# get_user_parameter_list

my @parameters = sort $b->get_user_parameter_list( $session );
test_assert_equal( $#parameters, 35 );
test_assert_equal( join( ' ', @parameters ), 'GLOBAL_can_admin GLOBAL_private_key GLOBAL_public_key bayes_subject_mod_left bayes_subject_mod_right bayes_unclassified_weight bayes_xpl_angle history_history_days html_column_characters html_columns html_date_format html_language html_last_reset html_last_update_check html_page_size html_send_stats html_session_dividers html_show_bucket_help html_show_configbars html_show_training_help html_skin html_test_language html_update_check html_wordtable_format imap_bucket_folder_mappings imap_expunge imap_hostname imap_login imap_password imap_port imap_training_mode imap_uidnexts imap_uidvalidities imap_update_interval imap_use_ssl imap_watched_folders' );

test_assert(  $b->get_user_parameter( $session,  'GLOBAL_can_admin' ) );
test_assert( !$b->get_user_parameter( $session1, 'GLOBAL_can_admin' ) );

my ( $val, $def ) = $b->get_user_parameter_from_id( 1, 'GLOBAL_can_admin' );
test_assert_equal( $val, 1 );
test_assert_equal( $def, 0 );

( $val, $def ) = $b->get_user_parameter_from_id( $id1, 'GLOBAL_can_admin' );
test_assert_equal( $val, 0 );
test_assert_equal( $def, 1 );
$b->set_user_parameter_from_id( $id1, 'GLOBAL_can_admin', 1 );

# Test for removing admin user

test_assert_equal( $b->remove_user( $session, 'testuser' ), 2 );

( $val, $def ) = $b->get_user_parameter_from_id( $id1, 'GLOBAL_can_admin' );
test_assert_equal( $val, 1 );
test_assert_equal( $def, 0 );

$b->set_user_parameter_from_id( $id1, 'GLOBAL_can_admin', 0 );
( $val, $def ) = $b->get_user_parameter_from_id( $id1, 'GLOBAL_can_admin' );
test_assert_equal( $val, 0 );
test_assert_equal( $def, 1 );

# validate_password and set_password

test_assert_equal( $b->validate_password( $session1, '1234'    ), 0 );
test_assert_equal( $b->validate_password( $session1, $password ), 1 );
test_assert_equal( $b->validate_password( $session,  '1234'    ), 0 );
test_assert_equal( $b->validate_password( $session,  ''        ), 1 );

test_assert_equal( $b->set_password( $session1, ''    ), 1 );
test_assert_equal( $b->validate_password( $session1, '1234'    ), 0 );
test_assert_equal( $b->validate_password( $session1, ''        ), 1 );

test_assert_equal( $b->set_password( $session, '1234' ), 1 );
test_assert_equal( $b->validate_password( $session,  '1234'    ), 1 );
test_assert_equal( $b->validate_password( $session,  ''        ), 0 );

test_assert_equal( $b->set_password( $session, '' ), 1 );

$b->release_session_key( $session1 );
$session1 = $b->get_session_key( 'testuser', '' );
test_assert( defined($session1) );

# Test for executing admin only subroutines from non admin user

test_assert( !$b->is_admin_session( $session1 ) );

test_assert( !defined($b->create_user( $session1, 'testuser3' )) );
test_assert( !defined($b->remove_user( $session1, 'testuser'  )) );

test_assert( !defined($b->get_user_list( $session1 )) );
test_assert( !defined($b->get_user_id( $session1, 'testuser' )) );

test_assert( !defined($b->get_accounts( $session1, $id1 )) );
test_assert_equal( $b->add_account(    $session1, $id1, 'pop3', 'foo:bar2' ), 0 );
test_assert_equal( $b->remove_account( $session1, $id1, 'pop3', 'foo:bar'  ), 0 );

test_assert( !defined($b->get_session_key_from_token( $session1, 'smtp', 'token' )) );

test_assert( !defined($b->get_user_parameter_list( $session1 )) );

test_assert( !defined($b->initialize_users_password( $session1, 'testuser4' )) );
test_assert( !defined($b->change_users_password( $session1, 'testuser4', 'password4' )) );

# get_user_id_from_session

test_assert_equal( $b->get_user_id_from_session( $session  ),    1 );
test_assert_equal( $b->get_user_id_from_session( $session1 ), $id1 );
test_assert( !defined($b->get_user_id_from_session( -1 )) );

# get_user_name_from_session_id

test_assert_equal( $b->get_user_name_from_session( $session  ), 'admin'    );
test_assert_equal( $b->get_user_name_from_session( $session1 ), 'testuser' );
test_assert( !defined($b->get_user_name_from_session( -1 )) );

# get_current_sessions

$POPFile->CORE_service(1);

my $active_sessions = $b->get_current_sessions( $session );
test_assert( defined($active_sessions) );
test_assert_equal( $#{$active_sessions}, 1 );

foreach my $active_session ( @{$active_sessions} ) {
    if ( $active_session->{userid} eq 1 ) {
        test_assert_equal( $active_session->{session}, $session  );
    } elsif ( $active_session->{userid} eq $id1 ) {
        test_assert_equal( $active_session->{session}, $session1 );
    } else {
        test_assert( 0 );
    }
    test_assert( defined($active_session->{lastused}) );
}

# timeout test

$session2 = $b->get_session_key_from_token( $session, 'smtp', 'token' );

$active_sessions = $b->get_current_sessions( $session );
test_assert_equal( $#{$active_sessions}, 2 );

$b->{api_sessions__}{$session2}{lastused} = 0; # expired
$POPFile->CORE_service(1);
$POPFile->CORE_service(1);

$active_sessions = $b->get_current_sessions( $session );
test_assert_equal( $#{$active_sessions}, 1 );

# create_user with cloning admin
# the magnets and corpus are not copied

my ( $success4, $password4 ) = $b->create_user( $session, 'testuser4', 'admin' );
test_assert_equal( $success4, 0 );
test_assert( defined( $password4 ) );
test_assert( $password4 ne '' );

my $id4 = $b->get_user_id( $session, 'testuser4' );
test_assert( defined( $id4 ) );

my $session4 = $b->get_session_key( 'testuser4', $password4 );

# check if parameters are copied

@parameters = sort $b->get_user_parameter_list ( $session );
foreach my $parameter (@parameters) {
    next if ( $parameter eq 'GLOBAL_can_admin' );

    my ( $val1, $def1 ) = $b->get_user_parameter_from_id(    1, $parameter );
    my ( $val4, $def4 ) = $b->get_user_parameter_from_id( $id4, $parameter );

    test_assert_equal( $val1, $val4, $parameter );
    test_assert_equal( $def1, $def4, $parameter );
}

# check if buckets and their parameters are copied

my @buckets1 = sort $b->get_all_buckets( $session  );
my @buckets4 = sort $b->get_all_buckets( $session4 );
for my $i (0..$#buckets1) {
    test_assert_equal( $buckets1[$i], $buckets4[$i] );

    my $bucket = $buckets1[$i];

    # bucket color

    my $color1 = $b->get_bucket_color( $session,  $bucket );
    my $color4 = $b->get_bucket_color( $session4, $bucket );
    test_assert_equal( $color1, $color4, "bucket color for $bucket" );

    # bucket parameters

    foreach my $parameter ( qw/quarantine subject xtc xpl/ ) {
        my $value1 = $b->get_bucket_parameter( $session,  $bucket, $parameter );
        my $value4 = $b->get_bucket_parameter( $session4, $bucket, $parameter );

        test_assert_equal( $value1, $value4, "parameter $parameter for bucket $bucket" );
    }
}

# word count (corpus is not copied)

test_assert_equal( $b->get_word_count( $session4 ), 0 );

foreach my $bucket (@buckets4) {
    test_assert_equal( $b->get_bucket_word_count(   $session4, $bucket ), 0 );
    test_assert_equal( $b->get_bucket_unique_count( $session4, $bucket ), 0 );
}

$b->release_session_key( $session4 );

# create_user with cloning admin
# the magnets and corpus are copied

my ( $success5, $password5 ) = $b->create_user( $session, 'testuser5', 'admin', 1, 1 );
test_assert_equal( $success5, 0 );
test_assert( defined( $password5 ) );
test_assert( $password5 ne '' );

my $id5 = $b->get_user_id( $session, 'testuser5' );
test_assert( defined( $id5 ) );

my $session5 = $b->get_session_key( 'testuser5', $password5 );

# magnets (magnets are copied)

my @mags1 = $b->get_buckets_with_magnets( $session  );
my @mags5 = $b->get_buckets_with_magnets( $session5 );
test_assert_equal( $#mags1, $#mags5 );
for (0..$#mags1) {
    test_assert_equal( $mags1[$_], $mags5[$_] );
}

my @types1 = $b->get_magnet_types_in_bucket( $session,  'personal' );
my @types5 = $b->get_magnet_types_in_bucket( $session5, 'personal' );
test_assert_equal( $#types1, $#types5 );
for (0..$#types1) {
    test_assert_equal( $types1[$_], $types5[$_] );
}

# word count (corpus is copied)

test_assert_equal( $b->get_word_count( $session5 ),
                   $b->get_word_count( $session  ) );

foreach my $bucket (@buckets4) {
    test_assert_equal( $b->get_bucket_word_count(   $session5, $bucket ),
                       $b->get_bucket_word_count(   $session,  $bucket ) );
    test_assert_equal( $b->get_bucket_unique_count( $session5, $bucket ),
                       $b->get_bucket_unique_count( $session,  $bucket ) );
}

$b->release_session_key( $session5 );

# initialize_users_password

my ( $success5, $password5 ) = $b->initialize_users_password( $session,  'testuser4' );
test_assert_equal( $success5, 0 );
test_assert( defined($password5) );
# test_assert( $password4 ne $password5 );

$session4 = $b->get_session_key( 'testuser4', $password5 );
test_assert( defined($session4) );
$b->release_session_key( $session4 );

test_assert_equal( $b->initialize_users_password( $session, 'baduser' ), 1 );

# change_users_password

my $success6 = $b->change_users_password( $session, 'testuser4', 'password4' );
test_assert_equal( $success6, 0 );

$session4 = $b->get_session_key( 'testuser4', 'password4' );
test_assert( defined($session4) );
$b->release_session_key( $session4 );

test_assert_equal( $b->change_users_password( $session, 'baduser', 'badpassword' ), 1 );

# rename_user

my ( $success7, $password7 ) = $b->rename_user( $session, 'testuser', 'changeduser' );
test_assert_equal( $success7, 0 );
test_assert(  defined($password7) );

my $session7 = $b->get_session_key( 'changeduser', $password7 );
test_assert(  defined($session7) );
$b->release_session_key( $session7 );

( $success7, $password7 ) = $b->rename_user( $session, 'admin', 'admincannotberenamed' );
test_assert_equal( $success7, 2 );
test_assert( !defined($password7) );

( $success7, $password7 ) = $b->rename_user( $session, 'changeduser', 'admin' );
test_assert_equal( $success7, 1 );
test_assert( !defined($password7) );

# get_user_name_from_id

my $username4 = $b->get_user_name_from_id( $session, $id4 );
test_assert(  defined($username4) );
test_assert_equal( $username4, 'testuser4' );

$username4    = $b->get_user_name_from_id( $session,    0 );
test_assert( !defined($username4) );

# accounts

my @accounts = $b->get_accounts( $session, 0 );
test_assert( $#accounts == -1 );
@accounts = $b->get_accounts( $session, $id1 );
test_assert( $#accounts ==  0 );
test_assert( $accounts[0] eq 'pop3:foo:bar' );

test_assert( $b->remove_account( $session, 'pop3', 'foo:bar' ) == 1 );

my $session3 = $b->get_session_key_from_token( $session, 'pop3', 'foo:bar' );
test_assert( !defined( $session3 ) );

# get_all_buckets

my @all_buckets = sort $b->get_all_buckets( $session );
test_assert_equal( $#all_buckets, 3 );
test_assert_equal( $all_buckets[0], 'other'        );
test_assert_equal( $all_buckets[1], 'personal'     );
test_assert_equal( $all_buckets[2], 'spam'         );
test_assert_equal( $all_buckets[3], 'unclassified' );

# is_bucket

test_assert(  $b->is_bucket( $session, 'personal'     ) );
test_assert( !$b->is_bucket( $session, 'impersonal'   ) );
test_assert( !$b->is_bucket( $session, 'unclassified' ) );

# get_pseudo_buckets

my @pseudo_buckets = $b->get_pseudo_buckets( $session );
test_assert_equal( $#pseudo_buckets, 0 );
test_assert_equal( $pseudo_buckets[0], 'unclassified' );

# is_pseudo_bucket

test_assert( !$b->is_pseudo_bucket( $session, 'personal'     ) );
test_assert(  $b->is_pseudo_bucket( $session, 'unclassified' ) );
test_assert( !$b->is_pseudo_bucket( $session, 'impersonal2'  ) );

# get_buckets

my @buckets = sort $b->get_buckets( $session );
test_assert_equal( $#buckets, 2 );
test_assert_equal( $buckets[0], 'other'    );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam'     );
test_assert( !defined($buckets[3]) );

# get_bucket_id, get_bucket_name

my $spam_id = $b->get_bucket_id( $session, 'spam' );
test_assert( defined( $spam_id ) );
test_assert_equal( $b->get_bucket_name( $session, $spam_id ), 'spam' );

test_assert( !defined($b->get_bucket_id( $session, 'badbucket' )) );
test_assert( !defined($b->get_bucket_name( $session, -1 )) );

# get_bucket_word_count

test_assert_equal( $b->get_bucket_word_count( $session, $buckets[0]),  1785 );
test_assert_equal( $b->get_bucket_word_count( $session, $buckets[1]),   103 );
test_assert_equal( $b->get_bucket_word_count( $session, $buckets[2]), 12114 );

# get_bucket_word_list and prefixes

my @words = $b->get_bucket_word_prefixes( $session, 'personal' );
test_assert_equal( $#words, 1 );
test_assert_equal( $words[0], 'b' );
test_assert_equal( $words[1], 'f' );

@words = $b->get_bucket_word_list( $session, 'personal', 'b' );
test_assert_equal( $#words, 1 );
test_assert_equal( $words[0], 'bar' );
test_assert_equal( $words[1], 'baz' );

@words = $b->get_bucket_word_list( $session, 'personal', 'f' );
test_assert_equal( $#words, 0 );
test_assert_equal( $words[0], 'foo' );

# get_word_count

test_assert_equal( $b->get_word_count( $session ), 14002 );

# get_count_for_word

test_assert_equal( $b->get_count_for_word( $session, $buckets[0], 'foo'), 0 );
test_assert_equal( $b->get_count_for_word( $session, $buckets[1], 'foo'), 1 );
test_assert_equal( $b->get_count_for_word( $session, $buckets[2], 'foo'), 0 );

# get_unique_word_count

test_assert_equal( $b->get_unique_word_count( $session ), 4012 );

# get_bucket_unique_count

test_assert_equal( $b->get_bucket_unique_count( $session, $buckets[0]),  656 );
test_assert_equal( $b->get_bucket_unique_count( $session, $buckets[1]),    3 );
test_assert_equal( $b->get_bucket_unique_count( $session, $buckets[2]), 3353 );

# get_bucket_color

test_assert_equal( $b->get_bucket_color( $session, $buckets[0] ), 'red'   );
test_assert_equal( $b->get_bucket_color( $session, $buckets[1] ), 'green' );
test_assert_equal( $b->get_bucket_color( $session, $buckets[2] ), 'blue'  );
test_assert_equal( $b->get_bucket_color( $session, 'notabucket'), ''      );

# get_buckets

@buckets = $b->get_buckets( $session );
test_assert_equal( $#buckets, 2 );
test_assert_equal( $buckets[0], 'other'    );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam'     );

# set_bucket_color

test_assert_equal( $b->get_bucket_color( $session, $buckets[0]), 'red'    );
$b->set_bucket_color( $session, $buckets[0], 'yellow' );
test_assert_equal( $b->get_bucket_color( $session, $buckets[0]), 'yellow' );
$b->set_bucket_color( $session, $buckets[0], 'red'    );
test_assert_equal( $b->get_bucket_color( $session, $buckets[0]), 'red'    );

# get_bucket_parameter

test_assert( !defined( $b->get_bucket_parameter( $session, $buckets[0], 'dummy' ) ) );
test_assert_equal( $b->get_bucket_parameter( $session, $buckets[0], 'quarantine' ), 0 );
test_assert_equal( $b->get_bucket_parameter( $session, $buckets[0], 'subject'    ), 1 );

# set_bucket_parameter

test_assert_equal( $b->get_bucket_parameter( $session, $buckets[0], 'quarantine' ), 0 );
test_assert(  $b->set_bucket_parameter( $session, $buckets[0], 'quarantine', 1 ) );
test_assert_equal( $b->get_bucket_parameter( $session, $buckets[0], 'quarantine' ), 1 );
test_assert(  $b->set_bucket_parameter( $session, $buckets[0], 'quarantine', 0 ) );

test_assert( !$b->set_bucket_parameter( $session, 'badbucket', 'quarantine', 0 ) );

# get_html_colored_message

my $html = $b->get_html_colored_message(  $session, 'TestMails/TestMailParse019.msg' );
open FILE, "<TestMails/TestMailParse019.clr";
my $check = <FILE>;
close FILE;
test_assert_equal( $html, $check );

if ( $html ne $check ) {
    my $color_test = 'get_html_colored_message';
    open FILE, ">$color_test.expecting.html";
    print FILE $check;
    close FILE;
    open FILE, ">$color_test.got.html";
    print FILE $html;
    close FILE;
}

# create_bucket

test_assert(  $b->create_bucket( $session, 'zebra' ) );
test_assert( !$b->create_bucket( $session, 'zebra' ) );

@buckets = $b->get_buckets( $session );
test_assert_equal( $#buckets, 3 );
test_assert_equal( $buckets[0], 'other'    );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam'     );
test_assert_equal( $buckets[3], 'zebra'    );

test_assert_equal( $b->get_bucket_parameter(  $session, 'zebra', 'count'      ), 0 );
test_assert_equal( $b->get_bucket_parameter(  $session, 'zebra', 'subject'    ), 1 );
test_assert_equal( $b->get_bucket_parameter(  $session, 'zebra', 'quarantine' ), 0 );

test_assert_equal( $b->get_bucket_word_count(   $session, 'zebra' ), 0 );
test_assert_equal( $b->get_bucket_unique_count( $session, 'zebra' ), 0 );

test_assert_equal( $b->get_word_count( $session ), 14002 );

# rename_bucket

test_assert( $b->rename_bucket(  $session, 'zebra', 'zeotrope' ) );

@buckets = $b->get_buckets( $session );
test_assert_equal( $#buckets, 3 );
test_assert_equal( $buckets[0], 'other' );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam' );
test_assert_equal( $buckets[3], 'zeotrope' );

test_assert_equal( $b->get_bucket_parameter( $session, 'zeotrope', 'count'      ), 0 );
test_assert_equal( $b->get_bucket_parameter( $session, 'zeotrope', 'subject'    ), 1 );
test_assert_equal( $b->get_bucket_parameter( $session, 'zeotrope', 'quarantine' ), 0 );

test_assert_equal( $b->get_bucket_word_count(   $session, 'zeotrope' ), 0 );
test_assert_equal( $b->get_bucket_unique_count( $session, 'zeotrope' ), 0 );

test_assert_equal( $b->get_word_count( $session ), 14002 );

test_assert( !$b->rename_bucket( $session, 'badbucket', 'badbucket2' ) );
test_assert( !$b->rename_bucket( $session, 'spam',      'zeotrope'   ) );

# add_message_to_bucket

my %words;

open WORDS, "<TestMails/TestMailParse021.wrd";
while ( <WORDS> ) {
    if ( /(.+) (\d+)/ ) {
        $words{$1} = $2;
    }
}
close WORDS;

test_assert( $b->add_message_to_bucket( $session, 'zeotrope', 'TestMails/TestMailParse021.msg' ) );

foreach my $word (keys %words) {
    test_assert_equal( $b->get_base_value_( $session, 'zeotrope', $word ), $words{$word}, "zeotrope: $word $words{$word}" );
}

test_assert( $b->add_message_to_bucket( $session, 'zeotrope', 'TestMails/TestMailParse021.msg' ) );

foreach my $word (keys %words) {
    test_assert_equal( $b->get_base_value_( $session, 'zeotrope', $word ), $words{$word}*2, "zeotrope: $word $words{$word}" );
}

# remove_message_from_bucket

test_assert( $b->remove_message_from_bucket( $session, 'zeotrope', 'TestMails/TestMailParse021.msg' ) );
test_assert( $b->remove_message_from_bucket( $session, 'zeotrope', 'TestMails/TestMailParse021.msg' ) );

test_assert_equal( $b->get_bucket_word_count(   $session, 'zeotrope' ), 0 );
test_assert_equal( $b->get_bucket_unique_count( $session, 'zeotrope' ), 0 );

# add_messages_to_bucket

test_assert( $b->add_messages_to_bucket( $session, 'zeotrope', ( 'TestMails/TestMailParse021.msg', 'TestMails/TestMailParse021.msg' ) ) );

foreach my $word (keys %words) {
    test_assert_equal( $b->get_base_value_( $session, 'zeotrope', $word ), $words{$word}*2, "zeotrope: $word $words{$word}" );
}

# Test corrupting the corpus

#open FILE, ">corpus/zeotrope/table";
#print FILE "__CORPUS__ __VERSION__ 2\n";
#close FILE;

#open STDERR, ">temp.tmp";
#test_assert( !$b->load_bucket_( 'zeotrope' ) );
#close STDERR;
#open FILE, "<temp.tmp";
#my $line = <FILE>;
#test_assert_regexp( $line, 'Incompatible corpus version in zeotrope' );
#close FILE;

#open FILE, ">corpus/zeotrope/table";
#close FILE;

#open STDERR, ">temp.tmp";
#test_assert( !$b->load_bucket_( 'zeotrope' ) );
#close STDERR;
#open FILE, "<temp.tmp";
#$line = <FILE>;
#test_assert( !defined( $line ) );
#close FILE;

# get_magnet_header_and_value

my ( $header, $value ) = $b->get_magnet_header_and_value( $session, 1 );
test_assert( defined( $header ) );
test_assert_equal( $header, 'Subject' );
test_assert_equal( $value, 'bar' );
( $header, $value ) = $b->get_magnet_header_and_value( $session, 2 );
test_assert( defined( $header ) );
test_assert_equal( $header, 'To' );
test_assert_equal( $value, 'baz@baz.com' );
( $header, $value ) = $b->get_magnet_header_and_value( $session, 3 );
test_assert( defined( $header ) );
test_assert_equal( $header, 'From' );
test_assert_equal( $value, 'foo' );

# create_magnet

test_assert_equal( $b->magnet_count( $session ), 4 );
$b->create_magnet( $session, 'zeotrope', 'from', 'francis' );
test_assert_equal( $b->magnet_count( $session ), 5 );

# get_buckets_with_magnets

my @mags = $b->get_buckets_with_magnets( $session );
test_assert_equal( $#mags, 1 );
test_assert_equal( $mags[0], 'personal' );
test_assert_equal( $mags[1], 'zeotrope' );

# get_magnet_type_in_bucket

my @types = $b->get_magnet_types_in_bucket(  $session, 'zeotrope' );
test_assert_equal( $#types, 0 );
test_assert_equal( $types[0], 'from' );

@types = $b->get_magnet_types_in_bucket(  $session, 'personal' );
test_assert_equal( $#types, 2 );
test_assert_equal( $types[0], 'from'    );
test_assert_equal( $types[1], 'subject' );
test_assert_equal( $types[2], 'to'      );

# get_magnets

my @magnets = $b->get_magnets(  $session, 'zeotrope', 'from' );
test_assert_equal( $#magnets, 0 );
test_assert_equal( $magnets[0], 'francis' );

@magnets = $b->get_magnets( $session, 'personal', 'from'    );
test_assert_equal( $#magnets, 1 );
test_assert_equal( $magnets[0], 'foo'      );
test_assert_equal( $magnets[1], 'oldstyle' );
@magnets = $b->get_magnets( $session, 'personal', 'to'      );
test_assert_equal( $#magnets, 0 );
test_assert_equal( $magnets[0], 'baz@baz.com' );
@magnets = $b->get_magnets( $session, 'personal', 'subject' );
test_assert_equal( $#magnets, 0 );
test_assert_equal( $magnets[0], 'bar'      );

# magnet_match__

test_assert(  $b->magnet_match__( $session, 'foo',            'personal', 'from' ) );
test_assert(  $b->magnet_match__( $session, 'barfoo',         'personal', 'from' ) );
test_assert(  $b->magnet_match__( $session, 'foobar',         'personal', 'from' ) );
test_assert(  $b->magnet_match__( $session, 'oldstylemagnet', 'personal', 'from' ) );
test_assert( !$b->magnet_match__( $session, 'fo',             'personal', 'from' ) );
test_assert( !$b->magnet_match__( $session, 'fobar',          'personal', 'from' ) );
test_assert( !$b->magnet_match__( $session, 'oldstylmagnet',  'personal', 'from' ) );

test_assert(  $b->magnet_match__( $session, 'baz@baz.com',       'personal', 'to'   ) );
test_assert(  $b->magnet_match__( $session, 'dobaz@baz.com',     'personal', 'to'   ) );
test_assert(  $b->magnet_match__( $session, 'dobaz@baz.com.edu', 'personal', 'to'   ) );
test_assert( !$b->magnet_match__( $session, 'bam@baz.com',       'personal', 'to'   ) );
test_assert( !$b->magnet_match__( $session, 'doba@baz.com',      'personal', 'to'   ) );
test_assert( !$b->magnet_match__( $session, 'dobz@baz.com.edu',  'personal', 'to'   ) );

$b->create_magnet( $session, 'zeotrope', 'from', '@yahoo.com' );
test_assert(  $b->magnet_match__( $session, 'baz@yahoo.com', 'zeotrope', 'from' ) );
test_assert(  $b->magnet_match__( $session, 'foo@yahoo.com', 'zeotrope', 'from' ) );
test_assert( !$b->magnet_match__( $session, 'foo@yaho.com',  'zeotrope', 'from' ) );
$b->delete_magnet( $session, 'zeotrope', 'from', '@yahoo.com' );

$b->create_magnet( $session, 'zeotrope', 'from', '__r' );
test_assert( !$b->magnet_match__( $session, 'baz@rahoo.com', 'zeotrope', 'from' ) );
test_assert(  $b->magnet_match__( $session, '@__r',          'zeotrope', 'from' ) );
$b->delete_magnet( $session, 'zeotrope', 'from', '__r' );

$b->create_magnet( $session, 'zeotrope', 'from', 'foo$bar' );
test_assert( !$b->magnet_match__( $session, 'foo@bar',   'zeotrope', 'from' ) );
test_assert( !$b->magnet_match__( $session, 'foo$baz',   'zeotrope', 'from' ) );
test_assert(  $b->magnet_match__( $session, 'foo$bar',   'zeotrope', 'from' ) );
test_assert(  $b->magnet_match__( $session, 'foo$barum', 'zeotrope', 'from' ) );
$b->delete_magnet( $session, 'zeotrope', 'from', 'foo$bar' );

# get_magnet_types

my %mtypes = $b->get_magnet_types( $session );
my @mkeys = keys %mtypes;
test_assert_equal( $#mkeys, 3 );
test_assert_equal( $mtypes{from},    'From'    );
test_assert_equal( $mtypes{to},      'To'      );
test_assert_equal( $mtypes{subject}, 'Subject' );
test_assert_equal( $mtypes{cc},      'Cc'      );

# delete_magnet

$b->delete_magnet( $session, 'zeotrope', 'from', 'francis' );
test_assert_equal( $b->magnet_count( $session ), 4 );

@mags = $b->get_buckets_with_magnets( $session );
test_assert_equal( $#mags, 0 );
test_assert_equal( $mags[0], 'personal' );

# send a message through the mq (doesn't actually use the MQ???)

test_assert_equal( $b->get_bucket_parameter(  $session, 'zeotrope', 'count' ), 0 );
$b->classified( $session, 'zeotrope' );
$POPFile->CORE_service(1);
test_assert_equal( $b->get_bucket_parameter(  $session, 'zeotrope', 'count' ), 1 );

# clear_bucket (Generates orphans !!!)

$b->clear_bucket( $session, 'zeotrope' );
test_assert_equal( $b->get_bucket_word_count( $session, 'zeotrope' ), 0 );
# At this point we have orphans

my $orphan_query = $b->db_()->prepare( "select count(*) from words where words.id in (select id from words except select wordid from matrix);" );

my $single_orphan_query = $b->db_()->prepare( "select count(*) from words where words.word = 'srvexch.reichraming.helopal.com' AND words.id in (select id from words except select wordid from matrix);" );

# Test the total number of orphans
$orphan_query->execute();

test_assert_equal( $orphan_query->fetchrow_arrayref->[0] , 160 );

# Test a few specific orphaned words

$single_orphan_query->execute();

test_assert_equal( $single_orphan_query->fetchrow_arrayref->[0] , 1 );

# Test clearing of orphans

# This is not the usual delivery method of TICKD, but is better than
# violating POPFile::Logger internals for a message anyone can send

# THIS DOES NOT WORK, freezes.. calling cleanup directly

# $b->mq_post_( 'TICKD' );

# $POPFile->CORE_service();

$b->cleanup_orphan_words__();

# Test the total number of orphans
$orphan_query->execute();

test_assert_equal( $orphan_query->fetchrow_arrayref->[0] , 0 );

$orphan_query->finish;
undef $orphan_query;

# Test a few specific orphaned words

$single_orphan_query->execute();

test_assert_equal( $single_orphan_query->fetchrow_arrayref->[0] , 0 );

$single_orphan_query->finish;
undef $single_orphan_query;

# classify a message using a magnet

$b->create_magnet( $session, 'zeotrope', 'from', 'cxcse231@yahoo.com' );
test_assert_equal( $b->classify( $session, 'TestMails/TestMailParse021.msg' ), 'zeotrope' );
test_assert_equal( $b->{magnet_detail__}, 8 );
test_assert( $b->{magnet_used__} );

# clear_magnets

$b->clear_magnets( $session );
test_assert_equal( $b->magnet_count( $session ), 0 );
@mags = $b->get_buckets_with_magnets( $session );
test_assert_equal( $#mags, -1 );

# delete_bucket

test_assert(  $b->delete_bucket( $session, 'zeotrope'  ) );

@buckets = $b->get_buckets( $session );
test_assert_equal( $#buckets, 2 );
test_assert_equal( $buckets[0], 'other'    );
test_assert_equal( $buckets[1], 'personal' );
test_assert_equal( $buckets[2], 'spam'     );

test_assert( !$b->is_bucket( $session, 'zeotrope' ) );
test_assert( !$b->is_pseudo_bucket( $session, 'zeotrope' ) );

test_assert( !$b->delete_bucket( $session, 'badbucket' ) );

# getting and setting values

test_assert_equal( $b->get_value_( $session, 'personal', 'foo' ),      log(1/103) );
test_assert_equal( $b->get_sort_value_( $session, 'personal', 'foo' ), log(1/103) );

test_assert_equal( $b->set_value_( $session, 'personal', 'foo', 0 ), 1 );
test_assert_equal( $b->get_value_( $session, 'personal', 'foo' ), 0 );
test_assert_equal( $b->get_sort_value_( $session, 'personal', 'foo' ), $b->{not_likely__}{1} );
test_assert_equal( $b->get_not_likely_( $session ), $b->{not_likely__}{1} );

$b->set_value_( $session, 'personal', 'foo', 100 );
$b->db_update_cache__( $session );
test_assert_equal( $b->get_base_value_( $session, 'personal', 'foo' ), 100 );
test_assert_equal( $b->get_value_( $session, 'personal', 'foo' ),      log(100/202) );
test_assert_equal( $b->get_sort_value_( $session, 'personal', 'foo' ), log(100/202) );

# glob the tests directory for files called TestMails/TestMailParse\d+.msg which consist of messages
# to be parsed with the resulting classification in TestMails/TestMailParse.cls

my @class_tests = sort glob 'TestMails/TestMailParse*.msg';

for my $class_test (@class_tests) {
    my $class_file = $class_test;
    $class_file    =~ s/msg/cls/;
    my $class;

    if ( open CLASS, "<$class_file" ) {
        $class = <CLASS>;
        $class =~ s/[\r\n]//g;
        close CLASS;
    }

    test_assert_equal( $b->classify( $session, $class_test ), $class, $class_test );
}

# glob the tests directory for files called TestMails/TestMailParse\d+.msg which consist of messages
# to be sent through classify_and_modify

$b->module_config_( 'html', 'port',  8080 );
$b->module_config_( 'html', 'local',    1 );
$b->module_config_( 1, 'pop3', 'local', 1 );
$b->set_bucket_parameter( $session, 'spam', 'subject', 1 );
$b->set_bucket_parameter( $session, 'spam', 'xtc',     1 );
$b->set_bucket_parameter( $session, 'spam', 'xpl',     1 );

my @modify_tests = sort glob 'TestMails/TestMailParse*.msg';

for my $modify_file (@modify_tests) {
    if ( ( open MSG, "<$modify_file" ) && ( open OUTPUT, ">temp.out" ) ) {
        my ( $class, $slot ) = $b->classify_and_modify( $session, \*MSG, \*OUTPUT, 0, '' );
        close MSG;
        close OUTPUT;

        my $output_file = $modify_file;
        $output_file    =~ s/msg/cam/;
        open CAM, "<$output_file";
        open OUTPUT, "<temp.out";
        while ( <OUTPUT> ) {
            my $output_line = $_;
            next if ( $output_line =~ /^X-POPFile-TimeoutPrevension:/ );
            my $cam_line    = <CAM> || '';
            $output_line =~ s/[\r\n]//g;
            $cam_line =~ s/[\r\n]//g;
            if ( ( $output_line ne '.' ) || ( $cam_line ne '' ) ) {
                next if ( $output_line =~ /X-POPFile-Link/ );
                test_assert_equal( $output_line, $cam_line, $modify_file );
            }
        }

        close CAM;
        close OUTPUT;
        $h->delete_slot( $slot, 0, $session, 0 );
        unlink( 'temp.out' );
    }
}

# tests for stopwords API

unlink 'stopwords';
open FILE, ">stopwords";
print FILE "notthis\nandnotthat\n";
close FILE;

$b->{parser__}->{mangle__}->load_stopwords();

# get_stopword_list

my @stopwords = sort $b->get_stopword_list( $session );
test_assert_equal( $#stopwords, 1 );
test_assert_equal( $stopwords[0], 'andnotthat' );
test_assert_equal( $stopwords[1], 'notthis'    );

# add_stopword

test_assert( $b->add_stopword( $session, 'northat' ) );
@stopwords = sort $b->get_stopword_list( $session );
test_assert_equal( $#stopwords, 2 );
test_assert_equal( $stopwords[0], 'andnotthat' );
test_assert_equal( $stopwords[1], 'northat'    );
test_assert_equal( $stopwords[2], 'notthis'    );

# remove_stopword

test_assert( $b->remove_stopword( $session, 'northat' ) );
@stopwords = sort $b->get_stopword_list( $session );
test_assert_equal( $#stopwords, 1 );
test_assert_equal( $stopwords[0], 'andnotthat' );
test_assert_equal( $stopwords[1], 'notthis'    );

# echo_to_dot_

open FILE, ">messages/one.msg";
print FILE "From: test\@test.com\n";
print FILE "Subject: Your attention please\n\n";
print FILE "This is the body www.supersizewebhosting.com www.gamelink.com\n.\n";
close FILE;

# Four possibilities for echo_to_dot_ depending on whether we give
# it a client handle, a file handle, both or neither

# neither

open MAIL, "<messages/one.msg";
test_assert( $b->echo_to_dot_( \*MAIL ) );
test_assert( eof( MAIL ) );
close MAIL;

# to a handle

open TEMP, ">temp.tmp";
binmode TEMP;
open MAIL, "<messages/one.msg";
binmode MAIL;
test_assert( $b->echo_to_dot_( \*MAIL, \*TEMP ) );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP;

open TEMP, "<temp.tmp";
binmode TEMP;
open MAIL, "<messages/one.msg";
binmode MAIL;
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# to a file

unlink( 'temp.tmp' );
open MAIL, "<messages/one.msg";
test_assert( $b->echo_to_dot_( \*MAIL, undef, '>temp.tmp' ) );
test_assert( eof( MAIL ) );
close MAIL;

open TEMP, "<temp.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    if ( $mail =~ /^\./ ) {
        last;
    }
    test_assert_regexp( $temp, $mail );
}
test_assert( !eof( MAIL ) );
test_assert(  eof( TEMP ) );
close MAIL;
close TEMP;

# both

unlink( 'temp.tmp' );
open TEMP2, ">temp2.tmp";
binmode TEMP2;
open MAIL, "<messages/one.msg";
binmode MAIL;
test_assert( $b->echo_to_dot_( \*MAIL, \*TEMP2, '>temp.tmp' ) );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP2;

open TEMP, "<temp.tmp";
binmode TEMP;
open TEMP2, "<temp2.tmp";
binmode TEMP2;
open MAIL, "<messages/one.msg";
binmode MAIL;
while ( !eof( MAIL ) && !eof( TEMP ) && !eof( TEMP2 ) ) {
    my $temp  = <TEMP>;
    my $temp2 = <TEMP2>;
    my $mail  = <MAIL>;
    test_assert_regexp( $temp2, $mail );
    last if ( $mail =~ /^\./ );
    test_assert_regexp( $temp, $mail );
}
test_assert( !eof( MAIL  ) );
test_assert(  eof( TEMP  ) );
test_assert( !eof( TEMP2 ) );
close MAIL;
close TEMP;
close TEMP2;

# to a file with before string

unlink( 'temp.tmp' );
open MAIL, "<messages/one.msg";
test_assert( $b->echo_to_dot_( \*MAIL, undef, '>temp.tmp', "before\n" ) );
test_assert( eof( MAIL ) );
close MAIL;

open TEMP, "<temp.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    if ( $mail =~ /^\./ ) {
        test_assert_regexp( $temp, 'before' );
        last;
    }
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# echo_to_dot_ with no dot at the end

open FILE, ">messages/one.msg";
print FILE "From: test\@test.com\n";
print FILE "Subject: Your attention please\n\n";
print FILE "This is the body www.supersizewebhosting.com www.gamelink.com\n";
close FILE;

# Four possibilities for echo_to_dot_ depending on whether we give
# it a client handle, a file handle, both or neither

# neither

open MAIL, "<messages/one.msg";
test_assert( !$b->echo_to_dot_( \*MAIL ) );
test_assert( eof( MAIL ) );
close MAIL;

# to a handle

open TEMP, ">temp.tmp";
binmode TEMP;
open MAIL, "<messages/one.msg";
binmode MAIL;
test_assert( !$b->echo_to_dot_( \*MAIL, \*TEMP ) );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP;

open TEMP, "<temp.tmp";
binmode TEMP;
open MAIL, "<messages/one.msg";
binmode MAIL;
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# to a file

unlink( 'temp.tmp' );
open MAIL, "<messages/one.msg";
test_assert( !$b->echo_to_dot_( \*MAIL, undef, '>temp.tmp' ) );
test_assert( eof( MAIL ) );
close MAIL;

open TEMP, "<temp.tmp";
binmode TEMP;
open MAIL, "<messages/one.msg";
binmode MAIL;
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    if ( $mail =~ /^\./ ) {
        last;
    }
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;

# both

unlink( 'temp.tmp' );
open TEMP2, ">temp2.tmp";
binmode TEMP2;
open MAIL, "<messages/one.msg";
binmode MAIL;
test_assert( !$b->echo_to_dot_( \*MAIL, \*TEMP2, '>temp.tmp' ) );
test_assert( eof( MAIL ) );
close MAIL;
close TEMP2;

open TEMP, "<temp.tmp";
open TEMP2, "<temp2.tmp";
open MAIL, "<messages/one.msg";
binmode TEMP;
binmode TEMP2;
binmode MAIL;
while ( !eof( MAIL ) && !eof( TEMP ) && !eof( TEMP2 ) ) {
    my $temp = <TEMP>;
    my $temp2 = <TEMP2>;
    my $mail = <MAIL>;
    test_assert_regexp( $temp2, $mail );
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
test_assert( eof( TEMP2 ) );
close MAIL;
close TEMP;
close TEMP2;

# to a file with before string

unlink( 'temp.tmp' );
open MAIL, "<messages/one.msg";
test_assert( !$b->echo_to_dot_( \*MAIL, undef, '>temp.tmp', "before\n" ) );
test_assert( eof( MAIL ) );
close MAIL;

open TEMP, "<temp.tmp";
open MAIL, "<messages/one.msg";
while ( !eof( MAIL ) && !eof( TEMP ) ) {
    my $temp = <TEMP>;
    my $mail = <MAIL>;
    test_assert_regexp( $temp, $mail );
}
test_assert( eof( MAIL ) );
test_assert( eof( TEMP ) );
close MAIL;
close TEMP;


# test quarantining of a message

$b->set_bucket_parameter( $session, 'spam', 'quarantine', 1 );

open CLIENT, ">temp.tmp";
open MAIL, "<messages/one.msg";
my ( $class, $slot ) = $b->classify_and_modify( $session, \*MAIL, \*CLIENT, 0, '', 0, 1 );
close CLIENT;
close MAIL;

test_assert_equal( $class, 'spam' );
test_assert( -e $h->get_slot_file( $slot ) );

my @lookfor = ( "--$slot", 'Quarantined Message Detail', ' This is the body', "--$slot", "--$slot"."--", '.' );
open CLIENT, "<temp.tmp";
while ( $#lookfor > -1 ) {
    test_assert( !eof( CLIENT ) );
    my $search = shift @lookfor;
    while ( <CLIENT> ) {
        if ( /^\Q$search\E/ ) {
            last;
        }
    }
}
close CLIENT;

# test no save option

unlink( 'messages/popfile0=0.cls' );
unlink( 'messages/popfile0=0.msg' );
open CLIENT, ">temp.tmp";
open MAIL, "<messages/one.msg";
( $class, $slot ) = $b->classify_and_modify( $session, \*MAIL, \*CLIENT, 1, '', 0, 1 );
close CLIENT;
close MAIL;

test_assert_equal( $class, 'spam' );
test_assert( !(-e $h->get_slot_file( $slot ) ) );

# test no echo option

open CLIENT, ">temp.tmp";
open MAIL, "<messages/one.msg";
( $class, $slot ) = $b->classify_and_modify( $session, \*MAIL, \*CLIENT, 0, '', 0, 0 );
close CLIENT;
close MAIL;

test_assert_equal( $class, 'spam' );
test_assert( -e $h->get_slot_file( $slot ) );

test_assert_equal( ( -s 'temp.tmp' ), 0 );

# test option where we know the classification

open CLIENT, ">temp.tmp";
open MAIL, "<messages/one.msg";
( $class, $slot ) = $b->classify_and_modify( $session, \*MAIL, \*CLIENT, 0, 'other', 0, 1 );
close CLIENT;
close MAIL;

test_assert_equal( $class, 'other' );
test_assert( -e $h->get_slot_file( $slot ) );

# TODO test that stop writes the parameters to disk

# Test Japanese mode

my $have_text_kakasi = 0;

foreach my $prefix (@INC) {
    my $realfilename = "$prefix/Text/Kakasi.pm";
    if (-f $realfilename) {
        $have_text_kakasi = 1;
        last;
    }
}

if ( $have_text_kakasi ) {

    $b->global_config_( 'language', 'Nihongo' );
    $b->initialize();
    test_assert( $b->start() );

    $b->{parser__}->{lang__} = 'Nihongo';

    # Test Japanese magnet. GOMI means "trash" in Japanese.

    $b->create_bucket( $session, 'gomi' );

    # create_magnet

    $b->clear_magnets( $session );
    $b->create_magnet( $session, 'gomi', 'subject', chr(0xbe) . chr(0xb5) . chr(0xc2) . chr(0xfa) );
    test_assert_equal( $b->classify( $session, 'TestMails/TestNihongo021.msg' ), 'gomi' );

    test_assert_equal( $b->magnet_count( $session ), 1 );
    $b->create_magnet( $session, 'gomi', 'subject', chr(0xa5) . chr(0xc6) . chr(0xa5) . chr(0xb9) . chr(0xa5) . chr(0xc8));
    test_assert_equal( $b->magnet_count( $session ), 2 );

    # get_magnets

    my @magnets = $b->get_magnets( $session, 'gomi', 'subject' );
    test_assert_equal( $#magnets, 1 );
    test_assert_equal( $magnets[0], chr(0xa5) . chr(0xc6) . chr(0xa5) . chr(0xb9) . chr(0xa5) . chr(0xc8) );
    test_assert_equal( $magnets[1], chr(0xbe) . chr(0xb5) . chr(0xc2) . chr(0xfa) );

    # delete_magnet
    $b->delete_magnet( $session, 'gomi', 'subject', chr(0xbe) . chr(0xb5) . chr(0xc2) . chr(0xfa) );
    test_assert_equal( $b->magnet_count( $session ), 1 );

    # add_message_to_bucket

    my %words;

    open WORDS, "<TestMails/TestNihongo021.wrd";
    while ( <WORDS> ) {
        if ( /(.+) (\d+)/ ) {
            $words{$1} = $2;
        }
    }
    close WORDS;

    test_assert( $b->add_message_to_bucket( $session, 'gomi', 'TestMails/TestNihongo021.msg' ) );

    foreach my $word (keys %words) {
        test_assert_equal( $b->get_base_value_( $session, 'gomi', $word ), $words{$word}, "gomi: $word $words{$word}" );
    }

    # get_bucket_word_prefixes

    my @words = $b->get_bucket_word_prefixes( $session, 'gomi' );
    test_assert_equal( $#words, 20 );
    test_assert_equal( $words[18], chr(0xa4) . chr(0xb3) );
    test_assert_equal( $words[19], chr(0xa4) . chr(0xc7) );
    test_assert_equal( $words[20], chr(0xa5) . chr(0xb9) );

    # qurantine test

    $b->set_bucket_parameter( $session, 'gomi', 'quarantine', 1 );

    open CLIENT, ">temp.tmp";
    open MAIL, "<TestMails/TestNihongo021.msg";
    my ( $class, $slot ) = $b->classify_and_modify( $session, \*MAIL, \*CLIENT, 0, '', 0, 1 );
    close CLIENT;
    close MAIL;

    test_assert_equal( $class, 'gomi' );
    test_assert( -e $h->get_slot_file( $slot ) );

    open TEMP, "<temp.tmp";
    open MAIL, "<TestMails/TestNihongo021.qrn";
    while ( !eof( MAIL ) && !eof( TEMP ) ) {
        my $temp = <TEMP>;
        $temp =~ s/[\r\n]//g;
        my $mail = <MAIL>;
        $mail =~ s/[\r\n]//g;
        test_assert_equal( $temp, $mail );
    }
    close MAIL;
    close TEMP;

    # remove_message_from_bucket

    test_assert( $b->remove_message_from_bucket( $session, 'gomi', 'TestMails/TestNihongo021.msg' ) );
    test_assert_equal( $b->get_bucket_word_count( $session, 'gomi' ), 0 );

} else {
    print "\nWarning: Japanese tests skipped because Text::Kakasi was not found\n";
}

$POPFile->CORE_stop();

unlink 'temp.tmp';
unlink 'temp2.tmp';

1;
