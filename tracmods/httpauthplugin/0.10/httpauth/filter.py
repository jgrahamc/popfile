from trac.core import *
from trac.config import ListOption
from trac.web.api import IRequestFilter, RequestDone, IAuthenticator
from trac.web.chrome import INavigationContributor

try:  
    from base64 import b64decode  
except ImportError:  
    from base64 import decodestring as b64decode

from acct_mgr.api import AccountManager

__all__ = ['HTTPAuthFilter']

class HTTPAuthFilter(Component):
    """Request filter and handler to provide HTTP authentication."""
    
    paths = ListOption('httpauth', 'paths', default='/login/xmlrpc',
                       doc='Paths to force HTTP authentication on.')
    
    formats = ListOption('httpauth', 'formats', doc='Request formats to force HTTP authentication on')
    
    implements(IRequestFilter, IAuthenticator)

    # IRequestFilter methods
    def pre_process_request(self, req, handler):
        check = False
        for path in self.paths:
            if req.path_info.startswith(path):
                check = True
                break
        if req.args.get('format') in self.formats:
            check = True
        if check and not self._check_password(req):
            self.log.info('HTTPAuthFilter: No/bad authentication data given, returing 403')
            return self
        return handler
        
    def post_process_request(self, req, template, content_type):
        return template, content_type

    # IRequestHandler methods (sort of)       
    def process_request(self, req):
        if req.session:
            req.session.save() # Just in case
        
        req.send_response(401)
        req.send_header('WWW-Authenticate', 'Basic realm="Control Panel"')
        req.send_header('Content-Type', 'text/plain')
        req.send_header('Pragma', 'no-cache')
        req.send_header('Cache-control', 'no-cache')
        req.send_header('Expires', 'Fri, 01 Jan 1999 00:00:00 GMT')
        req.end_headers()
        
        if req.method != 'HEAD':
            req.write('Authentication required')
        raise RequestDone

   # IAuthenticator methods
    def authenticate(self, req):
        if req.remote_user:
            return req.remote_user
        for path in self.paths:
            if req.path_info.startswith(path):
                header = req.get_header('Authorization')
                if header is None:
                    self.log.info('HTTPAuthFilter: No authentication data given, returing 403')
                    return None # Run HTTP auth
                else:
                    token = header.split()[1]
                    user, passwd = b64decode(token).split(':', 1)
                    if AccountManager(self.env).check_password(user, passwd):
                        self.log.debug('HTTPAuthFilter: Authentication okay')
                        # req.environ['REMOTE_USER'] = user
                        # self.log.debug(req.remote_user)
                        return user
                    else:
                        self.log.info('HTTPAuthFilter: Bad authentication data given, returing 403')
                        return None # Failed auth
        return None
            
    # Internal methods
    def _check_password(self, req):
        header = req.get_header('Authorization')
        if header:
            token = header.split()[1]
            user, passwd = b64decode(token).split(':', 1)
            if AccountManager(self.env).check_password(user, passwd):
                return user
