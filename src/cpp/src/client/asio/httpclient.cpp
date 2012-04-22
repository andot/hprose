/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * httpclient.cpp                                         *
 *                                                        *
 * hprose asio http client class unit for Cpp.            *
 *                                                        *
 * LastModified: Jun 3, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#include <hprose/client/asio/httpclient.hpp>

namespace hprose
{
    namespace asio
    {
        httpclient::httpclient(const std::string & uri)
        {
            use_service(uri);
            set_keep_alive(true);
            set_header("Content-Type", "application/hprose");
            set_user_agent("Hprose Http Client for Cpp (asio)");
        }

        httpclient::~httpclient()
        {
            boost::mutex::scoped_lock lock(mutex);
            while (!pool.empty())
            {
                httpcontext * c = pool.top();
                pool.pop();
                delete c;
            }
        }

        void httpclient::use_service(const std::string & uri)
        {
            client::use_service(uri);
            parse_uri();
        }

        inline void httpclient::set_keep_alive(bool keep_alive, int timeout)
        {
            if (keep_alive)
            {
                std::ostringstream stream;
                stream << "keep-alive\r\nKeep-Alive: " << timeout;
                set_header("Connection", stream.str());
            }
            else
            {
                set_header("Connection", "close");
            }
        }

        inline void httpclient::set_header(const std::string & key, const std::string & value)
        {
            headers[key] = value;
        }

        inline void httpclient::set_user_agent(const std::string & user_agent)
        {
            headers["User-Agent"] = user_agent;
        }

        void * httpclient::get_invoke_context()
        {
            boost::mutex::scoped_lock lock(mutex);
            if (pool.size() > 0)
            {
                httpcontext * c = pool.top();
                pool.pop();
                return c;
            }
            else
            {
                return new httpcontext(ios);
            }
        }

        std::ostream & httpclient::get_output_stream(void * context)
        {
            if (context)
            {
                return (static_cast<httpcontext *>(context))->request_stream;
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Can''t get output stream.");
            }
        }

        void httpclient::send_data(void * context)
        {
            if (context)
            {
                httpcontext & c = *static_cast<httpcontext *>(context);
                c.post(host, port, path, headers, protocol == "https");
            }
        }

        std::istream & httpclient::get_input_stream(void * context)
        {
            if (context)
            {
                return (static_cast<httpcontext *>(context))->response_stream;
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Can''t get input stream.");
            }
        }

        void httpclient::end_invoke(void * context)
        {
            if (context)
            {
                boost::mutex::scoped_lock lock(mutex);
                httpcontext * c = static_cast<httpcontext *>(context);
                pool.push(c);
            }
        }

        void httpclient::parse_uri()
        {
            std::string surl;
            std::string::size_type x, y;
            protocol = "http";
            user = "";
            password = "";
            port = "80";
            x = uri.find("://");
            if (x != std::string::npos)
            {
                protocol = uri.substr(0, x);
                surl = uri.substr(x + 3);
            }
            else
            {
                surl = uri;
            }
            std::transform(protocol.begin(), protocol.end(), protocol.begin(), tolower);
            if (protocol == "https")
            {
                port = "443";
            }
            x = surl.find('@');
            y = surl.find('/');
            if ((x != std::string::npos) && ((x < y) || (y == std::string::npos)))
            {
                user = surl.substr(0, x);
                surl.erase(0, x + 1);
                x = user.find(':');
                if (x != std::string::npos)
                {
                    password = user.substr(x + 1);
                    user.erase(x);
                }
            }
            x = surl.find('/');
            if (x != std::string::npos)
            {
                host = surl.substr(0, x);
                surl.erase(0, x + 1);
            }
            else
            {
                host = surl;
                surl = "";
            }
            bool ipv6 = host[0] == '[';
            if (ipv6)
            {
                x = host.find(']');
                if ((x + 1 < host.size()) && (host[x + 1] == ':'))
                {
                    port = host.substr(x + 2);
                }
                host = host.substr(1, x - 1);
            }
            else
            {
                x = host.find(':');
                if (x != std::string::npos)
                {
                    port = host.substr(x + 1);
                    host.erase(x);
                }
            }
            set_header("Host", (ipv6 ? ('[' + host + ']') : host) + ((port == "80") ? std::string() : (':' + port)));
            x = surl.find('?');
            if (x != std::string::npos)
            {
                path = '/' + surl.substr(0, x);
            }
            else
            {
                path = '/' + surl;
            }
            if (host == "")
            {
                host = "localhost";
            }
        }

        httpclient::httpcontext::httpcontext(boost::asio::io_service & ios)
          : resolver(ios),
            socket(ios),
        #ifndef HPROSE_NO_OPENSSL
            ssl_context(ios, boost::asio::ssl::context::sslv23),
            ssl_socket(ios, ssl_context),
        #endif
            request_stream(&request),
            response_stream(&response)
        {
        }

        void httpclient::httpcontext::post(const std::string & host, const std::string & port, const std::string & path, const std::map<std::string, std::string> & headers, bool secure)
        {
            if (!connect(
            #ifndef HPROSE_NO_OPENSSL
                secure ?
                    ssl_socket.next_layer() :
            #endif
                    socket, host, port, secure)) return;
            boost::system::error_code error = boost::asio::error::host_not_found;
            boost::asio::streambuf header;
            std::iostream header_stream(&header);
            header_stream << "POST " << ((path == "/*") ? std::string("*") : path) << " HTTP/1.1\r\n";;
            for (std::map<std::string, std::string>::const_iterator iter = headers.begin(); iter != headers.end(); iter++)
            {
                header_stream << iter->first << ": " << iter->second << "\r\n";
            }
            std::string cookie = cookies::get_cookie(alive_host, path, secure);
            if (!cookie.empty())
            {
                header_stream << "Cookie: " << cookie << "\r\n";
            }
            header_stream << "Content-Length: " << request.size() << "\r\n\r\n";
            if (request.size() >= 64 * 1024)
            {
                write(header, secure);
                write(request, secure);
            }
            else
            {
                header_stream << &request;
                write(header, secure);
            }
            if (response.size())
            {
                response.consume(response.size());
            }
            std::string s;
            size_t bytes = 0, len = 0;
            bool toclose = false, chunked = false;
            while ((bytes = read_line(header, secure)) > 2)
            {
                header_stream >> s;
                if (_strcmpi(s.c_str(), "Content-Length:") == 0)
                {
                    header_stream >> len;
                }
                else if (_strcmpi(s.c_str(), "Connection:") == 0)
                {
                    header_stream >> s;
                    if (_strcmpi(s.c_str(), "close") == 0)
                    {
                        toclose = true;
                    }
                }
                else if (_strcmpi(s.c_str(), "Keep-Alive:") == 0)
                {
                    std::getline(header_stream, s, '=');
                    if (_strcmpi(s.c_str(), " timeout") == 0)
                    {
                        clock_t timeout;
                        header_stream >> timeout;
                        alive_time = clock() + timeout * CLOCKS_PER_SEC;
                    }
                }
                else if (_strcmpi(s.c_str(), "Transfer-Encoding:") == 0)
                {
                    header_stream >> s;
                    if (_strcmpi(s.c_str(), "chunked") == 0)
                    {
                        chunked = true;
                    }
                }
                else if ((_strcmpi(s.c_str(), "Set-Cookie:") == 0) || (_strcmpi(s.c_str(), "Set-Cookie2:") == 0))
                {
                    std::getline(header_stream, s);
                    cookies::set_cookie(alive_host, s.substr(1, s.size() - 2));
                    continue;
                }
                header_stream.ignore((std::numeric_limits<int>::max)(), '\n');
            }
            header.consume(2);
            if (chunked)
            {
                while (true)
                {
                    size_t chunk_size = 0;
                    read_line(header, secure);
                    header_stream >> std::hex >> chunk_size >> std::dec;
                    header.consume(2);
                    if (chunk_size)
                    {
                        bytes = 0 ;
                        while (true)
                        {
                            bytes += read_line(header, secure);
                            if (bytes > chunk_size)
                            {
                                for (size_t i = 0; i < chunk_size; i++)
                                {
                                    response_stream << (char)header_stream.get();
                                };
                                header.consume(2);
                                break;
                            }
                        }
                    }
                    else
                    {
                        header.consume(2);
                        break;
                    }
                }
            }
            else
            {
                bool nosize = !len;
                size_t n = std::min<size_t>(len, header.size());
                for (size_t i = 0; i < n; ++i, --len)
                {
                    response_stream << (char)header_stream.get();
                };
                if (nosize)
                {
                    len = (std::numeric_limits<int>::max)();
                }
                if (len)
                {
                    char buf[1024];
                    while (len)
                    {
                        size_t n =
                        #ifndef HPROSE_NO_OPENSSL
                            secure ?
                                ssl_socket.read_some(boost::asio::buffer(buf), error) :
                        #endif
                                socket.read_some(boost::asio::buffer(buf), error);
                        if (error) break;
                        response_stream.write(buf, n);
                        len -= n;
                    }
                }
            }
            if (toclose)
            {
                (
                #ifndef HPROSE_NO_OPENSSL
                    secure ?
                        ssl_socket.next_layer() :
                #endif
                        socket).close();
                clear();
            }
        }

        inline void httpclient::httpcontext::clear()
        {
            alive_host.clear();
            alive_port.clear();
            alive_time = 0;
        }

        bool httpclient::httpcontext::connect(tcp::socket & socket, const std::string & host, const std::string & port, bool secure)
        {
            if (socket.is_open() && (alive_host == host) && (alive_port == port) && (clock() < alive_time))
            {
                return true;
            }
            tcp::resolver::query query(host, port);
            tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);
            tcp::resolver::iterator end;
            boost::system::error_code error = boost::asio::error::host_not_found;
            while (error && endpoint_iterator != end)
            {
               socket.close();
               socket.connect(*endpoint_iterator++, error);
            }
            if (error)
            {
                clear();
                return false;
            }
            else
            {
            #ifndef HPROSE_NO_OPENSSL
                if (secure)
                {
                    ssl_socket.handshake(boost::asio::ssl::stream_base::client, error);
                    if (error)
                    {
                        socket.close();
                        return false;
                    }
                }
            #endif
                alive_host = host;
                alive_port = port;
                return true;
            }
        }

        inline void httpclient::httpcontext::write(boost::asio::streambuf & buf, bool secure)
        {
        #ifndef HPROSE_NO_OPENSSL
            if (secure)
            {
                boost::asio::write(ssl_socket, buf);
            }
            else
        #endif
            {
                boost::asio::write(socket, buf);
            }
        }

        size_t httpclient::httpcontext::read_line(boost::asio::streambuf & buf, bool secure)
        {
            return
            #ifndef HPROSE_NO_OPENSSL
                secure ?
                    boost::asio::read_until(ssl_socket, buf, "\r\n") :
            #endif
                    boost::asio::read_until(socket, buf, std::string("\r\n"));
        }

    } // namespace asio

} // namespace hprose
