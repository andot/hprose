/*
 * @(#)TreeMap.java	1.56 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * Red-Black tree based implementation of the <tt>SortedMap</tt> interface.
 * This class guarantees that the map will be in ascending key order, sorted
 * according to the <i>natural order</i> for the key's class (see
 * <tt>Comparable</tt>), or by the comparator provided at creation time,
 * depending on which constructor is used.<p>
 *
 * This implementation provides guaranteed log(n) time cost for the
 * <tt>containsKey</tt>, <tt>get</tt>, <tt>put</tt> and <tt>remove</tt>
 * operations.  Algorithms are adaptations of those in Cormen, Leiserson, and
 * Rivest's <I>Introduction to Algorithms</I>.<p>
 *
 * Note that the ordering maintained by a sorted map (whether or not an
 * explicit comparator is provided) must be <i>consistent with equals</i> if
 * this sorted map is to correctly implement the <tt>Map</tt> interface.  (See
 * <tt>Comparable</tt> or <tt>Comparator</tt> for a precise definition of
 * <i>consistent with equals</i>.)  This is so because the <tt>Map</tt>
 * interface is defined in terms of the equals operation, but a map performs
 * all key comparisons using its <tt>compareTo</tt> (or <tt>compare</tt>)
 * method, so two keys that are deemed equal by this method are, from the
 * standpoint of the sorted map, equal.  The behavior of a sorted map
 * <i>is</i> well-defined even if its ordering is inconsistent with equals; it
 * just fails to obey the general contract of the <tt>Map</tt> interface.<p>
 *
 * <b>Note that this implementation is not synchronized.</b> If multiple
 * threads access a map concurrently, and at least one of the threads modifies
 * the map structurally, it <i>must</i> be synchronized externally.  (A
 * structural modification is any operation that adds or deletes one or more
 * mappings; merely changing the value associated with an existing key is not
 * a structural modification.)  This is typically accomplished by
 * synchronizing on some object that naturally encapsulates the map.  If no
 * such object exists, the map should be "wrapped" using the
 * <tt>Collections.synchronizedMap</tt> method.  This is best done at creation
 * time, to prevent accidental unsynchronized access to the map:
 * <pre>
 *     Map m = Collections.synchronizedMap(new TreeMap(...));
 * </pre><p>
 *
 * The iterators returned by all of this class's "collection view methods" are
 * <i>fail-fast</i>: if the map is structurally modified at any time after the
 * iterator is created, in any way except through the iterator's own
 * <tt>remove</tt> or <tt>add</tt> methods, the iterator throws a
 * <tt>ConcurrentModificationException</tt>.  Thus, in the face of concurrent
 * modification, the iterator fails quickly and cleanly, rather than risking
 * arbitrary, non-deterministic behavior at an undetermined time in the
 * future.
 *
 * <p>Note that the fail-fast behavior of an iterator cannot be guaranteed
 * as it is, generally speaking, impossible to make any hard guarantees in the
 * presence of unsynchronized concurrent modification.  Fail-fast iterators
 * throw <tt>ConcurrentModificationException</tt> on a best-effort basis.
 * Therefore, it would be wrong to write a program that depended on this
 * exception for its correctness:   <i>the fail-fast behavior of iterators
 * should be used only to detect bugs.</i><p>
 *
 * This class is a member of the
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch and Doug Lea
 * @version 1.56, 01/23/03
 * @see Map
 * @see HashMap
 * @see Hashtable
 * @see Comparable
 * @see Comparator
 * @see Collection
 * @see Collections#synchronizedMap(Map)
 * @since 1.2
 */

public class TreeMap extends AbstractMap implements SortedMap {
    /**
     * The Comparator used to maintain order in this TreeMap, or
     * null if this TreeMap uses its elements natural ordering.
     *
     * @serial
     */
    private Comparator comparator = null;

    private transient Entry root = null;

    /**
     * The number of entries in the tree
     */
    private transient int size = 0;

    /**
     * The number of structural modifications to the tree.
     */
    private transient int modCount = 0;

    private void incrementSize()   { modCount++; size++; }
    private void decrementSize()   { modCount++; size--; }

    /**
     * Constructs a new, empty map, sorted according to the keys' natural
     * order.  All keys inserted into the map must implement the
     * <tt>Comparable</tt> interface.  Furthermore, all such keys must be
     * <i>mutually comparable</i>: <tt>k1.compareTo(k2)</tt> must not throw a
     * ClassCastException for any elements <tt>k1</tt> and <tt>k2</tt> in the
     * map.  If the user attempts to put a key into the map that violates this
     * constraint (for example, the user attempts to put a string key into a
     * map whose keys are integers), the <tt>put(Object key, Object
     * value)</tt> call will throw a <tt>ClassCastException</tt>.
     *
     * @see Comparable
     */
    public TreeMap() {
    }

    /**
     * Constructs a new, empty map, sorted according to the given comparator.
     * All keys inserted into the map must be <i>mutually comparable</i> by
     * the given comparator: <tt>comparator.compare(k1, k2)</tt> must not
     * throw a <tt>ClassCastException</tt> for any keys <tt>k1</tt> and
     * <tt>k2</tt> in the map.  If the user attempts to put a key into the
     * map that violates this constraint, the <tt>put(Object key, Object
     * value)</tt> call will throw a <tt>ClassCastException</tt>.
     *
     * @param c the comparator that will be used to sort this map.  A
     *        <tt>null</tt> value indicates that the keys' <i>natural
     *        ordering</i> should be used.
     */
    public TreeMap(Comparator c) {
        this.comparator = c;
    }

    /**
     * Constructs a new map containing the same mappings as the given map,
     * sorted according to the keys' <i>natural order</i>.  All keys inserted
     * into the new map must implement the <tt>Comparable</tt> interface.
     * Furthermore, all such keys must be <i>mutually comparable</i>:
     * <tt>k1.compareTo(k2)</tt> must not throw a <tt>ClassCastException</tt>
     * for any elements <tt>k1</tt> and <tt>k2</tt> in the map.  This method
     * runs in n*log(n) time.
     *
     * @param  m the map whose mappings are to be placed in this map.
     * @throws ClassCastException the keys in t are not Comparable, or
     *         are not mutually comparable.
     * @throws NullPointerException if the specified map is null.
     */
    public TreeMap(Map m) {
        putAll(m);
    }

    /**
     * Constructs a new map containing the same mappings as the given
     * <tt>SortedMap</tt>, sorted according to the same ordering.  This method
     * runs in linear time.
     *
     * @param  m the sorted map whose mappings are to be placed in this map,
     *         and whose comparator is to be used to sort this map.
     * @throws NullPointerException if the specified sorted map is null.
     */
    public TreeMap(SortedMap m) {
        comparator = m.comparator();
        try {
            buildFromSorted(m.size(), m.entrySet().iterator(), null);
        } catch (java.io.IOException cannotHappen) {
        } catch (ClassNotFoundException cannotHappen) {
        }
    }


    // Query Operations

    /**
     * Returns the number of key-value mappings in this map.
     *
     * @return the number of key-value mappings in this map.
     */
    public int size() {
        return size;
    }

    /**
     * Returns <tt>true</tt> if this map contains a mapping for the specified
     * key.
     *
     * @param key key whose presence in this map is to be tested.
     *
     * @return <tt>true</tt> if this map contains a mapping for the
     *            specified key.
     * @throws ClassCastException if the key cannot be compared with the keys
     *                  currently in the map.
     * @throws NullPointerException key is <tt>null</tt> and this map uses
     *                  natural ordering, or its comparator does not tolerate
     *            <tt>null</tt> keys.
     */
    public boolean containsKey(Object key) {
        return getEntry(key) != null;
    }

    /**
     * Returns <tt>true</tt> if this map maps one or more keys to the
     * specified value.  More formally, returns <tt>true</tt> if and only if
     * this map contains at least one mapping to a value <tt>v</tt> such
     * that <tt>(value==null ? v==null : value.equals(v))</tt>.  This
     * operation will probably require time linear in the Map size for most
     * implementations of Map.
     *
     * @param value value whose presence in this Map is to be tested.
     * @return  <tt>true</tt> if a mapping to <tt>value</tt> exists;
     *		<tt>false</tt> otherwise.
     * @since 1.2
     */
    public boolean containsValue(Object value) {
        return (root==null ? false :
                (value==null ? valueSearchNull(root)
                             : valueSearchNonNull(root, value)));
    }

    private boolean valueSearchNull(Entry n) {
        if (n.value == null)
            return true;

        // Check left and right subtrees for value
        return (n.left  != null && valueSearchNull(n.left)) ||
               (n.right != null && valueSearchNull(n.right));
    }

    private boolean valueSearchNonNull(Entry n, Object value) {
        // Check this node for the value
        if (value.equals(n.value))
            return true;

        // Check left and right subtrees for value
        return (n.left  != null && valueSearchNonNull(n.left, value)) ||
               (n.right != null && valueSearchNonNull(n.right, value));
    }

    /**
     * Returns the value to which this map maps the specified key.  Returns
     * <tt>null</tt> if the map contains no mapping for this key.  A return
     * value of <tt>null</tt> does not <i>necessarily</i> indicate that the
     * map contains no mapping for the key; it's also possible that the map
     * explicitly maps the key to <tt>null</tt>.  The <tt>containsKey</tt>
     * operation may be used to distinguish these two cases.
     *
     * @param key key whose associated value is to be returned.
     * @return the value to which this map maps the specified key, or
     *               <tt>null</tt> if the map contains no mapping for the key.
     * @throws    ClassCastException key cannot be compared with the keys
     *                  currently in the map.
     * @throws NullPointerException key is <tt>null</tt> and this map uses
     *                  natural ordering, or its comparator does not tolerate
     *                  <tt>null</tt> keys.
     *
     * @see #containsKey(Object)
     */
    public Object get(Object key) {
        Entry p = getEntry(key);
        return (p==null ? null : p.value);
    }

    /**
     * Returns the comparator used to order this map, or <tt>null</tt> if this
     * map uses its keys' natural order.
     *
     * @return the comparator associated with this sorted map, or
     *                <tt>null</tt> if it uses its keys' natural sort method.
     */
    public Comparator comparator() {
        return comparator;
    }

    /**
     * Returns the first (lowest) key currently in this sorted map.
     *
     * @return the first (lowest) key currently in this sorted map.
     * @throws    NoSuchElementException Map is empty.
     */
    public Object firstKey() {
        return key(firstEntry());
    }

    /**
     * Returns the last (highest) key currently in this sorted map.
     *
     * @return the last (highest) key currently in this sorted map.
     * @throws    NoSuchElementException Map is empty.
     */
    public Object lastKey() {
        return key(lastEntry());
    }

    /**
     * Copies all of the mappings from the specified map to this map.  These
     * mappings replace any mappings that this map had for any of the keys
     * currently in the specified map.
     *
     * @param     map mappings to be stored in this map.
     * @throws    ClassCastException class of a key or value in the specified
     *                   map prevents it from being stored in this map.
     *
     * @throws NullPointerException if the given map is <tt>null</tt> or
     *         this map does not permit <tt>null</tt> keys and a
     *         key in the specified map is <tt>null</tt>.
     */
    public void putAll(Map map) {
        int mapSize = map.size();
        if (size==0 && mapSize!=0 && map instanceof SortedMap) {
            Comparator c = ((SortedMap)map).comparator();
            if (c == comparator || (c != null && c.equals(comparator))) {
              ++modCount;
              try {
                  buildFromSorted(mapSize, map.entrySet().iterator(), null);
              } catch (java.io.IOException cannotHappen) {
              } catch (ClassNotFoundException cannotHappen) {
              }
              return;
            }
        }
        super.putAll(map);
    }

    /**
     * Returns this map's entry for the given key, or <tt>null</tt> if the map
     * does not contain an entry for the key.
     *
     * @return this map's entry for the given key, or <tt>null</tt> if the map
     *                does not contain an entry for the key.
     * @throws ClassCastException if the key cannot be compared with the keys
     *                  currently in the map.
     * @throws NullPointerException key is <tt>null</tt> and this map uses
     *                  natural order, or its comparator does not tolerate *
     *                  <tt>null</tt> keys.
     */
    private Entry getEntry(Object key) {
        Entry p = root;
        while (p != null) {
            int cmp = compare(key,p.key);
            if (cmp == 0)
                return p;
            else if (cmp < 0)
                p = p.left;
            else
                p = p.right;
        }
        return null;
    }

    /**
     * Gets the entry corresponding to the specified key; if no such entry
     * exists, returns the entry for the least key greater than the specified
     * key; if no such entry exists (i.e., the greatest key in the Tree is less
     * than the specified key), returns <tt>null</tt>.
     */
    private Entry getCeilEntry(Object key) {
        Entry p = root;
        if (p==null)
            return null;

        while (true) {
            int cmp = compare(key, p.key);
            if (cmp == 0) {
                return p;
            } else if (cmp < 0) {
                if (p.left != null)
                    p = p.left;
                else
                    return p;
            } else {
                if (p.right != null) {
                    p = p.right;
                } else {
                    Entry parent = p.parent;
                    Entry ch = p;
                    while (parent != null && ch == parent.right) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            }
        }
    }

    /**
     * Returns the entry for the greatest key less than the specified key; if
     * no such entry exists (i.e., the least key in the Tree is greater than
     * the specified key), returns <tt>null</tt>.
     */
    private Entry getPrecedingEntry(Object key) {
        Entry p = root;
        if (p==null)
            return null;

        while (true) {
            int cmp = compare(key, p.key);
            if (cmp > 0) {
                if (p.right != null)
                    p = p.right;
                else
                    return p;
            } else {
                if (p.left != null) {
                    p = p.left;
                } else {
                    Entry parent = p.parent;
                    Entry ch = p;
                    while (parent != null && ch == parent.left) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            }
        }
    }

    /**
     * Returns the key corresonding to the specified Entry.  Throw
     * NoSuchElementException if the Entry is <tt>null</tt>.
     */
    private static Object key(Entry e) {
        if (e==null)
            throw new NoSuchElementException();
        return e.key;
    }

    /**
     * Associates the specified value with the specified key in this map.
     * If the map previously contained a mapping for this key, the old
     * value is replaced.
     *
     * @param key key with which the specified value is to be associated.
     * @param value value to be associated with the specified key.
     *
     * @return previous value associated with specified key, or <tt>null</tt>
     *         if there was no mapping for key.  A <tt>null</tt> return can
     *         also indicate that the map previously associated <tt>null</tt>
     *         with the specified key.
     * @throws    ClassCastException key cannot be compared with the keys
     *            currently in the map.
     * @throws NullPointerException key is <tt>null</tt> and this map uses
     *         natural order, or its comparator does not tolerate
     *         <tt>null</tt> keys.
     */
    public Object put(Object key, Object value) {
        Entry t = root;

        if (t == null) {
            incrementSize();
            root = new Entry(key, value, null);
            return null;
       }

        while (true) {
            int cmp = compare(key, t.key);
            if (cmp == 0) {
                return t.setValue(value);
            } else if (cmp < 0) {
                if (t.left != null) {
                    t = t.left;
                } else {
                    incrementSize();
                    t.left = new Entry(key, value, t);
                    fixAfterInsertion(t.left);
                    return null;
                }
            } else { // cmp > 0
                if (t.right != null) {
                    t = t.right;
                } else {
                    incrementSize();
                    t.right = new Entry(key, value, t);
                    fixAfterInsertion(t.right);
                    return null;
                }
            }
        }
    }

    /**
     * Removes the mapping for this key from this TreeMap if present.
     *
     * @param  key key for which mapping should be removed
     * @return previous value associated with specified key, or <tt>null</tt>
     *         if there was no mapping for key.  A <tt>null</tt> return can
     *         also indicate that the map previously associated
     *         <tt>null</tt> with the specified key.
     *
     * @throws    ClassCastException key cannot be compared with the keys
     *            currently in the map.
     * @throws NullPointerException key is <tt>null</tt> and this map uses
     *         natural order, or its comparator does not tolerate
     *         <tt>null</tt> keys.
     */
    public Object remove(Object key) {
        Entry p = getEntry(key);
        if (p == null)
            return null;

        Object oldValue = p.value;
        deleteEntry(p);
        return oldValue;
    }

    /**
     * Removes all mappings from this TreeMap.
     */
    public void clear() {
        modCount++;
        size = 0;
        root = null;
    }

    // Views

    /**
     * This field is initialized to contain an instance of the entry set
     * view the first time this view is requested.  The view is stateless,
     * so there's no reason to create more than one.
     */
    private transient volatile Set entrySet = null;

    /**
     * Returns a Set view of the keys contained in this map.  The set's
     * iterator will return the keys in ascending order.  The map is backed by
     * this <tt>TreeMap</tt> instance, so changes to this map are reflected in
     * the Set, and vice-versa.  The Set supports element removal, which
     * removes the corresponding mapping from the map, via the
     * <tt>Iterator.remove</tt>, <tt>Set.remove</tt>, <tt>removeAll</tt>,
     * <tt>retainAll</tt>, and <tt>clear</tt> operations.  It does not support
     * the <tt>add</tt> or <tt>addAll</tt> operations.
     *
     * @return a set view of the keys contained in this TreeMap.
     */
    public Set keySet() {
        if (keySet == null) {
            keySet = new AbstractSet() {
                public Iterator iterator() {
                    return new KeyIterator();
                }

                public int size() {
                    return TreeMap.this.size();
                }

                public boolean contains(Object o) {
                    return containsKey(o);
                }

                public boolean remove(Object o) {
                    int oldSize = size;
                    TreeMap.this.remove(o);
                    return size != oldSize;
                }

                public void clear() {
                    TreeMap.this.clear();
                }
            };
        }
        return keySet;
    }

    /**
     * Returns a collection view of the values contained in this map.  The
     * collection's iterator will return the values in the order that their
     * corresponding keys appear in the tree.  The collection is backed by
     * this <tt>TreeMap</tt> instance, so changes to this map are reflected in
     * the collection, and vice-versa.  The collection supports element
     * removal, which removes the corresponding mapping from the map through
     * the <tt>Iterator.remove</tt>, <tt>Collection.remove</tt>,
     * <tt>removeAll</tt>, <tt>retainAll</tt>, and <tt>clear</tt> operations.
     * It does not support the <tt>add</tt> or <tt>addAll</tt> operations.
     *
     * @return a collection view of the values contained in this map.
     */
    public Collection values() {
        if (values == null) {
            values = new AbstractCollection() {
                public Iterator iterator() {
                    return new ValueIterator();
                }

                public int size() {
                    return TreeMap.this.size();
                }

                public boolean contains(Object o) {
                    for (Entry e = firstEntry(); e != null; e = successor(e))
                        if (valEquals(e.getValue(), o))
                            return true;
                    return false;
                }

                public boolean remove(Object o) {
                    for (Entry e = firstEntry(); e != null; e = successor(e)) {
                        if (valEquals(e.getValue(), o)) {
                            deleteEntry(e);
                            return true;
                        }
                    }
                    return false;
                }

                public void clear() {
                    TreeMap.this.clear();
                }
            };
        }
        return values;
    }

    /**
     * Returns a set view of the mappings contained in this map.  The set's
     * iterator returns the mappings in ascending key order.  Each element in
     * the returned set is a <tt>Map.Entry</tt>.  The set is backed by this
     * map, so changes to this map are reflected in the set, and vice-versa.
     * The set supports element removal, which removes the corresponding
     * mapping from the TreeMap, through the <tt>Iterator.remove</tt>,
     * <tt>Set.remove</tt>, <tt>removeAll</tt>, <tt>retainAll</tt> and
     * <tt>clear</tt> operations.  It does not support the <tt>add</tt> or
     * <tt>addAll</tt> operations.
     *
     * @return a set view of the mappings contained in this map.
     * @see Map.Entry
     */
    public Set entrySet() {
        if (entrySet == null) {
            entrySet = new AbstractSet() {
                public Iterator iterator() {
                    return new EntryIterator();
                }

                public boolean contains(Object o) {
                    if (!(o instanceof Map.Entry))
                        return false;
                    Map.Entry entry = (Map.Entry)o;
                    Object value = entry.getValue();
                    Entry p = getEntry(entry.getKey());
                    return p != null && valEquals(p.getValue(), value);
                }

                public boolean remove(Object o) {
                    if (!(o instanceof Map.Entry))
                        return false;
                    Map.Entry entry = (Map.Entry)o;
                    Object value = entry.getValue();
                    Entry p = getEntry(entry.getKey());
                    if (p != null && valEquals(p.getValue(), value)) {
                        deleteEntry(p);
                        return true;
                    }
                    return false;
                }

                public int size() {
                    return TreeMap.this.size();
                }

                public void clear() {
                    TreeMap.this.clear();
                }
            };
        }
        return entrySet;
    }

    /**
     * Returns a view of the portion of this map whose keys range from
     * <tt>fromKey</tt>, inclusive, to <tt>toKey</tt>, exclusive.  (If
     * <tt>fromKey</tt> and <tt>toKey</tt> are equal, the returned sorted map
     * is empty.)  The returned sorted map is backed by this map, so changes
     * in the returned sorted map are reflected in this map, and vice-versa.
     * The returned sorted map supports all optional map operations.<p>
     *
     * The sorted map returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a key
     * less than <tt>fromKey</tt> or greater than or equal to
     * <tt>toKey</tt>.<p>
     *
     * Note: this method always returns a <i>half-open range</i> (which
     * includes its low endpoint but not its high endpoint).  If you need a
     * <i>closed range</i> (which includes both endpoints), and the key type
     * allows for calculation of the successor a given key, merely request the
     * subrange from <tt>lowEndpoint</tt> to <tt>successor(highEndpoint)</tt>.
     * For example, suppose that <tt>m</tt> is a sorted map whose keys are
     * strings.  The following idiom obtains a view containing all of the
     * key-value mappings in <tt>m</tt> whose keys are between <tt>low</tt>
     * and <tt>high</tt>, inclusive:
     *             <pre>    SortedMap sub = m.submap(low, high+"\0");</pre>
     * A similar technique can be used to generate an <i>open range</i> (which
     * contains neither endpoint).  The following idiom obtains a view
     * containing all of the key-value mappings in <tt>m</tt> whose keys are
     * between <tt>low</tt> and <tt>high</tt>, exclusive:
     *             <pre>    SortedMap sub = m.subMap(low+"\0", high);</pre>
     *
     * @param fromKey low endpoint (inclusive) of the subMap.
     * @param toKey high endpoint (exclusive) of the subMap.
     *
     * @return a view of the portion of this map whose keys range from
     *                <tt>fromKey</tt>, inclusive, to <tt>toKey</tt>, exclusive.
     *
     * @throws ClassCastException if <tt>fromKey</tt> and <tt>toKey</tt>
     *         cannot be compared to one another using this map's comparator
     *         (or, if the map has no comparator, using natural ordering).
     * @throws IllegalArgumentException if <tt>fromKey</tt> is greater than
     *         <tt>toKey</tt>.
     * @throws NullPointerException if <tt>fromKey</tt> or <tt>toKey</tt> is
     *               <tt>null</tt> and this map uses natural order, or its
     *               comparator does not tolerate <tt>null</tt> keys.
     */
    public SortedMap subMap(Object fromKey, Object toKey) {
        return new SubMap(fromKey, toKey);
    }

    /**
     * Returns a view of the portion of this map whose keys are strictly less
     * than <tt>toKey</tt>.  The returned sorted map is backed by this map, so
     * changes in the returned sorted map are reflected in this map, and
     * vice-versa.  The returned sorted map supports all optional map
     * operations.<p>
     *
     * The sorted map returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a key
     * greater than or equal to <tt>toKey</tt>.<p>
     *
     * Note: this method always returns a view that does not contain its
     * (high) endpoint.  If you need a view that does contain this endpoint,
     * and the key type allows for calculation of the successor a given key,
     * merely request a headMap bounded by <tt>successor(highEndpoint)</tt>.
     * For example, suppose that suppose that <tt>m</tt> is a sorted map whose
     * keys are strings.  The following idiom obtains a view containing all of
     * the key-value mappings in <tt>m</tt> whose keys are less than or equal
     * to <tt>high</tt>:
     * <pre>
     *     SortedMap head = m.headMap(high+"\0");
     * </pre>
     *
     * @param toKey high endpoint (exclusive) of the headMap.
     * @return a view of the portion of this map whose keys are strictly
     *                less than <tt>toKey</tt>.
     *
     * @throws ClassCastException if <tt>toKey</tt> is not compatible
     *         with this map's comparator (or, if the map has no comparator,
     *         if <tt>toKey</tt> does not implement <tt>Comparable</tt>).
     * @throws IllegalArgumentException if this map is itself a subMap,
     *         headMap, or tailMap, and <tt>toKey</tt> is not within the
     *         specified range of the subMap, headMap, or tailMap.
     * @throws NullPointerException if <tt>toKey</tt> is <tt>null</tt> and
     *               this map uses natural order, or its comparator does not
     *               tolerate <tt>null</tt> keys.
     */
    public SortedMap headMap(Object toKey) {
        return new SubMap(toKey, true);
    }

    /**
     * Returns a view of the portion of this map whose keys are greater than
     * or equal to <tt>fromKey</tt>.  The returned sorted map is backed by
     * this map, so changes in the returned sorted map are reflected in this
     * map, and vice-versa.  The returned sorted map supports all optional map
     * operations.<p>
     *
     * The sorted map returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a key
     * less than <tt>fromKey</tt>.<p>
     *
     * Note: this method always returns a view that contains its (low)
     * endpoint.  If you need a view that does not contain this endpoint, and
     * the element type allows for calculation of the successor a given value,
     * merely request a tailMap bounded by <tt>successor(lowEndpoint)</tt>.
     * For For example, suppose that suppose that <tt>m</tt> is a sorted map
     * whose keys are strings.  The following idiom obtains a view containing
     * all of the key-value mappings in <tt>m</tt> whose keys are strictly
     * greater than <tt>low</tt>: <pre>
     *     SortedMap tail = m.tailMap(low+"\0");
     * </pre>
     *
     * @param fromKey low endpoint (inclusive) of the tailMap.
     * @return a view of the portion of this map whose keys are greater
     *                than or equal to <tt>fromKey</tt>.
     * @throws ClassCastException if <tt>fromKey</tt> is not compatible
     *         with this map's comparator (or, if the map has no comparator,
     *         if <tt>fromKey</tt> does not implement <tt>Comparable</tt>).
     * @throws IllegalArgumentException if this map is itself a subMap,
     *         headMap, or tailMap, and <tt>fromKey</tt> is not within the
     *         specified range of the subMap, headMap, or tailMap.
     * @throws NullPointerException if <tt>fromKey</tt> is <tt>null</tt> and
     *               this map uses natural order, or its comparator does not
     *               tolerate <tt>null</tt> keys.
     */
    public SortedMap tailMap(Object fromKey) {
        return new SubMap(fromKey, false);
    }

    private class SubMap extends AbstractMap implements SortedMap {
        /**
         * fromKey is significant only if fromStart is false.  Similarly,
         * toKey is significant only if toStart is false.
         */
        private boolean fromStart = false, toEnd = false;
        private Object  fromKey,           toKey;

        SubMap(Object fromKey, Object toKey) {
            if (compare(fromKey, toKey) > 0)
                throw new IllegalArgumentException("fromKey > toKey");
            this.fromKey = fromKey;
            this.toKey = toKey;
        }

        SubMap(Object key, boolean headMap) {
            compare(key, key); // Type-check key

            if (headMap) {
                fromStart = true;
                toKey = key;
            } else {
                toEnd = true;
                fromKey = key;
            }
        }

        SubMap(boolean fromStart, Object fromKey, boolean toEnd, Object toKey){
            this.fromStart = fromStart;
            this.fromKey= fromKey;
            this.toEnd = toEnd;
            this.toKey = toKey;
        }

        public boolean isEmpty() {
            return entrySet.isEmpty();
        }

        public boolean containsKey(Object key) {
            return inRange(key) && TreeMap.this.containsKey(key);
        }

        public Object get(Object key) {
            if (!inRange(key))
                return null;
            return TreeMap.this.get(key);
        }

        public Object put(Object key, Object value) {
            if (!inRange(key))
                throw new IllegalArgumentException("key out of range");
            return TreeMap.this.put(key, value);
        }

        public Comparator comparator() {
            return comparator;
        }

        public Object firstKey() {
            Object first = key(fromStart ? firstEntry():getCeilEntry(fromKey));
            if (!toEnd && compare(first, toKey) >= 0)
                throw(new NoSuchElementException());
            return first;
        }

        public Object lastKey() {
            Object last = key(toEnd ? lastEntry() : getPrecedingEntry(toKey));
            if (!fromStart && compare(last, fromKey) < 0)
                throw(new NoSuchElementException());
            return last;
        }

        private transient Set entrySet = new EntrySetView();

        public Set entrySet() {
            return entrySet;
        }

        private class EntrySetView extends AbstractSet {
            private transient int size = -1, sizeModCount;

            public int size() {
                if (size == -1 || sizeModCount != TreeMap.this.modCount) {
                    size = 0;  sizeModCount = TreeMap.this.modCount;
                    Iterator i = iterator();
                    while (i.hasNext()) {
                        size++;
                        i.next();
                    }
                }
                return size;
            }

            public boolean isEmpty() {
                return !iterator().hasNext();
            }

            public boolean contains(Object o) {
                if (!(o instanceof Map.Entry))
                    return false;
                Map.Entry entry = (Map.Entry)o;
                Object key = entry.getKey();
                if (!inRange(key))
                    return false;
                TreeMap.Entry node = getEntry(key);
                return node != null &&
                       valEquals(node.getValue(), entry.getValue());
            }

            public boolean remove(Object o) {
                if (!(o instanceof Map.Entry))
                    return false;
                Map.Entry entry = (Map.Entry)o;
                Object key = entry.getKey();
                if (!inRange(key))
                    return false;
                TreeMap.Entry node = getEntry(key);
                if (node!=null && valEquals(node.getValue(),entry.getValue())){
                    deleteEntry(node);
                    return true;
                }
                return false;
            }

            public Iterator iterator() {
                return new SubMapEntryIterator(
                    (fromStart ? firstEntry() : getCeilEntry(fromKey)),
                    (toEnd     ? null         : getCeilEntry(toKey)));
            }
        }

        public SortedMap subMap(Object fromKey, Object toKey) {
            if (!inRange2(fromKey))
                throw new IllegalArgumentException("fromKey out of range");
            if (!inRange2(toKey))
                throw new IllegalArgumentException("toKey out of range");
            return new SubMap(fromKey, toKey);
        }

        public SortedMap headMap(Object toKey) {
            if (!inRange2(toKey))
                throw new IllegalArgumentException("toKey out of range");
            return new SubMap(fromStart, fromKey, false, toKey);
        }

        public SortedMap tailMap(Object fromKey) {
            if (!inRange2(fromKey))
                throw new IllegalArgumentException("fromKey out of range");
            return new SubMap(false, fromKey, toEnd, toKey);
        }

        private boolean inRange(Object key) {
            return (fromStart || compare(key, fromKey) >= 0) &&
                   (toEnd     || compare(key, toKey)   <  0);
        }

        // This form allows the high endpoint (as well as all legit keys)
        private boolean inRange2(Object key) {
            return (fromStart || compare(key, fromKey) >= 0) &&
                   (toEnd     || compare(key, toKey)   <= 0);
        }
    }

    /**
     * TreeMap Iterator.
     */
    private class EntryIterator implements Iterator {
        private int expectedModCount = TreeMap.this.modCount;
        private Entry lastReturned = null;
        Entry next;

        EntryIterator() {
            next = firstEntry();
        }

        // Used by SubMapEntryIterator
        EntryIterator(Entry first) {
            next = first;
        }

        public boolean hasNext() {
            return next != null;
        }

        final Entry nextEntry() {
            if (next == null)
                throw new NoSuchElementException();
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            lastReturned = next;
            next = successor(next);
            return lastReturned;
        }

        public Object next() {
            return nextEntry();
        }

        public void remove() {
            if (lastReturned == null)
                throw new IllegalStateException();
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            if (lastReturned.left != null && lastReturned.right != null)
                next = lastReturned;
            deleteEntry(lastReturned);
            expectedModCount++;
            lastReturned = null;
        }
    }

    private class KeyIterator extends EntryIterator {
        public Object next() {
            return nextEntry().key;
        }
    }

    private class ValueIterator extends EntryIterator {
        public Object next() {
            return nextEntry().value;
        }
    }

    private class SubMapEntryIterator extends EntryIterator {
        private final Object firstExcludedKey;

        SubMapEntryIterator(Entry first, Entry firstExcluded) {
            super(first);
            firstExcludedKey = (firstExcluded == null ?
                                firstExcluded : firstExcluded.key);
        }

        public boolean hasNext() {
            return next != null && next.key != firstExcludedKey;
        }

        public Object next() {
            if (next == null || next.key == firstExcludedKey)
                throw new NoSuchElementException();
            return nextEntry();
        }
    }

    /**
     * Compares two keys using the correct comparison method for this TreeMap.
     */
    private int compare(Object k1, Object k2) {
        return (comparator==null ? ((Comparable)k1).compareTo(k2)
                                 : comparator.compare(k1, k2));
    }

    /**
     * Test two values  for equality.  Differs from o1.equals(o2) only in
     * that it copes with with <tt>null</tt> o1 properly.
     */
    private static boolean valEquals(Object o1, Object o2) {
        return (o1==null ? o2==null : o1.equals(o2));
    }

    private static final boolean RED   = false;
    private static final boolean BLACK = true;

    /**
     * Node in the Tree.  Doubles as a means to pass key-value pairs back to
     * user (see Map.Entry).
     */

    static class Entry implements Map.Entry {
        Object key;
        Object value;
        Entry left = null;
        Entry right = null;
        Entry parent;
        boolean color = BLACK;

        /**
         * Make a new cell with given key, value, and parent, and with
         * <tt>null</tt> child links, and BLACK color.
         */
        Entry(Object key, Object value, Entry parent) {
            this.key = key;
            this.value = value;
            this.parent = parent;
        }

        /**
         * Returns the key.
         *
         * @return the key.
         */
        public Object getKey() {
            return key;
        }

        /**
         * Returns the value associated with the key.
         *
         * @return the value associated with the key.
         */
        public Object getValue() {
            return value;
        }

        /**
         * Replaces the value currently associated with the key with the given
         * value.
         *
         * @return the value associated with the key before this method was
         *           called.
         */
        public Object setValue(Object value) {
            Object oldValue = this.value;
            this.value = value;
            return oldValue;
        }

        public boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry e = (Map.Entry)o;

            return valEquals(key,e.getKey()) && valEquals(value,e.getValue());
        }

        public int hashCode() {
            int keyHash = (key==null ? 0 : key.hashCode());
            int valueHash = (value==null ? 0 : value.hashCode());
            return keyHash ^ valueHash;
        }

        public String toString() {
            return key + "=" + value;
        }
    }

    /**
     * Returns the first Entry in the TreeMap (according to the TreeMap's
     * key-sort function).  Returns null if the TreeMap is empty.
     */
    private Entry firstEntry() {
        Entry p = root;
        if (p != null)
            while (p.left != null)
                p = p.left;
        return p;
    }

    /**
     * Returns the last Entry in the TreeMap (according to the TreeMap's
     * key-sort function).  Returns null if the TreeMap is empty.
     */
    private Entry lastEntry() {
        Entry p = root;
        if (p != null)
            while (p.right != null)
                p = p.right;
        return p;
    }

    /**
     * Returns the successor of the specified Entry, or null if no such.
     */
    private Entry successor(Entry t) {
        if (t == null)
            return null;
        else if (t.right != null) {
            Entry p = t.right;
            while (p.left != null)
                p = p.left;
            return p;
        } else {
            Entry p = t.parent;
            Entry ch = t;
            while (p != null && ch == p.right) {
                ch = p;
                p = p.parent;
            }
            return p;
        }
    }

    /**
     * Balancing operations.
     *
     * Implementations of rebalancings during insertion and deletion are
     * slightly different than the CLR version.  Rather than using dummy
     * nilnodes, we use a set of accessors that deal properly with null.  They
     * are used to avoid messiness surrounding nullness checks in the main
     * algorithms.
     */

    private static boolean colorOf(Entry p) {
        return (p == null ? BLACK : p.color);
    }

    private static Entry  parentOf(Entry p) {
        return (p == null ? null: p.parent);
    }

    private static void setColor(Entry p, boolean c) {
        if (p != null)  p.color = c;
    }

    private static Entry  leftOf(Entry p) {
        return (p == null)? null: p.left;
    }

    private static Entry  rightOf(Entry p) {
        return (p == null)? null: p.right;
    }

    /** From CLR **/
    private void rotateLeft(Entry p) {
        Entry r = p.right;
        p.right = r.left;
        if (r.left != null)
            r.left.parent = p;
        r.parent = p.parent;
        if (p.parent == null)
            root = r;
        else if (p.parent.left == p)
            p.parent.left = r;
        else
            p.parent.right = r;
        r.left = p;
        p.parent = r;
    }

    /** From CLR **/
    private void rotateRight(Entry p) {
        Entry l = p.left;
        p.left = l.right;
        if (l.right != null) l.right.parent = p;
        l.parent = p.parent;
        if (p.parent == null)
            root = l;
        else if (p.parent.right == p)
            p.parent.right = l;
        else p.parent.left = l;
        l.right = p;
        p.parent = l;
    }


    /** From CLR **/
    private void fixAfterInsertion(Entry x) {
        x.color = RED;

        while (x != null && x != root && x.parent.color == RED) {
            if (parentOf(x) == leftOf(parentOf(parentOf(x)))) {
                Entry y = rightOf(parentOf(parentOf(x)));
                if (colorOf(y) == RED) {
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    x = parentOf(parentOf(x));
                } else {
                    if (x == rightOf(parentOf(x))) {
                        x = parentOf(x);
                        rotateLeft(x);
                    }
                    setColor(parentOf(x), BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    if (parentOf(parentOf(x)) != null)
                        rotateRight(parentOf(parentOf(x)));
                }
            } else {
                Entry y = leftOf(parentOf(parentOf(x)));
                if (colorOf(y) == RED) {
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    x = parentOf(parentOf(x));
                } else {
                    if (x == leftOf(parentOf(x))) {
                        x = parentOf(x);
                        rotateRight(x);
                    }
                    setColor(parentOf(x),  BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    if (parentOf(parentOf(x)) != null)
                        rotateLeft(parentOf(parentOf(x)));
                }
            }
        }
        root.color = BLACK;
    }

    /**
     * Delete node p, and then rebalance the tree.
     */

    private void deleteEntry(Entry p) {
        decrementSize();

        // If strictly internal, copy successor's element to p and then make p
        // point to successor.
        if (p.left != null && p.right != null) {
            Entry s = successor (p);
            p.key = s.key;
            p.value = s.value;
            p = s;
        } // p has 2 children

        // Start fixup at replacement node, if it exists.
        Entry replacement = (p.left != null ? p.left : p.right);

        if (replacement != null) {
            // Link replacement to parent
            replacement.parent = p.parent;
            if (p.parent == null)
                root = replacement;
            else if (p == p.parent.left)
                p.parent.left  = replacement;
            else
                p.parent.right = replacement;

            // Null out links so they are OK to use by fixAfterDeletion.
            p.left = p.right = p.parent = null;

            // Fix replacement
            if (p.color == BLACK)
                fixAfterDeletion(replacement);
        } else if (p.parent == null) { // return if we are the only node.
            root = null;
        } else { //  No children. Use self as phantom replacement and unlink.
            if (p.color == BLACK)
                fixAfterDeletion(p);

            if (p.parent != null) {
                if (p == p.parent.left)
                    p.parent.left = null;
                else if (p == p.parent.right)
                    p.parent.right = null;
                p.parent = null;
            }
        }
    }

    /** From CLR **/
    private void fixAfterDeletion(Entry x) {
        while (x != root && colorOf(x) == BLACK) {
            if (x == leftOf(parentOf(x))) {
                Entry sib = rightOf(parentOf(x));

                if (colorOf(sib) == RED) {
                    setColor(sib, BLACK);
                    setColor(parentOf(x), RED);
                    rotateLeft(parentOf(x));
                    sib = rightOf(parentOf(x));
                }

                if (colorOf(leftOf(sib))  == BLACK &&
                    colorOf(rightOf(sib)) == BLACK) {
                    setColor(sib,  RED);
                    x = parentOf(x);
                } else {
                    if (colorOf(rightOf(sib)) == BLACK) {
                        setColor(leftOf(sib), BLACK);
                        setColor(sib, RED);
                        rotateRight(sib);
                        sib = rightOf(parentOf(x));
                    }
                    setColor(sib, colorOf(parentOf(x)));
                    setColor(parentOf(x), BLACK);
                    setColor(rightOf(sib), BLACK);
                    rotateLeft(parentOf(x));
                    x = root;
                }
            } else { // symmetric
                Entry sib = leftOf(parentOf(x));

                if (colorOf(sib) == RED) {
                    setColor(sib, BLACK);
                    setColor(parentOf(x), RED);
                    rotateRight(parentOf(x));
                    sib = leftOf(parentOf(x));
                }

                if (colorOf(rightOf(sib)) == BLACK &&
                    colorOf(leftOf(sib)) == BLACK) {
                    setColor(sib,  RED);
                    x = parentOf(x);
                } else {
                    if (colorOf(leftOf(sib)) == BLACK) {
                        setColor(rightOf(sib), BLACK);
                        setColor(sib, RED);
                        rotateLeft(sib);
                        sib = leftOf(parentOf(x));
                    }
                    setColor(sib, colorOf(parentOf(x)));
                    setColor(parentOf(x), BLACK);
                    setColor(leftOf(sib), BLACK);
                    rotateRight(parentOf(x));
                    x = root;
                }
            }
        }

        setColor(x, BLACK);
    }

    /** Intended to be called only from TreeSet.addAll **/
    void addAllForTreeSet(SortedSet set, Object defaultVal) {
      try {
          buildFromSorted(set.size(), set.iterator(), defaultVal);
      } catch (java.io.IOException cannotHappen) {
      } catch (ClassNotFoundException cannotHappen) {
      }
    }


    /**
     * Linear time tree building algorithm from sorted data.  Can accept keys
     * and/or values from iterator or stream. This leads to too many
     * parameters, but seems better than alternatives.  The four formats
     * that this method accepts are:
     *
     *    1) An iterator of Map.Entries.  (it != null, defaultVal == null).
     *    2) An iterator of keys.         (it != null, defaultVal != null).
     *    3) A stream of alternating serialized keys and values.
     *                                   (it == null, defaultVal == null).
     *    4) A stream of serialized keys. (it == null, defaultVal != null).
     *
     * It is assumed that the comparator of the TreeMap is already set prior
     * to calling this method.
     *
     * @param size the number of keys (or key-value pairs) to be read from
     *        the iterator or stream.
     * @param it If non-null, new entries are created from entries
     *        or keys read from this iterator.
     * @param it If non-null, new entries are created from keys and
     *        possibly values read from this stream in serialized form.
     *        Exactly one of it and str should be non-null.
     * @param defaultVal if non-null, this default value is used for
     *        each value in the map.  If null, each value is read from
     *        iterator or stream, as described above.
     * @throws IOException propagated from stream reads. This cannot
     *         occur if str is null.
     * @throws ClassNotFoundException propagated from readObject.
     *         This cannot occur if str is null.
     */
    private void buildFromSorted(int size, Iterator it,
                                  Object defaultVal)
        throws  java.io.IOException, ClassNotFoundException {
        this.size = size;
        root = buildFromSorted(0, 0, size-1, computeRedLevel(size),
                               it, defaultVal);
    }

    /**
     * Recursive "helper method" that does the real work of the
     * of the previous method.  Identically named parameters have
     * identical definitions.  Additional parameters are documented below.
     * It is assumed that the comparator and size fields of the TreeMap are
     * already set prior to calling this method.  (It ignores both fields.)
     *
     * @param level the current level of tree. Initial call should be 0.
     * @param lo the first element index of this subtree. Initial should be 0.
     * @param hi the last element index of this subtree.  Initial should be
     *              size-1.
     * @param redLevel the level at which nodes should be red.
     *        Must be equal to computeRedLevel for tree of this size.
     */
    private static Entry buildFromSorted(int level, int lo, int hi,
                                         int redLevel,
                                         Iterator it,
                                         Object defaultVal)
        throws  java.io.IOException, ClassNotFoundException {
        /*
         * Strategy: The root is the middlemost element. To get to it, we
         * have to first recursively construct the entire left subtree,
         * so as to grab all of its elements. We can then proceed with right
         * subtree.
         *
         * The lo and hi arguments are the minimum and maximum
         * indices to pull out of the iterator or stream for current subtree.
         * They are not actually indexed, we just proceed sequentially,
         * ensuring that items are extracted in corresponding order.
         */

        if (hi < lo) return null;

        int mid = (lo + hi) / 2;

        Entry left  = null;
        if (lo < mid)
            left = buildFromSorted(level+1, lo, mid - 1, redLevel,
                                   it, defaultVal);

        // extract key and/or value from iterator or stream
        Object key;
        Object value;
        if (defaultVal==null) {
            Map.Entry entry = (Map.Entry) it.next();
            key = entry.getKey();
            value = entry.getValue();
        } else {
            key = it.next();
            value = defaultVal;
        }

        Entry middle =  new Entry(key, value, null);

        // color nodes in non-full bottommost level red
        if (level == redLevel)
            middle.color = RED;

        if (left != null) {
            middle.left = left;
            left.parent = middle;
        }

        if (mid < hi) {
            Entry right = buildFromSorted(level+1, mid+1, hi, redLevel,
                                          it, defaultVal);
            middle.right = right;
            right.parent = middle;
        }

        return middle;
    }

    /**
     * Find the level down to which to assign all nodes BLACK.  This is the
     * last `full' level of the complete binary tree produced by
     * buildTree. The remaining nodes are colored RED. (This makes a `nice'
     * set of color assignments wrt future insertions.) This level number is
     * computed by finding the number of splits needed to reach the zeroeth
     * node.  (The answer is ~lg(N), but in any case must be computed by same
     * quick O(lg(N)) loop.)
     */
    private static int computeRedLevel(int sz) {
        int level = 0;
        for (int m = sz - 1; m >= 0; m = m / 2 - 1)
            level++;
        return level;
    }
}
