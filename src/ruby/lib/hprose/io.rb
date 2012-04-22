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
# LastModified: Jun 20, 2011                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require 'stringio'
require "thread"

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
  class Exception < Exception; end

  module Tags
    # Serialize Tags
    TAG_INTEGER = ?i
    TAG_LONG = ?l
    TAG_DOUBLE = ?d
    TAG_NULL = ?n
    TAG_EMPTY = ?e
    TAG_TRUE = ?t
    TAG_FALSE = ?f
    TAG_NAN = ?N
    TAG_INFINITY = ?I
    TAG_DATE = ?D
    TAG_TIME = ?T
    TAG_UTC = ?Z
    TAG_BYTES = ?b
    TAG_UTF8CHAR = ?u
    TAG_STRING = ?s
    TAG_GUID = ?g
    TAG_LIST = ?a
    TAG_MAP = ?m
    TAG_CLASS = ?c
    TAG_OBJECT = ?o
    TAG_REF = ?r
    # Serialize Marks
    TAG_POS = ?+
    TAG_NEG = ?-
    TAG_SEMICOLON = ?;
    TAG_OPENBRACE = ?{
    TAG_CLOSEBRACE = ?}
    TAG_QUOTE = ?"
    TAG_POINT = ?.
    # Protocol Tags
    TAG_FUNCTIONS = ?F
    TAG_CALL = ?C
    TAG_RESULT = ?R
    TAG_ARGUMENT = ?A
    TAG_ERROR = ?E
    TAG_END = ?z
  end # module Tags

  module Stream
    def readuntil(stream, char)
      s = ''
      while true do
        c = stream.getc()
        break if c.nil? or (c == char)
        s.concat(c)
      end
      return s
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
      return @ref[readint(@stream, TAG_SEMICOLON)]
    end
    def read_class()
      cls = ClassManager.getClass(read_string(false, false))
      count = readint(@stream, TAG_OPENBRACE)
      fields = Array.new(count) { read_string() }
      @stream.getc()
      @classref << [cls, count, fields]
    end
    def read_usec()
      usec = 0
      tag = @stream.getc()
      if tag == TAG_POINT then
        usec = @stream.read(3).to_i * 1000
        tag = @stream.getc()
        if (?0..?9) === tag then
          usec = usec + (tag << @stream.read(2)).to_i
          tag = @stream.getc()
          if (?0..?9) === tag then
            @stream.read(2)
            tag = @stream.getc()
          end
        end
      end
      return tag, usec
    end
    public
    def initialize(stream)
      @stream = stream
      @classref = []
      @ref = []
    end
    attr_reader :stream
    def unserialize(tag = nil)
      tag = @stream.getc() if tag.nil?
      return case tag
      when ?0..?9 then tag - ?0
      when TAG_INTEGER then read_integer(false)
      when TAG_LONG then read_long(false)
      when TAG_DOUBLE then read_double(false)
      when TAG_NULL then nil
      when TAG_EMPTY then ""
      when TAG_TRUE then true
      when TAG_FALSE then false
      when TAG_NAN then 0.0/0.0
      when TAG_INFINITY then read_infinity(false)
      when TAG_DATE then read_date(false)
      when TAG_TIME then read_time(false)
      when TAG_BYTES then read_bytes(false)
      when TAG_UTF8CHAR then read_utf8char(false)
      when TAG_STRING then read_string(false)
      when TAG_GUID then read_guid(false)
      when TAG_LIST then read_list(false)
      when TAG_MAP then read_map(false)
      when TAG_CLASS then read_class(); unserialize()
      when TAG_OBJECT then read_object(false)
      when TAG_REF then read_ref()
      when TAG_ERROR then raise Exception, read_string()
      when nil then raise Exception, "No byte found in stream"
      else raise Exception, "Unexpected serialize tag '#{tag.chr}' in stream"
      end
    end
    def check_tag(expect_tag)
      tag = @stream.getc()
      raise Exception, "No byte found in stream" if tag.nil?
      raise Exception, "Tag '#{expect_tag.chr}' expected, but '#{tag.chr}' found in stream" if tag != expect_tag
    end
    def check_tags(expect_tags)
      tag = @stream.getc()
      raise Exception, "No byte found in stream" if tag.nil?
      raise Exception, "Tag '#{expect_tags.pack('c*')}' expected, but '#{tag.chr}' found in stream" if not expect_tags.include?(tag)
      return tag
    end
    def read_integer(include_tag = true)
      check_tag(TAG_INTEGER) if include_tag
      return readuntil(@stream, TAG_SEMICOLON).to_i
    end
    def read_long(include_tag = true)
      check_tag(TAG_LONG) if include_tag
      return readuntil(@stream, TAG_SEMICOLON).to_i
    end
    def read_double(include_tag = true)
      check_tag(TAG_DOUBLE) if include_tag
      return readuntil(@stream, TAG_SEMICOLON).to_f
    end
    def read_nan()
      check_tag(TAG_NAN)
      return 0.0/0.0
    end
    def read_infinity(include_tag = true)
      check_tag(TAG_INFINITY) if (include_tag)
      return (@stream.getc() == TAG_POS) ? 1.0/0.0 : -1.0/0.0
    end
    def read_null()
      check_tag(TAG_NULL)
      return nil
    end
    def read_empty()
      check_tag(TAG_EMPTY)
      return ""
    end
    def read_boolean()
      tag = check_tags([TAG_TRUE, TAG_FALSE])
      return tag == TAG_TRUE
    end
    def read_date(include_tag = true)
      if include_tag then
        tag = check_tags([TAG_DATE, TAG_REF])
        return read_ref() if tag == TAG_REF
      end
      year = @stream.read(4).to_i
      month = @stream.read(2).to_i
      day = @stream.read(2).to_i
      tag = @stream.getc
      if tag == TAG_TIME then
        hour = @stream.read(2).to_i
        min = @stream.read(2).to_i
        sec = @stream.read(2).to_i
        tag, usec = read_usec()
        if tag == TAG_UTC then
          date = Time.utc(year, month, day, hour, min, sec, usec)
        else
          date = Time.local(year, month, day, hour, min, sec, usec)
        end
      elsif tag == TAG_UTC then
        date = Time.utc(year, month, day)
      else
        date = Time.local(year, month, day)
      end
      @ref << date
      return date
    end
    def read_time(include_tag = true)
      if include_tag then
        tag = check_tags([TAG_TIME, TAG_REF])
        return read_ref() if (tag == TAG_REF)
      end
      hour = @stream.read(2).to_i
      min = @stream.read(2).to_i
      sec = @stream.read(2).to_i
      tag, usec = read_usec()
      if tag == TAG_UTC then
        time = Time.utc(1970, 1, 1, hour, min, sec, usec)
      else
        time = Time.local(1970, 1, 1, hour, min, sec, usec)
      end
      ref << time
      return time
    end
    def read_bytes(include_tag = true)
      if include_tag then
        tag = check_tags([TAG_BYTES, TAG_REF])
        return read_ref() if tag == TAG_REF
      end
      s = @stream.read(readint(@stream, TAG_QUOTE))
      @stream.getc()
      @ref << s
      return s
    end
    def read_utf8char(include_tag = true)
      check_tag(TAG_UTF8CHAR) if include_tag
      c = @stream.getc()
      s = c
      if ((c & 0xE0) == 0xC0) then
        s << @stream.getc()
      elsif ((c & 0xF0) == 0xE0) then
        s << @stream.read(2)
      elsif c > 0x7F then
        raise Exception, "Bad utf-8 encoding"
      end
      return s
    end
    def read_string(include_tag = true, include_ref = true)
      if include_tag then
        tag = check_tags([TAG_STRING, TAG_REF])
        return read_ref() if tag == TAG_REF
      end
      s = ''
      count = readint(@stream, TAG_QUOTE)
      i = 0
      while i < count do
        c = @stream.getc()
        s << c
        if ((c & 0xE0) == 0xC0) then
          s << @stream.getc()
        elsif ((c & 0xF0) == 0xE0) then
          s << @stream.read(2)
        elsif ((c & 0xF8) == 0xF0) then
          s << @stream.read(3)
          i += 1
        end
        i += 1
      end
      @stream.getc()
      @ref << s if (include_ref)
      return s
    end
    def read_list(include_tag = true)
      if include_tag then
        tag = check_tags([TAG_LIST, TAG_REF])
        return read_ref() if tag == TAG_REF
      end
      count = readint(@stream, TAG_OPENBRACE)
      list = Array.new(count)
      @ref << list
      count.times { |i| list[i] = unserialize() }
      @stream.getc()
      return list
    end
    def read_map(include_tag = true)
      if include_tag then
        tag = check_tags([TAG_MAP, TAG_REF])
        return read_ref() if tag == TAG_REF
      end
      map = {}
      @ref << map
      readint(@stream, TAG_OPENBRACE).times do
        k = unserialize()
        v = unserialize()
        map[k] = v
      end
      @stream.getc()
      return map
    end
    def read_object(include_tag = true)
      if include_tag then
        tag = check_tags([TAG_CLASS, TAG_OBJECT, TAG_REF])
        return read_ref() if tag == TAG_REF
        if tag == TAG_CLASS then
          read_class()
          return read_object()
        end
      end
      (cls, count, fields) = @classref[readint(@stream, TAG_OPENBRACE)]
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
      @stream.getc()
      return obj
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
      @stream.putc(TAG_CLASS)
      @stream.write(classname.ulength.to_s)
      @stream.putc(TAG_QUOTE)
      @stream.write(classname)
      @stream.putc(TAG_QUOTE)
      @stream.write(count.to_s) if count > 0
      @stream.putc(TAG_OPENBRACE)
      fields.each { |field| write_string(field) }
      @stream.putc(TAG_CLOSEBRACE)
      classref = @classref.length
      @classref[cls] = classref
      return classref
    end
    def write_ref(ref)
      @stream.putc(TAG_REF)
      @stream.write(ref.to_s)
      @stream.putc(TAG_SEMICOLON)
    end
    def write_usec(usec)
      if usec > 0 then
        @stream.putc(TAG_POINT)
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
    attr_reader :stream
    def serialize(obj)
      case obj
      when NilClass then @stream.putc(TAG_NULL)
      when FalseClass then @stream.putc(TAG_FALSE)
      when TrueClass then @stream.putc(TAG_TRUE)
      when Fixnum then write_integer(obj)
      when Bignum then write_long(obj)
      when Float then write_double(obj)
      when String then
        len = obj.length
        if len == 0 then
          @stream.putc(TAG_EMPTY)
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
      when Binding, Class, Continuation, Dir, Exception, IO, Numeric,
          Method, Module, Proc, Regexp, Thread, ThreadGroup then
        raise Exception, 'This type is not supported to serialize'
      else write_object(obj, false)
      end
    end
    def write_integer(integer)
      if (0..9) === integer then
        @stream.putc(integer.to_s)
      else
        @stream.putc((-2147483648..2147483647) === integer ? TAG_INTEGER : TAG_LONG)
        @stream.write(integer.to_s)
        @stream.putc(TAG_SEMICOLON)
      end
    end
    def write_long(long)
      if (0..9) === long then
        @stream.putc(long.to_s)
      else
        @stream.putc(TAG_LONG)
        @stream.write(long.to_s)
        @stream.putc(TAG_SEMICOLON)
      end
    end
    def write_double(double)
      if double.nan? then
        write_nan()
      elsif double.finite? then
        @stream.putc(TAG_DOUBLE)
        @stream.write(double.to_s)
        @stream.putc(TAG_SEMICOLON)
      else
        write_infinity(double > 0)
      end
    end
    def write_nan()
      @stream.putc(TAG_NAN)
    end
    def write_infinity(positive = true)
      @stream.putc(TAG_INFINITY)
      @stream.putc(positive ? TAG_POS : TAG_NEG)
    end
    def write_null()
      @stream.putc(TAG_NULL)
    end
    def write_empty()
      @stream.putc(TAG_EMPTY)
    end
    def write_boolean(bool)
      @stream.putc(bool ? TAG_TRUE : TAG_FALSE)
    end
    def write_date(time, check_ref = true)
      if check_ref and @ref.key?(time) then
        write_ref(@ref[time])
      else
        @ref[time] = @ref.length
        if time.hour == 0 and time.min == 0 and time.sec == 0 and time.usec == 0 then
          @stream.putc(TAG_DATE)
          @stream.write(time.strftime('%Y%m%d'))
          @stream.putc(time.utc? ? TAG_UTC : TAG_SEMICOLON)
        elsif time.year == 1970 and time.mon == 1 and time.day == 1 then
          @stream.putc(TAG_TIME)
          @stream.write(time.strftime('%H%M%S'))
          write_usec(time.usec)
          @stream.putc(time.utc? ? TAG_UTC : TAG_SEMICOLON)
        else
          @stream.putc(TAG_DATE)
          @stream.write(time.strftime('%Y%m%d' << TAG_TIME << '%H%M%S'))
          write_usec(time.usec)
          @stream.putc(time.utc? ? TAG_UTC : TAG_SEMICOLON)
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
        @stream.putc(TAG_BYTES)
        @stream.write(length.to_s) if length > 0
        @stream.putc(TAG_QUOTE)
        @stream.write(string)
        @stream.putc(TAG_QUOTE)
      end
    end
    def write_utf8char(utf8char)
      @stream.putc(TAG_UTF8CHAR)
      @stream.write(utf8char)
    end
    def write_string(string, check_ref = true)
      if check_ref and @ref.key?(string) then
        write_ref(@ref[string])
      else
        @ref[string] = @ref.length
        string = string.to_s
        length = string.ulength
        @stream.putc(TAG_STRING)
        @stream.write(length.to_s) if length > 0
        @stream.putc(TAG_QUOTE)
        @stream.write(string)
        @stream.putc(TAG_QUOTE)
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
        @stream.putc(TAG_LIST)
        @stream.write(count.to_s) if count > 0
        @stream.putc(TAG_OPENBRACE)
        0.upto(count - 1) { |i| serialize(list[i]) }
        @stream.putc(TAG_CLOSEBRACE)
      end
    end
    def write_map(map, check_ref = true)
      objid = map.object_id
      if check_ref and @ref.key?(objid) then
        write_ref(@ref[objid])
      else
        @ref[objid] = @ref.length
        size = map.size
        @stream.putc(TAG_MAP)
        @stream.write(size.to_s) if size > 0
        @stream.putc(TAG_OPENBRACE)
        map.each do |key, value|
          serialize(key)
          serialize(value)
        end
        @stream.putc(TAG_CLOSEBRACE)
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
          fields = vars.map { |var| var.delete('@') }
        end
        count = fields.size
        cls = [classname, fields, count]
        classref = @classref.key?(cls) ? @classref[cls] : write_class(cls)
        @ref[objid] = @ref.length
        @stream.putc(TAG_OBJECT)
        @stream.write(classref.to_s)
        @stream.putc(TAG_OPENBRACE)
        if object.is_a?(Struct) then
          fields.each { |field| serialize(object[field]) }
        else
          vars.each { |var| serialize(object.instance_variable_get(var)) }
        end
        @stream.putc(TAG_CLOSEBRACE)
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
