# -*- coding: utf8 -*-

from tracdiscussion.api import *
from trac.core import *
from trac.web.chrome import INavigationContributor, ITemplateProvider
from trac.web.main import IRequestHandler
from trac.config import Option, IntOption
from trac.perm import IPermissionRequestor
from trac.util.html import html
import re

class DiscussionCore(Component):
    """
        The core module implements a message board, including wiki links to
        discussions, topics and messages.
    """
    implements(INavigationContributor, IRequestHandler, ITemplateProvider,
      IPermissionRequestor)
    topics_per_page = IntOption('discussion', 'topics_per_page', 20,
      'The number of topics to display on each page inside a forum' )
    title = Option('discussion', 'title', 'Discussion',
      'Main navigation bar button title.')

    # IPermissionRequestor methods
    def get_permission_actions(self):
        return ['DISCUSSION_VIEW', 'DISCUSSION_APPEND', 'DISCUSSION_MODERATE',
          'DISCUSSION_ADMIN']

    # ITemplateProvider methods
    def get_htdocs_dirs(self):
        from pkg_resources import resource_filename
        return [('discussion', resource_filename(__name__, 'htdocs'))]

    def get_templates_dirs(self):
        from pkg_resources import resource_filename
        return [resource_filename(__name__, 'templates')]

    # INavigationContributor methods
    def get_active_navigation_item(self, req):
        return 'discussion'

    def get_navigation_items(self, req):
        if req.perm.has_permission('DISCUSSION_VIEW'):
            yield 'mainnav', 'discussion', html.a(self.title,
              href = req.href.discussion())

    # IRequestHandler methods
    def match_request(self, req):
        if req.path_info == '/discussion/redirect':
            # Proces redirection request.
            self.log.debug(req.path_info)
            self.log.debug(req.args.get('href'))
            req.redirect(req.href(req.args.get('href')))
        else:
            # Prepare regular requests.
            match = re.match(r'''/discussion(?:/?$|/(\d+)(?:/?$|/(\d+))(?:/?$|/(\d+)))$''',
          req.path_info)
        if match:
            forum = match.group(1)
            topic = match.group(2)
            message = match.group(3)
            if forum:
                req.args['forum'] = forum
            if topic:
                req.args['topic'] = topic
            if message:
                req.args['message'] = message
        return match

    def process_request(self, req):
        # Prepare request object
        req.args['component'] = 'core'

        # Return page content
        api = DiscussionApi(self, req)
        return api.render_discussion(req)
