# ----------------------------------------------------------------------------
#
# Tests for insert.pl
#
# Copyright (c) 2001-2011 John Graham-Cumming
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

my $insert = 'perl -I ../ ../insert.pl';

# One or no command line arguments

@stdout = `$insert`;
$code = ($? >> 8);
test_assert( $code != 0 );

my $line = shift @stdout;

test_assert_regexp( $line, 'insert mail messages into' );

@stdout = `$insert personal`;
test_assert( ($? >> 8) != 0 );
test_assert_regexp( shift @stdout, 'insert mail messages into' );

# Save STDERR

open my $old_stderr, ">&STDERR";

# Bad bucket name

open STDERR, ">temp.tmp";
system("$insert none TestMails/TestMailParse021.wrd");
close STDERR;
$code = ($? >> 8);
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: Bucket `none\' does not exist, insert aborted' );

# Bad file name

open STDERR, ">temp.tmp";
system("$insert personal doesnotexist");
$code = ($? >> 8);
close STDERR;

test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: File `doesnotexist\' does not exist, insert aborted' );


# Check that insertion actually works

my %words;

open WORDS, "<TestMails/TestMailParse021.wrd";
while ( <WORDS> ) {
    if ( /(.+) (\d+)/ ) {
        $words{$1} = $2;
    }
}
close WORDS;

open STDERR, ">temp.tmp";
@stdout =`$insert personal TestMails/TestMailParse021.msg`;
$code = ($? >> 8);
close STDERR;

test_assert_equal( $code, 0 );

$line = shift @stdout;

test_assert_regexp( $line, 'Added 1 files to `personal\'' );

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
my $session = $b->get_session_key( 'admin', '' );

foreach my $word (keys %words) {
    test_assert_equal( $b->get_base_value_( $session, 'personal', $word ), $words{$word}, "personal: $word $words{$word}" );
}

# Set multiuser mode

$b->global_config_( 'single_user', 0 );

# Create a new user

my ( $result, $password ) = $b->create_user( $session, 'testuser', 'admin' );
test_assert_equal( $result, 0 );

# Get user's session

my $user_session = $b->get_session_key( 'testuser', $password );

# Add a new bucket for the user

$b->create_bucket( $user_session, 'newbucket' );

$b->release_session_key( $session );
$b->release_session_key( $user_session );
$POPFile->CORE_stop();

# Two or less command line arguments

@stdout = `$insert`;
$code = ($? >> 8);
test_assert( $code != 0 );

my $line = shift @stdout;

test_assert_regexp( $line, 'insert mail messages into' );

@stdout = `$insert personal`;
test_assert( ($? >> 8) != 0 );
test_assert_regexp( shift @stdout, 'insert mail messages into' );

@stdout = `$insert personal2 TestMails/TestMailParse021.msg`;
test_assert( ($? >> 8) != 0 );
test_assert_regexp( shift @stdout, 'insert mail messages into' );

# Bad user name

open STDERR, ">temp.tmp";
system("$insert baduser personal TestMails/TestMailParse021.wrd");
close STDERR;
$code = ($? >> 8);
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: User `baduser\' does not exist, insert aborted' );

# Bad bucket name

open STDERR, ">temp.tmp";
system("$insert testuser none TestMails/TestMailParse021.wrd");
close STDERR;
$code = ($? >> 8);
test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: Bucket `none\' for user `testuser\' does not exist, insert aborted' );

# Bad file name

open STDERR, ">temp.tmp";
system("$insert testuser personal doesnotexist");
$code = ($? >> 8);
close STDERR;

test_assert( $code != 0 );
open TEMP, "<temp.tmp";
$line = <TEMP>;
close TEMP;
test_assert_regexp( $line, 'Error: File `doesnotexist\' does not exist, insert aborted' );

# Check that insertion actually works (multiuser mode)

open STDERR, ">temp.tmp";
@stdout =`$insert testuser newbucket TestMails/TestMailParse021.msg`;
$code = ($? >> 8);
close STDERR;

unlink 'temp.tmp';

test_assert_equal( $code, 0 );

$line = shift @stdout;

test_assert_regexp( $line, 'Added 1 files to `newbucket\' for user `testuser\'' );

$POPFile = POPFile::Loader->new();
$POPFile->CORE_loader_init();
$POPFile->CORE_signals();

$POPFile->CORE_load( 0, \%valid );
$POPFile->CORE_initialize();
$POPFile->CORE_config( 1 );
$POPFile->CORE_start();

$b = $POPFile->get_module( 'Classifier/Bayes' );
$user_session = $b->get_session_key( 'testuser', $password );

foreach my $word (keys %words) {
    test_assert_equal( $b->get_base_value_( $user_session, 'newbucket', $word ), $words{$word}, "newbucket: $word $words{$word}" );
}

$b->release_session_key( $user_session );
$POPFile->CORE_stop();

# Restore STDERR

open STDERR, ">&", $old_stderr;

rmtree( 'insert.pl' );


1;


