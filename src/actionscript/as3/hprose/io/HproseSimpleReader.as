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
 * HproseSimpleReader.as                                  *
 *                                                        *
 * hprose simple reader class for ActionScript 3.0.       *
 *                                                        *
 * LastModified: Dec 27, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;
    import hprose.common.HproseException;

    public class HproseSimpleReader extends HproseRawReader {
        private const classref:Array = [];

        public function HproseSimpleReader(stream:IDataInput) {
            super(stream);
        }

        public function unserialize():* {
            var tag:int = stream.readByte();
            switch (tag) {
                case 48: return 0;
                case 49: return 1;
                case 50: return 2;
                case 51: return 3;
                case 52: return 4;
                case 53: return 5;
                case 54: return 6;
                case 55: return 7;
                case 56: return 8;
                case 57: return 9;
                case HproseTags.TagInteger: return readIntegerWithoutTag();
                case HproseTags.TagLong: return readLongWithoutTag();
                case HproseTags.TagDouble: return readDoubleWithoutTag();
                case HproseTags.TagNull: return null;
                case HproseTags.TagEmpty: return "";
                case HproseTags.TagTrue: return true;
                case HproseTags.TagFalse: return false;
                case HproseTags.TagNaN: return NaN;
                case HproseTags.TagInfinity: return readInfinityWithoutTag();
                case HproseTags.TagDate: return readDateWithoutTag();
                case HproseTags.TagTime: return readTimeWithoutTag();
                case HproseTags.TagBytes: return readBytesWithoutTag();
                case HproseTags.TagUTF8Char: return readUTF8CharWithoutTag();
                case HproseTags.TagString: return readStringWithoutTag();
                case HproseTags.TagGuid: return readGuidWithoutTag();
                case HproseTags.TagList: return readListWithoutTag();
                case HproseTags.TagMap: return readMapWithoutTag();
                case HproseTags.TagClass: readClass(); return readObject();
                case HproseTags.TagObject: return readObjectWithoutTag();
                case HproseTags.TagRef: return readRef();
                case HproseTags.TagError: throw new HproseException(readString());
                default: throw unexpectedTag(tag);
            }
        }

        public function checkTag(expectTag:int, tag:int = -1):void {
            if (tag == -1) tag = stream.readByte();
            if (tag != expectTag) unexpectedTag(tag, expectTag);
        }

        public function checkTags(expectTags:Array, tag:int = -1):int {
            if (tag == -1) tag = stream.readByte();
            if (expectTags.indexOf(tag) < 0) unexpectedTag(tag, expectTags);
            return tag;
        }

        public function readUntil(tag:int):String {
            var s:Array = [];
            var i:int = 0;
            var c:int = stream.readByte();
            while (c != tag) {
                s[i++] = String.fromCharCode(c);
                c = stream.readByte();
            }
            return s.join('');
        }

        public function readInt(tag:int):int {
            var s:String = readUntil(tag);
            if (s.length == 0) return 0;
            return int(parseInt(s, 10));
        }

        public function readIntegerWithoutTag():int {
            return readInt(HproseTags.TagSemicolon);
        }

        public function readInteger():int {
            var tag:int = stream.readByte();
            switch (tag) {
                case 48: return 0;
                case 49: return 1;
                case 50: return 2;
                case 51: return 3;
                case 52: return 4;
                case 53: return 5;
                case 54: return 6;
                case 55: return 7;
                case 56: return 8;
                case 57: return 9;
                case HproseTags.TagInteger: return readIntegerWithoutTag();
                default: throw unexpectedTag(tag);
            }
        }

        public function readLongWithoutTag():* {
            return readUntil(HproseTags.TagSemicolon);
        }

        public function readLong():* {
            var tag:int = stream.readByte();
            switch (tag) {
                case 48: return 0;
                case 49: return 1;
                case 50: return 2;
                case 51: return 3;
                case 52: return 4;
                case 53: return 5;
                case 54: return 6;
                case 55: return 7;
                case 56: return 8;
                case 57: return 9;
                case HproseTags.TagInteger:
                case HproseTags.TagLong: return readLongWithoutTag();
                default: throw unexpectedTag(tag);
            }
        }

        public function readDoubleWithoutTag():Number {
            return parseFloat(readUntil(HproseTags.TagSemicolon));
        }

        public function readDouble():Number {
            var tag:int = stream.readByte();
            switch (tag) {
                case 48: return 0;
                case 49: return 1;
                case 50: return 2;
                case 51: return 3;
                case 52: return 4;
                case 53: return 5;
                case 54: return 6;
                case 55: return 7;
                case 56: return 8;
                case 57: return 9;
                case HproseTags.TagInteger:
                case HproseTags.TagLong:
                case HproseTags.TagDouble: return readDoubleWithoutTag();
                case HproseTags.TagNaN: return NaN;
                case HproseTags.TagInfinity: return readInfinityWithoutTag();
                default: throw unexpectedTag(tag);
            }
        }

        public function readNaN():Number {
            checkTag(HproseTags.TagNaN);
            return NaN;
        }

        public function readInfinityWithoutTag():Number {
            return ((stream.readByte() == HproseTags.TagPos) ? Infinity : -Infinity);
        }

        public function readInfinity():Number {
            checkTag(HproseTags.TagInfinity);
            return readInfinityWithoutTag();
        }

        public function readNull():Object {
            checkTag(HproseTags.TagNull);
            return null;
        }

        public function readEmpty():String {
            checkTag(HproseTags.TagEmpty);
            return '';
        }

        public function readBoolean():Boolean {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagTrue: return true;
                case HproseTags.TagFalse: return false;
                default: throw unexpectedTag(tag);
            }
        }

        public function readDateWithoutTag():Date {
            var year:Number = parseInt(stream.readUTFBytes(4), 10);
            var month:Number = parseInt(stream.readUTFBytes(2), 10) - 1;
            var day:Number = parseInt(stream.readUTFBytes(2), 10);
            var date:Date;
            var tag:int = stream.readByte();
            if (tag == HproseTags.TagTime) {
                var hour:Number = parseInt(stream.readUTFBytes(2), 10);
                var minute:Number = parseInt(stream.readUTFBytes(2), 10);
                var second:Number = parseInt(stream.readUTFBytes(2), 10);
                var millisecond:Number = 0;
                tag = stream.readByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = parseInt(stream.readUTFBytes(3), 10);
                    tag = stream.readByte();
                }
                tag = stream.readByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = parseInt(stream.readUTFBytes(3), 10);
                    tag = stream.readByte();
                    if ((tag >= 48) && (tag <= 57)) {
                        stream.readByte();
                        stream.readByte();
                        tag = stream.readByte();
                        if ((tag >= 48) && (tag <= 57)) {
                            stream.readByte();
                            stream.readByte();
                            tag = stream.readByte();
                        }
                    }
                }
                if (tag == HproseTags.TagUTC) {
                    date = new Date(Date.UTC(year, month, day, hour, minute, second, millisecond));
                }
                else {
                    date = new Date(year, month, day, hour, minute, second, millisecond);
                }
            }
            else if (tag == HproseTags.TagUTC) {
                date = new Date(Date.UTC(year, month, day));
            }
            else {
                date = new Date(year, month, day);
            }
            return date;
        }

        public function readDate():Date {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagDate: return readDateWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readTimeWithoutTag():Date {
            var time:Date;
            var hour:Number = parseInt(stream.readUTFBytes(2), 10);
            var minute:Number = parseInt(stream.readUTFBytes(2), 10);
            var second:Number = parseInt(stream.readUTFBytes(2), 10);
            var millisecond:Number = 0;
            var tag:int = stream.readByte();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.readUTFBytes(3), 10);
                tag = stream.readByte();
                    if ((tag >= 48) && (tag <= 57)) {
                    stream.readByte();
                    stream.readByte();
                    tag = stream.readByte();
                    if ((tag >= 48) && (tag <= 57)) {
                        stream.readByte();
                        stream.readByte();
                        tag = stream.readByte();
                    }
                }
            }
            if (tag == HproseTags.TagUTC) {
                time = new Date(Date.UTC(1970, 0, 1, hour, minute, second, millisecond));
            }
            else {
                time = new Date(1970, 0, 1, hour, minute, second, millisecond);
            }
            return time;
        }

        public function readTime():Date {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagTime: return readTimeWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readBytesWithoutTag():ByteArray {
            var count:int = readInt(HproseTags.TagQuote);
            var bytes:ByteArray = new ByteArray();
            stream.readBytes(bytes, 0, count);
            bytes.position = 0;
            stream.readByte();
            return bytes;
        }

        public function readBytes():ByteArray {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagBytes: return readBytesWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readUTF8CharWithoutTag():String {
            var u: String;
            var c:uint, c2:uint, c3:uint;
            c = stream.readUnsignedByte();
            switch (c >>> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    // 0xxx xxxx
                    u = String.fromCharCode(c);
                    break;
                case 12:
                case 13:
                    // 110x xxxx   10xx xxxx
                    c2 = stream.readUnsignedByte();
                    u = String.fromCharCode(((c & 0x1f) << 6) |
                                                 (c2 & 0x3f));
                    break;
                case 14:
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    c2 = stream.readUnsignedByte();
                    c3 = stream.readUnsignedByte();
                    u = String.fromCharCode(((c & 0x0f) << 12) |
                                                ((c2 & 0x3f) << 6) |
                                                 (c3 & 0x3f));
                    break;
                default:
                    throw new HproseException("bad utf-8 encoding at 0x" + c.toString(16));
            }
            return u;
        }

        public function readUTF8Char():String {
            checkTag(HproseTags.TagUTF8Char);
            return readUTF8CharWithoutTag();
        }

        private function _readString():String {
            var len:int = readInt(HproseTags.TagQuote);
            var buf:Array = [];
            var c:uint, c2:uint, c3:uint, c4:uint;
            for (var i:int = 0; i < len; i++) {
                c = stream.readUnsignedByte();
                switch (c >>> 4) {
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                        // 0xxx xxxx
                        buf[i] = String.fromCharCode(c);
                        break;
                    case 12:
                    case 13:
                        // 110x xxxx   10xx xxxx
                        c2 = stream.readUnsignedByte();
                        buf[i] = String.fromCharCode(((c & 0x1f) << 6) |
                                                     (c2 & 0x3f));
                        break;
                    case 14:
                        // 1110 xxxx  10xx xxxx  10xx xxxx
                        c2 = stream.readUnsignedByte();
                        c3 = stream.readUnsignedByte();
                        buf[i] = String.fromCharCode(((c & 0x0f) << 12) |
                                                    ((c2 & 0x3f) << 6) |
                                                     (c3 & 0x3f));
                        break;
                    case 15:
                        // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                        if ((c & 0xf) <= 4) {
                            c2 = stream.readUnsignedByte();
                            c3 = stream.readUnsignedByte();
                            c4 = stream.readUnsignedByte();
                            var s:uint = ((c & 0x07) << 18) |
                                        ((c2 & 0x3f) << 12) |
                                        ((c3 & 0x3f) << 6)  |
                                         (c4 & 0x3f) - 0x10000;
                            if (0 <= s && s <= 0xfffff) {
                                buf[i++] = String.fromCharCode(((s >>> 10) & 0x03ff) | 0xd800);
                                buf[i] = String.fromCharCode((s & 0x03ff) | 0xdc00);
                                break;
                            }
                        }
                    // no break here!! here need throw exception.
                    default:
                        throw new HproseException("bad utf-8 encoding at 0x" + c.toString(16));
                }
            }
            stream.readByte();
            return buf.join('');
        }

        public function readStringWithoutTag():String {
            return _readString();
        }

        public function readString():String {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagString: return readStringWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readGuidWithoutTag():String {
            stream.readByte();
            var guid:String = stream.readUTFBytes(36);
            stream.readByte();
            return guid;
        }

        public function readGuid():String {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagGuid: return readGuidWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        protected function readListBegin():Array {
            return [];
        }

        protected function readListEnd(list:Array):Array {
            var count:int = readInt(HproseTags.TagOpenbrace);
            for (var i:int = 0; i < count; i++) {
                list[i] = unserialize();
            }
            stream.readByte();
            return list;
        }

        public function readListWithoutTag():Array {
            return readListEnd(readListBegin());
        }

        public function readList():Array {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagList: return readListWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        protected function readMapBegin():Dictionary {
            return new Dictionary();
        }

        protected function readMapEnd(map:Dictionary):Dictionary {
            var count:int = readInt(HproseTags.TagOpenbrace);
            for (var i:int = 0; i < count; i++) {
                var key:* = unserialize();
                var value:* = unserialize();
                map[key] = value;
            }
            stream.readByte();
            return map;
        }

        public function readMapWithoutTag():Dictionary {
            return readMapEnd(readMapBegin());
        }

        public function readMap():Dictionary {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagMap: return readMapWithoutTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        protected function readObjectBegin():* {
            var cls:Object = classref[readInt(HproseTags.TagOpenbrace)];
            var obj:* = new cls['class'];
            return {obj: obj, cls: cls};
        }

        protected function readObjectEnd(obj, cls):* {
            for (var i:int = 0; i < cls.count; i++) {
                obj[cls.properties[i]] = unserialize();
            }
            stream.readByte();
            return obj;
        }

        public function readObjectWithoutTag():* {
            var result = readObjectBegin();
            return readObjectEnd(result.obj, result.cls);
        }

        public function readObject():* {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagObject: return readObjectWithoutTag();
                case HproseTags.TagClass: readClass(); return readObject();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        private function readClass():void {
            var classname:String = _readString();
            var count:int = readInt(HproseTags.TagOpenbrace);
            var properties:Array = [];
            for (var i:uint = 0; i < count; i++) {
                properties[i] = readString();
            }
            stream.readByte();
            classref[classref.length] = {'class': HproseClassManager.getClass(classname),
                                         'count': count,
                                         'properties': properties};
        }

        protected function readRef():* {
            throw unexpectedTag(HproseTags.TagRef);
        }

        public function reset():void {
			classref.length = 0;
        }
    }
}