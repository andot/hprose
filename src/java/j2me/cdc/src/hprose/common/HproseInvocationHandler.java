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
 * HproseInvocationHandler.java                           *
 *                                                        *
 * hprose InvocationHandler class for Java.               *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

public class HproseInvocationHandler implements InvocationHandler {

    private HproseInvoker client;
    private String ns;

    public HproseInvocationHandler(HproseInvoker client, String ns) {
        this.client = client;
        this.ns = ns;
    }

    public Object invoke(Object proxy, Method method, Object[] arguments) throws Throwable {
        Class[] paramTypes = method.getParameterTypes();
        Class returnType = method.getReturnType();
        if (void.class.equals(returnType) ||
            Void.class.equals(returnType)) {
            returnType = null;
        }
        int n = paramTypes.length;
        String functionName = method.getName();
        if (ns != null) {
            functionName = ns + '_' + functionName;
        }
        Object result = null;
        if ((n > 0) && (paramTypes[n - 1].equals(HproseCallback.class))) {
            HproseCallback callback = (HproseCallback) arguments[n - 1];
            Object[] tmpargs = new Object[n - 1];
            System.arraycopy(arguments, 0, tmpargs, 0, n - 1);
            client.invoke(functionName, tmpargs, callback, returnType);
        }
        else if ((n > 1) &&
                 (paramTypes[n - 2].equals(HproseCallback.class)) &&
                 (paramTypes[n - 1].equals(boolean.class))) {
            HproseCallback callback = (HproseCallback) arguments[n - 2];
            boolean byRef = ((Boolean) arguments[n - 1]).booleanValue();
            Object[] tmpargs = new Object[n - 2];
            System.arraycopy(arguments, 0, tmpargs, 0, n - 2);
            client.invoke(functionName, tmpargs, callback, returnType, byRef);
        }
        else if ((n > 1) &&
                 (paramTypes[n - 2].equals(HproseCallback.class)) &&
                 (paramTypes[n - 1].equals(Class.class))) {
            HproseCallback callback = (HproseCallback) arguments[n - 2];
            returnType = (Class) arguments[n - 1];
            Object[] tmpargs = new Object[n - 2];
            System.arraycopy(arguments, 0, tmpargs, 0, n - 2);
            client.invoke(functionName, tmpargs, callback, returnType);
        }
        else if ((n > 2) &&
                 (paramTypes[n - 3].equals(HproseCallback.class)) &&
                 (paramTypes[n - 2].equals(Class.class)) &&
                 (paramTypes[n - 1].equals(boolean.class))) {
            HproseCallback callback = (HproseCallback) arguments[n - 3];
            returnType = (Class) arguments[n - 2];
            boolean byRef = ((Boolean) arguments[n - 1]).booleanValue();
            Object[] tmpargs = new Object[n - 3];
            System.arraycopy(arguments, 0, tmpargs, 0, n - 3);
            client.invoke(functionName, tmpargs, callback, returnType, byRef);
        }
        else {
            result = client.invoke(functionName, arguments, returnType);
            if (result instanceof HproseException) {
                throw (HproseException) result;
            }
        }
        if (result == null) {
            if (int.class.equals(returnType)) {
                return new Integer(0);
            }
            if (long.class.equals(returnType)) {
                return new Long(0);
            }
            if (byte.class.equals(returnType)) {
                return new Byte((byte) 0);
            }
            if (short.class.equals(returnType)) {
                return new Short((short) 0);
            }
            if (float.class.equals(returnType)) {
                return new Float(0.0);
            }
            if (double.class.equals(returnType)) {
                return new Double(0.0);
            }
            if (char.class.equals(returnType)) {
                return new Character((char) 0);
            }
            if (boolean.class.equals(returnType)) {
                return Boolean.FALSE;
            }
        }
        return result;
    }
}
