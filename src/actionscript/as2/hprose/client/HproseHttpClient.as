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
 * HproseHttpClient.as                                    *
 *                                                        *
 * hprose http client class for ActionScript 2.0.         *
 *                                                        *
 * LastModified: Dec 24, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

import hprose.common.HproseException;
import hprose.common.IHproseFilter;
import hprose.common.HproseFilter;
import hprose.common.HproseResultMode;

import hprose.client.HproseHttpInvoker;

dynamic class hprose.client.HproseHttpClient extends Object {
    private var url:String;
    private var header:Object;
    private var onerror:Array;
    public var byref:Boolean;
    public var simple:Boolean;
    public var timeout:Number;
    public var filter:IHproseFilter;
    public function HproseHttpClient(url:String) {
        this.url = null;
        this.header = {};
        this.onerror = [];
        this.byref = false;
        this.simple = false;
        this.timeout = 30000;
        this.filter = new HproseFilter();
        if (url) {
            useService(url);
        }
    }
    private function __resolve(name:String):Function {
        function createProxy(client:HproseHttpClient, ns:String) {
            return function (n:String):Function {
                var proxy = function () {
                    if (ns == '') {
                        arguments.unshift(n);
                    }
                    else {
                        arguments.unshift(ns + '_' + n);
                    }
                    return client.invoke.apply(client, arguments);
                }
                if (ns == '') {
                    proxy.__resolve = createProxy(client, n);
                }
                else {
                    proxy.__resolve = createProxy(client, ns + '_' + n);
                }
                return proxy;
            }
        }
        return createProxy(this, '')(name);
    }
    public function useService(url:String) {
        if (url != null) {
            this.url = url;
        }
        if (this.url == null) {
            throw new HproseException("You should set server url first!");
        }
        return __resolve('');
    }
    public function set uri(value:String) {
        this.useService(value);
    }

    public function get uri():String {
        return this.url;
    }

    public function setHeader(name:String, value:String) {
        if (name.toLowerCase() != 'content-type' &&
            name.toLowerCase() != 'content-length') {
            if (value) {
                header[name] = value;
            }
            else {
                delete header[name];
            }
        }
    }
    public function addEventListener(type:String, listener:Function) {
        function addEvent(events:Array, listener:Function) {
            for (var i = 0, l = events.length; i < l; i++) {
                if (events[i] == listener) {
                    return;
                }
            }
            events.push(listener);
        }
        switch (type.toLowerCase()) {
            case 'error':
            case 'onerror':
                addEvent(onerror, listener);
                break;
        }
        return this;
    }

    public function removeEventListener(type:String, listener:Function) {
        function deleteEvent(events:Array, listener:Function) {
            for (var i = events.length - 1; i >= 0; i--) {
                if (events[i] == listener) {
                    events.splice(i, 1);
                }
            }
        }
        switch (type.toLowerCase()) {
            case 'error':
            case 'onerror':
                deleteEvent(onerror, listener);
                break;
        }
        return this;
    }
    public function invoke():HproseHttpInvoker {
        var args:Array = arguments;
        var func:String = args.shift().toString();
        var byref:Boolean = this.byref;
        var simple:Boolean = this.simple;
        var resultMode:Number = HproseResultMode.Normal;
        var callback:Function = null;
        var errorHandler:Function = null;
        var progressHandler:Function = null;
        var count = args.length;
        if (typeof(args[count - 1]) == 'boolean' &&
            typeof(args[count - 2]) == 'number' &&
            typeof(args[count - 3]) == 'boolean' &&
            typeof(args[count - 4]) == 'function' &&
            typeof(args[count - 5]) == 'function' &&
            typeof(args[count - 6]) == 'function') {
            simple = args[count - 1];
            resultMode = args[count - 2];
            byref = args[count - 3];
            progressHandler = args[count - 4];
            errorHandler = args[count - 5];
            callback = args[count - 6];
            args.length -= 6;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'number' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function' &&
                 typeof(args[count - 5]) == 'function') {
            simple = args[count - 1];
            resultMode = args[count - 2];
            progressHandler = args[count - 3];
            errorHandler = args[count - 4];
            callback = args[count - 5];
            args.length -= 5;
        }
        else if (typeof(args[count - 1]) == 'number' &&
                 typeof(args[count - 2]) == 'boolean' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function' &&
                 typeof(args[count - 5]) == 'function') {
            resultMode = args[count - 1];
            byref = args[count - 2];
            progressHandler = args[count - 3];
            errorHandler = args[count - 4];
            callback = args[count - 5];
            args.length -= 5;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'boolean' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function' &&
                 typeof(args[count - 5]) == 'function') {
            simple = args[count - 1];
            byref = args[count - 2];
            progressHandler = args[count - 3];
            errorHandler = args[count - 4];
            callback = args[count - 5];
            args.length -= 5;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'function' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function') {
            byref = args[count - 1];
            progressHandler = args[count - 2];
            errorHandler = args[count - 3];
            callback = args[count - 4];
            args.length -= 4;
        }
        else if (typeof(args[count - 1]) == 'number' &&
                 typeof(args[count - 2]) == 'function' &&
                 typeof(args[count - 3]) == 'function' &&
                 typeof(args[count - 4]) == 'function') {
            resultMode = args[count - 1];
            progressHandler = args[count - 2];
            errorHandler = args[count - 3];
            callback = args[count - 4];
            args.length -= 4;
        }
        else if (typeof(args[count - 1]) == 'function' &&
                 typeof(args[count - 2]) == 'function' &&
                 typeof(args[count - 3]) == 'function') {
            progressHandler = args[count - 1];
            errorHandler = args[count - 2];
            callback = args[count - 3];
            args.length -= 3;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'number' &&
                 typeof(args[count - 3]) == 'boolean' &&
                 typeof(args[count - 4]) == 'function' &&
                 typeof(args[count - 5]) == 'function') {
            simple = args[count - 1];
            resultMode = args[count - 2];
            byref = args[count - 3];
            errorHandler = args[count - 4];
            callback = args[count - 5];
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
            args.length -= 4;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'function' &&
                 typeof(args[count - 3]) == 'function') {
            byref = args[count - 1];
            errorHandler = args[count - 2];
            callback = args[count - 3];
            args.length -= 3;
        }
        else if (typeof(args[count - 1]) == 'number' &&
                 typeof(args[count - 2]) == 'function' &&
                 typeof(args[count - 3]) == 'function') {
            resultMode = args[count - 1];
            errorHandler = args[count - 2];
            callback = args[count - 3];
            args.length -= 3;
        }
        else if (typeof(args[count - 1]) == 'function' &&
                 typeof(args[count - 2]) == 'function') {
            errorHandler = args[count - 1];
            callback = args[count - 2];
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
            args.length -= 4;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'number' &&
                 typeof(args[count - 3]) == 'function') {
            simple = args[count - 1];
            resultMode = args[count - 2];
            callback = args[count - 3];
            args.length -= 3;
        }
        else if (typeof(args[count - 1]) == 'number' &&
                 typeof(args[count - 2]) == 'boolean' &&
                 typeof(args[count - 3]) == 'function') {
            resultMode = args[count - 1];
            byref = args[count - 2];
            callback = args[count - 3];
            args.length -= 3;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'boolean' &&
                 typeof(args[count - 3]) == 'function') {
            simple = args[count - 1];
            byref = args[count - 2];
            callback = args[count - 3];
            args.length -= 3;
        }
        else if (typeof(args[count - 1]) == 'boolean' &&
                 typeof(args[count - 2]) == 'function') {
            byref = args[count - 1];
            callback = args[count - 2];
            args.length -= 2;
        }
        else if (typeof(args[count - 1]) == 'number' &&
                 typeof(args[count - 2]) == 'function') {
            resultMode = args[count - 1];
            callback = args[count - 2];
            args.length -= 2;
        }
        else if (typeof(args[count - 1]) == 'function') {
            callback = args[count - 1];
            args.length--;
        }
        return new HproseHttpInvoker(url, header, func, args, byref, callback, errorHandler, progressHandler, onerror, timeout, resultMode, simple, filter);
    }
}