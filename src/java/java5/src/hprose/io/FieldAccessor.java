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
 * FieldAccessor.java                                     *
 *                                                        *
 * FieldAccessor class for Java.                          *
 *                                                        *
 * LastModified: Dec 26, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;

final class FieldAccessor extends MemberAccessor {
    private Field accessor;

    public FieldAccessor(Field accessor) {
        accessor.setAccessible(true);
        this.accessor = accessor;
        this.type = accessor.getGenericType();
        this.cls = HproseHelper.toClass(type);
        this.typecode = TypeCode.get(cls);
    }

    @Override
    void set(Object obj, Object value) throws IllegalAccessException,
                                              IllegalArgumentException,
                                              InvocationTargetException {
        accessor.set(obj, value);
    }

    @Override
    Object get(Object obj) throws IllegalAccessException,
                                  IllegalArgumentException,
                                  InvocationTargetException {
        return accessor.get(obj);
    }
}