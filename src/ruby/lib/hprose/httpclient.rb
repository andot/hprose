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
# hprose/httpclient.rb                                     #
#                                                          #
# hprose http client for ruby                              #
#                                                          #
# LastModified: Dec 1, 2012                                #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

require "hprose/client"
require "net/http"
require "net/https"
require "uri"

module Hprose
  class HttpClient < Client
    include Tags
    @@cookie_manager = {}
    @@cookie_manager_mutex = Mutex.new
    public
    def initialize(uri = nil)
      Net::HTTP.version_1_2
      @http = Net::HTTP
      @header = {}
      @timeout = 30
      @keepalive = false
      @keepalive_timeout = 300
      super(uri)
    end
    attr_reader :header
    attr_accessor :timeout, :keepalive, :keepalive_timeout
    def proxy=(proxy)
      @http = case proxy
      when Net::HTTP then
        proxy
      when String then
        uri = URI.parse(proxy)
        Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)
      else
        proxy.superclass == Net::HTTP ? proxy : Net::HTTP
      end
    end
    def uri=(uri)
      @uri = URI.parse(uri) if not uri.nil?
    end
    attr_reader :uri
    protected
    class HttpInvokeContext
      attr_accessor :instream, :outstream
    end    
    def get_invoke_context
      context = HttpInvokeContext.new()
    end
    def get_output_stream(context)
      context.outstream = StringIO.new()
    end
    def send_data(context)
      request = @filter.output_filter(context.outstream.string)
      context.outstream.close()
      context.outstream = nil
      context.instream = StringIO.new(@filter.input_filter(_post(request)), 'rb')      
    end
    def get_input_stream(context)
      context.instream      
    end
    def end_invoke(context)
      context.instream.close()
      context.instream = nil
    end
    private
    def _post(request)
      httpclient = @http.new(@uri.host, @uri.port)
      httpclient.open_timeout = @timeout
      httpclient.read_timeout = @timeout
      httpclient.use_ssl = (@uri.scheme == 'https')
      #httpclient.set_debug_output $stderr
      httpclient.start
      headers = {'Content-Type' => 'application/hprose',
                 'Connection' => 'close'}
      if @keepalive then
        headers['Connection'] = 'keep-alive'
        headers['Keep-Alive'] = @keepalive_timeout.to_s
      end
      headers['Authorization'] = 'Basic ' << ["#{@uri.user}:#{@uri.password}"].pack('m').delete!("\n") unless @uri.user.nil? or @uri.password.nil?
      @header.each { |name, value|
        headers[name] = value
      }
      headers['Content-Length'] = request.size.to_s
      headers['Cookie'] = _get_cookie(@uri.host.downcase, @uri.path, @uri.scheme == 'https')
      reqpath = @uri.path
      reqpath << '?' << @uri.query unless @uri.query.nil?
      response = httpclient.request_post(reqpath, request, headers)
      case response
        when Net::HTTPSuccess then
        cookielist = []
        cookielist.concat(response['set-cookie'].split(',')) if response.key?('set-cookie')
        cookielist.concat(response['set-cookie2'].split(',')) if response.key?('set-cookie2')
        _set_cookie(cookielist, @uri.host.downcase)
        return response.body
      else
        raise Exception.new(response.message)
      end
    end
    def _set_cookie(cookielist, host)
      @@cookie_manager_mutex.synchronize do
        cookielist.each do |cookies|
          unless cookies == '' then
            cookies = cookies.strip.split(';')
            cookie = {}
            value = cookies[0].strip.split('=', 2)
            cookie['name'] = value[0]
            cookie['value'] = value.size == 2 ? value[1] : ''
            1.upto(cookies.size - 1) do |i|
              value = cookies[i].strip.split('=', 2)
              cookie[value[0].upcase] = value.size == 2 ? value[1] : ''
            end
            # Tomcat can return SetCookie2 with path wrapped in "
            if cookie.has_key?('PATH') then
              cookie['PATH'][0] = '' if cookie['PATH'][0] == ?"
              cookie['PATH'].chop! if cookie['PATH'][-1] == ?"
            else
              cookie['PATH'] = '/'
            end
            cookie['EXPIRES'] = Time.parse(cookie['EXPIRES']) if cookie.has_key?('EXPIRES')
            cookie['DOMAIN'] = cookie.has_key?('DOMAIN') ? cookie['COMAIN'].downcase : host
            cookie['SECURE'] = cookie.has_key?('SECURE')
            @@cookie_manager[cookie['DOMAIN']] = {} unless @@cookie_manager.has_key?(cookie['DOMAIN'])
            @@cookie_manager[cookie['DOMAIN']][cookie['name']] = cookie
          end
        end
      end
    end
    def _get_cookie(host, path, secure)
      cookies = []
      @@cookie_manager_mutex.synchronize do
        @@cookie_manager.each do |domain, cookielist|
          if host =~ Regexp.new(Regexp.escape(domain) + '$') then
            names = []
            cookielist.each do |name, cookie|
              if cookie.has_key?('EXPIRES') and Time.now <=> cookie['EXPIRES'] > 0 then
                names << name
              elsif path =~ Regexp.new('^' + Regexp.escape(cookie['PATH'])) then
                if ((secure and cookie['SECURE']) or not cookie['SECURE']) and cookie['value'] != '' then
                  cookies << (cookie['name'] + '=' + cookie['value'])
                end
              end
            end
            names.each { |name| @@cookie_manager[domain].delete(name) }
          end
        end
      end
      return cookies.join('; ')
    end
  end # class HttpClient
end # module Hprose