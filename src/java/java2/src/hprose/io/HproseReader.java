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
 * HproseReader.java                                      *
 *                                                        *
 * hprose reader class for Java.                          *
 *                                                        *
 * LastModified: Nov 1, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

import hprose.common.HproseException;
import hprose.common.UUID;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.Serializable;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.AbstractCollection;
import java.util.AbstractList;
import java.util.AbstractMap;
import java.util.AbstractSequentialList;
import java.util.AbstractSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.Stack;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;

public final class HproseReader {

    public final InputStream stream;
    private final HproseMode mode;
    private final List ref = new ArrayList();
    private final List classref = new ArrayList();
    private final HashMap membersref = new HashMap();
    private static final Object[] nullArgs = new Object[0];

    public HproseReader(InputStream stream) {
        this(stream, HproseMode.FieldMode);
    }

    public HproseReader(InputStream stream, HproseMode mode) {
        this.stream = stream;
        this.mode = mode;
    }

    public Object unserialize() throws IOException {
        return unserialize(stream.read(), null);
    }

    public Object unserialize(Class type) throws IOException {
        return unserialize(stream.read(), type);
    }

    private Object unserialize(int tag, Class type) throws IOException {
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
                return readDigit(tag, type);
            case HproseTags.TagInteger:
                return readInteger(type);
            case HproseTags.TagLong:
                return readLong(type);
            case HproseTags.TagDouble:
                return readDouble(type);
            case HproseTags.TagNull:
                return readNull(type);
            case HproseTags.TagEmpty:
                return readEmpty(type);
            case HproseTags.TagTrue:
                return readTrue(type);
            case HproseTags.TagFalse:
                return readFalse(type);
            case HproseTags.TagNaN:
                return readNaN(type);
            case HproseTags.TagInfinity:
                return readInfinity(type);
            case HproseTags.TagDate:
                return readDate(false, type);
            case HproseTags.TagTime:
                return readTime(false, type);
            case HproseTags.TagBytes:
                return readBytes(type);
            case HproseTags.TagUTF8Char:
                return readUTF8Char(type);
            case HproseTags.TagString:
                return readString(false, type);
            case HproseTags.TagGuid:
                return readUUID(false, type);
            case HproseTags.TagList:
                return readList(false, type);
            case HproseTags.TagMap:
                return readMap(false, type);
            case HproseTags.TagClass:
                readClass();
                return unserialize(stream.read(), type);
            case HproseTags.TagObject:
                return readObject(false, type);
            case HproseTags.TagRef:
                return readRef(type);
            case HproseTags.TagError:
                throw new HproseException((String)readString());
            case -1:
                throw new HproseException("No byte found in stream");
        }
        throw new HproseException("Unexpected serialize tag '" +
                                  (char) tag + "' in stream");
    }

    private Object readDigit(int tag, Class type) throws IOException {
        if ((type == null) ||
            int.class.equals(type) ||
            Integer.class.equals(type) ||
            Number.class.equals(type) ||
            Object.class.equals(type)) {
            return HproseHelper.valueOf((int)(tag - '0'));
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return HproseHelper.valueOf((byte)(tag - '0'));
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return HproseHelper.valueOf((long)(tag - '0'));
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return HproseHelper.valueOf((short)(tag - '0'));
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return HproseHelper.valueOf((float)(tag - '0'));
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return HproseHelper.valueOf((double)(tag - '0'));
        }
        if (BigInteger.class.equals(type)) {
            return BigInteger.valueOf((long)(tag - '0'));
        }
        if (BigDecimal.class.equals(type)) {
            return BigDecimal.valueOf((long)(tag - '0'));
        }
        if (String.class.equals(type)) {
            return String.valueOf((char)tag);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf((char)tag);
        }
        if (boolean.class.equals(type) ||
            Boolean.class.equals(type)) {
            return HproseHelper.valueOf(tag != '0');
        }
        if (Calendar.class.equals(type)) {
            Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
            calendar.setTimeInMillis((long)(tag - '0'));
            return calendar;
        }
        if (Date.class.equals(type)) {
            return new Date((long)(tag - '0'));
        }
        if (java.sql.Date.class.equals(type)) {
            return new java.sql.Date((long)(tag - '0'));
        }
        if (java.sql.Time.class.equals(type)) {
            return new java.sql.Time((long)(tag - '0'));
        }
        if (java.sql.Timestamp.class.equals(type)) {
            return new java.sql.Timestamp((long)(tag - '0'));
        }
        if ((HproseHelper.enumClass != null) &&
             HproseHelper.enumClass.isAssignableFrom(type)) {
             return getEnum(type, (int)(tag - '0'));
        }
        return castError("Integer", type);
    }

    private Object readInteger(Class type) throws IOException {
        if ((type == null) ||
            int.class.equals(type) ||
            Integer.class.equals(type) ||
            Number.class.equals(type) ||
            Object.class.equals(type)) {
            return new Integer(readInt(HproseTags.TagSemicolon));
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return new Byte(readByte(HproseTags.TagSemicolon));
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return new Long(readLong(HproseTags.TagSemicolon));
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return new Short(readShort(HproseTags.TagSemicolon));
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return new Float(readUntil(HproseTags.TagSemicolon));
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return new Double(readUntil(HproseTags.TagSemicolon));
        }
        if (BigInteger.class.equals(type)) {
            return new BigInteger(readUntil(HproseTags.TagSemicolon));
        }
        if (BigDecimal.class.equals(type)) {
            return new BigDecimal(readUntil(HproseTags.TagSemicolon));
        }
        if (String.class.equals(type)) {
            return readUntil(HproseTags.TagSemicolon);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf((char) readInteger(false));
        }
        if (boolean.class.equals(type) ||
            Boolean.class.equals(type)) {
            return HproseHelper.valueOf(readInteger(false) != 0);
        }
        if (Calendar.class.equals(type)) {
            Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
            calendar.setTimeInMillis(readLong(false));
            return calendar;
        }
        if (Date.class.equals(type)) {
            return new Date(readLong(false));
        }
        if (java.sql.Date.class.equals(type)) {
            return new java.sql.Date(readLong(false));
        }
        if (java.sql.Time.class.equals(type)) {
            return new java.sql.Time(readLong(false));
        }
        if (java.sql.Timestamp.class.equals(type)) {
            return new java.sql.Timestamp(readLong(false));
        }
        if ((HproseHelper.enumClass != null) &&
             HproseHelper.enumClass.isAssignableFrom(type)) {
             return readEnum(type, false);
        }
        return castError("Integer", type);
    }

    private Object readLong(Class type) throws IOException {
        if ((type == null) ||
            BigInteger.class.equals(type) ||
            Number.class.equals(type) ||
            Object.class.equals(type)) {
            return new BigInteger(readUntil(HproseTags.TagSemicolon));
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return new Long(readLong(HproseTags.TagSemicolon));
        }
        if (int.class.equals(type) ||
            Integer.class.equals(type)) {
            return new Integer(readInt(HproseTags.TagSemicolon));
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return new Float(readUntil(HproseTags.TagSemicolon));
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return new Double(readUntil(HproseTags.TagSemicolon));
        }
        if (BigDecimal.class.equals(type)) {
            return new BigDecimal(readUntil(HproseTags.TagSemicolon));
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return new Byte(readByte(HproseTags.TagSemicolon));
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return new Short(readShort(HproseTags.TagSemicolon));
        }
        if (String.class.equals(type)) {
            return readUntil(HproseTags.TagSemicolon);
        }
        if (boolean.class.equals(type) ||
            Boolean.class.equals(type)) {
            return HproseHelper.valueOf(readLong(false) != 0);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf((char) readLong(false));
        }
        if (Calendar.class.equals(type)) {
            Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
            calendar.setTimeInMillis(readLong(false));
            return calendar;
        }
        if (Date.class.equals(type)) {
            return new Date(readLong(false));
        }
        if (java.sql.Date.class.equals(type)) {
            return new java.sql.Date(readLong(false));
        }
        if (java.sql.Time.class.equals(type)) {
            return new java.sql.Time(readLong(false));
        }
        if (java.sql.Timestamp.class.equals(type)) {
            return new java.sql.Timestamp(readLong(false));
        }
        if ((HproseHelper.enumClass != null) &&
             HproseHelper.enumClass.isAssignableFrom(type)) {
             return readEnum(type, false);
        }
        return castError("Long", type);
    }

    private Object readDouble(Class type) throws IOException {
        if ((type == null) ||
            double.class.equals(type) ||
            Double.class.equals(type) ||
            Number.class.equals(type) ||
            Object.class.equals(type)) {
            return new Double(readUntil(HproseTags.TagSemicolon));
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return new Float(readUntil(HproseTags.TagSemicolon));
        }
        if (BigDecimal.class.equals(type)) {
            return new BigDecimal(readUntil(HproseTags.TagSemicolon));
        }
        if (String.class.equals(type)) {
            return readUntil(HproseTags.TagSemicolon);
        }
        if (int.class.equals(type) ||
            Integer.class.equals(type)) {
            return HproseHelper.valueOf(new Double(readUntil(HproseTags.TagSemicolon)).intValue());
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return HproseHelper.valueOf(new Double(readUntil(HproseTags.TagSemicolon)).longValue());
        }
        if (BigInteger.class.equals(type)) {
            return new BigInteger(readUntil(HproseTags.TagSemicolon));
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return HproseHelper.valueOf(new Double(readUntil(HproseTags.TagSemicolon)).byteValue());
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return HproseHelper.valueOf(new Double(readUntil(HproseTags.TagSemicolon)).shortValue());
        }
        if (boolean.class.equals(type) ||
            Boolean.class.equals(type)) {
            return HproseHelper.valueOf(readDouble(false) != 0.0);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf((char) new Double(readUntil(HproseTags.TagSemicolon)).intValue());
        }
        if (Calendar.class.equals(type)) {
            Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
            calendar.setTimeInMillis(new Double(readUntil(HproseTags.TagSemicolon)).longValue());
            return calendar;
        }
        if (Date.class.equals(type)) {
            return new Date(new Double(readUntil(HproseTags.TagSemicolon)).longValue());
        }
        if (java.sql.Date.class.equals(type)) {
            return new java.sql.Date(new Double(readUntil(HproseTags.TagSemicolon)).longValue());
        }
        if (java.sql.Time.class.equals(type)) {
            return new java.sql.Time(new Double(readUntil(HproseTags.TagSemicolon)).longValue());
        }
        if (java.sql.Timestamp.class.equals(type)) {
            return new java.sql.Timestamp(new Double(readUntil(HproseTags.TagSemicolon)).longValue());
        }
        if ((HproseHelper.enumClass != null) &&
             HproseHelper.enumClass.isAssignableFrom(type)) {
             return readEnum(type, false);
        }
        return castError("Double", type);
    }

    private Object readNull(Class type) throws IOException {
        if (boolean.class.equals(type)) {
            return Boolean.FALSE;
        }
        if (int.class.equals(type)) {
            return HproseHelper.valueOf(0);
        }
        if (long.class.equals(type)) {
            return HproseHelper.valueOf((long) 0);
        }
        if (byte.class.equals(type)) {
            return HproseHelper.valueOf((byte) 0);
        }
        if (short.class.equals(type)) {
            return HproseHelper.valueOf((short) 0);
        }
        if (char.class.equals(type)) {
            return HproseHelper.valueOf((char) 0);
        }
        if (float.class.equals(type)) {
            return new Float(0);
        }
        if (double.class.equals(type)) {
            return new Double(0);
        }
        return null;
    }

    private Object readEmpty(Class type) throws IOException {
        if (type == null ||
            String.class.equals(type) ||
            Object.class.equals(type)) {
            return "";
        }
        if (StringBuffer.class.equals(type)) {
            return new StringBuffer();
        }
        if (char[].class.equals(type)) {
            return new char[0];
        }
        if (byte[].class.equals(type)) {
            return new byte[0];
        }
        if (boolean.class.equals(type) ||
            Boolean.class.equals(type)) {
            return Boolean.FALSE;
        }
        if (int.class.equals(type) ||
            Integer.class.equals(type) ||
            Number.class.equals(type)) {
            return HproseHelper.valueOf(0);
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return HproseHelper.valueOf((long) 0);
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return HproseHelper.valueOf((byte) 0);
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return HproseHelper.valueOf((short) 0);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf((char) 0);
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return new Float(0);
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return new Double(0);
        }
        if (BigInteger.class.equals(type)) {
            return BigInteger.ZERO;
        }
        if (BigDecimal.class.equals(type)) {
            return BigDecimal.valueOf(0);
        }
        return castError("Empty String", type);
    }

    private Object readTrue(Class type) throws IOException {
        if (type == null ||
            boolean.class.equals(type) ||
            Boolean.class.equals(type) ||
            Object.class.equals(type)) {
            return Boolean.TRUE;
        }
        if (String.class.equals(type)) {
            return "true";
        }
        if (int.class.equals(type) ||
            Integer.class.equals(type) ||
            Number.class.equals(type)) {
            return HproseHelper.valueOf(1);
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return HproseHelper.valueOf((long) 1);
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return HproseHelper.valueOf((byte) 1);
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return HproseHelper.valueOf((short) 1);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf('T');
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return new Float(1);
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return new Double(1);
        }
        if (BigInteger.class.equals(type)) {
            return BigInteger.ONE;
        }
        if (BigDecimal.class.equals(type)) {
            return BigDecimal.valueOf(1);
        }
        return castError("Boolean", type);
    }

    private Object readFalse(Class type) throws IOException {
        if (type == null ||
            boolean.class.equals(type) ||
            Boolean.class.equals(type) ||
            Object.class.equals(type)) {
            return Boolean.FALSE;
        }
        if (String.class.equals(type)) {
            return "false";
        }
        if (int.class.equals(type) ||
            Integer.class.equals(type) ||
            Number.class.equals(type)) {
            return HproseHelper.valueOf(0);
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return HproseHelper.valueOf((long) 0);
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return HproseHelper.valueOf((byte) 0);
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return HproseHelper.valueOf((short) 0);
        }
        if (char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf('F');
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return new Float(0);
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return new Double(0);
        }
        if (BigInteger.class.equals(type)) {
            return BigInteger.ZERO;
        }
        if (BigDecimal.class.equals(type)) {
            return BigDecimal.valueOf(0);
        }
        return castError("Boolean", type);
    }

    private Object readNaN(Class type) throws IOException {
        if ((type == null) ||
            double.class.equals(type) ||
            Double.class.equals(type) ||
            Number.class.equals(type) ||
            Object.class.equals(type)) {
            return HproseHelper.valueOf(Double.NaN);
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return HproseHelper.valueOf(Float.NaN);
        }
        if (String.class.equals(type)) {
            return "NaN";
        }
        return castError("NaN", type);
    }

    private Object readInfinity(Class type) throws IOException {
        if ((type == null) ||
            double.class.equals(type) ||
            Double.class.equals(type) ||
            Number.class.equals(type) ||
            Object.class.equals(type)) {
            return HproseHelper.valueOf(readInfinity(false));
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return HproseHelper.valueOf((float) readInfinity(false));
        }
        if (String.class.equals(type)) {
            return String.valueOf(readInfinity(false));
        }
        return castError("Infinity", type);
    }

    private Object readBytes(Class type) throws IOException {
        if ((type == null) ||
            byte[].class.equals(type) ||
            Object.class.equals(type)) {
            return readBytes(false);
        }
        if (String.class.equals(type)) {
            return new String(readBytes(false));
        }
        return castError("byte[]", type);
    }

    private Object readUTF8Char(Class type) throws IOException {
        char u = readUTF8Char(false);
        if ((type == null) ||
            char.class.equals(type) ||
            Character.class.equals(type)) {
            return HproseHelper.valueOf(u);
        }
        if (String.class.equals(type) ||
            Object.class.equals(type)) {
            return String.valueOf((char)u);
        }
        if (int.class.equals(type) ||
            Integer.class.equals(type) ||
            Number.class.equals(type)) {
            return HproseHelper.valueOf((int)u);
        }
        if (byte.class.equals(type) ||
            Byte.class.equals(type)) {
            return HproseHelper.valueOf((byte)u);
        }
        if (long.class.equals(type) ||
            Long.class.equals(type)) {
            return HproseHelper.valueOf((long)u);
        }
        if (short.class.equals(type) ||
            Short.class.equals(type)) {
            return HproseHelper.valueOf((short)u);
        }
        if (float.class.equals(type) ||
            Float.class.equals(type)) {
            return HproseHelper.valueOf((float)u);
        }
        if (double.class.equals(type) ||
            Double.class.equals(type)) {
            return HproseHelper.valueOf((double)u);
        }
        if (BigInteger.class.equals(type)) {
            return BigInteger.valueOf((long)u);
        }
        if (BigDecimal.class.equals(type)) {
            return BigDecimal.valueOf((long)u);
        }
        if (char[].class.equals(type)) {
            return new char[] { u };
        }
        if (boolean.class.equals(type) ||
            Boolean.class.equals(type)) {
            return HproseHelper.valueOf(u != 0 && u != '0' && u != 'F' && u != 'f');
        }
        if (Calendar.class.equals(type)) {
            Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
            calendar.setTimeInMillis((long)u);
            return calendar;
        }
        if (Date.class.equals(type)) {
            return new Date((long)u);
        }
        if (java.sql.Date.class.equals(type)) {
            return new java.sql.Date((long)u);
        }
        if (java.sql.Time.class.equals(type)) {
            return new java.sql.Time((long)u);
        }
        if (java.sql.Timestamp.class.equals(type)) {
            return new java.sql.Timestamp((long)u);
        }
        if ((HproseHelper.enumClass != null) &&
             HproseHelper.enumClass.isAssignableFrom(type)) {
             return getEnum(type, (int)u);
        }
        return castError("Character", type);
    }

    public void checkTag(int expectTag, int tag) throws IOException {
        if (tag != expectTag) {
            throw new HproseException("Tag '" + (char) expectTag +
                                      "' expected, but '" + (char) tag +
                                      "' found in stream");
        }
    }

    public void checkTag(int expectTag) throws IOException {
        checkTag(expectTag, stream.read());
    }

    public int checkTags(String expectTags, int tag) throws IOException {
        if (expectTags.indexOf(tag) == -1) {
            throw new HproseException("Tag '" + expectTags +
                                      "' expected, but '" + (char) tag +
                                      "' found in stream");
        }
        return tag;
    }

    public int checkTags(String expectTags) throws IOException {
        return checkTags(expectTags, stream.read());
    }

    private boolean isInstantiableClass(Class type) {
        return !Modifier.isInterface(type.getModifiers()) &&
               !Modifier.isAbstract(type.getModifiers());
    }

    public String readUntil(int tag) throws IOException {
        StringBuffer sb = new StringBuffer();
        int i = stream.read();
        while ((i != tag) && (i != -1)) {
            sb.append((char) i);
            i = stream.read();
        }
        return sb.toString();
    }

    public byte readByte(int tag) throws IOException {
        byte result = 0;
        int i = stream.read();
        if (i == tag) return result;
        byte sign = 1;
        if (i == '+') {
            i = stream.read();
        }
        else if (i == '-') {
            sign = -1;
            i = stream.read();
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    public short readShort(int tag) throws IOException {
        short result = 0;
        int i = stream.read();
        if (i == tag) return result;
        short sign = 1;
        if (i == '+') {
            i = stream.read();
        }
        else if (i == '-') {
            sign = -1;
            i = stream.read();
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    public int readInt(int tag) throws IOException {
        int result = 0;
        int i = stream.read();
        if (i == tag) return result;
        int sign = 1;
        if (i == '+') {
            i = stream.read();
        }
        else if (i == '-') {
            sign = -1;
            i = stream.read();
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    public long readLong(int tag) throws IOException {
        long result = 0;
        int i = stream.read();
        if (i == tag) return result;
        long sign = 1;
        if (i == '+') {
            i = stream.read();
        }
        else if (i == '-') {
            sign = -1;
            i = stream.read();
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    public int readInteger() throws IOException {
        return readInteger(true);
    }

    public int readInteger(boolean includeTag) throws IOException {
        if (includeTag) {
            int tag = stream.read();
            if ((tag >= '0') && (tag <= '9')) {
                return tag - '0';
            }
            checkTag(HproseTags.TagInteger, tag);
        }
        return readInt(HproseTags.TagSemicolon);
    }

    public Object readEnum(Class type) throws IOException {
        return readEnum(type, true);
    }

    public Object readEnum(Class type, boolean includeTag) throws IOException {
        return getEnum(type, readInteger(includeTag));
    }

    private Object getEnum(Class type, int value) throws IOException {
        try {
            Object o = HproseHelper.getEnumConstants.invoke(type, nullArgs);
            return Array.get(o, value);
        }
        catch (IllegalAccessException e) {
            throw new HproseException(e.getMessage());
        }
        catch (IllegalArgumentException e) {
            throw new HproseException(e.getMessage());
        }
        catch (InvocationTargetException e) {
            throw new HproseException(e.getMessage());
        }
    }

    public BigInteger readBigInteger() throws IOException {
        return readBigInteger(true);
    }

    public BigInteger readBigInteger(boolean includeTag) throws IOException {
        if (includeTag) {
            int tag = stream.read();
            if ((tag >= '0') && (tag <= '9')) {
                return BigInteger.valueOf((long)(tag - '0'));
            }
            checkTags((char) HproseTags.TagInteger + "" +
                      (char) HproseTags.TagLong, tag);
        }
        return new BigInteger(readUntil(HproseTags.TagSemicolon));
    }

    public long readLong() throws IOException {
        return readLong(true);
    }

    public long readLong(boolean includeTag) throws IOException {
        if (includeTag) {
            int tag = stream.read();
            if ((tag >= '0') && (tag <= '9')) {
                return (long)(tag - '0');
            }
            checkTags((char) HproseTags.TagInteger + "" +
                      (char) HproseTags.TagLong, tag);
        }
        return readLong(HproseTags.TagSemicolon);
    }

    public double readDouble() throws IOException {
        return readDouble(true);
    }

    public double readDouble(boolean includeTag) throws IOException {
        if (includeTag) {
            int tag = stream.read();
            if ((tag >= '0') && (tag <= '9')) {
                return (double)(tag - '0');
            }
            checkTags((char) HproseTags.TagInteger + "" +
                       (char) HproseTags.TagLong + "" +
                       (char) HproseTags.TagDouble + "" +
                       (char) HproseTags.TagNaN + "" +
                       (char) HproseTags.TagInfinity, tag);
            if (tag == HproseTags.TagNaN) {
                return Double.NaN;
            }
            if (tag == HproseTags.TagInfinity) {
                return readInfinity(false);
            }
        }
        return Double.parseDouble(readUntil(HproseTags.TagSemicolon));
    }

    public double readNaN() throws IOException {
        checkTag(HproseTags.TagNaN);
        return Double.NaN;
    }

    public double readInfinity() throws IOException {
        return readInfinity(true);
    }

    public double readInfinity(boolean includeTag) throws IOException {
        if (includeTag) {
            checkTag(HproseTags.TagInfinity);
        }
        return ((stream.read() == HproseTags.TagNeg) ? Double.NEGATIVE_INFINITY : Double.POSITIVE_INFINITY);
    }

    public Object readNull() throws IOException {
        checkTag(HproseTags.TagNull);
        return null;
    }

    public Object readEmpty() throws IOException {
        checkTag(HproseTags.TagEmpty);
        return "";
    }

    public boolean readBoolean() throws IOException {
        int tag = checkTags((char) HproseTags.TagTrue + "" + (char) HproseTags.TagFalse);
        return (tag == HproseTags.TagTrue);
    }

    public Object readDate() throws IOException {
        return readDate(true, null);
    }

    public Object readDate(boolean includeTag) throws IOException {
        return readDate(includeTag, null);
    }

    public Object readDate(Class type) throws IOException {
        return readDate(true, type);
    }

    public Object readDate(boolean includeTag, Class type) throws IOException {
        int tag;
        if (includeTag) {
            tag = checkTags((char) HproseTags.TagDate + "" + (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
        }
        Calendar calendar;
        int year = stream.read() - '0';
        year = year * 10 + stream.read() - '0';
        year = year * 10 + stream.read() - '0';
        year = year * 10 + stream.read() - '0';
        int month = stream.read() - '0';
        month = month * 10 + stream.read() - '0';
        int day = stream.read() - '0';
        day = day * 10 + stream.read() - '0';
        tag = stream.read();
        if (tag == HproseTags.TagTime) {
            int hour = stream.read() - '0';
            hour = hour * 10 + stream.read() - '0';
            int minute = stream.read() - '0';
            minute = minute * 10 + stream.read() - '0';
            int second = stream.read() - '0';
            second = second * 10 + stream.read() - '0';
            int nanosecond = 0;
            tag = stream.read();
            if (tag == HproseTags.TagPoint) {
                nanosecond = stream.read() - '0';
                nanosecond = nanosecond * 10 + stream.read() - '0';
                nanosecond = nanosecond * 10 + stream.read() - '0';
                nanosecond = nanosecond * 1000000;
                tag = stream.read();
                if (tag >= '0' && tag <= '9') {
                    nanosecond += (tag - '0') * 100000;
                    nanosecond += (stream.read() - '0') * 10000;
                    nanosecond += (stream.read() - '0') * 1000;
                    tag = stream.read();
                    if (tag >= '0' && tag <= '9') {
                        nanosecond += (tag - '0') * 100;
                        nanosecond += (stream.read() - '0') * 10;
                        nanosecond += stream.read() - '0';
                        tag = stream.read();
                    }
                }
            }
            calendar = Calendar.getInstance(tag == HproseTags.TagUTC ? HproseHelper.UTC : HproseHelper.DefaultTZ);
            calendar.set(year, month - 1, day, hour, minute, second);
            if (nanosecond > 0) {
                if (java.sql.Timestamp.class.equals(type)) {
                    java.sql.Timestamp timestamp = new java.sql.Timestamp(calendar.getTimeInMillis());
                    timestamp.setNanos(nanosecond);
                    ref.add(timestamp);
                    return timestamp;
                }
                else {
                    calendar.set(Calendar.MILLISECOND, (int)(nanosecond / 1000000));
                }
            }
        }
        else {
            calendar = Calendar.getInstance(tag == HproseTags.TagUTC ? HproseHelper.UTC : HproseHelper.DefaultTZ);
            calendar.set(year, month - 1, day);
        }
        Object o = changeCalendarType(calendar, type);
        ref.add(o);
        return o;
    }

    public Object readTime() throws IOException {
        return readTime(true, null);
    }

    public Object readTime(boolean includeTag) throws IOException {
        return readTime(includeTag, null);
    }

    public Object readTime(Class type) throws IOException {
        return readTime(true, type);
    }

    public Object readTime(boolean includeTag, Class type) throws IOException {
        int tag;
        if (includeTag) {
            tag = checkTags((char) HproseTags.TagTime + "" + (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
        }
        Calendar calendar;
        int hour = stream.read() - '0';
        hour = hour * 10 + stream.read() - '0';
        int minute = stream.read() - '0';
        minute = minute * 10 + stream.read() - '0';
        int second = stream.read() - '0';
        second = second * 10 + stream.read() - '0';
        int nanosecond = 0;
        tag = stream.read();
        if (tag == HproseTags.TagPoint) {
            nanosecond = stream.read() - '0';
            nanosecond = nanosecond * 10 + stream.read() - '0';
            nanosecond = nanosecond * 10 + stream.read() - '0';
            nanosecond = nanosecond * 1000000;
            tag = stream.read();
            if (tag >= '0' && tag <= '9') {
                nanosecond += (tag - '0') * 100000;
                nanosecond += (stream.read() - '0') * 10000;
                nanosecond += (stream.read() - '0') * 1000;
                tag = stream.read();
                if (tag >= '0' && tag <= '9') {
                    nanosecond += (tag - '0') * 100;
                    nanosecond += (stream.read() - '0') * 10;
                    nanosecond += stream.read() - '0';
                    tag = stream.read();
                }
            }
        }
        calendar = Calendar.getInstance(tag == HproseTags.TagUTC ? HproseHelper.UTC : HproseHelper.DefaultTZ);
        calendar.set(1970, 0, 1, hour, minute, second);
        if (nanosecond > 0) {
            if (java.sql.Timestamp.class.equals(type)) {
                java.sql.Timestamp timestamp = new java.sql.Timestamp(calendar.getTimeInMillis());
                timestamp.setNanos(nanosecond);
                ref.add(timestamp);
                return timestamp;
            }
            else {
                calendar.set(Calendar.MILLISECOND, (int)(nanosecond / 1000000));
            }
        }
        Object o = changeCalendarType(calendar, type);
        ref.add(o);
        return o;
    }

    public Object readDateTime() throws IOException {
        return readDateTime(null);
    }

    public Object readDateTime(Class type) throws IOException {
        int tag = checkTags((char) HproseTags.TagDate + "" +
                            (char) HproseTags.TagTime + "" +
                            (char) HproseTags.TagRef);
        if (tag == HproseTags.TagRef) {
            return readRef(type);
        }
        if (tag == HproseTags.TagDate) {
            return readDate(false, type);
        }
        return readTime(false, type);
    }

    private Object changeCalendarType(Calendar calendar, Class type) throws IOException {
        if (type == null ||
            Calendar.class.equals(type) ||
            GregorianCalendar.class.equals(type) ||
            Object.class.equals(type)) {
            return calendar;
        }
        if (Date.class.equals(type)) {
            return calendar.getTime();
        }
        if (Long.class.equals(type) || long.class.equals(type)) {
            return new Long(calendar.getTimeInMillis());
        }
        if (java.sql.Date.class.equals(type)) {
            return new java.sql.Date(calendar.getTimeInMillis());
        }
        if (java.sql.Time.class.equals(type)) {
            return new java.sql.Time(calendar.getTimeInMillis());
        }
        if (java.sql.Timestamp.class.equals(type)) {
            java.sql.Timestamp timestamp = new java.sql.Timestamp(calendar.getTimeInMillis());
            timestamp.setNanos(0);
            return timestamp;
        }
        if (String.class.equals(type)) {
            return calendar.getTime().toString();
        }
        return castError(calendar, type);
    }

    public byte[] readBytes() throws IOException {
        return readBytes(true);
    }

    public byte[] readBytes(boolean includeTag) throws IOException {
        if (includeTag) {
            int tag = checkTags((char) HproseTags.TagBytes + "" + (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return (byte[]) readRef(byte[].class);
            }
        }
        int len = readInt(HproseTags.TagQuote);
        int off = 0;
        byte[] b = new byte[len];
        while (len > 0) {
            int size = stream.read(b, off, len);
            off += size;
            len -= size;
        }
        checkTag(HproseTags.TagQuote);
        ref.add(b);
        return b;
    }

    public char readUTF8Char(boolean includeTag) throws IOException {
        if (includeTag) {
            checkTag(HproseTags.TagUTF8Char);
        }
        char u;
        int c = stream.read();
        switch (c >>> 4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7: {
                // 0xxx xxxx
                u = (char) c;
                break;
            }
            case 12:
            case 13: {
                // 110x xxxx   10xx xxxx
                int c2 = stream.read();
                u = (char) (((c & 0x1f) << 6) |
                            (c2 & 0x3f));
                break;
            }
            case 14: {
                // 1110 xxxx  10xx xxxx  10xx xxxx
                int c2 = stream.read();
                int c3 = stream.read();
                u = (char) (((c & 0x0f) << 12) |
                           ((c2 & 0x3f) << 6) |
                            (c3 & 0x3f));
                break;
            }
            default:
                throw new HproseException("bad utf-8 encoding at " +
                                          ((c < 0) ? "end of stream" : "0x" + Integer.toHexString(c & 0xff)));
        }
        return u;
    }

    public Object readString() throws IOException {
        return readString(true, null, true);
    }

    public Object readString(boolean includeTag) throws IOException {
        return readString(includeTag, null, true);
    }

    public Object readString(Class type) throws IOException {
        return readString(true, type, true);
    }

    public Object readString(boolean includeTag, Class type) throws IOException {
        return readString(includeTag, type, true);
    }

    private Object readString(boolean includeTag, Class type, boolean includeRef) throws IOException {
        if (includeTag) {
            int tag = checkTags((char) HproseTags.TagString + "" +
                                (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
        }
        int count = readInt(HproseTags.TagQuote);
        char[] buf = new char[count];
        for (int i = 0; i < count; i++) {
            int c = stream.read();
            switch (c >>> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    buf[i] = (char) c;
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    int c2 = stream.read();
                    buf[i] = (char) (((c & 0x1f) << 6) |
                                     (c2 & 0x3f));
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    int c2 = stream.read();
                    int c3 = stream.read();
                    buf[i] = (char) (((c & 0x0f) << 12) |
                                     ((c2 & 0x3f) << 6) |
                                     (c3 & 0x3f));
                    break;
                }
                case 15: {
                    // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                    if ((c & 0xf) <= 4) {
                        int c2 = stream.read();
                        int c3 = stream.read();
                        int c4 = stream.read();
                        int s = ((c & 0x07) << 18) |
                                ((c2 & 0x3f) << 12) |
                                ((c3 & 0x3f) << 6) |
                                (c4 & 0x3f) - 0x10000;
                        if (0 <= s && s <= 0xfffff) {
                            buf[i++] = (char) (((s >>> 10) & 0x03ff) | 0xd800);
                            buf[i] = (char) ((s & 0x03ff) | 0xdc00);
                            break;
                        }
                    }
                // no break here!! here need throw exception.
                }
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                                              ((c < 0) ? "end of stream" : "0x" + Integer.toHexString(c & 0xff)));
            }
        }
        checkTag(HproseTags.TagQuote);
        Object o = changeStringType(buf, type);
        if (includeRef) {
            ref.add(o);
        }
        return o;
    }

    private Object changeStringType(char[] str, Class type) throws IOException {
        if (char[].class.equals(type)) {
            return str;
        }
        if (StringBuffer.class.equals(type)) {
            return new StringBuffer(str.length).append(str);
        }
        String s = new String(str);
        if ((type == null) ||
            String.class.equals(type) ||
            Object.class.equals(type)) {
            return s;
        }
        if (BigDecimal.class.equals(type)) {
            return new BigDecimal(s);
        }
        if (BigInteger.class.equals(type)) {
            return new BigInteger(s);
        }
        if (Byte.class.equals(type) || byte.class.equals(type)) {
            return new Byte(s);
        }
        if (Short.class.equals(type) || short.class.equals(type)) {
            return new Short(s);
        }
        if (Integer.class.equals(type) || int.class.equals(type)) {
            return new Integer(s);
        }
        if (Long.class.equals(type) || long.class.equals(type)) {
            return new Long(s);
        }
        if (Float.class.equals(type) || float.class.equals(type)) {
            return new Float(s);
        }
        if (Double.class.equals(type) || double.class.equals(type)) {
            return new Double(s);
        }
        if (Character.class.equals(type) || char.class.equals(type)) {
            if (str.length == 1) {
                return new Character(str[0]);
            }
            else {
                return new Character((char) Integer.parseInt(s));
            }
        }
        if (Boolean.class.equals(type) || boolean.class.equals(type)) {
            return Boolean.valueOf(s);
        }
        if (byte[].class.equals(type)) {
            try {
                return s.getBytes("UTF-8");
            }
            catch (Exception e) {
                return s.getBytes();
            }
        }
        if (UUID.class.equals(type)) {
            return UUID.fromString(s);
        }
        if (HproseHelper.uuidClass != null &&
            HproseHelper.uuidClass.equals(type)) {
            try {
                return HproseHelper.uuidFromString.invoke(null, new Object[] {s});
            }
            catch (Exception ex) {
                throw new HproseException(ex.getMessage());
            }
        }
        return castError(str, type);
    }

    public Object readUUID() throws IOException {
        return readUUID(true, null);
    }

    public Object readUUID(boolean includeTag) throws IOException {
        return readUUID(includeTag, null);
    }

    public Object readUUID(Class type) throws IOException {
        return readUUID(true, type);
    }

    public Object readUUID(boolean includeTag, Class type) throws IOException {
        if (includeTag) {
            int tag = checkTags((char)HproseTags.TagGuid + "" +
                                (char)HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
        }
        checkTag(HproseTags.TagOpenbrace);
        char[] buf = new char[36];
        for (int i = 0; i < 36; i++) {
            buf[i] = (char) stream.read();
        }
        checkTag(HproseTags.TagClosebrace);
        Object o = changeUUIDType(buf, type);
        ref.add(o);
        return o;
    }

    private Object changeUUIDType(char[] buf, Class type) throws IOException {
        if (char[].class.equals(type)) {
            return buf;
        }
        String s = new String(buf);
        if (String.class.equals(type)) {
            return s;
        }
        if (StringBuffer.class.equals(type)) {
            return new StringBuffer(s);
        }
        if (HproseHelper.uuidClass == null &&
            (type == null || Object.class.equals(type)) ||
            UUID.class.equals(type)) {
            return UUID.fromString(s);
        }
        if (HproseHelper.uuidClass != null &&
            (type == null ||
            Object.class.equals(type) ||  
            HproseHelper.uuidClass.equals(type))) {
            try {
                return HproseHelper.uuidFromString.invoke(null, new Object[] {s});
            }
            catch (Exception ex) {
                throw new HproseException(ex.getMessage());
            }
        }
        return castError(buf, type);
    }

    private short[] readShortArray(int count) throws IOException {
        short[] a = new short[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = ((Short)unserialize(short.class)).shortValue();
        }
        return a;
    }

    private int[] readIntegerArray(int count) throws IOException {
        int[] a = new int[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = ((Integer)unserialize(int.class)).intValue();
        }
        return a;
    }

    private long[] readLongArray(int count) throws IOException {
        long[] a = new long[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = ((Long)unserialize(long.class)).longValue();
        }
        return a;
    }

    private boolean[] readBooleanArray(int count) throws IOException {
        boolean[] a = new boolean[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = ((Boolean)unserialize(boolean.class)).booleanValue();
        }
        return a;
    }

    private float[] readFloatArray(int count) throws IOException {
        float[] a = new float[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = ((Float)unserialize(float.class)).floatValue();
        }
        return a;
    }

    private double[] readDoubleArray(int count) throws IOException {
        double[] a = new double[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = ((Double)unserialize(double.class)).doubleValue();
        }
        return a;
    }

    private BigInteger[] readBigIntegerArray(int count) throws IOException {
        BigInteger[] a = new BigInteger[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (BigInteger)unserialize(BigInteger.class);
        }
        return a;
    }

    private String[] readStringArray(int count) throws IOException {
        String[] a = new String[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (String) unserialize(String.class);
        }
        return a;
    }

    private StringBuffer[] readStringBufferArray(int count) throws IOException {
        StringBuffer[] a = new StringBuffer[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (StringBuffer) unserialize(StringBuffer.class);
        }
        return a;
    }

    private BigDecimal[] readBigDecimalArray(int count) throws IOException {
        BigDecimal[] a = new BigDecimal[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (BigDecimal) unserialize(BigDecimal.class);
        }
        return a;
    }

    private byte[][] readBytesArray(int count) throws IOException {
        byte[][] a = new byte[count][];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (byte[])unserialize(byte[].class);
        }
        return a;
    }

    private char[][] readCharsArray(int count) throws IOException {
        char[][] a = new char[count][];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (char[])unserialize(char[].class);
        }
        return a;
    }

    private Calendar[] readCalendarArray(int count) throws IOException {
        Calendar[] a = new Calendar[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (Calendar) unserialize(Calendar.class);
        }
        return a;
    }

    private Date[] readDateArray(int count) throws IOException {
        Date[] a = new Date[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = (Date) unserialize(Date.class);
        }
        return a;
    }

    private Object readArray(Class type, int count) throws IOException {
        Object a = Array.newInstance(type, count);
        ref.add(a);
        for (int i = 0; i < count; i++) {
            Array.set(a, i, unserialize(type));
        }
        return a;
    }

    public void readArray(Class[] types, Object[] a, int count) throws IOException {
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = unserialize(types[i]);
        }
    }

    public Object[] readArray(int count) throws IOException {
        Object[] a = new Object[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = unserialize(Object.class);
        }
        return a;
    }

    private ArrayList readArrayList(int count) throws IOException {
        ArrayList list = new ArrayList(count);
        ref.add(list);
        for (int i = 0; i < count; i++) {
            list.add(unserialize(Object.class));
        }
        return list;
    }

    private LinkedList readLinkedList(int count) throws IOException {
        LinkedList list = new LinkedList();
        ref.add(list);
        for (int i = 0; i < count; i++) {
            list.add(unserialize(Object.class));
        }
        return list;
    }

    private Vector readVector(int count) throws IOException {
        Vector list = new Vector(count);
        ref.add(list);
        for (int i = 0; i < count; i++) {
            list.add(unserialize(Object.class));
        }
        return list;
    }

    private Stack readStack(int count) throws IOException {
        Stack list = new Stack();
        ref.add(list);
        for (int i = 0; i < count; i++) {
            list.add(unserialize(Object.class));
        }
        return list;
    }

    private HashSet readHashSet(int count) throws IOException {
        HashSet set = new HashSet();
        ref.add(set);
        for (int i = 0; i < count; i++) {
            set.add(unserialize(Object.class));
        }
        return set;
    }

    private TreeSet readTreeSet(int count) throws IOException {
        TreeSet set = new TreeSet();
        ref.add(set);
        for (int i = 0; i < count; i++) {
            set.add(unserialize(Object.class));
        }
        return set;
    }

    private Collection readCollection(int count, Class type) throws IOException {
        Collection collection = (Collection) HproseHelper.newInstance(type);
        ref.add(collection);
        for (int i = 0; i < count; i++) {
            collection.add(unserialize(Object.class));
        }
        return collection;
    }

    public Object readList() throws IOException {
        return readList(true, null);
    }

    public Object readList(boolean includeTag) throws IOException {
        return readList(includeTag, null);
    }

    public Object readList(Class type) throws IOException {
        return readList(true, type);
    }

    public Object readList(boolean includeTag, Class type) throws IOException {
        if (includeTag) {
            int tag = checkTags((char) HproseTags.TagList + "" +
                                (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
        }
        int count = readInt(HproseTags.TagOpenbrace);
        Object list = null;
        if ((type == null) ||
            Object.class.equals(type) ||
            Collection.class.equals(type) ||
            AbstractCollection.class.equals(type) ||
            List.class.equals(type) ||
            AbstractList.class.equals(type) ||
            ArrayList.class.equals(type)) {
            list = readArrayList(count);
        }
        else if (AbstractSequentialList.class.equals(type) ||
                 LinkedList.class.equals(type)) {
            list = readLinkedList(count);
        }
        else if (int[].class.equals(type)) {
            list = readIntegerArray(count);
        }
        else if (short[].class.equals(type)) {
            list = readShortArray(count);
        }
        else if (long[].class.equals(type)) {
            list = readLongArray(count);
        }
        else if (String[].class.equals(type)) {
            list = readStringArray(count);
        }
        else if (boolean[].class.equals(type)) {
            list = readBooleanArray(count);
        }
        else if (double[].class.equals(type)) {
            list = readDoubleArray(count);
        }
        else if (float[].class.equals(type)) {
            list = readFloatArray(count);
        }
        else if (BigInteger[].class.equals(type)) {
            list = readBigIntegerArray(count);
        }
        else if (BigDecimal[].class.equals(type)) {
            list = readBigDecimalArray(count);
        }
        else if (StringBuffer[].class.equals(type)) {
            list = readStringBufferArray(count);
        }
        else if (byte[][].class.equals(type)) {
            list = readBytesArray(count);
        }
        else if (char[][].class.equals(type)) {
            list = readCharsArray(count);
        }
        else if (Calendar[].class.equals(type)) {
            list = readCalendarArray(count);
        }
        else if (Date[].class.equals(type)) {
            list = readDateArray(count);
        }
        else if (Object[].class.equals(type)) {
            list = readArray(count);
        }
        else if (type.isArray()) {
            list = readArray(type.getComponentType(), count);
        }
        else if (Vector.class.equals(type)) {
            list = readVector(count);
        }
        else if (Stack.class.equals(type)) {
            list = readStack(count);
        }
        else if (Set.class.equals(type) ||
                 AbstractSet.class.equals(type) ||
                 HashSet.class.equals(type)) {
            list = readHashSet(count);
        }
        else if (SortedSet.class.equals(type) ||
                 TreeSet.class.equals(type)) {
            list = readTreeSet(count);
        }
        else if (Collection.class.isAssignableFrom(type) && isInstantiableClass(type)) {
            list = readCollection(count, type);
        }
        else {
            castError("List", type);
        }
        checkTag(HproseTags.TagClosebrace);
        return list;
    }

    private HashMap readHashMap(int count) throws IOException {
        HashMap map = new HashMap(count);
        ref.add(map);
        for (int i = 0; i < count; i++) {
            Object key = unserialize(Object.class);
            Object value = unserialize(Object.class);
            map.put(key, value);
        }
        return map;
    }

    private TreeMap readTreeMap(int count) throws IOException {
        TreeMap map = new TreeMap();
        ref.add(map);
        for (int i = 0; i < count; i++) {
            Object key = unserialize(Object.class);
            Object value = unserialize(Object.class);
            map.put(key, value);
        }
        return map;
    }

    private Hashtable readHashtable(int count) throws IOException {
        Hashtable map = new Hashtable(count);
        ref.add(map);
        for (int i = 0; i < count; i++) {
            Object key = unserialize(Object.class);
            Object value = unserialize(Object.class);
            map.put(key, value);
        }
        return map;
    }

    private Map readMap(int count, Class type) throws IOException {
        Map map = (Map) HproseHelper.newInstance(type);
        ref.add(map);
        for (int i = 0; i < count; i++) {
            Object key = unserialize(Object.class);
            Object value = unserialize(Object.class);
            map.put(key, value);
        }
        return map;
    }

    private Object readObject1(int count, Class type) throws IOException {
        Object obj = HproseHelper.newInstance(type);
        Map fields = HproseHelper.getFields(type);
        ref.add(obj);
        for (int i = 0; i < count; i++) {
            Field field = (Field) fields.get(unserialize(String.class));
            if (field != null) {
                Object value = unserialize(field.getType());
                try {
                    field.set(obj, value);
                }
                catch (Exception e) {
                    throw new HproseException(e.getMessage());
                }
            }
            else {
                unserialize();
            }
        }
        return obj;
    }

    private Object readObject2(int count, Class type) throws IOException {
        Object obj = HproseHelper.newInstance(type);
        Map properties = HproseHelper.getProperties(type);
        ref.add(obj);
        for (int i = 0; i < count; i++) {
            PropertyAccessor pa = (PropertyAccessor) properties.get(unserialize(String.class));
            if (pa != null) {
                Method setter = pa.setter;
                Object value = unserialize(setter.getParameterTypes()[0]);
                try {
                    setter.invoke(obj, new Object[]{value});
                }
                catch (Exception e) {
                    throw new HproseException(e.getMessage());
                }
            }
            else {
                unserialize();
            }
        }
        return obj;
    }

    private Object readBean(int count, Class type) throws IOException {
        Object obj = HproseHelper.newInstance(type);
        Map members = HproseHelper.getMembers(type);
        ref.add(obj);
        for (int i = 0; i < count; i++) {
            Object member = members.get(unserialize(String.class));
            if (member != null) {
                try {
                    if (member instanceof Field) {
                        Field field = (Field) member;
                        Object value = unserialize(field.getType());
                        field.set(obj, value);
                    }
                    else {
                        Method setter = ((PropertyAccessor) member).setter;
                        Object value = unserialize(setter.getParameterTypes()[0]);
                        setter.invoke(obj, new Object[]{value});
                    }
                }
                catch (Exception e) {
                    throw new HproseException(e.getMessage());
                }
            }
            else {
                unserialize();
            }
        }
        return obj;
    }

    public Object readMap() throws IOException {
        return readMap(true, null);
    }

    public Object readMap(boolean includeTag) throws IOException {
        return readMap(includeTag, null);
    }

    public Object readMap(Class type) throws IOException {
        return readMap(true, type);
    }

    public Object readMap(boolean includeTag, Class type) throws IOException {
        if (includeTag) {
            int tag = checkTags((char) HproseTags.TagMap + "" +
                                (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
        }
        int count = readInt(HproseTags.TagOpenbrace);
        Object map = null;
        if ((type == null) ||
            Object.class.equals(type) ||
            Map.class.equals(type) ||
            AbstractMap.class.equals(type) ||
            HashMap.class.equals(type)) {
            map = readHashMap(count);
        }
        else if (SortedMap.class.equals(type) ||
                 TreeMap.class.equals(type)) {
            map = readTreeMap(count);
        }
        else if (Hashtable.class.equals(type)) {
            map = readHashtable(count);
        }
        else if (isInstantiableClass(type)) {
            if (Map.class.isAssignableFrom(type)) {
                map = readMap(count, type);
            }
            else if (!Serializable.class.isAssignableFrom(type)) {
                map = readBean(count, type);
            }
            else if (mode == HproseMode.FieldMode) {
                map = readObject1(count, type);
            }
            else {
                map = readObject2(count, type);
            }
        }
        else {
            castError("Map", type);
        }
        checkTag(HproseTags.TagClosebrace);
        return map;
    }

    public Object readObject() throws IOException {
        return readObject(true, null);
    }

    public Object readObject(boolean includeTag) throws IOException {
        return readObject(includeTag, null);
    }

    public Object readObject(Class type) throws IOException {
        return readObject(true, type);
    }

    public Object readObject(boolean includeTag, Class type) throws IOException {
        if (includeTag) {
            int tag = checkTags((char) HproseTags.TagObject + "" +
                                (char) HproseTags.TagClass + "" +
                                (char) HproseTags.TagRef);
            if (tag == HproseTags.TagRef) {
                return readRef(type);
            }
            if (tag == HproseTags.TagClass) {
                readClass();
                return readObject(type);
            }
        }
        Object c = classref.get(readInt(HproseTags.TagOpenbrace));
        String[] memberNames = (String[]) membersref.get(c);
        int count = memberNames.length;
        Object obj = null;
        Map members = null;
        boolean isBean = false;
        if (Class.class.equals(c.getClass())) {
            Class cls = (Class) c;
            if ((type == null) || type.isAssignableFrom(cls)) {
                obj = HproseHelper.newInstance(cls);
                if (obj != null) {
                    isBean = !(Serializable.class.isAssignableFrom(cls));
                    if (isBean) {
                        members = HproseHelper.getMembers(cls);
                    }
                    else if (mode == HproseMode.FieldMode) {
                        members = HproseHelper.getFields(cls);
                    }
                    else {
                        members = HproseHelper.getProperties(cls);
                    }
                }
            }
            else if (isInstantiableClass(type)) {
                obj = HproseHelper.newInstance(type);
            }
        }
        else if ((type != null) && isInstantiableClass(type)) {
            obj = HproseHelper.newInstance(type);
        }
        if ((obj != null) && (members == null)) {
            isBean = !(Serializable.class.isAssignableFrom(type));
            if (isBean) {
                members = HproseHelper.getMembers(type);
            }
            else if (mode == HproseMode.FieldMode) {
                members = HproseHelper.getFields(type);
            }
            else {
                members = HproseHelper.getProperties(type);
            }
        }
        if (obj == null) {
            HashMap map = new HashMap(count);
            ref.add(map);
            for (int i = 0; i < count; i++) {
                map.put(memberNames[i], unserialize(Object.class));
            }
            obj = map;
        }
        else {
            ref.add(obj);
            if (isBean) {
                for (int i = 0; i < count; i++) {
                    Object member = members.get(memberNames[i]);
                    if (member != null) {
                        try {
                            if (member instanceof Field) {
                                Field field = (Field) member;
                                Object value = unserialize(field.getType());
                                field.set(obj, value);
                            }
                            else {
                                Method setter = ((PropertyAccessor) member).setter;
                                Object value = unserialize(setter.getParameterTypes()[0]);
                                setter.invoke(obj, new Object[]{value});
                            }
                        }
                        catch (Exception e) {
                            throw new HproseException(e.getMessage());
                        }
                    }
                    else {
                        unserialize();
                    }
                }
            }
            else if (mode == HproseMode.FieldMode) {
                for (int i = 0; i < count; i++) {
                    Field field = (Field) members.get(memberNames[i]);
                    if (field != null) {
                        Object value = unserialize(field.getType());
                        try {
                            field.set(obj, value);
                        }
                        catch (Exception e) {
                            throw new HproseException(e.getMessage());
                        }
                    }
                    else {
                        unserialize();
                    }
                }
            }
            else {
                for (int i = 0; i < count; i++) {
                    PropertyAccessor pa = (PropertyAccessor) members.get(memberNames[i]);
                    if (pa != null) {
                        Method setter = pa.setter;
                        Object value = unserialize(setter.getParameterTypes()[0]);
                        try {
                            setter.invoke(obj, new Object[]{value});
                        }
                        catch (Exception e) {
                            throw new HproseException(e.getMessage());
                        }
                    }
                    else {
                        unserialize();
                    }
                }
            }
        }
        checkTag(HproseTags.TagClosebrace);
        return obj;
    }

    private void readClass() throws IOException {
        String className = (String) readString(false, null, false);
        int count = readInt(HproseTags.TagOpenbrace);
        String[] memberNames = new String[count];
        for (int i = 0; i < count; i++) {
            memberNames[i] = (String) readString(true);
        }
        checkTag(HproseTags.TagClosebrace);
        Class type = HproseHelper.getClass(className);
        if (type == null) {
            Object key = new Object();
            classref.add(key);
            membersref.put(key, memberNames);
        }
        else {
            classref.add(type);
            membersref.put(type, memberNames);
        }
    }

    private Object readRef(Class type) throws IOException {
        Object o = ref.get(readInt(HproseTags.TagSemicolon));
        if (type == null || type.isInstance(o)) {
            return o;
        }
        return castError(o, type);
    }

    private Object castError(String srctype, Class desttype) throws IOException {
        throw new HproseException(srctype + " can't change to " + desttype.getName());
    }

    private Object castError(Object obj, Class type) throws IOException {
        throw new HproseException(obj.getClass().getName() + " can't change to " + type.getName());
    }
    
    public ByteArrayOutputStream readRaw() throws IOException {
    	ByteArrayOutputStream ostream = new ByteArrayOutputStream();
    	readRaw(ostream);
    	return ostream;
    }

    public void readRaw(OutputStream ostream) throws IOException {
        readRaw(ostream, stream.read());
    }

    private void readRaw(OutputStream ostream, int tag) throws IOException {
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
                ostream.write(tag);
                break;
            case HproseTags.TagInfinity:
                ostream.write(tag);
                ostream.write(stream.read());
                break;
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble:
            case HproseTags.TagRef:
                readNumberRaw(ostream, tag);
                break;
            case HproseTags.TagDate:
            case HproseTags.TagTime:
                readDateTimeRaw(ostream, tag);
                break;
            case HproseTags.TagUTF8Char:
                readUTF8CharRaw(ostream, tag);
                break;
            case HproseTags.TagBytes:
                readBytesRaw(ostream, tag);
                break;
            case HproseTags.TagString:
                readStringRaw(ostream, tag);
                break;
            case HproseTags.TagGuid:
                readGuidRaw(ostream, tag);
                break;
            case HproseTags.TagList:
            case HproseTags.TagMap:
            case HproseTags.TagObject:
                readComplexRaw(ostream, tag);
                break;
            case HproseTags.TagClass:
                readComplexRaw(ostream, tag);
                readRaw(ostream);
                break;
            case HproseTags.TagError:
                ostream.write(tag);
                readRaw(ostream);
                break;
            case -1:
                throw new HproseException("No byte found in stream");
            default:
                throw new HproseException("Unexpected serialize tag '" +
                        (char) tag + "' in stream");
        }
    }

    private void readNumberRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        do {
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon);        
    }
    
    private void readDateTimeRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        do {
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon &&
                 tag != HproseTags.TagUTC);
    }

    private void readUTF8CharRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        tag = stream.read();
        switch (tag >>> 4) {
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7: {
                // 0xxx xxxx
                ostream.write(tag);
                break;
            }
            case 12:
            case 13: {
                // 110x xxxx   10xx xxxx
                ostream.write(tag);
                ostream.write(stream.read());
                break;
            }
            case 14: {
                // 1110 xxxx  10xx xxxx  10xx xxxx
                ostream.write(tag);
                ostream.write(stream.read());
                ostream.write(stream.read());
                break;
            }
            default:
                throw new HproseException("bad utf-8 encoding at " +
                                          ((tag < 0) ? "end of stream" :
                                              "0x" + Integer.toHexString(tag & 0xff)));
        }
    }

    private void readBytesRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        int len = 0;
        tag = '0';
        do {
            len *= 10;
            len += tag - '0';
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagQuote);
        int off = 0;
        byte[] b = new byte[len];
        while (len > 0) {
            int size = stream.read(b, off, len);
            off += size;
            len -= size;
        }
        ostream.write(b);
        ostream.write(stream.read());        
    }

    private void readStringRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        int count = 0;
        tag = '0';
        do {
            count *= 10;
            count += tag - '0';
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagQuote);
        for (int i = 0; i < count; i++) {
            tag = stream.read();
            switch (tag >>> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7: {
                    // 0xxx xxxx
                    ostream.write(tag);
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    ostream.write(tag);
                    ostream.write(stream.read());
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    ostream.write(tag);
                    ostream.write(stream.read());
                    ostream.write(stream.read());
                    break;
                }
                case 15: {
                    // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                    if ((tag & 0xf) <= 4) {
                        ostream.write(tag);
                        ostream.write(stream.read());
                        ostream.write(stream.read());
                        ostream.write(stream.read());
                        break;
                    }
                // no break here!! here need throw exception.
                }
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                                              ((tag < 0) ? "end of stream" :
                                                  "0x" + Integer.toHexString(tag & 0xff)));
            }
        }
        ostream.write(stream.read());
    }

    private void readGuidRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        int len = 38;
        int off = 0;
        byte[] b = new byte[len];
        while (len > 0) {
            int size = stream.read(b, off, len);
            off += size;
            len -= size;
        }
        ostream.write(b);
    }

    private void readComplexRaw(OutputStream ostream, int tag) throws IOException {
        ostream.write(tag);
        do {
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagOpenbrace);
        while ((tag = stream.read()) != HproseTags.TagClosebrace) {
            readRaw(ostream, tag);
        }
        ostream.write(tag);
    }

    public void reset() {
        ref.clear();
        classref.clear();
        membersref.clear();
    }
}