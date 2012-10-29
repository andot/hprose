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
 * LastModified: Oct 29, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require('util');
var EventEmitter = require('events').EventEmitter;
var HproseResultMode = require('../common/HproseResultMode.js');
var HproseException = require('../common/HproseException.js');
var HproseTags = require('../io/HproseTags.js');

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

function HproseService() {
    var m_functions = {};
    var m_funcNames = {};
    var m_resultMode = {};
    var m_debug = false;

    EventEmitter.call(this);
    
    // protected methods
    this._sendError = function(writer, error) {
        this.emit('sendError', error);
        writer.stream.clear();
        writer.reset();
        writer.stream.write(HproseTags.TagError);
        writer.writeString(error, false);
        writer.stream.write(HproseTags.TagEnd);
    }

    this._doInvoke = function(reader, writer, request) {
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
                throw new HproseException("Can't find this function " + functionName + "().");
            }
            this.emit('afterInvoke', functionName, functionArgs, byref, result, request);
            if (resultMode == HproseResultMode.RawWithEndTag) {
                writer.stream.write(result);
                return;
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
        } while (tag == HproseTags.TagCall);
        writer.stream.write(HproseTags.TagEnd);
    }
    
    this._doFunctionList = function(writer) {
        var functions = arrayValues(m_funcNames);
        writer.stream.write(HproseTags.TagFunctions);
        writer.writeList(functions, false);
        writer.stream.write(HproseTags.TagEnd);
    }

    this._handle = function(reader, writer, request) {
        try {
            var exceptTags = [HproseTags.TagCall, HproseTags.TagEnd];
            var tag = reader.checkTags(exceptTags);
            switch (tag) {
                case HproseTags.TagCall: this._doInvoke(reader, writer, request); break;
                case HproseTags.TagEnd: this._doFunctionList(writer); break;
            }
        }
        catch (e) {
            this._sendError(writer, e.message);
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

    this.addMissingFunction = function(func, resultMode) {
        this.addFunction(func, "*", resultMode);
    }
    
    this.addMissingMethod = function(method, obj, context, resultMode) {
        this.addMethod(method, obj, "*", context, resultMode);
    }

    this.addFunction = function(func, alias, resultMode) {
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
            m_functions[aliasName] = {method: func, obj: null, context: null};
            m_funcNames[aliasName] = alias;
            m_resultMode[aliasName] = resultMode;
        }
        else {
            throw new HproseException('Argument alias is not a string');
        }
    }

    this.addFunctions = function(functions, aliases, resultMode) {
        var count = functions.length;
        var i;
        if (aliases === undefined || aliases == null) {
            for (i = 0; i < count; i++) this.addFunction(functions[i], null, resultMode);
        }
        else {
            if (count != aliases.length) {
                throw new HproseException('The count of functions is not matched with aliases');
            }
            for (i = 0; i < count; i++) this.addFunction(functions[i], aliases[i], resultMode);
        }
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
            m_functions[aliasName] = {method: method, obj: obj, context: context};
            m_funcNames[aliasName] = alias;
            m_resultMode[aliasName] = resultMode;
        }
        else {
            throw new HproseException('Argument alias is not a string');
        }
    }

    this.addMethods = function(methods, obj, aliases, context, resultMode) {
        var count = methods.length;
        var i;
        if (aliases === undefined || aliases == null) {
            for (i = 0; i < count; i++) {
                this.addMethod(methods[i], obj, null, context, resultMode);
            }
        }
        else {
            if (count != aliases.length) {
                throw new HproseException('The count of methods is not matched with aliases');
            }
            for (i = 0; i < count; i++) {
                this.addMethod(methods[i], obj, aliases[i], context, resultMode);
            }
        }
    }

    this.addInstanceMethods = function(obj, aliasPrefix, context, resultMode) {
        var alias;
        for (var name in obj) {
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

util.inherits(HproseService, EventEmitter);

module.exports = HproseService;