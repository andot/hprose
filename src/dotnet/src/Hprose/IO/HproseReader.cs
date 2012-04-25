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
 * HproseReader.cs                                        *
 *                                                        *
 * hprose reader class for C#.                            *
 *                                                        *
 * LastModified: Apr 25, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
using System.Collections;
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System.Collections.Generic;
#endif
using System.Globalization;
using System.Numerics;
using System.IO;
using System.Text;
using System.Reflection;
using Hprose.Common;
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
using Hprose.Reflection;
#endif

namespace Hprose.IO {
    public sealed class HproseReader {
        public Stream stream;
        private HproseMode mode;
#if !(dotNET10 || dotNET11 || dotNETCF10)
        private List<object> references = new List<object>();
        private List<object> classref = new List<object>();
        private Dictionary<object, string[]> membersref = new Dictionary<object, string[]>();
#else
        private ArrayList references = new ArrayList();
        private ArrayList classref = new ArrayList();
        private Hashtable membersref = new Hashtable();
#endif
        public HproseReader(Stream stream)
            : this(stream, HproseMode.FieldMode) {
        }
        public HproseReader(Stream stream, HproseMode mode) {
            this.stream = stream;
            this.mode = mode;
        }

        public object Unserialize() {
            return Unserialize(stream.ReadByte(), null);
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public T Unserialize<T>() {
            return (T)Unserialize(stream.ReadByte(), typeof(T));
        }
#endif

        public object Unserialize(Type type) {
            return Unserialize(stream.ReadByte(), type);
        }

        private object Unserialize(int tag, Type type) {
            if (type != null && type.IsByRef) {
                type = type.GetElementType();
            }
            switch (tag) {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    return ReadDigit(tag, type);
                case HproseTags.TagInteger:
                    return ReadInteger(type);
                case HproseTags.TagLong:
                    return ReadLong(type);
                case HproseTags.TagDouble:
                    return ReadDouble(type);
                case HproseTags.TagNull:
                    return ReadNull(type);
                case HproseTags.TagEmpty:
                    return ReadEmpty(type);
                case HproseTags.TagTrue:
                    return ReadTrue(type);
                case HproseTags.TagFalse:
                    return ReadFalse(type);
                case HproseTags.TagNaN:
                    return ReadNaN(type);
                case HproseTags.TagInfinity:
                    return ReadInfinity(type);
                case HproseTags.TagDate:
                    return ReadDate(false, type);
                case HproseTags.TagTime:
                    return ReadTime(false, type);
                case HproseTags.TagBytes:
                    return ReadBytes(type);
                case HproseTags.TagUTF8Char:
                    return ReadUTF8Char(type);
                case HproseTags.TagString:
                    return ReadString(false, type);
                case HproseTags.TagGuid:
                    return ReadGuid(false, type);
                case HproseTags.TagList:
                    return ReadList(false, type);
                case HproseTags.TagMap:
                    return ReadMap(false, type);
                case HproseTags.TagClass:
                    ReadClass();
                    return Unserialize(stream.ReadByte(), type);
                case HproseTags.TagObject:
                    return ReadObject(false, type);
                case HproseTags.TagRef:
                    return ReadRef(type);
                case HproseTags.TagError:
                    throw new HproseException((string)ReadString());
                case -1:
                    throw new HproseException("No byte found in stream");
            }
            throw new HproseException("Unexpected serialize tag '" +
                                      (char)tag + "' in stream");
        }

        private object ReadDigit(int tag, Type type) {
            int b = tag - '0';
            if (type == null ||
                type == HproseHelper.typeofInt32 ||
                type == HproseHelper.typeofObject) {
                return b;
            }
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return (byte)b;
                case TypeCode.SByte: return (sbyte)b;
                case TypeCode.Int16: return (short)b;
                case TypeCode.UInt16: return (ushort)b;
                case TypeCode.UInt32: return (uint)b;
                case TypeCode.Int64: return (long)b;
                case TypeCode.UInt64: return (ulong)b;
                case TypeCode.Char: return (char)tag;
                case TypeCode.Single: return (float)b;
                case TypeCode.Double: return (double)b;
                case TypeCode.Decimal: return (decimal)b;
                case TypeCode.String: return new string((char)tag, 1);
                case TypeCode.Boolean: return (tag != '0');
                case TypeCode.DateTime: return new DateTime((long)b);
            }
            if (type == HproseHelper.typeofBigInteger) {
                return new BigInteger(b);
            }
            if (type == HproseHelper.typeofTimeSpan) {
                return new TimeSpan((long)b);
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, b);
            }
            return CastError("Integer", type);
        }

        private object ReadInteger(Type type) {
            if (type == HproseHelper.typeofString) {
                return ReadUntil(HproseTags.TagSemicolon);
            }
            int i = ReadInt(HproseTags.TagSemicolon);
            if (type == null ||
                type == HproseHelper.typeofInt32 ||
                type == HproseHelper.typeofObject) {
                return i;
            }
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return (byte)i;
                case TypeCode.SByte: return (sbyte)i;
                case TypeCode.Int16: return (short)i;
                case TypeCode.UInt16: return (ushort)i;
                case TypeCode.UInt32: return (uint)i;
                case TypeCode.Int64: return (long)i;
                case TypeCode.UInt64: return (ulong)i;
                case TypeCode.Char: return (char)i;
                case TypeCode.Single: return (float)i;
                case TypeCode.Double: return (double)i;
                case TypeCode.Decimal: return (decimal)i;
                case TypeCode.Boolean: return (i != 0);
                case TypeCode.DateTime: return new DateTime((long)i);
            }
            if (type == HproseHelper.typeofBigInteger) {
                return new BigInteger(i);
            }
            if (type == HproseHelper.typeofTimeSpan) {
                return new TimeSpan((long)i);
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, i);
            }
            return CastError("Integer", type);
        }

        private object ReadLong(Type type) {
            string l = ReadUntil(HproseTags.TagSemicolon);
            if (type == null ||
                type == HproseHelper.typeofBigInteger ||
                type == HproseHelper.typeofObject) {
                return BigInteger.Parse(l);
            }
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return byte.Parse(l);
                case TypeCode.SByte: return sbyte.Parse(l);
                case TypeCode.Int16: return short.Parse(l);
                case TypeCode.UInt16: return ushort.Parse(l);
                case TypeCode.Int32: return int.Parse(l);
                case TypeCode.UInt32: return uint.Parse(l);
                case TypeCode.Int64: return long.Parse(l);
                case TypeCode.UInt64: return ulong.Parse(l);
                case TypeCode.Char: return (char)int.Parse(l);
                case TypeCode.Single: return float.Parse(l);
                case TypeCode.Double: return double.Parse(l);
                case TypeCode.Decimal: return decimal.Parse(l);
                case TypeCode.String: return l;
                case TypeCode.Boolean: return (int.Parse(l) != 0);
                case TypeCode.DateTime: return new DateTime(long.Parse(l));
            }
            if (type == HproseHelper.typeofTimeSpan) {
                return new TimeSpan(long.Parse(l));
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, long.Parse(l));
            }
            return CastError("Long", type);
        }

        private object ReadDouble(Type type) {
            String value = ReadUntil(HproseTags.TagSemicolon);
            TypeCode typeCode = Type.GetTypeCode(type);
            switch (typeCode) {
                case TypeCode.String: return value;
                case TypeCode.Decimal: return decimal.Parse(value);
                case TypeCode.Single: return float.Parse(value);
            }
            double d = ParseDouble(value);
            switch (typeCode) {
                case TypeCode.Empty:
                case TypeCode.Double: return d;
                case TypeCode.Byte: return (byte)d;
                case TypeCode.SByte: return (sbyte)d;
                case TypeCode.Int16: return (short)d;
                case TypeCode.UInt16: return (ushort)d;
                case TypeCode.Int32: return (int)d;
                case TypeCode.UInt32: return (uint)d;
                case TypeCode.Int64: return (long)d;
                case TypeCode.UInt64: return (ulong)d;
                case TypeCode.Char: return (char)(int)d;
                case TypeCode.Boolean: return ((int)(d) != 0);
                case TypeCode.DateTime: return new DateTime((long)d);
            }
            if (type == HproseHelper.typeofObject) {
                return d;
            }
            if (type == HproseHelper.typeofBigInteger) {
                return new BigInteger(d);
            }
            if (type == HproseHelper.typeofTimeSpan) {
                return new TimeSpan((long)d);
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, (long)d);
            }
            return CastError("Double", type);
        }

        private object ReadNull(Type type) {
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return (byte)0;
                case TypeCode.SByte: return (sbyte)0;
                case TypeCode.Int16: return (short)0;
                case TypeCode.UInt16: return (ushort)0;
                case TypeCode.Int32: return 0;
                case TypeCode.UInt32: return (uint)0;
                case TypeCode.Int64: return (long)0;
                case TypeCode.UInt64: return (ulong)0;
                case TypeCode.Char: return (char)0;
                case TypeCode.Single: return (float)0;
                case TypeCode.Double: return (double)0;
                case TypeCode.Decimal: return (decimal)0;
                case TypeCode.Boolean: return false;
                case TypeCode.DBNull: return DBNull.Value;
            }
            return null;
        }

        private object ReadEmpty(Type type) {
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Empty:
                case TypeCode.String: return "";
                case TypeCode.Byte: return (byte)0;
                case TypeCode.SByte: return (sbyte)0;
                case TypeCode.Int16: return (short)0;
                case TypeCode.UInt16: return (ushort)0;
                case TypeCode.Int32: return 0;
                case TypeCode.UInt32: return (uint)0;
                case TypeCode.Int64: return (long)0;
                case TypeCode.UInt64: return (ulong)0;
                case TypeCode.Char: return (char)0;
                case TypeCode.Single: return (float)0;
                case TypeCode.Double: return (double)0;
                case TypeCode.Decimal: return (decimal)0;
                case TypeCode.Boolean: return false;
                case TypeCode.DBNull: return DBNull.Value;
            }
            if (type == HproseHelper.typeofObject) {
                return "";
            }
            if (type == HproseHelper.typeofBigInteger) {
                return BigInteger.Zero;
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, 0);
            }
            if (type == HproseHelper.typeofStringBuilder) {
                return new StringBuilder();
            }
            if (type == HproseHelper.typeofCharArray) {
                return new char[0];
            }
            if (type == HproseHelper.typeofByteArray) {
                return new byte[0];
            }
            return CastError("Empty String", type);
        }

        private object ReadTrue(Type type) {
            if (type == null ||
                type == HproseHelper.typeofBoolean ||
                type == HproseHelper.typeofObject) {
                return true;
            }
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return (byte)1;
                case TypeCode.SByte: return (sbyte)1;
                case TypeCode.Int16: return (short)1;
                case TypeCode.UInt16: return (ushort)1;
                case TypeCode.Int32: return 1;
                case TypeCode.UInt32: return (uint)1;
                case TypeCode.Int64: return (long)1;
                case TypeCode.UInt64: return (ulong)1;
                case TypeCode.Char: return 'T';
                case TypeCode.Single: return (float)1;
                case TypeCode.Double: return (double)1;
                case TypeCode.Decimal: return (decimal)1;
                case TypeCode.String: return bool.TrueString;
            }
            if (type == HproseHelper.typeofBigInteger) {
                return BigInteger.One;
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, 1);
            }
            return CastError("Boolean", type);
        }

        private object ReadFalse(Type type) {
            if (type == null ||
                type == HproseHelper.typeofBoolean ||
                type == HproseHelper.typeofObject) {
                return false;
            }
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return (byte)0;
                case TypeCode.SByte: return (sbyte)0;
                case TypeCode.Int16: return (short)0;
                case TypeCode.UInt16: return (ushort)0;
                case TypeCode.Int32: return 0;
                case TypeCode.UInt32: return (uint)0;
                case TypeCode.Int64: return (long)0;
                case TypeCode.UInt64: return (ulong)0;
                case TypeCode.Char: return 'F';
                case TypeCode.Single: return (float)0;
                case TypeCode.Double: return (double)0;
                case TypeCode.Decimal: return (decimal)0;
                case TypeCode.String: return bool.FalseString;
            }
            if (type == HproseHelper.typeofBigInteger) {
                return BigInteger.Zero;
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, 0);
            }
            return CastError("Boolean", type);
        }

        private object ReadNaN(Type type) {
            if (type == null ||
                type == HproseHelper.typeofDouble ||
                type == HproseHelper.typeofObject) {
                return double.NaN;
            }
            if (type == HproseHelper.typeofSingle) {
                return float.NaN;
            }
            if (type == HproseHelper.typeofString) {
                return "NaN";
            }
            return CastError("NaN", type);
        }

        private object ReadInfinity(Type type) {
            if (type == null ||
                type == HproseHelper.typeofDouble ||
                type == HproseHelper.typeofObject) {
                return (stream.ReadByte() == HproseTags.TagPos ?
                    double.PositiveInfinity :
                    double.NegativeInfinity);
            }
            if (type == HproseHelper.typeofSingle) {
                return (stream.ReadByte() == HproseTags.TagPos ?
                    float.PositiveInfinity :
                    float.NegativeInfinity);
            }
            if (type == HproseHelper.typeofString) {
                return (stream.ReadByte() == HproseTags.TagPos ?
                    "Infinity" : "-Infinity");
            }
            return CastError("Infinity", type);
        }

        private object ReadBytes(Type type) {
            if ((type == null) ||
                type == HproseHelper.typeofByteArray ||
                type == HproseHelper.typeofObject) {
                return ReadBytes(false);
            }
            if (type == HproseHelper.typeofGuid) {
                return new Guid(ReadBytes(false));
            }
            if (type == HproseHelper.typeofMemoryStream ||
                type == HproseHelper.typeofStream) {
                return ReadStream(false);
            }
#if !SILVERLIGHT
            if (type == HproseHelper.typeofString) {
                byte[] buf = ReadBytes(false);
                return Encoding.Default.GetString(buf, 0, buf.Length);
            }
#endif
            return CastError("byte[]", type);
        }

        private object ReadUTF8Char(Type type) {
            char c = ReadUTF8Char(false);
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Empty:
                case TypeCode.Char: return c;
                case TypeCode.Byte: return (byte)c;
                case TypeCode.SByte: return (sbyte)c;
                case TypeCode.Int16: return (short)c;
                case TypeCode.UInt16: return (ushort)c;
                case TypeCode.Int32: return (int)c;
                case TypeCode.UInt32: return (uint)c;
                case TypeCode.Int64: return (long)c;
                case TypeCode.UInt64: return (ulong)c;
                case TypeCode.Single: return (float)c;
                case TypeCode.Double: return (double)c;
                case TypeCode.Decimal: return (decimal)c;
                case TypeCode.String: return new string(c, 1);
                case TypeCode.Boolean: return "\00Ff".IndexOf(c) > -1;
            }
            if (type == HproseHelper.typeofObject) {
                return new string(c, 1);
            }
            if (type == HproseHelper.typeofBigInteger) {
                return new BigInteger((int)c);
            }
            if (type.IsEnum) {
                return Enum.ToObject(type, (int)c);
            }
            return CastError("Char", type);
        }

        public void CheckTag(int expectTag, int tag) {
            if (tag != expectTag) {
                throw new HproseException("Tag '" + (char)expectTag +
                                          "' expected, but '" + (char)tag +
                                          "' found in stream");
            }
        }

        public void CheckTag(int expectTag) {
            CheckTag(expectTag, stream.ReadByte());
        }

        public int CheckTags(string expectTags, int tag) {
            if (expectTags.IndexOf((char)tag) == -1) {
                throw new HproseException("Tag '" + expectTags +
                                          "' expected, but '" + (char)tag +
                                          "' found in stream");
            }
            return tag;
        }

        public int CheckTags(string expectTags) {
            return CheckTags(expectTags, stream.ReadByte());
        }

        public string ReadUntil(int tag) {
            StringBuilder sb = new StringBuilder();
            int i = stream.ReadByte();
            while ((i != tag) && (i != -1)) {
                sb.Append((char)i);
                i = stream.ReadByte();
            }
            return sb.ToString();
        }

        public int ReadInt(int tag) {
            int result = 0;
            int sign = 1;
            int i = stream.ReadByte();
            if (i == '+') {
                i = stream.ReadByte();
            }
            else if (i == '-') {
                sign = -1;
                i = stream.ReadByte();
            }
            while ((i != tag) && (i != -1)) {
                result *= 10;
                result += (i - '0') * sign;
                i = stream.ReadByte();
            }
            return result;
        }

        public int ReadInteger() {
            return ReadInteger(true);
        }

        public int ReadInteger(bool includeTag) {
            if (includeTag) {
                int tag = stream.ReadByte();
                if ((tag >= '0') && (tag <= '9')) {
                    return tag - '0';
                }
                CheckTag(HproseTags.TagInteger, tag);
            }
            return ReadInt(HproseTags.TagSemicolon);
        }

        public BigInteger ReadBigInteger() {
            return ReadBigInteger(true);
        }

        public BigInteger ReadBigInteger(bool includeTag) {
            if (includeTag) {
                int tag = stream.ReadByte();
                if ((tag >= '0') && (tag <= '9')) {
                    return new BigInteger(tag - '0');
                }
                CheckTags((char)HproseTags.TagInteger + "" +
                          (char)HproseTags.TagLong, tag);
            }
            return BigInteger.Parse(ReadUntil(HproseTags.TagSemicolon));
        }

        public long ReadLong() {
            return ReadLong(true);
        }

        public long ReadLong(bool includeTag) {
            if (includeTag) {
                int tag = stream.ReadByte();
                if ((tag >= '0') && (tag <= '9')) {
                    return (long)(tag - '0');
                }
                CheckTags((char)HproseTags.TagInteger + "" +
                          (char)HproseTags.TagLong, tag);
            }
            return long.Parse(ReadUntil(HproseTags.TagSemicolon));
        }

        private double ParseDouble(string value) {
            try {
                return double.Parse(value);
            }
            catch (OverflowException) {
                if (value[0] == '-') {
                    return double.NegativeInfinity;
                }
                else {
                    return double.PositiveInfinity;
                }
            }
        }

        public double ReadDouble() {
            return ReadDouble(true);
        }

        public double ReadDouble(bool includeTag) {
            if (includeTag) {
                int tag = stream.ReadByte();
                if ((tag >= '0') && (tag <= '9')) {
                    return (double)(tag - '0');
                }
                CheckTags((char)HproseTags.TagInteger + "" +
                          (char)HproseTags.TagLong + "" +
                          (char)HproseTags.TagDouble + "" +
                          (char)HproseTags.TagNaN + "" +
                          (char)HproseTags.TagInfinity, tag);
                if (tag == HproseTags.TagNaN) {
                    return double.NaN;
                }
                if (tag == HproseTags.TagInfinity) {
                    return ReadInfinity(false);
                }
            }
            return ParseDouble(ReadUntil(HproseTags.TagSemicolon));
        }

        public double ReadNaN() {
            CheckTag(HproseTags.TagNaN);
            return double.NaN;
        }

        public double ReadInfinity() {
            return ReadInfinity(true);
        }

        public double ReadInfinity(bool includeTag) {
            if (includeTag) {
                CheckTag(HproseTags.TagInfinity);
            }
            return ((stream.ReadByte() == HproseTags.TagNeg) ?
                double.NegativeInfinity : double.PositiveInfinity);
        }

        public object ReadNull() {
            CheckTag(HproseTags.TagNull);
            return null;
        }

        public object ReadEmpty() {
            CheckTag(HproseTags.TagEmpty);
            return null;
        }

        public bool ReadBoolean() {
            int tag = CheckTags((char)HproseTags.TagTrue + "" + (char)HproseTags.TagFalse);
            return (tag == HproseTags.TagTrue);
        }

        public object ReadDate() {
            return ReadDate(true, null);
        }

        public object ReadDate(bool includeTag) {
            return ReadDate(includeTag, null);
        }

        public object ReadDate(Type type) {
            return ReadDate(true, type);
        }

        public object ReadDate(bool includeTag, Type type) {
            int tag;
            if (includeTag) {
                tag = CheckTags((char)HproseTags.TagDate + "" +
                                (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
            }
            DateTime datetime;
            int year = stream.ReadByte() - '0';
            year = year * 10 + stream.ReadByte() - '0';
            year = year * 10 + stream.ReadByte() - '0';
            year = year * 10 + stream.ReadByte() - '0';
            int month = stream.ReadByte() - '0';
            month = month * 10 + stream.ReadByte() - '0';
            int day = stream.ReadByte() - '0';
            day = day * 10 + stream.ReadByte() - '0';
            tag = stream.ReadByte();
            if (tag == HproseTags.TagTime) {
                int hour = stream.ReadByte() - '0';
                hour = hour * 10 + stream.ReadByte() - '0';
                int minute = stream.ReadByte() - '0';
                minute = minute * 10 + stream.ReadByte() - '0';
                int second = stream.ReadByte() - '0';
                second = second * 10 + stream.ReadByte() - '0';
                int millisecond = 0;
                tag = stream.ReadByte();
                if (tag == HproseTags.TagPoint) {
                    millisecond = stream.ReadByte() - '0';
                    millisecond = millisecond * 10 + stream.ReadByte() - '0';
                    millisecond = millisecond * 10 + stream.ReadByte() - '0';
                    tag = stream.ReadByte();
                    if ((tag >= '0') && (tag <= '9')) {
                        stream.ReadByte();
                        stream.ReadByte();
                        tag = stream.ReadByte();
                        if ((tag >= '0') && (tag <= '9')) {
                            stream.ReadByte();
                            stream.ReadByte();
                            tag = stream.ReadByte();
                        }
                    }
                }
#if !(dotNET10 || dotNET11 || dotNETCF10)
                DateTimeKind kind = (tag == HproseTags.TagUTC ? DateTimeKind.Utc : DateTimeKind.Local);
                datetime = new DateTime(year, month, day, hour, minute, second, millisecond, kind);
#else
                datetime = new DateTime(year, month, day, hour, minute, second, millisecond);
#endif
            }
            else {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                DateTimeKind kind = (tag == HproseTags.TagUTC ? DateTimeKind.Utc : DateTimeKind.Local);
                datetime = new DateTime(year, month, day, 0, 0, 0, kind);
#else
                datetime = new DateTime(year, month, day);
#endif
            }
            object o = ChangeCalendarType(datetime, type);
            references.Add(o);
            return o;
        }

        public object ReadTime() {
            return ReadTime(true, null);
        }

        public object ReadTime(bool includeTag) {
            return ReadTime(includeTag, null);
        }

        public object ReadTime(Type type) {
            return ReadTime(true, type);
        }

        public object ReadTime(bool includeTag, Type type) {
            int tag;
            if (includeTag) {
                tag = CheckTags((char)HproseTags.TagTime + "" +
                                (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
            }
            int hour = stream.ReadByte() - '0';
            hour = hour * 10 + stream.ReadByte() - '0';
            int minute = stream.ReadByte() - '0';
            minute = minute * 10 + stream.ReadByte() - '0';
            int second = stream.ReadByte() - '0';
            second = second * 10 + stream.ReadByte() - '0';
            int millisecond = 0;
            tag = stream.ReadByte();
            if (tag == HproseTags.TagPoint) {
                millisecond = stream.ReadByte() - '0';
                millisecond = millisecond * 10 + stream.ReadByte() - '0';
                millisecond = millisecond * 10 + stream.ReadByte() - '0';
                tag = stream.ReadByte();
                if ((tag >= '0') && (tag <= '9')) {
                    stream.ReadByte();
                    stream.ReadByte();
                    tag = stream.ReadByte();
                    if ((tag >= '0') && (tag <= '9')) {
                        stream.ReadByte();
                        stream.ReadByte();
                        tag = stream.ReadByte();
                    }
                }
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            DateTimeKind kind = (tag == HproseTags.TagUTC ? DateTimeKind.Utc : DateTimeKind.Local);
            DateTime datetime = new DateTime(1, 1, 1, hour, minute, second, millisecond, kind);
#else
            DateTime datetime = new DateTime(1, 1, 1, hour, minute, second, millisecond);
#endif
            object o = ChangeCalendarType(datetime, type);
            references.Add(o);
            return o;
        }

        public object ReadDateTime() {
            return ReadDateTime(null);
        }

        public object ReadDateTime(Type type) {
            int tag = CheckTags((char)HproseTags.TagDate + "" +
                                (char)HproseTags.TagTime + "" +
                                (char)HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return ReadRef(type);
            }
            if (tag == HproseTags.TagDate) {
                return ReadDate(false, type);
            }
            return ReadTime(false, type);
        }

        private object ChangeCalendarType(DateTime datetime, Type type) {
            if (type == null ||
                type == HproseHelper.typeofDateTime ||
                type == HproseHelper.typeofObject) {
                return datetime;
            }
            if (type == HproseHelper.typeofTimeSpan) {
                return new TimeSpan(datetime.Ticks);
            }
            if (type == HproseHelper.typeofInt64) {
                return datetime.Ticks;
            }
            if (type == HproseHelper.typeofString) {
                return datetime.ToString();
            }
            return CastError(datetime, type);
        }

        public byte[] ReadBytes() {
            return ReadBytes(true);
        }

        public byte[] ReadBytes(bool includeTag) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagBytes + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return (byte[])ReadRef(HproseHelper.typeofByteArray);
                }
            }
            int len = ReadInt(HproseTags.TagQuote);
            int off = 0;
            byte[] b = new byte[len];
            while (len > 0) {
                int size = stream.Read(b, off, len);
                off += size;
                len -= size;
            }
            CheckTag(HproseTags.TagQuote);
            references.Add(b);
            return b;
        }

        public MemoryStream ReadStream() {
            return ReadStream(true);
        }

        public MemoryStream ReadStream(bool includeTag) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagBytes + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return (MemoryStream)ReadRef(HproseHelper.typeofMemoryStream);
                }
            }
            int len = ReadInt(HproseTags.TagQuote);
            int size = 0;
            MemoryStream ms = new MemoryStream(len);
            byte[] buffer;
            if (len > 4096) {
                buffer = new byte[4096];
                for (; len > 4096; len -= size) {
                    size = stream.Read(buffer, 0, 4096);
                    ms.Write(buffer, 0, size);
                }
            }
            else {
                buffer = new byte[len];
            }
            len = stream.Read(buffer, 0, len);
            ms.Write(buffer, 0, len);
            buffer = null;
            CheckTag(HproseTags.TagQuote);
            ms.Position = 0;
            references.Add(ms);
            return ms;
        }

        public char ReadUTF8Char(bool includeTag) {
            if (includeTag) {
                CheckTag(HproseTags.TagUTF8Char);
            }
            char u;
            int c = stream.ReadByte();
            switch (c >> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    u = (char)c;
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    int c2 = stream.ReadByte();
                    u = (char)(((c & 0x1f) << 6) |
                               (c2 & 0x3f));
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    int c2 = stream.ReadByte();
                    int c3 = stream.ReadByte();
                    u = (char)(((c & 0x0f) << 12) |
                              ((c2 & 0x3f) << 6) |
                               (c3 & 0x3f));
                    break;
                }
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                                                  ((c < 0) ? "end of stream" :
                                                  "0x" + (c & 0xff).ToString("x2")));
            }
            return u;
        }

        public object ReadString() {
            return ReadString(true, null, true);
        }

        public object ReadString(bool includeTag) {
            return ReadString(includeTag, null, true);
        }

        public object ReadString(Type type) {
            return ReadString(true, type, true);
        }

        public object ReadString(bool includeTag, Type type) {
            return ReadString(includeTag, type, true);
        }

        private object ReadString(bool includeTag, Type type, bool includeRef) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagString + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
            }
            if (type == HproseHelper.typeofMemoryStream ||
                type == HproseHelper.typeofStream) {
                return ReadStringAsStream(includeRef);
            }
            if (type == HproseHelper.typeofByteArray) {
                return ReadStringAsBytes(includeRef);
            }
            int count = ReadInt(HproseTags.TagQuote);
            char[] buf = new char[count];
            for (int i = 0; i < count; i++) {
                int c = stream.ReadByte();
                switch (c >> 4) {
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7: {
                            // 0xxx xxxx
                            buf[i] = (char)c;
                            break;
                        }
                    case 12:
                    case 13: {
                            // 110x xxxx   10xx xxxx
                            int c2 = stream.ReadByte();
                            buf[i] = (char)(((c & 0x1f) << 6) |
                                             (c2 & 0x3f));
                            break;
                        }
                    case 14: {
                            // 1110 xxxx  10xx xxxx  10xx xxxx
                            int c2 = stream.ReadByte();
                            int c3 = stream.ReadByte();
                            buf[i] = (char)(((c & 0x0f) << 12) |
                                             ((c2 & 0x3f) << 6) |
                                             (c3 & 0x3f));
                            break;
                        }
                    case 15: {
                            // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                            if ((c & 0xf) <= 4) {
                                int c2 = stream.ReadByte();
                                int c3 = stream.ReadByte();
                                int c4 = stream.ReadByte();
                                int s = ((c & 0x07) << 18) |
                                        ((c2 & 0x3f) << 12) |
                                        ((c3 & 0x3f) << 6) |
                                        (c4 & 0x3f) - 0x10000;
                                if (0 <= s && s <= 0xfffff) {
                                    buf[i++] = (char)(((s >> 10) & 0x03ff) | 0xd800);
                                    buf[i] = (char)((s & 0x03ff) | 0xdc00);
                                    break;
                                }
                            }
                            goto default;
                            // no break here!! here need throw exception.
                        }
                    default:
                        throw new HproseException("bad utf-8 encoding at " +
                                                  ((c < 0) ? "end of stream" :
                                                  "0x" + (c & 0xff).ToString("x2")));
                }
            }
            CheckTag(HproseTags.TagQuote);
            object o = ChangeStringType(buf, type);
            if (includeRef) {
                references.Add(o);
            }
            return o;
        }

        private MemoryStream ReadStringAsStream(bool includeRef) {
            int count = ReadInt(HproseTags.TagQuote);
            MemoryStream ms = new MemoryStream(count);
            for (int i = 0; i < count; i++) {
                int c = stream.ReadByte();
                switch (c >> 4) {
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7: {
                            ms.WriteByte((byte)c);
                            break;
                        }
                    case 12:
                    case 13: {
                            int c2 = stream.ReadByte();
                            ms.WriteByte((byte)c);
                            ms.WriteByte((byte)c2);
                            break;
                        }
                    case 14: {
                            int c2 = stream.ReadByte();
                            int c3 = stream.ReadByte();
                            ms.WriteByte((byte)c);
                            ms.WriteByte((byte)c2);
                            ms.WriteByte((byte)c3);
                            break;
                        }
                    case 15: {
                            // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                            if ((c & 0xf) <= 4) {
                                int c2 = stream.ReadByte();
                                int c3 = stream.ReadByte();
                                int c4 = stream.ReadByte();
                                int s = ((c & 0x07) << 18) |
                                        ((c2 & 0x3f) << 12) |
                                        ((c3 & 0x3f) << 6) |
                                        (c4 & 0x3f) - 0x10000;
                                if (0 <= s && s <= 0xfffff) {
                                    ms.WriteByte((byte)c);
                                    ms.WriteByte((byte)c2);
                                    ms.WriteByte((byte)c3);
                                    ms.WriteByte((byte)c4);
                                    break;
                                }
                            }
                            goto default;
                            // no break here!! here need throw exception.
                        }
                    default:
                        throw new HproseException("bad utf-8 encoding at " +
                                                  ((c < 0) ? "end of stream" :
                                                  "0x" + (c & 0xff).ToString("x2")));
                }
            }
            CheckTag(HproseTags.TagQuote);
            ms.Position = 0;
            if (includeRef) {
                references.Add(ms);
            }
            return ms;
        }

        private byte[] ReadStringAsBytes(bool includeRef) {
            byte[] bytes = ReadStringAsStream(false).ToArray();
            if (includeRef) {
                references.Add(bytes);
            }
            return bytes;
        }

        private object ChangeStringType(char[] str, Type type) {
            if (type == HproseHelper.typeofCharArray) {
                return str;
            }
            if (type == HproseHelper.typeofStringBuilder) {
                return new StringBuilder(str.Length).Append(str);
            }
            String s = new String(str);
            if (type == null ||
                type == HproseHelper.typeofString ||
                type == HproseHelper.typeofObject) {
                return s;
            }
            if (type == HproseHelper.typeofBigInteger) {
                return BigInteger.Parse(s);
            }
            switch (Type.GetTypeCode(type)) {
                case TypeCode.Byte: return byte.Parse(s);
                case TypeCode.SByte: return sbyte.Parse(s);
                case TypeCode.Int16: return short.Parse(s);
                case TypeCode.UInt16: return ushort.Parse(s);
                case TypeCode.Int32: return int.Parse(s);
                case TypeCode.UInt32: return uint.Parse(s);
                case TypeCode.Int64: return long.Parse(s);
                case TypeCode.UInt64: return ulong.Parse(s);
                case TypeCode.Single: return float.Parse(s);
                case TypeCode.Double: return ParseDouble(s);
                case TypeCode.Decimal: return decimal.Parse(s);
                case TypeCode.Boolean: return bool.Parse(s);
                case TypeCode.Char:
                    if (str.Length == 1) {
                        return str[0];
                    }
                    else {
                        return (char)int.Parse(s);
                    }
            }
            if (type == HproseHelper.typeofGuid) {
                return new Guid(s);
            }
            return CastError(str, type);
        }

        public object ReadGuid()  {
            return ReadGuid(true, null);
        }

        public object ReadGuid(bool includeTag) {
            return ReadGuid(includeTag, null);
        }

        public object ReadGuid(Type type) {
            return ReadGuid(true, type);
        }

        public object ReadGuid(bool includeTag, Type type) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagGuid + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
            }
            CheckTag(HproseTags.TagOpenbrace);
            char[] buf = new char[36];
            for (int i = 0; i < 36; i++) {
                buf[i] = (char)stream.ReadByte();
            }
            CheckTag(HproseTags.TagClosebrace);
            object o = ChangeGuidType(buf, type);
            references.Add(o);
            return o;
        }

        private object ChangeGuidType(char[] buf, Type type) {
            if (type == HproseHelper.typeofCharArray) {
                return buf;
            }
            String s = new String(buf);
            if (type == HproseHelper.typeofString) {
                return s;
            }
            if (type == HproseHelper.typeofStringBuilder) {
                return new StringBuilder(s);
            }
            Guid g = new Guid(s);
            if (type == null ||
                type == HproseHelper.typeofGuid ||
                type == HproseHelper.typeofObject) {
                return g;
            }
            if (type == HproseHelper.typeofByteArray) {
                return g.ToByteArray();
            }
            return CastError(g, type);
        }

        private sbyte[] ReadSByteArray(int count) {
            sbyte[] a = new sbyte[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (sbyte)Unserialize(HproseHelper.typeofSByte);
            }
            return a;
        }

        private short[] ReadInt16Array(int count) {
            short[] a = new short[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (short)Unserialize(HproseHelper.typeofInt16);
            }
            return a;
        }

        private ushort[] ReadUInt16Array(int count) {
            ushort[] a = new ushort[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (ushort)Unserialize(HproseHelper.typeofUInt16);
            }
            return a;
        }

        private int[] ReadInt32Array(int count) {
            int[] a = new int[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (int)Unserialize(HproseHelper.typeofInt32);
            }
            return a;
        }

        private uint[] ReadUInt32Array(int count) {
            uint[] a = new uint[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (uint)Unserialize(HproseHelper.typeofUInt32);
            }
            return a;
        }

        private long[] ReadInt64Array(int count) {
            long[] a = new long[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (long)Unserialize(HproseHelper.typeofInt64);
            }
            return a;
        }

        private ulong[] ReadUInt64Array(int count) {
            ulong[] a = new ulong[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (ulong)Unserialize(HproseHelper.typeofUInt64);
            }
            return a;
        }

        private float[] ReadSingleArray(int count) {
            float[] a = new float[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (float)Unserialize(HproseHelper.typeofSingle);
            }
            return a;
        }

        private double[] ReadDoubleArray(int count) {
            double[] a = new double[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (double)Unserialize(HproseHelper.typeofDouble);
            }
            return a;
        }

        private decimal[] ReadDecimalArray(int count) {
            decimal[] a = new decimal[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (decimal)Unserialize(HproseHelper.typeofDecimal);
            }
            return a;
        }

        private bool[] ReadBooleanArray(int count) {
            bool[] a = new bool[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (bool)Unserialize(HproseHelper.typeofBoolean);
            }
            return a;
        }

        private BigInteger[] ReadBigIntegerArray(int count) {
            BigInteger[] a = new BigInteger[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (BigInteger)Unserialize(HproseHelper.typeofBigInteger);
            }
            return a;
        }

        private string[] ReadStringArray(int count) {
            string[] a = new string[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (string)Unserialize(HproseHelper.typeofString);
            }
            return a;
        }

        private StringBuilder[] ReadStringBuilderArray(int count) {
            StringBuilder[] a = new StringBuilder[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (StringBuilder)Unserialize(HproseHelper.typeofStringBuilder);
            }
            return a;
        }

        private byte[][] ReadBytesArray(int count) {
            byte[][] a = new byte[count][];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (byte[])Unserialize(HproseHelper.typeofByteArray);
            }
            return a;
        }

        private char[][] ReadCharsArray(int count) {
            char[][] a = new char[count][];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (char[])Unserialize(HproseHelper.typeofCharArray);
            }
            return a;
        }

        private DateTime[] ReadDateTimeArray(int count) {
            DateTime[] a = new DateTime[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (DateTime)Unserialize(HproseHelper.typeofDateTime);
            }
            return a;
        }

        private TimeSpan[] ReadTimeSpanArray(int count) {
            TimeSpan[] a = new TimeSpan[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (TimeSpan)Unserialize(HproseHelper.typeofTimeSpan);
            }
            return a;
        }

        private Array ReadArray(Type type, int count) {
#if !dotNETCF10
            int rank = type.GetArrayRank();
#endif
            Type elementType = type.GetElementType();
#if !dotNETCF10
            if (rank == 1) {
#endif
                Array a = Array.CreateInstance(elementType, count);
                references.Add(a);
                for (int i = 0; i < count; i++) {
                    a.SetValue(Unserialize(elementType), i);
                }
                return a;
#if !dotNETCF10
            }
            else {
                int i;
                int[] loc = new int[rank];
                int[] len = new int[rank];
                int maxrank = rank - 1;
                len[0] = count;
                for (i = 1; i < rank; i++) {
                    CheckTag(HproseTags.TagList);
                    len[i] = ReadInt(HproseTags.TagOpenbrace);
                }
                Array a = Array.CreateInstance(elementType, len);
                references.Add(a);
                for (i = 1; i < rank; i++) {
                    references.Add(null);
                }
                while (true) {
                    for (loc[maxrank] = 0;
                         loc[maxrank] < len[maxrank];
                         loc[maxrank]++) {
                        a.SetValue(Unserialize(elementType), loc);
                    }
                    for (i = maxrank; i > 0; i--) {
                        if (loc[i] >= len[i]) {
                            loc[i] = 0;
                            loc[i - 1]++;
                            CheckTag(HproseTags.TagClosebrace);
                        }
                    }
                    if (loc[0] >= len[0]) {
                        break;
                    }
                    int n = 0;
                    for (i = maxrank; i > 0; i--) {
                        if (loc[i] == 0) {
                            n++;
                        }
                        else {
                            break;
                        }
                    }
                    for (i = rank - n; i < rank; i++) {
                        CheckTag(HproseTags.TagList);
                        references.Add(null);
                        ReadUntil(HproseTags.TagOpenbrace);
                    }
                }
                return a;
            }
#endif
        }

        public void ReadArray(Type[] types, object[] a, int count) {
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = Unserialize(types[i]);
            }
        }

        public object[] ReadArray(int count) {
            object[] a = new object[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = Unserialize(HproseHelper.typeofObject);
            }
            return a;
        }

        private ArrayList ReadArrayList(int count) {
            ArrayList a = new ArrayList(count);
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Add(Unserialize(HproseHelper.typeofObject));
            }
            return a;
        }

        private BitArray ReadBitArray(int count) {
            BitArray a = new BitArray(count);
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (bool)Unserialize(HproseHelper.typeofBoolean);
            }
            return a;
        }

        private Queue ReadQuote(int count) {
            Queue a = new Queue(count);
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Enqueue(Unserialize(HproseHelper.typeofObject));
            }
            return a;
        }

        private Stack ReadStack(int count) {
#if !dotNETCF10
            Stack a = new Stack(count);
#else
            Stack a = new Stack();
#endif
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Push(Unserialize(HproseHelper.typeofObject));
            }
            return a;
        }

        private IList ReadIList(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            IList a = (IList)CtorAccessor.Get(type).NewInstance();
#else
            IList a = (IList)HproseHelper.NewInstance(type);
#endif
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Add(Unserialize(HproseHelper.typeofObject));
            }
            return a;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal List<T> ReadList<T>(int count) {
            List<T> a = new List<T>(count);
            references.Add(a);
            Type t = typeof(T);
            for (int i = 0; i < count; i++) {
                a.Add((T)Unserialize(t));
            }
            return a;
        }

        internal IList<T> ReadIList<T>(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
            IList<T> a = (IList<T>)CtorAccessor.Get(type).NewInstance();
#else
            IList<T> a = (IList<T>)HproseHelper.NewInstance(type);
#endif
            references.Add(a);
            Type t = typeof(T);
            for (int i = 0; i < count; i++) {
                a.Add((T)Unserialize(t));
            }
            return a;
        }

        internal ICollection<T> ReadICollection<T>(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
            ICollection<T> a = (ICollection<T>)CtorAccessor.Get(type).NewInstance();
#else
            ICollection<T> a = (ICollection<T>)HproseHelper.NewInstance(type);
#endif
            references.Add(a);
            Type t = typeof(T);
            for (int i = 0; i < count; i++) {
                a.Add((T)Unserialize(t));
            }
            return a;
        }
#endif

        public object ReadList() {
            return ReadList(true, null);
        }

        public object ReadList(bool includeTag) {
            return ReadList(includeTag, null);
        }

        public object ReadList(Type type) {
            return ReadList(true, type);
        }

        public object ReadList(bool includeTag, Type type) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagList + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
            }
            int count = ReadInt(HproseTags.TagOpenbrace);
            object list = null;
            if (type == null ||
                type == HproseHelper.typeofObject ||
                type == HproseHelper.typeofICollection ||
                type == HproseHelper.typeofIList ||
                type == HproseHelper.typeofArrayList) {
                list = ReadArrayList(count);
            }
            else if (type == HproseHelper.typeofSByteArray) {
                list = ReadSByteArray(count);
            }
            else if (type == HproseHelper.typeofInt16Array) {
                list = ReadInt16Array(count);
            }
            else if (type == HproseHelper.typeofUInt16Array) {
                list = ReadUInt16Array(count);
            }
            else if (type == HproseHelper.typeofInt32Array) {
                list = ReadInt32Array(count);
            }
            else if (type == HproseHelper.typeofUInt32Array) {
                list = ReadUInt32Array(count);
            }
            else if (type == HproseHelper.typeofInt64Array) {
                list = ReadInt64Array(count);
            }
            else if (type == HproseHelper.typeofUInt64Array) {
                list = ReadUInt64Array(count);
            }
            else if (type == HproseHelper.typeofSingleArray) {
                list = ReadSingleArray(count);
            }
            else if (type == HproseHelper.typeofDoubleArray) {
                list = ReadDoubleArray(count);
            }
            else if (type == HproseHelper.typeofDecimalArray) {
                list = ReadDecimalArray(count);
            }
            else if (type == HproseHelper.typeofBigIntegerArray) {
                list = ReadBigIntegerArray(count);
            }
            else if (type == HproseHelper.typeofBooleanArray) {
                list = ReadBooleanArray(count);
            }
            else if (type == HproseHelper.typeofBytesArray) {
                list = ReadBytesArray(count);
            }
            else if (type == HproseHelper.typeofCharsArray) {
                list = ReadCharsArray(count);
            }
            else if (type == HproseHelper.typeofStringArray) {
                list = ReadStringArray(count);
            }
            else if (type == HproseHelper.typeofStringBuilderArray) {
                list = ReadStringBuilderArray(count);
            }
            else if (type == HproseHelper.typeofDateTimeArray) {
                list = ReadDateTimeArray(count);
            }
            else if (type == HproseHelper.typeofTimeSpanArray) {
                list = ReadTimeSpanArray(count);
            }
            else if (type == HproseHelper.typeofObjectArray) {
                list = ReadArray(count);
            }
            else if (type.IsArray) {
                list = ReadArray(type, count);
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            else if (type.IsGenericType) {
                IGListReader listReader = HproseHelper.GetIGListReader(type);
                if (listReader != null) {
                    list = listReader.ReadList(this, count);
                }
                else {
                    IGIListReader ilistReader = HproseHelper.GetIGIListReader(type);
                    if (ilistReader != null) {
                        list = ilistReader.ReadIList(this, type, count);
                    }
                    else {
                        IGICollectionReader iCollectionReader = HproseHelper.GetIGICollectionReader(type);
                        if (iCollectionReader != null) {
                            list = iCollectionReader.ReadICollection(this, type, count);
                        }
                    }
                }
            }
#endif
            else if (HproseHelper.IsInstantiableClass(type)) {
                if (type == HproseHelper.typeofBitArray) {
                    list = ReadBitArray(count);
                }
                else if (type == HproseHelper.typeofQueue) {
                    list = ReadQuote(count);
                }
                else if (type == HproseHelper.typeofStack) {
                    list = ReadStack(count);
                }
                else if (HproseHelper.typeofIList.IsAssignableFrom(type)) {
                    list = ReadIList(type, count);
                }
            }
            if (list == null) {
                CastError("List", type);
            }
            CheckTag(HproseTags.TagClosebrace);
            return list;
        }

        private HashMap ReadHashMap(int count) {
            HashMap map = new HashMap(count);
            references.Add(map);
            for (int i = 0; i < count; i++) {
                object key = Unserialize(HproseHelper.typeofObject);
                object value = Unserialize(HproseHelper.typeofObject);
                map[key] = value;
            }
            return map;
        }

        private IDictionary ReadIDictionary(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            IDictionary map = (IDictionary)CtorAccessor.Get(type).NewInstance();
#else
            IDictionary map = (IDictionary)HproseHelper.NewInstance(type);
#endif
            references.Add(map);
            for (int i = 0; i < count; i++) {
                object key = Unserialize(HproseHelper.typeofObject);
                object value = Unserialize(HproseHelper.typeofObject);
                map[key] = value;
            }
            return map;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal Dictionary<TKey, TValue> ReadMap<TKey, TValue>(int count) {
            Dictionary<TKey, TValue> map = new Dictionary<TKey, TValue>(count);
            references.Add(map);
            Type k = typeof(TKey);
            Type v = typeof(TValue);
            for (int i = 0; i < count; i++) {
                TKey key = (TKey)Unserialize(k);
                TValue value = (TValue)Unserialize(v);
                map[key] = value;
            }
            return map;
        }

        internal IDictionary<TKey, TValue> ReadIMap<TKey, TValue>(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
            IDictionary<TKey, TValue> map = (IDictionary<TKey, TValue>)CtorAccessor.Get(type).NewInstance();
#else
            IDictionary<TKey, TValue> map = (IDictionary<TKey, TValue>)HproseHelper.NewInstance(type);
#endif
            references.Add(map);
            Type k = typeof(TKey);
            Type v = typeof(TValue);
            for (int i = 0; i < count; i++) {
                TKey key = (TKey)Unserialize(k);
                TValue value = (TValue)Unserialize(v);
                map[key] = value;
            }
            return map;
        }
#endif

        private object ReadObject(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            object obj = CtorAccessor.Get(type).NewInstance();
#else
            object obj = HproseHelper.NewInstance(type);
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> fields = HproseHelper.GetFields(type);
#else
            Hashtable fields = HproseHelper.GetFields(type);
#endif
            references.Add(obj);
            string[] names = new string[count];
            object[] values = new object[count];
            for (int i = 0; i < count; i++) {
                names[i] = (string)ReadString();
                FieldInfo field = (FieldInfo)fields[names[i]];
                values[i] = Unserialize(field.FieldType);
            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            ObjectFieldModeUnserializer.Get(type, names).Unserialize(obj, values);
#else
            for (int i = 0; i < count; i++) {
                FieldInfo field = (FieldInfo)fields[names[i]];
                field.SetValue(obj, values[i]);
            }
#endif
            return obj;
        }

        private object ReadObject2(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            object obj = CtorAccessor.Get(type).NewInstance();
#else
            object obj = HproseHelper.NewInstance(type);
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> properties = HproseHelper.GetProperties(type);
#else
            Hashtable properties = HproseHelper.GetProperties(type);
#endif
            references.Add(obj);
            string[] names = new string[count];
            object[] values = new object[count];
            for (int i = 0; i < count; i++) {
                names[i] = (string)ReadString();
                PropertyInfo property = (PropertyInfo)properties[names[i]];
                values[i] = Unserialize(property.PropertyType);
            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            ObjectPropertyModeUnserializer.Get(type, names).Unserialize(obj, values);
#else
            for (int i = 0; i < count; i++) {
                PropertyInfo property = (PropertyInfo)properties[names[i]];
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
                PropertyAccessor.Get(property).SetValue(obj, values[i]);
#else
                property.SetValue(obj, values[i], null);
#endif
            }
#endif
            return obj;
        }


        private object ReadObject3(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            object obj = CtorAccessor.Get(type).NewInstance();
#else
            object obj = HproseHelper.NewInstance(type);
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> members = HproseHelper.GetMembers(type);
#else
            Hashtable members = HproseHelper.GetMembers(type);
#endif
            references.Add(obj);
            string[] names = new string[count];
            object[] values = new object[count];
            for (int i = 0; i < count; i++) {
                names[i] = (string)ReadString();
                Type memberType;
#if !(dotNET10 || dotNET11 || dotNETCF10)
                MemberInfo member = members[names[i]];
#else
                MemberInfo member = (MemberInfo)members[names[i]];
#endif
                if (member is FieldInfo) {
                    memberType = ((FieldInfo)member).FieldType;
                }
                else {
                    memberType = ((PropertyInfo)member).PropertyType;
                }
                values[i] = Unserialize(memberType);
            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
            ObjectMemberModeUnserializer.Get(type, names).Unserialize(obj, values);
#else
            for (int i = 0; i < count; i++) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                MemberInfo member = members[names[i]];
#else
                MemberInfo member = (MemberInfo)members[names[i]];
#endif
                if (member is FieldInfo) {
                    ((FieldInfo)member).SetValue(obj, values[i]);
                }
                else {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
                    PropertyAccessor.Get((PropertyInfo)member).SetValue(obj, values[i]);
#else
                    ((PropertyInfo)member).SetValue(obj, values[i], null);
#endif
                }
            }
#endif
            return obj;
        }

        public object ReadMap() {
            return ReadMap(true, null);
        }

        public object ReadMap(bool includeTag) {
            return ReadMap(includeTag, null);
        }

        public object ReadMap(Type type) {
            return ReadMap(true, type);
        }

        public object ReadMap(bool includeTag, Type type) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagMap + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
            }
            int count = ReadInt(HproseTags.TagOpenbrace);
            object map = null;
            if (type == null ||
                type == HproseHelper.typeofObject ||
                type == HproseHelper.typeofIDictionary ||
                type == HproseHelper.typeofHashtable ||
                type == HproseHelper.typeofHashMap) {
                map = ReadHashMap(count);
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            else if (type.IsGenericType) {
                IGMapReader mapReader = HproseHelper.GetIGMapReader(type);
                if (mapReader != null) {
                    map = mapReader.ReadMap(this, count);
                }
                else {
                    IGIMapReader imapReader = HproseHelper.GetIGIMapReader(type);
                    if (imapReader != null) {
                        map = imapReader.ReadIMap(this, type, count);
                    }
                }
            }
#endif
            else if (HproseHelper.IsInstantiableClass(type) &&
                     HproseHelper.typeofIDictionary.IsAssignableFrom(type)) {
                map = ReadIDictionary(type, count);
            }
            if (map == null) {
                if (HproseHelper.IsInstantiableClass(type)) {
                    if (HproseHelper.IsSerializable(type)) {
                        if (mode == HproseMode.FieldMode) {
                            map = ReadObject(type, count);
                        }
                        else {
                            map = ReadObject2(type, count);
                        }
                    }
                    else {
                        map = ReadObject3(type, count);
                    }
                }
                else {
                    CastError("Map", type);
                }
            }
            CheckTag(HproseTags.TagClosebrace);
            return map;
        }

        public object ReadObject() {
            return ReadObject(true, null);
        }

        public object ReadObject(bool includeTag) {
            return ReadObject(includeTag, null);
        }

        public object ReadObject(Type type) {
            return ReadObject(true, type);
        }

        public object ReadObject(bool includeTag, Type type) {
            if (includeTag) {
                int tag = CheckTags((char)HproseTags.TagObject + "" +
                                    (char)HproseTags.TagClass + "" +
                                    (char)HproseTags.TagRef);
                if (tag == HproseTags.TagRef) {
                    return ReadRef(type);
                }
                if (tag == HproseTags.TagClass) {
                    ReadClass();
                    return ReadObject(type);
                }
            }
            object c = classref[ReadInt(HproseTags.TagOpenbrace)];
            string[] memberNames = (string[])membersref[c];
            int count = memberNames.Length;
            object obj = null;
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, MemberInfo> members = null;
#else
            Hashtable members = null;
#endif
            if (c is Type) {
                Type cls = (Type)c;
                if ((type == null) || type.IsAssignableFrom(cls)) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                    obj = CtorAccessor.Get(cls).NewInstance();
#else
                    obj = HproseHelper.NewInstance(cls);
#endif
                    if (obj != null) {
                        if (HproseHelper.IsSerializable(cls)) {
                            if (mode == HproseMode.FieldMode) {
                                members = HproseHelper.GetFields(cls);
                            }
                            else {
                                members = HproseHelper.GetProperties(cls);
                            }
                        }
                        else {
                            members = HproseHelper.GetMembers(cls);
                        }
                    }
                    type = cls;
                }
                else if (HproseHelper.IsInstantiableClass(type)) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                    obj = CtorAccessor.Get(type).NewInstance();
#else
                    obj = HproseHelper.NewInstance(type);
#endif
                }
            }
            else if ((type != null) && HproseHelper.IsInstantiableClass(type)) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                obj = CtorAccessor.Get(type).NewInstance();
#else
                obj = HproseHelper.NewInstance(type);
#endif
            }
            if ((obj != null) && (members == null)) {
                if (HproseHelper.IsSerializable(type)) {
                    if (mode == HproseMode.FieldMode) {
                        members = HproseHelper.GetFields(type);
                    }
                    else {
                        members = HproseHelper.GetProperties(type);
                    }
                }
                else {
                    members = HproseHelper.GetMembers(type);
                }
            }
            if (obj == null) {
                Hashtable map = new Hashtable(count);
                references.Add(map);
                for (int i = 0; i < count; i++) {
                    map[memberNames[i]] = Unserialize(HproseHelper.typeofObject);
                }
                obj = map;
            }
            else {
                references.Add(obj);
                object[] values = new object[count];
                if (HproseHelper.IsSerializable(type)) {
                    if (mode == HproseMode.FieldMode) {
                        FieldInfo field;
                        for (int i = 0; i < count; i++) {
                            field = (FieldInfo)members[memberNames[i]];
                            values[i] = Unserialize(field.FieldType);
                        }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                        ObjectFieldModeUnserializer.Get(type, memberNames).Unserialize(obj, values);
#else
                        for (int i = 0; i < count; i++) {
                            field = (FieldInfo)members[memberNames[i]];
                            field.SetValue(obj, values[i]);
                        }
#endif
                    }
                    else {
                        PropertyInfo property;
                        for (int i = 0; i < count; i++) {
                            property = (PropertyInfo)members[memberNames[i]];
                            values[i] = Unserialize(property.PropertyType);
                        }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                        ObjectPropertyModeUnserializer.Get(type, memberNames).Unserialize(obj, values);
#else
                        for (int i = 0; i < count; i++) {
                            property = (PropertyInfo)members[memberNames[i]];
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
                            PropertyAccessor.Get(property).SetValue(obj, values[i]);
#else
                            property.SetValue(obj, values[i], null);
#endif
                        }
#endif
                    }
                }
                else {
                        MemberInfo member;
                        for (int i = 0; i < count; i++) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                            member = members[memberNames[i]];
#else
                            member = (MemberInfo)members[memberNames[i]];
#endif
                            if (member is FieldInfo) {
                                values[i] = Unserialize(((FieldInfo)member).FieldType);
                            }
                            else {
                                values[i] = Unserialize(((PropertyInfo)member).PropertyType);
                            }
                        }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || WP70 || SL5)
                        ObjectMemberModeUnserializer.Get(type, memberNames).Unserialize(obj, values);
#else
                        for (int i = 0; i < count; i++) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                            member = members[memberNames[i]];
#else
                            member = (MemberInfo)members[memberNames[i]];
#endif
                            if (member is FieldInfo) {
                                ((FieldInfo)member).SetValue(obj, values[i]);
                            }
                            else {
#if !(PocketPC || Smartphone || WindowsCE || WP70 || SL5)
                                PropertyAccessor.Get((PropertyInfo)member).SetValue(obj, values[i]);
#else
                                ((PropertyInfo)member).SetValue(obj, values[i], null);
#endif
                            }
                        }
#endif
                }
            }
            CheckTag(HproseTags.TagClosebrace);
            return obj;
        }

        private void ReadClass() {
            string className = (string)ReadString(false, null, false);
            int count = ReadInt(HproseTags.TagOpenbrace);
            string[] memberNames = new string[count];
            for (int i = 0; i < count; i++) {
                memberNames[i] = (string)ReadString(true);
            }
            CheckTag(HproseTags.TagClosebrace);
            Type type = HproseHelper.GetClass(className);
            if (type == null) {
                object key = new object();
                classref.Add(key);
                membersref[key] = memberNames;
            }
            else {
                classref.Add(type);
                membersref[type] = memberNames;
            }
        }

        private object ReadRef(Type type) {
            object o = references[ReadInt(HproseTags.TagSemicolon)];
            if (type == null || type.IsInstanceOfType(o)) {
                return o;
            }
            return CastError(o, type);
        }

        private object CastError(string srctype, Type desttype) {
            throw new HproseException(srctype + " can't change to " + desttype.FullName);
        }

        private object CastError(object obj, Type type) {
            throw new HproseException(obj.GetType().FullName + " can't change to " + type.FullName);
        }
    
        public MemoryStream ReadRaw() {
            MemoryStream ostream = new MemoryStream();
            ReadRaw(ostream);
            return ostream;
        }

        public void ReadRaw(Stream ostream) {
            ReadRaw(ostream, stream.ReadByte());
        }

        private void ReadRaw(Stream ostream, int tag) {
            switch (tag) {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                case HproseTags.TagNull:
                case HproseTags.TagEmpty:
                case HproseTags.TagTrue:
                case HproseTags.TagFalse:
                case HproseTags.TagNaN:
                    ostream.WriteByte((byte)tag);
                    break;
                case HproseTags.TagInfinity:
                    ostream.WriteByte((byte)tag);
                    ostream.WriteByte((byte)stream.ReadByte());
                    break;
                case HproseTags.TagInteger:
                case HproseTags.TagLong:
                case HproseTags.TagDouble:
                case HproseTags.TagRef:
                    ReadNumberRaw(ostream, tag);
                    break;
                case HproseTags.TagDate:
                case HproseTags.TagTime:
                    ReadDateTimeRaw(ostream, tag);
                    break;
                case HproseTags.TagUTF8Char:
                    ReadUTF8CharRaw(ostream, tag);
                    break;
                case HproseTags.TagBytes:
                    ReadBytesRaw(ostream, tag);
                    break;
                case HproseTags.TagString:
                    ReadStringRaw(ostream, tag);
                    break;
                case HproseTags.TagGuid:
                    ReadGuidRaw(ostream, tag);
                    break;
                case HproseTags.TagList:
                case HproseTags.TagMap:
                case HproseTags.TagObject:
                    ReadComplexRaw(ostream, tag);
                    break;
                case HproseTags.TagClass:
                    ReadComplexRaw(ostream, tag);
                    ReadRaw(ostream);
                    break;
                case HproseTags.TagError:
                    ostream.WriteByte((byte)tag);
                    ReadRaw(ostream);
                    break;
                case -1:
                    throw new HproseException("No byte found in stream");
                default:
                    throw new HproseException("Unexpected serialize tag '" +
                            (char) tag + "' in stream");
            }
        }

        private void ReadNumberRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            do {
                tag = stream.ReadByte();
                ostream.WriteByte((byte)tag);
            } while (tag != HproseTags.TagSemicolon);        
        }
        
        private void ReadDateTimeRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            do {
                tag = stream.ReadByte();
                ostream.WriteByte((byte)tag);
            } while (tag != HproseTags.TagSemicolon &&
                     tag != HproseTags.TagUTC);
        }

        private void ReadUTF8CharRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            tag = stream.ReadByte();
            switch (tag >> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    ostream.WriteByte((byte)tag);
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    ostream.WriteByte((byte)tag);
                    ostream.WriteByte((byte)stream.ReadByte());
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    ostream.WriteByte((byte)tag);
                    ostream.WriteByte((byte)stream.ReadByte());
                    ostream.WriteByte((byte)stream.ReadByte());
                    break;
                }
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                                              ((tag < 0) ? "end of stream" :
                                                  "0x" + (tag & 0xff).ToString("x2")));
            }
        }

        private void ReadBytesRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            int len = 0;
            tag = '0';
            do {
                len *= 10;
                len += tag - '0';
                tag = stream.ReadByte();
                ostream.WriteByte((byte)tag);
            } while (tag != HproseTags.TagQuote);
            int off = 0;
            byte[] b = new byte[len];
            while (len > 0) {
                int size = stream.Read(b, off, len);
                off += size;
                len -= size;
            }
            ostream.Write(b, 0, b.Length);
            ostream.WriteByte((byte)stream.ReadByte());
        }

        private void ReadStringRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            int count = 0;
            tag = '0';
            do {
                count *= 10;
                count += tag - '0';
                tag = stream.ReadByte();
                ostream.WriteByte((byte)tag);
            } while (tag != HproseTags.TagQuote);
            for (int i = 0; i < count; i++) {
                tag = stream.ReadByte();
                switch (tag >> 4) {
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7: {
                        // 0xxx xxxx
                        ostream.WriteByte((byte)tag);
                        break;
                    }
                    case 12:
                    case 13: {
                        // 110x xxxx   10xx xxxx
                        ostream.WriteByte((byte)tag);
                        ostream.WriteByte((byte)stream.ReadByte());
                        break;
                    }
                    case 14: {
                        // 1110 xxxx  10xx xxxx  10xx xxxx
                        ostream.WriteByte((byte)tag);
                        ostream.WriteByte((byte)stream.ReadByte());
                        ostream.WriteByte((byte)stream.ReadByte());
                        break;
                    }
                    case 15: {
                        // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                        if ((tag & 0xf) <= 4) {
                            ostream.WriteByte((byte)tag);
                            ostream.WriteByte((byte)stream.ReadByte());
                            ostream.WriteByte((byte)stream.ReadByte());
                            ostream.WriteByte((byte)stream.ReadByte());
                            break;
                        }
                        goto default;
                    // no break here!! here need throw exception.
                    }
                    default:
                        throw new HproseException("bad utf-8 encoding at " +
                                                  ((tag < 0) ? "end of stream" :
                                                      "0x" + (tag & 0xff).ToString("x2")));
                }
            }
            ostream.WriteByte((byte)stream.ReadByte());
        }

        private void ReadGuidRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            int len = 38;
            int off = 0;
            byte[] b = new byte[len];
            while (len > 0) {
                int size = stream.Read(b, off, len);
                off += size;
                len -= size;
            }
            ostream.Write(b, 0, b.Length);
        }

        private void ReadComplexRaw(Stream ostream, int tag) {
            ostream.WriteByte((byte)tag);
            do {
                tag = stream.ReadByte();
                ostream.WriteByte((byte)tag);
            } while (tag != HproseTags.TagOpenbrace);
            while ((tag = stream.ReadByte()) != HproseTags.TagClosebrace) {
                ReadRaw(ostream, tag);
            }
            ostream.WriteByte((byte)tag);
        }
        
        public void Reset() {
            references.Clear();
            classref.Clear();
            membersref.Clear();
        }
    }
}