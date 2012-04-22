/*
 * Copyright  1990-2007 Sun Microsystems, Inc. All Rights Reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version
 * 2 only, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License version 2 for more details (a copy is
 * included at /legal/license.txt).
 *
 * You should have received a copy of the GNU General Public License
 * version 2 along with this work; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 *
 * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa
 * Clara, CA 95054 or visit www.sun.com if you need additional
 * information or have any questions.
 */

package java.lang;

/**
 * This interface imposes a total ordering on the objects of each class that
 * implements it.  This ordering is referred to as the class's <i>natural
 * ordering</i>, and the class's <tt>compareTo</tt> method is referred to as
 * its <i>natural comparison method</i>.
 *
 * <p><b><i>This interface is provided as part of the JSR 239 NIO Buffer
 * building block.</i></b>
 *
 * <p> <b><i>This interface is used by the <code>java.nio.ByteBuffer</code>,
 * <code>ShortBuffer</code>, <code>IntBuffer</code>, and
 * <code>FloatBuffer</code> classes.  The documentation that follows
 * is taken from Java Standard Edition version 1.4.2 and may not
 * reflect the actual classes and interfaces that are present on a
 * particular Java platform that supports the JSR 239 building
 * block.</i></b>
 *
 * <p>
 * Lists (and arrays) of objects that implement this interface can
 * be sorted automatically by <tt>Collections.sort</tt> (and
 * <tt>Arrays.sort</tt>).  Objects that implement this interface can
 * be used as keys in a sorted map or elements in a sorted set,
 * without the need to specify a comparator.<p>
 *
 * The natural ordering for a class <tt>C</tt> is said to be <i>consistent
 * with equals</i> if and only if <tt>(e1.compareTo((Object)e2) == 0)</tt> has
 * the same boolean value as <tt>e1.equals((Object)e2)</tt> for every
 * <tt>e1</tt> and <tt>e2</tt> of class <tt>C</tt>.  Note that <tt>null</tt>
 * is not an instance of any class, and <tt>e.compareTo(null)</tt> should
 * throw a <tt>NullPointerException</tt> even though <tt>e.equals(null)</tt>
 * returns <tt>false</tt>.<p>
 *
 * It is strongly recommended (though not required) that natural orderings be
 * consistent with equals.  This is so because sorted sets (and sorted maps)
 * without explicit comparators behave "strangely" when they are used with
 * elements (or keys) whose natural ordering is inconsistent with equals.  In
 * particular, such a sorted set (or sorted map) violates the general contract
 * for set (or map), which is defined in terms of the <tt>equals</tt>
 * method.<p>
 *
 * For example, if one adds two keys <tt>a</tt> and <tt>b</tt> such that
 * <tt>(!a.equals((Object)b) && a.compareTo((Object)b) == 0)</tt> to a sorted
 * set that does not use an explicit comparator, the second <tt>add</tt>
 * operation returns false (and the size of the sorted set does not increase)
 * because <tt>a</tt> and <tt>b</tt> are equivalent from the sorted set's
 * perspective.<p>
 *
 * Virtually all Java core classes that implement comparable have natural
 * orderings that are consistent with equals.  One exception is
 * <tt>java.math.BigDecimal</tt>, whose natural ordering equates
 * <tt>BigDecimal</tt> objects with equal values and different precisions
 * (such as 4.0 and 4.00).<p>
 *
 * For the mathematically inclined, the <i>relation</i> that defines
 * the natural ordering on a given class C is:<pre>
 *       {(x, y) such that x.compareTo((Object)y) <= 0}.
 * </pre> The <i>quotient</i> for this total order is: <pre>
 *       {(x, y) such that x.compareTo((Object)y) == 0}.
 * </pre>
 *
 * It follows immediately from the contract for <tt>compareTo</tt> that the
 * quotient is an <i>equivalence relation</i> on <tt>C</tt>, and that the
 * natural ordering is a <i>total order</i> on <tt>C</tt>.  When we say that a
 * class's natural ordering is <i>consistent with equals</i>, we mean that the
 * quotient for the natural ordering is the equivalence relation defined by
 * the class's <tt>equals(Object)</tt> method:<pre>
 *     {(x, y) such that x.equals((Object)y)}.
 * </pre><p>
 *
 * This interface is a member of the Java Collections Framework.
 *
 * @version 1.20, 01/23/03
 * @see java.util.Comparator
 * @see java.util.Collections#sort(java.util.List)
 * @see java.util.Arrays#sort(Object[])
 * @see java.util.SortedSet
 * @see java.util.SortedMap
 * @see java.util.TreeSet
 * @see java.util.TreeMap
 * @since 1.2
 */

public interface Comparable {
    /**
     * Compares this object with the specified object for order.  Returns a
     * negative integer, zero, or a positive integer as this object is less
     * than, equal to, or greater than the specified object.<p>
     *
     * In the foregoing description, the notation
     * <tt>sgn(</tt><i>expression</i><tt>)</tt> designates the mathematical
     * <i>signum</i> function, which is defined to return one of <tt>-1</tt>,
     * <tt>0</tt>, or <tt>1</tt> according to whether the value of <i>expression</i>
     * is negative, zero or positive.
     *
     * The implementor must ensure <tt>sgn(x.compareTo(y)) ==
     * -sgn(y.compareTo(x))</tt> for all <tt>x</tt> and <tt>y</tt>.  (This
     * implies that <tt>x.compareTo(y)</tt> must throw an exception iff
     * <tt>y.compareTo(x)</tt> throws an exception.)<p>
     *
     * The implementor must also ensure that the relation is transitive:
     * <tt>(x.compareTo(y)>0 && y.compareTo(z)>0)</tt> implies
     * <tt>x.compareTo(z)>0</tt>.<p>
     *
     * Finally, the implementer must ensure that <tt>x.compareTo(y)==0</tt>
     * implies that <tt>sgn(x.compareTo(z)) == sgn(y.compareTo(z))</tt>, for
     * all <tt>z</tt>.<p>
     *
     * It is strongly recommended, but <i>not</i> strictly required that
     * <tt>(x.compareTo(y)==0) == (x.equals(y))</tt>.  Generally speaking, any
     * class that implements the <tt>Comparable</tt> interface and violates
     * this condition should clearly indicate this fact.  The recommended
     * language is "Note: this class has a natural ordering that is
     * inconsistent with equals."
     *
     * @param   o the Object to be compared.
     * @return  a negative integer, zero, or a positive integer as this object
     *		is less than, equal to, or greater than the specified object.
     *
     * @throws ClassCastException if the specified object's type prevents it
     *         from being compared to this Object.
     */
    public int compareTo(Object o);
}
