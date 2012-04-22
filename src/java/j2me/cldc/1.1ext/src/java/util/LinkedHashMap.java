/*
 * @(#)LinkedHashMap.java	1.11 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * <p>Hash table and linked list implementation of the <tt>Map</tt> interface,
 * with predictable iteration order.  This implementation differs from
 * <tt>HashMap</tt> in that it maintains a doubly-linked list running through
 * all of its entries.  This linked list defines the iteration ordering,
 * which is normally the order in which keys were inserted into the map
 * (<i>insertion-order</i>).  Note that insertion order is not affected
 * if a key is <i>re-inserted</i> into the map.  (A key <tt>k</tt> is
 * reinserted into a map <tt>m</tt> if <tt>m.put(k, v)</tt> is invoked when
 * <tt>m.containsKey(k)</tt> would return <tt>true</tt> immediately prior to
 * the invocation.)
 *
 * <p>This implementation spares its clients from the unspecified, generally
 * chaotic ordering provided by {@link HashMap} (and {@link Hashtable}),
 * without incurring the increased cost associated with {@link TreeMap}.  It
 * can be used to produce a copy of a map that has the same order as the
 * original, regardless of the original map's implementation:
 * <pre>
 *     void foo(Map m) {
 *         Map copy = new LinkedHashMap(m);
 *         ...
 *     }
 * </pre>
 * This technique is particularly useful if a module takes a map on input,
 * copies it, and later returns results whose order is determined by that of
 * the copy.  (Clients generally appreciate having things returned in the same
 * order they were presented.)
 *
 * <p>A special {@link #LinkedHashMap(int,float,boolean) constructor} is
 * provided to create a linked hash map whose order of iteration is the order
 * in which its entries were last accessed, from least-recently accessed to
 * most-recently (<i>access-order</i>).  This kind of map is well-suited to
 * building LRU caches.  Invoking the <tt>put</tt> or <tt>get</tt> method
 * results in an access to the corresponding entry (assuming it exists after
 * the invocation completes).  The <tt>putAll</tt> method generates one entry
 * access for each mapping in the specified map, in the order that key-value
 * mappings are provided by the specified map's entry set iterator.  <i>No
 * other methods generate entry accesses.</i> In particular, operations on
 * collection-views do <i>not</i> affect the order of iteration of the backing
 * map.
 *
 * <p>The {@link #removeEldestEntry(Map.Entry)} method may be overridden to 
 * impose a policy for removing stale mappings automatically when new mappings
 * are added to the map.
 *
 * <p>This class provides all of the optional <tt>Map</tt> operations, and
 * permits null elements.  Like <tt>HashMap</tt>, it provides constant-time
 * performance for the basic operations (<tt>add</tt>, <tt>contains</tt> and
 * <tt>remove</tt>), assuming the the hash function disperses elements
 * properly among the buckets.  Performance is likely to be just slightly
 * below that of <tt>HashMap</tt>, due to the added expense of maintaining the
 * linked list, with one exception: Iteration over the collection-views
 * of a <tt>LinkedHashMap</tt> requires time proportional to the <i>size</i>
 * of the map, regardless of its capacity.  Iteration over a <tt>HashMap</tt>
 * is likely to be more expensive, requiring time proportional to its
 * <i>capacity</i>.
 *
 * <p>A linked hash map has two parameters that affect its performance:
 * <i>initial capacity</i> and <i>load factor</i>.  They are defined precisely
 * as for <tt>HashMap</tt>.  Note, however, that the penalty for choosing an
 * excessively high value for initial capacity is less severe for this class
 * than for <tt>HashMap</tt>, as iteration times for this class are unaffected
 * by capacity.
 * 
 * <p><strong>Note that this implementation is not synchronized.</strong> If
 * multiple threads access a linked hash map concurrently, and at least
 * one of the threads modifies the map structurally, it <em>must</em> be
 * synchronized externally.  This is typically accomplished by synchronizing
 * on some object that naturally encapsulates the map.  If no such object
 * exists, the map should be "wrapped" using the
 * <tt>Collections.synchronizedMap</tt>method.  This is best done at creation
 * time, to prevent accidental unsynchronized access:
 * <pre>
 *    Map m = Collections.synchronizedMap(new LinkedHashMap(...));
 * </pre>
 * A structural modification is any operation that adds or deletes one or more
 * mappings or, in the case of access-ordered linked hash maps, affects
 * iteration order.  In insertion-ordered linked hash maps, merely changing
 * the value associated with a key that is already contained in the map is not
 * a structural modification.  <strong>In access-ordered linked hash maps,
 * merely querying the map with <tt>get</tt> is a structural
 * modification.</strong>)
 *
 * <p>The iterators returned by the <tt>iterator</tt> methods of the
 * collections returned by all of this class's collection view methods are
 * <em>fail-fast</em>: if the map is structurally modified at any time after
 * the iterator is created, in any way except through the iterator's own
 * remove method, the iterator will throw a
 * <tt>ConcurrentModificationException</tt>.  Thus, in the face of concurrent
 * modification, the Iterator fails quickly and cleanly, rather than risking
 * arbitrary, non-deterministic behavior at an undetermined time in the
 * future.
 *
 * <p>Note that the fail-fast behavior of an iterator cannot be guaranteed
 * as it is, generally speaking, impossible to make any hard guarantees in the
 * presence of unsynchronized concurrent modification.  Fail-fast iterators
 * throw <tt>ConcurrentModificationException</tt> on a best-effort basis. 
 * Therefore, it would be wrong to write a program that depended on this
 * exception for its correctness:   <i>the fail-fast behavior of iterators
 * should be used only to detect bugs.</i>
 *
 * <p>This class is a member of the 
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch
 * @version 1.11, 01/23/03
 * @see     Object#hashCode()
 * @see     Collection
 * @see     Map
 * @see     HashMap
 * @see     TreeMap
 * @see     Hashtable
 * @since   JDK1.4
 */

public class LinkedHashMap extends HashMap {
    /**
     * The head of the doubly linked list.
     */
    private transient Entry header;

    /**
     * The iteration ordering method for this linked hash map: <tt>true</tt>
     * for access-order, <tt>false</tt> for insertion-order.
     *
     * @serial
     */
    private final boolean accessOrder;

    /**
     * Constructs an empty insertion-ordered <tt>LinkedHashMap</tt> instance
     * with the specified initial capacity and load factor.
     *
     * @param  initialCapacity the initial capacity.
     * @param  loadFactor      the load factor.
     * @throws IllegalArgumentException if the initial capacity is negative
     *         or the load factor is nonpositive.
     */
    public LinkedHashMap(int initialCapacity, float loadFactor) {
        super(initialCapacity, loadFactor);
        accessOrder = false;
    }

    /**
     * Constructs an empty insertion-ordered <tt>LinkedHashMap</tt> instance
     * with the specified initial capacity and a default load factor (0.75). 
     *
     * @param  initialCapacity the initial capacity.
     * @throws IllegalArgumentException if the initial capacity is negative.
     */
    public LinkedHashMap(int initialCapacity) {
	super(initialCapacity);
        accessOrder = false;
    }

    /**
     * Constructs an empty insertion-ordered <tt>LinkedHashMap</tt> instance
     * with a default capacity (16) and load factor (0.75).
     */
    public LinkedHashMap() {
	super();
        accessOrder = false;
    }

    /**
     * Constructs an insertion-ordered <tt>LinkedHashMap</tt> instance with
     * the same mappings as the specified map.  The <tt>LinkedHashMap</tt>
     * instance is created with a a default load factor (0.75) and an initial
     * capacity sufficient to hold the mappings in the specified map.
     *
     * @param  m the map whose mappings are to be placed in this map.
     * @throws NullPointerException if the specified map is null.
     */
    public LinkedHashMap(Map m) {
        super(m);
        accessOrder = false;
    }

    /**
     * Constructs an empty <tt>LinkedHashMap</tt> instance with the
     * specified initial capacity, load factor and ordering mode.
     *
     * @param  initialCapacity the initial capacity.
     * @param  loadFactor      the load factor.
     * @param  accessOrder     the ordering mode - <tt>true</tt> for
     *         access-order, <tt>false</tt> for insertion-order.
     * @throws IllegalArgumentException if the initial capacity is negative
     *         or the load factor is nonpositive.
     */
    public LinkedHashMap(int initialCapacity, float loadFactor,
                         boolean accessOrder) {
        super(initialCapacity, loadFactor);
        this.accessOrder = accessOrder;
    }

    /**
     * Called by superclass constructors and pseudoconstructors (clone,
     * readObject) before any entries are inserted into the map.  Initializes
     * the chain.
     */
    void init() {
        header = new Entry(-1, null, null, null);
        header.before = header.after = header;
    }

    /**
     * Transfer all entries to new table array.  This method is called
     * by superclass resize.  It is overridden for performance, as it is
     * faster to iterate using our linked list.
     */
    void transfer(HashMap.Entry[] newTable) {
        int newCapacity = newTable.length;
        for (Entry e = header.after; e != header; e = e.after) {
            int index = indexFor(e.hash, newCapacity);
            e.next = newTable[index];
            newTable[index] = e;
        }
    }


    /**
     * Returns <tt>true</tt> if this map maps one or more keys to the
     * specified value.
     *
     * @param value value whose presence in this map is to be tested.
     * @return <tt>true</tt> if this map maps one or more keys to the
     *         specified value.
     */
    public boolean containsValue(Object value) {
        // Overridden to take advantage of faster iterator
        if (value==null) {
            for (Entry e = header.after; e != header; e = e.after)
                if (e.value==null)
                    return true;
        } else {
            for (Entry e = header.after; e != header; e = e.after)
                if (value.equals(e.value))
                    return true;
        }
        return false;
    }

    /**
     * Returns the value to which this map maps the specified key.  Returns
     * <tt>null</tt> if the map contains no mapping for this key.  A return
     * value of <tt>null</tt> does not <i>necessarily</i> indicate that the
     * map contains no mapping for the key; it's also possible that the map
     * explicitly maps the key to <tt>null</tt>.  The <tt>containsKey</tt>
     * operation may be used to distinguish these two cases.
     *
     * @return the value to which this map maps the specified key.
     * @param key key whose associated value is to be returned.
     */
    public Object get(Object key) {
        Entry e = (Entry)getEntry(key);
        if (e == null)
            return null;
        e.recordAccess(this);
        return e.value;
    }

    /**
     * Removes all mappings from this map.
     */
    public void clear() {
        super.clear();
        header.before = header.after = header;
    }

    /**
     * LinkedHashMap entry.
     */
    private static class Entry extends HashMap.Entry {
        // These fields comprise the doubly linked list used for iteration.
        Entry before, after;

	Entry(int hash, Object key, Object value, HashMap.Entry next) {
            super(hash, key, value, next);
        }

        /**
         * Remove this entry from the linked list.
         */
        private void remove() {
            before.after = after;
            after.before = before;
        }

        /**                                             
         * Insert this entry before the specified existing entry in the list.
         */
        private void addBefore(Entry existingEntry) {
            after  = existingEntry;
            before = existingEntry.before;
            before.after = this;
            after.before = this;
        }

        /**
         * This method is invoked by the superclass whenever the value
         * of a pre-existing entry is read by Map.get or modified by Map.set.
         * If the enclosing Map is access-ordered, it moves the entry
         * to the end of the list; otherwise, it does nothing. 
         */
        void recordAccess(HashMap m) {
            LinkedHashMap lm = (LinkedHashMap)m;
            if (lm.accessOrder) {
                lm.modCount++;
                remove();
                addBefore(lm.header);
            }
        }

        void recordRemoval(HashMap m) {
            remove();
        }
    }

    private abstract class LinkedHashIterator implements Iterator {
	Entry nextEntry    = header.after;
	Entry lastReturned = null;

	/**
	 * The modCount value that the iterator believes that the backing
	 * List should have.  If this expectation is violated, the iterator
	 * has detected concurrent modification.
	 */
	int expectedModCount = modCount;

	public boolean hasNext() {
            return nextEntry != header;
	}

	public void remove() {
	    if (lastReturned == null)
		throw new IllegalStateException();
	    if (modCount != expectedModCount)
		throw new ConcurrentModificationException();

            LinkedHashMap.this.remove(lastReturned.key);
            lastReturned = null;
            expectedModCount = modCount;
	}

	Entry nextEntry() {
	    if (modCount != expectedModCount)
		throw new ConcurrentModificationException();
            if (nextEntry == header)
                throw new NoSuchElementException();

            Entry e = lastReturned = nextEntry;
            nextEntry = e.after;
            return e;
	}
    }

    private class KeyIterator extends LinkedHashIterator {
	public Object next() { return nextEntry().getKey(); }
    }

    private class ValueIterator extends LinkedHashIterator {
	public Object next() { return nextEntry().value; }
    }

    private class EntryIterator extends LinkedHashIterator {
	public Object next() { return nextEntry(); }
    }

    // These Overrides alter the behavior of superclass view iterator() methods
    Iterator newKeyIterator()   { return new KeyIterator();   }
    Iterator newValueIterator() { return new ValueIterator(); }
    Iterator newEntryIterator() { return new EntryIterator(); }

    /**
     * This override alters behavior of superclass put method. It causes newly
     * allocated entry to get inserted at the end of the linked list and
     * removes the eldest entry if appropriate.
     */
    void addEntry(int hash, Object key, Object value, int bucketIndex) {
        createEntry(hash, key, value, bucketIndex);

        // Remove eldest entry if instructed, else grow capacity if appropriate
        Entry eldest = header.after;
        if (removeEldestEntry(eldest)) {
            removeEntryForKey(eldest.key);
        } else {
            if (size >= threshold) 
                resize(2 * table.length);
        }
    }

    /**
     * This override differs from addEntry in that it doesn't resize the
     * table or remove the eldest entry.
     */
    void createEntry(int hash, Object key, Object value, int bucketIndex) {
        Entry e = new Entry(hash, key, value, table[bucketIndex]);
        table[bucketIndex] = e;
        e.addBefore(header);
        size++;
    }

    /**
     * Returns <tt>true</tt> if this map should remove its eldest entry.
     * This method is invoked by <tt>put</tt> and <tt>putAll</tt> after
     * inserting a new entry into the map.  It provides the implementer
     * with the opportunity to remove the eldest entry each time a new one
     * is added.  This is useful if the map represents a cache: it allows
     * the map to reduce memory consumption by deleting stale entries.
     *
     * <p>Sample use: this override will allow the map to grow up to 100
     * entries and then delete the eldest entry each time a new entry is
     * added, maintaining a steady state of 100 entries.
     * <pre>
     *     private static final int MAX_ENTRIES = 100;
     *
     *     protected boolean removeEldestEntry(Map.Entry eldest) {
     *        return size() > MAX_ENTRIES;
     *     }
     * </pre>
     *
     * <p>This method typically does not modify the map in any way,
     * instead allowing the map to modify itself as directed by its
     * return value.  It <i>is</i> permitted for this method to modify
     * the map directly, but if it does so, it <i>must</i> return
     * <tt>false</tt> (indicating that the map should not attempt any
     * further modification).  The effects of returning <tt>true</tt>
     * after modifying the map from within this method are unspecified.
     *
     * <p>This implementation merely returns <tt>false</tt> (so that this
     * map acts like a normal map - the eldest element is never removed).
     *
     * @param    eldest The least recently inserted entry in the map, or if 
     *           this is an access-ordered map, the least recently accessed
     *           entry.  This is the entry that will be removed it this
     *           method returns <tt>true</tt>.  If the map was empty prior
     *           to the <tt>put</tt> or <tt>putAll</tt> invocation resulting
     *           in this invocation, this will be the entry that was just
     *           inserted; in other words, if the map contains a single
     *           entry, the eldest entry is also the newest.
     * @return   <tt>true</tt> if the eldest entry should be removed
     *           from the map; <tt>false</t> if it should be retained.
     */
    protected boolean removeEldestEntry(Map.Entry eldest) {
        return false;
    }
}
