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
 * LastModified: Nov 10, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

namespace Hprose.IO {
    internal enum TypeEnum {
        Boolean,
        BooleanArray,
        BigInteger,
        BigIntegerArray,
        Byte,
        ByteArray,
        BytesArray,
        Char,
        CharArray,
        CharsArray,
        DateTime,
        DateTimeArray,
        Decimal,
        DecimalArray,
        Double,
        DoubleArray,
        Guid,
        GuidArray,
        Int16,
        Int16Array,
        Int32,
        Int32Array,
        Int64,
        Int64Array,
        Object,
        ObjectArray,
        SByte,
        SByteArray,
        Single,
        SingleArray,
        String,
        StringArray,
        StringBuilder,
        StringBuilderArray,
        TimeSpan,
        TimeSpanArray,
        UInt16,
        UInt16Array,
        UInt32,
        UInt32Array,
        UInt64,
        UInt64Array,
        MemoryStream,
        Stream,
        ICollection,
        IDictionary,
        IList,
        BitArray,
        Null,
        Enum,
        OtherType,
        OtherTypeArray,
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
        ArrayList,
        HashMap,
        Hashtable,
        Queue,
        Stack,
#endif
#if !Core
        DBNull,
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
        BooleanList,
        BigIntegerList,
        ByteList,
        BytesList,
        CharList,
        CharsList,
        DateTimeList,
        DecimalList,
        DoubleList,
        GuidList,
        Int16List,
        Int32List,
        Int64List,
        ObjectList,
        SByteList,
        SingleList,
        StringList,
        StringBuilderList,
        TimeSpanList,
        UInt16List,
        UInt32List,
        UInt64List,
#endif
    }
}