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
 * LastModified: Oct 29, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require('util');
var EventEmitter = require('events').EventEmitter;
var HproseResultMode = require('../common/HproseResultMode.js');
var HproseException = require('../common/HproseException.js');
var HproseBufferInputStream = require('../io/HproseBufferInputStream.js');
var HproseBufferOutputStream = require('../io/HproseBufferOutputStream.js');
var HproseReader = require('../io/HproseReader.js');
var HproseWriter = (typeof(Map) === 'undefined') ? require('../io/HproseWriter.js') : require('../io/HproseWriter2.js');
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
    var m_timeout = 30000;
    var m_proxy;
    if (typeof(Proxy) != 'undefined') m_proxy = Proxy.create(new HproseProxy(invoke.bind(this)));
    
    function invoke(func, args) {
        var resultMode = HproseResultMode.Normal;
        var byref = false;
        var errorHandler;
        var callback;
        var lowerCaseFunc = func.toLowerCase();
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
        var stream = new HproseBufferOutputStream(HproseTags.TagCall);
        var writer = new HproseWriter(stream);
        writer.writeString(func, false);
        if (args.length > 0 || byref) {
            writer.reset();
            writer.writeList(args, false);
            if (byref) {
                writer.writeBoolean(true);
            }
        }
        stream.write(HproseTags.TagEnd);
        var invoker = new EventEmitter();
        invoker.on('getdata', function(data) {
            try {
                var result = getResult(data, func, args, resultMode);
                if (callback) callback(result, args);
            }
            catch (e) {
                if (errorHandler) errorHandler(func, e);
            }
        });
        invoker.on('error', function(e) {
            if (errorHandler) errorHandler(func, e);
        });
        var data = stream.toBuffer();
        this.emit('senddata', invoker, data);
    }
    
    function getResult(data, func, args, resultMode) {
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
                            result = reader.unserialize();
                        }
                        break;
                    case HproseTags.TagArgument:
                        reader.reset();
                        var a = reader.readList();
                        for (var i = 0; i < a.length; i++) {
                            args[i] = a[i];
                        }
                        break;
                    case HproseTags.TagError:
                        reader.reset();
                        error = new HproseException(reader.readString());
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
}

util.inherits(HproseClient, EventEmitter);

module.exports = HproseClient;