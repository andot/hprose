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
 * HproseHttpInvoker.as                                   *
 *                                                        *
 * hprose http invoker class for ActionScript 2.0.        *
 *                                                        *
 * LastModified: Jun 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
import hprose.client.HproseHttpRequest;
import hprose.client.HproseSuccessEvent;
import hprose.client.HproseErrorEvent;
import hprose.client.HproseProgressEvent;
import hprose.client.HproseResultMode;
import hprose.client.IHproseFilter;
import hprose.io.HproseException;
import hprose.io.HproseReader;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;
import hprose.io.HproseWriter;

class hprose.client.HproseHttpInvoker {
    private var url:String;
    private var header:Object;
    private var func:String;
    private var args:Array;
    private var byref:Boolean;
    private var onsuccess:Array;
    private var onerror:Array;
    private var onprogress:Array;
    private var globalonerror:Array;
    private var progressId:Number;
    private var result;
    private var success:Boolean;
    private var completed:Boolean;
    private var lv:LoadVars;
    private var timeout:Number;
    private var resultMode:Number;
    private var filter:IHproseFilter;
    
    public function HproseHttpInvoker(url:String, header:Object, func:String, args:Array, byref:Boolean, callback:Function, errorHandler:Function, progressHandler:Function, onerror:Array, timeout:Number, resultMode:Number, filter:IHproseFilter) {
        this.url = url;
        this.header = header;
        this.func = func;
        this.args = args;
        this.byref = byref;
        this.onsuccess = [];
        this.onerror = [];
        this.onprogress = [];
        this.globalonerror = onerror;
        this.progressId = 0;
        this.result = null;
        this.success = false;
        this.completed = false;
        this.lv = null;
        this.timeout = timeout;
        this.resultMode = resultMode;
        this.filter = filter;
        if (callback) {
            start(callback, errorHandler, progressHandler);
        }
    }
    
    public function get byRef():Boolean {
        return byref;
    }
    
    public function set byRef(value:Boolean) {
        byref = value;
    }
    
    public function isSuccess():Boolean {
        return success;
    }
    
    public function isCompleted():Boolean {
        return completed;
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
            case 'success':
            case 'onsuccess':
                addEvent(onsuccess, listener);
                break;
            case 'error':
            case 'onerror':
                addEvent(onerror, listener);
                break;
            case 'progress':
            case 'onprogress':
                addEvent(onprogress, listener);
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
            case 'success':
            case 'onsuccess':
                deleteEvent(onsuccess, listener);
                break;
            case 'error':
            case 'onerror':
                deleteEvent(onerror, listener);
                break;
            case 'progress':
            case 'onprogress':
                deleteEvent(onprogress, listener);
                break;
        }
        return this;
    }
    
    private function fireEvent(events:Array, event) {
        for (var i = 0, l = events.length; i < l; i++) {
            events[i].call(this, event);
        }
    }
    
    public function getResult() {
        return result;
    }
    
    public function getArguments() {
        return args;
    }
    
    public function start(callback, errorHandler, progressHandler) {
        var stream:HproseStringOutputStream = new HproseStringOutputStream();
        stream.write(HproseTags.TagCall);
        var writer:HproseWriter = new HproseWriter(stream);
        writer.writeString(func, false);
        if (args.length > 0) {
            writer.reset();
            writer.writeList(args, false);
        }
        if (byref) {
            writer.writeBoolean(true);
        }
        stream.write(HproseTags.TagEnd);
        completed = false;
        var invoker = this;
        lv = HproseHttpRequest.post(url, header, stream.toString(), function(data) {
            if (invoker.resultMode == HproseResultMode.RawWithEndTag) {
                invoker.result = data;
            }
            else if (invoker.resultMode == HproseResultMode.Raw) {
                invoker.result = data.substr(0, data.length - 1);
            }
            else {
                var stream:HproseStringInputStream = new HproseStringInputStream(data);
                var reader:HproseReader = new HproseReader(stream);
                var tag;
                var error = null;
                try {
                    while ((tag = reader.checkTags(
                        [HproseTags.TagResult,
                         HproseTags.TagArgument,
                         HproseTags.TagError,
                         HproseTags.TagEnd])) !== HproseTags.TagEnd) {
                        switch (tag) {
                            case HproseTags.TagResult:
                                if (invoker.resultMode == HproseResultMode.Serialized) {
                                    invoker.result = reader.readRaw().toString();
                                }
                                else {
                                    invoker.result = reader.unserialize();
                                }
                                break;
                            case HproseTags.TagArgument:
                                reader.reset();
                                invoker.args = reader.readList();
                                break;
                            case HproseTags.TagError:
                                reader.reset();
                                error = new HproseException(reader.readString());
                                break;
                        }
                    }
                }
                catch (e:Error) {
                    error = e;
                }
            }
            _global.clearTimeout(invoker.progressId);
            invoker.fireEvent(invoker.onprogress, new HproseProgressEvent(invoker.lv.getBytesLoaded(), invoker.lv.getBytesTotal()));
            invoker.completed = true;
            invoker.success = (error == null);
            if (invoker.success) {
                if (callback) {
                    callback(invoker.result, invoker.args);
                }
                else if (invoker.onsuccess.length > 0) {
                    invoker.fireEvent(invoker.onsuccess, new HproseSuccessEvent(invoker.result, invoker.args));
                }
            }
            else {
                if (errorHandler) {
                    errorHandler(invoker.func, error);
                }
                else if (invoker.onerror.length > 0) {
                    invoker.fireEvent(invoker.onerror, new HproseErrorEvent(invoker.func, error));
                }
                else {
                    invoker.fireEvent(invoker.globalonerror, new HproseErrorEvent(invoker.func, error));
                }
            }
        }, timeout, filter);
        function doprogress() {
            var byteloaded = invoker.lv.getBytesLoaded();
            var bytetotal = invoker.lv.getBytesTotal();
            if (progressHandler) {
                progressHandler(byteloaded, bytetotal);
            }
            else if (invoker.onprogress.length > 0) {
                invoker.fireEvent(invoker.onprogress, new HproseProgressEvent(byteloaded, bytetotal));
            }
            _global.clearTimeout(invoker.progressId);
            invoker.progressId = _global.setTimeout(doprogress, 100);
        }
        if (invoker.onprogress.length > 0) {
            progressId = _global.setTimeout(doprogress, 100);
        }
        return this;
    }
    
    public function stop() {
        onprogress = [];
        onsuccess = [];
        onerror = [];
        lv = null;
    }
}