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
 * HproseHelper.cs                                        *
 *                                                        *
 * hprose helper class for C#.                            *
 *                                                        *
 * LastModified: May 31, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.IO;
using System.Text;
using System.Collections;
using System.Numerics;
using System.Reflection;
using System.Runtime.Serialization;
using Hprose.Common;

namespace Hprose.IO {
#if !(dotNET10 || dotNET11 || dotNETCF10)
    interface IGIListWriter {
        void WriteIList(HproseWriter writer, object list, bool checkRef);
    }
    class GIListWriter<T> : IGIListWriter {
        public void WriteIList(HproseWriter writer, object list, bool checkRef) {
            writer.WriteIList<T>((IList<T>) list, checkRef);
        }
    }
    interface IGICollectionWriter {
        void WriteICollection(HproseWriter writer, object collection, bool checkRef);
    }
    class GICollectionWriter<T> : IGICollectionWriter {
        public void WriteICollection(HproseWriter writer, object collection, bool checkRef) {
            writer.WriteICollection<T>((ICollection<T>) collection, checkRef);
        }
    }
    interface IGIMapWriter {
        void WriteIMap(HproseWriter writer, object map, bool checkRef);
    }
    class GIMapWriter<TKey, TValue> : IGIMapWriter {
        public void WriteIMap(HproseWriter writer, object map, bool checkRef) {
            writer.WriteIMap<TKey, TValue>((IDictionary<TKey, TValue>) map, checkRef);
        }
    }
    interface IGListReader {
        object ReadList(HproseReader reader, int count);
    }
    class GListReader<T> : IGListReader {
        public object ReadList(HproseReader reader, int count) {
            return reader.ReadList<T>(count);
        }
    }
    interface IGIListReader {
        object ReadIList(HproseReader reader, Type type, int count);
    }
    class GIListReader<T> : IGIListReader {
        public object ReadIList(HproseReader reader, Type type, int count) {
            return reader.ReadIList<T>(type, count);
        }
    }
    interface IGICollectionReader {
        object ReadICollection(HproseReader reader, Type type, int count);
    }
    class GICollectionReader<T> : IGICollectionReader {
        public object ReadICollection(HproseReader reader, Type type, int count) {
            return reader.ReadICollection<T>(type, count);
        }
    }
    interface IGMapReader {
        object ReadMap(HproseReader reader, int count);
    }
    class GMapReader<TKey, TValue> : IGMapReader {
        public object ReadMap(HproseReader reader, int count) {
            return reader.ReadMap<TKey, TValue>(count);
        }
    }
    interface IGIMapReader {
        object ReadIMap(HproseReader reader, Type type, int count);
    }
    class GIMapReader<TKey, TValue> : IGIMapReader {
        public object ReadIMap(HproseReader reader, Type type, int count) {
            return reader.ReadIMap<TKey, TValue>(type, count);
        }
    }
#endif
    public sealed class HproseHelper {
        public static readonly Type typeofArrayList = typeof(ArrayList);
        public static readonly Type typeofBoolean = typeof(Boolean);
        public static readonly Type typeofBooleanArray = typeof(Boolean[]);
        public static readonly Type typeofBigInteger = typeof(BigInteger);
        public static readonly Type typeofBigIntegerArray = typeof(BigInteger[]);
        public static readonly Type typeofBitArray = typeof(BitArray);
        public static readonly Type typeofByte = typeof(Byte);
        public static readonly Type typeofByteArray = typeof(Byte[]);
        public static readonly Type typeofBytesArray = typeof(Byte[][]);
        public static readonly Type typeofChar = typeof(Char);
        public static readonly Type typeofCharArray = typeof(Char[]);
        public static readonly Type typeofCharsArray = typeof(Char[][]);
        public static readonly Type typeofDateTime = typeof(DateTime);
        public static readonly Type typeofDateTimeArray = typeof(DateTime[]);
        public static readonly Type typeofDBNull = typeof(DBNull);
        public static readonly Type typeofDecimal = typeof(Decimal);
        public static readonly Type typeofDecimalArray = typeof(Decimal[]);
        public static readonly Type typeofDouble = typeof(Double);
        public static readonly Type typeofDoubleArray = typeof(Double[]);
        public static readonly Type typeofGuid = typeof(Guid);
        public static readonly Type typeofHashMap = typeof(HashMap);
        public static readonly Type typeofHashtable = typeof(Hashtable);
        public static readonly Type typeofICollection = typeof(ICollection);
        public static readonly Type typeofIDictionary = typeof(IDictionary);
        public static readonly Type typeofIList = typeof(IList);
        public static readonly Type typeofInt16 = typeof(Int16);
        public static readonly Type typeofInt16Array = typeof(Int16[]);
        public static readonly Type typeofInt32 = typeof(Int32);
        public static readonly Type typeofInt32Array = typeof(Int32[]);
        public static readonly Type typeofInt64 = typeof(Int64);
        public static readonly Type typeofInt64Array = typeof(Int64[]);
        public static readonly Type typeofISerializable = typeof(ISerializable);
        public static readonly Type typeofMemoryStream = typeof(MemoryStream);
        public static readonly Type typeofObject = typeof(Object);
        public static readonly Type typeofObjectArray = typeof(Object[]);
        public static readonly Type typeofQueue = typeof(Queue);
        public static readonly Type typeofSByte = typeof(SByte);
        public static readonly Type typeofSByteArray = typeof(SByte[]);
        public static readonly Type typeofSingle = typeof(Single);
        public static readonly Type typeofSingleArray = typeof(Single[]);
        public static readonly Type typeofStack = typeof(Stack);
        public static readonly Type typeofStream = typeof(Stream);
        public static readonly Type typeofString = typeof(String);
        public static readonly Type typeofStringArray = typeof(String[]);
        public static readonly Type typeofStringBuilder = typeof(StringBuilder);
        public static readonly Type typeofStringBuilderArray = typeof(StringBuilder[]);
        public static readonly Type typeofTimeSpan = typeof(TimeSpan);
        public static readonly Type typeofTimeSpanArray = typeof(TimeSpan[]);
        public static readonly Type typeofUInt16 = typeof(UInt16);
        public static readonly Type typeofUInt16Array = typeof(UInt16[]);
        public static readonly Type typeofUInt32 = typeof(UInt32);
        public static readonly Type typeofUInt32Array = typeof(UInt32[]);
        public static readonly Type typeofUInt64 = typeof(UInt64);
        public static readonly Type typeofUInt64Array = typeof(UInt64[]);
#if !(dotNET10 || dotNET11 || dotNETCF10)
        public static readonly Type typeofDictionary = typeof(Dictionary<,>);
        public static readonly Type typeofList = typeof(List<>);
        public static readonly Type typeofGICollection = typeof(ICollection<>);
        public static readonly Type typeofGIDictionary = typeof(IDictionary<,>);
        public static readonly Type typeofGIList = typeof(IList<>);
#endif
#if (dotNET35 || dotNET4)
        public static readonly Type typeofDataContract = typeof(DataContractAttribute);
        public static readonly Type typeofDataMember = typeof(DataMemberAttribute);
#endif
        public static readonly Encoding UTF8 = new UTF8Encoding(false, false);

#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static readonly Dictionary<Type, Dictionary<string, MemberInfo>> fieldsCache = new Dictionary<Type, Dictionary<string, MemberInfo>>();
        private static readonly Dictionary<Type, Dictionary<string, MemberInfo>> propertiesCache = new Dictionary<Type, Dictionary<string, MemberInfo>>();
        private static readonly Dictionary<Type, Dictionary<string, MemberInfo>> membersCache = new Dictionary<Type, Dictionary<string, MemberInfo>>();
        private static readonly Dictionary<Type, ConstructorInfo> ctorCache = new Dictionary<Type, ConstructorInfo>();
        private static readonly Dictionary<ConstructorInfo, object[]> argsCache = new Dictionary<ConstructorInfo, object[]>();
        private static readonly Dictionary<Type, IGIListWriter> gIListWriterCache = new Dictionary<Type, IGIListWriter>();
        private static readonly Dictionary<Type, IGICollectionWriter> gICollectionWriterCache = new Dictionary<Type, IGICollectionWriter>();
        private static readonly Dictionary<Type, IGIMapWriter> gIMapWriterCache = new Dictionary<Type, IGIMapWriter>();
        private static readonly Dictionary<Type, IGListReader> gListReaderCache = new Dictionary<Type, IGListReader>();
        private static readonly Dictionary<Type, IGIListReader> gIListReaderCache = new Dictionary<Type, IGIListReader>();
        private static readonly Dictionary<Type, IGICollectionReader> gICollectionReaderCache = new Dictionary<Type, IGICollectionReader>();
        private static readonly Dictionary<Type, IGMapReader> gMapReaderCache = new Dictionary<Type, IGMapReader>();
        private static readonly Dictionary<Type, IGIMapReader> gIMapReaderCache = new Dictionary<Type, IGIMapReader>();
#else
        private static readonly Hashtable fieldsCache = new Hashtable();
        private static readonly Hashtable propertiesCache = new Hashtable();
        private static readonly Hashtable membersCache = new Hashtable();
        private static readonly Hashtable ctorCache = new Hashtable();
        private static readonly Hashtable argsCache = new Hashtable();
#if !MONO
        private static readonly CaseInsensitiveHashCodeProvider caseInsensitiveHashCodeProvider = new CaseInsensitiveHashCodeProvider();
        private static readonly CaseInsensitiveComparer caseInsensitiveComparer = new CaseInsensitiveComparer();
#endif
#endif

#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT)
        private static readonly Assembly[] assemblies = new Assembly[] {
            Assembly.GetCallingAssembly(),
            Assembly.GetExecutingAssembly()
        };
#else
        private static readonly Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
#endif

        public static bool IsSerializable(Type type) {
            const TypeAttributes sa = TypeAttributes.Serializable;
            return (type.Attributes & sa) == sa;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static Dictionary<string, MemberInfo> GetMembersWithoutCache(Type type) {
#else
        internal static Hashtable GetMembersWithoutCache(Type type) {
#endif
#if (dotNET35 || dotNET4)
            if (type.IsDefined(typeofDataContract, false)) {
                return GetDataMembersWithoutCache(type);
            }
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> members = new Dictionary<string, MemberInfo>(StringComparer.OrdinalIgnoreCase);
#elif MONO
            Hashtable members = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
            Hashtable members = new Hashtable(caseInsensitiveHashCodeProvider, caseInsensitiveComparer);
#endif
            BindingFlags bindingflags = BindingFlags.Public |
                                        BindingFlags.Instance;
            PropertyInfo[] piarray = type.GetProperties(bindingflags);
            foreach (PropertyInfo pi in piarray) {
                string name;
                if (pi.CanRead && pi.CanWrite &&
                    pi.GetIndexParameters().GetLength(0) == 0 &&
                    !members.ContainsKey(name = pi.Name)) {
                    name = char.ToLower(name[0]) + name.Substring(1);
                    members[name] = pi;
                }
            }
            FieldInfo[] fiarray = type.GetFields(bindingflags);
            foreach (FieldInfo fi in fiarray) {
                string name;
                if (!members.ContainsKey(name = fi.Name)) {
                    members[name] = fi;
                }
            }
            return members;
        }

#if (dotNET35 || dotNET4)
        internal static Dictionary<string, MemberInfo> GetDataMembersWithoutCache(Type type) {
            Dictionary<string, MemberInfo> members = new Dictionary<string, MemberInfo>(StringComparer.OrdinalIgnoreCase);
            BindingFlags bindingflags = BindingFlags.Public |
                                        BindingFlags.NonPublic |
                                        BindingFlags.Instance;
            PropertyInfo[] piarray = type.GetProperties(bindingflags);
            foreach (PropertyInfo pi in piarray) {
                string name;
                if (pi.IsDefined(typeofDataMember, false) &&
                    pi.CanRead && pi.CanWrite &&
                    pi.GetIndexParameters().GetLength(0) == 0 &&
                    !members.ContainsKey(name = pi.Name)) {
                    name = char.ToLower(name[0]) + name.Substring(1);
                    members[name] = pi;
                }
            }
            FieldInfo[] fiarray = type.GetFields(bindingflags);
            foreach (FieldInfo fi in fiarray) {
                string name;
                if (fi.IsDefined(typeofDataMember, false) &&
                    !members.ContainsKey(name = fi.Name)) {
                    members[name] = fi;
                }
            }
            return members;
        }
#endif

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public static Dictionary<string, MemberInfo> GetMembers(Type type) {
#else
        public static Hashtable GetMembers(Type type) {
#endif
            ICollection pc = membersCache;
            lock (pc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> result;
                if (membersCache.TryGetValue(type, out result)) {
                    return result;
#else
                if (membersCache.ContainsKey(type)) {
                    return (Hashtable)membersCache[type];
#endif
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> members;
#else
            Hashtable members;
#endif
            members = GetMembersWithoutCache(type);
            lock (pc.SyncRoot) {
                membersCache[type] = members;
            }
            return members;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static Dictionary<string, MemberInfo> GetPropertiesWithoutCache(Type type) {
#else
        internal static Hashtable GetPropertiesWithoutCache(Type type) {
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> properties = new Dictionary<string, MemberInfo>(StringComparer.OrdinalIgnoreCase);
#elif MONO
            Hashtable properties = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
            Hashtable properties = new Hashtable(caseInsensitiveHashCodeProvider, caseInsensitiveComparer);
#endif
            BindingFlags bindingflags = BindingFlags.Public |
                                        BindingFlags.NonPublic |
                                        BindingFlags.Instance;
            if (IsSerializable(type)) {
                PropertyInfo[] piarray = type.GetProperties(bindingflags);
                foreach (PropertyInfo pi in piarray) {
                    string name;
                    if (pi.CanRead &&
                        pi.CanWrite &&
                        pi.GetIndexParameters().GetLength(0) == 0 &&
                        !properties.ContainsKey(name = pi.Name)) {
                        name = char.ToLower(name[0]) + name.Substring(1);
                        properties[name] = pi;
                    }
                }
            }
            return properties;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public static Dictionary<string, MemberInfo> GetProperties(Type type) {
#else
        public static Hashtable GetProperties(Type type) {
#endif
            ICollection pc = propertiesCache;
            lock (pc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> result;
                if (propertiesCache.TryGetValue(type, out result)) {
                    return result;
#else
                if (propertiesCache.ContainsKey(type)) {
                    return (Hashtable)propertiesCache[type];
#endif
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> properties;
#else
            Hashtable properties;
#endif
            properties = GetPropertiesWithoutCache(type);
            lock (pc.SyncRoot) {
                propertiesCache[type] = properties;
            }
            return properties;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public static Dictionary<string, MemberInfo> GetFieldsWithoutCache(Type type) {
#else
        public static Hashtable GetFieldsWithoutCache(Type type) {
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> fields = new Dictionary<string, MemberInfo>(StringComparer.OrdinalIgnoreCase);
#elif MONO
            Hashtable fields = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
            Hashtable fields = new Hashtable(caseInsensitiveHashCodeProvider, caseInsensitiveComparer);
#endif
            BindingFlags bindingflags = BindingFlags.Public |
                                        BindingFlags.NonPublic |
                                        BindingFlags.Instance;
            while (type != typeofObject && IsSerializable(type)) {
                FieldInfo[] fiarray = type.GetFields(bindingflags);
                foreach (FieldInfo fi in fiarray) {
                    string name;
                    if (!fi.IsNotSerialized &&
                        !fields.ContainsKey(name = fi.Name)) {
                        fields[name] = fi;
                    }
                }
                type = type.BaseType;
            }
            return fields;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public static Dictionary<string, MemberInfo> GetFields(Type type) {
#else
        public static Hashtable GetFields(Type type) {
#endif
            ICollection fc = fieldsCache;
            lock (fc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> result;
                if (fieldsCache.TryGetValue(type, out result)) {
                    return result;
#else
                if (fieldsCache.ContainsKey(type)) {
                    return (Hashtable)fieldsCache[type];
#endif
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> fields;
#else
            Hashtable fields;
#endif
            fields = GetFieldsWithoutCache(type);
            lock (fc.SyncRoot) {
                fieldsCache[type] = fields;
            }
            return fields;
        }

        public static string GetClassName(Type type) {
            string className = ClassManager.GetClassAlias(type);
            if (className == null) {
                className = type.FullName.Replace('.', '_').Replace('+', '_');
                int index = className.IndexOf('`');
                if (index > 0) {
                    className = className.Substring(0, index);
                }
                ClassManager.Register(type, className);
            }
            return className;
        }

        private static Type GetType(String name) {
            Type type = null;
            for (int i = assemblies.Length - 1; type == null && i >= 0; i--) {
                type = assemblies[i].GetType(name, false);
            }
            return type;
        }
#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static Type GetNestedType(StringBuilder name, List<int> positions, int i, char c) {
#else
        private static Type GetNestedType(StringBuilder name, ArrayList positions, int i, char c) {
#endif
            int length = positions.Count;
            Type type;
            if (i < length) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                name[positions[i++]] = c;
#else
                name[(int)positions[i++]] = c;
#endif
                type = GetNestedType(name, positions, i, '_');
                if (i < length && type == null) {
                    type = GetNestedType(name, positions, i, '+');
                }
            }
            else {
                type = GetType(name.ToString());
            }
            return type;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static Type GetType(StringBuilder name, List<int> positions, int i, char c) {
#else
        private static Type GetType(StringBuilder name, ArrayList positions, int i, char c) {
#endif
            int length = positions.Count;
            Type type;
            if (i < length) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                name[positions[i++]] = c;
#else
                name[(int)positions[i++]] = c;
#endif
                type = GetType(name, positions, i, '.');
                if (i < length) {
                    if (type == null) {
                        type = GetType(name, positions, i, '_');
                    }
                    if (type == null) {
                        type = GetNestedType(name, positions, i, '+');
                    }
                }
            }
            else {
                type = GetType(name.ToString());
            }
            return type;
        }

        public static Type GetClass(string className) {
            if (ClassManager.ContainsClass(className)) {
                return ClassManager.GetClass(className);
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            List<int> positions = new List<int>();
#else
            ArrayList positions = new ArrayList();
#endif
            int pos = className.IndexOf('_');
            while (pos > -1) {
                positions.Add(pos);
                pos = className.IndexOf('_', pos + 1);
            }
            Type type;
            if (positions.Count > 0) {
                StringBuilder name = new StringBuilder(className);
                type = GetType(name, positions, 0, '.');
                if (type == null) {
                    type = GetType(name, positions, 0, '_');
                }
                if (type == null) {
                    type = GetNestedType(name, positions, 0, '+');
                }
            }
            else {
                type = GetType(className.ToString());
            }
            ClassManager.Register(type, className);
            return type;
        }

        private static object[] GetArgs(ConstructorInfo ctor) {
            ICollection ac = argsCache;
            lock (ac.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                object[] result;
                if (argsCache.TryGetValue(ctor, out result)) {
                    return result;
#else
                if (argsCache.ContainsKey(ctor)) {
                    return (object[])argsCache[ctor];
#endif
                }
            }
            ParameterInfo[] piarray = ctor.GetParameters();
            int length = piarray.Length;
            object[] args = new Object[length];
            for (int i = 0; i < length; i++) {
                Type type = piarray[i].ParameterType;
                if (type == typeofByte) {
                    args[i] = (byte)0;
                }
                else if (type == typeofSByte) {
                    args[i] = (sbyte)0;
                }
                else if (type == typeofInt16) {
                    args[i] = (short)0;
                }
                else if (type == typeofUInt16) {
                    args[i] = (ushort)0;
                }
                else if (type == typeofInt32) {
                    args[i] = (int)0;
                }
                else if (type == typeofUInt32) {
                    args[i] = (uint)0;
                }
                else if (type == typeofInt64) {
                    args[i] = (long)0;
                }
                else if (type == typeofUInt64) {
                    args[i] = (ulong)0;
                }
                else if (type == typeofSingle) {
                    args[i] = (float)0;
                }
                else if (type == typeofDouble) {
                    args[i] = (double)0;
                }
                else if (type == typeofDecimal) {
                    args[i] = (decimal)0;
                }
                else if (type == typeofBoolean) {
                    args[i] = false;
                }
                else if (type == typeofChar) {
                    args[i] = (char)0;
                }
                else if (type == typeofString) {
                    args[i] = "";
                }
                else {
                    args[i] = null;
                }
            }
            lock (ac.SyncRoot) {
                argsCache[ctor] = args;
            }
            return args;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        private class ConstructorComparator : IComparer<ConstructorInfo> {
            public int Compare(ConstructorInfo x, ConstructorInfo y) {
                return x.GetParameters().Length - y.GetParameters().Length;
            }
        }
#else
        private class ConstructorComparator : IComparer {
            public int Compare(object x, object y) {
                return ((ConstructorInfo)x).GetParameters().Length - ((ConstructorInfo)y).GetParameters().Length;
            }
        }
#endif
        public static object NewInstance(Type type) {
            ConstructorInfo ctor = null;
            bool ctorCached = false;
            ICollection cc = ctorCache;
            lock (cc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                if (ctorCache.TryGetValue(type, out ctor)) {
#else
                if (ctorCache.ContainsKey(type)) {
                    ctor = (ConstructorInfo)ctorCache[type];
#endif
                    ctorCached = true;
                }
            }
            try {
                if (ctor != null) {
                    return ctor.Invoke(GetArgs(ctor));
                }
                else {
                    if (!ctorCached) {
                        BindingFlags bindingflags = BindingFlags.Instance |
                                                    BindingFlags.Public |
                                                    BindingFlags.NonPublic |
                                                    BindingFlags.FlattenHierarchy;
                        ConstructorInfo[] ctors = type.GetConstructors(bindingflags);
                        Array.Sort(ctors, 0, ctors.Length, new ConstructorComparator());
                        for (int i = 0, length = ctors.Length; i < length; i++) {
                            try {
                                object obj = ctors[i].Invoke(GetArgs(ctors[i]));
                                lock (cc.SyncRoot) {
                                    ctorCache[type] = ctors[i];
                                }
                                return obj;
                            }
                            catch { }
                        }
                        lock (cc.SyncRoot) {
                            ctorCache[type] = null;
                        }
                    }
                    return Activator.CreateInstance(type);
                }
            }
            catch {
                return null;
            }
        }
        internal static bool IsInstantiableClass(Type type) {
            return !type.IsInterface && !type.IsAbstract;
        }
#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static IGIListWriter GetIGIListWriter(Type type) {
            ICollection cache = gIListWriterCache;
            IGIListWriter listWriter = null;
            lock (cache.SyncRoot) {
                if (gIListWriterCache.TryGetValue(type, out listWriter)) {
                    return listWriter;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 1 &&
                IsInstantiableClass(type) &&
                typeofGIList.MakeGenericType(args).IsAssignableFrom(type)) {
                listWriter = Activator.CreateInstance(typeof(GIListWriter<>).MakeGenericType(args)) as IGIListWriter;
            }
            lock (cache.SyncRoot) {
                gIListWriterCache[type] = listWriter;
            }
            return listWriter;
        }
        internal static IGICollectionWriter GetIGICollectionWriter(Type type) {
            ICollection cache = gICollectionWriterCache;
            IGICollectionWriter collectionWriter = null;
            lock (cache.SyncRoot) {
                if (gICollectionWriterCache.TryGetValue(type, out collectionWriter)) {
                    return collectionWriter;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 1 &&
                IsInstantiableClass(type) &&
                typeofGICollection.MakeGenericType(args).IsAssignableFrom(type)) {
                collectionWriter = Activator.CreateInstance(typeof(GICollectionWriter<>).MakeGenericType(args)) as IGICollectionWriter;
            }
            lock (cache.SyncRoot) {
                gICollectionWriterCache[type] = collectionWriter;
            }
            return collectionWriter;
        }
        internal static IGIMapWriter GetIGIMapWriter(Type type) {
            ICollection cache = gIMapWriterCache;
            IGIMapWriter mapWriter = null;
            lock (cache.SyncRoot) {
                if (gIMapWriterCache.TryGetValue(type, out mapWriter)) {
                    return mapWriter;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 2 &&
                IsInstantiableClass(type) &&
                typeofGIDictionary.MakeGenericType(args).IsAssignableFrom(type)) {
                mapWriter = Activator.CreateInstance(typeof(GIMapWriter<,>).MakeGenericType(args)) as IGIMapWriter;
            }
            lock (cache.SyncRoot) {
                gIMapWriterCache[type] = mapWriter;
            }
            return mapWriter;
        }
        internal static IGIListReader GetIGIListReader(Type type) {
            ICollection cache = gIListReaderCache;
            IGIListReader listReader = null;
            lock (cache.SyncRoot) {
                if (gIListReaderCache.TryGetValue(type, out listReader)) {
                    return listReader;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 1 && 
                IsInstantiableClass(type) &&
                typeofGIList.MakeGenericType(args).IsAssignableFrom(type)) {
                listReader = Activator.CreateInstance(typeof(GIListReader<>).MakeGenericType(args)) as IGIListReader;
            }
            lock (cache.SyncRoot) {
                gIListReaderCache[type] = listReader;
            }
            return listReader;
        }
        internal static IGICollectionReader GetIGICollectionReader(Type type) {
            ICollection cache = gICollectionReaderCache;
            IGICollectionReader collectionReader = null;
            lock (cache.SyncRoot) {
                if (gICollectionReaderCache.TryGetValue(type, out collectionReader)) {
                    return collectionReader;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 1 && 
                IsInstantiableClass(type) &&
                typeofGICollection.MakeGenericType(args).IsAssignableFrom(type)) {
                collectionReader = Activator.CreateInstance(typeof(GICollectionReader<>).MakeGenericType(args)) as IGICollectionReader;
            }
            lock (cache.SyncRoot) {
                gICollectionReaderCache[type] = collectionReader;
            }
            return collectionReader;
        }
        internal static IGIMapReader GetIGIMapReader(Type type) {
            ICollection cache = gIMapReaderCache;
            IGIMapReader mapReader = null;
            lock (cache.SyncRoot) {
                if (gIMapReaderCache.TryGetValue(type, out mapReader)) {
                    return mapReader;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 2 && 
                IsInstantiableClass(type) &&
                typeofGIDictionary.MakeGenericType(args).IsAssignableFrom(type)) {
                mapReader = Activator.CreateInstance(typeof(GIMapReader<,>).MakeGenericType(args)) as IGIMapReader;
            }
            lock (cache.SyncRoot) {
                gIMapReaderCache[type] = mapReader;
            }
            return mapReader;
        }
        internal static IGListReader GetIGListReader(Type type) {
            ICollection cache = gListReaderCache;
            IGListReader listReader = null;
            lock (cache.SyncRoot) {
                if (gListReaderCache.TryGetValue(type, out listReader)) {
                    return listReader;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 1 &&
                (typeofList.MakeGenericType(args) == type ||
                 typeofGIList.MakeGenericType(args) == type ||
                 typeofGICollection.MakeGenericType(args) == type)) {
                listReader = Activator.CreateInstance(typeof(GListReader<>).MakeGenericType(args)) as IGListReader;
            }
            lock (cache.SyncRoot) {
                gListReaderCache[type] = listReader;
            }
            return listReader;
        }
        internal static IGMapReader GetIGMapReader(Type type) {
            ICollection cache = gMapReaderCache;
            IGMapReader mapReader = null;
            lock (cache.SyncRoot) {
                if (gMapReaderCache.TryGetValue(type, out mapReader)) {
                    return mapReader;
                }
            }
            Type[] args = type.GetGenericArguments();
            if (args.Length == 2 &&
                (typeofDictionary.MakeGenericType(args) == type ||
                 typeofGIDictionary.MakeGenericType(args) == type)) {
                mapReader = Activator.CreateInstance(typeof(GMapReader<,>).MakeGenericType(args)) as IGMapReader;
            }
            lock (cache.SyncRoot) {
                gMapReaderCache[type] = mapReader;
            }
            return mapReader;
        }
#endif
    }
}