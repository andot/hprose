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
 * client.hpp                                             *
 *                                                        *
 * hprose client class for Cpp.                           *
 *                                                        *
 * LastModified: Jun 6, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_CLIENT_INCLUDED
#define HPROSE_CLIENT_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/io.hpp>
#include <boost/thread.hpp>

namespace hprose
{
    class client
    {
    protected: // structors

        client()
        {
        }

        client(const std::string & uri)
        {
            use_service(uri);
        }

        virtual ~client()
        {
        }

    protected:

        virtual void * get_invoke_context() = 0;

        virtual void send_data(void * context) = 0;

        virtual void end_invoke(void * context) = 0;

        virtual std::ostream & get_output_stream(void * context) = 0;

        virtual std::istream & get_input_stream(void * context) = 0;

    public:

        virtual void use_service(const std::string & uri)
        {
            this->uri = uri;
        }

        template<typename ReturnType>
        inline ReturnType invoke(const std::string & name)
        {
            std::vector<any> args;
            return invoke<ReturnType>(name, args);
        }

        template<typename ReturnType>
        inline void invoke(ReturnType & ret, const std::string & name)
        {
            std::vector<any> args;
            invoke(ret, name, args);
        }

    #ifndef BOOST_NO_INITIALIZER_LISTS
        template<typename ReturnType, typename ArgType>
        inline ReturnType invoke(const std::string & name, const std::initializer_list<ArgType> & args)
        {
            return invoke<ReturnType>(name, args, false);
        }

        template<typename ReturnType, typename ArgType>
        inline void invoke(ReturnType & ret, const std::string & name, const std::initializer_list<ArgType> & args)
        {
            invoke(ret, name, args, false);
        }
    #endif

        template<typename ReturnType, typename ArgsType>
        inline ReturnType invoke(const std::string & name, ArgsType & args, bool ref = false)
        {
            ReturnType ret = ReturnType();
            invoke(ret, name, args, ref);
            return ret;
        }

        template<typename ReturnType, typename ArgsType>
        void invoke(ReturnType & ret, const std::string & name, ArgsType & args, bool ref = false)
        {
            std::string error;
            void * context = 0;
            context = get_invoke_context();
            try
            {
                do_output(name, args, ref, get_output_stream(context));
                send_data(context);
                do_input(ret, args, error, get_input_stream(context));
            }
            catch (...)
            {
            }
            end_invoke(context);
            if (!error.empty())
            {
                HPROSE_THROW_EXCEPTION(error);
            }
        }

        template<typename ReturnType, typename Functor>
        inline void async_invoke(const std::string & name, Functor func)
        {
            static std::vector<any> args;
            async_invoke<ReturnType>(name, args, func, false);
        }

        template<typename ReturnType, typename ArgsType, typename Functor>
        inline void async_invoke(const std::string & name, ArgsType & args, Functor func, bool ref = false)
        {
            boost::thread thread(async<ReturnType, ArgsType, Functor>(*this, name, args, func, ref));
        }

    private:

        template<typename ReturnType, typename ArgsType, typename Functor>
        class async
        {
        public:

            async(client & c, const std::string & name, ArgsType & args, Functor func, bool ref)
              : c(c), name(name), args(args), func(func), ref(ref)
            {
            }

        public:

            inline void operator()()
            {
                ReturnType ret = ReturnType();
                c.invoke(ret, name, args, ref);
                func(ret, args);
            }

        private:

            client & c;
            std::string name;
            ArgsType & args;
            Functor func;
            bool ref;

        }; // class async

    private:

        template<typename ReturnType, typename ArgsType>
        void do_input(ReturnType & ret, ArgsType & args, std::string & error, std::istream & stream)
        {
            reader r(stream);
            while (true)
            {
                switch (r.check_tags(ResultTags))
                {
                    case TagResult:
                        r.unserialize(ret);
                        break;
                    case TagArgument:
                        r.read_list(args, false);
                        break;
                    case TagError:
                        r.read_string(error);
                        return;
                    case TagEnd:
                        return;
                }
            }
        }

        template<typename ArgsType>
        void do_output(const std::string & name, ArgsType & args, bool ref, std::ostream & stream)
        {
            writer w(stream);
            stream << TagCall;
            w.write_string(name, false);
            w.write_list(args, false);
            if (ref)
            {
                w.write_bool(true);
            }
            stream << TagEnd;
        }

        template<typename ArgsType, size_t ArraySize>
        void do_output(const std::string & name, ArgsType (&args)[ArraySize], bool ref, std::ostream & stream)
        {
            writer w(stream);
            stream << TagCall;
            w.write_string(name, false);
            w.write_list(args, false);
            if (ref)
            {
                w.write_bool(true);
            }
            stream << TagEnd;
        }

    protected:

        std::string uri;

    }; // class client

} // namespace hprose

#endif
