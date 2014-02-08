############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.net/                 #
#                   http://www.hprose.org/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# hprose/io.py                                             #
#                                                          #
# hprose io for python 3.0+                                #
#                                                          #
# LastModified: Feb 9, 2014                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

from io import BytesIO
from calendar import timegm
import datetime
from fpconst import NaN, PosInf, NegInf, isInf, isNaN, isPosInf
from inspect import isclass
from sys import modules
from threading import RLock
from uuid import UUID
from hprose.common import *

ZERO = datetime.timedelta(0)

class UTC(datetime.tzinfo):
    def utcoffset(self, dt):
        return ZERO
    def tzname(self, dt):
        return "UTC"
    def dst(self, dt):
        return ZERO
utc = UTC()

class HproseSerializeException(HproseException):
    pass

class HproseUnserializeException(HproseException):
    pass

class HproseTags:
# Serialize Tags #
    TagInteger = b'i'
    TagLong = b'l'
    TagDouble = b'd'
    TagNull = b'n'
    TagEmpty = b'e'
    TagTrue = b't'
    TagFalse = b'f'
    TagNaN = b'N'
    TagInfinity = b'I'
    TagDate = b'D'
    TagTime = b'T'
    TagUTC = b'Z'
    TagBytes = b'b'
    TagUTF8Char = b'u'
    TagString = b's'
    TagGuid = b'g'
    TagList = b'a'
    TagMap = b'm'
    TagClass = b'c'
    TagObject = b'o'
    TagRef = b'r'
# Serialize Marks #
    TagPos = b'+'
    TagNeg = b'-'
    TagSemicolon = b';'
    TagOpenbrace = b'{'
    TagClosebrace = b'}'
    TagQuote = b'"'
    TagPoint = b'.'
# Protocol Tags #
    TagFunctions = b'F'
    TagCall = b'C'
    TagResult = b'R'
    TagArgument = b'A'
    TagError = b'E'
    TagEnd = b'z'

_classCache1 = {}
_classCache2 = {}
_classCacheLock = RLock()

def _get_class(name):
    name = name.split('.')
    if len(name) == 1:
        return getattr(modules['__main__'], name[0], None)
    clsname = name.pop()
    modname = '.'.join(name)
    if modname in modules:
        return getattr(modules[modname], clsname, None)
    return None

def _get_class2(name, ps, i, c):
    if i < len(ps):
        p = ps[i]
        name = name[:p] + c + name[p + 1:]
        cls = _get_class2(name, ps, i + 1, '.')
        if (i + 1 < len(ps)) and (cls == None):
            cls = _get_class2(name, ps, i + 1, '_')
        return cls
    return _get_class(name)

def _get_class_by_alias(name):
    cls = getattr(modules['__main__'], name, None)
    if not isclass(cls):
        ps = []
        p = name.find('_')
        while p > -1:
            ps.append(p)
            p = name.find('_', p + 1)
        cls = _get_class2(name, ps, 0, '.')
        if  cls == None:
            cls = _get_class2(name, ps, 0, '_')
    if cls == None:
        cls = type(name, (), {})
        cls.__module__ = '__main__'
        setattr(modules['__main__'], name, cls)
    return cls

class HproseClassManager:
    def register(cls, alias):
        _classCacheLock.acquire()
        try:
            _classCache1[cls] = alias
            _classCache2[alias] = cls
        finally:
            _classCacheLock.release()
    register = staticmethod(register)

    def getClass(alias):
        if alias in _classCache2:
            return _classCache2[alias]
        cls = _get_class_by_alias(alias)
        HproseClassManager.register(cls, alias)
        return cls
    getClass = staticmethod(getClass)

    def getClassAlias(cls):
        if cls in _classCache1:
            return _classCache1[cls]
        alias = [];
        if cls.__module__ != '__main__':
            alias.extend(cls.__module__.split('.'))
        alias.append(cls.__name__)
        alias = '_'.join(alias)
        HproseClassManager.register(cls, alias)
        return alias
    getClassAlias = staticmethod(getClassAlias)

def _readuntil(stream, char):
    a = []
    while True:
        c = stream.read(1)
        if (c == char) or (c == b''): break
        a.append(c)
    return b''.join(a)

def _readint(stream, char):
    s = _readuntil(stream, char)
    if s == b'': return 0
    return int(s)

class HproseRawReader(object):
    def __init__(self, stream):
        self.stream = stream
    def unexpectedTag(self, tag, expectTags = None):
        if tag == b'':
            raise HproseUnserializeException('No byte found in stream')
        elif expectTags == None:
            raise HproseUnserializeException(
                "Unexpected serialize tag '%s' in stream" %
                str(tag, 'utf-8'))
        else:
            raise HproseUnserializeException(
                "Tag '%s' expected, but '%s' found in stream" %
                (str(expectTags, 'utf-8'), str(tag, 'utf-8')))
    def readRaw(self, ostream = None, tag = None):
        if ostream == None:
            ostream = BytesIO()
        if tag == None:
            tag = self.stream.read(1)
        ostream.write(tag)
        if ((b'0' <= tag <= b'9') or
            (tag == HproseTags.TagNull) or
            (tag == HproseTags.TagEmpty) or
            (tag == HproseTags.TagTrue) or
            (tag == HproseTags.TagFalse) or
            (tag == HproseTags.TagNaN)):
        elif tag == HproseTags.TagInfinity:
            ostream.write(self.stream.read(1))
        elif ((tag == HproseTags.TagInteger) or
            (tag == HproseTags.TagLong) or
            (tag == HproseTags.TagDouble) or
            (tag == HproseTags.TagRef)):
            self.__readNumberRaw(ostream)
        elif ((tag == HproseTags.TagDate) or
            (tag == HproseTags.TagTime)):
            self.__readDateTimeRaw(ostream)
        elif (tag == HproseTags.TagUTF8Char):
            self.__readUTF8CharRaw(ostream)
        elif (tag == HproseTags.TagBytes):
            self.__readBytesRaw(ostream)
        elif (tag == HproseTags.TagString):
            self.__readStringRaw(ostream)
        elif (tag == HproseTags.TagGuid):
            self.__readGuidRaw(ostream)
        elif ((tag == HproseTags.TagList) or
            (tag == HproseTags.TagMap) or
            (tag == HproseTags.TagObject)):
            self.__readComplexRaw(ostream)
        elif (tag == HproseTags.TagClass):
            self.__readComplexRaw(ostream)
            self.readRaw(ostream)
        elif (tag == HproseTags.TagError):
            self.readRaw(ostream)
        else:
            self.unexpectedTag(tag)
        return ostream
    def __readNumberRaw(self, ostream):
        ostream.write(_readuntil(self.stream, HproseTags.TagSemicolon))
        ostream.write(HproseTags.TagSemicolon)
    def __readDateTimeRaw(self, ostream):
        s = []
        while True:
            c = stream.read(1)
            s.append(c)
            if ((c == HproseTags.TagSemicolon) or
                (c == HproseTags.TagUTC)): break
        ostream.write(b''.join(s))
    def __readUTF8CharRaw(self, ostream):
        s = []
        c = self.stream.read(1)
        s.append(c)
        a = ord(c)
        if (a & 0xE0) == 0xC0:
            s.append(self.stream.read(1))
        elif (a & 0xF0) == 0xE0:
            s.append(self.stream.read(2))
        elif a > 0x7F:
            raise HproseException('Bad utf-8 encoding')
        ostream.write(b''.join(s))

    def __readBytesRaw(self, ostream):
        l = _readuntil(self.stream, HproseTags.TagQuote)
        ostream.write(l)
        ostream.write(HproseTags.TagQuote)
        if l == b'':
            l = 0
        else:
            l = int(l)
        ostream.write(self.stream.read(l + 1))

    def __readStringRaw(self, ostream):
        l = _readuntil(self.stream, HproseTags.TagQuote)
        ostream.write(l)
        ostream.write(HproseTags.TagQuote)
        if l == b'':
            l = 0
        else:
            l = int(l)
        s = []
        i = 0
        while i < l:
            c = self.stream.read(1)
            s.append(c)
            a = ord(c)
            if (a & 0xE0) == 0xC0:
                s.append(self.stream.read(1))
            elif (a & 0xF0) == 0xE0:
                s.append(self.stream.read(2))
            elif (a & 0xF8) == 0xF0:
                s.append(self.stream.read(3))
                i += 1
            i += 1
        s.append(self.stream.read(1))
        ostream.write(b''.join(s))
    def __readGuidRaw(self, ostream):
        ostream.write(self.stream.read(38))
    def __readComplexRaw(self, ostream):
        ostream.write(_readuntil(self.stream, HproseTags.TagOpenbrace))
        ostream.write(HproseTags.TagOpenbrace)
        tag = self.stream.read(1)
        while tag != HproseTags.TagClosebrace:
            self.readRaw(ostream, tag)
            tag = self.stream.read(1)
        ostream.write(tag)

class HproseSimpleReader(HproseRawReader):
    def __init__(self, stream):
        super(HproseSimpleReader, self).__init__(stream)
        self.classref = []
    def unserialize(self, tag = None):
        if tag == None:
            tag = self.stream.read(1)
        if b'0' <= tag <= b'9':
            return int(tag);
        if (tag == HproseTags.TagInteger or
            tag == HproseTags.TagLong):
            return self.readIntegerWithoutTag()
        if tag == HproseTags.TagDouble:
            return self.readDoubleWithoutTag()
        if tag == HproseTags.TagNull:
            return None
        if tag == HproseTags.TagEmpty:
            return ''
        if tag == HproseTags.TagTrue:
            return True
        if tag == HproseTags.TagFalse:
            return False
        if tag == HproseTags.TagNaN:
            return NaN
        if tag == HproseTags.TagInfinity:
            return self.readInfinityWithoutTag()
        if tag == HproseTags.TagDate:
            return self.readDateWithoutTag()
        if tag == HproseTags.TagTime:
            return self.readTimeWithoutTag()
        if tag == HproseTags.TagBytes:
            return self.readBytesWithoutTag()
        if tag == HproseTags.TagUTF8Char:
            return self.readUTF8CharWithoutTag()
        if tag == HproseTags.TagString:
            return self.readStringWithoutTag()
        if tag == HproseTags.TagGuid:
            return self.readGuidWithoutTag()
        if tag == HproseTags.TagList:
            return self.readListWithoutTag()
        if tag == HproseTags.TagMap:
            return self.readMapWithoutTag()
        if tag == HproseTags.TagClass:
            self.__readClass()
            return self.readObject()
        if tag == HproseTags.TagObject:
            return self.readObjectWithoutTag()
        if tag == HproseTags.TagRef:
            return self._readRef()
        if tag == HproseTags.TagError:
            raise HproseException(self.readstring())
        self.unexpectedTag(tag)
    def checkTag(self, expectTag):
        tag = self.stream.read(1)
        if tag != expectTag:
            self.unexpectedTag(tag, expectTag)
    def checkTags(self, expectTags):
        tag = self.stream.read(1)
        if tag not in expectTags:
            self.unexpectedTag(tag, b''.join(expectTags))
        return tag
    def readIntegerWithoutTag(self):
        return int(_readuntil(self.stream, HproseTags.TagSemicolon))
    def readInteger(self):
        tag = self.stream.read(1)
        if b'0' <= tag <= b'9':
            return int(tag)
        if (tag == HproseTags.TagInteger or
            tag == HproseTags.TagLong):
            return self.readIntegerWithoutTag()
        self.unexpectedTag(tag)
    def readLongWithoutTag(self):
        return self.readIntegerWithoutTag()
    def readLong(self):
        return self.readInteger()
    def readDoubleWithoutTag(self):
        return float(_readuntil(self.stream, HproseTags.TagSemicolon))
    def readDouble(self):
        tag = self.stream.read(1)
        if b'0' <= tag <= b'9':
            return float(tag)
        if (tag == HproseTags.TagInteger or
            tag == HproseTags.TagLong or
            tag == HproseTags.TagDouble):
            return self.readDoubleWithoutTag()
        if tag == HproseTags.TagNaN:
            return NaN
        if tag == HproseTags.TagInfinity:
            return self.readInfinityWithoutTag()
        self.unexpectedTag(tag)
    def readNaN(self):
        self.checkTag(HproseTags.TagNaN)
        return NaN
    def readInfinityWithoutTag(self):
        if self.stream.read(1) == HproseTags.TagNeg:
            return NegInf
        else:
            return PosInf
    def readInfinity(self):
        self.checkTag(HproseTags.TagInfinity)
        return self.readInfinityWithoutTag()
    def readNull(self):
        self.checkTag(HproseTags.TagNull)
        return None
    def readEmpty(self):
        self.checkTag(HproseTags.TagEmpty)
        return ''
    def readBoolean(self):
        tag = self.checkTags((HproseTags.TagTrue, HproseTags.TagFalse))
        return tag == HproseTags.TagTrue
    def readDateWithoutTag(self):
        year = int(self.stream.read(4))
        month = int(self.stream.read(2))
        day = int(self.stream.read(2))
        tag = self.stream.read(1)
        if tag == HproseTags.TagTime:
            hour = int(self.stream.read(2))
            minute = int(self.stream.read(2))
            second = int(self.stream.read(2))
            (tag, microsecond) = self.__readMicrosecond()
            if tag == HproseTags.TagUTC:
                d = datetime.datetime(year, month, day, hour, minute, second, microsecond, utc)
            else:
                d = datetime.datetime(year, month, day, hour, minute, second, microsecond)
        elif tag == HproseTags.TagUTC:
            d = datetime.datetime(year, month, day, 0, 0, 0, 0, utc)
        else:
            d = datetime.date(year, month, day)
        return d
    def readDate(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagDate: return self.readDateWithoutTag()
        self.unexpectedTag(tag)
    def readTimeWithoutTag(self):
        hour = int(self.stream.read(2))
        minute = int(self.stream.read(2))
        second = int(self.stream.read(2))
        (tag, microsecond) = self.__readMicrosecond()
        if tag == HproseTags.TagUTC:
            t = datetime.time(hour, minute, second, microsecond, utc)
        else:
            t = datetime.time(hour, minute, second, microsecond)
        return t
    def readTime(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagTime: return self.readTimeWithoutTag()
        self.unexpectedTag(tag)
    def readBytesWithoutTag(self):
        b = self.stream.read(_readint(self.stream, HproseTags.TagQuote))
        self.stream.read(1)
        return b
    def readBytes(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagBytes: return self.readBytesWithoutTag()
        self.unexpectedTag(tag)
    def readUTF8CharWithoutTag(self):
        s = []
        c = self.stream.read(1)
        s.append(c)
        a = ord(c)
        if (a & 0xE0) == 0xC0:
            s.append(self.stream.read(1))
        elif (a & 0xF0) == 0xE0:
            s.append(self.stream.read(2))
        elif a > 0x7F:
            raise HproseUnserializeException('Bad utf-8 encoding')
        return str(b''.join(s), 'utf-8')
    def readUTF8Char(self):
        self.checkTag(HproseTags.TagUTF8Char)
        self.readUTF8CharWithoutTag()
    def __readString(self):
        l = _readint(self.stream, HproseTags.TagQuote)
        s = []
        i = 0
        while i < l:
            c = self.stream.read(1)
            s.append(c)
            a = ord(c)
            if (a & 0xE0) == 0xC0:
                s.append(self.stream.read(1))
            elif (a & 0xF0) == 0xE0:
                s.append(self.stream.read(2))
            elif (a & 0xF8) == 0xF0:
                s.append(self.stream.read(3))
                i += 1
            i += 1
        self.stream.read(1)
        s = str(b''.join(s), 'utf-8')
        return s
    def readStringWithoutTag(self):
        return self.__readString()
    def readString(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagString: return self.readStringWithoutTag()
        self.unexpectedTag(tag)
    def readGuidWithoutTag(self):
        return UUID(str(self.stream.read(38), 'utf-8'))
    def readGuid(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagGuid: return self.readGuidWithoutTag()
        self.unexpectedTag(tag)
    def _readListBegin(self):
        return []
    def _readListEnd(self, list):
        c = _readint(self.stream, HproseTags.TagOpenbrace)
        for i in range(c): list.append(self.unserialize())
        self.stream.read(1)
        return list
    def readListWithoutTag(self):
        return self._readListEnd(self._readListBegin())
    def readList(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagList: return self.readListWithoutTag()
        self.unexpectedTag(tag)
    def _readMapBegin(self):
        return {}
    def _readMapEnd(self, map):
        c = _readint(self.stream, HproseTags.TagOpenbrace)
        for i in range(c):
            k = self.unserialize()
            v = self.unserialize()
            map[k] = v
        self.stream.read(1)
        return map
    def readMapWithoutTag(self):
        return self._readMapEnd(self._readMapBegin())
    def readMap(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagMap: return self.readMapWithoutTag()
        self.unexpectedTag(tag)
    def _readObjectBegin(self):
        (cls, count, fields) = self.classref[_readint(self.stream, HproseTags.TagOpenbrace)]
        obj = cls()
        return (obj, count, fields)
    def _readObjectEnd(self, obj, count, fields):
        for i in range(count): setattr(obj, fields[i], self.unserialize())
        self.stream.read(1)
        return obj
    def readObjectWithoutTag(self):
        (obj, count, fields) = self._readObjectBegin()
        return self._readObjectEnd(obj, count, fields)
    def readObject(self):
        tag = self.stream.read(1)
        if tag == HproseTags.TagRef: return self._readRef()
        if tag == HproseTags.TagObject: return self.readObjectWithoutTag()
        if tag == HproseTags.TagClass:
            self.__readClass()
            return self.readObject()
        self.unexpectedTag(tag)
    def __readClass(self):
        classname = self.__readString()
        count = _readint(self.stream, HproseTags.TagOpenbrace)
        fields = [self.readString() for i in range(count)]
        self.stream.read(1)
        cls = HproseClassManager.getClass(classname)
        self.classref.append((cls, count, fields))
    def __readRef(self):
        self.unexpectedTag(HproseTags.TagRef)
    def __readMicrosecond(self):
        microsecond = 0
        tag = self.stream.read(1)
        if tag == HproseTags.TagPoint:
            microsecond = int(self.stream.read(3)) * 1000
            tag = self.stream.read(1)
            if b'0' <= tag <= b'9':
                microsecond = microsecond + int(tag) * 100 + int(self.stream.read(2))
                tag = self.stream.read(1)
                if b'0' <= tag <= b'9':
                    self.stream.read(2)
                    tag = self.stream.read(1)
        return (tag, microsecond)
    def reset(self):
        del self.classref[:]

class HproseReader(HproseSimpleReader):
    def __init__(self, stream):
        super(HproseReader, self).__init__(stream)
        self.ref = []
    def readDateWithoutTag(self):
        d = super(HproseReader, self).readDateWithoutTag()
        self.ref.append(d)
        return d
    def readTimeWithoutTag(self):
        t = super(HproseReader, self).readTimeWithoutTag()
        self.ref.append(t)
        return t
    def readBytesWithoutTag(self):
        b = super(HproseReader, self).readBytesWithoutTag()
        self.ref.append(b)
        return b
    def readStringWithoutTag(self):
        s = super(HproseReader, self).readStringWithoutTag()
        self.ref.append(s)
        return s
    def readGuidWithoutTag(self):
        g = super(HproseReader, self).readGuidWithoutTag()
        self.ref.append(g)
        return g
    def readListWithoutTag(self):
        list = self._readListBegin()
        self.ref.append(list)
        return self._readListEnd(list)
    def readMapWithoutTag(self):
        map = self._readMapBegin()
        self.ref.append(map)
        return self._readMapEnd(map)
    def readObjectWithoutTag(self):
        (obj, count, fields) = self._readObjectBegin()
        self.ref.append(obj)
        return self._readObjectEnd(obj, count, fields)
    def _readRef(self):
        return self.ref[_readint(self.stream, HproseTags.TagSemicolon)]
    def reset(self):
        super(HproseReader, self).reset()
        del self.ref[:]

dict_items = type({}.items())
dict_keys = type({}.keys())
dict_values = type({}.values())

class HproseSimpleWriter(object):
    def __init__(self, stream):
        self.stream = stream
        self.classref = {}
        self.fieldsref = []
    def serialize(self, v):
        if v == None: self.writeNull()
        elif isinstance(v, bool): self.writeBoolean(v)
        elif isinstance(v, int): self.writeInteger(v)
        elif isinstance(v, float): self.writeDouble(v)
        elif isinstance(v, (bytes, bytearray, memoryview)): self.writeBytesWithRef(v)
        elif isinstance(v, str):
            if v == '':
                self.writeEmpty()
            elif len(v) == 1:
                self.writeUTF8Char(v)
            else:
                self.writeStringWithRef(v)
        elif isinstance(v, UUID): self.writeGuidWithRef(v)
        elif isinstance(v, (list, tuple)): self.writeListWithRef(v)
        elif isinstance(v, (dict_items, dict_keys, dict_values)): self.writeViewWithRef(v)
        elif isinstance(v, dict): self.writeMapWithRef(v)
        elif isinstance(v, (datetime.datetime, datetime.date)): self.writeDateWithRef(v)
        elif isinstance(v, datetime.time): self.writeTimeWithRef(v)
        elif isinstance(v, object): self.writeObjectWithRef(v)
        else: raise HproseSerializeException('Not support to serialize this data')
    def writeInteger(self, i):
        if 0 <= i <= 9:
            self.stream.write(str(i).encode('utf-8'))
        elif -2147483648 <= i <= 2147483647:
            self.stream.write(HproseTags.TagInteger)
            self.stream.write(str(i).encode('utf-8'))
            self.stream.write(HproseTags.TagSemicolon)
        else:
            self.writeLong(i)
    def writeLong(self, l):
        self.stream.write(HproseTags.TagLong)
        self.stream.write(str(l).encode('utf-8'))
        self.stream.write(HproseTags.TagSemicolon)
    def writeDouble(self, d):
        if isNaN(d): self.writeNaN()
        elif isInf(d): self.writeInfinity(isPosInf(d))
        else:
            self.stream.write(HproseTags.TagDouble)
            self.stream.write(str(d).encode('utf-8'))
            self.stream.write(HproseTags.TagSemicolon)
    def writeNaN(self):
        self.stream.write(HproseTags.TagNaN)
    def writeInfinity(self, positive = True):
        self.stream.write(HproseTags.TagInfinity)
        if positive:
            self.stream.write(HproseTags.TagPos)
        else:
            self.stream.write(HproseTags.TagNeg)
    def writeNull(self):
        self.stream.write(HproseTags.TagNull)
    def writeEmpty(self):
        self.stream.write(HproseTags.TagEmpty)
    def writeBoolean(self, b):
        if b:
            self.stream.write(HproseTags.TagTrue)
        else:
            self.stream.write(HproseTags.TagFalse)
    def writeDate(self, date):
        if isinstance(date, datetime.datetime):
            if (date.utcoffset() != ZERO) and (date.utcoffset() != None):
                date = date.astimezone(utc)
            if date.hour == 0 and date.minute == 0 and date.second == 0 and date.microsecond == 0:
                format = '%c%s' % (str(HproseTags.TagDate, 'utf-8'), '%Y%m%d')
            elif date.year == 1970 and date.month == 1 and date.day == 1:
                format = '%c%s' % (str(HproseTags.TagTime, 'utf-8'), '%H%M%S')
            else:
                format = '%c%s%c%s' % (str(HproseTags.TagDate, 'utf-8'), '%Y%m%d',
                                       str(HproseTags.TagTime, 'utf-8'), '%H%M%S')
            if date.microsecond > 0:
                format = '%s%c%s' % (format, str(HproseTags.TagPoint, 'utf-8'), '%f')
            if date.utcoffset() == ZERO:
                format = '%s%c' % (format, str(HproseTags.TagUTC, 'utf-8'))
            else:
                format = '%s%c' % (format, str(HproseTags.TagSemicolon, 'utf-8'))
        else:
            format = '%c%s%c' % (str(HproseTags.TagDate, 'utf-8'),
                                 '%Y%m%d',
                                 str(HproseTags.TagSemicolon, 'utf-8'))
        self.stream.write(date.strftime(format).encode('utf-8'))
    def writeDateWithRef(self, date):
        if not self._writeRef(date): self.writeDate(date)
    def writeTime(self, time):
        format = '%c%s' % (str(HproseTags.TagTime, 'utf-8'), '%H%M%S')
        if time.microsecond > 0:
            format = '%s%c%s' % (format, str(HproseTags.TagPoint, 'utf-8'), '%f')
        if time.utcoffset() == ZERO:
            format = '%s%c' % (format, str(HproseTags.TagUTC, 'utf-8'))
        else:
            format = '%s%c' % (format, str(HproseTags.TagSemicolon, 'utf-8'))
        self.stream.write(time.strftime(format).encode('utf-8'))
    def writeTimeWithRef(self, time):
        if not self._writeRef(time): self.writeTime(time)
    def writeBytes(self, bytes):
        length = len(bytes)
        self.stream.write(HproseTags.TagBytes)
        if length > 0: self.stream.write(str(length).encode('utf-8'))
        self.stream.write(HproseTags.TagQuote)
        if length > 0: self.stream.write(bytes)
        self.stream.write(HproseTags.TagQuote)
    def writeBytesWithRef(self, bytes):
        if not self._writeRef(bytes): self.writeBytes(bytes)
    def writeUTF8Char(self, u):
        self.stream.write(HproseTags.TagUTF8Char)
        self.stream.write(u.encode('utf-8'))
    def writeString(self, s):
        length = len(s)
        if length == 0:
            self.stream.write(('%s%s%s' % (str(HproseTags.TagString, 'utf-8'),
                                           str(HproseTags.TagQuote, 'utf-8'),
                                           str(HproseTags.TagQuote, 'utf-8'))).encode('utf-8'))
        else:
            self.stream.write(('%s%d%s%s%s' % (str(HproseTags.TagString, 'utf-8'),
                                               length,
                                               str(HproseTags.TagQuote, 'utf-8'),
                                               s,
                                               str(HproseTags.TagQuote, 'utf-8'))).encode('utf-8'))
    def writeStringWithRef(self, s):
        if not self._writeRef(s): self.writeString(s)
    def writeGuid(self, guid):
        self.stream.write(HproseTags.TagGuid)
        self.stream.write(HproseTags.TagOpenbrace)
        self.stream.write(str(guid).encode('utf-8'))
        self.stream.write(HproseTags.TagClosebrace)
    def writeGuidWithRef(self, guid):
        if not self._writeRef(guid): self.writeGuid(guid)
    def writeList(self, list):
        count = len(list)
        self.stream.write(HproseTags.TagList)
        if count > 0: self.stream.write(str(count).encode('utf-8'))
        self.stream.write(HproseTags.TagOpenbrace)
        for i in range(count): self.serialize(list[i])
        self.stream.write(HproseTags.TagClosebrace)
    def writeListWithRef(self, list):
        if not self._writeRef(list): self.writeList(list)
    def writeView(self, view):
        count = len(view)
        self.stream.write(HproseTags.TagList)
        if count > 0: self.stream.write(str(count).encode('utf-8'))
        self.stream.write(HproseTags.TagOpenbrace)
        for v in view: self.serialize(v)
        self.stream.write(HproseTags.TagClosebrace)
    def writeViewWithRef(self, view):
        if not self._writeRef(view): self.writeView(view)
    def writeMap(self, map):
        count = len(map)
        self.stream.write(HproseTags.TagMap)
        if count > 0: self.stream.write(str(count).encode('utf-8'))
        self.stream.write(HproseTags.TagOpenbrace)
        for key in map:
            self.serialize(key)
            self.serialize(map[key])
        self.stream.write(HproseTags.TagClosebrace)
    def writeMapWithRef(self, map):
        if not self._writeRef(map): self.writeMap(map)
    def _writeObjectBegin(self, obj):
        classname = HproseClassManager.getClassAlias(obj.__class__)
        if classname in self.classref:
            index = self.classref[classname]
            fields = self.fieldsref[index]
        else:
            data = vars(obj)
            fields = tuple(data.keys())
            index = self.__writeClass(classname, fields)
        self.stream.write(HproseTags.TagObject)
        self.stream.write(str(index).encode('utf-8'))
        self.stream.write(HproseTags.TagOpenbrace)
        return fields
    def _writeObjectEnd(self, obj, fields):
        data = vars(obj)
        count = len(fields)
        for i in range(count):
            self.serialize(data[fields[i]])
        self.stream.write(HproseTags.TagClosebrace)
    def writeObject(self, obj):
        self._writeObjectEnd(obj, self._writeObjectBegin(obj))
    def writeObjectWithRef(self, obj):
        if not self._writeRef(obj): self.writeObject(obj)
    def __writeClass(self, classname, fields):
        count = len(fields)
        self.stream.write(HproseTags.TagClass)
        self.stream.write(str(len(classname)).encode('utf-8'))
        self.stream.write(HproseTags.TagQuote)
        self.stream.write(classname.encode('utf-8'))
        self.stream.write(HproseTags.TagQuote)
        if count > 0: self.stream.write(str(count).encode('utf-8'))
        self.stream.write(HproseTags.TagOpenbrace)
        for i in range(count):
            field = fields[i]
            self.writeString(field)
        self.stream.write(HproseTags.TagClosebrace)
        index = len(self.fieldsref)
        self.fieldsref.append(fields)
        self.classref[classname] = index
        return index
    def _writeRef(self, obj):
        return False
    def reset(self):
        self.classref.clear()
        del self.fieldsref[:]

class HproseWriter(HproseSimpleWriter):
    def __init__(self, stream):
        super(HproseWriter, self).__init__(stream)
        self.ref = {}
        self.refcount = 0
    def writeDate(self, date):
        self.ref[id(date)] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeDate(date)
    def writeTime(self, time):
        self.ref[id(time)] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeTime(time)
    def writeBytes(self, bytes):
        self.ref[bytes] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeBytes(bytes)
    def writeString(self, s):
        self.ref[s] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeString(s)
    def writeGuid(self, guid):
        self.ref[id(guid)] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeGuid(guid)
    def writeList(self, list):
        self.ref[id(list)] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeList(list)
    def writeView(self, view):
        self.ref[id(view)] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeView(view)
    def writeMap(self, map):
        self.ref[id(map)] = self.refcount
        self.refcount += 1
        super(HproseWriter, self).writeMap(map)
    def writeObject(self, obj):
        fields = self._writeObjectBegin(obj)
        self.ref[id(obj)] = self.refcount
        self.refcount += 1
        self._writeObjectEnd(obj, fields)
    def _writeRef(self, obj):
        if isinstance(obj, (bytes, bytearray, str)):
            objid = obj
        else:
            objid = id(obj)
        if (objid in self.ref):
            self.stream.write(HproseTags.TagRef)
            self.stream.write(str(self.ref[objid]).encode('utf-8'))
            self.stream.write(HproseTags.TagSemicolon)
            return True
        return False
    def reset(self):
        super(HproseWriter, self).reset()
        self.ref.clear()
        self.refcount = 0

class HproseFormatter:
    def serialize(v, simple):
        stream = BytesIO()
        writer = HproseSimpleWriter(stream) if simple else HproseWriter(stream)
        writer.serialize(v)
        return stream.getvalue()
    serialize = staticmethod(serialize)

    def unserialize(s, simple):
        stream = BytesIO(s)
        reader = HproseSimpleReader(stream) if simple else HproseReader(stream)
        return reader.unserialize()
    unserialize = staticmethod(unserialize)

