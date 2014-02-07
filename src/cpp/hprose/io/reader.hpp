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
 * reader.hpp                                             *
 *                                                        *
 * hprose reader unit for cpp.                            *
 *                                                        *
 * LastModified: Jun 27, 2011                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_READER_INCLUDED
#define HPROSE_READER_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/io/classes.hpp>
#include <hprose/io/tags.hpp>
#include <hprose/io/types.hpp>

#include <istream>

#if !defined(BOOST_NO_LONG_LONG)
#define HPROSE_LONG_LONG long long
#elif defined(BOOST_HAS_MS_INT64)
#define HPROSE_LONG_LONG __int64
#else
#define HPROSE_LONG_LONG bigint
#endif

namespace hprose
{
    class reader
    {
    public:

        reader(std::istream & stream)
          : stream(stream)
        {
        }

    public:

        template<typename ValueType>
        inline void unserialize(ValueType & value)
        {
            unserialize(value, NonCVType<ValueType>());
        }

        template<typename ValueType, size_t ArraySize>
        inline void unserialize(ValueType (&value)[ArraySize])
        {
            unserialize(value, NonCVArrayType<ValueType>());
        }

        template<typename ReturnType>
        inline ReturnType unserialize()
        {
            ReturnType ret = ReturnType();
            unserialize(ret);
            return ret;
        }

        inline any unserialize()
        {
            return unserialize<any>();
        }

    public:

        inline void read_null()
        {
            check_tag(TagNull);
        }

        inline void read_empty()
        {
            check_tag(TagEmpty);
        }

        inline bool read_bool()
        {
            return check_tags(BoolTags) == TagTrue;
        }

        template<typename ValueType>
        void read_integer(ValueType & i, bool include_tag = true)
        {
            if (include_tag)
            {
                char tag = stream.get();
                if (tag >= '0' && tag <= '9')
                {
                    i = tag - '0';
                    return;
                }
                check_tag(TagInteger, tag);
            }
            read_int(i, TagSemicolon);
        }

        inline int read_integer(bool include_tag = true)
        {
            int i;
            read_integer(i, include_tag);
            return i;
        }

        template<typename ValueType>
        void read_long(ValueType & l, bool include_tag = true)
        {
            if (include_tag)
            {
                char tag = stream.get();
                if (tag >= '0' && tag <= '9')
                {
                    l = tag - '0';
                    return;
                }
                check_tags(LongTags, tag);
            }
            read_int(l, TagSemicolon);
        }

        inline HPROSE_LONG_LONG read_long(bool include_tag = true)
        {
            HPROSE_LONG_LONG l = 0;
            read_long(l, include_tag);
            return l;
        }

        template<typename ValueType>
        inline void read_nan(ValueType & d)
        {
            check_tag(TagNaN);
            d = std::numeric_limits<ValueType>::quiet_NaN();
        }

        template<typename ValueType>
        inline void read_infinity(ValueType & d, bool include_tag = true)
        {
            if (include_tag)
            {
                check_tag(TagInfinity);
            }
            d = (stream.get() == TagPos)
                ?  std::numeric_limits<ValueType>::infinity()
                : -std::numeric_limits<ValueType>::infinity();
        }

        inline double read_infinity(bool include_tag = true)
        {
            double ret;
            read_infinity(ret, include_tag);
            return ret;
        }

        template<typename ValueType>
        void read_double(ValueType & d, bool include_tag = true)
        {
            if (include_tag)
            {
                char tag = stream.get();
                if (tag >= '0' && tag <= '9')
                {
                    d = tag - '0';
                    return ;
                }
                check_tags(DoubleTags, tag);
                if (tag == TagNaN)
                {
                    d = std::numeric_limits<ValueType>::quiet_NaN();
                    return;
                }
                if (tag == TagInfinity)
                {
                    read_infinity(d, false);
                    return;
                }
            }
            stream >> d;
            stream.ignore((std::numeric_limits<int>::max)(), TagSemicolon);
        }

        inline double read_double(bool include_tag = true)
        {
            double d = 0;
            read_double(d, include_tag);
            return d;
        }

        void read_date(ctime & t, bool include_tag = true)
        {
            char tag;
            if (include_tag)
            {
                tag = check_tags(DateTags);
                if (tag == TagRef)
                {
                    read_ref(t);
                }
            }
            int year, month, day, hour, minute, second;
            year = stream.get() - '0';
            year = year * 10 + stream.get() - '0';
            year = year * 10 + stream.get() - '0';
            year = year * 10 + stream.get() - '0';
            month = stream.get() - '0';
            month = month * 10 + stream.get() - '0';
            day = stream.get() - '0';
            day = day * 10 + stream.get() - '0';
            tag = stream.get();
            if (tag == TagTime)
            {
                hour = stream.get() - '0';
                hour = hour * 10 + stream.get() - '0';
                minute = stream.get() - '0';
                minute = minute * 10 + stream.get() - '0';
                second = stream.get() - '0';
                second = second * 10 + stream.get() - '0';
                tag = stream.get();
                if (tag == TagPoint) // ignore millisecond
                {
                    do
                    {
                        tag = stream.get();
                    } while((tag >= '0') && (tag <= '9'));
                }
                if (tag == TagUTC)
                {
                    second -= ctime::timezone();
                }
            }
            else
            {
                hour = 0;
                minute = 0;
                second = 0;
                if (tag == TagUTC)
                {
                    second -= ctime::timezone();
                }
            }
            t = ctime(year, month, day, hour, minute, second);
            references.push_back(t);
        }

        inline ctime read_date(bool include_tag = true)
        {
            ctime t;
            read_date(t, include_tag);
            return t;
        }

        void read_time(ctime & t, bool include_tag = true)
        {
            char tag;
            if (include_tag)
            {
                tag = check_tags(TimeTags);
                if (tag == TagRef)
                {
                    read_ref(t);
                }
            }
            int hour = stream.get() - '0';
            hour = hour * 10 + stream.get() - '0';
            int minute = stream.get() - '0';
            minute = minute * 10 + stream.get() - '0';
            int second = stream.get() - '0';
            second = second * 10 + stream.get() - '0';
            tag = stream.get();
            if (tag == TagPoint) // ignore millisecond
            {
                do
                {
                    tag = stream.get();
                } while((tag >= '0') && (tag <= '9'));
            }
            if (tag == TagUTC)
            {
                second -= ctime::timezone();
            }
            t = ctime(1970, 1, 1, hour, minute, second);
            references.push_back(t);
        }

        inline ctime read_time(bool include_tag = true)
        {
            ctime t;
            read_time(t, include_tag);
            return t;
        }

        void read_datetime(ctime & t)
        {
            char tag = check_tags(DateTimeTags);
            if (tag == TagDate)
            {
                read_date(t, false);
            }
            else if (tag == TagTime)
            {
                read_time(t, false);
            }
            else
            {
                read_ref(t);
            }
        }

        inline ctime read_datetime()
        {
            ctime t;
            read_datetime(t);
            return t;
        }

        template<typename ValueType>
        inline void read_utf8char(ValueType & c, bool include_tag = true)
        {
            if (include_tag) check_tag(TagUTF8Char);
            std::istream_iterator<char> itr(stream);
            c = utf8_decode(itr, UTFType<sizeof(ValueType)>());
            stream.unget();
        }

        inline void read_utf8char(char & c, bool include_tag = true)
        {
            wchar_t wc;
            read_utf8char(wc, include_tag);
            c = (char)wc;
        }

        template<typename ValueType>
        void read_bytes(ValueType & b, bool include_tag = true)
        {
            if (include_tag)
            {
                check_tags(ListTags);
            }
            b.clear();
            int count;
            read_int(count, TagOpenbrace);
            char c = 0;
            for (int i = 0; i < count; i++)
            {
                unserialize(c);
                b.push_back(c);
            }
            check_tag(TagClosebrace);
        }

        template<typename Element, typename Container>
        void read_bytes(std::stack<Element, Container> & s, bool include_tag = true)
        {
        }

        template<typename Element, typename Container>
        void read_bytes(std::queue<Element, Container> & q, bool include_tag = true)
        {
        }

        template<typename ValueType>
        void read_bytes(ValueType * b, size_t n, bool include_tag = true)
        {
        }

        template<typename ValueType, size_t ArraySize>
        inline void read_bytes(ValueType (&value)[ArraySize], bool include_tag = true)
        {
            read_bytes(value, ArraySize, include_tag);
        }

        template<typename Element, typename Traits, typename Allocator>
        inline void read_string(std::basic_string<Element, Traits, Allocator> & s, bool include_tag = true)
        {
            if (include_tag)
            {
                check_tags(StringTags);
            }
            stream.ignore((std::numeric_limits<int>::max)(), TagQuote);
            std::string u;
            std::getline(stream, u, TagQuote);
            s.resize(utf8_length(u.begin(), u.end(), UTFType<sizeof(Element)>()));
            utf8_decode(u.begin(), u.end(), s.begin(), UTFType<sizeof(Element)>());
        }

        inline void read_string(std::string & s, bool include_tag = true)
        {
        #ifdef BOOST_WINDOWS
            std::wstring u;
            read_string(u, include_tag);
            s  = unicode_to_ansi(u);
        #else
            if (include_tag)
            {
                check_tags(StringTags);
            }
            stream.ignore((std::numeric_limits<int>::max)(), TagQuote);
            std::getline(stream, s, TagQuote);
        #endif
        }

        inline std::string read_string(bool include_tag = true)
        {
            std::string ret;
            read_string(ret, include_tag);
            return ret;
        }

        template<typename ValueType>
        void read_list(ValueType & a, bool include_tag = true)
        {
            typedef BOOST_DEDUCED_TYPENAME NonCVElementType<ValueType>::type element;
            if (include_tag)
            {
                char tag = check_tags(ListTags);
                if (tag == TagRef)
                {
                    read_ref(a);
                    return;
                }
            }
            references.push_back(&a);
            int count = read_int(TagOpenbrace);
            a.resize(count);
            for (int i = 0; i < count; i++)
            {
                a[i] = unserialize<element>();
            }
            check_tag(TagClosebrace);
        }

        template<typename Element, typename Container>
        void read_list(std::stack<Element, Container> & s, bool include_tag = true)
        {
        }

        template<typename Element, typename Container>
        void read_list(std::queue<Element, Container> & q, bool include_tag = true)
        {
        }

        template<unsigned int Bits>
        void read_list(std::bitset<Bits> & b, bool include_tag = true)
        {
        }

        template<typename ValueType>
        void read_list(ValueType * a, size_t n, bool include_tag = true)
        {
            if (include_tag)
            {
                check_tags(ListTags);
            }
            size_t count;
            read_int(count, TagOpenbrace);
            if (n < count)
            {
                HPROSE_THROW_EXCEPTION("Not enough sapce to read list");
            }
            for (size_t i = 0; i < count; i++, a++)
            {
                unserialize(a);
            }
            check_tag(TagClosebrace);
        }

        template<typename ValueType, size_t ArraySize>
        inline void read_list(ValueType (&value)[ArraySize], bool include_tag = true)
        {
            read_list(value, ArraySize, include_tag);
        }

    #ifndef BOOST_NO_INITIALIZER_LISTS
        template<typename ValueType>
        inline void read_list(const std::initializer_list<ValueType> & a, bool include_tag = true)
        {
        }
    #endif

        template<typename ValueType>
        void read_map(ValueType & m, bool include_tag = true)
        {
            typedef BOOST_DEDUCED_TYPENAME NonCVKeyType<ValueType>::type key;
            typedef BOOST_DEDUCED_TYPENAME NonCVValueType<ValueType>::type value;
            if (include_tag)
            {
                check_tags(MapTags);
            }
            int count = read_int(TagOpenbrace);
            for (int i = 0; i < count; i++)
            {
                key k = unserialize<key>();
                value v = unserialize<value>();
                m.insert(std::make_pair<key, value>(k, v));
            }
            check_tag(TagClosebrace);
        }

        template<typename ValueType>
        void read_object(ValueType & o, bool include_tag = true)
        {
            if (include_tag)
            {
                char tag = check_tags(ObjectTags);
                if (tag == TagClass)
                {
                    read_class();
                    read_object(o, true);
                    return;
                }
            }
            const std::type_info * type = classref[read_int(TagOpenbrace)];
            std::vector<std::string> & attrs = attrsref[type];
            std::string alias = classes::find_alias(type);
            classes::PropertyMap & m  = classes::properties[alias];
            references.push_back(&o);
            for (size_t i = 0; i < attrs.size(); i++)
            {
                m[attrs[i]].unserialize(*this, o);
            }
            check_tag(TagClosebrace);
        }

    public:

        inline void check_tag(char expected, char found)
        {
            if (found != expected)
            {
                HPROSE_THROW_EXCEPTION(std::string("Tag '") + expected + "' expected, but '" + found + "' found in stream");
            }
        }

        inline void check_tag(char expected)
        {
            check_tag(expected, stream.get());
        }

        template<size_t ArraySize>
        inline char check_tags(const char (&expected)[ArraySize], char found)
        {
            bool ok = false;
            for (size_t i = 0; i < ArraySize; i++)
            {
                if (expected[i] == found)
                {
                    ok = true;
                    break;
                }
            }
            if (!ok)
            {
                HPROSE_THROW_EXCEPTION(std::string("Tag '") + std::string(expected, expected + ArraySize) + "' expected, but '" + found + "' found in stream");
            }
            return found;
        }

        template<size_t ArraySize>
        inline char check_tags(const char (&expected)[ArraySize])
        {
           return check_tags(expected, stream.get());
        }

    private:

        template<typename ValueType>
        inline void unserialize(ValueType &, UnknownType)
        {
            cast_error(TagToString(stream.get()), typeid(ValueType).name());
        }

    #ifndef BOOST_NO_NULLPTR
        inline void unserialize(std::nullptr_t &, NullPtrType)
        {
            read_null();
        }
    #endif

        template<typename ValueType>
        inline void unserialize(ValueType & p, AutoPtrType)
        {
            typedef BOOST_DEDUCED_TYPENAME NonCVElementType<ValueType>::type element;
            if (stream.peek() == TagNull)
            {
                p.reset(0);
            }
            else
            {
                if (!p.get())
                {
                    p.reset(new element());
                }
                unserialize(*p.get());
            }
        }

        template<typename ValueType>
        inline void unserialize(std::tr1::weak_ptr<ValueType> & wp, AutoPtrType)
        {
            try
            {
                std::tr1::shared_ptr<ValueType> sp(wp);
                unserialize(sp);
            }
            catch (std::tr1::bad_weak_ptr &)
            {
                std::tr1::shared_ptr<ValueType> * sp = 0;
                unserialize(sp);
                wp = *sp;
            }
        }

    #ifdef BOOST_HAS_TR1_SHARED_PTR
        template<typename ValueType>
        inline void unserialize(boost::weak_ptr<ValueType> & wp, AutoPtrType)
        {
            try
            {
                boost::shared_ptr<ValueType> sp(wp);
                unserialize(sp);
            }
            catch (boost::bad_weak_ptr &)
            {
                boost::shared_ptr<ValueType> * sp = 0;
                unserialize(sp);
                wp = *sp;
            }
        }
    #endif

        template<typename ValueType>
        inline void unserialize(ValueType & p, PointerType)
        {
            typedef BOOST_DEDUCED_TYPENAME std::tr1::remove_pointer<ValueType>::type nonptr;
            if (stream.peek() == TagNull)
            {
                delete p;
                p = 0;
            }
            else
            {
                if (!p)
                {
                    p = new nonptr();
                }
                unserialize(*p);
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & a, AnyType)
        {
            switch (char tag = stream.get())
            {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    a = tag - '0';
                    break;
                case TagInteger:
                    a = read_integer(false);
                    break;
                case TagLong:
                    a = read_long(false);
                    break;
                case TagDouble:
                    a = read_double(false);
                    break;
                case TagNaN:
                    a = std::numeric_limits<double>::quiet_NaN();
                    break;
                case TagInfinity:
                    a = read_infinity(false);
                    break;
                case TagNull:
                    a = any();
                    break;
                case TagTrue:
                    a = true;
                    break;
                case TagFalse:
                    a = false;
                    break;
                case TagDate:
                    a = read_date(false);
                    break;
                case TagTime:
                    a = read_time(false);
                    break;
                case TagBytes:
                {
                    std::vector<unsigned char> v;
                    read_bytes(v, false);
                    a = v;
                    break;
                }
                case TagString:
                    a = read_string(false);
                    break;
                case TagList:
                {
                    std::vector<any> v;
                    read_list(v, false);
                    a = v;
                    break;
                }
                case TagMap:
                    break;
                case TagClass:
                    read_class();
                    unserialize(a);
                    break;
                case TagObject:
                    break;
                case TagRef:
                    a = references[read_int(TagSemicolon)];
                    break;
                case TagError:
                case (char)0xff:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & b, BoolType)
        {
            switch (char tag = stream.get())
            {
                case '0':
                case TagFalse:
                case TagNull:
                case TagEmpty:
                    b = false;
                    break;
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                case TagTrue:
                    b = true;
                    break;
                case TagInteger:
                case TagLong:
                    b = true;
                    stream.ignore((std::numeric_limits<int>::max)(), TagSemicolon);
                    break;
                case TagDouble:
                {
                    b = false;
                    char c = stream.get();
                    while ((c != TagSemicolon) && (c != (char)0xff))
                    {
                        if (c != '0')
                        {
                            b = true;
                            stream.ignore((std::numeric_limits<int>::max)(), TagSemicolon);
                            break;
                        }
                        else
                        {
                            c = stream.get();
                        }
                    }
                    break;
                }
                case TagUTF8Char:
                {
                    wchar_t c;
                    read_utf8char(c, false);
                    b = (c != 0) && (c != L'0') && (c != L'F') && (c != L'f');
                }
                case TagNaN:
                case TagInfinity:
                case TagDate:
                case TagTime:
                case TagBytes:
                case TagString:
                case TagList:
                case TagMap:
                case TagClass:
                case TagObject:
                case TagRef:
                    cast_error(TagToString(tag), typeid(ValueType).name());
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xff:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + std::string("' in stream"));
            }
        }

        template<typename ValueType>
        inline void unserialize(ValueType & b, ByteType)
        {
            unserialize(b, IntegerType());
        }

        template<typename ValueType>
        void unserialize(ValueType & c, CharType)
        {
            switch (char tag = stream.get())
            {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    c = tag;
                    break;
                case TagTrue:
                    c = 'T';
                    break;
                case TagFalse:
                    c = 'F';
                    break;
                case TagNull:
                case TagEmpty:
                    c = 0;
                    break;
                case TagUTF8Char:
                    read_utf8char(c, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        inline void unserialize(ValueType & e, EnumType)
        {
            int i = (int)e;
            unserialize(i);
            e = (ValueType)i;
        }

        template<typename ValueType>
        void unserialize(ValueType & i, IntegerType)
        {
            switch (char tag = stream.get())
            {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    i = tag - '0';
                    break;
                case TagInteger:
                case TagLong:
                    read_int(i, TagSemicolon);
                    break;
                case TagTrue:
                    i = 1;
                    break;
                case TagFalse:
                case TagNull:
                case TagEmpty:
                    i = 0;
                    break;
                case TagNaN:
                case TagInfinity:
                case TagDate:
                case TagTime:
                case TagBytes:
                case TagString:
                case TagList:
                case TagMap:
                case TagClass:
                case TagObject:
                case TagRef:
                    cast_error(TagToString(tag), typeid(ValueType).name());
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        inline void unserialize(ValueType & l, LongType)
        {
            unserialize(l, IntegerType());
        }

        template<typename ValueType>
        void unserialize(ValueType & d, DoubleType)
        {
            switch (char tag = stream.get())
            {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    d = tag - '0';
                    break;
                case TagInteger:
                case TagLong:
               {
                    ValueType i;
                    read_int(i, TagSemicolon);
                    d = i;
                    break;
                }
                case TagDouble:
                    read_double(d, false);
                    break;
                case TagTrue:
                    d = 1;
                    break;
                case TagFalse:
                case TagNull:
                case TagEmpty:
                    d = 0;
                    break;
                case TagNaN:
                    d = std::numeric_limits<ValueType>::quiet_NaN();
                    break;
                case TagInfinity:
                    read_infinity(d, false);
                    break;
                case TagDate:
                case TagTime:
                case TagBytes:
                case TagString:
                case TagList:
                case TagMap:
                case TagClass:
                case TagObject:
                case TagRef:
                    cast_error(TagToString(tag), typeid(ValueType).name());
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & t, TimeType)
        {
            switch (char tag = stream.get())
            {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    t = tag - '0';
                    break;
                case TagDate:
                    read_date(t, false);
                    break;
                case TagTime:
                    read_time(t, false);
                    break;
                case TagRef:
                    read_ref(t);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & b, BytesType)
        {
            switch (char tag = stream.get())
            {
                case TagBytes:
                    read_bytes(b, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & s, StringType)
        {
            typedef BOOST_DEDUCED_TYPENAME NonCVElementType<ValueType>::type element;
            switch (char tag = stream.get())
            {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    s = std::basic_string<element>(1, tag);
                    break;
                case TagUTF8Char:
                {
                    element c;
                    read_utf8char(c, false);
                    s = std::basic_string<element>(1, c);
                    break;
                }
                case TagString:
                    read_string(s, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & g, GuidType)
        {
            switch (char tag = stream.get())
            {
                case TagGuid:
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & a, ListType)
        {
            switch (char tag = stream.get())
            {
                case TagList:
                    read_list(a, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType, size_t ArraySize>
        void unserialize(ValueType (&value)[ArraySize], ListType)
        {
            switch (char tag = stream.get())
            {
                case TagList:
                    read_list(value, ArraySize, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & m, MapType)
        {
            switch (char tag = stream.get())
            {
                case TagMap:
                    read_map(m, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

        template<typename ValueType>
        void unserialize(ValueType & o, ObjectType)
        {
            switch (char tag = stream.get())
            {
                case TagClass:
                    read_class();
                    unserialize(o);
                    break;
                case TagObject:
                    read_object(o, false);
                    break;
                case TagError:
                    HPROSE_THROW_EXCEPTION(read_string());
                case (char)0xFF:
                    HPROSE_THROW_EXCEPTION("No byte found in stream");
                default:
                    HPROSE_THROW_EXCEPTION(std::string("Unexpected serialize tag '") + tag + "' in stream");
            }
        }

    private:

        template<typename ValueType>
        void read_int(ValueType & i, char tag)
        {
            int sign = 1;
            int c = stream.get();
            i = 0;
            if (c == '+')
            {
                c = stream.get();
            }
            else if (c == '-')
            {
                sign = -1;
                c = stream.get();
            }
            while (c != tag && c != -1)
            {
                i *= 10;
                i += (c - '0') * sign;
                c = stream.get();
            }
        }

        inline void read_int(bigint & i, char tag)
        {
            std::string s;
            std::getline(stream, s, tag);
            i = bigint(s);
        }

        inline int read_int(char tag)
        {
            int ret;
            read_int(ret, tag);
            return ret;
        }

        void read_class()
        {
            std::string name = read_string(false);
            int count = read_int(TagOpenbrace);
            std::vector<std::string> attrs;
            attrs.reserve(count);
            for (int i = 0; i < count; i++)
            {
                attrs.push_back(read_string(true));
            }
            check_tag(TagClosebrace);
            const std::type_info * type = classes::find_type(name);
            if (type)
            {
                classref.push_back(type);
                attrsref[type] = attrs;
            }
        }

        template<typename ValueType>
        void read_ref(ValueType & value)
        {
            any a = references[read_int(TagSemicolon)];
            try
            {
                value = any::cast<ValueType>(a);
            }
            catch (...)
            {
               cast_error(a.type().name(), typeid(ValueType).name());
            }
        }

    private:

        inline void cast_error(const std::string & srctype, const std::string & desttype)
        {
            HPROSE_THROW_EXCEPTION("Can't convert type '" + srctype + "' to '" + desttype + "'");
        }

    private:

        std::istream & stream;
        std::vector<any> references;
        std::vector<const std::type_info *> classref;
        std::map<const std::type_info *, std::vector<std::string>, type_info_less> attrsref;

    }; // class reader

} // namespace hprose

#endif
