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
# hprose/io.rb                                             #
#                                                          #
# hprose io stream library for ruby                        #
#                                                          #
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require 'stringio'
require "thread"
require "hprose/common"

class String
  def utf8?
    return false if unpack('U*').find { |e| e > 0x10ffff } rescue return false
    true
  end
  def ulength
    (a = unpack('U*')) rescue return -1
    return -1 if a.find { |e| e > 0x10ffff }
    a.size + a.find_all { |e| e > 0xffff }.size
  end
  alias usize ulength
end

module Hprose
  module Tags
    # Serialize Tags
    TagInteger = ?i.ord
    TagLong = ?l.ord
    TagDouble = ?d.ord
    TagNull = ?n.ord
    TagEmpty = ?e.ord
    TagTrue = ?t.ord
    TagFalse = ?f.ord
    TagNaN = ?N.ord
    TagInfinity = ?I.ord
    TagDate = ?D.ord
    TagTime = ?T.ord
    TagUTC = ?Z.ord
    TagBytes = ?b.ord
    TagUTF8Char = ?u.ord
    TagString = ?s.ord
    TagGuid = ?g.ord
    TagList = ?a.ord
    TagMap = ?m.ord
    TagClass = ?c.ord
    TagObject = ?o.ord
    TagRef = ?r.ord
    # Serialize Marks
    TagPos = ?+.ord
    TagNeg = ?-.ord
    TagSemicolon = ?;.ord
    TagOpenbrace = ?{.ord
    TagClosebrace = ?}.ord
    TagQuote = ?".ord
    TagPoint = ?..ord
    # Protocol Tags
    TagFunctions = ?F.ord
    TagCall = ?C.ord
    TagResult = ?R.ord
    TagArgument = ?A.ord
    TagError = ?E.ord
    TagEnd = ?z.ord
    # Number Tags
    TagZero = ?0.ord
    TagNine = ?9.ord
  end # module Tags

  module Stream
    def readuntil(stream, char)
      s = StringIO.new()
      while true do
        c = stream.getbyte()
        break if c.nil? or (c == char)
        s.putc(c)
      end
      result = s.string()
      s.close()
      return result
    end
    def readint(stream, char)
      s = readuntil(stream, char)
      return 0 if s == ''
      return s.to_i
    end
  end # module Stream

  class ClassManager
    class << self
      private
      @@class_cache1 = {}
      @@class_cache2 = {}
      @@class_cache_lock = Mutex.new
      def get_class(name)
        name.split('.').inject(Object) {|x, y| x.const_get(y) } rescue return nil
      end
      def get_class2(name, ps, i, c)
        if i < ps.size then
          p = ps[i]
          name[p] = c
          cls = get_class2(name, ps, i + 1, '.')
          if (i + 1 < ps.size) and (cls.nil?) then
            cls = get_class2(name, ps, i + 1, '_')
          end
          return cls
        else
          return get_class(name)
        end
      end
      def get_class_by_alias(name)
        cls = nil
        if cls.nil? then
          ps = []
          p = name.index('_')
          while not p.nil?
            ps.push(p)
            p = name.index('_', p + 1)
          end
          cls = get_class2(name, ps, 0, '.')
          if cls.nil? then
            cls = get_class2(name, ps, 0, '_')
          end
        end
        if cls.nil? then
          return Object.const_set(name.to_sym, Class.new)
        else
          return cls
        end
      end
      public
      def register(cls, aliasname)
        @@class_cache_lock.synchronize do
            @@class_cache1[cls] = aliasname
            @@class_cache2[aliasname] = cls
        end
      end
            
      def getClass(aliasname)
        return @@class_cache2[aliasname] if @@class_cache2.key?(aliasname)
        cls = get_class_by_alias(aliasname)
        register(cls, aliasname)
        return cls
      end

      def getClassAlias(cls)
        return @@class_cache1[cls] if @@class_cache1.key?(cls)
        if cls == Struct then
          aliasname = cls.to_s
          aliasname['Struct::'] = '' if not aliasname['Struct::'].nil?
        else
          aliasname = cls.to_s.split('::').join('_')
        end
        register(cls, aliasname)
        return aliasname
      end
    end
  end

  class Reader
    private
    include Tags
    include Stream
    def read_ref()
      return @ref[readint(@stream, TagSemicolon)]
    end
    def read_class()
      cls = ClassManager.getClass(read_string(false, false))
      count = readint(@stream, TagOpenbrace)
      fields = Array.new(count) { read_string() }
      @stream.getbyte()
      @classref << [cls, count, fields]
    end
    def read_usec()
      usec = 0
      tag = @stream.getbyte()
      if tag == TagPoint then
        usec = @stream.read(3).to_i * 1000
        tag = @stream.getbyte()
        if (TagZero..TagNine) === tag then
          usec = usec + (tag << @stream.read(2)).to_i
          tag = @stream.getbyte()
          if (TagZero..TagNine) === tag then
            @stream.read(2)
            tag = @stream.getbyte()
          end
        end
      end
      return tag, usec
    end
    def read_number_raw(ostream, tag)
      ostream.putc(tag)
      ostream.write(readuntil(@stream, TagSemicolon))
      ostream.putc(TagSemicolon)
    end
    def read_datetime_raw(ostream, tag)
      ostream.putc(tag)
      while true
        c = @stream.getbyte()
        ostream.putc(c)
        break if (c == TagSemicolon) or (c == TagUTC)
      end
    end
    def read_utf8char_raw(ostream, tag)
      ostream.putc(tag)
      c = @stream.getbyte()
      ostream.putc(c)
      if (c & 0xE0) == 0xC0 then
        ostream.putc(@stream.getbyte())
      elsif (c & 0xF0) == 0xE0 then
        ostream.write(@stream.read(2))
      elsif c > 0x7F then
        raise HproseException, 'Bad utf-8 encoding'
      end
    end
    def read_bytes_raw(ostream, tag)
      count = readuntil(@stream, TagQuote)
      ostream.putc(tag)
      ostream.write(count)
      ostream.putc(TagQuote)
      count = ((count == '') ? 0 : count.to_i)
      ostream.write(@stream.read(count + 1))
    end
    def read_string_raw(ostream, tag)
      count = readuntil(@stream, TagQuote)
      ostream.putc(tag)
      ostream.write(count)
      ostream.putc(TagQuote)
      count = ((count == '') ? 0 : count.to_i)
      i = 0
      while i < count
        c = @stream.getbyte()
        ostream.putc(c)
        if (c & 0xE0) == 0xC0 then
          ostream.putc(@stream.getbyte())
        elsif (c & 0xF0) == 0xE0 then
          ostream.write(@stream.read(2))
        elsif (c & 0xF8) == 0xF0 then
          ostream.write(@stream.read(3))
          i += 1
        end
        i += 1
      end
      ostream.putc(@stream.getbyte())
    end
    def read_guid_raw(ostream, tag)
      ostream.putc(tag)
      ostream.write(@stream.read(38))
    end
    def read_complex_raw(ostream, tag)
      ostream.putc(tag)
      ostream.write(readuntil(@stream, TagOpenbrace))
      ostream.write(TagOpenbrace)
      tag = @stream.getbyte()
      while tag != TagClosebrace
        read_raw(ostream, tag)
        tag = @stream.getbyte()
      end
      ostream.putc(tag)
    end
    public
    def initialize(stream)
      @stream = stream
      @classref = []
      @ref = []
    end
    attr_accessor :stream
    def unserialize(tag = nil)
      tag = @stream.getbyte() if tag.nil?
      return case tag
      when TagZero..TagNine then tag - TagZero
      when TagInteger then read_integer(false)
      when TagLong then read_long(false)
      when TagDouble then read_double(false)
      when TagNull then nil
      when TagEmpty then ""
      when TagTrue then true
      when TagFalse then false
      when TagNaN then 0.0/0.0
      when TagInfinity then read_infinity(false)
      when TagDate then read_date(false)
      when TagTime then read_time(false)
      when TagBytes then read_bytes(false)
      when TagUTF8Char then read_utf8char(false)
      when TagString then read_string(false)
      when TagGuid then read_guid(false)
      when TagList then read_list(false)
      when TagMap then read_map(false)
      when TagClass then read_class(); unserialize()
      when TagObject then read_object(false)
      when TagRef then read_ref()
      when TagError then raise Exception, read_string()
      when nil then raise Exception, "No byte found in stream"
      else raise Exception, "Unexpected serialize tag '#{tag.chr}' in stream"
      end
    end
    def check_tag(expect_tag)
      tag = @stream.getbyte()
      raise Exception, "No byte found in stream" if tag.nil?
      raise Exception, "Tag '#{expect_tag.chr}' expected, but '#{tag.chr}' found in stream" if tag != expect_tag
    end
    def check_tags(expect_tags)
      tag = @stream.getbyte()
      raise Exception, "No byte found in stream" if tag.nil?
      raise Exception, "Tag '#{expect_tags.pack('c*')}' expected, but '#{tag.chr}' found in stream" if not expect_tags.include?(tag)
      return tag
    end
    def read_integer(include_tag = true)
      check_tag(TagInteger) if include_tag
      return readuntil(@stream, TagSemicolon).to_i
    end
    def read_long(include_tag = true)
      check_tag(TagLong) if include_tag
      return readuntil(@stream, TagSemicolon).to_i
    end
    def read_double(include_tag = true)
      check_tag(TagDouble) if include_tag
      return readuntil(@stream, TagSemicolon).to_f
    end
    def read_nan()
      check_tag(TagNaN)
      return 0.0/0.0
    end
    def read_infinity(include_tag = true)
      check_tag(TagInfinity) if (include_tag)
      return (@stream.getbyte() == TagPos) ? 1.0/0.0 : -1.0/0.0
    end
    def read_null()
      check_tag(TagNull)
      return nil
    end
    def read_empty()
      check_tag(TagEmpty)
      return ""
    end
    def read_boolean()
      tag = check_tags([TagTrue, TagFalse])
      return tag == TagTrue
    end
    def read_date(include_tag = true)
      if include_tag then
        tag = check_tags([TagDate, TagRef])
        return read_ref() if tag == TagRef
      end
      year = @stream.read(4).to_i
      month = @stream.read(2).to_i
      day = @stream.read(2).to_i
      tag = @stream.getbyte()
      if tag == TagTime then
        hour = @stream.read(2).to_i
        min = @stream.read(2).to_i
        sec = @stream.read(2).to_i
        tag, usec = read_usec()
        if tag == TagUTC then
          date = Time.utc(year, month, day, hour, min, sec, usec)
        else
          date = Time.local(year, month, day, hour, min, sec, usec)
        end
      elsif tag == TagUTC then
        date = Time.utc(year, month, day)
      else
        date = Time.local(year, month, day)
      end
      @ref << date
      return date
    end
    def read_time(include_tag = true)
      if include_tag then
        tag = check_tags([TagTime, TagRef])
        return read_ref() if (tag == TagRef)
      end
      hour = @stream.read(2).to_i
      min = @stream.read(2).to_i
      sec = @stream.read(2).to_i
      tag, usec = read_usec()
      if tag == TagUTC then
        time = Time.utc(1970, 1, 1, hour, min, sec, usec)
      else
        time = Time.local(1970, 1, 1, hour, min, sec, usec)
      end
      ref << time
      return time
    end
    def read_bytes(include_tag = true)
      if include_tag then
        tag = check_tags([TagBytes, TagRef])
        return read_ref() if tag == TagRef
      end
      s = @stream.read(readint(@stream, TagQuote))
      @stream.getbyte()
      @ref << s
      return s
    end
    def read_utf8char(include_tag = true)
      check_tag(TagUTF8Char) if include_tag
      c = @stream.getbyte()
      sio = StringIO.new()
      sio.putc(c)
      if ((c & 0xE0) == 0xC0) then
        sio.putc(@stream.getbyte())
      elsif ((c & 0xF0) == 0xE0) then
        sio.write(@stream.read(2))
      elsif c > 0x7F then
        raise Exception, "Bad utf-8 encoding"
      end
      s = sio.string()
      sio.close()
      return s
    end
    def read_string(include_tag = true, include_ref = true)
      if include_tag then
        tag = check_tags([TagString, TagRef])
        return read_ref() if tag == TagRef
      end
      sio = StringIO.new()
      count = readint(@stream, TagQuote)
      i = 0
      while i < count do
        c = @stream.getbyte()
        sio.putc(c)
        if ((c & 0xE0) == 0xC0) then
          sio.putc(@stream.getbyte())
        elsif ((c & 0xF0) == 0xE0) then
          sio.write(@stream.read(2))
        elsif ((c & 0xF8) == 0xF0) then
          sio.write(@stream.read(3))
          i += 1
        end
        i += 1
      end
      @stream.getbyte()
      s = sio.string()
      sio.close()
      @ref << s if (include_ref)
      return s
    end
    def read_list(include_tag = true)
      if include_tag then
        tag = check_tags([TagList, TagRef])
        return read_ref() if tag == TagRef
      end
      count = readint(@stream, TagOpenbrace)
      list = Array.new(count)
      @ref << list
      count.times { |i| list[i] = unserialize() }
      @stream.getbyte()
      return list
    end
    def read_map(include_tag = true)
      if include_tag then
        tag = check_tags([TagMap, TagRef])
        return read_ref() if tag == TagRef
      end
      map = {}
      @ref << map
      readint(@stream, TagOpenbrace).times do
        k = unserialize()
        v = unserialize()
        map[k] = v
      end
      @stream.getbyte()
      return map
    end
    def read_object(include_tag = true)
      if include_tag then
        tag = check_tags([TagClass, TagObject, TagRef])
        return read_ref() if tag == TagRef
        if tag == TagClass then
          read_class()
          return read_object()
        end
      end
      (cls, count, fields) = @classref[readint(@stream, TagOpenbrace)]
      obj = cls.new
      @ref << obj
      vars = obj.instance_variables
      count.times do |i|
        key = fields[i]
        var = '@' << key
        value = unserialize()
        begin
          obj[key] = value
        rescue
          unless vars.include?(var) then
            cls.send(:attr_accessor, key)
            cls.send(:public, key, key + '=')
          end
          obj.instance_variable_set(var.to_sym, value)
        end
      end
      @stream.getbyte()
      return obj
    end
    def read_raw(ostream = nil, tag = nil)
      ostream = StringIO.new() if ostream.nil?
      tag = @stream.getbyte() if tag.nil?
      return case tag
      when TagZero..TagNine, TagNull, TagEmpty, TagTrue, TagFalse, TagNaN then ostream.putc(tag)
      when TagInfinity then ostream.putc(tag); ostream.putc(@stream.getbyte())
      when TagInteger, TagLong, TagDouble, TagRef then read_number_raw(ostream, tag)
      when TagDate, TagTime then read_datetime_raw(ostream, tag)
      when TagUTF8Char then read_utf8char_raw(ostream, tag)
      when TagBytes then read_bytes_raw(ostream, tag)
      when TagString then read_string_raw(ostream, tag)
      when TagGuid then read_guid_raw(ostream, tag)
      when TagList, TagMap, TagObject then read_complex_raw(ostream, tag)
      when TagClass then read_complex_raw(ostream, tag); read_raw(ostream)
      when TagError then ostream.putc(tag); read_raw(ostream)
      when nil then raise Exception, "No byte found in stream"
      else raise Exception, "Unexpected serialize tag '#{tag.chr}' in stream"
      end
      return ostream
    end
    def reset
      @classref.clear()
      @ref.clear()
    end
  end # class Reader
  class Writer
    private
    include Tags
    include Stream
    def write_class(cls)
      classname, fields, count = cls
      @stream.putc(TagClass)
      @stream.write(classname.ulength.to_s)
      @stream.putc(TagQuote)
      @stream.write(classname)
      @stream.putc(TagQuote)
      @stream.write(count.to_s) if count > 0
      @stream.putc(TagOpenbrace)
      fields.each { |field| write_string(field) }
      @stream.putc(TagClosebrace)
      classref = @classref.length
      @classref[cls] = classref
      return classref
    end
    def write_ref(ref)
      @stream.putc(TagRef)
      @stream.write(ref.to_s)
      @stream.putc(TagSemicolon)
    end
    def write_usec(usec)
      if usec > 0 then
        @stream.putc(TagPoint)
        @stream.write(usec.div(1000).to_s.rjust(3, '0'))
        @stream.write(usec.modulo(1000).to_s.rjust(3, '0')) if usec % 1000 > 0
      end      
    end
    public
    def initialize(stream)
      @stream = stream
      @classref = {}
      @ref = {}
    end
    attr_accessor :stream
    def serialize(obj)
      case obj
      when NilClass then @stream.putc(TagNull)
      when FalseClass then @stream.putc(TagFalse)
      when TrueClass then @stream.putc(TagTrue)
      when Fixnum then write_integer(obj)
      when Bignum then write_long(obj)
      when Float then write_double(obj)
      when String then
        len = obj.length
        if len == 0 then
          @stream.putc(TagEmpty)
        elsif (len < 4) and (obj.ulength == 1) then
          write_utf8char(obj)
        elsif @ref.key?(obj) then
          write_ref(@ref[obj])
        elsif obj.utf8? then
          write_string(obj, false)
        else
          write_bytes(obj, false)
        end
      when Symbol then
        if @ref.key?(obj) then
          write_ref(@ref[obj])
        else
          write_string(obj, false)
        end
      when Time then write_date(obj, false)
      when Array, Range, MatchData then write_list(obj, false)
      when Hash then write_map(obj, false)
      when Binding, Class, Dir, Exception, IO, Numeric,
          Method, Module, Proc, Regexp, Thread, ThreadGroup then
        raise Exception, 'This type is not supported to serialize'
      else write_object(obj, false)
      end
    end
    def write_integer(integer)
      if (0..9) === integer then
        @stream.putc(integer.to_s)
      else
        @stream.putc((-2147483648..2147483647) === integer ? TagInteger : TagLong)
        @stream.write(integer.to_s)
        @stream.putc(TagSemicolon)
      end
    end
    def write_long(long)
      if (0..9) === long then
        @stream.putc(long.to_s)
      else
        @stream.putc(TagLong)
        @stream.write(long.to_s)
        @stream.putc(TagSemicolon)
      end
    end
    def write_double(double)
      if double.nan? then
        write_nan()
      elsif double.finite? then
        @stream.putc(TagDouble)
        @stream.write(double.to_s)
        @stream.putc(TagSemicolon)
      else
        write_infinity(double > 0)
      end
    end
    def write_nan()
      @stream.putc(TagNaN)
    end
    def write_infinity(positive = true)
      @stream.putc(TagInfinity)
      @stream.putc(positive ? TagPos : TagNeg)
    end
    def write_null()
      @stream.putc(TagNull)
    end
    def write_empty()
      @stream.putc(TagEmpty)
    end
    def write_boolean(bool)
      @stream.putc(bool ? TagTrue : TagFalse)
    end
    def write_date(time, check_ref = true)
      if check_ref and @ref.key?(time) then
        write_ref(@ref[time])
      else
        @ref[time] = @ref.length
        if time.hour == 0 and time.min == 0 and time.sec == 0 and time.usec == 0 then
          @stream.putc(TagDate)
          @stream.write(time.strftime('%Y%m%d'))
          @stream.putc(time.utc? ? TagUTC : TagSemicolon)
        elsif time.year == 1970 and time.mon == 1 and time.day == 1 then
          @stream.putc(TagTime)
          @stream.write(time.strftime('%H%M%S'))
          write_usec(time.usec)
          @stream.putc(time.utc? ? TagUTC : TagSemicolon)
        else
          @stream.putc(TagDate)
          @stream.write(time.strftime('%Y%m%d' << TagTime << '%H%M%S'))
          write_usec(time.usec)
          @stream.putc(time.utc? ? TagUTC : TagSemicolon)
        end
      end
    end
    alias write_time write_date
    def write_bytes(string, check_ref = true)
      if check_ref and @ref.key?(string) then
        write_ref(@ref[string])
      else
        @ref[string] = @ref.length
        length = string.length
        @stream.putc(TagBytes)
        @stream.write(length.to_s) if length > 0
        @stream.putc(TagQuote)
        @stream.write(string)
        @stream.putc(TagQuote)
      end
    end
    def write_utf8char(utf8char)
      @stream.putc(TagUTF8Char)
      @stream.write(utf8char)
    end
    def write_string(string, check_ref = true)
      if check_ref and @ref.key?(string) then
        write_ref(@ref[string])
      else
        @ref[string] = @ref.length
        string = string.to_s
        length = string.ulength
        @stream.putc(TagString)
        @stream.write(length.to_s) if length > 0
        @stream.putc(TagQuote)
        @stream.write(string)
        @stream.putc(TagQuote)
      end
    end
    def write_list(list, check_ref = true)
      objid = list.object_id
      if check_ref and @ref.key?(objid) then
        write_ref(@ref[objid])
      else
        @ref[objid] = @ref.length
        list = list.to_a
        count = list.size
        @stream.putc(TagList)
        @stream.write(count.to_s) if count > 0
        @stream.putc(TagOpenbrace)
        0.upto(count - 1) { |i| serialize(list[i]) }
        @stream.putc(TagClosebrace)
      end
    end
    def write_map(map, check_ref = true)
      objid = map.object_id
      if check_ref and @ref.key?(objid) then
        write_ref(@ref[objid])
      else
        @ref[objid] = @ref.length
        size = map.size
        @stream.putc(TagMap)
        @stream.write(size.to_s) if size > 0
        @stream.putc(TagOpenbrace)
        map.each do |key, value|
          serialize(key)
          serialize(value)
        end
        @stream.putc(TagClosebrace)
      end
    end
    def write_object(object, check_ref = true)
      objid = object.object_id
      if check_ref and @ref.key?(objid) then
        write_ref(@ref[objid])
      else
        classname = ClassManager.getClassAlias(object.class)
        if object.is_a?(Struct) then
          fields = object.members
        else
          vars = object.instance_variables
          fields = vars.map { |var| var.to_s.delete('@') }
        end
        count = fields.size
        cls = [classname, fields, count]
        classref = @classref.key?(cls) ? @classref[cls] : write_class(cls)
        @ref[objid] = @ref.length
        @stream.putc(TagObject)
        @stream.write(classref.to_s)
        @stream.putc(TagOpenbrace)
        if object.is_a?(Struct) then
          fields.each { |field| serialize(object[field]) }
        else
          vars.each { |var| serialize(object.instance_variable_get(var)) }
        end
        @stream.putc(TagClosebrace)
      end
    end
    def reset
      @classref.clear()
      @ref.clear()
    end
  end # class Writer

  class Formatter
    class << self
      def serialize(variable)
        stream = StringIO.new()
        writer = Writer.new(stream)
        writer.serialize(variable)
        s = stream.string
        stream.close()
        return s
      end
      def unserialize(variable_representation)
        stream = StringIO.new(variable_representation, 'rb')
        reader = Reader.new(stream)
        obj = reader.unserialize()
        stream.close()
        return obj
      end
    end # class
  end # class Formatter
end # module Hprose
