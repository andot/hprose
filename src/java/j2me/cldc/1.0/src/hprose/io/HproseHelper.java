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
 * HproseHelper.java                                      *
 *                                                        *
 * hprose helper class for Java.                          *
 *                                                        *
 * LastModified: May 6, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

import hprose.common.UUID;
import java.io.ByteArrayOutputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.Hashtable;
import java.util.Stack;
import java.util.TimeZone;
import java.util.Vector;

public final class HproseHelper {

    private static final Byte[] byteCache = new Byte[-(-128) + 127 + 1];
    private static final Character[] charCache = new Character[127 + 1];
    private static final Integer[] intCache = new Integer[-(-128) + 127 + 1];
    private static final Short[] shortCache = new Short[-(-128) + 127 + 1];
    private static final Long[] longCache = new Long[-(-128) + 127 + 1];
    private static final char[] base64EncodeChars = new char[] {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
        'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
        'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3',
        '4', '5', '6', '7', '8', '9', '+', '/' };
    private static final byte[] base64DecodeChars = new byte[] {
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1 };

    static final TimeZone UTC = TimeZone.getTimeZone("UTC");
    static final String DefaultTZID = TimeZone.getDefault().getID();
    public static final Object Null = new Object();
    public static final Boolean TRUE = new Boolean(true);
    public static final Boolean FALSE = new Boolean(false);
    public static final Class IntegerClass = new Integer(0).getClass();
    public static final Class ByteClass = new Byte((byte)0).getClass();
    public static final Class ShortClass = new Short((short)0).getClass();
    public static final Class LongClass = new Long((long)0).getClass();
    public static final Class CharClass = new Character((char)0).getClass();
    public static final Class BoolClass = TRUE.getClass();
    public static final Class StringClass = "".getClass();
    public static final Class StringBufferClass = new StringBuffer().getClass();
    public static final Class ObjectClass = Null.getClass();
    public static final Class DateClass = new Date().getClass();
    public static final Class CalendarClass = Calendar.getInstance().getClass();
    public static final Class BytesClass = new byte[0].getClass();
    public static final Class CharsClass = new char[0].getClass();
    public static final Class IntegerArrayClass = new int[0].getClass();
    public static final Class ShortArrayClass = new short[0].getClass();
    public static final Class LongArrayClass = new long[0].getClass();
    public static final Class BoolArrayClass = new boolean[0].getClass();
    public static final Class StringArrayClass = new String[0].getClass();
    public static final Class StringBufferArrayClass = new StringBuffer[0].getClass();
    public static final Class ObjectArrayClass = new Object[0].getClass();
    public static final Class DateArrayClass = new Date[0].getClass();
    public static final Class CalendarArrayClass = new Calendar[0].getClass();
    public static final Class BytesArrayClass = new byte[0][0].getClass();
    public static final Class CharsArrayClass = new char[0][0].getClass();
    public static final Class VectorClass = new Vector().getClass();
    public static final Class StackClass = new Stack().getClass();
    public static final Class HashtableClass = new Hashtable().getClass();
    public static final Class UUIDClass = new UUID(0, 0).getClass();
    public static final Class ClassClass = ObjectClass.getClass();
    public static final Class SerializableClass = new Serializable() {
        public String[] getPropertyNames() {
            return new String[0];
        }
        public Class getPropertyType(String name) {
            return this.getClass();
        }
        public Object getProperty(String name) {
            return Null;
        }
        public void setProperty(String name, Object value) {
        }
    }.getClass();

    private HproseHelper() {
    }

    static {
        for (int i = 0; i < byteCache.length; i++) {
            byteCache[i] = new Byte((byte) (i - 128));
        }
        for (int i = 0; i < charCache.length; i++) {
            charCache[i] = new Character((char) i);
        }
        for (int i = 0; i < intCache.length; i++) {
            intCache[i] = new Integer(i - 128);
        }
        for (int i = 0; i < shortCache.length; i++) {
            shortCache[i] = new Short((short) (i - 128));
        }
        for (int i = 0; i < longCache.length; i++) {
            longCache[i] = new Long(i - 128);
        }
    }

    public static Byte valueOf(byte b) {
        final int offset = 128;
        return byteCache[(int) b + offset];
    }

    public static Boolean valueOf(boolean b) {
        return (b ? TRUE : FALSE);
    }

    public static Character valueOf(char c) {
        if (c <= 127) {
            return charCache[(int) c];
        }
        return new Character(c);
    }

    public static Integer valueOf(int i) {
        final int offset = 128;
        if (i >= -128 && i <= 127) {
            return intCache[i + offset];
        }
        return new Integer(i);
    }

    public static Short valueOf(short s) {
        final int offset = 128;
        int sAsInt = s;
        if (sAsInt >= -128 && sAsInt <= 127) {
            return shortCache[sAsInt + offset];
        }
        return new Short(s);
    }

    public static Long valueOf(long l) {
        final int offset = 128;
        if (l >= -128 && l <= 127) {
            return longCache[(int) l + offset];
        }
        return new Long(l);
    }

    public static String[] split(String s, char c, int limit) {
        if (s == null) return null;
        Vector pos = new Vector();
        int i = -1;
        while ((i = s.indexOf((int) c, i + 1)) > 0) {
            pos.addElement(HproseHelper.valueOf(i));
        }
        int n = pos.size();
        int[] p = new int[n];
        for (i = 0; i < n; i++) {
            p[i] = ((Integer) pos.elementAt(i)).intValue();
        }
        if ((limit == 0) || (limit > n)) {
            limit = n + 1;
        }
        String[] result = new String[limit];
        if (n > 0) {
            result[0] = s.substring(0, p[0]);
        } else {
            result[0] = s;
        }
        for (i = 1; i < limit - 1; i++) {
            result[i] = s.substring(p[i - 1] + 1, p[i]);
        }
        if (limit > 1) {
            result[limit - 1] = s.substring(p[limit - 2] + 1);
        }
        return result;
    }

    public static String getClassName(Class type) {
        String className = ClassManager.getClassAlias(type);
        if (className == null) {
            className = type.getName().replace('.', '_').replace('$', '_');
            ClassManager.register(type, className);
        }
        return className;
    }

    private static Class getInnerClass(StringBuffer className, int[] pos, int i, char c) {
        if (i < pos.length) {
            int p = pos[i];
            className.setCharAt(p, c);
            Class type = getInnerClass(className, pos, i + 1, '_');
            if (i + 1 < pos.length && type == null) {
                type = getInnerClass(className, pos, i + 1, '$');
            }
            return type;
        }
        else {
            try {
                return Class.forName(className.toString());
            }
            catch (Exception e) {
                return null;
            }
        }
    }

    private static Class getClass(StringBuffer className, int[] pos, int i, char c) {
        if (i < pos.length) {
            int p = pos[i];
            className.setCharAt(p, c);
            Class type = getClass(className, pos, i + 1, '.');
            if (i + 1 < pos.length) {
                if (type == null) {
                    type = getClass(className, pos, i + 1, '_');
                }
                if (type == null) {
                    type = getInnerClass(className, pos, i + 1, '$');
                }
            }
            return type;
        }
        else {
            try {
                return Class.forName(className.toString());
            }
            catch (Exception e) {
                return null;
            }
        }
    }

    public static Class getClass(String className) {
        if (ClassManager.containsClass(className)) {
            return ClassManager.getClass(className);
        }
        StringBuffer cn = new StringBuffer(className);
        Vector al = new Vector();
        int p = className.indexOf("_");
        while (p > -1) {
            al.addElement(HproseHelper.valueOf(p));
            p = className.indexOf("_", p + 1);
        }
        Class type = null;
        if (al.size() > 0) {
            try {
                int size = al.size();
                int[] pos = new int[size];

                for (int i = 0; i < size; i++) {
                    pos[i] = ((Integer) al.elementAt(i)).intValue();
                }
                type = getClass(cn, pos, 0, '.');
                if (type == null) {
                    type = getClass(cn, pos, 0, '_');
                }
                if (type == null) {
                    type = getInnerClass(cn, pos, 0, '$');
                }
            }
            catch (Exception e) {
            }
        }
        else {
            try {
                type = Class.forName(className);
            }
            catch (Exception e) {
            }
        }
        ClassManager.register(type, className);
        return type;
    }

    public static Serializable newInstance(Class type) {
        try {
            return (Serializable)type.newInstance();
        }
        catch (Exception e) {}
        return null;
    }

    public static String base64Encode(byte[] data) {
        StringBuffer sb = new StringBuffer();
        int r = data.length % 3;
        int len = data.length - r;
        int i = 0;
        int c;
        while (i < len) {
            c = (0x000000ff & data[i++]) << 16 |
                (0x000000ff & data[i++]) << 8  |
                (0x000000ff & data[i++]);
            sb.append(base64EncodeChars[c >> 18]);
            sb.append(base64EncodeChars[c >> 12 & 0x3f]);
            sb.append(base64EncodeChars[c >> 6  & 0x3f]);
            sb.append(base64EncodeChars[c & 0x3f]);
        }
        if (r == 1) {
            c = 0x000000ff & data[i++];
            sb.append(base64EncodeChars[c >> 2]);
            sb.append(base64EncodeChars[(c & 0x03) << 4]);
            sb.append("==");
        }
        else if (r == 2) {
            c = (0x000000ff & data[i++]) << 8 |
                (0x000000ff & data[i++]);
            sb.append(base64EncodeChars[c >> 10]);
            sb.append(base64EncodeChars[c >> 4 & 0x3f]);
            sb.append(base64EncodeChars[(c & 0x0f) << 2]);
            sb.append("=");
        }
        return sb.toString();
    }

    public static byte[] base64Decode(String str) {
        byte[] data = str.getBytes();
        int len = data.length;
        ByteArrayOutputStream buf = new ByteArrayOutputStream(len);
        int i = 0;
        int b1, b2, b3, b4;

        while (i < len) {

            /* b1 */
            do {
                b1 = base64DecodeChars[data[i++]];
            } while (i < len && b1 == -1);
            if (b1 == -1) {
                break;
            }

            /* b2 */
            do {
                b2 = base64DecodeChars[data[i++]];
            } while (i < len && b2 == -1);
            if (b2 == -1) {
                break;
            }
            buf.write((int) ((b1 << 2) | ((b2 & 0x30) >>> 4)));

            /* b3 */
            do {
                b3 = data[i++];
                if (b3 == 61) {
                    return buf.toByteArray();
                }
                b3 = base64DecodeChars[b3];
            } while (i < len && b3 == -1);
            if (b3 == -1) {
                break;
            }
            buf.write((int) (((b2 & 0x0f) << 4) | ((b3 & 0x3c) >>> 2)));

            /* b4 */
            do {
                b4 = data[i++];
                if (b4 == 61) {
                    return buf.toByteArray();
                }
                b4 = base64DecodeChars[b4];
            } while (i < len && b4 == -1);
            if (b4 == -1) {
                break;
            }
            buf.write((int) (((b3 & 0x03) << 6) | b4));
        }
        return buf.toByteArray();
    }

    public static String createGUID() {
        return UUID.randomUUID().toString();
    }
}