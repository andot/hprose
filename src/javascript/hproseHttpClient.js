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
 * hprose http client for Javascript.                     *
 *                                                        *
 * LastModified: Nov 27, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseHttpClient = (function () {
    /* Reference of global Class */
    var r_HproseResultMode = HproseResultMode;
    var r_HproseException = HproseException;
    var r_HproseFilter = HproseFilter;
    var r_HproseHttpRequest = HproseHttpRequest;
    var r_HproseStringInputStream = HproseStringInputStream;
    var r_HproseStringOutputStream = HproseStringOutputStream;
    var r_HproseReader = HproseReader;
    var r_HproseWriter = HproseWriter;
    var r_HproseTags = HproseTags;

    var s_corsSupport = ((typeof(XMLHttpRequest) != "undefined" &&
                          "withCredentials" in new XMLHttpRequest()) ||
                         typeof(XDomainRequest) != "undefined");

    function HproseHttpClient(url, functions) {
        // private members
        var m_ready    = false;
        var m_header = {'Content-Type': 'text/plain'};
        var m_url;
        var m_timeout = 30000;
        var m_byref = false;
        var m_filter = new r_HproseFilter();
        var self = this;
        // public methods
        this.useService = function(url, functions, create) {
            if (typeof(functions) == 'boolean' && create === undefined) {
                create = functions;
            }
            var serviceProxy = this;
            if (create) {
                serviceProxy = {};
            }
            m_ready = false;
            if (url === undefined) {
                return new r_HproseException("You should set server url first!");
            }
            m_url = url;
            if (typeof(functions) == 'string' ||
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
            if (name.toLowerCase() != 'content-type') {
                if (value) {
                    m_header[name] = value;
                }
                else {
                    delete m_header[name];
                }
            }
        }
        this.setTimeout = function(timeout) {
            m_timeout = timeout;
        }
        this.getTimeout = function() {
            return m_timeout;
        }
        this.getReady = function() {
            return m_ready;
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
        // events
        this.onReady = function() {
            // your code
        }
        this.onError = function(name, error) {
            // your code
        }
        // private methods
        function useService() {
            var serverProxy = this;
            r_HproseHttpRequest.post(m_url, m_header, r_HproseTags.TagEnd, function(response) {
                var error = null;
                try {
                    var stream = new r_HproseStringInputStream(response);
                    var hproseReader = new r_HproseReader(stream);
                    var tag = hproseReader.checkTags([r_HproseTags.TagFunctions,
                                                      r_HproseTags.TagError]);
                    switch (tag) {
                        case r_HproseTags.TagError:
                            error = new r_HproseException(hproseReader.readString());
                            break;
                        case r_HproseTags.TagFunctions:
                            var functions = hproseReader.readList();
                            hproseReader.checkTag(r_HproseTags.TagEnd);
                            setFunctions.call(serverProxy, functions);
                            break;
                    }
                }
                catch (e) {
                    error = e;
                }
                if (error != null) {
                    self.onError('useService', error);
                }
            }, m_timeout, m_filter);
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
            if (typeof(methods) == 'string' || methods.constructor == Object) {
                methods = [methods]
            }
            if (Object.prototype.toString.apply(methods) === '[object Array]') {
                for (var i = 0; i < methods.length; i++) {
                    var m = methods[i];
                    if (typeof(m) == 'string') {
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
                if (typeof(f) == 'string') {
                    if (this[f] === undefined) {
                        this[f] = setFunction.call(this, f);
                    }
                }
                else {
                    for (var name in f) {
                        setMethods.call(this, this, '', name, f[name]);
                    }
                }
            }
            m_ready = true;
            self.onReady();
        }
        function invoke(func, args) {
            var resultMode = r_HproseResultMode.Normal;
            var byref = m_byref;
            var lowerCaseFunc = func.toLowerCase();
            var errorHandler = this[func + '_OnError'] ||
                               this[func + '_onError'] ||
                               this[func + '_onerror'] ||
                               this[lowerCaseFunc + '_OnError'] ||
                               this[lowerCaseFunc + '_onError'] ||
                               this[lowerCaseFunc + '_onerror'] ||
                               self[func + '_OnError'] ||
                               self[func + '_onError'] ||
                               self[func + '_onerror'] ||
                               self[lowerCaseFunc + '_OnError'] ||
                               self[lowerCaseFunc + '_onError'] ||
                               self[lowerCaseFunc + '_onerror'];
            var callback = this[func + '_Callback'] ||
                           this[func + '_callback'] ||
                           this[func + '_OnSuccess'] ||
                           this[func + '_onSuccess'] ||
                           this[func + '_onsuccess'] ||
                           this[lowerCaseFunc + '_Callback'] ||
                           this[lowerCaseFunc + '_callback'] ||
                           this[lowerCaseFunc + '_OnSuccess'] ||
                           this[lowerCaseFunc + '_onSuccess'] ||
                           this[lowerCaseFunc + '_onsuccess'] ||
                           self[func + '_Callback'] ||
                           self[func + '_callback'] ||
                           self[func + '_OnSuccess'] ||
                           self[func + '_onSuccess'] ||
                           self[func + '_onsuccess'] ||
                           self[lowerCaseFunc + '_Callback'] ||
                           self[lowerCaseFunc + '_callback'] ||
                           self[lowerCaseFunc + '_OnSuccess'] ||
                           self[lowerCaseFunc + '_onSuccess'] ||
                           self[lowerCaseFunc + '_onsuccess'];
            var count = args.length;
            if (typeof(args[count - 1]) == 'number' &&
                typeof(args[count - 2]) == 'boolean' &&
                typeof(args[count - 3]) == 'function' &&
                typeof(args[count - 4]) == 'function') {
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
            else if (typeof(args[count - 1]) == 'boolean' &&
                     typeof(args[count - 2]) == 'function' &&
                     typeof(args[count - 3]) == 'function') {
                byref = args[count - 1];
                errorHandler = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == 'number' &&
                     typeof(args[count - 2]) == 'function' &&
                     typeof(args[count - 3]) == 'function') {
                resultMode = args[count - 1];
                errorHandler = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == 'function' &&
                     typeof(args[count - 2]) == 'function') {
                errorHandler = args[count - 1];
                callback = args[count - 2];
                delete args[count - 1];
                delete args[count - 2];
                args.length -= 2;
            }
            else if (typeof(args[count - 1]) == 'number' &&
                     typeof(args[count - 2]) == 'boolean' &&
                     typeof(args[count - 3]) == 'function') {
                resultMode = args[count - 1];
                byref = args[count - 2];
                callback = args[count - 3];
                delete args[count - 1];
                delete args[count - 2];
                delete args[count - 3];
                args.length -= 3;
            }
            else if (typeof(args[count - 1]) == 'boolean' &&
                     typeof(args[count - 2]) == 'function') {
                byref = args[count - 1];
                callback = args[count - 2];
                delete args[count - 1];
                delete args[count - 2];
                args.length -= 2;
            }
            else if (typeof(args[count - 1]) == 'number' &&
                     typeof(args[count - 2]) == 'function') {
                resultMode = args[count - 1];
                callback = args[count - 2];
                delete args[count - 1];
                delete args[count - 2];
                args.length -= 2;
            }
            else if (typeof(args[count - 1]) == 'function') {
                callback = args[count - 1];
                delete args[count - 1];
                args.length--;
            }
            var stream = new r_HproseStringOutputStream(r_HproseTags.TagCall);
            var hproseWriter = new r_HproseWriter(stream);
            hproseWriter.writeString(func, false);
            if (args.length > 0 || byref) {
                hproseWriter.reset();
                hproseWriter.writeList(args, false);
                if (byref) {
                    hproseWriter.writeBoolean(true);
                }
            }
            stream.write(r_HproseTags.TagEnd);
            var request = stream.toString();
            r_HproseHttpRequest.post(m_url, m_header, request, function(response) {
                if (callback) {
                    var result = null;
                    var error = null;
                    if (resultMode == r_HproseResultMode.RawWithEndTag) {
                        result = response;
                    }
                    else if (resultMode == r_HproseResultMode.Raw) {
                        result = response.substr(0, response.length - 1);
                    }
                    else {
                        var stream = new r_HproseStringInputStream(response);
                        var hproseReader = new r_HproseReader(stream);
                        var tag;
                        try {
                            while ((tag = hproseReader.checkTags(
                                [r_HproseTags.TagResult,
                                 r_HproseTags.TagArgument,
                                 r_HproseTags.TagError,
                                 r_HproseTags.TagEnd])) !== r_HproseTags.TagEnd) {
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
                                        args = hproseReader.readList();
                                        break;
                                    case r_HproseTags.TagError:
                                        hproseReader.reset();
                                        error = new r_HproseException(hproseReader.readString());
                                        break;
                                }
                            }
                        }
                        catch (e) {
                            error = e;
                        }
                    }
                    if (error != null) {
                        if (errorHandler) {
                            errorHandler(func, error);
                        }
                        else {
                            self.onError(func, error);
                        }
                    }
                    else {
                        callback(result, args);
                    }
                }
            }, m_timeout, m_filter);
        }
        /* constructor */ {
            if (typeof(url) == "string") {
                this.useService(url, functions);
            }
        }
    }
    HproseHttpClient.create = function(url, functions) {
        return new HproseHttpClient(url, functions);
    }
    HproseHttpClient.corsSupport = s_corsSupport;
    HproseHttpClient.setFlash = r_HproseHttpRequest.setFlash;
    return HproseHttpClient;
})();