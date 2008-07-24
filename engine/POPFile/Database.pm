# POPFILE LOADABLE MODULE 2
package POPFile::Database;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile's database.  It maintains all database
# connections
#
# Copyright (c) 2001-2006 John Graham-Cumming
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
#----------------------------------------------------------------------------

use strict;
use warnings;
use locale;
use DBI;
use File::Copy;

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = POPFile::Module->new();

    # Database handle

    $self->{db__} = 0;

    bless($self, $class);

    $self->name( 'database' );

    return $self;
}

#----------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the database
#
# ---------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # This is the name for the database

    $self->config_( 'database', 'popfile.db' );

    # This is the 'connect' string used by DBI to connect to the
    # database, if you decide to change from using SQLite to some
    # other database (e.g. MySQL, Oracle, ... ) this *should* be all
    # you need to change.  The additional parameters user and auth are
    # needed for some databases.
    #
    # Note that the dbconnect string will be interpolated before being
    # passed to DBI and the variable $dbname can be used within it and
    # it resolves to the full path to the database named in the
    # database parameter above.

    $self->config_( 'dbconnect', 'dbi:SQLite:dbname=$dbname' );
    $self->config_( 'dbuser', '' );
    $self->config_( 'dbauth', '' );

    # SQLite 1.05+ have some problems we are resolving.  This lets us
    # give a nice message and then disable the version checking later

    $self->config_( 'bad_sqlite_version', '4.0.0' );

    # This is a bit mask used to control options when we are using the
    # default SQLite database.  By default all the options are on.
    #
    # 1 = Asynchronous deletes
    # 2 = Backup database every hour

    $self->config_( 'sqlite_tweaks', 0xFFFFFFFF );

    # Register for the TICKD message which is sent hourly by the
    # Logger module.  We use this to hourly save the database if bit 1
    # of the sqlite_tweaks is set and we are using SQLite

    $self->mq_register_( 'TICKD', $self );

    return 1;
}

# ---------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, @message ) = @_;

    if ( $type eq 'TICKD' ) {
        $self->backup_database__();
    }
}

#----------------------------------------------------------------------------
#
# start
#
# Called to start access to the database
#
#----------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    if ( !$self->db_connect__() ) {
        return 0;
    }

    return 1;
}

#----------------------------------------------------------------------------
#
# stop
#
# Called to terminate access to the database
#
#----------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    $self->db_disconnect__();
    $self->SUPER::stop();
}

#----------------------------------------------------------------------------
#
# backup_database__
#
# Called when the TICKD message is received each hour and if we are using
# the default SQLite database will make a copy with the .backup extension
#
#----------------------------------------------------------------------------
sub backup_database__
{
    my ( $self ) = @_;

    # If database backup is turned on and we are using SQLite then
    # backup the database by copying it

    if ( ( $self->config_( 'sqlite_tweaks' ) & 2 ) && # PROFILE BLOCK START
         $self->{db_is_sqlite__} ) {                  # PROFILE BLOCK STOP
        if ( !copy( $self->{db_name__}, $self->{db_name__} . ".backup" ) ) {
            $self->log_( 0, "Failed to backup database ".$self->{db_name__} );
        }
    }
}

#----------------------------------------------------------------------------
#
# tweak_sqlite
#
# Called when a module wants is to tweak access to the SQLite database.
#
# $tweak    The tweak to apply (a bit in the sqlite_tweaks mask)
# $state    1 to enable the tweak, 0 to disable
# $db       The db handle to tweak
#
#----------------------------------------------------------------------------
sub tweak_sqlite
{
    my ( $self, $tweak, $state, $db ) = @_;

    if ( $self->{db_is_sqlite__} &&                         # PROFILE BLOCK START
         ( $self->config_( 'sqlite_tweaks' ) & $tweak ) ) { # PROFILE BLOCK STOP

        $self->log_( 1, "Performing tweak $tweak to $state" );

        if ( $tweak == 1 ) {
            my $sync = $state?'off':'normal';
            $db->do( "pragma synchronous=$sync;" );
        }
    }
}

#----------------------------------------------------------------------------
#
# db_disconnect__
#
# Disconnects from the POPFile database
#
#----------------------------------------------------------------------------
sub db_disconnect__
{
    my ( $self ) = @_;

    if ( defined( $self->{db__} ) ) {
        $self->{db__}->disconnect;
        undef $self->{db__};
    }
}

#----------------------------------------------------------------------------
#
# db_connect__
#
# Connects to the POPFile database and returns 1 if successful
#
#----------------------------------------------------------------------------
sub db_connect__
{
    my ( $self ) = @_;

    $self->{db__} = $self->db_connect_helper__(1);

    return defined( $self->{db__} );
}

#----------------------------------------------------------------------------
#
# db_connect_helper__
#
# Connects to the POPFile database and returns the handle
#
# $upgrade         1 if it's ok to upgrade the database
#
#----------------------------------------------------------------------------
sub db_connect_helper__
{
    my ( $self, $upgrade ) = @_;

    # Connect to the database, note that the database must exist for
    # this to work, to make this easy for people POPFile we will
    # create the database automatically here using the file
    # 'popfile.sql' which should be located in the same directory the
    # Classifier/Bayes.pm module

    # If we are using SQLite then the dbname is actually the name of a
    # file, and hence we treat it like one, otherwise we leave it
    # alone

    my $dbname;
    my $dbconnect = $self->config_( 'dbconnect' );
    my $dbpresent;
    my $sqlite = ( $dbconnect =~ /sqlite/i );

    if ( $sqlite ) {
        $dbname = $self->get_user_path_( $self->config_( 'database' ) );
        $dbpresent = ( -e $dbname ) || 0;
    } else {
        $dbname = $self->config_( 'database' );
        $dbpresent = 1;
    }

    # Record whether we are using SQLite or not and the name of the
    # database so that other routines can access it; this is used by
    # the backup_database__ routine to make a backup copy of the
    # database when using SQLite.

    $self->{db_is_sqlite__} = $sqlite;
    $self->{db_name__}      = $dbname;

    # Now perform the connect, note that this is database independent
    # at this point, the actual database that we connect to is defined
    # by the dbconnect parameter.

    $dbconnect =~ s/\$dbname/$dbname/g;

    my $need_convert = 0;
    my $old_dbh;

    if ( $sqlite && $dbpresent ) {

        # Check if the database is SQLite2 format

        open DBFILE, $dbname;
        my $buffer;
        my $readed = sysread( DBFILE, $buffer, 47 );
        close DBFILE;

        if ( $buffer eq '** This file contains an SQLite 2.1 database **' ) {
            $self->log_( 0, 'SQLite 2 database found. Try to upgrade' );

            # Test DBD::SQLite version

            my $ver = -1;
            eval {
                require DBD::SQLite;
                $ver = $DBD::SQLite::VERSION;
            };

            if ( $ver >= 1.00 ) {
                $self->log_( 0, "DBD::SQLite $ver found" );

                # Backup SQLite2 database

                my $old_dbname = $dbname . '-sqlite2';
                unlink $old_dbname;
                rename $dbname, $old_dbname;

                # Connect to SQLite2 database

                my $old_dbconnect = $self->config_( 'dbconnect' );
                $old_dbconnect =~ s/SQLite:/SQLite2:/;
                $old_dbconnect =~ s/\$dbname/$old_dbname/g;

                $old_dbh = DBI->connect( $old_dbconnect,               # PROFILE BLOCK START
                                         $self->config_( 'dbuser' ),
                                         $self->config_( 'dbauth' ) ); # PROFILE BLOCK STOP

                # Update the config file

                $dbconnect = $self->config_( 'dbconnect' );
                $dbconnect =~ s/SQLite2:/SQLite:/;
                $self->config_( 'dbconnect', $dbconnect );
                $dbconnect =~ s/\$dbname/$dbname/g;

                $need_convert = 1;
            }
        } else {

            # Update the config file

            $dbconnect = $self->config_( 'dbconnect' );
            $dbconnect =~ s/SQLite2:/SQLite:/;
            $self->config_( 'dbconnect', $dbconnect );
            $dbconnect =~ s/\$dbname/$dbname/g;
        }
    }

    $self->log_( 0, "Attempting to connect to $dbconnect ($dbpresent)" );

    my $db = DBI->connect( $dbconnect,                    # PROFILE BLOCK START
                                  $self->config_( 'dbuser' ),
                                  $self->config_( 'dbauth' ) );  # PROFILE BLOCK STOP

    if ( !defined( $db ) ) {
        $self->log_( 0, "Failed to connect to database and got error $DBI::errstr" );
        return undef
    }

    if ( $sqlite ) {
        $self->log_( 0, "Using SQLite library version " . $db->{sqlite_version} );

        if ( $need_convert ) {
            $self->log_( 0, 'Convert SQLite2 database to SQLite3 database' );

            $self->db_upgrade__( $old_dbh );
            $old_dbh->disconnect;

            $self->log_( 0, 'Database convert completed' );
        }

        # For Japanese compatibility

        if ( $self->global_config_( 'language' ) eq 'Nihongo' ) {
            $db->do( 'pragma case_sensitive_like=1;' );
        }
    }

    if ( !$dbpresent ) {
        if ( !$self->insert_schema__( $db, $sqlite ) ) {
            return undef;
        }
    }

    # Now check for a need to upgrade the database because the schema
    # has been changed.  From POPFile v0.22.0 there's a special
    # 'popfile' table inside the database that contains the schema
    # version number.  If the version number doesn't match or is
    # missing then do the upgrade.

    open SCHEMA, '<' . $self->get_root_path_( 'Classifier/popfile.sql' );
    <SCHEMA> =~ /-- POPFILE SCHEMA (\d+)/;
    my $version = $1;
    close SCHEMA;

    my $need_upgrade = 1;

    # retrieve the SQL_IDENTIFIER_QUOTE_CHAR for the database then use it
    # to strip off any sqlquotechars from the table names we retrieve

    my $sqlquotechar = $db->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } ($db->tables());

    foreach my $table (@tables) {
        if ( $table =~ /\.?popfile$/ ) {
            my $row = $db->selectrow_arrayref(   # PROFILE BLOCK START
               'select version from popfile;' ); # PROFILE BLOCK STOP

            if ( defined( $row ) ) {
                $need_upgrade = ( $row->[0] != $version );
            }
        }
    }

    if ( $need_upgrade ) {

        print "\n\nDatabase schema is outdated, performing automatic upgrade\n";

        # The database needs upgrading

        $self->db_upgrade__( $db );

        print "\nDatabase upgrade complete\n\n";
    }

    return $db;
}

#----------------------------------------------------------------------------
#
# insert_schema__
#
# Insert the POPFile schema in a database
#
# $db              Database handle
# $sqlite          Set to 1 if this is a SQLite database
#
#----------------------------------------------------------------------------
sub insert_schema__
{
    my ( $self, $db, $sqlite ) = @_;

    if ( -e $self->get_root_path_( 'Classifier/popfile.sql' ) ) {
        my $schema = '';

        $self->log_( 0, "Creating database schema" );

        open SCHEMA, '<' . $self->get_root_path_( 'Classifier/popfile.sql' );
        while ( <SCHEMA> ) {
            next if ( /^--/ );
            next if ( !/[a-z;]/ );
            s/--.*$//;

            # If the line begins 'alter' and we are doing SQLite then ignore
            # the line

            if ( $sqlite && ( /^alter/i ) ) {
                next;
            }

            $schema .= $_;

            if ( ( /end;/ ) || ( /\);/ ) || ( /^alter/i ) ) {
                $db->do( $schema );
                $schema = '';
            }
        }
        close SCHEMA;
        return 1;
    } else {
        $self->log_( 0, "Can't find the database schema" );
        return 0;
    }
}

#----------------------------------------------------------------------------
#
# db_upgrade__
#
# Upgrade the POPFile schema / Convert the database
#
# $db_to           Database handle convert to
# $db_from         Database handle convert from
#                  undef if upgrade POPFile schema
#
#----------------------------------------------------------------------------
sub db_upgrade__
{
    my ( $self, $db_to, $db_from ) = @_;

    my $drop_table;

    if ( !defined( $db_from ) ) {
        # Upgrade

        $drop_table = 1;
        $db_from = $db_to;
    }

    my $from_sqlite = ( $db_from->{Driver}->{Name} =~ /SQLite/ );
    my $to_sqlite   = ( $db_to->{Driver}->{Name} =~ /SQLite/ );

    my $sqlquotechar = $db_from->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } ($db_from->tables());

    # We are going to dump out all the data in the database as
    # INSERT OR IGNORE statements in a temporary file, then DROP all
    # the tables in the database, then recreate the schema from the
    # new schema and finally rerun the inserts.

    my $i = 0;
    my $ins_file = $self->get_user_path_( 'insert.sql' );
    open INSERT, '>' . $ins_file;

    foreach my $table (@tables) {
        next if ( $table =~ /\.?popfile$/ );
        if ( $from_sqlite && ( $table =~ /^sqlite_/ ) ) {
            next;
        }
        if ( $i > 99 ) {
            print "\n";
        }
        print "    Saving table $table\n    ";

        my $t = $db_from->prepare( "select * from $table;" );
        $t->execute;
        $i = 0;
        while ( 1 ) {
            if ( ( ++$i % 100 ) == 0 ) {
                print "[$i]";
                flush STDOUT;
            }
            if ( ( $i % 1000 ) == 0 ) {
                print "\n";
                flush STDOUT;
            }
            my $rows = $t->fetchrow_arrayref;

            last if ( !defined( $rows ) );

            if ( $to_sqlite ) {
                print INSERT "INSERT OR IGNORE INTO $table (";
            } else {
                print INSERT "INSERT INTO $table (";
            }
            for my $i (0..$t->{NUM_OF_FIELDS}-1) {
                if ( $i != 0 ) {
                    print INSERT ',';
                }
                print INSERT $t->{NAME}->[$i];
            }
            print INSERT ') VALUES (';
            for my $i (0..$t->{NUM_OF_FIELDS}-1) {
                if ( $i != 0 ) {
                    print INSERT ',';
                }
                my $val = $rows->[$i];
                if ( $t->{TYPE}->[$i] !~ /^int/i ) {
                    $val = '' if ( !defined( $val ) );
                    $val = $db_to->quote( $val );
                } else {
                    $val = 'NULL' if ( !defined( $val ) );
                }
                print INSERT $val;
            }
            print INSERT ");\n";
        }
        $t->finish;
    }

    close INSERT;

    if ( $i > 99 ) {
        print "\n";
    }

    if ( $drop_table ) {
        foreach my $table (@tables) {
            if ( $from_sqlite && ( $table =~ /^sqlite_/ ) ) {
                next;
            }
            print "    Dropping old table $table\n";
            $db_to->do( "DROP TABLE $table;" );
        }
    }

    print "    Inserting new database schema\n";
    if ( !$self->insert_schema__( $db_to, $to_sqlite ) ) {
        return 0;
    }

    print "    Restoring old data\n    ";

    $db_to->begin_work;
    open INSERT, '<' . $ins_file;
    $i = 0;
    while ( <INSERT> ) {
        if ( ( ++$i % 100 ) == 0 ) {
           print "[$i]";
           flush STDOUT;
        }
        if ( ( $i % 1000 ) == 0 ) {
            print "\n";
            flush STDOUT;
        }
        s/[\r\n]//g;
        $db_to->do( $_ );
    }
    close INSERT;
    $db_to->commit;

    unlink $ins_file;
}

#----------------------------------------------------------------------------
#
# validate_sql_prepare_and_execute
#
# This method will prepare sql statements and execute them.
# The statement itself and any binding parameters are also
# tested for possible null-characters (\x00).
# If you pass in a handle to a prepared statement, the statement
# will be executed and possible binding-parameters are checked.
#
# $statement  The sql statement to prepare or the prepared statement handle
# @args       The (optional) list of binding parameters
#
# Returns the result of prepare()
#----------------------------------------------------------------------------
sub validate_sql_prepare_and_execute {
    my $self = shift;
    my $sql_or_sth  = shift;
    my @args = @_;

    my $dbh = $self->{db__};
    my $sth = undef;

    # Is this a statement-handle or a sql string?
    if ( (ref $sql_or_sth) =~ m/^DBI::/ ) {
        $sth = $sql_or_sth;
    }
    else {
        my $sql = $sql_or_sth;
        $sql = $self->check_for_nullbytes( $sql );
        $sth = $dbh->prepare( $sql );
    }

    my $execute_result = undef;

    # Any binding-params?
    if ( @args ) {
        foreach my $arg ( @args ) {
            $arg = $self->check_for_nullbytes( $arg );
        }
        $execute_result = $sth->execute( @args );
    }
    else {
        $execute_result = $sth->execute();
    }

    unless ( $execute_result ) {
        my ( $package, $file, $line ) = caller;
        $self->log_( 0, "DBI::execute failed.  Called from package '$package' ($file), line $line." );
    }

    return $sth;
}


#----------------------------------------------------------------------------
#
# check_for_nullbytes
#
# Will check a passed-in string for possible null-bytes and log and error
# message in case a null-byte is found.
#
# Will return the string with any null-bytes removed.
#----------------------------------------------------------------------------
sub check_for_nullbytes {
    my $self = shift;
    my $string = shift;

    if ( defined $string ) {
        my $backup = $string;

        if ( my $count = ( $string =~ s/\x00//g ) ) {
            my ( $package, $file, $line ) = caller( 1 );
            $self->log_( 0, "Found $count null-character(s) in string '$backup'. Called from package '$package' ($file), line $line." );
        }
    }

    return $string;
}

#----------------------------------------------------------------------------
#
# forked
#
# This is called inside a child process that has just forked, since
# the child needs access to the database we open it
#
#----------------------------------------------------------------------------
sub forked
{
    my ( $self, $writer ) = @_;

    $self->SUPER::forked( $writer );

    $self->db_connect__();
}

# GETTER

sub db
{
    my ( $self ) = @_;

    return $self->db_connect_helper__(0);
}

1;
