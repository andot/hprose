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
 * Proxy.cs                                               *
 *                                                        *
 * Proxy class for C#.                                    *
 *                                                        *
 * LastModified: Nov 6, 2012                              *
 * Authors: Ma Bingyao <andot@hprose.com>                 *
 *                                                        *
\**********************************************************/

#if !(PocketPC || Smartphone || WindowsCE || WINDOWS_PHONE || Core)
using System;
using System.Collections;
#if !(dotNET10 || dotNET11)
using System.Collections.Generic;
#endif
using System.Globalization;
using System.Reflection;
using System.Reflection.Emit;
using System.Threading;

namespace Hprose.Reflection {
    public class Proxy {
        protected IInvocationHandler handler;
#if !(dotNET10 || dotNET11)
        private static readonly List<MethodInfo> methodsTable = new List<MethodInfo>();
#else
        private static readonly ArrayList methodsTable = new ArrayList();
        private static readonly Type typeofType = typeof(Type);
#endif
        private static readonly Type typeofInt8 = typeof(sbyte);
        private static readonly Type typeofUInt8 = typeof(byte);
        private static readonly Type typeofBoolean = typeof(bool);
        private static readonly Type typeofInt16 = typeof(short);
        private static readonly Type typeofUInt16 = typeof(ushort);
        private static readonly Type typeofChar = typeof(char);
        private static readonly Type typeofInt32 = typeof(int);
        private static readonly Type typeofUInt32 = typeof(uint);
        private static readonly Type typeofInt64 = typeof(long);
        private static readonly Type typeofUInt64 = typeof(ulong);
        private static readonly Type typeofSingle = typeof(float);
        private static readonly Type typeofDouble = typeof(double);
        private static readonly Type typeofObject = typeof(object);
        private static readonly Type typeofObjectArray = typeof(object[]);
        private static readonly Type typeofVoid = typeof(void);
        private static readonly Type typeofMethodInfo = typeof(MethodInfo);
        private static readonly Type typeofProxy = typeof(Proxy);
        private static readonly Type typeofIInvocationHandler = typeof(IInvocationHandler);

        private static readonly Type[] Types_InvocationHandler = new Type[] { typeofIInvocationHandler };
        private static readonly FieldInfo FieldInfo_handler = typeofProxy.GetField("handler", BindingFlags.Instance | BindingFlags.NonPublic);
        private static readonly ConstructorInfo Proxy_Ctor = typeofProxy.GetConstructor(BindingFlags.NonPublic | BindingFlags.Instance, null, new Type[] { typeof(IInvocationHandler) }, null);
        private static readonly MethodInfo Proxy_Invoke = typeofIInvocationHandler.GetMethod("Invoke", new Type[] { typeofObject, typeofMethodInfo, typeofObjectArray });
        private static readonly MethodInfo MethodInfo_GetMethod = typeofProxy.GetMethod("GetMethod", BindingFlags.NonPublic | BindingFlags.Static, null, new Type[] { typeofInt32 }, null);

        private static int countAssembly = 0;
#if (dotNET35 || dotNET4)
        private static readonly ReaderWriterLockSlim proxyCacheLock = new ReaderWriterLockSlim();
#else
        private static readonly ReaderWriterLock proxyCacheLock = new ReaderWriterLock();
#endif
#if !(dotNET10 || dotNET11)
        private static readonly Dictionary<ProxyKey, Type> proxyCache = new Dictionary<ProxyKey, Type>();
#else
        private static readonly Hashtable proxyCache = new Hashtable();
#endif

        protected Proxy(IInvocationHandler handler) {
            this.handler = handler;
        }

        public static bool IsProxyType(Type type) {
            if (type == null) {
                throw new ArgumentNullException();
            }
            return proxyCache.ContainsValue(type);
        }

        public static IInvocationHandler GetInvocationHandler(object proxy) {
            if (proxy == null) {
                throw new ArgumentNullException();
            }
            if (!IsProxyType(proxy.GetType())) {
                throw new ArgumentException();
            }

            return ((Proxy)proxy).handler;
        }

        public static object NewInstance(AppDomain domain, Type[] interfaces, IInvocationHandler handler) {
            return GetProxy(domain, interfaces)
                .GetConstructor(Types_InvocationHandler)
                .Invoke(new object[] { handler });
        }

        public static Type GetProxy(AppDomain domain, params Type[] interfaces) {
            ProxyKey proxyKey = new ProxyKey(domain, interfaces);
            Type proxy = null;
            try {
#if (dotNET35 || dotNET4)
                proxyCacheLock.EnterReadLock();
#else
                proxyCacheLock.AcquireReaderLock(-1);
#endif
#if !(dotNET10 || dotNET11)
                if (proxyCache.TryGetValue(proxyKey, out proxy)) {
                    return proxy;
#else
                if (proxyCache.ContainsKey(proxyKey)) {
                    return (Type)proxyCache[proxyKey];
#endif
                }
            }
            finally {
#if (dotNET35 || dotNET4)
                proxyCacheLock.ExitReadLock();
#else
                proxyCacheLock.ReleaseReaderLock();
#endif
            }
            try {
#if (dotNET35 || dotNET4)
                proxyCacheLock.EnterWriteLock();
#else
                proxyCacheLock.AcquireWriterLock(-1);
#endif
#if !(dotNET10 || dotNET11)
                if (proxyCache.TryGetValue(proxyKey, out proxy)) {
                    return proxy;
#else
                if (proxyCache.ContainsKey(proxyKey)) {
                    return (Type)proxyCache[proxyKey];
#endif
                }
                proxy = GetProxyWithoutCache(domain, interfaces);
                proxyCache[proxyKey] = proxy;
            }
            finally {
#if (dotNET35 || dotNET4)
                proxyCacheLock.ExitWriteLock();
#else
                proxyCacheLock.ReleaseWriterLock();
#endif
            }
            return proxy;
        }

        private static Type GetProxyWithoutCache(AppDomain domain, Type[] interfaces) {
            interfaces = SumUpInterfaces(interfaces);
            String strNumber = countAssembly.ToString(NumberFormatInfo.InvariantInfo);
            String moduleName = "$Module" + strNumber;
            String proxyTypeName = "$Proxy" + strNumber;
            Interlocked.Increment(ref countAssembly);

            AssemblyName assemblyName = new AssemblyName();
            assemblyName.Name = "$Assembly" + strNumber;
            AssemblyBuilder assemblyBuilder = domain.DefineDynamicAssembly(assemblyName, AssemblyBuilderAccess.Run);
            ModuleBuilder moduleBuilder;

            moduleBuilder = assemblyBuilder.DefineDynamicModule(moduleName);

            TypeBuilder typeBuilder = moduleBuilder.DefineType(proxyTypeName, TypeAttributes.Public, typeofProxy, interfaces);

            //build .ctor
            ConstructorBuilder ctorBuilder = typeBuilder.DefineConstructor(MethodAttributes.Public |
                MethodAttributes.HideBySig, CallingConventions.Standard, Types_InvocationHandler);
            ILGenerator gen = ctorBuilder.GetILGenerator();
            gen.Emit(OpCodes.Ldarg_0);
            gen.Emit(OpCodes.Ldarg_1);
            gen.Emit(OpCodes.Call, Proxy_Ctor);
            gen.Emit(OpCodes.Ret);

            MakeMethods(typeBuilder, typeofObject, true);

            foreach (Type interfac in interfaces) {
                MakeMethods(typeBuilder, interfac, false);
            }

            return typeBuilder.CreateType();
        }

        private static Type[] SumUpInterfaces(Type[] interfaces) {
#if !(dotNET10 || dotNET11)
            List<Type> flattenedInterfaces = new List<Type>();
            SumUpInterfaces(flattenedInterfaces, interfaces);
            return flattenedInterfaces.ToArray();
#else
            ArrayList flattenedInterfaces = new ArrayList();
            SumUpInterfaces(flattenedInterfaces, interfaces);
            return (Type[])flattenedInterfaces.ToArray(typeofType);
#endif
        }

#if !(dotNET10 || dotNET11)
        private static void SumUpInterfaces(List<Type> types, Type[] interfaces) {
#else
        private static void SumUpInterfaces(ArrayList types, Type[] interfaces) {
#endif
            foreach (Type interfac in interfaces) {
                if (!interfac.IsInterface) {
                    throw new ArgumentException();
                }
                if (!types.Contains(interfac)) {
                    types.Add(interfac);
                }
                Type[] baseInterfaces = interfac.GetInterfaces();
                if (baseInterfaces.Length > 0) {
                    SumUpInterfaces(types, baseInterfaces);
                }
            }
        }

        private static Type[] ToTypes(ParameterInfo[] parameterInfos) {
            Type[] types = new Type[parameterInfos.Length];
            for (int i = 0; i < parameterInfos.Length; i++) {
                types[i] = parameterInfos[i].ParameterType;
            }
            return types;
        }

        private static void MakeMethods(TypeBuilder typeBuilder, Type type, bool createPublic) {
#if !(dotNET10 || dotNET11)
            Dictionary<MethodInfo, MethodBuilder> methodToMB = new Dictionary<MethodInfo, MethodBuilder>();
#else
            Hashtable methodToMB = new Hashtable();
#endif
            foreach (MethodInfo method in type.GetMethods(BindingFlags.Instance | BindingFlags.Public)) {
                MethodBuilder mdb = MakeMethod(typeBuilder, method, createPublic);
                methodToMB.Add(method, mdb);
            }

            foreach (PropertyInfo property in type.GetProperties(BindingFlags.Instance | BindingFlags.Public)) {
                PropertyBuilder pb = typeBuilder.DefineProperty(property.Name, property.Attributes, property.PropertyType, ToTypes(property.GetIndexParameters()));
                MethodInfo getMethod = property.GetGetMethod();
                if (getMethod != null && methodToMB.ContainsKey(getMethod)) {
#if !(dotNET10 || dotNET11)
                    pb.SetGetMethod(methodToMB[getMethod]);
#else
                    pb.SetGetMethod((MethodBuilder)methodToMB[getMethod]);
#endif
                }
                MethodInfo setMethod = property.GetSetMethod();
                if (setMethod != null && methodToMB.ContainsKey(setMethod)) {
#if !(dotNET10 || dotNET11)
                    pb.SetSetMethod(methodToMB[setMethod]);
#else
                    pb.SetGetMethod((MethodBuilder)methodToMB[getMethod]);
#endif
                }
            }
        }

        private static MethodBuilder MakeMethod(TypeBuilder typeBuilder, MethodInfo method, bool createPublic) {
            int methodNum = Proxy.Register(method);

            Type[] paramTypes = ToTypes(method.GetParameters());
            int paramNum = paramTypes.Length;
            bool[] paramsByRef = new bool[paramNum];

            MethodBuilder b;
            string name;
            MethodAttributes methodAttr;
            if (createPublic) {
                name = method.Name;
                methodAttr = MethodAttributes.Public |
                             MethodAttributes.Virtual |
                             MethodAttributes.HideBySig;
            }
            else {
                name = method.DeclaringType.FullName + "." + method.Name;
                methodAttr = MethodAttributes.Private |
                             MethodAttributes.Virtual |
                             MethodAttributes.HideBySig |
                             MethodAttributes.NewSlot |
                             MethodAttributes.Final;
            }
            b = typeBuilder.DefineMethod(name, methodAttr, method.CallingConvention, method.ReturnType, paramTypes);

            ILGenerator gen = b.GetILGenerator();
            LocalBuilder parameters = gen.DeclareLocal(typeofObjectArray);
            LocalBuilder result = gen.DeclareLocal(typeofObject);
            LocalBuilder retval = null;
            if (!method.ReturnType.Equals(typeofVoid)) {
                retval = gen.DeclareLocal(method.ReturnType);
            }
            gen.Emit(OpCodes.Ldarg_0);
            gen.Emit(OpCodes.Ldfld, FieldInfo_handler); //this.handler
            gen.Emit(OpCodes.Ldarg_0);

            gen.Emit(OpCodes.Ldc_I4, methodNum);
            gen.Emit(OpCodes.Call, MethodInfo_GetMethod);

            gen.Emit(OpCodes.Ldc_I4, paramNum);
            gen.Emit(OpCodes.Newarr, typeofObject); // new Object[]
            if (paramNum > 0) {
                gen.Emit(OpCodes.Stloc, parameters);

                for (Int32 i = 0; i < paramNum; i++) {
                    gen.Emit(OpCodes.Ldloc, parameters);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldarg, i + 1);
                    if (paramTypes[i].IsByRef) {
                        paramTypes[i] = paramTypes[i].GetElementType();
                        if (paramTypes[i] == typeofInt8 || paramTypes[i] == typeofBoolean) {
                            gen.Emit(OpCodes.Ldind_I1);
                        }
                        else if (paramTypes[i] == typeofUInt8) {
                            gen.Emit(OpCodes.Ldind_U1);
                        }
                        else if (paramTypes[i] == typeofInt16) {
                            gen.Emit(OpCodes.Ldind_I2);
                        }
                        else if (paramTypes[i] == typeofUInt16 || paramTypes[i] == typeofChar) {
                            gen.Emit(OpCodes.Ldind_U2);
                        }
                        else if (paramTypes[i] == typeofInt32) {
                            gen.Emit(OpCodes.Ldind_I4);
                        }
                        else if (paramTypes[i] == typeofUInt32) {
                            gen.Emit(OpCodes.Ldind_U4);
                        }
                        else if (paramTypes[i] == typeofInt64 || paramTypes[i] == typeofUInt64) {
                            gen.Emit(OpCodes.Ldind_I8);
                        }
                        else if (paramTypes[i] == typeofSingle) {
                            gen.Emit(OpCodes.Ldind_R4);
                        }
                        else if (paramTypes[i] == typeofDouble) {
                            gen.Emit(OpCodes.Ldind_R8);
                        }
                        else if (paramTypes[i].IsValueType) {
                            gen.Emit(OpCodes.Ldobj, paramTypes[i]);
                        }
                        else {
                            gen.Emit(OpCodes.Ldind_Ref);
                        }
                        paramsByRef[i] = true;
                    }
                    else {
                        paramsByRef[i] = false;
                    }
                    if (paramTypes[i].IsValueType) {
                        gen.Emit(OpCodes.Box, paramTypes[i]);
                    }
                    gen.Emit(OpCodes.Stelem_Ref);
                }

                gen.Emit(OpCodes.Ldloc, parameters);
            }

            // base.Invoke(this, method, parameters);
            gen.Emit(OpCodes.Callvirt, Proxy_Invoke);
            gen.Emit(OpCodes.Stloc, result);

            for (Int32 i = 0; i < paramNum; i++) {
                if (paramsByRef[i]) {
                    gen.Emit(OpCodes.Ldarg, i + 1);
                    gen.Emit(OpCodes.Ldloc, parameters);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldelem_Ref);
                    if (paramTypes[i].IsValueType) {
#if !(dotNET10 || dotNET11)
                        gen.Emit(OpCodes.Unbox_Any, paramTypes[i]);
#else
                        gen.Emit(OpCodes.Unbox, paramTypes[i]);
                        gen.Emit(OpCodes.Ldobj, paramTypes[i]);
#endif
                    }
                    else {
                        gen.Emit(OpCodes.Castclass, paramTypes[i]);
                    }
                    if (paramTypes[i] == typeofInt8 || paramTypes[i] == typeofUInt8 || paramTypes[i] == typeofBoolean) {
                        gen.Emit(OpCodes.Stind_I1);
                    }
                    else if (paramTypes[i] == typeofInt16 || paramTypes[i] == typeofUInt16 || paramTypes[i] == typeofChar) {
                        gen.Emit(OpCodes.Stind_I2);
                    }
                    else if (paramTypes[i] == typeofInt32 || paramTypes[i] == typeofUInt32) {
                        gen.Emit(OpCodes.Stind_I4);
                    }
                    else if (paramTypes[i] == typeofInt64 || paramTypes[i] == typeofUInt64) {
                        gen.Emit(OpCodes.Stind_I8);
                    }
                    else if (paramTypes[i] == typeofSingle) {
                        gen.Emit(OpCodes.Stind_R4);
                    }
                    else if (paramTypes[i] == typeofDouble) {
                        gen.Emit(OpCodes.Stind_R8);
                    }
                    else if (paramTypes[i].IsValueType) {
                        gen.Emit(OpCodes.Stobj, paramTypes[i]);
                    }
                    else {
                        gen.Emit(OpCodes.Stind_Ref);
                    }
                }
            }

            if (!method.ReturnType.Equals(typeofVoid)) {
                gen.Emit(OpCodes.Ldloc, result);
                if (method.ReturnType.IsValueType) {
#if !(dotNET10 || dotNET11)
                    gen.Emit(OpCodes.Unbox_Any, method.ReturnType);
#else
                    gen.Emit(OpCodes.Unbox, method.ReturnType);
                    gen.Emit(OpCodes.Ldobj, method.ReturnType);
#endif
                }
                else {
                    gen.Emit(OpCodes.Castclass, method.ReturnType);
                }
                gen.Emit(OpCodes.Stloc_S, retval);
                gen.Emit(OpCodes.Ldloc_S, retval);
            }
            gen.Emit(OpCodes.Ret);

            if (!createPublic) {
                typeBuilder.DefineMethodOverride(b, method);
            }

            return b;
        }

        private static int Register(MethodInfo method) {
            int index = methodsTable.IndexOf(method);
            if (index < 0) {
                methodsTable.Add(method);
                index = methodsTable.Count - 1;
            }
            return index;
        }

        protected static MethodInfo GetMethod(int index) {
            return (MethodInfo)methodsTable[index];
        }

        private struct ProxyKey {
            private AppDomain domain;
            private Type[] interfaces;

            public ProxyKey(AppDomain domain, Type[] interfaces) {
                this.domain = domain;
                this.interfaces = interfaces;
            }

            public static bool operator ==(ProxyKey p1, ProxyKey p2) {
                if (!p1.domain.Equals(p2.domain))
                    return false;
                if (p1.interfaces.Length != p2.interfaces.Length)
                    return false;
                for (int i = 0; i < p1.interfaces.Length; i++)
                    if (!p1.interfaces[i].Equals(p2.interfaces[i]))
                        return false;
                return true;
            }

            public static bool operator !=(ProxyKey p1, ProxyKey p2) {
                return !(p1 == p2);
            }

            public override bool Equals(object obj) {
                if (!(obj is ProxyKey))
                    return false;

                return this == (ProxyKey)obj;
            }

            public override int GetHashCode() {
                int hash = domain.GetHashCode();
                foreach (Type type in interfaces)
                    hash = hash * 31 + type.GetHashCode();
                return hash;
            }
        }
    }
}
#endif