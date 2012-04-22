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
 * HproseClient.h                                         *
 *                                                        *
 * hprose client header for Objective-C.                  *
 *                                                        *
 * LastModified: Jun 21, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseInvoker.h"

#if defined(Block_copy) && defined(Block_release)
typedef void (^HproseErrorEvent)(NSString *, NSException *);
#endif

@interface HproseClient : NSObject<HproseInvoker> {
    NSString *uri;
    BOOL defaultUTC;
    id defaultDelegate;
    SEL onError;
#if defined(Block_copy) && defined(Block_release)
    HproseErrorEvent errorHandler;
#endif
}

@property (copy) NSString *uri;
@property BOOL utc;
@property (assign, nonatomic) id delegate;
@property SEL onError;
#if defined(Block_copy) && defined(Block_release)
@property (copy) HproseErrorEvent errorHandler;
#endif

+ (id) client;
+ (id) client:(NSString *)uri;

- (id) init:(NSString *)uri;

- (id) useService:(Protocol *)protocol;
- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns;

@end
