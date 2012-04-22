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
 * HproseHttpRequest.as                                   *
 *                                                        *
 * hprose http request class for ActionScript 3.0.        *
 *                                                        *
 * LastModified: Jun 8, 2010                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.client {
    import hprose.io.HproseTags;
    import hprose.io.HproseWriter;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.net.URLStream;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    public final class HproseHttpRequest {
        public static function post(url:String, header:Object, data:ByteArray, callback:Function, progress:Function, timeout:uint):HproseHttpRequest {            
            var request:URLRequest = new URLRequest(url);
            request.method = URLRequestMethod.POST;
            request.contentType = "application/hprose";
            request.data = data;
            for (var name:String in header) {
                request.requestHeaders.push(new URLRequestHeader(name, header[name]));
            }
            return new HproseHttpRequest(request, callback, progress, timeout);
        }
        private const stream:URLStream = new URLStream();
        private var callback:Function;
        private var progress:Function;
        private var timer:Timer;
        private var complete:Boolean = false;
        public function HproseHttpRequest(request:URLRequest, callback:Function, progress:Function, timeout:uint) {
            this.callback = callback;
            this.progress = progress;
            timer = new Timer(timeout);
            stream.addEventListener(Event.COMPLETE, completeHandler);
            stream.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); 
            stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            stream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            stream.load(request);
            timer.addEventListener(TimerEvent.TIMER, timeoutHandler);
            timer.start();
        }
        private function completeHandler(event:Event):void {
            if (!complete) {
                complete = true;
                timer.stop();
                callback(stream);
            }
        }
        private function httpStatusHandler(event:HTTPStatusEvent):void {
            if (!complete && (event.status != 200) && (event.status != 100) && (event.status != 0)) {
                complete = true;
                timer.stop();
                var Status:Object = {};
                Status[101] = 'Switching Protocols',
                Status[201] = 'Created',
                Status[202] = 'Accepted',
                Status[203] = 'Non-Authoritative Information',
                Status[204] = 'No Content',
                Status[205] = 'Reset Content',
                Status[206] = 'Partial Content',
                Status[300] = 'Multiple Choices',
                Status[301] = 'Moved Permanently',
                Status[302] = 'Found',
                Status[303] = 'See Other',
                Status[304] = 'Not Modified',
                Status[305] = 'Use Proxy',
                Status[306] = 'No Longer Used',
                Status[307] = 'Temporary Redirect',
                Status[400] = 'Bad Request',
                Status[401] = 'Not Authorised',
                Status[402] = 'Payment Required',
                Status[403] = 'Forbidden',
                Status[404] = 'Not Found',
                Status[405] = 'Method Not Allowed',
                Status[406] = 'Not Acceptable',
                Status[407] = 'Proxy Authentication Required',
                Status[408] = 'Request Timeout',
                Status[409] = 'Conflict',
                Status[410] = 'Gone',
                Status[411] = 'Length Required',
                Status[412] = 'Precondition Failed',
                Status[413] = 'Request Entity Too Large',
                Status[414] = 'Request URI Too Long',
                Status[415] = 'Unsupported Media Type',
                Status[416] = 'Requested Range Not Satisfiable',
                Status[417] = 'Expectation Failed',
                Status[500] = 'Internal Server Error',
                Status[501] = 'Not Implemented',
                Status[502] = 'Bad Gateway',
                Status[503] = 'Service Unavailable',
                Status[504] = 'Gateway Timeout',
                Status[505] = 'HTTP Version Not Supported';
                var error:String = '[' + event.status + ':' + (Status[event.status] || "Unknown Error") + ']';
                var data:ByteArray = new ByteArray();
                var writer:HproseWriter = new HproseWriter(data);
                data.writeByte(HproseTags.TagError);
                writer.writeString(error);
                data.writeByte(HproseTags.TagEnd);
                data.position = 0;
                callback(data);
            }
        }
        private function ioErrorHandler(event:IOErrorEvent):void {
            if (!complete) {
                complete = true;
                timer.stop();
                var data:ByteArray = new ByteArray();
                var writer:HproseWriter = new HproseWriter(data);
                data.writeByte(HproseTags.TagError);
                writer.writeString(event.text);
                data.writeByte(HproseTags.TagEnd);
                data.position = 0;
                callback(data);
            }
        }
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            if (!complete) {
                complete = true;
                timer.stop();
                var data:ByteArray = new ByteArray();
                var writer:HproseWriter = new HproseWriter(data);
                data.writeByte(HproseTags.TagError);
                writer.writeString(event.text);
                data.writeByte(HproseTags.TagEnd);
                data.position = 0;
                callback(data);
            }
        }
        private function progressHandler(event:ProgressEvent):void {
            try {
                progress(event);
            }
            catch (e:Error) {}
        }
        private function timeoutHandler(event:TimerEvent):void {
            if (!complete) {
                complete = true;
                Timer(event.target).stop();
                stream.close();
                var data:ByteArray = new ByteArray();
                var writer:HproseWriter = new HproseWriter(data);
                data.writeByte(HproseTags.TagError);
                writer.writeString('timeout');
                data.writeByte(HproseTags.TagEnd);
                data.position = 0;
                callback(data);
            }
        }
        public function stop() {
            if (!complete) {
                complete = true;
                timer.stop();
                stream.close();
            }
        }
    }
}