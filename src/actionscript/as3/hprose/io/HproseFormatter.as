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
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    
    public final class HproseFormatter {
        public static function serialize(o:*, stream:IDataOutput = null):IDataOutput {
            if (stream == null) {
                stream = new ByteArray();
            }
            var writer:HproseWriter = new HproseWriter(stream);
            writer.serialize(o);
            return stream;
        }
        public static function unserialize(stream:IDataInput):* {
            var reader:HproseReader = new HproseReader(stream);
            return reader.unserialize();
        }
    }
}