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
 * HproseWriter.java                                      *
 *                                                        *
 * hprose writer class for Java.                          *
 *                                                        *
 * LastModified: Jan 4, 2013                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

import hprose.common.HproseException;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Serializable;
import java.lang.ref.SoftReference;
import java.lang.reflect.Array;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TimeZone;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public final class HproseWriter {
    private static final Object[] nullArgs = new Object[0];
    private static final ConcurrentHashMap<Class<?>, SoftReference<SerializeCache>> fieldsCache = new ConcurrentHashMap<Class<?>, SoftReference<SerializeCache>>();
    private static final ConcurrentHashMap<Class<?>, SoftReference<SerializeCache>> propertiesCache = new ConcurrentHashMap<Class<?>, SoftReference<SerializeCache>>();
    private static final ConcurrentHashMap<Class<?>, SoftReference<SerializeCache>> membersCache = new ConcurrentHashMap<Class<?>, SoftReference<SerializeCache>>();
    public final OutputStream stream;
    private final HproseMode mode;
    private final ObjectIntMap ref = new ObjectIntMap();
    private final ObjectIntMap classref = new ObjectIntMap();
    private final byte[] buf = new byte[20];
    private static final byte[] minIntBuf = new byte[] {'-','2','1','4','7','4','8','3','6','4','8'};
    private static final byte[] minLongBuf = new byte[] {'-','9','2','2','3','3','7','2','0','3','6','8','5','4','7','7','5','8','0','8'};
    private int lastref = 0;
    private int lastclassref = 0;

    public HproseWriter(OutputStream stream) {
        this(stream, HproseMode.PropertyMode);
    }

    public HproseWriter(OutputStream stream, HproseMode mode) {
        this.stream = stream;
        this.mode = mode;
    }
    public void serialize(Object obj) throws IOException {
        if (obj == null) {
            writeNull();
        }
        else {
            serialize(obj, TypeCode.get(obj.getClass()));
        }
    }
    
    private void serialize(Object obj, int typecode) throws IOException {
        if (obj == null) {
            writeNull();
        }
        else {
            switch (typecode) {
                case TypeCode.Null: writeNull(); break;
                case TypeCode.BooleanType: writeBoolean((Boolean)obj); break;
                case TypeCode.CharType: writeUTF8Char((Character)obj); break;
                case TypeCode.ByteType: writeInteger((Byte)obj); break;
                case TypeCode.ShortType: writeInteger((Short)obj); break;
                case TypeCode.IntType: writeInteger((Integer)obj); break;
                case TypeCode.LongType: writeLong((Long)obj); break;
                case TypeCode.FloatType: writeDouble((Float)obj); break;
                case TypeCode.DoubleType: writeDouble((Double)obj); break;
                case TypeCode.Enum: writeInteger(((Enum)obj).ordinal()); break;
                case TypeCode.Object: {
                    Class<?> cls = obj.getClass();
                    if (Object.class.equals(cls)) {
                        throw new HproseException("Can't serialize an object of the Object class.");
                    }
                    serialize(obj, TypeCode.get(cls));
                    break;
                }
                case TypeCode.Boolean: writeBoolean((Boolean)obj); break;
                case TypeCode.Character: writeUTF8Char((Character)obj); break;
                case TypeCode.Byte: writeInteger((Byte)obj); break;
                case TypeCode.Short: writeInteger((Short)obj); break;
                case TypeCode.Integer: writeInteger((Integer)obj); break;
                case TypeCode.Long: writeLong((Long)obj); break;
                case TypeCode.Float: writeDouble((Float)obj); break;
                case TypeCode.Double: writeDouble((Double)obj); break;
                case TypeCode.String: {
                    String s = (String)obj;
                    switch (s.length()) {
                        case 0: writeEmpty(); break;
                        case 1: writeUTF8Char(s.charAt(0)); break;
                        default: writeStringWithRef(s); break;
                    }
                    break;
                }
                case TypeCode.BigInteger: writeLong((BigInteger) obj); break;
                case TypeCode.Date: writeDateWithRef((Date) obj); break;
                case TypeCode.Time: writeDateWithRef((Time) obj); break;
                case TypeCode.Timestamp: writeDateWithRef((Timestamp) obj); break;
                case TypeCode.DateTime: writeDateWithRef((java.util.Date) obj); break;
                case TypeCode.Calendar: writeDateWithRef((Calendar) obj); break;
                case TypeCode.BigDecimal: writeDouble((BigDecimal) obj); break;
                case TypeCode.StringBuilder: {
                    StringBuilder s = (StringBuilder)obj;
                    switch (s.length()) {
                        case 0: writeEmpty(); break;
                        case 1: writeUTF8Char(s.charAt(0)); break;
                        default: writeStringWithRef(s); break;
                    }
                    break;
                }
                case TypeCode.StringBuffer: {
                    StringBuffer s = (StringBuffer)obj;
                    switch (s.length()) {
                        case 0: writeEmpty(); break;
                        case 1: writeUTF8Char(s.charAt(0)); break;
                        default: writeStringWithRef(s); break;
                    }
                    break;
                }
                case TypeCode.UUID: writeUUIDWithRef((UUID) obj); break;
                case TypeCode.ObjectArray: writeArrayWithRef((Object[]) obj); break;
                case TypeCode.BooleanArray: writeArrayWithRef((boolean[]) obj); break;
                case TypeCode.CharArray: {
                    char[] cs = (char[]) obj;
                    switch (cs.length) {
                        case 0: writeEmpty(); break;
                        case 1: writeUTF8Char(cs[0]); break;
                        default: writeStringWithRef(cs); break;
                    }
                    break;
                }
                case TypeCode.ByteArray: {
                    if (((byte[]) obj).length == 0) {
                        writeEmpty();
                    }
                    else {
                        writeBytesWithRef((byte[]) obj);
                    }
                    break;
                }
                case TypeCode.ShortArray: writeArrayWithRef((short[]) obj); break;
                case TypeCode.IntArray: writeArrayWithRef((int[]) obj); break;
                case TypeCode.LongArray: writeArrayWithRef((long[]) obj); break;
                case TypeCode.FloatArray: writeArrayWithRef((float[]) obj); break;
                case TypeCode.DoubleArray: writeArrayWithRef((double[]) obj); break;
                case TypeCode.StringArray: writeArrayWithRef((String[]) obj); break;
                case TypeCode.BigIntegerArray: writeArrayWithRef((BigInteger[]) obj); break;
                case TypeCode.DateArray: writeArrayWithRef((Date[]) obj); break;
                case TypeCode.TimeArray: writeArrayWithRef((Time[]) obj); break;
                case TypeCode.TimestampArray: writeArrayWithRef((Timestamp[]) obj); break;
                case TypeCode.DateTimeArray: writeArrayWithRef((java.util.Date[]) obj); break;
                case TypeCode.CalendarArray: writeArrayWithRef((Calendar[]) obj); break;
                case TypeCode.BigDecimalArray: writeArrayWithRef((BigDecimal[]) obj); break;
                case TypeCode.StringBuilderArray: writeArrayWithRef((StringBuilder[]) obj); break;
                case TypeCode.StringBufferArray: writeArrayWithRef((StringBuffer[]) obj); break;
                case TypeCode.UUIDArray: writeArrayWithRef((UUID[]) obj); break;
                case TypeCode.CharsArray: writeArrayWithRef((char[][]) obj); break;
                case TypeCode.BytesArray: writeArrayWithRef((byte[][]) obj); break;
                case TypeCode.OtherTypeArray: writeArrayWithRef(obj); break;
                case TypeCode.ArrayList: writeListWithRef((List) obj); break;
                case TypeCode.AbstractList:
                case TypeCode.AbstractCollection:
                case TypeCode.List:
                case TypeCode.Collection:
                case TypeCode.AbstractSequentialList:
                case TypeCode.LinkedList:
                case TypeCode.HashSet:
                case TypeCode.AbstractSet:
                case TypeCode.Set:
                case TypeCode.TreeSet:
                case TypeCode.SortedSet:
                case TypeCode.CollectionType: writeCollectionWithRef((Collection) obj); break;
                case TypeCode.HashMap:
                case TypeCode.AbstractMap:
                case TypeCode.Map:
                case TypeCode.TreeMap:
                case TypeCode.SortedMap:
                case TypeCode.MapType: writeMapWithRef((Map) obj); break;
                case TypeCode.OtherType: writeObjectWithRef(obj); break;
            }
        }
    }

    public void writeInteger(int i) throws IOException {
        if (i >= 0 && i <= 9) {
            stream.write(i + '0');
        }
        else {
            stream.write(HproseTags.TagInteger);
            writeInt(i);
            stream.write(HproseTags.TagSemicolon);
        }
    }

    public void writeLong(long l) throws IOException {
        if (l >= 0 && l <= 9) {
            stream.write((int)l + '0');
        }
        else {
            stream.write(HproseTags.TagLong);
            writeInt(l);
            stream.write(HproseTags.TagSemicolon);
        }
    }

    public void writeLong(BigInteger l) throws IOException {
        if (l.equals(BigInteger.ZERO)) {
            stream.write('0');
        }
        else if (l.equals(BigInteger.ONE)) {
            stream.write('1');
        }
        else {
            stream.write(HproseTags.TagLong);
            stream.write(getAscii(l.toString()));
            stream.write(HproseTags.TagSemicolon);
        }
    }

    public void writeDouble(double d) throws IOException {
        if (Double.isNaN(d)) {
            stream.write(HproseTags.TagNaN);
        }
        else if (Double.isInfinite(d)) {
            stream.write(HproseTags.TagInfinity);
            stream.write(d > 0 ? HproseTags.TagPos : HproseTags.TagNeg);
        }
        else {
            stream.write(HproseTags.TagDouble);
            stream.write(getAscii(Double.toString(d)));
            stream.write(HproseTags.TagSemicolon);
        }
    }

    public void writeDouble(BigDecimal d) throws IOException {
        stream.write(HproseTags.TagDouble);
        stream.write(getAscii(d.toString()));
        stream.write(HproseTags.TagSemicolon);
    }

    public void writeNaN() throws IOException {
        stream.write(HproseTags.TagNaN);
    }

    public void writeInfinity(boolean positive) throws IOException {
        stream.write(HproseTags.TagInfinity);
        stream.write(positive ? HproseTags.TagPos : HproseTags.TagNeg);
    }

    public void writeNull() throws IOException {
        stream.write(HproseTags.TagNull);
    }

    public void writeEmpty() throws IOException {
        stream.write(HproseTags.TagEmpty);
    }

    public void writeBoolean(boolean b) throws IOException {
        stream.write(b ? HproseTags.TagTrue : HproseTags.TagFalse);
    }

    public void writeDate(Date date) throws IOException {
        ref.put(date, lastref++);
        Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
        calendar.setTime(date);
        writeDateOfCalendar(calendar);
        stream.write(HproseTags.TagSemicolon);
    }

    public void writeDateWithRef(Date date) throws IOException {
        int r = ref.get(date);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeDate(date);
        }
    }

    public void writeDate(Time time) throws IOException {
        ref.put(time, lastref++);
        Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
        calendar.setTime(time);
        writeTimeOfCalendar(calendar, false, false);
        stream.write(HproseTags.TagSemicolon);
    }

    public void writeDateWithRef(Time time) throws IOException {
        int r = ref.get(time);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeDate(time);
        }
    }

    public void writeDate(Timestamp time) throws IOException {
        ref.put(time, lastref++);
        Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
        calendar.setTime(time);
        writeDateOfCalendar(calendar);
        writeTimeOfCalendar(calendar, false, true);
        int nanosecond = time.getNanos();
        if (nanosecond > 0) {
            stream.write(HproseTags.TagPoint);
            stream.write((byte) ('0' + (nanosecond / 100000000 % 10)));
            stream.write((byte) ('0' + (nanosecond / 10000000 % 10)));
            stream.write((byte) ('0' + (nanosecond / 1000000 % 10)));
            if (nanosecond % 1000000 > 0) {
                stream.write((byte) ('0' + (nanosecond / 100000 % 10)));
                stream.write((byte) ('0' + (nanosecond / 10000 % 10)));
                stream.write((byte) ('0' + (nanosecond / 1000 % 10)));
                if (nanosecond % 1000 > 0) {
                    stream.write((byte) ('0' + (nanosecond / 100 % 10)));
                    stream.write((byte) ('0' + (nanosecond / 10 % 10)));
                    stream.write((byte) ('0' + (nanosecond % 10)));
                }
            }
        }
        stream.write(HproseTags.TagSemicolon);
    }

    public void writeDateWithRef(Timestamp time) throws IOException {
        int r = ref.get(time);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeDate(time);
        }
    }

    public void writeDate(java.util.Date date) throws IOException {
        ref.put(date, lastref++);
        Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
        calendar.setTime(date);
        writeDateOfCalendar(calendar);
        writeTimeOfCalendar(calendar, true, false);
        stream.write(HproseTags.TagSemicolon);
    }

    public void writeDateWithRef(java.util.Date date) throws IOException {
        int r = ref.get(date);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeDate(date);
        }
    }

    public void writeDate(Calendar calendar) throws IOException {
        ref.put(calendar, lastref++);
        TimeZone tz = calendar.getTimeZone();
        if (!(tz.hasSameRules(HproseHelper.DefaultTZ) || tz.hasSameRules(HproseHelper.UTC))) {
            tz = HproseHelper.UTC;
            Calendar c = (Calendar) calendar.clone();
            c.setTimeZone(tz);
            calendar = c;
        }
        writeDateOfCalendar(calendar);
        writeTimeOfCalendar(calendar, true, false);
        stream.write(tz.hasSameRules(HproseHelper.UTC) ? HproseTags.TagUTC : HproseTags.TagSemicolon);
    }

    public void writeDateWithRef(Calendar calendar) throws IOException {
        int r = ref.get(calendar);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeDate(calendar);
        }
    }

    public void writeTime(Time time) throws IOException {
        writeDate(time);
    }

    public void writeTimeWithRef(Time time) throws IOException {
        writeDateWithRef(time);
    }

    private void writeDateOfCalendar(Calendar calendar) throws IOException {
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day = calendar.get(Calendar.DAY_OF_MONTH);
        stream.write(HproseTags.TagDate);
        stream.write((byte) ('0' + (year / 1000 % 10)));
        stream.write((byte) ('0' + (year / 100 % 10)));
        stream.write((byte) ('0' + (year / 10 % 10)));
        stream.write((byte) ('0' + (year % 10)));
        stream.write((byte) ('0' + (month / 10 % 10)));
        stream.write((byte) ('0' + (month % 10)));
        stream.write((byte) ('0' + (day / 10 % 10)));
        stream.write((byte) ('0' + (day % 10)));
    }

    private void writeTimeOfCalendar(Calendar calendar, boolean ignoreZero, boolean ignoreMillisecond) throws IOException {
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        int second = calendar.get(Calendar.SECOND);
        int millisecond = calendar.get(Calendar.MILLISECOND);
        if (ignoreZero && hour == 0 && minute == 0 && second == 0 && millisecond == 0) {
            return;
        }
        stream.write(HproseTags.TagTime);
        stream.write((byte) ('0' + (hour / 10 % 10)));
        stream.write((byte) ('0' + (hour % 10)));
        stream.write((byte) ('0' + (minute / 10 % 10)));
        stream.write((byte) ('0' + (minute % 10)));
        stream.write((byte) ('0' + (second / 10 % 10)));
        stream.write((byte) ('0' + (second % 10)));
        if (!ignoreMillisecond && millisecond > 0) {
            stream.write(HproseTags.TagPoint);
            stream.write((byte) ('0' + (millisecond / 100 % 10)));
            stream.write((byte) ('0' + (millisecond / 10 % 10)));
            stream.write((byte) ('0' + (millisecond % 10)));
        }
    }

    public void writeBytes(byte[] bytes) throws IOException {
        ref.put(bytes, lastref++);
        stream.write(HproseTags.TagBytes);
        if (bytes.length > 0) {
            writeInt(bytes.length);
        }
        stream.write(HproseTags.TagQuote);
        stream.write(bytes);
        stream.write(HproseTags.TagQuote);
    }

    public void writeBytesWithRef(byte[] bytes) throws IOException {
        int r = ref.get(bytes);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeBytes(bytes);
        }
    }

    public void writeUTF8Char(int c) throws IOException {
        stream.write(HproseTags.TagUTF8Char);
        if (c < 0x80) {
            stream.write(c);
        }
        else if (c < 0x800) {
            stream.write(0xc0 | (c >>> 6));
            stream.write(0x80 | (c & 0x3f));
        }
        else {
            stream.write(0xe0 | (c >>> 12));
            stream.write(0x80 | ((c >>> 6) & 0x3f));
            stream.write(0x80 | (c & 0x3f));
        }
    }

    public void writeString(String s) throws IOException {
        ref.put(s, lastref++);
        stream.write(HproseTags.TagString);
        writeUTF8String(s, stream);
    }

    public void writeStringWithRef(String s) throws IOException {
        int r = ref.get(s);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeString(s);
        }
    }

    private void writeUTF8String(String s, OutputStream stream) throws IOException {
        int length = s.length();
        if (length > 0) {
            writeInt(length, stream);
        }
        stream.write(HproseTags.TagQuote);
        for (int i = 0; i < length; ++i) {
            int c = 0xffff & s.charAt(i);
            if (c < 0x80) {
                stream.write(c);
            }
            else if (c < 0x800) {
                stream.write(0xc0 | (c >>> 6));
                stream.write(0x80 | (c & 0x3f));
            }
            else if (c < 0xd800 || c > 0xdfff) {
                stream.write(0xe0 | (c >>> 12));
                stream.write(0x80 | ((c >>> 6) & 0x3f));
                stream.write(0x80 | (c & 0x3f));
            }
            else {
                if (++i < length) {
                    int c2 = 0xffff & s.charAt(i);
                    if (c < 0xdc00 && 0xdc00 <= c2 && c2 <= 0xdfff) {
                        c = ((c & 0x03ff) << 10 | (c2 & 0x03ff)) + 0x010000;
                        stream.write(0xf0 | (c >>> 18));
                        stream.write(0x80 | ((c >>> 12) & 0x3f));
                        stream.write(0x80 | ((c >>> 6) & 0x3f));
                        stream.write(0x80 | (c & 0x3f));
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
        stream.write(HproseTags.TagQuote);
    }

    public void writeString(StringBuilder s) throws IOException {
        ref.put(s, lastref++);
        stream.write(HproseTags.TagString);
        writeUTF8String(s.toString(), stream);
    }

    public void writeStringWithRef(StringBuilder s) throws IOException {
        int r = ref.get(s);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeString(s);
        }
    }

    public void writeString(StringBuffer s) throws IOException {
        ref.put(s, lastref++);
        stream.write(HproseTags.TagString);
        writeUTF8String(s.toString(), stream);
    }

    public void writeStringWithRef(StringBuffer s) throws IOException {
        int r = ref.get(s);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeString(s);
        }
    }

    public void writeString(char[] s) throws IOException {
        ref.put(s, lastref++);
        stream.write(HproseTags.TagString);
        writeUTF8String(s);
    }

    public void writeStringWithRef(char[] s) throws IOException {
        int r = ref.get(s);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeString(s);
        }
    }

    private void writeUTF8String(char[] s) throws IOException {
        int length = s.length;
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagQuote);
        for (int i = 0; i < length; ++i) {
            int c = 0xffff & s[i];
            if (c < 0x80) {
                stream.write(c);
            }
            else if (c < 0x800) {
                stream.write(0xc0 | (c >>> 6));
                stream.write(0x80 | (c & 0x3f));
            }
            else if (c < 0xd800 || c > 0xdfff) {
                stream.write(0xe0 | (c >>> 12));
                stream.write(0x80 | ((c >>> 6) & 0x3f));
                stream.write(0x80 | (c & 0x3f));
            }
            else {
                if (++i < length) {
                    int c2 = 0xffff & s[i];
                    if (c < 0xdc00 && 0xdc00 <= c2 && c2 <= 0xdfff) {
                        c = ((c & 0x03ff) << 10 | (c2 & 0x03ff)) + 0x010000;
                        stream.write(0xf0 | ((c >>> 18) & 0x3f));
                        stream.write(0x80 | ((c >>> 12) & 0x3f));
                        stream.write(0x80 | ((c >>> 6) & 0x3f));
                        stream.write(0x80 | (c & 0x3f));
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
        stream.write(HproseTags.TagQuote);
    }
    
    public void writeUUID(UUID uuid) throws IOException {
        ref.put(uuid, lastref++);
        stream.write(HproseTags.TagGuid);
        stream.write(HproseTags.TagOpenbrace);
        stream.write(getAscii(uuid.toString()));
        stream.write(HproseTags.TagClosebrace);
    }
    
    public void writeUUIDWithRef(UUID uuid) throws IOException {
        int r = ref.get(uuid);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeUUID(uuid);
        }
    }

    public void writeArray(short[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            writeInteger(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(short[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(int[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            writeInteger(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(int[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(long[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            writeLong(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(long[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(float[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            writeDouble(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(float[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(double[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            writeDouble(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(double[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(boolean[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            writeBoolean(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(boolean[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(Date[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeDateWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(Date[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(Time[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeDateWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(Time[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(Timestamp[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeDateWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(Timestamp[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(java.util.Date[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeDateWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(java.util.Date[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(Calendar[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeDateWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(Calendar[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(String[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeStringWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(String[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(StringBuilder[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeStringWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(StringBuilder[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(StringBuffer[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeStringWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(StringBuffer[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(UUID[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeUUIDWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(UUID[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(char[][] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeStringWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(char[][] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(byte[][] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeBytesWithRef(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(byte[][] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(BigInteger[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeLong(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(BigInteger[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(BigDecimal[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            if (array[i] == null) {
                writeNull();
            }
            else {
                writeDouble(array[i]);
            }
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(BigDecimal[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(Object[] array) throws IOException {
        ref.put(array, lastref++);
        int length = array.length;
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            serialize(array[i]);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(Object[] array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeArray(Object array) throws IOException {
        ref.put(array, lastref++);
        int length = Array.getLength(array);
        stream.write(HproseTags.TagList);
        if (length > 0) {
            writeInt(length);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < length; ++i) {
            serialize(Array.get(array, i));
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeArrayWithRef(Object array) throws IOException {
        int r = ref.get(array);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeArray(array);
        }
    }

    public void writeCollection(Collection<?> collection) throws IOException {
        ref.put(collection, lastref++);
        int count = collection.size();
        stream.write(HproseTags.TagList);
        if (count > 0) {
            writeInt(count);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (Object item : collection) {
            serialize(item);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeCollectionWithRef(Collection<?> collection) throws IOException {
        int r = ref.get(collection);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeCollection(collection);
        }
    }

    public void writeList(List<?> list) throws IOException {
        ref.put(list, lastref++);
        int count = list.size();
        stream.write(HproseTags.TagList);
        if (count > 0) {
            writeInt(count);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (int i = 0; i < count; ++i) {
            serialize(list.get(i));
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeListWithRef(List<?> list) throws IOException {
        int r = ref.get(list);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeList(list);
        }
    }

    public void writeMap(Map<?, ?> map) throws IOException {
        ref.put(map, lastref++);
        int count = map.size();
        stream.write(HproseTags.TagMap);
        if (count > 0) {
            writeInt(count);
        }
        stream.write(HproseTags.TagOpenbrace);
        for (Entry<?,?> entry : map.entrySet()) {
            serialize(entry.getKey());
            serialize(entry.getValue());
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeMapWithRef(Map<?, ?> map) throws IOException {
        int r = ref.get(map);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeMap(map);
        }
    }

    public void writeObject(Object object) throws IOException {
        Class<?> type = object.getClass();
        int cr = classref.get(type);
        if (cr < 0) {
            cr = writeClass(type);
        }
        ref.put(object, lastref++);
        Map<String, MemberAccessor> members = HproseHelper.getMembers(type, mode);
        stream.write(HproseTags.TagObject);
        writeInt(cr);
        stream.write(HproseTags.TagOpenbrace);
        for (Entry<String, MemberAccessor> entry : members.entrySet()) {
            MemberAccessor member = entry.getValue();
            Object value;
            try {
                value = member.get(object);
            }
            catch (Exception e) {
                throw new HproseException(e.getMessage());
            }
            serialize(value, member.typecode);
        }
        stream.write(HproseTags.TagClosebrace);
    }

    public void writeObjectWithRef(Object object) throws IOException {
        int r = ref.get(object);
        if (r > -1) {
            writeRef(r);
        }
        else {
            writeObject(object);
        }
    }

    private SerializeCache getSerializeCache(Class<?> type, HproseMode mode) {
        SoftReference<SerializeCache> sref =
            (Serializable.class.isAssignableFrom(type)) ?
            (mode == HproseMode.FieldMode) ?
            fieldsCache.get(type) :
            propertiesCache.get(type) :
            membersCache.get(type);
        if (sref != null) {
            return sref.get();
        }
        return null;
    }
    
    private void putSerializeCache(Class<?> type, HproseMode mode, SerializeCache cache) {
        if (Serializable.class.isAssignableFrom(type)) {
            if (mode == HproseMode.FieldMode) {
                fieldsCache.put(type, new SoftReference<SerializeCache>(cache));
            }
            else {
                propertiesCache.put(type, new SoftReference<SerializeCache>(cache));
            }
        }
        else {
            membersCache.put(type, new SoftReference<SerializeCache>(cache));
        }
    }

    private int writeClass(Class<?> type) throws IOException {
        SerializeCache cache = getSerializeCache(type, mode);
        if (cache == null) {
            cache = new SerializeCache();
            ByteArrayOutputStream cachestream = new ByteArrayOutputStream();
            Map<String, MemberAccessor> members = HproseHelper.getMembers(type, mode);
            int count = members.size();
            cachestream.write(HproseTags.TagClass);
            writeUTF8String(HproseHelper.getClassName(type), cachestream);
            if (count > 0) {
                writeInt(count, cachestream);
            }
            cachestream.write(HproseTags.TagOpenbrace);
            for (Entry<String, MemberAccessor> member : members.entrySet()) {
                cachestream.write(HproseTags.TagString);
                writeUTF8String(member.getKey(), cachestream);
                ++cache.refcount;
            }
            cachestream.write(HproseTags.TagClosebrace);
            cache.data = cachestream.toByteArray();
            putSerializeCache(type, mode, cache);
        }
        stream.write(cache.data);
        lastref += cache.refcount;
        int cr = lastclassref++;
        classref.put(type, cr);
        return cr;
    }

    private void writeRef(int r) throws IOException {
        stream.write(HproseTags.TagRef);
        writeInt(r);
        stream.write(HproseTags.TagSemicolon);
    }

    private byte[] getAscii(String s) {
        int size = s.length();
        byte[] b = new byte[size--];
        for (; size >= 0; --size) {
            b[size] = (byte) s.charAt(size);
        }
        return b;
    }

    private void writeInt(int i) throws IOException {
        writeInt(i, stream);
    }

    private void writeInt(int i, OutputStream stream) throws IOException {
        if ((i >= 0) && (i <= 9)) {
            stream.write((byte)('0' + i));
        }
        else if (i == Integer.MIN_VALUE) {
            stream.write(minIntBuf);
        }
        else {
            int off = 20;
            int len = 0;
            boolean neg = false;
            if (i < 0) {
                neg = true;
                i = -i;
            }
            while (i != 0) {
                 buf[--off] = (byte) (i % 10 + '0');
                 ++len;
                 i /= 10;
            }
            if (neg) {
                buf[--off] = '-';
                ++len;
            }
            stream.write(buf, off, len);
        }
    }

    private void writeInt(long i) throws IOException {
        if ((i >= 0) && (i <= 9)) {
            stream.write((byte)('0' + i));
        }
        else if (i == Long.MIN_VALUE) {
            stream.write(minLongBuf);
        }
        else {
            int off = 20;
            int len = 0;
            boolean neg = false;
            if (i < 0) {
                neg = true;
                i = -i;
            }
            while (i != 0) {
                 buf[--off] = (byte) (i % 10 + '0');
                 ++len;
                 i /= 10;
            }
            if (neg) {
                buf[--off] = '-';
                ++len;
            }
            stream.write(buf, off, len);
        }
    }

    public void reset() {
        ref.clear();
        classref.clear();
        lastref = 0;
        lastclassref = 0;
    }

    class SerializeCache {
        byte[] data;
        int refcount;
    }
}