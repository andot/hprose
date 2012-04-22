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
 * HproseMethod.java                                      *
 *                                                        *
 * hprose remote method class for Java.                   *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Type;

public final class HproseMethod {
    public Object obj;
    public Method method;
    public Type[] paramTypes;
    public HproseResultMode mode;

    public HproseMethod(Method method, Object obj, HproseResultMode mode) {
        this.obj = obj;
        this.method = method;
        this.paramTypes = method.getGenericParameterTypes();
        this.mode = mode;
    }
    public HproseMethod(Method method, Object obj) {
        this(method, obj, HproseResultMode.Normal);
    }
    public HproseMethod(Method method) {
        this(method, null, HproseResultMode.Normal);
    }
    public HproseMethod(String methodName, Class<?> type, Class<?>[] paramTypes, HproseResultMode mode) throws NoSuchMethodException {
        this.obj = null;
        this.method = type.getMethod(methodName, paramTypes);
        if (!Modifier.isStatic(this.method.getModifiers())) {
            throw new NoSuchMethodException();
        }
        this.paramTypes = method.getGenericParameterTypes();
        this.mode = mode;
    }
    public HproseMethod(String methodName, Class<?> type, Class<?>[] paramTypes) throws NoSuchMethodException {
        this(methodName, type, paramTypes, HproseResultMode.Normal);
    }
    public HproseMethod(String methodName, Object obj, Class<?>[] paramTypes, HproseResultMode mode) throws NoSuchMethodException {
        this.obj = obj;
        this.method = obj.getClass().getMethod(methodName, paramTypes);
        if (Modifier.isStatic(this.method.getModifiers())) {
            throw new NoSuchMethodException();
        }
        this.paramTypes = method.getGenericParameterTypes();
        this.mode = mode;
    }
    public HproseMethod(String methodName, Object obj, Class<?>[] paramTypes) throws NoSuchMethodException {
        this(methodName, obj, paramTypes, HproseResultMode.Normal);
    }
}