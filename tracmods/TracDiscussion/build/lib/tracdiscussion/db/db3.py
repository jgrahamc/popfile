from trac.db import Table, Column, Index, DatabaseManager

tables = [
  Table('topic', key = 'id')[
    Column('id', type = 'integer', auto_increment = True),
    Column('forum', type = 'integer'),
    Column('time', type = 'integer'),
    Column('author'),
    Column('subject'),
    Column('body'),
    Column('lastreply', type='integer')
  ],
]

def do_upgrade(env, cursor):
    db_connector, _ = DatabaseManager(env)._get_connector()

    print "Upgrading forum database tables to version 3\n"

    # Backup old topic table
    cursor.execute( "CREATE TEMPORARY TABLE topic_old AS SELECT * FROM topic")
    cursor.execute( "DROP TABLE topic" )

    # Create tables
    for table in tables:
        for statement in db_connector.to_sql(table):
            cursor.execute(statement)

    sql = "INSERT INTO topic (id, forum, time, author, subject, body, lastreply) "\
                      "SELECT id, forum, time, author, subject, body, time " \
          "FROM topic_old"

    # Copy old topics
    print sql + "\n"
    cursor.execute(sql)

    # Set database schema version.
    cursor.execute("UPDATE system SET value = '3' WHERE" \
      " name = 'discussion_version'")

    print "done.\n"
