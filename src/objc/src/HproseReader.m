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
 * HproseReader.m                                         *
 *                                                        *
 * hprose reader class for Objective-C.                   *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <objc/runtime.h>
#import "HproseProperty.h"
#import "HproseException.h"
#import "HproseTags.h"
#import "HproseHelper.h"
#import "HproseReader.h"


@interface NSNumber(HproseReader)

+ (id) numberWithInt:(int)n withType:(char)type;
+ (id) numberWithString:(NSString *)s withType:(char)type;

@end

@implementation NSNumber(HproseReader)

+ (id) numberWithInt:(int)n withType:(char)type {
    switch (type) {
        case _C_ID:
        case _C_INT:
            return [NSNumber numberWithInt:n];
            break;
        case _C_CHR:
            return [NSNumber numberWithChar:(char)n];
            break;
        case _C_SHT:
            return [NSNumber numberWithShort:(short)n];
            break;
        case _C_LNG:
            return [NSNumber numberWithLong:(long)n];
            break;
        case _C_LNG_LNG:
            return [NSNumber numberWithLongLong:(long long)n];
            break;
        case _C_UCHR:
            return [NSNumber numberWithUnsignedChar:(unsigned char)n];
            break;
        case _C_USHT:
            return [NSNumber numberWithUnsignedShort:(unsigned short)n];
            break;
        case _C_UINT:
            return [NSNumber numberWithUnsignedInt:(unsigned int)n];
            break;
        case _C_ULNG:
            return [NSNumber numberWithUnsignedLong:(unsigned long)n];
            break;
        case _C_ULNG_LNG:
            return [NSNumber numberWithUnsignedLongLong:(unsigned long long)n];
            break;
        case _C_FLT:
            return [NSNumber numberWithFloat:(float)n];
            break;
        case _C_DBL:
            return [NSNumber numberWithDouble:(double)n];
            break;
        case _C_BOOL:
            return [NSNumber numberWithBool:(n != 0)];
            break;
    }
    @throw [HproseException exceptionWithReason:
            [NSString stringWithFormat:
             @"Not support this type: %c", type]];    
}

+ (id) numberWithString:(NSString *)s withType:(char)type {
    switch (type) {
        case _C_INT:
            return [NSNumber numberWithInt:[s intValue]];
            break;
        case _C_LNG:
            return [NSNumber numberWithLong:((sizeof(long) == 4) ? [s intValue] : [s longLongValue])];
            break;            
        case _C_LNG_LNG:
            return [NSNumber numberWithLongLong:[s longLongValue]];
            break;
        case _C_FLT:
            return [NSNumber numberWithFloat:[s floatValue]];
            break;
        case _C_DBL:
            return [NSNumber numberWithDouble:[s doubleValue]];
            break;
        case _C_BOOL:
            return [NSNumber numberWithBool:[s boolValue]];
            break;
        default:
            return [[[NSNumberFormatter new] autorelease] numberFromString:s];
            break;
    }
}

@end


@interface HproseReader(PrivateMethods)

- (id) readString:(int)tag withClass:(Class)cls withType:(char)type includeRef:(BOOL)b;
- (id) readObject:(Class)cls withCount:(int)count;
- (void) readProperty:(HproseProperty *)property forObject:(id)o;
- (void) readClass;
- (id) readRef;
- (void) readRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readNumberRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readDateTimeRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readUTF8CharRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readBytesRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readStringRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readGuidRaw:(NSOutputStream *)ostream withTag:(int)tag;
- (void) readComplexRaw:(NSOutputStream *)ostream withTag:(int)tag;

@end

void _throwCastException(NSString *clsname, Class cls) {
    @throw [HproseException exceptionWithReason:[NSString stringWithFormat:
            @"%@ can't change to %s", clsname, class_getName(cls)]];
}

@implementation HproseReader

@synthesize stream;

static double NaN, Infinity, NegInfinity;

+ (void) initialize {
    if (self == [HproseReader class]) {
        NaN = log((double)-1);
        Infinity = -log((double)0);
        NegInfinity = log((double)0);
    }
}

- (id) init {
    if((self = [super init])) {
        classref = [[NSMutableArray alloc] init];
        ref = [[NSMutableArray alloc] init];
        attrsref = [[NSMutableDictionary alloc] init];
    }
    return (self);
}

- (void) dealloc {
    [stream release];
    [classref release];
    [ref release];
    [attrsref release];
    [super dealloc];
}

- (id) initWithStream:(NSInputStream *)dataStream {
    if ((self = [self init])) {
        [dataStream retain];
        [stream release];
        stream = dataStream;
    }
    return (self);
}

+ (id) readerWithStream:(NSInputStream *)dataStream {
    return [[[HproseReader alloc] initWithStream:dataStream] autorelease];
}

- (id) unserialize {
    return [self unserialize:Nil withType:_C_ID withTag:[stream readByte]];
}

- (id) unserialize:(Class)cls {
    return [self unserialize:cls withType:_C_ID withTag:[stream readByte]];
}

- (id) unserialize:(Class)cls withType:(char)type {
    return [self unserialize:cls withType:type withTag:[stream readByte]];
}

- (id) unserialize:(Class)cls withType:(char)type withTag:(int)tag {
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            if (cls == Nil ||
                cls == [NSNumber class] ||
                cls == [NSValue class] ||
                cls == [NSObject class]) {
                return [NSNumber numberWithInt:(tag - '0') withType:type];
            }
            else if (cls == [NSString class] ||
                     cls == [NSMutableString class]) {
                return [NSMutableString stringWithFormat:@"%c", tag];
            }
            else if (cls == [NSDate class]) {
                return [NSDate dateWithTimeIntervalSince1970:(tag - '0')];
            }
            _throwCastException(@"Integer", cls);
            break;
        case HproseTagInteger:
        case HproseTagDouble:
            if (cls == Nil ||
                cls == [NSNumber class] ||
                cls == [NSValue class] ||
                cls == [NSObject class]) {
                return [self readNumber:tag withType:type];
            }
            else if (cls == [NSString class] ||
                cls == [NSMutableString class]) {
                return [self readUntil:HproseTagSemicolon];
            }
            else if (cls == [NSDate class]) {
                return [NSDate dateWithTimeIntervalSince1970:
                        [[self readUntil:HproseTagSemicolon] doubleValue]];
            }
            _throwCastException(@"Number", cls);
            break;
        case HproseTagLong:
            if (cls == Nil ||
                cls == [NSString class] ||
                cls == [NSMutableString class] ||
                cls == [NSObject class]) {
                return [self readUntil:HproseTagSemicolon];
            }
            else if (cls == [NSNumber class] ||
                cls == [NSValue class]) {
                return [self readNumber:tag withType:type];
            }
            else if (cls == [NSDate class]) {
                return [NSDate dateWithTimeIntervalSince1970:
                        [[self readUntil:HproseTagSemicolon] doubleValue]];
            }
            _throwCastException(@"Long", cls);
            break;
        case HproseTagNull:
            if (cls == [NSNumber class]) {
                return [NSNumber numberWithInt:0];
            }
            else if (cls == [NSNull class] || cls == [NSObject class]) {
                return [NSNull null];
            }
            return nil;
            break;
        case HproseTagEmpty:
            if (cls == Nil ||
                cls == [NSString class] ||
                cls == [NSObject class]) {
                return @"";
            }
            else if (cls == [NSMutableString class]) {
                return [NSMutableString string];
            }
            else if (cls == [NSData class]) {
                return [NSData data];
            }
            else if (cls == [NSMutableData class]) {
                return [NSMutableData data];
            }
            else if (cls == [NSNumber class] || cls == [NSValue class]) {
                return [NSNumber numberWithInt:0];
            }
            else if (cls == [NSNull class]) {
                return [NSNull null];
            }
            return nil;
            break;
        case HproseTagTrue:
            if (cls == Nil ||
                cls == [NSNumber class] ||
                cls == [NSValue class] ||
                cls == [NSObject class]) {
                return [NSNumber numberWithBool:YES];
            }
            else if (cls == [NSString class]) {
                return @"true";
            }
            else if (cls == [NSMutableString class]) {
                return [NSMutableString stringWithString:@"true"];
            }
            _throwCastException(@"Boolean", cls);
            break;
        case HproseTagFalse:
            if (cls == Nil ||
                cls == [NSNumber class] ||
                cls == [NSValue class] ||
                cls == [NSObject class]) {
                return [NSNumber numberWithBool:NO];
            }
            else if (cls == [NSString class]) {
                return @"false";
            }
            else if (cls == [NSMutableString class]) {
                return [NSMutableString stringWithString:@"false"];
            }
            _throwCastException(@"Boolean", cls);
            break;
        case HproseTagNaN:
            if (cls == Nil ||
                cls == [NSNumber class] ||
                cls == [NSValue class] ||
                cls == [NSObject class]) {
                return [NSNumber numberWithDouble:NaN];
            }
            else if (cls == [NSString class]) {
                return @"NaN";
            }
            else if (cls == [NSMutableString class]) {
                return [NSMutableString stringWithString:@"NaN"];
            }
            _throwCastException(@"NaN", cls);
            break;
        case HproseTagInfinity:
            if (cls == Nil ||
                cls == [NSNumber class] ||
                cls == [NSValue class] ||
                cls == [NSObject class]) {
                return [NSNumber numberWithDouble:
                        ([stream readByte] == HproseTagPos ?
                         Infinity : NegInfinity)];
            }
            else if (cls == [NSString class]) {
                return ([stream readByte] == HproseTagPos ?
                        @"Infinity" : @"-Infinity");
            }
            else if (cls == [NSMutableString class]) {
                return [NSMutableString stringWithString:
                        ([stream readByte] == HproseTagPos ?
                        @"Infinity" : @"-Infinity")];
            }
            _throwCastException(@"Infinity", cls);
            break;
        case HproseTagDate:
        case HproseTagTime:
            return [self readDate:tag withClass:cls];
            break;
        case HproseTagBytes:
            return [self readData:tag withClass:cls];
            break;
        case HproseTagUTF8Char:
            if (cls == Nil ||
                cls == [NSString class] ||
                cls == [NSMutableString class] ||
                cls == [NSObject class]) {
                unichar u = [self readUTF8Char:tag];
                return [NSMutableString stringWithCharacters:&u length:1];
            }
            else if (cls == [NSNumber class] ||
                cls == [NSValue class]) {
                return [NSNumber numberWithInt:[self readUTF8Char:tag] withType:type];
            }
            else if (cls == [NSData class]) {
                unichar u = [self readUTF8Char:tag];
                return [[NSString stringWithCharacters:&u length:1]
                        dataUsingEncoding:NSUTF8StringEncoding];
            }
            else if (cls == [NSMutableData class]) {
                unichar u = [self readUTF8Char:tag];
                return [NSMutableData dataWithData:
                        [[NSString stringWithCharacters:&u length:1]
                         dataUsingEncoding:NSUTF8StringEncoding]];
            }
            _throwCastException(@"unichar", cls);
            break;
        case HproseTagString:
            return [self readString:tag withClass:cls withType:type];
            break;
        case HproseTagGuid:
            if (cls == Nil ||
                cls == [NSString class] ||
                cls == [NSMutableString class] ||
                cls == [NSObject class]) {
                return [self readString:tag];
            }
            _throwCastException(@"Guid String", cls);
            break;
        case HproseTagList:
            return [self readArray:tag withClass:cls];
            break;
        case HproseTagMap:
            return [self readDict:tag withClass:cls];
            break;
        case HproseTagClass:
            [self readClass];
            return [self unserialize:cls withType:type withTag:[stream readByte]];
            break;
        case HproseTagObject:
            return [self readObject:tag withClass:cls];
            break;
        case HproseTagRef:
            return [self readRef];
            break;
        case HproseTagError:
            @throw [HproseException exceptionWithReason:[self readString]];
            break;
        case -1:
            @throw [HproseException exceptionWithReason:@"No byte found in stream"];
            break;
    }
    @throw [HproseException exceptionWithReason:@"Unexpected serialize tag in stream"];
}

- (void) checkTag:(int)expectTag {
    [self checkTag:expectTag withTag:[stream readByte]];
}

- (void) checkTag:(int)expectTag withTag:(int)tag {
    if (tag != expectTag) {
        @throw [HproseException exceptionWithReason:[NSString stringWithFormat:
        @"Tag '%c' expected, but '%c' found in stream", expectTag, tag]];
    }
}

- (int) checkTags:(char[])expectTags {
    return [self checkTags:expectTags withTag:[stream readByte]];
}

- (int) checkTags:(char[])expectTags withTag:(int)tag {
    for (int i = 0; expectTags[i] != 0; i++) {
        if (expectTags[i] == tag) return tag;
    }
    @throw [HproseException exceptionWithReason:[NSString stringWithFormat:
    @"Tag '%s' expected, but '%c' found in stream", expectTags, tag]];}

- (NSString *) readUntil:(int)tag {
    NSMutableString *s = [NSMutableString stringWithCapacity:255];
    char buf[256];
    int n = 0;
    int i = [stream readByte];
    while ((i != tag) && (i != -1)) {
        buf[n] = (char)i;
        if (n < 255) {
            ++n;
        }
        else {
            [s appendString:[NSString stringWithUTF8String:buf]];
            n = 0;
        }
        i = [stream readByte];
    }
    if (n > 0) {
        buf[n] = 0;
        [s appendString:[NSString stringWithUTF8String:buf]];
    }
    return s;
}

- (int8_t) readI8:(int)tag {
    int8_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int8_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (int16_t) readI16:(int)tag {
    int16_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int16_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (int32_t) readI32:(int)tag {
    int32_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int32_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (int64_t) readI64:(int)tag {
    int64_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    int64_t sign = 1;
    if (i == '+') {
        i = [stream readByte];
    }
    else if (i == '-') {
        sign = -1;
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (i - '0') * sign;
        i = [stream readByte];
    }
    return result;
}

- (uint8_t) readUI8:(int)tag {
    uint8_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint8_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (uint16_t) readUI16:(int)tag {
    uint16_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint16_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (uint32_t) readUI32:(int)tag {
    uint32_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint32_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (uint64_t) readUI64:(int)tag {
    uint64_t result = 0;
    int i = [stream readByte];
    if (i == tag) return result;
    if (i == '+') {
        i = [stream readByte];
    }
    while ((i != tag) && (i != -1)) {
        result *= 10;
        result += (uint64_t)(i - '0');
        i = [stream readByte];
    }
    return result;
}

- (int8_t) readInt8 {
    return [self readInt8:YES];
}

- (int8_t) readInt8:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (int8_t)(tag - '0');
        }
        [self checkTag:HproseTagInteger withTag:tag];
    }
    return [self readI8:HproseTagSemicolon];
}

- (int16_t) readInt16 {
    return [self readInt16:YES];
}

- (int16_t) readInt16:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (int16_t)(tag - '0');
        }
        [self checkTag:HproseTagInteger withTag:tag];
    }
    return [self readI16:HproseTagSemicolon];
}

- (int32_t) readInt32 {
    return [self readInt32:YES];
}

- (int32_t) readInt32:(int)tag {
    if (tag == -1) {
        int tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (int32_t)(tag - '0');
        }
        [self checkTag:HproseTagInteger withTag:tag];
    }
    return [self readI32:HproseTagSemicolon];    
}

- (int64_t) readInt64 {
    return [self readInt64:YES];
}

- (int64_t) readInt64:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (int64_t)(tag - '0');
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, 0};
        [self checkTags:expectTags withTag:tag];
    }
    return [self readI64:HproseTagSemicolon];    
}

- (uint8_t) readUInt8 {
    return [self readUInt8:YES];
}

- (uint8_t) readUInt8:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (uint8_t)(tag - '0');
        }
        [self checkTag:HproseTagInteger withTag:tag];
    }
    return [self readUI8:HproseTagSemicolon];
}

- (uint16_t) readUInt16 {
    return [self readUInt16:YES];
}

- (uint16_t) readUInt16:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (uint16_t)(tag - '0');
        }
        [self checkTag:HproseTagInteger withTag:tag];
    }
    return [self readUI16:HproseTagSemicolon];
}

- (uint32_t) readUInt32 {
    return [self readUInt32:YES];
}

- (uint32_t) readUInt32:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (uint32_t)(tag - '0');
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, 0};
        [self checkTags:expectTags withTag:tag];
    }
    return [self readUI32:HproseTagSemicolon];
}

- (uint64_t) readUInt64 {
    return [self readUInt64:YES];
}

- (uint64_t) readUInt64:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (uint64_t)(tag - '0');
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, 0};
        [self checkTags:expectTags withTag:tag];
    }
    return [self readUI64:HproseTagSemicolon];
}

- (NSString *) readBigInteger {
    return [self readBigInteger:YES];
}

- (NSString *) readBigInteger:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return [NSString stringWithFormat:@"%c", tag];
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, 0};
        [self checkTags:expectTags withTag:tag];
    }
    return [self readUntil:HproseTagSemicolon];
}

- (float) readFloat {
    return [self readFloat:YES];
}

- (float) readFloat:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (float)(tag - '0');
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, HproseTagDouble, 0};
        [self checkTags:expectTags withTag:tag];
    }
    return [[self readUntil:HproseTagSemicolon] floatValue];
}

- (double) readDouble {
    return [self readDouble:YES];
}

- (double) readDouble:(int)tag {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return (double)(tag - '0');
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, HproseTagDouble, 0};
        [self checkTags:expectTags withTag:tag];
    }
    return [[self readUntil:HproseTagSemicolon] doubleValue];
}

- (NSNumber *) readNumber {
    return [self readNumber:-1 withType:_C_ID];
}

- (NSNumber *) readNumber:(int)tag withType:(char)type {
    if (tag == -1) {
        tag = [stream readByte];
        if (tag >= '0' && tag <= '9') {
            return [NSNumber numberWithInt:(tag - '0') withType:type];
        }
        char expectTags[] = {HproseTagInteger, HproseTagLong, HproseTagDouble, 0};
        [self checkTags:expectTags withTag:tag];
    }
    switch (type) {
        case _C_ID:
            switch (tag) {
                case HproseTagInteger:
                    return [NSNumber numberWithInt:
                            [self readI32:HproseTagSemicolon]];
                    break;
                case HproseTagLong:
                    return [NSNumber numberWithLongLong:
                            [self readI64:HproseTagSemicolon]];
                    break;
                case HproseTagDouble:
                    return [NSNumber numberWithDouble:
                            [[self readUntil:HproseTagSemicolon] doubleValue]];
                    break;
            }
            break;
        case _C_CHR:
            return [NSNumber numberWithChar:
                    [self readI8:HproseTagSemicolon]];
            break;
        case _C_SHT:
            return [NSNumber numberWithShort:
                    [self readI16:HproseTagSemicolon]];
            break;
        case _C_INT:
            return [NSNumber numberWithInt:
                    [self readI32:HproseTagSemicolon]];
            break;
        case _C_LNG:
            return [NSNumber numberWithLong:
                    ((sizeof(long) == 4) ?
                    [self readI32:HproseTagSemicolon] :
                    [self readI64:HproseTagSemicolon])];
            break;
        case _C_LNG_LNG:
            return [NSNumber numberWithLongLong:
                    [self readI64:HproseTagSemicolon]];
            break;
        case _C_UCHR:
            return [NSNumber numberWithUnsignedChar:
                    [self readUI8:HproseTagSemicolon]];
            break;
        case _C_USHT:
            return [NSNumber numberWithUnsignedShort:
                    [self readUI16:HproseTagSemicolon]];
            break;
        case _C_UINT:
            return [NSNumber numberWithUnsignedInt:
                    [self readUI32:HproseTagSemicolon]];
            break;
        case _C_ULNG:
            return [NSNumber numberWithUnsignedLong:
                    ((sizeof(unsigned long) == 4) ?
                     [self readUI32:HproseTagSemicolon] :
                     [self readUI64:HproseTagSemicolon])];
            break;
        case _C_ULNG_LNG:
            return [NSNumber numberWithUnsignedLongLong:
                    [self readUI64:HproseTagSemicolon]];
            break;
        case _C_FLT:
            return [NSNumber numberWithFloat:
                    [[self readUntil:HproseTagSemicolon] floatValue]];
            break;
        case _C_DBL:
            return [NSNumber numberWithDouble:
                    [[self readUntil:HproseTagSemicolon] doubleValue]];
            break;
        case _C_BOOL:
            return [NSNumber numberWithBool:
                    ([self readUntil:HproseTagSemicolon] != @"0")];
            break;
    }
    @throw [HproseException exceptionWithReason:
            [NSString stringWithFormat:@"Not support this property: %c", type]];
}

- (double) readNaN {
    [self checkTag:HproseTagNaN];
    return NaN;
}

- (double) readInf {
    return [self readInf:-1];
}

- (double) readInf:(int)tag {
    if (tag == -1) [self checkTag:HproseTagInfinity];
    return (([stream readByte] == HproseTagNeg) ? NegInfinity : Infinity);
}

- (BOOL) readBoolean {
    char expectedTags[] = {HproseTagTrue, HproseTagFalse, 0};
    int tag = [self checkTags:expectedTags withTag:[stream readByte]];
    return (tag == HproseTagTrue);
}

- (id) readNull {
    [self checkTag:HproseTagNull];
    return nil;
}

- (id) readEmpty {
    [self checkTag:HproseTagEmpty];
    return @"";
}

- (id) readDate {
    return [self readDate:-1 withClass:Nil];
}

- (id) readDate:(int)tag {
    return [self readDate:tag withClass:Nil];    
}

- (id) readDate:(int)tag withClass:(Class)cls {
    if (tag == -1) {
        char expectedTags[] = {HproseTagDate, HproseTagTime, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
    }
    if (cls != Nil &&
        cls != [NSDate class] &&
        cls != [NSObject class]) {
        _throwCastException(@"Date", cls);
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSMutableString *dateString = [[NSMutableString alloc] initWithCapacity:18];
    NSMutableString *formatString = [[NSMutableString alloc] initWithCapacity:18];
    uint8_t buffer[9];
    if (tag == HproseTagDate) {
        [stream readBuffer:buffer maxLength:8];
        buffer[8] = 0;
        [dateString appendFormat:@"%s", buffer];
        [formatString appendString:@"yyyyMMdd"];
        tag = [stream readByte];
    }
    if (tag == HproseTagTime) {
        [stream readBuffer:buffer maxLength:6];
        buffer[6] = 0;
        [dateString appendFormat:@"%s", buffer];
        [formatString appendString:@"HHmmss"];
        tag = [stream readByte];
        if (tag == HproseTagPoint) {
            [stream readBuffer:buffer maxLength:3];
            buffer[3] = 0;
            [dateString appendFormat:@"%s", buffer];
            [formatString appendString:@"SSS"];
            tag = [stream readByte];
            if (tag >= '0' && tag <= '9') {
                [stream readBuffer:buffer maxLength:2];
                tag = [stream readByte];
                if (tag >= '0' && tag <= '9') {
                    [stream readBuffer:buffer maxLength:2];
                    tag = [stream readByte];
                }
            }
        }
    }
    if (tag == HproseTagUTC) {
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    else {
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    [dateFormatter setDateFormat:formatString];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [dateString release];
    [formatString release];
    [dateFormatter release];
    [ref addObject:date];
    return date;
}

- (id) readData {
    return [self readData:-1 withClass:Nil];
}

- (id) readData:(int)tag {
    return [self readData:tag withClass:Nil];
}

- (id) readData:(int)tag withClass:(Class)cls {
    if (tag == -1) {
        char expectedTags[] = {HproseTagBytes, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
    }
    NSUInteger len = [self readUI32:HproseTagQuote];
    uint8_t *buffer = malloc(len);
    [stream readBuffer:buffer maxLength:len];
    [self checkTag:HproseTagQuote];
    id data = nil;
    if (cls == Nil ||
        cls == [NSData class] ||
        cls == [NSObject class]) {
        data = [NSData dataWithBytesNoCopy:buffer
                                    length:len
                              freeWhenDone:YES];        
    }
    else if (cls == [NSMutableData class]) {
        data = [NSMutableData dataWithBytesNoCopy:buffer
                                           length:len
                                     freeWhenDone:YES];
    }
    else if (cls == [NSMutableString class]) {
        data = [[[NSMutableString alloc]
                 initWithBytesNoCopy:buffer
                              length:len
                            encoding:NSISOLatin1StringEncoding
                        freeWhenDone:YES] autorelease];
    }
    else if (cls == [NSString class]) {
        data = [[[NSString alloc]
                 initWithBytesNoCopy:buffer
                 length:len
                 encoding:NSISOLatin1StringEncoding
                 freeWhenDone:YES] autorelease];
    }
    else {
        _throwCastException(@"Bytes", cls);
    }
    [ref addObject:data];
    return data;
}

- (unichar) readUTF8Char {
    return [self readUTF8Char:-1];
}

- (unichar) readUTF8Char:(int)tag {
    if (tag == -1) [self checkTag:HproseTagUTF8Char];
    unichar u;
    int c = [stream readByte];
    switch (c >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7: {
            // 0xxx xxxx
            u = (unichar) c;
            break;
        }
        case 12:
        case 13: {
            // 110x xxxx   10xx xxxx
            int c2 = [stream readByte];
            u = (unichar) (((c & 0x1f) << 6) |
                           (c2 & 0x3f));
            break;
        }
        case 14: {
            // 1110 xxxx  10xx xxxx  10xx xxxx
            int c2 = [stream readByte];
            int c3 = [stream readByte];
            u = (unichar) (((c & 0x0f) << 12) |
                           ((c2 & 0x3f) << 6) |
                            (c3 & 0x3f));
            break;
        }
        default:
            @throw [HproseException exceptionWithReason:@"Bad utf-8 encoding"];
    }
    return u;    
}

- (id) readString {
    return [self readString:-1 withClass:Nil withType:'@' includeRef:YES];
}

- (id) readString:(int)tag {
    return [self readString:tag withClass:Nil withType:'@' includeRef:YES];
}

- (id) readString:(int)tag withClass:(Class)cls {
    return [self readString:tag withClass:cls withType:'@' includeRef:YES];
}

- (id) readString:(int)tag withClass:(Class)cls withType:(char)type {
    return [self readString:tag withClass:cls withType:type includeRef:YES];    
}

- (id) readGuid {
    return [self readGuid:-1];
}

- (id) readGuid:(int)tag {
    if (tag == -1) {
        char expectedTags[] = {HproseTagGuid, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
    }
    [self checkTag:HproseTagOpenbrace];
    uint8_t *buffer = malloc(36);
    [stream readBuffer:buffer maxLength:36];
    NSMutableString *guid = [[[NSMutableString alloc]
                             initWithBytesNoCopy:buffer
                             length:36
                             encoding:NSISOLatin1StringEncoding
                             freeWhenDone:YES] autorelease];
    [self checkTag:HproseTagClosebrace];
    [ref addObject:guid];
    return guid;
}

- (id) readArray {
    return [self readArray:-1 withClass:Nil];
}

- (id) readArray:(int)tag {
    return [self readArray:tag withClass:Nil];
}

- (id) readArray:(int)tag withClass:(Class)cls {
    if (tag == -1) {
        char expectedTags[] = {HproseTagList, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
    }
    if (cls != Nil &&
        cls != [NSArray class] &&
        cls != [NSMutableArray class] &&
        cls != [NSObject class]) {
        _throwCastException(@"Array", cls);
    }
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    [ref addObject:array];
    for (NSUInteger i = 0; i < count; ++i) {
        [array addObject:[self unserialize:[NSObject class]]];
    }
    [self checkTag:HproseTagClosebrace];
    return array;
}

- (id) readDict {
    return [self readDict:-1 withClass:Nil];
}

- (id) readDict:(int)tag {
    return [self readDict:tag withClass:Nil];
}

- (id) readDict:(int)tag withClass:(Class)cls {
    if (tag == -1) {
        char expectedTags[] = {HproseTagMap, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
    }
    NSUInteger count = [self readUI32:HproseTagOpenbrace];
    if (cls != Nil &&
        cls != [NSDictionary class] &&
        cls != [NSMutableDictionary class] &&
        cls != [NSObject class]) {
        return [self readObject:cls withCount:count];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
    [ref addObject:dict];
    for (NSUInteger i = 0; i < count; ++i) {
        id key = [self unserialize:[NSObject class]];
        id value = [self unserialize:[NSObject class]];
        [dict setObject:value forKey:key];
    }
    [self checkTag:HproseTagClosebrace];
    return dict;
}

- (id) readObject {
    return [self readObject:-1 withClass:Nil];
}

- (id) readObject:(int)tag {
    return [self readObject:tag withClass:Nil];
}

- (id) readObject:(int)tag withClass:(Class)cls {
    if (tag == -1) {
        char expectedTags[] = {HproseTagObject, HproseTagClass, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
        if (tag == HproseTagClass) {
            [self readClass];
            return [self readObject:-1 withClass:cls];
        }
    }
    Class cls2 = [classref objectAtIndex:[self readUI32:HproseTagOpenbrace]];
    if (cls == Nil || cls == [NSObject class] || [cls2 isSubclassOfClass:cls]) {
        cls = cls2;
    }
    else {
        _throwCastException([NSString stringWithUTF8String:class_getName(cls2)], cls);
    }
    id obj = [[cls new] autorelease];
    [ref addObject:obj];
    NSArray *propNames = [attrsref objectForKey:cls];
    NSDictionary *properties = [HproseHelper getHproseProperties:cls];
    for (id name in propNames) {
        [self readProperty:[properties objectForKey:name] forObject:obj];
    }
    [self checkTag:HproseTagClosebrace];
    return obj;
}

- (NSData *) readRaw {
    NSOutputStream *ostream = [[NSOutputStream alloc] initToMemory];
    [ostream open];
    NSData *data = nil;
    @try {
        [self readRaw:ostream];
        data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    }
    @finally {
        [ostream close];
        [ostream release];
    }
    return data;
}

- (void) readRaw:(NSOutputStream *)ostream {
    [self readRaw:ostream withTag:[stream readByte]];
}

- (void) reset {
    [ref removeAllObjects];
    [classref removeAllObjects];
    [attrsref removeAllObjects];
}
@end


@implementation HproseReader(PrivateMethods)

- (id) readString:(int)tag withClass:(Class)cls withType:(char)type includeRef:(BOOL)b {
    if (tag == -1) {
        char expectedTags[] = {HproseTagString, HproseTagRef, 0};
        tag = [self checkTags:expectedTags];
        if (tag == HproseTagRef) return [self readRef];
    }
    NSUInteger len = [self readUI32:HproseTagQuote];
    id data = nil;
    if (cls == [NSData class] || cls == [NSMutableData class]) {
        data = [NSMutableData dataWithCapacity:len * 3];
        uint8_t bytes[4];
        NSUInteger i;
        for (i = 0; i < len; ++i) {
            int l = [stream read:&bytes[0] maxLength:1];
            switch (bytes[0] >> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    [data appendBytes:(void *)bytes length:1];
                    break;
                case 12:
                case 13:
                    [stream readBuffer:&bytes[1] maxLength:1];
                    [data appendBytes:(void *)bytes length:2];
                    break;
                case 14:
                    [stream readBuffer:&bytes[1] maxLength:2];
                    [data appendBytes:(void *)bytes length:3];
                    break;
                case 15:
                    if ((bytes[0] & 0xf) <= 4) {
                        [stream readBuffer:&bytes[1] maxLength:3];
                        [data appendBytes:(void *)bytes length:4];
                        ++i;
                        break;
                    }
                    // no break here!! here need throw exception.
                default:
                    @throw [HproseException exceptionWithReason:
                            [NSString stringWithString:
                             (l <= 0 ? @"end of stream" : @"bad utf-8 encoding")]];
                    break;
            }
        }
        [self checkTag:HproseTagQuote];        
    }
    else {
        unichar *buffer = malloc(len * sizeof(unichar));
        int c, c2, c3, c4;
        for (NSUInteger i = 0; i < len; ++i) {
            c = [stream readByte];
            switch (c >> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    buffer[i] = (unichar)c;
                    break;
                case 12:
                case 13:
                    c2 = [stream readByte];
                    buffer[i] = (unichar)(((c & 0x1f) << 6) |
                                          (c2 & 0x3f));
                    break;
                case 14:
                    c2 = [stream readByte];
                    c3 = [stream readByte];
                    buffer[i] = (unichar)(((c & 0x0f) << 12) |
                                          ((c2 & 0x3f) << 6) |
                                          (c3 & 0x3f));
                    break;
                case 15:
                    if ((c & 0xf) <= 4) {
                        c2 = [stream readByte];
                        c3 = [stream readByte];
                        c4 = [stream readByte];
                        int s = (((c & 0x07) << 18) |
                                 ((c2 & 0x3f) << 12) |
                                 ((c3 & 0x3f) << 6)  |
                                 (c4 & 0x3f)) - 0x10000;
                        if (0 <= s && s <= 0xfffff) {
                            buffer[i++] = (unichar)(((s >> 10) & 0x03ff) | 0xd800);
                            buffer[i] = (unichar)((s & 0x03ff) | 0xdc00);
                            break;
                        }
                    }
                    // no break here!! here need throw exception.
                default:
                    @throw [HproseException exceptionWithReason:
                            [NSString stringWithString:
                             ((c < 0) ? @"end of stream" : @"bad utf-8 encoding")]];
                    break;
            }
        }
        [self checkTag:HproseTagQuote];
        if (cls == Nil ||
            cls == [NSNumber class] ||
            cls == [NSValue class] ||
            cls == [NSString class] ||
            cls == [NSObject class]) {
            data = [[[NSString alloc]
                     initWithCharactersNoCopy:buffer
                     length:len
                     freeWhenDone:YES] autorelease];
            if (((cls == Nil || cls == [NSObject class])
                 && type != _C_ID && type != _C_CHARPTR) ||
                cls == [NSNumber class] ||
                cls == [NSValue class]) {
                data = [NSNumber numberWithString:data withType:type];
            }
        }
        else if (cls == [NSMutableString class]) {
            data = [[[NSMutableString alloc]
                     initWithCharactersNoCopy:buffer
                     length:len
                     freeWhenDone:YES] autorelease];
        }
        else {
            _throwCastException(@"String", cls);
        }        
    }
    if (b) {
        [ref addObject:data];
    }
    return data;
}

- (id) readObject:(Class)cls withCount:(int)count {
    id obj = [[[cls alloc] init] autorelease];
    [ref addObject:obj];
    NSDictionary *properties = [HproseHelper getHproseProperties:cls];    
    for (NSUInteger i = 0; i < count; ++i) {
        id name = [self unserialize:[NSString class]];
        [self readProperty:[properties objectForKey:name] forObject:obj];
    }
    [self checkTag:HproseTagClosebrace];
    return obj;
}

- (void) readProperty:(HproseProperty *)property forObject:(id)o {
    IMP setterImp = [property setterImp];
    SEL setter = [property setter];
    id value = [self unserialize:[property cls] withType:[property type]];
    switch ([property type]) {
        case _C_ID:
            ((void (*)(id, SEL, id))setterImp)(o, setter, value);
            break;
        case _C_CHR:
            ((void (*)(id, SEL, char))setterImp)(o, setter, [value charValue]);
            break;
        case _C_SHT:
            ((void (*)(id, SEL, short))setterImp)(o, setter, [value shortValue]);
            break;
        case _C_INT:
            ((void (*)(id, SEL, int))setterImp)(o, setter, [value intValue]);
            break;
        case _C_LNG:
            ((void (*)(id, SEL, long))setterImp)(o, setter, [value longValue]);
            break;
        case _C_LNG_LNG:
            ((void (*)(id, SEL, long long))setterImp)(o, setter, [value longLongValue]);
            break;
        case _C_UCHR:
            ((void (*)(id, SEL, unsigned char))setterImp)(o, setter, [value unsignedCharValue]);
            break;
        case _C_USHT:
            ((void (*)(id, SEL, unsigned short))setterImp)(o, setter, [value unsignedShortValue]);
            break;
        case _C_UINT:
            ((void (*)(id, SEL, unsigned int))setterImp)(o, setter, [value unsignedIntValue]);
            break;
        case _C_ULNG:
            ((void (*)(id, SEL, unsigned long))setterImp)(o, setter, [value unsignedLongValue]);
            break;
        case _C_ULNG_LNG:
            ((void (*)(id, SEL, unsigned long long))setterImp)(o, setter, [value unsignedLongLongValue]);
            break;
        case _C_FLT:
            ((void (*)(id, SEL, float))setterImp)(o, setter, [value floatValue]);
            break;
        case _C_DBL:
            ((void (*)(id, SEL, double))setterImp)(o, setter, [value doubleValue]);
            break;
        case _C_BOOL:
            ((void (*)(id, SEL, bool))setterImp)(o, setter, [value boolValue]);
            break;
        case _C_CHARPTR:
            ((void (*)(id, SEL, const char *))setterImp)(o, setter, [value UTF8String]);
            break;
        default:
            @throw [HproseException exceptionWithReason:
                    [NSString stringWithFormat:
                     @"Not support this property: %@", [property name]]];
            break;
    }
}

- (void) readClass {
    NSString *className = [self readString:0 withClass:Nil withType:'@' includeRef:NO];
    Class cls = [HproseHelper getClass:className];
    int count = [self readI32:HproseTagOpenbrace];
    NSMutableArray *propNames = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [propNames addObject:[self readString]];
    }
    [self checkTag:HproseTagClosebrace];
    if (cls == Nil) {
        cls = [HproseHelper createClass:className withPropNames:propNames];
    }
    [attrsref setObject:propNames forKey:cls];
    [classref addObject:cls];
}

- (id) readRef {
    return [ref objectAtIndex:[self readUI32:HproseTagSemicolon]];
}

- (void) readRaw:(NSOutputStream *)ostream withTag:(int)tag {
    switch (tag) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case HproseTagNull:
        case HproseTagEmpty:
        case HproseTagTrue:
        case HproseTagFalse:
        case HproseTagNaN:
            [ostream writeByte:tag];
            break;
        case HproseTagInfinity:
            [ostream writeByte:tag];
            [ostream writeByte:[stream readByte]];
            break;
        case HproseTagInteger:
        case HproseTagLong:
        case HproseTagDouble:
        case HproseTagRef:
            [self readNumberRaw:ostream withTag:tag];
            break;
        case HproseTagDate:
        case HproseTagTime:
            [self readDateTimeRaw:ostream withTag:tag];
            break;
        case HproseTagUTF8Char:
            [self readUTF8CharRaw:ostream withTag:tag];
            break;
        case HproseTagBytes:
            [self readBytesRaw:ostream withTag:tag];
            break;
        case HproseTagString:
            [self readStringRaw:ostream withTag:tag];
            break;
        case HproseTagGuid:
            [self readGuidRaw:ostream withTag:tag];
            break;
        case HproseTagList:
        case HproseTagMap:
        case HproseTagObject:
            [self readComplexRaw:ostream withTag:tag];
            break;
        case HproseTagClass:
            [self readComplexRaw:ostream withTag:tag];
            [self readRaw:ostream];
            break;
        case HproseTagError:
            [ostream writeByte:tag];
            [self readRaw:ostream];
            break;
        case -1:
            @throw [HproseException exceptionWithReason:@"No byte found in stream"];
            break;
        default:
            @throw [HproseException exceptionWithReason:@"Unexpected serialize tag in stream"];            
    }
}
- (void) readNumberRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    do {
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagSemicolon);
}
- (void) readDateTimeRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    do {
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagSemicolon &&
             tag != HproseTagUTC);
}
- (void) readUTF8CharRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    tag = [stream readByte];
    switch (tag >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7: {
            // 0xxx xxxx
            [ostream writeByte:tag];
            break;
        }
        case 12:
        case 13: {
            // 110x xxxx   10xx xxxx
            [ostream writeByte:tag];
            [ostream writeByte:[stream readByte]];
            break;
        }
        case 14: {
            // 1110 xxxx  10xx xxxx  10xx xxxx
            [ostream writeByte:tag];
            [ostream writeByte:[stream readByte]];
            [ostream writeByte:[stream readByte]];
            break;
        }
        default:
            @throw [HproseException exceptionWithReason:@"Bad utf-8 encoding"];
    }
}
- (void) readBytesRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    NSUInteger len = 0;
    tag = '0';
    do {
        len *= 10;
        len += tag - '0';
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagQuote);
    [ostream copyFrom:stream maxLength:len + 1];
}
- (void) readStringRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    NSUInteger count = 0;
    tag = '0';
    do {
        count *= 10;
        count += tag - '0';
        [ostream writeByte:tag];
    } while (tag != HproseTagQuote);
    for (int i = 0; i < count; i++) {
        tag = [stream readByte];
        switch (tag >> 4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7: {
                // 0xxx xxxx
                [ostream writeByte:tag];
                break;
            }
            case 12:
            case 13: {
                // 110x xxxx   10xx xxxx
                [ostream writeByte:tag];
                [ostream writeByte:[stream readByte]];
                break;
            }
            case 14: {
                // 1110 xxxx  10xx xxxx  10xx xxxx
                [ostream writeByte:tag];
                [ostream writeByte:[stream readByte]];
                [ostream writeByte:[stream readByte]];
                break;
            }
            case 15: {
                // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                if ((tag & 0xf) <= 4) {
                    [ostream writeByte:tag];
                    [ostream writeByte:[stream readByte]];
                    [ostream writeByte:[stream readByte]];
                    [ostream writeByte:[stream readByte]];
                    break;
                }
                // no break here!! here need throw exception.
            }
            default:
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithString:
                         ((tag < 0) ? @"end of stream" : @"bad utf-8 encoding")]];
                break;
        }
    }
    [ostream writeByte:[stream readByte]];
}
- (void) readGuidRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    [ostream copyFrom:stream maxLength:38];
}
- (void) readComplexRaw:(NSOutputStream *)ostream withTag:(int)tag {
    [ostream writeByte:tag];
    do {
        tag = [stream readByte];
        [ostream writeByte:tag];
    } while (tag != HproseTagOpenbrace);
    while ((tag = [stream readByte]) != HproseTagClosebrace) {
        [self readRaw:ostream withTag:tag];
    }
    [ostream writeByte:tag];
}
@end