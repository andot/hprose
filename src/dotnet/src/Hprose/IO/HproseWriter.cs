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
 * HproseWriter.cs                                        *
 *                                                        *
 * hprose writer class for C#.                            *
 *                                                        *
 * LastModified: Dec 15, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
#if dotNET45
using System.Linq;
#endif
using System.Numerics;
using System.IO;
using System.Text;
using System.Reflection;
using System.Runtime.CompilerServices;
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
using System.Runtime.Serialization;
using Hprose.Reflection;
#endif
using Hprose.Common;

namespace Hprose.IO {
    public sealed class HproseWriter {
        public Stream stream;
        private HproseMode mode;
#if !(dotNET10 || dotNET11 || dotNETCF10)
        private static Dictionary<Type, SerializeCache> fieldsCache = new Dictionary<Type, SerializeCache>();
        private static Dictionary<Type, SerializeCache> propertiesCache = new Dictionary<Type, SerializeCache>();
        private static Dictionary<Type, SerializeCache> membersCache = new Dictionary<Type, SerializeCache>();
        private Dictionary<object, int> references;
        private Dictionary<Type, int> classref = new Dictionary<Type, int>();
#else
        private static Hashtable fieldsCache = new Hashtable();
        private static Hashtable propertiesCache = new Hashtable();
        private static Hashtable membersCache = new Hashtable();
        private Hashtable references;
        private Hashtable classref = new Hashtable();
#endif
        private byte[] buf = new byte[20];
        private static byte[] minIntBuf = new byte[] {(byte)'-',(byte)'2',(byte)'1',(byte)'4',(byte)'7',(byte)'4',
                                                        (byte)'8',(byte)'3',(byte)'6',(byte)'4',(byte)'8'};
        private static byte[] minLongBuf = new byte[] {(byte)'-',(byte)'9',(byte)'2',(byte)'2',(byte)'3',
                                                         (byte)'3',(byte)'7',(byte)'2',(byte)'0',(byte)'3',
                                                         (byte)'6',(byte)'8',(byte)'5',(byte)'4',(byte)'7',
                                                         (byte)'7',(byte)'5',(byte)'8',(byte)'0',(byte)'8'};        
        private int lastref = 0;
        private int lastclassref = 0;

#if !(dotNET10 || dotNET11 || dotNETCF10)
        class IdentityEqualityComparer : IEqualityComparer<object> {
            bool IEqualityComparer<object>.Equals(object x, object y) {
                return object.ReferenceEquals(x, y);
            }

            int IEqualityComparer<object>.GetHashCode(object obj) {
                return obj.GetHashCode();
            }
        }
#elif MONO
        class IdentityEqualityComparer : IEqualityComparer {
            bool IEqualityComparer.Equals(object x, object y) {
                return object.ReferenceEquals(x, y);
            }
            int IEqualityComparer.GetHashCode(object obj) {
                return obj.GetHashCode();
            }
        }
#elif !dotNETCF10
        public class IdentityHashcodeProvider : IHashCodeProvider {
            public int GetHashCode(object obj) {
                return obj.GetHashCode();
            }
        }

        public class IdentityComparer : IComparer {
            public int Compare(object obj1, object obj2) {
                if (object.ReferenceEquals(obj1, obj2))
                    return 0;
                else
                    return 1;
            }
        }
#endif

        public HproseWriter(Stream stream)
            : this(stream, HproseMode.FieldMode) {
        }

        public HproseWriter(Stream stream, HproseMode mode) {
            this.stream = stream;
            this.mode = mode;
#if !(dotNET10 || dotNET11 || dotNETCF10)
            if (mode == HproseMode.FieldMode) {
                references = new Dictionary<object, int>(new IdentityEqualityComparer());
            }
            else {
                references = new Dictionary<object, int>();
            }
#elif MONO 
            if (mode == HproseMode.FieldMode) {
                references = new Hashtable(new IdentityEqualityComparer());
            }
            else {
                references = new Hashtable();
            }
#elif !dotNETCF10 
            if (mode == HproseMode.FieldMode) {
                references = new Hashtable(new IdentityHashcodeProvider(), new IdentityComparer());
            }
            else {
                references = new Hashtable();
            }
#else
            references = new Hashtable();
#endif
        }

        
        public void Serialize(object obj) {
            if (obj == null) {
                WriteNull();
            }
            else {
                Serialize(obj, obj.GetType());
            }
        }

        private void Serialize(object obj, Type type) {
            if (obj == null) {
                WriteNull();
            }
            else {
                switch (HproseHelper.GetTypeEnum(type)) {
#if !Core
                    case TypeEnum.DBNull:
#endif
                    case TypeEnum.Null: WriteNull(); break;
                    case TypeEnum.Int32: WriteInteger((int)obj); break;
                    case TypeEnum.Char: WriteUTF8Char((char)obj); break;
                    case TypeEnum.Byte: WriteInteger((byte)obj); break;
                    case TypeEnum.SByte: WriteInteger((sbyte)obj); break;
                    case TypeEnum.Int16: WriteInteger((short)obj); break;
                    case TypeEnum.UInt16: WriteInteger((ushort)obj); break;
                    case TypeEnum.UInt32: WriteLong((uint)obj); break;
                    case TypeEnum.Int64: WriteLong((long)obj); break;
                    case TypeEnum.UInt64: WriteLong((ulong)obj); break;
                    case TypeEnum.Single: WriteDouble((float)obj); break;
                    case TypeEnum.Double: WriteDouble((double)obj); break;
                    case TypeEnum.Decimal: WriteDouble((decimal)obj); break;
                    case TypeEnum.Boolean: WriteBoolean((bool)obj); break;
                    case TypeEnum.BigInteger: WriteLong((BigInteger)obj); break;
                    case TypeEnum.Enum: WriteEnum(obj, type); break;
                    case TypeEnum.TimeSpan: WriteLong(((TimeSpan)obj).Ticks); break;

                    case TypeEnum.DateTime: WriteDateWithRef((DateTime)obj); break;
                    case TypeEnum.Guid: WriteGuidWithRef((Guid)obj); break;

                    case TypeEnum.BooleanArray: WriteArrayWithRef((bool[])obj); break;
                    case TypeEnum.BigIntegerArray: WriteArrayWithRef((BigInteger[])obj); break;
                    case TypeEnum.BytesArray: WriteArrayWithRef((byte[][])obj); break;
                    case TypeEnum.CharsArray: WriteArrayWithRef((char[][])obj); break;
                    case TypeEnum.DateTimeArray: WriteArrayWithRef((DateTime[])obj); break;
                    case TypeEnum.DecimalArray: WriteArrayWithRef((decimal[])obj); break;
                    case TypeEnum.DoubleArray: WriteArrayWithRef((double[])obj); break;
                    case TypeEnum.GuidArray: WriteArrayWithRef((Guid[])obj); break;
                    case TypeEnum.Int16Array: WriteArrayWithRef((short[])obj); break;
                    case TypeEnum.Int32Array: WriteArrayWithRef((int[])obj); break;
                    case TypeEnum.Int64Array: WriteArrayWithRef((long[])obj); break;
                    case TypeEnum.ObjectArray: WriteArrayWithRef((object[])obj); break;
                    case TypeEnum.OtherTypeArray: WriteArrayWithRef((Array)obj); break;
                    case TypeEnum.SByteArray: WriteArrayWithRef((sbyte[])obj); break;
                    case TypeEnum.SingleArray: WriteArrayWithRef((float[])obj); break;
                    case TypeEnum.StringArray: WriteArrayWithRef((string[])obj); break;
                    case TypeEnum.StringBuilderArray: WriteArrayWithRef((StringBuilder[])obj); break;
                    case TypeEnum.TimeSpanArray: WriteArrayWithRef((TimeSpan[])obj); break;
                    case TypeEnum.UInt16Array: WriteArrayWithRef((ushort[])obj); break;
                    case TypeEnum.UInt32Array: WriteArrayWithRef((uint[])obj); break;
                    case TypeEnum.UInt64Array: WriteArrayWithRef((ulong[])obj); break;
                    case TypeEnum.BitArray: WriteBitArrayWithRef((BitArray)obj); break;
#if !(dotNET10 || dotNET11 || dotNETCF10)
                    case TypeEnum.BooleanList: WriteIListWithRef((List<bool>)obj); break;
                    case TypeEnum.BigIntegerList: WriteIListWithRef((List<BigInteger>)obj); break;
                    case TypeEnum.ByteList: WriteIListWithRef((List<byte>)obj); break;
                    case TypeEnum.BytesList: WriteIListWithRef((List<byte[]>)obj); break;
                    case TypeEnum.CharList: WriteIListWithRef((List<char>)obj); break;
                    case TypeEnum.CharsList: WriteIListWithRef((List<char[]>)obj); break;
                    case TypeEnum.DateTimeList: WriteIListWithRef((List<DateTime>)obj); break;
                    case TypeEnum.DecimalList: WriteIListWithRef((List<decimal>)obj); break;
                    case TypeEnum.DoubleList: WriteIListWithRef((List<double>)obj); break;
                    case TypeEnum.GuidList: WriteIListWithRef((List<Guid>)obj); break;
                    case TypeEnum.Int16List: WriteIListWithRef((List<short>)obj); break;
                    case TypeEnum.Int32List: WriteIListWithRef((List<int>)obj); break;
                    case TypeEnum.Int64List: WriteIListWithRef((List<long>)obj); break;
                    case TypeEnum.ObjectList: WriteIListWithRef((List<Object>)obj); break;
                    case TypeEnum.SByteList: WriteIListWithRef((List<sbyte>)obj); break;
                    case TypeEnum.SingleList: WriteIListWithRef((List<float>)obj); break;
                    case TypeEnum.StringList: WriteIListWithRef((List<string>)obj); break;
                    case TypeEnum.StringBuilderList: WriteIListWithRef((List<StringBuilder>)obj); break;
                    case TypeEnum.TimeSpanList: WriteIListWithRef((List<TimeSpan>)obj); break;
                    case TypeEnum.UInt16List: WriteIListWithRef((List<ushort>)obj); break;
                    case TypeEnum.UInt32List: WriteIListWithRef((List<uint>)obj); break;
                    case TypeEnum.UInt64List: WriteIListWithRef((List<ulong>)obj); break;
#endif
                    case TypeEnum.Stream: 
                    case TypeEnum.MemoryStream: WriteStreamWithRef((Stream)obj); break;
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
                    case TypeEnum.ArrayList:
#endif
                    case TypeEnum.IList: WriteListWithRef((IList)obj); break;
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
                    case TypeEnum.Stack:
                    case TypeEnum.Queue:
#endif
                    case TypeEnum.ICollection: WriteCollectionWithRef((ICollection)obj); break;
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
                    case TypeEnum.Hashtable:
                    case TypeEnum.HashMap:
#endif
                    case TypeEnum.IDictionary: WriteMapWithRef((IDictionary)obj); break;
                    case TypeEnum.String:
                        switch (((string)obj).Length) {
                            case 0: WriteEmpty(); break;
                            case 1: WriteUTF8Char(((string)obj)[0]); break;
                            default: WriteStringWithRef((string)obj); break;
                        }
                        break;
                    case TypeEnum.StringBuilder:
                        switch (((StringBuilder)obj).Length) {
                            case 0: WriteEmpty(); break;
                            case 1: WriteUTF8Char(((StringBuilder)obj)[0]); break;
                            default: WriteStringWithRef((StringBuilder)obj); break;
                        }
                        break;
                    case TypeEnum.CharArray:
                        if (((char[])obj).Length == 0) {
                            WriteEmpty();
                        }
                        else {
                            WriteStringWithRef((char[])obj);
                        }
                        break;
                    case TypeEnum.ByteArray:
                        if (((byte[])obj).Length == 0) {
                            WriteEmpty();
                        }
                        else {
                            WriteBytesWithRef((byte[])obj);
                        }
                        break;
                    case TypeEnum.Object: 
                        type = obj.GetType();
                        if (type != HproseHelper.typeofObject) {
                            Serialize(obj, type);
                        }
                        else {
                            throw new HproseException("Hprose can't serialize Object type.");
                        }
                        break;
                     default: {
#if Core
                        TypeInfo typeInfo = type.GetTypeInfo();
                        if (HproseHelper.typeofStream.GetTypeInfo().IsAssignableFrom(typeInfo)) {
                            WriteStreamWithRef((Stream)obj);
                        }
                        else if (HproseHelper.typeofIList.GetTypeInfo().IsAssignableFrom(typeInfo)) {
                            WriteListWithRef((IList)obj);
                        }
                        else if (HproseHelper.typeofIDictionary.GetTypeInfo().IsAssignableFrom(typeInfo)) {
                            WriteMapWithRef((IDictionary)obj);
                        }
                        else if (HproseHelper.typeofICollection.GetTypeInfo().IsAssignableFrom(typeInfo)) {
                            WriteCollectionWithRef((ICollection)obj);
                        }
                        else if (typeInfo.IsGenericType && type.Name.StartsWith("<>f__AnonymousType")) {
                            WriteAnonymousTypeWithRef(obj);
                            return;
                        }
#else
                        if (type.IsSubclassOf(HproseHelper.typeofStream)) {
                            WriteStreamWithRef((Stream)obj);
                        }
                        else if (HproseHelper.typeofIList.IsAssignableFrom(type)) {
                            WriteListWithRef((IList)obj);
                        }
                        else if (HproseHelper.typeofIDictionary.IsAssignableFrom(type)) {
                            WriteMapWithRef((IDictionary)obj);
                        }
                        else if (HproseHelper.typeofICollection.IsAssignableFrom(type)) {
                            WriteCollectionWithRef((ICollection)obj);
                        }
#if !(dotNET10 || dotNET11 || dotNETCF10)
                        else if (type.IsGenericType && type.Name.StartsWith("<>f__AnonymousType")) {
                            WriteAnonymousTypeWithRef(obj);
                            return;
                        }
#endif
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE)
                        else if (HproseHelper.typeofISerializable.IsAssignableFrom(type)) {
                            throw new HproseException(type.Name + " is a ISerializable type, hprose can't support it.");
                        }
#endif
#endif
                        else {
                            WriteObjectWithRef(obj);
                        }
                        break;
                    }
                }
            }
        }

        public void WriteInteger(sbyte i) {
            if (i >= 0 && i <= 9) {
                stream.WriteByte((byte)('0' + i));
            }
            else {
                stream.WriteByte(HproseTags.TagInteger);
                WriteIntFast((int)i, stream);
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteInteger(short i) {
            if (i >= 0 && i <= 9) {
                stream.WriteByte((byte)('0' + i));
            }
            else {
                stream.WriteByte(HproseTags.TagInteger);
                WriteIntFast((int)i, stream);
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteInteger(int i) {
            if (i >= 0 && i <= 9) {
                stream.WriteByte((byte)('0' + i));
            }            
            else {
                stream.WriteByte(HproseTags.TagInteger);
                if (i == Int32.MinValue) {
                    stream.Write(minIntBuf, 0, minIntBuf.Length);
                }
                else {
                    WriteIntFast(i, stream);
                }
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteInteger(byte i) {
            if (i <= 9) {
                stream.WriteByte((byte)('0' + i));
            }
            else {
                stream.WriteByte(HproseTags.TagInteger);
                WriteIntFast((uint)i, stream);
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteInteger(ushort i) {
            if (i <= 9) {
                stream.WriteByte((byte)('0' + i));
            }
            else {
                stream.WriteByte(HproseTags.TagInteger);
                WriteIntFast((uint)i, stream);
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteLong(uint l) {
            if (l <= 9) {
                stream.WriteByte((byte)('0' + l));
            }
            else {
                stream.WriteByte(HproseTags.TagLong);
                WriteIntFast((uint)l, stream);
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteLong(long l) {
            if (l >= 0 && l <= 9) {
                stream.WriteByte((byte)('0' + l));
            }
            else {
                stream.WriteByte(HproseTags.TagLong);
                if (l == Int64.MinValue) {
                    stream.Write(minLongBuf, 0, minLongBuf.Length);
                }
                else {
                    WriteIntFast((long)l, stream);
                }
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteLong(ulong l) {
            if (l <= 9) {
                stream.WriteByte((byte)('0' + l));
            }
            else {
                stream.WriteByte(HproseTags.TagLong);
                WriteIntFast((ulong)l, stream);
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteLong(BigInteger l) {
            stream.WriteByte(HproseTags.TagLong);
            WriteAsciiString(l.ToString());
            stream.WriteByte(HproseTags.TagSemicolon);
        }

        public void WriteEnum(object value, Type type) {
            switch (HproseHelper.GetTypeEnum(Enum.GetUnderlyingType(type))) {
                case TypeEnum.Int32: WriteInteger((int)value); break;
                case TypeEnum.Byte: WriteInteger((byte)value); break;
                case TypeEnum.SByte: WriteInteger((sbyte)value); break;
                case TypeEnum.Int16: WriteInteger((short)value); break;
                case TypeEnum.UInt16: WriteInteger((ushort)value); break;
                case TypeEnum.UInt32: WriteLong((uint)value); break;
                case TypeEnum.Int64: WriteLong((long)value); break;
                case TypeEnum.UInt64: WriteLong((ulong)value); break;
            }
        }

        public void WriteDouble(float d) {
            if (float.IsNaN(d)) {
                stream.WriteByte(HproseTags.TagNaN);
            }
            else if (float.IsInfinity(d)) {
                stream.WriteByte(HproseTags.TagInfinity);
                if (d > 0) {
                    stream.WriteByte(HproseTags.TagPos);
                }
                else {
                    stream.WriteByte(HproseTags.TagNeg);
                }
            }
            else {
                stream.WriteByte(HproseTags.TagDouble);
                WriteAsciiString(d.ToString("R"));
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteDouble(double d) {
            if (double.IsNaN(d)) {
                stream.WriteByte(HproseTags.TagNaN);
            }
            else if (double.IsInfinity(d)) {
                stream.WriteByte(HproseTags.TagInfinity);
                if (d > 0) {
                    stream.WriteByte(HproseTags.TagPos);
                }
                else {
                    stream.WriteByte(HproseTags.TagNeg);
                }
            }
            else {
                stream.WriteByte(HproseTags.TagDouble);
                WriteAsciiString(d.ToString("R"));
                stream.WriteByte(HproseTags.TagSemicolon);
            }
        }

        public void WriteDouble(decimal d) {
            stream.WriteByte(HproseTags.TagDouble);
            WriteAsciiString(d.ToString());
            stream.WriteByte(HproseTags.TagSemicolon);
        }

        public void WriteNaN() {
            stream.WriteByte(HproseTags.TagNaN);
        }

        public void WriteInfinity(bool positive) {
            stream.WriteByte(HproseTags.TagInfinity);
            if (positive) {
                stream.WriteByte(HproseTags.TagPos);
            }
            else {
                stream.WriteByte(HproseTags.TagNeg);
            }
        }

        public void WriteNull() {
            stream.WriteByte(HproseTags.TagNull);
        }

        public void WriteEmpty() {
            stream.WriteByte(HproseTags.TagEmpty);
        }

        public void WriteBoolean(bool b) {
            if (b) {
                stream.WriteByte(HproseTags.TagTrue);
            }
            else {
                stream.WriteByte(HproseTags.TagFalse);
            }
        }

        private void WriteDate(int year, int month, int day) {
            stream.WriteByte(HproseTags.TagDate);
            stream.WriteByte((byte)('0' + (year / 1000 % 10)));
            stream.WriteByte((byte)('0' + (year / 100 % 10)));
            stream.WriteByte((byte)('0' + (year / 10 % 10)));
            stream.WriteByte((byte)('0' + (year % 10)));
            stream.WriteByte((byte)('0' + (month / 10 % 10)));
            stream.WriteByte((byte)('0' + (month % 10)));
            stream.WriteByte((byte)('0' + (day / 10 % 10)));
            stream.WriteByte((byte)('0' + (day % 10)));
        }

        private void WriteTime(int hour, int minute, int second, int millisecond) {
            stream.WriteByte(HproseTags.TagTime);
            stream.WriteByte((byte)('0' + (hour / 10 % 10)));
            stream.WriteByte((byte)('0' + (hour % 10)));
            stream.WriteByte((byte)('0' + (minute / 10 % 10)));
            stream.WriteByte((byte)('0' + (minute % 10)));
            stream.WriteByte((byte)('0' + (second / 10 % 10)));
            stream.WriteByte((byte)('0' + (second % 10)));
            if (millisecond > 0) {
                stream.WriteByte(HproseTags.TagPoint);
                stream.WriteByte((byte)('0' + (millisecond / 100 % 10)));
                stream.WriteByte((byte)('0' + (millisecond / 10 % 10)));
                stream.WriteByte((byte)('0' + (millisecond % 10)));
            }
        }

        private void WriteDateTime(DateTime datetime) {
            int year = datetime.Year;
            int month = datetime.Month;
            int day = datetime.Day;
            int hour = datetime.Hour;
            int minute = datetime.Minute;
            int second = datetime.Second;
            int millisecond = datetime.Millisecond;
            byte tag = HproseTags.TagSemicolon;
#if !(dotNET10 || dotNET11 || dotNETCF10)
            if (datetime.Kind == DateTimeKind.Utc) tag = HproseTags.TagUTC;
#endif
            if ((hour == 0) && (minute == 0) && (second == 0) && (millisecond == 0)) {
                WriteDate(year, month, day);
                stream.WriteByte(tag);
            }
            else if ((year == 1) && (month == 1) && (day == 1)) {
                WriteTime(hour, minute, second, millisecond);
                stream.WriteByte(tag);
            }
            else {
                WriteDate(year, month, day);
                WriteTime(hour, minute, second, millisecond);
                stream.WriteByte(tag);
            }
        }

        public void WriteDate(DateTime date) {
            references[date] = lastref++;
            WriteDateTime(date);
        }

        public void WriteDateWithRef(DateTime date) {
            if (references.ContainsKey(date)) WriteRef(date);
            else WriteDate(date);
        }

        public void WriteBytes(byte[] bytes) {
            references[bytes] = lastref++;
            stream.WriteByte(HproseTags.TagBytes);
            if (bytes.Length > 0) WriteInt(bytes.Length, stream);
            stream.WriteByte(HproseTags.TagQuote);
            stream.Write(bytes, 0, bytes.Length);
            stream.WriteByte(HproseTags.TagQuote);
        }

        public void WriteBytesWithRef(byte[] bytes) {
            if (references.ContainsKey(bytes)) WriteRef(bytes);
            else WriteBytes(bytes);
        }

        public void WriteStream(Stream s) {
            if (!s.CanRead) throw new HproseException("This stream can't support serialize.");
            references[s] = lastref++;
            stream.WriteByte(HproseTags.TagBytes);
            long oldPos = 0;
            if (s.CanSeek) {
                oldPos = s.Position;
                s.Position = 0;
            }
            int length = (int)s.Length;
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagQuote);
            byte[] buffer = new byte[4096];
            while ((length = s.Read(buffer, 0, 4096)) != 0) {
                stream.Write(buffer, 0, length);
            }
            stream.WriteByte(HproseTags.TagQuote);
            if (s.CanSeek) {
                s.Position = oldPos;
            }
        }

        public void WriteStreamWithRef(Stream s) {
            if (references.ContainsKey(s)) WriteRef(s);
            else WriteStream(s);
        }

        public void WriteUTF8Char(int c) {
            stream.WriteByte(HproseTags.TagUTF8Char);
            if (c < 0x80) {
                stream.WriteByte((byte)c);
            }
            else if (c < 0x800) {
                stream.WriteByte((byte)(0xc0 | (c >> 6)));
                stream.WriteByte((byte)(0x80 | (c & 0x3f)));
            }
            else {
                stream.WriteByte((byte)(0xe0 | (c >> 12)));
                stream.WriteByte((byte)(0x80 | ((c >> 6) & 0x3f)));
                stream.WriteByte((byte)(0x80 | (c & 0x3f)));
            }
        }

        public void WriteString(string s) {
            references[s] = lastref++;
            stream.WriteByte(HproseTags.TagString);
            WriteUTF8String(s, stream);
        }

        public void WriteStringWithRef(string s) {
            if (references.ContainsKey(s)) WriteRef(s);
            else WriteString(s);
        }

        private void WriteUTF8String(string s, Stream stream) {
            int length = s.Length;
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagQuote);
            for (int i = 0; i < length; i++) {
                int c = 0xffff & s[i];
                if (c < 0x80) {
                    stream.WriteByte((byte)c);
                }
                else if (c < 0x800) {
                    stream.WriteByte((byte)(0xc0 | (c >> 6)));
                    stream.WriteByte((byte)(0x80 | (c & 0x3f)));
                }
                else if (c < 0xd800 || c > 0xdfff) {
                    stream.WriteByte((byte)(0xe0 | (c >> 12)));
                    stream.WriteByte((byte)(0x80 | ((c >> 6) & 0x3f)));
                    stream.WriteByte((byte)(0x80 | (c & 0x3f)));
                }
                else {
                    if (++i < length) {
                        int c2 = 0xffff & s[i];
                        if (c < 0xdc00 && 0xdc00 <= c2 && c2 <= 0xdfff) {
                            c = ((c & 0x03ff) << 10 | (c2 & 0x03ff)) + 0x010000;
                            stream.WriteByte((byte)(0xf0 | (c >> 18)));
                            stream.WriteByte((byte)(0x80 | ((c >> 12) & 0x3f)));
                            stream.WriteByte((byte)(0x80 | ((c >> 6) & 0x3f)));
                            stream.WriteByte((byte)(0x80 | (c & 0x3f)));
                        }
                        else {
                            throw new HproseException("wrong unicode string");
                        }
                    }
                    else {
                        throw new HproseException("wrong unicode string");
                    }
                }
            }
            stream.WriteByte(HproseTags.TagQuote);
        }

        public void WriteString(char[] s) {
            references[s] = lastref++;
            stream.WriteByte(HproseTags.TagString);
            WriteUTF8String(s);
        }

        public void WriteStringWithRef(char[] s) {
            if (references.ContainsKey(s)) WriteRef(s);
            else WriteString(s);
        }

        private void WriteUTF8String(char[] s) {
            int length = s.Length;
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagQuote);
            for (int i = 0; i < length; i++) {
                int c = 0xffff & s[i];
                if (c < 0x80) {
                    stream.WriteByte((byte)c);
                }
                else if (c < 0x800) {
                    stream.WriteByte((byte)(0xc0 | (c >> 6)));
                    stream.WriteByte((byte)(0x80 | (c & 0x3f)));
                }
                else if (c < 0xd800 || c > 0xdfff) {
                    stream.WriteByte((byte)(0xe0 | (c >> 12)));
                    stream.WriteByte((byte)(0x80 | ((c >> 6) & 0x3f)));
                    stream.WriteByte((byte)(0x80 | (c & 0x3f)));
                }
                else {
                    if (++i < length) {
                        int c2 = 0xffff & s[i];
                        if (c < 0xdc00 && 0xdc00 <= c2 && c2 <= 0xdfff) {
                            c = ((c & 0x03ff) << 10 | (c2 & 0x03ff)) + 0x010000;
                            stream.WriteByte((byte)(0xf0 | (c >> 18)));
                            stream.WriteByte((byte)(0x80 | ((c >> 12) & 0x3f)));
                            stream.WriteByte((byte)(0x80 | ((c >> 6) & 0x3f)));
                            stream.WriteByte((byte)(0x80 | (c & 0x3f)));
                        }
                        else {
                            throw new HproseException("wrong unicode string");
                        }
                    }
                    else {
                        throw new HproseException("wrong unicode string");
                    }
                }
            }
            stream.WriteByte(HproseTags.TagQuote);
        }

        public void WriteString(StringBuilder s) {
            references[s] = lastref++;
            stream.WriteByte(HproseTags.TagString);
            WriteUTF8String(s.ToString(), stream);
        }

        public void WriteStringWithRef(StringBuilder s) {
            if (references.ContainsKey(s)) WriteRef(s);
            else WriteString(s);
        }

        public void WriteGuid(Guid g) {
            references[g] = lastref++;
            stream.WriteByte(HproseTags.TagGuid);
            stream.WriteByte(HproseTags.TagOpenbrace);
            WriteAsciiString(g.ToString());
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteGuidWithRef(Guid g) {
            if (references.ContainsKey(g)) WriteRef(g);
            else WriteGuid(g);
        }
 
        public void WriteArray(sbyte[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(sbyte[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(short[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(short[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(int[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(int[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(long[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(long[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(ushort[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(ushort[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(uint[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(uint[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(ulong[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(ulong[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(BigInteger[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(BigInteger[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(float[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDouble(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(float[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(double[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDouble(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(double[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(decimal[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDouble(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(decimal[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(bool[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteBoolean(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(bool[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(byte[][] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                byte[] value = array[i];
                if (value == null) WriteNull();
                else WriteBytes(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(byte[][] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(char[][] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                char[] value = array[i];
                if (value == null) WriteNull();
                else WriteString(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(char[][] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(string[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                string value = array[i];
                if (value == null) WriteNull();
                else WriteString(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(string[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(StringBuilder[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                StringBuilder value = array[i];
                if (value == null) WriteNull();
                else WriteString(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(StringBuilder[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(Guid[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteGuidWithRef(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(Guid[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(TimeSpan[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(array[i].Ticks);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(TimeSpan[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(DateTime[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDate(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(DateTime[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(object[] array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                Serialize(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteArrayWithRef(object[] array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteArray(Array array) {
            references[array] = lastref++;
            int rank = array.Rank;
            if (rank == 1) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    Serialize(array.GetValue(i));
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
            else {
                int i;
                int[,] des = new int[rank, 2];
                int[] loc = new int[rank];
                int[] len = new int[rank];
                int maxrank = rank - 1;
                for (i = 0; i < rank; i++) {
                    des[i, 0] = array.GetLowerBound(i);
                    des[i, 1] = array.GetUpperBound(i);
                    loc[i] = des[i, 0];
                    len[i] = array.GetLength(i);
                }
                stream.WriteByte(HproseTags.TagList);
                if (len[0] > 0) WriteInt(len[0], stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                while (loc[0] <= des[0, 1]) {
                    int n = 0;
                    for (i = maxrank; i > 0; i--) {
                        if (loc[i] == des[i, 0]) {
                            n++;
                        }
                        else {
                            break;
                        }
                    }
                    for (i = rank - n; i < rank; i++) {
                        references[new object()] = lastref++;
                        stream.WriteByte(HproseTags.TagList);
                        if (len[i] > 0) WriteInt(len[i], stream);
                        stream.WriteByte(HproseTags.TagOpenbrace);
                    }
                    for (loc[maxrank] = des[maxrank, 0];
                         loc[maxrank] <= des[maxrank, 1];
                         loc[maxrank]++) {
                        Serialize(array.GetValue(loc));
                    }
                    for (i = maxrank; i > 0; i--) {
                        if (loc[i] > des[i, 1]) {
                            loc[i] = des[i, 0];
                            loc[i - 1]++;
                            stream.WriteByte(HproseTags.TagClosebrace);
                        }
                    }
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArrayWithRef(Array array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteArray(array);
        }

        public void WriteBitArray(BitArray array) {
            references[array] = lastref++;
            int length = array.Length;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteBoolean(array[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteBitArrayWithRef(BitArray array) {
            if (references.ContainsKey(array)) WriteRef(array);
            else WriteBitArray(array);
        }

        public void WriteList(IList list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                Serialize(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteListWithRef(IList list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteList(list);
        }

        public void WriteMap(IDictionary map) {
            references[map] = lastref++;
            int length = map.Count;
            stream.WriteByte(HproseTags.TagMap);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            foreach (DictionaryEntry e in map) {
                Serialize(e.Key);
                Serialize(e.Value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteMapWithRef(IDictionary map) {
            if (references.ContainsKey(map)) WriteRef(map);
            else WriteMap(map);
        }

        public void WriteCollection(ICollection collection) {
            references[collection] = lastref++;
            int length = collection.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            foreach (object e in collection) {
                Serialize(e);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteCollectionWithRef(ICollection collection) {
            if (references.ContainsKey(collection)) WriteRef(collection);
            else WriteCollection(collection);
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public void WriteIList<T>(IList<T> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            Type type = typeof(T);
            for (int i = 0; i < length; i++) {
                Serialize(list[i], type);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef<T>(IList<T> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList<T>(list);
        }

        public void WriteIList(IList<Boolean> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteBoolean(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Boolean> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<BigInteger> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<BigInteger> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Byte> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Byte> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Byte[]> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                byte[] value = list[i];
                if (value == null) WriteNull();
                else WriteBytesWithRef(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Byte[]> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Char> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteUTF8Char(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Char> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Char[]> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                char[] value = list[i];
                if (value == null) WriteNull();
                else WriteStringWithRef(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Char[]> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<DateTime> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDateWithRef(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<DateTime> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Decimal> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDouble(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Decimal> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Double> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDouble(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Double> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Guid> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteGuidWithRef(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Guid> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Int16> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Int16> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Int32> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Int32> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Int64> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Int64> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Object> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                Serialize(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Object> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<SByte> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<SByte> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<Single> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteDouble(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<Single> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<String> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                string value = list[i];
                if (value == null) WriteNull();
                else WriteStringWithRef(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<String> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<StringBuilder> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                StringBuilder value = list[i];
                if (value == null) WriteNull();
                else WriteStringWithRef(value);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<StringBuilder> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<TimeSpan> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(list[i].Ticks);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<TimeSpan> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<UInt16> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteInteger(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<UInt16> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<UInt32> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<UInt32> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIList(IList<UInt64> list) {
            references[list] = lastref++;
            int length = list.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                WriteLong(list[i]);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIListWithRef(IList<UInt64> list) {
            if (references.ContainsKey(list)) WriteRef(list);
            else WriteIList(list);
        }

        public void WriteIMap<TKey, TValue>(IDictionary<TKey, TValue> map) {
            references[map] = lastref++;
            int length = map.Count;
            stream.WriteByte(HproseTags.TagMap);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            Type keyType = typeof(TKey);
            Type valueType = typeof(TValue);
            foreach (KeyValuePair<TKey, TValue> e in map) {
                Serialize(e.Key, keyType);
                Serialize(e.Value, valueType);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteIMapWithRef<TKey, TValue>(IDictionary<TKey, TValue> map) {
            if (references.ContainsKey(map)) WriteRef(map);
            else WriteIMap<TKey, TValue>(map);
        }

        public void WriteICollection<T>(ICollection<T> collection) {
            references[collection] = lastref++;
            int length = collection.Count;
            stream.WriteByte(HproseTags.TagList);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            Type type = typeof(T);
            foreach (object e in collection) {
                Serialize(e, type);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteICollectionWithRef<T>(ICollection<T> collection) {
            if (references.ContainsKey(collection)) WriteRef(collection);
            else WriteICollection<T>(collection);
        }

        public void WriteAnonymousType(object obj) {
            references[obj] = lastref++;
#if dotNET45
            IEnumerable<PropertyInfo> properties = obj.GetType().GetRuntimeProperties();
            int length = properties.Count();
#else
            PropertyInfo[] properties = obj.GetType().GetProperties();
            int length = properties.Length;
#endif
            stream.WriteByte(HproseTags.TagMap);
            if (length > 0) WriteInt(length, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            foreach (PropertyInfo property in properties) {
                WriteString(property.Name);
                Serialize(property.GetValue(obj, null));
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteAnonymousTypeWithRef(object obj) {
            if (references.ContainsKey(obj)) WriteRef(obj);
            else WriteAnonymousType(obj);
        }
#endif

        public void WriteObject(object obj) {
            Type type = obj.GetType();
            int cr;
#if (dotNET10 || dotNET11 || dotNETCF10)
            object crobj;
            if ((crobj = classref[type]) != null) {
                cr = (int)crobj;
            }
            else {
                cr = WriteClass(type);
            }
#else
            if (!classref.TryGetValue(type, out cr)) {
                cr = WriteClass(type);
            }
#endif
            references[obj] = lastref++;
            stream.WriteByte(HproseTags.TagObject);
            WriteInt(cr, stream);
            stream.WriteByte(HproseTags.TagOpenbrace);
            if (HproseHelper.IsSerializable(type)) {
                WriteSerializableObject(obj, type);
            }
            else {
                WriteDataContractObject(obj, type);
            }
            stream.WriteByte(HproseTags.TagClosebrace);
        }

        public void WriteObjectWithRef(object obj) {
            if (references.ContainsKey(obj)) WriteRef(obj);
            else WriteObject(obj);
        }

        private void WriteSerializableObject(object obj, Type type) {
            if (mode == HproseMode.FieldMode) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                ObjectSerializer.Get(type).SerializeFields(obj, this);
#else
#if !(dotNET10 || dotNET11 || dotNETCF10)
                ICollection<FieldInfo> fields = HproseHelper.GetFields(type).Values;
                foreach (FieldInfo field in fields) {
                    object value;
                    try {
                        value = field.GetValue(obj);
#else
                ICollection fields = HproseHelper.GetFields(type).Values;
                foreach (object field in fields) {
                    object value;
                    try {
                        value = ((FieldInfo)field).GetValue(obj);
#endif
                    }
                    catch (Exception e) {
                        throw new HproseException("The field value can't be serialized.", e);
                    }
                    Serialize(value);
                }
#endif
            }
            else {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                ObjectSerializer.Get(type).SerializeProperties(obj, this);
#else
#if !(dotNET10 || dotNET11 || dotNETCF10)
                ICollection<PropertyInfo> properties = HproseHelper.GetProperties(type).Values;
                foreach (PropertyInfo property in properties) {
                    object value;
                    try {
                        value = property.GetValue(obj, null);
#else
                ICollection properties = HproseHelper.GetProperties(type).Values;
                foreach (object property in properties) {
                    object value;
                    try {
#if (dotNET10 || dotNET11)
                        value = PropertyAccessor.Get((PropertyInfo)property).GetValue(obj);
#else
                        value = ((PropertyInfo)property).GetValue(obj, null);
#endif
#endif
                    }
                    catch (Exception e) {
                        throw new HproseException("The property value can't be serialized.", e);
                    }
                    Serialize(value);
                }
#endif
            }
        }

        private void WriteDataContractObject(object obj, Type type) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            ObjectSerializer.Get(type).SerializeMembers(obj, this);
#else
#if !(dotNET10 || dotNET11 || dotNETCF10)
            ICollection<MemberInfo> members = HproseHelper.GetMembers(type).Values;
            foreach (MemberInfo member in members) {
#else
            ICollection members = HproseHelper.GetMembers(type).Values;
            foreach (object member in members) {
#endif
                object value;
                try {
                    if (member is FieldInfo) {
                        value = ((FieldInfo)member).GetValue(obj);
                    }
                    else {
#if (dotNET10 || dotNET11)
                        value = PropertyAccessor.Get((PropertyInfo)member).GetValue(obj);
#else
                        value = ((PropertyInfo)member).GetValue(obj, null);
#endif
                    }
                }
                catch (Exception e) {
                    throw new HproseException("The member value can't be serialized.", e);
                }
                Serialize(value);
            }
#endif
        }

        private int WriteClass(Type type) {
            SerializeCache cache = null;
            if (HproseHelper.IsSerializable(type)) {
                cache = WriteSerializableClass(type);
            }
            else {
                cache = WriteDataContractClass(type);
            }
            stream.Write(cache.data, 0, cache.data.Length);
            lastref += cache.refcount;
            int cr = lastclassref++;
            classref[type] = cr;
            return cr;
        }

        private SerializeCache WriteSerializableClass(Type type) {
            SerializeCache cache = null;
            ICollection c = null;
            if (mode == HproseMode.FieldMode) {
                c = fieldsCache;
                lock (c.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                    fieldsCache.TryGetValue(type, out cache);
#else
                    cache = (SerializeCache)fieldsCache[type];
#endif
                }
            }
            else {
                c = propertiesCache;
                lock (c.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                    propertiesCache.TryGetValue(type, out cache);
#else
                    cache = (SerializeCache)propertiesCache[type];
#endif
                }
            }
            if (cache == null) {
                cache = new SerializeCache();
                MemoryStream cachestream = new MemoryStream();
#if !(dotNET10 || dotNET11 || dotNETCF10)
                ICollection<string> keys;
#else
                ICollection keys;
#endif
                if (mode == HproseMode.FieldMode) {
                    keys = HproseHelper.GetFields(type).Keys;
                }
                else {
                    keys = HproseHelper.GetProperties(type).Keys;
                }
                int count = keys.Count;
                cachestream.WriteByte(HproseTags.TagClass);
                WriteUTF8String(HproseHelper.GetClassName(type), cachestream);
                if (count > 0) WriteInt(count, cachestream);
                cachestream.WriteByte(HproseTags.TagOpenbrace);
#if !(dotNET10 || dotNET11 || dotNETCF10)
                foreach (string key in keys) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String(key, cachestream);
#else
                foreach (object key in keys) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String((string)key, cachestream);
#endif
                    cache.refcount++;
                }
                cachestream.WriteByte(HproseTags.TagClosebrace);
                cache.data = cachestream.ToArray();
                if (mode == HproseMode.FieldMode) {
                    c = fieldsCache;
                    lock (c.SyncRoot) {
                        fieldsCache[type] = cache;
                    }
                }
                else {
                    c = propertiesCache;
                    lock (c) {
                        propertiesCache[type] = cache;
                    }
                }
            }
            return cache;
        }

        private SerializeCache WriteDataContractClass(Type type) {
            SerializeCache cache = null;
            ICollection c = membersCache;
            lock (c.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                membersCache.TryGetValue(type, out cache);
#else
                cache = (SerializeCache)membersCache[type];
#endif
            }
            if (cache == null) {
                cache = new SerializeCache();
                MemoryStream cachestream = new MemoryStream();
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> members;
#else
                Hashtable members;
#endif
                members = HproseHelper.GetMembers(type);
                int count = members.Count;
                cachestream.WriteByte(HproseTags.TagClass);
                WriteUTF8String(HproseHelper.GetClassName(type), cachestream);
                if (count > 0) WriteInt(count, cachestream);
                cachestream.WriteByte(HproseTags.TagOpenbrace);
#if !(dotNET10 || dotNET11 || dotNETCF10)
                foreach (KeyValuePair<string, MemberInfo> member in members) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String(member.Key, cachestream);
#else
                foreach (DictionaryEntry member in members) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String((string)member.Key, cachestream);
#endif
                    cache.refcount++;
                }
                cachestream.WriteByte(HproseTags.TagClosebrace);
                cache.data = cachestream.ToArray();
                lock (c.SyncRoot) {
                    membersCache[type] = cache;
                }
            }
            return cache;
        }

        private void WriteRef(object obj) {
            stream.WriteByte(HproseTags.TagRef);
#if !(dotNET10 || dotNET11 || dotNETCF10)
            WriteInt(references[obj], stream);
#else
            WriteInt((int)references[obj], stream);
#endif
            stream.WriteByte(HproseTags.TagSemicolon);
        }

        private void WriteAsciiString(string s) {
            int size = s.Length;
            byte[] b = new byte[size--];
            for (; size >= 0; size--) {
                b[size] = (byte)s[size];
            }
            stream.Write(b, 0, b.Length);
        }

        private void WriteIntFast(int i, Stream stream) {
            int off = 20;
            int len = 0;
            bool neg = false;
            if (i < 0) {
                neg = true;
                i = -i;
            }
            while (i != 0) {
                buf[--off] = (byte)(i % 10 + (byte)'0');
                ++len;
                i /= 10;
            }
            if (neg) {
                buf[--off] = (byte)'-';
                ++len;
            }
            stream.Write(buf, off, len);
        }
        
        private void WriteIntFast(uint i, Stream stream) {
            int off = 20;
            int len = 0;
            while (i != 0) {
                buf[--off] = (byte) (i % 10 + (byte)'0');
                ++len;
                i /= 10;
            }
            stream.Write(buf, off, len);
        }

        private void WriteIntFast(long i, Stream stream) {
            int off = 20;
            int len = 0;
            bool neg = false;
            if (i < 0) {
                neg = true;
                i = -i;
            }
            while (i != 0) {
                buf[--off] = (byte)(i % 10 + (byte)'0');
                ++len;
                i /= 10;
            }
            if (neg) {
                buf[--off] = (byte)'-';
                ++len;
            }
            stream.Write(buf, off, len);
        }
        
        private void WriteIntFast(ulong i, Stream stream) {
            int off = 20;
            int len = 0;
            while (i != 0) {
                buf[--off] = (byte) (i % 10 + (byte)'0');
                ++len;
                i /= 10;
            }
            stream.Write(buf, off, len);
        }

        private void WriteInt(int i, Stream stream) {
            if (i >= 0 && i <= 9) {
                stream.WriteByte((byte)('0' + i));
            }
            else {
                WriteIntFast((uint)i, stream);
            }
        }

        public void Reset() {
            references.Clear();
            classref.Clear();
            lastref = 0;
            lastclassref = 0;
        }
        
        private class SerializeCache {
            public byte[] data;
            public int refcount;
        }
    }
}