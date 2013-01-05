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
 * HproseBufferInputStream.js                             *
 *                                                        *
 * HproseBufferInputStream for Node.js.                   *
 *                                                        *
 * LastModified: Oct 24, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseException = require('../common/HproseException.js');

function HproseBufferInputStream(buf) {
    var pos = 0;
    var length = buf.length;
    this.getc = function() {
        return buf[pos++];
    }
    this.read = function(len) {
        var b = new Buffer(len);
        buf.copy(b, 0, pos, pos + len);
        this.skip(len);
        return b;
    }
    this.skip = function(n) {
        pos += n;
    }
    this.readuntil = function(tag) {
        var p = pos;
        var c = buf[pos++];
        while ((c != tag) && (pos != length)) {
            c = buf[pos++];
        }
        var end = pos;
        if (c == tag) end--;
        if (end - p == 0) return '';
        return buf.toString('utf8', p, end);
    }
    this.readAsciiString = function(len) {
        var s = buf.toString('ascii', pos, pos + len);
        this.skip(len);
        return s;
    }
    this.readUTF8String = function(len) {
        if (len == 0) return '';
        var p = pos;
        for (var i = 0; i < len; i++) {
            var c = buf[pos++];
            switch (c >>> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    // 0xxx xxxx
                    break;
                case 12:
                case 13:
                    // 110x xxxx   10xx xxxx
                    pos++;
                    break;
                case 14:
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    pos += 2;
                    break;
                case 15:
                    // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                    if ((c & 0xf) <= 4) {
                        var c2 = buf[pos++];
                        var c3 = buf[pos++];
                        var c4 = buf[pos++];
                        var s = ((c & 0x07) << 18) |
                               ((c2 & 0x3f) << 12) |
                               ((c3 & 0x3f) << 6)  |
                                (c4 & 0x3f) - 0x10000;
                        if (0 <= s && s <= 0xfffff) {
                            i++;
                            break;
                        }
                    }
                // no break here!! here need throw exception.
                default:
                    throw new HproseException("bad utf-8 encoding at 0x" + c.toString(16));
            }
        }
        return buf.toString('utf8', p, pos);
    }
}

module.exports = HproseBufferInputStream;