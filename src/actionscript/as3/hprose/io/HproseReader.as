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
 * HproseReader.as                                        *
 *                                                        *
 * hprose reader class for ActionScript 3.0.              *
 *                                                        *
 * LastModified: Dec 7, 2013                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;
    import hprose.common.HproseException;

    public class HproseReader extends HproseSimpleReader {
        private const ref:Array = [];

        public function HproseReader(stream:IDataInput) {
            super(stream);
        }

        public override function readDateWithoutTag():Date {
            return ref[ref.length] = super.readDateWithoutTag();
        }

        public override function readTimeWithoutTag():Date {
            return ref[ref.length] = super.readTimeWithoutTag();
        }

        public override function readBytesWithoutTag():ByteArray {
            return ref[ref.length] = super.readBytesWithoutTag();
        }

        public override function readStringWithoutTag():String {
            return ref[ref.length] = super.readStringWithoutTag();
        }

        public override function readGuidWithoutTag():String {
            return ref[ref.length] = super.readGuidWithoutTag();
        }

        public override function readListWithoutTag():Array {
            return readListEnd(ref[ref.length] = readListBegin());
        }

        public override function readMapWithoutTag():Dictionary {
            return readMapEnd(ref[ref.length] = readMapBegin());
        }

        public override function readObjectWithoutTag():* {
            var result = readObjectBegin();
            ref[ref.length] = result.obj;
            return readObjectEnd(result.obj, result.cls);
        }

        protected override function readRef():* {
            return ref[readInt(HproseTags.TagSemicolon)];
        }

        public override function reset():void {
            super.reset();
            ref.length = 0;
        }
    }
}