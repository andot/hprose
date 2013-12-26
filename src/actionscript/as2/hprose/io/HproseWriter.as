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
 * HproseWriter.as                                        *
 *                                                        *
 * hprose writer class for ActionScript 2.0.              *
 *                                                        *
 * LastModified: Dec 26, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.common.Map;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseSimpleWriter;
import hprose.io.HproseTags;

class hprose.io.HproseWriter extends HproseSimpleWriter {
    private var ref:Map;
    private var refcount:Number;

    public function HproseWriter(stream:HproseStringOutputStream) {
        super(stream);
        ref = new Map();
        refcount = 0;
    }

    public function writeUTCDate(date):Void {
        ref.set(date, refcount++);
        super.writeUTCDate(date);
    }

    public function writeDate(date):Void {
        ref.set(date, refcount++);
        super.writeDate(date);
    }

    public function writeTime(time):Void {
        ref.set(time, refcount++);
        super.writeTime(time);
    }

    public function writeString(str):Void {
        ref.set(str, refcount++);
        super.writeString(str);
    }

    public function writeList(list):Void {
        ref.set(list, refcount++);
        super.writeList(list);
    }

    public function writeMap(map):Void {
        ref.set(map, refcount++);
        super.writeMap(map);
    }

    public function writeObject(obj):Void {
        var fields = writeObjectBegin(obj);
        ref.set(obj, refcount++);
        writeObjectEnd(obj, fields);
    }

    public function writeRef(obj):Boolean {
        var index = ref.get(obj);
        if (index !== undefined) {
            stream.write(HproseTags.TagRef + index + HproseTags.TagSemicolon);
            return true;
        }
        return false;
    }

    public function reset():Void {
        super.reset();
        ref = new Map();
        refcount = 0;
    }
}