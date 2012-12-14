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
 * LastModified: Dec 13, 2012                             *
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
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
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

        public HproseException UnexpectedTag(int tag) {
            return UnexpectedTag(tag, null);
        }
        
        public HproseException UnexpectedTag(int tag, string expectTags) {
            if (tag == -1) {
                return new HproseException("No byte found in stream");
            }
            else if (expectTags == null) {
                return new HproseException("Unexpected serialize tag '" + (char)tag + "' in stream");
            }
            else {
                return new HproseException("Tag '" + expectTags + "' expected, but '" + (char)tag +
                                          "' found in stream");
            }
        }

        private void CheckTag(int tag, int expectTag) {
            if (tag != expectTag) throw UnexpectedTag(tag, new String((char)expectTag, 1));
        }

        public void CheckTag(int expectTag) {
            CheckTag(stream.ReadByte(), expectTag);
        }

        private int CheckTags(int tag, string expectTags) {
            if (expectTags.IndexOf((char)tag) == -1) throw UnexpectedTag(tag, expectTags);
            return tag;
        }

        public int CheckTags(string expectTags) {
            return CheckTags(stream.ReadByte(), expectTags);
        }

        private StringBuilder ReadUntil(int tag) {
            StringBuilder sb = new StringBuilder();
            int i = stream.ReadByte();
            while ((i != tag) && (i != -1)) {
                sb.Append((char)i);
                i = stream.ReadByte();
            }
            return sb;
        }

        private void SkipUntil(int tag) {
            int i = stream.ReadByte();
            while ((i != tag) && (i != -1)) {
                i = stream.ReadByte();
            }
        }

        public int ReadInt(int tag) {
            int result = 0;
            int sign = 1;
            int i = stream.ReadByte();
            switch (i) {
                case '-':
                    sign = -1;
                    goto case '+';
                case '+':
                    i = stream.ReadByte();
                    break;
            }
            while ((i != tag) && (i != -1)) {
                result *= 10;
                result += (i - '0') * sign;
                i = stream.ReadByte();
            }
            return result;
        }

        private float ParseFloat(StringBuilder value) {
            return ParseFloat(value.ToString());
        }
        
        private float ParseFloat(String value) {
            try {
                return float.Parse(value);
            }
            catch (OverflowException) {
                if (value[0] == '-') {
                    return float.NegativeInfinity;
                }
                else {
                    return float.PositiveInfinity;
                }
            }
        }

        private double ParseDouble(StringBuilder value) {
            return ParseDouble(value.ToString());
        }

        private double ParseDouble(String value) {
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

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public T Unserialize<T>() {
            return (T)Unserialize(typeof(T));
        }
#endif

        public object Unserialize() {
            int tag = stream.ReadByte();
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
                    return ReadDigit(tag);
                case HproseTags.TagInteger:
                    return ReadIntegerWithoutTag();
                case HproseTags.TagLong:
                    return ReadLongWithoutTag();
                case HproseTags.TagDouble:
                    return ReadDoubleWithoutTag();
                case HproseTags.TagNull:
                    return null;
                case HproseTags.TagEmpty:
                    return "";
                case HproseTags.TagTrue:
                    return true;
                case HproseTags.TagFalse:
                    return false;
                case HproseTags.TagNaN:
                    return double.NaN;
                case HproseTags.TagInfinity:
                    return ReadInfinityWithoutTag();
                case HproseTags.TagDate:
                    return ReadDateWithoutTag();
                case HproseTags.TagTime:
                    return ReadDateWithoutTag();
                case HproseTags.TagBytes:
                    return ReadBytesWithoutTag();
                case HproseTags.TagUTF8Char:
                    return ReadUTF8CharWithoutTag();
                case HproseTags.TagString:
                    return ReadStringWithoutTag();
                case HproseTags.TagGuid:
                    return ReadStringWithoutTag();
                case HproseTags.TagList:
                    return ReadListWithoutTag();
                case HproseTags.TagMap:
                    return ReadListWithoutTag();
                case HproseTags.TagClass:
                    ReadClass();
                    return ReadObject(null);
                case HproseTags.TagObject:
                    return ReadObjectWithoutTag(null);
                case HproseTags.TagRef:
                    return ReadRef();
                case HproseTags.TagError:
                    throw new HproseException(ReadString());
                default:
                    throw UnexpectedTag(tag);
            }
        }

        public object Unserialize(Type type) {
            int tag = stream.ReadByte();
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
                    return ReadIntegerWithoutTag(type);
                case HproseTags.TagLong:
                    return ReadLongWithoutTag(type);
                case HproseTags.TagDouble:
                    return ReadDoubleWithoutTag(type);
                case HproseTags.TagNull:
                    return ReadNullWithoutTag(type);
                case HproseTags.TagEmpty:
                    return ReadEmptyWithoutTag(type);
                case HproseTags.TagTrue:
                    return ReadTrueWithoutTag(type);
                case HproseTags.TagFalse:
                    return ReadFalseWithoutTag(type);
                case HproseTags.TagNaN:
                    return ReadNaNWithoutTag(type);
                case HproseTags.TagInfinity:
                    return ReadInfinityWithoutTag(type);
                case HproseTags.TagDate:
                    return ReadDateWithoutTag(type);
                case HproseTags.TagTime:
                    return ReadDateWithoutTag(type);
                case HproseTags.TagBytes:
                    return ReadBytesWithoutTag(type);
                case HproseTags.TagUTF8Char:
                    return ReadUTF8CharWithoutTag(type);
                case HproseTags.TagString:
                    return ReadStringWithoutTag(type);
                case HproseTags.TagGuid:
                    return ReadStringWithoutTag(type);
                case HproseTags.TagList:
                    return ReadListWithoutTag(type);
                case HproseTags.TagMap:
                    return ReadListWithoutTag(type);
                case HproseTags.TagClass:
                    ReadClass();
                    return ReadObject(type);
                case HproseTags.TagObject:
                    return ReadObjectWithoutTag(type);
                case HproseTags.TagRef:
                    return ReadRef(type);
                case HproseTags.TagError:
                    throw new HproseException(ReadString());
                default:
                    throw UnexpectedTag(tag);
            }
        }

        private int ReadDigit(int tag) {
            return tag - '0';
        }

        private object ReadDigit(int tag, Type type) {
            int b = tag - '0';
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Int32:
                case TypeEnum.Object: return b;
                case TypeEnum.Byte: return (byte)b;
                case TypeEnum.SByte: return (sbyte)b;
                case TypeEnum.Int16: return (short)b;
                case TypeEnum.UInt16: return (ushort)b;
                case TypeEnum.UInt32: return (uint)b;
                case TypeEnum.Int64: return (long)b;
                case TypeEnum.UInt64: return (ulong)b;
                case TypeEnum.Char: return (char)tag;
                case TypeEnum.Single: return (float)b;
                case TypeEnum.Double: return (double)b;
                case TypeEnum.Decimal: return (decimal)b;
                case TypeEnum.String: return new string((char)tag, 1);
                case TypeEnum.Boolean: return (tag != '0');
                case TypeEnum.DateTime: return new DateTime((long)b);
                case TypeEnum.BigInteger: return new BigInteger(b);
                case TypeEnum.TimeSpan: return new TimeSpan((long)b);
                case TypeEnum.Enum: return Enum.ToObject(type, b);
                case TypeEnum.StringBuilder: return new StringBuilder(1).Append((char)tag);
            }
            return CastError("Integer", type);
        }

        public int ReadIntegerWithoutTag() {
            return ReadInt(HproseTags.TagSemicolon);
        }

        public int ReadInteger() {
            int tag = stream.ReadByte();
            switch (tag) {
                case '0': return 0;
                case '1': return 1;
                case '2': return 2;
                case '3': return 3;
                case '4': return 4;
                case '5': return 5;
                case '6': return 6;
                case '7': return 7;
                case '8': return 8;
                case '9': return 9;
                case HproseTags.TagInteger: return ReadIntegerWithoutTag();
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadIntegerWithoutTag(Type type) {
            int i = ReadInt(HproseTags.TagSemicolon);
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Int32:
                case TypeEnum.Object: return i;
                case TypeEnum.Byte: return (byte)i;
                case TypeEnum.SByte: return (sbyte)i;
                case TypeEnum.Int16: return (short)i;
                case TypeEnum.UInt16: return (ushort)i;
                case TypeEnum.UInt32: return (uint)i;
                case TypeEnum.Int64: return (long)i;
                case TypeEnum.UInt64: return (ulong)i;
                case TypeEnum.Char: return (char)i;
                case TypeEnum.Single: return (float)i;
                case TypeEnum.Double: return (double)i;
                case TypeEnum.Decimal: return (decimal)i;
                case TypeEnum.String: return i.ToString();
                case TypeEnum.Boolean: return (i != 0);
                case TypeEnum.DateTime: return new DateTime((long)i);
                case TypeEnum.BigInteger: return new BigInteger(i);
                case TypeEnum.TimeSpan: return new TimeSpan((long)i);
                case TypeEnum.Enum: return Enum.ToObject(type, i);
                case TypeEnum.StringBuilder: return new StringBuilder(i.ToString());
            }
            return CastError("Integer", type);
        }

        public object ReadInteger(Type type) {
            int tag = stream.ReadByte();
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
                case '9': return ReadDigit(tag, type);
                case HproseTags.TagInteger: return ReadIntegerWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public BigInteger ReadBigIntegerWithoutTag() {
            return BigInteger.Parse(ReadUntil(HproseTags.TagSemicolon).ToString());
        }

        public BigInteger ReadBigInteger() {
            int tag = stream.ReadByte();
            switch (tag) {
                case '0': return BigInteger.Zero;
                case '1': return BigInteger.One;
                case '2': return new BigInteger(2);
                case '3': return new BigInteger(3);
                case '4': return new BigInteger(4);
                case '5': return new BigInteger(5);
                case '6': return new BigInteger(6);
                case '7': return new BigInteger(7);
                case '8': return new BigInteger(8);
                case '9': return new BigInteger(9);
                case HproseTags.TagInteger:
                case HproseTags.TagLong: return ReadBigIntegerWithoutTag();
                default: throw UnexpectedTag(tag);
            }
        }

        public long ReadLongWithoutTag() {
            return long.Parse(ReadUntil(HproseTags.TagSemicolon).ToString());
        }

        public long ReadLong() {
            int tag = stream.ReadByte();
            switch (tag) {
                case '0': return 0L;
                case '1': return 1L;
                case '2': return 2L;
                case '3': return 3L;
                case '4': return 4L;
                case '5': return 5L;
                case '6': return 6L;
                case '7': return 7L;
                case '8': return 8L;
                case '9': return 9L;
                case HproseTags.TagInteger:
                case HproseTags.TagLong: return ReadLongWithoutTag();
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadLongWithoutTag(Type type) {
            StringBuilder l = ReadUntil(HproseTags.TagSemicolon);
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.BigInteger:
                case TypeEnum.Object: return BigInteger.Parse(l.ToString());
                case TypeEnum.Byte: return byte.Parse(l.ToString());
                case TypeEnum.SByte: return sbyte.Parse(l.ToString());
                case TypeEnum.Int16: return short.Parse(l.ToString());
                case TypeEnum.UInt16: return ushort.Parse(l.ToString());
                case TypeEnum.Int32: return int.Parse(l.ToString());
                case TypeEnum.UInt32: return uint.Parse(l.ToString());
                case TypeEnum.Int64: return long.Parse(l.ToString());
                case TypeEnum.UInt64: return ulong.Parse(l.ToString());
                case TypeEnum.Char: return (char)int.Parse(l.ToString());
                case TypeEnum.Single: return ParseFloat(l);
                case TypeEnum.Double: return ParseDouble(l);
                case TypeEnum.Decimal: return decimal.Parse(l.ToString());
                case TypeEnum.String: return l.ToString();
                case TypeEnum.Boolean: return (int.Parse(l.ToString()) != 0);
                case TypeEnum.DateTime: return new DateTime(long.Parse(l.ToString()));
                case TypeEnum.TimeSpan: return new TimeSpan(long.Parse(l.ToString()));
                case TypeEnum.Enum: return Enum.ToObject(type, long.Parse(l.ToString()));
                case TypeEnum.StringBuilder: return l;
            }
            return CastError("Long", type);
        }

        public object ReadLong(Type type) {
            int tag = stream.ReadByte();
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
                case '9': return ReadDigit(tag, type);
                case HproseTags.TagInteger:
                case HproseTags.TagLong: return ReadLongWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public double ReadDoubleWithoutTag() {
            return ParseDouble(ReadUntil(HproseTags.TagSemicolon));
        }

        public double ReadDouble() {
            int tag = stream.ReadByte();
            switch (tag) {
                case '0': return 0.0;
                case '1': return 1.0;
                case '2': return 2.0;
                case '3': return 3.0;
                case '4': return 4.0;
                case '5': return 5.0;
                case '6': return 6.0;
                case '7': return 7.0;
                case '8': return 8.0;
                case '9': return 9.0;
                case HproseTags.TagInteger:
                case HproseTags.TagLong:
                case HproseTags.TagDouble: return ReadDoubleWithoutTag();
                case HproseTags.TagNaN: return double.NaN;
                case HproseTags.TagInfinity: return ReadInfinityWithoutTag();
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadDoubleWithoutTag(Type type) {
            StringBuilder value = ReadUntil(HproseTags.TagSemicolon);
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Double:
                case TypeEnum.Object: return ParseDouble(value);
                case TypeEnum.Byte: return (byte)ParseDouble(value);
                case TypeEnum.SByte: return (sbyte)ParseDouble(value);
                case TypeEnum.Int16: return (short)ParseDouble(value);
                case TypeEnum.UInt16: return (ushort)ParseDouble(value);
                case TypeEnum.Int32: return (int)ParseDouble(value);
                case TypeEnum.UInt32: return (uint)ParseDouble(value);
                case TypeEnum.Int64: return (long)ParseDouble(value);
                case TypeEnum.UInt64: return (ulong)ParseDouble(value);
                case TypeEnum.Char: return (char)(int)ParseDouble(value);
                case TypeEnum.Single: return ParseFloat(value);
                case TypeEnum.Decimal: return decimal.Parse(value.ToString());
                case TypeEnum.String: return value.ToString();
                case TypeEnum.Boolean: return ((int)(ParseDouble(value)) != 0);
                case TypeEnum.DateTime: return new DateTime((long)ParseDouble(value));
                case TypeEnum.BigInteger: return new BigInteger(ParseDouble(value));
                case TypeEnum.TimeSpan: return new TimeSpan((long)ParseDouble(value));
                case TypeEnum.Enum: return Enum.ToObject(type, (long)ParseDouble(value));
                case TypeEnum.StringBuilder: return value;
            }
            return CastError("Double", type);
        }

        public object ReadDouble(Type type) {
            int tag = stream.ReadByte();
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
                case '9': return ReadDigit(tag, type);
                case HproseTags.TagInteger:
                case HproseTags.TagLong:
                case HproseTags.TagDouble: return ReadDoubleWithoutTag(type);
                case HproseTags.TagNaN: return ReadNaNWithoutTag(type);
                case HproseTags.TagInfinity: return ReadInfinityWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public double ReadNaN() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagNaN: return double.NaN;
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadNaNWithoutTag(Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Double:
                case TypeEnum.Object: return double.NaN;
                case TypeEnum.Single: return float.NaN;
                case TypeEnum.String: return "NaN";
                case TypeEnum.StringBuilder: return new StringBuilder("NaN");
            }
            return CastError("NaN", type);
        }

        public object ReadNaN(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagNaN: return ReadNaNWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public double ReadInfinityWithoutTag() {
            return ((stream.ReadByte() == HproseTags.TagNeg) ?
                double.NegativeInfinity : double.PositiveInfinity);
        }

        public double ReadInfinity() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagInfinity: return ReadInfinityWithoutTag();
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadInfinityWithoutTag(Type type) {
            bool isPosInf = (stream.ReadByte() == HproseTags.TagPos);
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Double:
                case TypeEnum.Object: return (isPosInf ? double.PositiveInfinity : double.NegativeInfinity);
                case TypeEnum.Single: return (isPosInf ? float.PositiveInfinity : float.NegativeInfinity);
                case TypeEnum.String: return (isPosInf ? "Infinity" : "-Infinity");
                case TypeEnum.StringBuilder: return new StringBuilder((isPosInf ? "Infinity" : "-Infinity"));
            }
            return CastError("Infinity", type);
        }

        public object ReadInfinity(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagInfinity: return ReadInfinityWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadNull() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagNull: return null;
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadNullWithoutTag(Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Byte: return (byte)0;
                case TypeEnum.SByte: return (sbyte)0;
                case TypeEnum.Int16: return (short)0;
                case TypeEnum.UInt16: return (ushort)0;
                case TypeEnum.Int32: return 0;
                case TypeEnum.UInt32: return (uint)0;
                case TypeEnum.Int64: return (long)0;
                case TypeEnum.UInt64: return (ulong)0;
                case TypeEnum.Char: return (char)0;
                case TypeEnum.Single: return (float)0;
                case TypeEnum.Double: return (double)0;
                case TypeEnum.Decimal: return (decimal)0;
                case TypeEnum.Boolean: return false;
                case TypeEnum.Enum: return Enum.ToObject(type, 0);
#if !Core
                case TypeEnum.DBNull: return DBNull.Value;
#endif
            }
            return null;
        }

        public object ReadNull(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagNull: return ReadNullWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public String ReadEmpty() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagEmpty: return "";
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadEmptyWithoutTag(Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.String:
                case TypeEnum.Object: return "";
                case TypeEnum.Byte: return (byte)0;
                case TypeEnum.SByte: return (sbyte)0;
                case TypeEnum.Int16: return (short)0;
                case TypeEnum.UInt16: return (ushort)0;
                case TypeEnum.Int32: return 0;
                case TypeEnum.UInt32: return (uint)0;
                case TypeEnum.Int64: return (long)0;
                case TypeEnum.UInt64: return (ulong)0;
                case TypeEnum.Char: return (char)0;
                case TypeEnum.Single: return (float)0;
                case TypeEnum.Double: return (double)0;
                case TypeEnum.Decimal: return (decimal)0;
                case TypeEnum.Boolean: return false;
                case TypeEnum.BigInteger: return BigInteger.Zero;
                case TypeEnum.Enum: return Enum.ToObject(type, 0);
                case TypeEnum.StringBuilder: return new StringBuilder();
                case TypeEnum.CharArray: return new char[0];
                case TypeEnum.ByteArray: return new byte[0];
#if !Core
                case TypeEnum.DBNull: return DBNull.Value;
#endif
            }
            return CastError("Empty String", type);
        }

        public object ReadEmpty(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagEmpty: return ReadEmptyWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public bool ReadBoolean() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagTrue: return true;
                case HproseTags.TagFalse: return false;
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadTrueWithoutTag(Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Boolean:
                case TypeEnum.Object: return true;
                case TypeEnum.Byte: return (byte)1;
                case TypeEnum.SByte: return (sbyte)1;
                case TypeEnum.Int16: return (short)1;
                case TypeEnum.UInt16: return (ushort)1;
                case TypeEnum.Int32: return 1;
                case TypeEnum.UInt32: return (uint)1;
                case TypeEnum.Int64: return (long)1;
                case TypeEnum.UInt64: return (ulong)1;
                case TypeEnum.Char: return 'T';
                case TypeEnum.Single: return (float)1;
                case TypeEnum.Double: return (double)1;
                case TypeEnum.Decimal: return (decimal)1;
                case TypeEnum.String: return bool.TrueString;
                case TypeEnum.BigInteger: return BigInteger.One;
                case TypeEnum.Enum: return Enum.ToObject(type, 1);
                case TypeEnum.StringBuilder: return new StringBuilder(bool.TrueString);
            }
            return CastError("Boolean", type);
        }

        private object ReadFalseWithoutTag(Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Boolean:
                case TypeEnum.Object: return false;
                case TypeEnum.Byte: return (byte)0;
                case TypeEnum.SByte: return (sbyte)0;
                case TypeEnum.Int16: return (short)0;
                case TypeEnum.UInt16: return (ushort)0;
                case TypeEnum.Int32: return 0;
                case TypeEnum.UInt32: return (uint)0;
                case TypeEnum.Int64: return (long)0;
                case TypeEnum.UInt64: return (ulong)0;
                case TypeEnum.Char: return 'F';
                case TypeEnum.Single: return (float)0;
                case TypeEnum.Double: return (double)0;
                case TypeEnum.Decimal: return (decimal)0;
                case TypeEnum.String: return bool.FalseString;
                case TypeEnum.BigInteger: return BigInteger.Zero;
                case TypeEnum.Enum: return Enum.ToObject(type, 0);
                case TypeEnum.StringBuilder: return new StringBuilder(bool.FalseString);
            }
            return CastError("Boolean", type);
        }

        public object ReadBoolean(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagTrue: return ReadTrueWithoutTag(type);
                case HproseTags.TagFalse: return ReadFalseWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        private object ChangeCalendarType(DateTime datetime, Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.DateTime:
                case TypeEnum.Object: return datetime;
                case TypeEnum.TimeSpan: return new TimeSpan(datetime.Ticks);
                case TypeEnum.Int64: return datetime.Ticks;
                case TypeEnum.String: return datetime.ToString();
                case TypeEnum.StringBuilder: return new StringBuilder(datetime.ToString());
            }
            return CastError(datetime, type);
        }

        private DateTime _ReadDate() {
            DateTime datetime;
            int year = stream.ReadByte() - '0';
            year = year * 10 + stream.ReadByte() - '0';
            year = year * 10 + stream.ReadByte() - '0';
            year = year * 10 + stream.ReadByte() - '0';
            int month = stream.ReadByte() - '0';
            month = month * 10 + stream.ReadByte() - '0';
            int day = stream.ReadByte() - '0';
            day = day * 10 + stream.ReadByte() - '0';
            int tag = stream.ReadByte();
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
            return datetime;
        }

        public DateTime ReadDateWithoutTag() {
            DateTime datetime = _ReadDate();
            references.Add(datetime);
            return datetime;
        }

        public DateTime ReadDate() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagDate: return ReadDateWithoutTag();
                case HproseTags.TagRef: return (DateTime)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadDateWithoutTag(Type type) {
            DateTime datetime = _ReadDate();
            object o = ChangeCalendarType(datetime, type);
            references.Add(o);
            return o;
        }

        public object ReadDate(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagDate: return ReadDateWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        private DateTime _ReadTime() {
            int hour = stream.ReadByte() - '0';
            hour = hour * 10 + stream.ReadByte() - '0';
            int minute = stream.ReadByte() - '0';
            minute = minute * 10 + stream.ReadByte() - '0';
            int second = stream.ReadByte() - '0';
            second = second * 10 + stream.ReadByte() - '0';
            int millisecond = 0;
            int tag = stream.ReadByte();
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
            return datetime;
        }

        public DateTime ReadTimeWithoutTag() {
            DateTime datetime = _ReadTime();
            references.Add(datetime);
            return datetime;
        }

        public DateTime ReadTime() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagTime: return ReadTimeWithoutTag();
                case HproseTags.TagRef: return (DateTime)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadTimeWithoutTag(Type type) {
            DateTime datetime = _ReadTime();
            object o = ChangeCalendarType(datetime, type);
            references.Add(o);
            return o;
        }

        public object ReadTime(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagTime: return ReadTimeWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public DateTime ReadDateTime() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagDate: return ReadDateWithoutTag();
                case HproseTags.TagTime: return ReadTimeWithoutTag();
                case HproseTags.TagRef: return (DateTime)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadDateTime(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagDate: return ReadDateWithoutTag(type);
                case HproseTags.TagTime: return ReadTimeWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public byte[] ReadBytesWithoutTag() {
            int len = ReadInt(HproseTags.TagQuote);
            int off = 0;
            byte[] b = new byte[len];
            while (len > 0) {
                int size = stream.Read(b, off, len);
                off += size;
                len -= size;
            }
            stream.ReadByte();
            //CheckTag(HproseTags.TagQuote);
            references.Add(b);
            return b;
        }

        public byte[] ReadBytes() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagBytes: return ReadBytesWithoutTag();
                case HproseTags.TagRef: return (byte[])ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public MemoryStream ReadStreamWithoutTag() {
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
            stream.ReadByte();
            //CheckTag(HproseTags.TagQuote);
            ms.Position = 0;
            references.Add(ms);
            return ms;
        }

        public MemoryStream ReadStream() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagBytes: return ReadStreamWithoutTag();
                case HproseTags.TagRef: return (MemoryStream)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadBytesWithoutTag(Type type) {
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.ByteArray:
                case TypeEnum.Object: return ReadBytesWithoutTag();
                case TypeEnum.Guid: return new Guid(ReadBytesWithoutTag());
                case TypeEnum.Stream:
                case TypeEnum.MemoryStream: return ReadStreamWithoutTag();
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
                case TypeEnum.String: {
                    byte[] buf = ReadBytesWithoutTag();
                    return Encoding.Default.GetString(buf, 0, buf.Length);
                }
                case TypeEnum.StringBuilder: {
                    byte[] buf = ReadBytesWithoutTag();
                    return new StringBuilder(Encoding.Default.GetString(buf, 0, buf.Length));
                }
#endif
            }
            return CastError("byte[]", type);
        }

        public object ReadBytes(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagBytes: return ReadBytesWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        private char ReadUTF8CharAsChar() {
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

        public string ReadUTF8CharWithoutTag() {
            return new string(ReadUTF8CharAsChar(), 1);
        }

        public string ReadUTF8Char() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagUTF8Char: return ReadUTF8CharWithoutTag();
                default: throw UnexpectedTag(tag);
            }
        }

        private object ReadUTF8CharWithoutTag(Type type) {
            char c = ReadUTF8CharAsChar();
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.String: return new string(c, 1);
                case TypeEnum.Object:
                case TypeEnum.Char: return c;
                case TypeEnum.Byte: return (byte)c;
                case TypeEnum.SByte: return (sbyte)c;
                case TypeEnum.Int16: return (short)c;
                case TypeEnum.UInt16: return (ushort)c;
                case TypeEnum.Int32: return (int)c;
                case TypeEnum.UInt32: return (uint)c;
                case TypeEnum.Int64: return (long)c;
                case TypeEnum.UInt64: return (ulong)c;
                case TypeEnum.Single: return (float)c;
                case TypeEnum.Double: return (double)c;
                case TypeEnum.Decimal: return (decimal)c;
                case TypeEnum.Boolean: return "\00Ff".IndexOf(c) > -1;
                case TypeEnum.BigInteger: return new BigInteger((int)c);
                case TypeEnum.Enum: return Enum.ToObject(type, (int)c);
                case TypeEnum.StringBuilder: return new StringBuilder(1).Append(c);
            }
            return CastError("Char", type);
        }

        public object ReadUTF8Char(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagUTF8Char: return ReadUTF8CharWithoutTag(type);
                default: throw UnexpectedTag(tag);
            }
        }

        private char[] ReadChars() {
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
            stream.ReadByte();
            //CheckTag(HproseTags.TagQuote);
            return buf;
        }

        private MemoryStream ReadCharsAsStream() {
            int count = ReadInt(HproseTags.TagQuote);
            // here count is capacity, not the real size
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
            stream.ReadByte();
            //CheckTag(HproseTags.TagQuote);
            ms.Position = 0;
            return ms;
        }

        private String ReadCharsAsString() {
            return new String(ReadChars());
        }

        public String ReadStringWithoutTag() {
            String str = ReadCharsAsString();
            references.Add(str);
            return str;
        }

        public String ReadString() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagString: return ReadStringWithoutTag();
                case HproseTags.TagRef: return (String)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadStringWithoutTag(Type type) {
            object o;
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.String:
                case TypeEnum.Object: o = ReadCharsAsString(); break;
                case TypeEnum.Stream:
                case TypeEnum.MemoryStream: o = ReadCharsAsStream(); break;
                case TypeEnum.ByteArray: o = ReadCharsAsStream().ToArray(); break;
                case TypeEnum.CharArray: o = ReadChars(); break;
                case TypeEnum.StringBuilder: o = new StringBuilder(ReadCharsAsString()); break;
                case TypeEnum.BigInteger: o = BigInteger.Parse(ReadCharsAsString()); break;
                case TypeEnum.Byte: o = byte.Parse(ReadCharsAsString()); break;
                case TypeEnum.SByte: o = sbyte.Parse(ReadCharsAsString()); break;
                case TypeEnum.Int16: o = short.Parse(ReadCharsAsString()); break;
                case TypeEnum.UInt16: o = ushort.Parse(ReadCharsAsString()); break;
                case TypeEnum.Int32: o = int.Parse(ReadCharsAsString()); break;
                case TypeEnum.UInt32: o = uint.Parse(ReadCharsAsString()); break;
                case TypeEnum.Int64: o = long.Parse(ReadCharsAsString()); break;
                case TypeEnum.UInt64: o = ulong.Parse(ReadCharsAsString()); break;
                case TypeEnum.Single: o = ParseFloat(ReadCharsAsString()); break;
                case TypeEnum.Double: o = ParseDouble(ReadCharsAsString()); break;
                case TypeEnum.Decimal: o = decimal.Parse(ReadCharsAsString()); break;
                case TypeEnum.Boolean: o = bool.Parse(ReadCharsAsString()); break;
                case TypeEnum.Guid: o = new Guid(ReadCharsAsString()); break;
                case TypeEnum.DateTime: o = DateTime.Parse(ReadCharsAsString()); break;
                case TypeEnum.TimeSpan: o = TimeSpan.Parse(ReadCharsAsString()); break;
                case TypeEnum.Char: {
                    char[] chars = ReadChars();
                    o = (chars.Length == 1) ? chars[0] : (char)int.Parse(new String(chars));
                    break;
                }
                default:
                    return CastError("String", type);
            }
            references.Add(o);
            return o;
        }

        public object ReadString(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagString: return ReadStringWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        private char[] ReadGuidAsChars() {
            stream.ReadByte();
            //CheckTag(HproseTags.TagOpenbrace);
            char[] buf = new char[36];
            for (int i = 0; i < 36; i++) {
                buf[i] = (char)stream.ReadByte();
            }
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
            return buf;
        }

        public Guid ReadGuidWithoutTag() {
            Guid guid = new Guid(new String(ReadGuidAsChars()));
            references.Add(guid);
            return guid;
        }

        public Guid ReadGuid()  {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagGuid: return ReadGuidWithoutTag();
                case HproseTags.TagRef: return (Guid)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadGuidWithoutTag(Type type) {
            char[] buf = ReadGuidAsChars();
            object o;
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.CharArray: o = buf; break;
                case TypeEnum.String: o = new String(buf); break;
                case TypeEnum.StringBuilder: o = new StringBuilder(new String(buf)); break;
                case TypeEnum.Null:
                case TypeEnum.Guid:
                case TypeEnum.Object: o = new Guid(new String(buf)); break;
                case TypeEnum.ByteArray: o = new Guid(new String(buf)).ToByteArray(); break;
                default: return CastError("Guid", type);
            }
            references.Add(o);
            return o;
        }

        public object ReadGuid(Type type)  {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagGuid: return ReadGuidWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
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

        private Guid[] ReadGuidArray(int count) {
            Guid[] a = new Guid[count];
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a[i] = (Guid)Unserialize(HproseHelper.typeofGuid);
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
                    stream.ReadByte();
                    //CheckTag(HproseTags.TagList);
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
                            stream.ReadByte();
                            //CheckTag(HproseTags.TagClosebrace);
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
                        stream.ReadByte();
                        //CheckTag(HproseTags.TagList);
                        references.Add(null);
                        SkipUntil(HproseTags.TagOpenbrace);
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
                a[i] = Unserialize();
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

#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
        private ArrayList ReadArrayList(int count) {
            ArrayList a = new ArrayList(count);
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Add(Unserialize());
            }
            return a;
        }

        private Queue ReadQuote(int count) {
            Queue a = new Queue(count);
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Enqueue(Unserialize());
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
                a.Push(Unserialize());
            }
            return a;
        }
#endif

        private IList ReadIList(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            IList a = (IList)CtorAccessor.Get(type).NewInstance();
#else
            IList a = (IList)HproseHelper.NewInstance(type);
#endif
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Add(Unserialize());
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

        internal List<object> ReadList(int count) {
            List<object> a = new List<object>(count);
            references.Add(a);
            for (int i = 0; i < count; i++) {
                a.Add(Unserialize());
            }
            return a;
        }

        internal IList<T> ReadIList<T>(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
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
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
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
        public IList ReadListWithoutTag() {
            int count = ReadInt(HproseTags.TagOpenbrace);
#if (dotNET10 || dotNET11 || dotNETCF10)
            IList list = ReadArrayList(count);
#else
            IList list = ReadList(count);
#endif
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
            return list;
        }

        public IList ReadList() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagList: return ReadListWithoutTag();
                case HproseTags.TagRef: return (IList)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadListWithoutTag(Type type) {
            int count = ReadInt(HproseTags.TagOpenbrace);
            object list = null;
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Object:
                case TypeEnum.ICollection:
#if (dotNET10 || dotNET11 || dotNETCF10)
                case TypeEnum.IList: list = ReadArrayList(count); break;
#else
                case TypeEnum.IList: list = ReadList(count); break;
#endif
                case TypeEnum.SByteArray: list = ReadSByteArray(count); break;
                case TypeEnum.Int16Array: list = ReadInt16Array(count); break;
                case TypeEnum.UInt16Array: list = ReadUInt16Array(count); break;
                case TypeEnum.Int32Array: list = ReadInt32Array(count); break;
                case TypeEnum.UInt32Array: list = ReadUInt32Array(count); break;
                case TypeEnum.Int64Array: list = ReadInt64Array(count); break;
                case TypeEnum.UInt64Array: list = ReadUInt64Array(count); break;
                case TypeEnum.SingleArray: list = ReadSingleArray(count); break;
                case TypeEnum.DoubleArray: list = ReadDoubleArray(count); break;
                case TypeEnum.DecimalArray: list = ReadDecimalArray(count); break;
                case TypeEnum.BigIntegerArray: list = ReadBigIntegerArray(count); break;
                case TypeEnum.BooleanArray: list = ReadBooleanArray(count); break;
                case TypeEnum.BytesArray: list = ReadBytesArray(count); break;
                case TypeEnum.CharsArray: list = ReadCharsArray(count); break;
                case TypeEnum.StringArray: list = ReadStringArray(count); break;
                case TypeEnum.StringBuilderArray: list = ReadStringBuilderArray(count); break;
                case TypeEnum.DateTimeArray: list = ReadDateTimeArray(count); break;
                case TypeEnum.TimeSpanArray: list = ReadTimeSpanArray(count); break;
                case TypeEnum.GuidArray: list = ReadGuidArray(count); break;
                case TypeEnum.ObjectArray: list = ReadArray(count); break;
                case TypeEnum.OtherTypeArray: list = ReadArray(type, count); break;
                case TypeEnum.BitArray: list = ReadBitArray(count); break;
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
                case TypeEnum.ArrayList: list = ReadArrayList(count); break;
                case TypeEnum.Queue: list = ReadQuote(count); break;
                case TypeEnum.Stack: list = ReadStack(count); break;
#endif
                default: {
#if !(dotNET10 || dotNET11 || dotNETCF10)
#if Core
                    if (type.GetTypeInfo().IsGenericType) {
#else
                    if (type.IsGenericType) {
#endif
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
                    else
#endif
#if Core
                    if (HproseHelper.typeofIList.GetTypeInfo().IsAssignableFrom(type.GetTypeInfo()) &&
#else
                    if (HproseHelper.typeofIList.IsAssignableFrom(type) &&
#endif
                        HproseHelper.IsInstantiableClass(type)) {
                        list = ReadIList(type, count);
                    }
                    break;
                }
            }
            if (list == null) {
                CastError("List", type);
            }
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
            return list;
        }

        public object ReadList(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagList: return ReadListWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
        private HashMap ReadHashMap(int count) {
            HashMap map = new HashMap(count);
            references.Add(map);
            for (int i = 0; i < count; i++) {
                object key = Unserialize();
                object value = Unserialize();
                map[key] = value;
            }
            return map;
        }
#endif
        private IDictionary ReadIDictionary(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            IDictionary map = (IDictionary)CtorAccessor.Get(type).NewInstance();
#else
            IDictionary map = (IDictionary)HproseHelper.NewInstance(type);
#endif
            references.Add(map);
            for (int i = 0; i < count; i++) {
                object key = Unserialize();
                object value = Unserialize();
                map[key] = value;
            }
            return map;
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        internal HashMap<TKey, TValue> ReadHashMap<TKey, TValue>(int count) {
            HashMap<TKey, TValue> map = new HashMap<TKey, TValue>(count);
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

        internal HashMap<object, object> ReadGHashMap(int count) {
            HashMap<object, object> map = new HashMap<object, object>(count);
            references.Add(map);
            for (int i = 0; i < count; i++) {
                object key = Unserialize();
                object value = Unserialize();
                map[key] = value;
            }
            return map;
        }

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
#if !(PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
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
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            object obj = CtorAccessor.Get(type).NewInstance();
#else
            object obj = HproseHelper.NewInstance(type);
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, FieldInfo> fields = HproseHelper.GetFields(type);
#else
            Hashtable fields = HproseHelper.GetFields(type);
#endif
            references.Add(obj);
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            string[] names = new string[count];
            object[] values = new object[count];
#endif
            FieldInfo field;
            for (int i = 0; i < count; i++) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                names[i] = ReadString();
                if (fields.TryGetValue(names[i], out field)) {
#elif !(dotNET10 || dotNET11 || dotNETCF10)
                if (fields.TryGetValue(ReadString(), out field)) {
#else
                if ((field = (FieldInfo)fields[ReadString()]) != null) {
#endif
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                    values[i] = Unserialize(field.FieldType);
#else
                    field.SetValue(obj, Unserialize(field.FieldType));
#endif
                }
                else {
                    Unserialize();
                }
            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            ObjectFieldModeUnserializer.Get(type, names).Unserialize(obj, values);
#endif
            return obj;
        }

        private object ReadObject2(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            object obj = CtorAccessor.Get(type).NewInstance();
#else
            object obj = HproseHelper.NewInstance(type);
#endif
#if !(dotNET10 || dotNET11 || dotNETCF10)
            Dictionary<string, PropertyInfo> properties = HproseHelper.GetProperties(type);
#else
            Hashtable properties = HproseHelper.GetProperties(type);
#endif
            references.Add(obj);
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            string[] names = new string[count];
            object[] values = new object[count];
#endif
            PropertyInfo property;
            for (int i = 0; i < count; i++) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                names[i] = ReadString();
                if (properties.TryGetValue(names[i], out property)) {
#elif !(dotNET10 || dotNET11 || dotNETCF10)
                if (properties.TryGetValue(ReadString(), out property)) {
#else
                if ((property = (PropertyInfo)properties[ReadString()]) != null) {
#endif
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                    values[i] = Unserialize(property.PropertyType);
#elif (dotNET10 || dotNET11)
                    PropertyAccessor.Get(property).SetValue(obj, Unserialize(property.PropertyType));
#else
                    property.SetValue(obj, Unserialize(property.PropertyType), null);
#endif
                }
                else {
                    Unserialize();
                }
            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            ObjectPropertyModeUnserializer.Get(type, names).Unserialize(obj, values);
#endif
            return obj;
        }


        private object ReadObject3(Type type, int count) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
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
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            string[] names = new string[count];
            object[] values = new object[count];
#endif
            MemberInfo member;
            for (int i = 0; i < count; i++) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                names[i] = ReadString();
                if (members.TryGetValue(names[i], out member)) {
#elif !(dotNET10 || dotNET11 || dotNETCF10)
                if (members.TryGetValue(ReadString(), out member)) {
#else
                if ((member = (MemberInfo)members[ReadString()]) != null) {
#endif
                    Type memberType;
                    if (member is FieldInfo) {
                        FieldInfo field = (FieldInfo)member;
                        memberType = field.FieldType;
#if (PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                        field.SetValue(obj, Unserialize(memberType));
#endif
                    }
                    else {
                        PropertyInfo property = (PropertyInfo)member;
                        memberType = property.PropertyType;
#if (dotNET10 || dotNET11)
                        PropertyAccessor.Get(property).SetValue(obj, Unserialize(memberType));
#elif (PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
                        property.SetValue(obj, Unserialize(memberType), null);
#endif
                    }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                    values[i] = Unserialize(memberType);
#endif
                }
                else {
                    Unserialize();
                }
            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
            ObjectMemberModeUnserializer.Get(type, names).Unserialize(obj, values);
#endif
            return obj;
        }

        public IDictionary ReadMapWithoutTag() {
            int count = ReadInt(HproseTags.TagOpenbrace);
#if !(dotNET10 || dotNET11 || dotNETCF10)
            IDictionary map = ReadGHashMap(count);
#else
            IDictionary map = ReadHashMap(count);
#endif
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
            return map;
        }

        public IDictionary ReadMap() {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagMap: return ReadMapWithoutTag();
                case HproseTags.TagRef: return (IDictionary)ReadRef();
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadMapWithoutTag(Type type) {
            int count = ReadInt(HproseTags.TagOpenbrace);
            object map = null;
            switch (HproseHelper.GetTypeEnum(type)) {
                case TypeEnum.Null:
                case TypeEnum.Object:
#if !(dotNET10 || dotNET11 || dotNETCF10)
                case TypeEnum.IDictionary: map = ReadGHashMap(count); break;
#else
                case TypeEnum.IDictionary: map = ReadHashMap(count); break;
#endif
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
                case TypeEnum.Hashtable:
                case TypeEnum.HashMap: map = ReadHashMap(count); break;
#endif
                default: {
#if !(dotNET10 || dotNET11 || dotNETCF10)
#if Core
                    if (type.GetTypeInfo().IsGenericType) {
#else
                    if (type.IsGenericType) {
#endif
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
                    else
#endif
                    if (HproseHelper.IsInstantiableClass(type)) {
#if Core
                        if (HproseHelper.typeofIDictionary.GetTypeInfo().IsAssignableFrom(type.GetTypeInfo())) {
#else
                        if (HproseHelper.typeofIDictionary.IsAssignableFrom(type)) {
#endif
                            map = ReadIDictionary(type, count);
                        }
                        else if (HproseHelper.IsSerializable(type)) {
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
                    break;
                }
            }
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
            return map;
        }

        public object ReadMap(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagMap: return ReadMapWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        public object ReadObjectWithoutTag(Type type) {
            object c = classref[ReadInt(HproseTags.TagOpenbrace)];
#if !(dotNET10 || dotNET11 || dotNETCF10)
            string[] memberNames = membersref[c];
#else
            string[] memberNames = (string[])membersref[c];
#endif
            int count = memberNames.Length;
            object obj = null;
            if (c is Type) {
                Type cls = (Type)c;
                if ((type == null) ||
#if Core
                    type.GetTypeInfo().IsAssignableFrom(cls.GetTypeInfo())
#else
                    type.IsAssignableFrom(cls)
#endif
                ) type = cls;
            }
            if ((type != null) && HproseHelper.IsInstantiableClass(type)) {
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                obj = CtorAccessor.Get(type).NewInstance();
#else
                obj = HproseHelper.NewInstance(type);
#endif
            }
            if (obj == null) {
#if (dotNET10 || dotNET11 || dotNETCF10)
                Hashtable map = new Hashtable(count);
#else
                Dictionary<string, object> map = new Dictionary<string, object>(count);
#endif
                references.Add(map);
                for (int i = 0; i < count; i++) {
                    map[memberNames[i]] = Unserialize(HproseHelper.typeofObject);
                }
                obj = map;
            }
            else {
                references.Add(obj);
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                object[] values = new object[count];
#endif
                if (HproseHelper.IsSerializable(type)) {
                    if (mode == HproseMode.FieldMode) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                        Dictionary<string, FieldInfo> fields = HproseHelper.GetFields(type);
#else
                        Hashtable fields = HproseHelper.GetFields(type);
#endif
                        FieldInfo field;
                        for (int i = 0; i < count; i++) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                            if (fields.TryGetValue(memberNames[i], out field)) {
#else
                            if ((field = (FieldInfo)fields[memberNames[i]]) != null) {
#endif
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                                values[i] = Unserialize(field.FieldType);
#else
                                field.SetValue(obj, Unserialize(field.FieldType));
#endif
                            }
                            else {
                                Unserialize();
                            }
                        }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                        ObjectFieldModeUnserializer.Get(type, memberNames).Unserialize(obj, values);
#endif
                    }
                    else {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                        Dictionary<string, PropertyInfo> properties = HproseHelper.GetProperties(type);
#else
                        Hashtable properties = HproseHelper.GetProperties(type);
#endif
                        PropertyInfo property;
                        for (int i = 0; i < count; i++) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                            if (properties.TryGetValue(memberNames[i], out property)) {
#else
                            if ((property = (PropertyInfo)properties[memberNames[i]]) != null) {
#endif
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                                values[i] = Unserialize(property.PropertyType);
#elif (dotNET10 || dotNET11)
                                PropertyAccessor.Get(property).SetValue(obj, Unserialize(property.PropertyType));
#else
                                property.SetValue(obj, Unserialize(property.PropertyType), null);
#endif
                            }
                            else {
                                Unserialize();
                            }
                        }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                        ObjectPropertyModeUnserializer.Get(type, memberNames).Unserialize(obj, values);
#endif
                    }
                }
                else {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                    Dictionary<string, MemberInfo> members = HproseHelper.GetMembers(type);
#else
                    Hashtable members = HproseHelper.GetMembers(type);
#endif
                    MemberInfo member;
                    for (int i = 0; i < count; i++) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                        if (members.TryGetValue(memberNames[i], out member)) {
#else
                        if ((member = (MemberInfo)members[memberNames[i]]) != null) {
#endif
                            Type memberType;
                            if (member is FieldInfo) {
                                FieldInfo field = (FieldInfo)member;
                                memberType = field.FieldType;
#if (PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                                field.SetValue(obj, Unserialize(memberType));
#endif
                            }
                            else {
                                PropertyInfo property = (PropertyInfo)member;
                                memberType = property.PropertyType;
#if (dotNET10 || dotNET11)
                                PropertyAccessor.Get(property).SetValue(obj, Unserialize(memberType));
#elif (PocketPC || Smartphone || WindowsCE || SILVERLIGHT || WINDOWS_PHONE || Core)
                                property.SetValue(obj, Unserialize(memberType), null);
#endif
                            }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                            values[i] = Unserialize(memberType);
#endif
                        }
                        else {
                            Unserialize();
                        }
                    }
#if !(PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11 || SILVERLIGHT || WINDOWS_PHONE || Core)
                    ObjectMemberModeUnserializer.Get(type, memberNames).Unserialize(obj, values);
#endif
                }
            }
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
            return obj;
        }

        public object ReadObject(Type type) {
            int tag = stream.ReadByte();
            switch (tag) {
                case HproseTags.TagClass: ReadClass(); return ReadObject(type);
                case HproseTags.TagObject: return ReadObjectWithoutTag(type);
                case HproseTags.TagRef: return ReadRef(type);
                default: throw UnexpectedTag(tag);
            }
        }

        private void ReadClass() {
            string className = ReadCharsAsString();
            int count = ReadInt(HproseTags.TagOpenbrace);
            string[] memberNames = new string[count];
            for (int i = 0; i < count; i++) {
                memberNames[i] = ReadString();
            }
            stream.ReadByte();
            //CheckTag(HproseTags.TagClosebrace);
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

        private object ReadRef() {
            return references[ReadInt(HproseTags.TagSemicolon)];
        }

        private object ReadRef(Type type) {
            object o = references[ReadInt(HproseTags.TagSemicolon)];
            if (type == null ||
#if Core
                type.GetTypeInfo().IsAssignableFrom(o.GetType().GetTypeInfo())) {
#else
                type.IsInstanceOfType(o)) {
#endif
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