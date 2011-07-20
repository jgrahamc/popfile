# ----------------------------------------------------------------------------
#
# Tests for import.pl
#
# Copyright (c) 2003-2011 John Graham-Cumming
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

# global to store STDOUT when doing backticks

my @stdout;

use_base_environment();
rmtree( 'import' );
mkdir( 'import' );
test_assert( rec_cp( 'corpus.base', 'import/corpus' ) );

my $import = 'perl -I ../ ../import.pl';

# One or no command line arguments

@stdout = `$import`;
$code = ($? >> 8);
test_assert( $code != 0 );

my $line = shift @stdout;

test_assert_regexp( $line, 'import user data into the new database' );

@stdout = `$import ./import`;
test_assert( ($? >> 8) != 0 );
test_assert_regexp( shift @stdout, 'import user data into the new database' );

# Save STDERR

open my $old_stderr, ">&STDERR";

# Bad user name

open STDERR, ">temp.tmp";
@stdout = `$import ./import none`;
close STDERR;
$code = ($? >> 8);
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error : User \'none\' does not exist, import aborted' );
test_assert_regexp( shift @stdout, 'Import from database \'./import/popfile.db\'' );

# Bad new user name

open STDERR, ">temp.tmp";
system("$import ./import admin admin");
$code = ($? >> 8);
close STDERR;

test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error : Bad new user name \'admin\', import aborted' );


# Check that import actually works

open STDERR, ">temp.tmp";
@stdout =`$import ./import admin importeduser`;
$code = ($? >> 8);
close STDERR;

test_assert_equal( $code, 0 );

$line = shift @stdout;
test_assert_regexp( $line, 'Import from database \'./import/popfile.db\'' );
$line = shift @stdout;
test_assert_regexp( $line, '  New user \'importeduser\' is created. The user\'s initial password is ' );
$line =~ m/password is \'(.+)\'/;
my $password = $1;

foreach my $bucket qw(spam other personal) {
    $line = shift @stdout;
    test_assert_regexp( $line, "  Created a bucket \'$bucket\'" );
}
foreach my $bucket qw(spam other personal) {
    $line = shift @stdout;
    test_assert_regexp( $line, "  Importing words into the bucket \'$bucket\'..." );
}

$line = shift @stdout;
test_assert_regexp( $line, 'Imported the database successfully' );

use POPFile::Loader;
my $POPFile = POPFile::Loader->new();
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

my %valid = ( 'Classifier/Bayes' => 1,
              'POPFile/Logger' => 1,
              'POPFile/MQ'     => 1,
              'POPFile/Database'     => 1,
              'POPFile/Configuration' => 1 );

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );
$POPFile->CORE_start();

my $b = $POPFile->get_module( 'Classifier/Bayes' );
my $session1 = $b->get_session_key( 'admin', '' );
my $session2 = $b->get_session_key( 'importeduser', $password );

test_assert( defined( $session1 ) );
test_assert( defined( $session2 ) );

# Check user parameters

my @parameters = sort $b->get_user_parameter_list( $session1 );
foreach my $parameter (@parameters) {
    next if ( $parameter eq 'GLOBAL_can_admin' );
    test_assert_equal( $b->get_user_parameter( $session1, $parameter ),
                       $b->get_user_parameter( $session2, $parameter ),
                       "user parameter : $parameter" );
}

# Check buckets, bucket parameters and words

foreach my $bucket qw(spam other personal) {
    my $bucketid1 = $b->get_bucket_id( $session1, $bucket );
    my $bucketid2 = $b->get_bucket_id( $session2, $bucket );

    test_assert( defined( $bucketid1 ) );
    test_assert( defined( $bucketid2 ) );

    foreach my $parameter ( qw/quarantine subject xtc xpl/ ) {
        test_assert_equal( $b->get_bucket_parameter( $session1, $bucket, $parameter ),
                           $b->get_bucket_parameter( $session2, $bucket, $parameter ),
                           "bucket parameter : $bucket $parameter" );
    }

    test_assert_equal( $b->get_bucket_word_count( $session1, $bucketid1 ),
                       $b->get_bucket_word_count( $session2, $bucketid2 ),
                       "bucekt word count : $bucket" );
}

$b->release_session_key( $session1 );
$b->release_session_key( $session2 );
$POPFile->CORE_stop();

# Restore STDERR

open STDERR, ">&", $old_stderr;


1;


