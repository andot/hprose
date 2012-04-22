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
 * HproseReader.h                                         *
 *                                                        *
 * hprose reader class header for Objective-C.            *
 *                                                        *
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseReader : NSObject {
    NSInputStream *stream;
    NSMutableArray *classref;
    NSMutableArray *ref;
    NSMutableDictionary *attrsref;
}

@property (retain) NSInputStream *stream;

+ (id) readerWithStream:(NSInputStream *)dataStream;

- (id) initWithStream:(NSInputStream *)dataStream;

- (id) unserialize;
- (id) unserialize:(Class)cls;
- (id) unserialize:(Class)cls withType:(char)type;
- (id) unserialize:(Class)cls withType:(char)type withTag:(int)tag;

- (void) checkTag:(int)expectTag;
- (void) checkTag:(int)expectTag withTag:(int)tag;
- (int) checkTags:(char[])expectTags;
- (int) checkTags:(char[])expectTags withTag:(int)tag;
- (NSString *) readUntil:(int)tag;
- (int8_t) readI8:(int)tag;
- (int16_t) readI16:(int)tag;
- (int32_t) readI32:(int)tag;
- (int64_t) readI64:(int)tag;
- (uint8_t) readUI8:(int)tag;
- (uint16_t) readUI16:(int)tag;
- (uint32_t) readUI32:(int)tag;
- (uint64_t) readUI64:(int)tag;
- (int8_t) readInt8;
- (int8_t) readInt8:(int)tag;
- (int16_t) readInt16;
- (int16_t) readInt16:(int)tag;
- (int32_t) readInt32;
- (int32_t) readInt32:(int)tag;
- (int64_t) readInt64;
- (int64_t) readInt64:(int)tag;
- (uint8_t) readUInt8;
- (uint8_t) readUInt8:(int)tag;
- (uint16_t) readUInt16;
- (uint16_t) readUInt16:(int)tag;
- (uint32_t) readUInt32;
- (uint32_t) readUInt32:(int)tag;
- (uint64_t) readUInt64;
- (uint64_t) readUInt64:(int)tag;
- (NSString *) readBigInteger;
- (NSString *) readBigInteger:(int)tag;
- (float) readFloat;
- (float) readFloat:(int)tag;
- (double) readDouble;
- (double) readDouble:(int)tag;
- (NSNumber *) readNumber;
- (NSNumber *) readNumber:(int)tag withType:(char)type;
- (double) readNaN;
- (double) readInf;
- (double) readInf:(int)tag;
- (BOOL) readBoolean;
- (id) readNull;
- (id) readEmpty;
- (id) readDate;
- (id) readDate:(int)tag;
- (id) readDate:(int)tag withClass:(Class)cls;
- (id) readData;
- (id) readData:(int)tag;
- (id) readData:(int)tag withClass:(Class)cls;
- (unichar) readUTF8Char;
- (unichar) readUTF8Char:(int)tag;
- (id) readString;
- (id) readString:(int)tag;
- (id) readString:(int)tag withClass:(Class)cls;
- (id) readString:(int)tag withClass:(Class)cls withType:(char)type;
- (id) readGuid;
- (id) readGuid:(int)tag;
- (id) readArray;
- (id) readArray:(int)tag;
- (id) readArray:(int)tag withClass:(Class)cls;
- (id) readDict;
- (id) readDict:(int)tag;
- (id) readDict:(int)tag withClass:(Class)cls;
- (id) readObject;
- (id) readObject:(int)tag;
- (id) readObject:(int)tag withClass:(Class)cls;
- (NSData *) readRaw;
- (void) readRaw:(NSOutputStream *)ostream;
- (void) reset;
@end
