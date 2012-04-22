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
 * LastModified: Jul 2, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@protocol HproseConnection

@optional

- (NSOutputStream *) getOutputStream:(id)context;
- (id) sendData:(NSOutputStream *)ostream withContext:(id)context isSuccess:(BOOL)success;
- (NSInputStream *) getInputStream:(id)context;
- (void) endInvoke:(NSInputStream *)istream withContext:(id)context isSuccess:(BOOL)success;

- (NSOutputStream *) getOutputStreamAsync:(id)context;
- (id) sendDataAsync:(NSOutputStream *)ostream withContext:(id)context isSuccess:(BOOL)success;
- (NSInputStream *) getInputStreamAsync:(id)context;
- (void) endInvokeAsync:(NSInputStream *)istream withContext:(id)context isSuccess:(BOOL)success;

- (void) doOutput:(NSOutputStream *)ostream withName:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef UTC:(BOOL)utc;
- (id) doInput:(NSInputStream *)istream withArgs:(NSMutableArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode;

@end