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
 * version.hpp                                            *
 *                                                        *
 * hprose version unit for cpp.                           *
 *                                                        *
 * LastModified: Jul 13, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_VERSION_INCLUDED
#define HPROSE_VERSION_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#define HPROSE_VERSION 100300
#define HPROSE_MAJOR_VERSION (HPROSE_VERSION / 100000)
#define HPROSE_MINOR_VERSION (HPROSE_VERSION / 100 % 1000)

#define HPROSE_LIB_VERSION "1_3"

#endif
