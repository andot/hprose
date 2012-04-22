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
 * HproseWriter.h                                         *
 *                                                        *
 * hprose writer class header for Objective-C.            *
 *                                                        *
 * LastModified: Jul 1, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseWriter : NSObject {
    NSOutputStream *stream;
    NSMutableArray *classref;
    NSMutableArray *ref;
    uint8_t buf[20];
    BOOL utc;
}

@property (retain) NSOutputStream *stream;
@property BOOL utc;

+ (id) writerWithStream:(NSOutputStream *)dataStream;

- (id) initWithStream:(NSOutputStream *)dataStream;

- (void) serialize:(id)obj;
- (void) writeInt8:(int8_t)i;
- (void) writeInt16:(int16_t)i;
- (void) writeInt32:(int32_t)i;
- (void) writeInt64:(int64_t)i;
- (void) writeUInt8:(uint8_t)i;
- (void) writeUInt16:(uint16_t)i;
- (void) writeUInt32:(uint32_t)i;
- (void) writeUInt64:(uint64_t)i;
- (void) writeBigInteger:(NSString *)bi;
- (void) writeFloat:(float)f;
- (void) writeDouble:(double)d;
- (void) writeNumber:(NSNumber *)n;
- (void) writeNull;
- (void) writeNaN;
- (void) writeInf;
- (void) writeNInf;
- (void) writeEmpty;
- (void) writeBoolean:(BOOL)b;
- (void) writeDate:(NSDate *)date;
- (void) writeDate:(NSDate *)date checkRef:(BOOL)b;
- (void) writeUTCDate:(NSDate *)date;
- (void) writeUTCDate:(NSDate *)date checkRef:(BOOL)b;
- (void) writeBytes:(const uint8_t *)bytes length:(int)l;
- (void) writeBytes:(const uint8_t *)bytes length:(int)l checkRef:(BOOL)b;
- (void) writeData:(NSData *)data;
- (void) writeData:(NSData *)data checkRef:(BOOL)b;
- (void) writeUTF8Char:(unichar)c;
- (void) writeString:(NSString *)s;
- (void) writeString:(NSString *)s checkRef:(BOOL)b;
- (void) writeArray:(NSArray *)a;
- (void) writeArray:(NSArray *)a checkRef:(BOOL)b;
- (void) writeDict:(NSDictionary *)m;
- (void) writeDict:(NSDictionary *)m checkRef:(BOOL)b;
- (void) writeObject:(id)o;
- (void) writeObject:(id)o checkRef:(BOOL)b;
- (void) reset;
@end
