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
 * HproseFormatter.as                                     *
 *                                                        *
 * hprose formatter class for ActionScript 3.0.           *
 *                                                        *
 * LastModified: Dec 7, 2013                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;

    public final class HproseFormatter {
        public static function serialize(o:*, stream:IDataOutput = null, simple:Boolean = false):IDataOutput {
            if (stream == null) {
                stream = new ByteArray();
            }
            var writer:* = (simple ? new HproseSimpleWriter(stream) : new HproseWriter(stream));
            writer.serialize(o);
            return stream;
        }
        public static function unserialize(stream:IDataInput, simple:Boolean = false):* {
            var reader:* = (simple ? new HproseSimpleReader(stream) : new HproseReader(stream));
            return reader.unserialize();
        }
    }
}