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
 * hprose http client class for ActionScript 3.0.         *
 *                                                        *
 * LastModified: Dec 24, 2013                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.client {
    import hprose.common.HproseException;
    import hprose.common.HproseResultMode;
    import hprose.common.IHproseFilter;
    import hprose.common.HproseFilter;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.EventDispatcher;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    [Event(name="error",type="hprose.client.HproseErrorEvent")]
    ﻿public dynamic class HproseHttpClient extends Proxy implements IEventDispatcher {
        private var url:String = null;
        private const header:Object = { };
        public var byref:Boolean = false;
        public var simple:Boolean = false;
        public var timeout:uint = 30000;
        public var filter:IHproseFilter = new HproseFilter();
        private var dispatcher:EventDispatcher;
        public function HproseHttpClient(url:String = "") {
            dispatcher = new EventDispatcher(this);
            if (url != "") {
                useService(url);
            }
        }

        flash_proxy override function callProperty(name:*, ...rest):* {
            rest.unshift(name);
            return invoke.apply(this, rest);
        }

        flash_proxy override function getProperty(name:*):* {
            return new HproseHttpProxy(this, name);
        }

        public function useService(url:String = ""):HproseHttpProxy {
            if (url != "") {
                this.url = url;
            }
            if (this.url == null) {
                throw new HproseException("You should set server url first!");
            }
            return new HproseHttpProxy(this, '');
        }

        public function set uri(value:String):void {
            this.useService(value);
        }

        public function get uri():String {
            return this.url;
        }

        public function setHeader(name:String, value:String):void {
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

        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            dispatcher.addEventListener(type, listener, useCapture, priority);
        }

        public function dispatchEvent(evt:Event):Boolean {
            return dispatcher.dispatchEvent(evt);
        }

        public function hasEventListener(type:String):Boolean {
            return dispatcher.hasEventListener(type);
        }

        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            dispatcher.removeEventListener(type, listener, useCapture);
        }

        public function willTrigger(type:String):Boolean {
            return dispatcher.willTrigger(type);
        }

        public function invoke(func:String, ...rest):HproseHttpInvoker {
            var args:Array = rest;
﻿            var byref:Boolean = this.byref;
            var simple:Boolean = this.simple;
            var resultMode:int = HproseResultMode.Normal;
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
            return new HproseHttpInvoker(url, header, func, args, byref, callback, errorHandler, progressHandler, dispatcher, timeout, resultMode, simple, filter);
        }

        public function toString():String {
            return '[HproseHttpClient uri="' + url + '"]';
        }
    }
}