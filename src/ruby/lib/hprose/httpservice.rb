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
# hprose/httpservice.rb                                    #
#                                                          #
# hprose http service for ruby                             #
#                                                          #
# LastModified: Oct 28, 2012                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require "hprose/io"
require "hprose/service"
require "thread"

module Hprose
  class HttpService < Service
    attr_accessor :crossdomain
    attr_accessor :p3p
    attr_accessor :get
    def initialize()
      super()
      @p3p = false
      @get = true
    end
    def call(env)
      session = env['rack.session'] ? env['rack.session'] : {}
      header = {'Content-Type' => 'text/plain'}
      header['P3P'] = 'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD ' +
        'IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi ' +
        'PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT ' +
        'STA POL HEA PRE GOV"' if @p3p
      if @crossdomain then
        origin = env["HTTP_ORIGIN"];
        if (origin and origin != "null") then
          header['Access-Control-Allow-Origin'] = origin
          header['Access-Control-Allow-Credentials'] = 'true' 
        else
          header['Access-Control-Allow-Origin'] = '*' 
        end
      end            
      @on_send_header.call(env, header) until @on_send_header.nil?
      stream = StringIO.new()
      writer = Writer.new(stream)
      if (env['REQUEST_METHOD'] == 'GET') and @get then
        do_function_list(writer)
        body = stream.string
        stream.close()
        header['Content-Length'] = body.size.to_s
        return ['200 OK', header, [body]]
      end
      begin
        reader = Reader.new(StringIO.new(env['rack.input'].read, 'rb'))
        handle(reader, writer, session, env)
      ensure
        reader.stream.close()
        stream = writer.stream
        body = stream.string
        stream.close()
        header['Content-Length'] = body.size.to_s
        return [200, header, [body]]
      end
    end
  end # class HttpService
end # module Hprose