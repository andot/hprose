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
 * HproseWriter.as                                        *
 *                                                        *
 * hprose writer class for ActionScript 2.0.              *
 *                                                        *
 * LastModified: Dec 11, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
import hprose.io.ClassManager;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;

class hprose.io.HproseWriter {
    private static function arrayIndexOf(a, v) {
        var count = a.length;
        for (var i = 0; i < count; i++) {
            if (a[i] === v) return i;
        }
        return -1;
    }

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

    private var ref:Array;
    private var classref:Array;
    private var stream:HproseStringOutputStream;

    public function HproseWriter(stream:HproseStringOutputStream) {
        ref = [];
        classref = [];
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
            writeStringWithRef(o);
            break;
        case Date:
            writeDateWithRef(o);
            break;
        case Array:
            writeListWithRef(o);
            break;
        default:
            var classAlias:String = ClassManager.getClassAlias(o);
            (classAlias == "Object") ? writeMapWithRef(o) : _writeObjectWithRef(o, classAlias);
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

    public function writeUTCDate(date) {
        ref[ref.length] = date;
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

    public function writeUTCDateWithRef(date) {
        var r = arrayIndexOf(ref, date);
        (r > -1) ? writeRef(r) : writeUTCDate(date);
    }

    public function writeDate(date, checkRef) {
        ref[ref.length] = date;
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

    public function writeDateWithRef(date) {
        var r = arrayIndexOf(ref, date);
        (r > -1) ? writeRef(r) : writeDate(date);
    }

    public function writeTime(time) {
        ref[ref.length] = time;
        var hour = ('00' + time.getHours()).slice(-2);
        var minute = ('00' + time.getMinutes()).slice(-2);
        var second = ('00' + time.getSeconds()).slice(-2);
        var millisecond = ('000' + time.getUTCMilliseconds()).slice(-3);
        stream.write(HproseTags.TagTime + hour + minute + second);
        if (millisecond != '000') {
            stream.write(HproseTags.TagPoint + millisecond);
        }
        stream.write(HproseTags.TagSemicolon);
    }

    public function writeTimeWithRef(time) {
        var r = arrayIndexOf(ref, time);
        (r > -1) ? writeRef(r) : writeTime(time);
    }

    public function writeUTF8Char(c) {
        stream.write(HproseTags.TagUTF8Char + c);
    }

    public function writeString(str) {
        ref[ref.length] = str;
        stream.write(HproseTags.TagString +
                     (str.length > 0 ? str.length : '') +
                     HproseTags.TagQuote + str + HproseTags.TagQuote);
    }

    public function writeStringWithRef(str) {
        var r = arrayIndexOf(ref, str);
        (r > -1) ? writeRef(r) : writeString(str);
    }

    public function writeList(list) {
        ref[ref.length] = list;
        var count = list.length;
        stream.write(HproseTags.TagList + (count > 0 ? count : '') + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            serialize(list[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public function writeListWithRef(list) {
        var r = arrayIndexOf(ref, list);
        (r > -1) ? writeRef(r) : writeList(list);
    }

    public function writeMap(map, checkRef) {
        ref[ref.length] = map;
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

    public function writeMapWithRef(map) {
        var r = arrayIndexOf(ref, map);
        (r > -1) ? writeRef(r) : writeMap(map);
    }

    private function _writeObject(obj, classAlias) {
        var fields = [];
        for (var key in obj) {
            if (typeof(obj[key]) != 'function') {
                fields[fields.length] = key;
            }
        }
        var cr = arrayIndexOf(classref, classAlias);
        if (cr == -1) {
            cr = writeClass(classAlias, fields);
        }
        ref[ref.length] = obj;
        var count = fields.length;
        stream.write(HproseTags.TagObject + cr + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            serialize(obj[fields[i]]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    private function _writeObjectWithRef(obj, classAlias) {
        var r = arrayIndexOf(ref, obj);
        (r > -1) ? writeRef(r) : _writeObject(obj, classAlias);
    }

    public function writeObject(obj) {
        _writeObject(obj, ClassManager.getClassAlias(obj));
    }

    public function writeObjectWithRef(obj) {
        var r = arrayIndexOf(ref, obj);
        (r > -1) ? writeRef(r) : writeObject(obj);
    }

    private function writeClass(classAlias, fields) {
        var count = fields.length;
        stream.write(HproseTags.TagClass + classAlias.length +
                     HproseTags.TagQuote + classAlias + HproseTags.TagQuote +
                     (count > 0 ? count : '') + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            writeString(fields[i]);
        }
        stream.write(HproseTags.TagClosebrace);
        var cr = classref.length;
        classref[cr] = classAlias;
        return cr;
    }

    private function writeRef(ref) {
        stream.write(HproseTags.TagRef + ref + HproseTags.TagSemicolon);
    }
    
    public function reset() {
        ref.length = 0;
        classref.length = 0;
    }
}