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
 * HproseStringOutputStream.as                            *
 *                                                        *
 * hprose string output stream for ActionScript 2.0.      *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
class hprose.io.HproseStringOutputStream {
    private var str:String;
    private var buf:Array;
    private var size:Number;
    public function HproseStringOutputStream(str:String) {
        if (str === undefined) str = '';
        buf = [str];
        size = buf.length;
    }
    public function write(s:String):Void {
        buf[size++] = s;
    }
    public function mark():Void {
        str = this.toString();
    }
    public function reset():Void {
        buf = [str];
    }
    public function clear():Void {
        buf = [];
    }
    public function toString():String {
        return buf.join('');
    }
}