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
 * HproseProperty.m                                       *
 *                                                        *
 * hprose property class for Objective-C.                 *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

#import "HproseProperty.h"

@implementation HproseProperty

@synthesize name;
@synthesize type;
@synthesize cls;
@synthesize getter;
@synthesize getterImp;
@synthesize setter;
@synthesize setterImp;

- (void) dealloc {
    [name release];
    [super dealloc];
}

@end
