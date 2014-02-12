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
 * HproseProgressEvent.as                                 *
 *                                                        *
 * hprose progress event class for ActionScript 2.0.      *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
class hprose.client.HproseProgressEvent {
    public static var PROGRESS:String = 'progress';
    private var _bytesLoaded:Number;
    private var _bytesTotal:Number;

    public function HproseProgressEvent(bytesLoaded:Number, bytesTotal:Number) {
        this._bytesLoaded = bytesLoaded;
        this._bytesTotal = bytesTotal;
    }

    public function get bytesLoaded():Number {
        return _bytesLoaded;
    }

    public function get bytesTotal():Number {
        return _bytesTotal;
    }
}