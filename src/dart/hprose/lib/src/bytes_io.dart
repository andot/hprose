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
 * bytes_io.dart                                          *
 *                                                        *
 * hprose bytes io for Dart.                              *
 *                                                        *
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
part of hprose;

class BytesIO {
  static const int _INIT_SIZE = 1024;
  Uint8List _bytes;
  int _length = 0;  // for write
  int _mark = 0;    // for write
  int _off = 0;     // for read

  int get length => _length;

  int get capacity => _bytes.length;

  int get position => _off;

  BytesIO([Uint8List this._bytes]) {
    if (_bytes != null) {
      _length = _bytes.length;
      mark();
    }
  }

  void reset() {
    _length = _mark;
    _off = 0;
  }

  void clear() {
    _bytes = null;
    _length = 0;
    _mark = 0;
    _off = 0;
  }

  void mark() {
    _mark = _length;
  }

  void writeByte(int byte) {
    _grow(1);
    _bytes[_length++] = byte;
  }

  void write(List<int> bytes) {
    int length = bytes.length;
    if (length == 0) return;
    _grow(length);
    int totalLength = length + _length;
    if (bytes is Uint8List) {
      _bytes.setRange(_length, totalLength, bytes);
    } else {
      for (int i = 0; i < length; i++) {
        _bytes[_length + i] = bytes[i];
      }
    }
    _length = totalLength;
  }

  void writeString(String string) {
    int length = string.length;
    if (length == 0) return;
    // A single code unit uses at most 3 bytes. Two code units at most 4.
    _grow(length * 3);
    for (int i = 0; i < length; i++) {
      int codeUnit = string.codeUnitAt(i);
      if (codeUnit < 0x80) {
        _bytes[_length++] = codeUnit;
      } else if (codeUnit < 0x800) {
        _bytes[_length++] = 0xC0 | (codeUnit >> 6);
        _bytes[_length++] = 0x80 | (codeUnit & 0x3F);
      } else if (codeUnit < 0xD800 || codeUnit > 0xDfff) {
        _bytes[_length++] = 0xE0 | (codeUnit >> 12);
        _bytes[_length++] = 0x80 | ((codeUnit >> 6) & 0x3F);
        _bytes[_length++] = 0x80 | (codeUnit & 0x3F);
      } else {
        if (i + 1 < length) {
          int nextCodeUnit = string.codeUnitAt(i + 1);
          if (codeUnit < 0xDC00 && 0xDC00 <= nextCodeUnit && nextCodeUnit <= 0xDFFF) {
            int rune = (((codeUnit & 0xDC00) << 10) | (nextCodeUnit & 0x03FF)) + 0x010000;
            _bytes[_length++] = 0xF0 | ((rune >> 18) & 0x3F);
            _bytes[_length++] = 0x80 | ((rune >> 12) & 0x3F);
            _bytes[_length++] = 0x80 | ((rune >> 6) & 0x3F);
            _bytes[_length++] = 0x80 | (rune & 0x3F);
            i++;
            continue;
          }
        }
        throw new FormatException("Malformed string");
      }
    }
  }

  int readByte() {
    if (_off < _length) {
      return _bytes[_off++];
    }
    return -1;
  }

  Uint8List read(int length) {
    if (_off + length > _length) {
      length = _length - _off;
    }
    if (length == 0) return new Uint8List(0);
    Uint8List buf = new Uint8List.fromList(new Uint8List.view(_bytes.buffer, _off, length));
    _off += length;
    return buf;
  }

  int skip(int length) {
    if (_off + length > _length) {
      length = _length - _off;
      _off = _length;
    } else {
      _off += length;
    }
    return length;
  }

  // the result includes tag.
  Uint8List readBytes(int tag) {
    Uint8List buf = new Uint8List.view(_bytes.buffer, _off, _length);
    int pos = buf.indexOf(tag);
    if (pos == -1) {
      _off = _length;
    } else {
      buf = new Uint8List.view(_bytes.buffer, _off, pos + 1);
      _off += pos + 1;
    }
    return buf;
  }

  // the result doesn't include tag. but the position is the same as readBytes
  String readUntil(int tag) {
    Uint8List buf = new Uint8List.view(_bytes.buffer, _off, _length);
    int pos = buf.indexOf(tag);
    switch (pos) {
      case  0:
        _off++;
        return "";
      case -1:
        _off = _length;
        return new Utf8Decoder().convert(buf);
    }
    String str = const Utf8Decoder().convert(new Uint8List.view(_bytes.buffer, _off, pos));
    _off += pos + 1;
    return str;
  }

  String readAsciiString(int length) {
    if (_off + length > _length) {
      length = _length - _off;
    }
    if (length == 0) return "";
    String str = const AsciiDecoder().convert(new Uint8List.view(_bytes.buffer, _off, length));
    _off += length;
    return str;
  }

  // length is the UTF16 length
  String readUTF8String(int length) {
    if (length == 0) return "";
    Uint16List charCodes = new Uint16List(length);
    int i = 0;
    for (; i < length && _off < _length; i++) {
      int unit = _bytes[_off++];
      switch (unit >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          charCodes[i] = unit;
          break;
        case 12:
        case 13:
          if (_off < _length) {
            charCodes[i] = ((unit & 0x1F) << 6) |
                           (_bytes[_off++] & 0x3F);
          } else {
            throw new FormatException("Unfinished UTF-8 octet sequence");
          }
          break;
        case 14:
          if (_off + 1 < _length) {
            charCodes[i] = ((unit & 0x0F) << 12) |
                           ((_bytes[_off++] & 0x3F) << 6) |
                           (_bytes[_off++] & 0x3F);
          } else {
            throw new FormatException("Unfinished UTF-8 octet sequence");
          }
          break;
        case 15:
          if (_off + 2 < _length) {
             int rune = ((unit & 0x07) << 18) |
                        ((_bytes[_off++] & 0x3F) << 12) |
                        ((_bytes[_off++] & 0x3F) << 6) |
                        (_bytes[_off++] & 0x3F) - 0x10000;
             if (0 <= rune && rune <= 0xFFFFF) {
               charCodes[i++] = (((rune >> 10) & 0x03FF) | 0xD800);
               charCodes[i] = ((rune & 0x03FF) | 0xDC00);
             } else {
               throw new FormatException("Character outside valid Unicode range: "
                                         "0x${rune.toRadixString(16)}");
             }
          } else {
            throw new FormatException("Unfinished UTF-8 octet sequence");
          }
          break;
        default:
          throw new FormatException(
              "Bad UTF-8 encoding 0x${unit.toRadixString(16)}");
      }
    }
    if (i < length) {
      charCodes = new Uint16List.view(charCodes.buffer, 0, i);
    }
    return new String.fromCharCodes(charCodes);
  }

  // returns a view of the the internal buffer and clears `this`.
  Uint8List takeBytes() {
    if (_bytes == null) return new Uint8List(0);
    var buffer = new Uint8List.view(_bytes.buffer, 0, _length);
    clear();
    return buffer;
  }

  // returns a copy of the current contents and leaves `this` intact.
  Uint8List toBytes() {
    if (_bytes == null) return new Uint8List(0);
    return new Uint8List.fromList(
        new Uint8List.view(_bytes.buffer, 0, _length));
  }

  String toString() {
    if (_length == 0) return "";
    return const Utf8Decoder().convert(new Uint8List.view(_bytes.buffer, 0, _length));
  }

  int _pow2roundup(int x) {
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x + 1;
  }

  void _grow(int n) {
    int required = _length + n;
    if (_bytes == null) {
      int size = _pow2roundup(required);
      size = max(size, _INIT_SIZE);
      _bytes = new Uint8List(size);
    } else {
      int size = _pow2roundup(required) * 2;
      if (size > _bytes.length) {
        var buf = new Uint8List(size);
        buf.setRange(0, _bytes.length, _bytes);
        _bytes = buf;
      }
    }
  }
}