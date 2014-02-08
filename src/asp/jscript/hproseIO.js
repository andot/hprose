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
 * hproseIO.js                                            *
 *                                                        *
 * hprose io stream library for JavaScript.               *
 *                                                        *
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

function HproseStringInputStream(str) {
    var pos = 0;
    var length = str.length;
    this.getc = function() {
        return str.charAt(pos++);
    }
    this.read = function(len) {
        var s = str.substr(pos, len);
        this.skip(len);
        return s;
    }
    this.skip = function(n) {
        pos += n;
    }
    this.readuntil = function(tag) {
        var p = str.indexOf(tag, pos);
        var s;
        if (p !== -1) {
            s = str.substr(pos, p - pos);
            pos = p + tag.length;
        }
        else {
            s = str.substr(pos);
            pos = length;
        }
        return s;
    }
    this.rawData = function() {
        return str;
    }
}

function HproseStringOutputStream(str) {
    if (str === undefined) str = '';
    var buf = [str];
    var size = buf.length;
    this.write = function(s) {
        buf[size++] = s;
    }
    this.mark = function() {
        str = this.toString();
    }
    this.reset = function() {
        buf = [str];
    }
    this.clear = function() {
        buf = [];
    }
    this.toString = function() {
        return buf.join('');
    }
}

var HproseTags = {
    /* Serialize Tags */
    TagInteger: 'i',
    TagLong: 'l',
    TagDouble: 'd',
    TagNull: 'n',
    TagEmpty: 'e',
    TagTrue: 't',
    TagFalse: 'f',
    TagNaN: 'N',
    TagInfinity: 'I',
    TagDate: 'D',
    TagTime: 'T',
    TagUTC: 'Z',
/*  TagBytes: 'b', */ // Not support bytes in JavaScript.
    TagUTF8Char: 'u',
    TagString: 's',
    TagGuid: 'g',
    TagList: 'a',
    TagMap: 'm',
    TagClass: 'c',
    TagObject: 'o',
    TagRef: 'r',
    /* Serialize Marks */
    TagPos: '+',
    TagNeg: '-',
    TagSemicolon: ';',
    TagOpenbrace: '{',
    TagClosebrace: '}',
    TagQuote: '"',
    TagPoint: '.',
    /* Protocol Tags */
    TagFunctions: 'F',
    TagCall: 'C',
    TagResult: 'R',
    TagArgument: 'A',
    TagError: 'E',
    TagEnd: 'z'
}

var HproseClassManager = new (function() {
    var classCache = {};
    var aliasCache = new ActiveXObject("Scripting.Dictionary");
    this.register = function(cls, alias) {
        aliasCache.Item(cls) = alias;
        classCache[alias] = cls;
    }
    this.getClassAlias = function(cls) {
        return aliasCache.Item(cls);
    }
    this.getClass = function(alias) {
        return classCache[alias];
    }
    this.register(Object, 'Object');
})();

var HproseRawReader, HproseSimpleReader, HproseReader;
var HproseSimpleWriter, HproseWriter;

(function() {
    function freeEval(str) {
        return eval(str);
    }

    (function() {
        // private static members
        var hproseUtil = HproseUtil;
        var hproseTags = HproseTags;
        var hproseException = HproseException;
        var hproseClassManager = HproseClassManager;

        function arrayIndexOf(array, value) {
            var count = array.length;
            for (var i = 0; i < count; i++) {
                if (array[i] === value) return i;
            }
            return -1;
        }
        function findClass(cn, poslist, i, c) {
            if (i < poslist.length) {
                var pos = poslist[i];
                cn[pos] = c;
                var cls = findClass(cn, poslist, i + 1, '.');
                if (i + 1 < poslist.length) {
                    if (cls == null) {
                        cls = findClass(cn, poslist, i + 1, '_');
                    }
                }
                return cls;
            }
            var classname = cn.join('');
            try {
                if (freeEval('typeof(' + classname + ') == "function"')) {
                    return freeEval(classname);
                }
                else {
                    return null;
                }
            }
            catch(e) {
                return null;
            }
        }
        function getClass(classname) {
            var cls = hproseClassManager.getClass(classname);
            if (cls) return cls;
            if (freeEval('typeof(' + classname + ') == "function"')) {
                cls = freeEval(classname);
                hproseClassManager.register(cls, classname);
                return cls;
            }
            var poslist = [];
            var pos = classname.indexOf("_");
            while (pos > -1) {
                poslist[poslist.length] = pos;
                pos = classname.indexOf("_", pos + 1);
            }
            if (poslist.length > 0) {
                var cn = classname.split('');
                cls = findClass(cn, poslist, 0, '.');
                if (cls == null) {
                    cls = findClass(cn, poslist, 0, '_');
                }
                if (cls != null) {
                    hproseClassManager.register(cls, classname);
                    return cls;
                }
            }
            cls = function() {
                this.getClassName = function() {
                    return classname;
                }
            };
            hproseClassManager.register(cls, classname);
            return cls;
        }
        var prototypePropertyOfArray = function() {
            var result = {};
            for (var p in []) {
                result[p] = true;
            }
            return result;
        }();
        var prototypePropertyOfObject = function() {
            var result = {};
            for (var p in {}) {
                result[p] = true;
            }
            return result;
        }();
        function isDigit(value) {
            switch (value.toString()) {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9': return true;
            }
            return false;
        }
        function isInteger(value) {
            var l = value.length;
            for (var i = (value.charAt(0) == '-') ? 1 : 0; i < l; i++) {
                if (!isDigit(value.charAt(i))) return false;
            }
            return (value != '-');
        }
        function isInt32(value) {
            var s = value.toString();
            var l = s.length;
            return ((l < 12) && isInteger(s) &&
                    !(value < -2147483648 || value > 2147483647));
        }
        function isArray(value) {
            return (Object.prototype.toString.apply(value) === '[object Array]');
        }
        function getClassName(obj) {
            if (obj === undefined || obj.constructor === undefined) return 'Object';
            var cls = obj.constructor;
            var classname = hproseClassManager.getClassAlias(cls);
            if (classname) return classname;
            var ctor = cls.toString();
            classname = ctor.substr(0, ctor.indexOf('(')).replace(/(^\s*function\s*)|(\s*$)/ig, '');
            if (classname == '' || classname == 'Object') {
                return (typeof(obj.getClassName) == 'function') ? obj.getClassName() : 'Object';
            }
            if (classname != 'Object') {
                hproseClassManager.register(cls, classname);
            }
            return classname;
        }

        function unexpectedTag(tag, expectTags) {
            if (tag && expectTags) {
                throw new hproseException("Tag '" + expectTags + "' expected, but '" + tag + "' found in stream");
            }
            else if (tag) {
                throw new hproseException("Unexpected serialize tag '" + tag + "' in stream")
            }
            else {
                throw new hproseException('No byte found in stream');
            }
        }

        // public class
        HproseRawReader = function hproseRawReader(stream) {
            function readRaw(ostream, tag) {
                if (ostream === undefined) ostream = new HproseStringOutputStream();
                if (tag === undefined) tag = stream.getc();
                ostream.write(tag);
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
                        break;
                    case HproseTags.TagInfinity:
                    case HproseTags.TagUTF8Char:
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
                        readDateTimeRaw(ostream);
                        break;
                    case HproseTags.TagString:
                        readStringRaw(ostream);
                        break;
                    case HproseTags.TagGuid:
                        readGuidRaw(ostream);
                        break;
                    case HproseTags.TagList:
                    case HproseTags.TagMap:
                    case HproseTags.TagObject:
                        readComplexRaw(ostream);
                        break;
                    case HproseTags.TagClass:
                        readComplexRaw(ostream);
                        readRaw(ostream);
                        break;
                    case HproseTags.TagError:
                        readRaw(ostream);
                        break;
                    default: unexpectedTag(tag);
                }
                return ostream;
            }
            function readNumberRaw(ostream) {
                do {
                    var tag = stream.getc();
                    ostream.write(tag);
                } while (tag != HproseTags.TagSemicolon);
            }
            function readDateTimeRaw(ostream) {
                do {
                    var tag = stream.getc();
                    ostream.write(tag);
                } while (tag != HproseTags.TagSemicolon &&
                         tag != HproseTags.TagUTC);
            }
            function readStringRaw(ostream) {
                var s = stream.readuntil(HproseTags.TagQuote);
                ostream.write(s);
                ostream.write(HproseTags.TagQuote);
                var len = 0;
                if (s.length > 0) len = parseInt(s);
                ostream.write(stream.read(len + 1));
            }
            function readGuidRaw(ostream) {
                ostream.write(stream.read(38));
            }
            function readComplexRaw(ostream) {
                do {
                    var tag = stream.getc();
                    ostream.write(tag);
                } while (tag != HproseTags.TagOpenbrace);
                while ((tag = stream.getc()) != HproseTags.TagClosebrace) {
                    readRaw(ostream, tag);
                }
                ostream.write(tag);
            }
            this.readRaw = readRaw;
        }

        // public class
        HproseSimpleReader = function hproseSimpleReader(stream, vbs) {
            HproseRawReader.call(this, stream);
            var classref = [];
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
                return parseInt(s);
            }
            function unserialize(tag) {
                if (tag === undefined) {
                    tag = stream.getc();
                }
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
                    case hproseTags.TagInteger: return readIntegerWithoutTag();
                    case hproseTags.TagLong: return readLongWithoutTag();
                    case hproseTags.TagDouble: return readDoubleWithoutTag();
                    case hproseTags.TagNull: return null;
                    case hproseTags.TagEmpty: return '';
                    case hproseTags.TagTrue: return true;
                    case hproseTags.TagFalse: return false;
                    case hproseTags.TagNaN: return NaN;
                    case hproseTags.TagInfinity: return readInfinityWithoutTag();
                    case hproseTags.TagDate: return this.readDateWithoutTag();
                    case hproseTags.TagTime: return this.readTimeWithoutTag();
                    case hproseTags.TagUTF8Char: return stream.getc();
                    case hproseTags.TagString: return this.readStringWithoutTag();
                    case hproseTags.TagGuid: return this.readGuidWithoutTag();
                    case hproseTags.TagList: return this.readListWithoutTag();
                    case hproseTags.TagMap: return this.readMapWithoutTag();
                    case hproseTags.TagClass: this.readClass(); return this.readObject();
                    case hproseTags.TagObject: return this.readObjectWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    case hproseTags.TagError: throw new hproseException(this.readString());
                    default: unexpectedTag(tag);
                }
            }
            function readIntegerWithoutTag() {
                return readInt(hproseTags.TagSemicolon);
            }
            function readInteger() {
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
                    case hproseTags.TagInteger: return readIntegerWithoutTag();
                    default: unexpectedTag(tag);
                }
            }
            function readLongWithoutTag() {
                return stream.readuntil(hproseTags.TagSemicolon);
            }
            function readLong() {
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
                    case hproseTags.TagInteger:
                    case hproseTags.TagLong: return readLongWithoutTag();
                    default: unexpectedTag(tag);
                }
            }
            function readDoubleWithoutTag() {
                return parseFloat(stream.readuntil(hproseTags.TagSemicolon));
            }
            function readDouble() {
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
                    case hproseTags.TagInteger:
                    case hproseTags.TagLong:
                    case hproseTags.TagDouble: return readDoubleWithoutTag();
                    case hproseTags.TagNaN: return NaN;
                    case hproseTags.TagInfinity: return readInfinityWithoutTag();
                    default: unexpectedTag(tag);
                }
            }
            function readNaN() {
                checkTag(hproseTags.TagNaN);
                return NaN;
            }
            function readInfinityWithoutTag() {
                return ((stream.getc() == hproseTags.TagNeg) ? -Infinity : Infinity);
            }
            function readInfinity() {
                checkTag(hproseTags.TagInfinity);
                return readInfinityWithoutTag();
            }
            function readNull() {
                checkTag(hproseTags.TagNull);
                return null;
            }
            function readEmpty() {
                checkTag(hproseTags.TagEmpty);
                return '';
            }
            function readBoolean() {
                var tag = stream.getc();
                switch (tag) {
                    case hproseTags.TagTrue: return true;
                    case hproseTags.TagFalse: return false;
                    default: unexpectedTag(tag);
                }
            }
            function readDateWithoutTag() {
                var year = parseInt(stream.read(4));
                var month = parseInt(stream.read(2)) - 1;
                var day = parseInt(stream.read(2));
                var date;
                var tag = stream.getc();
                if (tag == hproseTags.TagTime) {
                    var hour = parseInt(stream.read(2));
                    var minute = parseInt(stream.read(2));
                    var second = parseInt(stream.read(2));
                    var millisecond = 0;
                    tag = stream.getc();
                    if (tag == hproseTags.TagPoint) {
                        millisecond = parseInt(stream.read(3));
                        tag = stream.getc();
                        if ((tag >= '0') && (tag <= '9')) {
                            stream.skip(2);
                            tag = stream.getc();
                            if ((tag >= '0') && (tag <= '9')) {
                                stream.skip(2);
                                tag = stream.getc();
                            }
                        }
                    }
                    if (tag == hproseTags.TagUTC) {
                        date = new Date(Date.UTC(year, month, day, hour, minute, second, millisecond));
                    }
                    else {
                        date = new Date(year, month, day, hour, minute, second, millisecond);
                    }
                }
                else if (tag == hproseTags.TagUTC) {
                    date = new Date(Date.UTC(year, month, day));
                }
                else {
                    date = new Date(year, month, day);
                }
                if (vbs) date = date.getVarDate();
                return date;
            }
            function readDate() {
                var tag = stream.getc();
                switch (tag) {
                    case hproseTags.TagDate: return this.readDateWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readTimeWithoutTag() {
                var time;
                var hour = parseInt(stream.read(2));
                var minute = parseInt(stream.read(2));
                var second = parseInt(stream.read(2));
                var millisecond = 0;
                var tag = stream.getc();
                if (tag == hproseTags.TagPoint) {
                    millisecond = parseInt(stream.read(3));
                    tag = stream.getc();
                    if ((tag >= '0') && (tag <= '9')) {
                        stream.skip(2);
                        tag = stream.getc();
                        if ((tag >= '0') && (tag <= '9')) {
                            stream.skip(2);
                            tag = stream.getc();
                        }
                    }
                }
                if (tag == hproseTags.TagUTC) {
                    if (vbs) {
                        time = new Date(Date.UTC(1899, 11, 30, hour, minute, second, millisecond)).getVarDate();
                    }
                    else {
                        time = new Date(Date.UTC(1970, 0, 1, hour, minute, second, millisecond));
                    }
                }
                else {
                    if (vbs) {
                        time = new Date(1899, 11, 30, hour, minute, second, millisecond).getVarDate();
                    }
                    else {
                        time = new Date(1970, 0, 1, hour, minute, second, millisecond);
                    }
                }
                return time;
            }
            function readTime() {
                var tag = stream.getc();
                switch (tag) {
                    case hproseTags.TagTime: return this.readTimeWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readUTF8CharWithoutTag() {
                return stream.getc();
            }
            function readUTF8Char() {
                checkTag(hproseTags.TagUTF8Char);
                return stream.getc();
            }
            function readStringWithoutTag() {
                var s = stream.read(readInt(hproseTags.TagQuote));
                stream.skip(1);
                return s;
            }
            function readString() {
                var tag = stream.getc();
                switch (tag) {
                    case hproseTags.TagString: return this.readStringWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readGuidWithoutTag() {
                stream.skip(1);
                var s = stream.read(36);
                stream.skip(1);
                return s;
            }
            function readGuid() {
                var tag = stream.getc();
                switch (tag) {
                    case hproseTags.TagGuid: return this.readGuidWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readListBegin() {
                return [];
            }
            function readListEnd(list) {
                var count = readInt(hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    list[i] = this.unserialize();
                }
                stream.skip(1);
                if (vbs) list = hproseUtil.toVBArray(list);
                return list;
            }
            function readListWithoutTag() {
                return this.readListEnd(this.readListBegin());
            }
            function readList() {
                var tag = stream.getc();
                switch (tag) {
                    case hproseTags.TagList: return this.readListWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readMapBegin() {
                if (vbs) return new ActiveXObject("Scripting.Dictionary");
                return {};
            }
            function readMapEnd(map) {
                var count = readInt(hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    var key = this.unserialize();
                    var value = this.unserialize();
                    if (vbs) {
                        map.Add(key, value);
                    }
                    else {
                        map[key] = value;
                    }
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
                    case hproseTags.TagMap: return this.readMapWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readObjectBegin() {
                var cls = classref[readInt(hproseTags.TagOpenbrace)];
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
                    case hproseTags.TagClass: this.readClass(); return this.readObject();
                    case hproseTags.TagObject: return this.readObjectWithoutTag();
                    case hproseTags.TagRef: return this.readRef();
                    default: unexpectedTag(tag);
                }
            }
            function readClass() {
                var classname = readStringWithoutTag();
                var count = readInt(hproseTags.TagOpenbrace);
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
                unexpectedTag(hproseTags.TagRef);
            }
            function reset() {
                classref.length = 0;
            }
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

        // public class
        HproseReader = function hproseReader(stream, vbs) {
            HproseSimpleReader.call(this, stream, vbs);
            var ref = [];
            function readInt(tag) {
                var s = stream.readuntil(tag);
                if (s.length == 0) return 0;
                return parseInt(s);
            }
            var readDateWithoutTag = this.readDateWithoutTag;
            this.readDateWithoutTag = function() {
                return ref[ref.length] = readDateWithoutTag();
            }
            var readTimeWithoutTag = this.readTimeWithoutTag;
            this.readTimeWithoutTag = function() {
                return ref[ref.length] = readTimeWithoutTag();
            }
            var readStringWithoutTag = this.readStringWithoutTag;
            this.readStringWithoutTag = function() {
                return ref[ref.length] = readStringWithoutTag();
            }
            var readGuidWithoutTag = this.readGuidWithoutTag;
            this.readGuidWithoutTag = function() {
                return ref[ref.length] = readGuidWithoutTag();
            }
            this.readListWithoutTag = function() {
                var list = this.readListBegin();
                var p = ref.length;
                ref[p] = list;
                list = this.readListEnd(list);
                if (vbs) ref[p] = list;
                return list;
            }
            this.readMapWithoutTag = function() {
                return this.readMapEnd(ref[ref.length] = this.readMapBegin());
            }
            this.readObjectWithoutTag = function() {
                var result = this.readObjectBegin();
                ref[ref.length] = result.obj;
                return this.readObjectEnd(result.obj, result.cls);
            }
            this.readRef = function() {
                return ref[readInt(hproseTags.TagSemicolon)];
            }
            var reset = this.reset;
            this.reset = function() {
                reset();
                ref.length = 0;
            }
        }

        // public class
        HproseSimpleWriter = function hproseSimpleWriter(stream) {
            var classref = {};
            var fieldsref = [];
            function serialize(variable) {
                if (variable === undefined ||
                    variable === null ||
                    variable.constructor == Function) {
                    return writeNull();
                }
                if (variable === '') {
                    return writeEmpty();
                }
                if (typeof(variable) == 'date') {
                    return writeVBSDate(variable);
                }
                if (hproseUtil.isDictionary(variable)) {
                    return this.writeDictWithRef(variable);
                }
                if (hproseUtil.isVBArray(variable)) {
                    variable = hproseUtil.toJSArray(variable);
                }
                switch (variable.constructor) {
                    case Boolean: writeBoolean(variable); break;
                    case Number: isDigit(variable) ?
                                 stream.write(variable) :
                                 isInt32(variable) ?
                                 writeInteger(variable) :
                                 writeDouble(variable); break;
                    case String: variable.length == 1 ?
                                 writeUTF8Char(variable) :
                                 this.writeStringWithRef(variable); break;
                    case Date: this.writeDateWithRef(variable); break;
                    default: {
                        if (Array.isArray(variable)) {
                            this.writeListWithRef(variable);
                        }
                        else {
                            var classname = getClassName(variable);
                            if (classname == "Object") {
                                this.writeMapWithRef(variable);
                            }
                            else {
                                this.writeObjectWithRef(variable);
                            }
                        }
                    }
                }
            }
            function writeInteger(i) {
                stream.write(hproseTags.TagInteger + i + hproseTags.TagSemicolon);
            }
            function writeLong(l) {
                stream.write(hproseTags.TagLong + l + hproseTags.TagSemicolon);
            }
            function writeDouble(d) {
                if (isNaN(d)) {
                    writeNaN();
                }
                else if (isFinite(d)) {
                    stream.write(hproseTags.TagDouble + d + hproseTags.TagSemicolon);
                }
                else {
                    writeInfinity(d > 0);
                }
            }
            function writeNaN() {
                stream.write(hproseTags.TagNaN);
            }
            function writeInfinity(positive) {
                stream.write(hproseTags.TagInfinity + (positive ?
                                                       hproseTags.TagPos :
                                                       hproseTags.TagNeg));
            }
            function writeNull() {
                stream.write(hproseTags.TagNull);
            }
            function writeEmpty() {
                stream.write(hproseTags.TagEmpty);
            }
            function writeBoolean(b) {
                stream.write(b ? hproseTags.TagTrue : hproseTags.TagFalse);
            }
            function writeUTCDate(date) {
                var year = ('0000' + date.getUTCFullYear()).slice(-4);
                var month = ('00' + (date.getUTCMonth() + 1)).slice(-2);
                var day = ('00' + date.getUTCDate()).slice(-2);
                var hour = ('00' + date.getUTCHours()).slice(-2);
                var minute = ('00' + date.getUTCMinutes()).slice(-2);
                var second = ('00' + date.getUTCSeconds()).slice(-2);
                var millisecond = ('000' + date.getUTCMilliseconds()).slice(-3);
                stream.write(hproseTags.TagDate + year + month + day +
                             hproseTags.TagTime + hour + minute + second);
                if (millisecond != '000') {
                    stream.write(hproseTags.TagPoint + millisecond);
                }
                stream.write(hproseTags.TagUTC);
            }
            function writeUTCDateWithRef(date) {
                if (!this.writeRef(date)) this.writeUTCDate(date);
            }
            function writeXDate(date, y, m, d) {
                var year = ('0000' + date.getFullYear()).slice(-4);
                var month = ('00' + (date.getMonth() + 1)).slice(-2);
                var day = ('00' + date.getDate()).slice(-2);
                var hour = ('00' + date.getHours()).slice(-2);
                var minute = ('00' + date.getMinutes()).slice(-2);
                var second = ('00' + date.getSeconds()).slice(-2);
                var millisecond = ('000' + date.getMilliseconds()).slice(-3);
                if ((hour == '00') && (minute == '00') &&
                    (second == '00') && (millisecond == '000')) {
                    stream.write(hproseTags.TagDate + year + month + day);
                }
                else if ((year == y) && (month == m) && (day == d)) {
                    stream.write(hproseTags.TagTime + hour + minute + second);
                    if (millisecond != '000') {
                        stream.write(hproseTags.TagPoint + millisecond);
                    }
                }
                else {
                    stream.write(hproseTags.TagDate + year + month + day +
                                 hproseTags.TagTime + hour + minute + second);
                    if (millisecond != '000') {
                        stream.write(hproseTags.TagPoint + millisecond);
                    }
                }
                stream.write(hproseTags.TagSemicolon);
            }
            function writeVBSDate(date) {
                writeXDate(new Date(date), '1899', '12', '30');
            }
            function writeDate(date) {
                writeXDate(date, '1970', '01', '01');
            }
            function writeDateWithRef(date) {
                if (!this.writeRef(date)) this.writeDate(date);
            }
            function writeTime(time) {
                var hour = ('00' + time.getHours()).slice(-2);
                var minute = ('00' + time.getMinutes()).slice(-2);
                var second = ('00' + time.getSeconds()).slice(-2);
                var millisecond = ('000' + time.getMilliseconds()).slice(-3);
                stream.write(hproseTags.TagTime + hour + minute + second);
                if (millisecond != '000') {
                    stream.write(hproseTags.TagPoint + millisecond);
                }
                stream.write(hproseTags.TagSemicolon);
            }
            function writeTimeWithRef(time) {
                if (!this.writeRef(time)) this.writeTime(time);
            }
            function writeUTF8Char(c) {
                stream.write(hproseTags.TagUTF8Char + c);
            }
            function writeString(s) {
                stream.write(hproseTags.TagString +
                    (s.length > 0 ? s.length : '') +
                    hproseTags.TagQuote + s + hproseTags.TagQuote);
            }
            function writeStringWithRef(str) {
                if (!this.writeRef(str)) this.writeString(str);
            }
            function writeList(list) {
                var count = list.length;
                stream.write(hproseTags.TagList + (count > 0 ? count : '') + hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    this.serialize(list[i]);
                }
                stream.write(hproseTags.TagClosebrace);
            }
            function writeListWithRef(list) {
                if (!this.writeRef(list)) this.writeList(list);
            }
            function writeDict(dict) {
                var fields = (new VBArray(dict.Keys())).toArray();
                var count = fields.length;
                stream.write(hproseTags.TagMap + (count > 0 ? count : '') + hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    this.serialize(fields[i]);
                    this.serialize(dict.Item(fields[i]));
                }
                stream.write(hproseTags.TagClosebrace);
            }
            function writeDictWithRef(dict) {
                if (!this.writeRef(dict)) this.writeDict(dict);
            }
            function writeMap(map) {
                var fields = [];
                for (var key in map) {
                    if (typeof(map[key]) != 'function' &&
                        (typeof(map[key]) != 'unknown' ||
                        hproseUtil.isVBArray(map[key])) &&
                        !prototypePropertyOfObject[key] &&
                        !prototypePropertyOfArray[key]) {
                        fields[fields.length] = key;
                    }
                }
                var count = fields.length;
                stream.write(hproseTags.TagMap + (count > 0 ? count : '') + hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    this.serialize(fields[i]);
                    this.serialize(map[fields[i]]);
                }
                stream.write(hproseTags.TagClosebrace);
            }
            function writeMapWithRef(map) {
                if (!this.writeRef(map)) this.writeMap(map);
            }
            function writeObjectBegin(obj) {
                var classname = getClassName(obj);
                var index = classref[classname];
                var fields;
                if (index !== undefined) {
                    fields = fieldsref[index];
                }
                else {
                    fields = [];
                    for (var key in obj) {
                        if (typeof(obj[key]) != 'function' &&
                            !prototypePropertyOfObject[key]) {
                            fields[fields.length] = key.toString();
                        }
                    }
                    index = writeClass.call(this, classname, fields);
                }
                stream.write(hproseTags.TagObject + index + hproseTags.TagOpenbrace);
                return fields;
            }
            function writeObjectEnd(obj, fields) {
                var count = fields.length;
                for (var i = 0; i < count; i++) {
                    this.serialize(obj[fields[i]]);
                }
                stream.write(hproseTags.TagClosebrace);
            }
            function writeObject(obj) {
                this.writeObjectEnd(obj, this.writeObjectBegin(obj));
            }
            function writeObjectWithRef(obj) {
                if (!this.writeRef(obj)) this.writeObject(obj);
            }
            function writeClass(classname, fields) {
                var count = fields.length;
                stream.write(hproseTags.TagClass + classname.length +
                             hproseTags.TagQuote + classname + hproseTags.TagQuote +
                             (count > 0 ? count : '') + hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    this.writeString(fields[i]);
                }
                stream.write(hproseTags.TagClosebrace);
                var index = fieldsref.length;
                classref[classname] = index;
                fieldsref[index] = fields;
                return index;
            }
            function writeRef(obj) {
                return false;
            }
            function reset() {
                classref = {};
                fieldsref.length = 0;
            }
            this.serialize = serialize;
            this.writeInteger = writeInteger;
            this.writeLong = writeLong;
            this.writeDouble = writeDouble;
            this.writeNaN = writeNaN;
            this.writeInfinity = writeInfinity;
            this.writeNull = writeNull;
            this.writeEmpty = writeEmpty;
            this.writeBoolean = writeBoolean;
            this.writeUTCDate = writeUTCDate;
            this.writeUTCDateWithRef = writeUTCDateWithRef;
            this.writeVBSDate = writeVBSDate;
            this.writeDate = writeDate;
            this.writeDateWithRef = writeDateWithRef;
            this.writeTime = writeTime;
            this.writeTimeWithRef = writeTimeWithRef;
            this.writeUTF8Char = writeUTF8Char;
            this.writeString = writeString;
            this.writeStringWithRef = writeStringWithRef;
            this.writeList = writeList;
            this.writeListWithRef = writeListWithRef;
            this.writeDict = writeDict;
            this.writeDictWithRef = writeDictWithRef;
            this.writeMap = writeMap;
            this.writeMapWithRef = writeMapWithRef;
            this.writeObjectBegin = writeObjectBegin;
            this.writeObjectEnd = writeObjectEnd;
            this.writeObject = writeObject;
            this.writeObjectWithRef = writeObjectWithRef;
            this.writeRef = writeRef;
            this.reset = reset;
        }

        // public class
        HproseWriter = function hproseWriter(stream) {
            HproseSimpleWriter.call(this, stream);
            var ref = new ActiveXObject("Scripting.Dictionary");
            var refcount = 0;
            var writeUTCDate = this.writeUTCDate;
            this.writeUTCDate = function(date) {
                ref.Item(date) = refcount++;
                writeUTCDate.call(this, date);
            }
            var writeVBSDate = this.writeVBSDate;
            this.writeVBSDate = function(date) {
                ref.Item(date) = refcount++;
                writeVBSDate.call(this, date);
            }
            var writeDate = this.writeDate;
            this.writeDate = function(date) {
                ref.Item(date) = refcount++;
                writeDate.call(this, date);
            }
            var writeTime = this.writeTime;
            this.writeTime = function(time) {
                ref.Item(time) = refcount++;
                writeTime.call(this, time);
            }
            var writeString = this.writeString;
            this.writeString = function(str) {
                ref.Item(str) = refcount++;
                writeString.call(this, str);
            }
            var writeList = this.writeList;
            this.writeList = function(list) {
                ref.Item(list) = refcount++;
                writeList.call(this, list);
            }
            var writeDict = this.writeDict;
            this.writeDict = function(dict) {
                ref.Item(dict) = refcount++;
                writeDict.call(this, dict);
            }
            var writeMap = this.writeMap;
            this.writeMap = function(map) {
                ref.Item(map) = refcount++;
                writeMap.call(this, map);
            }
            this.writeObject = function(obj) {
                var fields = this.writeObjectBegin(obj);
                ref.Item(obj) = refcount++;
                this.writeObjectEnd(obj, fields);
            }
            this.writeRef = function(obj) {
                if (ref.Exists(obj)) {
                    stream.write(hproseTags.TagRef + ref.Item(obj) + hproseTags.TagSemicolon);
                    return true;
                }
                return false;
            }
            var reset = this.reset;
            this.reset = function() {
                reset();
                ref.RemoveAll();
                refcount = 0;
            }
        }
    })();
})();

var HproseFormatter = {
    serialize: function(variable, simple) {
        var stream = new HproseStringOutputStream();
        var hproseWriter = (simple ? new HproseSimpleWriter(stream) : new HproseWriter(stream));
        hproseWriter.serialize(variable);
        return stream.toString();
    },
    unserialize: function(variable_representation, simple) {
        var stream = new HproseStringInputStream(variable_representation);
        var hproseReader = (simple ? new HproseSimpleReader(stream) : new HproseReader(stream));
        return hproseReader.unserialize();
    }
}
