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
 * HproseClient.m                                         *
 *                                                        *
 * hprose client for Objective-C.                         *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <objc/message.h>
#import <objc/runtime.h>
#import "HproseException.h"
#import "HproseReader.h"
#import "HproseWriter.h"
#import "HproseTags.h"
#import "HproseHelper.h"
#import "HproseClient.h"
#import "HproseClientProxy.h"
#import "HproseConnection.h"
#import "HproseAsyncInvoke.h"

@interface HproseClient(HproseConnection)<HproseConnection>
@end

@interface HproseAsyncInvoke : NSObject<HproseAsyncInvoke> {
    HproseClient *client;
    NSString *name;
    NSMutableArray *args;
    char type;
    Class cls;
    BOOL byRef;
    BOOL utc;
    id context;
    HproseCallback callback;
    id delegate;
    SEL selector;
    id defaultDelegate;
    SEL onError;
#if defined(Block_copy) && defined(Block_release)
    HproseBlock block;
    HproseErrorEvent errorHandler;
#endif
    HproseResultMode mode;
}

@property (retain) HproseClient *client;
@property (copy) NSString *name;
@property (retain) NSMutableArray *args;
@property char type;
@property (assign, nonatomic) Class cls;
@property BOOL byRef;
@property BOOL utc;
@property HproseCallback callback;
@property (retain) id delegate;
@property (retain) id defaultDelegate;
@property SEL selector;
@property SEL onError;
#if defined(Block_copy) && defined(Block_release)
@property (copy) HproseBlock block;
@property (copy) HproseErrorEvent errorHandler;
@property HproseResultMode mode;
#endif

- (void) invoke;
- (void) successCallback;
- (void) errorCallback:(NSException *)e;

@end

@implementation HproseAsyncInvoke

@synthesize client;
@synthesize name;
@synthesize args;
@synthesize type;
@synthesize cls;
@synthesize byRef;
@synthesize utc;
@synthesize callback;
@synthesize delegate;
@synthesize defaultDelegate;
@synthesize selector;
@synthesize onError;
#if defined(Block_copy) && defined(Block_release)
@synthesize block;
@synthesize errorHandler;
@synthesize mode;
#endif

- (void) dealloc {
    [client release];
    [name release];
    [args release];
    [delegate release];
    [defaultDelegate release];
#if defined(Block_copy) && defined(Block_release)
    [block release];
    [errorHandler release];
#endif
    [super dealloc];
}

- (void) invoke {
    NSOutputStream *ostream = nil;
    BOOL success = NO;
    @try {
        ostream = [client getOutputStreamAsync:nil];
        [client doOutput:ostream withName:name withArgs:args byRef:byRef UTC:utc];
        success = YES;
    }
    @catch (NSException *e) {
        [self errorCallback:e];
    }
    @finally {
        context = [client sendDataAsync:ostream withContext:self isSuccess:success];
        
    }
}

- (void) successCallback {
    BOOL success = NO;
    id result = nil;
    NSInputStream *istream = nil;
    @try {
        NSInputStream *istream = [client getInputStreamAsync:context];
        result = [client doInput:istream withArgs:args resultClass:cls resultType:type resultMode:mode];
        success = YES;
    }
    @catch (NSException *e) {
        [self errorCallback:e];
        return;
    }
    @finally {
        [client endInvokeAsync:istream withContext:context isSuccess:success];
    }
    if ([result isMemberOfClass:[HproseException class]]) {
        [self errorCallback:result];
        return;
    }
    if (callback) {
        callback(result, args);        
    }
#if defined(Block_copy) && defined(Block_release)
    else if (block) {
        block(result, args);
    }
#endif
    else if (delegate != nil && selector != NULL) {
        NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
        NSUInteger n = [methodSignature numberOfArguments];
        switch (n) {
            case 2:
                objc_msgSend(delegate, selector);
                break;
            case 3:
            case 4: {
                switch (type) {
                    case _C_ID: {
                        if (n == 3) {
                            objc_msgSend(delegate, selector, result);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, result, args);                            
                        }
                        break;
                    }
                    case _C_CHR: {
                        char value = [result charValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char value = [result unsignedCharValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_SHT: {
                        short value = [result shortValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_USHT: {
                        unsigned short value = [result unsignedShortValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_INT: {
                        int value = [result intValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_UINT: {
                        unsigned int value = [result unsignedIntValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_LNG: {
                        long value = [result longValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long value = [result unsignedLongValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long value = [result longLongValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long value = [result unsignedLongLongValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_FLT: {
                        float value = [result floatValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_DBL: {
                        double value = [result doubleValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_BOOL: {
                        BOOL value = [result boolValue];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                    case _C_CHARPTR: {
                        const char *value = [result UTF8String];
                        if (n == 3) {
                            objc_msgSend(delegate, selector, value);                            
                        }
                        else {
                            objc_msgSend(delegate, selector, value, args);                            
                        }
                        break;
                    }
                }
                break;
            }
        }        
    }    
}

- (void) errorCallback:(NSException *)e {
    if ([delegate respondsToSelector:onError]) {
        [delegate performSelector:onError withObject:name withObject:e];
    }
#if defined(Block_copy) && defined(Block_release)
    else if (errorHandler) {
        errorHandler(name, e);
    }
#endif
    else if ([defaultDelegate respondsToSelector:onError]) {
        [defaultDelegate performSelector:onError withObject:name withObject:e];
    }
    else {
        NSLog(@"%@", e);        
    }
}

@end

@interface HproseClient(PrivateMethods)
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode UTC:(BOOL)utc;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode UTC:(BOOL)utc callback:(HproseCallback)callback;
#if defined(Block_copy) && defined(Block_release)
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode UTC:(BOOL)utc block:(HproseBlock)block;
#endif

@end

@implementation HproseClient

@synthesize uri;
@synthesize utc=defaultUTC;
@synthesize delegate=defaultDelegate;
@synthesize onError;
#if defined(Block_copy) && defined(Block_release)
@synthesize errorHandler;
#endif

+ (id) client {
    return [[[self alloc] init] autorelease];
}

+ (id) client:(NSString *)aUri {
    return [[[self alloc] init:aUri] autorelease];
}

- (id) init:(NSString *)aUri {
    if ((self = [super init])) {
        [self setUri:aUri];
    }
    return (self);
}

- (void) dealloc {
    [uri release];
#if defined(Block_copy) && defined(Block_release)
    [errorHandler release];
#endif
    [super dealloc];
}

- (id) useService:(Protocol *)protocol {
    return [self useService:protocol withNameSpace:nil];
}

- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns {
    return [[[HproseClientProxy alloc] init:protocol withClient:self withNameSpace:ns] autorelease];
}

- (id) invoke:(NSString *)name {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:NO];
}
- (id) invoke:(NSString *)name resultType:(char)type {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:NO];
}
- (id) invoke:(NSString *)name resultClass:(Class)cls {
    return [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:NO];
}
- (id) invoke:(NSString *)name resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:NO];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:defaultUTC];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls {
    return [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:defaultUTC];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:utc];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:utc];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:utc];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:utc];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:defaultUTC];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls {
    return [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode UTC:defaultUTC];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:utc];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:utc];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:utc];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode UTC:(BOOL)utc {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode UTC:utc];
}



- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:NO callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:defaultUTC callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:defaultUTC callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:utc callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:utc callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:utc callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:utc callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:defaultUTC callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode UTC:defaultUTC callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:utc callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:utc callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:utc callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode UTC:(BOOL)utc callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode UTC:utc callback:callback];
}



#if defined(Block_copy) && defined(Block_release)
- (oneway void) invoke:(NSString *)name block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:NO block:block];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:NO block:block];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:NO block:block];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:NO block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:defaultUTC block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:defaultUTC block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:utc block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:utc block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:utc block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode UTC:utc block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:defaultUTC block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:defaultUTC block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode UTC:defaultUTC block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal UTC:utc block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal UTC:utc block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal UTC:utc block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode UTC:(BOOL)utc block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode UTC:utc block:block];
}
#endif

- (oneway void) invoke:(NSString *)name selector:(SEL)selector {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO UTC:NO selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO UTC:NO selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO UTC:NO selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:NO UTC:defaultUTC selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO UTC:defaultUTC selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO UTC:defaultUTC selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args UTC:(BOOL)utc selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:NO UTC:utc selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args UTC:(BOOL)utc delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO UTC:utc selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args UTC:(BOOL)utc selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO UTC:utc selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:byRef UTC:defaultUTC selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef UTC:defaultUTC selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef UTC:defaultUTC selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:byRef UTC:utc selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef UTC:utc selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc selector:(SEL)selector delegate:(id)delegate {
    id asyncInvoke = [[HproseAsyncInvoke new] autorelease];
    [asyncInvoke setClient:self];
    [asyncInvoke setName:name];
    [asyncInvoke setArgs:args];
    [asyncInvoke setByRef:byRef];
    [asyncInvoke setUtc:utc];
    [asyncInvoke setCls:Nil];
    [asyncInvoke setType:_C_ID];
    [asyncInvoke setMode:HproseResultMode_Normal];
    [asyncInvoke setCallback:NULL];
    if (delegate == nil) delegate = defaultDelegate;
    if (delegate == nil && selector == NULL) {
        [asyncInvoke invoke];
        return;
    }
    if (selector == NULL) {
        selector = @selector(callback);
        if (![delegate respondsToSelector:selector]) {
            selector = @selector(callback:);
            if (![delegate respondsToSelector:selector]) {
                selector = @selector(callback:withArgs:);
            }
        }
    }
    [asyncInvoke setDefaultDelegate:defaultDelegate];    
    [asyncInvoke setDelegate:delegate];    
    [asyncInvoke setSelector:selector];
    [asyncInvoke setOnError:onError];
#if defined(Block_copy) && defined(Block_release)
    [asyncInvoke setBlock:nil];
    [asyncInvoke setErrorHandler:errorHandler];
#endif
    NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
    if (methodSignature == nil) {
        [asyncInvoke errorCallback:[HproseException exceptionWithReason:
                            [NSString stringWithFormat:
                             @"Not support this callback: %@, the delegate doesn't respond to the selector.",
                            NSStringFromSelector(selector)]]];
        return;
    }
    NSUInteger n = [methodSignature numberOfArguments];
    if (n < 2 || n > 4) {
        [asyncInvoke errorCallback:[HproseException exceptionWithReason:
                            [NSString stringWithFormat:
                             @"Not support this callback: %@, number of arguments is wrong.",
                            NSStringFromSelector(selector)]]];
        return;
    }
    if (n > 2) {
        const char *type = [methodSignature getArgumentTypeAtIndex:2];
        if (type != NULL && [HproseHelper isSerializableType:type[0]]) {
            if (type[0] == _C_ID) {
                if (strlen(type) > 3) {
                    NSString *className = [[NSString stringWithUTF8String:type]
                                           substringWithRange:
                                           NSMakeRange(2, strlen(type) - 3)];
                    [asyncInvoke setCls:objc_getClass([className UTF8String])];
                }
            }
            [asyncInvoke setType:type[0]];
        }
        else {
            [asyncInvoke errorCallback:[HproseException exceptionWithReason:
                                        [NSString stringWithFormat:@"Not support this type: %s", type]]];
            return;
        }
    }
    [asyncInvoke invoke];
}

- (void) doOutput:(NSOutputStream *)ostream withName:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc {
    HproseWriter *writer = [HproseWriter writerWithStream:ostream];
    [writer setUtc:utc];
    [ostream writeByte:HproseTagCall];
    [writer writeString:name checkRef:NO];
    if (args != nil && ([args count] > 0 || byRef)) {
        [writer reset];
        [writer writeArray:args checkRef:NO];
        if (byRef) {
            [writer writeBoolean:YES];
        }
    }
    [ostream writeByte:HproseTagEnd];
}

- (id) doInput:(NSInputStream *)istream withArgs:(NSMutableArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode {
    HproseReader *reader = [HproseReader readerWithStream:istream];
    char expectTags[] = {HproseTagResult, HproseTagArgument, HproseTagError, HproseTagEnd, 0};
    int tag;
    id result = nil;
    NSOutputStream * ostream = nil;
    if (mode == HproseResultMode_RawWithEndTag || mode == HproseResultMode_Raw) {
        ostream = [[NSOutputStream alloc] initToMemory];
        [ostream open];
    }
    @try {
        while ((tag = [reader checkTags:expectTags]) != HproseTagEnd) {
            switch (tag) {
                case HproseTagResult: {
                    if (mode == HproseResultMode_Normal) {
                        [reader reset];
                        result = [reader unserialize:cls withType:type];                    
                    }
                    else if (mode == HproseResultMode_Serialized) {
                        result = [reader readRaw];
                    }
                    else {
                        [ostream writeByte:HproseTagResult];
                        [reader readRaw:ostream];
                    }
                    break;
                }
                case HproseTagArgument: {
                    if (mode == HproseResultMode_RawWithEndTag || mode == HproseResultMode_Raw) {
                        [ostream writeByte:HproseTagArgument];
                        [reader readRaw:ostream];
                    }
                    else {
                        [reader reset];
                        NSArray *arguments = [reader readArray];
                        if (args != nil) {
                            for (int i = 0, n = [args count]; i < n; i++) {
                                [args replaceObjectAtIndex:i withObject:[arguments objectAtIndex:i]];
                            }
                        }
                    }
                    break;
                }
                case HproseTagError: {
                    if (mode == HproseResultMode_RawWithEndTag || mode == HproseResultMode_Raw) {
                        [ostream writeByte:HproseTagError];
                        [reader readRaw:ostream];
                    }
                    else {
                        [reader reset];
                        result = [HproseException exceptionWithReason:[reader readString]];
                    }
                    break;
                }
            }
        }
        if (mode == HproseResultMode_RawWithEndTag || mode == HproseResultMode_Raw) {
            if (mode == HproseResultMode_RawWithEndTag) {
                [ostream writeByte:HproseTagEnd];
            }
            result = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        }
    }
    @finally {
        if (mode == HproseResultMode_RawWithEndTag || mode == HproseResultMode_Raw) {
            [ostream close];
            [ostream release];
        }
    }
    return result;
}

@end

@implementation HproseClient(PrivateMethods)

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode UTC:(BOOL)utc {
    id context = nil;
    NSOutputStream *ostream = [self getOutputStream:context];
    BOOL success = NO;
    @try {
        [self doOutput:ostream withName:name withArgs:args byRef:byRef UTC:utc];
        success = YES;
    }
    @finally {
        context = [self sendData:ostream withContext:context isSuccess:success];
    }
    NSInputStream *istream = [self getInputStream:context];
    success = NO;
    id result = nil;
    @try {
        result = [self doInput:istream withArgs:args resultClass:cls resultType:type resultMode:mode];
        success = YES;
    }
    @finally {
        [self endInvoke:istream withContext:context isSuccess:success];
    }
    if ([result isMemberOfClass:[HproseException class]]) {
        @throw result;
    }
    return result;
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode UTC:(BOOL)utc callback:(HproseCallback)callback {
    id asyncInvoke = [[HproseAsyncInvoke new] autorelease];
    [asyncInvoke setClient:self];
    [asyncInvoke setName:name];
    [asyncInvoke setArgs:args];
    [asyncInvoke setByRef:byRef];
    [asyncInvoke setCls:cls];
    [asyncInvoke setType:type];
    [asyncInvoke setMode:mode];
    [asyncInvoke setUtc:utc];
    [asyncInvoke setCallback:callback];
    [asyncInvoke setDefaultDelegate:defaultDelegate];
    [asyncInvoke setDelegate:defaultDelegate];
    [asyncInvoke setOnError:onError];
#if defined(Block_copy) && defined(Block_release)
    [asyncInvoke setBlock:nil];
    [asyncInvoke setErrorHandler:errorHandler];
#endif    
    [asyncInvoke invoke];
}

#if defined(Block_copy) && defined(Block_release)
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode UTC:(BOOL)utc block:(HproseBlock)block {
    id asyncInvoke = [[HproseAsyncInvoke new] autorelease];
    [asyncInvoke setClient:self];
    [asyncInvoke setName:name];
    [asyncInvoke setArgs:args];
    [asyncInvoke setByRef:byRef];
    [asyncInvoke setCls:cls];
    [asyncInvoke setType:type];
    [asyncInvoke setMode:mode];
    [asyncInvoke setUtc:utc];
    [asyncInvoke setCallback:NULL];
    [asyncInvoke setDefaultDelegate:defaultDelegate];
    [asyncInvoke setDelegate:defaultDelegate];
    [asyncInvoke setOnError:onError];
    [asyncInvoke setBlock:block];
    [asyncInvoke setErrorHandler:errorHandler];
    [asyncInvoke invoke];
}
#endif    

@end
