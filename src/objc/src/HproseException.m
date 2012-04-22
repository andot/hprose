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
 * HproseException.m                                      *
 *                                                        *
 * hprose exception class for Objective-C.                *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import "HproseException.h"

@implementation HproseException

+ (HproseException *)exceptionWithReason:(NSString *)reason {
    return (HproseException *)[HproseException
        exceptionWithName:@"HproseException"
        reason:reason
        userInfo:nil];
}

@end
