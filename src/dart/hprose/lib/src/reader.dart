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
 * LastModified: Feb 11, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose;

abstract class _ReaderRefer {
  void set(dynamic obj);

  dynamic read(int index);

  void reset();
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

class _FakeReaderRefer implements _ReaderRefer {
  void set(dynamic obj) {}

  dynamic read(int index) { unexpectedTag(TagRef); }

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
      case TagInfinity:
        bytes.writeByte(_bytes.readByte());
        break;
      case TagInteger:
      case TagLong:
      case TagDouble:
      case TagRef:
        _readNumberRaw(bytes);
        break;
      case TagDate:
      case TagTime:
        _readDateTimeRaw(bytes);
        break;
      case TagUTF8Char:
        _readUTF8CharRaw(bytes);
        break;
      case TagBytes:
        _readBytesRaw(bytes);
        break;
      case TagString:
        _readStringRaw(bytes);
        break;
      case TagGuid:
        _readGuidRaw(bytes);
        break;
      case TagList:
      case TagMap:
      case TagObject:
        _readComplexRaw(bytes);
        break;
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

HashMap<ClassMirror, MethodMirror> _CtorCache = new HashMap<ClassMirror, MethodMirror>();

class HproseReader extends HproseRawReader {
  _ReaderRefer _refer;
  final List<dynamic> _classref = new List<dynamic>();
  final List<Map<String, Symbol>> _fieldsref = new List<Map<String, Symbol>>();

  HproseReader(BytesIO bytes, [bool simple = false]): super(bytes) {
    _refer = simple ? new _FakeReaderRefer() : new _RealReaderRefer();
  }

  void checkTag(int expectTag, [int tag = null]) {
    if (tag == null) tag = _bytes.readByte();
    if (tag != expectTag) unexpectedTag(tag, [expectTag]);
  }

  int checkTags(List<int> expectTags, [int tag = null]) {
    if (tag == null) tag = _bytes.readByte();
    if (expectTags.indexOf(tag) >= 0) return tag;
    unexpectedTag(tag, expectTags);
  }

  int _readInt(int tag) {
    String s = _bytes.readUntil(tag);
    if (s.isEmpty) return 0;
    return int.parse(s);
  }

  dynamic unserialize([int tag = null]) {
    if (tag == null) tag = _bytes.readByte();
    switch (tag) {
      case 0x30: return 0;
      case 0x31: return 1;
      case 0x32: return 2;
      case 0x33: return 3;
      case 0x34: return 4;
      case 0x35: return 5;
      case 0x36: return 6;
      case 0x37: return 7;
      case 0x38: return 8;
      case 0x39: return 9;
      case TagInteger:
      case TagLong: return readIntWithoutTag();
      case TagDouble: return readDoubleWithoutTag();
      case TagNull: return null;
      case TagEmpty: return '';
      case TagTrue: return true;
      case TagFalse: return false;
      case TagNaN: return double.NAN;
      case TagInfinity: return (_bytes.readByte() == TagPos ?
                                double.INFINITY :
                                double.NEGATIVE_INFINITY);
      case TagDate: return readDateWithoutTag();
      case TagTime: return readTimeWithoutTag();
      case TagBytes: return readBytesWithoutTag();
      case TagUTF8Char: return _bytes.readUTF8String(1);
      case TagString: return readStringWithoutTag();
      case TagGuid: return readGuidWithoutTag();
      case TagList: return readListWithoutTag();
      case TagMap: return readMapWithoutTag();
      case TagClass: _readClass(); return unserialize();
      case TagObject: return readObjectWithoutTag();
      case TagRef: return _readRef();
      case TagError: throw new HproseException(readString());
      default: unexpectedTag(tag);
    }
  }

  int readIntWithoutTag() {
    return _readInt(TagSemicolon);
  }

  int readInt() {
    int tag = _bytes.readByte();
    switch (tag) {
      case 0x30: return 0;
      case 0x31: return 1;
      case 0x32: return 2;
      case 0x33: return 3;
      case 0x34: return 4;
      case 0x35: return 5;
      case 0x36: return 6;
      case 0x37: return 7;
      case 0x38: return 8;
      case 0x39: return 9;
      case TagInteger:
      case TagLong: return readIntWithoutTag();
      default: unexpectedTag(tag);
    }
  }

  double readDoubleWithoutTag() {
    return double.parse(_bytes.readUntil(TagSemicolon));
  }

  double readDouble() {
    int tag = _bytes.readByte();
    switch (tag) {
      case 0x30: return 0.0;
      case 0x31: return 1.0;
      case 0x32: return 2.0;
      case 0x33: return 3.0;
      case 0x34: return 4.0;
      case 0x35: return 5.0;
      case 0x36: return 6.0;
      case 0x37: return 7.0;
      case 0x38: return 8.0;
      case 0x39: return 9.0;
      case TagInteger:
      case TagLong:
      case TagDouble: return readDoubleWithoutTag();
      case TagNaN: return double.NAN;
      case TagInfinity: return (_bytes.readByte() == TagPos ?
                                double.INFINITY :
                                double.NEGATIVE_INFINITY);
      default: unexpectedTag(tag);
    }
  }

  bool readBool() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagTrue: return true;
      case TagFalse: return false;
      default: unexpectedTag(tag);
    }
  }

  DateTime readDateWithoutTag() {
    int year = int.parse(_bytes.readAsciiString(4));
    int month = int.parse(_bytes.readAsciiString(2));
    int day = int.parse(_bytes.readAsciiString(2));
    DateTime date;
    int tag = _bytes.readByte();
    if (tag == TagTime) {
      int hour = int.parse(_bytes.readAsciiString(2));
      int minute = int.parse(_bytes.readAsciiString(2));
      int second = int.parse(_bytes.readAsciiString(2));
      int millisecond = 0;
      tag = _bytes.readByte();
      if (tag == TagPoint) {
        millisecond = int.parse(_bytes.readAsciiString(3));
        tag = _bytes.readByte();
        if ((tag >= 0x30) && (tag <= 0x39)) {
          _bytes.skip(2);
          tag = _bytes.readByte();
          if ((tag >= 0x30) && (tag <= 0x39)) {
            _bytes.skip(2);
            tag = _bytes.readByte();
          }
        }
      }
      if (tag == TagUTC) {
        date = new DateTime.utc(year, month, day, hour, minute, second, millisecond);
      } else {
        date = new DateTime(year, month, day, hour, minute, second, millisecond);
      }
    } else if (tag == TagUTC) {
      date = new DateTime.utc(year, month, day);
    } else {
      date = new DateTime(year, month, day);
    }
    _refer.set(date);
    return date;
  }

  DateTime readTimeWithoutTag() {
    DateTime time;
      int hour = int.parse(_bytes.readAsciiString(2));
      int minute = int.parse(_bytes.readAsciiString(2));
      int second = int.parse(_bytes.readAsciiString(2));
      int millisecond = 0;
      int tag = _bytes.readByte();
      if (tag == TagPoint) {
        millisecond = int.parse(_bytes.readAsciiString(3));
        tag = _bytes.readByte();
        if ((tag >= 0x30) && (tag <= 0x39)) {
          _bytes.skip(2);
          tag = _bytes.readByte();
          if ((tag >= 0x30) && (tag <= 0x39)) {
            _bytes.skip(2);
            tag = _bytes.readByte();
          }
        }
      }
      if (tag == TagUTC) {
        time = new DateTime.utc(1970, 1, 1, hour, minute, second, millisecond);
      } else {
        time = new DateTime(1970, 1, 1, hour, minute, second, millisecond);
      }
    _refer.set(time);
    return time;
  }

  DateTime readDateTime() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagDate: return readDateWithoutTag();
      case TagTime: return readTimeWithoutTag();
      case TagRef: return _readRef();
      default: unexpectedTag(tag);
    }
  }

  Uint8List readBytesWithoutTag() {
    int length = _readInt(TagQuote);
    Uint8List bytes = _bytes.read(length);
    _bytes.skip(1);
    _refer.set(bytes);
    return bytes;
  }

  Uint8List readBytes() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagString: return _stringToBytes(readStringWithoutTag());
      case TagBytes: return readBytesWithoutTag();
      case TagRef:
        dynamic r = _readRef();
        if (r is Uint8List) return r;
        if (r is String) return _stringToBytes(r);
        if (r is List<int>) return _intListToBytes(r);
        return _stringToBytes(r.toString());
      default: unexpectedTag(tag);
    }
  }

  Uint8List _intListToBytes(List<int> list) {
    if (list is Uint8List) return list;
    return new Uint8List.fromList(list);
  }

  Uint8List _stringToBytes(String str) {
    return _intListToBytes(const Utf8Encoder().convert(str));
  }

  String _readStringWithoutTag() {
    int length = _readInt(TagQuote);
    String str = _bytes.readUTF8String(length);
    _bytes.skip(1);
    return str;
  }

  String readStringWithoutTag() {
    String str = _readStringWithoutTag();
    _refer.set(str);
    return str;
  }

  String readString() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagString: return readStringWithoutTag();
      case TagRef: return _readRef().toString();
      default: unexpectedTag(tag);
    }
  }

  String readGuidWithoutTag() {
    _bytes.skip(1);
    String guid = _bytes.readAsciiString(36);
    _bytes.skip(1);
    _refer.set(guid);
    return guid;
  }

  String readGuid() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagGuid: return readGuidWithoutTag();
      case TagRef: return _readRef();
      default: unexpectedTag(tag);
    }
  }

  List<dynamic> readListWithoutTag() {
    List<dynamic> list = new List<dynamic>();
    _refer.set(list);
    int count = _readInt(TagOpenbrace);
    for (int i = 0; i < count; i++) {
      list.add(unserialize());
    }
    _bytes.skip(1);
    return list;
  }

  List<dynamic> readList() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagList: return readListWithoutTag();
      case TagRef: return _readRef();
      default: unexpectedTag(tag);
    }
  }

  Map<dynamic, dynamic> readMapWithoutTag() {
    Map<dynamic, dynamic> map = new Map<dynamic, dynamic>();
    _refer.set(map);
    int count = _readInt(TagOpenbrace);
    for (int i = 0; i < count; i++) {
      dynamic key = unserialize();
      dynamic val = unserialize();
      map[key] = val;
    }
    _bytes.skip(1);
    return map;
  }

  Map<dynamic, dynamic> readMap() {
    int tag = _bytes.readByte();
    switch (tag) {
      case TagMap: return readMapWithoutTag();
      case TagRef: return _readRef();
      default: unexpectedTag(tag);
    }
  }

  Map<String, dynamic> _readObjectAsMap(Iterable<String> keys) {
    Map<String, dynamic> map = new Map<String, dynamic>();
    _refer.set(map);
    keys.forEach((String key) {
      map[key] = unserialize();
    });
    _bytes.skip(1);
    return map;
  }

  dynamic readObjectWithoutTag() {
    int index = _readInt(TagOpenbrace);
    dynamic cm = _classref[index];
    if (cm is! ClassMirror) {
      return _readObjectAsMap(_fieldsref[index].keys);
    }
    InstanceMirror im = _newInstance(cm);
    _refer.set(im.reflectee);
    _fieldsref[index].values.forEach((Symbol name) {
      dynamic value = unserialize();
      if (name != null) {
        im.setField(name, value);
      }
    });
    _bytes.skip(1);
    return im.reflectee;
  }

  InstanceMirror _newInstance(ClassMirror cm) {
    if (!_CtorCache.containsKey(cm)) {
      _CtorCache[cm] = cm.declarations.values.where((value) {
        if (value is MethodMirror) {
          return value.isGenerativeConstructor;
        }
        return false;
      }).first;
    }
    return cm.newInstance(_CtorCache[cm].constructorName, []);
  }

  void _readClass() {
    String className = _readStringWithoutTag();
    dynamic cm = HproseClassManager.getClass(className);
    Map<String, Symbol> cachedFields = null;
    if (cm == null) {
      cm = _classref.length;
    } else {
      cachedFields = _getFieldsFromCache(cm);
    }
    int count = _readInt(TagOpenbrace);
    Map<String, Symbol> fields = new Map<String, Symbol>();
    for (int i = 0; i < count; i++) {
      String name = readString();
      if (cachedFields == null) {
        fields[name] = null;
      } else {
        fields[name] = cachedFields[name];
      }
    }
    _bytes.skip(1);
    _classref.add(cm);
    _fieldsref.add(fields);
  }

  dynamic _readRef() {
    return _refer.read(_readInt(TagSemicolon));
  }

  void reset() {
    _classref.clear();
    _fieldsref.clear();
    _refer.reset();
  }
}
