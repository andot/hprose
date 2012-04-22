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
 * ObjectIntMap.java                                      *
 *                                                        *
 * ObjectIntMap class for Java.                           *
 *                                                        *
 * LastModified: Jun 7, 2011                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

final class ObjectIntMap {

    static final int DEFAULT_INITIAL_CAPACITY = 16;
    static final int MAXIMUM_CAPACITY = 1 << 30;
    Entry[] table;
    int size;
    int threshold;

    public ObjectIntMap() {
        threshold = DEFAULT_INITIAL_CAPACITY;
        table = new Entry[DEFAULT_INITIAL_CAPACITY];
    }

    static int hash(Object key) {
        int h = System.identityHashCode(key);
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }

    static int indexFor(int h, int length) {
        return h & (length - 1);
    }

    public int size() {
        return size;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    public void clear() {
        Entry[] tab = table;
        for (int i = 0; i < tab.length; i++)
            tab[i] = null;
        size = 0;
    }

    public int get(Object key) {
        if (key == null) {
            return getForNullKey();
        }
        int hash = hash(key);
        for (Entry e = table[indexFor(hash, table.length)];
            e != null;
            e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key)) {
                return e.value;
            }
        }
        return -1;
    }

    private int getForNullKey() {
        for (Entry e = table[0]; e != null; e = e.next) {
            if (e.key == null) {
                return e.value;
            }
        }
        return -1;
    }

    public boolean containsKey(Object key) {
        return getEntry(key) != null;
    }

    final Entry getEntry(Object key) {
        if (key == null) {
            for (Entry e = table[0]; e != null; e = e.next) {
                if (e.key == null) {
                    return e;
                }
            }
        }
        else {
            int hash = hash(key);
            for (Entry e = table[indexFor(hash, table.length)];
                e != null;
                e = e.next) {
                Object k;
                if (e.hash == hash &&
                    ((k = e.key) == key)) {
                    return e;
                }
            }
        }
        return null;
    }

    public int put(Object key, int value) {
        if (key == null) {
            return putForNullKey(value);
        }
        int hash = hash(key);
        int i = indexFor(hash, table.length);
        for (Entry e = table[i]; e != null; e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key)) {
                int oldValue = e.value;
                e.value = value;
                return oldValue;
            }
        }

        addEntry(hash, key, value, i);
        return -1;
    }

    private int putForNullKey(int value) {
        for (Entry e = table[0]; e != null; e = e.next) {
            if (e.key == null) {
                int oldValue = e.value;
                e.value = value;
                return oldValue;
            }
        }
        addEntry(0, null, value, 0);
        return -1;
    }

    void resize(int newCapacity) {
        Entry[] oldTable = table;
        int oldCapacity = oldTable.length;
        if (oldCapacity == MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return;
        }

        Entry[] newTable = new Entry[newCapacity];
        transfer(newTable);
        table = newTable;
        threshold = newCapacity;
    }

    void transfer(Entry[] newTable) {
        Entry[] src = table;
        int newCapacity = newTable.length;
        for (int j = 0; j < src.length; j++) {
            Entry e = src[j];
            if (e != null) {
                src[j] = null;
                do {
                    Entry next = e.next;
                    int i = indexFor(e.hash, newCapacity);
                    e.next = newTable[i];
                    newTable[i] = e;
                    e = next;
                } while (e != null);
            }
        }
    }

    static class Entry {

        final Object key;
        int value;
        Entry next;
        final int hash;

        Entry(int h, Object k, int v, Entry n) {
            value = v;
            next = n;
            key = k;
            hash = h;
        }
    }

    void addEntry(int hash, Object key, int value, int bucketIndex) {
        Entry e = table[bucketIndex];
        table[bucketIndex] = new Entry(hash, key, value, e);
        if (size++ >= threshold) {
            resize(2 * table.length);
        }
    }
}
