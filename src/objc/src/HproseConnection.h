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
 * HproseConnection.h                                     *
 *                                                        *
 * hprose connection protocol for Objective-C.            *
 *                                                        *
 * LastModified: Dec 3, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@protocol HproseConnection

@optional

- (id) getInvokeContext:(id)invoke;
- (NSOutputStream *) getOutputStream:(id)context;
- (void) sendData:(id)context isSuccess:(BOOL)success;
- (NSInputStream *) getInputStream:(id)context;
- (void) endInvoke:(id)context isSuccess:(BOOL)success;

- (id) getInvokeContextAsync:(id)invoke;
- (NSOutputStream *) getOutputStreamAsync:(id)context;
- (void) sendDataAsync:(id)context isSuccess:(BOOL)success;
- (NSInputStream *) getInputStreamAsync:(id)context;
- (void) endInvokeAsync:(id)context isSuccess:(BOOL)success;

- (void) doOutput:(NSOutputStream *)ostream withName:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc;
- (id) doInput:(NSInputStream *)istream withArgs:(NSMutableArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode;

@end