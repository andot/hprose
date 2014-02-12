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
 * CtorAccessor.cs                                        *
 *                                                        *
 * CtorAccessor class for C#.                             *
 *                                                        *
 * LastModified: Nov 6, 2012                              *
 * Authors: Ma Bingyao <andot@hprose.com>                 *
 *                                                        *
\**********************************************************/

#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Reflection;
using System.Reflection.Emit;
using System.Threading;

namespace Hprose.Reflection {
    public class CtorAccessor {
        private delegate object NewInstanceDelegate();
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
        private static readonly Type[] zeroTypeArray = new Type[0];
        private static readonly ParameterModifier[] zeroParameterModifierArray = new ParameterModifier[0];
        private static readonly Type typeofNewInstanceDelegate = typeof(NewInstanceDelegate);
        NewInstanceDelegate newInstanceDelegate;
#if (dotNET35 || dotNET4)
        private static readonly ReaderWriterLockSlim ctorAccessorsCacheLock = new ReaderWriterLockSlim();
#else
        private static readonly ReaderWriterLock ctorAccessorsCacheLock = new ReaderWriterLock();
#endif
        private static readonly Dictionary<Type, CtorAccessor> ctorAccessorsCache = new Dictionary<Type, CtorAccessor>();

        private class ConstructorComparator : IComparer<ConstructorInfo> {
            public int Compare(ConstructorInfo x, ConstructorInfo y) {
                return x.GetParameters().Length - y.GetParameters().Length;
            }
        }
        private CtorAccessor(Type type) {
            if (type.IsValueType) {
                DynamicMethod dynamicNewInstance = new DynamicMethod("$NewInstance",
                    typeofObject,
                    zeroTypeArray,
                    type,
                    true);
                ILGenerator newInstanceGen = dynamicNewInstance.GetILGenerator();
                LocalBuilder v = newInstanceGen.DeclareLocal(type);
                newInstanceGen.Emit(OpCodes.Ldloca_S, v);
                newInstanceGen.Emit(OpCodes.Initobj, type);
                newInstanceGen.Emit(OpCodes.Ldloc_S, v);
                newInstanceGen.Emit(OpCodes.Box, type);
                newInstanceGen.Emit(OpCodes.Ret);
                newInstanceDelegate = (NewInstanceDelegate)dynamicNewInstance.CreateDelegate(typeofNewInstanceDelegate);
                return;
            }
            BindingFlags bindingflags = BindingFlags.Instance |
                            BindingFlags.Public |
                            BindingFlags.NonPublic |
                            BindingFlags.FlattenHierarchy;
            ConstructorInfo ctor = type.GetConstructor(bindingflags, null, zeroTypeArray, zeroParameterModifierArray);
            if (ctor != null) {
                DynamicMethod dynamicNewInstance = new DynamicMethod("$NewInstance",
                    typeofObject,
                    zeroTypeArray,
                    type,
                    true);
                ILGenerator newInstanceGen = dynamicNewInstance.GetILGenerator();
                newInstanceGen.Emit(OpCodes.Newobj, ctor);
                newInstanceGen.Emit(OpCodes.Ret);
                newInstanceDelegate = (NewInstanceDelegate)dynamicNewInstance.CreateDelegate(typeofNewInstanceDelegate);
            }
            else {
                ConstructorInfo[] ctors = type.GetConstructors(bindingflags);
                Array.Sort(ctors, 0, ctors.Length, new ConstructorComparator());
                for (int i = 0, length = ctors.Length; i < length; i++) {
                    try {
                        DynamicMethod dynamicNewInstance = new DynamicMethod("$NewInstance",
                            typeofObject,
                            zeroTypeArray,
                            type,
                            true);
                        ParameterInfo[] pi = ctors[i].GetParameters();
                        int piLength = pi.Length;
                        ILGenerator newInstanceGen = dynamicNewInstance.GetILGenerator();
                        for (int j = 0; j < piLength; j++) {
                            Type parameterType = pi[j].ParameterType;
                            if (parameterType == typeofInt8 ||
                                parameterType == typeofBoolean ||
                                parameterType == typeofUInt8 ||
                                parameterType == typeofInt16 ||
                                parameterType == typeofUInt16 ||
                                parameterType == typeofChar ||
                                parameterType == typeofInt32 ||
                                parameterType == typeofUInt32) {
                                newInstanceGen.Emit(OpCodes.Ldc_I4_0);
                            }
                            else if (parameterType == typeofInt64 ||
                                     parameterType == typeofUInt64) {
                                newInstanceGen.Emit(OpCodes.Ldc_I8, (long)0);
                            }
                            else if (parameterType == typeofSingle) {
                                newInstanceGen.Emit(OpCodes.Ldc_R4, (float)0);
                            }
                            else if (parameterType == typeofDouble) {
                                newInstanceGen.Emit(OpCodes.Ldc_R8, (double)0);
                            }
                            else if (parameterType.IsValueType) {
                                LocalBuilder v = newInstanceGen.DeclareLocal(parameterType);
                                newInstanceGen.Emit(OpCodes.Ldloca_S, v);
                                newInstanceGen.Emit(OpCodes.Initobj, parameterType);
                                newInstanceGen.Emit(OpCodes.Ldloc_S, v);
                            }
                            else {
                                newInstanceGen.Emit(OpCodes.Ldnull);
                            }
                        }
                        newInstanceGen.Emit(OpCodes.Newobj, ctors[i]);
                        if (type.IsValueType) {
                            newInstanceGen.Emit(OpCodes.Box, type);
                        }
                        newInstanceGen.Emit(OpCodes.Ret);
                        newInstanceDelegate = (NewInstanceDelegate)dynamicNewInstance.CreateDelegate(typeofNewInstanceDelegate);
                        newInstanceDelegate();
                        break;
                    }
                    catch (Exception e) {
                        Console.WriteLine(e);
                        newInstanceDelegate = null;
                    }
                }
            }
            if (newInstanceDelegate == null)
                throw new NotSupportedException();
        }
        public static CtorAccessor Get(Type type) {
            CtorAccessor ctorAccessor = null;
            try {
#if (dotNET35 || dotNET4)
                ctorAccessorsCacheLock.EnterReadLock();
#else
                ctorAccessorsCacheLock.AcquireReaderLock(-1);
#endif
                if (ctorAccessorsCache.TryGetValue(type, out ctorAccessor)) {
                    return ctorAccessor;
                }
            }
            finally {
#if (dotNET35 || dotNET4)
                ctorAccessorsCacheLock.ExitReadLock();
#else
                ctorAccessorsCacheLock.ReleaseReaderLock();
#endif
            }
            try {
#if (dotNET35 || dotNET4)
                ctorAccessorsCacheLock.EnterWriteLock();
#else
                ctorAccessorsCacheLock.AcquireWriterLock(-1);
#endif
                if (ctorAccessorsCache.TryGetValue(type, out ctorAccessor)) {
                    return ctorAccessor;
                }
                ctorAccessor = new CtorAccessor(type);
                ctorAccessorsCache[type] = ctorAccessor;
            }
            finally {
#if (dotNET35 || dotNET4)
                ctorAccessorsCacheLock.ExitWriteLock();
#else
                ctorAccessorsCacheLock.ReleaseWriterLock();
#endif
            }
            return ctorAccessor;
        }
        public object NewInstance() {
            return newInstanceDelegate();
        }
    }
}
#endif