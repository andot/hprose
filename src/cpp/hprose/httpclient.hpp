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
 * httpclient.hpp                                         *
 *                                                        *
 * hprose http client class unit for Cpp.                 *
 *                                                        *
 * LastModified: Jun 27, 2011                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_HTTPCLIENT_INCLUDED
#define HPROSE_HTTPCLIENT_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/client/asio/httpclient.hpp>

namespace hprose {
    typedef asio::httpclient httpclient;
}

#endif
