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
 * HproseWriter.js                                        *
 *                                                        *
 * HproseWriter for Node.js.                              *
 *                                                        *
 * LastModified: Oct 27, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require('util');
var HproseTags = require('./HproseTags.js');
var ClassManager = require('./ClassManager.js');

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

function getClassName(obj) {
    var cls = obj.constructor;
    var classname = ClassManager.getClassAlias(cls);
    if (classname) return classname;
    if (cls.name) {
        classname = cls.name;
    }
    else {
        var ctor = cls.toString();
        classname = ctor.substr(0, ctor.indexOf('(')).replace(/(^\s*function\s*)|(\s*$)/ig, '');
        if (classname == '' || classname == 'Object') {
            return (typeof(obj.getClassName) == 'function') ? obj.getClassName() : 'Object';
        }
    }
    if (classname != 'Object') {
        ClassManager.register(cls, classname);       
    }
    return classname;
}

function HproseWriter(stream) {
    var ref = [];
    var classref = [];
    function serialize(variable) {
        if (variable === undefined ||
            variable === null ||
            typeof(variable) == "function") {
            writeNull();
            return;
        }
        if (variable === '') {
            writeEmpty();
            return;
        }
        switch (typeof(variable)) {
            case "boolean": writeBoolean(variable); break;
            case "number": isDigit(variable) ?
                           stream.write(variable + 48) :
                           isInt32(variable) ?
                           writeInteger(variable) :
                           writeDouble(variable); break;
            case "string": variable.length == 1 ?
                           writeUTF8Char(variable) :
                           writeString(variable); break;
            default: {
                if (util.isDate(variable)) {
                    writeDate(variable);
                }
                else {
                    var r = ref.indexOf(variable);
                    if (r > -1) {
                        writeRef(r);
                    }
                    else if (util.isArray(variable)) {
                        writeList(variable, false);
                    }
                    else if (Buffer.isBuffer(variable)) {
                        if (variable.length == 0) {
                            writeEmpty();
                        }
                        else {
                            writeBytes(variable, false);
                        }
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
    }
    function writeInteger(i) {
        stream.write(HproseTags.TagInteger);
        stream.write(i.toString());
        stream.write(HproseTags.TagSemicolon);
    }
    function writeLong(l) {
        stream.write(HproseTags.TagLong);
        stream.write(l.toString());
        stream.write(HproseTags.TagSemicolon);
    }
    function writeDouble(d) {
        if (isNaN(d)) {
            writeNaN();
        }
        else if (isFinite(d)) {
            stream.write(HproseTags.TagDouble);
            stream.write(d.toString());
            stream.write(HproseTags.TagSemicolon);
        }
        else {
            writeInfinity(d > 0);
        }
    }
    function writeNaN() {
        stream.write(HproseTags.TagNaN);
    }
    function writeInfinity(positive) {
        stream.write(HproseTags.TagInfinity);
        stream.write(positive ? HproseTags.TagPos : HproseTags.TagNeg);
    }
    function writeNull() {
        stream.write(HproseTags.TagNull);
    }
    function writeEmpty() {
        stream.write(HproseTags.TagEmpty);
    }
    function writeBoolean(b) {
        stream.write(b ? HproseTags.TagTrue : HproseTags.TagFalse);
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
        date = String.fromCharCode(HproseTags.TagDate) + year + month + day +
               String.fromCharCode(HproseTags.TagTime) + hour + minute + second;
        if (millisecond != '000') {
            date += String.fromCharCode(HproseTags.TagPoint) + millisecond;
        }
        date += String.fromCharCode(HproseTags.TagUTC);
        var r;
        if (checkRef && ((r = ref.indexOf(date)) > -1)) {
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
            date = String.fromCharCode(HproseTags.TagDate) + year + month + day +
                   String.fromCharCode(HproseTags.TagSemicolon);
        }
        else if ((year == '1970') && (month == '01') && (day == '01')) {
            date = String.fromCharCode(HproseTags.TagTime) + hour + minute + second;
            if (millisecond != '000') {
                date += String.fromCharCode(HproseTags.TagPoint) + millisecond;
            }                        
            date += String.fromCharCode(HproseTags.TagSemicolon);
        }
        else {
            date = String.fromCharCode(HproseTags.TagDate) + year + month + day +
                   String.fromCharCode(HproseTags.TagTime) + hour + minute + second;
            if (millisecond != '000') {
                date += String.fromCharCode(HproseTags.TagPoint) + millisecond;
            }                        
            date += String.fromCharCode(HproseTags.TagSemicolon);
        }
        var r;
        if (checkRef && ((r = ref.indexOf(date)) > -1)) {
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
        time = String.fromCharCode(HproseTags.TagTime) + hour + minute + second;
        if (millisecond != '000') {
            time += String.fromCharCode(HproseTags.TagPoint) + millisecond;
        }                        
        time += String.fromCharCode(HproseTags.TagSemicolon);
        var r;
        if (checkRef && ((r = ref.indexOf(time)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = time;
            stream.write(time);
        }
    }
    function writeBytes(bytes, checkRef) {
        if (checkRef === undefined) checkRef = true;
         var r;
        if (checkRef && ((r = ref.indexOf(bytes)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = bytes;
            stream.write(String.fromCharCode(HproseTags.TagBytes) +
                         (bytes.length > 0 ? bytes.length : '') +
                         String.fromCharCode(HproseTags.TagQuote));
            stream.write(bytes);
            stream.write(HproseTags.TagQuote);
        }           
    }
    function writeUTF8Char(c) {
        stream.write(HproseTags.TagUTF8Char);
        stream.write(c);
    }
    function writeString(s, checkRef) {
        if (checkRef === undefined) checkRef = true;
        s = String.fromCharCode(HproseTags.TagString) + (s.length > 0 ? s.length : '') +
            String.fromCharCode(HproseTags.TagQuote) + s + String.fromCharCode(HproseTags.TagQuote);
        var r;
        if (checkRef && ((r = ref.indexOf(s)) > -1)) {
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
        if (checkRef && ((r = ref.indexOf(list)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = list;
            var count = list.length;
            stream.write(String.fromCharCode(HproseTags.TagList) +
                         (count > 0 ? count : '') +
                         String.fromCharCode(HproseTags.TagOpenbrace));
            for (var i = 0; i < count; i++) {
                serialize(list[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }
    function writeMap(map, checkRef) {
        if (checkRef === undefined) checkRef = true;
        var r;
        if (checkRef && ((r = ref.indexOf(map)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = map;
            var fields = [];
            for (var key in map) {
                if (typeof(map[key]) != 'function') {
                    fields[fields.length] = key;
                }
            }
            var count = fields.length;
            stream.write(String.fromCharCode(HproseTags.TagMap) +
                         (count > 0 ? count : '') +
                         String.fromCharCode(HproseTags.TagOpenbrace));
            for (var i = 0; i < count; i++) {
                serialize(fields[i]);
                serialize(map[fields[i]]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }
    function writeObject(obj, checkRef) {
        if (checkRef === undefined) checkRef = true;
        var r;
        if (checkRef && ((r = ref.indexOf(obj)) > -1)) {
            writeRef(r);
        }
        else {
            var classname = getClassName(obj);
            var fields = [];
            for (var key in obj) {
                if (typeof(obj[key]) != 'function') {
                    fields[fields.length] = key.toString();
                }
            }
            var cr = classref.indexOf(classname);
            if (cr === -1) {
                cr = writeClass(classname, fields);
            }
            ref[ref.length] = obj;
            var count = fields.length;
            stream.write(String.fromCharCode(HproseTags.TagObject) + cr + String.fromCharCode(HproseTags.TagOpenbrace));
            for (var i = 0; i < count; i++) {
                serialize(obj[fields[i]]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }
    function writeClass(classname, fields) {
        var count = fields.length;
        stream.write(String.fromCharCode(HproseTags.TagClass) + classname.length +
                     String.fromCharCode(HproseTags.TagQuote) + classname +
                     String.fromCharCode(HproseTags.TagQuote) + (count > 0 ? count : '') +
                     String.fromCharCode(HproseTags.TagOpenbrace));
        for (var i = 0; i < count; i++) {
            writeString(fields[i]);
        }
        stream.write(HproseTags.TagClosebrace);
        var cr = classref.length;
        classref[cr] = classname;
        return cr;
    }
    function writeRef(ref) {
        stream.write(String.fromCharCode(HproseTags.TagRef) + ref + String.fromCharCode(HproseTags.TagSemicolon));
    }
    function reset() {
        ref.length = 0;
        classref.length = 0;
    }
    this.stream = stream;
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
    this.writeBytes = writeBytes;
    this.writeUTF8Char = writeUTF8Char;
    this.writeString = writeString;
    this.writeList = writeList;
    this.writeMap = writeMap;
    this.writeObject = writeObject;
    this.reset = reset;
}

module.exports = HproseWriter;