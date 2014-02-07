/*
 * Copyright 2003 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

/*
 * @(#)BigDecimal.java	1.42 03/01/23
 */

package java.math;

/**
 * Immutable, arbitrary-precision signed decimal numbers.  A BigDecimal
 * consists of an arbitrary precision integer <i>unscaled value</i> and a
 * non-negative 32-bit integer <i>scale</i>, which represents the number of
 * digits to the right of the decimal point.  The number represented by the
 * BigDecimal is <tt>(unscaledValue/10<sup>scale</sup>)</tt>.  BigDecimal
 * provides operations for basic arithmetic, scale manipulation, comparison,
 * hashing, and format conversion.
 * <p>
 * The BigDecimal class gives its user complete control over rounding
 * behavior, forcing the user to explicitly specify a rounding
 * behavior for operations capable of discarding precision ({@link
 * #divide(BigDecimal, int)}, {@link #divide(BigDecimal, int, int)},
 * and {@link #setScale}).  Eight <em>rounding modes</em> are provided
 * for this purpose.
 * <p>
 * Two types of operations are provided for manipulating the scale of a
 * BigDecimal: scaling/rounding operations and decimal point motion
 * operations.  Scaling/rounding operations (<tt>setScale</tt>) return a
 * BigDecimal whose value is approximately (or exactly) equal to that of the
 * operand, but whose scale is the specified value; that is, they increase or
 * decrease the precision of the number with minimal effect on its value.
 * Decimal point motion operations ({@link #movePointLeft} and
 * {@link #movePointRight}) return a BigDecimal created from the operand by
 * moving the decimal point a specified distance in the specified direction;
 * that is, they change a number's value without affecting its precision.
 * <p>
 * For the sake of brevity and clarity, pseudo-code is used throughout the
 * descriptions of BigDecimal methods.  The pseudo-code expression
 * <tt>(i + j)</tt> is shorthand for "a BigDecimal whose value is
 * that of the BigDecimal <tt>i</tt> plus that of the BigDecimal <tt>j</tt>."
 * The pseudo-code expression <tt>(i == j)</tt> is shorthand for
 * "<tt>true</tt> if and only if the BigDecimal <tt>i</tt> represents the same
 * value as the the BigDecimal <tt>j</tt>."  Other pseudo-code expressions are
 * interpreted similarly.
 * <p>
 * Note: care should be exercised if BigDecimals are to be used as
 * keys in a {@link java.util.SortedMap} or elements in a {@link
 * java.util.SortedSet}, as BigDecimal's <i>natural ordering</i> is
 * <i>inconsistent with equals</i>.  See {@link Comparable}, {@link
 * java.util.SortedMap} or {@link java.util.SortedSet} for more
 * information.
 * <p>
 * All methods and constructors for this class
 * throw <CODE>NullPointerException</CODE> when passed
 * a null object reference for any input parameter.
 *
 * @see     BigInteger
 * @see	    java.util.SortedMap
 * @see	    java.util.SortedSet
 * @version 1.42, 01/23/03
 * @author Josh Bloch
 */
public class BigDecimal implements Comparable {
    /**
     * The unscaled value of this BigDecimal, as returned by unscaledValue().
     *
     * @serial
     * @see #unscaledValue
     */
    private BigInteger intVal;

    /**
     * The scale of this BigDecimal, as returned by scale().
     *
     * @serial
     * @see #scale
     */
    private int	       scale = 0;

    // Constructors

    /**
     * Translates the String representation of a BigDecimal into a
     * BigDecimal.  The String representation consists of an optional
     * sign, <tt>'+'</tt> (<tt>'&#92;u002B'</tt>) or <tt>'-'</tt>
     * (<tt>'&#92;u002D'</tt>), followed by a sequence of zero or more
     * decimal digits ("the integer"), optionally followed by a
     * fraction, optionally followed by an exponent.
     *
     * <p>The fraction consists of of a decimal point followed by zero or more
     * decimal digits.  The string must contain at least one digit in either
     * the integer or the fraction.  The number formed by the sign, the
     * integer and the fraction is referred to as the <i>significand</i>.
     *
     * <p>The exponent consists of the character <tt>'e'</tt>
     * (<tt>'&#92;u0075'</tt>) or <tt>'E'</tt> (<tt>'&#92;u0045'</tt>)
     * followed by one or more decimal digits.  The value of the
     * exponent must lie between -{@link Integer#MAX_VALUE} ({@link
     * Integer#MIN_VALUE}+1) and {@link Integer#MAX_VALUE}, inclusive.
     *
     * <p>More formally, the strings this constructor accepts are
     * described by the following grammar:
     * <blockquote>
     * <dl>
     * <dt><i>BigDecimalString:</i>
     * <dd><i>Sign<sub>opt</sub> Significand Exponent<sub>opt</sub></i>
     * <p>
     * <dt><i>Sign:</i>
     * <dd><code>+</code>
     * <dd><code>-</code>
     * <p>
     * <dt><i>Significand:</i>
     * <dd><i>IntegerPart</i> <code>.</code> <i>FractionPart<sub>opt</sub></i>
     * <dd><code>.</code> <i>FractionPart</i>
     * <dd><i>IntegerPart</i>
     * <p>
     * <dt><i>IntegerPart:
     * <dd>Digits</i>
     * <p>
     * <dt><i>FractionPart:
     * <dd>Digits</i>
     * <p>
     * <dt><i>Exponent:
     * <dd>ExponentIndicator SignedInteger</i>
     * <p>
     * <dt><i>ExponentIndicator:</i>
     * <dd><code>e</code>
     * <dd><code>E</code>
     * <p>
     * <dt><i>SignedInteger:
     * <dd>Sign<sub>opt</sub> Digits</i>
     * <p>
     * <dt><i>Digits:
     * <dd>Digit
     * <dd>Digits Digit</i>
     * <p>
     * <dt><i>Digit:</i>
     * <dd>any character for which {@link Character#isDigit}
     * returns <code>true</code>, including 0, 1, 2 ...
     * </dl>
     * </blockquote>
     *
     * <p>The scale of the returned BigDecimal will be the number of digits in
     * the fraction, or zero if the string contains no decimal point, subject
     * to adjustment for any exponent:  If the string contains an exponent, the
     * exponent is subtracted from the scale.  If the resulting scale is
     * negative, the scale of the returned BigDecimal is zero and the unscaled
     * value is multiplied by the appropriate power of ten so that, in every
     * case, the resulting BigDecimal is equal to <i>significand</i> &times;
     * 10<i><sup>exponent</sup></i>. (If in the future this specification is
     * amended to permit negative scales, the final step of zeroing the scale
     * and adjusting the unscaled value will be eliminated.)
     *
     * <p>The character-to-digit mapping is provided by {@link
     * java.lang.Character#digit} set to convert to radix 10.  The
     * String may not contain any extraneous characters (whitespace,
     * for example).
     *
     * <p>Note: For values other <tt>float</tt> and <tt>double</tt>
     * NaN and &plusmn;Infinity, this constructor is compatible with
     * the values returned by {@link Float#toString} and {@link
     * Double#toString}.  This is generally the preferred way to
     * convert a <tt>float</tt> or <tt>double</tt> into a BigDecimal,
     * as it doesn't suffer from the unpredictability of the {@link
     * #BigDecimal(double)} constructor.
     *
     * <p>Note: the optional leading plus sign and trailing exponent were
     * added in release 1.3.
     *
     * @param val String representation of BigDecimal.
     * @throws NumberFormatException <tt>val</tt> is not a valid representation
     *	       of a BigDecimal.
     */
    public BigDecimal(String val) {
        // Empty string not accepted
        if (val.length() == 0)
            throw new NumberFormatException();

        // Deal with leading plus sign if present
        if (val.charAt(0) == '+') {
            val = val.substring(1);      /* Discard leading '+' */
	    if (val.length() == 0 || 	 /* "+" illegal! */
		val.charAt(0) == '-')	 /* "+-123.456" illegal! */
		throw new NumberFormatException();
        }

        // If exponent is present, break into exponent and significand
        int exponent = 0;
	int ePos = val.indexOf('e');
        if (ePos == -1)
            ePos = val.indexOf('E');
        if (ePos != -1) {
            String exp = val.substring(ePos+1);
            if (exp.length() == 0)              /* "1.2e" illegal! */
                throw new NumberFormatException();
            if (exp.charAt(0) == '+') {
                exp = exp.substring(1);         /* Discard leading '+' */
                if (exp.length() == 0 ||	/* "123.456e+" illegal! */
		    exp.charAt(0) == '-')       /* "123.456e+-7" illegal! */
                    throw new NumberFormatException();
            }
            exponent = Integer.parseInt(exp);
            if (ePos==0)
		throw new NumberFormatException(); /* "e123" illegal! */
            val = val.substring(0, ePos);
        }

        // Parse significand
	int pointPos = val.indexOf('.');
	if (pointPos == -1) {			 /* e.g. "123" */
	    intVal = new BigInteger(val);
	} else if (pointPos == val.length()-1) { /* e.g. "123." */
	    intVal = new BigInteger(val.substring(0, val.length()-1));
	} else {    /* Fraction part exists */
            if (val.charAt(pointPos+1) == '-')	 /* ".-123" illegal! */
		throw new NumberFormatException();

            char[] digits = new char[val.length()-1];
            // Get chars before decimal point
            val.getChars(0, pointPos, digits, 0);
            // Get chars after decimal point
            val.getChars(pointPos+1, val.length(), digits, pointPos);
	    scale = val.length() - pointPos - 1;
            intVal = new BigInteger(digits);
	}

        // Combine exponent into significand
	long longScale = (long)scale - (long)exponent; 	// Avoid errors
							// in calculating scale
	if(longScale > Integer.MAX_VALUE)
	    throw new NumberFormatException("Final scale out of range");
        scale = (int)longScale;

        if (scale < 0) {
            intVal = timesTenToThe(intVal, -scale);
            scale = 0;
        }
    }

    /**
     * Translates a <code>double</code> into a BigDecimal.  The scale
     * of the BigDecimal is the smallest value such that
     * <tt>(10<sup>scale</sup> * val)</tt> is an integer.
     * <p>
     * Note: the results of this constructor can be somewhat unpredictable.
     * One might assume that <tt>new BigDecimal(.1)</tt> is exactly equal
     * to .1, but it is actually equal
     * to .1000000000000000055511151231257827021181583404541015625.
     * This is so because .1 cannot be represented exactly as a double
     * (or, for that matter, as a binary fraction of any finite length).
     * Thus, the long value that is being passed <i>in</i> to the constructor
     * is not exactly equal to .1, appearances notwithstanding.
     * <p>
     * The (String) constructor, on the other hand, is perfectly predictable:
     * <tt>new BigDecimal(".1")</tt> is <i>exactly</i> equal to .1, as one
     * would expect.  Therefore, it is generally recommended that the (String)
     * constructor be used in preference to this one.
     *
     * @param val <code>double</code> value to be converted to BigDecimal.
     * @throws NumberFormatException <tt>val</tt> if <tt>val</tt> is
     *         infinite or NaN.
     */
    public BigDecimal(double val) {
	if (Double.isInfinite(val) || Double.isNaN(val))
	    throw new NumberFormatException("Infinite or NaN");

	/*
	 * Translate the double into sign, exponent and mantissa, according
	 * to the formulae in JLS, Section 20.10.22.
	 */
	long valBits = Double.doubleToLongBits(val);
	int sign = ((valBits >> 63)==0 ? 1 : -1);
	int exponent = (int) ((valBits >> 52) & 0x7ffL);
	long mantissa = (exponent==0 ? (valBits & ((1L<<52) - 1)) << 1
				     : (valBits & ((1L<<52) - 1)) | (1L<<52));
	exponent -= 1075;
	/* At this point, val == sign * mantissa * 2**exponent */

	/*
	 * Special case zero to to supress nonterminating normalization
	 * and bogus scale calculation.
	 */
	if (mantissa == 0) {
	    intVal = BigInteger.ZERO;
	    return;
	}

	/* Normalize */
	while((mantissa & 1) == 0) {    /*  i.e., Mantissa is even */
	    mantissa >>= 1;
	    exponent++;
	}

	/* Calculate intVal and scale */
	intVal = BigInteger.valueOf(sign*mantissa);
	if (exponent < 0) {
	    intVal = intVal.multiply(BigInteger.valueOf(5).pow(-exponent));
	    scale = -exponent;
	} else if (exponent > 0) {
	    intVal = intVal.multiply(BigInteger.valueOf(2).pow(exponent));
	}
    }

    /**
     * Translates a BigInteger into a BigDecimal.  The scale of the BigDecimal
     * is zero.
     *
     * @param val BigInteger value to be converted to BigDecimal.
     */
    public BigDecimal(BigInteger val) {
	intVal = val;
    }

    /**
     * Translates a BigInteger unscaled value and an <code>int</code>
     * scale into a BigDecimal.  The value of the BigDecimal is
     * <tt>(unscaledVal/10<sup>scale</sup>)</tt>.
     *
     * @param unscaledVal unscaled value of the BigDecimal.
     * @param scale scale of the BigDecimal.
     * @throws NumberFormatException scale is negative
     */
    public BigDecimal(BigInteger unscaledVal, int scale) {
	if (scale < 0)
	    throw new NumberFormatException("Negative scale");

	intVal = unscaledVal;
	this.scale = scale;
    }


    // Static Factory Methods

    /**
     * Translates a <code>long</code> unscaled value and an
     * <code>int</code> scale into a BigDecimal.  This &quot;static factory
     * method&quot; is provided in preference to a (<code>long</code>,
     * <code>int</code>) constructor because it allows for reuse of
     * frequently used BigDecimals.
     *
     * @param unscaledVal unscaled value of the BigDecimal.
     * @param scale scale of the BigDecimal.
     * @return a BigDecimal whose value is
     *	       <tt>(unscaledVal/10<sup>scale</sup>)</tt>.
     */
    public static BigDecimal valueOf(long unscaledVal, int scale) {
	return new BigDecimal(BigInteger.valueOf(unscaledVal), scale);
    }

    /**
     * Translates a <code>long</code> value into a BigDecimal with a
     * scale of zero.  This &quot;static factory method&quot; is provided in
     * preference to a (<code>long</code>) constructor because it
     * allows for reuse of frequently used BigDecimals.
     *
     * @param val value of the BigDecimal.
     * @return a BigDecimal whose value is <tt>val</tt>.
     */
    public static BigDecimal valueOf(long val) {
	return valueOf(val, 0);
    }


    // Arithmetic Operations

    /**
     * Returns a BigDecimal whose value is <tt>(this + val)</tt>, and whose
     * scale is <tt>max(this.scale(), val.scale())</tt>.
     *
     * @param  val value to be added to this BigDecimal.
     * @return <tt>this + val</tt>
     */
    public BigDecimal add(BigDecimal val){
	BigDecimal arg[] = new BigDecimal[2];
	arg[0] = this;	arg[1] = val;
	matchScale(arg);
	return new BigDecimal(arg[0].intVal.add(arg[1].intVal), arg[0].scale);
    }

    /**
     * Returns a BigDecimal whose value is <tt>(this - val)</tt>, and whose
     * scale is <tt>max(this.scale(), val.scale())</tt>.
     *
     * @param  val value to be subtracted from this BigDecimal.
     * @return <tt>this - val</tt>
     */
    public BigDecimal subtract(BigDecimal val){
	BigDecimal arg[] = new BigDecimal[2];
	arg[0] = this;	arg[1] = val;
	matchScale(arg);
	return new BigDecimal(arg[0].intVal.subtract(arg[1].intVal),
			      arg[0].scale);
    }

    /**
     * Returns a BigDecimal whose value is <tt>(this * val)</tt>, and whose
     * scale is <tt>(this.scale() + val.scale())</tt>.
     *
     * @param  val value to be multiplied by this BigDecimal.
     * @return <tt>this * val</tt>
     */
    public BigDecimal multiply(BigDecimal val){
	return new BigDecimal(intVal.multiply(val.intVal), scale+val.scale);
    }

    /**
     * Returns a BigDecimal whose value is <tt>(this / val)</tt>, and whose
     * scale is as specified.  If rounding must be performed to generate a
     * result with the specified scale, the specified rounding mode is
     * applied.
     *
     * @param  val value by which this BigDecimal is to be divided.
     * @param  scale scale of the BigDecimal quotient to be returned.
     * @param  roundingMode rounding mode to apply.
     * @return <tt>this / val</tt>
     * @throws ArithmeticException <tt>val</tt> is zero, <tt>scale</tt> is
     *	       negative, or <tt>roundingMode==ROUND_UNNECESSARY</tt> and
     *	       the specified scale is insufficient to represent the result
     *	       of the division exactly.
     * @throws IllegalArgumentException <tt>roundingMode</tt> does not
     *	       represent a valid rounding mode.
     * @see    #ROUND_UP
     * @see    #ROUND_DOWN
     * @see    #ROUND_CEILING
     * @see    #ROUND_FLOOR
     * @see    #ROUND_HALF_UP
     * @see    #ROUND_HALF_DOWN
     * @see    #ROUND_HALF_EVEN
     * @see    #ROUND_UNNECESSARY
     */
    public BigDecimal divide(BigDecimal val, int scale, int roundingMode) {
	if (scale < 0)
	    throw new ArithmeticException("Negative scale");
	if (roundingMode < ROUND_UP || roundingMode > ROUND_UNNECESSARY)
	    throw new IllegalArgumentException("Invalid rounding mode");

	/*
	 * Rescale dividend or divisor (whichever can be "upscaled" to
	 * produce correctly scaled quotient).
	 */
	BigDecimal dividend, divisor;
	if (scale + val.scale >= this.scale) {
	    dividend = this.setScale(scale + val.scale);
	    divisor = val;
	} else {
	    dividend = this;
	    divisor = val.setScale(this.scale - scale);
	}

	/* Do the division and return result if it's exact */
	BigInteger i[] = dividend.intVal.divideAndRemainder(divisor.intVal);
	BigInteger q = i[0], r = i[1];
	if (r.signum() == 0)
	    return new BigDecimal(q, scale);
	else if (roundingMode == ROUND_UNNECESSARY) /* Rounding prohibited */
	    throw new ArithmeticException("Rounding necessary");

	/* Round as appropriate */
	int signum = dividend.signum() * divisor.signum(); /* Sign of result */
	boolean increment;
	if (roundingMode == ROUND_UP) {		    /* Away from zero */
	    increment = true;
	} else if (roundingMode == ROUND_DOWN) {    /* Towards zero */
	    increment = false;
	} else if (roundingMode == ROUND_CEILING) { /* Towards +infinity */
	    increment = (signum > 0);
	} else if (roundingMode == ROUND_FLOOR) {   /* Towards -infinity */
	    increment = (signum < 0);
	} else { /* Remaining modes based on nearest-neighbor determination */
	    int cmpFracHalf = r.abs().multiply(BigInteger.valueOf(2)).
					 compareTo(divisor.intVal.abs());
	    if (cmpFracHalf < 0) {	   /* We're closer to higher digit */
		increment = false;
	    } else if (cmpFracHalf > 0) {  /* We're closer to lower digit */
		increment = true;
	    } else { 			   /* We're dead-center */
		if (roundingMode == ROUND_HALF_UP)
		    increment = true;
		else if (roundingMode == ROUND_HALF_DOWN)
		    increment = false;
		else  /* roundingMode == ROUND_HALF_EVEN */
		    increment = q.testBit(0);	/* true iff q is odd */
	    }
	}
	return (increment
		? new BigDecimal(q.add(BigInteger.valueOf(signum)), scale)
		: new BigDecimal(q, scale));
    }

    /**
     * Returns a BigDecimal whose value is <tt>(this / val)</tt>, and whose
     * scale is <tt>this.scale()</tt>.  If rounding must be performed to
     * generate a result with the given scale, the specified rounding mode is
     * applied.
     *
     * @param  val value by which this BigDecimal is to be divided.
     * @param  roundingMode rounding mode to apply.
     * @return <tt>this / val</tt>
     * @throws ArithmeticException <tt>val==0</tt>, or
     * 	       <tt>roundingMode==ROUND_UNNECESSARY</tt> and
     *	       <tt>this.scale()</tt> is insufficient to represent the result
     *	       of the division exactly.
     * @throws IllegalArgumentException <tt>roundingMode</tt> does not
     *	       represent a valid rounding mode.
     * @see    #ROUND_UP
     * @see    #ROUND_DOWN
     * @see    #ROUND_CEILING
     * @see    #ROUND_FLOOR
     * @see    #ROUND_HALF_UP
     * @see    #ROUND_HALF_DOWN
     * @see    #ROUND_HALF_EVEN
     * @see    #ROUND_UNNECESSARY
     */
    public BigDecimal divide(BigDecimal val, int roundingMode) {
	    return this.divide(val, scale, roundingMode);
    }

   /**
    * Returns a BigDecimal whose value is the absolute value of this
    * BigDecimal, and whose scale is <tt>this.scale()</tt>.
    *
    * @return <tt>abs(this)</tt>
    */
    public BigDecimal abs(){
	return (signum() < 0 ? negate() : this);
    }

    /**
     * Returns a BigDecimal whose value is <tt>(-this)</tt>, and whose scale
     * is <tt>this.scale()</tt>.
     *
     * @return <tt>-this</tt>
     */
    public BigDecimal negate(){
	return new BigDecimal(intVal.negate(), scale);
    }

    /**
     * Returns the signum function of this BigDecimal.
     *
     * @return -1, 0 or 1 as the value of this BigDecimal is negative, zero or
     *	       positive.
     */
    public int signum(){
	return intVal.signum();
    }

    /**
     * Returns the <i>scale</i> of this BigDecimal.  (The scale is the number
     * of digits to the right of the decimal point.)
     *
     * @return the scale of this BigDecimal.
     */
    public int scale() {
	return scale;
    }

    /**
     * Returns a BigInteger whose value is the <i>unscaled value</i> of this
     * BigDecimal.  (Computes <tt>(this * 10<sup>this.scale()</sup>)</tt>.)
     *
     * @return the unscaled value of this BigDecimal.
     * @since   1.2
     */
    public BigInteger unscaledValue() {
        return intVal;
    }


    // Rounding Modes

    /**
     * Rounding mode to round away from zero.  Always increments the
     * digit prior to a non-zero discarded fraction.  Note that this rounding
     * mode never decreases the magnitude of the calculated value.
     */
    public final static int ROUND_UP = 		 0;

    /**
     * Rounding mode to round towards zero.  Never increments the digit
     * prior to a discarded fraction (i.e., truncates).  Note that this
     * rounding mode never increases the magnitude of the calculated value.
     */
    public final static int ROUND_DOWN = 	 1;

    /**
     * Rounding mode to round towards positive infinity.  If the
     * BigDecimal is positive, behaves as for <tt>ROUND_UP</tt>; if negative,
     * behaves as for <tt>ROUND_DOWN</tt>.  Note that this rounding mode never
     * decreases the calculated value.
     */
    public final static int ROUND_CEILING = 	 2;

    /**
     * Rounding mode to round towards negative infinity.  If the
     * BigDecimal is positive, behave as for <tt>ROUND_DOWN</tt>; if negative,
     * behave as for <tt>ROUND_UP</tt>.  Note that this rounding mode never
     * increases the calculated value.
     */
    public final static int ROUND_FLOOR = 	 3;

    /**
     * Rounding mode to round towards "nearest neighbor" unless both
     * neighbors are equidistant, in which case round up.
     * Behaves as for <tt>ROUND_UP</tt> if the discarded fraction is &gt;= .5;
     * otherwise, behaves as for <tt>ROUND_DOWN</tt>.  Note that this is the
     * rounding mode that most of us were taught in grade school.
     */
    public final static int ROUND_HALF_UP = 	 4;

    /**
     * Rounding mode to round towards "nearest neighbor" unless both
     * neighbors are equidistant, in which case round down.
     * Behaves as for <tt>ROUND_UP</tt> if the discarded fraction is &gt; .5;
     * otherwise, behaves as for <tt>ROUND_DOWN</tt>.
     */
    public final static int ROUND_HALF_DOWN = 	 5;

    /**
     * Rounding mode to round towards the "nearest neighbor" unless both
     * neighbors are equidistant, in which case, round towards the even
     * neighbor.  Behaves as for ROUND_HALF_UP if the digit to the left of the
     * discarded fraction is odd; behaves as for ROUND_HALF_DOWN if it's even.
     * Note that this is the rounding mode that minimizes cumulative error
     * when applied repeatedly over a sequence of calculations.
     */
    public final static int ROUND_HALF_EVEN = 	 6;

    /**
     * Rounding mode to assert that the requested operation has an exact
     * result, hence no rounding is necessary.  If this rounding mode is
     * specified on an operation that yields an inexact result, an
     * <tt>ArithmeticException</tt> is thrown.
     */
    public final static int ROUND_UNNECESSARY =  7;


    // Scaling/Rounding Operations

    /**
     * Returns a BigDecimal whose scale is the specified value, and whose
     * unscaled value is determined by multiplying or dividing this
     * BigDecimal's unscaled value by the appropriate power of ten to maintain
     * its overall value.  If the scale is reduced by the operation, the
     * unscaled value must be divided (rather than multiplied), and the value
     * may be changed; in this case, the specified rounding mode is applied to
     * the division.
     * <p>
     * Note that since BigDecimal objects are immutable, calls of this
     * method do <i>not</i> result in the original object being
     * modified, contrary to the usual convention of having methods
     * named <code>set<i>X</i></code> mutate field
     * <code><i>X</i></code>.  Instead, <code>setScale</code> returns
     * an object with the proper scale; the returned object may or may
     * not be newly allocated.
     *
     * @param  scale scale of the BigDecimal value to be returned.
     * @param  roundingMode The rounding mode to apply.
     * @return a BigDecimal whose scale is the specified value, and whose
     *	       unscaled value is determined by multiplying or dividing this
     * 	       BigDecimal's unscaled value by the appropriate power of ten to
     *	       maintain its overall value.
     * @throws ArithmeticException <tt>scale</tt> is negative, or
     * 	       <tt>roundingMode==ROUND_UNNECESSARY</tt> and the specified
     *	       scaling operation would require rounding.
     * @throws IllegalArgumentException <tt>roundingMode</tt> does not
     *	       represent a valid rounding mode.
     * @see    #ROUND_UP
     * @see    #ROUND_DOWN
     * @see    #ROUND_CEILING
     * @see    #ROUND_FLOOR
     * @see    #ROUND_HALF_UP
     * @see    #ROUND_HALF_DOWN
     * @see    #ROUND_HALF_EVEN
     * @see    #ROUND_UNNECESSARY
     */
    public BigDecimal setScale(int scale, int roundingMode) {
	if (scale < 0)
	    throw new ArithmeticException("Negative scale");
	if (roundingMode < ROUND_UP || roundingMode > ROUND_UNNECESSARY)
	    throw new IllegalArgumentException("Invalid rounding mode");

	/* Handle the easy cases */
	if (scale == this.scale)
	    return this;
	else if (scale > this.scale)
	    return new BigDecimal(timesTenToThe(intVal, scale-this.scale),
				  scale);
	else /* scale < this.scale */
	    return divide(valueOf(1), scale, roundingMode);
    }

    /**
     * Returns a BigDecimal whose scale is the specified value, and whose
     * value is numerically equal to this BigDecimal's.  Throws an
     * ArithmeticException if this is not possible.  This call is typically
     * used to increase the scale, in which case it is guaranteed that there
     * exists a BigDecimal of the specified scale and the correct value.  The
     * call can also be used to reduce the scale if the caller knows that the
     * BigDecimal has sufficiently many zeros at the end of its fractional
     * part (i.e., factors of ten in its integer value) to allow for the
     * rescaling without loss of precision.
     * <p>
     * This method returns the same result as the two argument version
     * of setScale, but saves the caller the trouble of specifying a
     * rounding mode in cases where it is irrelevant.
     * <p>
     * Note that since BigDecimal objects are immutable, calls of this
     * method do <i>not</i> result in the original object being
     * modified, contrary to the usual convention of having methods
     * named <code>set<i>X</i></code> mutate field
     * <code><i>X</i></code>.  Instead, <code>setScale</code> returns
     * an object with the proper scale; the returned object may or may
     * not be newly allocated.
     *
     * @param  scale scale of the BigDecimal value to be returned.
     * @return a BigDecimal whose scale is the specified value, and whose
     *	       unscaled value is determined by multiplying or dividing this
     * 	       BigDecimal's unscaled value by the appropriate power of ten to
     *	       maintain its overall value.
     * @throws ArithmeticException <tt>scale</tt> is negative, or
     * 	       the specified scaling operation would require rounding.
     * @see    #setScale(int, int)
     */
    public BigDecimal setScale(int scale) {
	return setScale(scale, ROUND_UNNECESSARY);
    }


    // Decimal Point Motion Operations

    /**
     * Returns a BigDecimal which is equivalent to this one with the decimal
     * point moved n places to the left.  If n is non-negative, the call merely
     * adds n to the scale.  If n is negative, the call is equivalent to
     * movePointRight(-n).  (The BigDecimal returned by this call has value
     * <tt>(this * 10<sup>-n</sup>)</tt> and scale
     * <tt>max(this.scale()+n, 0)</tt>.)
     *
     * @param  n number of places to move the decimal point to the left.
     * @return a BigDecimal which is equivalent to this one with the decimal
     *	       point moved <tt>n</tt> places to the left.
     */
    public BigDecimal movePointLeft(int n){
	return (n>=0 ? new BigDecimal(intVal, scale+n) : movePointRight(-n));
    }

    /**
     * Moves the decimal point the specified number of places to the right.
     * If this BigDecimal's scale is &gt;= <tt>n</tt>, the call merely
     * subtracts <tt>n</tt> from the scale; otherwise, it sets the scale to
     * zero, and multiplies the integer value by
     * <tt>10<sup>(n - this.scale)</sup></tt>.  If <tt>n</tt>
     * is negative, the call is equivalent to <tt>movePointLeft(-n)</tt>. (The
     * BigDecimal returned by this call has value
     * <tt>(this * 10<sup>n</sup>)</tt> and scale
     * <tt>max(this.scale()-n, 0)</tt>.)
     *
     * @param  n number of places to move the decimal point to the right.
     * @return a BigDecimal which is equivalent to this one with the decimal
     *         point moved <tt>n</tt> places to the right.
     */
    public BigDecimal movePointRight(int n){
	return (scale >= n ? new BigDecimal(intVal, scale-n)
		           : new BigDecimal(timesTenToThe(intVal, n-scale),0));
    }

    // Comparison Operations

    /**
     * Compares this BigDecimal with the specified BigDecimal.   Two
     * BigDecimals that are equal in value but have a different scale (like
     * 2.0 and 2.00) are considered equal by this method.  This method is
     * provided in preference to individual methods for each of the six
     * boolean comparison operators (&lt;, ==, &gt;, &gt;=, !=, &lt;=).  The
     * suggested idiom for performing these comparisons is:
     * <tt>(x.compareTo(y)</tt> &lt;<i>op</i>&gt; <tt>0)</tt>,
     * where &lt;<i>op</i>&gt; is one of the six comparison operators.
     *
     * @param  val BigDecimal to which this BigDecimal is to be compared.
     * @return -1, 0 or 1 as this BigDecimal is numerically less than, equal
     *         to, or greater than <tt>val</tt>.
     */
    public int compareTo(BigDecimal val){
	/* Optimization: would run fine without the next three lines */
	int sigDiff = signum() - val.signum();
	if (sigDiff != 0)
	    return (sigDiff > 0 ? 1 : -1);

	/* If signs match, scale and compare intVals */
	BigDecimal arg[] = new BigDecimal[2];
	arg[0] = this;	arg[1] = val;
	matchScale(arg);
	return arg[0].intVal.compareTo(arg[1].intVal);
    }

    /**
     * Compares this BigDecimal with the specified Object.  If the Object is a
     * BigDecimal, this method behaves like {@link #compareTo compareTo}.
     * Otherwise, it throws a <tt>ClassCastException</tt> (as BigDecimals are
     * comparable only to other BigDecimals).
     *
     * @param  o Object to which this BigDecimal is to be compared.
     * @return a negative number, zero, or a positive number as this
     *	       BigDecimal is numerically less than, equal to, or greater
     *	       than <tt>o</tt>, which must be a BigDecimal.
     * @throws ClassCastException <tt>o</tt> is not a BigDecimal.
     * @see    #compareTo(java.math.BigDecimal)
     * @see    Comparable
     * @since  1.2
     */
    public int compareTo(Object o) {
	return compareTo((BigDecimal)o);
    }

    /**
     * Compares this BigDecimal with the specified Object for
     * equality.  Unlike {@link #compareTo compareTo}, this method
     * considers two BigDecimals equal only if they are equal in value
     * and scale (thus 2.0 is not equal to 2.00 when compared by this
     * method).
     *
     * @param  x Object to which this BigDecimal is to be compared.
     * @return <tt>true</tt> if and only if the specified Object is a
     *	       BigDecimal whose value and scale are equal to this BigDecimal's.
     * @see    #compareTo(java.math.BigDecimal)
     */
    public boolean equals(Object x){
	if (!(x instanceof BigDecimal))
	    return false;
	BigDecimal xDec = (BigDecimal) x;

	return scale == xDec.scale && intVal.equals(xDec.intVal);
    }

    /**
     * Returns the minimum of this BigDecimal and <tt>val</tt>.
     *
     * @param  val value with which the minimum is to be computed.
     * @return the BigDecimal whose value is the lesser of this BigDecimal and
     *	       <tt>val</tt>.  If they are equal, as defined by the
     * 	       {@link #compareTo compareTo} method, either may be returned.
     * @see    #compareTo(java.math.BigDecimal)
     */
    public BigDecimal min(BigDecimal val){
	return (compareTo(val)<0 ? this : val);
    }

    /**
     * Returns the maximum of this BigDecimal and <tt>val</tt>.
     *
     * @param  val value with which the maximum is to be computed.
     * @return the BigDecimal whose value is the greater of this BigDecimal
     *	       and <tt>val</tt>.  If they are equal, as defined by the
     * 	       {@link #compareTo compareTo} method, either may be returned.
     * @see    #compareTo(java.math.BigDecimal)
     */
    public BigDecimal max(BigDecimal val){
	return (compareTo(val)>0 ? this : val);
    }


    // Hash Function

    /**
     * Returns the hash code for this BigDecimal.  Note that two BigDecimals
     * that are numerically equal but differ in scale (like 2.0 and 2.00)
     * will generally <i>not</i> have the same hash code.
     *
     * @return hash code for this BigDecimal.
     */
    public int hashCode() {
	return 31*intVal.hashCode() + scale;
    }

    //
    // add one to the least significant digit.
    // in the unlikely event there is a carry out,
    // deal with it.
    //
    private String
    roundup(String val){
	int i;
        char[] digits = val.toCharArray();
        int nDigits = digits.length;

	int q = digits[ i = (nDigits-1)];
	if ( q == '9' ){
	    while ( q == '9' && i > 0 ){
		digits[i] = '0';
		q = digits[--i];
	    }
	    if ( q == '9' ){
		// carryout! High-order 1, rest 0s, larger exp.
		digits[0] = '0';
		return "1" + String.valueOf(digits);
	    }
	    // else fall through.
	}
	digits[i] = (char)(q+1);
        return String.valueOf(digits);
    }



    // Format Converters

    /**
     * Returns the string representation of this BigDecimal.  The digit-to-
     * character mapping provided by {@link Character#forDigit} is used.
     * A leading minus sign is used to indicate sign, and the number of digits
     * to the right of the decimal point is used to indicate scale.  (This
     * representation is compatible with the (String) constructor.)
     *
     * @return String representation of this BigDecimal.
     * @see    Character#forDigit
     * @see    #BigDecimal(java.lang.String)
     */
    public String toString(){
	if (scale == 0)	/* No decimal point */
	    return intVal.toString();
        return getValueString(signum(), intVal.abs().toString(), scale);
    }

    /**
     * Converts this BigDecimal to a BigInteger.  This conversion is
     * analogous to a <a
     * href="http://java.sun.com/docs/books/jls/second_edition/html/conversions.doc.html#25363"><i>narrowing
     * primitive conversion</i></a> from <code>double</code> to
     * <code>long</code> as defined in the <a
     * href="http://java.sun.com/docs/books/jls/html/">Java Language
     * Specification</a>: any fractional part of this BigDecimal will
     * be discarded.  Note that this conversion can lose information
     * about the precision of the BigDecimal value.
     *
     * @return this BigDecimal converted to a BigInteger.
     */
    public BigInteger toBigInteger() {
	return (scale==0 ? intVal
			 : intVal.divide(BigInteger.valueOf(10).pow(scale)));
    }

    /**
     * Converts this BigDecimal to an <code>int</code>.  This
     * conversion is analogous to a <a
     * href="http://java.sun.com/docs/books/jls/second_edition/html/conversions.doc.html#25363"><i>narrowing
     * primitive conversion</i></a> from <code>double</code> to
     * <code>short</code> as defined in the <a
     * href="http://java.sun.com/docs/books/jls/html/">Java Language
     * Specification</a>: any fractional part of this BigDecimal will
     * be discarded, and if the resulting &quot;BigInteger&quot; is
     * too big to fit in an <code>int</code>, only the low-order 32
     * bits are returned.  Note that this conversion can lose
     * information about the overall magnitude and precision of the
     * BigDecimal value as well as return a result with the opposite
     * sign.
     *
     * @return this BigDecimal converted to an <code>int</code>.
     */
    public int intValue(){
	return toBigInteger().intValue();
    }

    /**
     * Converts this BigDecimal to a <code>long</code>.  This
     * conversion is analogous to a <a
     * href="http://java.sun.com/docs/books/jls/second_edition/html/conversions.doc.html#25363"><i>narrowing
     * primitive conversion</i></a> from <code>double</code> to
     * <code>short</code> as defined in the <a
     * href="http://java.sun.com/docs/books/jls/html/">Java Language
     * Specification</a>: any fractional part of this BigDecimal will
     * be discarded, and if the resulting &quot;BigInteger&quot; is
     * too big to fit in a <code>long</code>, only the low-order 64
     * bits are returned.  Note that this conversion can lose
     * information about the overall magnitude and precision of the
     * BigDecimal value as well as return a result with the opposite
     * sign.
     *
     * @return this BigDecimal converted to an <code>long</code>.
     */
    public long longValue(){
	return toBigInteger().longValue();
    }

    /**
     * Converts this BigDecimal to a <code>float</code>.  This
     * conversion is similar to the <a
     * href="http://java.sun.com/docs/books/jls/second_edition/html/conversions.doc.html#25363"><i>narrowing
     * primitive conversion</i></a> from <code>double</code> to
     * <code>float</code> defined in the <a
     * href="http://java.sun.com/docs/books/jls/html/">Java Language
     * Specification</a>: if this BigDecimal has too great a magnitude
     * to represent as a <code>float</code>, it will be converted to
     * {@link Float#NEGATIVE_INFINITY} or {@link
     * Float#POSITIVE_INFINITY} as appropriate.  Note that even when
     * the return value is finite, this conversion can lose
     * information about the precision of the BigDecimal value.
     *
     * @return this BigDecimal converted to a <code>float</code>.
     */
    public float floatValue(){
	/* Somewhat inefficient, but guaranteed to work. */
	return Float.valueOf(this.toString()).floatValue();
    }

    /**
     * Converts this BigDecimal to a <code>double</code>.  This
     * conversion is similar to the <a
     * href="http://java.sun.com/docs/books/jls/second_edition/html/conversions.doc.html#25363"><i>narrowing
     * primitive conversion</i></a> from <code>double</code> to
     * <code>float</code> as defined in the <a
     * href="http://java.sun.com/docs/books/jls/html/">Java Language
     * Specification</a>: if this BigDecimal has too great a magnitude
     * represent as a <code>double</code>, it will be converted to
     * {@link Double#NEGATIVE_INFINITY} or {@link
     * Double#POSITIVE_INFINITY} as appropriate.  Note that even when
     * the return value is finite, this conversion can lose
     * information about the precision of the BigDecimal value.
     *
     * @return this BigDecimal converted to a <code>double</code>.
     */
    public double doubleValue(){
	/* Somewhat inefficient, but guaranteed to work. */
	return Double.valueOf(this.toString()).doubleValue();
    }


    // Private "Helper" Methods

    /* Returns a digit.digit string */
    private String getValueString(int signum, String intString, int scale) {
 	/* Insert decimal point */
 	StringBuffer buf;
 	int insertionPoint = intString.length() - scale;
 	if (insertionPoint == 0) {  /* Point goes right before intVal */
 	    return (signum<0 ? "-0." : "0.") + intString;
 	} else if (insertionPoint > 0) { /* Point goes inside intVal */
 	    buf = new StringBuffer(intString);
 	    buf.insert(insertionPoint, '.');
 	    if (signum < 0)
 		buf.insert(0, '-');
 	} else { /* We must insert zeros between point and intVal */
 	    buf = new StringBuffer(3-insertionPoint + intString.length());
 	    buf.append(signum<0 ? "-0." : "0.");
 	    for (int i=0; i<-insertionPoint; i++)
 		buf.append('0');
 	    buf.append(intString);
 	}
 	return buf.toString();
    }

    /* Returns (a * 10^b) */
    private static BigInteger timesTenToThe(BigInteger a, int b) {
	return a.multiply(BigInteger.valueOf(10).pow(b));
    }

    /*
     * If the scales of val[0] and val[1] differ, rescale (non-destructively)
     * the lower-scaled BigDecimal so they match.
     */
    private static void matchScale(BigDecimal[] val) {
	if (val[0].scale < val[1].scale)
	    val[0] = val[0].setScale(val[1].scale);
	else if (val[1].scale < val[0].scale)
	    val[1] = val[1].setScale(val[0].scale);
    }
}
