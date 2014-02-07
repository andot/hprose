/*
 * @(#)TreeSet.java	1.26 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * This class implements the <tt>Set</tt> interface, backed by a
 * <tt>TreeMap</tt> instance.  This class guarantees that the sorted set will
 * be in ascending element order, sorted according to the <i>natural order</i>
 * of the elements (see <tt>Comparable</tt>), or by the comparator provided at
 * set creation time, depending on which constructor is used.<p>
 *
 * This implementation provides guaranteed log(n) time cost for the basic
 * operations (<tt>add</tt>, <tt>remove</tt> and <tt>contains</tt>).<p>
 *
 * Note that the ordering maintained by a set (whether or not an explicit
 * comparator is provided) must be <i>consistent with equals</i> if it is to
 * correctly implement the <tt>Set</tt> interface.  (See <tt>Comparable</tt>
 * or <tt>Comparator</tt> for a precise definition of <i>consistent with
 * equals</i>.)  This is so because the <tt>Set</tt> interface is defined in
 * terms of the <tt>equals</tt> operation, but a <tt>TreeSet</tt> instance
 * performs all key comparisons using its <tt>compareTo</tt> (or
 * <tt>compare</tt>) method, so two keys that are deemed equal by this method
 * are, from the standpoint of the set, equal.  The behavior of a set
 * <i>is</i> well-defined even if its ordering is inconsistent with equals; it
 * just fails to obey the general contract of the <tt>Set</tt> interface.<p>
 *
 * <b>Note that this implementation is not synchronized.</b> If multiple
 * threads access a set concurrently, and at least one of the threads modifies
 * the set, it <i>must</i> be synchronized externally.  This is typically
 * accomplished by synchronizing on some object that naturally encapsulates
 * the set.  If no such object exists, the set should be "wrapped" using the
 * <tt>Collections.synchronizedSet</tt> method.  This is best done at creation
 * time, to prevent accidental unsynchronized access to the set: <pre>
 *     SortedSet s = Collections.synchronizedSortedSet(new TreeSet(...));
 * </pre><p>
 *
 * The Iterators returned by this class's <tt>iterator</tt> method are
 * <i>fail-fast</i>: if the set is modified at any time after the iterator is
 * created, in any way except through the iterator's own <tt>remove</tt>
 * method, the iterator will throw a <tt>ConcurrentModificationException</tt>.
 * Thus, in the face of concurrent modification, the iterator fails quickly
 * and cleanly, rather than risking arbitrary, non-deterministic behavior at
 * an undetermined time in the future.
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
 * @author  Josh Bloch
 * @version 1.26, 01/23/03
 * @see	    Collection
 * @see	    Set
 * @see	    HashSet
 * @see     Comparable
 * @see     Comparator
 * @see	    Collections#synchronizedSortedSet(SortedSet)
 * @see	    TreeMap
 * @since   1.2
 */

public class TreeSet extends AbstractSet implements SortedSet {
    private transient SortedMap m;	 // The backing Map
    private transient Set      	keySet;  // The keySet view of the backing Map

    // Dummy value to associate with an Object in the backing Map
    private static final Object PRESENT = new Object();

    /**
     * Constructs a set backed by the specified sorted map.
     */
    private TreeSet(SortedMap m) {
        this.m = m;
        keySet = m.keySet();
    }

    /**
     * Constructs a new, empty set, sorted according to the elements' natural
     * order.  All elements inserted into the set must implement the
     * <tt>Comparable</tt> interface.  Furthermore, all such elements must be
     * <i>mutually comparable</i>: <tt>e1.compareTo(e2)</tt> must not throw a
     * <tt>ClassCastException</tt> for any elements <tt>e1</tt> and
     * <tt>e2</tt> in the set.  If the user attempts to add an element to the
     * set that violates this constraint (for example, the user attempts to
     * add a string element to a set whose elements are integers), the
     * <tt>add(Object)</tt> call will throw a <tt>ClassCastException</tt>.
     *
     * @see Comparable
     */
    public TreeSet() {
	this(new TreeMap());
    }

    /**
     * Constructs a new, empty set, sorted according to the specified
     * comparator.  All elements inserted into the set must be <i>mutually
     * comparable</i> by the specified comparator: <tt>comparator.compare(e1,
     * e2)</tt> must not throw a <tt>ClassCastException</tt> for any elements
     * <tt>e1</tt> and <tt>e2</tt> in the set.  If the user attempts to add
     * an element to the set that violates this constraint, the
     * <tt>add(Object)</tt> call will throw a <tt>ClassCastException</tt>.
     *
     * @param c the comparator that will be used to sort this set.  A
     *        <tt>null</tt> value indicates that the elements' <i>natural
     *        ordering</i> should be used.
     */
    public TreeSet(Comparator c) {
	this(new TreeMap(c));
    }

    /**
     * Constructs a new set containing the elements in the specified
     * collection, sorted according to the elements' <i>natural order</i>.
     * All keys inserted into the set must implement the <tt>Comparable</tt>
     * interface.  Furthermore, all such keys must be <i>mutually
     * comparable</i>: <tt>k1.compareTo(k2)</tt> must not throw a
     * <tt>ClassCastException</tt> for any elements <tt>k1</tt> and
     * <tt>k2</tt> in the set.
     *
     * @param c The elements that will comprise the new set.
     *
     * @throws ClassCastException if the keys in the specified collection are
     *         not comparable, or are not mutually comparable.
     * @throws NullPointerException if the specified collection is null.
     */
    public TreeSet(Collection c) {
        this();
        addAll(c);
    }

    /**
     * Constructs a new set containing the same elements as the specified
     * sorted set, sorted according to the same ordering.
     *
     * @param s sorted set whose elements will comprise the new set.
     * @throws NullPointerException if the specified sorted set is null.
     */
    public TreeSet(SortedSet s) {
        this(s.comparator());
	addAll(s);
    }

    /**
     * Returns an iterator over the elements in this set.  The elements
     * are returned in ascending order.
     *
     * @return an iterator over the elements in this set.
     */
    public Iterator iterator() {
	return keySet.iterator();
    }

    /**
     * Returns the number of elements in this set (its cardinality).
     *
     * @return the number of elements in this set (its cardinality).
     */
    public int size() {
	return m.size();
    }

    /**
     * Returns <tt>true</tt> if this set contains no elements.
     *
     * @return <tt>true</tt> if this set contains no elements.
     */
    public boolean isEmpty() {
	return m.isEmpty();
    }

    /**
     * Returns <tt>true</tt> if this set contains the specified element.
     *
     * @param o the object to be checked for containment in this set.
     * @return <tt>true</tt> if this set contains the specified element.
     *
     * @throws ClassCastException if the specified object cannot be compared
     * 		  with the elements currently in the set.
     */
    public boolean contains(Object o) {
	return m.containsKey(o);
    }

    /**
     * Adds the specified element to this set if it is not already present.
     *
     * @param o element to be added to this set.
     * @return <tt>true</tt> if the set did not already contain the specified
     *         element.
     *
     * @throws ClassCastException if the specified object cannot be compared
     * 		  with the elements currently in the set.
     */
    public boolean add(Object o) {
	return m.put(o, PRESENT)==null;
    }

    /**
     * Removes the specified element from this set if it is present.
     *
     * @param o object to be removed from this set, if present.
     * @return <tt>true</tt> if the set contained the specified element.
     *
     * @throws ClassCastException if the specified object cannot be compared
     * 		  with the elements currently in the set.
     */
    public boolean remove(Object o) {
	return m.remove(o)==PRESENT;
    }

    /**
     * Removes all of the elements from this set.
     */
    public void clear() {
	m.clear();
    }

    /**
     * Adds all of the elements in the specified collection to this set.
     *
     * @param c elements to be added
     * @return <tt>true</tt> if this set changed as a result of the call.
     *
     * @throws ClassCastException if the elements provided cannot be compared
     *		  with the elements currently in the set.
     * @throws NullPointerException of the specified collection is null.
     */
    public boolean addAll(Collection c) {
        // Use linear-time version if applicable
        if (m.size()==0 && c.size() > 0 && c instanceof SortedSet &&
            m instanceof TreeMap) {
            SortedSet set = (SortedSet)c;
            TreeMap map = (TreeMap)m;
            Comparator cc = set.comparator();
            Comparator mc = map.comparator();
            if (cc==mc || (cc != null && cc.equals(mc))) {
                map.addAllForTreeSet(set, PRESENT);
                return true;
            }
        }
        return super.addAll(c);
    }

    /**
     * Returns a view of the portion of this set whose elements range from
     * <tt>fromElement</tt>, inclusive, to <tt>toElement</tt>, exclusive.  (If
     * <tt>fromElement</tt> and <tt>toElement</tt> are equal, the returned
     * sorted set is empty.)  The returned sorted set is backed by this set,
     * so changes in the returned sorted set are reflected in this set, and
     * vice-versa.  The returned sorted set supports all optional Set
     * operations.<p>
     *
     * The sorted set returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert an
     * element outside the specified range.<p>
     *
     * Note: this method always returns a <i>half-open range</i> (which
     * includes its low endpoint but not its high endpoint).  If you need a
     * <i>closed range</i> (which includes both endpoints), and the element
     * type allows for calculation of the successor of a specified value,
     * merely request the subrange from <tt>lowEndpoint</tt> to
     * <tt>successor(highEndpoint)</tt>.  For example, suppose that <tt>s</tt>
     * is a sorted set of strings.  The following idiom obtains a view
     * containing all of the strings in <tt>s</tt> from <tt>low</tt> to
     * <tt>high</tt>, inclusive: <pre>
     *     SortedSet sub = s.subSet(low, high+"\0");
     * </pre>
     *
     * A similar technique can be used to generate an <i>open range</i> (which
     * contains neither endpoint).  The following idiom obtains a view
     * containing all of the strings in <tt>s</tt> from <tt>low</tt> to
     * <tt>high</tt>, exclusive: <pre>
     *     SortedSet sub = s.subSet(low+"\0", high);
     * </pre>
     *
     * @param fromElement low endpoint (inclusive) of the subSet.
     * @param toElement high endpoint (exclusive) of the subSet.
     * @return a view of the portion of this set whose elements range from
     * 	       <tt>fromElement</tt>, inclusive, to <tt>toElement</tt>,
     * 	       exclusive.
     * @throws ClassCastException if <tt>fromElement</tt> and
     *         <tt>toElement</tt> cannot be compared to one another using
     *         this set's comparator (or, if the set has no comparator,
     *         using natural ordering).
     * @throws IllegalArgumentException if <tt>fromElement</tt> is greater than
     *         <tt>toElement</tt>.
     * @throws NullPointerException if <tt>fromElement</tt> or
     *	       <tt>toElement</tt> is <tt>null</tt> and this set uses natural
     *	       order, or its comparator does not tolerate <tt>null</tt>
     *         elements.
     */
    public SortedSet subSet(Object fromElement, Object toElement) {
	return new TreeSet(m.subMap(fromElement, toElement));
    }

    /**
     * Returns a view of the portion of this set whose elements are strictly
     * less than <tt>toElement</tt>.  The returned sorted set is backed by
     * this set, so changes in the returned sorted set are reflected in this
     * set, and vice-versa.  The returned sorted set supports all optional set
     * operations.<p>
     *
     * The sorted set returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert an
     * element greater than or equal to <tt>toElement</tt>.<p>
     *
     * Note: this method always returns a view that does not contain its
     * (high) endpoint.  If you need a view that does contain this endpoint,
     * and the element type allows for calculation of the successor of a
     * specified value, merely request a headSet bounded by
     * <tt>successor(highEndpoint)</tt>.  For example, suppose that <tt>s</tt>
     * is a sorted set of strings.  The following idiom obtains a view
     * containing all of the strings in <tt>s</tt> that are less than or equal
     * to <tt>high</tt>: <pre> SortedSet head = s.headSet(high+"\0");</pre>
     *
     * @param toElement high endpoint (exclusive) of the headSet.
     * @return a view of the portion of this set whose elements are strictly
     * 	       less than toElement.
     * @throws ClassCastException if <tt>toElement</tt> is not compatible
     *         with this set's comparator (or, if the set has no comparator,
     *         if <tt>toElement</tt> does not implement <tt>Comparable</tt>).
     * @throws IllegalArgumentException if this set is itself a subSet,
     *         headSet, or tailSet, and <tt>toElement</tt> is not within the
     *         specified range of the subSet, headSet, or tailSet.
     * @throws NullPointerException if <tt>toElement</tt> is <tt>null</tt> and
     *	       this set uses natural ordering, or its comparator does
     *         not tolerate <tt>null</tt> elements.
     */
    public SortedSet headSet(Object toElement) {
	return new TreeSet(m.headMap(toElement));
    }

    /**
     * Returns a view of the portion of this set whose elements are
     * greater than or equal to <tt>fromElement</tt>.  The returned sorted set
     * is backed by this set, so changes in the returned sorted set are
     * reflected in this set, and vice-versa.  The returned sorted set
     * supports all optional set operations.<p>
     *
     * The sorted set returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert an
     * element less than <tt>fromElement</tt>.
     *
     * Note: this method always returns a view that contains its (low)
     * endpoint.  If you need a view that does not contain this endpoint, and
     * the element type allows for calculation of the successor of a specified
     * value, merely request a tailSet bounded by
     * <tt>successor(lowEndpoint)</tt>.  For example, suppose that <tt>s</tt>
     * is a sorted set of strings.  The following idiom obtains a view
     * containing all of the strings in <tt>s</tt> that are strictly greater
     * than <tt>low</tt>: <pre>
     *     SortedSet tail = s.tailSet(low+"\0");
     * </pre>
     *
     * @param fromElement low endpoint (inclusive) of the tailSet.
     * @return a view of the portion of this set whose elements are
     * 	       greater than or equal to <tt>fromElement</tt>.
     * @throws ClassCastException if <tt>fromElement</tt> is not compatible
     *         with this set's comparator (or, if the set has no comparator,
     *         if <tt>fromElement</tt> does not implement <tt>Comparable</tt>).
     * @throws IllegalArgumentException if this set is itself a subSet,
     *         headSet, or tailSet, and <tt>fromElement</tt> is not within the
     *         specified range of the subSet, headSet, or tailSet.
     * @throws NullPointerException if <tt>fromElement</tt> is <tt>null</tt>
     *	       and this set uses natural ordering, or its comparator does
     *         not tolerate <tt>null</tt> elements.
     */
    public SortedSet tailSet(Object fromElement) {
	return new TreeSet(m.tailMap(fromElement));
    }

    /**
     * Returns the comparator used to order this sorted set, or <tt>null</tt>
     * if this tree set uses its elements natural ordering.
     *
     * @return the comparator used to order this sorted set, or <tt>null</tt>
     * if this tree set uses its elements natural ordering.
     */
    public Comparator comparator() {
        return m.comparator();
    }

    /**
     * Returns the first (lowest) element currently in this sorted set.
     *
     * @return the first (lowest) element currently in this sorted set.
     * @throws    NoSuchElementException sorted set is empty.
     */
    public Object first() {
        return m.firstKey();
    }

    /**
     * Returns the last (highest) element currently in this sorted set.
     *
     * @return the last (highest) element currently in this sorted set.
     * @throws    NoSuchElementException sorted set is empty.
     */
    public Object last() {
        return m.lastKey();
    }
}
