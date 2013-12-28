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
 * HproseSimpleWriter.js                                  *
 *                                                        *
 * HproseSimpleWriter for Node.js.                        *
 *                                                        *
 * LastModified: Dec 28, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require('util');
var HproseTags = require('./HproseTags.js');
var HproseClassManager = require('./HproseClassManager.js');

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
    var classname = HproseClassManager.getClassAlias(cls);
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
        HproseClassManager.register(cls, classname);       
    }
    return classname;
}

function HproseSimpleWriter(stream) {
    var classref = Object.create(null);
    var fieldsref = [];
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
                           this.writeStringWithRef(variable); break;
            default: {
                if (util.isDate(variable)) {
                    this.writeDateWithRef(variable);
                }
                else if (util.isArray(variable)) {
                    this.writeListWithRef(variable);
                }
                else if (Buffer.isBuffer(variable)) {
                    if (variable.length == 0) {
                        writeEmpty();
                    }
                    else {
                        this.writeBytesWithRef(variable);
                    }
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
    function writeUTCDate(date) {
        var year = ('0000' + date.getUTCFullYear()).slice(-4);
        var month = ('00' + (date.getUTCMonth() + 1)).slice(-2);
        var day = ('00' + date.getUTCDate()).slice(-2);
        var hour = ('00' + date.getUTCHours()).slice(-2);
        var minute = ('00' + date.getUTCMinutes()).slice(-2);
        var second = ('00' + date.getUTCSeconds()).slice(-2);
        var millisecond = ('000' + date.getUTCMilliseconds()).slice(-3);
        stream.write(HproseTags.TagDate);
        stream.write(year + month + day);
        stream.write(HproseTags.TagTime);
        stream.write(hour + minute + second);
        if (millisecond != '000') {
            stream.write(HproseTags.TagPoint);
            stream.write(millisecond);
        }
        stream.write(HproseTags.TagUTC);
    }
    function writeUTCDateWithRef(date) {
        if (!this.writeRef(date)) this.writeUTCDate(date);
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
            stream.write(HproseTags.TagDate);
            stream.write(year + month + day);
        }
        else if ((year == '1970') && (month == '01') && (day == '01')) {
            stream.write(HproseTags.TagTime);
            stream.write(hour + minute + second);
            if (millisecond != '000') {
                stream.write(HproseTags.TagPoint);
                stream.write(millisecond);
            }                        
        }
        else {
            stream.write(HproseTags.TagDate);
            stream.write(year + month + day);
            stream.write(HproseTags.TagTime);
            stream.write(hour + minute + second);
            if (millisecond != '000') {
                stream.write(HproseTags.TagPoint);
                stream.write(millisecond);
            }                        
        }
        stream.write(HproseTags.TagSemicolon);
    }
    function writeDateWithRef(date) {
        if (!this.writeRef(date)) this.writeDate(date);
    }
    function writeTime(time) {
        var hour = ('00' + time.getHours()).slice(-2);
        var minute = ('00' + time.getMinutes()).slice(-2);
        var second = ('00' + time.getSeconds()).slice(-2);
        var millisecond = ('000' + time.getMilliseconds()).slice(-3);
        stream.write(HproseTags.TagTime);
        stream.write(hour + minute + second);
        if (millisecond != '000') {
            stream.write(HproseTags.TagPoint);
            stream.write(millisecond);
        }                        
        stream.write(HproseTags.TagSemicolon);
    }
    function writeTimeWithRef(time) {
        if (!this.writeRef(time)) this.writeTime(time);
    }
    function writeBytes(bytes) {
        stream.write(HproseTags.TagBytes);
        if (bytes.length > 0) stream.write(bytes.length.toString());
        stream.write(HproseTags.TagQuote);
        if (bytes.length > 0) stream.write(bytes);
        stream.write(HproseTags.TagQuote);
    }
    function writeBytesWithRef(bytes) {
        if (!this.writeRef(bytes)) this.writeBytes(bytes);
    }
    function writeUTF8Char(c) {
        stream.write(HproseTags.TagUTF8Char);
        stream.write(c);
    }
    function writeString(str) {
        var length = str.length;
        stream.write(HproseTags.TagString);
        if (length > 0) stream.write(length.toString());
        stream.write(HproseTags.TagQuote);
        if (length > 0) stream.write(str);
        stream.write(HproseTags.TagQuote);
    }
    function writeStringWithRef(str) {
        if (!this.writeRef(str)) this.writeString(str);
    }
    function writeList(list) {
        var count = list.length;
        stream.write(HproseTags.TagList);
        if (count > 0) stream.write(count.toString());
        stream.write(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            this.serialize(list[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }
    function writeListWithRef(list) {
        if (!this.writeRef(list)) this.writeList(list);
    }
    function writeMap(map) {
        var fields = [];
        for (var key in map) {
            if (typeof(map[key]) != 'function') {
                fields[fields.length] = key;
            }
        }
        var count = fields.length;
        stream.write(HproseTags.TagMap);
        if (count > 0) stream.write(count.toString());
        stream.write(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            this.serialize(fields[i]);
            this.serialize(map[fields[i]]);
        }
        stream.write(HproseTags.TagClosebrace);
    }
    function writeMapWithRef(map) {
        if (!this.writeRef(map)) this.writeMap(map);
    }
    function writeObjectBegin(obj) {
        var classname = getClassName(obj);
        var fields;
        var index = classref[classname];
        if (index >= 0) {
            fields = fieldsref[index];
        }
        else {
            fields = [];
            for (var key in obj) {
                if (typeof(obj[key]) != 'function') {
                    fields[fields.length] = key.toString();
                }
            }
            index = writeClass.call(this, classname, fields);
        }
        stream.write(HproseTags.TagObject);
        stream.write(index.toString());
        stream.write(HproseTags.TagOpenbrace);
        return fields;
    }
    function writeObjectEnd(obj, fields) {
        var count = fields.length;
        for (var i = 0; i < count; i++) {
            this.serialize(obj[fields[i]]);
        }
        stream.write(HproseTags.TagClosebrace);
    }
    function writeObject(obj) {
        this.writeObjectEnd(obj, this.writeObjectBegin(obj));
    }
    function writeObjectWithRef(obj) {
        if (!this.writeRef(obj)) this.writeObject(obj);
    }
    function writeClass(classname, fields) {
        var count = fields.length;
        stream.write(HproseTags.TagClass);
        stream.write(classname.length.toString());
        stream.write(HproseTags.TagQuote);
        stream.write(classname);
        stream.write(HproseTags.TagQuote);
        if (count > 0) stream.write(count.toString());
        stream.write(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            this.writeString(fields[i]);
        }
        stream.write(HproseTags.TagClosebrace);
        var index = fieldsref.length;
        classref[classname] = index;
        fieldsref[index] = fields;
        return index;
    }
    function writeRef(obj) {
        return false;
    }
    function reset() {
        classref = Object.create(null);
        fieldsref.length = 0;
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
    this.writeUTCDateWithRef = writeUTCDateWithRef;
    this.writeDate = writeDate;
    this.writeDateWithRef = writeDateWithRef;
    this.writeTime = writeTime;
    this.writeTimeWithRef = writeTimeWithRef;
    this.writeBytes = writeBytes;
    this.writeBytesWithRef = writeBytesWithRef;
    this.writeUTF8Char = writeUTF8Char;
    this.writeString = writeString;
    this.writeStringWithRef = writeStringWithRef;
    this.writeList = writeList;
    this.writeListWithRef = writeListWithRef;
    this.writeMap = writeMap;
    this.writeMapWithRef = writeMapWithRef;
    this.writeObjectBegin = writeObjectBegin;
    this.writeObjectEnd = writeObjectEnd;
    this.writeObject = writeObject;
    this.writeObjectWithRef = writeObjectWithRef;
    this.writeRef = writeRef;
    this.reset = reset;
}

module.exports = HproseSimpleWriter;