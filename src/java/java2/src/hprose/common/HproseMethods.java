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
 * HproseMethods.java                                     *
 *                                                        *
 * hprose remote methods class for Java.                  *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.HashMap;
import java.util.Collection;

public class HproseMethods {

    protected HashMap remoteMethods = new HashMap();
    protected HashMap methodNames = new HashMap();

    public HproseMethods() {
    }

    public HproseMethod get(String aliasName, int paramCount) {
        HashMap methods = (HashMap) remoteMethods.get(aliasName);
        if (methods == null) {
            return null;
        }
        return (HproseMethod) methods.get(new Integer(paramCount));
    }

    public Collection getAllNames() {
        return methodNames.values();
    }

    public int getCount() {
        return remoteMethods.size();
    }

    protected int getCount(Class[] paramTypes) {
        return paramTypes.length;
    }

    void addMethod(String aliasName, HproseMethod method) {
        HashMap methods;
        String name = aliasName.toLowerCase();
        if (remoteMethods.containsKey(name)) {
            methods = (HashMap) remoteMethods.get(name);
        }
        else {
            methods = new HashMap();
            methodNames.put(name, aliasName);
        }
        if (aliasName.equals("*") &&
            (!((method.paramTypes.length == 2) &&
               method.paramTypes[0].equals(String.class) &&
               method.paramTypes[1].equals(Object[].class)))) {
            return;
        }
        int i = getCount(method.paramTypes);
        methods.put(new Integer(i), method);
        remoteMethods.put(name, methods);
    }

    public void addMethod(Method method, Object obj, String aliasName) {
        addMethod(aliasName, new HproseMethod(method, obj));
    }

    public void addMethod(Method method, Object obj, String aliasName, HproseResultMode mode) {
        addMethod(aliasName, new HproseMethod(method, obj, mode));
    }

    public void addMethod(String methodName, Object obj, Class[] paramTypes, String aliasName) throws NoSuchMethodException {
        addMethod(aliasName, new HproseMethod(methodName, obj, paramTypes));
    }

    public void addMethod(String methodName, Object obj, Class[] paramTypes, String aliasName, HproseResultMode mode) throws NoSuchMethodException {
        addMethod(aliasName, new HproseMethod(methodName, obj, paramTypes, mode));
    }

    public void addMethod(String methodName, Class type, Class[] paramTypes, String aliasName) throws NoSuchMethodException {
        addMethod(aliasName, new HproseMethod(methodName, type, paramTypes));
    }

    public void addMethod(String methodName, Class type, Class[] paramTypes, String aliasName, HproseResultMode mode) throws NoSuchMethodException {
        addMethod(aliasName, new HproseMethod(methodName, type, paramTypes, mode));
    }

    public void addMethod(String methodName, Object obj, Class[] paramTypes) throws NoSuchMethodException {
        addMethod(methodName, new HproseMethod(methodName, obj, paramTypes));
    }

    public void addMethod(String methodName, Object obj, Class[] paramTypes, HproseResultMode mode) throws NoSuchMethodException {
        addMethod(methodName, new HproseMethod(methodName, obj, paramTypes, mode));
    }

    public void addMethod(String methodName, Class type, Class[] paramTypes) throws NoSuchMethodException {
        addMethod(methodName, new HproseMethod(methodName, type, paramTypes));
    }

    public void addMethod(String methodName, Class type, Class[] paramTypes, HproseResultMode mode) throws NoSuchMethodException {
        addMethod(methodName, new HproseMethod(methodName, type, paramTypes, mode));
    }

    private void addMethod(String methodName, Object obj, Class type, String aliasName, HproseResultMode mode) {
        Method[] methods = type.getMethods();
        for (int i = 0; i < methods.length; i++) {
            if (methodName.equals(methods[i].getName()) &&
                ((obj == null) == Modifier.isStatic(methods[i].getModifiers()))) {
                addMethod(aliasName, new HproseMethod(methods[i], obj, mode));
            }
        }
    }

    private void addMethod(String methodName, Object obj, Class type, String aliasName) {
        addMethod(methodName, obj, type, aliasName, HproseResultMode.Normal);
    }

    public void addMethod(String methodName, Object obj, String aliasName) {
        addMethod(methodName, obj, obj.getClass(), aliasName);
    }

    public void addMethod(String methodName, Object obj, String aliasName, HproseResultMode mode) {
        addMethod(methodName, obj, obj.getClass(), aliasName, mode);
    }

    public void addMethod(String methodName, Class type, String aliasName) {
        addMethod(methodName, null, type, aliasName);
    }

    public void addMethod(String methodName, Class type, String aliasName, HproseResultMode mode) {
        addMethod(methodName, null, type, aliasName, mode);
    }

    public void addMethod(String methodName, Object obj) {
        addMethod(methodName, obj, methodName);
    }

    public void addMethod(String methodName, Object obj, HproseResultMode mode) {
        addMethod(methodName, obj, methodName, mode);
    }

    public void addMethod(String methodName, Class type) {
        addMethod(methodName, type, methodName);
    }

    public void addMethod(String methodName, Class type, HproseResultMode mode) {
        addMethod(methodName, type, methodName, mode);
    }

    private void addMethods(String[] methodNames, Object obj, Class type, String[] aliasNames, HproseResultMode mode) {
        Method[] methods = type.getMethods();
        for (int i = 0; i < methodNames.length; i++) {
            String methodName = methodNames[i];
            String aliasName = aliasNames[i];
            for (int j = 0; j < methods.length; j++) {
                if (methodName.equals(methods[j].getName()) &&
                    ((obj == null) == Modifier.isStatic(methods[j].getModifiers()))) {
                    addMethod(aliasName, new HproseMethod(methods[j], obj, mode));
                }
            }
        }
    }

    private void addMethods(String[] methodNames, Object obj, Class type, String[] aliasNames) {
        addMethods(methodNames, obj, type, aliasNames, HproseResultMode.Normal);
    }

    private void addMethods(String[] methodNames, Object obj, Class type, String aliasPrefix, HproseResultMode mode) {
        String[] aliasNames = new String[methodNames.length];
        for (int i = 0; i < methodNames.length; i++) {
            aliasNames[i] = aliasPrefix + "_" + methodNames[i];
        }
        addMethods(methodNames, obj, type, aliasNames, mode);
    }

    private void addMethods(String[] methodNames, Object obj, Class type, String aliasPrefix) {
        addMethods(methodNames, obj, type, aliasPrefix, HproseResultMode.Normal);
    }

    private void addMethods(String[] methodNames, Object obj, Class type, HproseResultMode mode) {
        addMethods(methodNames, obj, type, methodNames, mode);
    }

    private void addMethods(String[] methodNames, Object obj, Class type) {
        addMethods(methodNames, obj, type, methodNames, HproseResultMode.Normal);
    }

    public void addMethods(String[] methodNames, Object obj, String[] aliasNames) {
        addMethods(methodNames, obj, obj.getClass(), aliasNames);
    }

    public void addMethods(String[] methodNames, Object obj, String[] aliasNames, HproseResultMode mode) {
        addMethods(methodNames, obj, obj.getClass(), aliasNames, mode);
    }

    public void addMethods(String[] methodNames, Object obj, String aliasPrefix) {
        addMethods(methodNames, obj, obj.getClass(), aliasPrefix);
    }

    public void addMethods(String[] methodNames, Object obj, String aliasPrefix, HproseResultMode mode) {
        addMethods(methodNames, obj, obj.getClass(), aliasPrefix, mode);
    }

    public void addMethods(String[] methodNames, Object obj) {
        addMethods(methodNames, obj, obj.getClass());
    }

    public void addMethods(String[] methodNames, Object obj, HproseResultMode mode) {
        addMethods(methodNames, obj, obj.getClass(), mode);
    }

    public void addMethods(String[] methodNames, Class type, String[] aliasNames) {
        addMethods(methodNames, null, type, aliasNames);
    }

    public void addMethods(String[] methodNames, Class type, String[] aliasNames, HproseResultMode mode) {
        addMethods(methodNames, null, type, aliasNames, mode);
    }

    public void addMethods(String[] methodNames, Class type, String aliasPrefix) {
        addMethods(methodNames, null, type, aliasPrefix);
    }

    public void addMethods(String[] methodNames, Class type, String aliasPrefix, HproseResultMode mode) {
        addMethods(methodNames, null, type, aliasPrefix, mode);
    }

    public void addMethods(String[] methodNames, Class type) {
        addMethods(methodNames, null, type);
    }

    public void addMethods(String[] methodNames, Class type, HproseResultMode mode) {
        addMethods(methodNames, null, type, mode);
    }

    public void addInstanceMethods(Object obj, Class type, String aliasPrefix, HproseResultMode mode) {
        if (obj != null) {
            Method[] methods = type.getDeclaredMethods();
            for (int i = 0; i < methods.length; i++) {
                int mod = methods[i].getModifiers();
                if (Modifier.isPublic(mod) && !Modifier.isStatic(mod)) {
                    addMethod(methods[i], obj, aliasPrefix + "_" + methods[i].getName(), mode);
                }
            }
        }
    }

    public void addInstanceMethods(Object obj, Class type, String aliasPrefix) {
        addInstanceMethods(obj, type, aliasPrefix, HproseResultMode.Normal);
    }

    public void addInstanceMethods(Object obj, Class type, HproseResultMode mode) {
        if (obj != null) {
            Method[] methods = type.getDeclaredMethods();
            for (int i = 0; i < methods.length; i++) {
                int mod = methods[i].getModifiers();
                if (Modifier.isPublic(mod) && !Modifier.isStatic(mod)) {
                    addMethod(methods[i], obj, methods[i].getName(), mode);
                }
            }
        }
    }

    public void addInstanceMethods(Object obj, Class type) {
        addInstanceMethods(obj, type, HproseResultMode.Normal);
    }

    public void addInstanceMethods(Object obj, String aliasPrefix) {
        addInstanceMethods(obj, obj.getClass(), aliasPrefix);
    }

    public void addInstanceMethods(Object obj, String aliasPrefix, HproseResultMode mode) {
        addInstanceMethods(obj, obj.getClass(), aliasPrefix, mode);
    }

    public void addInstanceMethods(Object obj) {
        addInstanceMethods(obj, obj.getClass());
    }

    public void addInstanceMethods(Object obj, HproseResultMode mode) {
        addInstanceMethods(obj, obj.getClass(), mode);
    }

    public void addStaticMethods(Class type, String aliasPrefix, HproseResultMode mode) {
        Method[] methods = type.getDeclaredMethods();
        for (int i = 0; i < methods.length; i++) {
            int mod = methods[i].getModifiers();
            if (Modifier.isPublic(mod) && Modifier.isStatic(mod)) {
                addMethod(methods[i], null, aliasPrefix + "_" + methods[i].getName(), mode);
            }
        }
    }

    public void addStaticMethods(Class type, String aliasPrefix) {
        addStaticMethods(type, aliasPrefix, HproseResultMode.Normal);
    }

    public void addStaticMethods(Class type, HproseResultMode mode) {
        Method[] methods = type.getDeclaredMethods();
        for (int i = 0; i < methods.length; i++) {
            int mod = methods[i].getModifiers();
            if (Modifier.isPublic(mod) && Modifier.isStatic(mod)) {
                addMethod(methods[i], null, methods[i].getName(), mode);
            }
        }
    }

    public void addStaticMethods(Class type) {
        addStaticMethods(type, HproseResultMode.Normal);
    }

    public void addMissingMethod(String methodName, Object obj) throws NoSuchMethodException {
        addMethod(methodName, obj, new Class[] { String.class, Object[].class }, "*");
    }

    public void addMissingMethod(String methodName, Object obj, HproseResultMode mode) throws NoSuchMethodException {
        addMethod(methodName, obj, new Class[] { String.class, Object[].class }, "*", mode);
    }

    public void addMissingMethod(String methodName, Class type) throws NoSuchMethodException {
        addMethod(methodName, type, new Class[] { String.class, Object[].class }, "*");
    }

    public void addMissingMethod(String methodName, Class type, HproseResultMode mode) throws NoSuchMethodException {
        addMethod(methodName, type, new Class[] { String.class, Object[].class }, "*", mode);
    }
}
