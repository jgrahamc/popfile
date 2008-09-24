# -*- coding: utf8 -*-

from trac.notification import NotifyEmail
from trac.util import format_datetime
from trac.util.text import CRLF, wrap, to_unicode

class DiscussionNotifyEmail(NotifyEmail):

    template_name = "discussion-notify-body.cs"
    forum = None
    topic = None
    message = None
    torcpts = []
    ccrcpts = []
    from_email = 'trac+discussion@localhost'
    COLS = 75

    def __init__(self, env):
        NotifyEmail.__init__(self, env)

    def notify(self, req, cursor, action, forum = None, topic = None,
      message = None, torcpts = [], ccrcpts = []):
        self.env.log.debug("action: %s" % action)
        self.env.log.debug("forum: %s" % forum)
        self.env.log.debug("topic: %s" % topic)
        self.env.log.debug("message: %s" % message)
        self.env.log.debug("torcpts: %s" % torcpts)
        self.env.log.debug("ccrcpts: %s" % ccrcpts)

        # Store link to currently notifying forum, topic and message.
        self.forum = forum
        self.topic = topic
        self.message = message
        self.torcpts = torcpts
        self.ccrcpts = ccrcpts

        author_short = ''

        # Get action and item of action.
        index = action.find('-')
        item = action[:index]
        action = action[index + 1:]

        # Which item notify about:
        if item == 'topic':
            # Prepare topic specific fields.
            re = ''
            title = 'Topic'
            id = self.topic['id']
            author = "    Author:  %s" % self.topic['author']
            time = "      Time:  %s" % format_datetime(self.topic['time'])
            body = self.topic['body']
            link = req.abs_href.discussion(self.forum['id'], self.topic['id'])
            author_short = self.topic['author']

            # Save link for bad times.
            topic['link'] = link
        elif item == 'message':
            # Prepare message specific fields
            re = 'Re: '
            title = 'Message'
            id = self.message['id']
            author = "    Author:  %s" % self.message['author']
            time = "      Time:  %s" % format_datetime(self.message['time'])
            body = self.message['body']
            link = req.abs_href.discussion(self.forum['id'], self.topic['id'],
              self.message['id']) + '#%s' % self.message['id']
            author_short = self.message['author']

            # Save link for bad times.
            message['link'] = link
        else:
            return

        prefix = self.config.get('notification', 'smtp_subject_prefix')
        if prefix == '__default__':
            prefix = self.env.project_name
        moderators = "Moderators:  %s" % ' '.join(self.forum['moderators'])
        subject = self.topic['subject']

        # Set set e-mail template values.
        self.hdf.set_unescaped('discussion.re', re)
        self.hdf.set_unescaped('discussion.prefix', prefix)
        self.hdf.set_unescaped('discussion.title', title)
        self.hdf.set_unescaped('discussion.id', id)
        self.hdf.set_unescaped('discussion.author', author)
        if item == 'message' or item == 'topic':
            self.hdf.set_unescaped('discussion.author_short', author_short)
        self.hdf.set_unescaped('discussion.time', time)
        self.hdf.set_unescaped('discussion.moderators', moderators)
        self.hdf.set_unescaped('discussion.subject', subject)
        self.hdf.set_unescaped('discussion.body', body)
        self.hdf.set_unescaped('discussion.link', link)
        self.hdf.set_unescaped('discussion.forum', forum['name'])

        # Render body and send notification.
        subject = to_unicode(self.hdf.render('discussion-notify-subject.cs'))
        NotifyEmail.notify(self, id, subject)

    def get_message_id(self, forum_id, topic_id, message_id):
        # Fix ID of messages replying to topic.
        if message_id < 0:
            message_id = 0

        # Construct Message-ID according to RFC 2822.
        id = '%s.%s.%s' % (forum_id, topic_id, message_id)
        host = self.from_email[self.from_email.find('@') + 1:]
        return '<%s@%s>' % (id, host)

    def get_recipients(self, resid):
        return (self.torcpts, self.ccrcpts)

    def send(self, torcpts, ccrcpts):
        header = {}

        # Add item specific e-mail header fields.
        if self.message:
            # Get this messge ID.
            header['Message-ID'] = self.get_message_id(self.forum['id'],
              self.topic['id'], self.message['id'])
            header['X-Trac-Message-ID'] = to_unicode(self.message['id'])
            header['X-Trac-Discussion-URL'] = self.message['link']

            # Get replied message ID.
            reply_id = self.get_message_id(self.forum['id'], self.topic['id'],
              self.message['replyto'])
            header['In-Reply-To'] = reply_id
            header['References'] = reply_id
        else:
            # Get this message ID.
            header['Message-ID'] = self.get_message_id(self.forum['id'],
              self.topic['id'], 0)
            header['X-Trac-Topic-ID'] = to_unicode(self.topic['id'])
            header['X-Trac-Discussion-URL'] = self.topic['link']

        print torcpts, ccrcpts, header

        # Send e-mail.
        NotifyEmail.send(self, torcpts, ccrcpts, header)
