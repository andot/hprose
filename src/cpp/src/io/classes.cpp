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
 * classes.cpp                                            *
 *                                                        *
 * hprose classes unit for cpp.                           *
 *                                                        *
 * LastModified: May 31, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#include <hprose/io/classes.hpp>

namespace hprose
{
    classes::ClassAliases classes::aliases;
    classes::ClassCaches classes::caches;
    classes::PropertyMaps classes::properties;
    boost::shared_mutex classes::alias_mutex;
    boost::shared_mutex classes::cache_mutex;
    boost::shared_mutex classes::property_mutex;

} // namespace hprose 
