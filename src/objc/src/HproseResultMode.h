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
 * HproseResultMode.h                                     *
 *                                                        *
 * hprose tags header for Objective-C.                    *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

typedef enum {
    HproseResultMode_Normal,
    HproseResultMode_Serialized,
    HproseResultMode_Raw,
    HproseResultMode_RawWithEndTag,
} HproseResultMode;