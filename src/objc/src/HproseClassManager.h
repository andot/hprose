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
 * HproseClassManager.h                                   *
 *                                                        *
 * hprose class manager header for Objective-C.           *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseClassManager : NSObject 

+ (void) registerClass:(Class)cls withAlias:(NSString *)alias;
+ (NSString *) getClassAlias:(Class)cls;
+ (Class) getClass:(NSString *)alias;
+ (BOOL) containsClass:(NSString *)alias;

@end
