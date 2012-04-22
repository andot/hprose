############################################################
#                                                          #
#                          hprose                          #
#                                                          #
# Official WebSite: http://www.hprose.com/                 #
#                   http://www.hprose.net/                 #
#                   http://www.hprose.com/                 #
#                                                          #
############################################################

############################################################
#                                                          #
# fpconst.py                                               #
#                                                          #
# fpconst for python 3.0+                                  #
#                                                          #
# LastModified: May 16, 2010                               #
# Author: Ma Bingyao <andot@hprfc.com>                     #
#                                                          #
############################################################

# This python module implements constants and functions for
# working with IEEE754 double-precision special values. It
# provides constants for Not-a-Number (NaN), Positive
# Infinity (PosInf), and Negative Infinity (NegInf), as well
# as functions to test for these values.
#
# More: http://www.python.org/dev/peps/pep-0754/

PosInf = 1e300000
NegInf = -PosInf
NaN = PosInf/PosInf

def isPosInf(value):
    return PosInf == value

def isNegInf(value):
    return NegInf == value

def isInf(value):
    return PosInf == value or NegInf == value

def isFinite(value):
    return PosInf > value > NegInf

def isNaN(value):
    return isinstance(value, float) and value != value

if __name__ == "__main__":
    def test_isNaN():
        assert( not isNaN(PosInf) )
        assert( not isNaN(NegInf) )
        assert(     isNaN(NaN   ) )
        assert( not isNaN(   1.0) )
        assert( not isNaN(  -1.0) )

    def test_isInf():
        assert(     isInf(PosInf) )
        assert(     isInf(NegInf) )
        assert( not isInf(NaN   ) )
        assert( not isInf(   1.0) )
        assert( not isInf(  -1.0) )

    def test_isFinite():
        assert( not isFinite(PosInf) )
        assert( not isFinite(NegInf) )
        assert( not isFinite(NaN   ) )
        assert(     isFinite(   1.0) )
        assert(     isFinite(  -1.0) )

    def test_isPosInf():
        assert(     isPosInf(PosInf) )
        assert( not isPosInf(NegInf) )
        assert( not isPosInf(NaN   ) )
        assert( not isPosInf(   1.0) )
        assert( not isPosInf(  -1.0) )

    def test_isNegInf():
        assert( not isNegInf(PosInf) )
        assert(     isNegInf(NegInf) )
        assert( not isNegInf(NaN   ) )
        assert( not isNegInf(   1.0) )
        assert( not isNegInf(  -1.0) )

    # overall test
    def test():
        test_isNaN()
        test_isInf()
        test_isFinite()
        test_isPosInf()
        test_isNegInf()

    test()