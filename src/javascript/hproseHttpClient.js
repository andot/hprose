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
 * LastModified: Dec 27, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
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
    var r_HproseSimpleReader = HproseSimpleReader;
    var r_HproseReader = HproseReader;
    var r_HproseSimpleWriter = HproseSimpleWriter;
    var r_HproseWriter = HproseWriter;
    var r_HproseTags = HproseTags;

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

    function HproseHttpClient(url, functions) {
        // private members
        var m_ready    = false;
        var m_header = {'Content-Type': 'text/plain'};
        var m_url;
        var m_timeout = 30000;
        var m_byref = false;
        var m_simple = false;
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
            m_ready = false;
            if (url === undefined) {
                return new r_HproseException("You should set server url first!");
            }
            m_url = url;
            if (typeof(functions) == s_string ||
                (functions && functions.constructor == Object)) {
                functions = [functions];
            }
            if (Array.isArray(functions)) {
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
        this.getFilter = function() {
            return m_filter;
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
                    var hproseReader = new r_HproseSimpleReader(stream);
                    var tag = hproseReader.checkTags(r_HproseTags.TagFunctions +
                                                     r_HproseTags.TagError);
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
            if (typeof(methods) == s_string || methods.constructor == Object) {
                methods = [methods]
            }
            if (Array.isArray(methods)) {
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
            r_HproseHttpRequest.post(m_url, m_header, request, function(response) {
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
                                        hproseReader.reset();
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
                else if (callback) {
                    callback(result, args);
                }
            }, m_timeout, m_filter);
        }
        /* constructor */ {
            if (typeof(url) == s_string) {
                this.useService(url, functions);
            }
        }
    }
    HproseHttpClient.create = function(url, functions) {
        return new HproseHttpClient(url, functions);
    }

    return HproseHttpClient;
})();