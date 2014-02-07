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
 * LastModified: Apr 13, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.util.Hashtable;

public final class ClassManager {
    private static final Hashtable classCache1 = new Hashtable();
    private static final Hashtable classCache2 = new Hashtable();
    private static final Object Null = new Object();

    private ClassManager() {
    }

    public static void register(Class type, String alias) {
        if (type != null) {
            classCache1.put(type, alias);
        }
        if (type != null) {
            classCache2.put(alias, type);
        }
        else {
            classCache2.put(alias, Null);
        }
    }

    public static String getClassAlias(Class type) {
        return (String)classCache1.get(type);
    }

    public static Class getClass(String alias) {
        Object obj = classCache2.get(alias);
        if (obj == Null) return null;
        return (Class)obj;
    }

    public static boolean containsClass(String alias) {
        return classCache2.containsKey(alias);
    }
}