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
 * HproseReader.js                                        *
 *                                                        *
 * HproseReader for Node.js.                              *
 *                                                        *
 * LastModified: Oct 29, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseTags = require('./HproseTags.js');
var ClassManager = (typeof(Map) === 'undefined') ? require('./ClassManager.js') : require('./ClassManager2.js');
var HproseException = require('../common/HproseException.js');

function getClass(classname) {
    var cls = ClassManager.getClass(classname);
    if (cls) return cls;
    cls = function() {};
    ClassManager.register(cls, classname);
    return cls;
}

function HproseReader(stream) {
    var ref = [];
    var classref = [];
    function checkTag(expectTag, tag) {
        if (tag === undefined) tag = stream.getc();
        if (tag != expectTag) {
            throw new HproseException("Tag '" + expectTag +
                                      "' expected, but '" +
                                      tag + "' found in stream");
        }
    }
    function checkTags(expectTags, tag) {
        if (tag === undefined) tag = stream.getc();
        if (expectTags.indexOf(tag) != -1) return tag;
        throw new HproseException("'" + tag +
                                  "' is not the expected tag");
    }
    function readInt(tag) {
        var s = stream.readuntil(tag);
        if (s.length == 0) return 0;
        return parseInt(s);
    }
    function unserialize(tag) {
        if (tag === undefined) {
            tag = stream.getc();
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
            case HproseTags.TagEmpty: return '';
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
            case undefined: throw new HproseException('No byte found in stream');
            default: throw new HproseException("Unexpected serialize tag '" +
                                               tag + "' in stream");
        }
    }
    function readInteger(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= 48) && (tag <= 57)) return tag - 48;
            checkTag(HproseTags.TagInteger, tag);
        }
        return readInt(HproseTags.TagSemicolon);
    }
    function readLong(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= 48) && (tag <= 57)) return tag - 48;
            checkTag(HproseTags.TagLong, tag);
        }
        return stream.readuntil(HproseTags.TagSemicolon);
    }
    function readDouble(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= 48) && (tag <= 57)) return tag - 48;
            checkTag(HproseTags.TagDouble, tag);
        }
        return parseFloat(stream.readuntil(HproseTags.TagSemicolon));
    }
    function readNaN() {
        checkTag(HproseTags.TagNaN);
        return NaN;
    }
    function readInfinity(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) checkTag(HproseTags.TagInfinity);
        return ((stream.getc() == HproseTags.TagNeg) ? -Infinity : Infinity);
    }
    function readNull() {
        checkTag(HproseTags.TagNull);
        return null;
    }
    function readEmpty() {
        checkTag(HproseTags.TagEmpty);
        return '';
    }
    function readBoolean() {
        var tag = checkTags([HproseTags.TagTrue,
                             HproseTags.TagFalse]);
        return (tag == HproseTags.TagTrue);
    }
    function readDate(includeTag) {
        if (includeTag === undefined) includeTag = true;
        var tag;
        if (includeTag) {
            tag = checkTags([HproseTags.TagDate,
                             HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var year = parseInt(stream.readAsciiString(4));
        var month = parseInt(stream.readAsciiString(2)) - 1;
        var day = parseInt(stream.readAsciiString(2));
        var date;
        tag = stream.getc();
        if (tag == HproseTags.TagTime) {
            var hour = parseInt(stream.readAsciiString(2));
            var minute = parseInt(stream.readAsciiString(2));
            var second = parseInt(stream.readAsciiString(2));
            var millisecond = 0;
            tag = stream.getc();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.readAsciiString(3));
                tag = stream.getc();
                if ((tag >= 48) && (tag <= 57)) {
                    stream.skip(2);
                    tag = stream.getc();
                    if ((tag >= 48) && (tag <= 57)) {
                        stream.skip(2);
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
    function readTime(includeTag) {
        if (includeTag === undefined) includeTag = true;
        var tag;
        if (includeTag) {
            tag = checkTags([HproseTags.TagTime,
                             HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var time;
        var hour = parseInt(stream.readAsciiString(2));
        var minute = parseInt(stream.readAsciiString(2));
        var second = parseInt(stream.readAsciiString(2));
        var millisecond = 0;
        tag = stream.getc();
        if (tag == HproseTags.TagPoint) {
            millisecond = parseInt(stream.readAsciiString(3));
            tag = stream.getc();
            if ((tag >= 48) && (tag <= 57)) {
                stream.skip(2);
                tag = stream.getc();
                if ((tag >= 48) && (tag <= 57)) {
                    stream.skip(2);
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
    function readBytes(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagBytes,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var count = readInt(HproseTags.TagQuote);
        var bytes = stream.read(count);
        stream.skip(1);
        ref[ref.length] = bytes;
        return bytes;
    }
    function readUTF8Char(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) checkTag(HproseTags.TagUTF8Char);
        return stream.readUTF8String(1);
    }
    function readString(includeTag, includeRef) {
        if (includeTag === undefined) includeTag = true;
        if (includeRef === undefined) includeRef = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagString,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var s = stream.readUTF8String(readInt(HproseTags.TagQuote));
        stream.skip(1);
        if (includeRef) ref[ref.length] = s;
        return s;
    }
    function readGuid(includeTag) {
        if (includeTag === undefined) includeTag = true;
        if (includeTag) {
            var tag = checkTags([HproseTags.TagGuid,
                                 HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        stream.skip(1);
        var s = stream.readAsciiString(36);
        stream.skip(1);
        ref[ref.length] = s;
        return s;
    }
    function readList(includeTag) {
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
    function readMap(includeTag) {
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
    function readObject(includeTag) {
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
    function readClass() {
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
    function readRef() {
        return ref[readInt(HproseTags.TagSemicolon)];
    }
    function readRaw(ostream, tag) {
        if (ostream === undefined) ostream = new HproseBufferOutputStream();
        if (tag === undefined) tag = stream.getc();
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
                ostream.write(tag);
                break;
            case HproseTags.TagInfinity:
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
                ostream.write(tag);
                readRaw(ostream);
                break;
            case '': throw new HproseException('No byte found in stream');
            default: throw new HproseException("Unexpected serialize tag '" +
                                               tag + "' in stream");
        }
        return ostream;
    }
    function readNumberRaw(ostream, tag) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon);        
    }
    function readDateTimeRaw(ostream, tag) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon &&
                 tag != HproseTags.TagUTC);
    }
    function readUTF8CharRaw(ostream, tag) {
        ostream.write(tag);
        ostream.write(stream.readUTF8String(1));
    }
    function readBytesRaw(ostream, tag) {
        ostream.write(tag);
        var count = 0;
        tag = 48;
        do {
            count *= 10;
            count += tag - 48;
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagQuote);
        ostream.write(stream.read(count + 1));
    }
    function readStringRaw(ostream, tag) {
        ostream.write(tag);
        var count = 0;
        tag = 48;
        do {
            count *= 10;
            count += tag - 48;
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagQuote);
        ostream.write(stream.readUTF8String(count + 1));
    }
    function readGuidRaw(ostream, tag) {
        ostream.write(tag);
        ostream.write(stream.read(38));
    }
    function readComplexRaw(ostream, tag) {
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
    function reset() {
        ref.length = 0;
        classref.length = 0;
    }
    this.stream = stream;
    this.checkTag = checkTag;
    this.checkTags = checkTags;
    this.unserialize = unserialize;
    this.readInteger = readInteger;
    this.readLong = readLong;
    this.readDouble = readDouble;
    this.readNaN = readNaN;
    this.readInfinity = readInfinity;
    this.readNull = readNull;
    this.readEmpty = readEmpty;
    this.readBoolean = readBoolean;
    this.readDate = readDate;
    this.readTime = readTime;
    this.readBytes = readBytes;
    this.readUTF8Char = readUTF8Char;
    this.readString = readString;
    this.readList = readList;
    this.readMap = readMap;
    this.readObject = readObject;
    this.readRaw = readRaw;
    this.reset = reset;
}

module.exports = HproseReader;