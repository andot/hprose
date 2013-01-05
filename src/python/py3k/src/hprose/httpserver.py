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
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

import re, urllib.parse, datetime
from math import trunc
from random import random
from io import BytesIO
from sys import exc_info
from hprose.io import *
from hprose.common import *
from hprose.server import HproseService

class HproseHttpService(HproseService):
    def __init__(self, sessionName = None):
        super(HproseHttpService, self).__init__()
        self._crossDomain = False;
        self._P3P = False
        self._get = True
        self._crossDomainXmlFile = None
        self._crossDomainXmlContent = None
        self._clientAccessPolicyXmlFile = None
        self._clientAccessPolicyXmlContent = None
        self._lastModified = datetime.datetime.utcnow().strftime("%a, %d %b %Y %H:%M:%S GMT");
        self._etag = '"%x:%x"' % (trunc(random() * 2147483647), trunc(random() * 2147483647));
        self.sessionName = sessionName     

    def __call__(self, environ, start_response = None):
        result = self.handle(environ)
        # WSGI 2
        if start_response == None:
            return result
        # WSGI 1
        start_response(result[0], result[1])
        return result[2]

    def _crossDomainXmlHandler(self, environ):
        path = (environ['SCRIPT_NAME'] + environ['PATH_INFO']).lower()
        if (path == '/crossdomain.xml'):
            if ((environ.get('HTTP_IF_MODIFIED_SINCE', '') == self._lastModified) and
                (environ.get('HTTP_IF_NONE_MATCH', '') == self._etag)):
                return [b'304 Not Modified', [], [b'']]
            else:
                header = [(b'Content-Type', b'text/xml'),
                          (b'Last-Modified', self._lastModified.encode("utf-8")),
                          (b'Etag', self._etag.encode("utf-8"))]
                return [b'200 OK', header, [self._crossDomainXmlContent.encode("utf-8")]]
        return False;

    def _clientAccessPolicyXmlHandler(self, environ):
        path = (environ['SCRIPT_NAME'] + environ['PATH_INFO']).lower()
        if (path == '/clientaccesspolicy.xml'):
            if ((environ.get('HTTP_IF_MODIFIED_SINCE', '') == self._lastModified) and
                (environ.get('HTTP_IF_NONE_MATCH', '') == self._etag)):
                return [b'304 Not Modified', [], [b'']]
            else:
                header = [(b'Content-Type', b'text/xml'),
                          (b'Last-Modified', self._lastModified.encode("utf-8")),
                          (b'Etag', self._etag.encode("utf-8"))]
                return [b'200 OK', header, [self.m_clientAccessPolicyXmlContent.encode("utf-8")]]
        return False;

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
        if (self._clientAccessPolicyXmlContent != None):
            result = self._clientAccessPolicyXmlHandler(environ)
            if (result):
                return result
        if (self._crossDomainXmlContent != None):
            result = self._crossDomainXmlHandler(environ)
            if (result):
                return result
        sessionService = environ.get(self.sessionName, None)
        if sessionService:
            session = getattr(sessionService, 'session', sessionService)
        else:
            session = {}
        header = self._header(environ)
        writer = HproseWriter(self._filter.outputFilter(BytesIO()))
        try:
            if (environ['REQUEST_METHOD'] == 'GET') and self._get):
                self._doFunctionList(writer)
            elif (environ['REQUEST_METHOD'] == 'POST'):
                reader = HproseReader(self._filter.inputFilter(environ['wsgi.input']))
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

    def getCrossDomainXmlFile(self):
        return self._crossDomainXmlFile

    def setCrossDomainXmlFile(self, value):
        self._crossDomainXmlFile = value
        f = open(value)
        try:
            self._crossDomainXmlContent = f.read()
        finally:
            f.close()

    def getCrossDomainXmlContent(self):
        return self._crossDomainXmlContent

    def setCrossDomainXmlContent(self, value):
        self._crossDomainXmlFile = None
        self._crossDomainXmlContent = value

    def getClientAccessPolicyXmlFile(self):
        return self._clientAccessPolicyXmlFile

    def setClientAccessPolicyXmlFile(self, value):
        self._clientAccessPolicyXmlFile = value
        f = open(value)
        try:
            self._clientAccessPolicyXmlContent = f.read()
        finally:
            f.close()

    def getClientAccessPolicyXmlContent(self):
        return self._clientAccessPolicyXmlContent

    def setClientAccessPolicyXmlContent(self, value):
        self._clientAccessPolicyXmlFile = None
        self._clientAccessPolicyXmlContent = value

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

    def isCrossDomainEnabled(self):
        return self.app.isCrossDomainEnabled()

    def setCrossDomainEnabled(self, enable = True):
        self.app.setCrossDomainEnabled(enable)

    def isP3PEnabled(self):
        return self.app.isP3PEnabled()

    def setP3PEnabled(self, enable = True):
        self.app.setP3PEnabled(enable)

    def isGetEnabled(self):
        return self.app.isGetEnabled()

    def setGetEnabled(self, enable = True):
        self.app.setGetEnabled(enable)

    def getFilter(self):
        return self.app.getFilter()

    def setFilter(self, filter):
        self.app.setFilter(filter)

    def getCrossDomainXmlFile(self):
        return self.app.getCrossDomainXmlFile()

    def setCrossDomainXmlFile(self, value):
        self.app.setCrossDomainXmlFile(value)

    def getCrossDomainXmlContent(self):
        return self.app.getCrossDomainXmlContent()

    def setCrossDomainXmlContent(self, value):
        self.app.setCrossDomainXmlContent(value)

    def getClientAccessPolicyXmlFile(self):
        return self.app.getClientAccessPolicyXmlFile()

    def setClientAccessPolicyXmlFile(self, value):
        self.app.setClientAccessPolicyXmlFile(value)

    def getClientAccessPolicyXmlContent(self):
        return self.app.getClientAccessPolicyXmlContent()

    def setClientAccessPolicyXmlContent(self, value):
        self.app.setClientAccessPolicyXmlContent(value)

    def start(self):
        print("Serving on port %s:%s..." % (self.host, self.port))
        from wsgiref.simple_server import make_server
        httpd = make_server(self.host, self.port, self.app)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            exit()
