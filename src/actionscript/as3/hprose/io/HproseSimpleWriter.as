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
 * hprose simple writer class for ActionScript 3.0.       *
 *                                                        *
 * LastModified: Dec 26, 2013                             *
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

    public class HproseSimpleWriter {
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

        private var classref:Object = {};
        private var fieldsref:Array = [];
        protected var stream:IDataOutput;

        public function HproseSimpleWriter(stream:IDataOutput) {
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
                writeStringWithRef(o);
                break;
            case ByteArray:
                writeBytesWithRef(o);
                break;
            case Date:
                writeDateWithRef(o);
                break;
            case Array:
                writeListWithRef(o);
                break;
            default:
                switch (HproseClassManager.getClassAlias(o)) {
                    case "Object": writeMapWithRef(o); break;
                    case "mx_collections_ArrayCollection": writeListWithRef(o.source); break;
                    default: writeObjectWithRef(o); break;
                }
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

        public function writeUTCDate(date:Date):void {
            var year:String = ('0000' + date.getUTCFullYear()).slice(-4);
            var month:String = ('00' + (date.getUTCMonth() + 1)).slice(-2);
            var day:String = ('00' + date.getUTCDate()).slice(-2);
            var hour:String = ('00' + date.getUTCHours()).slice(-2);
            var minute:String = ('00' + date.getUTCMinutes()).slice(-2);
            var second:String = ('00' + date.getUTCSeconds()).slice(-2);
            var millisecond:String = ('000' + date.getUTCMilliseconds()).slice(-3);
            if ((hour == '00') && (minute == '00') && (second == '00') && (millisecond == '000')) {
                stream.writeByte(HproseTags.TagDate);
                stream.writeUTFBytes(year + month + day);
                stream.writeByte(HproseTags.TagUTC);
            }
            else if ((year == '1970') && (month == '01') && (day == '01')) {
                stream.writeByte(HproseTags.TagTime);
                stream.writeUTFBytes(hour + minute + second);
                if (millisecond != '000') {
                    stream.writeByte(HproseTags.TagPoint);
                    stream.writeUTFBytes(millisecond);
                }
                stream.writeByte(HproseTags.TagUTC);
            }
            else {
                stream.writeByte(HproseTags.TagDate);
                stream.writeUTFBytes(year + month + day);
                stream.writeByte(HproseTags.TagTime);
                stream.writeUTFBytes(hour + minute + second);
                if (millisecond != '000') {
                    stream.writeByte(HproseTags.TagPoint);
                    stream.writeUTFBytes(millisecond);
                }
                stream.writeByte(HproseTags.TagUTC);
            }
        }
        
        public function writeUTCDateWithRef(date:Date):void {
            if (!writeRef(date)) writeUTCDate(date);
        }

        public function writeDate(date:Date):void {
            var year:String = ('0000' + date.getFullYear()).slice(-4);
            var month:String = ('00' + (date.getMonth() + 1)).slice(-2);
            var day:String = ('00' + date.getDate()).slice(-2);
            var hour:String = ('00' + date.getHours()).slice(-2);
            var minute:String = ('00' + date.getMinutes()).slice(-2);
            var second:String = ('00' + date.getSeconds()).slice(-2);
            var millisecond:String = ('000' + date.getMilliseconds()).slice(-3);
            if ((hour == '00') && (minute == '00') && (second == '00') && (millisecond == '000')) {
                stream.writeByte(HproseTags.TagDate);
                stream.writeUTFBytes(year + month + day);
                stream.writeByte(HproseTags.TagSemicolon);
            }
            else if ((year == '1970') && (month == '01') && (day == '01')) {
                stream.writeByte(HproseTags.TagTime);
                stream.writeUTFBytes(hour + minute + second);
                if (millisecond != '000') {
                    stream.writeByte(HproseTags.TagPoint);
                    stream.writeUTFBytes(millisecond);
                }
                stream.writeByte(HproseTags.TagSemicolon);
            }
            else {
                stream.writeByte(HproseTags.TagDate);
                stream.writeUTFBytes(year + month + day);
                stream.writeByte(HproseTags.TagTime);
                stream.writeUTFBytes(hour + minute + second);
                if (millisecond != '000') {
                    stream.writeByte(HproseTags.TagPoint);
                    stream.writeUTFBytes(millisecond);
                }
                stream.writeByte(HproseTags.TagSemicolon);
            }
        }

        public function writeDateWithRef(date:Date):void {
            if (!writeRef(date)) writeDate(date);
        }

        public function writeTime(time:Date):void {
            var hour:String = ('00' + time.getHours()).slice(-2);
            var minute:String = ('00' + time.getMinutes()).slice(-2);
            var second:String = ('00' + time.getSeconds()).slice(-2);
            var millisecond:String = ('000' + time.getMilliseconds()).slice(-3);
            stream.writeByte(HproseTags.TagTime);
            stream.writeUTFBytes(hour + minute + second);
            if (millisecond != '000') {
                stream.writeByte(HproseTags.TagPoint)
                stream.writeUTFBytes(millisecond);
            }
            stream.writeByte(HproseTags.TagSemicolon);
        }

        public function writeTimeWithRef(time:Date):void {
            if (!writeRef(time)) writeTime(time);
        }

        public function writeBytes(bytes:ByteArray):void {
            stream.writeByte(HproseTags.TagBytes);
            if (bytes.length > 0) {
                stream.writeUTFBytes(bytes.length.toString());
            }
            stream.writeByte(HproseTags.TagQuote);
            stream.writeBytes(bytes);
            stream.writeByte(HproseTags.TagQuote);
        }

        public function writeBytesWithRef(bytes:ByteArray):void {
            if (!writeRef(bytes)) writeBytes(bytes);
        }

        public function writeUTF8Char(c:String):void {
            stream.writeByte(HproseTags.TagUTF8Char);
            stream.writeUTFBytes(c);
        }

        public function writeString(s:String):void {
            stream.writeByte(HproseTags.TagString);
            if (s.length > 0) {
                stream.writeUTFBytes(s.length.toString());
            }
            stream.writeByte(HproseTags.TagQuote);
            stream.writeUTFBytes(s);
            stream.writeByte(HproseTags.TagQuote);
        }

        public function writeStringWithRef(s:String):void {
            if (!writeRef(s)) writeString(s);
        }

        public function writeList(list:Array):void {
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

        public function writeListWithRef(list:Array):void {
            if (!writeRef(list)) writeList(list);
        }

        public function writeMap(map:*):void {
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

        public function writeMapWithRef(map:*):void {
            if (!writeRef(map)) writeMap(map);
        }

        protected function writeObjectBegin(obj:*):Array {
            var alias:String = HproseClassManager.getClassAlias(obj);
            var fields:Array;
            var index:int;
            if (alias in classref) {
                index = classref[alias];
                fields = fieldsref[index];
            }
            else {
                fields = getPropertyNames(obj);
                for (var key:String in obj) {
                    if (typeof(obj[key]) != 'function' &&
                        fields.indexOf(key) < 0) {
                        fields.push(key);
                    }
                }
                index = writeClass(alias, fields);            
            }
            stream.writeByte(HproseTags.TagObject);
            stream.writeUTFBytes(index.toString());
            stream.writeByte(HproseTags.TagOpenbrace);
            return fields;
        }

        protected function writeObjectEnd(obj:*, fields:Array):void {
            var count:uint = fields.length;
            for (var i:uint = 0; i < count; i++) {
                serialize(obj[fields[i]]);
            }
            stream.writeByte(HproseTags.TagClosebrace);    
        }

        public function writeObject(obj:*):void {
            writeObjectEnd(obj, writeObjectBegin(obj));
        }

        public function writeObjectWithRef(obj:*):void {
            if (!writeRef(obj)) writeObject(obj);
        }

        private function writeClass(alias:String, fields:Array):uint {
            var count:uint = fields.length;
            stream.writeByte(HproseTags.TagClass);
            stream.writeUTFBytes(alias.length.toString());
            stream.writeByte(HproseTags.TagQuote);
            stream.writeUTFBytes(alias);
            stream.writeByte(HproseTags.TagQuote);
            if (count > 0) {
                stream.writeUTFBytes(count.toString());
            }
            stream.writeByte(HproseTags.TagOpenbrace);
            for (var i:uint = 0; i < count; i++) {
                writeString(fields[i]);
            }
            stream.writeByte(HproseTags.TagClosebrace);
            var index:int = fieldsref.length;
            classref[alias] = index;
            fieldsref[index] = fields;
            return index;
        }

        protected function writeRef(obj:*):Boolean {
            return false;
        }

        public function reset():void {
            classref = {};
            fieldsref.length = 0;
        }
    }
}