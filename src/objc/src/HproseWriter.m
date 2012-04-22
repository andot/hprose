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
 * HproseWriter.m                                         *
 *                                                        *
 * hprose writer class for Objective-C.                   *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseException.h"
#import "HproseTags.h"
#import "HproseProperty.h"
#import "HproseHelper.h"
#import "HproseWriter.h"

@interface HproseWriter(PrivateMethods)

- (NSUInteger) writeClass:(Class)cls;
- (void) writeRef:(NSUInteger)r;
- (BOOL) writeRef:(id)o checkRef:(BOOL)b;
- (void) writeProperty:(HproseProperty *)property forObject:(id)o;

- (void) writeInt8:(int8_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeInt16:(int16_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeInt32:(int32_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeInt64:(int64_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt8:(uint8_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt16:(uint16_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt32:(uint32_t)i withStream:(NSOutputStream *)dataStream;
- (void) writeUInt64:(uint64_t)i withStream:(NSOutputStream *)dataStream;

@end

@implementation HproseWriter

@synthesize stream;
@synthesize utc;

static NSDateFormatter *gDateFormatter;
static NSDateFormatter *gTimeFormatter;
static NSDateFormatter *gUTCDateFormatter;
static NSDateFormatter *gUTCTimeFormatter;
static Class classOfNSCFBoolean;

+ (void) initialize {
    if (self == [HproseWriter class]) {
        gDateFormatter = [[NSDateFormatter alloc] init];
        gTimeFormatter = [[NSDateFormatter alloc] init];
        gUTCDateFormatter = [[NSDateFormatter alloc] init];
        gUTCTimeFormatter = [[NSDateFormatter alloc] init];
        [gDateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [gTimeFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [gUTCDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [gUTCTimeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [gDateFormatter setDateFormat:@"yyyyMMdd"];
        [gTimeFormatter setDateFormat:@"HHmmss.SSS"];
        [gUTCDateFormatter setDateFormat:@"yyyyMMdd"];
        [gUTCTimeFormatter setDateFormat:@"HHmmss.SSS"];
        NSNumber *b = [[NSNumber alloc] initWithBool:YES];
        classOfNSCFBoolean = [b class];
        [b release];
    }
}

- (id) init {
    if((self = [super init])) {
        classref = [[NSMutableArray alloc] init];
        ref = [[NSMutableArray alloc] init];
    }
    return (self);
}

- (void) dealloc {
    [stream release];
    [classref release];
    [ref release];
    [super dealloc];
}

- (id) initWithStream:(NSOutputStream *)dataStream {
    if ((self = [self init])) {
        [dataStream retain];
        [stream release];
        stream = dataStream;
    }
    return (self);
}

+ (id) writerWithStream:(NSOutputStream *)dataStream {
    return [[[HproseWriter alloc] initWithStream:dataStream] autorelease];
}

- (void) serialize:(id)obj {
    if (obj == nil || obj == [NSNull null]) {
        [self writeNull];
        return;
    }
    Class c = [obj class];
    if (c == classOfNSCFBoolean) {
        [self writeBoolean:[obj boolValue]];
    }
    else if ([c isSubclassOfClass:[NSNumber class]]) {
        [self writeNumber:(NSNumber *)obj];
    }
    else if ([c isSubclassOfClass:[NSDate class]]) {
        if (utc) {
            [self writeUTCDate:(NSDate *)obj checkRef:YES];
        }
        else {
            [self writeDate:(NSDate *)obj checkRef:YES];            
        }
    }
    else if ([c isSubclassOfClass:[NSData class]]) {
        if ([obj length] > 0) {
            [self writeData:(NSData *)obj checkRef:YES];
        }
        else {
            [self writeEmpty];
        }
    }
    else if ([c isSubclassOfClass:[NSString class]]) {
        if ([obj length] == 0) {
            [self writeEmpty];
        }
        else if ([obj length] == 1) {
            [self writeUTF8Char:[obj characterAtIndex:0]];
        }
        else {
            [self writeString:(NSString *)obj checkRef:YES];
        }
    }
    else if ([c isSubclassOfClass:[NSArray class]]) {
        [self writeArray:(NSArray *)obj checkRef:YES];
    }
    else if ([c isSubclassOfClass:[NSDictionary class]]) {
        [self writeDict:(NSDictionary *)obj checkRef:YES];
    }
    else {
        [self writeObject:obj checkRef:YES];
    }
}

- (void) writeInt8:(int8_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeInt8: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeInt16:(int16_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeInt16: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeInt32:(int32_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeInt32: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeInt64:(int64_t)i {
    if (i >= 0 && i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagLong];
    [self writeInt64: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt8:(uint8_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeUInt8: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt16:(uint16_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagInteger];
    [self writeUInt16: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt32:(uint32_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagLong];
    [self writeUInt32: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeUInt64:(uint64_t)i {
    if (i <= 9) {
        [stream writeByte:'0' + i];
        return;
    }
    [stream writeByte:HproseTagLong];
    [self writeUInt64: i withStream: stream];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeBigInteger:(NSString *)bi {
    [stream writeByte:HproseTagLong];
    NSData * data = [bi dataUsingEncoding:NSASCIIStringEncoding];
    [stream writeBuffer:[data bytes] maxLength:[data length]];
    [stream writeByte:HproseTagSemicolon];
}

- (void) writeFloat:(float)f {
    if (isnan(f)) {
        [self writeNaN];
    }
    else if (isinf(f)) {
        if (signbit(f)) {
            [self writeNInf];
        }
        else {
            [self writeInf];
        }
    }
    else {
        [stream writeByte:HproseTagDouble];
        NSData * data = [[[NSNumber numberWithFloat:f] stringValue]
                         dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
}

- (void) writeDouble:(double)d {
    if (isnan(d)) {
        [self writeNaN];
    }
    else if (isinf(d)) {
        if (signbit(d)) {
            [self writeNInf];
        }
        else {
            [self writeInf];
        }
    }
    else {
        [stream writeByte:HproseTagDouble];
        NSData * data = [[[NSNumber numberWithDouble:d] stringValue]
                         dataUsingEncoding:NSASCIIStringEncoding];
        [stream writeBuffer:[data bytes] maxLength:[data length]];
        [stream writeByte:HproseTagSemicolon];
    }
}

- (void) writeNumber:(NSNumber *)n {
    if([n class] == classOfNSCFBoolean) {
        [self writeBoolean:[n boolValue]];
    }
    else {
        const char *type = [n objCType];
        switch (type[0]) {
            case _C_CHR:
                [self writeInt8:[n charValue]];
                break;
            case _C_SHT:
                [self writeInt16:[n shortValue]];
                break;
            case _C_INT:
                [self writeInt32:[n intValue]];
                break;
            case _C_LNG:
                (sizeof(long) == 4) ?
                [self writeInt32:[n longValue]] :
                [self writeInt64:[n longValue]];
                break;
            case _C_LNG_LNG:
                [self writeInt64:[n longLongValue]];
                break;
            case _C_UCHR:
                [self writeUInt8:[n unsignedCharValue]];
                break;
            case _C_USHT:
                [self writeUInt16:[n unsignedShortValue]];
                break;
            case _C_UINT:
                [self writeUInt32:[n unsignedIntValue]];
                break;
            case _C_ULNG:
                (sizeof(unsigned long) == 4) ?
                [self writeUInt32:[n unsignedLongValue]] :
                [self writeUInt64:[n unsignedLongValue]];
                break;
            case _C_ULNG_LNG:
                [self writeUInt64:[n unsignedLongLongValue]];
                break;
            case _C_FLT:
                [self writeFloat:[n floatValue]];
                break;
            case _C_DBL:
                [self writeDouble:[n doubleValue]];
                break;
            case _C_BOOL:
                [self writeBoolean:[n boolValue]];
                break;
            default:
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithFormat:
                         @"Not support this type: %s", type]];
                break;
        }
    }
}

- (void) writeNull {
    [stream writeByte:HproseTagNull];
}

- (void) writeNaN {
    [stream writeByte:HproseTagNaN];
}

- (void) writeInf {
    [stream writeByte:HproseTagInfinity];
    [stream writeByte:HproseTagPos];   
}

- (void) writeNInf {
    [stream writeByte:HproseTagInfinity];
    [stream writeByte:HproseTagNeg]; 
}

- (void) writeEmpty {
    [stream writeByte:HproseTagEmpty];
}

- (void) writeBoolean:(BOOL)b {
    [stream writeByte:(b ? HproseTagTrue : HproseTagFalse)];
}

- (void) writeDate:(NSDate *)date {
    [self writeDate:date checkRef:YES];
}

- (void) writeDate:(NSDate *)date checkRef:(BOOL)b {
    if ([self writeRef:date checkRef:b]) {
        NSString *d = [gDateFormatter stringFromDate:date];
        NSString *t = [gTimeFormatter stringFromDate:date];
        NSData * data;
        if ([t isEqualToString:@"000000.000"]) {
            [stream writeByte:HproseTagDate];
            data = [d dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagSemicolon];
        }
        else if ([d isEqualToString:@"19700101"]) {
            [stream writeByte:HproseTagTime];
            data = [t dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagSemicolon];
        }
        else {
            [stream writeByte:HproseTagDate];
            data = [d dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagTime];
            data = [t dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagSemicolon];
        }
    }
}

- (void) writeUTCDate:(NSDate *)date {
    [self writeUTCDate:date checkRef:YES];
}

- (void) writeUTCDate:(NSDate *)date checkRef:(BOOL)b {
    if ([self writeRef:date checkRef:b]) {
        NSString *d = [gUTCDateFormatter stringFromDate:date];
        NSString *t = [gUTCTimeFormatter stringFromDate:date];
        NSData * data;
        if ([t isEqualToString:@"000000.000"]) {
            [stream writeByte:HproseTagDate];
            data = [d dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagUTC];
        }
        else if ([d isEqualToString:@"19700101"]) {
            [stream writeByte:HproseTagTime];
            data = [t dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagUTC];
        }
        else {
            [stream writeByte:HproseTagDate];
            data = [d dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagTime];
            data = [t dataUsingEncoding:NSASCIIStringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
            [stream writeByte:HproseTagUTC];
        }
    }
}

- (void) writeBytes:(const uint8_t *)bytes length:(int)l {
    NSData * data = [[NSData alloc] initWithBytesNoCopy:(void *)bytes
                                    length:l
                                    freeWhenDone:NO];
    [self writeData:data];
    [data release];
}

- (void) writeBytes:(const uint8_t *)bytes length:(int)l checkRef:(BOOL)b {
    NSData * data = [[NSData alloc] initWithBytesNoCopy:(void *)bytes
                                    length:l
                                    freeWhenDone:NO];
    [self writeData:data checkRef:b];
    [data release];
}

- (void) writeData:(NSData *)data {
    [self writeData:data checkRef:YES];
}

- (void) writeData:(NSData *)data checkRef:(BOOL)b {
    if ([self writeRef:data checkRef:b]) {
        [stream writeByte:HproseTagBytes];
        int length = [data length];
        if (length > 0) {
            [self writeInt32:length withStream:stream];            
        }
        [stream writeByte:HproseTagQuote];
        if (length > 0) {
            [stream writeBuffer:[data bytes] maxLength:length];
        }
        [stream writeByte:HproseTagQuote];
    }
}

- (void) writeUTF8Char:(unichar)c {
    [stream writeByte:HproseTagUTF8Char];
    if (c < 0x80) {
        [stream writeByte:c];
    }
    else if (c < 0x800) {
        [stream writeByte:(0xc0 | (c >> 6))];
        [stream writeByte:(0x80 | (c & 0x3f))];
    }
    else {
        [stream writeByte:(0xe0 | (c >> 12))];
        [stream writeByte:(0x80 | ((c >> 6) & 0x3f))];
        [stream writeByte:(0x80 | (c & 0x3f))];
    }
}

- (void) writeString:(NSString *)s {
    [self writeString:s checkRef:YES];
}

- (void) writeString:(NSString *)s checkRef:(BOOL)b {
    if ([self writeRef:s checkRef:b]) {
        [stream writeByte:HproseTagString];
        int length = [s length];
        if (length > 0) {
            [self writeInt32:length withStream:stream];            
        }
        [stream writeByte:HproseTagQuote];
        if (length > 0) {
            NSData * data = [s dataUsingEncoding:NSUTF8StringEncoding];
            [stream writeBuffer:[data bytes] maxLength:[data length]];
        }
        [stream writeByte:HproseTagQuote];
    }
}

- (void) writeArray:(NSArray *)a {
    [self writeArray:a checkRef:YES];
}

- (void) writeArray:(NSArray *)a checkRef:(BOOL)b {
    if ([self writeRef:a checkRef:b]) {
        [stream writeByte:HproseTagList];
        int count = [a count];
        if (count > 0) {
            [self writeInt32:count withStream:stream];            
        }
        [stream writeByte:HproseTagOpenbrace];
        if (count > 0) {
            for (id obj in a) {
                [self serialize:obj];
            }
        }
        [stream writeByte:HproseTagClosebrace];
    }
}

- (void) writeDict:(NSDictionary *)m {
    [self writeDict:m checkRef:YES];
}

- (void) writeDict:(NSDictionary *)m checkRef:(BOOL)b {
    if ([self writeRef:m checkRef:b]) {
        [stream writeByte:HproseTagMap];
        int count = [m count];
        if (count) {
            [self writeInt32:count withStream:stream];
        }
        [stream writeByte:HproseTagOpenbrace];
        if (count > 0) {
            for (id key in m) {
                [self serialize:key];
                [self serialize:[m objectForKey:key]];
            }
        }
        [stream writeByte:HproseTagClosebrace];
    }
}

- (void) writeObject:(id)o {
    [self writeObject:o checkRef:YES];
}

- (void) writeObject:(id)o checkRef:(BOOL)b {
    NSUInteger r = [ref indexOfObjectIdenticalTo:o];
    if (b && (r != NSNotFound)) {
        [self writeRef:r];
    }
    else {
        Class cls = [o class];
        NSUInteger cr = [classref indexOfObjectIdenticalTo:cls];
        if (cr == NSNotFound) {
            cr = [self writeClass:cls];
        }
        [ref addObject:o];
        NSDictionary * properties = [HproseHelper getHproseProperties:cls];
        [stream writeByte:HproseTagObject];
        [self writeInt32:cr withStream:stream];
        [stream writeByte:HproseTagOpenbrace];
        if ([properties count] > 0) {
            for (id name in properties) {
                [self writeProperty:[properties objectForKey:name] forObject:o];
            }
        }
        [stream writeByte:HproseTagClosebrace];
    }
}

- (void) reset {
    [ref removeAllObjects];
    [classref removeAllObjects];
}

@end

@implementation HproseWriter(PrivateMethods)

- (NSUInteger) writeClass:(Class)cls {
    NSDictionary * properties = [HproseHelper getHproseProperties:cls];
    [stream writeByte:HproseTagClass];
    NSString *className = [HproseHelper getClassName:cls];
    int len = [className length];
    [self writeInt32:len withStream:stream];
    [stream writeByte:HproseTagQuote];
    if (len > 0) {
        [stream writeBuffer:(void *)[className UTF8String] maxLength:len];
    }
    [stream writeByte:HproseTagQuote];
    int count = [properties count];
    if (count > 0) {
        [self writeInt32:count withStream:stream];
    }
    [stream writeByte:HproseTagOpenbrace];
    for (id name in properties) {
        [self writeString: name];
    }
    [stream writeByte:HproseTagClosebrace];
    [classref addObject:cls];
    return [classref count] - 1;
}

- (void) writeRef:(NSUInteger)r {
    [stream writeByte:HproseTagRef];
    [self writeInt32:r withStream:stream];
    [stream writeByte:HproseTagSemicolon];
}

- (BOOL) writeRef:(id)o checkRef:(BOOL)b {
    NSUInteger r = [ref indexOfObject:o];
    if (b && (r != NSNotFound)) {
        [self writeRef:r];
        return NO;
    }
    else {
        [ref addObject:o];
        return YES;
    }
}

- (void) writeProperty:(HproseProperty *)property forObject:(id)o {
    IMP getterImp = [property getterImp];
    SEL getter = [property getter];
    switch ([property type]) {
        case _C_ID:
            [self serialize:((id (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_CHR:
            [self writeInt8:((char (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_SHT:
            [self writeInt16:((short (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_INT:
            [self writeInt32:((int (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_LNG:
            (sizeof(long) == 4) ?
            [self writeInt32:((long (*)(id, SEL))getterImp)(o, getter)] :
            [self writeInt64:((long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_LNG_LNG:
            [self writeInt64:((long long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_UCHR:
            [self writeUInt8:((unsigned char (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_USHT:
            [self writeUInt16:((unsigned short (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_UINT:
            [self writeUInt32:((unsigned int (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_ULNG:
            (sizeof(unsigned long) == 4) ?
            [self writeUInt32:((unsigned long (*)(id, SEL))getterImp)(o, getter)] :
            [self writeUInt64:((unsigned long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_ULNG_LNG:
            [self writeUInt64:((unsigned long long (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_FLT:
            [self writeFloat:((float (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_DBL:
            [self writeDouble:((double (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_BOOL:
            [self writeBoolean:((bool (*)(id, SEL))getterImp)(o, getter)];
            break;
        case _C_CHARPTR:
            [self writeString:[NSString stringWithUTF8String:
                               ((const char * (*)(id, SEL))getterImp)(o, getter)]];
            break;
        default:
            @throw [HproseException exceptionWithReason:
                    [NSString stringWithFormat:
                     @"Not support this property: %@", [property name]]];
            break;
    }
}

- (void) writeInt8:(int8_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (abs(i % 10) + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeInt16:(int16_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (abs(i % 10) + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeInt32:(int32_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (abs(i % 10) + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeInt64:(int64_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i >= 0 && i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        BOOL neg = NO;
        if (i < 0) {
            neg = YES;
        }
        while (i != 0) {
            buf[--off] = (uint8_t) (abs(i % 10) + '0');
            ++len;
            i /= 10;
        }
        if (neg) {
            buf[--off] = '-';
            ++len;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeUInt8:(uint8_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeUInt16:(uint16_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeUInt32:(uint32_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

- (void) writeUInt64:(uint64_t)i withStream:(NSOutputStream *)dataStream {
    int off, len;
    if (i <= 9) {
        buf[0] = (uint8_t)(i + '0');
        off = 0;
        len = 1;
    }
    else {
        off = 20;
        len = 0;
        while (i != 0) {
            buf[--off] = (uint8_t) (i % 10 + '0');
            ++len;
            i /= 10;
        }
    }
    [dataStream writeBuffer:(void *)(buf + off) maxLength:len];
}

@end
