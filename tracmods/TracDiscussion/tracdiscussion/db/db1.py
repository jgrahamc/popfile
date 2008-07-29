from trac.db import Table, Column, Index, DatabaseManager

tables = [
  Table('forum', key = 'id')[
    Column('id', type = 'integer', auto_increment = True),
    Column('name'),
    Column('time', type = 'integer'),
    Column('moderators'),
    Column('subject'),
    Column('description')
  ],
  Table('topic', key = 'id')[
    Column('id', type = 'integer', auto_increment = True),
    Column('forum', type = 'integer'),
    Column('time', type = 'integer'),
    Column('author'),
    Column('subject'),
    Column('body')
  ],
  Table('message', key = 'id')[
    Column('id', type = 'integer', auto_increment = True),
    Column('forum', type = 'integer'),
    Column('topic', type = 'integer'),
    Column('replyto', type = 'integer'),
    Column('time', type = 'integer'),
    Column('author'),
    Column('body')
  ]
]

def do_upgrade(env, cursor):
    db_connector, _ = DatabaseManager(env)._get_connector()

    print "Upgrading forum database tables to version 1\n"

    # Create tables
    for table in tables:
        for statement in db_connector.to_sql(table):
            cursor.execute(statement)

    # Set database schema version.
    cursor.execute("INSERT INTO system (name, value) VALUES"
      " ('discussion_version', '1')")

    print "done.\n"
