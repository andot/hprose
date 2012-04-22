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
 * LastModified: Apr 19, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.Numerics;
using System.IO;
using System.Text;
using System.Reflection;
using System.Runtime.Serialization;
using System.Runtime.CompilerServices;
using Hprose.Common;
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
using Hprose.Reflection;
#endif

namespace Hprose.IO {
    public sealed class HproseWriter {
#if (dotNET10 || PocketPC || Smartphone || WindowsCE)
        private static MethodInfo getHashCode = typeof(object).GetMethod("GetHashCode", BindingFlags.Public | BindingFlags.Instance);
#endif
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
#if (PocketPC || Smartphone || WindowsCE)
                return (int)getHashCode.Invoke(obj, null);
#else
                return RuntimeHelpers.GetHashCode(obj);
#endif
            }
        }
#elif MONO
        class IdentityEqualityComparer : IEqualityComparer {
            bool IEqualityComparer.Equals(object x, object y) {
                return object.ReferenceEquals(x, y);
            }
            int IEqualityComparer.GetHashCode(object obj) {
                return RuntimeHelpers.GetHashCode(obj);
            }
        }
#elif !dotNETCF10
        public class IdentityHashcodeProvider : IHashCodeProvider {
            public int GetHashCode(object obj) {
#if dotNET10
                return (int)getHashCode.Invoke(obj, null);
#else
                return RuntimeHelpers.GetHashCode(obj);
#endif
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
            if (obj == null ||
                obj is DBNull) {
                WriteNull();
                return;
            }
            Type type = obj.GetType();
            if (type == HproseHelper.typeofInt32) {
                WriteInteger((int)obj);
            }
            else if (type == HproseHelper.typeofChar) {
                WriteUTF8Char((char)obj);
            }
            else if (type == HproseHelper.typeofByte) {
                WriteInteger((byte)obj);
            }
            else if (type == HproseHelper.typeofSByte) {
                WriteInteger((sbyte)obj);
            }
            else if (type == HproseHelper.typeofInt16) {
                WriteInteger((short)obj);
            }
            else if (type == HproseHelper.typeofUInt16) {
                WriteInteger((ushort)obj);
            }
            else if (type == HproseHelper.typeofUInt32) {
                WriteLong((uint)obj);
            }
            else if (type == HproseHelper.typeofInt64) {
                WriteLong((long)obj);
            }
            else if (type == HproseHelper.typeofUInt64) {
                WriteLong((ulong)obj);
            }
            else if (type == HproseHelper.typeofBigInteger) {
                WriteLong((BigInteger)obj);
            }
            else if (type == HproseHelper.typeofSingle) {
                WriteDouble((float)obj);
            }
            else if (type == HproseHelper.typeofDouble) {
                WriteDouble((double)obj);
            }
            else if (type == HproseHelper.typeofDecimal) {
                WriteDouble((decimal)obj);
            }
            else if (type.IsEnum) {
                WriteEnum((Enum)obj);
            }
            else if (type == HproseHelper.typeofBoolean) {
                WriteBoolean((bool)obj);
            }
            else if (type == HproseHelper.typeofDateTime) {
                WriteDate((DateTime)obj);
            }
            else if (type == HproseHelper.typeofTimeSpan) {
                WriteLong(((TimeSpan)obj).Ticks);
            }
            else if (type.IsSubclassOf(HproseHelper.typeofStream)) {
                WriteStream((Stream)obj);
            }
            else if (type == HproseHelper.typeofByteArray) {
                if (((byte[])obj).Length == 0) {
                    WriteEmpty();
                }
                else {
                    WriteBytes((byte[])obj);
                }
            }
            else if (type == HproseHelper.typeofCharArray) {
                if (((char[])obj).Length == 0) {
                    WriteEmpty();
                }
                else {
                    WriteString((char[])obj);
                }
            }
            else if (type == HproseHelper.typeofString) {
                switch (((string)obj).Length) {
                    case 0: WriteEmpty(); break;
                    case 1: WriteUTF8Char(((string)obj)[0]); break;
                    default: WriteString((string)obj); break;
                }
            }
            else if (type == HproseHelper.typeofStringBuilder) {
                switch (((StringBuilder)obj).Length) {
                    case 0: WriteEmpty(); break;
                    case 1: WriteUTF8Char(((StringBuilder)obj)[0]); break;
                    default: WriteString((StringBuilder)obj); break;
                }
            }
            else if (type == HproseHelper.typeofGuid) {
                WriteGuid((Guid)obj);
            }
            else if (type.IsArray) {
                if (type == HproseHelper.typeofInt32Array) {
                    WriteArray((int[])obj);
                }
                else if (type == HproseHelper.typeofSByteArray) {
                    WriteArray((sbyte[])obj);
                }
                else if (type == HproseHelper.typeofInt16Array) {
                    WriteArray((short[])obj);
                }
                else if (type == HproseHelper.typeofUInt16Array) {
                    WriteArray((ushort[])obj);
                }
                else if (type == HproseHelper.typeofUInt32Array) {
                    WriteArray((uint[])obj);
                }
                else if (type == HproseHelper.typeofInt64Array) {
                    WriteArray((long[])obj);
                }
                else if (type == HproseHelper.typeofUInt64Array) {
                    WriteArray((ulong[])obj);
                }
                else if (type == HproseHelper.typeofBigIntegerArray) {
                    WriteArray((BigInteger[])obj);
                }
                else if (type == HproseHelper.typeofSingleArray) {
                    WriteArray((float[])obj);
                }
                else if (type == HproseHelper.typeofDoubleArray) {
                    WriteArray((double[])obj);
                }
                else if (type == HproseHelper.typeofDecimalArray) {
                    WriteArray((decimal[])obj);
                }
                else if (type == HproseHelper.typeofBooleanArray) {
                    WriteArray((bool[])obj);
                }
                else if (type == HproseHelper.typeofBytesArray) {
                    WriteArray((byte[][])obj);
                }
                else if (type == HproseHelper.typeofCharsArray) {
                    WriteArray((char[][])obj);
                }
                else if (type == HproseHelper.typeofStringArray) {
                    WriteArray((string[])obj);
                }
                else if (type == HproseHelper.typeofStringBuilderArray) {
                    WriteArray((StringBuilder[])obj);
                }
                else if (type == HproseHelper.typeofTimeSpanArray) {
                    WriteArray((TimeSpan[])obj);
                }
                else if (type == HproseHelper.typeofDateTimeArray) {
                    WriteArray((DateTime[])obj);
                }
                else if (type == HproseHelper.typeofObjectArray) {
                    WriteArray((object[])obj);
                }
                else {
                    WriteArray((Array)obj);
                }
            }
            else if (type.IsSubclassOf(HproseHelper.typeofIList)) {
                WriteList((IList)obj);
            }
            else if (type.IsSubclassOf(HproseHelper.typeofIDictionary)) {
                WriteMap((IDictionary)obj);
            }
            else if (type.IsSubclassOf(HproseHelper.typeofICollection)) {
                WriteCollection((ICollection)obj);
            }
            else {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                if (type.IsGenericType) {
                    if (type.Name.StartsWith("<>f__AnonymousType")) {
                        WriteAnonymousType(obj);
                        return;
                    }
                    IGIListWriter listWriter = HproseHelper.GetIGIListWriter(type);
                    if (listWriter != null) {
                        listWriter.WriteIList(this, obj, true);
                        return;
                    }
                    IGICollectionWriter collectionWriter = HproseHelper.GetIGICollectionWriter(type);
                    if (collectionWriter != null) {
                        collectionWriter.WriteICollection(this, obj, true);
                        return;
                    }
                    IGIMapWriter mapWriter = HproseHelper.GetIGIMapWriter(type);
                    if (mapWriter != null) {
                        mapWriter.WriteIMap(this, obj, true);
                        return;
                    }
                }
#endif
                if (type.IsSubclassOf(HproseHelper.typeofISerializable)) {
                    throw new HproseException(type.Name + " is a ISerializable type, hprose can't support it.");
                }
                WriteObject(obj);
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

        public void WriteEnum(Enum value) {
            Type entype = value.GetType();
            Type underlyingType = Enum.GetUnderlyingType(entype);
            object graph = Convert.ChangeType(value, underlyingType, null);
            if (underlyingType == HproseHelper.typeofInt32) {
                WriteInteger((int)graph);
            }
            else if (underlyingType == HproseHelper.typeofByte) {
                WriteInteger((byte)graph);
            }
            else if (underlyingType == HproseHelper.typeofSByte) {
                WriteInteger((sbyte)graph);
            }
            else if (underlyingType == HproseHelper.typeofInt16) {
                WriteInteger((short)graph);
            }
            else if (underlyingType == HproseHelper.typeofUInt16) {
                WriteInteger((ushort)graph);
            }
            else if (underlyingType == HproseHelper.typeofUInt32) {
                WriteLong((uint)graph);
            }
            else if (underlyingType == HproseHelper.typeofInt64) {
                WriteLong((long)graph);
            }
            else if (underlyingType == HproseHelper.typeofUInt64) {
                WriteLong((ulong)graph);
            }
            else if (underlyingType == HproseHelper.typeofBoolean) {
                WriteBoolean((bool)graph);
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

        public void WriteDate(DateTime date) {
            WriteDate(date, true);
        }

        public void WriteDate(DateTime date, bool checkRef) {
            if (WriteRef(date, checkRef)) {
                WriteDateTime(date);
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

        public void WriteBytes(byte[] bytes) {
            WriteBytes(bytes, true);
        }

        public void WriteBytes(byte[] bytes, bool checkRef) {
            if (WriteRef(bytes, checkRef)) {
                stream.WriteByte(HproseTags.TagBytes);
                if (bytes.Length > 0) WriteInt(bytes.Length, stream);
                stream.WriteByte(HproseTags.TagQuote);
                stream.Write(bytes, 0, bytes.Length);
                stream.WriteByte(HproseTags.TagQuote);
            }
        }

        public void WriteStream(Stream s) {
            WriteStream(s, true);
        }

        public void WriteStream(Stream s, bool checkRef) {
            if (!s.CanRead || !s.CanSeek) throw new HproseException("This stream can't support serialize.");
            if (WriteRef(s, checkRef)) {
                stream.WriteByte(HproseTags.TagBytes);
                long oldPos = s.Position;
                s.Position = 0;
                byte[] buffer;
                int length = (int)s.Length;
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagQuote);
                if (length > 4096) {
                    for (buffer = new byte[4096];
                        s.Position < s.Length;
                        length = s.Read(buffer, 0, 4096),
                        stream.Write(buffer, 0, length)) ;
                }
                else if (length > 0) {
                    buffer = new byte[length];
                    length = s.Read(buffer, 0, length);
                    stream.Write(buffer, 0, length);
                }
                stream.WriteByte(HproseTags.TagQuote);
                s.Position = oldPos;
            }
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
            WriteString(s, true);
        }

        public void WriteString(string s, bool checkRef) {
            if (WriteRef(s, checkRef)) {
                stream.WriteByte(HproseTags.TagString);
                WriteUTF8String(s, stream);
            }
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
            WriteString(s, true);
        }

        public void WriteString(char[] s, bool checkRef) {
            if (WriteRef(s, checkRef)) {
                stream.WriteByte(HproseTags.TagString);
                WriteUTF8String(s);
            }
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
            WriteString(s, true);
        }

        public void WriteString(StringBuilder s, bool checkRef) {
            if (WriteRef(s, checkRef)) {
                stream.WriteByte(HproseTags.TagString);
                WriteUTF8String(s);
            }
        }

        private void WriteUTF8String(StringBuilder s) {
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

        public void WriteGuid(Guid g) {
            WriteGuid(g, true);
        }

        public void WriteGuid(Guid g, bool checkRef) {
            if (WriteRef(g, checkRef)) {
                stream.WriteByte(HproseTags.TagGuid);
                stream.WriteByte(HproseTags.TagOpenbrace);
                WriteAsciiString(g.ToString());
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }
 
        public void WriteArray(sbyte[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(sbyte[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteInteger(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(short[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(short[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteInteger(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(int[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(int[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteInteger(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(long[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(long[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteLong(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(ushort[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(ushort[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteInteger(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(uint[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(uint[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteLong(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(ulong[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(ulong[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteLong(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(BigInteger[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(BigInteger[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteLong(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(float[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(float[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteDouble(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(double[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(double[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteDouble(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(decimal[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(decimal[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteDouble(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(bool[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(bool[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteBoolean(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(byte[][] array) {
            WriteArray(array, true);
        }

        public void WriteArray(byte[][] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteBytes(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(char[][] array) {
            WriteArray(array, true);
        }

        public void WriteArray(char[][] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteString(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(string[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(string[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteString(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(StringBuilder[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(StringBuilder[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteString(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(TimeSpan[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(TimeSpan[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteLong(array[i].Ticks);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(DateTime[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(DateTime[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    WriteDate(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(object[] array) {
            WriteArray(array, true);
        }

        public void WriteArray(object[] array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
                int length = array.Length;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    Serialize(array[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteArray(Array array) {
            WriteArray(array, true);
        }

        public void WriteArray(Array array, bool checkRef) {
            if (WriteRef(array, checkRef)) {
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
        }

        public void WriteList(IList list) {
            WriteList(list, true);
        }

        public void WriteList(IList list, bool checkRef) {
            if (WriteRef(list, checkRef)) {
                int length = list.Count;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    Serialize(list[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteMap(IDictionary map) {
            WriteMap(map, true);
        }

        public void WriteMap(IDictionary map, bool checkRef) {
            if (WriteRef(map, checkRef)) {
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
        }

        public void WriteCollection(ICollection collection) {
            WriteCollection(collection, true);
        }

        public void WriteCollection(ICollection collection, bool checkRef) {
            if (WriteRef(collection, checkRef)) {
                int length = collection.Count;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                foreach (object e in collection) {
                    Serialize(e);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public void WriteIList<T>(IList<T> list) {
            WriteIList(list, true);
        }

        public void WriteIList<T>(IList<T> list, bool checkRef) {
            if (WriteRef(list, checkRef)) {
                int length = list.Count;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                for (int i = 0; i < length; i++) {
                    Serialize(list[i]);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteIMap<TKey, TValue>(IDictionary<TKey, TValue> map) {
            WriteIMap(map, true);
        }

        public void WriteIMap<TKey, TValue>(IDictionary<TKey, TValue> map, bool checkRef) {
            if (WriteRef(map, checkRef)) {
                int length = map.Count;
                stream.WriteByte(HproseTags.TagMap);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                foreach (KeyValuePair<TKey, TValue> e in map) {
                    Serialize(e.Key);
                    Serialize(e.Value);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteICollection<T>(ICollection<T> collection) {
            WriteICollection(collection, true);
        }

        public void WriteICollection<T>(ICollection<T> collection, bool checkRef) {
            if (WriteRef(collection, checkRef)) {
                int length = collection.Count;
                stream.WriteByte(HproseTags.TagList);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                foreach (object e in collection) {
                    Serialize(e);
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }

        public void WriteAnonymousType(object obj) {
            WriteAnonymousType(obj, true);
        }

        public void WriteAnonymousType(object obj, bool checkRef) {
            if (WriteRef(obj, checkRef)) {
                PropertyInfo[] properties = obj.GetType().GetProperties();
                int length = properties.Length;
                stream.WriteByte(HproseTags.TagMap);
                if (length > 0) WriteInt(length, stream);
                stream.WriteByte(HproseTags.TagOpenbrace);
                foreach (PropertyInfo property in properties) {
                    WriteString(property.Name);
                    Serialize(property.GetValue(obj, null));
                }
                stream.WriteByte(HproseTags.TagClosebrace);
            }
        }
#endif

        public void WriteObject(object obj) {
            WriteObject(obj, true);
        }

        public void WriteObject(object obj, bool checkRef) {
            if (checkRef && references.ContainsKey(obj)) {
                WriteRef(obj);
            }
            else {
                Type type = obj.GetType();
                int cr;
#if (dotNET10 || dotNET11 || dotNETCF10)
                if (classref.ContainsKey(type)) {
                    cr = (int)classref[type];
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
        }

        private void WriteSerializableObject(object obj, Type type) {
            if (mode == HproseMode.FieldMode) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                ObjectSerializer.Get(type).SerializeFields(obj, this);
#else
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> fields = HproseHelper.GetFields(type);
                foreach (KeyValuePair<string, MemberInfo> field in fields) {
#else
                Hashtable fields = HproseHelper.GetFields(type);
                foreach (DictionaryEntry field in fields) {
#endif
                    object value;
                    try {
                        value = ((FieldInfo)field.Value).GetValue(obj);
                    }
                    catch (Exception e) {
                        throw new HproseException("The field value can't be serialized.", e);
                    }
                    Serialize(value);
                }
#endif
            }
            else {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                ObjectSerializer.Get(type).SerializeProperties(obj, this);
#else
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> properties = HproseHelper.GetProperties(type);
                foreach (KeyValuePair<string, MemberInfo> property in properties) {
#else
                Hashtable properties = HproseHelper.GetProperties(type);
                foreach (DictionaryEntry property in properties) {
#endif
                    object value;
                    try {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
                        value = PropertyAccessor.Get((PropertyInfo)property.Value).GetValue(obj);
#else
                        value = ((PropertyInfo)property.Value).GetValue(obj, null);
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
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            ObjectSerializer.Get(type).SerializeMembers(obj, this);
#else
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> members = HproseHelper.GetMembers(type);
            foreach (KeyValuePair<string, MemberInfo> member in members) {
#else
            Hashtable members = HproseHelper.GetMembers(type);
            foreach (DictionaryEntry member in members) {
#endif
                object value;
                try {
                    if (member.Value is FieldInfo) {
                        value = ((FieldInfo)member.Value).GetValue(obj);
                    }
                    else {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
                        value = PropertyAccessor.Get((PropertyInfo)member.Value).GetValue(obj);
#else
                        value = ((PropertyInfo)member.Value).GetValue(obj, null);
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
                    if (fieldsCache.ContainsKey(type)) {
                        cache = (SerializeCache)fieldsCache[type];
                    }
#endif
                }
            }
            else {
                c = propertiesCache;
                lock (c.SyncRoot) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                    propertiesCache.TryGetValue(type, out cache);
#else
                    if (propertiesCache.ContainsKey(type)) {
                        cache = (SerializeCache)propertiesCache[type];
                    }
#endif
                }
            }
            if (cache == null) {
                cache = new SerializeCache();
                MemoryStream cachestream = new MemoryStream();
#if !(dotNET10 || dotNET11 || dotNETCF10)
                Dictionary<string, MemberInfo> members;
#else
                Hashtable members;
#endif
                if (mode == HproseMode.FieldMode) {
                    members = HproseHelper.GetFields(type);
                }
                else {
                    members = HproseHelper.GetProperties(type);
                }
                int count = members.Count;
                cachestream.WriteByte(HproseTags.TagClass);
                WriteUTF8String(HproseHelper.GetClassName(type), cachestream);
                if (count > 0) WriteInt(count, cachestream);
                cachestream.WriteByte(HproseTags.TagOpenbrace);
#if !(dotNET10 || dotNET11 || dotNETCF10)
                foreach (KeyValuePair<string, MemberInfo> member in members) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String(member.Key, cachestream);
                    cache.refcount++;
                }
#else
                foreach (DictionaryEntry member in members) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String((string)member.Key, cachestream);
                    cache.refcount++;
                }
#endif
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
                if (membersCache.ContainsKey(type)) {
                    cache = (SerializeCache)membersCache[type];
                }
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
                    cache.refcount++;
                }
#else
                foreach (DictionaryEntry member in members) {
                    cachestream.WriteByte(HproseTags.TagString);
                    WriteUTF8String((string)member.Key, cachestream);
                    cache.refcount++;
                }
#endif
                cachestream.WriteByte(HproseTags.TagClosebrace);
                cache.data = cachestream.ToArray();
                lock (c.SyncRoot) {
                    membersCache[type] = cache;
                }
            }
            return cache;
        }

        private bool WriteRef(object obj, bool checkRef) {
            if (checkRef && references.ContainsKey(obj)) {
                WriteRef(obj);
                return false;
            }
            else {
                references[obj] = lastref++;
                return true;
            }
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