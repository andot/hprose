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
 * hproseHttpServer.js                                    *
 *                                                        *
 * hprose http server library for ASP.                    *
 *                                                        *
 * LastModified: Oct 28, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseHttpServer = (function() {
    function callService(method, obj, context, args) {
        var result;
        if (typeof(method) == "function") {
            result = method.apply(context, args);
        }
        else if (obj && typeof(obj[method]) == "function") {
            result = obj[method].apply(context, args);
        }
        else {
            var a = [];
            for (var i = 0, n = args.length; i < n; i++) {
                a[i] = 'args[' + i + ']';
            }
            if (obj == null) {
                if (typeof(method) == "string") {
                    result = eval(method + "(" + a.join(', ') + ")");
                }
                else {
                    result = eval("method(" + a.join(', ') + ")");                    
                }
            }
            else {
                result = eval("obj[method](" + a.join(', ') + ")");
            }
        }
        return result;
    }
    return (function() {
        /* Reference of global Class */
        var r_HproseResultMode = HproseResultMode;
        var r_HproseException = HproseException;
        var r_HproseUtil = HproseUtil;
        var r_HproseStringInputStream = HproseStringInputStream;
        var r_HproseStringOutputStream = HproseStringOutputStream;
        var r_HproseReader = HproseReader;
        var r_HproseWriter = HproseWriter;
        var r_HproseTags = HproseTags;
        var r_HproseFormatter = HproseFormatter;
        var prototypePropertyOfArray = function() {
            var result = {};
            for (var p in []) {
                result[p] = true;
            }
            return result;
        }();
        var prototypePropertyOfObject = function() {
            var result = {};
            for (var p in {}) {
                result[p] = true;
            }
            return result;
        }();

        function arrayValues(obj) {
            var result = [];
            for (var key in obj) {
                if (!prototypePropertyOfObject[key] &&
                    !prototypePropertyOfArray[key]) {
                    result[result.length] = obj[key];
                }
            }
            return result;
        }
        
        function getRefName(ref) {
            for (var name in ref) return name;
        }

        function getFuncName(func) {
            var f = func.toString();
            return f.substr(0, f.indexOf('(')).replace(/(^\s*function\s*)|(\s*$)/ig, '');
        }
        
        function HproseHttpServer(vbs) {
            var m_functions = {};
            var m_funcNames = {};
            var m_resultMode = {};
            var m_debug = false;
            var m_crossDomain = false;
            var m_P3P = false;
            var m_get = true;
            var m_filter = null;
            var m_input;
            var m_output;
            var m_reader;
            var m_writer;
            this.onBeforeInvoke = null;
            this.onAfterInvoke = null;
            this.onSendHeader = null;
            this.onSendError = null;

            function constructor() {
                var count = Request.totalBytes;
                var bytes = Request.binaryRead(count);
                var str = "";
                if (count > 0) {
                    str = r_HproseUtil.binaryToString(bytes);
                }
                Session.CodePage = 65001;
                Response.CodePage = 65001;
                Response.Buffer = true;
                if (m_filter) {
                    str = m_filter.inputFilter(str);
                }
                m_input = new r_HproseStringInputStream(str);
                m_reader = new r_HproseReader(m_input, vbs);
                if (m_filter) {
                    m_output = r_HproseStringOutputStream();
                }
                else {
                    m_output = Response;
                }
                m_writer = new r_HproseWriter(m_output);
            }

            function sendHeader() {
                if (this.onSendHeader != null) {
                    this.onSendHeader();
                }
                Response.addHeader('Content-Type', "text/plain");
                if (m_P3P) {
                    Response.addHeader('P3P', 
                        'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi ' +
                        'CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL ' +
                        'UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"');
                }
                if (m_crossDomain) {
                    var origin = Request.ServerVariables("HTTP_ORIGIN");
                    if (origin && origin != "null") {
                        Response.addHeader('Access-Control-Allow-Origin', origin);
                        Response.addHeader('Access-Control-Allow-Credentials', 'true');  
                    }
                    else {
                        Response.addHeader('Access-Control-Allow-Origin', '*');
                    }
                }
            }

            function sendError(error) {
                if (this.onSendError != null) {
                    this.onSendError(error);
                }
                m_output.clear();
                m_writer.reset();
                m_output.write(r_HproseTags.TagError);
                m_writer.writeString(error, false);
                m_output.write(r_HproseTags.TagEnd);
            }

            function doInvoke() {
                do {
                    m_reader.reset();
                    var functionName = m_reader.readString();
                    var aliasName = functionName.toLowerCase();
                    var functionArgs = [];
                    var byref = false;
                    var tag = m_reader.checkTags([r_HproseTags.TagList,
                                                  r_HproseTags.TagEnd,
                                                  r_HproseTags.TagCall]);
                    if (tag == r_HproseTags.TagList) {
                        m_reader.reset();
                        functionArgs = m_reader.readList(false);
                        if (vbs) functionArgs = r_HproseUtil.toJSArray(functionArgs);
                        tag = m_reader.checkTags([r_HproseTags.TagTrue,
                                                  r_HproseTags.TagEnd,
                                                  r_HproseTags.TagCall]);
                        if (tag == r_HproseTags.TagTrue) {
                            byref = true;
                            tag = m_reader.checkTags([r_HproseTags.TagEnd,
                                                      r_HproseTags.TagCall]);
                        }
                    }
                    if (this.onBeforeInvoke != null) {
                        this.onBeforeInvoke(functionName, functionArgs, byref);
                    }
                    var func, resultMode, result;
                    if (func = m_functions[aliasName]) {
                        resultMode = m_resultMode[aliasName];
                        result = callService(func.method, func.obj, func.context, functionArgs);
                    }
                    else if (func = m_functions['*']) {
                        resultMode = m_resultMode['*'];
                        var args = [functionName, functionArgs];
                        result = callService(func.method, func.obj, func.context, args);
                    }
                    else {
                        throw new r_HproseException("Can't find this function " + functionName + "().");
                    }
                    if (this.onAfterInvoke != null) {
                        this.onAfterInvoke(functionName, functionArgs, byref, result);
                    }
                    if (resultMode == r_HproseResultMode.RawWithEndTag) {
                        m_output.write(result);
                        return;
                    }
                    else if (resultMode == r_HproseResultMode.Raw) {
                        m_output.write(result);
                    }
                    else {
                        m_output.write(r_HproseTags.TagResult);
                        if (resultMode == r_HproseResultMode.Serialized) {
                            m_output.write(result);
                        }
                        else {
                            m_writer.reset();
                            m_writer.serialize(result);
                        }
                        if (byref) {
                            m_output.write(r_HproseTags.TagArgument);
                            m_writer.reset();
                            m_writer.writeList(functionArgs, false);
                        }
                    }
                } while (tag == r_HproseTags.TagCall);
                m_output.write(r_HproseTags.TagEnd);
            }

            function doFunctionList() {
                var functions = arrayValues(m_funcNames);
                m_output.write(r_HproseTags.TagFunctions);
                m_writer.writeList(functions, false);
                m_output.write(r_HproseTags.TagEnd);
            }

            function handle() {
                try {
                    var exceptTags = [r_HproseTags.TagCall, r_HproseTags.TagEnd];
                    var tag = m_reader.checkTags(exceptTags);
                    switch (tag) {
                        case r_HproseTags.TagCall: doInvoke.apply(this); break;
                        case r_HproseTags.TagEnd: doFunctionList(); break;
                    }
                }
                catch (e) {
                    sendError.call(this, e.description);
                }
            }

            this.addMissingFunction = function(func, resultMode) {
                this.addFunction(func, "*", resultMode);
            }

            this.addMissingMethod = function(method, obj, context, resultMode) {
                this.addMethod(method, obj, "*", context, resultMode);
            }

            this.addFunction = function(func, alias, resultMode) {
                if (resultMode === undefined) {
                    resultMode = r_HproseResultMode.Normal;
                }
                if (alias === undefined || alias == null) {
                    switch(typeof(func)) {
                        case "string":
                            alias = func;
                            break;
                        case "object":
                            alias = getRefName(func);
                            break;
                        case "function": 
                            alias = getFuncName(func);
                            if (alias != "") break;
                        default:
                            throw new r_HproseException('Need an alias');                            
                    }
                }
                if (typeof(alias) == "string") {
                    var aliasName = alias.toLowerCase();
                    m_functions[aliasName] = {method: func, obj: null, context: null};
                    m_funcNames[aliasName] = alias;
                    m_resultMode[aliasName] = resultMode;
                }
                else {
                    throw new r_HproseException('Argument alias is not a string');
                }
            }

            this.addFunctions = function(functions, aliases, resultMode) {
                if (r_HproseUtil.isVBArray(functions)) {
                    functions = r_HproseUtil.toJSArray(functions);
                }
                var count = functions.length;
                var i;
                if (aliases === undefined || aliases == null) {
                    for (i = 0; i < count; i++) this.addFunction(functions[i], null, resultMode);
                    return;
                }
                else if (r_HproseUtil.isVBArray(aliases)) {
                    aliases = r_HproseUtil.toJSArray(aliases);
                }
                if (count != aliases.length) {
                    throw new r_HproseException('The count of functions is not matched with aliases');
                }
                for (i = 0; i < count; i++) this.addFunction(functions[i], aliases[i], resultMode);
            }

            this.addMethod = function(method, obj, alias, context, resultMode) {
                if (obj === undefined || obj == null) {
                    this.addFunction(method, alias, resultMode);
                    return;
                }
                if (context === undefined) {
                    context = obj;
                }
                if (resultMode === undefined) {
                    resultMode = r_HproseResultMode.Normal;
                }
                if (alias === undefined || alias == null) {
                    switch(typeof(method)) {
                        case "string":
                            alias = method;
                            break;
                        case "object":
                            alias = getRefName(method);
                            break;
                        case "function": 
                            alias = getFuncName(method);
                            if (alias != "") break;
                        default:
                            throw new r_HproseException('Need an alias');                            
                    }
                }
                if (typeof(alias) == "string") {
                    var aliasName = alias.toLowerCase();
                    m_functions[aliasName] = {method: method, obj: obj, context: context};
                    m_funcNames[aliasName] = alias;
                    m_resultMode[aliasName] = resultMode;
                }
                else {
                    throw new r_HproseException('Argument alias is not a string');
                }
            }

            this.addMethods = function(methods, obj, aliases, context, resultMode) {
                if (r_HproseUtil.isVBArray(methods)) {
                    methods = r_HproseUtil.toJSArray(methods);
                }
                var count = methods.length;
                var i;
                if (aliases === undefined || aliases == null) {
                    for (i = 0; i < count; i++) {
                        this.addMethod(methods[i], obj, null, context, resultMode);
                    }
                    return;
                }
                else if (r_HproseUtil.isVBArray(aliases)) {
                    aliases = r_HproseUtil.toJSArray(aliases);
                }
                if (count != aliases.length) {
                    throw new r_HproseException('The count of methods is not matched with aliases');
                }
                for (i = 0; i < count; i++) {
                    this.addMethod(methods[i], obj, aliases[i], context, resultMode);
                }
            }
            
            this.addInstanceMethods = function(obj, aliasPrefix, context, resultMode) {
                var alias;
                for (var name in obj) {
                    if (!prototypePropertyOfObject[name] &&
                        !prototypePropertyOfArray[name]) {
                        alias = (aliasPrefix ? aliasPrefix + "_" + name : name);
                        if (typeof(obj[name]) == 'function') {
                            this.addMethod(obj[name], obj, alias, context, resultMode);
                        }
                        else if (typeof(obj[name]) == 'unknown') {
                            this.addFunction(obj[name], alias, resultMode);
                        }
                    }
                }
            }

            this.isDebugEnabled = function() {
                return m_debug;
            }
            this.setDebugEnabled = function(enable) {
                if (enable === undefined) enable = true;
                m_debug = enable;
            }
            this.isCrossDomainEnabled = function() {
                return m_crossDomain;
            }
            this.setCrossDomainEnabled = function(enable) {
                if (enable === undefined) enable = true;
                m_crossDomain = enable;
            }
            this.isP3PEnabled = function() {
                return m_P3P;
            }
            this.setP3PEnabled = function(enable) {
                if (enable === undefined) enable = true;
                m_P3P = enable;
            }
            this.isGetEnabled = function() {
                return m_get;
            }
            this.setGetEnabled = function(enable) {
                if (enable === undefined) enable = true;
                m_get = enable;
            }
            this.handle = function() {
                Response.clear();
                sendHeader.apply(this);
                if ((Request.ServerVariables("REQUEST_METHOD") == 'GET') && m_get) {
                    doFunctionList();
                }
                else if (Request.ServerVariables("REQUEST_METHOD") == 'POST') {
                    handle.apply(this);
                }
                if (m_filter) {
                    Response.write(m_filter.outputFilter(m_output.toString()));
                }
                Response.end();
            }
            this.start = this.handle;
            constructor();
        }
        HproseHttpServer.create = function() {
            return new HproseHttpServer(true);
        }
        return HproseHttpServer;
    })();
})();