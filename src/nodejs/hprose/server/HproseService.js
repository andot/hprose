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
 * HproseService.js                                       *
 *                                                        *
 * HproseService for Node.js.                             *
 *                                                        *
 * LastModified: Nov 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require('util');
var EventEmitter = require('events').EventEmitter;
var HproseResultMode = require('../common/HproseResultMode.js');
var HproseException = require('../common/HproseException.js');
var HproseFilter = require('../common/HproseFilter.js');
var HproseTags = require('../io/HproseTags.js');
var HproseBufferInputStream = require('../io/HproseBufferInputStream.js');
var HproseBufferOutputStream = require('../io/HproseBufferOutputStream.js');
var HproseReader = require('../io/HproseReader.js');
var HproseWriter = (typeof(Map) === 'undefined') ? require('../io/HproseWriter.js') : require('../io/HproseWriter2.js');

function callService(method, obj, context, args) {
    var result;
    if (typeof(method) == "function") {
        result = method.apply(context, args);
    }
    else if (obj && typeof(obj[method]) == "function") {
        result = obj[method].apply(context, args);
    }
    return result;
}

function arrayValues(obj) {
    var result = [];
    for (var key in obj) result.push(obj[key]);
    return result;
}

function getFuncName(func, obj) {
    var f = func.toString();
    var funcname = f.substr(0, f.indexOf('(')).replace(/(^\s*function\s*)|(\s*$)/ig, '');
    if ((funcname == "") && obj) {
        for (var name in obj) {
            if (obj[name] === func) return name;
        }
    }
    return funcname;
}

function responseEnd(writer, response, filter) {
    response.emit("end", filter.outputFilter(writer.stream.toBuffer()));
}

function getCallback(functionName, functionArgs, byref, resultMode, async, writer, request, response, filter) {
    return function(result) {
        this.emit('afterInvoke', functionName, functionArgs, byref, result, request);
        if (resultMode == HproseResultMode.RawWithEndTag) {
            writer.stream.write(result);
            responseEnd(writer, response, filter);
            return true;
        }
        else if (resultMode == HproseResultMode.Raw) {
            writer.stream.write(result);
        }
        else {
            writer.stream.write(HproseTags.TagResult);
            if (resultMode == HproseResultMode.Serialized) {
                writer.stream.write(result);
            }
            else {
                writer.reset();
                writer.serialize(result);
            }
            if (byref) {
                writer.stream.write(HproseTags.TagArgument);
                writer.reset();
                writer.writeList(functionArgs, false);
            }
        }
        if (async) {
            writer.stream.write(HproseTags.TagEnd);
            responseEnd(writer, response, filter);
        }
        return false;
    };
}

function HproseService() {
    var m_functions = {};
    var m_funcNames = {};
    var m_debug = false;
    var m_filter = new HproseFilter();

    EventEmitter.call(this);
    
    // protected methods
    this._sendError = function(writer, e, response) {
        this.emit('sendError', e);
        writer.stream.clear();
        writer.reset();
        writer.stream.write(HproseTags.TagError);
        writer.writeString(e.message, false);
        writer.stream.write(HproseTags.TagEnd);
        responseEnd(writer, response, m_filter);
    }

    this._doInvoke = function(reader, writer, request, response) {
        var func, callback, async = false;
        do {
            reader.reset();
            var functionName = reader.readString();
            var aliasName = functionName.toLowerCase();
            var functionArgs = [];
            var byref = false;
            var tag = reader.checkTags([HproseTags.TagList,
                                    HproseTags.TagEnd,
                                    HproseTags.TagCall]);
            if (tag == HproseTags.TagList) {
                reader.reset();
                functionArgs = reader.readList(false);
                tag = reader.checkTags([HproseTags.TagTrue,
                                          HproseTags.TagEnd,
                                          HproseTags.TagCall]);
                if (tag == HproseTags.TagTrue) {
                    byref = true;
                    tag = reader.checkTags([HproseTags.TagEnd,
                                              HproseTags.TagCall]);
                }
            }
            this.emit('beforeInvoke', functionName, functionArgs, byref, request);
            if (func = m_functions[aliasName]) {
                callback = getCallback(functionName, functionArgs, byref, func.resultMode, func.async, writer, request, response, m_filter).bind(this);
                if (func.async) {
                    async = true;
                    callService(func.method, func.obj, func.context, functionArgs.concat([callback]));
                }
                else {
                    if (callback(callService(func.method, func.obj, func.context, functionArgs))) return;
                }
            }
            else if (func = m_functions['*']) {
                callback = getCallback(functionName, functionArgs, byref, func.resultMode, func.async, writer, request, response, m_filter).bind(this);
                if (func.async) {
                    async = true;
                    callService(func.method, func.obj, func.context, [functionName, functionArgs, callback]);
                }
                else {
                    if (callback(callService(func.method, func.obj, func.context, [functionName, functionArgs]))) return;
                }
            }
            else {
                throw new HproseException("Can't find this function " + functionName + "().");
            }
        } while (tag == HproseTags.TagCall);
        if (!async) {
            writer.stream.write(HproseTags.TagEnd);
            responseEnd(writer, response, m_filter);
        }
    }
    
    this._doFunctionList = function(response) {
        var writer = new HproseWriter(new HproseBufferOutputStream());
        var functions = arrayValues(m_funcNames);
        writer.stream.write(HproseTags.TagFunctions);
        writer.writeList(functions, false);
        writer.stream.write(HproseTags.TagEnd);
        responseEnd(writer, response, m_filter);
    }

    this._handle = function(data, request, response) {
        var reader = new HproseReader(new HproseBufferInputStream(m_filter.inputFilter(data)));
        var writer = new HproseWriter(new HproseBufferOutputStream());
        try {
            var exceptTags = [HproseTags.TagCall, HproseTags.TagEnd];
            var tag = reader.checkTags(exceptTags);
            switch (tag) {
                case HproseTags.TagCall: return this._doInvoke(reader, writer, request, response);
                case HproseTags.TagEnd: return this._doFunctionList(writer, response);
            }
        }
        catch (e) {
            this._sendError(writer, e, response);
        }
    }
    
    // public methods
    this.isDebugEnabled = function() {
        return m_debug;
    }
    
    this.setDebugEnabled = function(enable) {
        if (enable === undefined) enable = true;
        m_debug = enable;
    }

    this.addMissingFunction = function(func, resultMode, async) {
        this.addFunction(func, "*", resultMode, async);
    }
    
    this.addAsyncMissingFunction = function(func, resultMode) {
        this.addMissingFunction(func, resultMode, true);
    }

    this.addMissingMethod = function(method, obj, context, resultMode, async) {
        this.addMethod(method, obj, "*", context, resultMode, async);
    }

    this.addAsyncMissingMethod = function(method, obj, context, resultMode) {
        this.addMissingMethod(method, obj, context, resultMode, true);
    }

    this.addFunction = function(func, alias, resultMode, async) {
        if (resultMode === undefined) {
            resultMode = HproseResultMode.Normal;
        }
        if (alias === undefined || alias == null) {
            switch(typeof(func)) {
                case "string":
                    alias = func;
                    break;
                case "function":
                    alias = getFuncName(func);
                    if (alias != "") break;
                default:
                    throw new HproseException('Need an alias');                            
            }
        }
        if (typeof(alias) == "string") {
            var aliasName = alias.toLowerCase();
            m_functions[aliasName] = {method: func, obj: null, context: null, resultMode: resultMode, async: async};
            m_funcNames[aliasName] = alias;
        }
        else {
            throw new HproseException('Argument alias is not a string');
        }
    }

    this.addAsyncFunction = function(func, alias, resultMode) {
        this.addFunction(func, alias, resultMode, true);
    }

    this.addFunctions = function(functions, aliases, resultMode, async) {
        var count = functions.length;
        var i;
        if (aliases === undefined || aliases == null) {
            for (i = 0; i < count; i++) this.addFunction(functions[i], null, resultMode, async);
        }
        else {
            if (count != aliases.length) {
                throw new HproseException('The count of functions is not matched with aliases');
            }
            for (i = 0; i < count; i++) this.addFunction(functions[i], aliases[i], resultMode, async);
        }
    }

    this.addAsyncFunctions = function(functions, aliases, resultMode) {
        this.addFunctions(functions, aliases, resultMode, true);
    }

    this.addMethod = function(method, obj, alias, context, resultMode, async) {
        if (obj === undefined || obj == null) {
            this.addFunction(method, alias, resultMode);
            return;
        }
        if (context === undefined) {
            context = obj;
        }
        if (resultMode === undefined) {
            resultMode = HproseResultMode.Normal;
        }
        if (alias === undefined || alias == null) {
            switch(typeof(method)) {
                case "string":
                    alias = method;
                    break;
                case "function": 
                    alias = getFuncName(method, obj);
                    if (alias != "") break;
                default:
                    throw new HproseException('Need an alias');                            
            }
        }
        if (typeof(alias) == "string") {
            var aliasName = alias.toLowerCase();
            m_functions[aliasName] = {method: method, obj: obj, context: context, resultMode: resultMode, async: async};
            m_funcNames[aliasName] = alias;
        }
        else {
            throw new HproseException('Argument alias is not a string');
        }
    }

    this.addAsyncMethod = function(method, obj, alias, context, resultMode) {
        this.addMethod(method, obj, alias, context, resultMode, true);
    }

    this.addMethods = function(methods, obj, aliases, context, resultMode, async) {
        var count = methods.length;
        var i;
        if (aliases === undefined || aliases == null) {
            for (i = 0; i < count; i++) {
                this.addMethod(methods[i], obj, null, context, resultMode, async);
            }
        }
        else {
            if (count != aliases.length) {
                throw new HproseException('The count of methods is not matched with aliases');
            }
            for (i = 0; i < count; i++) {
                this.addMethod(methods[i], obj, aliases[i], context, resultMode, async);
            }
        }
    }

    this.addAsyncMethods = function(methods, obj, aliases, context, resultMode) {
        this.addMethods(methods, obj, aliases, context, resultMode, true);
    }

    this.addInstanceMethods = function(obj, aliasPrefix, context, resultMode, async) {
        var alias;
        for (var name in obj) {
            alias = (aliasPrefix ? aliasPrefix + "_" + name : name);
            if (typeof(obj[name]) == 'function') {
                this.addMethod(obj[name], obj, alias, context, resultMode, async);
            }
        }
    }

    this.addAsyncInstanceMethods = function(obj, aliasPrefix, context, resultMode, async) {
        this.addInstanceMethods(obj, aliasPrefix, context, resultMode, true);
    }

    this.setFilter = function(filter) {
        m_filter = filter;
    }
}

util.inherits(HproseService, EventEmitter);

module.exports = HproseService;