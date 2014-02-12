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
 * MemberAccessor.java                                    *
 *                                                        *
 * MemberAccessor interface for Java.                     *
 *                                                        *
 * LastModified: Dec 26, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Type;

abstract class MemberAccessor {
    Class<?> cls;
    Type type;
    int typecode;
    abstract void set(Object obj, Object value) throws IllegalAccessException,
                                                       IllegalArgumentException,
                                                       InvocationTargetException;
    abstract Object get(Object obj) throws IllegalAccessException,
                                           IllegalArgumentException,
                                           InvocationTargetException;
}