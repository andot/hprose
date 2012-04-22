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
 * hprose writer class for ActionScript 3.0.              *
 *                                                        *
 * LastModified: Jun 7, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataOutput;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    public final class HproseWriter {        
        private static var propertyCache:Object = {};

        private static function getPropertyNames(target:*):Array {
            var className:String = getQualifiedClassName(target);
            if (className in propertyCache) return propertyCache[className];
            var propertyNames:Array = [];
            var typeInfo:XML = describeType(target is Class ? target : getDefinitionByName(className) as Class);
            var properties:XMLList = typeInfo.factory..accessor.(@access == "readwrite") + typeInfo..variable;
            for each (var propertyInfo:XML in properties) propertyNames.push(propertyInfo.@name.toString());
            propertyCache[className] = propertyNames;
            return propertyNames;
        }
        
        private static function getClassName(o:*):String {
            var classReference:* = o.constructor;
            var className:String = ClassManager.getClassAlias(classReference);
            if (className) {
                return className;
            }
            className = getQualifiedClassName(o);
            if (className == 'Object') {
                if (o.getClassName) {
                    className = o.getClassName();
                }
            }
            if (className == 'flash.utils::Dictionary') {
                className = 'Object';
            }
            className = className.replace(/\./g, '_').replace(/\:\:/g, '_');
            ClassManager.register(classReference, className);
            return className;
        }

        private static function isDigit(value:String):Boolean {
            switch (value) {
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

        private static function isInteger(s:String):Boolean {
            var l:uint = s.length;
            for (var i:uint = (s.charAt(0) == '-') ? 1 : 0; i < l; i++) {
                if (!isDigit(s.charAt(i))) return false;
            }
            return (s != '-');
        }
        
        private static function isInt32(value:Number):Boolean {
            var s:String = value.toString();
            return ((s.length < 12) &&
                    isInteger(s) &&
                    (value >= -2147483648) &&
                    (value <= 2147483647));
        }
        
        private const ref:Dictionary = new Dictionary();
        private const classref:Object = {};
        private var refCount:int = 0;
        private var classrefCount:int = 0;
        private var stream:IDataOutput;

        public function HproseWriter(stream:IDataOutput) {
            this.stream = stream;
        }

        public function get outputStream():IDataOutput {
            return stream;
        }

        public function serialize(o:*):void {
            if (o == null) {
                writeNull();
                return;
            }
            switch (o.constructor) {
            case Boolean:
                writeBoolean(o);
                break;
            case int:
                ((o >= 0) && (o <= 9)) ?
                stream.writeByte(o + 48):
                writeInteger(o);
                break;
            case uint:
                (o <= 9) ?
                stream.writeByte(int(o) + 48):
                (o <= 2147483647) ?
                writeInteger(int(o)) :
                writeLong(o);
                break;
            case Number:
                isDigit(o.toString()) ?
                stream.writeByte(int(o) + 48):
                isInt32(o) ?
                writeInteger(int(o)) :
                writeDouble(o);
                break;
            case String:
                o.length == 0 ?
                writeEmpty() :
                o.length == 1 ?
                writeUTF8Char(o) :
                writeString(o);
                break;
            case ByteArray:
                writeBytes(o);
                break;
            case Date:
                writeDate(o);
                break;
            case Array:
                writeList(o);
                break;
            default:
                var className:String = getClassName(o);
                (className == "Object") ? writeMap(o) : 
                (className == "mx_collections_ArrayCollection") ? writeList(o.source) :
                 writeObject(o, className);
                break;
            }
        }
        
        public function writeInteger(i:int):void {
            stream.writeByte(HproseTags.TagInteger);
            stream.writeUTFBytes(i.toString());
            stream.writeByte(HproseTags.TagSemicolon);
        }
        
        public function writeLong(i:*):void {
            stream.writeByte(HproseTags.TagLong);
            stream.writeUTFBytes(i.toString());
            stream.writeByte(HproseTags.TagSemicolon);
        }
        
        public function writeDouble(d:Number):void {
            if (isNaN(d)) {
                writeNaN();
            }
            else if (isFinite(d)) {
                stream.writeByte(HproseTags.TagDouble);
                stream.writeUTFBytes(d.toString());
                stream.writeByte(HproseTags.TagSemicolon);
            }
            else {
                writeInfinity(d > 0);
            }
        }
        
        public function writeNaN():void {
            stream.writeByte(HproseTags.TagNaN);
        }
        
        public function writeInfinity(positive:Boolean = true):void {
            stream.writeByte(HproseTags.TagInfinity);
            stream.writeByte(positive ? HproseTags.TagPos : HproseTags.TagNeg);
        }
        
        public function writeNull():void {
            stream.writeByte(HproseTags.TagNull);
        }

        public function writeEmpty():void {
            stream.writeByte(HproseTags.TagEmpty);
        }

        public function writeBoolean(bool:Boolean):void {
            stream.writeByte(bool ? HproseTags.TagTrue : HproseTags.TagFalse);
        }
        
        public function writeUTCDate(date:Date, checkRef:Boolean = true):void {
            var year:String = ('0000' + date.getUTCFullYear()).slice(-4);
            var month:String = ('00' + (date.getUTCMonth() + 1)).slice(-2);
            var day:String = ('00' + date.getUTCDate()).slice(-2);
            var hour:String = ('00' + date.getUTCHours()).slice(-2);
            var minute:String = ('00' + date.getUTCMinutes()).slice(-2);
            var second:String = ('00' + date.getUTCSeconds()).slice(-2);
            var millisecond:String = ('000' + date.getUTCMilliseconds()).slice(-3);
            var d:String = String.fromCharCode(HproseTags.TagDate) +
                           year + month + day +
                           String.fromCharCode(HproseTags.TagTime) +
                           hour + minute + second;
            if (millisecond != '000') {
                d += String.fromCharCode(HproseTags.TagPoint) + millisecond;
            }
            d += String.fromCharCode(HproseTags.TagUTC);
            var r:*;
            if (checkRef && ((r = ref[d]) != null)) {
                writeRef(r);
            }
            else {
                ref[d] = refCount++;
                stream.writeUTFBytes(d);
            }
        }
        
        public function writeDate(date:Date, checkRef:Boolean = true):void {
            var year:String = ('0000' + date.getFullYear()).slice(-4);
            var month:String = ('00' + (date.getMonth() + 1)).slice(-2);
            var day:String = ('00' + date.getDate()).slice(-2);
            var hour:String = ('00' + date.getHours()).slice(-2);
            var minute:String = ('00' + date.getMinutes()).slice(-2);
            var second:String = ('00' + date.getSeconds()).slice(-2);
            var millisecond:String = ('000' + date.getUTCMilliseconds()).slice(-3);
            var d:String;
            if ((hour == '00') && (minute == '00') && (second == '00') && (millisecond == '000')) {
                d = String.fromCharCode(HproseTags.TagDate) +
                    year + month + day +
                    String.fromCharCode(HproseTags.TagSemicolon);
            }
            else if ((year == '1970') && (month == '01') && (day == '01')) {
                d = String.fromCharCode(HproseTags.TagTime) +
                    hour + minute + second;
                if (millisecond != '000') {
                    d += String.fromCharCode(HproseTags.TagPoint) + millisecond;
                }
                d += String.fromCharCode(HproseTags.TagSemicolon);
            }
            else {
                d = String.fromCharCode(HproseTags.TagDate) +
                    year + month + day +
                    String.fromCharCode(HproseTags.TagTime) +
                    hour + minute + second;
                if (millisecond != '000') {
                    d += String.fromCharCode(HproseTags.TagPoint) + millisecond;
                }
                d += String.fromCharCode(HproseTags.TagSemicolon);
            }
            var r:*;
            if (checkRef && ((r = ref[d]) != null)) {
                writeRef(r);
            }
            else {
                ref[d] = refCount++;
                stream.writeUTFBytes(d);
            }
        }
        
        public function writeTime(time:Date, checkRef:Boolean = true):void {
            var hour:String = ('00' + time.getHours()).slice(-2);
            var minute:String = ('00' + time.getMinutes()).slice(-2);
            var second:String = ('00' + time.getSeconds()).slice(-2);
            var millisecond:String = ('000' + time.getUTCMilliseconds()).slice(-3);
            var t:String = String.fromCharCode(HproseTags.TagTime) +
                           hour + minute + second;
            if (millisecond != '000') {
                t += String.fromCharCode(HproseTags.TagPoint) + millisecond;
                }
            t += String.fromCharCode(HproseTags.TagSemicolon);
            var r:*;
            if (checkRef && ((r = ref[t]) != null)) {
                writeRef(r);
            }
            else {
                ref[t] = refCount++;
                stream.writeUTFBytes(t);
            }
        }

        public function writeBytes(b:ByteArray, checkRef:Boolean = true):void {
            var r:*;
            if (checkRef && ((r = ref[b]) != null)) {
                writeRef(r);
            }
            else {
                ref[b] = refCount++;
                stream.writeByte(HproseTags.TagBytes);
                if (b.length > 0) {
                    stream.writeUTFBytes(b.length.toString());
                }
                stream.writeByte(HproseTags.TagQuote);
                stream.writeBytes(b);
                stream.writeByte(HproseTags.TagQuote);
            }
        }

        public function writeUTF8Char(c:String):void {
            stream.writeByte(HproseTags.TagUTF8Char);
            stream.writeUTFBytes(c);
        }
        
        public function writeString(s:String, checkRef:Boolean = true):void {
            s = String.fromCharCode(HproseTags.TagString) +
                ((s.length > 0) ? s.length.toString() : '') +
                String.fromCharCode(HproseTags.TagQuote) +
                s +
                String.fromCharCode(HproseTags.TagQuote);
            var r:*;
            if (checkRef && ((r = ref[s]) != null)) {
                writeRef(r);
            }
            else {
                ref[s] = refCount++;
                stream.writeUTFBytes(s);
            }
        }

        public function writeList(list:Array, checkRef:Boolean = true):void {
            var r:*;
            if (checkRef && ((r = ref[list]) != null)) {
                writeRef(r);
            }
            else {
                ref[list] = refCount++;
                var count:uint = list.length;
                stream.writeByte(HproseTags.TagList);
                if (count > 0) {
                    stream.writeUTFBytes(count.toString());
                }
                stream.writeByte(HproseTags.TagOpenbrace);
                for (var i:uint = 0; i < count; i++) {
                    serialize(list[i]);
                }
                stream.writeByte(HproseTags.TagClosebrace);
            }
        }

        public function writeMap(map:*, checkRef:Boolean = true):void {
            var r:*;
            if (checkRef && ((r = ref[map]) != null)) {
                writeRef(r);
            }
            else {
                ref[map] = refCount++;
                var fields:Array = [];
                for (var key:* in map) {
                    if (typeof(map[key]) != 'function') {
                        fields[fields.length] = key;
                    }
                }
                var count:uint = fields.length;
                stream.writeByte(HproseTags.TagMap);
                if (count > 0) {
                    stream.writeUTFBytes(count.toString());
                }
                stream.writeByte(HproseTags.TagOpenbrace);
                for (var i:uint = 0; i < count; i++) {
                    serialize(fields[i]);
                    serialize(map[fields[i]]);
                }
                stream.writeByte(HproseTags.TagClosebrace);
            }
        }

        public function writeObject(obj:*, classname:String = "", checkRef:Boolean = true):void {
            var r:*;
            if (checkRef && ((r = ref[obj]) != null)) {
                writeRef(r);
            }
            else {
                if (classname == '') classname = getClassName(obj);                
                var fields:Array = getPropertyNames(obj);
                for (var key:String in obj) {
                    if (typeof(obj[key]) != 'function' &&
                        fields.indexOf(key) < 0) {
                        fields.push(key);
                    }
                }
                var cr:uint;
                classref[classname];
                if (classname in classref) {
                    cr = classref[classname];
                }
                else {
                    cr = writeClass(classname, fields);
                }
                ref[obj] = refCount++;
                var count:uint = fields.length;
                stream.writeByte(HproseTags.TagObject);
                stream.writeUTFBytes(cr.toString());
                stream.writeByte(HproseTags.TagOpenbrace);
                for (var i:uint = 0; i < count; i++) {
                    serialize(obj[fields[i]]);
                }
                stream.writeByte(HproseTags.TagClosebrace);
            }
        }

        private function writeClass(classname:String, fields:Array):uint {
            var count:uint = fields.length;
            stream.writeByte(HproseTags.TagClass);
            stream.writeUTFBytes(classname.length.toString());
            stream.writeByte(HproseTags.TagQuote);
            stream.writeUTFBytes(classname);
            stream.writeByte(HproseTags.TagQuote);
            if (count > 0) {
                stream.writeUTFBytes(count.toString());
            }
            stream.writeByte(HproseTags.TagOpenbrace);
            for (var i:uint = 0; i < count; i++) {
                writeString(fields[i]);
            }
            stream.writeByte(HproseTags.TagClosebrace);
            var cr:* = classrefCount++;
            classref[classname] = cr;
            return cr;
        }

        private function writeRef(ref:int):void {
            stream.writeByte(HproseTags.TagRef);
            stream.writeUTFBytes(ref.toString());
            stream.writeByte(HproseTags.TagSemicolon);
        }
        
        public function reset():void {
			var key:*;
            for(key in ref) delete ref[key];
            for (key in classref) delete classref[key];
            refCount = 0;
            classrefCount = 0;
        }
    }
}