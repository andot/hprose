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
 * LastModified: Dec 11, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
import hprose.io.ClassManager;
import hprose.io.HproseException;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;

class hprose.io.HproseReader {
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

    public function unserialize() {
        var tag = stream.getc();
        switch (tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags.TagInteger: return readInteger();
            case HproseTags.TagLong: return readLong();
            case HproseTags.TagDouble: return readDouble();
            case HproseTags.TagNull: return null;
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagEmpty: return "";
            case HproseTags.TagInfinity: return readInfinity();
            case HproseTags.TagDate: return readDate();
            case HproseTags.TagTime: return readTime();
            case HproseTags.TagUTF8Char: return stream.getc();
            case HproseTags.TagString: return readString();
            case HproseTags.TagGuid: return readGuid();
            case HproseTags.TagList: return readList();
            case HproseTags.TagMap: return readMap();
            case HproseTags.TagClass: readClass(); return unserialize();
            case HproseTags.TagObject: return readObject();
            case HproseTags.TagRef: return readRef();
            case HproseTags.TagError: throw new HproseException(readStringWithTag());
            default: unexpectedTag(tag);
        }
    }

    public function unexpectedTag(tag:String, expectTags:String):Void {
        if (tag && expectTags) {
            throw new HproseException("Tag '" + expectTags + "' expected, but '" + tag + "' found in stream");
        }
        else if (tag) {
            throw new HproseException("Unexpected serialize tag '" + tag + "' in stream")
        }
        else {
            throw new HproseException('No byte found in stream');
        }
    }

    private function _checkTag(tag:String, expectTag:String):Void {
        if (tag != expectTag) unexpectedTag(tag, expectTag);
    }

    public function checkTag(expectTag:String):Void {
         _checkTag(stream.getc(), expectTag);
    }

    private function _checkTags(tag:String, expectTags:Array):String {
        if (expectTags.indexOf(tag) < 0) unexpectedTag(tag, expectTags.join(''));
        return tag;
    }

    public function checkTags(expectTags:Array):String {
        return _checkTags(stream.getc(), expectTags);
    }

    private function readInt(tag) {
        var s = stream.readuntil(tag);
        if (s.length == 0) return 0;
        return parseInt(s);
    }

    public function readInteger():Number {
        return readInt(HproseTags.TagSemicolon);
    }

    public function readIntegerWithTag():Number {
        var tag = stream.getc();
        switch (tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags.TagInteger: return readInteger();
            default: unexpectedTag(tag);
        }
    }

    public function readLong():String {
        return stream.readuntil(HproseTags.TagSemicolon);
    }

    public function readLongWithTag():String {
        var tag = stream.getc();
        switch (tag) {
            case '0': return '0';
            case '1': return '1';
            case '2': return '2';
            case '3': return '3';
            case '4': return '4';
            case '5': return '5';
            case '6': return '6';
            case '7': return '7';
            case '8': return '8';
            case '9': return '9';
            case HproseTags.TagLong: return readLong();
            default: unexpectedTag(tag);
        }
    }

    public function readDouble():Number {
        return parseFloat(stream.readuntil(HproseTags.TagSemicolon));
    }
    
    public function readDoubleWithTag():Number {
        var tag = stream.getc();
        switch (tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags.TagDouble: return readDouble();
            default: unexpectedTag(tag);
        }
    }

    public function readNaN():Number {
        return NaN;
    }
    
    public function readNaNWithTag():Number {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagNaN: return NaN;
            default: unexpectedTag(tag);
        }
    }

    public function readInfinity():Number {
        return ((stream.getc() == HproseTags.TagNeg) ? -Infinity : Infinity);
    }

    public function readInfinityWithTag():Number {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagInfinity: return readInfinity();
            default: unexpectedTag(tag);
        }
    }
    
    public function readNull():Object {
        return null;
    }

    public function readNullWithTag():Object {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: unexpectedTag(tag);
        }
    }

    public function readEmpty():Object {
        return "";
    }
    
    public function readEmptyWithTag():Object {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagEmpty: return '';
            default: unexpectedTag(tag);
        }
    }

    public function readBooleanWithTag():Boolean {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            default: unexpectedTag(tag);
        }
    }

    public function readDate():Date {
        var year = parseInt(stream.read(4));
        var month = parseInt(stream.read(2)) - 1;
        var day = parseInt(stream.read(2));
        var date;
        var tag = stream.getc();
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
        return ref[ref.length] = date;
    }

    public function readDateWithTag():Date {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagDate: return readDate();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readTime():Date {
        var time;
        var hour = parseInt(stream.read(2));
        var minute = parseInt(stream.read(2));
        var second = parseInt(stream.read(2));
        var millisecond = 0;
        var tag = stream.getc();
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
        return ref[ref.length] = time;
    }

    public function readTimeWithTag():Date {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagTime: return readTime();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readUTF8Char() {
        return stream.getc();
    }

    public function readUTF8CharWithTag() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagUTF8Char: return readUTF8Char();
            default: unexpectedTag(tag);
        }
    }

    private function _readString():String {
        var str = stream.read(readInt(HproseTags.TagQuote));
        stream.skip(1);
        return str;
    }

    public function readString():String {
        return ref[ref.length] = _readString();
    }

    public function readStringWithTag():String {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagString: return readString();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readGuid():String {
        stream.skip(1);
        var guid = stream.read(36);
        stream.skip(1);
        return ref[ref.length] = guid;
    }

    public function readGuidWithTag():String {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagGuid: return readGuid();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }
    
    public function readList():Array {
        var list = [];
        ref[ref.length] = list;
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            list[i] = unserialize();
        }
        stream.skip(1);
        return list;
    }

    public function readListWithTag():Array {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagList: return readList();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }
    
    public function readMap():Object {
        var map = {};
        ref[ref.length] = map;
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            map[unserialize()] = unserialize();
        }
        stream.skip(1);
        return map;
    }

    public function readMapWithTag():Object {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagMap: return readMap();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readObject() {
        var cls = classref[readInt(HproseTags.TagOpenbrace)];
        var obj = new cls.classname();
        ref[ref.length] = obj;
        for (var i = 0; i < cls.count; i++) {
            obj[cls.fields[i]] = unserialize();
        }
        stream.skip(1);
        return obj;
    }

    public function readObjectWithTag():Array {
        var tag = stream.getc();
        switch(tag) {
            case HproseTags.TagClass: readClass(); return readObjectWithTag();
            case HproseTags.TagObject: return readObject();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    private function readClass():Void {
        var classname = _readString();
        var count = readInt(HproseTags.TagOpenbrace);
        var fields = [];
        for (var i = 0; i < count; i++) {
            fields[i] = readStringWithTag();
        }
        stream.skip(1);
        classref[classref.length] = {
            classname: ClassManager.getClass(classname),
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