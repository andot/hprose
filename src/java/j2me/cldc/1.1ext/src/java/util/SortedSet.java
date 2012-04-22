/*
 * @(#)SortedSet.java	1.18 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * A set that further guarantees that its iterator will traverse the set in
 * ascending element order, sorted according to the <i>natural ordering</i> of
 * its elements (see Comparable), or by a Comparator provided at sorted set
 * creation time.  Several additional operations are provided to take
 * advantage of the ordering.  (This interface is the set analogue of
 * SortedMap.)<p>
 *
 * All elements inserted into an sorted set must implement the Comparable
 * interface (or be accepted by the specified Comparator).  Furthermore, all
 * such elements must be <i>mutually comparable</i>: <tt>e1.compareTo(e2)</tt>
 * (or <tt>comparator.compare(e1, e2)</tt>) must not throw a
 * <tt>ClassCastException</tt> for any elements <tt>e1</tt> and <tt>e2</tt> in
 * the sorted set.  Attempts to violate this restriction will cause the
 * offending method or constructor invocation to throw a
 * <tt>ClassCastException</tt>.<p>
 *
 * Note that the ordering maintained by a sorted set (whether or not an
 * explicit comparator is provided) must be <i>consistent with equals</i> if
 * the sorted set is to correctly implement the <tt>Set</tt> interface.  (See
 * the <tt>Comparable</tt> interface or <tt>Comparator</tt> interface for a
 * precise definition of <i>consistent with equals</i>.)  This is so because
 * the <tt>Set</tt> interface is defined in terms of the <tt>equals</tt>
 * operation, but a sorted set performs all element comparisons using its
 * <tt>compareTo</tt> (or <tt>compare</tt>) method, so two elements that are
 * deemed equal by this method are, from the standpoint of the sorted set,
 * equal.  The behavior of a sorted set <i>is</i> well-defined even if its
 * ordering is inconsistent with equals; it just fails to obey the general
 * contract of the <tt>Set</tt> interface.<p>
 *
 * All general-purpose sorted set implementation classes should provide four
 * "standard" constructors: 1) A void (no arguments) constructor, which
 * creates an empty sorted set sorted according to the <i>natural order</i> of
 * its elements.  2) A constructor with a single argument of type
 * <tt>Comparator</tt>, which creates an empty sorted set sorted according to
 * the specified comparator.  3) A constructor with a single argument of type
 * <tt>Collection</tt>, which creates a new sorted set with the same elements
 * as its argument, sorted according to the elements' natural ordering.  4) A
 * constructor with a single argument of type <tt>SortedSet</tt>, which
 * creates a new sorted set with the same elements and the same ordering as
 * the input sorted set.  There is no way to enforce this recommendation (as
 * interfaces cannot contain constructors) but the SDK implementation (the
 * <tt>TreeSet</tt> class) complies.<p>
 *
 * This interface is a member of the 
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch
 * @version 1.18, 01/23/03
 * @see Set
 * @see TreeSet
 * @see SortedMap
 * @see Collection
 * @see Comparable
 * @see Comparator
 * @see java.lang.ClassCastException
 * @since 1.2
 */

public interface SortedSet extends Set {
    /**
     * Returns the comparator associated with this sorted set, or
     * <tt>null</tt> if it uses its elements' natural ordering.
     *
     * @return the comparator associated with this sorted set, or
     * 	       <tt>null</tt> if it uses its elements' natural ordering.
     */
    Comparator comparator();

    /**
     * Returns a view of the portion of this sorted set whose elements range
     * from <tt>fromElement</tt>, inclusive, to <tt>toElement</tt>, exclusive.
     * (If <tt>fromElement</tt> and <tt>toElement</tt> are equal, the returned
     * sorted set is empty.)  The returned sorted set is backed by this sorted
     * set, so changes in the returned sorted set are reflected in this sorted
     * set, and vice-versa.  The returned sorted set supports all optional set
     * operations that this sorted set supports.<p>
     *
     * The sorted set returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a
     * element outside the specified range.<p>
     * 
     * Note: this method always returns a <i>half-open range</i> (which
     * includes its low endpoint but not its high endpoint).  If you need a
     * <i>closed range</i> (which includes both endpoints), and the element
     * type allows for calculation of the successor a given value, merely
     * request the subrange from <tt>lowEndpoint</tt> to
     * <tt>successor(highEndpoint)</tt>.  For example, suppose that <tt>s</tt>
     * is a sorted set of strings.  The following idiom obtains a view
     * containing all of the strings in <tt>s</tt> from <tt>low</tt> to
     * <tt>high</tt>, inclusive: <pre>
     * SortedSet sub = s.subSet(low, high+"\0");
     * </pre>
     * 
     * A similar technique can be used to generate an <i>open range</i> (which
     * contains neither endpoint).  The following idiom obtains a view
     * containing all of the Strings in <tt>s</tt> from <tt>low</tt> to
     * <tt>high</tt>, exclusive: <pre>
     * SortedSet sub = s.subSet(low+"\0", high);
     * </pre>
     *
     * @param fromElement low endpoint (inclusive) of the subSet.
     * @param toElement high endpoint (exclusive) of the subSet.
     * @return a view of the specified range within this sorted set.
     * 
     * @throws ClassCastException if <tt>fromElement</tt> and
     *         <tt>toElement</tt> cannot be compared to one another using this
     *         set's comparator (or, if the set has no comparator, using
     *         natural ordering).  Implementations may, but are not required
     *	       to, throw this exception if <tt>fromElement</tt> or
     *         <tt>toElement</tt> cannot be compared to elements currently in
     *         the set.
     * @throws IllegalArgumentException if <tt>fromElement</tt> is greater than
     *         <tt>toElement</tt>; or if this set is itself a subSet, headSet,
     *         or tailSet, and <tt>fromElement</tt> or <tt>toElement</tt> are
     *         not within the specified range of the subSet, headSet, or
     *         tailSet.
     * @throws NullPointerException if <tt>fromElement</tt> or
     *	       <tt>toElement</tt> is <tt>null</tt> and this sorted set does
     *	       not tolerate <tt>null</tt> elements.
     */
    SortedSet subSet(Object fromElement, Object toElement);

    /**
     * Returns a view of the portion of this sorted set whose elements are
     * strictly less than <tt>toElement</tt>.  The returned sorted set is
     * backed by this sorted set, so changes in the returned sorted set are
     * reflected in this sorted set, and vice-versa.  The returned sorted set
     * supports all optional set operations.<p>
     *
     * The sorted set returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a
     * element outside the specified range.<p>
     *
     * Note: this method always returns a view that does not contain its
     * (high) endpoint.  If you need a view that does contain this endpoint,
     * and the element type allows for calculation of the successor a given
     * value, merely request a headSet bounded by
     * <tt>successor(highEndpoint)</tt>.  For example, suppose that <tt>s</tt>
     * is a sorted set of strings.  The following idiom obtains a view
     * containing all of the strings in <tt>s</tt> that are less than or equal
     * to <tt>high</tt>:
     * 	    <pre>    SortedSet head = s.headSet(high+"\0");</pre>
     *
     * @param toElement high endpoint (exclusive) of the headSet.
     * @return a view of the specified initial range of this sorted set.
     * @throws ClassCastException if <tt>toElement</tt> is not compatible
     *         with this set's comparator (or, if the set has no comparator,
     *         if <tt>toElement</tt> does not implement <tt>Comparable</tt>).
     *         Implementations may, but are not required to, throw this
     *	       exception if <tt>toElement</tt> cannot be compared to elements
     *         currently in the set.
     * @throws NullPointerException if <tt>toElement</tt> is <tt>null</tt> and
     *	       this sorted set does not tolerate <tt>null</tt> elements.
     * @throws IllegalArgumentException if this set is itself a subSet,
     *         headSet, or tailSet, and <tt>toElement</tt> is not within the
     *         specified range of the subSet, headSet, or tailSet.
     */
    SortedSet headSet(Object toElement);

    /**
     * Returns a view of the portion of this sorted set whose elements are
     * greater than or equal to <tt>fromElement</tt>.  The returned sorted set
     * is backed by this sorted set, so changes in the returned sorted set are
     * reflected in this sorted set, and vice-versa.  The returned sorted set
     * supports all optional set operations.<p>
     *
     * The sorted set returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a
     * element outside the specified range.<p>
     *
     * Note: this method always returns a view that contains its (low)
     * endpoint.  If you need a view that does not contain this endpoint, and
     * the element type allows for calculation of the successor a given value,
     * merely request a tailSet bounded by <tt>successor(lowEndpoint)</tt>.
     * For example, suppose that <tt>s</tt> is a sorted set of strings.  The
     * following idiom obtains a view containing all of the strings in
     * <tt>s</tt> that are strictly greater than <tt>low</tt>:
     * 
     * 	    <pre>    SortedSet tail = s.tailSet(low+"\0");</pre>
     *
     * @param fromElement low endpoint (inclusive) of the tailSet.
     * @return a view of the specified final range of this sorted set.
     * @throws ClassCastException if <tt>fromElement</tt> is not compatible
     *         with this set's comparator (or, if the set has no comparator,
     *         if <tt>fromElement</tt> does not implement <tt>Comparable</tt>).
     *         Implementations may, but are not required to, throw this
     *	       exception if <tt>fromElement</tt> cannot be compared to elements
     *         currently in the set.
     * @throws NullPointerException if <tt>fromElement</tt> is <tt>null</tt>
     *	       and this sorted set does not tolerate <tt>null</tt> elements.
     * @throws IllegalArgumentException if this set is itself a subSet,
     *         headSet, or tailSet, and <tt>fromElement</tt> is not within the
     *         specified range of the subSet, headSet, or tailSet.
     */
    SortedSet tailSet(Object fromElement);

    /**
     * Returns the first (lowest) element currently in this sorted set.
     *
     * @return the first (lowest) element currently in this sorted set.
     * @throws    NoSuchElementException sorted set is empty.
     */
    Object first();

    /**
     * Returns the last (highest) element currently in this sorted set.
     *
     * @return the last (highest) element currently in this sorted set.
     * @throws    NoSuchElementException sorted set is empty.
     */
    Object last();
}
