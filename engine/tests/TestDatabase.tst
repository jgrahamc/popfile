# ----------------------------------------------------------------------------
#
# Tests for Database.pm
#
# Copyright (c) 2003-2008 John Graham-Cumming
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

my %valid = ( 'POPFile/Module'        => 1,
              'POPFile/Logger'        => 1,
              'POPFile/MQ'            => 1,
              'POPFile/Configuration' => 1 );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );
$POPFile->CORE_start();

use POPFile::Database;
my $db = new POPFile::Database;
$db->loader( $POPFile );

# Check that base functions return good values

test_assert_equal( $db->initialize(), 1 );
test_assert_equal( $db->start(),      1 );
test_assert_equal( $db->service(),    1 );

# 

my $schema_version = 8;

# Test default tables and data

my ( $h, $row );

$h = $db->validate_sql_prepare_and_execute( 'select * from accounts;' );
test_assert(  defined( $h ) );
test_assert( !defined( $h->fetchrow_arrayref ) );

$h = $db->validate_sql_prepare_and_execute( 'select * from history;' );
test_assert(  defined( $h ) );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $id, $version );
$h = $db->validate_sql_prepare_and_execute( 'select * from popfile;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$version );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $version, $schema_version );
test_assert( !defined( $h->fetchrow_arrayref ) );

$h = $db->validate_sql_prepare_and_execute( 'select * from bucket_params;' );
test_assert(  defined( $h ) );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $mtype, $header );
$h = $db->validate_sql_prepare_and_execute( 'select * from magnet_types order by id;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$mtype, \$header );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $mtype, 'from' );
test_assert_equal( $header, 'From' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 2 );
test_assert_equal( $mtype, 'to' );
test_assert_equal( $header, 'To' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 3 );
test_assert_equal( $mtype, 'subject' );
test_assert_equal( $header, 'Subject' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 4 );
test_assert_equal( $mtype, 'cc' );
test_assert_equal( $header, 'Cc' );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $userid, $utid, $val );
$h = $db->validate_sql_prepare_and_execute( 'select * from user_params;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$userid, \$utid, \$val );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $userid, 1 );
test_assert_equal( $utid, 3 );
test_assert_equal( $val, 1 );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $name, $def );
$h = $db->validate_sql_prepare_and_execute( 'select * from bucket_template order by id;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$name, \$def );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $name, 'subject' );
test_assert_equal( $def, '1' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 2 );
test_assert_equal( $name, 'xtc' );
test_assert_equal( $def, '1' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 3 );
test_assert_equal( $name, 'xpl' );
test_assert_equal( $def, '1' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 4 );
test_assert_equal( $name, 'fncount' );
test_assert_equal( $def, '0' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 5 );
test_assert_equal( $name, 'fpcount' );
test_assert_equal( $def, '0' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 6 );
test_assert_equal( $name, 'quarantine' );
test_assert_equal( $def, '0' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 7 );
test_assert_equal( $name, 'count' );
test_assert_equal( $def, '0' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 8 );
test_assert_equal( $name, 'color' );
test_assert_equal( $def, 'black' );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $bucketid, $mtid, $comment, $seq );
$h = $db->validate_sql_prepare_and_execute( 'select * from magnets order by id;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$bucketid, \$mtid, \$val, \$comment, \$seq );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 0 );
test_assert_equal( $bucketid, 0 );
test_assert_equal( $mtid, 0 );
test_assert_equal( $val, '' );
test_assert_equal( $comment, '' );
test_assert_equal( $seq, 0 );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $form );
$h = $db->validate_sql_prepare_and_execute( 'select * from user_template order by id;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$name, \$def, \$form );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $name, 'GLOBAL_public_key' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 2 );
test_assert_equal( $name, 'GLOBAL_private_key' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 3 );
test_assert_equal( $name, 'GLOBAL_can_admin' );
test_assert_equal( $def, '0' );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 4 );
test_assert_equal( $name, 'bayes_subject_mod_left' );
test_assert_equal( $def, '[' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 5 );
test_assert_equal( $name, 'bayes_subject_mod_right' );
test_assert_equal( $def, ']' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 6 );
test_assert_equal( $name, 'bayes_unclassified_weight' );
test_assert_equal( $def, 100 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 7 );
test_assert_equal( $name, 'bayes_xpl_angle' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 8 );
test_assert_equal( $name, 'history_history_days' );
test_assert_equal( $def, 2 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 9 );
test_assert_equal( $name, 'html_update_check' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 10 );
test_assert_equal( $name, 'html_send_stats' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 11 );
test_assert_equal( $name, 'html_page_size' );
test_assert_equal( $def, 20 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 12 );
test_assert_equal( $name, 'html_skin' );
test_assert_equal( $def, 'default' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 13 );
test_assert_equal( $name, 'html_last_update_check' );
test_assert_equal( $def, 1104192000 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 14 );
test_assert_equal( $name, 'html_last_reset' );
test_assert_equal( $def, 'Thu Sep  2 14:22:23 2004' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 15 );
test_assert_equal( $name, 'html_language' );
test_assert_equal( $def, 'English' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 16 );
test_assert_equal( $name, 'html_test_language' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 17 );
test_assert_equal( $name, 'html_wordtable_format' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 18 );
test_assert_equal( $name, 'html_columns' );
test_assert_equal( $def, '+inserted,+from,+to,-cc,+subject,-date,-size,+bucket,' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 19 );
test_assert_equal( $name, 'html_date_format' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 20 );
test_assert_equal( $name, 'html_session_dividers' );
test_assert_equal( $def, 1 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 21 );
test_assert_equal( $name, 'html_column_characters' );
test_assert_equal( $def, 34 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 22 );
test_assert_equal( $name, 'html_show_bucket_help' );
test_assert_equal( $def, 1 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 23 );
test_assert_equal( $name, 'html_show_training_help' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 24 );
test_assert_equal( $name, 'imap_bucket_folder_mappings' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 25 );
test_assert_equal( $name, 'imap_expunge' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 26 );
test_assert_equal( $name, 'imap_hostname' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 27 );
test_assert_equal( $name, 'imap_login' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 28 );
test_assert_equal( $name, 'imap_password' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 29 );
test_assert_equal( $name, 'imap_port' );
test_assert_equal( $def, 143 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 30 );
test_assert_equal( $name, 'imap_training_mode' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 31 );
test_assert_equal( $name, 'imap_uidnexts' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 32 );
test_assert_equal( $name, 'imap_uidvalidities' );
test_assert_equal( $def, '' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 33 );
test_assert_equal( $name, 'imap_update_interval' );
test_assert_equal( $def, 20 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 34 );
test_assert_equal( $name, 'imap_use_ssl' );
test_assert_equal( $def, 0 );
test_assert_equal( $form, '%d' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 35 );
test_assert_equal( $name, 'imap_watched_folders' );
test_assert_equal( $def, 'INBOX' );
test_assert_equal( $form, '%s' );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 36 );
test_assert_equal( $name, 'html_show_configbars' );
test_assert_equal( $def, 1 );
test_assert_equal( $form, '%d' );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $pseudo );
$h = $db->validate_sql_prepare_and_execute( 'select * from buckets;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$userid, \$name, \$pseudo, \$comment );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $userid, 1 );
test_assert_equal( $name, 'unclassified' );
test_assert_equal( $pseudo, 1 );
test_assert_equal( $comment, '' );
test_assert( !defined( $h->fetchrow_arrayref ) );

$h = $db->validate_sql_prepare_and_execute( 'select * from matrix;' );
test_assert(  defined( $h ) );
test_assert( !defined( $h->fetchrow_arrayref ) );

my ( $password );
$h = $db->validate_sql_prepare_and_execute( 'select * from users;' );
test_assert(  defined( $h ) );
$h->bind_columns( \$id, \$name, \$password );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $id, 1 );
test_assert_equal( $name, 'admin' );
test_assert_equal( $password, 'e11f180f4a31d8caface8e62994abfaf' );
test_assert( !defined( $h->fetchrow_arrayref ) );

# Tests for validate_sql_prepare_and_execute

# prepared statement with a parameter

my $dbh = $db->db();
my $sth = $dbh->prepare( 'select def from user_template where name = ?' );
$h = $db->validate_sql_prepare_and_execute( $sth, 'GLOBAL_can_admin' );
test_assert(  defined( $h ) );
$h->bind_columns( \$def );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $def, 0 );
test_assert( !defined( $h->fetchrow_arrayref ) );

# null-bytes in parameter

$h = $db->validate_sql_prepare_and_execute( $sth, 'GLOBAL_can_admin' . "\00" );
test_assert(  defined( $h ) );
$h->bind_columns( \$def );
test_assert(  defined( $h->fetchrow_arrayref ) );
test_assert_equal( $def, 0 );
test_assert( !defined( $h->fetchrow_arrayref ) );

# bad number of parameters

{
    local $SIG{__WARN__} = sub{};
    $h = $db->validate_sql_prepare_and_execute( $sth, 'GLOBAL_can_admin', 'bad parameter' );
}

$sth->finish;
undef $sth;
undef $h;

# Test backup_database__

$db->config_( 'sqlite_tweaks', 2 );
$db->backup_database__();

# Test tweak_sqlite

$db->config_( 'sqlite_tweaks', 1 );
$db->tweak_sqlite( 1, 1, $db->{db__} );
$db->tweak_sqlite( 1, 0, $db->{db__} );

# Test for database conversion

use DBI;
use DBD::SQLite2;
use DBD::SQLite;

my $dbname = $db->get_user_path_( 'temp.db' );
my $dbconnect = $db->config_( 'dbconnect' );

if ( $dbconnect =~ /SQLite:/ ) {
    $dbconnect =~ s/SQLite:/SQLite2:/;
}
$dbconnect =~ s/\$dbname/$dbname/;

my $dbh_to = DBI->connect( $dbconnect );

$db->db_upgrade__( $dbh_to, $dbh );

$dbh_to->disconnect;
$dbh->disconnect;
$db->db_disconnect__();

# Test for automatic conversion

rename $db->get_user_path_( 'temp.db' ), $db->get_user_path_( 'popfile.db' );

$db->start();

$db->stop();
$POPFile->CORE_stop();

1;
