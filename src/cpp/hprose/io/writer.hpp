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
 * writer.hpp                                             *
 *                                                        *
 * hprose writer unit for cpp.                            *
 *                                                        *
 * LastModified: Jun 27, 2011                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_WRITER_INCLUDED
#define HPROSE_WRITER_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/io/classes.hpp>
#include <hprose/io/tags.hpp>
#include <hprose/io/types.hpp>

#include <ostream>

namespace hprose
{
    class writer
    {
    public:

        writer(std::ostream & stream)
          : stream(stream)
        {
        }

    public:

        template<typename ValueType>
        inline void serialize(const ValueType & value)
        {
            serialize(value, NonCVType<ValueType>());
        }

        template<typename ValueType, size_t ArraySize>
        inline void serialize(const ValueType (&value)[ArraySize])
        {
            serialize(value, NonCVArrayType<ValueType>());
        }

    #ifndef BOOST_NO_INITIALIZER_LISTS
        template<typename ValueType>
        inline void serialize(const std::initializer_list<ValueType> & value)
        {
            serialize(value, NonCVListType<ValueType>());
        }
    #endif

    public:

        inline void write_null()
        {
            stream << TagNull;
        }

        inline void write_empty()
        {
            stream << TagEmpty;
        }

        template<typename ValueType>
        inline void write_bool(const ValueType & b)
        {
            stream << (b ? TagTrue : TagFalse);
        }

        template<typename ValueType>
        inline void write_enum(const ValueType & e)
        {
            HPROSE_STATIC_ASSERT(NonCVType<ValueType>::value == EnumType::value, "Require EnumType");
            write_integer(static_cast<int>(e), std::tr1::true_type());
        }

        template<typename ValueType>
        inline void write_integer(const ValueType & i)
        {
            HPROSE_STATIC_ASSERT(
                (NonCVType<ValueType>::value == ByteType::value) ||
                (NonCVType<ValueType>::value == CharType::value) ||
                (NonCVType<ValueType>::value == IntegerType::value), "Require [ByteType, CharType, IntegerType]");
            write_integer(i, std::tr1::is_signed<ValueType>());
        }

        template<typename ValueType>
        inline void write_long(const ValueType & l)
        {
            HPROSE_STATIC_ASSERT(
                (NonCVType<ValueType>::value == ByteType::value) ||
                (NonCVType<ValueType>::value == CharType::value) ||
                (NonCVType<ValueType>::value == IntegerType::value) ||
                (NonCVType<ValueType>::value == LongType::value), "Require [ByteType, CharType, IntegerType, LongType]");
            write_long(l, std::tr1::is_signed<ValueType>());
        }

        inline void write_long(const bigint & l)
        {
            stream << TagLong << l << TagSemicolon;
        }

        inline void write_nan()
        {
            stream << TagNaN;
        }

        inline void write_infinity(bool positive)
        {
            stream << TagInfinity << (positive ? TagPos : TagNeg);
        }

        template<typename ValueType>
        void write_double(const ValueType & d)
        {
            HPROSE_STATIC_ASSERT(NonCVType<ValueType>::value == DoubleType::value, "Require DoubleType");
            if (d != d)
            {
                write_nan();
            }
            else if (d == std::numeric_limits<ValueType>::infinity())
            {
                write_infinity(true);
            }
            else if (d == -std::numeric_limits<ValueType>::infinity())
            {
                write_infinity(false);
            }
            else
            {
                stream.precision(std::numeric_limits<ValueType>::digits10);
                stream << TagDouble << d << TagSemicolon;
            }
        }

        inline void write_datetime(ctime t, bool check_ref = true)
        {
            if (write_ref(t, check_ref))
            {
                tm m;
                write_datetime(*t.get_gmt_tm(&m));
            }
        }

        template<typename ValueType>
        inline void write_utf8char(const ValueType & c)
        {
            HPROSE_STATIC_ASSERT(
                (NonCVType<ValueType>::value == CharType::value) ||
                (NonCVType<ValueType>::value == IntegerType::value) ||
                (NonCVType<ValueType>::value == LongType::value), "Require [CharType, IntegerType, LongType]");
            size_t len = utf8_encode(c, buf, UTFType<sizeof(ValueType)>());
            if (len)
            {
                stream << TagUTF8Char;
                stream.write(buf, len);
            }
            else
            {
                write_long(c);
            }
        }

        inline void write_utf8char(char c)
        {
        #ifdef BOOST_WINDOWS
            write_utf8char(ansi_to_unicode(c));
        #else
            if (is_ascii(c))
            {
                stream << TagUTF8Char << c;
            }
            else
            {
                write_long(c);
            }
        #endif
        }

        template<typename ValueType>
        void write_bytes(const ValueType & b, bool check_ref = true)
        {
            HPROSE_STATIC_ASSERT(NonCVType<ValueType>::value == BytesType::value, "Require BytesType");
            size_t n = b.size();
            if (write_ref(&b, check_ref))
            {
                stream << TagBytes;
                if (n > 0) write_int(n, stream);
                stream << TagQuote;
            #ifdef _MSC_VER
                stream.write(reinterpret_cast<const char *>(b.data()), n);
            #else
            #ifndef BOOST_NO_AUTO_DECLARATIONS
                for (auto itr = b.begin(); itr != b.end(); ++itr)
            #else
                for (BOOST_DEDUCED_TYPENAME ValueType::const_iterator itr = b.begin(); itr != b.end(); ++itr)
            #endif
                {
                    stream << *itr;
                }
            #endif
                stream << TagQuote;
            }
        }

        template<typename Element, typename Container>
        void write_bytes(const std::stack<Element, Container> & s, bool check_ref = true)
        {
        #ifdef _MSC_VER
            write_bytes(s._Get_container(), check_ref);
        #else
            size_t n = s.size();
            if (write_ref(&s, check_ref))
            {
                std::stack<Element, Container> temp = s;
                std::vector<Element> v;
                v.resize(n);
                for (size_t i = 1; i <= n; i++)
                {
                    v[n - i] = temp.top();
                    temp.pop();
                }
                write_bytes(v, false);
            }
        #endif
        }

        template<typename Element, typename Container>
        void write_bytes(const std::queue<Element, Container> & q, bool check_ref = true)
        {
        #ifdef _MSC_VER
            write_bytes(q._Get_container(), check_ref);
        #else
            size_t n = q.size();
            if (write_ref(&q, check_ref))
            {
                std::queue<Element, Container> temp = q;
                std::vector<Element> v;
                v.resize(n);
                for (size_t i = 0; i < n; i++)
                {
                    v[i] = temp.front();
                    temp.pop();
                }
                write_bytes(v, false);
            }
        #endif
        }

        template<typename ValueType>
        void write_bytes(const ValueType * b, size_t n, bool check_ref = true)
        {
            HPROSE_STATIC_ASSERT(NonCVListType<ValueType>::value == BytesType::value, "Require BytesType");
            if (check_ref)
            {
                references.push_back(any());
            }
            stream << TagBytes;
            if (n > 0) write_int(n, stream);
            stream << TagQuote;
            stream.write(reinterpret_cast<const char *>(b), n);
            stream << TagQuote;
        }

        template<typename ValueType, size_t ArraySize>
        inline void write_bytes(const ValueType (&value)[ArraySize], bool check_ref = true)
        {
            write_bytes(value, ArraySize, check_ref);
        }

    #ifndef BOOST_NO_INITIALIZER_LISTS
        template<typename ValueType>
        inline void write_bytes(const std::initializer_list<ValueType> & l, bool check_ref = true)
        {
            if (write_ref(&l, check_ref))
            {
                write_bytes(l.begin(), l.size(), false);
            }
        }
    #endif

        template<typename ValueType>
        inline void write_string(const ValueType & s, bool check_ref = true)
        {
            typedef BOOST_DEDUCED_TYPENAME NonCVElementType<ValueType>::type element;
            write_string(std::basic_string<element>(s), check_ref);
        }

        template<typename Element, typename Traits, typename Allocator>
        inline void write_string(const std::basic_string<Element, Traits, Allocator> & s, bool check_ref = true)
        {
            if (write_ref(s, check_ref))
            {
                stream << TagString;
                write_utf8string(utf8_encode(s), utf16_size(s), stream);
            }
        }

        inline void write_string(const std::string & s, bool check_ref = true)
        {
        #ifdef BOOST_WINDOWS
            write_string(ansi_to_unicode(s), check_ref);
        #else
            if (write_ref(s, check_ref))
            {
                stream << TagString;
                write_utf8string(s, utf8_length(s.begin(), s.end(), UTF16Type()), stream);
            }
        #endif
        }

        inline void write_guid(const GUID & g, bool check_ref = true)
        {
            if (write_ref(g, check_ref))
            {
            #if defined(__STDC_WANT_SECURE_LIB__) || defined(__STDC_WANT_LIB_EXT1__)
                sprintf_s(buf, 40,
            #else
                sprintf(buf,
            #endif
                    "g{%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X}",
                    g.Data1, g.Data2, g.Data3, g.Data4[0], g.Data4[1], g.Data4[2],
                    g.Data4[3], g.Data4[4], g.Data4[5], g.Data4[6], g.Data4[7]);
                stream.write(buf, 39);
            }
        }

        template<typename ValueType>
        void write_list(const ValueType & a, bool check_ref = true)
        {
            HPROSE_STATIC_ASSERT(
                (NonCVType<ValueType>::value == BytesType::value) ||
                (NonCVType<ValueType>::value == ListType::value), "Require [BytesType, ListType]");
            size_t n = a.size();
            if (n > 0)
            {
                if (write_ref(&a, check_ref))
                {
                    stream << TagList;
                    write_int(n, stream);
                    stream << TagOpenbrace;
                #ifndef BOOST_NO_AUTO_DECLARATIONS
                    for (auto itr = a.begin(); itr != a.end(); ++itr)
                #else
                    for (BOOST_DEDUCED_TYPENAME ValueType::const_iterator itr = a.begin(); itr != a.end(); ++itr)
                #endif
                    {
                        serialize(*itr);
                    }
                    stream << TagClosebrace;
                }
            }
            else
            {
                stream << TagList << TagOpenbrace << TagClosebrace;
            }
        }

        template<typename Element, typename Container>
        void write_list(const std::stack<Element, Container> & s, bool check_ref = true)
        {
        #ifdef _MSC_VER
            write_list(s._Get_container(), check_ref);
        #else
            size_t n = s.size();
            if (n > 0)
            {
                if (write_ref(&s, check_ref))
                {
                    std::stack<Element, Container> temp = s;
                    std::vector<Element> v;
                    v.resize(n);
                    for (size_t i = 1; i <= n; i++)
                    {
                        v[n - i] = temp.top();
                        temp.pop();
                    }
                    write_list(v, false);
                }
            }
            else
            {
                stream << TagList << TagOpenbrace << TagClosebrace;
            }
        #endif
        }

        template<typename Element, typename Container>
        void write_list(const std::queue<Element, Container> & q, bool check_ref = true)
        {
        #ifdef _MSC_VER
            write_list(q._Get_container(), check_ref);
        #else
            size_t n = q.size();
            if (n > 0)
            {
                if (write_ref(&q, check_ref))
                {
                    std::queue<Element, Container> temp = q;
                    std::vector<Element> v;
                    v.resize(n);
                    for (size_t i = 0; i < n; i++)
                    {
                        v[i] = temp.front();
                        temp.pop();
                    }
                    write_list(v, false);
                }
            }
            else
            {
                stream << TagList << TagOpenbrace << TagClosebrace;
            }
        #endif
        }

        template<unsigned int Bits>
        void write_list(const std::bitset<Bits> & b, bool check_ref = true)
        {
             if (Bits > 0)
            {
                stream << TagList;
                write_int(Bits, stream);
                stream << TagOpenbrace;
                for (size_t i = 0; i < Bits; i++)
                {
                    serialize(b[i]);
                }
                stream << TagClosebrace;
            }
            else
            {
                stream << TagList << TagOpenbrace << TagClosebrace;
            }
        }

        template<typename ValueType>
        void write_list(const ValueType * a, size_t n, bool check_ref = true)
        {
            if (check_ref)
            {
                references.push_back(any());
            }
            if (n > 0)
            {
                stream << TagList;
                write_int(n, stream);
                stream << TagOpenbrace;
                for (size_t i = 0; i < n; i++)
                {
                    serialize(a[i]);
                }
                stream << TagClosebrace;
            }
            else
            {
                stream << TagList << TagOpenbrace << TagClosebrace;
            }
        }

        template<typename ValueType, size_t ArraySize>
        inline void write_list(const ValueType (&value)[ArraySize], bool check_ref = true)
        {
            write_list(value, ArraySize, check_ref);
        }

    #ifndef BOOST_NO_INITIALIZER_LISTS
        template<typename ValueType>
        inline void write_list(const std::initializer_list<ValueType> & l, bool check_ref = true)
        {
            if (write_ref(&l, check_ref))
            {
                write_list(l.begin(), l.size(), false);
            }
        }
    #endif

        template<typename ValueType>
        void write_map(const ValueType & m, bool check_ref = true)
        {
            HPROSE_STATIC_ASSERT(NonCVType<ValueType>::value == MapType::value, "Require MapType");
            size_t n = m.size();
            if (n > 0)
            {
                if (write_ref(&m, check_ref))
                {
                    stream << TagMap;
                    write_int(n, stream);
                    stream << TagOpenbrace;
                #ifndef BOOST_NO_AUTO_DECLARATIONS
                    for (auto itr = m.begin(); itr != m.end(); ++itr)
                #else
                    for (BOOST_DEDUCED_TYPENAME ValueType::const_iterator itr = m.begin(); itr != m.end(); ++itr)
                #endif
                    {
                        serialize(itr->first);
                        serialize(itr->second);
                    }
                    stream << TagClosebrace;
                }
            }
            else
            {
                stream << TagMap << TagOpenbrace << TagClosebrace;
            }
        }

        template<typename ValueType>
        void write_object(const ValueType & o, bool check_ref = true)
        {
            if (write_ref(&o, check_ref))
            {
                const std::type_info * type = &typeid(ValueType);
                int cr;
            #ifndef BOOST_NO_AUTO_DECLARATIONS
                auto itr = std::find(classref.begin(), classref.end(), type);
            #else
                std::vector<const std::type_info *>::iterator itr = std::find(classref.begin(), classref.end(), type);
            #endif
                if (itr != classref.end())
                {
                    cr = itr - classref.begin();
                }
                else
                {
                    cr = write_class(o);
                }
                stream << TagObject;
                write_int(cr, stream);
                stream << TagOpenbrace;
                std::string alias = classes::find_alias(type);
                classes::PropertyMap & m  = classes::properties[alias];
            #ifndef BOOST_NO_AUTO_DECLARATIONS
                for (auto itr = m.begin(); itr != m.end(); ++itr)
            #else
                for (classes::PropertyMap::const_iterator itr = m.begin(); itr != m.end(); ++itr)
            #endif
                {
                    itr->second.serialize(*this, o);
                }
                stream << TagClosebrace;
            }
        }

    private:

        template<typename ValueType>
        inline void serialize(const ValueType &, UnknownType)
        {
            HPROSE_THROW_EXCEPTION(std::string(typeid(ValueType).name()) + " is not a serializable type");
        }

    #ifndef BOOST_NO_NULLPTR
        inline void serialize(const std::nullptr_t &, NullPtrType)
        {
            write_null();
        }
    #endif

        template<typename ValueType>
        inline void serialize(const ValueType & p, AutoPtrType)
        {
            serialize(p.get());
        }

        template<typename ValueType>
        inline void serialize(const std::tr1::weak_ptr<ValueType> & wp, AutoPtrType)
        {
            try
            {
                std::tr1::shared_ptr<ValueType> sp(wp);
                serialize(sp);
            }
            catch (std::tr1::bad_weak_ptr &)
            {
                write_null();
            }
        }

    #ifdef BOOST_HAS_TR1_SHARED_PTR
        template<typename ValueType>
        inline void serialize(const boost::weak_ptr<ValueType> & wp, AutoPtrType)
        {
            try
            {
                boost::shared_ptr<ValueType> sp(wp);
                serialize(sp);
            }
            catch (boost::bad_weak_ptr &)
            {
                write_null();
            }
        }
    #endif

        template<typename ValueType>
        inline void serialize(const ValueType & p, PointerType)
        {
            if (p)
            {
                serialize(*p);
            }
            else
            {
                write_null();
            }
        }

        template<typename ValueType>
        inline void serialize(const ValueType & a, AnyType)
        {
            a.serialize(*this);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & b, BoolType)
        {
            write_bool(b);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & b, ByteType)
        {
            write_integer(b);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & c, CharType)
        {
            write_utf8char(c);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & e, EnumType)
        {
            write_enum(e);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & i, IntegerType)
        {
            write_integer(i);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & l, LongType)
        {
            write_long(l);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & d, DoubleType)
        {
            write_double(d);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & t, TimeType)
        {
            write_datetime(t);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & b, BytesType)
        {
            if (!b.empty())
            {
                write_bytes(b);
            }
            else
            {
                write_empty();
            }
        }

        template<typename ValueType, size_t ArraySize>
        inline void serialize(const ValueType (&value)[ArraySize], BytesType)
        {
            write_bytes(value);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & s, StringType)
        {
            typedef BOOST_DEDUCED_TYPENAME NonCVElementType<ValueType>::type element;
            serialize(std::basic_string<element>(s));
        }

        template<typename Element, typename Traits, typename Allocator>
        inline void serialize(const std::basic_string<Element, Traits, Allocator> & s, StringType)
        {
            switch (s.size())
            {
                case 0:
                    write_empty();
                    break;
                case 1:
                    write_utf8char(s[0]);
                    break;
                default:
                    write_string(s);
            }
        }

        template<typename ValueType, size_t ArraySize>
        inline void serialize(const ValueType (&value)[ArraySize], StringType)
        {
            size_t len = value[ArraySize - 1] == 0 ? (ArraySize - 1) : ArraySize;
            switch (len)
            {
                case 0:
                    write_empty();
                    break;
                case 1:
                    write_utf8char(value[0]);
                    break;
                default:
                    write_string(std::basic_string<ValueType>(value, len));
            }
        }

        template<typename ValueType>
        inline void serialize(const ValueType & g, GuidType)
        {
            write_guid(g);
        }        
        
        template<typename ValueType>
        inline void serialize(const ValueType & a, ListType)
        {
            write_list(a);
        }

        template<typename ValueType, size_t ArraySize>
        inline void serialize(const ValueType (&value)[ArraySize], ListType)
        {
            write_list(value);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & m, MapType)
        {
            write_map(m);
        }

        template<typename ValueType>
        inline void serialize(const ValueType & o, ObjectType)
        {
            write_object(o);
        }

    private:

        template<typename ValueType>
        inline void write_integer(ValueType i, const std::tr1::true_type &)
        {
            if (i >= 0 && i <= 9)
            {
                stream << (char)('0' + i);
            }
            else
            {
                stream << TagInteger;
                write_int_fast(i, stream);
                stream << TagSemicolon;
            }
        }

        template<typename ValueType>
        inline void write_integer(ValueType i, const std::tr1::false_type &)
        {
            if (i <= 9)
            {
                stream << (char)('0' + i);
            }
            else
            {
                stream << TagInteger;
                write_int_fast(i, stream);
                stream << TagSemicolon;
            }
        }

        template<typename ValueType>
        inline void write_long(ValueType l, const std::tr1::true_type &)
        {
            if (l >= 0 && l <= 9)
            {
                stream << (char)('0' + l);
            }
            else
            {
                stream << TagLong;
                write_int_fast(l, stream);
                stream << TagSemicolon;
            }
        }

        template<typename ValueType>
        inline void write_long(ValueType l, const std::tr1::false_type &)
        {
            if (l <= 9)
            {
                stream << (char)('0' + l);
            }
            else
            {
                stream << TagLong;
                write_int_fast(l, stream);
                stream << TagSemicolon;
            }
        }

        void write_datetime(const tm & t)
        {
            int year = t.tm_year + 1900;
            int month = t.tm_mon + 1;
            int day = t.tm_mday;
            int hour = t.tm_hour;
            int minute = t.tm_min;
            int second = t.tm_sec;
            if ((hour == 0) && (minute == 0) && (second == 0))
            {
                write_date(year, month, day);
            }
            else if ((year == 1970) && (month == 1) && (day == 1))
            {
                write_time(hour, minute, second);
            }
            else
            {
                write_date(year, month, day);
                write_time(hour, minute, second);
            }
            stream << TagUTC;
        }

        void write_date(int year, int month, int day)
        {
            stream << TagDate;
            stream << (char)('0' + (year / 1000 % 10));
            stream << (char)('0' + (year / 100 % 10));
            stream << (char)('0' + (year / 10 % 10));
            stream << (char)('0' + (year % 10));
            stream << (char)('0' + (month / 10 % 10));
            stream << (char)('0' + (month % 10));
            stream << (char)('0' + (day / 10 % 10));
            stream << (char)('0' + (day % 10));
        }

        void write_time(int hour, int minute, int second, int milliseconds = 0)
        {
            stream << TagTime;
            stream << (char)('0' + (hour / 10 % 10));
            stream << (char)('0' + (hour % 10));
            stream << (char)('0' + (minute / 10 % 10));
            stream << (char)('0' + (minute % 10));
            stream << (char)('0' + (second / 10 % 10));
            stream << (char)('0' + (second % 10));
            if (milliseconds > 0)
            {
                stream << TagPoint;
                stream << (char)('0' + (milliseconds / 100 % 10));
                stream << (char)('0' + (milliseconds / 10 % 10));
                stream << (char)('0' + (milliseconds % 10));
            }
        }

        inline void write_utf8string(const std::string & s, size_t len, std::ostream & os)
        {
            if (len)
            {
                write_int(len, os);
            }
            os << TagQuote << s << TagQuote;
        }

        inline void write_utf8string(const std::string & s, std::ostream & os)
        {
        #ifdef BOOST_WINDOWS
            std::wstring w = ansi_to_unicode(s);
            write_utf8string(utf8_encode(w), w.size(), os);
        #else
            write_utf8string(s, utf8_length(s.begin(), s.end(), UTF16Type()), os);
        #endif
        }

        template<typename ValueType>
        int write_class(const ValueType & o)
        {
            const std::type_info * type = &typeid(ValueType);
            serialize_cache cache = classes::find_cache(type);
            if (cache.data.empty())
            {
                cache.ref_count = 0;
                std::ostringstream os;
                std::string alias = classes::find_alias(type);
                if (!alias.empty())
                {
                    os << TagClass;
                    write_utf8string(alias, os);
                    classes::PropertyMap & m  = classes::properties[alias];
                    size_t n = m.size();
                    if (n > 0) write_int(n, os);
                    os << TagOpenbrace;
                #ifndef BOOST_NO_AUTO_DECLARATIONS
                    for (auto itr = m.begin(); itr != m.end(); ++itr, cache.ref_count++)
                #else
                    for (classes::PropertyMap::const_iterator itr = m.begin(); itr != m.end(); ++itr, cache.ref_count++)
                #endif
                    {
                        os << TagString;
                        write_utf8string(itr->first, os);
                    }
                    os << TagClosebrace;
                    cache.data = os.str();
                    classes::register_cache(type, cache);
                }
                else
                {
                    serialize(o, UnknownType());
                }
            }
            stream << cache.data;
            references.resize(references.size() + cache.ref_count);
            classref.push_back(type);
            return classref.size() - 1;
        }

        template<typename ValueType>
        bool write_ref(const ValueType & value, bool check_ref)
        {
            if (check_ref)
            {
                int ref = vector_index_of(references, value);
                if (ref > -1)
                {
                    write_ref(ref);
                    return false;
                }
            }
            references.push_back(value);
            return true;
        }

        inline void write_ref(int ref)
        {
            stream << TagRef;
            write_int(ref, stream);
            stream << TagSemicolon;
        }

        template<typename ValueType>
        void write_int_fast(ValueType i, std::ostream & os, const std::tr1::true_type &)
        {
            int off = 20;
            int len = 0;
            bool neg = i < 0;
            while (i != 0)
            {
                buf[--off] = (char)abs(i % 10) + '0';
                ++len;
                i /= 10;
            }
            if (neg)
            {
                buf[--off] = '-';
                ++len;
            }
            os.write(&buf[off], len);
        }

        template<typename ValueType>
        void write_int_fast(ValueType i, std::ostream & os, const std::tr1::false_type &)
        {
            int off = 20;
            int len = 0;
            while (i != 0)
            {
                buf[--off] = i % 10 + '0';
                ++len;
                i /= 10;
            }
            os.write(&buf[off], len);
        }

        template<typename ValueType>
        inline void write_int_fast(ValueType i, std::ostream & os)
        {
            write_int_fast(i, os, std::tr1::is_signed<ValueType>());
        }

        template<typename ValueType>
        inline void write_int(ValueType i, std::ostream & os, const std::tr1::true_type &)
        {
            if (i >= 0 && i <= 9)
            {
                os << (char)('0' + i);
            }
            else
            {
                write_int_fast(i, os);
            }
        }

        template<typename ValueType>
        inline void write_int(ValueType i, std::ostream & os, const std::tr1::false_type &)
        {
            if (i <= 9)
            {
                os << (char)('0' + i);
            }
            else
            {
                write_int_fast(i, os);
            }
        }

        template<typename ValueType>
        inline void write_int(ValueType i, std::ostream & os)
        {
            write_int(i, os, std::tr1::is_signed<ValueType>());
        }

    private:

        char buf[40];
        std::ostream & stream;
        std::vector<any> references;
        std::vector<const std::type_info *> classref;

    }; // class writer

} // namespace hprose

#endif
