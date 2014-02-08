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
 * hprose raw reader class for ActionScript 3.0.          *
 *                                                        *
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    import hprose.common.HproseException;

    public class HproseRawReader {
        protected var stream:IDataInput;

        public function HproseRawReader(stream:IDataInput) {
            this.stream = stream;
        }

        public function get inputStream():IDataInput {
            return stream;
        }

        public function unexpectedTag(tag:int, expectTags:* = null):HproseException {
            if (expectTags == null) {
                return new HproseException("Unexpected serialize tag 0x" + tag.toString(16) + " in stream");
            }
            var expectTag:String = "";
            if (expectTags is Array) {
                for (var t:String in expectTags) {
                    expectTag += String.fromCharCode(t);
                }
            }
            else {
                expectTag = expectTags;
            }
            return new HproseException("Tag '" + String.fromCharCode(expectTag) + "' expected, " +
                                      "but 0x" + tag.toString(16) + " found in stream");
        }

        public function readRaw():ByteArray {
            var ostream:ByteArray = new ByteArray();
            _readRaw(ostream, stream.readByte());
            ostream.position = 0;
			return ostream;
		}

        private function _readRaw(ostream:ByteArray, tag:int):void {
            ostream.writeByte(tag);
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
                    break;
                case HproseTags.TagInfinity:
                    ostream.writeByte(stream.readByte());
                    break;
                case HproseTags.TagInteger:
                case HproseTags.TagLong:
                case HproseTags.TagDouble:
                case HproseTags.TagRef:
                    readNumberRaw(ostream);
                    break;
                case HproseTags.TagDate:
                case HproseTags.TagTime:
                    readDateTimeRaw(ostream);
                    break;
                case HproseTags.TagUTF8Char:
                    readUTF8CharRaw(ostream);
                    break;
                case HproseTags.TagBytes:
                    readBytesRaw(ostream);
                    break;
                case HproseTags.TagString:
                    readStringRaw(ostream);
                    break;
                case HproseTags.TagGuid:
                    readGuidRaw(ostream);
                    break;
                case HproseTags.TagList:
                case HproseTags.TagMap:
                case HproseTags.TagObject:
                    readComplexRaw(ostream);
                    break;
                case HproseTags.TagClass:
                    readComplexRaw(ostream);
                    _readRaw(ostream, stream.readByte());
                    break;
                case HproseTags.TagError:
                    _readRaw(ostream, stream.readByte());
                    break;
                default:
                    throw unexpectedTag(tag);
            }
        }

        private function readNumberRaw(ostream:ByteArray):void {
            do {
                var tag:int = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagSemicolon);
        }

        private function readDateTimeRaw(ostream:ByteArray):void {
            ostream.writeByte(tag);
            do {
                var tag:int = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagSemicolon &&
                     tag != HproseTags.TagUTC);
        }

        private function readUTF8CharRaw(ostream:ByteArray):void {
            var tag:int = stream.readByte();
            switch ((tag & 0xff) >>> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    ostream.writeByte(tag);
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    ostream.writeByte(tag);
                    ostream.writeByte(stream.readByte());
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    ostream.writeByte(tag);
                    ostream.writeByte(stream.readByte());
                    ostream.writeByte(stream.readByte());
                    break;
                }
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                                              ((tag < 0) ? "end of stream" :
                                                  "0x" + (tag & 0xff).toString(16)));
            }
        }

        private function readBytesRaw(ostream:ByteArray):void {
            var count:int = 0;
            var tag:int = 48;
            do {
                count *= 10;
                count += tag - 48;
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagQuote);
            stream.readBytes(ostream, ostream.position, count);
            ostream.position = ostream.length;
            ostream.writeByte(stream.readByte());
        }

        private function readStringRaw(ostream:ByteArray):void {
            var count:int = 0;
            var tag:int = 48;
            do {
                count *= 10;
                count += tag - 48;
                tag = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagQuote);
            for (var i:int = 0; i < count; i++) {
                tag = stream.readByte();
                switch ((tag & 0xff) >>> 4) {
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7: {
                        // 0xxx xxxx
                        ostream.writeByte(tag);
                        break;
                    }
                    case 12:
                    case 13: {
                        // 110x xxxx   10xx xxxx
                        ostream.writeByte(tag);
                        ostream.writeByte(stream.readByte());
                        break;
                    }
                    case 14: {
                        // 1110 xxxx  10xx xxxx  10xx xxxx
                        ostream.writeByte(tag);
                        ostream.writeByte(stream.readByte());
                        ostream.writeByte(stream.readByte());
                        break;
                    }
                    case 15: {
                        // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                        if ((tag & 0xf) <= 4) {
                            ostream.writeByte(tag);
                            ostream.writeByte(stream.readByte());
                            ostream.writeByte(stream.readByte());
                            ostream.writeByte(stream.readByte());
                            break;
                        }
                    // no break here!! here need throw exception.
                    }
                    default:
                        throw new HproseException("bad utf-8 encoding at " +
                                                  ((tag < 0) ? "end of stream" :
                                                      "0x" + (tag & 0xff).toString(16)));
                }
            }
            ostream.writeByte(stream.readByte());
        }

        private function readGuidRaw(ostream:ByteArray):void {
            stream.readBytes(ostream, ostream.position, 38);
            ostream.position = ostream.length;
        }

        private function readComplexRaw(ostream:ByteArray):void {
            do {
                var tag:int = stream.readByte();
                ostream.writeByte(tag);
            } while (tag != HproseTags.TagOpenbrace);
            while ((tag = stream.readByte()) != HproseTags.TagClosebrace) {
                _readRaw(ostream, tag);
            }
            ostream.writeByte(tag);
        }
    }
}