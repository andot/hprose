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
 * writer.dart                                            *
 *                                                        *
 * hprose writer for Dart.                                *
 *                                                        *
 * LastModified: Feb 11, 2014                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
part of hprose;

abstract class _WriterRefer {
  void set(dynamic obj);

  bool write(BytesIO bytes, dynamic obj);

  void reset();
}

class _FakeWriterRefer implements _WriterRefer {
  void set(dynamic obj) {}

  bool write(BytesIO bytes, dynamic obj) { return false; }

  void reset() {}
}

class _RealWriterRefer implements _WriterRefer {
  final Map<dynamic, int> _ref = new Map<dynamic, int>();
  int _refcount = 0;

  void set(dynamic obj) {
    _ref[obj] = _refcount++;
  }

  bool write(BytesIO bytes, dynamic obj) {
    if (_ref.containsKey(obj)) {
      int n = _ref[obj];
      bytes.writeByte(TagRef);
      bytes.writeString(n.toString());
      bytes.writeByte(TagSemicolon);
      return true;
    }
    return false;
  }

  void reset() {
    _ref.clear();
    _refcount = 0;
  }
}

final Map<ClassMirror, Map<String, Symbol>> _FieldsCache = new Map<ClassMirror, Map<String, Symbol>>();

Map<String, Symbol> _getFieldsFromCache(ClassMirror cm) {
  Map<String, Symbol> fields = _FieldsCache[cm];
  if (fields == null) {
    fields = new Map<String, Symbol>();
    Map<String, Symbol> properties = new Map<String, Symbol>();
    cm.instanceMembers.values.forEach((MethodMirror e) {
      if ((e.isSetter || e.isGetter) &&
          !e.isStatic && !e.isPrivate &&
          e.returnType is! TypedefMirror &&
          e.returnType is! FunctionTypeMirror &&
          e.returnType.simpleName != #Function) {
        String name = MirrorSystem.getName(e.simpleName);
        if (e.isSetter) name = name.substring(0, name.length - 1);
        if (properties[name] != null) {
          if (e.isSetter) {
            fields[name] = properties[name];
          } else {
            fields[name] = e.simpleName;
          }
        } else {
          properties[name] = e.simpleName;
        }
      }
    });
    _FieldsCache[cm] = fields;
  }
  return fields;
}

class HproseWriter {
  BytesIO _bytes;
  _WriterRefer _refer;
  final HashMap<String, int> _classref = new HashMap<String, int>();
  final List<Map<String, Symbol>> _fieldsref = new List<Map<String, Symbol>>();

  HproseWriter(BytesIO this._bytes, [bool simple = false]) {
    _refer = simple ? new _FakeWriterRefer() : new _RealWriterRefer();
  }

  void serialize(dynamic value) {
    if (value == null || value is Function) {
      _bytes.writeByte(TagNull);
      return;
    }
    Type type = value.runtimeType;
    switch (type) {
      case int: writeInt(value); return;
      case double: writeDouble(value); return;
      case bool: writeBool(value); return;
      case DateTime: writeDateTimeWithRef(value); return;
      case String:
        switch (value.length) {
          case 0:
            _bytes.writeByte(TagEmpty);
            return;
          case 1:
            _bytes.writeByte(TagUTF8Char);
            _bytes.writeString(value);
            return;
        }
        writeStringWithRef(value);
        return;
      default:
        switch (type.toString()) {
          case "Int32":
          case "Int64": writeInt(value.toInt()); return;
        }
        if (value is Uint8List) {
          writeBytesWithRef(value); return;
        } else if (value is List) {
          writeListWithRef(value); return;
        } else if (value is Map) {
          writeMapWithRef(value); return;
        } else {
          writeObjectWithRef(value); return;
        }
        break;
    }
  }

  void writeInt(int value) {
    if ( 0 <= value && value <= 9) {
      _bytes.writeByte(value + 0x30);
    } else {
      if (value < -2147483648 || value > 2147483647) {
        _bytes.writeByte(TagLong);
      } else {
        _bytes.writeByte(TagInteger);
      }
      _bytes.writeString(value.toString());
      _bytes.writeByte(TagSemicolon);
    }
  }

  void writeDouble(double value) {
    if (value.isNaN) {
      _bytes.writeByte(TagNaN);
    } else if (value.isInfinite) {
      _bytes.writeByte(TagInfinity);
      _bytes.writeByte(value.isNegative ? TagNeg : TagPos);
    } else {
      _bytes.writeByte(TagDouble);
      _bytes.writeString(value.toString());
      _bytes.writeByte(TagSemicolon);
    }
  }

  void writeBool(bool value) {
    _bytes.writeByte(value ? TagTrue : TagFalse);
  }

  Uint8List _formatDate(int year, int month, int day) {
    Uint8List date = new Uint8List(9);
    date[0] = TagDate;
    date[1] = 0x30 + (year ~/ 1000 % 10);
    date[2] = 0x30 + (year ~/ 100 % 10);
    date[3] = 0x30 + (year ~/ 10 % 10);
    date[4] = 0x30 + (year % 10);
    date[5] = 0x30 + (month ~/ 10 % 10);
    date[6] = 0x30 + (month % 10);
    date[7] = 0x30 + (day ~/ 10 % 10);
    date[8] = 0x30 + (day % 10);
    return date;
  }

  Uint8List _formatTime(int hour, int minute, int second, int millisecond) {
    Uint8List time = new Uint8List(11);
    time[0] = TagTime;
    time[1] = 0x30 + (hour ~/ 10 % 10);
    time[2] = 0x30 + (hour % 10);
    time[3] = 0x30 + (minute ~/ 10 % 10);
    time[4] = 0x30 + (minute % 10);
    time[5] = 0x30 + (second ~/ 10 % 10);
    time[6] = 0x30 + (second % 10);
    if (millisecond == 0) {
      time = new Uint8List.view(time.buffer, 0, 7);
    } else {
      time[7] = TagPoint;
      time[8] = 0x30 + (millisecond ~/ 100 % 10);
      time[9] = 0x30 + (millisecond ~/ 10 % 10);
      time[10] = 0x30 + (millisecond % 10);
    }
    return time;
  }

  void writeDateTime(DateTime value) {
    _refer.set(value);
    int year = value.year;
    int month = value.month;
    int day = value.day;
    int hour = value.hour;
    int minute = value.minute;
    int second = value.second;
    int millisecond = value.millisecond;
    int tag = (value.isUtc ? TagUTC : TagSemicolon);
    if (hour == 0 && minute == 0 && second == 0 && millisecond == 0) {
      _bytes.write(_formatDate(year, month, day));
      _bytes.writeByte(tag);
    } else if (year == 1970 && month == 1 && day == 1) {
      _bytes.write(_formatTime(hour, minute, second, millisecond));
      _bytes.writeByte(tag);
    } else {
      _bytes.write(_formatDate(year, month, day));
      _bytes.write(_formatTime(hour, minute, second, millisecond));
      _bytes.writeByte(tag);
    }
  }

  void writeDateTimeWithRef(DateTime value) {
    if (!_refer.write(_bytes, value)) writeDateTime(value);
  }

  void writeString(String value) {
    _refer.set(value);
    _bytes.writeByte(TagString);
    int len = value.length;
    if (len > 0) _bytes.writeString(len.toString());
    _bytes.writeByte(TagQuote);
    _bytes.writeString(value);
    _bytes.writeByte(TagQuote);
  }

  void writeStringWithRef(String value) {
    if (!_refer.write(_bytes, value)) writeString(value);
  }

  void writeBytes(Uint8List value) {
    _refer.set(value);
    _bytes.writeByte(TagBytes);
    int len = value.length;
    if (len > 0) _bytes.writeString(len.toString());
    _bytes.writeByte(TagQuote);
    _bytes.write(value);
    _bytes.writeByte(TagQuote);
  }

  void writeBytesWithRef(Uint8List value) {
    if (!_refer.write(_bytes, value)) writeBytes(value);
  }

  void _writeList(List value, void writeElem(dynamic elem)) {
    _refer.set(value);
    _bytes.writeByte(TagList);
    int len = value.length;
    if (len > 0) _bytes.writeString(len.toString());
    _bytes.writeByte(TagOpenbrace);
    value.forEach(writeElem);
    _bytes.writeByte(TagClosebrace);
  }

  void writeList(List value) {
    if (value is Int8List ||
        value is Int16List ||
        value is Int32List ||
        value is Int64List ||
        value is Uint16List ||
        value is Uint32List ||
        value is Uint64List) {
        _writeList(value, writeInt);
    } else if (value is Float32List ||
               value is Float64List) {
      _writeList(value, writeDouble);
    } else {
      _writeList(value, serialize);
    }
  }

  void writeListWithRef(List value) {
    if (!_refer.write(_bytes, value)) writeList(value);
  }

  void writeMap(Map value) {
    _refer.set(value);
    _bytes.writeByte(TagMap);
    int len = value.length;
    if (len > 0) _bytes.writeString(len.toString());
    _bytes.writeByte(TagOpenbrace);
    value.forEach((dynamic key, dynamic val) {
      serialize(key);
      serialize(val);
    });
    _bytes.writeByte(TagClosebrace);
  }

  void writeMapWithRef(Map value) {
    if (!_refer.write(_bytes, value)) writeMap(value);
  }

  void writeObject(dynamic value) {
    InstanceMirror im = reflect(value);
    ClassMirror cm = im.type;
    String className = HproseClassManager.getClassAlias(cm);
    if (className == null) {
      className = MirrorSystem.getName(cm.simpleName);
      HproseClassManager.register(cm, className);
    }
    int index = _classref[className];
    Map<String, Symbol> fields;
    if (index != null) {
      fields = _fieldsref[index];
    } else {
      fields = _getFieldsFromCache(cm);
      index = _writeClass(className, fields);
    }
    _refer.set(value);
    _bytes.writeByte(TagObject);
    _bytes.writeString(index.toString());
    _bytes.writeByte(TagOpenbrace);
    fields.values.forEach((Symbol name) => serialize(im.getField(name).reflectee));
    _bytes.writeByte(TagClosebrace);
  }

  void writeObjectWithRef(dynamic value) {
    if (!_refer.write(_bytes, value)) writeObject(value);
  }

  int _writeClass(String className, Map<String, Symbol> fields) {
    _bytes.writeByte(TagClass);
    _bytes.writeString(className.length.toString());
    _bytes.writeByte(TagQuote);
    _bytes.writeString(className);
    _bytes.writeByte(TagQuote);
    int count = fields.length;
    if (count > 0) _bytes.writeString(count.toString());
    _bytes.writeByte(TagOpenbrace);
    fields.keys.forEach(writeString);
    _bytes.writeByte(TagClosebrace);
    int index = _fieldsref.length;
    _classref[className] = index;
    _fieldsref.add(fields);
    return index;
  }

  void reset() {
    _classref.clear();
    _fieldsref.clear();
    _refer.reset();
  }
}

