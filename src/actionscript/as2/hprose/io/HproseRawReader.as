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
 * HproseRawReader.as                                     *
 *                                                        *
 * hprose raw reader class for ActionScript 2.0.          *
 *                                                        *
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.common.HproseException;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;

class hprose.io.HproseRawReader {
    private var stream:HproseStringInputStream;

    public function HproseRawReader(stream:HproseStringInputStream) {
        this.stream = stream;
    }

    public function get inputStream():HproseStringInputStream {
        return stream;
    }

    public function unexpectedTag(tag:String, expectTags:String):Void {
        if (tag && expectTags) {
            throw new HproseException("Tag '" + expectTags + "' expected, but '" + tag + "' found in stream");
        }
        else if (tag) {
            throw new HproseException("Unexpected serialize tag '" + tag + "' in stream")
        }
        else {
            throw new HproseException('No byte found in stream');
        }
    }

    public function readRaw(ostream:HproseStringOutputStream, tag:String) {
        if (ostream === undefined) ostream = new HproseStringOutputStream();
        if (tag === undefined) tag = stream.getc();
        switch (tag) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case HproseTags.TagNull:
            case HproseTags.TagEmpty:
            case HproseTags.TagTrue:
            case HproseTags.TagFalse:
            case HproseTags.TagNaN:
                ostream.write(tag);
                break;
            case HproseTags.TagInfinity:
            case HproseTags.TagUTF8Char:
                ostream.write(tag);
                ostream.write(stream.getc());
                break;
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble:
            case HproseTags.TagRef:
                readNumberRaw(ostream);
                break;
            case HproseTags.TagDate:
            case HproseTags.TagTime:
                readDateTimeRaw(ostream, tag);
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
            default: unexpectedTag(tag);
        }
        return ostream;
    }

    private function readNumberRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon);        
    }
    
    private function readDateTimeRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        do {
            tag = stream.getc();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon &&
                 tag != HproseTags.TagUTC);
    }

    private function readStringRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        var s:String = stream.readuntil(HproseTags.TagQuote);
        ostream.write(s);
        ostream.write(HproseTags.TagQuote);
        var len = 0;
        if (s.length > 0) len = parseInt(s);
        ostream.write(stream.read(len));
        ostream.write(stream.getc());
    }

    private function readGuidRaw(ostream:HproseStringOutputStream, tag:String) {
        ostream.write(tag);
        ostream.write(stream.read(38));
    }

    private function readComplexRaw(ostream:HproseStringOutputStream, tag:String) {
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
}