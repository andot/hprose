/*
 * @(#)AbstractList.java	1.37 03/01/18
 *
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package java.util;

/**
 * This class provides a skeletal implementation of the <tt>List</tt>
 * interface to minimize the effort required to implement this interface
 * backed by a "random access" data store (such as an array).  For sequential
 * access data (such as a linked list), <tt>AbstractSequentialList</tt> should
 * be used in preference to this class.<p>
 *
 * To implement an unmodifiable list, the programmer needs only to extend this
 * class and provide implementations for the <tt>get(int index)</tt> and
 * <tt>size()</tt> methods.<p>
 *
 * To implement a modifiable list, the programmer must additionally override
 * the <tt>set(int index, Object element)</tt> method (which otherwise throws
 * an <tt>UnsupportedOperationException</tt>.  If the list is variable-size
 * the programmer must additionally override the <tt>add(int index, Object
 * element)</tt> and <tt>remove(int index)</tt> methods.<p>
 *
 * The programmer should generally provide a void (no argument) and collection
 * constructor, as per the recommendation in the <tt>Collection</tt> interface
 * specification.<p>
 *
 * Unlike the other abstract collection implementations, the programmer does
 * <i>not</i> have to provide an iterator implementation; the iterator and
 * list iterator are implemented by this class, on top the "random access"
 * methods: <tt>get(int index)</tt>, <tt>set(int index, Object element)</tt>,
 * <tt>set(int index, Object element)</tt>, <tt>add(int index, Object
 * element)</tt> and <tt>remove(int index)</tt>.<p>
 *
 * The documentation for each non-abstract methods in this class describes its
 * implementation in detail.  Each of these methods may be overridden if the
 * collection being implemented admits a more efficient implementation.<p>
 *
 * This class is a member of the 
 * <a href="{@docRoot}/../guide/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @author  Josh Bloch
 * @version 1.37, 01/18/03
 * @see Collection
 * @see List
 * @see AbstractSequentialList
 * @see AbstractCollection
 * @since 1.2
 */

public abstract class AbstractList extends AbstractCollection implements List {
    /**
     * Sole constructor.  (For invocation by subclass constructors, typically
     * implicit.)
     */
    protected AbstractList() {
    }

    /**
     * Appends the specified element to the end of this List (optional
     * operation). <p>
     *
     * This implementation calls <tt>add(size(), o)</tt>.<p>
     *
     * Note that this implementation throws an
     * <tt>UnsupportedOperationException</tt> unless <tt>add(int, Object)</tt>
     * is overridden.
     *
     * @param o element to be appended to this list.
     * 
     * @return <tt>true</tt> (as per the general contract of
     * <tt>Collection.add</tt>).
     * 
     * @throws UnsupportedOperationException if the <tt>add</tt> method is not
     * 		  supported by this Set.
     * 
     * @throws ClassCastException if the class of the specified element
     * 		  prevents it from being added to this set.
     * 
     * @throws IllegalArgumentException some aspect of this element prevents
     *            it from being added to this collection.
     */
    public boolean add(Object o) {
	add(size(), o);
	return true;
    }

    /**
     * Returns the element at the specified position in this list.
     *
     * @param index index of element to return.
     * 
     * @return the element at the specified position in this list.
     * @throws IndexOutOfBoundsException if the given index is out of range
     * 		  (<tt>index &lt; 0 || index &gt;= size()</tt>).
     */
    abstract public Object get(int index);

    /**
     * Replaces the element at the specified position in this list with the
     * specified element (optional operation). <p>
     *
     * This implementation always throws an
     * <tt>UnsupportedOperationException</tt>.
     *
     * @param index index of element to replace.
     * @param element element to be stored at the specified position.
     * @return the element previously at the specified position.
     * 
     * @throws UnsupportedOperationException if the <tt>set</tt> method is not
     *		  supported by this List.
     * @throws ClassCastException if the class of the specified element
     * 		  prevents it from being added to this list.
     * @throws IllegalArgumentException if some aspect of the specified
     *		  element prevents it from being added to this list.
     * 
     * @throws IndexOutOfBoundsException if the specified index is out of
     *            range (<tt>index &lt; 0 || index &gt;= size()</tt>).
     */
    
    public Object set(int index, Object element) {
	throw new UnsupportedOperationException();
    }

    /**
     * Inserts the specified element at the specified position in this list
     * (optional operation).  Shifts the element currently at that position
     * (if any) and any subsequent elements to the right (adds one to their
     * indices).<p>
     *
     * This implementation always throws an UnsupportedOperationException.
     *
     * @param index index at which the specified element is to be inserted.
     * @param element element to be inserted.
     * 
     * @throws UnsupportedOperationException if the <tt>add</tt> method is not
     *		  supported by this list.
     * @throws ClassCastException if the class of the specified element
     * 		  prevents it from being added to this list.
     * @throws IllegalArgumentException if some aspect of the specified
     *		  element prevents it from being added to this list.
     * @throws IndexOutOfBoundsException index is out of range (<tt>index &lt;
     *		  0 || index &gt; size()</tt>).
     */
    public void add(int index, Object element) {
	throw new UnsupportedOperationException();
    }

    /**
     * Removes the element at the specified position in this list (optional
     * operation).  Shifts any subsequent elements to the left (subtracts one
     * from their indices).  Returns the element that was removed from the
     * list.<p>
     *
     * This implementation always throws an
     * <tt>UnsupportedOperationException</tt>.
     *
     * @param index the index of the element to remove.
     * @return the element previously at the specified position.
     * 
     * @throws UnsupportedOperationException if the <tt>remove</tt> method is
     *		  not supported by this list.
     * @throws IndexOutOfBoundsException if the specified index is out of
     * 		  range (<tt>index &lt; 0 || index &gt;= size()</tt>).
     */
    public Object remove(int index) {
	throw new UnsupportedOperationException();
    }


    // Search Operations

    /**
     * Returns the index in this list of the first occurence of the specified
     * element, or -1 if the list does not contain this element.  More
     * formally, returns the lowest index <tt>i</tt> such that <tt>(o==null ?
     * get(i)==null : o.equals(get(i)))</tt>, or -1 if there is no such
     * index.<p>
     *
     * This implementation first gets a list iterator (with
     * <tt>listIterator()</tt>).  Then, it iterates over the list until the
     * specified element is found or the end of the list is reached.
     *
     * @param o element to search for.
     * 
     * @return the index in this List of the first occurence of the specified
     * 	       element, or -1 if the List does not contain this element.
     */
    public int indexOf(Object o) {
	ListIterator e = listIterator();
	if (o==null) {
	    while (e.hasNext())
		if (e.next()==null)
		    return e.previousIndex();
	} else {
	    while (e.hasNext())
		if (o.equals(e.next()))
		    return e.previousIndex();
	}
	return -1;
    }

    /**
     * Returns the index in this list of the last occurence of the specified
     * element, or -1 if the list does not contain this element.  More
     * formally, returns the highest index <tt>i</tt> such that <tt>(o==null ?
     * get(i)==null : o.equals(get(i)))</tt>, or -1 if there is no such
     * index.<p>
     *
     * This implementation first gets a list iterator that points to the end
     * of the list (with listIterator(size())).  Then, it iterates backwards
     * over the list until the specified element is found, or the beginning of
     * the list is reached.
     *
     * @param o element to search for.
     * 
     * @return the index in this list of the last occurence of the specified
     * 	       element, or -1 if the list does not contain this element.
     */
    public int lastIndexOf(Object o) {
	ListIterator e = listIterator(size());
	if (o==null) {
	    while (e.hasPrevious())
		if (e.previous()==null)
		    return e.nextIndex();
	} else {
	    while (e.hasPrevious())
		if (o.equals(e.previous()))
		    return e.nextIndex();
	}
	return -1;
    }


    // Bulk Operations

    /**
     * Removes all of the elements from this collection (optional operation).
     * The collection will be empty after this call returns (unless it throws
     * an exception).<p>
     *
     * This implementation calls <tt>removeRange(0, size())</tt>.<p>
     *
     * Note that this implementation throws an
     * <tt>UnsupportedOperationException</tt> unless <tt>remove(int
     * index)</tt> or <tt>removeRange(int fromIndex, int toIndex)</tt> is
     * overridden.
     *
     * @throws UnsupportedOperationException if the <tt>clear</tt> method is
     * 		  not supported by this Collection.
     */
    public void clear() {
        removeRange(0, size());
    }

    /**
     * Inserts all of the elements in the specified collection into this list
     * at the specified position (optional operation).  Shifts the element
     * currently at that position (if any) and any subsequent elements to the
     * right (increases their indices).  The new elements will appear in the
     * list in the order that they are returned by the specified collection's
     * iterator.  The behavior of this operation is unspecified if the
     * specified collection is modified while the operation is in progress.
     * (Note that this will occur if the specified collection is this list,
     * and it's nonempty.)<p>
     *
     * This implementation gets an iterator over the specified collection and
     * iterates over it, inserting the elements obtained from the iterator
     * into this list at the appropriate position, one at a time, using
     * <tt>add(int, Object)</tt>.  Many implementations will override this
     * method for efficiency.<p>
     *
     * Note that this implementation throws an
     * <tt>UnsupportedOperationException</tt> unless <tt>add(int, Object)</tt>
     * is overridden.
     *
     * @return <tt>true</tt> if this list changed as a result of the call.
     * @param index index at which to insert the first element from the
     *		    specified collection.
     * @param c elements to be inserted into this List.
     * 
     * @throws UnsupportedOperationException if the <tt>addAll</tt> method is
     *		  not supported by this list.
     * 
     * @throws ClassCastException if the class of an element of the specified
     * 		  collection prevents it from being added to this List.
     * 
     * @throws IllegalArgumentException some aspect an element of the
     *		  specified collection prevents it from being added to this
     *		  List.
     * 
     * @throws IndexOutOfBoundsException index out of range (<tt>index &lt; 0
     *            || index &gt; size()</tt>).
     *
     * @throws NullPointerException if the specified collection is null.
     */
    public boolean addAll(int index, Collection c) {
	boolean modified = false;
	Iterator e = c.iterator();
	while (e.hasNext()) {
	    add(index++, e.next());
	    modified = true;
	}
	return modified;
    }


    // Iterators

    /**
     * Returns an iterator over the elements in this list in proper
     * sequence. <p>
     *
     * This implementation returns a straightforward implementation of the
     * iterator interface, relying on the backing list's <tt>size()</tt>,
     * <tt>get(int)</tt>, and <tt>remove(int)</tt> methods.<p>
     *
     * Note that the iterator returned by this method will throw an
     * <tt>UnsupportedOperationException</tt> in response to its
     * <tt>remove</tt> method unless the list's <tt>remove(int)</tt> method is
     * overridden.<p>
     *
     * This implementation can be made to throw runtime exceptions in the face
     * of concurrent modification, as described in the specification for the
     * (protected) <tt>modCount</tt> field.
     *
     * @return an iterator over the elements in this list in proper sequence.
     * 
     * @see #modCount
     */
    public Iterator iterator() {
	return new Itr();
    }

    /**
     * Returns an iterator of the elements in this list (in proper sequence).
     * This implementation returns <tt>listIterator(0)</tt>.
     * 
     * @return an iterator of the elements in this list (in proper sequence).
     * 
     * @see #listIterator(int)
     */
    public ListIterator listIterator() {
	return listIterator(0);
    }

    /**
     * Returns a list iterator of the elements in this list (in proper
     * sequence), starting at the specified position in the list.  The
     * specified index indicates the first element that would be returned by
     * an initial call to the <tt>next</tt> method.  An initial call to
     * the <tt>previous</tt> method would return the element with the
     * specified index minus one.<p>
     *
     * This implementation returns a straightforward implementation of the
     * <tt>ListIterator</tt> interface that extends the implementation of the
     * <tt>Iterator</tt> interface returned by the <tt>iterator()</tt> method.
     * The <tt>ListIterator</tt> implementation relies on the backing list's
     * <tt>get(int)</tt>, <tt>set(int, Object)</tt>, <tt>add(int, Object)</tt>
     * and <tt>remove(int)</tt> methods.<p>
     *
     * Note that the list iterator returned by this implementation will throw
     * an <tt>UnsupportedOperationException</tt> in response to its
     * <tt>remove</tt>, <tt>set</tt> and <tt>add</tt> methods unless the
     * list's <tt>remove(int)</tt>, <tt>set(int, Object)</tt>, and
     * <tt>add(int, Object)</tt> methods are overridden.<p>
     *
     * This implementation can be made to throw runtime exceptions in the
     * face of concurrent modification, as described in the specification for
     * the (protected) <tt>modCount</tt> field.
     *
     * @param index index of the first element to be returned from the list
     *		    iterator (by a call to the <tt>next</tt> method).
     * 
     * @return a list iterator of the elements in this list (in proper
     * 	       sequence), starting at the specified position in the list.
     * 
     * @throws IndexOutOfBoundsException if the specified index is out of
     *		  range (<tt>index &lt; 0 || index &gt; size()</tt>).
     * 
     * @see #modCount
     */
    public ListIterator listIterator(final int index) {
	if (index<0 || index>size())
	  throw new IndexOutOfBoundsException("Index: "+index);

	return new ListItr(index);
    }

    private class Itr implements Iterator {
	/**
	 * Index of element to be returned by subsequent call to next.
	 */
	int cursor = 0;

	/**
	 * Index of element returned by most recent call to next or
	 * previous.  Reset to -1 if this element is deleted by a call
	 * to remove.
	 */
	int lastRet = -1;

	/**
	 * The modCount value that the iterator believes that the backing
	 * List should have.  If this expectation is violated, the iterator
	 * has detected concurrent modification.
	 */
	int expectedModCount = modCount;

	public boolean hasNext() {
	    return cursor != size();
	}

	public Object next() {
            checkForComodification();
	    try {
		Object next = get(cursor);
		lastRet = cursor++;
		return next;
	    } catch(IndexOutOfBoundsException e) {
		checkForComodification();
		throw new NoSuchElementException();
	    }
	}

	public void remove() {
	    if (lastRet == -1)
		throw new IllegalStateException();
            checkForComodification();

	    try {
		AbstractList.this.remove(lastRet);
		if (lastRet < cursor)
		    cursor--;
		lastRet = -1;
		expectedModCount = modCount;
	    } catch(IndexOutOfBoundsException e) {
		throw new ConcurrentModificationException();
	    }
	}

	final void checkForComodification() {
	    if (modCount != expectedModCount)
		throw new ConcurrentModificationException();
	}
    }

    private class ListItr extends Itr implements ListIterator {
	ListItr(int index) {
	    cursor = index;
	}

	public boolean hasPrevious() {
	    return cursor != 0;
	}

        public Object previous() {
            checkForComodification();
            try {
                int i = cursor - 1;
                Object previous = get(i);
                lastRet = cursor = i;
                return previous;
            } catch(IndexOutOfBoundsException e) {
                checkForComodification();
                throw new NoSuchElementException();
            }
        }

	public int nextIndex() {
	    return cursor;
	}

	public int previousIndex() {
	    return cursor-1;
	}

	public void set(Object o) {
	    if (lastRet == -1)
		throw new IllegalStateException();
            checkForComodification();

	    try {
		AbstractList.this.set(lastRet, o);
		expectedModCount = modCount;
	    } catch(IndexOutOfBoundsException e) {
		throw new ConcurrentModificationException();
	    }
	}

	public void add(Object o) {
            checkForComodification();

	    try {
		AbstractList.this.add(cursor++, o);
		lastRet = -1;
		expectedModCount = modCount;
	    } catch(IndexOutOfBoundsException e) {
		throw new ConcurrentModificationException();
	    }
	}
    }

    /**
     * Returns a view of the portion of this list between <tt>fromIndex</tt>,
     * inclusive, and <tt>toIndex</tt>, exclusive.  (If <tt>fromIndex</tt> and
     * <tt>toIndex</tt> are equal, the returned list is empty.)  The returned
     * list is backed by this list, so changes in the returned list are
     * reflected in this list, and vice-versa.  The returned list supports all
     * of the optional list operations supported by this list.<p>
     *
     * This method eliminates the need for explicit range operations (of the
     * sort that commonly exist for arrays).  Any operation that expects a
     * list can be used as a range operation by operating on a subList view
     * instead of a whole list.  For example, the following idiom removes a
     * range of elements from a list:
     * <pre>
     *     list.subList(from, to).clear();
     * </pre>
     * Similar idioms may be constructed for <tt>indexOf</tt> and
     * <tt>lastIndexOf</tt>, and all of the algorithms in the
     * <tt>Collections</tt> class can be applied to a subList.<p>
     * 
     * The semantics of the list returned by this method become undefined if
     * the backing list (i.e., this list) is <i>structurally modified</i> in
     * any way other than via the returned list.  (Structural modifications are
     * those that change the size of the list, or otherwise perturb it in such
     * a fashion that iterations in progress may yield incorrect results.)<p>
     *
     * This implementation returns a list that subclasses
     * <tt>AbstractList</tt>.  The subclass stores, in private fields, the
     * offset of the subList within the backing list, the size of the subList
     * (which can change over its lifetime), and the expected
     * <tt>modCount</tt> value of the backing list.  There are two variants
     * of the subclass, one of which implements <tt>RandomAccess</tt>.
     * If this list implements <tt>RandomAccess</tt> the returned list will
     * be an instance of the subclass that implements <tt>RandomAccess</tt>.<p>
     *
     * The subclass's <tt>set(int, Object)</tt>, <tt>get(int)</tt>,
     * <tt>add(int, Object)</tt>, <tt>remove(int)</tt>, <tt>addAll(int,
     * Collection)</tt> and <tt>removeRange(int, int)</tt> methods all
     * delegate to the corresponding methods on the backing abstract list,
     * after bounds-checking the index and adjusting for the offset.  The
     * <tt>addAll(Collection c)</tt> method merely returns <tt>addAll(size,
     * c)</tt>.<p>
     *
     * The <tt>listIterator(int)</tt> method returns a "wrapper object" over a
     * list iterator on the backing list, which is created with the
     * corresponding method on the backing list.  The <tt>iterator</tt> method
     * merely returns <tt>listIterator()</tt>, and the <tt>size</tt> method
     * merely returns the subclass's <tt>size</tt> field.<p>
     *
     * All methods first check to see if the actual <tt>modCount</tt> of the
     * backing list is equal to its expected value, and throw a
     * <tt>ConcurrentModificationException</tt> if it is not.
     *
     * @param fromIndex low endpoint (inclusive) of the subList.
     * @param toIndex high endpoint (exclusive) of the subList.
     * @return a view of the specified range within this list.
     * @throws IndexOutOfBoundsException endpoint index value out of range
     *         <tt>(fromIndex &lt; 0 || toIndex &gt; size)</tt>
     * @throws IllegalArgumentException endpoint indices out of order
     * <tt>(fromIndex &gt; toIndex)</tt> */
    public List subList(int fromIndex, int toIndex) {
        return (this instanceof RandomAccess ?
                new RandomAccessSubList(this, fromIndex, toIndex) :
                new SubList(this, fromIndex, toIndex));
    }

    // Comparison and hashing

    /**
     * Compares the specified object with this list for equality.  Returns
     * <tt>true</tt> if and only if the specified object is also a list, both
     * lists have the same size, and all corresponding pairs of elements in
     * the two lists are <i>equal</i>.  (Two elements <tt>e1</tt> and
     * <tt>e2</tt> are <i>equal</i> if <tt>(e1==null ? e2==null :
     * e1.equals(e2))</tt>.)  In other words, two lists are defined to be
     * equal if they contain the same elements in the same order.<p>
     *
     * This implementation first checks if the specified object is this
     * list. If so, it returns <tt>true</tt>; if not, it checks if the
     * specified object is a list. If not, it returns <tt>false</tt>; if so,
     * it iterates over both lists, comparing corresponding pairs of elements.
     * If any comparison returns <tt>false</tt>, this method returns
     * <tt>false</tt>.  If either iterator runs out of elements before the
     * other it returns <tt>false</tt> (as the lists are of unequal length);
     * otherwise it returns <tt>true</tt> when the iterations complete.
     *
     * @param o the object to be compared for equality with this list.
     * 
     * @return <tt>true</tt> if the specified object is equal to this list.
     */
    public boolean equals(Object o) {
	if (o == this)
	    return true;
	if (!(o instanceof List))
	    return false;

	ListIterator e1 = listIterator();
	ListIterator e2 = ((List) o).listIterator();
	while(e1.hasNext() && e2.hasNext()) {
	    Object o1 = e1.next();
	    Object o2 = e2.next();
	    if (!(o1==null ? o2==null : o1.equals(o2)))
		return false;
	}
	return !(e1.hasNext() || e2.hasNext());
    }

    /**
     * Returns the hash code value for this list. <p>
     *
     * This implementation uses exactly the code that is used to define the
     * list hash function in the documentation for the <tt>List.hashCode</tt>
     * method.
     *
     * @return the hash code value for this list.
     */
    public int hashCode() {
	int hashCode = 1;
	Iterator i = iterator();
     	while (i.hasNext()) {
	    Object obj = i.next();
	    hashCode = 31*hashCode + (obj==null ? 0 : obj.hashCode());
	}
	return hashCode;
    }

    /**
     * Removes from this list all of the elements whose index is between
     * <tt>fromIndex</tt>, inclusive, and <tt>toIndex</tt>, exclusive.
     * Shifts any succeeding elements to the left (reduces their index).  This
     * call shortens the ArrayList by <tt>(toIndex - fromIndex)</tt>
     * elements.  (If <tt>toIndex==fromIndex</tt>, this operation has no
     * effect.)<p>
     *
     * This method is called by the <tt>clear</tt> operation on this list
     * and its subLists.  Overriding this method to take advantage of
     * the internals of the list implementation can <i>substantially</i>
     * improve the performance of the <tt>clear</tt> operation on this list
     * and its subLists.<p>
     *
     * This implementation gets a list iterator positioned before
     * <tt>fromIndex</tt>, and repeatedly calls <tt>ListIterator.next</tt>
     * followed by <tt>ListIterator.remove</tt> until the entire range has
     * been removed.  <b>Note: if <tt>ListIterator.remove</tt> requires linear
     * time, this implementation requires quadratic time.</b>
     *
     * @param fromIndex index of first element to be removed.
     * @param toIndex index after last element to be removed.
     */
    protected void removeRange(int fromIndex, int toIndex) {
        ListIterator it = listIterator(fromIndex);
        for (int i=0, n=toIndex-fromIndex; i<n; i++) {
            it.next();
            it.remove();
        }
    }

    /**
     * The number of times this list has been <i>structurally modified</i>.
     * Structural modifications are those that change the size of the
     * list, or otherwise perturb it in such a fashion that iterations in
     * progress may yield incorrect results.<p>
     *
     * This field is used by the iterator and list iterator implementation
     * returned by the <tt>iterator</tt> and <tt>listIterator</tt> methods.
     * If the value of this field changes unexpectedly, the iterator (or list
     * iterator) will throw a <tt>ConcurrentModificationException</tt> in
     * response to the <tt>next</tt>, <tt>remove</tt>, <tt>previous</tt>,
     * <tt>set</tt> or <tt>add</tt> operations.  This provides
     * <i>fail-fast</i> behavior, rather than non-deterministic behavior in
     * the face of concurrent modification during iteration.<p>
     *
     * <b>Use of this field by subclasses is optional.</b> If a subclass
     * wishes to provide fail-fast iterators (and list iterators), then it
     * merely has to increment this field in its <tt>add(int, Object)</tt> and
     * <tt>remove(int)</tt> methods (and any other methods that it overrides
     * that result in structural modifications to the list).  A single call to
     * <tt>add(int, Object)</tt> or <tt>remove(int)</tt> must add no more than
     * one to this field, or the iterators (and list iterators) will throw
     * bogus <tt>ConcurrentModificationExceptions</tt>.  If an implementation
     * does not wish to provide fail-fast iterators, this field may be
     * ignored.
     */
    protected transient int modCount = 0;
}

class SubList extends AbstractList {
    private AbstractList l;
    private int offset;
    private int size;
    private int expectedModCount;

    SubList(AbstractList list, int fromIndex, int toIndex) {
        if (fromIndex < 0)
            throw new IndexOutOfBoundsException("fromIndex = " + fromIndex);
        if (toIndex > list.size())
            throw new IndexOutOfBoundsException("toIndex = " + toIndex);
        if (fromIndex > toIndex)
            throw new IllegalArgumentException("fromIndex(" + fromIndex +
                                               ") > toIndex(" + toIndex + ")");
        l = list;
        offset = fromIndex;
        size = toIndex - fromIndex;
        expectedModCount = l.modCount;
    }

    public Object set(int index, Object element) {
        rangeCheck(index);
        checkForComodification();
        return l.set(index+offset, element);
    }

    public Object get(int index) {
        rangeCheck(index);
        checkForComodification();
        return l.get(index+offset);
    }

    public int size() {
        checkForComodification();
        return size;
    }

    public void add(int index, Object element) {
        if (index<0 || index>size)
            throw new IndexOutOfBoundsException();
        checkForComodification();
        l.add(index+offset, element);
        expectedModCount = l.modCount;
        size++;
        modCount++;
    }

    public Object remove(int index) {
        rangeCheck(index);
        checkForComodification();
        Object result = l.remove(index+offset);
        expectedModCount = l.modCount;
        size--;
        modCount++;
        return result;
    }

    protected void removeRange(int fromIndex, int toIndex) {
        checkForComodification();
        l.removeRange(fromIndex+offset, toIndex+offset);
        expectedModCount = l.modCount;
        size -= (toIndex-fromIndex);
        modCount++;
    }

    public boolean addAll(Collection c) {
        return addAll(size, c);
    }

    public boolean addAll(int index, Collection c) {
        if (index<0 || index>size)
            throw new IndexOutOfBoundsException(
                "Index: "+index+", Size: "+size);
        int cSize = c.size();
        if (cSize==0)
            return false;

        checkForComodification();
        l.addAll(offset+index, c);
        expectedModCount = l.modCount;
        size += cSize;
        modCount++;
        return true;
    }

    public Iterator iterator() {
        return listIterator();
    }

    public ListIterator listIterator(final int index) {
        checkForComodification();
        if (index<0 || index>size)
            throw new IndexOutOfBoundsException(
                "Index: "+index+", Size: "+size);

        return new ListIterator() {
            private ListIterator i = l.listIterator(index+offset);

            public boolean hasNext() {
                return nextIndex() < size;
            }

            public Object next() {
                if (hasNext())
                    return i.next();
                else
                    throw new NoSuchElementException();
            }

            public boolean hasPrevious() {
                return previousIndex() >= 0;
            }

            public Object previous() {
                if (hasPrevious())
                    return i.previous();
                else
                    throw new NoSuchElementException();
            }

            public int nextIndex() {
                return i.nextIndex() - offset;
            }

            public int previousIndex() {
                return i.previousIndex() - offset;
            }

            public void remove() {
                i.remove();
                expectedModCount = l.modCount;
                size--;
                modCount++;
            }

            public void set(Object o) {
                i.set(o);
            }

            public void add(Object o) {
                i.add(o);
                expectedModCount = l.modCount;
                size++;
                modCount++;
            }
        };
    }

    public List subList(int fromIndex, int toIndex) {
        return new SubList(this, fromIndex, toIndex);
    }

    private void rangeCheck(int index) {
        if (index<0 || index>=size)
            throw new IndexOutOfBoundsException("Index: "+index+
                                                ",Size: "+size);
    }

    private void checkForComodification() {
        if (l.modCount != expectedModCount)
            throw new ConcurrentModificationException();
    }
}

class RandomAccessSubList extends SubList implements RandomAccess {
    RandomAccessSubList(AbstractList list, int fromIndex, int toIndex) {
        super(list, fromIndex, toIndex);
    }

    public List subList(int fromIndex, int toIndex) {
        return new RandomAccessSubList(this, fromIndex, toIndex);
    }
}
