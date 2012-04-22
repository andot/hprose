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
 * httpclient.hpp                                         *
 *                                                        *
 * hprose asio http client class unit for Cpp.            *
 *                                                        *
 * LastModified: May 29, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_ASIO_HTTPCLIENT_INCLUDED
#define HPROSE_ASIO_HTTPCLIENT_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/client/client.hpp>
#include <hprose/client/cookie.hpp>
#include <boost/asio.hpp>
#ifndef HPROSE_NO_OPENSSL
#include <boost/asio/ssl.hpp>
#endif
#include <boost/thread/mutex.hpp>

namespace hprose
{
    namespace asio
    {
        using boost::asio::ip::tcp;

        class httpclient : public client
        {
        public: // structors

            httpclient(const std::string & uri = "http://localhost/");

            virtual ~httpclient();

        public:

            virtual void use_service(const std::string & uri);

            void set_header(const std::string & key, const std::string & value);

            void set_keep_alive(bool keep_alive, int timeout = 300);

            void set_user_agent(const std::string & user_agent);

        protected:

            virtual void * get_invoke_context();

            virtual std::ostream & get_output_stream(void * context);

            virtual void send_data(void * context);

            virtual std::istream & get_input_stream(void * context);

            virtual void end_invoke(void * context);

        private:

            void parse_uri();

        private:

            class httpcontext
            {
            public: // structors

                httpcontext(boost::asio::io_service & ios);

            public:

                void post(const std::string & host, const std::string & port, const std::string & path, const std::map<std::string, std::string> & headers, bool secure);

            private:

                void clear();

                bool connect(tcp::socket & socket, const std::string & host, const std::string & port, bool secure);
 
                void write(boost::asio::streambuf & buf, bool secure);

                size_t read_line(boost::asio::streambuf & buf, bool secure);

            private:

                std::string alive_host;
                std::string alive_port;
                clock_t alive_time;

                tcp::resolver resolver;
                tcp::socket socket;

            #ifndef HPROSE_NO_OPENSSL
                boost::asio::ssl::context ssl_context;
                boost::asio::ssl::stream<tcp::socket> ssl_socket;
            #endif

                boost::asio::streambuf request;
                boost::asio::streambuf response;

            public:

                std::iostream request_stream;
                std::iostream response_stream;

            };

        private:

            std::string protocol;
            std::string user;
            std::string password;
            std::string host;
            std::string port;
            std::string path;

            std::map<std::string, std::string> headers;
            std::stack<httpcontext *> pool;
            boost::mutex mutex;
            boost::asio::io_service ios;

        }; // class httpclient

    } // namespace asio

} // namespace hprose

#endif
