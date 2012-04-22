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
 * classes.hpp                                            *
 *                                                        *
 * hprose classes unit for cpp.                           *
 *                                                        *
 * LastModified: Jun 5, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_CLASSES_INCLUDED
#define HPROSE_CLASSES_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/common.hpp>

#include <boost/tr1/unordered_map.hpp>
#include <boost/thread/shared_mutex.hpp>
#include <boost/thread/locks.hpp>

#include <map>

#define HPROSE_REG_CLASS(Class) \
    hprose::classes::register_class(&typeid(Class), #Class)
#define HPROSE_REG_CLASS_EX(Class, Alias) \
    hprose::classes::register_class(&typeid(Class), Alias)
#define HPROSE_REG_PROPERTY(Class, Property) \
    hprose::classes::register_property(&typeid(Class), #Property, &Class::Property)
#define HPROSE_REG_PROPERTY_EX(Class, Property, Alias) \
    hprose::classes::register_property(&typeid(Class), Alias, &Class::Property)

#define HproseRegClass      HPROSE_REG_CLASS
#define HproseRegClassEx    HPROSE_REG_CLASS_EX
#define HproseRegProperty   HPROSE_REG_PROPERTY
#define HproseRegPropertyEx HPROSE_REG_PROPERTY_EX

namespace hprose
{
    struct serialize_cache
    {
        int ref_count;
        std::string data;
    };

    class classes
    {
    public:

        typedef std::map<const std::type_info *, std::string, type_info_less> ClassAliases;
        typedef std::map<const std::type_info *, serialize_cache, type_info_less> ClassCaches;
        typedef std::tr1::unordered_map<std::string, any> PropertyMap;
        typedef std::tr1::unordered_map<std::string, PropertyMap> PropertyMaps;

    public:

        inline static void register_class(const std::type_info * type, const std::string & alias)
        {
            boost::unique_lock<boost::shared_mutex> lock(alias_mutex);
            aliases[type] = alias;
        }

        inline static void register_cache(const std::type_info * type, const serialize_cache & cache)
        {
            boost::unique_lock<boost::shared_mutex> lock(cache_mutex);
            caches[type] = cache;
        }

        template<typename ValueType>
        inline static void register_property(const std::type_info * type, const std::string & name, ValueType value)
        {
            std::string alias = find_alias(type);
            if (!alias.empty())
            {
                boost::unique_lock<boost::shared_mutex> lock(property_mutex);
                properties[alias][name] = value;
            }
        }

        inline static std::string find_alias(const std::type_info * type)
        {
            boost::shared_lock<boost::shared_mutex> lock(alias_mutex);
            ClassAliases::const_iterator itr = aliases.find(type);
            return (itr != aliases.end()) ? itr->second : std::string();
        }

        inline static const std::type_info * find_type(const std::string & alias)
        {
            boost::shared_lock<boost::shared_mutex> lock(alias_mutex);
            for (ClassAliases::const_iterator itr = aliases.begin(); itr != aliases.end(); ++itr)
            {
                if (itr->second == alias)
                {
                    return itr->first;
                }
            }
            return 0;
        }

        inline static serialize_cache find_cache(const std::type_info * type)
        {
            boost::shared_lock<boost::shared_mutex> lock(cache_mutex);
            ClassCaches::const_iterator itr = caches.find(type);
            return (itr != caches.end()) ? itr->second : serialize_cache();
        }

    private:

        friend class reader;
        friend class writer;

        static ClassAliases aliases;
        static ClassCaches caches;
        static PropertyMaps properties;
        static boost::shared_mutex alias_mutex; // read-write lock for aliases;
        static boost::shared_mutex cache_mutex; // read-write lock for caches;
        static boost::shared_mutex property_mutex; // read-write lock for properties;

    }; // class classes

} // namespace hprose

#endif
