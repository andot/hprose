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
 * LastModified: Dec 26, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataOutput;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    public class HproseWriter extends HproseSimpleWriter {
        private var ref:Dictionary = new Dictionary();
        private var refcount:int = 0;

        public function HproseWriter(stream:IDataOutput) {
            super(stream);
        }

        public override function writeUTCDate(date:Date):void {
            ref.set(date, refcount++);
            super.writeUTCDate(date);
        }

        public override function writeDate(date:Date):void {
            ref.set(date, refcount++);
            super.writeDate(date);
        }

        public override function writeTime(time:Date):void {
            ref.set(time, refcount++);
            super.writeTime(time);
        }

        public override function writeBytes(bytes:ByteArray):void {
            ref.set(bytes, refcount++);
            super.writeBytes(bytes);
        }

        public override function writeString(str:String):void {
            ref.set(str, refcount++);
            super.writeString(str);
        }

        public override function writeList(list:Array):void {
            ref.set(list, refcount++);
            super.writeList(list);
        }

        public override function writeMap(map:*):void {
            ref.set(map, refcount++);
            super.writeMap(map);
        }

        public override function writeObject(obj:*):void {
            var fields = writeObjectBegin(obj);
            ref.set(obj, refcount++);
            writeObjectEnd(obj, fields);
        }

        protected override function writeRef(obj:*):Boolean {
            var index:* = ref[obj];
            if (index !== null) {
                stream.writeByte(HproseTags.TagRef);
                stream.writeUTFBytes(index.toString());
                stream.writeByte(HproseTags.TagSemicolon);
                return true;
            }
            return false;
        }

        public override function reset():void {
            super.reset();
            ref = new Dictionary();
            refcount = 0;
        }
    }
}