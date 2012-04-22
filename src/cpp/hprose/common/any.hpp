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
 * any.hpp                                                *
 *                                                        *
 * hprose any unit for cpp.                               *
 *                                                        *
 * LastModified: Jun 5, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_ANY_INCLUDED
#define HPROSE_ANY_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/common/exception.hpp>

#include <algorithm>
#include <typeinfo>

#include <boost/tr1/type_traits.hpp>

#if (defined(__GNUC__) && __GNUC__ >= 3) \
 || defined(_AIX) \
 || (defined(__sgi) && defined(__host_mips)) \
 || (defined(__hpux) && defined(__HP_aCC)) \
 || (defined(linux) && defined(__INTEL_COMPILER) && defined(__ICC))
#define BOOST_AUX_ANY_TYPE_ID_NAME
#include <cstring>
#endif

namespace hprose
{
    template<typename ValueType>
    struct is_const
      : public std::tr1::is_const<ValueType>
    {
    };

    template<typename ValueType>
    struct is_const<ValueType *>
      : public is_const<ValueType>
    {
    };

    template<typename Reader, typename Writer>
    class basic_any
    {
    public: // structors

        basic_any()
          : content(0)
        {
        }

        template<typename ValueType>
        basic_any(const ValueType & value)
          : content(new holder<ValueType, void>(value))
        {
        }

        template<typename ValueType, typename ClassType>
        basic_any(ValueType ClassType::*value)
          : content(new holder<ValueType ClassType::*, ClassType>(value))
        {
        }

        basic_any(const basic_any & other)
          : content(other.content ? other.content->clone() : 0)
        {
        }

        ~basic_any()
        {
            delete content;
        }

    public: // modifies

        basic_any & swap(basic_any & rhs)
        {
            std::swap(content, rhs.content);
            return *this;
        }

        template<typename T>
        basic_any & operator=(const T & rhs)
        {
            basic_any<Reader, Writer>(rhs).swap(*this);
            return *this;
        }

        basic_any & operator=(basic_any rhs)
        {
            rhs.swap(*this);
            return *this;
        }

    public: // queries

        bool empty() const
        {
            return !content;
        }

        const std::type_info & type() const
        {
            return content ? content->type() : typeid(void);
        }

    public: // serialize

        inline void unserialize(Reader & r)
        {
            if (content)
            {
                content->unserialize(r);
            }
            else
            {
                r.unserialize(*this);
            }
        }

        template<typename Object>
        inline void unserialize(Reader & r, Object & object)
        {
            if (content)
            {
                content->unserialize(r, &object);
            }
            else
            {
                r.unserialize(*this);
            }
        }

        inline void serialize(Writer & w) const
        {
            if (content)
            {
                content->serialize(w);
            }
            else
            {
                w.write_null();
            }
        }

        template<typename Object>
        inline void serialize(Writer & w, const Object & object) const
        {
            if (content)
            {
                content->serialize(w, &object);
            }
            else
            {
                w.write_null();
            }
        }

    private: // types

        class placeholder
        {
        public: // structors

            virtual ~placeholder()
            {
            }

        public: // queries

            virtual const std::type_info & type() const = 0;

            virtual placeholder * clone() const = 0;

            virtual void unserialize(Reader & r) = 0;

            virtual void unserialize(Reader & r, void * o) = 0;

            virtual void serialize(Writer & w) const = 0;

            virtual void serialize(Writer & w, const void * o) const = 0;

        };

        template<typename ValueType, typename ClassType>
        class holder : public placeholder
        {
        public: // structors

            holder(const ValueType & value)
              : held(value)
            {
            }

        public: // queries

            virtual const std::type_info & type() const
            {
                return typeid(ValueType);
            }

            virtual placeholder * clone() const
            {
                return new holder(held);
            }

            virtual void unserialize(Reader & r)
            {
                unserialize(r, is_const<ValueType>());
            }

            virtual void unserialize(Reader & r, void * o)
            {
                unserialize(r, o, std::tr1::is_member_pointer<ValueType>());
            }

            virtual void serialize(Writer & w) const
            {
                w.serialize(held);
            }

            virtual void serialize(Writer & w, const void * o) const
            {
                serialize(w, o, std::tr1::is_member_pointer<ValueType>());
            }

        private:

            inline void serialize(Writer & w, const void * o, const std::tr1::true_type &) const
            {
                const ClassType * p = static_cast<const ClassType *>(o);
                w.serialize(p->*held);
            }

            inline void serialize(Writer & w, const void * o, const std::tr1::false_type &) const
            {
                HPROSE_THROW_EXCEPTION("Can't serialize none member pointer");
            }

            inline void unserialize(Reader & r, const std::tr1::true_type &)
            {
                HPROSE_THROW_EXCEPTION("Constant value can't be unserialized");
            }

            inline void unserialize(Reader & r, const std::tr1::false_type &)
            {
                r.unserialize(held);
            }

            inline void unserialize(Reader & r, void * o, const std::tr1::true_type &)
            {
                ClassType * p = static_cast<ClassType *>(o);
                r.unserialize(p->*held);
            }

            inline void unserialize(Reader & w, void * o, const std::tr1::false_type &)
            {
                HPROSE_THROW_EXCEPTION("Can't unserialize none member pointer");
            }

        public: // representation

            ValueType held;

        private: // intentionally left unimplemented

            holder & operator=(const holder &);

        };

    public:

        template<typename ValueType>
        static ValueType * cast(basic_any<Reader, Writer> * operand)
        {
            return operand &&
            #ifdef BOOST_AUX_ANY_TYPE_ID_NAME
                std::strcmp(operand->type().name(), typeid(ValueType).name()) == 0
            #else
                operand->type() == typeid(ValueType)
            #endif
                ? &static_cast<BOOST_DEDUCED_TYPENAME basic_any<Reader, Writer>::BOOST_NESTED_TEMPLATE holder<ValueType, void> *>(operand->content)->held
                : 0;
        }

        template<typename ValueType>
        inline static const ValueType * cast(const basic_any<Reader, Writer> * operand)
        {
            return cast<ValueType>(const_cast<basic_any<Reader, Writer> *>(operand));
        }

        template<typename ValueType>
        static ValueType cast(basic_any<Reader, Writer> & operand)
        {
            typedef BOOST_DEDUCED_TYPENAME std::tr1::remove_reference<ValueType>::type nonref;
        #ifdef BOOST_NO_TEMPLATE_PARTIAL_SPECIALIZATION
            BOOST_STATIC_ASSERT(!is_reference<nonref>::value);
        #endif
            nonref * result = cast<nonref>(&operand);
            if (!result)
            {
                HPROSE_THROW_EXCEPTION("Failed conversion using hprose::any::cast");
            }
            return *result;
        }

        template<typename ValueType>
        inline static ValueType cast(const basic_any<Reader, Writer> & operand)
        {
            typedef BOOST_DEDUCED_TYPENAME std::tr1::remove_reference<ValueType>::type nonref;
        #ifdef BOOST_NO_TEMPLATE_PARTIAL_SPECIALIZATION
            BOOST_STATIC_ASSERT(!is_reference<nonref>::value);
        #endif
            return cast<const nonref &>(const_cast<basic_any<Reader, Writer> &>(operand));
        }

        template<typename ValueType>
        inline static ValueType * unsafe_cast(basic_any<Reader, Writer> * operand)
        {
            return &static_cast<BOOST_DEDUCED_TYPENAME basic_any<Reader, Writer>::BOOST_NESTED_TEMPLATE holder<ValueType, void> *>(operand->content)->held;
        }

        template<typename ValueType>
        inline static const ValueType * unsafe_cast(const basic_any<Reader, Writer> * operand)
        {
            return unsafe_cast<ValueType>(const_cast<basic_any<Reader, Writer> *>(operand));
        }

    private: // representation

        placeholder * content;

    };

    class reader;
    class writer;

    typedef basic_any<reader, writer> any;

} // namespace hprose

#endif
