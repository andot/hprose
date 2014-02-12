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
 * ObjectUnserializer.cs                                  *
 *                                                        *
 * Object Unserializer class for C#.                      *
 *                                                        *
 * LastModified: Dec 19, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;
using System.Threading;
using Hprose.Common;

namespace Hprose.IO {

    abstract class ObjectUnserializer {
        protected delegate ObjectUnserializer CreateObjectUnserializerDelegate(Type type, string[] names);
        protected static readonly Type typeofException = typeof(Exception);
        protected static ConstructorInfo hproseExceptionCtor = typeof(HproseException).GetConstructor(new Type[] { typeof(string), typeofException });
        private static readonly Type typeofVoid = typeof(void);
        private static readonly Type typeofObject = typeof(object);
        private static readonly Type[] typeofArgs = new Type[] { typeofObject, typeof(object[]) };
        private delegate void UnserializeDelegate(object result, object[] values);
        private static readonly Type typeofUnserializeDelegate = typeof(UnserializeDelegate);
        private UnserializeDelegate unserializeDelegate;
#if (dotNET35 || dotNET4)
        private static readonly ReaderWriterLockSlim unserializersCacheLock = new ReaderWriterLockSlim();
#else
        private static readonly ReaderWriterLock unserializersCacheLock = new ReaderWriterLock();
#endif
        private static readonly Dictionary<CacheKey, ObjectUnserializer> unserializersCache = new Dictionary<CacheKey, ObjectUnserializer>();

        public ObjectUnserializer(Type type, string[] names) {
            DynamicMethod dynamicMethod = new DynamicMethod("$Unserialize",
                typeofVoid,
                typeofArgs,
                type,
                true);
            InitUnserializeDelegate(type, names, dynamicMethod);
            unserializeDelegate = (UnserializeDelegate)dynamicMethod.CreateDelegate(typeofUnserializeDelegate);
        }

        protected abstract void InitUnserializeDelegate(Type type, string[] names, DynamicMethod dynamicMethod);

        protected static ObjectUnserializer Get(HproseMode mode, Type type, string[] names, CreateObjectUnserializerDelegate createObjectUnserializer) {
            CacheKey key = new CacheKey(mode, type, names);
            ObjectUnserializer unserializer = null;
            try {
#if (dotNET35 || dotNET4)
                unserializersCacheLock.EnterReadLock();
#else
                unserializersCacheLock.AcquireReaderLock(-1);
#endif
                if (unserializersCache.TryGetValue(key, out unserializer)) {
                    return unserializer;
                }
            }
            finally {
#if (dotNET35 || dotNET4)
                unserializersCacheLock.ExitReadLock();
#else
                unserializersCacheLock.ReleaseReaderLock();
#endif
            }
            try {
#if (dotNET35 || dotNET4)
                unserializersCacheLock.EnterWriteLock();
#else
                unserializersCacheLock.AcquireWriterLock(-1);
#endif
                if (unserializersCache.TryGetValue(key, out unserializer)) {
                    return unserializer;
                }
                unserializer = createObjectUnserializer(type, names);
                unserializersCache[key] = unserializer;
            }
            finally {
#if (dotNET35 || dotNET4)
                unserializersCacheLock.ExitWriteLock();
#else
                unserializersCacheLock.ReleaseWriterLock();
#endif
            }
            return unserializer;
        }

        public void Unserialize(object obj, object[] values) {
            unserializeDelegate(obj, values);
        }

        private class CacheKey {
            private HproseMode mode;
            private Type type;
            private string[] names;
            private int hash;

            public CacheKey(HproseMode mode, Type type, string[] names) {
                this.mode = mode;
                this.type = type;
                this.names = names;
            }

            public static bool operator ==(CacheKey k1, CacheKey k2) {
                if (!k1.mode.Equals(k2.mode))
                    return false;
                if (!k1.type.Equals(k2.type))
                    return false;
                if (k1.names.Length != k2.names.Length)
                    return false;
                for (int i = 0; i < k1.names.Length; i++)
                    if (!k1.names[i].Equals(k2.names[i]))
                        return false;
                return true;
            }

            public static bool operator !=(CacheKey k1, CacheKey k2) {
                return !(k1 == k2);
            }

            public override bool Equals(object obj) {
                if (!(obj is CacheKey))
                    return false;

                return this == (CacheKey)obj;
            }

            public override int GetHashCode() {
                if (hash == 0) {
                    hash = mode.GetHashCode() * 31 + type.GetHashCode();
                    foreach (string name in names)
                       hash = hash * 31 + name.GetHashCode();
                }
                return hash;
            }
        }
    }

    class ObjectFieldModeUnserializer: ObjectUnserializer {

        public ObjectFieldModeUnserializer(Type type, string[] names)
            : base(type, names) {
        }

        protected override void InitUnserializeDelegate(Type type, string[] names, DynamicMethod dynamicMethod) {
            Dictionary<string, FieldTypeInfo> fields = HproseHelper.GetFields(type);
            ILGenerator gen = dynamicMethod.GetILGenerator();
            LocalBuilder e = gen.DeclareLocal(typeofException);
            int count = names.Length;
            for (int i = 0; i < count; i++) {
                FieldTypeInfo field;
                if (fields.TryGetValue(names[i], out field)) {
                    Label exTryCatch = gen.BeginExceptionBlock();
                    if (type.IsValueType) {
                        gen.Emit(OpCodes.Ldarg_0);
                        gen.Emit(OpCodes.Unbox, type);
                    }
                    else {
                        gen.Emit(OpCodes.Ldarg_0);
                    }
                    gen.Emit(OpCodes.Ldarg_1);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldelem_Ref);
                    if (field.type.IsValueType) {
                        gen.Emit(OpCodes.Unbox_Any, field.type);
                    }
                    gen.Emit(OpCodes.Stfld, field.info);
                    gen.Emit(OpCodes.Leave_S, exTryCatch);
                    gen.BeginCatchBlock(typeofException);
                    gen.Emit(OpCodes.Stloc_S, e);
                    gen.Emit(OpCodes.Ldstr, "The field value can\'t be unserialized.");
                    gen.Emit(OpCodes.Ldloc_S, e);
                    gen.Emit(OpCodes.Newobj, hproseExceptionCtor);
                    gen.Emit(OpCodes.Throw);
                    gen.Emit(OpCodes.Leave_S, exTryCatch);
                    gen.EndExceptionBlock();
                }
            }
            gen.Emit(OpCodes.Ret);
        }

        private static ObjectUnserializer CreateObjectUnserializer(Type type, string[] names) {
            return new ObjectFieldModeUnserializer(type, names);
        }
        public static ObjectUnserializer Get(Type type, string[] names) {
            return ObjectUnserializer.Get(HproseMode.FieldMode, type, names, CreateObjectUnserializer);
        }
    }

    class ObjectPropertyModeUnserializer: ObjectUnserializer {

        public ObjectPropertyModeUnserializer(Type type, string[] names)
            : base(type, names) {
        }

        protected override void InitUnserializeDelegate(Type type, string[] names, DynamicMethod dynamicMethod) {
            Dictionary<string, PropertyTypeInfo> properties = HproseHelper.GetProperties(type);
            ILGenerator gen = dynamicMethod.GetILGenerator();
            LocalBuilder e = gen.DeclareLocal(typeofException);
            int count = names.Length;
            for (int i = 0; i < count; i++) {
                PropertyTypeInfo property;
                if (properties.TryGetValue(names[i], out property)) {
                    Label exTryCatch = gen.BeginExceptionBlock();
                    if (type.IsValueType) {
                        gen.Emit(OpCodes.Ldarg_0);
                        gen.Emit(OpCodes.Unbox, type);
                    }
                    else {
                        gen.Emit(OpCodes.Ldarg_0);
                    }
                    gen.Emit(OpCodes.Ldarg_1);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldelem_Ref);
                    if (property.type.IsValueType) {
                        gen.Emit(OpCodes.Unbox_Any, property.type);
                    }
                    MethodInfo setMethod = property.info.GetSetMethod(true);
                    if (setMethod.IsVirtual) {
                        gen.Emit(OpCodes.Callvirt, setMethod);
                    }
                    else {
                        gen.Emit(OpCodes.Call, setMethod);
                    }
                    gen.Emit(OpCodes.Leave_S, exTryCatch);
                    gen.BeginCatchBlock(typeofException);
                    gen.Emit(OpCodes.Stloc_S, e);
                    gen.Emit(OpCodes.Ldstr, "The property value can\'t be unserialized.");
                    gen.Emit(OpCodes.Ldloc_S, e);
                    gen.Emit(OpCodes.Newobj, hproseExceptionCtor);
                    gen.Emit(OpCodes.Throw);
                    gen.Emit(OpCodes.Leave_S, exTryCatch);
                    gen.EndExceptionBlock();
                }
            }
            gen.Emit(OpCodes.Ret);
        }

        private static ObjectUnserializer CreateObjectUnserializer(Type type, string[] names) {
            return new ObjectPropertyModeUnserializer(type, names);
        }
        public static ObjectUnserializer Get(Type type, string[] names) {
            return ObjectUnserializer.Get(HproseMode.PropertyMode, type, names, CreateObjectUnserializer);
        }
    }

    class ObjectMemberModeUnserializer: ObjectUnserializer {

        public ObjectMemberModeUnserializer(Type type, string[] names)
            : base(type, names) {
        }

        protected override void InitUnserializeDelegate(Type type, string[] names, DynamicMethod dynamicMethod) {
            Dictionary<string, MemberTypeInfo> members = HproseHelper.GetMembers(type);
            ILGenerator gen = dynamicMethod.GetILGenerator();
            LocalBuilder e = gen.DeclareLocal(typeofException);
            int count = names.Length;
            for (int i = 0; i < count; i++) {
                MemberTypeInfo member;
                if (members.TryGetValue(names[i], out member)) {
                    Label exTryCatch = gen.BeginExceptionBlock();
                    if (type.IsValueType) {
                        gen.Emit(OpCodes.Ldarg_0);
                        gen.Emit(OpCodes.Unbox, type);
                    }
                    else {
                        gen.Emit(OpCodes.Ldarg_0);
                    }
                    gen.Emit(OpCodes.Ldarg_1);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldelem_Ref);
                    if (member.info is FieldInfo) {
                        FieldInfo fieldInfo = (FieldInfo)member.info;
                        if (member.type.IsValueType) {
                            gen.Emit(OpCodes.Unbox_Any, member.type);
                        }
                        gen.Emit(OpCodes.Stfld, fieldInfo);
                    }
                    else {
                        PropertyInfo propertyInfo = (PropertyInfo)member.info;
                        if (member.type.IsValueType) {
                            gen.Emit(OpCodes.Unbox_Any, member.type);
                        }
                        MethodInfo setMethod = propertyInfo.GetSetMethod(true);
                        if (setMethod.IsVirtual) {
                            gen.Emit(OpCodes.Callvirt, setMethod);
                        }
                        else {
                            gen.Emit(OpCodes.Call, setMethod);
                        }
                    }
                    gen.Emit(OpCodes.Leave_S, exTryCatch);
                    gen.BeginCatchBlock(typeofException);
                    gen.Emit(OpCodes.Stloc_S, e);
                    gen.Emit(OpCodes.Ldstr, "The member value can\'t be unserialized.");
                    gen.Emit(OpCodes.Ldloc_S, e);
                    gen.Emit(OpCodes.Newobj, hproseExceptionCtor);
                    gen.Emit(OpCodes.Throw);
                    gen.Emit(OpCodes.Leave_S, exTryCatch);
                    gen.EndExceptionBlock();
                }
            }
            gen.Emit(OpCodes.Ret);
        }

        private static ObjectUnserializer CreateObjectUnserializer(Type type, string[] names) {
            return new ObjectMemberModeUnserializer(type, names);
        }
        public static ObjectUnserializer Get(Type type, string[] names) {
            return ObjectUnserializer.Get(HproseMode.FieldMode | HproseMode.PropertyMode, type, names, CreateObjectUnserializer);
        }
    }
}
#endif
