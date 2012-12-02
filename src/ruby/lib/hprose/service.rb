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
# hprose/service.rb                                        #
#                                                          #
# hprose service for ruby                                  #
#                                                          #
# LastModified: Dec 2, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require "hprose/common"
require "hprose/io"
require "thread"

module Hprose
  class Service
    private
    include Tags
    include ResultMode
    public
    attr_accessor :debug, :filter
    attr_accessor :on_before_invoke, :on_after_invoke
    attr_accessor :on_send_header, :on_send_error
    def initialize
      @functions = {}
      @funcNames = {}
      @resultMode = {}
      @debug = $DEBUG
      @filter = Filter.new
      @on_before_invoke = nil
      @on_after_invoke = nil
      @on_send_header = nil
      @on_send_error = nil
    end
    def add(*args, &block)
      case args.size
      when 1 then
        case args[0]
        when Array then add_functions(args[0])
        when Class then add_class_methods(args[0])
        when String, Symbol then block_given? ? add_block(args[0], &block) : add_function(args[0])
        when Proc, Method then add_function(args[0])
        else add_instance_methods(args[0])
        end
      when 2 then
        case args[0]
        when Array then
          case args[1]
          when Array then add_functions(args[0], args[1])
          else add_methods(args[0], args[1])
          end
        when Class then
          case args[1]
          when Class then add_class_methods(args[0], args[1])
          when String, Symbol then add_class_methods(args[0], args[0], args[1])
          else raise Exception, 'wrong arguments'
          end
        when String, Symbol then
          case args[1]
          when String, Symbol then add_function(args[0], args[1])
          else add_method(args[0], args[1])
          end
        when Proc, Method then
          case args[1]
          when String, Symbol then add_function(args[0], args[1])
          else raise Exception, 'wrong arguments'
          end
        else
          case args[1]
          when Class then add_instance_methods(args[0], args[1])
          when String, Symbol then add_instance_methods(args[0], nil, args[1])
          else raise Exception, 'wrong arguments'
          end
        end
      when 3 then
        case args[0]
        when Array then
          if args[1].nil? then
            case args[2]
            when Array then add_functions(args[0], args[2])
            else raise Exception, 'wrong arguments'
            end
          else
            case args[2]
            when Array, String, Symbol then add_methods(args[0], args[1], args[2])
            else raise Exception, 'wrong arguments'
            end
          end
        when Class then
          case args[2]
          when String, Symbol then
            if args[1].is_a?(Class) then
              add_class_methods(args[0], args[1], args[2])
            else
              add_instance_methods(args[1], args[0], args[2])
            end
          else raise Exception, 'wrong arguments'
          end
        when String, Symbol then
          case args[2]
          when String, Symbol then
            if args[1].nil? then
              add_function(args[0], args[2])
            else
              add_method(args[0], args[1], args[2])
            end
          else raise Exception, 'wrong arguments'
          end
        when Proc, Method then raise Exception, 'wrong arguments'
        else
          if args[1].is_a?(Class) and (args[2].is_a?(String) or args[2].is_a?(Symbol)) then
            add_instance_methods(args[0], args[1], args[2])
          else
            raise Exception, 'wrong arguments'
          end
        end
      else raise Exception, 'wrong arguments'
      end
    end
    def add_missing_function(function, resultMode = Normal)
      add_function(function, '*', resultMode)
    end
    def add_block(methodname, resultMode = Normal, &block)
      if block_given? then
        methodname = methodname.to_s if methodname.is_a?(Symbol)
        aliasname = methodname.downcase
        @functions[aliasname] = block
        @funcNames[aliasname] = methodname
        @resultMode[aliasname] = resultMode
      else
        raise Exception, 'block must be given'
      end
    end
    def add_function(function, aliasname = nil, resultMode = Normal)
      function = function.to_s if function.is_a?(Symbol)
      aliasname = aliasname.to_s if aliasname.is_a?(Symbol)
      if function.is_a?(String) then
        aliasname = function if aliasname.nil?
        function = Object.method(function)
      end
      unless function.is_a?(Proc) or function.is_a?(Method) or function.respond_to?(:call) then
        raise Exception, 'function must be callable'
      end
      if aliasname.nil? then
        if function.is_a?(Method) then
          aliasname = function.inspect
          aliasname[/#(.*?)#/] = ''
          aliasname[/>$/] = ''
          aliasname[/<(.*?)>\./] = '' if !aliasname[/<(.*?)>\./].nil?
        else
          raise Exception, 'need a alias name for function'
        end
      end
      name = aliasname.downcase
      @functions[name] = function
      @funcNames[name] = aliasname
      @resultMode[name] = resultMode
    end
    def add_functions(functions, aliases = nil, resultMode = Normal)
      unless functions.is_a?(Array) then
        raise Exception, 'argument functions is not an array'
      end
      count = functions.size
      unless aliases.nil? or aliases.is_a?(Array) and count == aliases.size then
        raise Exception, 'the count of functions is not matched with aliases'
      end
      count.times do |i|
        function = functions[i]
        if aliases.nil? then
          add_function(function, nil, resultMode)
        else
          add_function(function, aliases[i], resultMode)
        end
      end
    end
    def add_method(methodname, belongto, aliasname = nil, resultMode = Normal)
      function = belongto.method(methodname)
      add_function(function, (aliasname.nil? ? methodname : aliasname), resultMode)
    end
    def add_methods(methods, belongto, aliases = nil, resultMode = Normal)
      unless methods.is_a?(Array) then
        raise Exception, 'argument methods is not an array'
      end
      aliases = aliases.to_s if aliases.is_a?(Symbol)
      count = methods.size
      if aliases.is_a?(String) then
        alias_prefix = aliases
        aliases = Array.new(count) { |i| alias_prefix + '_' + methods[i].to_s }
      end
      if not aliases.nil? and count != aliases.size then
        raise Exception, 'The count of methods is not matched with aliases'
      end
      count.times do |i|
        method = methods[i]
        function = belongto.method(method)
        add_function(function, (aliases.nil? ? method : aliases[i]), resultMode)
      end
    end
    def add_instance_methods(obj, cls = nil, alias_prefix = nil, resultMode = Normal)
      alias_prefix = alias_prefix.to_s if alias_prefix.is_a?(Symbol)
      cls = obj.class if cls.nil?
      methods = cls.public_instance_methods(false)
      aliases = Array.new(methods.size) do |i|
        if alias_prefix.nil? then
          methods[i].to_s
        else
          alias_prefix + '_' + methods[i].to_s
        end
      end
      methods.map! { |method| cls.instance_method(method).bind(obj) }
      add_functions(methods, aliases, resultMode)
    end
    def add_class_methods(cls, execcls = nil, alias_prefix = nil, resultMode = Normal)
      alias_prefix = alias_prefix.to_s if alias_prefix.is_a?(Symbol)
      execcls = cls if execcls.nil?
      methods = cls.singleton_methods(false)
      aliases = Array.new(methods.size) do |i|
        if alias_prefix.nil? then
          methods[i].to_s
        else
          alias_prefix + '_' + methods[i].to_s
        end
      end
      methods.map! { |method| execcls.method(method) }
      add_functions(methods, aliases, resultMode)
    end
    protected
    def do_invoke(reader, writer, session, env)
      begin
        reader.reset
        name = reader.read_string
        aliasname = name.downcase
        args = []
        byref = false
        result = nil
        tag = reader.check_tags([TagList, TagCall, TagEnd])
        if tag == TagList then
          reader.reset
          args = reader.read_list(false)
          tag = reader.check_tags([TagTrue, TagCall, TagEnd])
          if tag == TagTrue then
            byref = true
            tag = reader.check_tags([TagCall, TagEnd])
          end
        end
        @on_before_invoke.call(env, name, args, byref) until @on_before_invoke.nil?
        result = nil
        if @functions.has_key?(aliasname) then
          function = @functions[aliasname]
          resultMode = @resultMode[aliasname]
          result = function.call(*(((function.arity > 0) and
                  (args.length + 1 == function.arity))? args + [session] : args))
        elsif @functions.has_key?('*') then
          function = @functions['*']
          resultMode = @resultMode['*']
          result = function.call(name, args)
        else
          raise Exception, "Can't find this function " << name
        end
        @on_after_invoke.call(env, name, args, byref, result) until @on_after_invoke.nil?
        if resultMode == RawWithEndTag then
          writer.stream.write(result)
          return
        elsif resultMode == Raw then
          writer.stream.write(result)            
        else
          writer.stream.putc(TagResult)
          if resultMode == Serialized then
            writer.stream.write(result)
          else
            writer.reset
            writer.serialize(result)
            if byref then
              writer.stream.putc(TagArgument)
              writer.reset
              writer.write_list(args, false)
            end
          end
        end
      end while tag == TagCall
      writer.stream.putc(TagEnd)
    end
    def do_function_list(writer)
      writer.stream.putc(TagFunctions)
      writer.write_list(@funcNames.values, false)
      writer.stream.putc(TagEnd)
    end
    def handle(reader, writer, session, env)
      begin
        except_tags = [TagCall, TagEnd]
        tag = reader.check_tags(except_tags)
        case tag
        when TagCall then do_invoke(reader, writer, session, env)
        when TagEnd then do_function_list(writer)
        end
      rescue ::Exception => e
        error = @debug ? e.backtrace.unshift(e.message).join("\r\n") : e.message
        @on_send_error.call(env, error) until @on_send_error.nil?
        writer.stream.seek(0)
        writer.stream.truncate(0)
        writer.reset
        writer.stream.putc(TagError)
        writer.write_string(error, false)
        writer.stream.putc(TagEnd)
      end
    end
  end # class Service
end # module Hprose
