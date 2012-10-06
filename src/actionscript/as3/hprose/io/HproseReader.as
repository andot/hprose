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
 * LastModified: Jun 6, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;
    import flash.utils.getDefinitionByName;

    public final class HproseReader {
        private static function findClass(cn:Array, poslist:Array, i:uint, c:String):Class {
            if (i < poslist.length) {
                var pos:uint = poslist[i];
                cn[pos] = c;
                var classReference:Class = findClass(cn, poslist, i + 1, '.');
                if (i + 1 < poslist.length) {
                    if (classReference == null) {
                        classReference = findClass(cn, poslist, i + 1, '_');
                    }
                }
                return classReference;
            }
            var classname:String = cn.join('');
            try {
                return getDefinitionByName(classname) as Class;
            }
            catch (e:ReferenceError) {};
            return null;
        }

        public static function getClass(classname:String):* {
            var classReference:* = ClassManager.getClass(classname);
            if (classReference) {
                return classReference;
            }
            try {
                classReference = getDefinitionByName(classname) as Class;
                ClassManager.register(classReference, classname);
                return classReference;
            }
            catch (e:ReferenceError) {}
            var poslist:Array = [];
            var pos:int = classname.indexOf("_");
            while (pos > -1) {
                poslist[poslist.length] = pos;
                pos = classname.indexOf("_", pos + 1);
            }
            if (poslist.length > 0) {
                var cn:Array = classname.split('');
                classReference = findClass(cn, poslist, 0, '.');
                if (classReference == null) {
                    classReference = findClass(cn, poslist, 0, '_');
                }
            }
            if (classReference == null) {
                classReference = function ():void {
                    this.getClassName = function ():String {
                        return classname;
                    }
                }
            }
            ClassManager.register(classReference, classname);
            return classReference;
        }
        
        private const ref:Array = [];
        private const classref:Array = [];
        private var stream:IDataInput;

        public function HproseReader(stream:IDataInput) {
            this.stream = stream;
        }

        public function get inputStream():IDataInput {
            return stream;
        }

        public function unserialize(tag:int = -1):* {
            if (tag == -1) {
                tag = stream.readByte();
            }
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
                case 57: return tag - 48;
                case HproseTags.TagInteger: return readInteger(false);
                case HproseTags.TagLong: return readLong(false);
                case HproseTags.TagDouble: return readDouble(false);
                case HproseTags.TagNull: return null;
                case HproseTags.TagEmpty: return "";
                case HproseTags.TagTrue: return true;
                case HproseTags.TagFalse: return false;
                case HproseTags.TagNaN: return NaN;
                case HproseTags.TagInfinity: return readInfinity(false);
                case HproseTags.TagDate: return readDate(false);
                case HproseTags.TagTime: return readTime(false);
                case HproseTags.TagBytes: return readBytes(false);
                case HproseTags.TagUTF8Char: return readUTF8Char(false);
                case HproseTags.TagString: return readString(false);
                case HproseTags.TagGuid: return readGuid(false);
                case HproseTags.TagList: return readList(false);
                case HproseTags.TagMap: return readMap(false);
                case HproseTags.TagClass: readClass(); return unserialize();
                case HproseTags.TagObject: return readObject(false);
                case HproseTags.TagRef: return readRef();
                case HproseTags.TagError: throw new HproseException(readString());
                default: throw new HproseException("Unexpected serialize tag 0x" +
                                                   tag.toString(16) + " in stream");
            }
        }
    
        public function checkTag(expectTag:int, tag:int = -1):void {
            if (tag == -1) tag = stream.readByte();
            if (tag != expectTag) {
                throw new HproseException("Tag '" +
                    String.fromCharCode(expectTag) + 
                    "' expected, but '" +
                    String.fromCharCode(tag) +
                    "' found in stream");
            }
        }
        
        public function checkTags(expectTags:Array, tag:int = -1):int {
            if (tag == -1) tag = stream.readByte();
            if (expectTags.indexOf(tag) < 0) {
                throw new HproseException("unexpected tag '" +
                    String.fromCharCode(tag) +
                    "' found in stream");
            }
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

        public function readInteger(includeTag:Boolean = true):int {
            if (includeTag) {
                var tag:int = stream.readByte();
                if ((tag >= 48) && (tag <= 57)) return tag - 48;
                checkTag(HproseTags.TagInteger, tag);
            }﻿
            return readInt(HproseTags.TagSemicolon);            
        }
        
        public function readDouble(includeTag:Boolean = true):Number {
            if (includeTag) {
                var tag:int = stream.readByte();
                if ((tag >= 48) && (tag <= 57)) return tag - 48;
                checkTag(HproseTags.TagDouble, tag);
            }﻿
            return parseFloat(readUntil(HproseTags.TagSemicolon));
        }
        
        public function readLong(includeTag:Boolean = true):* {
            if (includeTag) {
                var tag:int = stream.readByte();
                if ((tag >= 48) && (tag <= 57)) return tag - 48;
                checkTag(HproseTags.TagLong, tag);
            }﻿
            return readUntil(HproseTags.TagSemicolon);
        }
        
        public function readNaN():Number {
            checkTag(HproseTags.TagNaN);
            return NaN;
        }
        
        public function readInfinity(includeTag:Boolean = true):Number {
            if (includeTag) checkTag(HproseTags.TagInfinity);
            return ((stream.readByte() == HproseTags.TagPos) ? Infinity : -Infinity);
        }

        public function readNull():Object {
            checkTag(HproseTags.TagNull);
            return null;
        }
        
        public function readEmpty():Object {
            checkTag(HproseTags.TagEmpty);
            return "";
        }

        public function readBoolean():Boolean {
            return (checkTags([HproseTags.TagTrue, HproseTags.TagFalse]) == HproseTags.TagTrue);
        }
        
        public function readDate(includeTag:Boolean = true):Date {
            var tag:int;
            if (includeTag) {
                tag = checkTags([HproseTags.TagDate,
                                 HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
            var year:Number = parseInt(stream.readMultiByte(4, "iso-8859-1"));
            var month:Number = parseInt(stream.readMultiByte(2, "iso-8859-1")) - 1;
            var day:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
            var date:Date;
            tag = stream.readByte();
            if (tag == HproseTags.TagTime) {
                var hour:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
                var minute:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
                var second:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
                var millisecond:Number = 0;
                tag = stream.readByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = parseInt(stream.readMultiByte(3, "iso-8859-1"));
                    tag = stream.readByte();
                }
                tag = stream.readByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = parseInt(stream.readMultiByte(3, "iso-8859-1"));
                    tag = stream.readByte();
                    if ((tag >= '0'.charCodeAt(0)) && (tag <= '9'.charCodeAt(0))) {
                        stream.readByte();
                        stream.readByte();
                        tag = stream.readByte();
                        if ((tag >= '0'.charCodeAt(0)) && (tag <= '9'.charCodeAt(0))) {
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
            ref[ref.length] = date;
            return date;
        }

        public function readTime(includeTag:Boolean = true):Date {
            var tag:int;
            if (includeTag) {
                tag = checkTags([HproseTags.TagTime,
                                 HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
            var time:Date;
            var hour:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
            var minute:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
            var second:Number = parseInt(stream.readMultiByte(2, "iso-8859-1"));
            var millisecond:Number = 0;
            tag = stream.readByte();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.readMultiByte(3, "iso-8859-1"));
                tag = stream.readByte();
                if ((tag >= '0'.charCodeAt(0)) && (tag <= '9'.charCodeAt(0))) {
                    stream.readByte();
                    stream.readByte();
                    tag = stream.readByte();
                    if ((tag >= '0'.charCodeAt(0)) && (tag <= '9'.charCodeAt(0))) {
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
            ref[ref.length] = time;
            return time;
        }

        public function readBytes(includeTag:Boolean = true):ByteArray {
            if (includeTag) {
                var tag:int = checkTags([HproseTags.TagBytes,
                                         HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
            var count:int = readInt(HproseTags.TagQuote);
            var bytes:ByteArray = new ByteArray();
            stream.readBytes(bytes, 0, count);
            checkTag(HproseTags.TagQuote);
            ref[ref.length] = bytes;
            return bytes;
        }

        public function readUTF8Char(includeTag:Boolean = true):String {
            if (includeTag) {
                checkTag(HproseTags.TagUTF8Char);
            }
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

        public function readString(includeTag:Boolean = true, includeRef:Boolean = true):String {
            if (includeTag) {
                var tag:int = checkTags([HproseTags.TagString,
                                         HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
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
            checkTag(HproseTags.TagQuote);
            var str:String = buf.join('');
            if (includeRef) ref[ref.length] = str;
            return str;
        }

        public function readGuid(includeTag:Boolean = true):String {
            if (includeTag) {
                var tag:int = checkTags([HproseTags.TagGuid,
                                         HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
            checkTag(HproseTags.TagOpenbrace);
            var buf:Array = [];
            for (var i:int = 0; i < 16; i++) {
                buf[i] = String.fromCharCode(stream.readUnsignedByte());
            }
            checkTag(HproseTags.TagClosebrace);
            var guid:String = buf.join('');
            ref[ref.length] = guid;
            return guid;
        }

        public function readList(includeTag:Boolean = true):Array {
            if (includeTag) {
                var tag:int = checkTags([HproseTags.TagList,
                                         HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
            var list:Array = [];
            ref[ref.length] = list;
            var count:int = readInt(HproseTags.TagOpenbrace);
            for (var i:int = 0; i < count; i++) {
                list[i] = unserialize();
            }
            checkTag(HproseTags.TagClosebrace);
            return list;
        }

        public function readMap(includeTag:Boolean = true):Dictionary {
            if (includeTag) {
                var tag:int = checkTags([HproseTags.TagMap,
                                         HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
            }
            var map:Dictionary = new Dictionary();
            ref[ref.length] = map;
            var count:int = readInt(HproseTags.TagOpenbrace);
            for (var i:int = 0; i < count; i++) {
                var key:* = unserialize();
                var value:* = unserialize();
                map[key] = value;
            }
            checkTag(HproseTags.TagClosebrace);
            return map;
        }

        public function readObject(includeTag:Boolean = true):* {
            if (includeTag) {
                var tag:int = checkTags([HproseTags.TagClass,
                                         HproseTags.TagObject,
                                         HproseTags.TagRef]);
                if (tag == HproseTags.TagRef) return readRef();
                if (tag == HproseTags.TagClass) {
                    readClass();
                    return readObject();
                }
            }
            var type:Object = classref[readInt(HproseTags.TagOpenbrace)];
            var object:* = new type['class'];
            var properties:Array = type['properties'];
            var count:int = type['count'];
            ref[ref.length] = object;
            for (var i:int = 0; i < count; i++) {
                object[properties[i]] = unserialize();
            }
            checkTag(HproseTags.TagClosebrace);
            return object;
        }

        private function readClass():void {
            var classname:String = readString(false, false);
            var count:int = readInt(HproseTags.TagOpenbrace);
            var properties:Array = [];
            for (var i:uint = 0; i < count; i++) {
                properties[i] = readString();
            }
            checkTag(HproseTags.TagClosebrace);
            classref[classref.length] = {'class': getClass(classname),
                                         'count': count,
                                         'properties': properties};
        }

        private function readRef():* {
            return ref[readInt(HproseTags.TagSemicolon)];
        }

        public function readRaw(ostream:ByteArray = null, tag:int = -1):ByteArray {
            if (ostream == null) ostream = new ByteArray();
            if (tag == -1) tag = stream.readByte();
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
                    readRaw(ostream);
                    break;
                case HproseTags.TagError:
                    ostream.writeByte(tag);
                    readRaw(ostream);
                    break;
                default:
                    throw new HproseException("Unexpected serialize tag 0x" +
                                              tag.toString(16) + " in stream");

            }
            return ostream;
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
                readRaw(ostream, tag);
            }
            ostream.writeByte(tag);
        }

        public function reset():void {
            ref.length = 0;
			classref.length = 0;
        }
    }
}