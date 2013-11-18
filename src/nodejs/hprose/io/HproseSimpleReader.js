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
 * HproseSimpleReader.js                                  *
 *                                                        *
 * HproseSimpleReader for Node.js.                        *
 *                                                        *
 * LastModified: Nov 18, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseTags = require('./HproseTags.js');
var HproseClassManager = require('./HproseClassManager.js');
var HproseException = require('../common/HproseException.js');
var HproseRawReader = require('./HproseRawReader.js');

function getClass(classname) {
    var cls = HproseClassManager.getClass(classname);
    if (cls) return cls;
    cls = function() {};
    HproseClassManager.register(cls, classname);
    return cls;
}

function HproseSimpleReader(stream) {
    HproseRawReader.call(this, stream);
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
        if (expectTags.indexOf(tag) >= 0) return tag;
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
            case HproseTags.TagInteger: return readInteger();
            case HproseTags.TagLong: return readLong();
            case HproseTags.TagDouble: return readDouble();
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return '';
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagInfinity: return readInfinity();
            case HproseTags.TagDate: return this.readDate();
            case HproseTags.TagTime: return this.readTime();
            case HproseTags.TagBytes: return this.readBytes();
            case HproseTags.TagUTF8Char: return readUTF8Char();
            case HproseTags.TagString: return this.readString();
            case HproseTags.TagGuid: return this.readGuid();
            case HproseTags.TagList: return this.readList();
            case HproseTags.TagMap: return this.readMap();
            case HproseTags.TagClass: this.readClass(); return this.unserialize();
            case HproseTags.TagObject: return this.readObject();
            case HproseTags.TagError: throw new HproseException(this.readString(true));
            case undefined: throw new HproseException('No byte found in stream');
            default: throw new HproseException("Unexpected serialize tag '" +
                                               tag + "' in stream");
        }
    }
    function readInteger(includeTag) {
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= 48) && (tag <= 57)) return tag - 48;
            checkTag(HproseTags.TagInteger, tag);
        }
        return readInt(HproseTags.TagSemicolon);
    }
    function readLong(includeTag) {
        if (includeTag) {
            var tag = stream.getc();
            if ((tag >= 48) && (tag <= 57)) return tag - 48;
            checkTag(HproseTags.TagLong, tag);
        }
        return stream.readuntil(HproseTags.TagSemicolon);
    }
    function readDouble(includeTag) {
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
        if (includeTag) checkTag(HproseTags.TagDate);
        var year = parseInt(stream.readAsciiString(4));
        var month = parseInt(stream.readAsciiString(2)) - 1;
        var day = parseInt(stream.readAsciiString(2));
        var date;
        var tag = stream.getc();
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
        return date;
    }
    function readTime(includeTag) {
        if (includeTag) checkTag(HproseTags.TagTime);
        var time;
        var hour = parseInt(stream.readAsciiString(2));
        var minute = parseInt(stream.readAsciiString(2));
        var second = parseInt(stream.readAsciiString(2));
        var millisecond = 0;
        var tag = stream.getc();
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
        return time;
    }
    function readBytes(includeTag) {
        if (includeTag) checkTag(HproseTags.TagBytes);
        var count = readInt(HproseTags.TagQuote);
        var bytes = stream.read(count);
        stream.skip(1);
        return bytes;
    }
    function readUTF8Char(includeTag) {
        if (includeTag) checkTag(HproseTags.TagUTF8Char);
        return stream.readUTF8String(1);
    }
    function readString(includeTag) {
        if (includeTag) checkTag(HproseTags.TagString);
        var s = stream.readUTF8String(readInt(HproseTags.TagQuote));
        stream.skip(1);
        return s;
    }
    function readGuid(includeTag) {
        if (includeTag) checkTag(HproseTags.TagGuid);
        stream.skip(1);
        var s = stream.readAsciiString(36);
        stream.skip(1);
        return s;
    }
    function readListBegin() {
        return [];
    }
    function readListEnd(list) {
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            list[i] = this.unserialize();
        }
        stream.skip(1);
        return list;
    }
    function readList(includeTag) {
        if (includeTag) checkTag(HproseTags.TagList);
        return this.readListEnd(this.readListBegin());
    }
    function readMapBegin() {
        return {};
    }
    function readMapEnd(map) {
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            var key = this.unserialize();
            var value = this.unserialize();
            map[key] = value;
        }
        stream.skip(1);
        return map;
    }
    function readMap(includeTag) {
        if (includeTag) checkTag(HproseTags.TagMap);
        return this.readMapEnd(this.readMapBegin());
    }
    function readObjectBegin() {
        var cls = classref[readInt(HproseTags.TagOpenbrace)];
        var obj = new cls.classname();
        return {obj: obj, cls: cls};
    }
    function readObjectEnd(obj, cls) {
        for (var i = 0; i < cls.count; i++) {
            obj[cls.fields[i]] = this.unserialize();
        }
        stream.skip(1);
        return obj;
    }
    function readObject(includeTag) {
        if (includeTag) {
            var tag = checkTags([HproseTags.TagClass,
                                 HproseTags.TagObject]);
            if (tag == HproseTags.TagClass) {
                this.readClass();
                return this.readObject(true);
            }
        }
        var result = this.readObjectBegin();
        return this.readObjectEnd(result.obj, result.cls);
    }
    function readClass() {
        var classname = readString();
        var count = readInt(HproseTags.TagOpenbrace);
        var fields = [];
        for (var i = 0; i < count; i++) {
            fields[i] = this.readString(true);
        }
        stream.skip(1);
        classname = getClass(classname);
        classref[classref.length] = {
            classname: classname,
            count: count,
            fields: fields
        };
    }
    function reset() {
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
    this.readListBegin = readListBegin;
    this.readListEnd = readListEnd;
    this.readList = readList;
    this.readMapBegin = readMapBegin;
    this.readMapEnd = readMapEnd;
    this.readMap = readMap;
    this.readObjectBegin = readObjectBegin;
    this.readObjectEnd = readObjectEnd;
    this.readObject = readObject;
    this.readClass = readClass;
    this.reset = reset;
}

module.exports = HproseSimpleReader;