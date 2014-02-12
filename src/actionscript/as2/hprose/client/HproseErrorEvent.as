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
 * HproseErrorEvent.as                                    *
 *                                                        *
 * hprose error event class for ActionScript 2.0.         *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
class hprose.client.HproseErrorEvent {
    public static var ERROR:String = 'error';
    private var _name:String;
    private var _error:Error;

    public function HproseErrorEvent(name:String, error:Error) {
        this._name = name;
        this._error = error;
    }

    public function get name():String {
        return _name;
    }

    public function get error():Error {
        return _error;
    }
}