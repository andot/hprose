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
 * TypeEnum.cs                                            *
 *                                                        *
 * type enum for C#.                                      *
 *                                                        *
 * LastModified: Dec 16, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
namespace Hprose.IO {
    using System;
    internal enum TypeEnum {
#if !Core
        Null = TypeCode.Empty,
        DBNull = TypeCode.DBNull,
        Boolean = TypeCode.Boolean,
        Char = TypeCode.Char,
        SByte = TypeCode.SByte,
        Byte = TypeCode.Byte,
        Int16 = TypeCode.Int16,
        UInt16 = TypeCode.UInt16,
        Int32 = TypeCode.Int32,
        UInt32 = TypeCode.UInt32,
        Int64 = TypeCode.Int64,
        UInt64 = TypeCode.UInt64,
        Single = TypeCode.Single,
        Double = TypeCode.Double,
        Decimal = TypeCode.Decimal,
        DateTime = TypeCode.DateTime,
        String = TypeCode.String,
#else
        Null,
        Boolean,
        Char,
        SByte,
        Byte,
        Int16,
        UInt16,
        Int32,
        UInt32,
        Int64,
        UInt64,
        Single,
        Double,
        Decimal,
        DateTime,
        String,
#endif
        BigInteger,
        Guid,
        StringBuilder,
        TimeSpan,
        Object,
        BooleanArray,
        CharArray,
        SByteArray,
        ByteArray,
        Int16Array,
        UInt16Array,
        Int32Array,
        UInt32Array,
        Int64Array,
        UInt64Array,
        SingleArray,
        DoubleArray,
        DecimalArray,
        DateTimeArray,
        StringArray,
        BigIntegerArray,
        GuidArray,
        StringBuilderArray,
        TimeSpanArray,
        ObjectArray,
        BytesArray,
        CharsArray,
        MemoryStream,
        Stream,
        ICollection,
        IDictionary,
        IList,
        BitArray,
        OtherType,
        OtherTypeArray,
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
        ArrayList,
        HashMap,
        Hashtable,
        Queue,
        Stack,
#endif
    }
}