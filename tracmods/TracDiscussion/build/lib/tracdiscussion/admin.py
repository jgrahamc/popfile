# -*- coding: utf8 -*-

from tracdiscussion.api import *
from trac.core import *
from trac.perm import IPermissionRequestor
from trac.web.chrome import add_stylesheet
from trac.wiki import wiki_to_html, wiki_to_oneliner
from webadmin.web_ui import IAdminPageProvider
from trac.config import IntOption
import time

class DiscussionWebAdmin(Component):
    """
        The webadmin module implements discussion plugin administration
        via WebAdminPlugin.
    """
    implements(IAdminPageProvider)

    topics_per_page = IntOption('discussion', 'topics_per_page', 20,
      'The number of topics to display on each page inside a forum' )

    # IAdminPageProvider
    def get_admin_pages(self, req):
        if req.perm.has_permission('DISCUSSION_ADMIN'):
            yield ('discussion', 'Discussion System', 'group', 'Forum Groups')
            yield ('discussion', 'Discussion System', 'forum', 'Forums')

    def process_admin_request(self, req, category, page, path_info):
        # Prepare request object
        if page == 'forum':
            if not req.args.has_key('group'):
                req.args['group'] = '-1'
            if path_info:
                req.args['forum'] = path_info
        else:
            if path_info:
                req.args['group'] = path_info
        req.args['component'] = 'admin'

        # Retrun page content
        api = DiscussionApi(self, req)
        return api.render_discussion(req)
