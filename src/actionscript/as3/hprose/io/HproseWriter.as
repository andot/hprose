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
 * LastModified: Dec 7, 2013                              *
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

    public class HproseWriter extends HproseSimpleWriter {
        private var ref:Dictionary = new Dictionary();
        private var refcount:int = 0;

        public function HproseWriter(stream:IDataOutput) {
            super(stream);
        }

        private function writeRef(obj:*, checkRef:Boolean, writeBegin:Function, writeEnd:Function):void {
            var index:*;
            if (checkRef && ((index = ref[obj]) !== null)) {
                stream.writeByte(HproseTags.TagRef);
                stream.writeUTFBytes(index.toString());
                stream.writeByte(HproseTags.TagSemicolon);
            }
            else {
                var result = writeBegin.call(this, obj);
                ref[obj] = refcount++;
                writeEnd.call(this, obj, result);
            }
        }
        
        public override function reset():void {
            super.reset();
            ref = new Dictionary();
            refcount = 0;
        }
    
        private function doNothing():void {};
        
        public override function writeUTCDate(date:Date, checkRef:Boolean = false):void {
            writeRef.call(this, date, checkRef, doNothing, super.writeUTCDate);
        }

        public override function writeDate(date:Date, checkRef:Boolean = false):void {
            writeRef.call(this, date, checkRef, doNothing, super.writeDate);
        }

        public override function writeTime(time:Date, checkRef:Boolean = false):void {
            writeRef.call(this, time, checkRef, doNothing, super.writeTime);
        }

        public override function writeBytes(b:ByteArray, checkRef:Boolean = false):void {
            writeRef.call(this, b, checkRef, doNothing, super.writeBytes);
        }

        public override function writeString(str:String, checkRef:Boolean = false):void {
            writeRef.call(this, str, checkRef, doNothing, super.writeString);
        }

        public override function writeList(list:Array, checkRef:Boolean = false):void {
            writeRef.call(this, list, checkRef, doNothing, super.writeList);
        }

        public override function writeMap(map:*, checkRef:Boolean = false):void {
            writeRef.call(this, map, checkRef, doNothing, super.writeMap);
        }

        public override function writeObject(obj:*, checkRef:Boolean = false):void {
            writeRef.call(this, obj, checkRef, writeObjectBegin, writeObjectEnd);
        }
    }
}