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
 * HproseFilter.java                                      *
 *                                                        *
 * hprose filter interface for Java.                      *
 *                                                        *
 * LastModified: Nov 27, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.io.InputStream;
import java.io.OutputStream;

public interface HproseFilter {
    InputStream inputFilter(InputStream istream);
    OutputStream outputFilter(OutputStream ostream);
}