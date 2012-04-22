/*
 * @(#)SortedMap.java	1.15 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * A map that further guarantees that it will be in ascending key order,
 * sorted according to the <i>natural ordering</i> of its keys (see the
 * <tt>Comparable</tt> interface), or by a comparator provided at sorted map
 * creation time.  This order is reflected when iterating over the sorted
 * map's collection views (returned by the <tt>entrySet</tt>, <tt>keySet</tt>
 * and <tt>values</tt> methods).  Several additional operations are provided
 * to take advantage of the ordering.  (This interface is the map analogue of
 * the <tt>SortedSet</tt> interface.)<p>
 *
 * All keys inserted into a sorted map must implement the <tt>Comparable</tt>
 * interface (or be accepted by the specified comparator).  Furthermore, all
 * such keys must be <i>mutually comparable</i>: <tt>k1.compareTo(k2)</tt> (or
 * <tt>comparator.compare(k1, k2)</tt>) must not throw a
 * <tt>ClassCastException</tt> for any elements <tt>k1</tt> and <tt>k2</tt> in
 * the sorted map.  Attempts to violate this restriction will cause the
 * offending method or constructor invocation to throw a
 * <tt>ClassCastException</tt>.<p>
 *
 * Note that the ordering maintained by a sorted map (whether or not an
 * explicit comparator is provided) must be <i>consistent with equals</i> if
 * the sorted map is to correctly implement the <tt>Map</tt> interface.  (See
 * the <tt>Comparable</tt> interface or <tt>Comparator</tt> interface for a
 * precise definition of <i>consistent with equals</i>.)  This is so because
 * the <tt>Map</tt> interface is defined in terms of the <tt>equals</tt>
 * operation, but a sorted map performs all key comparisons using its
 * <tt>compareTo</tt> (or <tt>compare</tt>) method, so two keys that are
 * deemed equal by this method are, from the standpoint of the sorted map,
 * equal.  The behavior of a tree map <i>is</i> well-defined even if its
 * ordering is inconsistent with equals; it just fails to obey the general
 * contract of the <tt>Map</tt> interface.<p>
 *
 * All general-purpose sorted map implementation classes should provide four
 * "standard" constructors: 1) A void (no arguments) constructor, which
 * creates an empty sorted map sorted according to the <i>natural order</i> of
 * its keys.  2) A constructor with a single argument of type
 * <tt>Comparator</tt>, which creates an empty sorted map sorted according to
 * the specified comparator.  3) A constructor with a single argument of type
 * <tt>Map</tt>, which creates a new map with the same key-value mappings as
 * its argument, sorted according to the keys' natural ordering.  4) A
 * constructor with a single argument of type sorted map, which creates a new
 * sorted map with the same key-value mappings and the same ordering as the
 * input sorted map.  There is no way to enforce this recommendation (as
 * interfaces cannot contain constructors) but the SDK implementation
 * (TreeMap) complies.<p>
 *
 * This interface is a member of the 
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch
 * @version 1.15, 01/23/03
 * @see Map
 * @see TreeMap
 * @see SortedSet
 * @see Comparator
 * @see Comparable
 * @see Collection
 * @see ClassCastException
 * @since 1.2
 */

public interface SortedMap extends Map {
    /**
     * Returns the comparator associated with this sorted map, or
     * <tt>null</tt> if it uses its keys' natural ordering.
     *
     * @return the comparator associated with this sorted map, or
     * 	       <tt>null</tt> if it uses its keys' natural ordering.
     */
    Comparator comparator();

    /**
     * Returns a view of the portion of this sorted map whose keys range from
     * <tt>fromKey</tt>, inclusive, to <tt>toKey</tt>, exclusive.  (If
     * <tt>fromKey</tt> and <tt>toKey</tt> are equal, the returned sorted map
     * is empty.)  The returned sorted map is backed by this sorted map, so
     * changes in the returned sorted map are reflected in this sorted map,
     * and vice-versa.  The returned Map supports all optional map operations
     * that this sorted map supports.<p>
     *
     * The map returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a key
     * outside the specified range.<p>
     *
     * Note: this method always returns a <i>half-open range</i> (which
     * includes its low endpoint but not its high endpoint).  If you need a
     * <i>closed range</i> (which includes both endpoints), and the key type
     * allows for calculation of the successor a given key, merely request the
     * subrange from <tt>lowEndpoint</tt> to <tt>successor(highEndpoint)</tt>.
     * For example, suppose that <tt>m</tt> is a map whose keys are strings.
     * The following idiom obtains a view containing all of the key-value
     * mappings in <tt>m</tt> whose keys are between <tt>low</tt> and
     * <tt>high</tt>, inclusive:
     * 
     * 	    <pre>    Map sub = m.subMap(low, high+"\0");</pre>
     * 
     * A similarly technique can be used to generate an <i>open range</i>
     * (which contains neither endpoint).  The following idiom obtains a
     * view containing  all of the key-value mappings in <tt>m</tt> whose keys
     * are between <tt>low</tt> and <tt>high</tt>, exclusive:
     * 
     * 	    <pre>    Map sub = m.subMap(low+"\0", high);</pre>
     *
     * @param fromKey low endpoint (inclusive) of the subMap.
     * @param toKey high endpoint (exclusive) of the subMap.
     * @return a view of the specified range within this sorted map.
     * 
     * @throws ClassCastException if <tt>fromKey</tt> and <tt>toKey</tt>
     *         cannot be compared to one another using this map's comparator
     *         (or, if the map has no comparator, using natural ordering).
     *         Implementations may, but are not required to, throw this
     *	       exception if <tt>fromKey</tt> or <tt>toKey</tt>
     *         cannot be compared to keys currently in the map.
     * @throws IllegalArgumentException if <tt>fromKey</tt> is greater than
     *         <tt>toKey</tt>; or if this map is itself a subMap, headMap,
     *         or tailMap, and <tt>fromKey</tt> or <tt>toKey</tt> are not
     *         within the specified range of the subMap, headMap, or tailMap.
     * @throws NullPointerException if <tt>fromKey</tt> or <tt>toKey</tt> is
     *	       <tt>null</tt> and this sorted map does not tolerate
     *	       <tt>null</tt> keys.
     */
    SortedMap subMap(Object fromKey, Object toKey);

    /**
     * Returns a view of the portion of this sorted map whose keys are
     * strictly less than toKey.  The returned sorted map is backed by this
     * sorted map, so changes in the returned sorted map are reflected in this
     * sorted map, and vice-versa.  The returned map supports all optional map
     * operations that this sorted map supports.<p>
     *
     * The map returned by this method will throw an IllegalArgumentException
     * if the user attempts to insert a key outside the specified range.<p>
     *
     * Note: this method always returns a view that does not contain its
     * (high) endpoint.  If you need a view that does contain this endpoint,
     * and the key type allows for calculation of the successor a given
     * key, merely request a headMap bounded by successor(highEndpoint).
     * For example, suppose that suppose that <tt>m</tt> is a map whose keys
     * are strings.  The following idiom obtains a view containing all of the
     * key-value mappings in <tt>m</tt> whose keys are less than or equal to
     * <tt>high</tt>:
     * 
     * 	    <pre>    Map head = m.headMap(high+"\0");</pre>
     *
     * @param toKey high endpoint (exclusive) of the subMap.
     * @return a view of the specified initial range of this sorted map.
     * @throws ClassCastException if <tt>toKey</tt> is not compatible
     *         with this map's comparator (or, if the map has no comparator,
     *         if <tt>toKey</tt> does not implement <tt>Comparable</tt>).
     *         Implementations may, but are not required to, throw this
     *	       exception if <tt>toKey</tt> cannot be compared to keys
     *         currently in the map.
     * @throws IllegalArgumentException if this map is itself a subMap,
     *         headMap, or tailMap, and <tt>toKey</tt> is not within the
     *         specified range of the subMap, headMap, or tailMap.
     * @throws NullPointerException if <tt>toKey</tt> is <tt>null</tt> and
     *	       this sorted map does not tolerate <tt>null</tt> keys.
     */
    SortedMap headMap(Object toKey);

    /**
     * Returns a view of the portion of this sorted map whose keys are greater
     * than or equal to <tt>fromKey</tt>.  The returned sorted map is backed
     * by this sorted map, so changes in the returned sorted map are reflected
     * in this sorted map, and vice-versa.  The returned map supports all
     * optional map operations that this sorted map supports.<p>
     *
     * The map returned by this method will throw an
     * <tt>IllegalArgumentException</tt> if the user attempts to insert a key
     * outside the specified range.<p>
     *
     * Note: this method always returns a view that contains its (low)
     * endpoint.  If you need a view that does not contain this endpoint, and
     * the element type allows for calculation of the successor a given value,
     * merely request a tailMap bounded by <tt>successor(lowEndpoint)</tt>.
     * For example, suppose that suppose that <tt>m</tt> is a map whose keys
     * are strings.  The following idiom obtains a view containing all of the
     * key-value mappings in <tt>m</tt> whose keys are strictly greater than
     * <tt>low</tt>:
     * 
     * 	    <pre>    Map tail = m.tailMap(low+"\0");</pre>
     *
     * @param fromKey low endpoint (inclusive) of the tailMap.
     * @return a view of the specified final range of this sorted map.
     * @throws ClassCastException if <tt>fromKey</tt> is not compatible
     *         with this map's comparator (or, if the map has no comparator,
     *         if <tt>fromKey</tt> does not implement <tt>Comparable</tt>).
     *         Implementations may, but are not required to, throw this
     *	       exception if <tt>fromKey</tt> cannot be compared to keys
     *         currently in the map.
     * @throws IllegalArgumentException if this map is itself a subMap,
     *         headMap, or tailMap, and <tt>fromKey</tt> is not within the
     *         specified range of the subMap, headMap, or tailMap.
     * @throws NullPointerException if <tt>fromKey</tt> is <tt>null</tt> and
     *	       this sorted map does not tolerate <tt>null</tt> keys.
     */
    SortedMap tailMap(Object fromKey);

    /**
     * Returns the first (lowest) key currently in this sorted map.
     *
     * @return the first (lowest) key currently in this sorted map.
     * @throws    NoSuchElementException if this map is empty.
     */
    Object firstKey();

    /**
     * Returns the last (highest) key currently in this sorted map.
     *
     * @return the last (highest) key currently in this sorted map.
     * @throws     NoSuchElementException if this map is empty.
     */
    Object lastKey();
}
