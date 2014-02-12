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
 * HproseMethods.cs                                       *
 *                                                        *
 * hprose remote methods class for C#.                    *
 *                                                        *
 * LastModified: Dec 15, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.Reflection;

namespace Hprose.Common {
    public class HproseMethods {

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal Dictionary<string, Dictionary<int, HproseMethod>> remoteMethods = new Dictionary<string, Dictionary<int, HproseMethod>>(StringComparer.OrdinalIgnoreCase);
#elif MONO
        internal Hashtable remoteMethods = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
        internal Hashtable remoteMethods = new Hashtable(new CaseInsensitiveHashCodeProvider(), new CaseInsensitiveComparer());
#endif
        public HproseMethods() {
        }

        internal HproseMethod GetMethod(string aliasName, int paramCount) {
            if (!remoteMethods.ContainsKey(aliasName)) {
                return null;
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<int, HproseMethod> methods = remoteMethods[aliasName];
#else
            Hashtable methods = (Hashtable)remoteMethods[aliasName];
#endif
            if (!methods.ContainsKey(paramCount)) {
                return null;
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            return methods[paramCount];
#else
            return (HproseMethod)methods[paramCount];
#endif
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public ICollection<string> AllNames {
#else
        public ICollection AllNames {
#endif
            get {
                return remoteMethods.Keys;
            }
        }

        public int Count {
            get {
                return remoteMethods.Count;
            }
        }

        protected virtual int GetCount(Type[] paramTypes) {
            return paramTypes.Length;
        }

        internal void AddMethod(string aliasName, HproseMethod method) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<int, HproseMethod> methods;
            if (remoteMethods.ContainsKey(aliasName)) {
                methods = remoteMethods[aliasName];
            }
            else {
                methods = new Dictionary<int, HproseMethod>();
            }
#else
            Hashtable methods;
            if (remoteMethods.ContainsKey(aliasName)) {
                methods = (Hashtable)remoteMethods[aliasName];
            }
            else {
                methods = new Hashtable();
            }
#endif
            if (aliasName == "*" &&
                (!((method.paramTypes.Length == 2) &&
                   method.paramTypes[0] == typeof(string) &&
                   method.paramTypes[1] == typeof(object[])))) {
                return;
            }
            int i = GetCount(method.paramTypes);
            methods[i] = method;
            remoteMethods[aliasName] = methods;
        }

        public void AddMethod(MethodInfo method, object obj, string aliasName) {
            AddMethod(aliasName, new HproseMethod(method, obj));
        }

        public void AddMethod(MethodInfo method, object obj, string aliasName, HproseResultMode mode) {
            AddMethod(aliasName, new HproseMethod(method, obj, mode));
        }

        public void AddMethod(string methodName, object obj, Type[] paramTypes, string aliasName) {
            AddMethod(aliasName, new HproseMethod(methodName, obj, paramTypes));
        }

        public void AddMethod(string methodName, object obj, Type[] paramTypes, string aliasName, HproseResultMode mode) {
            AddMethod(aliasName, new HproseMethod(methodName, obj, paramTypes, mode));
        }

        public void AddMethod(string methodName, Type type, Type[] paramTypes, string aliasName) {
            AddMethod(aliasName, new HproseMethod(methodName, type, paramTypes));
        }

        public void AddMethod(string methodName, Type type, Type[] paramTypes, string aliasName, HproseResultMode mode) {
            AddMethod(aliasName, new HproseMethod(methodName, type, paramTypes, mode));
        }

        public void AddMethod(string methodName, object obj, Type[] paramTypes) {
            AddMethod(methodName, new HproseMethod(methodName, obj, paramTypes));
        }

        public void AddMethod(string methodName, object obj, Type[] paramTypes, HproseResultMode mode) {
            AddMethod(methodName, new HproseMethod(methodName, obj, paramTypes, mode));
        }

        public void AddMethod(string methodName, Type type, Type[] paramTypes) {
            AddMethod(methodName, new HproseMethod(methodName, type, paramTypes));
        }

        public void AddMethod(string methodName, Type type, Type[] paramTypes, HproseResultMode mode) {
            AddMethod(methodName, new HproseMethod(methodName, type, paramTypes, mode));
        }

        private void AddMethod(string methodName, object obj, Type type, string aliasName) {
            AddMethod(methodName, obj, type, aliasName, HproseResultMode.Normal);
        }

        private void AddMethod(string methodName, object obj, Type type, string aliasName, HproseResultMode mode) {
#if dotNET45
            IEnumerable<MethodInfo> methods = type.GetRuntimeMethods();
            foreach (MethodInfo method in methods) {
                if (method.IsPublic && (method.IsStatic == (obj == null)) && (methodName == method.Name)) {
                    AddMethod(aliasName, new HproseMethod(method, obj, mode));
                }
            }
#else
            BindingFlags flags = (obj == null) ? BindingFlags.Static : BindingFlags.Instance;
            MethodInfo[] methods = type.GetMethods(flags | BindingFlags.Public);
            for (int i = 0; i < methods.Length; i++) {
                if (methodName == methods[i].Name) {
                    AddMethod(aliasName, new HproseMethod(methods[i], obj, mode));
                }
            }
#endif
        }

        public void AddMethod(string methodName, object obj, string aliasName) {
            AddMethod(methodName, obj, obj.GetType(), aliasName);
        }

        public void AddMethod(string methodName, object obj, string aliasName, HproseResultMode mode) {
            AddMethod(methodName, obj, obj.GetType(), aliasName, mode);
        }

        public void AddMethod(string methodName, Type type, string aliasName) {
            AddMethod(methodName, null, type, aliasName);
        }

        public void AddMethod(string methodName, Type type, string aliasName, HproseResultMode mode) {
            AddMethod(methodName, null, type, aliasName, mode);
        }

        public void AddMethod(string methodName, object obj) {
            AddMethod(methodName, obj, methodName);
        }

        public void AddMethod(string methodName, object obj, HproseResultMode mode) {
            AddMethod(methodName, obj, methodName, mode);
        }

        public void AddMethod(string methodName, Type type) {
            AddMethod(methodName, type, methodName);
        }

        public void AddMethod(string methodName, Type type, HproseResultMode mode) {
            AddMethod(methodName, type, methodName, mode);
        }

        private void AddMethods(string[] methodNames, object obj, Type type, string[] aliasNames) {
            AddMethods(methodNames, obj, type, aliasNames, HproseResultMode.Normal);
        }

        private void AddMethods(string[] methodNames, object obj, Type type, string[] aliasNames, HproseResultMode mode) {
#if dotNET45
            IEnumerable<MethodInfo> methods = type.GetRuntimeMethods();
            for (int i = 0; i < methodNames.Length; i++) {
                string methodName = methodNames[i];
                string aliasName = aliasNames[i];
                foreach (MethodInfo method in methods) {
                    if (method.IsPublic && (method.IsStatic == (obj == null)) && (methodName == method.Name)) {
                        AddMethod(aliasName, new HproseMethod(method, obj, mode));
                    }
                }
            }
#else
            BindingFlags flags = (obj == null) ? BindingFlags.Static : BindingFlags.Instance;
            MethodInfo[] methods = type.GetMethods(flags | BindingFlags.Public);
            for (int i = 0; i < methodNames.Length; i++) {
                string methodName = methodNames[i];
                string aliasName = aliasNames[i];
                for (int j = 0; j < methods.Length; j++) {
                    if (methodName == methods[j].Name) {
                        AddMethod(aliasName, new HproseMethod(methods[j], obj, mode));
                    }
                }
            }
#endif
        }

        private void AddMethods(string[] methodNames, object obj, Type type, string aliasPrefix) {
            AddMethods(methodNames, obj, type, aliasPrefix, HproseResultMode.Normal);
        }

        private void AddMethods(string[] methodNames, object obj, Type type, string aliasPrefix, HproseResultMode mode) {
            string[] aliasNames = new string[methodNames.Length];
            for (int i = 0; i < methodNames.Length; i++) {
                aliasNames[i] = aliasPrefix + "_" + methodNames[i];
            }
            AddMethods(methodNames, obj, type, aliasNames, mode);
        }

        private void AddMethods(string[] methodNames, object obj, Type type) {
            AddMethods(methodNames, obj, type, methodNames, HproseResultMode.Normal);
        }

        private void AddMethods(string[] methodNames, object obj, Type type, HproseResultMode mode) {
            AddMethods(methodNames, obj, type, methodNames, mode);
        }

        public void AddMethods(string[] methodNames, object obj, string[] aliasNames) {
            AddMethods(methodNames, obj, obj.GetType(), aliasNames);
        }

        public void AddMethods(string[] methodNames, object obj, string[] aliasNames, HproseResultMode mode) {
            AddMethods(methodNames, obj, obj.GetType(), aliasNames, mode);
        }

        public void AddMethods(string[] methodNames, object obj, string aliasPrefix) {
            AddMethods(methodNames, obj, obj.GetType(), aliasPrefix);
        }

        public void AddMethods(string[] methodNames, object obj, string aliasPrefix, HproseResultMode mode) {
            AddMethods(methodNames, obj, obj.GetType(), aliasPrefix, mode);
        }

        public void AddMethods(string[] methodNames, object obj) {
            AddMethods(methodNames, obj, obj.GetType());
        }

        public void AddMethods(string[] methodNames, object obj, HproseResultMode mode) {
            AddMethods(methodNames, obj, obj.GetType(), mode);
        }

        public void AddMethods(string[] methodNames, Type type, string[] aliasNames) {
            AddMethods(methodNames, null, type, aliasNames);
        }

        public void AddMethods(string[] methodNames, Type type, string[] aliasNames, HproseResultMode mode) {
            AddMethods(methodNames, null, type, aliasNames, mode);
        }

        public void AddMethods(string[] methodNames, Type type, string aliasPrefix) {
            AddMethods(methodNames, null, type, aliasPrefix);
        }

        public void AddMethods(string[] methodNames, Type type, string aliasPrefix, HproseResultMode mode) {
            AddMethods(methodNames, null, type, aliasPrefix, mode);
        }

        public void AddMethods(string[] methodNames, Type type) {
            AddMethods(methodNames, null, type);
        }

        public void AddMethods(string[] methodNames, Type type, HproseResultMode mode) {
            AddMethods(methodNames, null, type, mode);
        }

        public void AddInstanceMethods(object obj, Type type, string aliasPrefix) {
            AddInstanceMethods(obj, type, aliasPrefix, HproseResultMode.Normal);
        }

        public void AddInstanceMethods(object obj, Type type, string aliasPrefix, HproseResultMode mode) {
            if (obj != null) {
#if dotNET45
                IEnumerable<MethodInfo> methods = type.GetTypeInfo().DeclaredMethods;
                foreach (MethodInfo method in methods) {
                    if (method.IsPublic && !(method.IsStatic)) {
                        AddMethod(method, obj, aliasPrefix + "_" + method.Name, mode);
                    }
                }
#else
                MethodInfo[] methods = type.GetMethods(BindingFlags.DeclaredOnly |
                                                       BindingFlags.Instance |
                                                       BindingFlags.Public);
                for (int i = 0; i < methods.Length; i++) {
                    AddMethod(methods[i], obj, aliasPrefix + "_" + methods[i].Name, mode);
                }
#endif
            }
        }

        public void AddInstanceMethods(object obj, Type type) {
            AddInstanceMethods(obj, type, HproseResultMode.Normal);
        }

        public void AddInstanceMethods(object obj, Type type, HproseResultMode mode) {
            if (obj != null) {
#if dotNET45
                IEnumerable<MethodInfo> methods = type.GetTypeInfo().DeclaredMethods;
                foreach (MethodInfo method in methods) {
                    if (method.IsPublic && !(method.IsStatic)) {
                        AddMethod(method, obj, method.Name, mode);
                    }
                }
#else
                MethodInfo[] methods = type.GetMethods(BindingFlags.DeclaredOnly |
                                                       BindingFlags.Instance |
                                                       BindingFlags.Public);
                for (int i = 0; i < methods.Length; i++) {
                    AddMethod(methods[i], obj, methods[i].Name, mode);
                }
#endif
            }
        }

        public void AddInstanceMethods(object obj, string aliasPrefix) {
            AddInstanceMethods(obj, obj.GetType(), aliasPrefix);
        }

        public void AddInstanceMethods(object obj, string aliasPrefix, HproseResultMode mode) {
            AddInstanceMethods(obj, obj.GetType(), aliasPrefix, mode);
        }

        public void AddInstanceMethods(object obj) {
            AddInstanceMethods(obj, obj.GetType());
        }

        public void AddInstanceMethods(object obj, HproseResultMode mode) {
            AddInstanceMethods(obj, obj.GetType(), mode);
        }

        public void AddStaticMethods(Type type, string aliasPrefix) {
            AddStaticMethods(type, aliasPrefix, HproseResultMode.Normal);
        }

        public void AddStaticMethods(Type type, string aliasPrefix, HproseResultMode mode) {
#if dotNET45
            IEnumerable<MethodInfo> methods = type.GetTypeInfo().DeclaredMethods;
            foreach (MethodInfo method in methods) {
                if (method.IsPublic && method.IsStatic) {
                    AddMethod(method, null, aliasPrefix + "_" + method.Name, mode);
                }
            }
#else
            MethodInfo[] methods = type.GetMethods(BindingFlags.DeclaredOnly |
                                                   BindingFlags.Static |
                                                   BindingFlags.Public);
            for (int i = 0; i < methods.Length; i++) {
                AddMethod(methods[i], null, aliasPrefix + "_" + methods[i].Name, mode);
            }
#endif
        }

        public void AddStaticMethods(Type type) {
            AddStaticMethods(type, HproseResultMode.Normal);
        }

        public void AddStaticMethods(Type type, HproseResultMode mode) {
#if dotNET45
            IEnumerable<MethodInfo> methods = type.GetTypeInfo().DeclaredMethods;
            foreach (MethodInfo method in methods) {
                if (method.IsPublic && method.IsStatic) {
                    AddMethod(method, null, method.Name, mode);
                }
            }
#else
            MethodInfo[] methods = type.GetMethods(BindingFlags.DeclaredOnly |
                                                   BindingFlags.Static |
                                                   BindingFlags.Public);
            for (int i = 0; i < methods.Length; i++) {
                AddMethod(methods[i], null, methods[i].Name, mode);
            }
#endif
        }

        public void AddMissingMethod(string methodName, object obj) {
            AddMethod(methodName, obj, new Type[] { typeof(string), typeof(object[]) }, "*");
        }

        public void AddMissingMethod(string methodName, object obj, HproseResultMode mode) {
            AddMethod(methodName, obj, new Type[] { typeof(string), typeof(object[]) }, "*", mode);
        }

        public void AddMissingMethod(string methodName, Type type) {
            AddMethod(methodName, type, new Type[] { typeof(string), typeof(object[]) }, "*");
        }

        public void AddMissingMethod(string methodName, Type type, HproseResultMode mode) {
            AddMethod(methodName, type, new Type[] { typeof(string), typeof(object[]) }, "*", mode);
        }
    }
}