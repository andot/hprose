/*
 * @(#)AbstractSequentialList.java	1.27 03/01/23
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * This class provides a skeletal implementation of the <tt>List</tt>
 * interface to minimize the effort required to implement this interface
 * backed by a "sequential access" data store (such as a linked list).  For
 * random access data (such as an array), <tt>AbstractList</tt> should be used
 * in preference to this class.<p>
 *
 * This class is the opposite of the <tt>AbstractList</tt> class in the sense
 * that it implements the "random access" methods (<tt>get(int index)</tt>,
 * <tt>set(int index, Object element)</tt>, <tt>set(int index, Object
 * element)</tt>, <tt>add(int index, Object element)</tt> and <tt>remove(int
 * index)</tt>) on top of the list's list iterator, instead of the other way
 * around.<p>
 *
 * To implement a list the programmer needs only to extend this class and
 * provide implementations for the <tt>listIterator</tt> and <tt>size</tt>
 * methods.  For an unmodifiable list, the programmer need only implement the
 * list iterator's <tt>hasNext</tt>, <tt>next</tt>, <tt>hasPrevious</tt>,
 * <tt>previous</tt> and <tt>index</tt> methods.<p>
 *
 * For a modifiable list the programmer should additionally implement the list
 * iterator's <tt>set</tt> method.  For a variable-size list the programmer
 * should additionally implement the list iterator's <tt>remove</tt> and
 * <tt>add</tt> methods.<p>
 *
 * The programmer should generally provide a void (no argument) and collection
 * constructor, as per the recommendation in the <tt>Collection</tt> interface
 * specification.<p>
 *
 * This class is a member of the 
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch
 * @version 1.27, 01/23/03
 * @see Collection
 * @see List
 * @see AbstractList
 * @see AbstractCollection
 * @since 1.2
 */

public abstract class AbstractSequentialList extends AbstractList {
    /**
     * Sole constructor.  (For invocation by subclass constructors, typically
     * implicit.)
     */
    protected AbstractSequentialList() {
    }

    /**
     * Returns the element at the specified position in this list. <p>
     *
     * This implementation first gets a list iterator pointing to the indexed
     * element (with <tt>listIterator(index)</tt>).  Then, it gets the element
     * using <tt>ListIterator.next</tt> and returns it.
     * @param index index of element to return.
     *
     * @return the element at the specified position in this list.  
     * @throws IndexOutOfBoundsException if the specified index is out of
     *         range (<tt>index &lt; 0 || index &gt;= size()</tt>).
     */
    public Object get(int index) {
	ListIterator e = listIterator(index);
	try {
	    return(e.next());
	} catch(NoSuchElementException exc) {
	    throw(new IndexOutOfBoundsException("Index: "+index));
	}
    }

    /**
     * Replaces the element at the specified position in this list with the
     * specified element. <p>
     *
     * This implementation first gets a list iterator pointing to the
     * indexed element (with <tt>listIterator(index)</tt>).  Then, it gets
     * the current element using <tt>ListIterator.next</tt> and replaces it
     * with <tt>ListIterator.set</tt>.<p>
     *
     * Note that this implementation will throw an
     * UnsupportedOperationException if list iterator does not implement
     * the set operation.
     *
     * @param index index of element to replace.
     * @param element element to be stored at the specified position.
     * @return the element previously at the specified position.
     * @throws    UnsupportedOperationException set is not supported
     *		  by this list.
     * @throws    NullPointerException this list does not permit null
     * 		  elements and one of the elements of <code>c</code> is null.
     * @throws    ClassCastException class of the specified element
     * 		  prevents it from being added to this list.
     * @throws    IllegalArgumentException some aspect of the specified
     *		  element prevents it from being added to this list.
     * @throws    IndexOutOfBoundsException index out of range
     *		  <tt>(index &lt; 0 || index &gt;= size()</tt>).
     * @throws    IllegalArgumentException fromIndex &gt; toIndex.
     */
    public Object set(int index, Object element) {
	ListIterator e = listIterator(index);
	try {
	    Object oldVal = e.next();
	    e.set(element);
	    return oldVal;
	} catch(NoSuchElementException exc) {
	    throw(new IndexOutOfBoundsException("Index: "+index));
	}
    }

    /**
     * Inserts the specified element at the specified position in this list.
     * Shifts the element currently at that position (if any) and any
     * subsequent elements to the right (adds one to their indices).<p>
     *
     * This implementation first gets a list iterator pointing to the
     * indexed element (with <tt>listIterator(index)</tt>).  Then, it inserts
     * the specified element with <tt>ListIterator.add</tt>.<p>
     *
     * Note that this implementation will throw an
     * <tt>UnsupportedOperationException</tt> if list iterator does not
     * implement the <tt>add</tt> operation.
     *
     * @param index index at which the specified element is to be inserted.
     * @param element element to be inserted.
     * @throws UnsupportedOperationException if the <tt>add</tt> operation is
     *		  not supported by this list.
     * @throws NullPointerException this list does not permit <tt>null</tt>
     * 		  elements and one of the elements of <code>c</code> is
     * 		  <tt>null</tt>.
     * @throws    ClassCastException if the class of the specified element
     * 		  prevents it from being added to this list.
     * @throws    IllegalArgumentException if some aspect of the specified
     *		  element prevents it from being added to this list.
     * @throws IndexOutOfBoundsException if the specified index is out of
     *            range (<tt>index &lt; 0 || index &gt; size()</tt>).
     */
    public void add(int index, Object element) {
	ListIterator e = listIterator(index);
	e.add(element);
    }

    /**
     * Removes the element at the specified position in this list.  Shifts any
     * subsequent elements to the left (subtracts one from their indices).<p>
     *
     * This implementation first gets a list iterator pointing to the
     * indexed element (with <tt>listIterator(index)</tt>).  Then, it removes
     * the element with <tt>ListIterator.remove</tt>.<p>
     *
     * Note that this implementation will throw an
     * <tt>UnsupportedOperationException</tt> if list iterator does not
     * implement the <tt>remove</tt> operation.
     *
     * @param  index index of the element to be removed from the List.
     * @return the element that was removed from the list.
     * @throws UnsupportedOperationException if the <tt>remove</tt> operation
     *		  is not supported by this list.
     * @throws IndexOutOfBoundsException if the specified index is out of
     * 		  range (index &lt; 0 || index &gt;= size()).
     */
    public Object remove(int index) {
	ListIterator e = listIterator(index);
	Object outCast;
	try {
	    outCast = e.next();
	} catch(NoSuchElementException exc) {
	    throw(new IndexOutOfBoundsException("Index: "+index));
	}
	e.remove();
	return(outCast);
    }


    // Bulk Operations

    /**
     * Inserts all of the elements in in the specified collection into this
     * list at the specified position.  Shifts the element currently at that
     * position (if any) and any subsequent elements to the right (increases
     * their indices).  The new elements will appear in the list in the order
     * that they are returned by the specified collection's iterator.  The
     * behavior of this operation is unspecified if the specified collection
     * is modified while the operation is in progress.  (Note that this will
     * occur if the specified collection is this list, and it's nonempty.)
     * Optional operation.<p>
     *
     * This implementation gets an iterator over the specified collection and
     * a list iterator over this list pointing to the indexed element (with
     * <tt>listIterator(index)</tt>).  Then, it iterates over the specified
     * collection, inserting the elements obtained from the iterator into this
     * list, one at a time, using <tt>ListIterator.add</tt> followed by
     * <tt>ListIterator.next</tt> (to skip over the added element).<p>
     *
     * Note that this implementation will throw an
     * <tt>UnsupportedOperationException</tt> if the list iterator returned by
     * the <tt>listIterator</tt> method does not implement the <tt>add</tt>
     * operation.
     *
     * @return <tt>true</tt> if this list changed as a result of the call.
     * @param index index at which to insert first element from the specified
     *		    collection.
     * @param c elements to be inserted into this list.
     * @throws UnsupportedOperationException if the <tt>addAll</tt> operation
     *		  is not supported by this list.
     * @throws NullPointerException this list does not permit <tt>null</tt>
     * 		  elements and one of the elements of the specified collection
     * 		  is <tt>null</tt>.
     * @throws    ClassCastException if the class of the specified element
     * 		  prevents it from being added to this list.
     * @throws    IllegalArgumentException if some aspect of the specified
     *		  element prevents it from being added to this list.
     * @throws IndexOutOfBoundsException if the specified index is out of
     *            range (<tt>index &lt; 0 || index &gt; size()</tt>).
     * @throws NullPointerException if the specified collection is null.
     */
    public boolean addAll(int index, Collection c) {
	boolean modified = false;
	ListIterator e1 = listIterator(index);
	Iterator e2 = c.iterator();
	while (e2.hasNext()) {
	    e1.add(e2.next());
	    modified = true;
	}
	return modified;
    }


    // Iterators

    /**
     * Returns an iterator over the elements in this list (in proper
     * sequence).<p> 
     *
     * This implementation merely returns a list iterator over the list.
     *
     * @return an iterator over the elements in this list (in proper sequence).
     */
    public Iterator iterator() {
        return listIterator();
    }

    /**
     * Returns a list iterator over the elements in this list (in proper
     * sequence).
     *
     * @param  index index of first element to be returned from the list 
     *		iterator (by a call to the <code>next</code> method)
     * @return a list iterator over the elements in this list (in proper
     *      sequence).
     */
    public abstract ListIterator listIterator(int index);
}
