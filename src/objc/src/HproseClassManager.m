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
 * hprose class manager for Objective-C.                  *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import "HproseClassManager.h"

@implementation HproseClassManager

static NSMutableDictionary *gClassCache1;
static NSMutableDictionary *gClassCache2;

+ (void) initialize {
    if (self == [HproseClassManager class]) {
        gClassCache1 = [[NSMutableDictionary alloc] init];        
        gClassCache2 = [[NSMutableDictionary alloc] init];        
    }
}

+ (void) registerClass:(Class)cls withAlias:(NSString *)alias {
    @synchronized (gClassCache1) {
        if (cls == Nil) {
            [gClassCache1 setObject:alias forKey:[NSNull null]];
        }
        else {
            [gClassCache1 setObject:alias forKey:cls];
        }
    }
    @synchronized (gClassCache2) {
        if (cls == Nil) {
            [gClassCache2 setObject:[NSNull null] forKey:alias];          
        }
        else {
            [gClassCache2 setObject:cls forKey:alias];          
        }
    }
}

+ (NSString *) getClassAlias:(Class)cls {
    NSString *alias = nil;
    @synchronized (gClassCache1) {
        alias = [gClassCache1 objectForKey:cls];
    }
    return alias;
}

+ (Class) getClass:(NSString *)alias {
    id cls = Nil;
    @synchronized (gClassCache2) {
        cls = [gClassCache2 objectForKey:alias];
    }
    if (cls == [NSNull null]) cls = Nil;
    return cls;
}

+ (BOOL) containsClass:(NSString *)alias {
    BOOL contains = NO;
    @synchronized (gClassCache2) {
        contains = ([gClassCache2 objectForKey:alias] != nil);
    }
    return contains;
}

@end
