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
 * formatter.hpp                                          *
 *                                                        *
 * hprose formatter unit for cpp.                         *
 *                                                        *
 * LastModified: May 29, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_FORMATTER_INCLUDED
#define HPROSE_FORMATTER_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/io/reader.hpp>
#include <hprose/io/writer.hpp>

#include <sstream>

namespace hprose
{
    class formatter
    {
    public:

        template<typename ValueType>
        inline static std::string serialize(const ValueType & value)
        {
            std::ostringstream stream;
            writer w(stream);
            w.serialize(value);
            return stream.str();
        }

        template<typename ValueType>
        inline static void serialize(std::ostream & stream, const ValueType & value)
        {
            writer w(stream);
            w.serialize(value);
        }

    #ifndef BOOST_NO_INITIALIZER_LISTS
        template<typename ValueType>
        inline static std::string serialize(const std::initializer_list<ValueType> & value)
        {
            std::ostringstream stream;
            writer w(stream);
            w.serialize(value);
            return stream.str();
        }

        template<typename ValueType>
        inline static void serialize(std::ostream & stream, const std::initializer_list<ValueType> & value)
        {
            writer w(stream);
            w.serialize(value);
        }
    #endif

        template<typename ValueType>
        inline static void unserialize(const std::string & data, ValueType & value)
        {
            std::istringstream stream(data);
            reader r(stream);
            r.unserialize(value);
        }

        template<typename ReturnType>
        inline static ReturnType unserialize(const std::string & data)
        {
            ReturnType ret = ReturnType();
            unserialize(data, ret);
            return ret;
        }

        inline static any unserialize(const std::string & data)
        {
            return unserialize<any>(data);
        }

        template<typename ValueType>
        inline static void unserialize(std::istream & stream, ValueType & value)
        {
            reader r(stream);
            r.unserialize(value);
        }

        template<typename ReturnType>
        inline static ReturnType unserialize(std::istream & stream)
        {
            ReturnType ret = ReturnType();
            unserialize(stream, ret);
            return ret;
        }

        inline static any unserialize(std::istream & stream)
        {
            return unserialize<any>(stream);
        }

    }; // class formatter

} // namespace hprose

#endif
