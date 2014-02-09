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
 * LastModified: Feb 10, 2014                             *
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
    var unexpectedTag = this.unexpectedTag;
    function checkTag(expectTag, tag) {
        if (tag === undefined) tag = stream.getc();
        if (tag != expectTag) unexpectedTag(tag, expectTag);
    }
    function checkTags(expectTags, tag) {
        if (tag === undefined) tag = stream.getc();
        if (expectTags.indexOf(tag) >= 0) return tag;
        unexpectedTag(tag, expectTags);
    }
    function readInt(tag) {
        var s = stream.readuntil(tag);
        if (s.length == 0) return 0;
        return parseInt(s, 10);
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
            case HproseTags.TagInteger: return readIntegerWithoutTag();
            case HproseTags.TagLong: return readLongWithoutTag();
            case HproseTags.TagDouble: return readDoubleWithoutTag();
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return '';
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagInfinity: return readInfinityWithoutTag();
            case HproseTags.TagDate: return this.readDateWithoutTag();
            case HproseTags.TagTime: return this.readTimeWithoutTag();
            case HproseTags.TagBytes: return this.readBytesWithoutTag();
            case HproseTags.TagUTF8Char: return readUTF8CharWithoutTag();
            case HproseTags.TagString: return this.readStringWithoutTag();
            case HproseTags.TagGuid: return this.readGuidWithoutTag();
            case HproseTags.TagList: return this.readListWithoutTag();
            case HproseTags.TagMap: return this.readMapWithoutTag();
            case HproseTags.TagClass: this.readClass(); return this.readObject();
            case HproseTags.TagObject: return this.readObjectWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            case HproseTags.TagError: throw new HproseException(this.readString());
            default: unexpectedTag(tag);
        }
    }
    function readIntegerWithoutTag() {
        return readInt(HproseTags.TagSemicolon);
    }
    function readInteger() {
        var tag = stream.getc();
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
            case HproseTags.TagInteger: return readIntegerWithoutTag();
            default: unexpectedTag(tag);
        }
    }
    function readLongWithoutTag() {
        return stream.readuntil(HproseTags.TagSemicolon);
    }
    function readLong() {
        var tag = stream.getc();
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
            case HproseTags.TagInteger:
            case HproseTags.TagLong: return readLongWithoutTag();
            default: unexpectedTag(tag);
        }
    }
    function readDoubleWithoutTag() {
        return parseFloat(stream.readuntil(HproseTags.TagSemicolon));
    }
    function readDouble() {
        var tag = stream.getc();
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
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble: return readDoubleWithoutTag();
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagInfinity: return readInfinityWithoutTag();
            default: unexpectedTag(tag);
        }
    }
    function readNaN() {
        checkTag(HproseTags.TagNaN);
        return NaN;
    }
    function readInfinityWithoutTag() {
        return ((stream.getc() == HproseTags.TagNeg) ? -Infinity : Infinity);
    }
    function readInfinity() {
        checkTag(HproseTags.TagInfinity);
        return readInfinityWithoutTag();
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
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            default: unexpectedTag(tag);
        }
    }
    function readDateWithoutTag() {
        var year = parseInt(stream.readAsciiString(4), 10);
        var month = parseInt(stream.readAsciiString(2), 10) - 1;
        var day = parseInt(stream.readAsciiString(2), 10);
        var date;
        var tag = stream.getc();
        if (tag == HproseTags.TagTime) {
            var hour = parseInt(stream.readAsciiString(2), 10);
            var minute = parseInt(stream.readAsciiString(2), 10);
            var second = parseInt(stream.readAsciiString(2), 10);
            var millisecond = 0;
            tag = stream.getc();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.readAsciiString(3), 10);
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
    function readDate() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagDate: return this.readDateWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
    }
    function readTimeWithoutTag() {
        var time;
        var hour = parseInt(stream.readAsciiString(2), 10);
        var minute = parseInt(stream.readAsciiString(2), 10);
        var second = parseInt(stream.readAsciiString(2), 10);
        var millisecond = 0;
        var tag = stream.getc();
        if (tag == HproseTags.TagPoint) {
            millisecond = parseInt(stream.readAsciiString(3), 10);
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
    function readTime() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagTime: return this.readTimeWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
    }
    function readBytesWithoutTag() {
        var count = readInt(HproseTags.TagQuote);
        var bytes = stream.read(count);
        stream.skip(1);
        return bytes;
    }
    function readBytes() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagBytes: return this.readBytesWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
    }
    function readUTF8CharWithoutTag() {
        return stream.readUTF8String(1);
    }
    function readUTF8Char() {
        checkTag(HproseTags.TagUTF8Char);
        return readUTF8CharWithoutTag();
    }
    function readStringWithoutTag() {
        var s = stream.readUTF8String(readInt(HproseTags.TagQuote));
        stream.skip(1);
        return s;
    }
    function readString() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagString: return this.readStringWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
    }
    function readGuidWithoutTag() {
        stream.skip(1);
        var s = stream.readAsciiString(36);
        stream.skip(1);
        return s;
    }
    function readGuid() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagGuid: return this.readGuidWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
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
    function readListWithoutTag() {
        return this.readListEnd(this.readListBegin());
    }
    function readList() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagList: return this.readListWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
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
    function readMapWithoutTag() {
        return this.readMapEnd(this.readMapBegin());
    }
    function readMap() {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagMap: return this.readMapWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
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
    function readObjectWithoutTag() {
        var result = this.readObjectBegin();
        return this.readObjectEnd(result.obj, result.cls);
    }
    function readObject() {
        var tag = stream.getc();
        switch(tag) {
            case HproseTags.TagClass: this.readClass(); return this.readObject();
            case HproseTags.TagObject: return this.readObjectWithoutTag();
            case HproseTags.TagRef: return this.readRef();
            default: unexpectedTag(tag);
        }
    }
    function readClass() {
        var classname = readStringWithoutTag();
        var count = readInt(HproseTags.TagOpenbrace);
        var fields = [];
        for (var i = 0; i < count; i++) {
            fields[i] = this.readString();
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
        unexpectedTag(HproseTags.TagRef);
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
    this.readDateWithoutTag = readDateWithoutTag;
    this.readDate = readDate;
    this.readTimeWithoutTag = readTimeWithoutTag;
    this.readTime = readTime;
    this.readBytesWithoutTag = readBytesWithoutTag;
    this.readBytes = readBytes;
    this.readUTF8Char = readUTF8Char;
    this.readStringWithoutTag = readStringWithoutTag;
    this.readString = readString;
    this.readGuidWithoutTag = readGuidWithoutTag;
    this.readGuid = readGuid;
    this.readListBegin = readListBegin;
    this.readListEnd = readListEnd;
    this.readListWithoutTag = readListWithoutTag;
    this.readList = readList;
    this.readMapBegin = readMapBegin;
    this.readMapEnd = readMapEnd;
    this.readMapWithoutTag = readMapWithoutTag;
    this.readMap = readMap;
    this.readObjectBegin = readObjectBegin;
    this.readObjectEnd = readObjectEnd;
    this.readObjectWithoutTag = readObjectWithoutTag;
    this.readObject = readObject;
    this.readClass = readClass;
    this.readRef = readRef;
    this.reset = reset;
}

module.exports = HproseSimpleReader;