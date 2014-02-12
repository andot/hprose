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
 * ClassManager.java                                      *
 *                                                        *
 * ClassManager for Java.                                 *
 *                                                        *
 * LastModified: May 6, 2011                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.util.concurrent.ConcurrentHashMap;

public final class ClassManager {
    private static final ConcurrentHashMap<Class<?>, String> classCache1 = new ConcurrentHashMap<Class<?>, String>();
    private static final ConcurrentHashMap<String, Class<?>> classCache2 = new ConcurrentHashMap<String, Class<?>>();

    private ClassManager() {
    }

    public static void register(Class<?> type, String alias) {
        classCache1.put(type, alias);
        classCache2.put(alias, type);
    }

    public static String getClassAlias(Class<?> type) {
        return classCache1.get(type);
    }

    public static Class<?> getClass(String alias) {
        return classCache2.get(alias);
    }

    public static boolean containsClass(String alias) {
        return classCache2.containsKey(alias);
    }
}