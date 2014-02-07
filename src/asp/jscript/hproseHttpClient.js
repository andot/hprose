/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/

/**********************************************************\
 *                                                        *
 * hproseHttpClient.js                                    *
 *                                                        *
 * hprose http client for ASP.                            *
 *                                                        *
 * LastModified: Dec 29, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseHttpClient = (function () {
    /* Reference of global Class */
    var r_HproseResultMode = HproseResultMode;
    var r_HproseException = HproseException;
    var r_HproseFilter = HproseFilter;
    var r_HproseStringInputStream = HproseStringInputStream;
    var r_HproseStringOutputStream = HproseStringOutputStream;
    var r_HproseSimpleReader = HproseSimpleReader;
    var r_HproseReader = HproseReader;
    var r_HproseSimpleWriter = HproseSimpleWriter;
    var r_HproseWriter = HproseWriter;
    var r_HproseTags = HproseTags;
    var r_HproseFormatter = HproseFormatter;

    var s_undefined = "undefined";
    var s_boolean = "boolean";
    var s_string = "string";
    var s_number = "number";
    var s_function = "function";
    var s_OnError = "_OnError";
    var s_onError = "_onError";
    var s_onerror = "_onerror";
    var s_Callback = "_Callback";
    var s_callback = "_callback";
    var s_OnSuccess = "_OnSuccess";
    var s_onSuccess = "_onSuccess";
    var s_onsuccess = "_onsuccess";

    /* static private members */
    var s_keepSession = false;

    var s_cookieManager = {};

    var s_XMLHttpNameCache = null;

    function createXMLHttp() {
        if (s_XMLHttpNameCache != null) {
            // Use the cache name first.
            return new ActiveXObject(s_XMLHttpNameCache);
        }
        else {
            var MSXML = ['MSXML2.ServerXMLHTTP.6.0',
                         'MSXML2.ServerXMLHTTP.5.0',
                         'MSXML2.ServerXMLHTTP.4.0',
                         'MSXML2.ServerXMLHTTP.3.0',
                         'MSXML2.ServerXMLHTTP'];
            var n = MSXML.length;
            var objXMLHttp;
            for(var i = 0; i < n; i++) {
                try {
                    objXMLHttp = new ActiveXObject(MSXML[i]);
                    // Cache the XMLHttp ActiveX object name.
                    s_XMLHttpNameCache = MSXML[i];
                    return objXMLHttp;
                }
                catch(e) {}
            }
            return null;
        }
    }

    function setCookie(headers, host) {
        for (var i = 0; i < headers.length; i++) {
            var header = headers[i].split(':', 2);
            var name = header[0].toLowerCase();
            var value = header[1];
            if ((name == 'set-cookie') || (name == 'set-cookie2')) {
                var cookies = value.replace(/(^\s*)|(\s*$)/g, "").split(';');
                var cookie = {};
                value = cookies[0].replace(/(^\s*)|(\s*$)/g, "").split('=', 2);
                if (value[1] === undefined) value[1] = null;
                cookie['name'] = value[0];
                cookie['value'] = value[1];
                for (var j = 1; j < cookies.length; j++) {
                    value = cookies[j].replace(/(^\s*)|(\s*$)/g, "").split('=', 2);
                    if (value[1] === undefined) value[1] = null;
                    cookie[value[0].toUpperCase()] = value[1];
                }
                // Tomcat can return SetCookie2 with path wrapped in "
                if (cookie['PATH']) {
                    if (cookie['PATH'].charAt(0) == '"') {
                        cookie['PATH'] = cookie['PATH'].substr(1);
                    }
                    if (cookie['PATH'].charAt(cookie['PATH'].length - 1) == '"') {
                        cookie['PATH'] = cookie['PATH'].substr(0, cookie['PATH'].length - 1);
                    }
                }
                else {
                    cookie['PATH'] = '/'
                }
                if (cookie['EXPIRES']) {
                    cookie['EXPIRES'] = Date.parse(cookie['EXPIRES']);
                }
                if (cookie['DOMAIN']) {
                    cookie['DOMAIN'] = cookie['DOMAIN'].toLowerCase();
                }
                else {
                    cookie['DOMAIN'] = host;
                }
                cookie['SECURE'] = (cookie['SECURE'] !== undefined);
                if (s_cookieManager[cookie['DOMAIN']] === undefined) {
                    s_cookieManager[cookie['DOMAIN']] = {};
                }
                s_cookieManager[cookie['DOMAIN']][cookie['name']] = cookie;
                if (s_keepSession) {
                    Session("HPROSE_COOKIE_MANAGER") = s_cookieManager;
                }
            }
        }
    }

    function getCookie(host, path, secure) {
        var cookies = [];
        for (var domain in s_cookieManager) {
            if (host.indexOf(domain) > -1) {
                var names = [];
                for (var name in s_cookieManager[domain]) {
                    var cookie = s_cookieManager[domain][name];
                    if (cookie['EXPIRES'] && ((new Date()).getTime() > cookie['EXPIRES'])) {
                        names.push(name);
                    }
                    else if (path.indexOf(cookie['PATH']) === 0) {
                        if (((secure && cookie['SECURE']) ||
                             !cookie['SECURE']) && (cookie['value'] !== null)) {
                            cookies.push(cookie['name'] + '=' + cookie['value']);
                        }
                    }
                }
                for (var i in names) {
                    delete s_cookieManager[domain][names[i]];
                }
            }
        }
        if (cookies.length > 0) {
            return cookies.join('; ');
        }
        return '';
    }

    function getResponse(xmlhttp, host, filter) {
        if (xmlhttp.status == 200) {
            var headers = xmlhttp.getAllResponseHeaders().split("\r\n");
            setCookie(headers, host);
            return filter.inputFilter(xmlhttp.responseText);
        }
        else {
            var error = xmlhttp.status + ':' +  xmlhttp.statusText;
            return r_HproseTags.TagError +
                   r_HproseFormatter.serialize(error, true) +
                   r_HproseTags.TagEnd;
        }
    }

    function post(url, header, data, proxy, proxyUsername, proxyPassword, timeout, filter, callback) {
        var host, path, secure, p;
        if (url.substr(0, 7).toLowerCase() == 'http://') {
            secure = false;
            p = 7;
        }
        else if (url.substr(0, 8).toLowerCase() == 'https://') {
            secure = true;
            p = 8;
        }
        if (p > 0) {
            host = url.substring(p, url.indexOf('/', p));
            var m = host.match(/^([^:]*):([^@]*)@(.*)$/);
            if (m != null) {
                host = m[3];
            }
            path = url.substr(url.indexOf('/', p));
        }
        else {
            throw new r_HproseException('Url must be an absolute path.');
        }
        var xmlhttp = createXMLHttp();
        xmlhttp.setTimeouts(timeout, timeout, timeout, timeout);
        if (proxy) {
            try {
                xmlhttp.setProxy(2, proxy);
                if (proxyUsername) {
                    xmlhttp.setProxyCredentials(proxyUsername, proxyPassword);
                }
            }
            catch(e) {}
        }
        if (callback) {
            xmlhttp.open('POST', url, true);
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4) {
                    callback(getResponse(xmlhttp, host, filter));
                }
            }
        }
        else {
            xmlhttp.open('POST', url, false);
        }
        for (var name in header) {
            xmlhttp.setRequestHeader(name, header[name]);
        }
        var cookie = getCookie(host, path, secure);
        if (cookie != '') {
            xmlhttp.setRequestHeader('Cookie', cookie);
        }
        xmlhttp.send(filter.outputFilter(data));
        if (callback) {
            return xmlhttp;
        }
        else {
            return getResponse(xmlhttp, host, filter);
        }
    }

    function HproseHttpClient(url, functions, vbs) {
        // private members
        var m_header = {'Content-Type': 'application/hprose; charset=utf-8'};
        var m_url;
        var m_proxy;
        var m_proxyUsername;
        var m_proxyPassword;
        var m_timeout = 30000;
        var m_byref = false;
        var m_simple = false;
        var m_xhrs = [];
        var m_filter = new r_HproseFilter();
        var self = this;
        // public methods
        this.useService = function(url, functions, create) {
            if (typeof(functions) == s_boolean && create === undefined) {
                create = functions;
            }
            var serviceProxy = this;
            if (create) {
                serviceProxy = {};
            }
            if (url === undefined) {
                return new r_HproseException("You should set server url first!");
            }
            m_url = url;
            if (typeof(functions) == s_string ||
                (functions && functions.constructor == Object)) {
                functions = [functions];
            }
            if (Object.prototype.toString.apply(functions) === '[object Array]') {
                setFunctions.call(serviceProxy, functions);
            }
            else {
                useService.apply(serviceProxy);
            }
            return serviceProxy;
        }

        this.invoke = function() {
            var args = arguments;
            var func = Array.prototype.shift.apply(args);
            return invoke.call(this, func, args);
        }

        this.setHeader = function(name, value) {
            var lname = name.toLowerCase();
            if (lname != 'content-type' &&
                lname != 'content-length' &&
                lname != 'host') {
                if (value) {
                    m_header[name] = value;
                }
                else {
                    delete m_header[name];
                }
            }
        }

        this.setProxy = function(host, port, username, password) {
            if (!host) {
                m_proxy = null;
            }
            else if (port === undefined) {
                var p1 = 0;
                if (host.substr(0, 7).toLowerCase() == 'http://') {
                    p1 = 7;
                }
                else if (host.substr(0, 6).toLowerCase() == 'tcp://') {
                    p1 = 6;
                }
                var p2 = host.indexOf('/', p1);
                if (p2 > 0) {
                    host = host.substring(p1, p2);
                    var m = host.match(/^([^:]*):([^@]*)@(.*)$/);
                    if (m != null) {
                        m_proxyUsername = decodeURIComponent(m[1]);
                        m_proxyPassword = decodeURIComponent(m[2]);
                        host = m[3];
                    }
                }
                m_proxy = host;
            }
            else {
                m_proxy = host + ":" + port;
                if (username !== undefined && password !== undefined) {
                    m_proxyUsername = username;
                    m_proxyPassword = password;
                }
            }
        }

        this.setTimeout = function(value) {
            m_timeout = value;
        }

        this.getTimeout = function() {
            return m_timeout;
        }

        this.getByRef = function() {
            return m_byref;
        }

        this.setByRef = function(value) {
            if (value === undefined) value = true;
            m_byref = value;
        }

        this.setFilter = function(filter) {
            m_filter = filter;
        }

        this.getSimpleMode = function() {
            return m_simple;
        }

        this.setSimpleMode = function(value) {
            if (value === undefined) value = true;
            m_simple = value;
        }

        // events
        this.onError = function(name, error) {
            // your code for asynchronous invoke
        }

        this.waitForResponse = function(timeout) {
            for (var i = 0, l = m_xhrs.length; i < l; i++) {
                if (m_xhrs[i]) {
                    var xhr = m_xhrs[i];
                    if (timeout === undefined) {
                        xhr.waitForResponse();
                    }
                    else {
                        if (timeout < 0) return;
                        var s = new Date();
                        xhr.waitForResponse(timeout / 1000);
                        var e = new Date();
                        timeout -= e.getTime() - s.getTime();
                    }
                }
            }
        }

        // private methods
        function useService() {
            var response = post(m_url, m_header, r_HproseTags.TagEnd,
                                m_proxy, m_proxyUsername, m_proxyPassword,
                                m_timeout, m_filter);
            var stream = new r_HproseStringInputStream(response);
            var hproseReader = new r_HproseSimpleReader(stream, vbs);
            var tag = hproseReader.checkTags(r_HproseTags.TagFunctions +
                                             r_HproseTags.TagError);
            switch (tag) {
                case r_HproseTags.TagFunctions:
                    var functions = hproseReader.readList();
                    hproseReader.checkTag(r_HproseTags.TagEnd);
                    setFunctions.call(this, functions);
                    break;
                case r_HproseTags.TagError:
                    throw new r_HproseException(hproseReader.readString());
                    break;
            }
        }

        function setFunction(func) {
            var serverProxy = this;
            return function() {
                return invoke.call(serverProxy, func, arguments);
            }
        }

        function setMethods(obj, namespace, name, methods) {
            if (obj[name] !== undefined) return;
            obj[name] = {};
            if (typeof(methods) == s_string || methods.constructor == Object) {
                methods = [methods]
            }
            if (Object.prototype.toString.apply(methods) === '[object Array]') {
                for (var i = 0; i < methods.length; i++) {
                    var m = methods[i];
                    if (typeof(m) == s_string) {
                        obj[name][m] = setFunction.call(this, namespace + name + '_' + m);
                    }
                    else {
                        for (var n in m) {
                            setMethods.call(this, obj[name], name + '_', n, m[n]);
                        }
                    }
                }
            }
        }

        function setFunctions(functions) {
            for (var i = 0; i < functions.length; i++) {
                var f = functions[i];
                if (typeof(f) == s_string) {
                    if (this[f] === undefined) {
                        this[f] = setFunction(f);
                    }
                }
                else {
                    for (var name in f) {
                        setMethods.call(this, this, '', name, f[name]);
                    }
                }
            }
        }

        function getResult(response, func, args, resultMode) {
            var result = null;
            if (resultMode == r_HproseResultMode.RawWithEndTag) {
                result = response;
            }
            else if (resultMode == r_HproseResultMode.Raw) {
                result = response.substr(0, response.length - 1);
            }
            else {
                var stream = new r_HproseStringInputStream(response);
                var hproseReader = new r_HproseReader(stream, vbs);
                var tag;
                var error = null;
                while ((tag = hproseReader.checkTags(
                    r_HproseTags.TagResult +
                    r_HproseTags.TagArgument +
                    r_HproseTags.TagError +
                    r_HproseTags.TagEnd)) !== r_HproseTags.TagEnd) {
                    switch (tag) {
                        case r_HproseTags.TagResult:
                            if (resultMode == r_HproseResultMode.Serialized) {
                                result = hproseReader.readRaw().toString();
                            }
                            else {
                                result = hproseReader.unserialize();
                            }
                            break;
                        case r_HproseTags.TagArgument:
                            hproseReader.reset();
                            var a = hproseReader.readList();
                            for (var i = 0; i < a.length; i++) {
                                args[i] = a[i];
                            }
                            break;
                        case r_HproseTags.TagError:
                            hproseReader.reset();
                            error = new r_HproseException(hproseReader.readString());
                            break;
                    }
                }
                if (error != null) throw error;
            }
            return result;
        }

        function invoke(func, args) {
            var resultMode = r_HproseResultMode.Normal;
            var byref = m_byref;
            var simple = m_simple;
            var lowerCaseFunc = func.toLowerCase();
            var errorHandler = this[func + s_OnError] ||
                               this[func + s_onError] ||
                               this[func + s_onerror] ||
                               this[lowerCaseFunc + s_OnError] ||
                               this[lowerCaseFunc + s_onError] ||
                               this[lowerCaseFunc + s_onerror] ||
                               self[func + s_OnError] ||
                               self[func + s_onError] ||
                               self[func + s_onerror] ||
                               self[lowerCaseFunc + s_OnError] ||
                               self[lowerCaseFunc + s_onError] ||
                               self[lowerCaseFunc + s_onerror];
            var callback = this[func + s_Callback] ||
                           this[func + s_callback] ||
                           this[func + s_OnSuccess] ||
                           this[func + s_onSuccess] ||
                           this[func + s_onsuccess] ||
                           this[lowerCaseFunc + s_Callback] ||
                           this[lowerCaseFunc + s_callback] ||
                           this[lowerCaseFunc + s_OnSuccess] ||
                           this[lowerCaseFunc + s_onSuccess] ||
                           this[lowerCaseFunc + s_onsuccess] ||
                           self[func + s_Callback] ||
                           self[func + s_callback] ||
                           self[func + s_OnSuccess] ||
                           self[func + s_onSuccess] ||
                           self[func + s_onsuccess] ||
                           self[lowerCaseFunc + s_Callback] ||
                           self[lowerCaseFunc + s_callback] ||
                           self[lowerCaseFunc + s_OnSuccess] ||
                           self[lowerCaseFunc + s_onSuccess] ||
                           self[lowerCaseFunc + s_onsuccess];
            var count = args.length;
            if (typeof(args[count - 1]) == s_boolean &&
                typeof(args[count - 2]) == s_number &&
                typeof(args[count - 3]) == s_boolean &&
                typeof(args[count - 4]) == s_function &&
                typeof(args[count - 5]) == s_function) {
                simple = args[count - 1];
                resultMode = args[count - 2];
                byref = args[count - 3];
                errorHandler = args[count - 4];
                callback = args[count - 5];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                delete args[count - 4];
                delete args[count - 5];
                args.length -= 5;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_number &&
                     typeof(args[count - 3]) == s_function &&
                     typeof(args[count - 4]) == s_function) {
                simple = args[count - 1];
                resultMode = args[count - 2];
                errorHandler = args[count - 3];
                callback = args[count - 4];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                delete args[count - 4];
                args.length -= 4;
            }
            else if (typeof(args[count - 1]) == s_number &&
                     typeof(args[count - 2]) == s_boolean &&
                     typeof(args[count - 3]) == s_function &&
                     typeof(args[count - 4]) == s_function) {
                resultMode = args[count - 1];
                byref = args[count - 2];
                errorHandler = args[count - 3];
                callback = args[count - 4];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                delete args[count - 4];
                args.length -= 4;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_boolean &&
                     typeof(args[count - 3]) == s_function &&
                     typeof(args[count - 4]) == s_function) {
                simple = args[count - 1];
                byref = args[count - 2];
                errorHandler = args[count - 3];
                callback = args[count - 4];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                delete args[count - 4];
                args.length -= 4;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_function &&
                     typeof(args[count - 3]) == s_function) {
                byref = args[count - 1];
                errorHandler = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == s_number &&
                     typeof(args[count - 2]) == s_function &&
                     typeof(args[count - 3]) == s_function) {
                resultMode = args[count - 1];
                errorHandler = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == s_function &&
                     typeof(args[count - 2]) == s_function) {
                errorHandler = args[count - 1];
                callback = args[count - 2];
                delete args[count - 1];
                delete args[count - 2];
                args.length -= 2;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_number &&
                     typeof(args[count - 3]) == s_boolean &&
                     typeof(args[count - 4]) == s_function) {
                simple = args[count - 1];
                resultMode = args[count - 2];
                byref = args[count - 3];
                callback = args[count - 4];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                delete args[count - 4];
                args.length -= 4;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_number &&
                     typeof(args[count - 3]) == s_function) {
                simple = args[count - 1];
                resultMode = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == s_number &&
                     typeof(args[count - 2]) == s_boolean &&
                     typeof(args[count - 3]) == s_function) {
                resultMode = args[count - 1];
                byref = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_boolean &&
                     typeof(args[count - 3]) == s_function) {
                simple = args[count - 1];
                byref = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == s_boolean &&
                     typeof(args[count - 2]) == s_function) {
                byref = args[count - 1];
                callback = args[count - 2];
                delete args[count - 1];
                delete args[count - 2];
                args.length -= 2;
            }
            else if (typeof(args[count - 1]) == s_number &&
                     typeof(args[count - 2]) == s_function) {
                resultMode = args[count - 1];
                callback = args[count - 2];
                delete args[count - 1];
                delete args[count - 2];
                args.length -= 2;
            }
            else if (typeof(args[count - 1]) == s_function) {
                callback = args[count - 1];
                delete args[count - 1];
                args.length--;
            }
            var stream = new r_HproseStringOutputStream(r_HproseTags.TagCall);
            var hproseWriter = (simple ? new r_HproseSimpleWriter(stream) : new r_HproseWriter(stream));
            hproseWriter.writeString(func);
            if (args.length > 0 || byref) {
                hproseWriter.reset();
                hproseWriter.writeList(args);
                if (byref) {
                    hproseWriter.writeBoolean(true);
                }
            }
            stream.write(r_HproseTags.TagEnd);
            var request = stream.toString();
            if (callback) {
                var xhr_index = m_xhrs.length;
                return m_xhrs[xhr_index] = post(m_url, m_header, request,
                               m_proxy, m_proxyUsername, m_proxyPassword,
                               m_timeout, m_filter, function(response) {
                    try {
                        var result = getResult(response, func, args, resultMode);
                    }
                    catch (e) {
                        if (errorHandler) {
                            errorHandler(func, e);
                        }
                        else {
                            self.onError(func, e);
                        }
                        return;
                    }
                    callback(result, args);
                    delete m_xhrs[xhr_index];
                });
            }
            else {
                var response = post(m_url, m_header, request,
                                    m_proxy, m_proxyUsername, m_proxyPassword,
                                    m_timeout, m_filter);
                return getResult(response, func, args, resultMode);
            }
        }
        /* constructor */ {
            if (typeof(url) == s_string) {
                this.useService(url, functions);
            }
        }
    }
    HproseHttpClient.create = function(url, functions) {
        return new HproseHttpClient(url, functions, true);
    }
    HproseHttpClient.keepSession = function() {
        s_keepSession = true;
        if (Session("HPROSE_COOKIE_MANAGER")) {
            s_cookieManager = Session("HPROSE_COOKIE_MANAGER");
        }
    }
    return HproseHttpClient;
})();