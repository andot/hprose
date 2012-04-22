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
 * LastModified: Jun 7, 2011                              *
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
    private static function getClassName(o) {
        var classReference = o.constructor;
        var className:String = ClassManager.getClassAlias(classReference);
        if (className) {
            return className;
        }
        if (o.getClassName) {
            className = o.getClassName();
        }
        else {
            className = "Object";
        }
        ClassManager.register(classReference, className);        
        return className;
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
            writeString(o);
            break;
        case Date:
            writeDate(o);
            break;
        case Array:
            writeList(o);
            break;
        default:
            var className:String = getClassName(o);
            (className == "Object") ? writeMap(o) : writeObject(o, className);
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
        if (checkRef === undefined) checkRef = true;
        var year = ('0000' + date.getUTCFullYear()).slice(-4);
        var month = ('00' + (date.getUTCMonth() + 1)).slice(-2);
        var day = ('00' + date.getUTCDate()).slice(-2);
        var hour = ('00' + date.getUTCHours()).slice(-2);
        var minute = ('00' + date.getUTCMinutes()).slice(-2);
        var second = ('00' + date.getUTCSeconds()).slice(-2);
        var millisecond = ('000' + date.getUTCMilliseconds()).slice(-3);
        date = HproseTags.TagDate + year + month + day +
               HproseTags.TagTime + hour + minute + second;
        if (millisecond != '000') {
            date += HproseTags.TagPoint + millisecond;
        }
        date += HproseTags.TagUTC;
        var r;
        if (checkRef && ((r = arrayIndexOf(ref, date)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = date;
            stream.write(date);
        }
    }
    
    public function writeDate(date, checkRef) {
        if (checkRef === undefined) checkRef = true;
        var year = ('0000' + date.getFullYear()).slice(-4);
        var month = ('00' + (date.getMonth() + 1)).slice(-2);
        var day = ('00' + date.getDate()).slice(-2);
        var hour = ('00' + date.getHours()).slice(-2);
        var minute = ('00' + date.getMinutes()).slice(-2);
        var second = ('00' + date.getSeconds()).slice(-2);
        var millisecond = ('000' + date.getUTCMilliseconds()).slice(-3);
        if ((hour == '00') && (minute == '00') && (second == '00') && (millisecond == '000')) {
            date = HproseTags.TagDate + year + month + day +
                   HproseTags.TagSemicolon;
        }
        else if ((year == '1970') && (month == '01') && (day == '01')) {
            date = HproseTags.TagTime + hour + minute + second;
            if (millisecond != '000') {
                date += HproseTags.TagPoint + millisecond;
            }
            date += HproseTags.TagSemicolon;
        }
        else {
            date = HproseTags.TagDate + year + month + day +
                   HproseTags.TagTime + hour + minute + second;
            if (millisecond != '000') {
                date += HproseTags.TagPoint + millisecond;
            }
            date += HproseTags.TagSemicolon;
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
    
    public function writeTime(time, checkRef) {
        if (checkRef === undefined) checkRef = true;
        var hour = ('00' + time.getHours()).slice(-2);
        var minute = ('00' + time.getMinutes()).slice(-2);
        var second = ('00' + time.getSeconds()).slice(-2);
        var millisecond = ('000' + time.getUTCMilliseconds()).slice(-3);
        time = HproseTags.TagTime + hour + minute + second;
        if (millisecond != '000') {
            time += HproseTags.TagPoint + millisecond;
        }
        time += HproseTags.TagSemicolon;
        var r;
        if (checkRef && ((r = arrayIndexOf(ref, time)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = time;
            stream.write(time);
        }
    }

    public function writeUTF8Char(c) {
        stream.write(HproseTags.TagUTF8Char + c);
    }

    public function writeString(s, checkRef) {
        if (checkRef === undefined) checkRef = true;
        s = HproseTags.TagString + (s.length > 0 ? s.length : '') +
            HproseTags.TagQuote + s + HproseTags.TagQuote;
        var r;
        if (checkRef && ((r = arrayIndexOf(ref, s)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = s;
            stream.write(s);
        }
    }

    public function writeList(list, checkRef) {
        if (checkRef === undefined) checkRef = true;
        var r;
        if (checkRef && ((r = arrayIndexOf(ref, list)) > -1)) {
            writeRef(r);
        }
        else {
            ref[ref.length] = list;
            var count = list.length;
            stream.write(HproseTags.TagList + (count > 0 ? count : '') + HproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                serialize(list[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public function writeMap(map, checkRef) {
        if (checkRef === undefined) checkRef = true;
        var r;
        if (checkRef && ((r = arrayIndexOf(ref, map)) > -1)) {
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
            stream.write(HproseTags.TagMap + (count > 0 ? count : '') + HproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                serialize(fields[i]);
                serialize(map[fields[i]]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public function writeObject(obj, classname, checkRef) {
        if (classname === undefined) classname = getClassName(obj);
        if (checkRef === undefined) checkRef = true;
        var r;
        if (checkRef && ((r = arrayIndexOf(ref, obj)) > -1)) {
            writeRef(r);
        }
        else {
            var fields = [];
            for (var key in obj) {
                if (typeof(obj[key]) != 'function') {
                    fields[fields.length] = key;
                }
            }
            var cr = arrayIndexOf(classref, classname);
            if (cr == -1) {
                cr = writeClass(classname, fields);
            }
            ref[ref.length] = obj;
            var count = fields.length;
            stream.write(HproseTags.TagObject + cr + HproseTags.TagOpenbrace);
            for (var i = 0; i < count; i++) {
                serialize(obj[fields[i]]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    private function writeClass(classname, fields) {
        var count = fields.length;
        stream.write(HproseTags.TagClass + classname.length +
                     HproseTags.TagQuote + classname + HproseTags.TagQuote +
                     (count > 0 ? count : '') + HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            writeString(fields[i]);
        }
        stream.write(HproseTags.TagClosebrace);
        var cr = classref.length;
        classref[cr] = classname;
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