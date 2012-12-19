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
 * LastModified: Dec 19, 2012                             *
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
#if !(PocketPC || Smartphone || WindowsCE)
using System.Runtime.Serialization;
#endif
using Hprose.Common;
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
using Hprose.Reflection;
#endif

namespace Hprose.IO {
#if !(dotNET10 || dotNET11 || dotNETCF10)
    interface IGListReader {
        object ReadList(HproseReader reader);
    }
    class GListReader<T> : IGListReader {
        public object ReadList(HproseReader reader) {
            return reader.ReadList<T>();
        }
    }
    interface IGQueueReader {
        object ReadQueue(HproseReader reader);
    }
    class GQueueReader<T> : IGQueueReader {
        public object ReadQueue(HproseReader reader) {
            return reader.ReadQueue<T>();
        }
    }
    interface IGStackReader {
        object ReadStack(HproseReader reader);
    }
    class GStackReader<T> : IGStackReader {
        public object ReadStack(HproseReader reader) {
            return reader.ReadStack<T>();
        }
    }
    interface IGIListReader {
        object ReadIList(HproseReader reader, Type type);
    }
    class GIListReader<T> : IGIListReader {
        public object ReadIList(HproseReader reader, Type type) {
            return reader.ReadIList<T>(type);
        }
    }
    interface IGICollectionReader {
        object ReadICollection(HproseReader reader, Type type);
    }
    class GICollectionReader<T> : IGICollectionReader {
        public object ReadICollection(HproseReader reader, Type type) {
            return reader.ReadICollection<T>(type);
        }
    }
    interface IGDictionaryReader {
        object ReadDictionary(HproseReader reader);
    }
    class GDictionaryReader<TKey, TValue> : IGDictionaryReader {
        public object ReadDictionary(HproseReader reader) {
            return reader.ReadDictionary<TKey, TValue>();
        }
    }
    interface IGIDictionaryReader {
        object ReadIDictionary(HproseReader reader, Type type);
    }
    class GIDictionaryReader<TKey, TValue> : IGIDictionaryReader {
        public object ReadIDictionary(HproseReader reader, Type type) {
            return reader.ReadIDictionary<TKey, TValue>(type);
        }
    }
#endif
    internal struct FieldTypeInfo {
        public FieldInfo info;
        public Type type;
        public TypeEnum typeEnum;
        public FieldTypeInfo(FieldInfo field) {
            info = field;
            type = field.FieldType;
            typeEnum = HproseHelper.GetTypeEnum(type);
        }
    }
    internal struct PropertyTypeInfo {
        public PropertyInfo info;
        public Type type;
        public TypeEnum typeEnum;
        public PropertyTypeInfo(PropertyInfo property) {
            info = property;
            type = property.PropertyType;
            typeEnum = HproseHelper.GetTypeEnum(type);
        }
    }
    internal struct MemberTypeInfo {
        public MemberInfo info;
        public Type type;
        public TypeEnum typeEnum;
        public MemberTypeInfo(MemberInfo member) {
            info = member;
            type = (member is FieldInfo) ? ((FieldInfo)member).FieldType : ((PropertyInfo)member).PropertyType;
            typeEnum = HproseHelper.GetTypeEnum(type);
        }
    }
    public sealed class HproseHelper {
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
        public static readonly Type typeofArrayList = typeof(ArrayList);
        public static readonly Type typeofQueue = typeof(Queue);
        public static readonly Type typeofStack = typeof(Stack);
        public static readonly Type typeofHashMap = typeof(HashMap);
        public static readonly Type typeofHashtable = typeof(Hashtable);
#endif
#if !Core
        public static readonly Type typeofDBNull = typeof(DBNull);
#endif
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
        public static readonly Type typeofDecimal = typeof(Decimal);
        public static readonly Type typeofDecimalArray = typeof(Decimal[]);
        public static readonly Type typeofDouble = typeof(Double);
        public static readonly Type typeofDoubleArray = typeof(Double[]);
        public static readonly Type typeofGuid = typeof(Guid);
        public static readonly Type typeofGuidArray = typeof(Guid[]);
        public static readonly Type typeofICollection = typeof(ICollection);
        public static readonly Type typeofIDictionary = typeof(IDictionary);
        public static readonly Type typeofIList = typeof(IList);
        public static readonly Type typeofInt16 = typeof(Int16);
        public static readonly Type typeofInt16Array = typeof(Int16[]);
        public static readonly Type typeofInt32 = typeof(Int32);
        public static readonly Type typeofInt32Array = typeof(Int32[]);
        public static readonly Type typeofInt64 = typeof(Int64);
        public static readonly Type typeofInt64Array = typeof(Int64[]);
        public static readonly Type typeofMemoryStream = typeof(MemoryStream);
        public static readonly Type typeofObject = typeof(Object);
        public static readonly Type typeofObjectArray = typeof(Object[]);
        public static readonly Type typeofSByte = typeof(SByte);
        public static readonly Type typeofSByteArray = typeof(SByte[]);
        public static readonly Type typeofSingle = typeof(Single);
        public static readonly Type typeofSingleArray = typeof(Single[]);
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
        public static readonly Type typeofObjectList = typeof(List<Object>);
        public static readonly Type typeofBooleanList = typeof(List<Boolean>);
        public static readonly Type typeofCharList = typeof(List<Char>);
        public static readonly Type typeofSByteList = typeof(List<SByte>);
        public static readonly Type typeofByteList = typeof(List<Byte>);
        public static readonly Type typeofInt16List = typeof(List<Int16>);
        public static readonly Type typeofUInt16List = typeof(List<UInt16>);
        public static readonly Type typeofInt32List = typeof(List<Int32>);
        public static readonly Type typeofUInt32List = typeof(List<UInt32>);
        public static readonly Type typeofInt64List = typeof(List<Int64>);
        public static readonly Type typeofUInt64List = typeof(List<UInt64>);
        public static readonly Type typeofSingleList = typeof(List<Single>);
        public static readonly Type typeofDoubleList = typeof(List<Double>);
        public static readonly Type typeofDecimalList = typeof(List<Decimal>);
        public static readonly Type typeofDateTimeList = typeof(List<DateTime>);
        public static readonly Type typeofStringList = typeof(List<String>);
        public static readonly Type typeofStringBuilderList = typeof(List<StringBuilder>);
        public static readonly Type typeofGuidList = typeof(List<Guid>);
        public static readonly Type typeofBigIntegerList = typeof(List<BigInteger>);
        public static readonly Type typeofTimeSpanList = typeof(List<TimeSpan>);
        public static readonly Type typeofCharsList = typeof(List<Char[]>);
        public static readonly Type typeofBytesList = typeof(List<Byte[]>);

        public static readonly Type typeofObjectIList = typeof(IList<Object>);
        public static readonly Type typeofBooleanIList = typeof(IList<Boolean>);
        public static readonly Type typeofCharIList = typeof(IList<Char>);
        public static readonly Type typeofSByteIList = typeof(IList<SByte>);
        public static readonly Type typeofByteIList = typeof(IList<Byte>);
        public static readonly Type typeofInt16IList = typeof(IList<Int16>);
        public static readonly Type typeofUInt16IList = typeof(IList<UInt16>);
        public static readonly Type typeofInt32IList = typeof(IList<Int32>);
        public static readonly Type typeofUInt32IList = typeof(IList<UInt32>);
        public static readonly Type typeofInt64IList = typeof(IList<Int64>);
        public static readonly Type typeofUInt64IList = typeof(IList<UInt64>);
        public static readonly Type typeofSingleIList = typeof(IList<Single>);
        public static readonly Type typeofDoubleIList = typeof(IList<Double>);
        public static readonly Type typeofDecimalIList = typeof(IList<Decimal>);
        public static readonly Type typeofDateTimeIList = typeof(IList<DateTime>);
        public static readonly Type typeofStringIList = typeof(IList<String>);
        public static readonly Type typeofStringBuilderIList = typeof(IList<StringBuilder>);
        public static readonly Type typeofGuidIList = typeof(IList<Guid>);
        public static readonly Type typeofBigIntegerIList = typeof(IList<BigInteger>);
        public static readonly Type typeofTimeSpanIList = typeof(IList<TimeSpan>);
        public static readonly Type typeofCharsIList = typeof(IList<Char[]>);
        public static readonly Type typeofBytesIList = typeof(IList<Byte[]>);

        public static readonly Type typeofStringObjectHashMap = typeof(HashMap<string, object>);
        public static readonly Type typeofObjectObjectHashMap = typeof(HashMap<object, object>);
        public static readonly Type typeofIntObjectHashMap = typeof(HashMap<int, object>);
        public static readonly Type typeofStringObjectDictionary = typeof(Dictionary<string, object>);
        public static readonly Type typeofObjectObjectDictionary = typeof(Dictionary<object, object>);
        public static readonly Type typeofIntObjectDictionary = typeof(Dictionary<int, object>);

        public static readonly Type typeofDictionary = typeof(Dictionary<,>);
        public static readonly Type typeofList = typeof(List<>);
        public static readonly Type typeofGQueue = typeof(Queue<>);
        public static readonly Type typeofGStack = typeof(Stack<>);
        public static readonly Type typeofGHashMap = typeof(HashMap<,>);
        public static readonly Type typeofGICollection = typeof(ICollection<>);
        public static readonly Type typeofGIDictionary = typeof(IDictionary<,>);
        public static readonly Type typeofGIList = typeof(IList<>);
#endif

#if (dotNET35 || dotNET4 || SILVERLIGHT || WINDOWS_PHONE || Core)
        public static readonly Type typeofDataContract = typeof(DataContractAttribute);
        public static readonly Type typeofDataMember = typeof(DataMemberAttribute);
#endif
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
        public static readonly Type typeofISerializable = typeof(ISerializable);
#endif

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static readonly Dictionary<Type, TypeEnum> typeMap = new Dictionary<Type, TypeEnum>();
#else
        internal static readonly Hashtable typeMap = new Hashtable();
#endif
        static HproseHelper() {
#if !Core
            typeMap[typeofDBNull] = TypeEnum.DBNull;
#endif
            typeMap[typeofObject] = TypeEnum.Object;
            typeMap[typeofBoolean] = TypeEnum.Boolean;
            typeMap[typeofChar] = TypeEnum.Char;
            typeMap[typeofSByte] = TypeEnum.SByte;
            typeMap[typeofByte] = TypeEnum.Byte;
            typeMap[typeofInt16] = TypeEnum.Int16;
            typeMap[typeofUInt16] = TypeEnum.UInt16;
            typeMap[typeofInt32] = TypeEnum.Int32;
            typeMap[typeofUInt32] = TypeEnum.UInt32;
            typeMap[typeofInt64] = TypeEnum.Int64;
            typeMap[typeofUInt64] = TypeEnum.UInt64;
            typeMap[typeofSingle] = TypeEnum.Single;
            typeMap[typeofDouble] = TypeEnum.Double;
            typeMap[typeofDecimal] = TypeEnum.Decimal;
            typeMap[typeofDateTime] = TypeEnum.DateTime;
            typeMap[typeofString] = TypeEnum.String;
            typeMap[typeofBigInteger] = TypeEnum.BigInteger;
            typeMap[typeofGuid] = TypeEnum.Guid;
            typeMap[typeofStringBuilder] = TypeEnum.StringBuilder;
            typeMap[typeofTimeSpan] = TypeEnum.TimeSpan;

            typeMap[typeofObjectArray] = TypeEnum.ObjectArray;
            typeMap[typeofBooleanArray] = TypeEnum.BooleanArray;
            typeMap[typeofCharArray] = TypeEnum.CharArray;
            typeMap[typeofSByteArray] = TypeEnum.SByteArray;
            typeMap[typeofByteArray] = TypeEnum.ByteArray;
            typeMap[typeofInt16Array] = TypeEnum.Int16Array;
            typeMap[typeofUInt16Array] = TypeEnum.UInt16Array;
            typeMap[typeofInt32Array] = TypeEnum.Int32Array;
            typeMap[typeofUInt32Array] = TypeEnum.UInt32Array;
            typeMap[typeofInt64Array] = TypeEnum.Int64Array;
            typeMap[typeofUInt64Array] = TypeEnum.UInt64Array;
            typeMap[typeofSingleArray] = TypeEnum.SingleArray;
            typeMap[typeofDoubleArray] = TypeEnum.DoubleArray;
            typeMap[typeofDecimalArray] = TypeEnum.DecimalArray;
            typeMap[typeofDateTimeArray] = TypeEnum.DateTimeArray;
            typeMap[typeofStringArray] = TypeEnum.StringArray;
            typeMap[typeofBigIntegerArray] = TypeEnum.BigIntegerArray;
            typeMap[typeofGuidArray] = TypeEnum.GuidArray;
            typeMap[typeofStringBuilderArray] = TypeEnum.StringBuilderArray;
            typeMap[typeofTimeSpanArray] = TypeEnum.TimeSpanArray;
            typeMap[typeofBytesArray] = TypeEnum.BytesArray;
            typeMap[typeofCharsArray] = TypeEnum.CharsArray;
            typeMap[typeofMemoryStream] = TypeEnum.MemoryStream;
            typeMap[typeofStream] = TypeEnum.Stream;
            typeMap[typeofBitArray] = TypeEnum.BitArray;
            typeMap[typeofICollection] = TypeEnum.ICollection;
            typeMap[typeofIDictionary] = TypeEnum.IDictionary;
            typeMap[typeofIList] = TypeEnum.IList;
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
            typeMap[typeofArrayList] = TypeEnum.ArrayList;
            typeMap[typeofHashMap] = TypeEnum.HashMap;
            typeMap[typeofHashtable] = TypeEnum.Hashtable;
            typeMap[typeofQueue] = TypeEnum.Queue;
            typeMap[typeofStack] = TypeEnum.Stack;
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            typeMap[typeofObjectList] = TypeEnum.ObjectList;
            typeMap[typeofBooleanList] = TypeEnum.BooleanList;
            typeMap[typeofCharList] = TypeEnum.CharList;
            typeMap[typeofSByteList] = TypeEnum.SByteList;
            typeMap[typeofByteList] = TypeEnum.ByteList;
            typeMap[typeofInt16List] = TypeEnum.Int16List;
            typeMap[typeofUInt16List] = TypeEnum.UInt16List;
            typeMap[typeofInt32List] = TypeEnum.Int32List;
            typeMap[typeofUInt32List] = TypeEnum.UInt32List;
            typeMap[typeofInt64List] = TypeEnum.Int64List;
            typeMap[typeofUInt64List] = TypeEnum.UInt64List;
            typeMap[typeofSingleList] = TypeEnum.SingleList;
            typeMap[typeofDoubleList] = TypeEnum.DoubleList;
            typeMap[typeofDecimalList] = TypeEnum.DecimalList;
            typeMap[typeofDateTimeList] = TypeEnum.DateTimeList;
            typeMap[typeofStringList] = TypeEnum.StringList;
            typeMap[typeofBigIntegerList] = TypeEnum.BigIntegerList;
            typeMap[typeofGuidList] = TypeEnum.GuidList;
            typeMap[typeofStringBuilderList] = TypeEnum.StringBuilderList;
            typeMap[typeofTimeSpanList] = TypeEnum.TimeSpanList;
            typeMap[typeofBytesList] = TypeEnum.BytesList;
            typeMap[typeofCharsList] = TypeEnum.CharsList;

            typeMap[typeofObjectIList] = TypeEnum.ObjectIList;
            typeMap[typeofBooleanIList] = TypeEnum.BooleanIList;
            typeMap[typeofCharIList] = TypeEnum.CharIList;
            typeMap[typeofSByteIList] = TypeEnum.SByteIList;
            typeMap[typeofByteIList] = TypeEnum.ByteIList;
            typeMap[typeofInt16IList] = TypeEnum.Int16IList;
            typeMap[typeofUInt16IList] = TypeEnum.UInt16IList;
            typeMap[typeofInt32IList] = TypeEnum.Int32IList;
            typeMap[typeofUInt32IList] = TypeEnum.UInt32IList;
            typeMap[typeofInt64IList] = TypeEnum.Int64IList;
            typeMap[typeofUInt64IList] = TypeEnum.UInt64IList;
            typeMap[typeofSingleIList] = TypeEnum.SingleIList;
            typeMap[typeofDoubleIList] = TypeEnum.DoubleIList;
            typeMap[typeofDecimalIList] = TypeEnum.DecimalIList;
            typeMap[typeofDateTimeIList] = TypeEnum.DateTimeIList;
            typeMap[typeofStringIList] = TypeEnum.StringIList;
            typeMap[typeofBigIntegerIList] = TypeEnum.BigIntegerIList;
            typeMap[typeofGuidIList] = TypeEnum.GuidIList;
            typeMap[typeofStringBuilderIList] = TypeEnum.StringBuilderIList;
            typeMap[typeofTimeSpanIList] = TypeEnum.TimeSpanIList;
            typeMap[typeofBytesIList] = TypeEnum.BytesIList;
            typeMap[typeofCharsIList] = TypeEnum.CharsIList;
            
            typeMap[typeofStringObjectHashMap] = TypeEnum.StringObjectHashMap;
            typeMap[typeofObjectObjectHashMap] = TypeEnum.ObjectObjectHashMap;
            typeMap[typeofIntObjectHashMap] = TypeEnum.IntObjectHashMap;
            typeMap[typeofStringObjectDictionary] = TypeEnum.StringObjectDictionary;
            typeMap[typeofObjectObjectDictionary] = TypeEnum.ObjectObjectDictionary;
            typeMap[typeofIntObjectDictionary] = TypeEnum.IntObjectDictionary;

#endif
        }

        internal static bool IsInstantiableClass(Type type) {
#if Core
            TypeInfo typeInfo = type.GetTypeInfo();
            return !typeInfo.IsInterface && !typeInfo.IsAbstract;
#else
            return !type.IsInterface && !type.IsAbstract;
#endif
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static bool IsGenericList(Type type) {
            return (type.GetGenericTypeDefinition() == typeofList);
        }
        
        private static bool IsGenericDictionary(Type type) {
            return (type.GetGenericTypeDefinition() == typeofDictionary);
        }

        private static bool IsGenericQueue(Type type) {
            return (type.GetGenericTypeDefinition() == typeofGQueue);
        }

        private static bool IsGenericStack(Type type) {
            return (type.GetGenericTypeDefinition() == typeofGStack);
        }

        private static bool IsGenericHashMap(Type type) {
            return (type.GetGenericTypeDefinition() == typeofGHashMap);
        }

        private static bool IsGenericIList(Type type) {
#if Core
            Type[] args = type.GenericTypeArguments;
            TypeInfo typeInfo = type.GetTypeInfo();
            return (args.Length == 1 &&
                    typeofGIList.MakeGenericType(args).GetTypeInfo().IsAssignableFrom(typeInfo));
#else
            Type[] args = type.GetGenericArguments();
            return (args.Length == 1 && 
                    typeofGIList.MakeGenericType(args).IsAssignableFrom(type));
#endif
        }

        private static bool IsGenericIDictionary(Type type) {
#if Core
            Type[] args = type.GenericTypeArguments;
            TypeInfo typeInfo = type.GetTypeInfo();
            return (args.Length == 2 &&
                    typeofGIDictionary.MakeGenericType(args).GetTypeInfo().IsAssignableFrom(typeInfo));
#else
            Type[] args = type.GetGenericArguments();
            return (args.Length == 2 && 
                    typeofGIDictionary.MakeGenericType(args).IsAssignableFrom(type));
#endif
        }

        private static bool IsGenericICollection(Type type) {
#if Core
            Type[] args = type.GenericTypeArguments;
            TypeInfo typeInfo = type.GetTypeInfo();
            return (args.Length == 1 &&
                    typeofGICollection.MakeGenericType(args).GetTypeInfo().IsAssignableFrom(typeInfo));
#else
            Type[] args = type.GetGenericArguments();
            return (args.Length == 1 && 
                    typeofGICollection.MakeGenericType(args).IsAssignableFrom(type));
#endif
        }
#endif

        internal static TypeEnum GetTypeEnum(Type type) {
            if (type == null) return TypeEnum.Null;
#if !(dotNET10 || dotNET11 || dotNETCF10)
            TypeEnum t;
            if (typeMap.TryGetValue(type, out t)) return t;
#else
            Object t;
            if ((t = typeMap[type]) != null) return (TypeEnum)t;
#endif
#if Core
            TypeInfo typeInfo = type.GetTypeInfo();
            if (typeInfo.IsArray) return TypeEnum.OtherTypeArray;
            if (typeInfo.IsByRef) return GetTypeEnum(typeInfo.GetElementType());
            if (typeInfo.IsEnum) return TypeEnum.Enum;
#else
            if (type.IsArray) return TypeEnum.OtherTypeArray;
            if (type.IsByRef) return GetTypeEnum(type.GetElementType());
            if (type.IsEnum) return TypeEnum.Enum;
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
#if Core
            if (typeInfo.IsGenericType) {
#else
            if (type.IsGenericType) {
#endif
                if (IsGenericDictionary(type)) return TypeEnum.GenericDictionary;
                if (IsGenericList(type)) return TypeEnum.GenericList;
                if (IsGenericQueue(type)) return TypeEnum.GenericQueue;
                if (IsGenericStack(type)) return TypeEnum.GenericStack;
                if (IsGenericHashMap(type)) return TypeEnum.GenericHashMap;
                if (IsGenericIDictionary(type)) return TypeEnum.GenericIDictionary;
                if (IsGenericIList(type)) return TypeEnum.GenericIList;
                if (IsGenericICollection(type)) return TypeEnum.GenericICollection;            
            }
#endif
            if (IsInstantiableClass(type)) {
#if Core
                if (typeofIDictionary.GetTypeInfo().IsAssignableFrom(typeInfo)) return TypeEnum.Dictionary;
                if (typeofIList.GetTypeInfo().IsAssignableFrom(typeInfo)) return TypeEnum.List;
#else
                if (typeofIDictionary.IsAssignableFrom(type)) return TypeEnum.Dictionary;
                if (typeofIList.IsAssignableFrom(type)) return TypeEnum.List;
#endif
            }
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
            if (typeofISerializable.IsAssignableFrom(type)) return TypeEnum.UnSupportedType;
#endif
            return TypeEnum.OtherType;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static readonly Dictionary<Type, Dictionary<string, FieldTypeInfo>> fieldsCache = new Dictionary<Type, Dictionary<string, FieldTypeInfo>>();
        private static readonly Dictionary<Type, Dictionary<string, PropertyTypeInfo>> propertiesCache = new Dictionary<Type, Dictionary<string, PropertyTypeInfo>>();
        private static readonly Dictionary<Type, Dictionary<string, MemberTypeInfo>> membersCache = new Dictionary<Type, Dictionary<string, MemberTypeInfo>>();
#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
        private static readonly Dictionary<Type, ConstructorInfo> ctorCache = new Dictionary<Type, ConstructorInfo>();
        private static readonly Dictionary<ConstructorInfo, object[]> argsCache = new Dictionary<ConstructorInfo, object[]>();
#endif
        private static readonly Dictionary<Type, IGListReader> gListReaderCache = new Dictionary<Type, IGListReader>();
        private static readonly Dictionary<Type, IGQueueReader> gQueueReaderCache = new Dictionary<Type, IGQueueReader>();
        private static readonly Dictionary<Type, IGStackReader> gStackReaderCache = new Dictionary<Type, IGStackReader>();
        private static readonly Dictionary<Type, IGIListReader> gIListReaderCache = new Dictionary<Type, IGIListReader>();
        private static readonly Dictionary<Type, IGICollectionReader> gICollectionReaderCache = new Dictionary<Type, IGICollectionReader>();
        private static readonly Dictionary<Type, IGDictionaryReader> gDictionaryReaderCache = new Dictionary<Type, IGDictionaryReader>();
        private static readonly Dictionary<Type, IGIDictionaryReader> gIDictionaryReaderCache = new Dictionary<Type, IGIDictionaryReader>();
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

#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE)
        private static readonly Assembly[] assemblies = new Assembly[] {
            Assembly.GetCallingAssembly(),
            Assembly.GetExecutingAssembly()
        };
#elif !Core
        private static readonly Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
#endif

        public static bool IsSerializable(Type type) {
#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE)
            const TypeAttributes sa = TypeAttributes.Serializable;
            return (type.Attributes & sa) == sa;
#elif Core
            return type.GetTypeInfo().IsDefined(typeof(SerializableAttribute));
#else
            return type.IsSerializable;
#endif
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static Dictionary<string, MemberTypeInfo> GetMembersWithoutCache(Type type) {
#else
        private static Hashtable GetMembersWithoutCache(Type type) {
#endif
#if Core
            if (type.GetTypeInfo().IsDefined(typeofDataContract, false)) {
                return GetDataMembersWithoutCache(type);
            }
#elif (dotNET35 || dotNET4 || SILVERLIGHT || WINDOWS_PHONE)
            if (type.IsDefined(typeofDataContract, false)) {
                return GetDataMembersWithoutCache(type);
            }
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberTypeInfo> members = new Dictionary<string, MemberTypeInfo>(StringComparer.OrdinalIgnoreCase);
#elif MONO
            Hashtable members = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
            Hashtable members = new Hashtable(caseInsensitiveHashCodeProvider, caseInsensitiveComparer);
#endif
#if dotNET45
            IEnumerable<PropertyInfo> piarray = type.GetRuntimeProperties();
            foreach (PropertyInfo pi in piarray) {
                string name;
                if (pi.CanRead && pi.CanWrite &&
                    pi.GetMethod.IsPublic && !pi.GetMethod.IsStatic && !pi.SetMethod.IsStatic &&
                    pi.GetIndexParameters().GetLength(0) == 0 &&
                    !members.ContainsKey(name = pi.Name)) {
                    name = char.ToLower(name[0]) + name.Substring(1);
                    members[name] = new MemberTypeInfo(pi);
                }
            }
            IEnumerable<FieldInfo> fiarray = type.GetRuntimeFields();
            foreach (FieldInfo fi in fiarray) {
                string name;
                if (fi.IsPublic && !fi.IsStatic && !members.ContainsKey(name = fi.Name)) {
                    members[name] = new MemberTypeInfo(fi);
                }
            }
#else
            BindingFlags bindingflags = BindingFlags.Public |
                                        BindingFlags.NonPublic |
                                        BindingFlags.Instance;
            PropertyInfo[] piarray = type.GetProperties(bindingflags);
            foreach (PropertyInfo pi in piarray) {
                string name;
                if (pi.CanRead && pi.CanWrite && pi.GetGetMethod() != null &&
                    pi.GetIndexParameters().GetLength(0) == 0 &&
                    !members.ContainsKey(name = pi.Name)) {
                    name = char.ToLower(name[0]) + name.Substring(1);
                    members[name] = new MemberTypeInfo(pi);
                }
            }
            bindingflags = BindingFlags.Public | BindingFlags.Instance;
            FieldInfo[] fiarray = type.GetFields(bindingflags);
            foreach (FieldInfo fi in fiarray) {
                string name;
                if (!members.ContainsKey(name = fi.Name)) {
                    members[name] = new MemberTypeInfo(fi);
                }
            }
#endif
            return members;
        }

#if dotNET45
        private static Dictionary<string, MemberTypeInfo> GetDataMembersWithoutCache(Type type) {
            Dictionary<string, MemberTypeInfo> members = new Dictionary<string, MemberTypeInfo>(StringComparer.OrdinalIgnoreCase);
            IEnumerable<PropertyInfo> piarray = type.GetRuntimeProperties();
            foreach (PropertyInfo pi in piarray) {
                string name;
                if (pi.IsDefined(typeofDataMember, false) &&
                    pi.CanRead && pi.CanWrite &&
                    !pi.GetMethod.IsStatic && !pi.SetMethod.IsStatic &&
                    pi.GetIndexParameters().GetLength(0) == 0 &&
                    !members.ContainsKey(name = pi.Name)) {
                    name = char.ToLower(name[0]) + name.Substring(1);
                    members[name] = new MemberTypeInfo(pi);
                }
            }
            IEnumerable<FieldInfo> fiarray = type.GetRuntimeFields();
            foreach (FieldInfo fi in fiarray) {
                string name;
                if (fi.IsDefined(typeofDataMember, false) &&
                    !fi.IsStatic && !members.ContainsKey(name = fi.Name)) {
                    members[name] = new MemberTypeInfo(fi);
                }
            }
            return members;
        }
#elif (dotNET35 || dotNET4 || SILVERLIGHT || WINDOWS_PHONE)
        private static Dictionary<string, MemberTypeInfo> GetDataMembersWithoutCache(Type type) {
            Dictionary<string, MemberTypeInfo> members = new Dictionary<string, MemberTypeInfo>(StringComparer.OrdinalIgnoreCase);
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
                    members[name] = new MemberTypeInfo(pi);
                }
            }
            FieldInfo[] fiarray = type.GetFields(bindingflags);
            foreach (FieldInfo fi in fiarray) {
                string name;
                if (fi.IsDefined(typeofDataMember, false) &&
                    !members.ContainsKey(name = fi.Name)) {
                    members[name] = new MemberTypeInfo(fi);
                }
            }
            return members;
        }
#endif

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static Dictionary<string, MemberTypeInfo> GetMembers(Type type) {
#else
        internal static Hashtable GetMembers(Type type) {
#endif
            ICollection pc = membersCache;
            lock (pc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberTypeInfo> result;
                if (membersCache.TryGetValue(type, out result)) {
                    return result;
#else
                if (membersCache.ContainsKey(type)) {
                    return (Hashtable)membersCache[type];
#endif
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberTypeInfo> members;
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
        private static Dictionary<string, PropertyTypeInfo> GetPropertiesWithoutCache(Type type) {
#else
        private static Hashtable GetPropertiesWithoutCache(Type type) {
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, PropertyTypeInfo> properties = new Dictionary<string, PropertyTypeInfo>(StringComparer.OrdinalIgnoreCase);
#elif MONO
            Hashtable properties = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
            Hashtable properties = new Hashtable(caseInsensitiveHashCodeProvider, caseInsensitiveComparer);
#endif
            if (IsSerializable(type)) {
#if dotNET45
                IEnumerable<PropertyInfo> piarray = type.GetRuntimeProperties();
                foreach (PropertyInfo pi in piarray) {
                    string name;
                    if (pi.CanRead && pi.CanWrite &&
                        pi.GetMethod.IsPublic && pi.SetMethod.IsPublic &&
                        !pi.GetMethod.IsStatic && !pi.SetMethod.IsStatic &&
                        pi.GetIndexParameters().GetLength(0) == 0 &&
                        !properties.ContainsKey(name = pi.Name)) {
                        name = char.ToLower(name[0]) + name.Substring(1);
                        properties[name] = new PropertyTypeInfo(pi);
                    }
                }
#else
                BindingFlags bindingflags = BindingFlags.Public |
                                            BindingFlags.Instance;
                PropertyInfo[] piarray = type.GetProperties(bindingflags);
                foreach (PropertyInfo pi in piarray) {
                    string name;
                    if (pi.CanRead && pi.CanWrite &&
                        pi.GetIndexParameters().GetLength(0) == 0 &&
                        !properties.ContainsKey(name = pi.Name)) {
                        name = char.ToLower(name[0]) + name.Substring(1);
                        properties[name] = new PropertyTypeInfo(pi);
                    }
                }
#endif
            }
            return properties;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static Dictionary<string, PropertyTypeInfo> GetProperties(Type type) {
#else
        internal static Hashtable GetProperties(Type type) {
#endif
            ICollection pc = propertiesCache;
            lock (pc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, PropertyTypeInfo> result;
                if (propertiesCache.TryGetValue(type, out result)) {
                    return result;
#else
                Hashtable result;
                if ((result = (Hashtable)propertiesCache[type]) != null) {
                    return result;
#endif
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, PropertyTypeInfo> properties;
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
        private static Dictionary<string, FieldTypeInfo> GetFieldsWithoutCache(Type type) {
#else
        private static Hashtable GetFieldsWithoutCache(Type type) {
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, FieldTypeInfo> fields = new Dictionary<string, FieldTypeInfo>(StringComparer.OrdinalIgnoreCase);
#elif MONO
            Hashtable fields = new Hashtable(StringComparer.OrdinalIgnoreCase);
#else
            Hashtable fields = new Hashtable(caseInsensitiveHashCodeProvider, caseInsensitiveComparer);
#endif
#if dotNET45
            FieldAttributes ns = FieldAttributes.NotSerialized;
            while (type != typeofObject && IsSerializable(type)) {
                TypeInfo typeInfo = type.GetTypeInfo();
                IEnumerable<FieldInfo> fiarray = typeInfo.DeclaredFields;
                foreach (FieldInfo fi in fiarray) {
                    string name;
                    if (((fi.Attributes & ns) != ns) &&
                        !fi.IsStatic &&
                        !fields.ContainsKey(name = fi.Name)) {
                        fields[name] = new FieldTypeInfo(fi);
                    }
                }
                type = typeInfo.BaseType;
            }
#else
            BindingFlags bindingflags = BindingFlags.Public |
                                        BindingFlags.NonPublic |
                                        BindingFlags.DeclaredOnly |
                                        BindingFlags.Instance;
            while (type != typeofObject && IsSerializable(type)) {
                FieldInfo[] fiarray = type.GetFields(bindingflags);
                foreach (FieldInfo fi in fiarray) {
                    string name;
                    if (!fi.IsNotSerialized &&
                        !fields.ContainsKey(name = fi.Name)) {
                        fields[name] = new FieldTypeInfo(fi);
                    }
                }
                type = type.BaseType;
            }
#endif
            return fields;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static Dictionary<string, FieldTypeInfo> GetFields(Type type) {
#else
        internal static Hashtable GetFields(Type type) {
#endif
            ICollection fc = fieldsCache;
            lock (fc.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, FieldTypeInfo> result;
                if (fieldsCache.TryGetValue(type, out result)) {
                    return result;
#else
                Hashtable result;
                if ((result = (Hashtable)fieldsCache[type]) != null) {
                    return result;
#endif
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, FieldTypeInfo> fields;
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
#if Core
        private static Type GetType(String name) {
            try {
                return Type.GetType(name);
            }
            catch (Exception) {
                return null;
            }
        }
#else
        private static Type GetType(String name) {
            Type type = null;
            for (int i = assemblies.Length - 1; type == null && i >= 0; i--) {
                type = assemblies[i].GetType(name);
            }
            return type;
        }
#endif
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

#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
        public static object NewInstance(Type type) {
            return CtorAccessor.Get(type).NewInstance();
        }
#else
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
#if dotNET45
                        IEnumerable<ConstructorInfo> ctors = type.GetTypeInfo().DeclaredConstructors;
                        foreach (ConstructorInfo c in ctors) {
                            try {
                                object obj = c.Invoke(GetArgs(c));
                                lock (cc.SyncRoot) {
                                    ctorCache[type] = c;
                                }
                                return obj;
                            }
                            catch { }
                        }
#else
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
#endif
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
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal static IGIListReader GetIGIListReader(Type type) {
            ICollection cache = gIListReaderCache;
            IGIListReader listReader = null;
            lock (cache.SyncRoot) {
                if (gIListReaderCache.TryGetValue(type, out listReader)) {
                    return listReader;
                }
            }
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            listReader = Activator.CreateInstance(typeof(GIListReader<>).MakeGenericType(args)) as IGIListReader;
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
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            collectionReader = Activator.CreateInstance(typeof(GICollectionReader<>).MakeGenericType(args)) as IGICollectionReader;
            lock (cache.SyncRoot) {
                gICollectionReaderCache[type] = collectionReader;
            }
            return collectionReader;
        }
        
        internal static IGIDictionaryReader GetIGIDictionaryReader(Type type) {
            ICollection cache = gIDictionaryReaderCache;
            IGIDictionaryReader dictionaryReader = null;
            lock (cache.SyncRoot) {
                if (gIDictionaryReaderCache.TryGetValue(type, out dictionaryReader)) {
                    return dictionaryReader;
                }
            }
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            dictionaryReader = Activator.CreateInstance(typeof(GIDictionaryReader<,>).MakeGenericType(args)) as IGIDictionaryReader;
            lock (cache.SyncRoot) {
                gIDictionaryReaderCache[type] = dictionaryReader;
            }
            return dictionaryReader;
        }
        
        internal static IGListReader GetIGListReader(Type type) {
            ICollection cache = gListReaderCache;
            IGListReader listReader = null;
            lock (cache.SyncRoot) {
                if (gListReaderCache.TryGetValue(type, out listReader)) {
                    return listReader;
                }
            }
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            listReader = Activator.CreateInstance(typeof(GListReader<>).MakeGenericType(args)) as IGListReader;
            lock (cache.SyncRoot) {
                gListReaderCache[type] = listReader;
            }
            return listReader;
        }
        
        internal static IGDictionaryReader GetIGDictionaryReader(Type type) {
            ICollection cache = gDictionaryReaderCache;
            IGDictionaryReader dictionaryReader = null;
            lock (cache.SyncRoot) {
                if (gDictionaryReaderCache.TryGetValue(type, out dictionaryReader)) {
                    return dictionaryReader;
                }
            }
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            dictionaryReader = Activator.CreateInstance(typeof(GDictionaryReader<,>).MakeGenericType(args)) as IGDictionaryReader;
            lock (cache.SyncRoot) {
                gDictionaryReaderCache[type] = dictionaryReader;
            }
            return dictionaryReader;
        }

        internal static IGQueueReader GetIGQueueReader(Type type) {
            ICollection cache = gQueueReaderCache;
            IGQueueReader queueReader = null;
            lock (cache.SyncRoot) {
                if (gQueueReaderCache.TryGetValue(type, out queueReader)) {
                    return queueReader;
                }
            }
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            queueReader = Activator.CreateInstance(typeof(GQueueReader<>).MakeGenericType(args)) as IGQueueReader;
            lock (cache.SyncRoot) {
                gQueueReaderCache[type] = queueReader;
            }
            return queueReader;
        }


        internal static IGStackReader GetIGStackReader(Type type) {
            ICollection cache = gStackReaderCache;
            IGStackReader stackReader = null;
            lock (cache.SyncRoot) {
                if (gStackReaderCache.TryGetValue(type, out stackReader)) {
                    return stackReader;
                }
            }
#if dotNET45
            Type[] args = type.GenericTypeArguments;
#else
            Type[] args = type.GetGenericArguments();
#endif
            stackReader = Activator.CreateInstance(typeof(GStackReader<>).MakeGenericType(args)) as IGStackReader;
            lock (cache.SyncRoot) {
                gStackReaderCache[type] = stackReader;
            }
            return stackReader;
        }
#endif
    }
}