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
 * LastModified: Jun 20, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import "HproseException.h"
#import "HproseHttpClient.h"
#import "HproseConnection.h"
#import "HproseAsyncInvoke.h"

@interface AsyncInvokeDelegate : NSObject {
    NSMutableData *buffer;
    id <HproseAsyncInvoke, NSObject> asyncInvoke;
}

@property (retain) id <HproseAsyncInvoke, NSObject> asyncInvoke;
@property (readonly) NSMutableData *buffer;

- (id) init:(id <HproseAsyncInvoke, NSObject>)invoke;
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection;

@end

@implementation AsyncInvokeDelegate

@synthesize asyncInvoke;
@synthesize buffer;

- (id) init {
    if ((self = [super init])) {
        buffer = [[NSMutableData alloc] initWithLength:0];
    }
    return (self);
}

- (id) init:(id <HproseAsyncInvoke, NSObject>)invoke {
    if ((self = [self init])) {
        [self setAsyncInvoke:invoke];
    }
    return (self);
}

- (void) dealloc {
    [buffer release];
    [asyncInvoke release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;    
    if ([httpResponse statusCode] != 200) {
        [asyncInvoke errorCallback:[HproseException exceptionWithReason:
                                    [NSString stringWithFormat:@"Http error %d: %@",
                                     [httpResponse statusCode],
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

@interface HproseHttpClient(HproseConnection)<HproseConnection>
@end

@implementation HproseHttpClient(HproseConnection)

- (NSOutputStream *) getOutputStream:(id)context {
    NSOutputStream *ostream = [[NSOutputStream alloc] initToMemory];
    [ostream open];
    return ostream;
}

- (id) sendData:(NSOutputStream *)ostream withContext:(id)context isSuccess:(BOOL)success {
    @try { 
        if (success) {
            NSData *data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
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
            context = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSInteger statusCode = [response statusCode];
            if (statusCode != 200 && statusCode != 0) {
                @throw [HproseException exceptionWithReason:
                        [NSString stringWithFormat:@"Http error %d: %@",
                         statusCode,
                         [NSHTTPURLResponse localizedStringForStatusCode:statusCode]]];                
            }
            if (context == nil) {
                @throw [HproseException exceptionWithReason:[error localizedDescription]];
            }
            return context;
        }
    }
    @finally {
        [ostream close];
        [ostream release];
    }
    return nil;
}

- (NSInputStream *) getInputStream:(id)context {
    NSInputStream *istream = [[NSInputStream alloc] initWithData:context];
    [istream open];
    return istream;
}

- (void) endInvoke:(NSInputStream *)istream withContext:(id)context isSuccess:(BOOL)success {
    @try { 
        [istream close];
        [istream release];
    }
    @catch (NSException *e) {
    }
}

- (NSOutputStream *) getOutputStreamAsync:(id)context {
    NSOutputStream *ostream = [[NSOutputStream alloc] initToMemory];
    [ostream open];
    return ostream;
}

- (id) sendDataAsync:(NSOutputStream *)ostream withContext:(id)context isSuccess:(BOOL)success {
    id delegate = nil;
    @try { 
        if (success) {
            NSData *data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
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
            delegate = [[[AsyncInvokeDelegate alloc] init:context] autorelease];
            [NSURLConnection connectionWithRequest:request delegate:delegate];
        }
    }
    @catch (NSException *e) {
        [context errorCallback:e];
    }
    @finally {
        [ostream close];
        [ostream release];
    }
    return delegate;
}

- (NSInputStream *) getInputStreamAsync:(id)context {
    NSInputStream *istream = [[NSInputStream alloc] initWithData:[context buffer]];
    [istream open];
    return istream;
}

- (void) endInvokeAsync:(NSInputStream *)istream withContext:(id)context isSuccess:(BOOL)success {
    @try { 
        [istream close];
        [istream release];
    }
    @catch (NSException *e) {
        [context errorCallback:e];
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