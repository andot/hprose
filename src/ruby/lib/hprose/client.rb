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
# LastModified: Jun 20, 2011                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require "hprose/io"

module Hprose
  class Client
    include Tags
    public
    def initialize(uri = nil)
      @onerror = nil;
      self.uri = uri;
    end
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
      self.uri = uri;
      Proxy.new(self, namespace)
    end
    def [](namespace)
      Proxy.new(self, namespace)
    end
    def invoke(methodname, args = [], byref = false, &block)
      if block_given? then
        Thread.start do
          begin
            result = _invoke(methodname, args, byref)
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
        return _invoke(methodname, args, byref)
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
    def _invoke(methodname, args, byref = false)
      context = self.get_invoke_context()
      stream = self.get_output_stream(context)
      writer = Writer.new(stream)
      stream.putc(TAG_CALL)
      writer.write_string(methodname.to_s, false)
      if (args.size > 0 or byref) then
        writer.reset()
        writer.write_list(args, false)
        writer.write_boolean(true) if byref
      end
      stream.putc(TAG_END)
      self.send_data(context)
      result = nil
      stream = self.get_input_stream(context)
      reader = Reader.new(stream)
      loop do
        tag = reader.check_tags([TAG_RESULT, TAG_ARGUMENT, TAG_ERROR, TAG_END])
        break if tag == TAG_END
        case tag
        when TAG_RESULT then
          reader.reset()
          result = reader.unserialize()
        when TAG_ARGUMENT then
          reader.reset()
          a = reader.read_list()
          args.each_index { |i| args[i] = a[i] }
        when TAG_ERROR then
          reader.reset()
          result = Exception.new(reader.read_string())
        end
      end
      self.end_invoke(context)
      raise result if result.is_a?(Exception)
      return result
    end
    def method_missing(methodname, *args, &block)
      self.invoke(methodname, args, &block)
    end

    class Proxy
      def initialize(phprpc_client, namespace = nil)
        @phprpc_client = phprpc_client
        @namespace = namespace
      end
      def [](namespace)
        Proxy.new(@phprpc_client, @namespace.to_s + '_' + namespace.to_s)
      end
      def method_missing(methodname, *args, &block)
        methodname = @namespace.to_s + '_' + methodname.to_s unless @namespace.nil?
        @phprpc_client.invoke(methodname, args, &block)
      end
    end # class Proxy
  end # class Client
end # module Hprose