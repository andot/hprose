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
 * HproseSuccessEvent.as                                  *
 *                                                        *
 * hprose success event class for ActionScript 2.0.       *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
class hprose.client.HproseSuccessEvent {
    public static var SUCCESS:String = 'success';
    private var _result;
    private var _args:Array;

    public function HproseSuccessEvent(result, args:Array) {
        this._result = result;
        this._args = args;
    }

    public function get result() {
        return _result;
    }

    public function get args():Array {
        return _args;
    }
}