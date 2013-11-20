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
 * LastModified: Nov 20, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.common.Map;
import hprose.io.HproseClassManager;
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

    private function writeRef(obj, checkRef, writeBegin, writeEnd) {
        var index;
        if (checkRef && ((index = ref.get(obj)) !== undefined)) {
            stream.write(HproseTags.TagRef + index + HproseTags.TagSemicolon);
        }
        else {
            var result = writeBegin.call(this, obj);
            ref.set(obj, refcount++);
            writeEnd.call(this, obj, result);
        }
    }
    
    public function reset() {
        super.reset();
        ref = new Map();
        refcount = 0;
    }
    
    private function doNothing() {};
    
    public function writeUTCDate(date, checkRef) {
        writeRef.call(this, date, checkRef, doNothing, super.writeUTCDate);
    }

    public function writeDate(date, checkRef) {
        writeRef.call(this, date, checkRef, doNothing, super.writeDate);
    }

    public function writeTime(time, checkRef) {
        writeRef.call(this, time, checkRef, doNothing, super.writeTime);
    }

    public function writeString(str, checkRef) {
        writeRef.call(this, str, checkRef, doNothing, super.writeString);
    }

    public function writeList(list, checkRef) {
        writeRef.call(this, list, checkRef, doNothing, super.writeList);
    }

    public function writeMap(map, checkRef) {
        writeRef.call(this, map, checkRef, doNothing, super.writeMap);
    }

    private function writeObject(obj, checkRef) {
        writeRef.call(this, obj, checkRef, writeObjectBegin, writeObjectEnd);
    }
}