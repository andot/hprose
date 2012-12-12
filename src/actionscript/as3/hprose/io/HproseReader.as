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
 * hprose reader class for ActionScript 3.0.              *
 *                                                        *
 * LastModified: Dec 12, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;

    public final class HproseReader {
        private const ref:Array = [];
        private const classref:Array = [];
        private var stream:IDataInput;

        public function HproseReader(stream:IDataInput) {
            this.stream = stream;
        }

        public function get inputStream():IDataInput {
            return stream;
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
                case HproseTags.TagInteger: return readInteger();
                case HproseTags.TagLong: return readLong();
                case HproseTags.TagDouble: return readDouble();
                case HproseTags.TagNull: return null;
                case HproseTags.TagEmpty: return "";
                case HproseTags.TagTrue: return true;
                case HproseTags.TagFalse: return false;
                case HproseTags.TagNaN: return NaN;
                case HproseTags.TagInfinity: return readInfinity();
                case HproseTags.TagDate: return readDate();
                case HproseTags.TagTime: return readTime();
                case HproseTags.TagBytes: return readBytes();
                case HproseTags.TagUTF8Char: return readUTF8Char();
                case HproseTags.TagString: return readString();
                case HproseTags.TagGuid: return readGuid();
                case HproseTags.TagList: return readList();
                case HproseTags.TagMap: return readMap();
                case HproseTags.TagClass: readClass(); return readObjectWithTag();
                case HproseTags.TagObject: return readObject();
                case HproseTags.TagRef: return readRef();
                case HproseTags.TagError: throw new HproseException(readStringWithTag());
                default: throw unexpectedTag(tag);
            }
        }

        public function unexpectedTag(tag:int, expectTags:* = null):HproseException {
            if (expectTags == null) {
                return new HproseException("Unexpected serialize tag 0x" + tag.toString(16) + " in stream");
            }
            var expectTag:String = "";
            if (expectTags is Array) {
                for (var t:String in expectTags) {
                    expectTag += String.fromCharCode(t);
                }
            }
            else {
                expectTag = expectTags;
            }
            return new HproseException("Tag '" + String.fromCharCode(expectTag) + "' expected, " +
                                      "but 0x" + tag.toString(16) + " found in stream");
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
            return int(parseInt(s));
        }

        public function readInteger():int {
            return readInt(HproseTags.TagSemicolon);
        }

        public function readIntegerWithTag():int {
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
                case HproseTags.TagInteger: return readInteger();
                default: throw unexpectedTag(tag);
            }
        }

        public function readLong():* {
            return readUntil(HproseTags.TagSemicolon);
        }

        public function readLongWithTag():* {
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
                case HproseTags.TagInteger: return readLong();
                case HproseTags.TagLong: return readLong();
                default: throw unexpectedTag(tag);
            }
        }

        public function readDouble():Number {
            return parseFloat(readUntil(HproseTags.TagSemicolon));
        }

        public function readDoubleWithTag():Number {
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
                case HproseTags.TagInteger: return readDouble();
                case HproseTags.TagLong: return readDouble();
                case HproseTags.TagDouble: return readDouble();
                default: throw unexpectedTag(tag);
            }
        }

        public function readNaN():Number {
            return NaN;
        }

        public function readNaNWithTag():Number {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagNaN: return NaN;
                default: throw unexpectedTag(tag);
            }
        }

        public function readInfinity():Number {
            return ((stream.readByte() == HproseTags.TagPos) ? Infinity : -Infinity);
        }

        public function readInfinityWithTag():Number {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagInfinity: return readInfinity();
                default: throw unexpectedTag(tag);
            }
        }

        public function readNull():Object {
            return null;
        }

        public function readNullWithTag():Object {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagNull: return null;
                default: throw unexpectedTag(tag);
            }
        }

        public function readEmpty():String {
            return "";
        }

        public function readEmptyWithTag():String {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagEmpty: return "";
                default: throw unexpectedTag(tag);
            }
        }

        public function readBooleanWithTag():Boolean {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagTrue: return true;
                case HproseTags.TagFalse: return false;
                default: throw unexpectedTag(tag);
            }
        }

        public function readDate():Date {
            var year:Number = parseInt(stream.readUTFBytes(4));
            var month:Number = parseInt(stream.readUTFBytes(2)) - 1;
            var day:Number = parseInt(stream.readUTFBytes(2));
            var date:Date;
            var tag:int = stream.readByte();
            if (tag == HproseTags.TagTime) {
                var hour:Number = parseInt(stream.readUTFBytes(2));
                var minute:Number = parseInt(stream.readUTFBytes(2));
                var second:Number = parseInt(stream.readUTFBytes(2));
                var millisecond:Number = 0;
                tag = stream.readByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = parseInt(stream.readUTFBytes(3));
                    tag = stream.readByte();
                }
                tag = stream.readByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = parseInt(stream.readUTFBytes(3));
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
            return ref[ref.length] = date;
        }

        public function readDateWithTag():Date {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagDate: return readDate();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readTime():Date {
            var time:Date;
            var hour:Number = parseInt(stream.readUTFBytes(2));
            var minute:Number = parseInt(stream.readUTFBytes(2));
            var second:Number = parseInt(stream.readUTFBytes(2));
            var millisecond:Number = 0;
            var tag:int = stream.readByte();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.readUTFBytes(3));
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
            return ref[ref.length] = time;
        }

        public function readTimeWithTag():Date {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagTime: return readTime();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readBytes():ByteArray {
            var count:int = readInt(HproseTags.TagQuote);
            var bytes:ByteArray = new ByteArray();
            stream.readBytes(bytes, 0, count);
            bytes.position = 0;
            stream.readByte();
            return ref[ref.length] = bytes;
        }

        public function readBytesWithTag():ByteArray {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagBytes: return readBytes();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readUTF8Char():String {
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

        public function readUTF8CharWithTag():String {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagUTF8Char: return readUTF8Char();
                default: throw unexpectedTag(tag);
            }
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
        
        public function readString():String {
            return ref[ref.length] = _readString();
        }

        public function readStringWithTag():String {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagString: return readString();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readGuid():String {
            stream.readByte();
            var guid:String = stream.readUTFBytes(36);
            stream.readByte();
            ref[ref.length] = guid;
            return guid;
        }

        public function readGuidWithTag():String {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagGuid: return readGuid();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readList():Array {
            var list:Array = [];
            ref[ref.length] = list;
            var count:int = readInt(HproseTags.TagOpenbrace);
            for (var i:int = 0; i < count; i++) {
                list[i] = unserialize();
            }
            stream.readByte();
            return list;
        }

        public function readListWithTag():Array {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagList: return readList();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readMap():Dictionary {
            var map:Dictionary = new Dictionary();
            ref[ref.length] = map;
            var count:int = readInt(HproseTags.TagOpenbrace);
            for (var i:int = 0; i < count; i++) {
                var key:* = unserialize();
                var value:* = unserialize();
                map[key] = value;
            }
            stream.readByte();
            return map;
        }

        public function readMapWithTag():Dictionary {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagMap: return readMap();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        public function readObject():* {
            var type:Object = classref[readInt(HproseTags.TagOpenbrace)];
            var object:* = new type['class'];
            var properties:Array = type['properties'];
            var count:int = type['count'];
            ref[ref.length] = object;
            for (var i:int = 0; i < count; i++) {
                object[properties[i]] = unserialize();
            }
            stream.readByte();
            return object;
        }

        public function readObjectWithTag():* {
            var tag:int = stream.readByte();
            switch (tag) {
                case HproseTags.TagObject: return readObject();
                case HproseTags.TagClass: readClass(); return readObjectWithTag();
                case HproseTags.TagRef: return readRef();
                default: throw unexpectedTag(tag);
            }
        }

        private function readClass():void {
            var classname:String = _readString();
            var count:int = readInt(HproseTags.TagOpenbrace);
            var properties:Array = [];
            for (var i:uint = 0; i < count; i++) {
                properties[i] = readStringWithTag();
            }
            stream.readByte();
            classref[classref.length] = {'class': ClassManager.getClass(classname),
                                         'count': count,
                                         'properties': properties};
        }

        private function readRef():* {
            return ref[readInt(HproseTags.TagSemicolon)];
        }

        public function readRaw():ByteArray {
            var ostream:ByteArray = new ByteArray();
            _readRaw(ostream, stream.readByte());
            ostream.position = 0;
			return ostream;
		}

        private function _readRaw(ostream:ByteArray, tag:int):void {
            switch (tag) {
                case 48:
                case 49:
                case 50:
                case 51:
                case 52:
                case 53:
                case 54:
                case 55:
                case 56:
                case 57:
                case HproseTags.TagNull:
                case HproseTags.TagEmpty:
                case HproseTags.TagTrue:
                case HproseTags.TagFalse:
                case HproseTags.TagNaN:
                    ostream.writeByte(tag);
                    break;
                case HproseTags.TagInfinity:
                    ostream.writeByte(tag);
                    ostream.writeByte(stream.readByte());
                    break;
                case HproseTags.TagInteger:
                case HproseTags.TagLong:
                case HproseTags.TagDouble:
                case HproseTags.TagRef:
                    readNumberRaw(ostream, tag);
                    break;
                case HproseTags.TagDate:
                case HproseTags.TagTime:
                    readDateTimeRaw(ostream, tag);
                    break;
                case HproseTags.TagUTF8Char:
                    readUTF8CharRaw(ostream, tag);
                    break;
                case HproseTags.TagBytes:
                    readBytesRaw(ostream, tag);
                    break;
                case HproseTags.TagString:
                    readStringRaw(ostream, tag);
                    break;
                case HproseTags.TagGuid:
                    readGuidRaw(ostream, tag);
                    break;
                case HproseTags.TagList:
                case HproseTags.TagMap:
                case HproseTags.TagObject:
                    readComplexRaw(ostream, tag);
                    break;
                case HproseTags.TagClass:
                    readComplexRaw(ostream, tag);
                    _readRaw(ostream, stream.readByte());
                    break;
                case HproseTags.TagError:
                    ostream.writeByte(tag);
                    _readRaw(ostream, stream.readByte());
                    break;
                default:
                    throw unexpectedTag(tag);
            }
        }

        private function readNumberRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            do {
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagSemicolon);
        }

        private function readDateTimeRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            do {
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagSemicolon &&
                     tag != HproseTags.TagUTC);
        }

        private function readUTF8CharRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            tag = stream.readByte();
            switch ((tag & 0xff) >>> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    ostream.writeByte(tag);
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    ostream.writeByte(tag);
                    ostream.writeByte(stream.readByte());
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    ostream.writeByte(tag);
                    ostream.writeByte(stream.readByte());
                    ostream.writeByte(stream.readByte());
                    break;
                }
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                                              ((tag < 0) ? "end of stream" :
                                                  "0x" + (tag & 0xff).toString(16)));
            }
        }

        private function readBytesRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            var count:int = 0;
            tag = 48;
            do {
                count *= 10;
                count += tag - 48;
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagQuote);
            stream.readBytes(ostream, ostream.position, count);
            ostream.position = ostream.length;
            ostream.writeByte(stream.readByte());
        }

        private function readStringRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            var count:int = 0;
            tag = 48;
            do {
                count *= 10;
                count += tag - 48;
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagQuote);
            for (var i:int = 0; i < count; i++) {
                tag = stream.readByte();
                switch ((tag & 0xff) >>> 4) {
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7: {
                        // 0xxx xxxx
                        ostream.writeByte(tag);
                        break;
                    }
                    case 12:
                    case 13: {
                        // 110x xxxx   10xx xxxx
                        ostream.writeByte(tag);
                        ostream.writeByte(stream.readByte());
                        break;
                    }
                    case 14: {
                        // 1110 xxxx  10xx xxxx  10xx xxxx
                        ostream.writeByte(tag);
                        ostream.writeByte(stream.readByte());
                        ostream.writeByte(stream.readByte());
                        break;
                    }
                    case 15: {
                        // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                        if ((tag & 0xf) <= 4) {
                            ostream.writeByte(tag);
                            ostream.writeByte(stream.readByte());
                            ostream.writeByte(stream.readByte());
                            ostream.writeByte(stream.readByte());
                            break;
                        }
                    // no break here!! here need throw exception.
                    }
                    default:
                        throw new HproseException("bad utf-8 encoding at " +
                                                  ((tag < 0) ? "end of stream" :
                                                      "0x" + (tag & 0xff).toString(16)));
                }
            }
            ostream.writeByte(stream.readByte());
        }

        private function readGuidRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            stream.readBytes(ostream, ostream.position, 38);
            ostream.position = ostream.length;
        }

        private function readComplexRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
            do {
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagOpenbrace);
            while ((tag = stream.readByte()) != HproseTags.TagClosebrace) {
                _readRaw(ostream, tag);
            }
            ostream.writeByte(tag);
        }

        public function reset():void {
            ref.length = 0;
			classref.length = 0;
        }
    }
}