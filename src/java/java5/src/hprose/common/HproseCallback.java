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
 * HproseCallback.java                                    *
 *                                                        *
 * hprose callback class for Java.                        *
 *                                                        *
 * LastModified: May 7, 2011                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

public interface HproseCallback<T> {
    void handler(T result, Object[] arguments);
}
