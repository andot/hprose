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
 * HproseFilter.h                                         *
 *                                                        *
 * hprose filter protocol for Objective-C.                *
 *                                                        *
 * LastModified: Dec 3, 2012                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@protocol HproseFilter

- (NSData *) inputFilter:(NSData *) data;
- (NSData *) outputFilter:(NSData *) data;

@end
