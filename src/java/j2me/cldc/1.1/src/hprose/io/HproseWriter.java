/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseWriter.java                                      *
 *                                                        *
 * hprose writer class for Java.                          *
 *                                                        *
 * LastModified: Feb 7, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import hprose.common.HproseException;
import hprose.common.UUID;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.TimeZone;
import java.util.Vector;

public final class HproseWriter {
    private static final Hashtable propertiesCache = new Hashtable();
    public final OutputStream stream;
    private final ObjectIntMap ref = new ObjectIntMap();
    private final ObjectIntMap classref = new ObjectIntMap();
    private final byte[] buf = new byte[20];
    private static final byte[] minIntBuf = new byte[] {'-','2','1','4','7','4','8','3','6','4','8'};
    private static final byte[] minLongBuf = new byte[] {'-','9','2','2','3','3','7','2','0','3','6','8','5','4','7','7','5','8','0','8'};
    private int lastref = 0;
    private int lastclassref = 0;

    public HproseWriter(OutputStream stream) {
        this.stream = stream;
    }

    public void serialize(Object obj) throws IOException {
        if (obj == null) {
            writeNull();
        }
        else if (obj instanceof Integer) {
            writeInteger(((Integer) obj).intValue());
        }
        else if (obj instanceof Byte) {
            writeInteger(((Byte) obj).byteValue());
        }
        else if (obj instanceof Short) {
            writeInteger(((Short) obj).shortValue());
        }
        else if (obj instanceof Character) {
            writeUTF8Char(((Character) obj).charValue());
        }
        else if (obj instanceof Long) {
            writeLong(((Long) obj).longValue());
        }
        else if (obj instanceof Double) {
            writeDouble(((Double) obj).doubleValue());
        }
        else if (obj instanceof Float) {
            writeDouble(((Float) obj).doubleValue());
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
            writeBytes((byte[]) obj, true);
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
        else if (obj instanceof Object[]) {
            writeArray((Object[]) obj, true);
        }
        else if (obj instanceof Vector) {
            writeList((Vector) obj, true);
        }
        else if (obj instanceof Hashtable) {
            writeMap((Hashtable) obj, true);
        }
        else if (obj instanceof Serializable) {
            writeObject((Serializable)obj, true);
        }
        else {
            throw new HproseException(obj.getClass().getName() + " is not a serializable type");
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
            Calendar calendar = Calendar.getInstance(TimeZone.getDefault());
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
            String tzID = calendar.getTimeZone().getID();
            if (!(tzID.equals(HproseHelper.DefaultTZID) || tzID.equals("UTC"))) {
                TimeZone tz = HproseHelper.UTC;
                Calendar c = Calendar.getInstance(calendar.getTimeZone());
                c.setTime(calendar.getTime());
                c.setTimeZone(tz);
                calendar = c;
            }
            writeDateOfCalendar(calendar);
            writeTimeOfCalendar(calendar);
            stream.write(tzID.equals("UTC") ? HproseTags.TagUTC : HproseTags.TagSemicolon);
        }
    }

    private void writeDateOfCalendar(Calendar calendar) throws IOException {
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day = calendar.get(Calendar.DATE);
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
            if (bytes.length > 0) writeInt(bytes.length);
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

    public void writeList(Vector list) throws IOException {
        writeList(list, true);
    }

    public void writeList(Vector list, boolean checkRef) throws IOException {
        if (writeRef(list, checkRef)) {
            int count = list.size();
            stream.write(HproseTags.TagList);
            if (count > 0) writeInt(count);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < count; i++) {
                serialize(list.elementAt(i));
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeMap(Hashtable map) throws IOException {
        writeMap(map, true);
    }

    public void writeMap(Hashtable map, boolean checkRef) throws IOException {
        if (writeRef(map, checkRef)) {
            int count = map.size();
            stream.write(HproseTags.TagMap);
            if (count > 0) writeInt(count);
            stream.write(HproseTags.TagOpenbrace);
            for (Enumeration e = map.keys(); e.hasMoreElements();) {
                Object key = (Object) e.nextElement();
                serialize(key);
                serialize(map.get(key));
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    public void writeObject(Serializable object) throws IOException {
        writeObject(object, true);
    }

    public void writeObject(Serializable object, boolean checkRef) throws IOException {
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
                cr = writeClass(object);
            }
            ref.put(object, lastref++);
            String[] names = object.getPropertyNames();
            stream.write(HproseTags.TagObject);
            writeInt(cr);
            stream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < names.length; i++) {
                serialize(object.getProperty(names[i]));
            }
            stream.write(HproseTags.TagClosebrace);
        }
    }

    private int writeClass(Serializable object) throws IOException {
        Class type = object.getClass();
        SerializeCache cache = null;
        if (propertiesCache.containsKey(type)) {
            cache = (SerializeCache) propertiesCache.get(type);
        }
        if (cache == null) {
            cache = new SerializeCache();
            ByteArrayOutputStream cachestream = new ByteArrayOutputStream();
            String[] names = object.getPropertyNames();
            int count = names.length;
            cachestream.write(HproseTags.TagClass);
            writeUTF8String(HproseHelper.getClassName(type), cachestream);
            if (count > 0) writeInt(count, cachestream);
            cachestream.write(HproseTags.TagOpenbrace);
            for (int i = 0; i < count; i++) {
                cachestream.write(HproseTags.TagString);
                writeUTF8String(names[i], cachestream);
                cache.refcount++;
            }
            cachestream.write(HproseTags.TagClosebrace);
            cache.data = cachestream.toByteArray();
            propertiesCache.put(type, cache);
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