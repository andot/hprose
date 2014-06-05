/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * ClassManager.java                                      *
 *                                                        *
 * ClassManager for Java.                                 *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.util.HashMap;

public final class ClassManager {
    private static final HashMap classCache1 = new HashMap();
    private static final HashMap classCache2 = new HashMap();

    private ClassManager() {
    }

    public static void register(Class type, String alias) {
        synchronized (classCache1) {
            classCache1.put(type, alias);
        }
        synchronized (classCache2) {
            classCache2.put(alias, type);
        }
    }

    public static String getClassAlias(Class type) {
        synchronized (classCache1) {
            return (String)classCache1.get(type);
        }
    }

    public static Class getClass(String alias) {
        synchronized (classCache2) {
            return (Class)classCache2.get(alias);
        }
    }

    public static boolean containsClass(String alias) {
        synchronized (classCache2) {
            return classCache2.containsKey(alias);
        }
    }
}