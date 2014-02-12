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
 * PropertyAccessor.java                                  *
 *                                                        *
 * PropertyAccessor class for Java.                       *
 *                                                        *
 * LastModified: Dec 26, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

final class PropertyAccessor extends MemberAccessor {
    private Method getter;
    private Method setter;
    private static final Object[] nullArgs = new Object[0];

    public PropertyAccessor(Method getter, Method setter) {
        getter.setAccessible(true);
        setter.setAccessible(true);
        this.getter = getter;
        this.setter = setter;
        this.type = getter.getGenericReturnType();
        this.cls =  HproseHelper.toClass(type);
        this.typecode = TypeCode.get(cls);
    }

    @Override
    void set(Object obj, Object value) throws IllegalAccessException,
                                              IllegalArgumentException,
                                              InvocationTargetException {
        setter.invoke(obj, new Object[] { value });
    }

    @Override
    Object get(Object obj) throws IllegalAccessException,
                                  IllegalArgumentException,
                                  InvocationTargetException {
        return getter.invoke(obj, nullArgs);
    }
}