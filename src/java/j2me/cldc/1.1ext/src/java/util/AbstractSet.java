/*
 * @(#)AbstractSet.java	1.19 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * This class provides a skeletal implementation of the <tt>Set</tt>
 * interface to minimize the effort required to implement this
 * interface. <p>
 *
 * The process of implementing a set by extending this class is identical
 * to that of implementing a Collection by extending AbstractCollection,
 * except that all of the methods and constructors in subclasses of this
 * class must obey the additional constraints imposed by the <tt>Set</tt>
 * interface (for instance, the add method must not permit addition of
 * multiple intances of an object to a set).<p>
 *
 * Note that this class does not override any of the implementations from
 * the <tt>AbstractCollection</tt> class.  It merely adds implementations
 * for <tt>equals</tt> and <tt>hashCode</tt>.<p>
 *
 * This class is a member of the 
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch
 * @version 1.19, 01/23/03
 * @see Collection
 * @see AbstractCollection
 * @see Set
 * @since 1.2
 */

public abstract class AbstractSet extends AbstractCollection implements Set {
    /**
     * Sole constructor.  (For invocation by subclass constructors, typically
     * implicit.)
     */
    protected AbstractSet() {
    }

    // Comparison and hashing

    /**
     * Compares the specified object with this set for equality.  Returns
     * <tt>true</tt> if the given object is also a set, the two sets have
     * the same size, and every member of the given set is contained in
     * this set.  This ensures that the <tt>equals</tt> method works
     * properly across different implementations of the <tt>Set</tt>
     * interface.<p>
     *
     * This implementation first checks if the specified object is this
     * set; if so it returns <tt>true</tt>.  Then, it checks if the
     * specified object is a set whose size is identical to the size of
     * this set; if not, it it returns false.  If so, it returns
     * <tt>containsAll((Collection) o)</tt>.
     *
     * @param o Object to be compared for equality with this set.
     * @return <tt>true</tt> if the specified object is equal to this set.
     */
    public boolean equals(Object o) {
	if (o == this)
	    return true;

	if (!(o instanceof Set))
	    return false;
	Collection c = (Collection) o;
	if (c.size() != size())
	    return false;
        try {
            return containsAll(c);
        } catch(ClassCastException unused)   {
            return false;
        } catch(NullPointerException unused) {
            return false;
        }
    }

    /**
     * Returns the hash code value for this set.  The hash code of a set is
     * defined to be the sum of the hash codes of the elements in the set.
     * This ensures that <tt>s1.equals(s2)</tt> implies that
     * <tt>s1.hashCode()==s2.hashCode()</tt> for any two sets <tt>s1</tt>
     * and <tt>s2</tt>, as required by the general contract of
     * Object.hashCode.<p>
     *
     * This implementation enumerates over the set, calling the
     * <tt>hashCode</tt> method on each element in the collection, and
     * adding up the results.
     *
     * @return the hash code value for this set.
     */
    public int hashCode() {
	int h = 0;
	Iterator i = iterator();
	while (i.hasNext()) {
	    Object obj = i.next();
            if (obj != null)
                h += obj.hashCode();
        }
	return h;
    }

    /**
     * Removes from this set all of its elements that are contained in
     * the specified collection (optional operation).<p>
     *
     * This implementation determines which is the smaller of this set
     * and the specified collection, by invoking the <tt>size</tt>
     * method on each.  If this set has fewer elements, then the
     * implementation iterates over this set, checking each element
     * returned by the iterator in turn to see if it is contained in
     * the specified collection.  If it is so contained, it is removed
     * from this set with the iterator's <tt>remove</tt> method.  If
     * the specified collection has fewer elements, then the
     * implementation iterates over the specified collection, removing
     * from this set each element returned by the iterator, using this
     * set's <tt>remove</tt> method.<p>
     *
     * Note that this implementation will throw an
     * <tt>UnsupportedOperationException</tt> if the iterator returned by the
     * <tt>iterator</tt> method does not implement the <tt>remove</tt> method.
     *
     * @param c elements to be removed from this set.
     * @return <tt>true</tt> if this set changed as a result of the call.
     *
     * @throws    UnsupportedOperationException removeAll is not supported
     *            by this set.
     * @throws    NullPointerException if the specified collection is null.
     * @see #remove(Object)
     * @see #contains(Object)
     */
    public boolean removeAll(Collection c) {
        boolean modified = false;

        if (size() > c.size()) {
            for (Iterator i = c.iterator(); i.hasNext(); )
                modified |= remove(i.next());
        } else {
            for (Iterator i = iterator(); i.hasNext(); ) {
                if(c.contains(i.next())) {
                    i.remove();
                    modified = true;
                }
            }
        }
        return modified;
    }

}

