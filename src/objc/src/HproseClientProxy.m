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
 * HproseClientProxy.m                                    *
 *                                                        *
 * hprose client proxy for Objective-C.                   *
 *                                                        *
 * LastModified: Jun 21, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseException.h"
#import "HproseClient.h"
#import "HproseClientProxy.h"

NSMutableArray *getArguments(NSUInteger count, NSMethodSignature *methodSignature, NSInvocation *anInvocation, BOOL *byRef) {
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:count - 2];
    for (NSUInteger i = 2; i < count; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        id arg;
        int j = 0;
        char t = type[j];
        switch (t) {
            case 'r':
            case 'n':
            case 'N':
            case 'o':
            case 'O':
            case 'R':
            case 'V':
                if (t == 'N' || t == 'o' || t == 'R') {
                    *byRef = YES;
                }
                t = type[++j];
                break;
        }
        switch (t) {
            case _C_ID: {
                [anInvocation getArgument:&arg atIndex:i];
                if (arg == nil) arg = [NSNull null];
                break;
            }
            case _C_CHR: {
                char value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithChar:value];
                break;
            }
            case _C_UCHR: {
                unsigned char value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithUnsignedChar:value];
                break;
            }
            case _C_SHT: {
                short value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithShort:value];
                break;
            }
            case _C_USHT: {
                unsigned short value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithUnsignedShort:value];
                break;
            }
            case _C_INT: {
                int value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithInt:value];
                break;
            }
            case _C_UINT: {
                unsigned int value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithUnsignedInt:value];
                break;
            }
            case _C_LNG: {
                long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithLong:value];
                break;
            }
            case _C_ULNG: {
                unsigned long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithUnsignedLong:value];
                break;
            }
            case _C_LNG_LNG: {
                long long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithLongLong:value];
                break;
            }
            case _C_ULNG_LNG: {
                unsigned long long value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithUnsignedLongLong:value];
                break;
            }
            case _C_FLT: {
                float value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithFloat:value];
                break;
            }
            case _C_DBL: {
                double value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithDouble:value];
                break;
            }
            case _C_BOOL: {
                BOOL value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSNumber numberWithBool:value];
                break;
            }
            case _C_CHARPTR: {
                char *value;
                [anInvocation getArgument:&value atIndex:i];
                arg = [NSString stringWithUTF8String:value];
                break;
            }
            case _C_PTR: {
                switch (type[++j]) {
                    case _C_ID: {
                        id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = *value;
                        if (arg == nil) arg = [NSNull null];
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithChar:*value];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithUnsignedChar:*value];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithShort:*value];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithUnsignedShort:*value];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithInt:*value];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithUnsignedInt:*value];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithLong:*value];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithUnsignedLong:*value];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithLongLong:*value];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithUnsignedLongLong:*value];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithFloat:*value];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithDouble:*value];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSNumber numberWithBool:*value];
                        break;
                    }
                    case _C_CHARPTR: {
                        char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSString stringWithUTF8String:*value];
                        break;
                    }
                    default:
                        @throw [HproseException exceptionWithReason:
                                [NSString stringWithFormat:@"Not support this type: %s", type]];
                        break;
                }
                break;
            }
            case _C_ARY_B: {
                int n = 0;
                for (++j; isdigit(type[j]); ++j) n = n * 10 + (type[j] - '0');
                switch (type[j]) {
                    case _C_ID: {
                        id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:value[k]];
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithChar:value[k]]];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithUnsignedChar:value[k]]];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithShort:value[k]]];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithUnsignedShort:value[k]]];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithInt:value[k]]];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithUnsignedInt:value[k]]];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithLong:value[k]]];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithUnsignedLong:value[k]]];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithLongLong:value[k]]];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithUnsignedLongLong:value[k]]];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithFloat:value[k]]];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithDouble:value[k]]];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSNumber numberWithBool:value[k]]];
                        break;
                    }
                    case _C_CHARPTR: {
                        char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        arg = [NSMutableArray arrayWithCapacity:n];
                        for (int k = 0; k < n; ++k) [arg addObject:[NSString stringWithUTF8String:value[k]]];
                        break;
                    }
                    default:
                        @throw [HproseException exceptionWithReason:
                                [NSString stringWithFormat:@"Not support this type: %s", type]];
                        break;
                }                
                break;
            }
            default:
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithFormat:@"Not support this type: %s", type]];
                break;
        }
        [args addObject:arg];
    }
    return args;
}

void setArguments(NSUInteger count, NSMethodSignature *methodSignature, NSInvocation *anInvocation, NSMutableArray *args) {
    for (NSUInteger i = 2; i < count; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        id arg = [args objectAtIndex:i - 2];
        if (arg == [NSNull null]) arg = nil;
        int j = 0;
        BOOL byRef = NO;
        if (type[j] == 'N' || type[j] == 'o' || type[j] == 'R') {
            j++;
            byRef = YES;
        }
        switch (type[j]) {
            case _C_ID:
            case _C_CHR:
            case _C_UCHR:
            case _C_SHT:
            case _C_USHT:
            case _C_INT:
            case _C_UINT:
            case _C_LNG:
            case _C_ULNG:
            case _C_LNG_LNG:
            case _C_ULNG_LNG:
            case _C_FLT:
            case _C_DBL:
            case _C_BOOL:
            case _C_CHARPTR:
                break;
            case _C_PTR: {
                if (!byRef) break;
                switch (type[++j]) {
                    case _C_ID: {
                        id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = arg;
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg charValue];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedCharValue];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg shortValue];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedShortValue];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg intValue];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedIntValue];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg longValue];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedLongValue];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg longLongValue];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg unsignedLongLongValue];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg floatValue];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg doubleValue];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg boolValue];
                        break;
                    }
                    case _C_CHARPTR: {
                        const char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        *value = [arg UTF8String];
                        break;
                    }
                    default:
                        @throw [HproseException exceptionWithReason:
                                [NSString stringWithFormat:@"Not support this type: %s", type]];
                        break;
                }                   
                break;
            }
            case _C_ARY_B: {
                int n = 0;
                for (++j; isdigit(type[j]); ++j) n = n * 10 + (type[j] - '0');
                switch (type[j]) {
                    case _C_ID: {
                        id *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [arg objectAtIndex:k];
                        break;
                    }
                    case _C_CHR: {
                        char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] charValue];
                        break;
                    }
                    case _C_UCHR: {
                        unsigned char *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] unsignedCharValue];
                        break;
                    }
                    case _C_SHT: {
                        short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] shortValue];
                        break;
                    }
                    case _C_USHT: {
                        unsigned short *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] unsignedShortValue];
                        break;
                    }
                    case _C_INT: {
                        int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] intValue];
                        break;
                    }
                    case _C_UINT: {
                        unsigned int *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] unsignedIntValue];
                        break;
                    }
                    case _C_LNG: {
                        long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] longValue];
                        break;
                    }
                    case _C_ULNG: {
                        unsigned long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] unsignedLongValue];
                        break;
                    }
                    case _C_LNG_LNG: {
                        long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] longLongValue];
                        break;
                    }
                    case _C_ULNG_LNG: {
                        unsigned long long *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] unsignedLongLongValue];
                        break;
                    }
                    case _C_FLT: {
                        float *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] floatValue];
                        break;
                    }
                    case _C_DBL: {
                        double *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] doubleValue];
                        break;
                    }
                    case _C_BOOL: {
                        BOOL *value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] boolValue];
                        break;
                    }
                    case _C_CHARPTR: {
                        const char **value;
                        [anInvocation getArgument:&value atIndex:i];
                        for (int k = 0; k < n; ++k) value[k] = [[arg objectAtIndex:k] UTF8String];
                        break;
                    }
                    default:
                        @throw [HproseException exceptionWithReason:
                                [NSString stringWithFormat:@"Not support this type: %s", type]];
                        break;
                }
                break;
            }
            default:
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithFormat:@"Not support this type: %s", type]];
                break;
        }
    }
}

void setReturnValue(char type, id result, NSInvocation *anInvocation) {
    switch (type) {
        case _C_ID: {
            [anInvocation setReturnValue:&result];
            break;
        }
        case _C_CHR: {
            char value = [result charValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_UCHR: {
            unsigned char value = [result unsignedCharValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_SHT: {
            short value = [result shortValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_USHT: {
            unsigned short value = [result unsignedShortValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_INT: {
            int value = [result intValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_UINT: {
            unsigned int value = [result unsignedIntValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_LNG: {
            long value = [result longValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_ULNG: {
            unsigned long value = [result unsignedLongValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_LNG_LNG: {
            long long value = [result longLongValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_ULNG_LNG: {
            unsigned long long value = [result unsignedLongLongValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_FLT: {
            float value = [result floatValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_DBL: {
            double value = [result doubleValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_BOOL: {
            BOOL value = [result boolValue];
            [anInvocation setReturnValue:&value];
            break;
        }
        case _C_CHARPTR: {
            const char *value = [result UTF8String];
            [anInvocation setReturnValue:&value];
            break;
        }
        default:
            @throw [HproseException exceptionWithReason:
                    [NSString stringWithFormat:@"Not support this type: %c", type]];
            break;
    }    
}

@implementation HproseClientProxy

@synthesize protocol;
@synthesize client;
@synthesize ns;

- init:(Protocol *)aProtocol withClient:(HproseClient *)aClient withNameSpace:(NSString *)aNameSpace {
    [self setProtocol:aProtocol];
    [self setClient:aClient];
    [self setNs:aNameSpace];
    return (self);
}

- (void) dealloc {
    [client release];
    [ns release];
    [super dealloc];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSString *selname = NSStringFromSelector([anInvocation selector]);
    NSString *name = [[selname componentsSeparatedByString:@":"] objectAtIndex:0];
    if (ns != nil) {
        name = [NSString stringWithFormat:@"%@_%@", ns, name];
    }
    NSMethodSignature *methodSignature = [anInvocation methodSignature];
    NSUInteger count = [methodSignature numberOfArguments];
    const char *type = [methodSignature methodReturnType];
    HproseCallback callback = NULL;
#if defined(Block_copy) && defined(Block_release)
    HproseBlock block = nil;
#endif
    SEL selector = NULL;
    id delegate = nil;
    BOOL async = NO;
    if (type[0] == 'V' && type[1] == _C_VOID) {
        async = YES;
        if (count > 2) {
            type = [methodSignature getArgumentTypeAtIndex:count - 1];
            if (type[0] == _C_PTR && type[1] == _C_UNDEF) {
                [anInvocation getArgument:&callback atIndex:count - 1];
                count--;
            }
#if defined(Block_copy) && defined(Block_release)
            else if (type[0] == _C_ID && type[1] == _C_UNDEF) {
                [anInvocation getArgument:&block atIndex:count - 1];
                count--;
            }
#endif
            else if (type[0] == _C_ID) {
                if (count > 3) {
                    type = [methodSignature getArgumentTypeAtIndex:count - 2];
                    if (type[0] == _C_SEL) {
                        [anInvocation getArgument:&delegate atIndex:count - 1];
                        [anInvocation getArgument:&selector atIndex:count - 2];
                        count -= 2;
                    }
                }
            }
            else if (type[0] == _C_SEL) {
                [anInvocation getArgument:&selector atIndex:count - 1];
                count--;
            }
        }
    }
    BOOL byRef = NO;
    NSMutableArray *args = getArguments(count, methodSignature, anInvocation, &byRef);
    if (async) {
        if (callback != NULL) {
            [client invoke:name
                  withArgs:args
                     byRef:byRef
                  callback:callback];
        }
#if defined(Block_copy) && defined(Block_release)
        else if (block != nil) {
            [client invoke:name
                  withArgs:args
                     byRef:byRef
                     block:block];
        }
#endif
        else {
            [client invoke:name
                  withArgs:args
                     byRef:byRef
                  selector:selector
                  delegate:delegate];
        }
    }
    else {
        type = [methodSignature methodReturnType];
        char t = type[0];
        id result;
        if (t == _C_ID) {
            if (strlen(type) > 3) {
                NSString *className = [[NSString stringWithUTF8String:type]
                                       substringWithRange:
                                       NSMakeRange(2, strlen(type) - 3)];
                Class cls = objc_getClass([className UTF8String]);
                result = [client invoke:name
                               withArgs:args
                                  byRef:byRef
                            resultClass:cls];
            }
            else {
                result = [client invoke:name
                               withArgs:args
                                  byRef:byRef];                
            }
        }
        else {
            switch (t) {
                case 'r':
                case 'n':
                case 'N':
                case 'o':
                case 'O':
                case 'R':
                case 'V':
                    t = type[1];
                    break;
            }
            result = [client invoke:name
                           withArgs:args
                              byRef:byRef
                         resultType:t];
        }
        if (byRef) {
            setArguments(count, methodSignature, anInvocation, args);
        }
        setReturnValue(t, result, anInvocation);
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    const char *types = protocol_getMethodDescription(protocol, aSelector, YES, YES).types;
    return [NSMethodSignature signatureWithObjCTypes:types];
}

@end
