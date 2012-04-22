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
 * config.hpp                                             *
 *                                                        *
 * hprose config unit for cpp.                            *
 *                                                        *
 * LastModified: Jun 6, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_CONFIG_INCLUDED
#define HPROSE_CONFIG_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <boost/config.hpp>
#include <boost/version.hpp>

#define BOOST_MAJOR_VERSION (BOOST_VERSION / 100000)
#define BOOST_MINOR_VERSION (BOOST_VERSION / 100 % 1000)

#if BOOST_MAJOR_VERSION == 1
#   if BOOST_MINOR_VERSION < 36
#       error Boost version requires >= 1.36 // Asio requires >= 1.35, Unordered requires >= 1.36
#   elif BOOST_MINOR_VERSION < 44
#       if BOOST_MINOR_VERSION < 40
#           define BOOST_NO_AUTO_DECLARATIONS
#           define BOOST_NO_LAMBDAS
#           define BOOST_NO_NULLPTR
#       endif
#       if BOOST_MINOR_VERSION < 38
#           define BOOST_NO_INITIALIZER_LISTS
#       endif
#       ifndef BOOST_NO_STATIC_ASSERT
#           ifndef BOOST_HAS_STATIC_ASSERT
#               define BOOST_HAS_STATIC_ASSERT // Used in BOOST_STATIC_ASSERT
#           endif
#       endif
#   endif
#endif

#define HPROSE_NO_UNIQUE_PTR

#if defined(_MSC_VER) && (_MSC_VER >= 1600) // decltype supported by vc2010
#   ifdef BOOST_NO_DECLTYPE
#       undef BOOST_NO_DECLTYPE
#   endif
#   ifdef BOOST_NO_NULLPTR
#       undef BOOST_NO_NULLPTR
#   endif
#   undef HPROSE_NO_UNIQUE_PTR
#endif

#if (__GNUC__ == 4 && __GNUC_MINOR__ >= 4) && defined(__GXX_EXPERIMENTAL_CXX0X__)
#undef HPROSE_NO_UNIQUE_PTR
#endif

#if defined(_MSC_VER) && defined(_DEBUG)
#define HPROSE_DEBUG_MODE
#elif defined(__BORLANDC__) && (__BORLANDC__ > 0x561)
#pragma defineonoption HPROSE_DEBUG_MODE -v
#endif

#include <boost/static_assert.hpp>

#ifndef BOOST_NO_STATIC_ASSERT
#define HPROSE_STATIC_ASSERT(Exp, Msg) static_assert(Exp, Msg)
#else
#define HPROSE_STATIC_ASSERT(Exp, Msg) BOOST_STATIC_ASSERT(Exp)   
#endif

#ifdef BOOST_WINDOWS
#   ifdef __BORLANDC__
#       define _strcmpi strcmpi
#       define timezone _timezone
#   endif
#else
#   define _strcmpi strcasecmp
#   define _tzset tzset
#endif

#endif
