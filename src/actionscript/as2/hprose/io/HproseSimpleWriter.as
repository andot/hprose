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
 * HproseSimpleWriter.as                                  *
 *                                                        *
 * hprose simple writer class for ActionScript 2.0.       *
 *                                                        *
 * LastModified: Nov 20, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.io.HproseClassManager;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;

class hprose.io.HproseSimpleWriter {
    private static function isDigit(value) {
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

    private static function isInteger(s) {
        var l = s.length;
        for (var i = (s.charAt(0) == '-') ? 1 : 0; i < l; i++) {
            if (!isDigit(s.charAt(i))) return false;
        }
        return (s != '-');
    }

    private static function isInt32(value) {
        var s = value.toString();
        return ((s.length < 12) &&
                isInteger(s) &&
                (value >= -2147483648) &&
                (value <= 2147483647));
    }

    private var classref:Object;
    private var fieldsref:Array;
    private var stream:HproseStringOutputStream;

    public function HproseSimpleWriter(stream:HproseStringOutputStream) {
        classref = {};
        fieldsref = [];
        this.stream = stream;
    }

    public function get outputStream():HproseStringOutputStream {
        return stream;
    }

    public function serialize(o) {
        if (o == null) {
            writeNull();
            return;
        }
        switch (o.constructor) {
        case Boolean:
            writeBoolean(o);
            break;
        case Number:
            isDigit(o) ?
            stream.write(o) :
            isInt32(o) ?
            writeInteger(o) :
            writeDouble(o);
            break;
        case String:
            o.length == 0 ?
            writeEmpty() :
            o.length == 1 ?
            writeUTF8Char(o) :
            writeString(o, true);
            break;
        case Date:
            writeDate(o, true);
            break;
        case Array:
            writeList(o, true);
            break;
        default:
            var alias:String = HproseClassManager.getClassAlias(o);
            (alias == "Object") ? writeMap(o, true) : writeObject(o, true);
            break;
        }
    }

    public function writeInteger(i) {
        stream.write(HproseTags.TagInteger + i + HproseTags.TagSemicolon);
    }

    public function writeLong(l) {
        stream.write(HproseTags.TagLong + l + HproseTags.TagSemicolon);
    }

    public function writeDouble(d) {
        if (isNaN(d)) {
            writeNaN();
        }
        else if (isFinite(d)) {
            stream.write(HproseTags.TagDouble + d + HproseTags.TagSemicolon);
        }
        else {
            writeInfinity(d > 0);
        }
    }

    public function writeNaN() {
        stream.write(HproseTags.TagNaN);
    }

    public function writeInfinity(positive) {
        stream.write(HproseTags.TagInfinity + (positive ?
                                               HproseTags.TagPos :
                                               HproseTags.TagNeg));
    }

    public function writeNull() {
        stream.write(HproseTags.TagNull);
    }

    public function writeEmpty() {
        stream.write(HproseTags.TagEmpty);
    }

    public function writeBoolean(bool) {
        stream.write(bool ? HproseTags.TagTrue : HproseTags.TagFalse);
    }

    public function writeUTCDate(date, checkRef) {
        var year = ('0000' + date.getUTCFullYear()).slice(-4);
        var month = ('00' + (date.getUTCMonth() + 1)).slice(-2);
        var day = ('00' + date.getUTCDate()).slice(-2);
        var hour = ('00' + date.getUTCHours()).slice(-2);
        var minute = ('00' + date.getUTCMinutes()).slice(-2);
        var second = ('00' + date.getUTCSeconds()).slice(-2);
        var millisecond = ('000' + date.getUTCMilliseconds()).slice(-3);
        if ((hour == '00') && (minute == '00') && (second == '00') && (millisecond == '000')) {
            stream.write(HproseTags.TagDate + year + month + day + HproseTags.TagUTC);
        }
        else if ((year == '1970') && (month == '01') && (day == '01')) {
            stream.write(HproseTags.TagTime + hour + minute + second);
            if (millisecond != '000') {
                stream.write(HproseTags.TagPoint + millisecond);
            }
            stream.write(HproseTags.TagUTC);
        }
        else {
            stream.write(HproseTags.TagDate + year + month + day +
                         HproseTags.TagTime + hour + minute + second);
            if (millisecond != '000') {
                stream.write(HproseTags.TagPoint + millisecond);
            }
            stream.write(HproseTags.TagUTC);
        }
    }

    public function writeDate(date, checkRef) {
        var year = ('0000' + date.getFullYear()).slice(-4);
        var month = ('00' + (date.getMonth() + 1)).slice(-2);
        var day = ('00' + date.getDate()).slice(-2);
        var hour = ('00' + date.getHours()).slice(-2);
        var minute = ('00' + date.getMinutes()).slice(-2);
        var second = ('00' + date.getSeconds()).slice(-2);
        var millisecond = ('000' + date.getMilliseconds()).slice(-3);
        if ((hour == '00') && (minute == '00') && (second == '00') && (millisecond == '000')) {
            stream.write(HproseTags.TagDate + year + month + day + HproseTags.TagSemicolon);
        }
        else if ((year == '1970') && (month == '01') && (day == '01')) {
            stream.write(HproseTags.TagTime + hour + minute + second);
            if (millisecond != '000') {
                stream.write(HproseTags.TagPoint + millisecond);
            }
            stream.write(HproseTags.TagSemicolon);
        }
        else {
            stream.write(HproseTags.TagDate + year + month + day +
                         HproseTags.TagTime + hour + minute + second);
            if (millisecond != '000') {
                stream.write(HproseTags.TagPoint + millisecond);
            }
            stream.write(HproseTags.TagSemicolon);
        }
    }

    public function writeTime(time, checkRef) {
        var hour = ('00' + time.getHours()).slice(-2);
        var minute = ('00' + time.getMinutes()).slice(-2);
        var second = ('00' + time.getSeconds()).slice(-2);
        var millisecond = ('000' + time.getMilliseconds()).slice(-3);
        stream.write(HproseTags.TagTime + hour + minute + second);
        if (millisecond != '000') {
            stream.write(HproseTags.TagPoint + millisecond);
        }
        stream.write(HproseTags.TagSemicolon);
    }

    public function writeUTF8Char(c) {
        stream.write(HproseTags.TagUTF8Char + c);
    }

    public function writeString(str, checkRef) {
        stream.write(HproseTags.TagString +
                     (str.length > 0 ? str.length : '') +
                     HproseTags.TagQuote + str + HproseTags.TagQuote);
    }

    public function writeList(list, checkRef) {
        var count = list.length;
        stream.write(HproseTags.TagList + (count > 0 ? count : '') + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            serialize(list[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public function writeMap(map, checkRef) {
        var fields = [];
        for (var key in map) {
            if (typeof(map[key]) != 'function') {
                fields[fields.length] = key;
            }
        }
        var count = fields.length;
        stream.write(HproseTags.TagMap + (count > 0 ? count : '') + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            serialize(fields[i]);
            serialize(map[fields[i]]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    private function writeObjectBegin(obj) {
        var alias = HproseClassManager.getClassAlias(obj);
        var fields;
        var index = classref[alias];
        if (index !== undefined) {
            fields = fieldsref[index];
        }
        else {
            fields = [];
            for (var key in obj) {
                if (typeof(obj[key]) != 'function') {
                    fields[fields.length] = key;
                }
            }
            index = writeClass(alias, fields);            
        }
        stream.write(HproseTags.TagObject + index + HproseTags.TagOpenbrace);
        return fields;
    }
    
    private function writeObjectEnd(obj, fields) {
        var count = fields.length;
        for (var i = 0; i < count; i++) {
            serialize(obj[fields[i]]);
        }
        stream.write(HproseTags.TagClosebrace);        
    }

    public function writeObject(obj, checkRef) {
        writeObjectEnd(obj, writeObjectBegin(obj));
    }

    private function writeClass(alias, fields) {
        var count = fields.length;
        stream.write(HproseTags.TagClass + alias.length +
                     HproseTags.TagQuote + alias + HproseTags.TagQuote +
                     (count > 0 ? count : '') + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            writeString(fields[i]);
        }
        stream.write(HproseTags.TagClosebrace);
        var index = fieldsref.length;
        classref[alias] = index;
        fieldsref[index] = fields;
        return index;
    }
    
    public function reset() {
        classref = {};
        fieldsref.length = 0;
    }
}