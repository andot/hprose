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
 * HproseAsyncInvoke.h                                    *
 *                                                        *
 * hprose asyncInvoke protocol for Objective-C.           *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@protocol HproseAsyncInvoke

- (void) invoke;
- (void) successCallback;
- (void) errorCallback:(NSException *)e;

@end
