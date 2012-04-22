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
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;

namespace Hprose.IO {
    public sealed class ClassManager {
        private static readonly HashMap classCache1 = new HashMap();
        private static readonly HashMap classCache2 = new HashMap();

        public static void Register(Type type, string alias) {
            lock (classCache1.SyncRoot) {
                classCache1[type] = alias;
            }
            lock (classCache2.SyncRoot) {
                classCache2[alias] = type;           
            }
        }

        public static string GetClassAlias(Type type) {
            lock (classCache1.SyncRoot) {
                return (string)classCache1[type];
            }
        }

        public static Type GetClass(string alias) {
            lock (classCache2.SyncRoot) {
                return (Type)classCache2[alias];
            }
        }

        public static bool ContainsClass(string alias) {
            lock (classCache2.SyncRoot) {
                return classCache2.ContainsKey(alias);
            }
        }
    }
}