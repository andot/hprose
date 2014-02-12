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
 * Serializable.java                                      *
 *                                                        *
 * hprose Serializable interface for Java.                *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

public interface Serializable {
    String[] getPropertyNames();
    Class getPropertyType(String name);
    Object getProperty(String name);
    void setProperty(String name, Object value);
}