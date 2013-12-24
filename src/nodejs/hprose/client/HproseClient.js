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
 * HproseClient.js                                        *
 *                                                        *
 * HproseClient for Node.js.                              *
 *                                                        *
 * LastModified: Dec 24, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require('util');
var EventEmitter = require('events').EventEmitter;
var HproseResultMode = require('../common/HproseResultMode.js');
var HproseException = require('../common/HproseException.js');
var HproseFilter = require('../common/HproseFilter.js');
var HproseBufferInputStream = require('../io/HproseBufferInputStream.js');
var HproseBufferOutputStream = require('../io/HproseBufferOutputStream.js');
var HproseSimpleReader = require('../io/HproseSimpleReader.js');
var HproseSimpleWriter = require('../io/HproseSimpleWriter.js');
var HproseReader = require('../io/HproseReader.js');
var HproseWriter = require('../io/HproseWriter.js');
var HproseTags = require('../io/HproseTags.js');

function HproseProxy(invoke, ns) {
    this.get = function(proxy, name) {
        if (ns) name = ns + "_" + name;
        return Proxy.createFunction(
            new HproseProxy(invoke, name),
            function () {
                var args = Array.prototype.slice.call(arguments);
                return invoke(name, args);
            }
        );
    }
}

function HproseClient() {
    EventEmitter.call(this);
    var self = this;
    var m_byref = false;
    var m_simple = false;
    var m_timeout = 30000;
    var m_proxy;
    var m_filter = new HproseFilter();
    if (typeof(Proxy) != 'undefined') m_proxy = Proxy.create(new HproseProxy(invoke.bind(this)));
    
    function invoke(func, args) {
        var resultMode = HproseResultMode.Normal;
        var byref = m_byref;
        var simple = m_simple;
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
        if (typeof(args[count - 1]) == 'boolean' &&
            typeof(args[count - 2]) == 'number' &&
            typeof(args[count - 3]) == 'boolean' &&
            typeof(args[count - 4]) == 'function' &&
            typeof(args[count - 5]) == 'function') {
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
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'number' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function') {
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
        else if (typeof(args[count - 1]) == 'number' &&
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
                 typeof(args[count - 2]) == 'boolean' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function') {
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
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'number' &&
                 typeof(args[count - 3]) == 'boolean' &&
                 typeof(args[count - 4]) == 'function') {
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
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'number' &&
                 typeof(args[count - 3]) == 'function') {
            simple = args[count - 1];
            resultMode = args[count - 2];
            callback = args[count - 3];
            delete args[count - 1];
            delete args[count - 2];
            delete args[count - 3];
            args.length -= 3;
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
                 typeof(args[count - 2]) == 'boolean' &&
                 typeof(args[count - 3]) == 'function') {
            simple = args[count - 1];
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
        var stream = new HproseBufferOutputStream(HproseTags.TagCall);
        var writer = (simple ? new HproseSimpleWriter(stream) : new HproseWriter(stream));
        writer.writeString(func);
        if (args.length > 0 || byref) {
            writer.reset();
            writer.writeList(args);
            if (byref) {
                writer.writeBoolean(true);
            }
        }
        stream.write(HproseTags.TagEnd);
        var invoker = new EventEmitter();
        invoker.on('getdata', function(data) {
            try {
                var result = getResult(data, func, args, resultMode, simple);
                if (callback) callback(result, args);
            }
            catch (e) {
                invoker.emit('error', e);
            }
        });
        invoker.on('error', function(e) {
            if (errorHandler) {
                errorHandler(func, e);
            }
            else {
                self.emit('error', func, e);
            }
        });
        var data = m_filter.outputFilter(stream.toBuffer());
        this.emit('senddata', invoker, data);
    }
    
    function getResult(data, func, args, resultMode, simple) {
        data = m_filter.inputFilter(data);
        var result;
        if (resultMode == HproseResultMode.RawWithEndTag) {
            result = data;
        }
        else if (resultMode == HproseResultMode.Raw) {
            result = data.slice(0, data.length - 1);
        }
        else {
            var stream = new HproseBufferInputStream(data);
            var reader = new HproseReader(stream);
            var tag;
            var error;
            while ((tag = reader.checkTags(
                [HproseTags.TagResult,
                 HproseTags.TagArgument,
                 HproseTags.TagError,
                 HproseTags.TagEnd])) !== HproseTags.TagEnd) {
                switch (tag) {
                    case HproseTags.TagResult:
                        if (resultMode == HproseResultMode.Serialized) {
                            result = reader.readRaw().toBuffer();
                        }
                        else {
                            reader.reset();
                            result = reader.unserialize();
                        }
                        break;
                    case HproseTags.TagArgument:
                        reader.reset();
                        var a = reader.readList(true);
                        for (var i = 0; i < a.length; i++) {
                            args[i] = a[i];
                        }
                        break;
                    case HproseTags.TagError:
                        reader.reset();
                        error = new HproseException(reader.readString(true));
                        break;
                }
            }
            if (error) throw error;
        }
        return result;
    }
    
    // public methods
    this.setTimeout = function(value) {
        m_timeout = value;
    }
    this.getTimeout = function() {
        return m_timeout;
    }
    this.invoke = function() {
        var args = arguments;
        var func = Array.prototype.shift.apply(args);
        return invoke.call(this, func, args);
    }
    this.useService = function() {
        return m_proxy;
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
}

util.inherits(HproseClient, EventEmitter);

module.exports = HproseClient;