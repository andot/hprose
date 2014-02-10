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
# LastModified: Feb 11, 2014                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require 'stringio'
require 'thread'
require 'uuidtools'
require 'hprose/common'

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

include UUIDTools

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
      s = StringIO.new
      while true do
        c = stream.getbyte
        break if c.nil? or (c == char)
        s.putc(c)
      end
      result = s.string
      s.close
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

  class RawReader
    private
    include Tags
    include Stream
    def read_number_raw(ostream)
      ostream.write(readuntil(@stream, TagSemicolon))
      ostream.putc(TagSemicolon)
    end
    def read_datetime_raw(ostream)
      while true
        c = @stream.getbyte
        ostream.putc(c)
        break if (c == TagSemicolon) or (c == TagUTC)
      end
    end
    def read_utf8char_raw(ostream)
      c = @stream.getbyte
      ostream.putc(c)
      if (c & 0xE0) == 0xC0 then
        ostream.putc(@stream.getbyte())
      elsif (c & 0xF0) == 0xE0 then
        ostream.write(@stream.read(2))
      elsif c > 0x7F then
        raise HproseException, 'Bad utf-8 encoding'
      end
    end
    def read_bytes_raw(ostream)
      count = readuntil(@stream, TagQuote)
      ostream.write(count)
      ostream.putc(TagQuote)
      count = ((count == '') ? 0 : count.to_i)
      ostream.write(@stream.read(count + 1))
    end
    def read_string_raw(ostream)
      count = readuntil(@stream, TagQuote)
      ostream.write(count)
      ostream.putc(TagQuote)
      count = ((count == '') ? 0 : count.to_i)
      i = 0
      while i < count
        c = @stream.getbyte
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
    def read_guid_raw(ostream)
      ostream.write(@stream.read(38))
    end
    def read_complex_raw(ostream)
      ostream.write(readuntil(@stream, TagOpenbrace))
      ostream.write(TagOpenbrace)
      tag = @stream.getbyte
      while tag != TagClosebrace
        read_raw(ostream, tag)
        tag = @stream.getbyte
      end
      ostream.putc(tag)
    end
    public
    def initialize(stream)
      @stream = stream
    end
    attr_accessor :stream
    def unexpected_tag(tag, expect_tag = nil)
      if tag.nil? then
        raise Exception, "No byte found in stream"
      elsif expect_tag.nil? then
        raise Exception, "Unexpected serialize tag '#{tag.chr}' in stream"
      else
        raise Exception, "Tag '#{expect_tag}' expected, but '#{tag.chr}' found in stream"
      end
    end
    def read_raw(ostream = nil, tag = nil)
      ostream = StringIO.new if ostream.nil?
      tag = @stream.getbyte if tag.nil?
      ostream.putc(tag)
      case tag
      when TagZero..TagNine, TagNull, TagEmpty, TagTrue, TagFalse, TagNaN then {}
      when TagInfinity then ostream.putc(@stream.getbyte())
      when TagInteger, TagLong, TagDouble, TagRef then read_number_raw(ostream)
      when TagDate, TagTime then read_datetime_raw(ostream)
      when TagUTF8Char then read_utf8char_raw(ostream)
      when TagBytes then read_bytes_raw(ostream)
      when TagString then read_string_raw(ostream)
      when TagGuid then read_guid_raw(ostream)
      when TagList, TagMap, TagObject then read_complex_raw(ostream)
      when TagClass then read_complex_raw(ostream); read_raw(ostream)
      when TagError then read_raw(ostream)
      else unexpected_tag(tag)
      end
      return ostream
    end
  end # class RawReader

  class SimpleReader < RawReader
    private
    def read_string_without_ref
      sio = StringIO.new
      count = readint(@stream, TagQuote)
      i = 0
      while i < count do
        c = @stream.getbyte
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
      @stream.getbyte
      s = sio.string
      sio.close
      return s
    end
    def read_class
      cls = ClassManager.getClass(read_string_without_ref)
      count = readint(@stream, TagOpenbrace)
      fields = Array.new(count) { read_string }
      @stream.getbyte
      @classref << [cls, count, fields]
    end
    def read_usec
      usec = 0
      tag = @stream.getbyte
      if tag == TagPoint then
        usec = @stream.read(3).to_i * 1000
        tag = @stream.getbyte
        if (TagZero..TagNine) === tag then
          usec = usec + (tag << @stream.read(2)).to_i
          tag = @stream.getbyte
          if (TagZero..TagNine) === tag then
            @stream.read(2)
            tag = @stream.getbyte
          end
        end
      end
      return tag, usec
    end
    def read_list_begin
      count = readint(@stream, TagOpenbrace)
      return Array.new(count)
    end
    def read_list_end(list)
      list.size.times do |i|
        list[i] = unserialize
      end
      @stream.getbyte
      return list
    end
    def read_map_begin
      return {}
    end
    def read_map_end(map)
      readint(@stream, TagOpenbrace).times do
        k = unserialize
        v = unserialize
        map[k] = v
      end
      @stream.getbyte
      return map
    end
    def read_object_begin
      cls, count, fields = @classref[readint(@stream, TagOpenbrace)]
      obj = cls.new
      return obj, cls, count, fields
    end
    def read_object_end(obj, cls, count, fields)
      vars = obj.instance_variables
      count.times do |i|
        key = fields[i]
        var = '@' << key
        value = unserialize
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
      @stream.getbyte
      return obj
    end
    protected
    def read_ref
      return unexpected_tag(TagRef)
    end
    public
    def initialize(stream)
      super
      @classref = []
    end
    def unserialize(tag = nil)
      tag = @stream.getbyte if tag.nil?
      return case tag
      when TagZero..TagNine then tag - TagZero
      when TagInteger then read_integer_without_tag
      when TagLong then read_long_without_tag
      when TagDouble then read_double_without_tag
      when TagNull then nil
      when TagEmpty then ""
      when TagTrue then true
      when TagFalse then false
      when TagNaN then 0.0/0.0
      when TagInfinity then read_infinity_without_tag
      when TagDate then read_date_without_tag
      when TagTime then read_time_without_tag
      when TagBytes then read_bytes_without_tag
      when TagUTF8Char then read_utf8char_without_tag
      when TagString then read_string_without_tag
      when TagGuid then read_guid_without_tag
      when TagList then read_list_without_tag
      when TagMap then read_map_without_tag
      when TagClass then read_class; read_object_without_tag
      when TagObject then read_object_without_tag
      when TagRef then read_ref
      when TagError then raise Exception, read_string
      else unexpected_tag(tag)
      end
    end
    def check_tag(expect_tag)
      tag = @stream.getbyte
      unexpected_tag(tag, expect_tag.chr) if tag != expect_tag
    end
    def check_tags(expect_tags)
      tag = @stream.getbyte
      unexpected_tag(tag, expect_tags.pack('c*')) if not expect_tags.include?(tag)
      return tag
    end
    def read_integer_without_tag
      return readuntil(@stream, TagSemicolon).to_i
    end
    def read_integer
      tag = @stream.getbyte
      return case tag
      when TagZero..TagNine then tag - TagZero
      when TagInteger then read_integer_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_long_without_tag
      return readuntil(@stream, TagSemicolon).to_i
    end
    def read_long
      tag = @stream.getbyte
      return case tag
      when TagZero..TagNine then tag - TagZero
      when TagInteger, TagLong then read_long_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_double_without_tag
      return readuntil(@stream, TagSemicolon).to_f
    end
    def read_double
      tag = @stream.getbyte
      return case tag
      when TagZero..TagNine then tag - TagZero
      when TagInteger, TagLong, TagDouble then read_double_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_nan
      check_tag(TagNaN)
      return 0.0/0.0
    end
    def read_infinity_without_tag
      return (@stream.getbyte == TagPos) ? 1.0/0.0 : -1.0/0.0
    end
    def read_infinity
      check_tag(TagInfinity)
      return read_infinity_without_tag
    end
    def read_null
      check_tag(TagNull)
      return nil
    end
    def read_empty
      check_tag(TagEmpty)
      return ""
    end
    def read_boolean
      tag = check_tags([TagTrue, TagFalse])
      return tag == TagTrue
    end
    def read_date_without_tag
      year = @stream.read(4).to_i
      month = @stream.read(2).to_i
      day = @stream.read(2).to_i
      tag = @stream.getbyte
      if tag == TagTime then
        hour = @stream.read(2).to_i
        min = @stream.read(2).to_i
        sec = @stream.read(2).to_i
        tag, usec = read_usec
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
      return date
    end
    def read_date
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagDate then read_date_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_time_without_tag
      hour = @stream.read(2).to_i
      min = @stream.read(2).to_i
      sec = @stream.read(2).to_i
      tag, usec = read_usec
      if tag == TagUTC then
        time = Time.utc(1970, 1, 1, hour, min, sec, usec)
      else
        time = Time.local(1970, 1, 1, hour, min, sec, usec)
      end
      return time
    end
    def read_time
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagTime then read_time_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_bytes_without_tag
      bytes = @stream.read(readint(@stream, TagQuote))
      @stream.getbyte
      return bytes
    end
    def read_bytes
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagBytes then read_bytes_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_utf8char_without_tag
      c = @stream.getbyte
      sio = StringIO.new
      sio.putc(c)
      if ((c & 0xE0) == 0xC0) then
        sio.putc(@stream.getbyte())
      elsif ((c & 0xF0) == 0xE0) then
        sio.write(@stream.read(2))
      elsif c > 0x7F then
        raise Exception, "Bad utf-8 encoding"
      end
      s = sio.string
      sio.close
      return s
    end
    def read_utf8char
      check_tag(TagUTF8Char)
      return read_utf8char_without_tag
    end
    def read_string_without_tag
      return read_string_without_ref
    end
    def read_string
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagString then read_string_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_guid_without_tag
      @stream.getbyte
      guid = UUID.parse(@stream.read(36))
      @stream.getbyte
      return guid
    end
    def read_guid
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagGuid then read_guid_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_list_without_tag
      return read_list_end(read_list_begin)
    end
    def read_list
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagList then read_list_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_map_without_tag
      return read_map_end(read_map_begin)
    end
    def read_map
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagMap then read_map_without_tag
      else unexpected_tag(tag)
      end
    end
    def read_object_without_tag
      return read_object_end(*read_object_begin)
    end
    def read_object
      tag = @stream.getbyte
      return case tag
      when TagRef then read_ref
      when TagClass then read_class; read_object
      when TagObject then read_object_without_tag
      else unexpected_tag(tag)
      end
    end
    def reset
      @classref.clear
    end
  end # class SimpleReader

  class Reader < SimpleReader
    protected
    def read_ref
      return @ref[readint(@stream, TagSemicolon)]
    end
    public
    def initialize(stream)
      super
      @ref = []
    end
    def read_date_without_tag
      date = super
      @ref << date
      return date
    end
    def read_time_without_tag
      time = super
      @ref << time
      return time
    end
    def read_bytes_without_tag
      bytes = super
      @ref << bytes
      return bytes
    end
    def read_string_without_tag
      s = super
      @ref << s
      return s
    end
    def read_guid_without_tag
      guid = super
      @ref << guid
      return guid
    end
    def read_list_without_tag
      list = read_list_begin
      @ref << list
      return read_list_end(list)
    end
    def read_map_without_tag
      map = read_map_begin
      @ref << map
      return read_map_end(map)
    end
    def read_object_without_tag
      obj, cls, count, fields = read_object_begin
      @ref << obj
      return read_object_end(obj, cls, count, fields)
    end
    def reset
      super
      @ref.clear
    end
  end # class Reader

  class SimpleWriter
    private
    include Tags
    include Stream
    def write_object_begin(object)
        classname = ClassManager.getClassAlias(object.class)
        if @classref.key?(classname) then
          index = @classref[classname]
          fields, vars = @fieldsref[index]
        else
          if object.is_a?(Struct) then
            vars = nil
            fields = object.members
          else
            vars = object.instance_variables
            fields = vars.map { |var| var.to_s.delete('@') }
          end
          index = write_class(classname, fields, vars)
        end
        @stream.putc(TagObject)
        @stream.write(index.to_s)
        @stream.putc(TagOpenbrace)
        return fields, vars
    end
    def write_object_end(object, fields, vars)
      if vars.nil? then
        fields.each { |field| serialize(object[field]) }
      else
        vars.each { |var| serialize(object.instance_variable_get(var)) }
      end
      @stream.putc(TagClosebrace)
    end
    def write_class(classname, fields, vars)
      count = fields.size
      @stream.putc(TagClass)
      @stream.write(classname.ulength.to_s)
      @stream.putc(TagQuote)
      @stream.write(classname)
      @stream.putc(TagQuote)
      @stream.write(count.to_s) if count > 0
      @stream.putc(TagOpenbrace)
      fields.each { |field| write_string(field) }
      @stream.putc(TagClosebrace)
      index = @fieldsref.size
      @classref[classname] = index
      @fieldsref << [fields, vars]
      return index
    end
    def write_usec(usec)
      if usec > 0 then
        @stream.putc(TagPoint)
        @stream.write(usec.div(1000).to_s.rjust(3, '0'))
        @stream.write(usec.modulo(1000).to_s.rjust(3, '0')) if usec % 1000 > 0
      end
    end
    protected
    def write_ref(obj)
      return false
    end
    public
    def initialize(stream)
      @stream = stream
      @classref = {}
      @fieldsref = []
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
        elsif not write_ref(obj) then
          if obj.utf8? then
            write_string(obj)
          else
            write_bytes(obj)
          end
        end
      when Symbol then write_string_with_ref(obj)
      when UUID then write_guid_with_ref(obj)
      when Time then write_date_with_ref(obj)
      when Array, Range, MatchData then write_list_with_ref(obj)
      when Hash then write_map_with_ref(obj)
      when Binding, Class, Dir, Exception, IO, Numeric,
          Method, Module, Proc, Regexp, Thread, ThreadGroup then
        raise Exception, 'This type is not supported to serialize'
      else write_object_with_ref(obj)
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
        write_nan
      elsif double.finite? then
        @stream.putc(TagDouble)
        @stream.write(double.to_s)
        @stream.putc(TagSemicolon)
      else
        write_infinity(double > 0)
      end
    end
    def write_nan
      @stream.putc(TagNaN)
    end
    def write_infinity(positive = true)
      @stream.putc(TagInfinity)
      @stream.putc(positive ? TagPos : TagNeg)
    end
    def write_null
      @stream.putc(TagNull)
    end
    def write_empty
      @stream.putc(TagEmpty)
    end
    def write_boolean(bool)
      @stream.putc(bool ? TagTrue : TagFalse)
    end
    def write_date(time)
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
    def write_date_with_ref(time)
      write_date(time) if not write_ref(time)
    end
    alias write_time write_date
    alias write_time_with_ref write_date_with_ref
    def write_bytes(bytes)
      length = bytes.length
      @stream.putc(TagBytes)
      @stream.write(length.to_s) if length > 0
      @stream.putc(TagQuote)
      @stream.write(bytes)
      @stream.putc(TagQuote)
    end
    def write_bytes_with_ref(bytes)
      write_bytes(bytes) if not write_ref(bytes)
    end
    def write_utf8char(utf8char)
      @stream.putc(TagUTF8Char)
      @stream.write(utf8char)
    end
    def write_string(string)
      string = string.to_s
      length = string.ulength
      @stream.putc(TagString)
      @stream.write(length.to_s) if length > 0
      @stream.putc(TagQuote)
      @stream.write(string)
      @stream.putc(TagQuote)
    end
    def write_string_with_ref(string)
      write_string(string) if not write_ref(string)
    end
    def write_guid(guid)
      @stream.putc(TagGuid)
      @stream.putc(TagOpenbrace)
      @stream.write(guid.to_s)
      @stream.putc(TagClosebrace)
    end
    def write_guid_with_ref(guid)
      write_guid(guid) if not write_ref(guid)
    end
    def write_list(list)
      list = list.to_a
      count = list.size
      @stream.putc(TagList)
      @stream.write(count.to_s) if count > 0
      @stream.putc(TagOpenbrace)
      count.times do |i|
        serialize(list[i])
      end
      @stream.putc(TagClosebrace)
    end
    def write_list_with_ref(list)
      write_list(list) if not write_ref(list)
    end
    def write_map(map)
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
    def write_map_with_ref(map)
      write_map(map) if not write_ref(map)
    end
    def write_object(object)
      fields, vars = write_object_begin(object)
      write_object_end(object, fields, vars)
    end
    def write_object_with_ref(object)
      write_object(object) if not write_ref(object)
    end
    def reset
      @classref.clear
      @fieldsref.clear
    end
  end # class SimpleWriter

  class Writer < SimpleWriter
    protected
    def write_ref(obj)
      objid = obj.object_id
      if @ref.key?(objid) then
        @stream.putc(TagRef)
        @stream.write(@ref[objid].to_s)
        @stream.putc(TagSemicolon)
        return true
      end
      return false
    end
    public
    def initialize(stream)
      super
      @ref = {}
      @refcount = 0
    end
    def write_date(time)
      @ref[time.object_id] = @refcount
      @refcount += 0
      super
    end
    def write_bytes(bytes)
      @ref[bytes.object_id] = @refcount
      @refcount += 0
      super
    end
    def write_string(string)
      @ref[string.object_id] = @refcount
      @refcount += 0
      super
    end
    def write_guid(guid)
      @ref[guid.object_id] = @refcount
      @refcount += 0
      super
    end
    def write_list(list)
      @ref[list.object_id] = @refcount
      @refcount += 0
      super
    end
    def write_map(map)
      @ref[map.object_id] = @refcount
      @refcount += 0
      super
    end
    def write_object(object)
      fields, vars = write_object_begin(object)
      @ref[object.object_id] = @refcount
      @refcount += 0
      write_object_end(object, fields, vars)
    end
    def reset
      super
      @ref.clear
      @refcount = 0
    end
  end # class Writer

  class Formatter
    class << self
      def serialize(variable, simple = false)
        stream = StringIO.new
        writer = simple ? SimpleWriter.new(stream) : Writer.new(stream)
        writer.serialize(variable)
        s = stream.string
        stream.close
        return s
      end
      def unserialize(variable_representation, simple = false)
        stream = StringIO.new(variable_representation, 'rb')
        reader = simple ? SimpleReader.new(stream) : Reader.new(stream)
        obj = reader.unserialize
        stream.close
        return obj
      end
    end # class
  end # class Formatter
end # module Hprose
