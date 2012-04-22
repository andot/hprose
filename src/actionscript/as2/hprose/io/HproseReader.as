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
 * LastModified: Jun 7, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
import hprose.io.ClassManager;
import hprose.io.HproseException;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;

class hprose.io.HproseReader {
    private static var classCache:Object = {};
    private static function findClass(cn:Array, poslist:Array, i:Number, c:String):Function {
        if (i < poslist.length) {
            var pos:Number = poslist[i];
            cn[pos] = c;
            var classReference:Function = findClass(cn, poslist, i + 1, '.');
            if (i + 1 < poslist.length) {
                if (classReference == null) {
                    classReference = findClass(cn, poslist, i + 1, '_');
                }
            }
            return classReference;
        }
        return eval(cn.join(''));
    }
    public static function getClass(classname:String):Function {
        var classReference = ClassManager.getClass(classname);
        if (classReference) {
            return classReference;
        }
        classReference = eval(classname);
        if (classReference) {
            ClassManager.register(classReference, classname);
            return classReference;
        }
        var poslist:Array = [];
        var pos:Number = classname.indexOf("_");
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
            classReference = function () {
                this.getClassName = function ():String {
                    return classname;
                }
            }
        }
        ClassManager.register(classReference, classname);
        return classReference;
    }

    private var ref:Array;
    private var classref:Array;
    private var stream:HproseStringInputStream;

    public function HproseReader(stream:HproseStringInputStream) {
        this.ref = [];
        this.classref = [];
        this.stream = stream;
    }

    public function get inputStream():HproseStringInputStream {
        return stream;
    }

    public function unserialize(tag:String) {
        if (tag === undefined) {
            tag = stream.getc();
        }
        switch (tag) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': return parseInt(tag);
            case HproseTags.TagInteger: return readInteger(false);
            case HproseTags.TagLong: return readLong(false);
            case HproseTags.TagDouble: return readDouble(false);
            case HproseTags.TagNull: return null;
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagEmpty: return "";
            case HproseTags.TagInfinity: return readInfinity(false);
            case HproseTags.TagDate: return readDate(false);
            case HproseTags.TagTime: return readTime(false);
            case HproseTags.TagUTF8Char: return stream.getc();
            case HproseTags.TagString: return readString(false);
            case HproseTags.TagGuid: return readGuid(false);
            case HproseTags.TagList: return readList(false);
            case HproseTags.TagMap: return readMap(false);
            case HproseTags.TagClass: readClass(); return unserialize();
            case HproseTags.TagObject: return readObject(false);
            case HproseTags.TagRef: return readRef();
            case HproseTags.TagError: throw new HproseException(readString());
            case '': throw new HproseException('No byte found in stream');
            default: throw new HproseException("Unexpected serialize tag '" +
                                                          tag + "' in stream");
        }
    }
        
    public function checkTag(expectTag:String, tag:String):Void {
        if (tag === undefined) tag = stream.getc();
        if (tag != expectTag) {
            throw new HproseException("Tag '" + expectTag + 
                "' expected, but '" + tag + "' found in stream");
        }
    }
    
    public function checkTags(expectTags:Array, tag:String):String {
        if (tag === undefined) tag = stream.getc();
        if (expectTags.indexOf(tag) < 0) {
            throw new HproseException("unexpected tag '" +
                                      tag + "' found in stream");
        }
        return tag;
    }

    private function readInt(tag) {
        var s = stream.readuntil(tag);
        if (s.length == 0) return 0;
        return parseInt(s);
    }

    public function readInteger(includeTag:Boolean):Number {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= '0') && (tag <= '9')) return parseInt(tag);
            checkTag(HproseTags.TagInteger, tag);
        }
        return readInt(HproseTags.TagSemicolon);
    }

    public function readLong(includeTag:Boolean):String {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= '0') && (tag <= '9')) return tag;
            checkTag(HproseTags.TagLong, tag);
        }
        return stream.readuntil(HproseTags.TagSemicolon);
    }

    public function readDouble(includeTag:Boolean):Number {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= '0') && (tag <= '9')) return parseFloat(tag);
            checkTag(HproseTags.TagDouble, tag);
        }
        return parseFloat(stream.readuntil(HproseTags.TagSemicolon));
    }
    
    public function readNaN():Number {
        checkTag(HproseTags.TagNaN);
        return NaN;
    }
    
    public function readInfinity(includeTag:Boolean):Number {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) checkTag(HproseTags.TagInfinity);
        return ((stream.getc() == HproseTags.TagNeg) ? -Infinity : Infinity);
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
        var tag = checkTags([HproseTags.TagTrue,
                             HproseTags.TagFalse]);
        return (tag == HproseTags.TagTrue);
    }
    
    public function readDate(includeTag:Boolean):Date {
        if (includeTag === undefined) includeTag = true;
        var tag;
        if (includeTag) {
             tag = checkTags([HproseTags.TagDate,
                              HproseTags.TagRef]);
              if (tag == HproseTags.TagRef) return readRef();
        }
        var year = parseInt(stream.read(4));
        var month = parseInt(stream.read(2)) - 1;
        var day = parseInt(stream.read(2));
        var date;
        tag = stream.getc();
        if (tag == HproseTags.TagTime) {
            var hour = parseInt(stream.read(2));
            var minute = parseInt(stream.read(2));
            var second = parseInt(stream.read(2));
            var millisecond = 0;
            tag = stream.getc();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.read(3));
                tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) {
                    stream.read(2);
                    tag = stream.getc();
                    if ((tag >= '0') && (tag <= '9')) {
                        stream.read(2);
                        tag = stream.getc();
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

    public function readTime(includeTag:Boolean):Date {
        if (includeTag === undefined) includeTag = true;
        var tag;
        if (includeTag) {
            tag = checkTags([HproseTags.TagTime,
                             HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var time;
        var hour = parseInt(stream.read(2));
        var minute = parseInt(stream.read(2));
        var second = parseInt(stream.read(2));
        var millisecond = 0;
        tag = stream.getc();
        if (tag == HproseTags.TagPoint) {
            millisecond = parseInt(stream.read(3));
            tag = stream.getc();
            if ((tag >= '0') && (tag <= '9')) {
                stream.read(2);
                tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) {
                    stream.read(2);
                    tag = stream.getc();
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

    public function readUTF8Char(includeTag:Boolean) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) checkTag(HproseTags.TagUTF8Char);
        return stream.getc();
    }

    public function readString(includeTag:Boolean, includeRef:Boolean):String {
        if (includeTag === undefined) includeTag = true;
        if (includeRef === undefined) includeRef = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagString,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var s = stream.read(readInt(HproseTags.TagQuote));
        stream.skip(1);
        if (includeRef) ref[ref.length] = s;
        return s;
    }

    public function readGuid(includeTag:Boolean):String {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagGuid,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        stream.skip(1);
        var s = stream.read(36);
        stream.skip(1);
        ref[ref.length] = s;
        return s;
    }

    public function readList(includeTag:Boolean):Array {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagList,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var list = [];
        ref[ref.length] = list;
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            list[i] = unserialize();
        }
        stream.skip(1);
        return list;
    }

    public function readMap(includeTag:Boolean):Object {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagMap,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var map = {};
        ref[ref.length] = map;
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            var key = unserialize();
            var value = unserialize();
            map[key] = value;
        }
        stream.skip(1);
        return map;
    }

    public function readObject(includeTag:Boolean) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagClass,
                                 HproseTags.TagObject,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
            if (tag == HproseTags.TagClass) {
                readClass();
                return readObject();
            }
        }
        var cls = classref[readInt(HproseTags.TagOpenbrace)];
        var obj = new cls.classname();
        ref[ref.length] = obj;
        for (var i = 0; i < cls.count; i++) {
            obj[cls.fields[i]] = unserialize();
        }
        stream.skip(1);
        return obj;
    }

    private function readClass():Void {
        var classname = readString(false, false);
        var count = readInt(HproseTags.TagOpenbrace);
        var fields = [];
        for (var i = 0; i < count; i++) {
            fields[i] = readString();
        }
        stream.skip(1);
        classname = getClass(classname);
        classref[classref.length] = {
            classname: classname,
            count: count,
            fields: fields
        };
    }

    private function readRef() {
        return ref[readInt(HproseTags.TagSemicolon)];
    }
    
    public function readRaw(ostream:HproseStringOutputStream, tag:String) {
        if (ostream === undefined) ostream = new HproseStringOutputStream();
        if (tag === undefined) tag = stream.getc();
        switch (tag) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case HproseTags.TagNull:
            case HproseTags.TagEmpty:
            case HproseTags.TagTrue:
            case HproseTags.TagFalse:
            case HproseTags.TagNaN:
                ostream.write(tag);
                break;
            case HproseTags.TagInfinity:
            case HproseTags.TagUTF8Char:
                ostream.write(tag);
                ostream.write(stream.getc());
                break;
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble:
            case HproseTags.TagRef:
                readNumberRaw(ostream);
                break;
            case HproseTags.TagDate:
            case HproseTags.TagTime:
                readDateTimeRaw(ostream, tag);
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
                ostream.write(tag);
                readRaw(ostream);
                break;
            case '':
                throw new HproseException('No byte found in stream');
            default:
                throw new HproseException("Unexpected serialize tag '" +
                                                          tag + "' in stream");
        }
        return ostream;
    }

    private function readNumberRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon);        
    }
    
    private function readDateTimeRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon &&
                 tag != HproseTags.TagUTC);
    }

    private function readStringRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        var s:String = stream.readuntil(HproseTags.TagQuote);
        ostream.write(s);
        ostream.write(HproseTags.TagQuote);
        var len = 0;
        if (s.length > 0) len = parseInt(s);
        ostream.write(stream.read(len));
        ostream.write(stream.getc());
    }

    private function readGuidRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        ostream.write(stream.read(38));
    }

    private function readComplexRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagOpenbrace);
        while ((tag = stream.getc()) != HproseTags.TagClosebrace) {
            readRaw(ostream, tag);
        }
        ostream.write(tag);
    }

    public function reset() {
        ref.length = 0;
        classref.length = 0;
    }
}