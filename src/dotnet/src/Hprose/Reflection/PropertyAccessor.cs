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
 * PropertyAccessor.cs                                    *
 *                                                        *
 * PropertyAccessor class for C#.                         *
 *                                                        *
 * LastModified: Dec 19, 2012                             *
 * Authors: Ma Bingyao <andot@hprose.com>                 *
 *                                                        *
\**********************************************************/
#if (dotNET10 || dotNET11)
using System;
using System.Collections;
using System.Globalization;
using System.Reflection;
using System.Reflection.Emit;
using System.Threading;

namespace Hprose.Reflection {
    public abstract class PropertyAccessor {
        private static AssemblyBuilder asmBuilder;
        private static ModuleBuilder modBuilder;
        private static Type typeofVoid = typeof(void);
        private static Type typeofObject = typeof(object);
        private static Type[] oneObjectTypeArray = new Type[] { typeofObject };
        private static Type[] twoObjectTypeArray = new Type[] { typeofObject, typeofObject };
        private static Type typeofPropertyAccessor = typeof(PropertyAccessor);
        private static MethodInfo getValueMethodInfo = typeofPropertyAccessor.GetMethod("GetValue");
        private static MethodInfo setValueMethodInfo = typeofPropertyAccessor.GetMethod("SetValue");
        static PropertyAccessor() {
            AssemblyName asmName = new AssemblyName();
            asmName.Name = "$Assembly.Hprose.IO.PropertyAccessor";
            asmBuilder = AppDomain.CurrentDomain.DefineDynamicAssembly(asmName, AssemblyBuilderAccess.Run);
            modBuilder = asmBuilder.DefineDynamicModule("$Module.PropertyAccessor");
        }
        private static ReaderWriterLock propertyAccessorsCacheLock = new ReaderWriterLock();
        private static readonly Hashtable propertyAccessorsCache = new Hashtable();
        public abstract object GetValue(object obj);
        public abstract void SetValue(object obj, object value);
        public PropertyAccessor() {
        }
        public static PropertyAccessor Get(PropertyInfo propertyInfo) {
            PropertyAccessor propertyAccessor = null;
            try {
                propertyAccessorsCacheLock.AcquireReaderLock(-1);
                if (propertyAccessorsCache.ContainsKey(propertyInfo)) {
                    return (PropertyAccessor)propertyAccessorsCache[propertyInfo];
                }
            }
            finally {
                propertyAccessorsCacheLock.ReleaseReaderLock();
            }
            try {
                propertyAccessorsCacheLock.AcquireWriterLock(-1);
                if (propertyAccessorsCache.ContainsKey(propertyInfo)) {
                    return (PropertyAccessor)propertyAccessorsCache[propertyInfo];
                }
                propertyAccessor = NewInstance(propertyInfo);
                propertyAccessorsCache[propertyInfo] = propertyAccessor;
            }
            finally {
                propertyAccessorsCacheLock.ReleaseWriterLock();
            }
            return propertyAccessor;
        }
        private static PropertyAccessor NewInstance(PropertyInfo propertyInfo) {
            return (PropertyAccessor)Activator.CreateInstance(GetPropertyAccessorType(propertyInfo));
        }
        private static Type GetPropertyAccessorType(PropertyInfo propertyInfo) {
            String typeName = "$Type.PropertyAccessor$" + propertyInfo.ReflectedType.FullName + "$" + propertyInfo.Name;
            TypeBuilder typeBuilder = modBuilder.DefineType(typeName, TypeAttributes.Public, typeofPropertyAccessor);
            MethodBuilder getValueMethod = typeBuilder.DefineMethod("GetValue",
                                                                    MethodAttributes.Public |
                                                                    MethodAttributes.Virtual |
                                                                    MethodAttributes.HideBySig,
                                                                    typeofObject,
                                                                    oneObjectTypeArray);
            ILGenerator gen;
            gen = getValueMethod.GetILGenerator();
            gen.Emit(OpCodes.Ldarg_1);
            if (propertyInfo.ReflectedType.IsValueType) {
                gen.Emit(OpCodes.Unbox, propertyInfo.ReflectedType);
            }
            MethodInfo getMethod = propertyInfo.GetGetMethod(true);
            if (getMethod.IsVirtual) {
                gen.Emit(OpCodes.Callvirt, getMethod);
            }
            else {
                gen.Emit(OpCodes.Call, getMethod);
            }
            if (propertyInfo.PropertyType.IsValueType) {
                gen.Emit(OpCodes.Box, propertyInfo.PropertyType);
            }
            gen.Emit(OpCodes.Ret);
            typeBuilder.DefineMethodOverride(getValueMethod, getValueMethodInfo);
            MethodBuilder setValueMethod = typeBuilder.DefineMethod("SetValue",
                                                                    MethodAttributes.Public |
                                                                    MethodAttributes.Virtual |
                                                                    MethodAttributes.HideBySig,
                                                                    typeofVoid,
                                                                    twoObjectTypeArray);
            gen = setValueMethod.GetILGenerator();
            gen.Emit(OpCodes.Ldarg_1);
            if (propertyInfo.ReflectedType.IsValueType) {
                gen.Emit(OpCodes.Unbox, propertyInfo.ReflectedType);
            }
            gen.Emit(OpCodes.Ldarg_2);
            if (propertyInfo.PropertyType.IsValueType) {
                gen.Emit(OpCodes.Unbox, propertyInfo.PropertyType);
                gen.Emit(OpCodes.Ldobj, propertyInfo.PropertyType);
            }
            MethodInfo setMethod = propertyInfo.GetSetMethod(true);
            if (setMethod.IsVirtual) {
                gen.Emit(OpCodes.Callvirt, setMethod);
            }
            else {
                gen.Emit(OpCodes.Call, setMethod);
            }
            gen.Emit(OpCodes.Ret);
            typeBuilder.DefineMethodOverride(setValueMethod, setValueMethodInfo);
            return typeBuilder.CreateType();
        }
    }
}
#endif