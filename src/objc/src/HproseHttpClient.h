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
 * HproseHttpClient.h                                     *
 *                                                        *
 * hprose http client header for Objective-C.             *
 *                                                        *
 * LastModified: Jun 10, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseClient.h"

@interface HproseHttpClient : HproseClient {
    NSURL *url;
    NSTimeInterval timeout;
    BOOL keepAlive;
    int keepAliveTimeout;
    NSMutableDictionary *header;
}

@property NSTimeInterval timeout;
@property BOOL keepAlive;
@property int keepAliveTimeout;
@property (readonly) NSDictionary *header;

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end
