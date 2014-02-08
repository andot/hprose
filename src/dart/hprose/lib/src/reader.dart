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
 * reader.dart                                            *
 *                                                        *
 * hprose reader for Dart.                                *
 *                                                        *
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
part of hprose;

abstract class _ReaderRefer {
  void set(dynamic obj);

  dynamic read(int index);

  void reset();
}

class _FakeReaderRefer implements _ReaderRefer {
  void set(dynamic obj) {}

  dynamic read(int index) { return null; }

  void reset() {}
}

class _RealReaderRefer implements _ReaderRefer {
  final List<dynamic> _ref = new List<dynamic>();
  void set(dynamic obj) {
    _ref.add(obj);
  }

  dynamic read(int index) {
    return _ref[index];
  }

  void reset() {
    _ref.clear();
  }
}

class HproseRawReader {
  BytesIO _bytes;
  HproseRawReader(BytesIO this._bytes);
  Uint8List readRaw() {
    BytesIO bytes = new BytesIO();
    readRawTo(bytes);
    return bytes.takeBytes();
  }

  void readRawTo(BytesIO bytes) {
    int tag = _bytes.readByte();
    if (tag != -1) {
      _readRaw(bytes, tag);
    }
  }

  void unexpectedTag(int tag, [List<int> expectTags = null]) {
    if (tag != -1 && expectTags != null) {
      String expectTagStr = new String.fromCharCodes(expectTags);
      throw new HproseException("Tag '${expectTagStr}' expected, but '${new String.fromCharCode(tag)}}' found in stream");
    } else if (tag != -1) {
      throw new HproseException("Unexpected serialize tag '${new String.fromCharCode(tag)}' in stream");
    } else {
      throw new HproseException('No byte found in stream');
    }
  }

  void _readRaw(BytesIO bytes, int tag) {
    bytes.writeByte(tag);
    switch (tag) {
      case 0x30:  // '0'
      case 0x31:  // '1'
      case 0x32:  // '2'
      case 0x33:  // '3'
      case 0x34:  // '4'
      case 0x35:  // '5'
      case 0x36:  // '6'
      case 0x37:  // '7'
      case 0x38:  // '8'
      case 0x39:  // '9'
      case TagNull:
      case TagEmpty:
      case TagTrue:
      case TagFalse:
      case TagNaN:
        break;
      case TagInfinity: bytes.writeByte(_bytes.readByte());
        break;
      case TagInteger:
      case TagLong:
      case TagDouble:
      case TagRef: _readNumberRaw(bytes); break;
      case TagDate:
      case TagTime: _readDateTimeRaw(bytes); break;
      case TagUTF8Char: _readUTF8CharRaw(bytes); break;
      case TagBytes: _readBytesRaw(bytes); break;
      case TagString: _readStringRaw(bytes); break;
      case TagGuid: _readGuidRaw(bytes); break;
      case TagList:
      case TagMap:
      case TagObject: _readComplexRaw(bytes); break;
      case TagClass:
        _readComplexRaw(bytes);
        readRawTo(bytes);
        break;
      case TagError:
        readRawTo(bytes);
        break;
      default:
        unexpectedTag(tag);
        break;
    }
  }

  void _readNumberRaw(BytesIO bytes) {
    int tag;
    do {
      tag = _bytes.readByte();
      bytes.writeByte(tag);
    } while (tag != TagSemicolon);
  }

  void _readDateTimeRaw(BytesIO bytes) {
    int tag;
    do {
      tag = _bytes.readByte();
      bytes.writeByte(tag);
    } while (tag != TagSemicolon && tag != TagUTC);
  }

  void _readUTF8CharRaw(BytesIO bytes) {
    bytes.writeString(_bytes.readUTF8String(1));
  }

  void _readBytesRaw(BytesIO bytes) {
    int count = 0;
    int tag = 0x30; // '0'
    do {
      count *= 10;
      count += tag - 0x30;
      tag = _bytes.readByte();
      bytes.writeByte(tag);
    } while (tag != TagQuote);
    bytes.write(_bytes.read(count + 1));
  }

  void _readStringRaw(BytesIO bytes) {
    int count = 0;
    int tag = 0x30; // '0'
    do {
      count *= 10;
      count += tag - 0x30;
      tag = _bytes.readByte();
      bytes.writeByte(tag);
    } while (tag != TagQuote);
    bytes.writeString(_bytes.readUTF8String(count + 1));
  }

  void _readGuidRaw(BytesIO bytes) {
    bytes.write(_bytes.read(38));
  }

  void _readComplexRaw(BytesIO bytes) {
    bytes.write(_bytes.readBytes(TagOpenbrace));
    int tag;
    while ((tag = _bytes.readByte()) != TagClosebrace) {
      _readRaw(bytes, tag);
    }
    bytes.writeByte(tag);
  }
}

class HproseReader {

}
