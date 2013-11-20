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
 * HproseReader.as                                        *
 *                                                        *
 * hprose reader class for ActionScript 2.0.              *
 *                                                        *
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.io.HproseStringInputStream;
import hprose.io.HproseSimpleReader;
import hprose.io.HproseTags;

class hprose.io.HproseReader extends HproseSimpleReader {
    private var ref:Array;

    public function HproseReader(stream:HproseStringInputStream) {
        super(stream);
        this.ref = [];
    }

    public function readDateWithoutTag():Date {
        return ref[ref.length] = super.readDateWithoutTag();
    }

    public function readTimeWithoutTag():Date {
        return ref[ref.length] = super.readTimeWithoutTag();
    }

    public function readStringWithoutTag():String {
        return ref[ref.length] = super.readStringWithoutTag();
    }

    public function readGuidWithoutTag():String {
        return ref[ref.length] = super.readGuidWithoutTag();
    }

    public function readListWithoutTag():Array {
        return readListEnd(ref[ref.length] = readListBegin());
    }

    public function readMapWithoutTag():Object {
        return readMapEnd(ref[ref.length] = readMapBegin());
    }

    public function readObjectWithoutTag() {
        var result = readObjectBegin();
        ref[ref.length] = result.obj;
        return readObjectEnd(result.obj, result.cls);
    }

    private function readRef() {
        return ref[readInt(HproseTags.TagSemicolon)];
    }

    public function reset() {
        super.reset();
        ref.length = 0;
    }
}