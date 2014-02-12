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
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

public final class HproseMethod {
    public Object obj;
    public Method method;
    public Class[] paramTypes;
    public HproseMethod(Method method, Object obj) {
        this.obj = obj;
        this.method = method;
        this.paramTypes = method.getParameterTypes();
    }
    public HproseMethod(Method method) {
        this(method, null);
    }
    public HproseMethod(String methodName, Class type, Class[] paramTypes) throws NoSuchMethodException {
        this.obj = null;
        this.method = type.getMethod(methodName, paramTypes);
        if (!Modifier.isStatic(this.method.getModifiers())) {
            throw new NoSuchMethodException();
        }
        this.paramTypes = paramTypes;
    }
    public HproseMethod(String methodName, Object obj, Class[] paramTypes) throws NoSuchMethodException {
        this.obj = obj;
        this.method = obj.getClass().getMethod(methodName, paramTypes);
        if (Modifier.isStatic(this.method.getModifiers())) {
            throw new NoSuchMethodException();
        }
        this.paramTypes = paramTypes;
    }
}