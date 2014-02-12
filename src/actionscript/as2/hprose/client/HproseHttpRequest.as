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
 * hprose http request class for ActionScript 2.0.        *
 *                                                        *
 * LastModified: Nov 20, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

import hprose.common.IHproseFilter;
import hprose.io.HproseFormatter;
import hprose.io.HproseTags;

class hprose.client.HproseHttpRequest {
    public static function post(url:String, header:Object, data:String, callback:Function, timeout:Number, filter:IHproseFilter) {
        var lv:LoadVars = new LoadVars();
        var timeoutID:Number;
        lv.contentType = "application/hprose; charset=utf-8";
        lv.toString = function () {
            return filter.outputFilter(data);
        }
        for (var name:String in header) {
            lv.addRequestHeader(name, header[name]);
        }
        lv.onData = function (src:String) {
            _global.clearTimeout(timeoutID);
            if (src) {
                callback(filter.inputFilter(src));
            }
            else {
                callback(this.error);
            }
        };
        lv.onHTTPStatus = function (httpStatus:Number) {
            if ((httpStatus != 200) && (httpStatus != 100) && (httpStatus != 0)) {
                _global.clearTimeout(timeoutID);
                var Status = {};
                Status['101'] = 'Switching Protocols',
                Status['201'] = 'Created',
                Status['202'] = 'Accepted',
                Status['203'] = 'Non-Authoritative Information',
                Status['204'] = 'No Content',
                Status['205'] = 'Reset Content',
                Status['206'] = 'Partial Content',
                Status['300'] = 'Multiple Choices',
                Status['301'] = 'Moved Permanently',
                Status['302'] = 'Found',
                Status['303'] = 'See Other',
                Status['304'] = 'Not Modified',
                Status['305'] = 'Use Proxy',
                Status['306'] = 'No Longer Used',
                Status['307'] = 'Temporary Redirect',
                Status['400'] = 'Bad Request',
                Status['401'] = 'Not Authorised',
                Status['402'] = 'Payment Required',
                Status['403'] = 'Forbidden',
                Status['404'] = 'Not Found',
                Status['405'] = 'Method Not Allowed',
                Status['406'] = 'Not Acceptable',
                Status['407'] = 'Proxy Authentication Required',
                Status['408'] = 'Request Timeout',
                Status['409'] = 'Conflict',
                Status['410'] = 'Gone',
                Status['411'] = 'Length Required',
                Status['412'] = 'Precondition Failed',
                Status['413'] = 'Request Entity Too Large',
                Status['414'] = 'Request URI Too Long',
                Status['415'] = 'Unsupported Media Type',
                Status['416'] = 'Requested Range Not Satisfiable',
                Status['417'] = 'Expectation Failed',
                Status['500'] = 'Internal Server Error',
                Status['501'] = 'Not Implemented',
                Status['502'] = 'Bad Gateway',
                Status['503'] = 'Service Unavailable',
                Status['504'] = 'Gateway Timeout',
                Status['505'] = 'HTTP Version Not Supported';
                var error:String = '[' + httpStatus + ':' + (Status[httpStatus] || "Unknown Error") + ']';
                this.error = HproseTags.TagError +
                             HproseFormatter.serialize(error, null, true).toString() +
                             HproseTags.TagEnd;
            }
        };
        if (timeout) {
            timeoutID = _global.setTimeout(function () {
                _global.clearTimeout(timeoutID);
                delete(timeoutID);
                lv.onData = function(src:String) { };
                lv.onLoad = function(success:Boolean) { lv.loaded = false; return; };
                lv.onHTTPStatus = function (httpStatus:Number) { };
                delete(lv);
                callback(HproseTags.TagError +
                         HproseFormatter.serialize("timeout", null, true).toString() +
                         HproseTags.TagEnd);
            }, timeout);
        }
        lv.sendAndLoad(url, lv, 'POST');
        return lv;
    }
}