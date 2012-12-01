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
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

from io import BytesIO
from calendar import timegm
import datetime
from fpconst import NaN, PosInf, NegInf, isInf, isNaN, isPosInf
from inspect import isclass
from sys import modules, exc_info
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

class HproseReader:
    def __init__(self, stream):
        self.stream = stream
        self.classref = []
        self.ref = []
    def unserialize(self, tag = None):
        if tag == None:
            tag = self.stream.read(1)
        if b'0' <= tag <= b'9':
            return int(tag);
        if tag == HproseTags.TagInteger:
            return self.readInteger(False)
        if tag == HproseTags.TagLong:
            return self.readLong(False)
        if tag == HproseTags.TagDouble:
            return self.readDouble(False)
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
            return self.readInfinity(False)
        if tag == HproseTags.TagDate:
            return self.readDate(False)
        if tag == HproseTags.TagTime:
            return self.readTime(False)
        if tag == HproseTags.TagBytes:
            return self.readBytes(False)
        if tag == HproseTags.TagUTF8Char:
            return self.readUTF8Char(False)
        if tag == HproseTags.TagString:
            return self.readString(False)
        if tag == HproseTags.TagGuid:
            return self.readGuid(False)
        if tag == HproseTags.TagList:
            return self.readList(False)
        if tag == HproseTags.TagMap:
            return self.readMap(False)
        if tag == HproseTags.TagClass:
            self.__readClass()
            return self.unserialize()
        if tag == HproseTags.TagObject:
            return self.readObject(False)
        if tag == HproseTags.TagRef:
            return self.__readRef()
        if tag == HproseTags.TagError:
            raise HproseException(self.readstring())
        if tag == b'':
            raise HproseUnserializeException('No byte found in stream')
        raise HproseUnserializeException(
            "Unexpected serialize tag '%s' in stream" %
            str(tag, 'utf-8'))
    def checkTag(self, expectTag):
        tag = self.stream.read(1)
        if tag != expectTag:
            raise HproseUnserializeException(
                "Tag '%s' expected, but '%s' found in stream" %
                (str(expectTag, 'utf-8'), str(tag, 'utf-8')))
    def checkTags(self, expectTags):
        tag = self.stream.read(1)
        if tag not in expectTags:
            raise HproseUnserializeException(
                "Tags '%s' expected, but '%s' found in stream" %
                (str(b''.join(expectTags), 'utf-8'), str(tag, 'utf-8')))
        return tag
    def readInteger(self, includeTag = True):
        if includeTag:
            self.checkTag(HproseTags.TagInteger)
        return int(_readuntil(self.stream, HproseTags.TagSemicolon))
    def readLong(self, includeTag = True):
        if includeTag:
            self.checkTag(HproseTags.TagLong)
        return int(_readuntil(self.stream, HproseTags.TagSemicolon))
    def readDouble(self, includeTag = True):
        if includeTag:
            self.checkTag(HproseTags.TagDouble)
        return float(_readuntil(self.stream, HproseTags.TagSemicolon))
    def readNaN(self):
        self.checkTag(HproseTags.TagNaN)
        return NaN
    def readInfinity(self, includeTag = True):
        if includeTag:
            self.checkTag(HproseTags.TagInfinity)
        if self.stream.read(1) == HproseTags.TagNeg:
            return NegInf
        else:
            return PosInf
    def readNull(self):
        self.checkTag(HproseTags.TagNull)
        return None
    def readEmpty(self):
        self.checkTag(HproseTags.TagEmpty)
        return ''
    def readBoolean(self):
        tag = self.checkTags((HproseTags.TagTrue, HproseTags.TagFalse))
        return tag == HproseTags.TagTrue
    def readDate(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagDate, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
        year = int(self.stream.read(4))
        month = int(self.stream.read(2))
        day = int(self.stream.read(2))
        if self.stream.read(1) == HproseTags.TagTime:
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
        self.ref.append(d)
        return d
    def readTime(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagTime, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
        hour = int(self.stream.read(2))
        minute = int(self.stream.read(2))
        second = int(self.stream.read(2))
        (tag, microsecond) = self.__readMicrosecond()
        if tag == HproseTags.TagUTC:
            t = datetime.time(hour, minute, second, microsecond, utc)
        else:
            t = datetime.time(hour, minute, second, microsecond)
        self.ref.append(t)
        return t
    def readBytes(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagBytes, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
        s = self.stream.read(_readint(self.stream, HproseTags.TagQuote))
        self.stream.read(1)
        self.ref.append(s)
        return s
    def readUTF8Char(self, includeTag = True):
        if includeTag:
            tag = self.checkTag(HproseTags.TagUTF8Char)
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
    def readString(self, includeTag = True, includeRef = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagString, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
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
        if includeRef: self.ref.append(s)
        return s
    def readGuid(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagGuid, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
        g = UUID(str(self.stream.read(38), 'utf-8'))
        self.ref.append(s)
        return s
    def readList(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagList, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
        a = []
        self.ref.append(a)
        c = _readint(self.stream, HproseTags.TagOpenbrace)
        for i in range(c): a.append(self.unserialize())
        self.stream.read(1)
        return a
    def readMap(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagMap, HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
        m = {}
        self.ref.append(m)
        c = _readint(self.stream, HproseTags.TagOpenbrace)
        for i in range(c):
            k = self.unserialize()
            v = self.unserialize()
            m[k] = v
        self.stream.read(1)
        return m
    def readObject(self, includeTag = True):
        if includeTag:
            tag = self.checkTags((HproseTags.TagClass,
                                  HproseTags.TagObject,
                                  HproseTags.TagRef))
            if tag == HproseTags.TagRef: return self.__readRef()
            if tag == HproseTags.TagClass:
                self.__readClass()
                return self.readObject()
        (cls, count, fields) = self.classref[_readint(self.stream, HproseTags.TagOpenbrace)]
        o = cls()
        self.ref.append(o)
        for i in range(count): setattr(o, fields[i], self.unserialize())
        self.stream.read(1)
        return o
    def __readClass(self):
        classname = self.readString(False, False)
        count = _readint(self.stream, HproseTags.TagOpenbrace)
        fields = [self.readString() for i in range(count)]
        self.stream.read(1)
        cls = HproseClassManager.getClass(classname)
        self.classref.append((cls, count, fields))
    def __readRef(self):
        return self.ref[_readint(self.stream, HproseTags.TagSemicolon)]
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
    def readRaw(self, ostream = None, tag = None):
        if ostream == None:
            ostream = BytesIO()
        if tag == None:
            tag = self.stream.read(1)
        if ((b'0' <= tag <= b'9') or
            (tag == HproseTags.TagNull) or
            (tag == HproseTags.TagEmpty) or
            (tag == HproseTags.TagTrue) or
            (tag == HproseTags.TagFalse) or
            (tag == HproseTags.TagNaN)):
            ostream.write(tag)
        elif tag == HproseTags.TagInfinity:
            ostream.write(tag)
            ostream.write(self.stream.read(1))
        elif ((tag == HproseTags.TagInteger) or
            (tag == HproseTags.TagLong) or
            (tag == HproseTags.TagDouble) or
            (tag == HproseTags.TagRef)):
            self.__readNumberRaw(ostream, tag)
        elif ((tag == HproseTags.TagDate) or
            (tag == HproseTags.TagTime)):
            self.__readDateTimeRaw(ostream, tag)
        elif (tag == HproseTags.TagUTF8Char):
            self.__readUTF8CharRaw(ostream, tag)
        elif (tag == HproseTags.TagBytes):
            self.__readBytesRaw(ostream, tag)
        elif (tag == HproseTags.TagString):
            self.__readStringRaw(ostream, tag)
        elif (tag == HproseTags.TagGuid):
            self.__readGuidRaw(ostream, tag)
        elif ((tag == HproseTags.TagList) or
            (tag == HproseTags.TagMap) or
            (tag == HproseTags.TagObject)):
            self.__readComplexRaw(ostream, tag)
        elif (tag == HproseTags.TagClass):
            self.__readComplexRaw(ostream, tag)
            self.readRaw(ostream)
        elif (tag == HproseTags.TagError):
            ostream.write(tag)
            self.readRaw(ostream)
        elif tag == b'':
            raise HproseUnserializeException('No byte found in stream')
        else:
            raise HproseUnserializeException(
                "Unexpected serialize tag '%s' in stream" %
                str(tag, 'utf-8'))
        return ostream
    def __readNumberRaw(self, ostream, tag):
        ostream.write(tag)
        ostream.write(_readuntil(self.stream, HproseTags.TagSemicolon))
        ostream.write(HproseTags.TagSemicolon)
    def __readDateTimeRaw(self, ostream, tag):
        s = [tag]
        while True:
            c = stream.read(1)
            s.append(c)
            if ((c == HproseTags.TagSemicolon) or
                (c == HproseTags.TagUTC)): break
        ostream.write(b''.join(s))
    def __readUTF8CharRaw(self, ostream, tag):
        s = [tag]
        c = self.stream.read(1)
        s.append(c)
        a = ord(c)
        if (a & 0xE0) == 0xC0:
            s.append(self.stream.read(1))
        elif (a & 0xF0) == 0xE0:
            s.append(self.stream.read(2))
        elif a > 0x7F:
            raise HproseException, 'Bad utf-8 encoding'
        ostream.write(b''.join(s))

    def __readBytesRaw(self, ostream, tag):
        l = _readuntil(self.stream, HproseTags.TagQuote)
        ostream.write(tag)
        ostream.write(l)
        ostream.write(HproseTags.TagQuote)
        if l == b'':
            l = 0
        else:
            l = int(l)
        ostream.write(self.stream.read(l + 1))

    def __readStringRaw(self, ostream, tag):
        l = _readuntil(self.stream, HproseTags.TagQuote)
        ostream.write(tag)
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
    def __readGuidRaw(self, ostream, tag):
        ostream.write(tag)
        ostream.write(self.stream.read(38))
    def __readComplexRaw(self, ostream, tag):
        ostream.write(tag)
        ostream.write(_readuntil(self.stream, HproseTags.TagOpenbrace))
        ostream.write(HproseTags.TagOpenbrace)
        tag = self.stream.read(1)
        while tag != HproseTags.TagClosebrace:
            self.readRaw(ostream, tag)
            tag = self.stream.read(1)
        ostream.write(tag)
    def reset(self):
        del self.classref[:]
        del self.ref[:]

class HproseWriter:
    def __init__(self, stream):
        self.stream = stream
        self.classref = {}
        self.ref = {}
    def serialize(self, v):
        if v == None: self.writeNull()
        elif isinstance(v, bool): self.writeBoolean(v)
        elif isinstance(v, int): self.writeInteger(v)
        elif isinstance(v, float): self.writeDouble(v)
        elif isinstance(v, (bytes, bytearray)):
            if v == b'':
                self.writeEmpty()
            else:
                self.writeBytes(v)
        elif isinstance(v, str):
            if v == '':
                self.writeEmpty()
            elif len(v) == 1:
                self.writeUTF8Char(v)
            else:
                self.writeString(v)
        elif isinstance(v, UUID): self.writeGuid(v)
        elif isinstance(v, (list, tuple)): self.writeList(v)
        elif isinstance(v, dict): self.writeMap(v)
        elif isinstance(v, (datetime, date)): self.writeDate(v)
        elif isinstance(v, time): self.writeTime(v)
        elif isinstance(v, object): self.writeObject(v)
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
    def writeDate(self, d, checkRef = True):
        if isinstance(d, datetime):
            if (d.utcoffset() != ZERO) and (d.utcoffset() != None):
                d = d.astimezone(utc)
            if (d.hour == 0) and (d.minute == 0) and (d.second == 0) and (d.microsecond == 0):
                format = '%c%s' % (str(HproseTags.TagDate, 'utf-8'), '%Y%m%d')
            elif (d.year == 1970) and (d.month == 1) and (d.day == 1):
                format = '%c%s' % (str(HproseTags.TagTime, 'utf-8'), '%H%M%S')
            else:
                format = '%c%s%c%s' % (str(HproseTags.TagDate, 'utf-8'), '%Y%m%d',
                                       str(HproseTags.TagTime, 'utf-8'), '%H%M%S')
            if d.microsecond > 0:                
                format = '%s%c%s' % (format, str(HproseTags.TagPoint, 'utf-8'), '%f')
            if d.utcoffset() == ZERO:
                format = '%s%c' % (format, str(HproseTags.TagUTC, 'utf-8'))
            else:
                format = '%s%c' % (format, str(HproseTags.TagSemicolon, 'utf-8'))
        else:
            format = '%c%s%c' % (HproseTags.TagDate, '%Y%m%d', str(HproseTags.TagSemicolon, 'utf-8'))            
        s = d.strftime(format)            
        if checkRef and (s in self.ref):
            self.__writeRef(self.ref[s])
        else:
            self.ref[s] = len(self.ref)
            self.stream.write(s.encode('utf-8'))
    def writeTime(self, t, checkRef = True):
        format = '%c%s' % (str(HproseTags.TagTime, 'utf-8'), '%H%M%S')
        if d.microsecond > 0:                
            format = '%s%c%s' % (format, str(HproseTags.TagPoint, 'utf-8'), '%f')        
        if t.utcoffset() == ZERO:
            format = '%s%c' % (format, str(HproseTags.TagUTC, 'utf-8'))
        else:
            format = '%s%c' % (format, str(HproseTags.TagSemicolon, 'utf-8'))        
        s = t.strftime(format)
        if checkRef and (s in self.ref):
            self.__writeRef(self.ref[s])
        else:
            self.ref[s] = len(self.ref)
            self.stream.write(s.encode('utf-8'))
    def writeBytes(self, s, checkRef = True):
        if checkRef and (s in self.ref):
            self.__writeRef(self.ref[s])
        else:
            self.ref[s] = len(self.ref)
            l = len(s)
            self.stream.write(HproseTags.TagBytes)
            if l > 0: self.stream.write(str(len(s)).encode('utf-8'))
            self.stream.write(HproseTags.TagQuote)
            if l > 0: self.stream.write(s)
            self.stream.write(HproseTags.TagQuote)
    def writeUTF8Char(self, u):
        self.stream.write(HproseTags.TagUTF8Char)
        self.stream.write(u.encode('utf-8'))
    def writeString(self, u, checkRef = True):
        l = len(u)
        if l == 0:
            u = '%s%s%s' % (str(HproseTags.TagString, 'utf-8'),
                            str(HproseTags.TagQuote, 'utf-8'),
                            str(HproseTags.TagQuote, 'utf-8'))
        else:
            u = '%s%d%s%s%s' % (str(HproseTags.TagString, 'utf-8'),
                                len(u),
                                str(HproseTags.TagQuote, 'utf-8'),
                                u,
                                str(HproseTags.TagQuote, 'utf-8'))
        if checkRef and (u in self.ref):
            self.__writeRef(self.ref[u])
        else:
            self.ref[u] = len(self.ref)
            self.stream.write(u.encode('utf-8'))
    def writeGuid(self, g, checkRef = True):
        gid = id(g)
        if checkRef and (gid in self.ref):
            self.__writeRef(self.ref[gid])
        else:
            self.ref[gid] = len(self.ref)
            self.stream.write(HproseTags.TagGuid)
            self.stream.write(HproseTags.TagOpenbrace)
            self.stream.write(str(g).encode('utf-8'))
            self.stream.write(HproseTags.TagClosebrace)
    def writeList(self, l, checkRef = True):
        listid = id(l)
        if checkRef and (listid in self.ref):
            self.__writeRef(self.ref[listid])
        else:
            self.ref[listid] = len(self.ref)
            count = len(l)
            self.stream.write(HproseTags.TagList)
            if count > 0: self.stream.write(str(count).encode('utf-8'))
            self.stream.write(HproseTags.TagOpenbrace)
            for i in range(count): self.serialize(l[i])
            self.stream.write(HproseTags.TagClosebrace)
    def writeMap(self, m, checkRef = True):
        mapid = id(m)
        if checkRef and (mapid in self.ref):
            self.__writeRef(self.ref[mapid])
        else:
            self.ref[mapid] = len(self.ref)
            count = len(m)
            self.stream.write(HproseTags.TagMap)
            if count > 0: self.stream.write(str(count).encode('utf-8'))
            self.stream.write(HproseTags.TagOpenbrace)
            for k in m:
                self.serialize(k)
                self.serialize(m[k])
            self.stream.write(HproseTags.TagClosebrace)
    def writeObject(self, o, checkRef = True):
        objid = id(o)
        if checkRef and (objid in self.ref):
            self.__writeRef(self.ref[objid])
        else:
            classname = HproseClassManager.getClassAlias(o.__class__)
            data = vars(o)
            fields = tuple(data.keys())
            count = len(fields)
            cls = (classname, count, fields)
            classref = self.classref[cls] if cls in self.classref else self.__writeClass(cls)
            self.ref[objid] = len(self.ref)
            self.stream.write(HproseTags.TagObject)
            self.stream.write(str(classref).encode('utf-8'))
            self.stream.write(HproseTags.TagOpenbrace)
            for i in range(count):
                self.serialize(data[fields[i]])
            self.stream.write(HproseTags.TagClosebrace)
    def __writeClass(self, c):
        (classname, count, fields) = c
        l = len(classname)
        self.stream.write(HproseTags.TagClass)
        self.stream.write(str(l).encode('utf-8'))
        self.stream.write(HproseTags.TagQuote)
        self.stream.write(classname.encode('utf-8'))
        self.stream.write(HproseTags.TagQuote)
        if count > 0: self.stream.write(str(count).encode('utf-8'))
        self.stream.write(HproseTags.TagOpenbrace)
        for i in range(count):
            field = fields[i]
            self.writeString(field)
        self.stream.write(HproseTags.TagClosebrace)
        classref = len(self.classref)
        self.classref[c] = classref
        return classref
    def __writeRef(self, ref):
        self.stream.write(HproseTags.TagRef)
        self.stream.write(str(ref).encode('utf-8'))
        self.stream.write(HproseTags.TagSemicolon)
    def reset(self):
        self.classref.clear()
        self.ref.clear()

class HproseFormatter:
    def serialize(v):
        stream = BytesIO()
        hproseWriter = HproseWriter(stream)
        hproseWriter.serialize(v)
        return stream.getvalue()
    serialize = staticmethod(serialize)

    def unserialize(s):
        stream = BytesIO(s)
        hproseReader = HproseReader(stream)
        return hproseReader.unserialize()
    unserialize = staticmethod(unserialize)

