from trac.db import Table, Column, Index, DatabaseManager

tables = [
  Table('forum', key = 'id')[
    Column('id', type = 'integer', auto_increment = True),
    Column('name'),
    Column('time', type = 'integer'),
    Column('forum_group', type = 'integer'),
    Column('author'),
    Column('moderators'),
    Column('subject'),
    Column('description')
  ],
#  Table('forum_group', key = 'id')[
#    Column('id', type = 'integer', auto_increment = True),
#    Column('name'),
#    Column('description')
#  ]
]

def do_upgrade(env, cursor):
    db_connector, _ = DatabaseManager(env)._get_connector()

    print "Upgrading forum database tables to version 2\n"

    # Backup old screenshot table.
    cursor.execute("CREATE TEMPORARY TABLE forum_old AS SELECT * FROM forum")
    cursor.execute("DROP TABLE forum")

    # Create tables
    for table in tables:
        for statement in db_connector.to_sql(table):
            cursor.execute(statement)

    sql = "INSERT INTO forum (id, name, time, moderators, subject, description) " \
                      "SELECT id, name, time, moderators, subject, description " \
                      " FROM forum_old"

    print sql + "\n"

    # Copy old forums
    cursor.execute( sql )

    # Set database schema version.
    cursor.execute("UPDATE system SET value = '2' WHERE" \
      " name = 'discussion_version'")

    print "done.\n"
