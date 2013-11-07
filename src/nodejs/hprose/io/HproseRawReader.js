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
 * HproseRawReader.js                                     *
 *                                                        *
 * HproseRawReader for Node.js.                           *
 *                                                        *
 * LastModified: Nov 6, 2013                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseTags = require('./HproseTags.js');
var HproseException = require('../common/HproseException.js');
var HproseBufferOutputStream = require('./HproseBufferOutputStream.js');

function HproseRawReader(stream) {
    function readRaw(ostream, tag) {
        if (ostream === undefined) ostream = new HproseBufferOutputStream();
        if (tag === undefined) tag = stream.getc();
        switch (tag) {
            case 48:
            case 49:
            case 50:
            case 51:
            case 52:
            case 53:
            case 54:
            case 55:
            case 56:
            case 57:
            case HproseTags.TagNull:
            case HproseTags.TagEmpty:
            case HproseTags.TagTrue:
            case HproseTags.TagFalse:
            case HproseTags.TagNaN:
                ostream.write(tag);
                break;
            case HproseTags.TagInfinity:
                ostream.write(tag);
                ostream.write(stream.getc());
                break;
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble:
            case HproseTags.TagRef:
                readNumberRaw(ostream, tag);
                break;
            case HproseTags.TagDate:
            case HproseTags.TagTime:
                readDateTimeRaw(ostream, tag);
                break;
            case HproseTags.TagUTF8Char:
                readUTF8CharRaw(ostream, tag);
                break;
            case HproseTags.TagBytes:
                readBytesRaw(ostream, tag);
                break;
            case HproseTags.TagString:
                readStringRaw(ostream, tag);
                break;
            case HproseTags.TagGuid:
                readGuidRaw(ostream, tag);
                break;
            case HproseTags.TagList:
            case HproseTags.TagMap:
            case HproseTags.TagObject:
                readComplexRaw(ostream, tag);
                break;
            case HproseTags.TagClass:
                readComplexRaw(ostream, tag);
                readRaw(ostream);
                break;
            case HproseTags.TagError:
                ostream.write(tag);
                readRaw(ostream);
                break;
            case '': throw new HproseException('No byte found in stream');
            default: throw new HproseException("Unexpected serialize tag '" +
                                               tag + "' in stream");
        }
        return ostream;
    }
    function readNumberRaw(ostream, tag) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon);        
    }
    function readDateTimeRaw(ostream, tag) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon &&
                 tag != HproseTags.TagUTC);
    }
    function readUTF8CharRaw(ostream, tag) {
        ostream.write(tag);
        ostream.write(stream.readUTF8String(1));
    }
    function readBytesRaw(ostream, tag) {
        ostream.write(tag);
        var count = 0;
        tag = 48;
        do {
            count *= 10;
            count += tag - 48;
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagQuote);
        ostream.write(stream.read(count + 1));
    }
    function readStringRaw(ostream, tag) {
        ostream.write(tag);
        var count = 0;
        tag = 48;
        do {
            count *= 10;
            count += tag - 48;
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagQuote);
        ostream.write(stream.readUTF8String(count + 1));
    }
    function readGuidRaw(ostream, tag) {
        ostream.write(tag);
        ostream.write(stream.read(38));
    }
    function readComplexRaw(ostream, tag) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagOpenbrace);
        while ((tag = stream.getc()) != HproseTags.TagClosebrace) {
            readRaw(ostream, tag);
        }
        ostream.write(tag);
    }
    this.readRaw = readRaw;
}

module.exports = HproseRawReader;