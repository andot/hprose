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
 * exception.hpp                                          *
 *                                                        *
 * hprose exception unit for cpp.                         *
 *                                                        *
 * LastModified: May 29, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_EXCEPTION_INCLUDED
#define HPROSE_EXCEPTION_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/config.hpp>

#include <boost/throw_exception.hpp>

#ifndef HPROSE_DEBUG_MODE
#include <string>
#define HPROSE_EXCEPTION(s) hprose::exception(s)
#else
#include <sstream>
#define HPROSE_EXCEPTION(s) hprose::exception(s, __FILE__, __LINE__)
#endif

// HPROSE_THROW_EXCEPTION(s) = boost::throw_exception(hprose::exception(s))
// Use HPROSE_THROW_EXCEPTION instead of boost::throw_exception can avoid some warnings
#ifndef BOOST_EXCEPTION_DISABLE
#define HPROSE_THROW_EXCEPTION(s) throw boost::enable_current_exception(boost::enable_error_info(HPROSE_EXCEPTION(s)))
#else
#define HPROSE_THROW_EXCEPTION(s) throw HPROSE_EXCEPTION(s)
#endif

namespace hprose
{
    class exception : public std::exception
    {
    public:

    #ifdef HPROSE_DEBUG_MODE
        exception(const std::string & message, const char * file, unsigned int line) throw()
        {
            std::ostringstream stream;
            stream << "[" << file << ":" << line << "] " << message;
            this->message = stream.str();
        }
    #endif

        exception(const std::string & message) throw()
          : message(message)
        {
        }

        virtual ~exception() throw()
        {
        }

        virtual const char * what() const throw()
        {
            return message.c_str();
        }

    private:

        std::string message;

    }; // class exception

} // namespace hprose

#endif
