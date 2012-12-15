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
        Null,
#if !Core
        DBNull,
#endif
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
        Enum,
    }
}