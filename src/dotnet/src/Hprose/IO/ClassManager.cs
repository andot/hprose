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
 * ClassManager.cs                                        *
 *                                                        *
 * hprose ClassManager for C#.                            *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif

namespace Hprose.IO {
    public sealed class ClassManager {
#if (dotNET10 || dotNET11 || dotNETCF10)
        private static readonly Hashtable classCache1 = new Hashtable();
        private static readonly Hashtable classCache2 = new Hashtable();
#else
        private static readonly Dictionary<Type, string> classCache1 = new Dictionary<Type, string>();
        private static readonly Dictionary<string, Type> classCache2 = new Dictionary<string, Type>();
#endif
        public static void Register(Type type, string alias) {
            lock (((ICollection)classCache1).SyncRoot) {
                if (type != null) {
                    classCache1[type] = alias;
                }
            }
            lock (((ICollection)classCache2).SyncRoot) {
                classCache2[alias] = type;
            }
        }

        public static string GetClassAlias(Type type) {
            lock (((ICollection)classCache1).SyncRoot) {
#if (dotNET10 || dotNET11 || dotNETCF10)
                return (string)classCache1[type];
#else
                string alias = null;
                classCache1.TryGetValue(type, out alias);
                return alias;
#endif
            }
        }

        public static Type GetClass(string alias) {
            lock (((ICollection)classCache2).SyncRoot) {
#if (dotNET10 || dotNET11 || dotNETCF10)
                return (Type)classCache2[alias];
#else
                Type type = null;
                classCache2.TryGetValue(alias, out type);
                return type;
#endif
            }
        }

        public static bool ContainsClass(string alias) {
            lock (((ICollection)classCache2).SyncRoot) {
                return classCache2.ContainsKey(alias);
            }
        }
    }
}