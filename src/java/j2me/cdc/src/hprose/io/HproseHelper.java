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
 * HproseHelper.java                                      *
 *                                                        *
 * hprose helper class for Java.                          *
 *                                                        *
 * LastModified: Mar 6, 2011                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

import hprose.common.UUID;
import java.io.ByteArrayOutputStream;
import java.io.ObjectStreamClass;
import java.lang.ref.SoftReference;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.TimeZone;

public final class HproseHelper {

    private static final Byte[] byteCache = new Byte[-(-128) + 127 + 1];
    private static final Character[] charCache = new Character[127 + 1];
    private static final Integer[] intCache = new Integer[-(-128) + 127 + 1];
    private static final Short[] shortCache = new Short[-(-128) + 127 + 1];
    private static final Long[] longCache = new Long[-(-128) + 127 + 1];
    private static final HashMap fieldsCache = new HashMap();
    private static final HashMap propertiesCache = new HashMap();
    private static final HashMap membersCache = new HashMap();
    private static final HashMap ctorCache = new HashMap();
    private static final HashMap argsCache = new HashMap();
    private static final Object[] nullArgs = new Object[0];
    private static final Byte byteZero = new Byte((byte) 0);
    private static final Short shortZero = new Short((short) 0);
    private static final Integer intZero = new Integer(0);
    private static final Long longZero = new Long((long) 0);
    private static final Float floatZero = new Float((float) 0);
    private static final Double doubleZero = new Double((double) 0);
    private static final Character charZero = new Character((char) 0);
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

    private static final Method newInstance;
    static final Class enumClass;
    static final Field enumOrdinal;
    static final Method getEnumConstants;

    static final TimeZone UTC = TimeZone.getTimeZone("UTC");
    static final TimeZone DefaultTZ = TimeZone.getDefault();

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
        Method _newInstance;
        try {
            _newInstance = ObjectStreamClass.class.getDeclaredMethod("newInstance", new Class[0]);
            _newInstance.setAccessible(true);
        }
        catch (Exception e) {
            _newInstance = null;
        }
        newInstance = _newInstance;
        Class _enumClass;
        Field _enumOrdinal;
        Method _getEnumConstants;
        try {
            _enumClass = Class.forName("java.lang.Enum");
            _enumOrdinal = _enumClass.getDeclaredField("ordinal");
            _enumOrdinal.setAccessible(true);
            _getEnumConstants = Class.class.getDeclaredMethod("getEnumConstants", new Class[0]);
            _getEnumConstants.setAccessible(true);
        }
        catch (Exception e) {
            _enumClass = null;
            _enumOrdinal = null;
            _getEnumConstants = null;
        }
        enumClass = _enumClass;
        enumOrdinal = _enumOrdinal;
        getEnumConstants = _getEnumConstants;

    }

    public static Byte valueOf(byte b) {
        final int offset = 128;
        return byteCache[(int) b + offset];
    }

    public static Boolean valueOf(boolean b) {
        return (b ? Boolean.TRUE : Boolean.FALSE);
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

    public static Float valueOf(float f) {
        return new Float(f);
    }

    public static Double valueOf(double d) {
        return new Double(d);
    }

    public static String[] split(String s, char c, int limit) {
        if (s == null) return null;
        LinkedList pos = new LinkedList();
        int i = -1;
        while ((i = s.indexOf((int) c, i + 1)) > 0) {
            pos.add(HproseHelper.valueOf(i));
        }
        int n = pos.size();
        int[] p = new int[n];
        i = 0;
        for (Iterator iter = pos.iterator(); iter.hasNext(); i++) {
            p[i] = ((Integer) iter.next()).intValue();
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

    private static Method findGetter(Method[] methods, String name, Class paramType) {
        String getterName = "get" + name;
        String isGetterName = "is" + name;
        for (int i = 0; i < methods.length; i++) {
            Method method = methods[i];
            if (Modifier.isStatic(method.getModifiers())) {
                continue;
            }
            String methodName = method.getName();
            if (!methodName.equals(getterName) && !methodName.equals(isGetterName)) {
                continue;
            }
            if (!method.getReturnType().equals(paramType)) {
                continue;
            }
            if (method.getParameterTypes().length == 0) {
                return method;
            }
        }
        return null;
    }

    public static Map getProperties(Class type) {
        Map properties;
        synchronized (propertiesCache) {
            if (propertiesCache.containsKey(type)) {
                SoftReference sref = (SoftReference) propertiesCache.get(type);
                properties = (Map) sref.get();
                if (properties != null) {
                    return properties;
                }
            }
        }
        properties = new HashMap();
        Method[] methods = type.getMethods();
        for (int i = 0; i < methods.length; i++) {
            Method setter = methods[i];
            if (Modifier.isStatic(methods[i].getModifiers())) {
                continue;
            }
            String name = setter.getName();
            if (!name.startsWith("set")) {
                continue;
            }
            if (!setter.getReturnType().equals(void.class)) {
                continue;
            }
            Class[] paramTypes = setter.getParameterTypes();
            if (paramTypes.length != 1) {
                continue;
            }
            String propertyName = name.substring(3);
            Method getter = findGetter(methods, propertyName, paramTypes[0]);
            if (getter != null) {
                getter.setAccessible(true);
                setter.setAccessible(true);
                PropertyAccessor propertyAccessor = new PropertyAccessor(getter, setter);
                char[] cname = propertyName.toCharArray();
                cname[0] = Character.toLowerCase(cname[0]);
                propertyName = new String(cname);
                properties.put(propertyName, propertyAccessor);
            }
        }
        synchronized (propertiesCache) {
            propertiesCache.put(type, new SoftReference(properties));
        }
        return properties;
    }

    public static Map getFields(Class type) {
        Map fields;
        synchronized (fieldsCache) {
            if (fieldsCache.containsKey(type)) {
                SoftReference sref = (SoftReference) fieldsCache.get(type);
                fields = (Map) sref.get();
                if (fields != null) {
                    return fields;
                }
            }
        }
        fields = new HashMap();
        for (Class clazz = type; clazz != null; clazz = clazz.getSuperclass()) {
            Field[] fs = clazz.getDeclaredFields();
            for (int i = 0; i < fs.length; i++) {
                Field field = fs[i];
                int mod = fs[i].getModifiers();
                if (!Modifier.isTransient(mod) && !Modifier.isStatic(mod)) {
                    field.setAccessible(true);
                    String fieldName = field.getName();
                    if (!fields.containsKey(fieldName)) {
                        fields.put(fieldName, field);
                    }
                }
            }
        }
        synchronized (fieldsCache) {
            fieldsCache.put(type, new SoftReference(fields));
        }
        return fields;
    }

    public static Map getMembers(Class type) {
        Map members;
        synchronized (membersCache) {
            if (membersCache.containsKey(type)) {
                SoftReference sref = (SoftReference) membersCache.get(type);
                members = (Map) sref.get();
                if (members != null) {
                    return members;
                }
            }
        }
        members = new HashMap();
        Method[] methods = type.getMethods();
        for (int i = 0; i < methods.length; i++) {
            Method setter = methods[i];
            if (Modifier.isStatic(methods[i].getModifiers())) {
                continue;
            }
            String name = setter.getName();
            if (!name.startsWith("set")) {
                continue;
            }
            if (!setter.getReturnType().equals(void.class)) {
                continue;
            }
            Class[] paramTypes = setter.getParameterTypes();
            if (paramTypes.length != 1) {
                continue;
            }
            String propertyName = name.substring(3);
            Method getter = findGetter(methods, propertyName, paramTypes[0]);
            if (getter != null) {
                getter.setAccessible(true);
                setter.setAccessible(true);
                PropertyAccessor propertyAccessor = new PropertyAccessor(getter, setter);
                char[] cname = propertyName.toCharArray();
                cname[0] = Character.toLowerCase(cname[0]);
                propertyName = new String(cname);
                members.put(propertyName, propertyAccessor);
            }
        }
        Field[] fs = type.getFields();
        for (int i = 0; i < fs.length; i++) {
            Field field = fs[i];
            int mod = fs[i].getModifiers();
            if (!Modifier.isTransient(mod) && !Modifier.isStatic(mod)) {
                field.setAccessible(true);
                String fieldName = field.getName();
                if (!members.containsKey(fieldName)) {
                    members.put(fieldName, field);
                }
            }
        }
        synchronized (membersCache) {
            membersCache.put(type, new SoftReference(members));
        }
        return members;
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
        LinkedList al = new LinkedList();
        int p = cn.indexOf("_");
        while (p > -1) {
            al.add(HproseHelper.valueOf(p));
            p = cn.indexOf("_", p + 1);
        }
        Class type = null;
        if (al.size() > 0) {
            try {
                int size = al.size();
                int[] pos = new int[size];
                int i = 0;
                for (Iterator iter = al.iterator(); iter.hasNext(); i++) {
                    pos[i] = ((Integer) iter.next()).intValue();
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

    private static Object[] getArgs(Constructor ctor) {
        Object[] args;
        synchronized (argsCache) {
            if (argsCache.containsKey(ctor)) {
                SoftReference sref = (SoftReference) argsCache.get(ctor);
                args = (Object[]) sref.get();
                if (args != null) {
                    return args;
                }
            }
        }
        Class[] params = ctor.getParameterTypes();
        args = new Object[params.length];
        for (int i = 0; i < params.length; i++) {
            Class type = params[i];
            if (int.class.equals(type)) {
                args[i] = intZero;
            }
            else if (long.class.equals(type)) {
                args[i] = longZero;
            }
            else if (byte.class.equals(type)) {
                args[i] = byteZero;
            }
            else if (short.class.equals(type)) {
                args[i] = shortZero;
            }
            else if (float.class.equals(type)) {
                args[i] = floatZero;
            }
            else if (double.class.equals(type)) {
                args[i] = doubleZero;
            }
            else if (char.class.equals(type)) {
                args[i] = charZero;
            }
            else if (boolean.class.equals(type)) {
                args[i] = Boolean.FALSE;
            }
            else {
                args[i] = null;
            }
        }
        synchronized (argsCache) {
            argsCache.put(ctor, new SoftReference(args));
        }
        return args;
    }

    private static class ConstructorComparator implements Comparator {

        public int compare(Object o1, Object o2) {
            return ((Constructor) o1).getParameterTypes().length -
                   ((Constructor) o2).getParameterTypes().length;
        }
    }

    public static Object newInstance(Class type) {
        Constructor ctor = null;
        boolean ctorCached = false;
        synchronized (ctorCache) {
            if (ctorCache.containsKey(type)) {
                ctorCached = true;
                SoftReference sref = (SoftReference) ctorCache.get(type);
                if (sref != null) {
                    ctor = (Constructor) sref.get();
                    if (ctor == null) {
                        ctorCached = false;
                    }
                }
            }
        }
        try {
            if (ctor != null) {
                return ctor.newInstance(getArgs(ctor));
            }
            else {
                if (!ctorCached) {
                    Constructor[] ctors = type.getDeclaredConstructors();
                    Arrays.sort(ctors, new ConstructorComparator());
                    for (int i = 0; i < ctors.length; i++) {
                        try {
                            ctors[i].setAccessible(true);
                            Object obj = ctors[i].newInstance(getArgs(ctors[i]));
                            synchronized (ctorCache) {
                                ctorCache.put(type, new SoftReference(ctors[i]));
                            }
                            return obj;
                        }
                        catch (Exception e) {
                        }
                    }
                    synchronized (ctorCache) {
                        ctorCache.put(type, null);
                    }
                }
                if (newInstance != null) {
                    return newInstance.invoke(ObjectStreamClass.lookup(type), nullArgs);
                }
                else {
                    return null;
                }
            }
        }
        catch (Exception e) {
            return null;
        }
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