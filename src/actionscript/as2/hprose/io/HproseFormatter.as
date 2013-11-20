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
 * hprose formatter class for ActionScript 2.0.           *
 *                                                        *
 * LastModified: Nov 20, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.io.HproseSimpleReader;
import hprose.io.HproseSimpleWriter;
import hprose.io.HproseReader;
import hprose.io.HproseWriter;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;

class hprose.io.HproseFormatter {
    public static function serialize(o, stream:HproseStringOutputStream, simple:Boolean):HproseStringOutputStream {
        if (stream == null) {
            stream = new HproseStringOutputStream();
        }
        var writer = (simple ? new HproseSimpleWriter(stream) : new HproseWriter(stream));
        writer.serialize(o);
        return stream;
    }
    public static function unserialize(stream, simple:Boolean) {
        if (typeof(stream) == "string") {
            stream = new HproseStringInputStream(stream);
        }
        var reader = (simple ? new HproseSimpleReader(stream) : new HproseReader(stream));
        return reader.unserialize();
    }
}