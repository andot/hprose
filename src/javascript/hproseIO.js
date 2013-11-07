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
 * LastModified: Nov 7, 2013                              *
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
        if (p >= 0) {
            s = str.substr(pos, p - pos);
            pos = p + tag.length;
        }
        else {
            s = str.substr(pos);
            pos = length;
        }
        return s;
    }
}

function HproseStringOutputStream(str) {
    if (str === undefined) str = '';
    var buf = [str];
    this.write = function(s) {
        buf.push(s);
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
    var classCache = { 'Object': Object };
    this.register = function(cls, alias) {
        classCache[alias] = cls;
    }
    this.getClassAlias = function(cls) {
        for (var alias in classCache) {
            if (cls === classCache[alias]) return alias;
        }
        return '';
    }
    this.getClass = function(alias) {
        return classCache[alias];
    } 
})();

var HproseRawReader;
var HproseSimpleReader, HproseReader;
var HproseSimpleWriter, HproseWriter;
(function() {
    // private static members
    var hproseTags = HproseTags;
    var hproseException = HproseException;
    var hproseClassManager = HproseClassManager;

    var arrayIndexOf;
    if (Array.prototype.indexOf === undefined) {
        arrayIndexOf = function(array, value) {
            var count = array.length;
            for (var i = 0; i < count; i++) {
                if (array[i] === value) return i;
            }
            return -1;
        }
    }
    else {
        arrayIndexOf = function(array, value) {
            return array.indexOf(value);
        }
    }
    function getter(str) {
        var obj = window; 
        var names = str.split('.'); 
        for(var i = 0; i < names.length; i++) { 
            obj = obj[names[i]];
            if (typeof(obj) == 'undefined') {  
                return null; 
            }
        }
        return obj;
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
            var cls = getter(classname);
            return (typeof(cls) == "function" ? cls : null);
        }
        catch(e) {
            return null;
        }
    }
    function getClass(classname) {
        var cls = hproseClassManager.getClass(classname);
        if (cls) return cls;
        cls = getter(classname);
        if (typeof(cls) == "function") {
            hproseClassManager.register(cls, classname);
            return cls;
        }
        var poslist = [];
        var pos = classname.indexOf("_");
        while (pos >= 0) {
            poslist[poslist.length] = pos;
            pos = classname.indexOf("_", pos + 1);
        }
        if (poslist.length > 0) {
            var cn = classname.split('');
            cls = findClass(cn, poslist, 0, '.');
            if (cls == null) {
                cls = findClass(cn, poslist, 0, '_');
            }
            if (typeof(cls) == "function") {
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
        if (obj === undefined || obj.constructor === undefined) return '';
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

    // public class
    HproseRawReader = function hproseRawReader(stream) {
        function readRaw(ostream, tag) {
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
                    readNumberRaw(ostream, tag);
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
                case '': throw new hproseException('No byte found in stream');
                default: throw new hproseException("Unexpected serialize tag '" +
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
        function readStringRaw(ostream, tag) {
            ostream.write(tag);
            var s = stream.readuntil(HproseTags.TagQuote);
            ostream.write(s);
            ostream.write(HproseTags.TagQuote);
            var len = 0;
            if (s.length > 0) len = parseInt(s);
            ostream.write(stream.read(len + 1));
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
        this.readRaw = readRaw;
    }
    
    // public class
    HproseSimpleReader = function hproseSimpleReader(stream) {
        HproseRawReader.call(this, stream);
        var classref = [];
        function checkTag(expectTag, tag) {
            if (tag === undefined) tag = stream.getc();
            if (tag != expectTag) {
                throw new hproseException("Tag '" + expectTag +
                                          "' expected, but '" +
                                          tag + "' found in stream");
            }
        }
        function checkTags(expectTags, tag) {
            if (tag === undefined) tag = stream.getc();
            if (arrayIndexOf(expectTags, tag) >= 0) return tag;
            throw new hproseException("'" + tag +
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
                case hproseTags.TagInteger: return readInteger();
                case hproseTags.TagLong: return readLong();
                case hproseTags.TagDouble: return readDouble();
                case hproseTags.TagNull: return null;
                case hproseTags.TagEmpty: return '';
                case hproseTags.TagTrue: return true;
                case hproseTags.TagFalse: return false;
                case hproseTags.TagNaN: return NaN;
                case hproseTags.TagInfinity: return readInfinity();
                case hproseTags.TagDate: return this.readDate();
                case hproseTags.TagTime: return this.readTime();
                case hproseTags.TagUTF8Char: return stream.getc();
                case hproseTags.TagString: return this.readString();
                case hproseTags.TagGuid: return this.readGuid();
                case hproseTags.TagList: return this.readList();
                case hproseTags.TagMap: return this.readMap();
                case hproseTags.TagClass: this.readClass(); return this.unserialize();
                case hproseTags.TagObject: return this.readObject();
                case HproseTags.TagError: throw new hproseException(this.readString(true));
                case '': throw new hproseException('No byte found in stream');
                default: throw new hproseException("Unexpected serialize tag '" +
                                                   tag + "' in stream");
            }
        }
        function readInteger(includeTag) {
            if (includeTag) {
                var tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) return parseInt(tag);
                checkTag(hproseTags.TagInteger, tag);
            }
            return readInt(hproseTags.TagSemicolon);
        }
        function readLong(includeTag) {
            if (includeTag) {
                var tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) return tag;
                checkTag(hproseTags.TagLong, tag);
            }
            return stream.readuntil(hproseTags.TagSemicolon);
        }
        function readDouble(includeTag) {
            if (includeTag) {
                var tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) return parseFloat(tag);
                checkTag(hproseTags.TagDouble, tag);
            }
            return parseFloat(stream.readuntil(hproseTags.TagSemicolon));
        }
        function readNaN() {
            checkTag(hproseTags.TagNaN);
            return NaN;
        }
        function readInfinity(includeTag) {
            if (includeTag) checkTag(hproseTags.TagInfinity);
            return ((stream.getc() == hproseTags.TagNeg) ? -Infinity : Infinity);
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
            var tag = checkTags([hproseTags.TagTrue,
                                 hproseTags.TagFalse]);
            return (tag == hproseTags.TagTrue);
        }
        function readDate(includeTag) {
            if (includeTag) checkTag(hproseTags.TagDate);
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
            return date;
        }
        function readTime(includeTag) {
            if (includeTag) checkTag(hproseTags.TagTime);
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
                time = new Date(Date.UTC(1970, 0, 1, hour, minute, second, millisecond));
            }
            else {
                time = new Date(1970, 0, 1, hour, minute, second, millisecond);
            }
            return time;
        }
        function readUTF8Char(includeTag) {
            if (includeTag) checkTag(hproseTags.TagUTF8Char);
            return stream.getc();
        }
        function readString(includeTag) {
            if (includeTag) checkTag(hproseTags.TagString);
            var s = stream.read(readInt(hproseTags.TagQuote));
            stream.skip(1);
            return s;
        }
        function readGuid(includeTag) {
            if (includeTag) checkTag(hproseTags.TagGuid);
            stream.skip(1);
            var s = stream.read(36);
            stream.skip(1);
            return s;
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
            return list;
        }
        function readList(includeTag) {
            if (includeTag) checkTag(hproseTags.TagList);
            return this.readListEnd(this.readListBegin());
        }
        function readMapBegin() {
            return {};
        }
        function readMapEnd(map) {
            var count = readInt(hproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                var key = this.unserialize();
                var value = this.unserialize();
                map[key] = value;
            }
            stream.skip(1);
            return map;
        }
        function readMap(includeTag) {
            if (includeTag) checkTag(hproseTags.TagMap);
            return this.readMapEnd(this.readMapBegin());
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
        function readObject(includeTag) {
            if (includeTag) {
                var tag = checkTags([hproseTags.TagClass,
                                     hproseTags.TagObject]);
                if (tag == hproseTags.TagClass) {
                    this.readClass();
                    return this.readObject(true);
                }
            }
            var result = this.readObjectBegin();
            return this.readObjectEnd(result.obj, result.cls);
        }
        function readClass() {
            var classname = readString();
            var count = readInt(hproseTags.TagOpenbrace);
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

    // public class
    HproseReader = function hproseReader(stream) {
        HproseSimpleReader.call(this, stream);
        var ref = [];
        function readInt(tag) {
            var s = stream.readuntil(tag);
            if (s.length == 0) return 0;
            return parseInt(s);
        }
        function readRef() {
            return ref[readInt(hproseTags.TagSemicolon)];
        }
        var unserialize = this.unserialize;
        this.unserialize = function(tag) {
            if (tag === undefined) {
                tag = stream.getc();
            }
            if (tag == hproseTags.TagRef) {
                return readRef();
            }
            return unserialize.call(this, tag);
        }
        var readDate = this.readDate;
        this.readDate = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagDate,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var date = readDate();
            ref[ref.length] = date;
            return date;
        }
        var readTime = this.readTime;
        this.readTime = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagTime,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var time = readTime();
            ref[ref.length] = time;
            return time;
        }
        var readString = this.readString;
        this.readString = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagString,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var s = readString();
            ref[ref.length] = s;
            return s;
        }
        var readGuid = this.readGuid;
        this.readGuid = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagGuid,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var s = readGuid();
            ref[ref.length] = s;
            return s;
        }
        this.readList = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagList,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var list = this.readListBegin();
            ref[ref.length] = list;
            return this.readListEnd(list);
        }
        this.readMap = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagMap,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var map = this.readMapBegin();
            ref[ref.length] = map;
            return this.readMapEnd(map);
        }
        this.readObject = function(includeTag) {
            if (includeTag) {
                var tag = this.checkTags([hproseTags.TagClass,
                                          hproseTags.TagObject,
                                          hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
                if (tag == hproseTags.TagClass) {
                    this.readClass();
                    return this.readObject(true);
                }
            }
            var result = this.readObjectBegin();
            ref[ref.length] = result.obj;
            return this.readObjectEnd(result.obj, result.cls);
        }
        var reset = this.reset;
        this.reset = function() {
            reset();
            ref.length = 0;
        }
    }

    // public class
    HproseSimpleWriter = function hproseSimpleWriter(stream) {
        var classref = Object.create(null);
        var fieldsref = [];
        function serialize(variable) {
            if (variable === undefined ||
                variable === null ||
                variable.constructor == Function) {
                writeNull();
                return;
            }
            if (variable === '') {
                writeEmpty();
                return;
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
                             this.writeString(variable, true); break;
                case Date: this.writeDate(variable, true); break;
                default: {
                    if (isArray(variable)) {
                        this.writeList(variable, true);
                    }
                    else {
                        var classname = getClassName(variable);
                        if (classname == "Object") {
                            this.writeMap(variable, true);
                        }
                        else {
                            this.writeObject(variable, true);
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
        function writeDate(date) {
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
            else if ((year == '1970') && (month == '01') && (day == '01')) {
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
        function writeUTF8Char(c) {
            stream.write(hproseTags.TagUTF8Char + c);
        }
        function writeString(s) {
            stream.write(hproseTags.TagString +
                (s.length > 0 ? s.length : '') +
                hproseTags.TagQuote + s + hproseTags.TagQuote);
        }
        function writeList(list) {
            var count = list.length;
            stream.write(hproseTags.TagList + (count > 0 ? count : '') + hproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                this.serialize(list[i]);
            }
            stream.write(hproseTags.TagClosebrace);
        }
        function writeMap(map) {
            var fields = [];
            for (var key in map) {
                if (typeof(map[key]) != 'function' &&
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
        function reset() {
            classref = Object.create(null);
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
        this.writeDate = writeDate;
        this.writeTime = writeTime;
        this.writeUTF8Char = writeUTF8Char;
        this.writeString = writeString;
        this.writeList = writeList;
        this.writeMap = writeMap;
        this.writeObjectBegin = writeObjectBegin;
        this.writeObjectEnd = writeObjectEnd;
        this.writeObject = writeObject;
        this.reset = reset;
    }

    // public class
    HproseWriter = function hproseWriter(stream) {
        HproseSimpleWriter.call(this, stream);
        var ref = [];
        function writeRef(obj, checkRef, writeBegin, writeEnd) {
            var index;
            if (checkRef && ((index = arrayIndexOf(ref, obj)) >= 0)) {
                stream.write(hproseTags.TagRef + index + hproseTags.TagSemicolon);
            }
            else {
                var result = writeBegin.call(this, obj);
                ref[ref.length] = obj;
                writeEnd.call(this, obj, result);
            }
        }
        function doNothing() {};
        var writeUTCDate = this.writeUTCDate;
        this.writeUTCDate = function(date, checkRef) {
            writeRef.call(this, date, checkRef, doNothing, writeUTCDate);
        }
        var writeDate = this.writeDate;
        this.writeDate = function(date, checkRef) {
            writeRef.call(this, date, checkRef, doNothing, writeDate);
        }
        var writeTime = this.writeTime;
        this.writeTime = function(time, checkRef) {
            writeRef.call(this, time, checkRef, doNothing, writeTime);
        }
        var writeString = this.writeString;
        this.writeString = function(str, checkRef) {
            writeRef.call(this, str, checkRef, doNothing, writeString);
        }
        var writeList = this.writeList;
        this.writeList = function(list, checkRef) {
            writeRef.call(this, list, checkRef, doNothing, writeList);
        }
        var writeMap = this.writeMap;
        this.writeMap = function(map, checkRef) {
            writeRef.call(this, map, checkRef, doNothing, writeMap);
        }
        this.writeObject = function(obj, checkRef) {
            writeRef.call(this, obj, checkRef, this.writeObjectBegin, this.writeObjectEnd);
        }
        var reset = this.reset;
        this.reset = function() {
            reset();
            ref.length = 0;
        }
    }
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
