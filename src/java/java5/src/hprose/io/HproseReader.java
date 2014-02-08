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
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

import hprose.common.HproseException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Array;
import java.lang.reflect.GenericArrayType;
import java.lang.reflect.Modifier;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.UUID;

public final class HproseReader {

    public final InputStream stream;
    private final HproseMode mode;
    private final ArrayList<Object> ref = new ArrayList<Object>();
    private final ArrayList<Object> classref = new ArrayList<Object>();
    private final HashMap<Object, String[]> membersref = new HashMap<Object, String[]>();
    private static final Object[] nullArgs = new Object[0];

    public HproseReader(InputStream stream) {
        this(stream, HproseMode.MemberMode);
    }

    public HproseReader(InputStream stream, HproseMode mode) {
        this.stream = stream;
        this.mode = mode;
    }

    public HproseException unexpectedTag(int tag) {
        return unexpectedTag(tag, null);
    }

    public HproseException unexpectedTag(int tag, String expectTags) {
        if (tag == -1) {
            return new HproseException("No byte found in stream");
        }
        else if (expectTags == null) {
            return new HproseException("Unexpected serialize tag '" +
                                       (char)tag + "' in stream");
        }
        else {
            return new HproseException("Tag '" + expectTags +
                                       "' expected, but '" + (char)tag +
                                       "' found in stream");
        }
    }

    private HproseException castError(String srctype, Type desttype) {
        return new HproseException(srctype + " can't change to " +
                                   desttype.toString());
    }

    private HproseException castError(Object obj, Type type) {
        return new HproseException(obj.getClass().toString() +
                                   " can't change to " +
                                   type.toString());
    }

    public void checkTag(int tag, int expectTag) throws HproseException {
        if (tag != expectTag) {
            throw unexpectedTag(tag, new String(new char[] {(char)expectTag}));
        }
    }

    public void checkTag(int expectTag) throws IOException {
        checkTag(stream.read(), expectTag);
    }

    public int checkTags(int tag, String expectTags) throws IOException {
        if (expectTags.indexOf(tag) == -1) {
            throw unexpectedTag(tag, expectTags);
        }
        return tag;
    }

    public int checkTags(String expectTags) throws IOException {
        return checkTags(stream.read(), expectTags);
    }

    private boolean isInstantiableClass(Class<?> type) {
        return !Modifier.isInterface(type.getModifiers()) &&
               !Modifier.isAbstract(type.getModifiers());
    }

    private StringBuilder readUntil(int tag) throws IOException {
        StringBuilder sb = new StringBuilder();
        int i = stream.read();
        while ((i != tag) && (i != -1)) {
            sb.append((char) i);
            i = stream.read();
        }
        return sb;
    }

    private void skipUntil(int tag) throws IOException {
        int i = stream.read();
        while ((i != tag) && (i != -1)) {
            i = stream.read();
        }
    }

    @SuppressWarnings({"fallthrough"})
    public byte readByte(int tag) throws IOException {
        byte result = 0;
        int i = stream.read();
        if (i == tag) {
            return result;
        }
        byte sign = 1;
        switch (i) {
            case '-': sign = -1; // NO break HERE
            case '+': i = stream.read(); break;
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    @SuppressWarnings({"fallthrough"})
    public short readShort(int tag) throws IOException {
        short result = 0;
        int i = stream.read();
        if (i == tag) {
            return result;
        }
        short sign = 1;
        switch (i) {
            case '-': sign = -1; // NO break HERE
            case '+': i = stream.read(); break;
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    @SuppressWarnings({"fallthrough"})
    public int readInt(int tag) throws IOException {
        int result = 0;
        int i = stream.read();
        if (i == tag) {
            return result;
        }
        int sign = 1;
        switch (i) {
            case '-': sign = -1; // NO break HERE
            case '+': i = stream.read(); break;
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    @SuppressWarnings({"fallthrough"})
    public long readLong(int tag) throws IOException {
        long result = 0;
        int i = stream.read();
        if (i == tag) {
            return result;
        }
        long sign = 1;
        switch (i) {
            case '-': sign = -1; // NO break HERE
            case '+': i = stream.read(); break;
        }
        while ((i != tag) && (i != -1)) {
            result *= 10;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    @SuppressWarnings({"fallthrough"})
    public float readIntAsFloat() throws IOException {
        float result = 0.0f;
        float sign = 1.0f;
        int i = stream.read();
        switch (i) {
            case '-': sign = -1.0f; // NO BREAK HERE
            case '+': i = stream.read(); break;
        }
        while ((i != HproseTags.TagSemicolon) && (i != -1)) {
            result *= 10.0f;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    @SuppressWarnings({"fallthrough"})
    public double readIntAsDouble() throws IOException {
        double result = 0.0;
        double sign = 1.0;
        int i = stream.read();
        switch (i) {
            case '-': sign = -1.0; // NO BREAK HERE
            case '+': i = stream.read(); break;
        }
        while ((i != HproseTags.TagSemicolon) && (i != -1)) {
            result *= 10.0;
            result += (i - '0') * sign;
            i = stream.read();
        }
        return result;
    }

    private float parseFloat(String value) {
        try {
            return Float.parseFloat(value);
        }
        catch (NumberFormatException e) {
            return Float.NaN;
        }
    }

    private float parseFloat(StringBuilder value) {
        return parseFloat(value.toString());
    }

    private double parseDouble(String value) {
        try {
            return Double.parseDouble(value);
        }
        catch (NumberFormatException e) {
            return Double.NaN;
        }
    }

    private double parseDouble(StringBuilder value) {
        return parseDouble(value.toString());
    }

    private Object readDateAs(Class<?> type) throws IOException {
        int hour = 0, minute = 0, second = 0, nanosecond = 0;
        int year = stream.read() - '0';
        year = year * 10 + stream.read() - '0';
        year = year * 10 + stream.read() - '0';
        year = year * 10 + stream.read() - '0';
        int month = stream.read() - '0';
        month = month * 10 + stream.read() - '0';
        int day = stream.read() - '0';
        day = day * 10 + stream.read() - '0';
        int tag = stream.read();
        if (tag == HproseTags.TagTime) {
            hour = stream.read() - '0';
            hour = hour * 10 + stream.read() - '0';
            minute = stream.read() - '0';
            minute = minute * 10 + stream.read() - '0';
            second = stream.read() - '0';
            second = second * 10 + stream.read() - '0';
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
        }
        Calendar calendar = Calendar.getInstance(tag == HproseTags.TagUTC ?
                HproseHelper.UTC : HproseHelper.DefaultTZ);
        calendar.set(year, month - 1, day, hour, minute, second);
        calendar.set(Calendar.MILLISECOND, nanosecond / 1000000);
        if (Timestamp.class.equals(type)) {
            Timestamp timestamp = new Timestamp(calendar.getTimeInMillis());
            timestamp.setNanos(nanosecond);
            ref.add(timestamp);
            return timestamp;
        }
        ref.add(calendar);
        return calendar;
    }

    private Object readTimeAs(Class<?> type) throws IOException {
        int hour = stream.read() - '0';
        hour = hour * 10 + stream.read() - '0';
        int minute = stream.read() - '0';
        minute = minute * 10 + stream.read() - '0';
        int second = stream.read() - '0';
        second = second * 10 + stream.read() - '0';
        int nanosecond = 0;
        int tag = stream.read();
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
        Calendar calendar = Calendar.getInstance(tag == HproseTags.TagUTC ?
                HproseHelper.UTC : HproseHelper.DefaultTZ);
        calendar.set(1970, 0, 1, hour, minute, second);
        calendar.set(Calendar.MILLISECOND, nanosecond / 1000000);
        if (Timestamp.class.equals(type)) {
            Timestamp timestamp = new Timestamp(calendar.getTimeInMillis());
            timestamp.setNanos(nanosecond);
            ref.add(timestamp);
            return timestamp;
        }
        ref.add(calendar);
        return calendar;
    }

    private char readUTF8CharAsChar() throws IOException {
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
            default: throw new HproseException("bad utf-8 encoding at " +
                         ((c < 0) ? "end of stream" :
                         "0x" + Integer.toHexString(c & 0xff)));
        }
        return u;
    }

    @SuppressWarnings({"fallthrough"})
    private char[] readChars() throws IOException {
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
                    buf[i] = (char)c;
                    break;
                }
                case 12:
                case 13: {
                    // 110x xxxx   10xx xxxx
                    int c2 = stream.read();
                    buf[i] = (char)(((c & 0x1f) << 6) |
                                     (c2 & 0x3f));
                    break;
                }
                case 14: {
                    // 1110 xxxx  10xx xxxx  10xx xxxx
                    int c2 = stream.read();
                    int c3 = stream.read();
                    buf[i] = (char)(((c & 0x0f) << 12) |
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
                            buf[i++] = (char)(((s >> 10) & 0x03ff) | 0xd800);
                            buf[i] = (char)((s & 0x03ff) | 0xdc00);
                            break;
                        }
                    }
                }
                // NO break here
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                        ((c < 0) ? "end of stream" :
                        "0x" + Integer.toHexString(c & 0xff)));
            }
        }
        stream.read();
        return buf;
    }

    private String readCharsAsString() throws IOException {
        return new String(readChars());
    }

    @SuppressWarnings({"unchecked"})
    private Map readObjectAsMap(Map map) throws IOException {
        Object c = classref.get(readInt(HproseTags.TagOpenbrace));
        String[] memberNames = membersref.get(c);
        ref.add(map);
        int count = memberNames.length;
        for (int i = 0; i < count; i++) {
            map.put(memberNames[i], unserialize());
        }
        stream.read();
        return map;
    }

    private <T> T readMapAsObject(Class<T> type) throws IOException {
        T obj = HproseHelper.newInstance(type);
        if (obj == null) {
            throw new HproseException("Can not make an instance of type: " + type.toString());
        }
        ref.add(obj);
        Map<String, MemberAccessor> members = HproseHelper.getMembers(type, mode);
        int count = readInt(HproseTags.TagOpenbrace);
        for (int i = 0; i < count; i++) {
            MemberAccessor member = members.get(readString());
            if (member != null) {
                Object value = unserialize(member.cls, member.type, member.typecode);
                try {
                    member.set(obj, value);
                }
                catch (Exception e) {
                    throw new HproseException(e.getMessage());
                }
            }
            else {
                unserialize();
            }
        }
        stream.read();
        return obj;
    }

    private void readClass() throws IOException {
        String className = readCharsAsString();
        int count = readInt(HproseTags.TagOpenbrace);
        String[] memberNames = new String[count];
        for (int i = 0; i < count; i++) {
            memberNames[i] = readString();
        }
        stream.read();
        Type type = HproseHelper.getClass(className);
        Object key = (type.equals(void.class)) ? new Object() : type;
        classref.add(key);
        membersref.put(key, memberNames);
    }

    private Object readRef() throws IOException {
        return ref.get(readIntWithoutTag());
    }

    @SuppressWarnings({"unchecked"})
    private <T> T readRef(Class<T> type) throws IOException {
        Object obj = readRef();
        Class<?> objType = obj.getClass();
        if (objType.equals(type) ||
            type.isAssignableFrom(objType)) {
            return (T)obj;
        }
        throw castError(objType.toString(), type);
    }

    public int readIntWithoutTag() throws IOException {
        return readInt(HproseTags.TagSemicolon);
    }

    public BigInteger readBigIntegerWithoutTag() throws IOException {
        return new BigInteger(readUntil(HproseTags.TagSemicolon).toString(), 10);
    }

    public long readLongWithoutTag() throws IOException {
        return readLong(HproseTags.TagSemicolon);
    }

    public double readDoubleWithoutTag() throws IOException {
        return parseDouble(readUntil(HproseTags.TagSemicolon));
    }

    public double readInfinityWithoutTag() throws IOException {
        return ((stream.read() == HproseTags.TagNeg) ?
            Double.NEGATIVE_INFINITY : Double.POSITIVE_INFINITY);
    }

    public Calendar readDateWithoutTag()throws IOException {
        return (Calendar)readDateAs(Calendar.class);
    }

    public Calendar readTimeWithoutTag()throws IOException {
        return (Calendar)readTimeAs(Calendar.class);
    }

    public byte[] readBytesWithoutTag() throws IOException {
        int len = readInt(HproseTags.TagQuote);
        int off = 0;
        byte[] b = new byte[len];
        while (len > 0) {
            int size = stream.read(b, off, len);
            off += size;
            len -= size;
        }
        stream.read();
        ref.add(b);
        return b;
    }

    public String readUTF8CharWithoutTag() throws IOException {
        return new String(new char[] { readUTF8CharAsChar() });
    }

    public String readStringWithoutTag() throws IOException {
        String str = readCharsAsString();
        ref.add(str);
        return str;
    }

    public char[] readCharsWithoutTag() throws IOException {
        char[] chars = readChars();
        ref.add(chars);
        return chars;
    }

    public UUID readUUIDWithoutTag() throws IOException {
        checkTag(HproseTags.TagOpenbrace);
        char[] buf = new char[36];
        for (int i = 0; i < 36; i++) {
            buf[i] = (char) stream.read();
        }
        checkTag(HproseTags.TagClosebrace);
        UUID uuid = UUID.fromString(new String(buf));
        ref.add(uuid);
        return uuid;
    }

    @SuppressWarnings({"unchecked"})
    public ArrayList readListWithoutTag() throws IOException {
        int count = readInt(HproseTags.TagOpenbrace);
        ArrayList a = new ArrayList(count);
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a.add(unserialize());
        }
        stream.read();
        return a;
    }

    @SuppressWarnings({"unchecked"})
    public HashMap readMapWithoutTag() throws IOException {
        int count = readInt(HproseTags.TagOpenbrace);
        HashMap map = new HashMap(count);
        ref.add(map);
        for (int i = 0; i < count; i++) {
            Object key = unserialize();
            Object value = unserialize();
            map.put(key, value);
        }
        stream.read();
        return map;
    }

    public Object readObjectWithoutTag(Class<?> type) throws IOException {
        Object c = classref.get(readInt(HproseTags.TagOpenbrace));
        String[] memberNames = membersref.get(c);
        int count = memberNames.length;
        if (Class.class.equals(c.getClass())) {
            Class<?> cls = (Class<?>) c;
            if ((type == null) || type.isAssignableFrom(cls)) {
                type = cls;
            }
        }
        if (type == null) {
            HashMap<String, Object> map = new HashMap<String, Object>(count);
            ref.add(map);
            for (int i = 0; i < count; i++) {
                map.put(memberNames[i], unserialize());
            }
            stream.read();
            return map;
        }
        else {
            Object obj = HproseHelper.newInstance(type);
            ref.add(obj);
            Map<String, MemberAccessor> members = HproseHelper.getMembers(type, mode);
            for (int i = 0; i < count; i++) {
                MemberAccessor member = members.get(memberNames[i]);
                if (member != null) {
                    Object value = unserialize(member.cls, member.type, member.typecode);
                    try {
                        member.set(obj, value);
                    }
                    catch (Exception e) {
                        throw new HproseException(e.getMessage());
                    }
                }
                else {
                    unserialize();
                }
            }
            stream.read();
            return obj;
        }
    }

    private Object unserialize(int tag) throws IOException {
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
            case HproseTags.TagInteger: return readIntWithoutTag();
            case HproseTags.TagLong: return readBigIntegerWithoutTag();
            case HproseTags.TagDouble: return readDoubleWithoutTag();
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return "";
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return Double.NaN;
            case HproseTags.TagInfinity: return readInfinityWithoutTag();
            case HproseTags.TagDate: return readDateWithoutTag();
            case HproseTags.TagTime: return readTimeWithoutTag();
            case HproseTags.TagBytes: return readBytesWithoutTag();
            case HproseTags.TagUTF8Char: return readUTF8CharWithoutTag();
            case HproseTags.TagString: return readStringWithoutTag();
            case HproseTags.TagGuid: return readUUIDWithoutTag();
            case HproseTags.TagList: return readListWithoutTag();
            case HproseTags.TagMap: return readMapWithoutTag();
            case HproseTags.TagClass: readClass(); return readObject(null);
            case HproseTags.TagObject: return readObjectWithoutTag(null);
            case HproseTags.TagRef: return readRef();
            case HproseTags.TagError: throw new HproseException(readString());
            default: throw unexpectedTag(tag);
        }
    }

    public Object unserialize() throws IOException {
        return unserialize(stream.read());
    }

    private String tagToString(int tag) throws IOException {
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
            case HproseTags.TagInteger: return "Integer";
            case HproseTags.TagLong: return "BigInteger";
            case HproseTags.TagDouble: return "Double";
            case HproseTags.TagNull: return "Null";
            case HproseTags.TagEmpty: return "Empty String";
            case HproseTags.TagTrue: return "Boolean True";
            case HproseTags.TagFalse: return "Boolean False";
            case HproseTags.TagNaN: return "NaN";
            case HproseTags.TagInfinity: return "Infinity";
            case HproseTags.TagDate: return "DateTime";
            case HproseTags.TagTime: return "DateTime";
            case HproseTags.TagBytes: return "Byte[]";
            case HproseTags.TagUTF8Char: return "Char";
            case HproseTags.TagString: return "String";
            case HproseTags.TagGuid: return "Guid";
            case HproseTags.TagList: return "IList";
            case HproseTags.TagMap: return "IDictionary";
            case HproseTags.TagClass: return "Class";
            case HproseTags.TagObject: return "Object";
            case HproseTags.TagRef: return "Object Reference";
            case HproseTags.TagError: throw new HproseException(readString());
            default: throw unexpectedTag(tag);
        }
    }

    private boolean readBooleanWithTag(int tag) throws IOException {
        switch (tag) {
            case '0': return false;
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': return true;
            case HproseTags.TagInteger: return readIntWithoutTag() != 0;
            case HproseTags.TagLong: return !(BigInteger.ZERO.equals(readBigIntegerWithoutTag()));
            case HproseTags.TagDouble: return readDoubleWithoutTag() != 0.0;
            case HproseTags.TagEmpty: return false;
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return true;
            case HproseTags.TagInfinity: return true;
            case HproseTags.TagUTF8Char: return "\00".indexOf(readUTF8CharAsChar()) > -1;
            case HproseTags.TagString: return Boolean.parseBoolean(readStringWithoutTag());
            case HproseTags.TagRef: return Boolean.parseBoolean(readRef(String.class));
            default: throw castError(tagToString(tag), boolean.class);
        }
    }

    public boolean readBoolean() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return false;
            default: return readBooleanWithTag(tag);
        }
    }

    public Boolean readBooleanObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readBooleanWithTag(tag);
        }
    }

    private char readCharWithTag(int tag) throws IOException {
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
            case '9': return (char)tag;
            case HproseTags.TagInteger: return (char)readIntWithoutTag();
            case HproseTags.TagLong: return (char)readLongWithoutTag();
            case HproseTags.TagDouble: return (char)Double.valueOf(readDoubleWithoutTag()).intValue();
            case HproseTags.TagUTF8Char: return readUTF8CharAsChar();
            case HproseTags.TagString: return readStringWithoutTag().charAt(0);
            case HproseTags.TagRef: return readRef(String.class).charAt(0);
            default: throw castError(tagToString(tag), char.class);
        }
    }

    public char readChar() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return (char)0;
            default: return readCharWithTag(tag);
        }
    }

    public Character readCharObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readCharWithTag(tag);
        }
    }

    private byte readByteWithTag(int tag) throws IOException {
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
            case HproseTags.TagInteger: return readByte(HproseTags.TagSemicolon);
            case HproseTags.TagLong: return readByte(HproseTags.TagSemicolon);
            case HproseTags.TagDouble: return Double.valueOf(readDoubleWithoutTag()).byteValue();
            case HproseTags.TagEmpty: return 0;
            case HproseTags.TagTrue: return 1;
            case HproseTags.TagFalse: return 0;
            case HproseTags.TagUTF8Char: return (byte)readUTF8CharAsChar();
            case HproseTags.TagString: return Byte.parseByte(readStringWithoutTag());
            case HproseTags.TagRef: return Byte.parseByte(readRef(String.class));
            default: throw castError(tagToString(tag), byte.class);
        }
    }

    public byte readByte() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return 0;
            default: return readByteWithTag(tag);
        }
    }

    public Byte readByteObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readByteWithTag(tag);
        }
    }

    private short readShortWithTag(int tag) throws IOException {
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
            case HproseTags.TagInteger: return readShort(HproseTags.TagSemicolon);
            case HproseTags.TagLong: return readShort(HproseTags.TagSemicolon);
            case HproseTags.TagDouble: return Double.valueOf(readDoubleWithoutTag()).shortValue();
            case HproseTags.TagEmpty: return 0;
            case HproseTags.TagTrue: return 1;
            case HproseTags.TagFalse: return 0;
            case HproseTags.TagUTF8Char: return (short)readUTF8CharAsChar();
            case HproseTags.TagString: return Short.parseShort(readStringWithoutTag());
            case HproseTags.TagRef: return Short.parseShort(readRef(String.class));
            default: throw castError(tagToString(tag), short.class);
        }
    }

    public short readShort() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return 0;
            default: return readShortWithTag(tag);
        }
    }

    public Short readShortObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readShortWithTag(tag);
        }
    }

    private int readIntWithTag(int tag) throws IOException {
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
            case HproseTags.TagInteger: return readInt(HproseTags.TagSemicolon);
            case HproseTags.TagLong: return readInt(HproseTags.TagSemicolon);
            case HproseTags.TagDouble: return Double.valueOf(readDoubleWithoutTag()).intValue();
            case HproseTags.TagEmpty: return 0;
            case HproseTags.TagTrue: return 1;
            case HproseTags.TagFalse: return 0;
            case HproseTags.TagUTF8Char: return (int)readUTF8CharAsChar();
            case HproseTags.TagString: return Integer.parseInt(readStringWithoutTag());
            case HproseTags.TagRef: return Integer.parseInt(readRef(String.class));
            default: throw castError(tagToString(tag), int.class);
        }
    }

    public int readInt() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return 0;
            default: return readIntWithTag(tag);
        }
    }

    public Integer readIntObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readIntWithTag(tag);
        }
    }

    private long readLongWithTag(int tag) throws IOException {
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
            case HproseTags.TagInteger: return readLong(HproseTags.TagSemicolon);
            case HproseTags.TagLong: return readLong(HproseTags.TagSemicolon);
            case HproseTags.TagDouble: return Double.valueOf(readDoubleWithoutTag()).longValue();
            case HproseTags.TagEmpty: return 0l;
            case HproseTags.TagTrue: return 1l;
            case HproseTags.TagFalse: return 0l;
            case HproseTags.TagDate: return readDateWithoutTag().getTimeInMillis();
            case HproseTags.TagTime: return readTimeWithoutTag().getTimeInMillis();
            case HproseTags.TagUTF8Char: return (long)readUTF8CharAsChar();
            case HproseTags.TagString: return Long.parseLong(readStringWithoutTag());
            case HproseTags.TagRef: return Long.parseLong(readRef(String.class));
            default: throw castError(tagToString(tag), long.class);
        }
    }

    public long readLong() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return 0l;
            default: return readLongWithTag(tag);
        }
    }

    public Long readLongObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readLongWithTag(tag);
        }
    }

    private float readFloatWithTag(int tag) throws IOException {
        switch (tag) {
            case '0': return 0.0f;
            case '1': return 1.0f;
            case '2': return 2.0f;
            case '3': return 3.0f;
            case '4': return 4.0f;
            case '5': return 5.0f;
            case '6': return 6.0f;
            case '7': return 7.0f;
            case '8': return 8.0f;
            case '9': return 9.0f;
            case HproseTags.TagInteger: return readIntAsFloat();
            case HproseTags.TagLong: return readIntAsFloat();
            case HproseTags.TagDouble: return parseFloat(readUntil(HproseTags.TagSemicolon));
            case HproseTags.TagEmpty: return 0.0f;
            case HproseTags.TagTrue: return 1.0f;
            case HproseTags.TagFalse: return 0.0f;
            case HproseTags.TagNaN: return Float.NaN;
            case HproseTags.TagInfinity: return (stream.read() == HproseTags.TagPos) ?
                                                 Float.POSITIVE_INFINITY :
                                                 Float.NEGATIVE_INFINITY;
            case HproseTags.TagUTF8Char: return readUTF8CharAsChar();
            case HproseTags.TagString: return Float.parseFloat(readStringWithoutTag());
            case HproseTags.TagRef: return Float.parseFloat(readRef(String.class));
            default: throw castError(tagToString(tag), float.class);
        }
    }

    public float readFloat() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return 0.0f;
            default: return readFloatWithTag(tag);
        }
    }

    public Float readFloatObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readFloatWithTag(tag);
        }
    }

    private double readDoubleWithTag(int tag) throws IOException {
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
            case HproseTags.TagInteger: return readIntAsDouble();
            case HproseTags.TagLong: return readIntAsDouble();
            case HproseTags.TagDouble: return readDoubleWithoutTag();
            case HproseTags.TagEmpty: return 0.0;
            case HproseTags.TagTrue: return 1.0;
            case HproseTags.TagFalse: return 0.0;
            case HproseTags.TagNaN: return Double.NaN;
            case HproseTags.TagInfinity: return readInfinityWithoutTag();
            case HproseTags.TagUTF8Char: return (double)readUTF8CharAsChar();
            case HproseTags.TagString: return Double.parseDouble(readStringWithoutTag());
            case HproseTags.TagRef: return Double.parseDouble(readRef(String.class));
            default: throw castError(tagToString(tag), double.class);
        }
    }

    public double readDouble() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return 0.0;
            default: return readDoubleWithTag(tag);
        }
    }

    public Double readDoubleObject() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            default: return readDoubleWithTag(tag);
        }
    }

    public <T> T readEnum(Class<T> type) throws HproseException {
        try {
            return type.getEnumConstants()[readInt()];
        }
        catch (Exception e) {
            throw new HproseException(e.getMessage());
        }
    }

    public String readString() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return "0";
            case '1': return "1";
            case '2': return "2";
            case '3': return "3";
            case '4': return "4";
            case '5': return "5";
            case '6': return "6";
            case '7': return "7";
            case '8': return "8";
            case '9': return "9";
            case HproseTags.TagInteger: return readUntil(HproseTags.TagSemicolon).toString();
            case HproseTags.TagLong: return readUntil(HproseTags.TagSemicolon).toString();
            case HproseTags.TagDouble: return readUntil(HproseTags.TagSemicolon).toString();
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return "";
            case HproseTags.TagTrue: return "true";
            case HproseTags.TagFalse: return "false";
            case HproseTags.TagNaN: return "NaN";
            case HproseTags.TagInfinity: return (stream.read() == HproseTags.TagPos) ?
                                                 "Infinity" : "-Infinity";
            case HproseTags.TagDate: return readDateWithoutTag().toString();
            case HproseTags.TagTime: return readTimeWithoutTag().toString();
            case HproseTags.TagUTF8Char: return readUTF8CharWithoutTag();
            case HproseTags.TagString: return readStringWithoutTag();
            case HproseTags.TagGuid: return readUUIDWithoutTag().toString();
            case HproseTags.TagList: return readListWithoutTag().toString();
            case HproseTags.TagMap: return readMapWithoutTag().toString();
            case HproseTags.TagClass: readClass(); return readObject(null).toString();
            case HproseTags.TagObject: return readObjectWithoutTag(null).toString();
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof char[]) {
                    return new String((char[])obj);
                }
                return obj.toString();
            }
            default: throw castError(tagToString(tag), String.class);
        }
    }

    public BigInteger readBigInteger() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return BigInteger.ZERO;
            case '1': return BigInteger.ONE;
            case '2': return BigInteger.valueOf(2);
            case '3': return BigInteger.valueOf(3);
            case '4': return BigInteger.valueOf(4);
            case '5': return BigInteger.valueOf(5);
            case '6': return BigInteger.valueOf(6);
            case '7': return BigInteger.valueOf(7);
            case '8': return BigInteger.valueOf(8);
            case '9': return BigInteger.valueOf(9);
            case HproseTags.TagInteger: return BigInteger.valueOf(readIntWithoutTag());
            case HproseTags.TagLong: return readBigIntegerWithoutTag();
            case HproseTags.TagDouble: return BigInteger.valueOf(Double.valueOf(readDoubleWithoutTag()).longValue());
            case HproseTags.TagNull: return BigInteger.ZERO;
            case HproseTags.TagEmpty: return BigInteger.ZERO;
            case HproseTags.TagTrue: return BigInteger.ONE;
            case HproseTags.TagFalse: return BigInteger.ZERO;
            case HproseTags.TagDate: return BigInteger.valueOf(readDateWithoutTag().getTimeInMillis());
            case HproseTags.TagTime: return BigInteger.valueOf(readTimeWithoutTag().getTimeInMillis());
            case HproseTags.TagUTF8Char: return BigInteger.valueOf((long)readUTF8CharAsChar());
            case HproseTags.TagString: return new BigInteger(readStringWithoutTag());
            case HproseTags.TagRef: return new BigInteger(readRef(String.class));
            default: throw castError(tagToString(tag), BigInteger.class);
        }
    }

    public Date readDate() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return new Date(0l);
            case '1': return new Date(1l);
            case '2': return new Date(2l);
            case '3': return new Date(3l);
            case '4': return new Date(4l);
            case '5': return new Date(5l);
            case '6': return new Date(6l);
            case '7': return new Date(7l);
            case '8': return new Date(8l);
            case '9': return new Date(9l);
            case HproseTags.TagInteger:
            case HproseTags.TagLong: return new Date(readLongWithoutTag());
            case HproseTags.TagDouble: return new Date(Double.valueOf(readDoubleWithoutTag()).longValue());
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return null;
            case HproseTags.TagDate: return new Date(readDateWithoutTag().getTimeInMillis());
            case HproseTags.TagTime: return new Date(readTimeWithoutTag().getTimeInMillis());
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof Calendar) {
                    return new Date(((Calendar)obj).getTimeInMillis());
                }
                if (obj instanceof Timestamp) {
                    return new Date(((Timestamp)obj).getTime());
                }
                throw castError(obj, Date.class);
            }
            default: throw castError(tagToString(tag), Date.class);
        }
    }

    public Time readTime() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return new Time(0l);
            case '1': return new Time(1l);
            case '2': return new Time(2l);
            case '3': return new Time(3l);
            case '4': return new Time(4l);
            case '5': return new Time(5l);
            case '6': return new Time(6l);
            case '7': return new Time(7l);
            case '8': return new Time(8l);
            case '9': return new Time(9l);
            case HproseTags.TagInteger:
            case HproseTags.TagLong: return new Time(readLongWithoutTag());
            case HproseTags.TagDouble: return new Time(Double.valueOf(readDoubleWithoutTag()).longValue());
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return null;
            case HproseTags.TagDate: return new Time(readDateWithoutTag().getTimeInMillis());
            case HproseTags.TagTime: return new Time(readTimeWithoutTag().getTimeInMillis());
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof Calendar) {
                    return new Time(((Calendar)obj).getTimeInMillis());
                }
                if (obj instanceof Timestamp) {
                    return new Time(((Timestamp)obj).getTime());
                }
                throw castError(obj, Time.class);
            }
            default: throw castError(tagToString(tag), Time.class);
        }
    }

    public java.util.Date readDateTime() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return new java.util.Date(0l);
            case '1': return new java.util.Date(1l);
            case '2': return new java.util.Date(2l);
            case '3': return new java.util.Date(3l);
            case '4': return new java.util.Date(4l);
            case '5': return new java.util.Date(5l);
            case '6': return new java.util.Date(6l);
            case '7': return new java.util.Date(7l);
            case '8': return new java.util.Date(8l);
            case '9': return new java.util.Date(9l);
            case HproseTags.TagInteger:
            case HproseTags.TagLong: return new java.util.Date(readLongWithoutTag());
            case HproseTags.TagDouble: return new java.util.Date(Double.valueOf(readDoubleWithoutTag()).longValue());
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return null;
            case HproseTags.TagDate: return new java.util.Date(readDateWithoutTag().getTimeInMillis());
            case HproseTags.TagTime: return new java.util.Date(readTimeWithoutTag().getTimeInMillis());
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof Calendar) {
                    return new java.util.Date(((Calendar)obj).getTimeInMillis());
                }
                if (obj instanceof Timestamp) {
                    return new java.util.Date(((Timestamp)obj).getTime());
                }
                throw castError(obj, java.util.Date.class);
            }
            default: throw castError(tagToString(tag), java.util.Date.class);
        }
    }

    public Timestamp readTimestamp() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return new Timestamp(0l);
            case '1': return new Timestamp(1l);
            case '2': return new Timestamp(2l);
            case '3': return new Timestamp(3l);
            case '4': return new Timestamp(4l);
            case '5': return new Timestamp(5l);
            case '6': return new Timestamp(6l);
            case '7': return new Timestamp(7l);
            case '8': return new Timestamp(8l);
            case '9': return new Timestamp(9l);
            case HproseTags.TagInteger:
            case HproseTags.TagLong: return new Timestamp(readLongWithoutTag());
            case HproseTags.TagDouble: return new Timestamp(Double.valueOf(readDoubleWithoutTag()).longValue());
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return null;
            case HproseTags.TagDate: return (Timestamp)readDateAs(Timestamp.class);
            case HproseTags.TagTime: return (Timestamp)readTimeAs(Timestamp.class);
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof Calendar) {
                    return new Timestamp(((Calendar)obj).getTimeInMillis());
                }
                if (obj instanceof Timestamp) {
                    return (Timestamp)obj;
                }
                throw castError(obj, Timestamp.class);
            }
            default: throw castError(tagToString(tag), Timestamp.class);
        }
    }

    public Calendar readCalendar() throws IOException {
        int tag = stream.read();
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
            case '9': {
                Calendar calendar = Calendar.getInstance();
                calendar.setTimeInMillis(tag - '0');
                return calendar;
            }
            case HproseTags.TagInteger:
            case HproseTags.TagLong: {
                Calendar calendar = Calendar.getInstance();
                calendar.setTimeInMillis(readLongWithoutTag());
                return calendar;
            }
            case HproseTags.TagDouble: {
                Calendar calendar = Calendar.getInstance();
                calendar.setTimeInMillis(Double.valueOf(readDoubleWithoutTag()).longValue());
                return calendar;
            }
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return null;
            case HproseTags.TagDate: return readDateWithoutTag();
            case HproseTags.TagTime: return readTimeWithoutTag();
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof Calendar) {
                    return (Calendar)obj;
                }
                if (obj instanceof Timestamp) {
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTimeInMillis(((Timestamp)obj).getTime());
                    return calendar;
                }
                throw castError(obj, Calendar.class);
            }
            default: throw castError(tagToString(tag), Calendar.class);
        }
    }

    public BigDecimal readBigDecimal() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return BigDecimal.ZERO;
            case '1': return BigDecimal.ONE;
            case '2': return BigDecimal.valueOf(2);
            case '3': return BigDecimal.valueOf(3);
            case '4': return BigDecimal.valueOf(4);
            case '5': return BigDecimal.valueOf(5);
            case '6': return BigDecimal.valueOf(6);
            case '7': return BigDecimal.valueOf(7);
            case '8': return BigDecimal.valueOf(8);
            case '9': return BigDecimal.valueOf(9);
            case HproseTags.TagInteger: return new BigDecimal(readIntWithoutTag());
            case HproseTags.TagLong: return new BigDecimal(readLongWithoutTag());
            case HproseTags.TagDouble: return new BigDecimal(readUntil(HproseTags.TagSemicolon).toString());
            case HproseTags.TagNull: return BigDecimal.ZERO;
            case HproseTags.TagEmpty: return BigDecimal.ZERO;
            case HproseTags.TagTrue: return BigDecimal.ONE;
            case HproseTags.TagFalse: return BigDecimal.ZERO;
            case HproseTags.TagUTF8Char: return new BigDecimal((long)readUTF8CharAsChar());
            case HproseTags.TagString: return new BigDecimal(readStringWithoutTag());
            case HproseTags.TagRef: return new BigDecimal(readRef(String.class));
            default: throw castError(tagToString(tag), BigDecimal.class);
        }
    }

    public StringBuilder readStringBuilder() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return new StringBuilder("0");
            case '1': return new StringBuilder("1");
            case '2': return new StringBuilder("2");
            case '3': return new StringBuilder("3");
            case '4': return new StringBuilder("4");
            case '5': return new StringBuilder("5");
            case '6': return new StringBuilder("6");
            case '7': return new StringBuilder("7");
            case '8': return new StringBuilder("8");
            case '9': return new StringBuilder("9");
            case HproseTags.TagInteger: return readUntil(HproseTags.TagSemicolon);
            case HproseTags.TagLong: return readUntil(HproseTags.TagSemicolon);
            case HproseTags.TagDouble: return readUntil(HproseTags.TagSemicolon);
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return new StringBuilder();
            case HproseTags.TagTrue: return new StringBuilder("true");
            case HproseTags.TagFalse: return new StringBuilder("false");
            case HproseTags.TagNaN: return new StringBuilder("NaN");
            case HproseTags.TagInfinity: return new StringBuilder(
                                                (stream.read() == HproseTags.TagPos) ?
                                                "Infinity" : "-Infinity");
            case HproseTags.TagDate: return new StringBuilder(readDateWithoutTag().toString());
            case HproseTags.TagTime: return new StringBuilder(readTimeWithoutTag().toString());
            case HproseTags.TagUTF8Char: return new StringBuilder(1).append(readUTF8CharAsChar());
            case HproseTags.TagString: return new StringBuilder(readStringWithoutTag());
            case HproseTags.TagGuid: return new StringBuilder(readUUIDWithoutTag().toString());
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof char[]) {
                    return new StringBuilder(new String((char[])obj));
                }
                return new StringBuilder(obj.toString());
            }
            default: throw castError(tagToString(tag), StringBuilder.class);
        }
    }

    public StringBuffer readStringBuffer() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case '0': return new StringBuffer("0");
            case '1': return new StringBuffer("1");
            case '2': return new StringBuffer("2");
            case '3': return new StringBuffer("3");
            case '4': return new StringBuffer("4");
            case '5': return new StringBuffer("5");
            case '6': return new StringBuffer("6");
            case '7': return new StringBuffer("7");
            case '8': return new StringBuffer("8");
            case '9': return new StringBuffer("9");
            case HproseTags.TagInteger: return new StringBuffer(readUntil(HproseTags.TagSemicolon));
            case HproseTags.TagLong: return new StringBuffer(readUntil(HproseTags.TagSemicolon));
            case HproseTags.TagDouble: return new StringBuffer(readUntil(HproseTags.TagSemicolon));
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return new StringBuffer();
            case HproseTags.TagTrue: return new StringBuffer("true");
            case HproseTags.TagFalse: return new StringBuffer("false");
            case HproseTags.TagNaN: return new StringBuffer("NaN");
            case HproseTags.TagInfinity: return new StringBuffer(
                                                (stream.read() == HproseTags.TagPos) ?
                                                "Infinity" : "-Infinity");
            case HproseTags.TagDate: return new StringBuffer(readDateWithoutTag().toString());
            case HproseTags.TagTime: return new StringBuffer(readTimeWithoutTag().toString());
            case HproseTags.TagUTF8Char: return new StringBuffer(1).append(readUTF8CharAsChar());
            case HproseTags.TagString: return new StringBuffer(readStringWithoutTag());
            case HproseTags.TagGuid: return new StringBuffer(readUUIDWithoutTag().toString());
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof char[]) {
                    return new StringBuffer(new String((char[])obj));
                }
                return new StringBuffer(obj.toString());
            }
            default: throw castError(tagToString(tag), StringBuffer.class);
        }
    }

    public UUID readUUID() throws IOException  {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return null;
            case HproseTags.TagBytes: return UUID.nameUUIDFromBytes(readBytesWithoutTag());
            case HproseTags.TagGuid: return readUUIDWithoutTag();
            case HproseTags.TagString: return UUID.fromString(readStringWithoutTag());
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof UUID) {
                    return (UUID)obj;
                }
                if (obj instanceof byte[]) {
                    return UUID.nameUUIDFromBytes((byte[])obj);
                }
                if (obj instanceof String) {
                    return UUID.fromString((String)obj);
                }
                if (obj instanceof char[]) {
                    return UUID.fromString(new String((char[])obj));
                }
                throw castError(obj, UUID.class);
            }
            default: throw castError(tagToString(tag), UUID.class);
        }
    }

    public void readArray(Type[] types, Object[] a, int count) throws IOException {
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = unserialize(types[i]);
        }
        stream.read();
    }

    public Object[] readArray(int count) throws IOException {
        Object[] a = new Object[count];
        ref.add(a);
        for (int i = 0; i < count; i++) {
            a[i] = unserialize();
        }
        stream.read();
        return a;
    }

    public Object[] readObjectArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: return readArray(readInt(HproseTags.TagOpenbrace));
            case HproseTags.TagRef: return (Object[])readRef();
            default: throw castError(tagToString(tag), Object[].class);
        }
    }

    public boolean[] readBooleanArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                boolean[] a = new boolean[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readBoolean();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (boolean[])readRef();
            default: throw castError(tagToString(tag), boolean[].class);
        }
    }

    public char[] readCharArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagUTF8Char: return new char[] { readUTF8CharAsChar() };
            case HproseTags.TagString: return readCharsWithoutTag();
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                char[] a = new char[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readChar();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof char[]) {
                    return (char[])obj;
                }
                if (obj instanceof String) {
                    return ((String)obj).toCharArray();
                }
                throw castError(obj, char[].class);
            }
            default: throw castError(tagToString(tag), char[].class);
        }
    }

    public byte[] readByteArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagUTF8Char: return readUTF8CharWithoutTag().getBytes("UTF-8");
            case HproseTags.TagString: return readStringWithoutTag().getBytes("UTF-8");
            case HproseTags.TagBytes: return readBytesWithoutTag();
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                byte[] a = new byte[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readByte();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: {
                Object obj = readRef();
                if (obj instanceof byte[]) {
                    return (byte[])obj;
                }
                if (obj instanceof String) {
                    return ((String)obj).getBytes("UTF-8");
                }
                throw castError(obj, byte[].class);
            }
            default: throw castError(tagToString(tag), byte[].class);
        }
    }

    public short[] readShortArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                short[] a = new short[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readShort();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (short[])readRef();
            default: throw castError(tagToString(tag), short[].class);
        }
    }

    public int[] readIntArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                int[] a = new int[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readInt();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (int[])readRef();
            default: throw castError(tagToString(tag), int[].class);
        }
    }

    public long[] readLongArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                long[] a = new long[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readLong();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (long[])readRef();
            default: throw castError(tagToString(tag), long[].class);
        }
    }

    public float[] readFloatArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                float[] a = new float[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readFloat();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (float[])readRef();
            default: throw castError(tagToString(tag), float[].class);
        }
    }

    public double[] readDoubleArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                double[] a = new double[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readDouble();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (double[])readRef();
            default: throw castError(tagToString(tag), double[].class);
        }
    }

    public String[] readStringArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                String[] a = new String[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readString();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (String[])readRef();
            default: throw castError(tagToString(tag), String[].class);
        }
    }

    public BigInteger[] readBigIntegerArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                BigInteger[] a = new BigInteger[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readBigInteger();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (BigInteger[])readRef();
            default: throw castError(tagToString(tag), BigInteger[].class);
        }
    }

    public Date[] readDateArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                Date[] a = new Date[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readDate();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (Date[])readRef();
            default: throw castError(tagToString(tag), Date[].class);
        }
    }

    public Time[] readTimeArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                Time[] a = new Time[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readTime();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (Time[])readRef();
            default: throw castError(tagToString(tag), Time[].class);
        }
    }

    public Timestamp[] readTimestampArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                Timestamp[] a = new Timestamp[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readTimestamp();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (Timestamp[])readRef();
            default: throw castError(tagToString(tag), Timestamp[].class);
        }
    }

    public java.util.Date[] readDateTimeArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                java.util.Date[] a = new java.util.Date[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readDateTime();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (java.util.Date[])readRef();
            default: throw castError(tagToString(tag), java.util.Date[].class);
        }
    }

    public Calendar[] readCalendarArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                Calendar[] a = new Calendar[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readCalendar();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (Calendar[])readRef();
            default: throw castError(tagToString(tag), Calendar[].class);
        }
    }

    public BigDecimal[] readBigDecimalArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                BigDecimal[] a = new BigDecimal[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readBigDecimal();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (BigDecimal[])readRef();
            default: throw castError(tagToString(tag), BigDecimal[].class);
        }
    }

    public StringBuilder[] readStringBuilderArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                StringBuilder[] a = new StringBuilder[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readStringBuilder();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (StringBuilder[])readRef();
            default: throw castError(tagToString(tag), StringBuilder[].class);
        }
    }

    public StringBuffer[] readStringBufferArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                StringBuffer[] a = new StringBuffer[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readStringBuffer();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (StringBuffer[])readRef();
            default: throw castError(tagToString(tag), StringBuffer[].class);
        }
    }

    public UUID[] readUUIDArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                UUID[] a = new UUID[count];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readUUID();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (UUID[])readRef();
            default: throw castError(tagToString(tag), UUID[].class);
        }
    }

    public char[][] readCharsArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                char[][] a = new char[count][];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readCharArray();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (char[][])readRef();
            default: throw castError(tagToString(tag), char[][].class);
        }
    }

    public byte[][] readBytesArray() throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                byte[][] a = new byte[count][];
                ref.add(a);
                for (int i = 0; i < count; i++) {
                    a[i] = readByteArray();
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (byte[][])readRef();
            default: throw castError(tagToString(tag), byte[][].class);
        }
    }

    @SuppressWarnings({"unchecked"})
    public <T> T[] readOtherTypeArray(Class<T> componentClass, Type componentType) throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                T[] a = (T[])Array.newInstance(componentClass, count);
                ref.add(a);
                int typecode = TypeCode.get(componentClass);
                for (int i = 0; i < count; i++) {
                    a[i] = (T)unserialize(componentClass, componentType, typecode);
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (T[])readRef();
            default: throw castError(tagToString(tag), Array.newInstance(componentClass, 0).getClass());
        }
    }

    @SuppressWarnings({"unchecked"})
    public Collection readCollection(Class<?> cls, Type type) throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: {
                int count = readInt(HproseTags.TagOpenbrace);
                Collection a = (Collection)HproseHelper.newInstance(cls);
                ref.add(a);
                Type componentType;
                Class<?> componentClass;
                if (type instanceof ParameterizedType) {
                    componentType = ((ParameterizedType)type).getActualTypeArguments()[0];
                    componentClass = HproseHelper.toClass(componentType);
                }
                else {
                    componentType = Object.class;
                    componentClass = Object.class;
                }
                int typecode = TypeCode.get(componentClass);
                for (int i = 0; i < count; i++) {
                    a.add(unserialize(componentClass, componentType, typecode));
                }
                stream.read();
                return a;
            }
            case HproseTags.TagRef: return (Collection)readRef();
            default: throw castError(tagToString(tag), cls);
        }
    }

    @SuppressWarnings({"unchecked"})
    private Map readListAsMap(Class<?> cls, Type type) throws IOException {
        int count = readInt(HproseTags.TagOpenbrace);
        Map m = (Map)HproseHelper.newInstance(cls);
        ref.add(m);
        if (count > 0) {
            Type keyType, valueType;
            Class<?> keyClass, valueClass;
            if (type instanceof ParameterizedType) {
                Type[] argsType = ((ParameterizedType)type).getActualTypeArguments();
                keyType = argsType[0];
                valueType = argsType[1];
                keyClass = HproseHelper.toClass(keyType);
                valueClass = HproseHelper.toClass(valueType);
            }
            else {
                valueType = Object.class;
                keyClass = Object.class;
                valueClass = Object.class;
            }
            int valueTypecode = TypeCode.get(valueClass);
            if (keyClass.equals(int.class) &&
                keyClass.equals(Integer.class) &&
                keyClass.equals(String.class) &&
                keyClass.equals(Object.class)) {
                throw castError(tagToString(HproseTags.TagList), cls);
            }
            for (int i = 0; i < count; i++) {
                Object key = (keyClass.equals(String.class) ? String.valueOf(i) : i);
                Object value = unserialize(valueClass, valueType, valueTypecode);
                m.put(key, value);
            }
        }
        stream.read();
        return m;
    }

    @SuppressWarnings({"unchecked"})
    private Map readMapWithoutTag(Class<?> cls, Type type) throws IOException {
        int count = readInt(HproseTags.TagOpenbrace);
        Map m = (Map)HproseHelper.newInstance(cls);
        ref.add(m);
        Type keyType, valueType;
        Class<?> keyClass, valueClass;
        if (type instanceof ParameterizedType) {
            Type[] argsType = ((ParameterizedType)type).getActualTypeArguments();
            keyType = argsType[0];
            valueType = argsType[1];
            keyClass = HproseHelper.toClass(keyType);
            valueClass = HproseHelper.toClass(valueType);
        }
        else {
            keyType = Object.class;
            valueType = Object.class;
            keyClass = Object.class;
            valueClass = Object.class;
        }
        int keyTypecode = TypeCode.get(keyClass);
        int valueTypecode = TypeCode.get(valueClass);
        for (int i = 0; i < count; i++) {
            Object key = unserialize(keyClass, keyType, keyTypecode);
            Object value = unserialize(valueClass, valueType, valueTypecode);
            m.put(key, value);
        }
        stream.read();
        return m;
    }

    @SuppressWarnings({"unchecked"})
    public Map readMap(Class<?> cls, Type type) throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagList: return readListAsMap(cls, type);
            case HproseTags.TagMap: return readMapWithoutTag(cls, type);
            case HproseTags.TagClass: readClass(); return readMap(cls, type);
            case HproseTags.TagObject: return readObjectAsMap((Map)HproseHelper.newInstance(cls));
            case HproseTags.TagRef: return (Map)readRef();
            default: throw castError(tagToString(tag), cls);
        }
    }

    public Object readObject(Class<?> type) throws IOException {
        int tag = stream.read();
        switch (tag) {
            case HproseTags.TagNull: return null;
            case HproseTags.TagMap: return readMapAsObject(type);
            case HproseTags.TagClass: readClass(); return readObject(type);
            case HproseTags.TagObject: return readObjectWithoutTag(type);
            case HproseTags.TagRef: return readRef(type);
            default: throw castError(tagToString(tag), type);
        }
    }

    public Object unserialize(Type type) throws IOException {
        if (type == null) {
            return unserialize();
        }
        Class<?> cls = HproseHelper.toClass(type);
        return unserialize(cls, type, TypeCode.get(cls));
    }

    @SuppressWarnings({"unchecked"})
    public <T> T unserialize(Class<T> type) throws IOException {
        return (T) unserialize(type, type, TypeCode.get(type));
    }

    private Object unserialize(Class<?> cls, Type type, int typecode) throws IOException {
        switch (typecode) {
            case TypeCode.Null: return unserialize();
            case TypeCode.BooleanType: return readBoolean();
            case TypeCode.CharType: return readChar();
            case TypeCode.ByteType: return readByte();
            case TypeCode.ShortType: return readShort();
            case TypeCode.IntType: return readInt();
            case TypeCode.LongType: return readLong();
            case TypeCode.FloatType: return readFloat();
            case TypeCode.DoubleType: return readDouble();
            case TypeCode.Enum: return readEnum(cls);
            case TypeCode.Object: return unserialize();
            case TypeCode.Boolean: return readBooleanObject();
            case TypeCode.Character: return readCharObject();
            case TypeCode.Byte: return readByteObject();
            case TypeCode.Short: return readShortObject();
            case TypeCode.Integer: return readIntObject();
            case TypeCode.Long: return readLongObject();
            case TypeCode.Float: return readFloatObject();
            case TypeCode.Double: return readDoubleObject();
            case TypeCode.String: return readString();
            case TypeCode.BigInteger: return readBigInteger();
            case TypeCode.Date: return readDate();
            case TypeCode.Time: return readTime();
            case TypeCode.Timestamp: return readTimestamp();
            case TypeCode.DateTime: return readDateTime();
            case TypeCode.Calendar: return readCalendar();
            case TypeCode.BigDecimal: return readBigDecimal();
            case TypeCode.StringBuilder: return readStringBuilder();
            case TypeCode.StringBuffer: return readStringBuffer();
            case TypeCode.UUID: return readUUID();
            case TypeCode.ObjectArray: return readObjectArray();
            case TypeCode.BooleanArray: return readBooleanArray();
            case TypeCode.CharArray: return readCharArray();
            case TypeCode.ByteArray: return readByteArray();
            case TypeCode.ShortArray: return readShortArray();
            case TypeCode.IntArray: return readIntArray();
            case TypeCode.LongArray: return readLongArray();
            case TypeCode.FloatArray: return readFloatArray();
            case TypeCode.DoubleArray: return readDoubleArray();
            case TypeCode.StringArray: return readStringArray();
            case TypeCode.BigIntegerArray: return readBigIntegerArray();
            case TypeCode.DateArray: return readDateArray();
            case TypeCode.TimeArray: return readTimeArray();
            case TypeCode.TimestampArray: return readTimestampArray();
            case TypeCode.DateTimeArray: return readDateTimeArray();
            case TypeCode.CalendarArray: return readCalendarArray();
            case TypeCode.BigDecimalArray: return readBigDecimalArray();
            case TypeCode.StringBuilderArray: return readStringBuilderArray();
            case TypeCode.StringBufferArray: return readStringBufferArray();
            case TypeCode.UUIDArray: return readUUIDArray();
            case TypeCode.CharsArray: return readCharsArray();
            case TypeCode.BytesArray: return readBytesArray();
            case TypeCode.OtherTypeArray: {
                Class<?> componentClass = cls.getComponentType();
                if (type instanceof GenericArrayType) {
                    Type componentType = ((GenericArrayType)type).getGenericComponentType();
                    return readOtherTypeArray(componentClass, componentType);
                }
                else {
                    return readOtherTypeArray(componentClass, componentClass);
                }
            }
            case TypeCode.ArrayList:
            case TypeCode.AbstractList:
            case TypeCode.AbstractCollection:
            case TypeCode.List:
            case TypeCode.Collection: return readCollection(ArrayList.class, type);
            case TypeCode.AbstractSequentialList:
            case TypeCode.LinkedList: return readCollection(LinkedList.class, type);
            case TypeCode.HashSet:
            case TypeCode.AbstractSet:
            case TypeCode.Set: return readCollection(HashSet.class, type);
            case TypeCode.TreeSet:
            case TypeCode.SortedSet: return readCollection(TreeSet.class, type);
            case TypeCode.CollectionType: {
                if (isInstantiableClass(cls)) {
                    return readCollection(cls, type);
                }
                else {
                    throw new HproseException(type.toString() + " is not an instantiable class.");
                }
            }
            case TypeCode.HashMap:
            case TypeCode.AbstractMap:
            case TypeCode.Map: return readMap(HashMap.class, type);
            case TypeCode.TreeMap:
            case TypeCode.SortedMap: return readMap(TreeMap.class, type);
            case TypeCode.MapType: {
                if (isInstantiableClass(cls)) {
                    return readMap(cls, type);
                }
                else {
                    throw new HproseException(type.toString() + " is not an instantiable class.");
                }
            }
            case TypeCode.OtherType: return readObject(cls);
        }
        throw new HproseException("Can not unserialize this type: " + type.toString());
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
        ostream.write(tag);
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
                break;
            case HproseTags.TagInfinity:
                ostream.write(stream.read());
                break;
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble:
            case HproseTags.TagRef:
                readNumberRaw(ostream);
                break;
            case HproseTags.TagDate:
            case HproseTags.TagTime:
                readDateTimeRaw(ostream);
                break;
            case HproseTags.TagUTF8Char:
                readUTF8CharRaw(ostream);
                break;
            case HproseTags.TagBytes:
                readBytesRaw(ostream);
                break;
            case HproseTags.TagString:
                readStringRaw(ostream);
                break;
            case HproseTags.TagGuid:
                readGuidRaw(ostream);
                break;
            case HproseTags.TagList:
            case HproseTags.TagMap:
            case HproseTags.TagObject:
                readComplexRaw(ostream);
                break;
            case HproseTags.TagClass:
                readComplexRaw(ostream);
                readRaw(ostream);
                break;
            case HproseTags.TagError:
                readRaw(ostream);
                break;
            case -1:
                throw new HproseException("No byte found in stream");
            default:
                throw new HproseException("Unexpected serialize tag '" +
                        (char) tag + "' in stream");
        }
    }

    private void readNumberRaw(OutputStream ostream) throws IOException {
        int tag;
        do {
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon);
    }

    private void readDateTimeRaw(OutputStream ostream) throws IOException {
        int tag;
        do {
            tag = stream.read();
            ostream.write(tag);
        } while (tag != HproseTags.TagSemicolon &&
                 tag != HproseTags.TagUTC);
    }

    private void readUTF8CharRaw(OutputStream ostream) throws IOException {
        int tag = stream.read();
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

    private void readBytesRaw(OutputStream ostream) throws IOException {
        int len = 0;
        int tag = '0';
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

    @SuppressWarnings({"fallthrough"})
    private void readStringRaw(OutputStream ostream) throws IOException {
        int count = 0;
        int tag = '0';
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
                }
                // No break here
                default:
                    throw new HproseException("bad utf-8 encoding at " +
                        ((tag < 0) ? "end of stream" :
                        "0x" + Integer.toHexString(tag & 0xff)));
            }
        }
        ostream.write(stream.read());
    }

    private void readGuidRaw(OutputStream ostream) throws IOException {
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

    private void readComplexRaw(OutputStream ostream) throws IOException {
        int tag;
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