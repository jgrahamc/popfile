# POPFILE LOADABLE MODULE 2
package POPFile::Database;

use POPFile::Module;
@ISA = ("POPFile::Module");

#----------------------------------------------------------------------------
#
# This module handles POPFile's database.  It maintains all database
# connections
#
# Copyright (c) 2001-2005 John Graham-Cumming
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
    $self->config_( 'dbuser', '' ); $self->config_( 'dbauth', '' );

    # SQLite 1.05+ have some problems we are resolving.  This lets us
    # give a nice message and then disable the version checking later

    $self->config_( 'bad_sqlite_version', '3.0.0' );

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

    if ( ( $self->config_( 'sqlite_tweaks' ) & 2 ) && 
         $self->{db_is_sqlite__} ) {
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

    if ( $self->{db_is_sqlite__} && 
         ( $self->config_( 'sqlite_tweaks' ) & $tweak ) ) {

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

    $self->log_( 0, "Attempting to connect to $dbconnect ($dbpresent)" );

    my $db = DBI->connect( $dbconnect,                    # PROFILE BLOCK START
                                  $self->config_( 'dbuser' ),
                                  $self->config_( 'dbauth' ) );  # PROFILE BLOCK STOP

    $self->log_( 0, "Using SQLite library version " . $db->{sqlite_version});

    # We check to make sure we're not using DBD::SQLite 1.05 or greater
    # which uses SQLite V 3 If so, we'll use DBD::SQLite2 and SQLite 2.8,
    # which is still compatible with old databases

    if ( $db->{sqlite_version} gt $self->config_('bad_sqlite_version' ) )  {
        $self->log_( 0, "Substituting DBD::SQLite2 for DBD::SQLite 1.05" );
        $self->log_( 0, "Please install DBD::SQLite2 and set dbconnect to use DBD::SQLite2" );

        $dbconnect =~ s/SQLite:/SQLite2:/;

        $db = DBI->connect( $dbconnect,                    # PROFILE BLOCK START
                                      $self->config_( 'dbuser' ),
                                      $self->config_( 'dbauth' ) );  # PROFILE BLOCK STOP
    }

    if ( !defined( $db ) ) {
        $self->log_( 0, "Failed to connect to database and got error $DBI::errstr" );
        return undef
    }

    if ( !$dbpresent ) {
        if ( !$self->insert_schema__( $db, $sqlite ) ) {
            return undef;
        }
    }

    if ( $upgrade ) {

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
            if ( $table eq 'popfile' ) {
                my @row = $db->selectrow_array(
                   'select version from popfile;' );

                if ( $#row == 0 ) {
                    $need_upgrade = ( $row[0] != $version );
                }
            }
        }

        if ( $need_upgrade ) {
            print "\n\nDatabase schema is outdated, performing automatic upgrade\n";

            # The database needs upgrading, so we are going to dump out
            # all the data in the database as INSERT statements in a
            # temporary file, then DROP all the tables in the database,
            # then recreate the schema from the new schema and finally
            # rerun the inserts.

            my $i = 0;
            my $ins_file = $self->get_user_path_( 'insert.sql' );
            open INSERT, '>' . $ins_file;

            foreach my $table (@tables) {
                next if ( $table eq 'popfile' );
                if ( $sqlite && ( $table =~ /^sqlite_/ ) ) {
                    next;
                }
                if ( $i > 99 ) {
                    print "\n";
                }
                print "    Saving table $table\n    ";

                my $t = $db->prepare( "select * from $table;" );
                $t->execute;
                $i = 0;
                while ( 1 ) {
                    if ( ( ++$i % 100 ) == 0 ) {
                        print "[$i]";
                        flush STDOUT;
                    }
                    my @rows = $t->fetchrow_array;

                    last if ( $#rows == -1 );

                    print INSERT "INSERT INTO $table (";
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
                        my $val = $rows[$i];
                        if ( $t->{TYPE}->[$i] !~ /^int/i ) {
                            $val = '' if ( !defined( $val ) );
                            $val = $db->quote( $val );
                        } else {
                            $val = 'NULL' if ( !defined( $val ) );
                        }
                        print INSERT $val;
                    }
                    print INSERT ");\n";
                }
            }

            close INSERT;

            if ( $i > 99 ) {
                print "\n";
            }

            foreach my $table (@tables) {
                if ( $sqlite && ( $table =~ /^sqlite_/ ) ) {
                    next;
                }
                print "    Dropping old table $table\n";
                $db->do( "DROP TABLE $table;" );
            }

            print "    Inserting new database schema\n";
            if ( !$self->insert_schema__( $db, $sqlite ) ) {
                return undef;
            }

            print "    Restoring old data\n    ";

            $db->begin_work;
            open INSERT, '<' . $ins_file;
            $i = 0;
            while ( <INSERT> ) {
                if ( ( ++$i % 100 ) == 0 ) {
                    print "[$i]";
                    flush STDOUT;
                }
                s/[\r\n]//g;
                $db->do( $_ );
            }
            close INSERT;
            $db->commit;

            # Now write the current version to the database

            $db->do( "insert into popfile ( version ) values ( $version ); " );

            unlink $ins_file;
            print "\nDatabase upgrade complete\n\n";
        }
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
