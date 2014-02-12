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
# hprose/client.rb                                         #
#                                                          #
# hprose client for ruby                                   #
#                                                          #
# LastModified: Jan 4, 2014                                #
# Author: Ma Bingyao <andot@hprose.com>                    #
#                                                          #
############################################################

require "hprose/common"
require "hprose/io"

module Hprose
  class Client
    include Tags
    include ResultMode
    public
    def initialize(uri = nil)
      @onerror = nil
      @filter = Filter.new
      @simple = false
      self.uri = uri
    end
    attr_accessor :filter, :simple
    def onerror(&block)
      @onerror = block if block_given?
      @onerror
    end
    def onerror=(error_handler)
      error_handler = error_handler.to_sym if error_handler.is_a?(String)
      if error_handler.is_a?(Symbol) then
        error_handler = Object.method(error_handler)
      end
      @onerror = error_handler
    end
    def use_service(uri = nil, namespace = nil)
      self.uri = uri
      Proxy.new(self, namespace)
    end
    def [](namespace)
      Proxy.new(self, namespace)
    end
    def invoke(methodname, args = [], byref = false, resultMode = Normal, simple = nil, &block)
      simple = @simple if simple.nil?
      if block_given? then
        Thread.start do
          begin
            result = _invoke(methodname, args, byref, resultMode, simple)
            case block.arity
            when 0 then yield
            when 1 then yield result
            when 2 then yield result, args
            end
          rescue ::Exception => e
            @onerror.call(methodname, e) if (@onerror.is_a?(Proc) or
                                             @onerror.is_a?(Method) or
                                             @onerror.respond_to?(:call))
          end
        end
      else
        return _invoke(methodname, args, byref, resultMode, simple)
      end
    end
    def uri=(uri)
      raise NotImplementedError.new("#{self.class.name}#uri is an abstract attr")
    end
    protected
    def get_invoke_context
      raise NotImplementedError.new("#{self.class.name}#get_invoke_context is an abstract method")
    end
    def get_output_stream(context)
      raise NotImplementedError.new("#{self.class.name}#get_output_stream is an abstract method")
    end
    def send_data(context)
      raise NotImplementedError.new("#{self.class.name}#send_data is an abstract method")
    end
    def get_input_stream(context)
      raise NotImplementedError.new("#{self.class.name}#get_input_stream is an abstract method")
    end
    def end_invoke(context)
      raise NotImplementedError.new("#{self.class.name}#end_invoke is an abstract method")
    end
    private
    def _invoke(methodname, args, byref, resultMode, simple)
      context = self.get_invoke_context
      stream = self.get_output_stream(context)
      writer = simple ? SimpleWriter.new(stream) : Writer.new(stream)
      stream.putc(TagCall)
      writer.write_string(methodname.to_s)
      if (args.size > 0 or byref) then
        writer.reset
        writer.write_list(args)
        writer.write_boolean(true) if byref
      end
      stream.putc(TagEnd)
      result = nil
      begin
        self.send_data(context)
        stream = self.get_input_stream(context)
        if resultMode == RawWithEndTag then
          result = stream.string
          return result
        end
        if resultMode == Raw then
          result = stream.string.chop!
          return result
        end
        reader = Reader.new(stream)
        loop do
          tag = reader.check_tags([TagResult, TagArgument, TagError, TagEnd])
          break if tag == TagEnd
          case tag
          when TagResult then
            if resultMode == Serialized then
              s = reader.read_raw
              result = s.string
              s.close
            else
              reader.reset
              result = reader.unserialize
            end
          when TagArgument then
            reader.reset
            a = reader.read_list
            args.each_index { |i| args[i] = a[i] }
          when TagError then
            reader.reset
            result = Exception.new(reader.read_string())
          end
        end
      ensure
        self.end_invoke(context)
      end
      raise result if result.is_a?(Exception)
      return result
    end
    def method_missing(methodname, *args, &block)
      self.invoke(methodname, args, &block)
    end

    class Proxy
      def initialize(client, namespace = nil)
        @client = client
        @namespace = namespace
      end
      def [](namespace)
        Proxy.new(@client, @namespace.to_s + '_' + namespace.to_s)
      end
      def method_missing(methodname, *args, &block)
        methodname = @namespace.to_s + '_' + methodname.to_s unless @namespace.nil?
        @client.invoke(methodname, args, &block)
      end
    end # class Proxy
  end # class Client
end # module Hprose