# -*- coding: utf8 -*-

from trac.core import *
from trac.config import Option
from trac.Search import ISearchSource, shorten_result
from trac import util

class DiscussionSearch(Component):
    """
        The search module implements searching in topics and messages.
    """
    implements(ISearchSource)

    title = Option('discussion', 'title', 'Discussion',
      'Main navigation bar button title.')

    #ISearchSource
    def get_search_filters(self, req):
        if req.perm.has_permission('DISCUSSION_VIEW'):
            yield ("discussion", self.title)

    def get_search_results(self, req, keywords, filters):
        if not 'discussion' in filters:
            return

        # Create database context
        db = self.env.get_db_cnx()
        cursor = db.cursor()

        # Search in topics.
        query = ' '.join(keywords)
        columns = ('id', 'forum', 'time', 'subject', 'body', 'author')
        sql = "SELECT id, forum, time, subject, body, author FROM topic" \
          " WHERE subject || body LIKE '%%%s%%'" % (query)
        self.log.debug(sql)
        cursor.execute(sql)
        for row in cursor:
            row = dict(zip(columns, row))
            yield (req.href.discussion(row['forum'], row['id']) + '#-1',
              "topic: %d: %s" % (row['id'], util.shorten_line(row['subject'])),
              row['time'], row['author'], shorten_result(row['body'],
              [query]))

        # Search in messages
        columns = ('id', 'forum', 'topic', 'time', 'author', 'body', 'subject')
        sql = "SELECT m.id, m.forum, m.topic, m.time, m.author, m.body," \
          " t.subject FROM message m LEFT JOIN (SELECT subject, id FROM" \
          " topic) t ON t.id = m.topic WHERE body LIKE '%%%s%%'" \
          % (query)
        self.log.debug(sql)
        cursor.execute(sql)
        for row in cursor:
            row = dict(zip(columns, row))
            yield (req.href.discussion(row['forum'], row['topic'], row['id'])
              + '#%s' % (row['id']), "message: %d: %s" % (row['id'],
              util.shorten_line(row['subject'])), row['time'], row['author'],
              shorten_result(row['body'], [query]))
