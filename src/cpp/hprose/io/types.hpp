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
 * types.hpp                                              *
 *                                                        *
 * hprose types unit for cpp.                             *
 *                                                        *
 * LastModified: Jun 27, 2011                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_TYPES_INCLUDED
#define HPROSE_TYPES_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/common.hpp>

#include <stdio.h>
#include <iomanip>
#include <vector>
#include <list>
#include <deque>
#include <stack>
#include <queue>
#include <set>
#include <bitset>
#include <map>

#include <boost/tr1/array.hpp>
#include <boost/tr1/memory.hpp>
#include <boost/tr1/unordered_map.hpp>
#include <boost/tr1/unordered_set.hpp>
#include <boost/array.hpp>
#include <boost/smart_ptr.hpp>
#include <boost/unordered_map.hpp>
#include <boost/unordered_set.hpp>

namespace hprose
{
    template<int v>
    struct IntToType
    {
        BOOST_STATIC_CONSTANT(int, value = v);
    };

    // Special Types
    typedef IntToType<-4> UnknownType;
    typedef IntToType<-3> NullPtrType; // c++0x std::nullptr_t
    typedef IntToType<-2> AutoPtrType;
    typedef IntToType<-1> PointerType; // std::tr1::is_pointer
    typedef IntToType< 0> AnyType;
    // Native and STL Types
    typedef IntToType< 1> BoolType;
    typedef IntToType< 2> ByteType;
    typedef IntToType< 3> CharType;
    typedef IntToType< 4> EnumType;    // std::tr1::is_enum
    typedef IntToType< 5> IntegerType;
    typedef IntToType< 6> LongType;
    typedef IntToType< 7> DoubleType;
    typedef IntToType< 8> TimeType;
    typedef IntToType< 9> BytesType;
    typedef IntToType<10> StringType;
    typedef IntToType<11> GuidType;
    typedef IntToType<12> ListType;
    typedef IntToType<13> MapType;
    typedef IntToType<14> ObjectType;  // std::tr1::is_class

    template<typename Type>
    struct TypeToType
    {
        typedef BOOST_DEDUCED_TYPENAME std::tr1::is_pointer<Type> is_pointer;
        typedef BOOST_DEDUCED_TYPENAME std::tr1::is_enum<Type> is_enum;
        typedef BOOST_DEDUCED_TYPENAME std::tr1::is_class<Type> is_class;
        typedef IntToType<
            is_pointer::value
                ? PointerType::value
                : (is_enum::value
                    ? EnumType::value
                    : (is_class::value
                        ? ObjectType::value
                        : UnknownType::value))> type;
    };

#ifndef BOOST_NO_NULLPTR
    template<>
    struct TypeToType<std::nullptr_t>
    {
        typedef NullPtrType type;
    };
#endif

#ifndef BOOST_NO_AUTO_PTR
    template<typename Type>
    struct TypeToType<std::auto_ptr<Type> > // departed in c++0x
    {
        typedef AutoPtrType type;
        typedef Type element;
    };
#endif

#ifndef HPROSE_NO_UNIQUE_PTR
    template<typename Type>
    struct TypeToType<std::unique_ptr<Type> >
    {
        typedef AutoPtrType type;
        typedef Type element;
    };
#endif

    template<typename Type>
    struct TypeToType<std::tr1::shared_ptr<Type> >
    {
        typedef AutoPtrType type;
        typedef Type element;
    };

    template<typename Type>
    struct TypeToType<std::tr1::weak_ptr<Type> >
    {
        typedef AutoPtrType type;
        typedef Type element;
    };

#ifdef BOOST_HAS_TR1_SHARED_PTR
    template<typename Type>
    struct TypeToType<boost::shared_ptr<Type> >
    {
        typedef AutoPtrType type;
        typedef Type element;
    };

    template<typename Type>
    struct TypeToType<boost::weak_ptr<Type> >
    {
        typedef AutoPtrType type;
        typedef Type element;
    };
#endif

    template<typename Type>
    struct TypeToType<boost::scoped_ptr<Type> >
    {
        typedef AutoPtrType type;
        typedef Type element;
    };

    template<>
    struct TypeToType<any>
    {
        typedef AnyType type;
    };

    template<>
    struct TypeToType<bool>
    {
        typedef BoolType type;
    };

    template<>
    struct TypeToType<char>
    {
        typedef CharType type;
    };

#ifndef BOOST_NO_INTRINSIC_WCHAR_T
    template<>
    struct TypeToType<wchar_t>
    {
        typedef CharType type;
    };
#endif

#ifndef BOOST_NO_CHAR16_T
    template<>
    struct TypeToType<char16_t>
    {
        typedef CharType type;
    };
#endif

#ifndef BOOST_NO_CHAR32_T
    template<>
    struct TypeToType<char32_t>
    {
        typedef CharType type;
    };
#endif

    template<>
    struct TypeToType<signed char>
    {
        typedef ByteType type;
    };

    template<>
    struct TypeToType<unsigned char>
    {
        typedef ByteType type;
    };

    template<>
    struct TypeToType<short>
    {
        typedef IntegerType type;
    };

    template<>
    struct TypeToType<unsigned short>
    {
        typedef IntegerType type;
    };

    template<>
    struct TypeToType<int>
    {
        typedef IntegerType type;
    };

    template<>
    struct TypeToType<unsigned int>
    {
        typedef LongType type;
    };

    template<>
    struct TypeToType<long>
    {
    #if LONG_MAX == INT_MAX
        typedef IntegerType type;
    #else
        typedef LongType type;
    #endif
    };

    template<>
    struct TypeToType<unsigned long>
    {
        typedef LongType type;
    };

#if !defined(BOOST_NO_LONG_LONG)
    template<>
    struct TypeToType<long long>
    {
        typedef LongType type;
    };

    template<>
    struct TypeToType<unsigned long long>
    {
        typedef LongType type;
    };
#elif defined(BOOST_HAS_MS_INT64)
    template<>
    struct TypeToType<__int64>
    {
        typedef LongType type;
    };

    template<>
    struct TypeToType<unsigned __int64>
    {
        typedef LongType type;
    };
#endif

    template<>
    struct TypeToType<bigint>
    {
        typedef LongType type;
    };

    template<>
    struct TypeToType<float>
    {
        typedef DoubleType type;
    };

    template<>
    struct TypeToType<double>
    {
        typedef DoubleType type;
    };

    template<>
    struct TypeToType<long double>
    {
        typedef DoubleType type;
    };

    template<>
    struct TypeToType<ctime>
    {
        typedef TimeType type;
    };

    template<>
    struct TypeToType<char *>
    {
        typedef StringType type;
        typedef char element;
    };

    template<>
    struct TypeToType<const char *>
    {
        typedef StringType type;
        typedef char element;
    };

#ifndef BOOST_NO_INTRINSIC_WCHAR_T
    template<>
    struct TypeToType<wchar_t *>
    {
        typedef StringType type;
        typedef wchar_t element;
    };

    template<>
    struct TypeToType<const wchar_t *>
    {
        typedef StringType type;
        typedef wchar_t element;
    };
#endif

#ifndef BOOST_NO_CHAR16_T
    template<>
    struct TypeToType<char16_t *>
    {
        typedef StringType type;
        typedef char16_t element;
    };

    template<>
    struct TypeToType<const char16_t *>
    {
        typedef StringType type;
        typedef char16_t element;
    };
#endif

#ifndef BOOST_NO_CHAR32_T
    template<>
    struct TypeToType<char32_t *>
    {
        typedef StringType type;
        typedef char32_t element;
    };

    template<>
    struct TypeToType<const char32_t *>
    {
        typedef StringType type;
        typedef char32_t element;
    };
#endif

    template<typename Element, typename Traits, typename Allocator>
    struct TypeToType<std::basic_string<Element, Traits, Allocator> >
    {
        typedef StringType type;
        typedef Element element;
    };

    template<>
    struct TypeToType<GUID>
    {
        typedef GuidType type;
    };    
    
    template<typename Type>
    struct ContainerType
    {
        typedef ListType type;
    };

    template<>
    struct ContainerType<signed char>
    {
        typedef BytesType type;
    };

    template<>
    struct ContainerType<unsigned char>
    {
        typedef BytesType type;
    };

    template<>
    struct ContainerType<char>
    {
        typedef BytesType type;
    };    

    template<typename Type>
    struct StaticArrayType
    {
        typedef ListType type;
    };

    template<>
    struct StaticArrayType<signed char>
    {
        typedef BytesType type;
    };

    template<>
    struct StaticArrayType<unsigned char>
    {
        typedef BytesType type;
    };

    template<>
    struct StaticArrayType<char>
    {
        typedef StringType type;
    };

#ifndef BOOST_NO_INTRINSIC_WCHAR_T    
    template<>
    struct StaticArrayType<wchar_t>
    {
        typedef StringType type;
    };
#endif

#ifndef BOOST_NO_CHAR16_T    
    template<>
    struct StaticArrayType<char16_t>
    {
        typedef StringType type;
    };
#endif

#ifndef BOOST_NO_CHAR32_T
    template<>
    struct StaticArrayType<char32_t>
    {
        typedef StringType type;
    };
#endif

    template<typename Element, size_t ArraySize>
    struct TypeToType<std::tr1::array<Element, ArraySize> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

#ifdef BOOST_HAS_TR1_ARRAY
    template<typename Element, size_t ArraySize>
    struct TypeToType<boost::array<Element, ArraySize> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };
#endif

    template<typename Element, typename Allocator>
    struct TypeToType<std::vector<Element, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Allocator>
    struct TypeToType<std::list<Element, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Allocator>
    struct TypeToType<std::deque<Element, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Container>
    struct TypeToType<std::stack<Element, Container> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Container>
    struct TypeToType<std::queue<Element, Container> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Compare, typename Allocator>
    struct TypeToType<std::set<Element, Compare, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Compare, typename Allocator>
    struct TypeToType<std::multiset<Element, Compare, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<unsigned int Bits>
    struct TypeToType<std::bitset<Bits> >
    {
        typedef ListType type;
        typedef bool element;
    };

    template<typename Element, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<std::tr1::unordered_set<Element, Hash, EqualTo, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<std::tr1::unordered_multiset<Element, Hash, EqualTo, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

#ifdef BOOST_HAS_TR1_UNORDERED_SET
    template<typename Element, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<boost::unordered_set<Element, Hash, EqualTo, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };

    template<typename Element, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<boost::unordered_multiset<Element, Hash, EqualTo, Allocator> >
    {
        typedef BOOST_DEDUCED_TYPENAME ContainerType<Element>::type type;
        typedef Element element;
    };
#endif

    template<typename KeyType, typename ValueType, typename Compare, typename Allocator>
    struct TypeToType<std::map<KeyType, ValueType, Compare, Allocator> >
    {
        typedef MapType type;
        typedef KeyType key;
        typedef ValueType value;
    };

    template<typename KeyType, typename ValueType, typename Compare, typename Allocator>
    struct TypeToType<std::multimap<KeyType, ValueType, Compare, Allocator> >
    {
        typedef MapType type;
        typedef KeyType key;
        typedef ValueType value;
    };

    template<typename KeyType, typename ValueType, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<std::tr1::unordered_map<KeyType, ValueType, Hash, EqualTo, Allocator> >
    {
        typedef MapType type;
        typedef KeyType key;
        typedef ValueType value;
    };

    template<typename KeyType, typename ValueType, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<std::tr1::unordered_multimap<KeyType, ValueType, Hash, EqualTo, Allocator> >
    {
        typedef MapType type;
        typedef KeyType key;
        typedef ValueType value;
    };

#ifdef BOOST_HAS_TR1_UNORDERED_MAP
    template<typename KeyType, typename ValueType, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<boost::unordered_map<KeyType, ValueType, Hash, EqualTo, Allocator> >
    {
        typedef MapType type;
        typedef KeyType key;
        typedef ValueType value;
    };

    template<typename KeyType, typename ValueType, typename Hash, typename EqualTo, typename Allocator>
    struct TypeToType<boost::unordered_multimap<KeyType, ValueType, Hash, EqualTo, Allocator> >
    {
        typedef MapType type;
        typedef KeyType key;
        typedef ValueType value;
    };
#endif

    template<typename Type>
    struct NonCVType
      : public TypeToType<BOOST_DEDUCED_TYPENAME std::tr1::remove_cv<Type>::type>::type
    {
    };

    template<typename Type>
    struct NonCVListType
      : public ContainerType<BOOST_DEDUCED_TYPENAME std::tr1::remove_cv<Type>::type>::type
    {
    };

    template<typename Type>
    struct NonCVArrayType
      : public StaticArrayType<BOOST_DEDUCED_TYPENAME std::tr1::remove_cv<Type>::type>::type
    {
    };

    template<typename Type>
    struct NonCVElementType
    {
        typedef BOOST_DEDUCED_TYPENAME std::tr1::remove_cv<Type>::type noncv;
        typedef BOOST_DEDUCED_TYPENAME TypeToType<noncv>::element type;
    };

    template<typename Type>
    struct NonCVKeyType
    {
        typedef BOOST_DEDUCED_TYPENAME std::tr1::remove_cv<Type>::type noncv;
        typedef BOOST_DEDUCED_TYPENAME TypeToType<noncv>::key type;
    };

    template<typename Type>
    struct NonCVValueType
    {
        typedef BOOST_DEDUCED_TYPENAME std::tr1::remove_cv<Type>::type noncv;
        typedef BOOST_DEDUCED_TYPENAME TypeToType<noncv>::value type;
    };

} // namespace hprose

#endif
