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
 * HproseStringInputStream.as                             *
 *                                                        *
 * hprose string input stream for ActionScript 2.0.       *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
class hprose.io.HproseStringInputStream {
    private var pos:Number;
    private var length:Number;
    private var str:String;
    public function HproseStringInputStream(str:String) {
		this.pos = 0;
        this.str = str;
        this.length = str.length;
    }
    public function getc():String {
        return str.charAt(pos++);
    }
    public function read(len):String {
        var s:String = str.substr(pos, len);
        this.skip(len);
        return s;
    }
    public function skip(n):Void {
        pos += n;
    }
    public function readuntil(tag:String):String {
        var p:Number = str.indexOf(tag, pos);
        var s:String;
        if (p !== -1) {
            s = str.substr(pos, p - pos);
            pos = p + tag.length;
        }
        else {
            s = str.substr(pos);
            pos = length;
        }
        return s;
    }
}