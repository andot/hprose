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
 * cookie.hpp                                             *
 *                                                        *
 * hprose cookie unit for cpp.                            *
 *                                                        *
 * LastModified: May 30, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_COOKIE_INCLUDED
#define HPROSE_COOKIE_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/common.hpp>

#include <boost/tr1/unordered_map.hpp>
#include <boost/thread/shared_mutex.hpp>

namespace hprose
{
    struct cookie
    {
        cookie()
          : expiry(0), secure(false)
        {
        }

        bool expired() const;

        bool good() const;

        std::string rawform() const;

        std::string name;
        std::string value;
        std::string domain;
        std::string path;
        std::time_t expiry;
        bool secure;
    };

    class cookies
    {
    public:

        static std::string get_cookie(const std::string & host, const std::string & path, bool secure = false);

        static void set_cookie(const std::string & host, std::string value);

    private:

        typedef std::tr1::unordered_map<std::string, cookie> DomainCookies;
        typedef std::tr1::unordered_map<std::string, DomainCookies> AllCookies;

        static AllCookies container;
        static boost::shared_mutex mutex; // read-write lock for containers

    }; // class cookies

} // namespace hprose

#endif
