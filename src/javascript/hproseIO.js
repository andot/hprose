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
 * LastModified: Jun 22, 2011                             *
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

var HproseReader, HproseWriter;
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
    HproseReader = function hproseReader(stream) {
        var ref = [];
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
            if (arrayIndexOf(expectTags, tag) != -1) return tag;
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
                case hproseTags.TagInteger: return readInteger(false);
                case hproseTags.TagLong: return readLong(false);
                case hproseTags.TagDouble: return readDouble(false);
                case hproseTags.TagNull: return null;
                case hproseTags.TagEmpty: return '';
                case hproseTags.TagTrue: return true;
                case hproseTags.TagFalse: return false;
                case hproseTags.TagNaN: return NaN;
                case hproseTags.TagInfinity: return readInfinity(false);
                case hproseTags.TagDate: return readDate(false);
                case hproseTags.TagTime: return readTime(false);
                case hproseTags.TagUTF8Char: return stream.getc();
                case hproseTags.TagString: return readString(false);
                case hproseTags.TagGuid: return readGuid(false);
                case hproseTags.TagList: return readList(false);
                case hproseTags.TagMap: return readMap(false);
                case hproseTags.TagClass: readClass(); return unserialize();
                case hproseTags.TagObject: return readObject(false);
                case hproseTags.TagRef: return readRef();
                case HproseTags.TagError: throw new hproseException(readString());
                case '': throw new hproseException('No byte found in stream');
                default: throw new hproseException("Unexpected serialize tag '" +
                                                   tag + "' in stream");
            }
        }
        function readInteger(includeTag) {
            if (includeTag === undefined) includeTag = true;
            if (includeTag) {
                var tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) return parseInt(tag);
                checkTag(hproseTags.TagInteger, tag);
            }
            return readInt(hproseTags.TagSemicolon);
        }
        function readLong(includeTag) {
            if (includeTag === undefined) includeTag = true;
            if (includeTag) {
                var tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) return tag;
                checkTag(hproseTags.TagLong, tag);
            }
            return stream.readuntil(hproseTags.TagSemicolon);
        }
        function readDouble(includeTag) {
            if (includeTag === undefined) includeTag = true;
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
            if (includeTag === undefined) includeTag = true;
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
            if (includeTag === undefined) includeTag = true;
            var tag;
            if (includeTag) {
                tag = checkTags([hproseTags.TagDate,
                                 hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var year = parseInt(stream.read(4));
            var month = parseInt(stream.read(2)) - 1;
            var day = parseInt(stream.read(2));
            var date;
            tag = stream.getc();
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
            ref[ref.length] = date;
            return date;
        }
        function readTime(includeTag) {
            if (includeTag === undefined) includeTag = true;
            var tag;
            if (includeTag) {
                tag = checkTags([hproseTags.TagTime,
                                 hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var time;
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
                time = new Date(Date.UTC(1970, 0, 1, hour, minute, second, millisecond));
            }
            else {
                time = new Date(1970, 0, 1, hour, minute, second, millisecond);
            }
            ref[ref.length] = time;
            return time;
        }
        function readUTF8Char(includeTag) {
            if (includeTag === undefined) includeTag = true;
            if (includeTag) checkTag(hproseTags.TagUTF8Char);
            return stream.getc();
        }
        function readString(includeTag, includeRef) {
            if (includeTag === undefined) includeTag = true;
            if (includeRef === undefined) includeRef = true;
            if (includeTag) {
                var tag = checkTags([hproseTags.TagString,
                                     hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var s = stream.read(readInt(hproseTags.TagQuote));
            stream.skip(1);
            if (includeRef) ref[ref.length] = s;
            return s;
        }
        function readGuid(includeTag) {
            if (includeTag === undefined) includeTag = true;
            if (includeTag) {
                var tag = checkTags([hproseTags.TagGuid,
                                     hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            stream.skip(1);
            var s = stream.read(36);
            stream.skip(1);
            ref[ref.length] = s;
            return s;
        }
        function readList(includeTag) {
            if (includeTag === undefined) includeTag = true;
            if (includeTag) {
                var tag = checkTags([hproseTags.TagList,
                                     hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var list = [];
            ref[ref.length] = list;
            var count = readInt(hproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                list[i] = unserialize();
            }
            stream.skip(1);
            return list;
        }
        function readMap(includeTag) {
            if (includeTag === undefined) includeTag = true;
            if (includeTag) {
                var tag = checkTags([hproseTags.TagMap,
                                     hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
            }
            var map = {};
            ref[ref.length] = map;
            var count = readInt(hproseTags.TagOpenbrace);
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
                var tag = checkTags([hproseTags.TagClass,
                                     hproseTags.TagObject,
                                     hproseTags.TagRef]);
                if (tag == hproseTags.TagRef) return readRef();
                if (tag == hproseTags.TagClass) {
                    readClass();
                    return readObject();
                }
            }
            var cls = classref[readInt(hproseTags.TagOpenbrace)];
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
            var count = readInt(hproseTags.TagOpenbrace);
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
            return ref[readInt(hproseTags.TagSemicolon)];
        }
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
        function reset() {
            ref.length = 0;
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
        this.readList = readList;
        this.readMap = readMap;
        this.readObject = readObject;
        this.readRaw = readRaw;
        this.reset = reset;
    }

    // public class
    HproseWriter = function hproseWriter(stream) {
        var ref = [];
        var classref = [];
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
                             writeString(variable); break;
                case Date: writeDate(variable); break;
                default: {
                    var r = arrayIndexOf(ref, variable);
                    if (r > -1) {
                        writeRef(r);
                    }
                    else if (isArray(variable)) {
                        writeList(variable, false);
                    }
                    else {
                        var classname = getClassName(variable);
                        if (classname == "Object") {
                            writeMap(variable, false);
                        }
                        else {
                            writeObject(variable, false);
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
        function writeUTCDate(date, checkRef) {
            if (checkRef === undefined) checkRef = true;
            var year = ('0000' + date.getUTCFullYear()).slice(-4);
            var month = ('00' + (date.getUTCMonth() + 1)).slice(-2);
            var day = ('00' + date.getUTCDate()).slice(-2);
            var hour = ('00' + date.getUTCHours()).slice(-2);
            var minute = ('00' + date.getUTCMinutes()).slice(-2);
            var second = ('00' + date.getUTCSeconds()).slice(-2);
            var millisecond = ('000' + date.getUTCMilliseconds()).slice(-3);
            date = hproseTags.TagDate + year + month + day +
                   hproseTags.TagTime + hour + minute + second;
            if (millisecond != '000') {
                date += hproseTags.TagPoint + millisecond;
            }
            date += hproseTags.TagUTC;
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, date)) > -1)) {
                writeRef(r);
            }
            else {
                ref[ref.length] = date;
                stream.write(date);
            }
        }
        function writeDate(date, checkRef) {
            if (checkRef === undefined) checkRef = true;
            var year = ('0000' + date.getFullYear()).slice(-4);
            var month = ('00' + (date.getMonth() + 1)).slice(-2);
            var day = ('00' + date.getDate()).slice(-2);
            var hour = ('00' + date.getHours()).slice(-2);
            var minute = ('00' + date.getMinutes()).slice(-2);
            var second = ('00' + date.getSeconds()).slice(-2);
            var millisecond = ('000' + date.getMilliseconds()).slice(-3);
            if ((hour == '00') && (minute == '00') &&
                (second == '00') && (millisecond == '000')) {
                date = hproseTags.TagDate + year + month + day +
                       hproseTags.TagSemicolon;
            }
            else if ((year == '1970') && (month == '01') && (day == '01')) {
                date = hproseTags.TagTime + hour + minute + second;
                if (millisecond != '000') {
                    date += hproseTags.TagPoint + millisecond;
                }                        
                date += hproseTags.TagSemicolon;
            }
            else {
                date = hproseTags.TagDate + year + month + day +
                       hproseTags.TagTime + hour + minute + second;
                if (millisecond != '000') {
                    date += hproseTags.TagPoint + millisecond;
                }                        
                date += hproseTags.TagSemicolon;
            }
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, date)) > -1)) {
                writeRef(r);
            }
            else {
                ref[ref.length] = date;
                stream.write(date);
            }
        }
        function writeTime(time, checkRef) {
            if (checkRef === undefined) checkRef = true;
            var hour = ('00' + time.getHours()).slice(-2);
            var minute = ('00' + time.getMinutes()).slice(-2);
            var second = ('00' + time.getSeconds()).slice(-2);
            var millisecond = ('000' + time.getMilliseconds()).slice(-3);
            time = hproseTags.TagTime + hour + minute + second;
            if (millisecond != '000') {
                time += hproseTags.TagPoint + millisecond;
            }                        
            time += hproseTags.TagSemicolon;
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, time)) > -1)) {
                writeRef(r);
            }
            else {
                ref[ref.length] = time;
                stream.write(time);
            }
        }
        function writeUTF8Char(c) {
            stream.write(hproseTags.TagUTF8Char + c);
        }
        function writeString(s, checkRef) {
            if (checkRef === undefined) checkRef = true;
            s = hproseTags.TagString + (s.length > 0 ? s.length : '') +
                hproseTags.TagQuote + s + hproseTags.TagQuote;
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, s)) > -1)) {
                writeRef(r);
            }
            else {
                ref[ref.length] = s;
                stream.write(s);
            }
        }
        function writeList(list, checkRef) {
            if (checkRef === undefined) checkRef = true;
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, list)) > -1)) {
                writeRef(r);
            }
            else {
                ref[ref.length] = list;
                var count = list.length;
                stream.write(hproseTags.TagList + (count > 0 ? count : '') + hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    serialize(list[i]);
                }
                stream.write(hproseTags.TagClosebrace);
            }
        }
        function writeMap(map, checkRef) {
            if (checkRef === undefined) checkRef = true;
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, map)) > -1)) {
                writeRef(r);
            }
            else {
                ref[ref.length] = map;
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
                    serialize(fields[i]);
                    serialize(map[fields[i]]);
                }
                stream.write(hproseTags.TagClosebrace);
            }
        }
        function writeObject(obj, checkRef) {
            if (checkRef === undefined) checkRef = true;
            var classname = getClassName(obj);
            var r;
            if (checkRef && ((r = arrayIndexOf(ref, obj)) > -1)) {
                writeRef(r);
            }
            else {
                var fields = [];
                for (var key in obj) {
                    if (typeof(obj[key]) != 'function' &&
                        !prototypePropertyOfObject[key]) {
                        fields[fields.length] = key.toString();
                    }
                }
                var cr = arrayIndexOf(classref, classname);
                if (cr === -1) {
                    cr = writeClass(classname, fields);
                }
                ref[ref.length] = obj;
                var count = fields.length;
                stream.write(hproseTags.TagObject + cr + hproseTags.TagOpenbrace);
                for (var i = 0; i < count; i++) {
                    serialize(obj[fields[i]]);
                }
                stream.write(hproseTags.TagClosebrace);
            }
        }
        function writeClass(classname, fields) {
            var count = fields.length;
            stream.write(hproseTags.TagClass + classname.length +
                         hproseTags.TagQuote + classname + hproseTags.TagQuote +
                         (count > 0 ? count : '') + hproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                writeString(fields[i]);
            }
            stream.write(hproseTags.TagClosebrace);
            var cr = classref.length;
            classref[cr] = classname;
            return cr;
        }
        function writeRef(ref) {
            stream.write(hproseTags.TagRef + ref + hproseTags.TagSemicolon);
        }
        function reset() {
            ref.length = 0;
            classref.length = 0;
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
        this.writeObject = writeObject;
        this.reset = reset;
    }
})();

var HproseFormatter = {
    serialize: function(variable) {
        var stream = new HproseStringOutputStream();
        var hproseWriter = new HproseWriter(stream);
        hproseWriter.serialize(variable);
        return stream.toString();
    },
    unserialize: function(variable_representation) {
        var stream = new HproseStringInputStream(variable_representation);
        var hproseReader = new HproseReader(stream);
        return hproseReader.unserialize();
    }
}
