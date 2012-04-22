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
 * HproseHelper.m                                         *
 *                                                        *
 * hprose helper class for Objective-C.                   *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseProperty.h"
#import "HproseClassManager.h"
#import "HproseHelper.h"


@implementation NSInputStream(HproseHelper)

- (int) readByte {
    uint8_t b = 0;
    if ([self read:&b maxLength:1] == 1) return b;
    return -1;
}

- (void) readBuffer:(uint8_t *)buffer maxLength:(NSUInteger)length {
    NSInteger totalLength = [self read:buffer maxLength:length];
    while (totalLength < length) {
        NSInteger readLength = [self read:buffer + totalLength maxLength:length - totalLength];
        if (readLength <= 0) {
            @throw [NSException exceptionWithName:@"NSReadBufferException"
                                           reason:@"Stream read error"
                                         userInfo:nil];
        }
        else {
            totalLength += readLength;
        }
    }
}

@end

@implementation NSOutputStream(HproseHelper)

- (NSInteger) writeByte:(uint8_t)b {
    return [self write:&b maxLength:1];
}

- (void) writeBuffer:(const uint8_t *)buffer maxLength:(NSUInteger)length {
    NSInteger totalLength = [self write:buffer maxLength:length];
    while (totalLength < length) {
        NSInteger writtenLength = [self write:buffer + totalLength maxLength:length - totalLength];
        if (writtenLength <= 0) {
            @throw [NSException exceptionWithName:@"NSWriteBufferException"
                                           reason:@"Stream write error"
                                         userInfo:nil];
        }
        else {
            totalLength += writtenLength;
        }
    }
}

- (void) copyFrom:(NSInputStream *)source maxLength:(NSUInteger)length {
    const NSInteger MAX_BUFFER_SIZE = 0xf000;
    NSInteger bufSize, n;
    if (length > MAX_BUFFER_SIZE) {
        bufSize = MAX_BUFFER_SIZE;
    }
    else {
        bufSize = length;
    }
    uint8_t *buffer = malloc(bufSize);
    @try {
        while (length > 0) {
            if (length > bufSize) {
                n = bufSize;
            }
            else {
                n = length;
            }
            [source readBuffer:buffer maxLength:n];
            [self writeBuffer:buffer maxLength:n];
            length -= n;
        }
    }
    @finally {
        free(buffer);
    }
}

@end

id getHprosePropertyFormMethod(Class cls, Method method) {
    if (method_getNumberOfArguments(method) > 2) return nil;
    HproseProperty *property = [[HproseProperty alloc] init];
    char *type = method_copyReturnType(method);
    SEL getter = method_getName(method);
    NSString *name = NSStringFromSelector(getter);
    [property setName:name];
    BOOL serializable = NO;
    if ([HproseHelper isSerializableType:type[0]]) {
        [property setType:type[0]];
        if (type[0] == _C_ID) {
            if (strlen(type) > 3) {
                NSString *className = [[NSString stringWithUTF8String:type]
                                       substringWithRange:
                                       NSMakeRange(2, strlen(type) - 3)];
                [property setCls:objc_getClass([className UTF8String])];
            }
        }
        NSString *setterName = [NSString stringWithFormat:@"set%@%@:",
                                [[name substringToIndex:1] uppercaseString],
                                [name substringFromIndex:1]];
        SEL setter = NSSelectorFromString(setterName);
        Method setterMethod = class_getInstanceMethod(cls, setter);
        if (setterMethod != NULL) {
            char * setterType = method_copyArgumentType(setterMethod, 2);
            if (type[0] == setterType[0]) {
                IMP getterImp = method_getImplementation(method);
                IMP setterImp = method_getImplementation(setterMethod);
                [property setGetter:getter];
                [property setSetter:setter];
                [property setGetterImp:getterImp];
                [property setSetterImp:setterImp];
                serializable = YES;
            }
            free(setterType);
        }
    }
    free(type);
    if (serializable) {
        [property autorelease];
        return property;
    }
    else {
        [property release];
        return nil;
    }
}

id getHprosePropertyFormProperty(Class cls, objc_property_t prop) {
    HproseProperty *property = [[HproseProperty alloc] init];
    NSString *name = [NSString stringWithUTF8String:property_getName(prop)];
    [property setName:name];
    NSArray *propAttrs = [[NSString stringWithUTF8String:
                           property_getAttributes(prop)]
                          componentsSeparatedByString:@","];
    SEL getter = NULL, setter = NULL;
    char type;
    BOOL serializable = YES;
    for (NSString *propAttr in propAttrs) {
        switch ([propAttr characterAtIndex:0]) {
            case 'T':
                serializable = NO;
                type = [propAttr characterAtIndex:1];
                if ([HproseHelper isSerializableType:type]) {
                    [property setType:type];
                    serializable = YES;
                }
                if (type == _C_ID) {
                    if ([propAttr length] > 4) {
                        NSString *className = [propAttr substringWithRange:
                                               NSMakeRange(3, [propAttr length] - 4)];
                        [property setCls:objc_getClass([className UTF8String])];
                    }
                }
                break;
            case 'G':
                getter = NSSelectorFromString([propAttr substringFromIndex:1]);
                [property setGetter:getter];
                [property setGetterImp:class_getMethodImplementation(cls, getter)]; 
                break;
            case 'S':
                setter = NSSelectorFromString([propAttr substringFromIndex:1]);
                [property setSetter:setter];
                [property setSetterImp:class_getMethodImplementation(cls, setter)];
                break;
            default:
                break;
        }
        if (!serializable) break;
    }
    if (serializable) {
        if (getter == NULL) {
            getter = NSSelectorFromString(name);
            [property setGetter:getter];
            [property setGetterImp:class_getMethodImplementation(cls, getter)];
        }
        if (setter == NULL) {
            NSString *setterName = [NSString stringWithFormat:@"set%@%@:",
                                    [[name substringToIndex:1] uppercaseString],
                                    [name substringFromIndex:1]];
            setter = NSSelectorFromString(setterName);
            [property setSetter:setter];
            [property setSetterImp:class_getMethodImplementation(cls, setter)];
        }
        [property autorelease];
        return property;
    }
    else {
        [property release];
        return nil;
    }
}

id getHproseProperties1(Class cls) {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    Class c = cls;
    while (c != Nil && c != [NSObject class]) {
        unsigned int count;
        Method *methods = class_copyMethodList(c, &count);
        for (unsigned int i = 0; i < count; i++) {
            HproseProperty *property = getHprosePropertyFormMethod(cls, methods[i]);
            if (property != nil) {
                [properties setObject:property
                               forKey:NSStringFromSelector(method_getName(methods[i]))];
            }
        }
        free(methods);
        c = class_getSuperclass(c);
    }
    return properties;
}

id getHproseProperties2(Class cls) {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    Class c = cls;
    while (c != Nil && c != [NSObject class]) {
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(cls, &count);
        for (unsigned int i = 0; i < count; i++) {
            HproseProperty *property = getHprosePropertyFormProperty(cls, props[i]);
            if (property != nil) {
                [properties setObject:property
                               forKey:[NSString stringWithUTF8String:
                                       property_getName(props[i])]];
            }
        }
        free(props);
        c = class_getSuperclass(c);
    }
    return properties;
}

void deallocHproseAutoObject(id self, SEL _cmd) {
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        id var = object_getIvar(self, ivar);
        [var release];
    }
    free(ivars);
    IMP dealloc = class_getMethodImplementation([self superclass], _cmd);
    ((void (*)(id, SEL))dealloc)(self, _cmd);
}

id getHproseAutoObjectProperty(id self, SEL _cmd) {
    id property;
    NSString *name = NSStringFromSelector(_cmd);
    object_getInstanceVariable(self,
                               (const char *)[name UTF8String],
                               (void **)(&property));
    return property;
}

void setHproseAutoObjectProperty(id self, SEL _cmd, id value) {
    id property;
    NSString *name = NSStringFromSelector(_cmd);
    name = [NSString stringWithFormat:@"%c%@",
            tolower([name characterAtIndex:3]),
            [name substringWithRange:
             NSMakeRange(4, [name length] - 5)]];
    object_getInstanceVariable(self,
                               (const char *)[name UTF8String],
                               (void **)(&property));
    [value retain];
    [property release];
    object_setInstanceVariable(self,
                               (const char *)[name UTF8String],
                               value);
}

@implementation HproseHelper

static NSMutableDictionary *gPropertiesCache;

+ (void) initialize {
    if (self == [HproseHelper class]) {
        gPropertiesCache = [[NSMutableDictionary alloc] init];        
    }
}

+ (BOOL) isSerializableType:(char)type {
    switch (type) {
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
            return YES;
    }
    return NO;
}

+ (NSDictionary *) getHproseProperties:(Class)cls {
    NSMutableDictionary *properties = nil;
    @synchronized(gPropertiesCache) {
        properties = [gPropertiesCache objectForKey:cls];
    }
    if (properties != nil) return properties;
    properties = getHproseProperties2(cls);
    if (properties == nil || [properties count] == 0) {
        properties = getHproseProperties1(cls);
    }
    @synchronized(gPropertiesCache) {
        [gPropertiesCache setObject:properties forKey:cls];
    }
    return properties;
}

+ (NSString *) getClassName:(Class)cls {
    NSString *className = [HproseClassManager getClassAlias:cls];
    if (className == nil) {
        className = [NSString stringWithUTF8String:class_getName(cls)];
        [HproseClassManager registerClass:cls withAlias:className];
    }
    return className;
}

+ (Class) getClass:(NSString *)className {
    if ([HproseClassManager containsClass:className]) {
        return [HproseClassManager getClass:className];
    }
    Class cls = objc_getClass([className UTF8String]);
    [HproseClassManager registerClass:cls withAlias:className];
    return cls;
}

+ (Class) createClass:(NSString *)className withPropNames:(NSArray *)propNames {
    Class cls = objc_allocateClassPair([NSObject class], [className UTF8String], 0);
    class_addMethod(cls, @selector(dealloc), (IMP)deallocHproseAutoObject, "v@:");
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:[propNames count]];
    for (NSString *propName in propNames) {
        HproseProperty *property = [[HproseProperty alloc] init];
        SEL getter = NSSelectorFromString(propName);
        SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",
                                           [[propName substringToIndex:1] uppercaseString],
                                           [propName substringFromIndex:1]]);
        class_addIvar(cls, [propName UTF8String], sizeof(id), log2(sizeof(id)), "@");
        class_addMethod(cls, getter, (IMP)getHproseAutoObjectProperty, "@@:");
        class_addMethod(cls, setter, (IMP)setHproseAutoObjectProperty, "v@:@");
        [property setName:propName];
        [property setType:'@'];
        [property setGetter:getter];
        [property setGetterImp:(IMP)getHproseAutoObjectProperty];
        [property setSetter:setter];
        [property setSetterImp:(IMP)setHproseAutoObjectProperty];
        [properties setObject:property forKey:propName];                    
        [property release];
    }
    objc_registerClassPair(cls);
    [HproseClassManager registerClass:cls withAlias:className];
    @synchronized(gPropertiesCache) {
        [gPropertiesCache setObject:properties forKey:cls];
    }
    return cls;
}

@end