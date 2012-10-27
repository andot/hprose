############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.net/                 #
#                   http://www.hprose.org/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# hprose/httpserver.py                                     #
#                                                          #
# hprose httpserver for python 3.0+                        #
#                                                          #
# LastModified: Oct 28, 2012                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

import re, urllib.parse
from io import BytesIO
from sys import exc_info
from hprose.io import *
from hprose.server import HproseService

class HproseHttpService(HproseService):
    def __init__(self, sessionName = None):
        super(HproseHttpService, self).__init__()
        self._crossDomain = False;
        self._P3P = False
        self._get = True
        self.sessionName = sessionName     

    def __call__(self, environ, start_response = None):
        result = self.handle(environ)
        # WSGI 2
        if start_response == None:
            return result
        # WSGI 1
        start_response(result[0], result[1])
        return result[2]

    def _header(self, environ):
        header = [(b'Content-Type', b'text/plain')]
        if self._P3P:
            header.append((b'P3P', b'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD ' +
                         'IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi ' +
                         'PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT ' +
                         'STA POL HEA PRE GOV"'))
        if self._crossDomain:
            origin = environ.get("HTTP_ORIGIN", "null")
            if origin != "null":
                header.append((b"Access-Control-Allow-Origin", origin.encode("utf-8")))
                header.append((b"Access-Control-Allow-Credentials", b"true"))
            else:
                header.append((b"Access-Control-Allow-Origin", b"*"))
        if self.onSendHeader != None:
            self.onSendHeader(environ, header)
        return header

    def handle(self, environ):
        sessionService = environ.get(self.sessionName, None)
        if sessionService:
            session = getattr(sessionService, 'session', sessionService)
        else:
            session = {}
        header = self._header(environ)
        stream = BytesIO()
        writer = HproseWriter(stream)
        if (environ['REQUEST_METHOD'] == 'GET'):
            self._doFunctionList(writer)
            body = stream.getvalue()
            stream.close()
            return [b'200 OK', header, [body]]
        try:
            reader = HproseReader(environ['wsgi.input'])
            self._handle(reader, writer, session, environ)
        finally:
            if hasattr(session, 'save'): session.save()
            stream = writer.stream
            body = stream.getvalue()
            stream.close()
            return [b'200 OK', header, [body]]

    def isCrossDomainEnabled(self):
        return self._crossDomain

    def setCrossDomainEnabled(self, enable = True):
        self._crossDomain = enable

    def isP3PEnabled(self):
        return self._P3P

    def setP3PEnabled(self, enable = True):
        self._P3P = enable

    def isGetEnabled(self):
        return self._get

    def setGetEnabled(self, enable = True):
        self._get = enable
        
################################################################################
# UrlMapMiddleware                                                             #
################################################################################

class UrlMapMiddleware:
    def __init__(self, url_mapping):
        self.__init_url_mappings(url_mapping)

    def __init_url_mappings(self, url_mapping):
        self.__url_mapping = []
        for regexp, app in url_mapping:
            if not regexp.startswith('^'):
                regexp = '^' + regexp
            if not regexp.endswith('$'):
                regexp += '$'
            compiled = re.compile(regexp)
            self.__url_mapping.append((compiled, app))

    def __call__(self, environ, start_response = None):
        script_name = environ['SCRIPT_NAME']
        path_info = environ['PATH_INFO']
        path = urllib.parse.quote(script_name) + urllib.parse.quote(path_info)
        for regexp, app in self.__url_mapping:
            if regexp.match(path): return app(environ, start_response)
        if start_response:
            start_response(b'404 Not Found', [(b'Content-Type', b'text/plain')])
            return [b'404 Not Found']
        return (b'404 Not Found', [(b'Content-Type', b'text/plain')], [b'404 Not Found'])

################################################################################
# HproseHttpServer                                                             #
################################################################################

class HproseHttpServer(object):
    def __init__(self, host = '', port = 80, app = None):
        self.host = host
        self.port = port
        if app == None:
            self.app = HproseHttpService()
        else:
            self.app = app

    def add(self, *args):
        self.app.add(*args)

    def addMissingFunction(self, function, resultMode = HproseResultMode.Normal):
        self.app.addMissingFunction(function, resultMode)

    def addFunction(self, function, alias = None, resultMode = HproseResultMode.Normal):
        self.app.addFunction(function, alias, resultMode)

    def addFunctions(self, functions, aliases = None, resultMode = HproseResultMode.Normal):
        self.app.addFunctions(functions, aliases, resultMode)

    def addMethod(self, methodname, belongto, alias = None, resultMode = HproseResultMode.Normal):
        self.app.addMethod(methodname, belongto, alias, resultMode)

    def addMethods(self, methods, belongto, aliases = None, resultMode = HproseResultMode.Normal):
        self.app.addMethods(methods, belongto, aliases, resultMode)

    def addInstanceMethods(self, obj, cls = None, aliasPrefix = None, resultMode = HproseResultMode.Normal):
        self.app.addInstanceMethods(obj, cls, aliasPrefix, resultMode)

    def addClassMethods(self, cls, execcls = None, aliasPrefix = None, resultMode = HproseResultMode.Normal):
        self.app.addClassMethods(cls, execcls, aliasPrefix, resultMode)

    def addStaticMethods(self, cls, aliasPrefix = None, resultMode = HproseResultMode.Normal):
        self.app.addStaticMethods(cls, aliasPrefix, resultMode)

    def isDebugEnabled(self):
        return self.app.isDebugEnabled()

    def setDebugEnabled(self, enable = True):
        self.app.setDebugEnabled(enable)

    def isP3PEnabled(self):
        return self.app.isP3PEnabled()

    def setP3PEnabled(self, enable = True):
        self.app.setP3PEnabled(enable)

    def isGetEnabled(self):
        return self.app.isGetEnabled()

    def setGetEnabled(self, enable = True):
        self.app.setGetEnabled(enable)

    def start(self):
        print("Serving on port %s:%s..." % (self.host, self.port))
        from wsgiref.simple_server import make_server
        httpd = make_server(self.host, self.port, self.app)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            exit()
