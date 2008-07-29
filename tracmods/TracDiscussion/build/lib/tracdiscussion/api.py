# -*- coding: utf8 -*-

from tracdiscussion.notification import *
from trac.core import *
from trac.web.chrome import add_stylesheet, add_link
from trac.wiki import wiki_to_html, wiki_to_oneliner
from trac.perm import PermissionError
from trac.util import format_datetime, pretty_timedelta
from trac.util.text import to_unicode
import time

class DiscussionApi(object):
    def __init__(self, component, req):
        self.env = component.env
        self.log = component.log
        self.topics_per_page = component.topics_per_page

    # Main request processing function

    def render_discussion(self, req):
        # Get request mode
        group, forum, topic, message = self._get_items(req)
        modes = self._get_modes(req, group, forum, topic, message)
        self.log.debug('modes: %s' % modes)

        # Determine moderator rights.
        if forum:
            is_moderator = (req.authname in forum['moderators']) or \
              req.perm.has_permission('DISCUSSION_ADMIN')
        else:
            is_moderator = req.perm.has_permission('DISCUSSION_ADMIN')

        # Perform mode actions
        self._do_action(req, modes, group, forum, topic, message, is_moderator)

        # Add CSS styles
        add_stylesheet(req, 'common/css/wiki.css')
        add_stylesheet(req, 'discussion/css/discussion.css')
        add_stylesheet(req, 'discussion/css/admin.css')

        add_link(req, 'alternate', '/timeline?discussion=on&amp;max=50&amp;daysback=90&amp;format=rss', 'POPFile forums', 'application/rss+xml')

        # Fill up HDF structure and return template
        req.hdf['discussion.authname'] = req.authname
        req.hdf['discussion.is_moderator'] = is_moderator
        title = 'POPFile Forums'
        if group:
            group['name'] = wiki_to_oneliner(group['name'], self.env)
            group['description'] = wiki_to_oneliner(group['description'],
              self.env)
            req.hdf['discussion.group'] = group
        if forum:
            forum['name'] = wiki_to_oneliner(forum['name'], self.env)
            forum['description'] = wiki_to_oneliner(forum['description'],
              self.env)
            forum['subject'] = wiki_to_oneliner(forum['subject'], self.env)
            forum['time'] = format_datetime(forum['time'])
            req.hdf['discussion.forum'] = forum
            title = 'POPFile ' + forum['name'] + ' Forum'
        if topic:
            topic['subject'] = wiki_to_oneliner(topic['subject'], self.env)
            topic['author'] = wiki_to_oneliner(topic['author'], self.env)
            topic['body'] = wiki_to_html(topic['body'], self.env, req, None, False, True)
            topic['time'] = format_datetime(topic['time'])
            req.hdf['discussion.topic'] = topic
        if message:
            message['author'] = wiki_to_oneliner(message['author'], self.env)
            message['body'] = wiki_to_html(message['body'], self.env, req, None, False, True)
            message['time'] = format_datetime(message['time'])
            req.hdf['discussion.message'] = message
        req.hdf['discussion.mode'] = modes[-1]
        req.hdf['discussion.time'] = format_datetime(time.time())
        req.hdf['title'] = title

        return modes[-1] + '.cs', None

    def _get_items(self, req):
        group, forum, topic, message = None, None, None, None

        # Get database access.
        db = self.env.get_db_cnx()
        cursor = db.cursor()

        # Populate active group
        if req.args.has_key('group'):
            group_id = int(req.args.get('group') or 0)
            group = self.get_group(cursor, group_id)

        # Populate active forum
        if req.args.has_key('forum'):
            forum_id = int(req.args.get('forum') or 0)
            forum = self.get_forum(cursor, forum_id)

        # Populate active topic
        if req.args.has_key('topic'):
            topic_id = int(req.args.get('topic') or 0)
            topic = self.get_topic(cursor, topic_id)

        # Populate active topic
        if req.args.has_key('message'):
            message_id = int(req.args.get('message') or 0)
            message = self.get_message(cursor, message_id)

        self.log.debug('group: %s' % group)
        self.log.debug('forum: %s' % forum)
        self.log.debug('topic: %s' % topic)
        self.log.debug('message: %s' % message)
        return group, forum, topic, message

    def _get_modes(self, req, group, forum, topic, message):
        # Get action
        component = req.args.get('component')
        action = req.args.get('discussion_action')
        preview = req.args.has_key('preview');
        submit = req.args.has_key('submit');
        self.log.debug('component: %s' % component)
        self.log.debug('action: %s' % action)

        if component == 'admin':
            req.hdf['discussion.href'] = req.href.admin('discussion')
        elif component == 'wiki':
            req.hdf['discussion.href'] = req.href(req.path_info)
        else:
            req.hdf['discussion.href'] = req.href.discussion()
        req.hdf['discussion.component'] = component

        # Determine mode
        if message:
            if component == 'admin':
                pass
            elif component == 'wiki':
                if action == 'add':
                    return ['wiki-message-list']
                elif action == 'quote':
                    return ['message-quote', 'wiki-message-list']
                elif action == 'post-add':
                    if preview:
                        return ['wiki-message-list']
                    else:
                        return ['message-post-add', 'wiki-message-list']
                elif action == 'edit':
                    return ['message-edit', 'wiki-message-list']
                elif action == 'post-edit':
                    if preview:
                        return ['wiki-message-list']
                    else:
                        return ['message-post-edit', 'wiki-message-list']
                elif action == 'delete':
                    return ['message-delete', 'wiki-message-list']
                elif action == 'set-display':
                    return ['message-set-display', 'wiki-message-list']
                else:
                    return ['wiki-message-list']
            else:
                if action == 'add':
                    return ['message-list']
                elif action == 'quote':
                    return ['message-quote', 'message-list']
                elif action == 'post-add':
                    if preview:
                        return ['message-list']
                    else:
                        return ['message-post-add', 'message-list']
                elif action == 'edit':
                    return ['message-edit', 'message-list']
                elif action == 'post-edit':
                    if preview:
                        return ['message-list']
                    else:
                        return ['message-post-edit', 'message-list']
                elif action == 'delete':
                    return ['message-delete', 'message-list']
                elif action == 'set-display':
                    return ['message-set-display', 'message-list']
                else:
                    return ['message-list']
        if topic:
            if component == 'admin':
                pass
            elif component == 'wiki':
                if action == 'add':
                    return ['wiki-message-list']
                elif action == 'quote':
                    return ['topic-quote','wiki-message-list']
                elif action == 'post-add':
                    if preview:
                        return ['wiki-message-list']
                    else:
                        return ['message-post-add', 'wiki-message-list']
                elif action == 'edit':
                    return ['topic-edit', 'wiki-message-list']
                elif action == 'post-edit':
                    if preview:
                        return ['wiki-message-list']
                    else:
                        return ['topic-post-edit', 'wiki-message-list']
                elif action == 'set-display':
                    return ['message-set-display', 'wiki-message-list']
                else:
                    return ['wiki-message-list']
            else:
                if action == 'add':
                    return ['message-list']
                elif action == 'quote':
                    return ['topic-quote', 'message-list']
                elif action == 'post-add':
                    if preview:
                        return ['message-list']
                    else:
                        return ['message-post-add', 'message-list']
                elif action == 'edit':
                    return ['topic-edit', 'message-list']
                elif action == 'post-edit':
                    if preview:
                        return ['message-list']
                    else:
                        return ['topic-post-edit', 'message-list']
                elif action == 'delete':
                    return ['topic-delete', 'topic-list']
                elif action == 'move':
                    return ['topic-move']
                elif action == 'post-move':
                    return ['topic-post-move', 'topic-list']
                elif action == 'set-display':
                    return ['message-set-display', 'message-list']
                else:
                    return ['message-list']
        elif forum:
            if component == 'admin':
                if action == 'post-edit':
                    return ['forum-post-edit', 'admin-forum-list']
                else:
                    return ['admin-forum-list']
            elif component == 'wiki':
                return ['wiki-message-list']
            else:
                if action == 'add':
                    return ['topic-add']
                elif action == 'post-add':
                    if preview:
                        return ['topic-add']
                    else:
                        return ['topic-post-add', 'topic-list']
                elif action == 'delete':
                    return ['forum-delete', 'forum-list']
                else:
                    return ['topic-list']
        elif group:
            if component == 'admin':
                if action == 'post-add':
                    return ['forum-post-add', 'admin-forum-list']
                elif action == 'post-edit':
                    return ['group-post-edit', 'admin-group-list']
                elif action == 'delete':
                    return ['forums-delete', 'admin-forum-list']
                else:
                    if group['id']:
                        return ['admin-group-list']
                    else:
                        return ['admin-forum-list']
            elif component == 'wiki':
                return ['wiki-message-list']
            else:
                if action == 'post-add':
                    return ['forum-post-add', 'forum-list']
                else:
                    return ['forum-list']
        else:
            if component == 'admin':
                if action == 'post-add':
                    return ['group-post-add', 'admin-group-list']
                elif action == 'delete':
                    return ['groups-delete', 'admin-group-list']
                else:
                    return ['admin-group-list']
            elif component == 'wiki':
                return ['wiki-message-list']
            else:
                if action == 'add':
                    return ['forum-add']
                elif action == 'post-add':
                    return ['forum-post-add', 'forum-list']
                else:
                    return ['forum-list']

    def _do_action(self, req, modes, group, forum, topic, message,
      is_moderator):

        # Get database access.
        db = self.env.get_db_cnx()
        cursor = db.cursor()

        for mode in modes:
            self.log.debug('doing %s mode action' % (mode,))
            if mode == 'group-list':
                req.perm.assert_permission('DISCUSSION_VIEW')

                # Display groups.
                req.hdf['discussion.groups'] = self.get_groups(req, cursor)

            elif mode == 'admin-group-list':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get form values
                order = req.args.get('order') or 'id'
                desc = req.args.get('desc')

                # Display groups.
                req.hdf['discussion.order'] = order
                req.hdf['discussion.desc'] = desc
                if group:
                    req.hdf['discussion.name'] = group['name']
                    req.hdf['discussion.description'] = \
                      group['description']
                req.hdf['discussion.groups'] = self.get_groups(req, cursor, order, desc)

            elif mode == 'group-add':
                req.perm.assert_permission('DISCUSSION_ADMIN')

            elif mode == 'group-post-add':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get form values.
                new_name = req.args.get('name')
                new_description = req.args.get('description')

                # Add new group.
                self.add_group(cursor, new_name, new_description)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'group-post-edit':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get form values.
                new_group = int(req.args.get('group') or 0)
                new_name = req.args.get('name')
                new_description = req.args.get('description')

                # Edit group.
                self.edit_group(cursor, new_group, new_name, new_description)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'group-delete':
                req.perm.assert_permission('DISCUSSION_ADMIN')

            elif mode == 'groups-delete':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get selected groups.
                selection = req.args.get('selection')
                if isinstance(selection, (str, unicode)):
                    selection = [selection]

                # Delete selected groups.
                if selection:
                    for group_id in selection:
                        self.delete_group(cursor, int(group_id))
                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'forum-list':
                req.perm.assert_permission('DISCUSSION_VIEW')

                # Get form values
                order = req.args.get('order') or 'id'
                asc = req.args.get('asc')

                # default to ASCending order here:
                if asc == None:
                    asc = 1;

                # Display forums.
                req.hdf['discussion.order'] = order
                req.hdf['discussion.asc'] = asc
                req.hdf['discussion.groups'] = self.get_groups(req, cursor)
                req.hdf['discussion.forums'] = self.get_forums(req, cursor, asc, order)

            elif mode == 'admin-forum-list':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get form values
                order = req.args.get('order') or 'id'
                asc = req.args.get('asc')
                # Default to ASCending order here
                if asc == None:
                    asc = 1

                # Display forums.
                req.hdf['discussion.order'] = order
                req.hdf['discussion.asc'] = asc
                if forum:
                    req.hdf['discussion.name'] = forum['name']
                    req.hdf['discussion.subject'] = forum['subject']
                    req.hdf['discussion.description'] = \
                      forum['description']
                    req.hdf['discussion.moderators'] = forum['moderators']
                    req.hdf['discussion.group'] = forum['group']
                req.hdf['discussion.users'] = self.get_users()
                req.hdf['discussion.groups'] = self.get_groups(req, cursor)
                req.hdf['discussion.forums'] = self.get_forums(req, cursor,
                  asc, order)

            elif mode == 'forum-add':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Display Add Forum form.
                req.hdf['discussion.users'] = self.get_users()
                req.hdf['discussion.groups'] = self.get_groups(req, cursor)

            elif mode == 'forum-post-add':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get form values
                new_name = req.args.get('name')
                new_author = req.authname
                new_subject = req.args.get('subject')
                new_description = req.args.get('description')
                new_moderators = req.args.get('moderators')
                new_group = int(req.args.get('group') or 0)
                if not new_moderators:
                    new_moderators = []
                if not isinstance(new_moderators, list):
                     new_moderators = [new_moderators]

                # Perform new forum add.
                self.add_forum(cursor, new_name, new_author, new_subject,
                   new_description, new_moderators, new_group)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'forum-post-edit':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get form values.
                new_forum = int(req.args.get('forum') or 0)
                new_name = req.args.get('name')
                new_subject = req.args.get('subject')
                new_description = req.args.get('description')
                new_moderators = req.args.get('moderators')
                new_group = int(req.args.get('group') or 0)
                if not new_moderators:
                    new_moderators = []
                if not isinstance(new_moderators, list):
                    new_moderators = [new_moderators]

                # Perform forum edit.
                self.edit_forum(cursor, new_forum, new_name, new_subject,
                  new_description, new_moderators, new_group)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'forum-delete':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Delete forum
                self.delete_forum(cursor, forum['id'])

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'forums-delete':
                req.perm.assert_permission('DISCUSSION_ADMIN')

                # Get selected forums.
                selection = req.args.get('selection')
                if isinstance(selection, (str, unicode)):
                    selection = [selection]

                # Delete selected forums.
                if selection:
                    for forum_id in selection:
                        self.delete_forum(cursor, int(forum_id))

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'topic-list':
                req.perm.assert_permission('DISCUSSION_VIEW')

                # Get form values
                order = req.args.get('order') or 'lastreply'
                asc = req.args.get('asc') or 0
                start = int(req.args.get('start') or 0)
                if start < 0:
                    start = 0

                # Display topics.
                req.hdf['discussion.order'] = order
                req.hdf['discussion.asc']  = asc

                req.hdf['discussion.topics'] = self.get_topics(req, cursor, forum['id'], start, order, asc)
                topic_count = self.get_topic_count( req, cursor, forum['id'] )
                req.hdf['discussion.topic_count'] = int(topic_count)

                # Create the paging links
                if start + self.topics_per_page < topic_count:
                    req.hdf['discussion.next_page'] = start + self.topics_per_page
                else:
                    req.hdf['discussion.next_page'] = ''

                if start > 0:
                    prev_start = start - self.topics_per_page
                    if prev_start < 0:
                        prev_start = 0
                    req.hdf['discussion.prev_page'] = prev_start
                else:
                    req.hdf['discussion.prev_page'] = ''

            elif mode == 'topic-add':
                req.perm.assert_permission('DISCUSSION_APPEND')

                # Get form values.
                new_subject = req.args.get('subject')
                new_author = req.args.get('author')
                new_body = req.args.get('body')

                # Display Add Topic form.
                if new_subject:
                    req.hdf['discussion.subject'] = wiki_to_oneliner(
                      new_subject, self.env)
                if new_author:
                    req.hdf['discussion.author'] = wiki_to_oneliner(
                     new_author, self.env)
                if new_body:
                    req.hdf['discussion.body'] = wiki_to_html(new_body,
                      self.env, req, None, False, True)

            elif mode == 'topic-quote':
                req.perm.assert_permission('DISCUSSION_APPEND')

                # Prepare old content.
                lines = topic['body'].splitlines()
                for I in xrange(len(lines)):
                    lines[I] = '> %s' % (lines[I])
                req.hdf['args.body'] = '\n'.join(lines)

            elif mode == 'topic-post-add':
                req.perm.assert_permission('DISCUSSION_APPEND')

                # Get form values.
                new_subject = req.args.get('subject')
                new_author = req.args.get('author')
                new_body = req.args.get('body')
                new_time = int(time.time())

                # Add topic.
                self.add_topic(cursor, forum['id'], new_subject, new_time,
                  new_author, new_body)

                # Get new topic and notify about creation.
                new_topic = self.get_topic_by_time(cursor, new_time)
                to = self.get_topic_to_recipients(cursor, new_topic['id'])
                cc = self.get_topic_cc_recipients(cursor, new_topic['id'])
                notifier = DiscussionNotifyEmail(self.env)
                notifier.notify(req, cursor, mode, forum, new_topic, None, to,
                  cc)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'topic-edit':
                req.perm.assert_permission('DISCUSSION_APPEND')
                if not is_moderator and (topic['author'] != req.authname):
                    raise PermissionError('Topic edit')

                # Prepare form values.
                req.args['subject'] = topic['subject']
                req.args['body'] = topic['body']
                req.hdf['args.subject'] = topic['subject']
                req.hdf['args.body'] = topic['body']

            elif mode == 'topic-post-edit':
                req.perm.assert_permission('DISCUSSION_APPEND')
                if not is_moderator and (topic['author'] != req.authname):
                    raise PermissionError('Topic edit')

                # Get form values.
                new_subject = req.args.get('subject')
                new_body = req.args.get('body')

                # Edit topic.
                topic['subject'] = new_subject
                topic['body'] = new_body
                self.edit_topic(cursor, topic['id'], topic['forum'],
                  new_subject, new_body)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'topic-move':
                req.perm.assert_permission('DISCUSSION_MODERATE')
                if not is_moderator:
                    raise PermissionError('Forum moderate')

                # Display Move Topic form
                req.hdf['discussion.forums'] = self.get_forums(req, cursor)

            elif mode == 'topic-post-move':
                req.perm.assert_permission('DISCUSSION_MODERATE')
                if not is_moderator:
                    raise PermissionError('Forum moderate')

                # Get form values
                new_forum = int(req.args.get('new_forum') or 0)

                # Move topic.
                self.set_forum(cursor, topic['id'], new_forum)

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'topic-delete':
                req.perm.assert_permission('DISCUSSION_MODERATE')
                if not is_moderator:
                    raise PermissionError('Forum moderate')

                # Delete topic.
                self.delete_topic(cursor, topic['id'])

                # Redirect request to prevent re-submit.
                db.commit()
                req.redirect(req.href.discussion('redirect', href =
                  req.path_info))

            elif mode == 'message-list':
                req.perm.assert_permission('DISCUSSION_VIEW')
                self._prepare_message_list(req, cursor, topic)

            elif mode == 'wiki-message-list':
                if topic:
                    self._prepare_message_list(req, cursor, topic)

            elif mode == 'message-quote':
                req.perm.assert_permission('DISCUSSION_APPEND')

                # Prepare old content.
                lines = message['body'].splitlines()
                for I in xrange(len(lines)):
                    lines[I] = '> %s' % (lines[I])
                req.hdf['args.body'] = '\n'.join(lines)

            elif mode == 'message-post-add':
                req.perm.assert_permission('DISCUSSION_APPEND')

                # Get form values.
                new_author = req.args.get('author')
                new_body = req.args.get('body')
                new_time = int(time.time())

                # Add message.
                if message:
                    self.add_message(cursor, forum['id'], topic['id'],
                      message['id'], new_time, new_author, new_body)
                else:
                    self.add_message(cursor, forum['id'], topic['id'], '-1',
                      new_time, new_author, new_body)

                # Get inserted message and notify about its creation.
                new_message = self.get_message_by_time(cursor, new_time)
                to = self.get_topic_to_recipients(cursor, topic['id'])
                cc = self.get_topic_cc_recipients(cursor, topic['id'])
                notifier = DiscussionNotifyEmail(self.env)
                notifier.notify(req, cursor, mode, forum, topic, new_message,
                  to, cc)

                # Redirect request to prevent re-submit.
                if req.args.get('component') != 'wiki':
                    db.commit()
                    req.redirect(req.href.discussion('redirect', href =
                      req.path_info))

            elif mode == 'message-edit':
                req.perm.assert_permission('DISCUSSION_APPEND')
                if not is_moderator and (message['author'] != req.authname):
                    raise PermissionError('Message edit')

                # Prepare form values.
                req.args['body'] = message['body']
                req.hdf['args.body'] = message['body']

            elif mode == 'message-post-edit':
                req.perm.assert_permission('DISCUSSION_APPEND')
                if not is_moderator and (message['author'] != req.authname):
                    raise PermissionError('Message edit')

                # Get form values.
                new_body = req.args.get('body')

                # Edit message.
                message['body'] = new_body
                self.edit_message(cursor, message['id'], message['forum'],
                  message['topic'], message['replyto'], new_body)

                # Redirect request to prevent re-submit.
                if req.args.get('component') != 'wiki':
                    db.commit()
                    req.redirect(req.href.discussion('redirect', href =
                      req.path_info))

            elif mode == 'message-delete':
                req.perm.assert_permission('DISCUSSION_MODERATE')
                if not is_moderator:
                    raise PermissionError('Forum moderate')

                # Delete message.
                self.delete_message(cursor, message['id'])

                # Redirect request to prevent re-submit.
                if req.args.get('component') != 'wiki':
                    db.commit()
                    req.redirect(req.href.discussion('redirect', href =
                      req.path_info))

            elif mode == 'message-set-display':
                req.perm.assert_permission('DISCUSSION_VIEW')

                # Get form values
                display = req.args.get('display')

                # Set message list display mode to session
                req.session['message-list-display'] = display
        # Commit database changes.
        db.commit()

    def _prepare_message_list(self, req, cursor, topic):
        # Get form values.
        new_author = req.args.get('author')
        new_subject = req.args.get('subject')
        new_body = req.args.get('body')

        # Get time when topic was visited from session.
        visited = eval(req.session.get('visited-topics') or '{}')
        if visited.has_key(topic['id']):
            visit_time = int(visited[topic['id']])
        else:
            visit_time = 0

        # Update this topic visit time and save to session.
        visited[topic['id']] = int(time.time())
        req.session['visited-topics'] = to_unicode(visited)

        # Mark new topic.
        if int(topic['time']) > visit_time:
            topic['new'] = True

        # Prepare display of topic
        if new_author:
            req.hdf['discussion.author'] = wiki_to_oneliner(new_author,
              self.env)
        if new_subject:
            req.hdf['discussion.subject'] = wiki_to_oneliner(new_subject,
              self.env)
        if new_body:
            req.hdf['discussion.body'] = wiki_to_html(new_body, self.env, req, None, False, True)

        # Prepare display of messages
        display = req.session.get('message-list-display')
        req.hdf['discussion.display'] = display
        if display == 'flat-asc':
            req.hdf['discussion.messages'] = self.get_flat_messages(req, cursor,
              topic['id'], visit_time)
        elif display == 'flat-desc':
            req.hdf['discussion.messages'] = self.get_flat_messages(req, cursor,
              topic['id'], visit_time, 'ORDER BY time DESC')
        else:
            req.hdf['discussion.messages'] = self.get_messages(req, cursor,
             topic['id'], visit_time)

    # Get one item functions

    def get_message(self, cursor, id):
        columns = ('id', 'forum', 'topic', 'replyto', 'time', 'author', 'body')
        sql = "SELECT id, forum, topic, replyto, time, author, body FROM" \
          " message WHERE id = %s"
        self.log.debug(sql % (id,))
        cursor.execute(sql, (id,))
        for row in cursor:
            row = dict(zip(columns, row))
            return row
        return None

    def get_message_by_time(self, cursor, time):
        columns = ('id', 'forum', 'topic', 'replyto', 'time', 'author', 'body')
        sql = "SELECT id, forum, topic, replyto, time, author, body FROM" \
          " message WHERE time = %s"
        self.log.debug(sql % (time,))
        cursor.execute(sql, (time,))
        for row in cursor:
            row = dict(zip(columns, row))
            return row
        return None

    def get_topic(self, cursor, id):
        columns = ('id', 'forum', 'subject', 'time', 'author', 'body')
        sql = "SELECT id, forum, subject, time, author, body FROM topic WHERE" \
          " id = %s"
        self.log.debug(sql % (id,))
        cursor.execute(sql, (id,))
        for row in cursor:
            row = dict(zip(columns, row))
            return row
        return None

    def get_topic_by_time(self, cursor, time):
        columns = ('id', 'forum', 'subject', 'time', 'author', 'body')
        sql = "SELECT id, forum, subject, time, author, body FROM topic WHERE" \
          " time = %s"
        self.log.debug(sql % (time,))
        cursor.execute(sql, (time,))
        for row in cursor:
            row = dict(zip(columns, row))
            return row
        return None

    def get_topic_by_subject(self, cursor, subject):
        columns = ('id', 'forum', 'subject', 'time', 'author', 'body')
        sql = "SELECT id, forum, subject, time, author, body FROM topic WHERE" \
          " subject = '%s'" % (subject)
        self.log.debug(sql)
        cursor.execute(sql)
        for row in cursor:
            row = dict(zip(columns, row))
            return row
        return None

    def get_topic_to_recipients(self, cursor, id):
        sql = "SELECT t.author FROM topic t WHERE t.id = %s UNION SELECT" \
          " m.author FROM message m WHERE m.topic = %s"
        self.log.debug(sql % (id, id))
        cursor.execute(sql, (id, id))
        to_recipients = []
        for row in cursor:
            to_recipients.append(row[0])
        self.log.debug(to_recipients)
        return to_recipients

    def get_topic_cc_recipients(self, cursor, id):
        cc_recip = to_unicode( "forum_alert@getpopfile.org" );
        return [cc_recip]
#        return []

    def get_forum(self, cursor, id):
        columns = ('id', 'group', 'name', 'subject', 'time', 'moderators',
          'description')
        sql = "SELECT id, forum_group, name, subject, time, moderators," \
           " description FROM forum WHERE id = %s"
        self.log.debug(sql % (id,))
        cursor.execute(sql, (id,))
        for row in cursor:
            row = dict(zip(columns, row))
            row['moderators'] = row['moderators'].split(' ')
            return row
        return None

    def get_group(self, cursor, id):
        columns = ('id', 'name', 'description')
        sql = "SELECT id, name, description FROM forum_group WHERE id = %s"
        self.log.debug(sql % (id,))
        cursor.execute(sql, (id,))
        for row in cursor:
            row = dict(zip(columns, row))
            return row
        return {'id' : 0, 'name': 'None', 'description': 'No Group'}

    # Set item functions

    def set_group(self, cursor, forum, group):
        if not group:
            group = '0'
        sql = "UPDATE forum SET forum_group = %s WHERE id = %s"
        self.log.debug(sql % (group, forum))
        cursor.execute(sql, (group, forum))

    def set_forum(self, cursor, topic, forum):
        sql = "UPDATE topic SET forum = %s WHERE id = %s"
        self.log.debug(sql % (forum, topic))
        cursor.execute(sql, (forum, topic))
        sql = "UPDATE message SET forum = %s WHERE topic = %s"
        self.log.debug(sql % (forum, topic))
        cursor.execute(sql, (forum, topic))

    # Edit all functons

    def edit_group(self, cursor, group, name, description):
        sql = "UPDATE forum_group SET name = %s, description = %s WHERE id = %s"
        self.log.debug(sql % (name, description, group))
        cursor.execute(sql, (name, description, group))

    def edit_forum(self, cursor, forum, name, subject, description, moderators,
      group):
        moderators = ' '.join(moderators)
        if not group:
            group = '0'
        sql = "UPDATE forum SET name = %s, subject = %s, description = %s," \
          " moderators = %s, forum_group = %s WHERE id = %s"
        self.log.debug(sql % (name, subject, description, moderators,
          group, forum))
        cursor.execute(sql, (name, subject, description, moderators, group,
          forum))

    def edit_topic(self, cursor, topic, forum, subject, body):
        sql = "UPDATE topic SET forum = %s, subject = %s, body = %s WHERE id" \
          " = %s"
        self.log.debug(sql % (forum, subject, body, topic))
        cursor.execute(sql, (forum, subject, body, topic))

    def edit_message(self, cursor, message, forum, topic, replyto, body):
        sql = "UPDATE message SET forum = %s, topic = %s, replyto = %s, body" \
          " = %s WHERE id = %s"
        self.log.debug(sql % (forum, topic, replyto, body, message))
        cursor.execute(sql, (forum, topic, replyto, body, message))

    # Get list functions

    def get_groups(self, req, cursor, order_by = 'id', desc = False):
        # Get count of forums without group
        sql = "SELECT COUNT(f.id) FROM forum f WHERE f.forum_group = 0"
        self.log.debug(sql)
        cursor.execute(sql)
        no_group_forums = 0
        for row in cursor:
            no_group_forums = row[0]
        groups = [{'id' : 0, 'name' : 'None', 'description' : 'No Group',
          'forums' : no_group_forums}]

        # Get forum groups
        if order_by != 'forum':
            order_by = 'g.' + order_by
        columns = ('id', 'name', 'description', 'forums')
        sql = "SELECT g.id, g.name, g.description, f.forums FROM " \
          " forum_group g LEFT JOIN (SELECT COUNT(id) AS forums, " \
          " forum_group FROM forum GROUP BY forum_group) f ON g.id = " \
          " f.forum_group ORDER BY " + order_by + (" ASC",
          " DESC")[bool(desc)]
        self.log.debug(sql)
        cursor.execute(sql)
        for row in cursor:
            row = dict(zip(columns, row))
            row['name'] = wiki_to_oneliner(row['name'], self.env)
            row['description'] = wiki_to_oneliner(row['description'], self.env)
            groups.append(row)
        return groups

    def get_forums(self, req, cursor, asc=0, order_by = 'subject'):
        if not order_by in ('topics', 'replies', 'lasttopic', 'lastreply'):
            order_by = 'f.' + order_by
        columns = ('id', 'name', 'author', 'time', 'moderators', 'group',
          'subject', 'description', 'topics', 'replies', 'lasttopic',
          'lastreply')
        sql = "SELECT f.id, f.name, f.author, f.time, f.moderators, " \
          "f.forum_group, f.subject, f.description, ta.topics, ta.replies, " \
          "ta.lasttopic, ta.lastreply FROM forum f LEFT JOIN (SELECT " \
          "COUNT(t.id) AS topics, MAX(t.time) AS lasttopic, SUM(ma.replies) " \
          "AS replies, MAX(ma.lastreply) AS lastreply, t.forum AS forum FROM " \
          " topic t LEFT JOIN (SELECT COUNT(m.id) AS replies, MAX(m.time) AS " \
          "lastreply, m.topic AS topic FROM message m GROUP BY m.topic) ma ON " \
          "t.id = ma.topic GROUP BY forum) ta ON f.id = ta.forum ORDER BY " + \
          order_by + (" DESC", " ASC")[int(asc)]
        self.log.debug(sql)
        cursor.execute(sql)
        forums = []
        for row in cursor:
            row = dict(zip(columns, row))
            row['moderators'] = wiki_to_oneliner(row['moderators'], self.env)
            row['description'] = wiki_to_oneliner(row['description'], self.env)
            if row['lastreply']:
                row['lastreply'] = pretty_timedelta(float(row['lastreply']))
            else:
                row['lastreply'] = 'No replies'
            if row['lasttopic']:
                self.log.debug('lasttopic: %s' % row['lasttopic'])
                row['lasttopic'] = pretty_timedelta(float(row['lasttopic']))
            else:
                row['lasttopic'] = 'No topics'
            if not row['topics']:
                row['topics'] = 0
            if not row['replies']:
                row['replies'] = 0
            else:
                # SUM on PosgreSQL returns float number.
                row['replies'] = int(row['replies'])
            row['time'] = format_datetime(row['time'])
            forums.append(row)
        return forums

    def get_topic_count(self, req, cursor, forum_id):
        sql = "SELECT COUNT(*) FROM topic WHERE forum = %s"
        self.log.debug(sql % (forum_id,))
        cursor.execute( sql, (forum_id,))
        row = cursor.fetchone()
        columns = ('count',)
        count = row[0]
        self.log.debug( "Topic count is %d" % count )
        return count

    def get_topics(self, req, cursor, forum_id, start_at, order_by = 'lastreply', asc = 0):
        if not order_by in ('replies', 'lastreply',):
            order_by = 't.' + order_by
        columns = ('id', 'forum', 'time', 'subject', 'body', 'author',
          'replies', 'lastreply')
        sql = "SELECT t.id, t.forum, t.time, t.subject, t.body, t.author," \
          " m.replies, t.lastreply FROM topic t LEFT JOIN (SELECT COUNT(id)" \
          " AS replies, topic FROM message GROUP BY" \
          " topic) m ON t.id = m.topic WHERE t.forum = %s ORDER BY " \
          + order_by + (" DESC", " ASC")[int(asc)] + " LIMIT %s,%s"

        self.log.debug(sql % (forum_id, start_at, self.topics_per_page))
        cursor.execute(sql, (forum_id, start_at, self.topics_per_page) )

        topics = []
        for row in cursor:
            row = dict(zip(columns, row))
            row['author'] = wiki_to_oneliner(row['author'], self.env)
            row['body'] = wiki_to_html(row['body'], self.env, req, None, False, True)
            if row['lastreply']:
                row['lastreply'] = pretty_timedelta(float(row['lastreply']))
            else:
                row['lastreply'] = 'No replies'
            if not row['replies']:
                row['replies'] = 0
            row['time'] = format_datetime(row['time'])
            topics.append(row)
        return topics

    def get_messages(self, req, cursor, topic_id, time, order_by = 'time', desc = False):
        order_by = 'm.' + order_by
        columns = ('id', 'replyto', 'time', 'author', 'body')
        sql = "SELECT m.id, m.replyto, m.time, m.author, m.body FROM message m WHERE" \
          " m.topic = %s ORDER BY " + order_by + (" ASC", " DESC")[bool(desc)]
        self.log.debug(sql % (topic_id,))
        cursor.execute(sql, (topic_id,))
        messagemap = {}
        messages = []
        for row in cursor:
            row = dict(zip(columns, row))
            row['author'] = wiki_to_oneliner(row['author'], self.env)
            row['body'] = wiki_to_html(row['body'], self.env, req, None, False, True)
            if int(row['time']) > time:
                row['new'] = True
            row['time'] = format_datetime(row['time'])
            messagemap[row['id']] = row

            # Add top-level messages to the main list, in order of time
            if row['replyto'] == -1:
                messages.append(row)

        # Second pass, add replies
        for message in messagemap.values():
            if message['replyto'] != -1:
                parent = messagemap[message['replyto']]
                if 'replies' in parent:
                    parent['replies'].append(message)
                else:
                    parent['replies'] = [message]
        return messages;

    def get_flat_messages(self, req, cursor, topic_id, time, order_by =
      'ORDER BY time ASC'):
        columns = ('id', 'replyto', 'time', 'author', 'body')
        sql = "SELECT m.id, m.replyto, m.time, m.author, m.body FROM message m" \
          " WHERE m.topic = %s " + order_by
        self.log.debug(sql % (topic_id,))
        cursor.execute(sql, (topic_id,))
        messages = []
        for row in cursor:
            row = dict(zip(columns, row))
            row['author'] = wiki_to_oneliner(row['author'], self.env)
            row['body'] = wiki_to_html(row['body'], self.env, req, None, False, True)
            if int(row['time']) > time:
                row['new'] = True
            row['time'] = format_datetime(row['time'])
            messages.append(row)
        return messages

    def get_users(self):
        users = []
        for user in self.env.get_known_users():
            users.append(user[0])
        return users

    # Add items functions

    def add_group(self, cursor, name, description):
        sql = "INSERT INTO forum_group (name, description) VALUES (%s, %s)"
        self.log.debug(sql % (name, description))
        cursor.execute(sql, (name, description))

    def add_forum(self, cursor, name, author, subject, description, moderators,
      group):
        moderators = ' '.join(moderators)
        sql = "INSERT INTO forum (name, author, time, moderators, subject," \
          " description, forum_group) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        self.log.debug(sql % (name, author, int(time.time()), moderators,
          subject, description, group))
        cursor.execute(sql, (name, author, int(time.time()), moderators,
          subject, description, group))

    def add_topic(self, cursor, forum, subject, time, author, body):
        sql = "INSERT INTO topic (forum, subject, time, author, body, lastreply) VALUES" \
          " (%s, %s, %s, %s, %s, %s)"
        self.log.debug(sql % (forum, subject, time, author, body, time))
        cursor.execute(sql, (forum, subject, time, author, body, time))

    def add_message(self, cursor, forum, topic, replyto, time, author, body):
        sql = "INSERT INTO message (forum, topic, replyto, time, author," \
          " body) VALUES (%s, %s, %s, %s, %s, %s)"
        self.log.debug(sql % (forum, topic, replyto, time, author, body))
        cursor.execute(sql, (forum, topic, replyto, time, author, body))

        sql = "UPDATE topic SET lastreply = %s WHERE id = %s"
        self.log.debug( sql % (time, topic))
        cursor.execute( sql, (time, topic) )

    # Delete items functions

    def delete_group(self, cursor, group):
        sql = "DELETE FROM forum_group WHERE id = %s"
        self.log.debug(sql % (group,))
        cursor.execute(sql, (group,))
        sql = "UPDATE forum SET forum_group = 0 WHERE forum_group = %s"
        self.log.debug(sql % (group,))
        cursor.execute(sql, (group,))

    def delete_forum(self, cursor, forum):
        sql = "DELETE FROM message WHERE forum = %s"
        self.log.debug(sql % (forum,))
        cursor.execute(sql, (forum,))
        sql = "DELETE FROM topic WHERE forum = %s"
        self.log.debug(sql % (forum,))
        cursor.execute(sql, (forum,))
        sql = "DELETE FROM forum WHERE id = %s"
        self.log.debug(sql % (forum,))
        cursor.execute(sql, (forum,))

    def delete_topic(self, cursor, topic):
        sql = "DELETE FROM message WHERE topic = %s"
        self.log.debug(sql % (topic,))
        cursor.execute(sql, (topic,))
        sql = "DELETE FROM topic WHERE id = %s"
        self.log.debug(sql % (topic,))
        cursor.execute(sql, (topic,))

    def delete_message(self, cursor, message):
        # Get message replies
        sql = "SELECT m.id FROM message m WHERE m.replyto = %s"
        self.log.debug(sql % (message,))
        cursor.execute(sql, (message,))
        replies = []

        # Get all replies first.
        for row in cursor:
            replies.append(row[0])

        # Delete all replies
        for reply in replies:
            self.delete_message(cursor, reply)

        # Delete message itself
        sql = "DELETE FROM message WHERE id = %s"
        self.log.debug(sql % (message,))
        cursor.execute(sql, (message,))
