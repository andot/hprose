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
import hprose.common.UUID;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Serializable;
import java.lang.ref.SoftReference;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TimeZone;
import java.util.Vector;

public final class HproseWriter {
    private static final Object[] nullArgs = new Object[0];
    private static final HashMap fieldsCache = new HashMap();
    private static final HashMap propertiesCache = new HashMap();
    private static final HashMap membersCache = new HashMap();
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
        else if (obj instanceof Byte ||
                 obj instanceof Short ||
                 obj instanceof Integer) {
            writeInteger(((Number) obj).intValue());
        }
        else if (obj instanceof Character) {
            writeUTF8Char(((Character) obj).charValue());
        }
        else if (obj instanceof Long) {
            writeLong(((Long) obj).longValue());
        }
        else if (obj instanceof BigInteger) {
            writeLong((BigInteger) obj);
        }
        else if (obj instanceof Float ||
                 obj instanceof Double) {
            writeDouble(((Number) obj).doubleValue());
        }
        else if (obj instanceof Boolean) {
            writeBoolean(((Boolean) obj).booleanValue());
        }
        else if (obj instanceof Date) {
            writeDate((Date) obj, true);
        }
        else if (obj instanceof Calendar) {
            writeDate((Calendar) obj, true);
        }
        else if (obj instanceof BigDecimal) {
            writeString(obj.toString(), true);
        }
        else if (obj instanceof String ||
                 obj instanceof StringBuffer) {
            String s = obj.toString();
            switch (s.length()) {
                case 0: writeEmpty(); break;
                case 1: writeUTF8Char(s.charAt(0)); break;
                default: writeString(s, true); break;
            }
        }
        else if (obj instanceof UUID) {
            writeUUID((UUID)obj, true);
        }
        else if (obj instanceof char[]) {
            char[] cs = (char[]) obj;
            switch (cs.length) {
                case 0: writeEmpty(); break;
                case 1: writeUTF8Char(cs[0]); break;
                default: writeString(cs, true); break;
            }
        }
        else if (obj instanceof byte[]) {
            if (((byte[]) obj).length == 0) {
                writeEmpty();
            }
            else {
                writeBytes((byte[]) obj, true);
            }
        }
        else if (obj instanceof short[]) {
            writeArray((short[]) obj, true);
        }
        else if (obj instanceof int[]) {
            writeArray((int[]) obj, true);
        }
        else if (obj instanceof long[]) {
            writeArray((long[]) obj, true);
        }
        else if (obj instanceof float[]) {
            writeArray((float[]) obj, true);
        }
        else if (obj instanceof double[]) {
            writeArray((double[]) obj, true);
        }
        else if (obj instanceof boolean[]) {
            writeArray((boolean[]) obj, true);
        }
        else if (obj instanceof String[]) {
            writeArray((String[]) obj, true);
        }
        else if (obj instanceof StringBuffer[]) {
            writeArray((StringBuffer[]) obj, true);
        }
        else if (obj instanceof char[][]) {
            writeArray((char[][]) obj, true);
        }
        else if (obj instanceof byte[][]) {
            writeArray((byte[][]) obj, true);
        }
        else if (obj instanceof BigInteger[]) {
            writeArray((BigInteger[]) obj, true);
        }
        else if (obj instanceof BigDecimal[]) {
            writeArray((BigDecimal[]) obj, true);
        }
        else if (obj instanceof Object[]) {
            writeArray((Object[]) obj, true);
        }
        else if (!(obj instanceof Serializable)) {
            throw new HproseException(obj.getClass().getName() + " is not a serializable type");
        }
        else if (obj.getClass().isArray()) {
            writeArray(obj, true);
        }
        else if (obj instanceof ArrayList ||
                 obj instanceof Vector) {
            writeList((List) obj, true);
        }
        else if (obj instanceof Collection) {
            writeCollection((Collection) obj, true);
        }
        else if (obj instanceof Map) {
            writeMap((Map) obj, true);
        }
        else if ((HproseHelper.enumClass != null) &&
                  HproseHelper.enumClass.isAssignableFrom(obj.getClass())) {
            writeEnum(obj);
        }
        else {
            writeObject(obj, true);
        }
    }

    public void writeEnum(Object obj) throws IOException  {
        try {
            writeInteger(((Integer) HproseHelper.enumOrdinal.get(obj)).intValue());
        }
        catch (IllegalAccessException e) {
            throw new HproseException(e.getMessage());
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
        writeDate(date, true);
    }

    public void writeDate(Date date, boolean checkRef) throws IOException {
        if (writeRef(date, checkRef)) {
            Calendar calendar = Calendar.getInstance(HproseHelper.DefaultTZ);
            calendar.setTime(date);
            writeDateOfCalendar(calendar);
            writeTimeOfCalendar(calendar);
            stream.write(HproseTags.TagSemicolon);
        }
    }

    public void writeDate(Calendar calendar) throws IOException {
        writeDate(calendar, true);
    }

    public void writeDate(Calendar calendar, boolean checkRef) throws IOException {
        if (writeRef(calendar, checkRef)) {
            TimeZone tz = calendar.getTimeZone();
            if (!(tz.hasSameRules(HproseHelper.DefaultTZ) || tz.hasSameRules(HproseHelper.UTC))) {
                tz = HproseHelper.UTC;
                Calendar c = (Calendar) calendar.clone();
                c.setTimeZone(tz);
                calendar = c;
            }
            writeDateOfCalendar(calendar);
            writeTimeOfCalendar(calendar);
            stream.write(tz.hasSameRules(HproseHelper.UTC) ? HproseTags.TagUTC : HproseTags.TagSemicolon);
        }
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

    private void writeTimeOfCalendar(Calendar calendar) throws IOException {
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        int second = calendar.get(Calendar.SECOND);
        int millisecond = calendar.get(Calendar.MILLISECOND);
        if (hour == 0 && minute == 0 && second == 0 && millisecond == 0) return;
        stream.write(HproseTags.TagTime);
        stream.write((byte) ('0' + (hour / 10 % 10)));
        stream.write((byte) ('0' + (hour % 10)));
        stream.write((byte) ('0' + (minute / 10 % 10)));
        stream.write((byte) ('0' + (minute % 10)));
        stream.write((byte) ('0' + (second / 10 % 10)));
        stream.write((byte) ('0' + (second % 10)));
        if (millisecond > 0) {
            stream.write(HproseTags.TagPoint);
            stream.write((byte) ('0' + (millisecond / 100 % 10)));
            stream.write((byte) ('0' + (millisecond / 10 % 10)));
            stream.write((byte) ('0' + (millisecond % 10)));
        }
    }

    public void writeBytes(byte[] bytes) throws IOException {
        writeBytes(bytes, true);
    }

    public void writeBytes(byte[] bytes, boolean checkRef) throws IOException {
        if (writeRef(bytes, checkRef)) {
            stream.write(HproseTags.TagBytes);
            writeInt(bytes.length);
            stream.write(HproseTags.TagQuote);
            stream.write(bytes);
            stream.write(HproseTags.TagQuote);
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
        writeString(s, true);
    }

    public void writeString(String s, boolean checkRef) throws IOException {
        if (writeRef(s, checkRef)) {
            stream.write(HproseTags.TagString);
            writeUTF8String(s, stream);
        }
    }

    private void writeUTF8String(String s, OutputStream stream) throws IOException {
        int length = s.length();
        if (length > 0) writeInt(length, stream);
        stream.write(HproseTags.TagQuote);
        for (int i = 0; i < length; i++) {
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

    public void writeString(char[] s) throws IOException {
        writeString(s, true);
    }

    public void writeString(char[] s, boolean checkRef) throws IOException {
        if (writeRef(s, checkRef)) {
            stream.write(HproseTags.TagString);
            writeUTF8String(s);
        }
    }

    private void writeUTF8String(char[] s) throws IOException {
        int length = s.length;
        if (length > 0) writeInt(length);
        stream.write(HproseTags.TagQuote);
        for (int i = 0; i < length; i++) {
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
        writeUUID(uuid, true);
    }

    public void writeUUID(UUID uuid, boolean checkRef) throws IOException {
        if (writeRef(uuid, checkRef)) {
            stream.write(HproseTags.TagGuid);
            stream.write(HproseTags.TagOpenbrace);
            stream.write(getAscii(uuid.toString()));
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(short[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(short[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeInteger(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(int[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(int[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeInteger(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(long[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(long[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeLong(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(float[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(float[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeDouble(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(double[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(double[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeDouble(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(boolean[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(boolean[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeBoolean(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(String[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(String[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeString(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(StringBuffer[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(StringBuffer[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeString(array[i].toString());
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(char[][] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(char[][] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeString(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(byte[][] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(byte[][] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeBytes(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(BigInteger[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(BigInteger[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeLong(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(BigDecimal[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(BigDecimal[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                writeString(array[i].toString());
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(Object[] array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(Object[] array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = array.length;
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                serialize(array[i]);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeArray(Object array) throws IOException {
        writeArray(array, true);
    }

    public void writeArray(Object array, boolean checkRef) throws IOException {
        if (writeRef(array, checkRef)) {
            int length = Array.getLength(array);
            stream.write(HproseTags.TagList);
            if (length > 0) writeInt(length);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < length; i++) {
                serialize(Array.get(array, i));
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeCollection(Collection collection) throws IOException {
        writeCollection(collection, true);
    }

    public void writeCollection(Collection collection, boolean checkRef) throws IOException {
        if (writeRef(collection, checkRef)) {
            int count = collection.size();
            stream.write(HproseTags.TagList);
            if (count > 0) writeInt(count);
            stream.write(HproseTags.TagOpenbrace);
            for (Iterator iter = collection.iterator(); iter.hasNext();) {
                serialize(iter.next());
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeList(List list) throws IOException {
        writeList(list, true);
    }

    public void writeList(List list, boolean checkRef) throws IOException {
        if (writeRef(list, checkRef)) {
            int count = list.size();
            stream.write(HproseTags.TagList);
            if (count > 0) writeInt(count);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < count; i++) {
                serialize(list.get(i));
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeMap(Map map) throws IOException {
        writeMap(map, true);
    }

    public void writeMap(Map map, boolean checkRef) throws IOException {
        if (writeRef(map, checkRef)) {
            int count = map.size();
            stream.write(HproseTags.TagMap);
            if (count > 0) writeInt(count);
            stream.write(HproseTags.TagOpenbrace);
            for (Iterator entrys = map.entrySet().iterator(); entrys.hasNext();) {
                Entry entry = (Entry) entrys.next();
                serialize(entry.getKey());
                serialize(entry.getValue());
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeObject(Object object) throws IOException {
        writeObject(object, true);
    }

    public void writeObject(Object object, boolean checkRef) throws IOException {
        if (!(object instanceof Serializable)) {
            writeBean(object, checkRef);
            return;
        }
        if (checkRef && ref.containsKey(object)) {
            writeRef(object);
        }
        else {
            Class type = object.getClass();
            int cr;
            if (classref.containsKey(type)) {
                cr =classref.get(type);
            }
            else {
                cr = writeClass(type);
            }
            ref.put(object, lastref++);
            Map members;
            if (mode == HproseMode.FieldMode) {
                members = HproseHelper.getFields(type);
            }
            else {
                members = HproseHelper.getProperties(type);
            }
            stream.write(HproseTags.TagObject);
            writeInt(cr);
            stream.write(HproseTags.TagOpenbrace);
            if (mode == HproseMode.FieldMode) {
                for (Iterator iter = members.entrySet().iterator(); iter.hasNext();) {
                    Object value;
                    try {
                        value = ((Field) ((Entry) iter.next()).getValue()).get(object);
                    }
                    catch (Exception e) {
                        throw new HproseException(e.getMessage());
                    }
                    serialize(value);
                }
            }
            else {
                for (Iterator iter = members.entrySet().iterator(); iter.hasNext();) {
                    Object value;
                    try {
                        value = ((PropertyAccessor) ((Entry) iter.next()).getValue()).getter.invoke(object, nullArgs);
                    }
                    catch (Exception e) {
                        throw new HproseException(e.getMessage());
                    }
                    serialize(value);
                }
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    private int writeClass(Class type) throws IOException {
        SerializeCache cache = null;
        if (mode == HproseMode.FieldMode) {
            synchronized (fieldsCache) {
                if (fieldsCache.containsKey(type)) {
                    SoftReference sref = (SoftReference) fieldsCache.get(type);
                    cache = (SerializeCache) sref.get();
                }
            }
        }
        else {
            synchronized (propertiesCache) {
                if (propertiesCache.containsKey(type)) {
                    SoftReference sref = (SoftReference) propertiesCache.get(type);
                    cache = (SerializeCache) sref.get();
                }
            }
        }
        if (cache == null) {
            cache = new SerializeCache();
            ByteArrayOutputStream cachestream = new ByteArrayOutputStream();
            Map members;
            if (mode == HproseMode.FieldMode) {
                members = HproseHelper.getFields(type);
            }
            else {
                members = HproseHelper.getProperties(type);
            }
            int count = members.size();
            cachestream.write(HproseTags.TagClass);
            writeUTF8String(HproseHelper.getClassName(type), cachestream);
            if (count > 0) writeInt(count, cachestream);
            cachestream.write(HproseTags.TagOpenbrace);
            for (Iterator iter = members.entrySet().iterator(); iter.hasNext();) {
                cachestream.write(HproseTags.TagString);
                writeUTF8String((String) ((Entry) iter.next()).getKey(), cachestream);
                cache.refcount++;
            }
            cachestream.write(HproseTags.TagClosebrace);
            cache.data = cachestream.toByteArray();
            if (mode == HproseMode.FieldMode) {
                synchronized (fieldsCache) {
                    fieldsCache.put(type, new SoftReference(cache));
                }
            }
            else {
                synchronized (propertiesCache) {
                    propertiesCache.put(type, new SoftReference(cache));
                }
            }
        }
        stream.write(cache.data);
        lastref += cache.refcount;
        int cr = lastclassref++;
        classref.put(type, cr);
        return cr;
    }

    private void writeBean(Object object, boolean checkRef) throws IOException {
        if (checkRef && ref.containsKey(object)) {
            writeRef(object);
        }
        else {
            Class type = object.getClass();
            int cr;
            if (classref.containsKey(type)) {
                cr = classref.get(type);
            }
            else {
                cr = writeBeanClass(type);
            }
            ref.put(object, lastref++);
            Map members = HproseHelper.getMembers(type);
            stream.write(HproseTags.TagObject);
            writeInt(cr);
            stream.write(HproseTags.TagOpenbrace);
            for (Iterator iter = members.entrySet().iterator(); iter.hasNext();) {
                Object value;
                try {
                    Object member = ((Entry) iter.next()).getValue();
                    if (member instanceof Field) {
                        value = ((Field) member).get(object);
                    }
                    else {
                        value = ((PropertyAccessor) member).getter.invoke(object, nullArgs);
                    }
                }
                catch (Exception e) {
                    throw new HproseException(e.getMessage());
                }
                serialize(value);
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    private int writeBeanClass(Class type) throws IOException {
        SerializeCache cache = null;
        synchronized (membersCache) {
            if (membersCache.containsKey(type)) {
                SoftReference sref = (SoftReference) membersCache.get(type);
                cache = (SerializeCache) sref.get();
            }
        }
        if (cache == null) {
            cache = new SerializeCache();
            ByteArrayOutputStream cachestream = new ByteArrayOutputStream();
            Map members = HproseHelper.getMembers(type);
            int count = members.size();
            cachestream.write(HproseTags.TagClass);
            writeUTF8String(HproseHelper.getClassName(type), cachestream);
            if (count > 0) writeInt(count, cachestream);
            cachestream.write(HproseTags.TagOpenbrace);
            for (Iterator iter = members.entrySet().iterator(); iter.hasNext();) {
                cachestream.write(HproseTags.TagString);
                writeUTF8String((String) ((Entry) iter.next()).getKey(), cachestream);
                cache.refcount++;
            }
            cachestream.write(HproseTags.TagClosebrace);
            cache.data = cachestream.toByteArray();
            synchronized (membersCache) {
                membersCache.put(type, new SoftReference(cache));
            }
        }
        stream.write(cache.data);
        lastref += cache.refcount;
        int cr = lastclassref++;
        classref.put(type, cr);
        return cr;
    }

    private boolean writeRef(Object obj, boolean checkRef) throws IOException {
        if (checkRef && ref.containsKey(obj)) {
            stream.write(HproseTags.TagRef);
            writeInt(ref.get(obj));
            stream.write(HproseTags.TagSemicolon);
            return false;
        }
        else {
            ref.put(obj, lastref++);
            return true;
        }
    }

    private void writeRef(Object obj) throws IOException {
        stream.write(HproseTags.TagRef);
        writeInt(ref.get(obj));
        stream.write(HproseTags.TagSemicolon);
    }

    private byte[] getAscii(String s) {
        int size = s.length();
        byte[] b = new byte[size--];
        for (; size >= 0; size--) {
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