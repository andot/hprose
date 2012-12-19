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
 * TypeCode.java                                          *
 *                                                        *
 * TypeCode class for Java.                               *
 *                                                        *
 * LastModified: Dec 18, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.AbstractCollection;
import java.util.AbstractList;
import java.util.AbstractMap;
import java.util.AbstractSequentialList;
import java.util.AbstractSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
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
import java.util.UUID;
import java.util.Vector;

public final class TypeCode {
    public static final int Null = 0;
    public static final int BooleanType = 1;
    public static final int ByteType = 2;
    public static final int CharType = 3;
    public static final int ShortType = 4;
    public static final int IntType = 5;
    public static final int LongType = 6;
    public static final int FloatType = 7;
    public static final int DoubleType = 8;
    public static final int Enum = 9;
    public static final int Object = 10;
    public static final int Boolean = 11;
    public static final int Byte = 12;
    public static final int Character = 13;
    public static final int Short = 14;
    public static final int Integer = 15;
    public static final int Long = 16;
    public static final int Float = 17;
    public static final int Double = 18;
    public static final int String = 19;
    public static final int BigInteger = 20;
    public static final int Date = 21;
    public static final int Time = 22;
    public static final int Timestamp = 23;
    public static final int DateTime = 24;
    public static final int Calendar = 25;
    public static final int BigDecimal = 26;
    public static final int StringBuilder = 27;
    public static final int StringBuffer = 28;
    public static final int UUID = 29;
    public static final int ObjectArray = 30;
    public static final int BooleanArray = 31;
    public static final int ByteArray = 32;
    public static final int CharArray = 33;
    public static final int ShortArray = 34;
    public static final int IntArray = 35;
    public static final int LongArray = 36;
    public static final int FloatArray = 37;
    public static final int DoubleArray = 38;
    public static final int StringArray = 39;
    public static final int BigIntegerArray = 40;
    public static final int DateArray = 41;
    public static final int TimeArray = 42;
    public static final int TimestampArray = 43;
    public static final int DateTimeArray = 44;
    public static final int CalendarArray = 45;
    public static final int BigDecimalArray = 46;
    public static final int StringBuilderArray = 47;
    public static final int StringBufferArray = 48;
    public static final int UUIDArray = 49;
    public static final int BytesArray = 50;
    public static final int CharsArray = 51;
    public static final int Array = 52;
    public static final int ArrayList = 53;
    public static final int LinkedList = 54;
    public static final int Vector = 55;
    public static final int Stack = 56;
    public static final int HashSet = 57;
    public static final int TreeSet = 58;
    public static final int SortedSet = 59;
    public static final int AbstractSet = 60;
    public static final int AbstractSequentialList = 61;
    public static final int AbstractList = 62;
    public static final int AbstractCollection = 63;
    public static final int Set = 64;
    public static final int List = 65;
    public static final int Collection = 66;
    public static final int HashMap = 67;
    public static final int TreeMap = 68;
    public static final int Hashtable = 69;
    public static final int SortedMap = 70;
    public static final int AbstractMap = 71;
    public static final int Map = 72;
    public static final int CollectionType = 73;
    public static final int MapType = 74;
    public static final int AnonymousType = 75;
    public static final int OtherType = 76;

    static final ObjectIntMap typeMap = new ObjectIntMap();

    static {
        typeMap.put(null, TypeCode.Null);
        typeMap.put(boolean.class, TypeCode.BooleanType);
        typeMap.put(byte.class, TypeCode.ByteType);
        typeMap.put(char.class, TypeCode.CharType);
        typeMap.put(short.class, TypeCode.ShortType);
        typeMap.put(int.class, TypeCode.IntType);
        typeMap.put(long.class, TypeCode.LongType);
        typeMap.put(float.class, TypeCode.FloatType);
        typeMap.put(double.class, TypeCode.DoubleType);
        typeMap.put(Object.class, TypeCode.Object);
        typeMap.put(Boolean.class, TypeCode.Boolean);
        typeMap.put(Byte.class, TypeCode.Byte);
        typeMap.put(Character.class, TypeCode.Character);
        typeMap.put(Short.class, TypeCode.Short);
        typeMap.put(Integer.class, TypeCode.Integer);
        typeMap.put(Long.class, TypeCode.Long);
        typeMap.put(Float.class, TypeCode.Float);
        typeMap.put(Double.class, TypeCode.Double);
        typeMap.put(String.class, TypeCode.String);
        typeMap.put(BigInteger.class, TypeCode.BigInteger);
        typeMap.put(Date.class, TypeCode.Date);
        typeMap.put(Time.class, TypeCode.Time);
        typeMap.put(Timestamp.class, TypeCode.Timestamp);
        typeMap.put(java.util.Date.class, TypeCode.DateTime);
        typeMap.put(Calendar.class, TypeCode.Calendar);
        typeMap.put(BigDecimal.class, TypeCode.BigDecimal);
        typeMap.put(StringBuilder.class, TypeCode.StringBuilder);
        typeMap.put(StringBuffer.class, TypeCode.StringBuffer);
        typeMap.put(UUID.class, TypeCode.UUID);
        typeMap.put(boolean[].class, TypeCode.BooleanArray);
        typeMap.put(byte[].class, TypeCode.ByteArray);
        typeMap.put(char[].class, TypeCode.CharArray);
        typeMap.put(short[].class, TypeCode.ShortArray);
        typeMap.put(int[].class, TypeCode.IntArray);
        typeMap.put(long[].class, TypeCode.LongArray);
        typeMap.put(float[].class, TypeCode.FloatArray);
        typeMap.put(double[].class, TypeCode.DoubleArray);
        typeMap.put(String[].class, TypeCode.StringArray);
        typeMap.put(BigInteger[].class, TypeCode.BigIntegerArray);
        typeMap.put(Date[].class, TypeCode.DateArray);
        typeMap.put(Time[].class, TypeCode.TimeArray);
        typeMap.put(Timestamp[].class, TypeCode.TimestampArray);
        typeMap.put(java.util.Date[].class, TypeCode.DateTimeArray);
        typeMap.put(Calendar[].class, TypeCode.CalendarArray);
        typeMap.put(BigDecimal[].class, TypeCode.BigDecimalArray);
        typeMap.put(StringBuilder[].class, TypeCode.StringBuilderArray);
        typeMap.put(StringBuffer[].class, TypeCode.StringBufferArray);
        typeMap.put(UUID[].class, TypeCode.UUIDArray);
        typeMap.put(byte[][].class, TypeCode.BytesArray);
        typeMap.put(char[][].class, TypeCode.CharsArray);
        typeMap.put(ArrayList.class, TypeCode.ArrayList);
        typeMap.put(LinkedList.class, TypeCode.LinkedList);
        typeMap.put(Vector.class, TypeCode.Vector);
        typeMap.put(Stack.class, TypeCode.Stack);
        typeMap.put(HashSet.class, TypeCode.HashSet);
        typeMap.put(TreeSet.class, TypeCode.TreeSet);
        typeMap.put(SortedSet.class, TypeCode.SortedSet);
        typeMap.put(AbstractSet.class, TypeCode.AbstractSet);
        typeMap.put(AbstractSequentialList.class, TypeCode.AbstractSequentialList);
        typeMap.put(AbstractList.class, TypeCode.AbstractList);
        typeMap.put(AbstractCollection.class, TypeCode.AbstractCollection);
        typeMap.put(Set.class, TypeCode.Set);
        typeMap.put(List.class, TypeCode.List);
        typeMap.put(Collection.class, TypeCode.Collection);
        typeMap.put(HashMap.class, TypeCode.HashMap);
        typeMap.put(TreeMap.class, TypeCode.TreeMap);
        typeMap.put(Hashtable.class, TypeCode.Hashtable);
        typeMap.put(SortedMap.class, TypeCode.SortedMap);
        typeMap.put(AbstractMap.class, TypeCode.AbstractMap);
        typeMap.put(Map.class, TypeCode.Map);
    }

    public static int get(Class<?> type) {
        int typeCode = typeMap.get(type);
        if (typeCode != -1) {
            return typeCode;
        }
        else if (type.isEnum()) {
            return TypeCode.Enum;
        }
        else if (type.isArray()) {
            return TypeCode.Array;
        }
        else if (Collection.class.isAssignableFrom(type)) {
            return TypeCode.CollectionType;
        }
        else if (Map.class.isAssignableFrom(type)) {
            return TypeCode.MapType;
        }
        else if (type.isAnonymousClass()) {
            return TypeCode.AnonymousType;
        }
        return TypeCode.OtherType;
    }
}