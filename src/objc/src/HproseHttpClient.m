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
 * HproseHttpClient.m                                     *
 *                                                        *
 * hprose http client for Objective-C.                    *
 *                                                        *
 * LastModified: Dec 3, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import "HproseException.h"
#import "HproseHttpClient.h"
#import "HproseConnection.h"
#import "HproseAsyncInvoke.h"

@interface AsyncInvokeContext: NSObject {
    NSMutableData *buffer;
    id <HproseAsyncInvoke, NSObject> asyncInvoke;
    NSOutputStream *ostream;
    NSInputStream *istream;
}

@property (readonly) NSMutableData *buffer;
@property (retain) id <HproseAsyncInvoke, NSObject> asyncInvoke;
@property (retain) NSOutputStream *ostream;
@property (retain) NSInputStream *istream;

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection;
@end

@implementation AsyncInvokeContext

@synthesize buffer;
@synthesize asyncInvoke;
@synthesize ostream;
@synthesize istream;

- (id) init {
    if ((self = [super init])) {
        buffer = [[NSMutableData alloc] initWithLength:0];
    }
    return (self);
}

- (void) dealloc {
    [asyncInvoke release];
    [ostream release];
    [istream release];
    [super dealloc];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode] != 200) {
        [asyncInvoke errorCallback:[HproseException exceptionWithReason:
                                    [NSString stringWithFormat:@"Http error %d: %@",
                                     (int)[httpResponse statusCode],
                                     [NSHTTPURLResponse localizedStringForStatusCode:
                                      [httpResponse statusCode]]]]];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
#pragma unused(theConnection)
    [buffer appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
#pragma unused(theConnection)
    [asyncInvoke errorCallback:[HproseException exceptionWithReason:[error localizedDescription]]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
#pragma unused(theConnection)
    [asyncInvoke successCallback];
}

@end

@interface SyncInvokeContext: NSObject {
    NSOutputStream *ostream;
    NSInputStream *istream;
}

@property (retain) NSOutputStream *ostream;
@property (retain) NSInputStream *istream;

@end

@implementation SyncInvokeContext

@synthesize ostream;
@synthesize istream;

- (void) dealloc {
    [ostream release];
    [istream release];
    [super dealloc];
}
@end

@interface HproseHttpClient(HproseConnection)<HproseConnection>
@end

@implementation HproseHttpClient(HproseConnection)

- (id) getInvokeContext:(id)invoke {
    SyncInvokeContext *context = [[[SyncInvokeContext alloc] init] autorelease];
    return context;
}

- (NSOutputStream *) getOutputStream:(id)context {
    NSOutputStream *ostream = [[[NSOutputStream alloc] initToMemory] autorelease];
    [context setOstream: ostream];
    [ostream open];
    return ostream;
}

- (void) sendData:(id)context isSuccess:(BOOL)success {
    NSOutputStream *ostream = [context ostream];
    @try {
        if (success) {
            NSData *data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            if (filter != nil) {
                data = [filter outputFilter:data];
            }
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setTimeoutInterval:timeout];
            for (id field in header) {
                [request setValue:[header objectForKey:field] forHTTPHeaderField:field];
            }
            if (keepAlive) {
                [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
                [request setValue:[[NSNumber numberWithInt:keepAliveTimeout] stringValue] forHTTPHeaderField:@"Keep-Alive"];
            }
            else {
                [request setValue:@"close" forHTTPHeaderField:@"Connection"];
            }
            [request setHTTPShouldHandleCookies:YES];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:data];
            NSHTTPURLResponse *response;
            NSError *error;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSInteger statusCode = [response statusCode];
            if (statusCode != 200 && statusCode != 0) {
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithFormat:@"Http error %d: %@",
                         (int)statusCode,
                         [NSHTTPURLResponse localizedStringForStatusCode:statusCode]]];                
            }
            if (data == nil) {
                @throw [HproseException exceptionWithReason:[error localizedDescription]];
            }
            if (filter != nil) {
                data = [filter inputFilter: data];
            }
            NSInputStream *istream = [[[NSInputStream alloc] initWithData:data] autorelease];
            [context setIstream: istream];
        }
    }
    @finally {
        [ostream close];
    }
}

- (NSInputStream *) getInputStream:(id)context {
    NSInputStream *istream = [context istream];
    [istream open];
    return istream;
}

- (void) endInvoke:(id)context isSuccess:(BOOL)success {
    NSInputStream *istream = [context istream];
    [istream close];
}

- (id) getInvokeContextAsync:(id)invoke {
    AsyncInvokeContext *context = [[[AsyncInvokeContext alloc] init] autorelease];
    [context setAsyncInvoke: invoke];
    return context;
}

- (NSOutputStream *) getOutputStreamAsync:(id)context {
    NSOutputStream *ostream = [[[NSOutputStream alloc] initToMemory] autorelease];
    [context setOstream: ostream];
    [ostream open];
    return ostream;
}

- (void) sendDataAsync:(id)context isSuccess:(BOOL)success {
    NSOutputStream *ostream = [context ostream];
    @try { 
        if (success) {
            NSData *data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            if (filter != nil) {
                data = [filter outputFilter:data];
            }
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setTimeoutInterval:timeout];
            for (id field in header) {
                [request setValue:[header objectForKey:field] forHTTPHeaderField:field];
            }
            if (keepAlive) {
                [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
                [request setValue:[[NSNumber numberWithInt:keepAliveTimeout] stringValue] forHTTPHeaderField:@"Keep-Alive"];
            }
            else {
                [request setValue:@"close" forHTTPHeaderField:@"Connection"];
            }            
            [request setHTTPShouldHandleCookies:YES];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:data];
            [NSURLConnection connectionWithRequest:request delegate:context];
        }
    }
    @catch (NSException *e) {
        [[context asyncInvoke] errorCallback:e];
    }
    @finally {
        [ostream close];
    }
}

- (NSInputStream *) getInputStreamAsync:(id)context {
    NSData *data = [context buffer];
    if (filter != nil) {
        data = [filter inputFilter: data];
    }
    NSInputStream *istream = [[[NSInputStream alloc] initWithData:data] autorelease];
    [context setIstream: istream];
    [istream open];
    return istream;
}

- (void) endInvokeAsync:(id)context isSuccess:(BOOL)success {
    @try { 
        NSInputStream *istream = [context istream];
        [istream close];
    }
    @catch (NSException *e) {
        [[context asyncInvoke] errorCallback:e];
    }
}

@end

@implementation HproseHttpClient

@synthesize timeout;
@synthesize keepAlive;
@synthesize keepAliveTimeout;
@synthesize header;
@dynamic uri;

- (void) setUri:(NSString *)aUri {
    if (aUri != uri) {
        [uri release];
        uri = [aUri retain];
        url = [[NSURL URLWithString:uri] retain];
    }
}

- (id) init {
    if ((self = [super init])) {
        [self setTimeout:30.0];
        [self setKeepAlive:NO];
        [self setKeepAliveTimeout:300];
        header = [[NSMutableDictionary alloc] init];
    }
    return (self);
}

- (void) dealloc {
    [header release];
    [url release];
    [super dealloc];
}

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (field != nil) {
         if (value != nil) {
            [header setObject:value forKey:field];
         }
        else {
            [header removeObjectForKey:field];
        }
    }
}

@end