using System;
using System.Diagnostics;
using System.Globalization;
using System.Runtime.InteropServices;

namespace System.Numerics {

    [StructLayout(LayoutKind.Sequential)]
    public struct BigInteger : IFormattable, IComparable
#if !(dotNET10 || dotNET11 || dotNETCF10)
        , IComparable<BigInteger>, IEquatable<BigInteger>
#endif
    {
        private const int knMaskHighBit = -2147483648;
        private const uint kuMaskHighBit = 0x80000000;
        private const int kcbitUint = 0x20;
        private const int kcbitUlong = 0x40;
        private const int DecimalScaleFactorMask = 0xff0000;
        private const int DecimalSignMask = -2147483648;
        internal int _sign;
        internal uint[] _bits;
        private static readonly BigInteger s_bnMinInt;
        private static readonly BigInteger s_bnOneInt;
        private static readonly BigInteger s_bnZeroInt;
        private static readonly BigInteger s_bnMinusOneInt;

        public static BigInteger Zero {
            get {
                return s_bnZeroInt;
            }
        }

        public static BigInteger One {
            get {
                return s_bnOneInt;
            }
        }

        public static BigInteger MinusOne {
            get {
                return s_bnMinusOneInt;
            }
        }

        public bool IsPowerOfTwo {
            get {
                if (this._bits == null) {
                    return (((this._sign & (this._sign - 1)) == 0) && (this._sign != 0));
                }
                if (this._sign == 1) {
                    int index = Length(this._bits) - 1;
                    if ((this._bits[index] & (this._bits[index] - 1)) == 0) {
                        while (--index >= 0) {
                            if (this._bits[index] != 0) {
                                return false;
                            }
                        }
                        return true;
                    }
                }
                return false;
            }
        }

        public bool IsZero {
            get {
                return (this._sign == 0);
            }
        }

        public bool IsOne {
            get {
                return ((this._sign == 1) && (this._bits == null));
            }
        }

        public bool IsEven {
            get {
                if (this._bits != null) {
                    return ((this._bits[0] & 1) == 0);
                }
                return ((this._sign & 1) == 0);
            }
        }

        public int Sign {
            get {
                return ((this._sign >> 0x1f) - (-this._sign >> 0x1f));
            }
        }

        public override bool Equals(object obj) {
            return ((obj is BigInteger) && this.Equals((BigInteger)obj));
        }

        public override int GetHashCode() {
            if (this._bits == null) {
                return this._sign;
            }
            int num = this._sign;
            int index = Length(this._bits);
            while (--index >= 0) {
                num = NumericsHelpers.CombineHash(num, (int)this._bits[index]);
            }
            return num;
        }

        public bool Equals(long other) {
            int num;
            if (this._bits == null) {
                return (this._sign == other);
            }
            if (((this._sign ^ other) < 0L) || ((num = Length(this._bits)) > 2)) {
                return false;
            }
            ulong num2 = (other < 0L) ? ((ulong)-other) : ((ulong)other);
            if (num == 1) {
                return (this._bits[0] == num2);
            }
            return (NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) == num2);
        }

        [CLSCompliant(false)]
        public bool Equals(ulong other) {
            if (this._sign < 0) {
                return false;
            }
            if (this._bits == null) {
                return ((ulong)this._sign == other);
            }
            int num = Length(this._bits);
            if (num > 2) {
                return false;
            }
            if (num == 1) {
                return (this._bits[0] == other);
            }
            return (NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) == other);
        }

        public bool Equals(BigInteger other) {
            if (this._sign != other._sign) {
                return false;
            }
            if (this._bits == other._bits) {
                return true;
            }
            if ((this._bits == null) || (other._bits == null)) {
                return false;
            }
            int cu = Length(this._bits);
            if (cu != Length(other._bits)) {
                return false;
            }
            return (GetDiffLength(this._bits, other._bits, cu) == 0);
        }

        public int CompareTo(long other) {
            int num;
            if (this._bits == null) {
                long num4 = this._sign;
                return num4.CompareTo(other);
            }
            if (((this._sign ^ other) < 0L) || ((num = Length(this._bits)) > 2)) {
                return this._sign;
            }
            ulong num2 = (other < 0L) ? ((ulong)-other) : ((ulong)other);
            ulong num3 = (num == 2) ? NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) : ((ulong)this._bits[0]);
            return (this._sign * num3.CompareTo(num2));
        }

        [CLSCompliant(false)]
        public int CompareTo(ulong other) {
            if (this._sign < 0) {
                return -1;
            }
            if (this._bits == null) {
                ulong num3 = (ulong)this._sign;
                return num3.CompareTo(other);
            }
            int num = Length(this._bits);
            if (num > 2) {
                return 1;
            }
            ulong num2 = (num == 2) ? NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) : ((ulong)this._bits[0]);
            return num2.CompareTo(other);
        }

        public int CompareTo(BigInteger other) {
            int num;
            int num2;
            if ((this._sign ^ other._sign) < 0) {
                if (this._sign >= 0) {
                    return 1;
                }
                return -1;
            }
            if (this._bits == null) {
                if (other._bits != null) {
                    return -other._sign;
                }
                if (this._sign < other._sign) {
                    return -1;
                }
                if (this._sign <= other._sign) {
                    return 0;
                }
                return 1;
            }
            if ((other._bits == null) || ((num = Length(this._bits)) > (num2 = Length(other._bits)))) {
                return this._sign;
            }
            if (num >= num2) {
                int num3 = GetDiffLength(this._bits, other._bits, num);
                if (num3 == 0) {
                    return 0;
                }
                if (this._bits[num3 - 1] >= other._bits[num3 - 1]) {
                    return this._sign;
                }
            }
            return -this._sign;
        }

        public int CompareTo(object obj) {
            if (obj == null) {
                return 1;
            }
            if (!(obj is BigInteger)) {
                throw new ArgumentException("The parameter must be a BigInteger.");
            }
            return this.CompareTo((BigInteger)obj);
        }

        public byte[] ToByteArray() {
            uint[] numArray;
            byte num;
            if ((this._bits == null) && (this._sign == 0)) {
                return new byte[1];
            }
            if (this._bits == null) {
                numArray = new uint[] { (uint)this._sign };
                num = (this._sign < 0) ? ((byte)0xff) : ((byte)0);
            }
            else if (this._sign == -1) {
                numArray = (uint[])this._bits.Clone();
                NumericsHelpers.DangerousMakeTwosComplement(numArray);
                num = 0xff;
            }
            else {
                numArray = this._bits;
                num = 0;
            }
            byte[] sourceArray = new byte[4 * numArray.Length];
            int num2 = 0;
            for (int i = 0; i < numArray.Length; i++) {
                uint num3 = numArray[i];
                for (int j = 0; j < 4; j++) {
                    sourceArray[num2++] = (byte)(num3 & 0xff);
                    num3 = num3 >> 8;
                }
            }
            int index = sourceArray.Length - 1;
            while (index > 0) {
                if (sourceArray[index] != num) {
                    break;
                }
                index--;
            }
            bool flag = (sourceArray[index] & 0x80) != (num & 0x80);
            byte[] destinationArray = new byte[(index + 1) + (flag ? 1 : 0)];
            Array.Copy(sourceArray, 0, destinationArray, 0, (int)(index + 1));
            if (flag) {
                destinationArray[destinationArray.Length - 1] = num;
            }
            return destinationArray;
        }

        private uint[] ToUInt32Array() {
            uint[] numArray;
            uint maxValue;
            if ((this._bits == null) && (this._sign == 0)) {
                return new uint[1];
            }
            if (this._bits == null) {
                numArray = new uint[] { (uint)this._sign };
                maxValue = (this._sign < 0) ? uint.MaxValue : 0;
            }
            else if (this._sign == -1) {
                numArray = (uint[])this._bits.Clone();
                NumericsHelpers.DangerousMakeTwosComplement(numArray);
                maxValue = uint.MaxValue;
            }
            else {
                numArray = this._bits;
                maxValue = 0;
            }
            int index = numArray.Length - 1;
            while (index > 0) {
                if (numArray[index] != maxValue) {
                    break;
                }
                index--;
            }
            bool flag = (numArray[index] & 0x80000000) != (maxValue & 0x80000000);
            uint[] destinationArray = new uint[(index + 1) + (flag ? 1 : 0)];
            Array.Copy(numArray, 0, destinationArray, 0, (int)(index + 1));
            if (flag) {
                destinationArray[destinationArray.Length - 1] = maxValue;
            }
            return destinationArray;
        }

        public override string ToString() {
            return BigNumber.FormatBigInteger(this, null, NumberFormatInfo.CurrentInfo);
        }

        public string ToString(IFormatProvider provider) {
            return BigNumber.FormatBigInteger(this, null, NumberFormatInfo.GetInstance(provider));
        }

        public string ToString(string format) {
            return BigNumber.FormatBigInteger(this, format, NumberFormatInfo.CurrentInfo);
        }

        public string ToString(string format, IFormatProvider provider) {
            return BigNumber.FormatBigInteger(this, format, NumberFormatInfo.GetInstance(provider));
        }

        public BigInteger(int value) {
            if (value == -2147483648) {
                this = s_bnMinInt;
            }
            else {
                this._sign = value;
                this._bits = null;
            }
        }

        [CLSCompliant(false)]
        public BigInteger(uint value) {
            if (value <= 0x7fffffff) {
                this._sign = (int)value;
                this._bits = null;
            }
            else {
                this._sign = 1;
                this._bits = new uint[] { value };
            }
        }

        public BigInteger(long value) {
            if ((-2147483648L <= value) && (value <= 0x7fffffffL)) {
                if (value == -2147483648L) {
                    this = s_bnMinInt;
                }
                else {
                    this._sign = (int)value;
                    this._bits = null;
                }
            }
            else {
                ulong num = 0L;
                if (value < 0L) {
                    num = (ulong)-value;
                    this._sign = -1;
                }
                else {
                    num = (ulong)value;
                    this._sign = 1;
                }
                this._bits = new uint[] { (uint)num, (uint)(num >> 0x20) };
            }
        }

        [CLSCompliant(false)]
        public BigInteger(ulong value) {
            if (value <= 0x7fffffffL) {
                this._sign = (int)value;
                this._bits = null;
            }
            else {
                this._sign = 1;
                this._bits = new uint[] { (uint)value, (uint)(value >> 0x20) };
            }
        }

        public BigInteger(float value) {
            if (float.IsInfinity(value)) {
                throw new OverflowException("BigInteger cannot represent infinity.");
            }
            if (float.IsNaN(value)) {
                throw new OverflowException("The value is not a number.");
            }
            this._sign = 0;
            this._bits = null;
            this.SetBitsFromDouble((double)value);
        }

        public BigInteger(double value) {
            if (double.IsInfinity(value)) {
                throw new OverflowException("BigInteger cannot represent infinity.");
            }
            if (double.IsNaN(value)) {
                throw new OverflowException("The value is not a number.");
            }
            this._sign = 0;
            this._bits = null;
            this.SetBitsFromDouble(value);
        }

        public BigInteger(decimal value) {
            int[] bits = decimal.GetBits(decimal.Truncate(value));
            int num = 3;
            while ((num > 0) && (bits[num - 1] == 0)) {
                num--;
            }
            if (num == 0) {
                this = s_bnZeroInt;
            }
            else if ((num == 1) && (bits[0] > 0)) {
                this._sign = bits[0];
                this._sign *= ((bits[3] & -2147483648) != 0) ? -1 : 1;
                this._bits = null;
            }
            else {
                this._bits = new uint[num];
                this._bits[0] = (uint)bits[0];
                if (num > 1) {
                    this._bits[1] = (uint)bits[1];
                }
                if (num > 2) {
                    this._bits[2] = (uint)bits[2];
                }
                this._sign = ((bits[3] & -2147483648) != 0) ? -1 : 1;
            }
        }

        [CLSCompliant(false)]
        public BigInteger(byte[] value) {
            if (value == null) {
                throw new ArgumentNullException("value");
            }
            int length = value.Length;
            bool flag = (length > 0) && ((value[length - 1] & 0x80) == 0x80);
            while ((length > 0) && (value[length - 1] == 0)) {
                length--;
            }
            if (length == 0) {
                this._sign = 0;
                this._bits = null;
            }
            else if (length <= 4) {
                if (flag) {
                    this._sign = -1;
                }
                else {
                    this._sign = 0;
                }
                for (int i = length - 1; i >= 0; i--) {
                    this._sign = this._sign << 8;
                    this._sign |= value[i];
                }
                this._bits = null;
                if ((this._sign < 0) && !flag) {
                    this._bits = new uint[] { (uint)this._sign };
                    this._sign = 1;
                }
                if (this._sign == -2147483648) {
                    this = s_bnMinInt;
                }
            }
            else {
                int num3 = length % 4;
                int num4 = (length / 4) + ((num3 == 0) ? 0 : 1);
                bool flag2 = true;
                uint[] d = new uint[num4];
                int index = 3;
                int num5 = 0;
                while (num5 < (num4 - ((num3 == 0) ? 0 : 1))) {
                    for (int j = 0; j < 4; j++) {
                        if (value[index] != 0) {
                            flag2 = false;
                        }
                        d[num5] = d[num5] << 8;
                        d[num5] |= value[index];
                        index--;
                    }
                    index += 8;
                    num5++;
                }
                if (num3 != 0) {
                    if (flag) {
                        d[num4 - 1] = uint.MaxValue;
                    }
                    for (index = length - 1; index >= (length - num3); index--) {
                        if (value[index] != 0) {
                            flag2 = false;
                        }
                        d[num5] = d[num5] << 8;
                        d[num5] |= value[index];
                    }
                }
                if (flag2) {
                    this = s_bnZeroInt;
                }
                else if (flag) {
                    NumericsHelpers.DangerousMakeTwosComplement(d);
                    int num8 = d.Length;
                    while ((num8 > 0) && (d[num8 - 1] == 0)) {
                        num8--;
                    }
                    if ((num8 == 1) && (d[0] > 0)) {
                        if (d[0] == 1) {
                            this = s_bnMinusOneInt;
                        }
                        else if (d[0] == 0x80000000) {
                            this = s_bnMinInt;
                        }
                        else {
                            this._sign = (int)(uint.MaxValue * d[0]);
                            this._bits = null;
                        }
                    }
                    else if (num8 != d.Length) {
                        this._sign = -1;
                        this._bits = new uint[num8];
                        Array.Copy(d, 0, this._bits, 0, num8);
                    }
                    else {
                        this._sign = -1;
                        this._bits = d;
                    }
                }
                else {
                    this._sign = 1;
                    this._bits = d;
                }
            }
        }

        public static BigInteger Parse(string value) {
            int length = value.Length;
            int sign = 1;
            int i = 0;
            if (value[0] == '+') {
                i++;
            }
            else if (value[0] == '-') {
                i++;
                sign = -1;
            }
            for (int j = i; j < length; j++) {
                if (value[j] < '0' || value[j] > '9') {
                    throw new ArgumentException("The parsed string was invalid.");
                }
            }
            uint n = 0;
            for (int l = ((length - i > 9) ? 9 + i : length); i < l; i++) {
                n *= 10;
                n += (uint)(value[i] - '0');
            }
            if (i == length) {
                return new BigInteger((int)n * sign);
            }
            int m = (length - i) / 9;
            int r = (length - i) % 9;
            BigIntegerBuilder builder = new BigIntegerBuilder(m + 2);
            builder.Set(n);
            for (int j = 0; j < m; j++) {
                n = 0;
                for (int l = 9 + i; i < l; i++) {
                    n *= 10;
                    n += (uint)(value[i] - '0');
                }
                builder.Mul((uint)1000000000);
                builder.Add(n);
            }
            if (r > 0) {
                uint k = 1;
                n = 0;
                for (int l = r + i; i < l; i++) {
                    k *= 10;
                    n *= 10;
                    n += (uint)(value[i] - '0');
                }
                builder.Mul(k);
                builder.Add(n);
            }
            return builder.GetInteger(sign);
        }

        internal BigInteger(int n, uint[] rgu) {
            this._sign = n;
            this._bits = rgu;
        }

        internal BigInteger(uint[] value, bool negative) {
            if (value == null) {
                throw new ArgumentNullException("value");
            }
            int length = value.Length;
            while ((length > 0) && (value[length - 1] == 0)) {
                length--;
            }
            if (length == 0) {
                this = s_bnZeroInt;
            }
            else if ((length == 1) && (value[0] < 0x80000000)) {
                this._sign = negative ? ((int)-value[0]) : ((int)value[0]);
                this._bits = null;
                if (this._sign == -2147483648) {
                    this = s_bnMinInt;
                }
            }
            else {
                this._sign = negative ? -1 : 1;
                this._bits = new uint[length];
                Array.Copy(value, 0, this._bits, 0, length);
            }
        }

        private BigInteger(uint[] value) {
            if (value == null) {
                throw new ArgumentNullException("value");
            }
            int length = value.Length;
            bool flag = (length > 0) && ((value[length - 1] & 0x80000000) == 0x80000000);
            while ((length > 0) && (value[length - 1] == 0)) {
                length--;
            }
            switch (length) {
                case 0:
                    this = s_bnZeroInt;
                    return;

                case 1:
                    if ((value[0] < 0) && !flag) {
                        this._bits = new uint[] { value[0] };
                        this._sign = 1;
                        return;
                    }
                    if (0x80000000 == value[0]) {
                        this = s_bnMinInt;
                        return;
                    }
                    this._sign = (int)value[0];
                    this._bits = null;
                    return;
            }
            if (!flag) {
                if (length != value.Length) {
                    this._sign = 1;
                    this._bits = new uint[length];
                    Array.Copy(value, 0, this._bits, 0, length);
                }
                else {
                    this._sign = 1;
                    this._bits = value;
                }
            }
            else {
                NumericsHelpers.DangerousMakeTwosComplement(value);
                int num2 = value.Length;
                while ((num2 > 0) && (value[num2 - 1] == 0)) {
                    num2--;
                }
                if ((num2 == 1) && (value[0] > 0)) {
                    if (value[0] == 1) {
                        this = s_bnMinusOneInt;
                    }
                    else if (value[0] == 0x80000000) {
                        this = s_bnMinInt;
                    }
                    else {
                        this._sign = (int)(uint.MaxValue * value[0]);
                        this._bits = null;
                    }
                }
                else if (num2 != value.Length) {
                    this._sign = -1;
                    this._bits = new uint[num2];
                    Array.Copy(value, 0, this._bits, 0, num2);
                }
                else {
                    this._sign = -1;
                    this._bits = value;
                }
            }
        }

        public static int Compare(BigInteger left, BigInteger right) {
            return left.CompareTo(right);
        }

        public static BigInteger Abs(BigInteger value) {
            if (value < Zero) {
                return -value;
            }
            return value;
        }

        public static BigInteger Add(BigInteger left, BigInteger right) {
            return (left + right);
        }

        public static BigInteger Subtract(BigInteger left, BigInteger right) {
            return (left - right);
        }

        public static BigInteger Multiply(BigInteger left, BigInteger right) {
            return (left * right);
        }

        public static BigInteger Divide(BigInteger dividend, BigInteger divisor) {
            return (dividend / divisor);
        }

        public static BigInteger Remainder(BigInteger dividend, BigInteger divisor) {
            return (dividend % divisor);
        }

        public static BigInteger DivRem(BigInteger dividend, BigInteger divisor, out BigInteger remainder) {
            int sign = 1;
            int num2 = 1;
            BigIntegerBuilder builder = new BigIntegerBuilder(dividend, ref sign);
            BigIntegerBuilder regDen = new BigIntegerBuilder(divisor, ref num2);
            BigIntegerBuilder regQuo = new BigIntegerBuilder();
            builder.ModDiv(ref regDen, ref regQuo);
            remainder = builder.GetInteger(sign);
            return regQuo.GetInteger(sign * num2);
        }

        public static BigInteger Negate(BigInteger value) {
            return -value;
        }

        public static double Log(BigInteger value) {
            return Log(value, 2.7182818284590451);
        }

        public static double Log(BigInteger value, double baseValue) {
            if ((value._sign < 0) || (baseValue == 1.0)) {
                return double.NaN;
            }
            if (baseValue == double.PositiveInfinity) {
                if (!value.IsOne) {
                    return double.NaN;
                }
                return 0.0;
            }
            if ((baseValue == 0.0) && !value.IsOne) {
                return double.NaN;
            }
            if (value._bits == null) {
                double a = (double)value._sign;
                if (double.IsNaN(a)) {
                    return a;
                }
                if (double.IsNaN(baseValue)) {
                    return baseValue;
                }
                if ((baseValue != 1.0) && ((a == 1.0) || ((baseValue != 0.0) && !double.IsPositiveInfinity(baseValue))))
                {
                    return (Math.Log(a) / Math.Log(baseValue));
                }
                return double.NaN;
            }
            double d = 0.0;
            double num2 = 0.5;
            int num3 = Length(value._bits);
            int num4 = BitLengthOfUInt(value._bits[num3 - 1]);
            int num5 = ((num3 - 1) * 0x20) + num4;
            uint num6 = ((uint)1) << (num4 - 1);
            for (int i = num3 - 1; i >= 0; i--) {
                while (num6 != 0) {
                    if ((value._bits[i] & num6) != 0) {
                        d += num2;
                    }
                    num2 *= 0.5;
                    num6 = num6 >> 1;
                }
                num6 = 0x80000000;
            }
            return ((Math.Log(d) + (0.69314718055994529 * num5)) / Math.Log(baseValue));
        }

        public static double Log10(BigInteger value) {
            return Log(value, 10.0);
        }

        public static BigInteger GreatestCommonDivisor(BigInteger left, BigInteger right) {
            if (left._sign == 0) {
                return Abs(right);
            }
            if (right._sign == 0) {
                return Abs(left);
            }
            BigIntegerBuilder builder = new BigIntegerBuilder(left);
            BigIntegerBuilder builder2 = new BigIntegerBuilder(right);
            BigIntegerBuilder.GCD(ref builder, ref builder2);
            return builder.GetInteger(1);
        }

        public static BigInteger Max(BigInteger left, BigInteger right) {
            if (left.CompareTo(right) < 0) {
                return right;
            }
            return left;
        }

        public static BigInteger Min(BigInteger left, BigInteger right) {
            if (left.CompareTo(right) <= 0) {
                return left;
            }
            return right;
        }

        private static void ModPowUpdateResult(ref BigIntegerBuilder regRes, ref BigIntegerBuilder regVal, ref BigIntegerBuilder regMod, ref BigIntegerBuilder regTmp) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
            NumericsHelpers.Swap<BigIntegerBuilder>(ref regRes, ref regTmp);
#else
            NumericsHelpers.Swap(ref regRes, ref regTmp);
#endif
            regRes.Mul(ref regTmp, ref regVal);
            regRes.Mod(ref regMod);
        }

        private static void ModPowSquareModValue(ref BigIntegerBuilder regVal, ref BigIntegerBuilder regMod, ref BigIntegerBuilder regTmp) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
            NumericsHelpers.Swap<BigIntegerBuilder>(ref regVal, ref regTmp);
#else
            NumericsHelpers.Swap(ref regVal, ref regTmp);
#endif
            regVal.Mul(ref regTmp, ref regTmp);
            regVal.Mod(ref regMod);
        }

        private static void ModPowInner(uint exp, ref BigIntegerBuilder regRes, ref BigIntegerBuilder regVal, ref BigIntegerBuilder regMod, ref BigIntegerBuilder regTmp) {
            while (exp != 0) {
                if ((exp & 1) == 1) {
                    ModPowUpdateResult(ref regRes, ref regVal, ref regMod, ref regTmp);
                }
                if (exp == 1) {
                    return;
                }
                ModPowSquareModValue(ref regVal, ref regMod, ref regTmp);
                exp = exp >> 1;
            }
        }

        private static void ModPowInner32(uint exp, ref BigIntegerBuilder regRes, ref BigIntegerBuilder regVal, ref BigIntegerBuilder regMod, ref BigIntegerBuilder regTmp) {
            for (int i = 0; i < 0x20; i++) {
                if ((exp & 1) == 1) {
                    ModPowUpdateResult(ref regRes, ref regVal, ref regMod, ref regTmp);
                }
                ModPowSquareModValue(ref regVal, ref regMod, ref regTmp);
                exp = exp >> 1;
            }
        }

        public static BigInteger ModPow(BigInteger value, BigInteger exponent, BigInteger modulus) {
            if (exponent.Sign < 0) {
                throw new ArgumentOutOfRangeException("The exponent must be greater than or equal to zero.");
            }
            int sign = 1;
            int num2 = 1;
            int num3 = 1;
            bool isEven = exponent.IsEven;
            BigIntegerBuilder regRes = new BigIntegerBuilder(One, ref sign);
            BigIntegerBuilder regVal = new BigIntegerBuilder(value, ref num2);
            BigIntegerBuilder regDen = new BigIntegerBuilder(modulus, ref num3);
            BigIntegerBuilder regTmp = new BigIntegerBuilder(regVal.Size);
            regRes.Mod(ref regDen);
            if (exponent._bits == null) {
                ModPowInner((uint)exponent._sign, ref regRes, ref regVal, ref regDen, ref regTmp);
            }
            else {
                int num4 = Length(exponent._bits);
                for (int i = 0; i < (num4 - 1); i++) {
                    uint exp = exponent._bits[i];
                    ModPowInner32(exp, ref regRes, ref regVal, ref regDen, ref regTmp);
                }
                ModPowInner(exponent._bits[num4 - 1], ref regRes, ref regVal, ref regDen, ref regTmp);
            }
            return regRes.GetInteger((value._sign > 0) ? 1 : (isEven ? 1 : -1));
        }

        public static BigInteger Pow(BigInteger value, int exponent) {
            if (exponent < 0) {
                throw new ArgumentOutOfRangeException("The exponent must be greater than or equal to zero.");
            }
            if (exponent == 0) {
                return One;
            }
            if (exponent == 1) {
                return value;
            }
            if (value._bits == null) {
                if (value._sign == 1) {
                    return value;
                }
                if (value._sign == -1) {
                    if ((exponent & 1) == 0) {
                        return 1;
                    }
                    return value;
                }
                if (value._sign == 0) {
                    return value;
                }
            }
            int sign = 1;
            BigIntegerBuilder builder = new BigIntegerBuilder(value, ref sign);
            int size = builder.Size;
            int cuMul = size;
            uint high = builder.High;
            uint uHiMul = high + 1;
            if (uHiMul == 0) {
                cuMul++;
                uHiMul = 1;
            }
            int cuRes = 1;
            int num7 = 1;
            uint uHiRes = 1;
            uint num9 = 1;
            int num10 = exponent;
        Label_00A4:
            if ((num10 & 1) != 0) {
                MulUpper(ref num9, ref num7, uHiMul, cuMul);
                MulLower(ref uHiRes, ref cuRes, high, size);
            }
            num10 = num10 >> 1;
            if (num10 != 0) {
                MulUpper(ref uHiMul, ref cuMul, uHiMul, cuMul);
                MulLower(ref high, ref size, high, size);
                goto Label_00A4;
            }
            if (num7 > 1) {
                builder.EnsureWritable(num7, 0);
            }
            BigIntegerBuilder b = new BigIntegerBuilder(num7);
            BigIntegerBuilder a = new BigIntegerBuilder(num7);
            a.Set((uint)1);
            if ((exponent & 1) == 0) {
                sign = 1;
            }
            int num11 = exponent;
        Label_0122:
            if ((num11 & 1) != 0) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                NumericsHelpers.Swap<BigIntegerBuilder>(ref a, ref b);
#else
                NumericsHelpers.Swap(ref a, ref b);
#endif
                a.Mul(ref builder, ref b);
            }
            num11 = num11 >> 1;
            if (num11 != 0) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                NumericsHelpers.Swap<BigIntegerBuilder>(ref builder, ref b);
#else
                NumericsHelpers.Swap(ref builder, ref b);
#endif
                builder.Mul(ref b, ref b);
                goto Label_0122;
            }
            return a.GetInteger(sign);
        }

        public static implicit operator BigInteger(byte value) {
            return new BigInteger(value);
        }

        [CLSCompliant(false)]
        public static implicit operator BigInteger(sbyte value) {
            return new BigInteger(value);
        }

        public static implicit operator BigInteger(short value) {
            return new BigInteger(value);
        }

        [CLSCompliant(false)]
        public static implicit operator BigInteger(ushort value) {
            return new BigInteger(value);
        }

        public static implicit operator BigInteger(int value) {
            return new BigInteger(value);
        }

        [CLSCompliant(false)]
        public static implicit operator BigInteger(uint value) {
            return new BigInteger(value);
        }

        public static implicit operator BigInteger(long value) {
            return new BigInteger(value);
        }

        [CLSCompliant(false)]
        public static implicit operator BigInteger(ulong value) {
            return new BigInteger(value);
        }

        public static explicit operator BigInteger(float value) {
            return new BigInteger(value);
        }

        public static explicit operator BigInteger(double value) {
            return new BigInteger(value);
        }

        public static explicit operator BigInteger(decimal value) {
            return new BigInteger(value);
        }

        [CLSCompliant(false)]
        public static implicit operator BigInteger(string value) {
            return BigInteger.Parse(value);
        }

        public static explicit operator byte(BigInteger value) {
            return (byte)((int)value);
        }

        [CLSCompliant(false)]
        public static explicit operator sbyte(BigInteger value) {
            return (sbyte)((int)value);
        }

        public static explicit operator short(BigInteger value) {
            return (short)((int)value);
        }

        [CLSCompliant(false)]
        public static explicit operator ushort(BigInteger value) {
            return (ushort)((int)value);
        }

        public static explicit operator int(BigInteger value) {
            if (value._bits == null) {
                return value._sign;
            }
            if (Length(value._bits) > 1) {
                throw new OverflowException("Value was either too large or too small for an Int32.");
            }
            if (value._sign > 0) {
                return (int)value._bits[0];
            }
            if (value._bits[0] > 0x80000000) {
                throw new OverflowException("Value was either too large or too small for an Int32.");
            }
            return (int)-value._bits[0];
        }

        [CLSCompliant(false)]
        public static explicit operator uint(BigInteger value) {
            if (value._bits == null) {
                return (uint)value._sign;
            }
            if ((Length(value._bits) > 1) || (value._sign < 0)) {
                throw new OverflowException("Value was either too large or too small for a UInt32.");
            }
            return value._bits[0];
        }

        public static explicit operator long(BigInteger value) {
            ulong num2;
            if (value._bits == null) {
                return (long)value._sign;
            }
            int num = Length(value._bits);
            if (num > 2) {
                throw new OverflowException("Value was either too large or too small for an Int64.");
            }
            if (num > 1) {
                num2 = NumericsHelpers.MakeUlong(value._bits[1], value._bits[0]);
            }
            else {
                num2 = value._bits[0];
            }
            long num3 = (value._sign > 0) ? ((long)num2) : (-(long)num2);
            if (((num3 <= 0L) || (value._sign <= 0)) && ((num3 >= 0L) || (value._sign >= 0))) {
                throw new OverflowException("Value was either too large or too small for an Int64.");
            }
            return num3;
        }

        [CLSCompliant(false)]
        public static explicit operator ulong(BigInteger value) {
            if (value._bits == null) {
                return (ulong)value._sign;
            }
            int num = Length(value._bits);
            if ((num > 2) || (value._sign < 0)) {
                throw new OverflowException("Value was either too large or too small for a UInt64.");
            }
            if (num > 1) {
                return NumericsHelpers.MakeUlong(value._bits[1], value._bits[0]);
            }
            return (ulong)value._bits[0];
        }

        public static explicit operator float(BigInteger value) {
            return (float)((double)value);
        }

        public static explicit operator double(BigInteger value) {
            ulong num;
            int num2;
            if (value._bits == null) {
                return (double)value._sign;
            }
            int sign = 1;
            new BigIntegerBuilder(value, ref sign).GetApproxParts(out num2, out num);
            return NumericsHelpers.GetDoubleFromParts(sign, num2, num);
        }

        public static explicit operator decimal(BigInteger value) {
            if (value._bits == null) {
                return value._sign;
            }
            int num = Length(value._bits);
            if (num > 3) {
                throw new OverflowException("Value was either too large or too small for a Decimal.");
            }
            int lo = 0;
            int mid = 0;
            int hi = 0;
            if (num > 2) {
                hi = (int)value._bits[2];
            }
            if (num > 1) {
                mid = (int)value._bits[1];
            }
            if (num > 0) {
                lo = (int)value._bits[0];
            }
            return new decimal(lo, mid, hi, value._sign < 0, 0);
        }

        public static explicit operator string(BigInteger value) {
            return value.ToString();
        }

        public static BigInteger operator &(BigInteger left, BigInteger right) {
            if (left.IsZero || right.IsZero) {
                return Zero;
            }
            uint[] numArray = left.ToUInt32Array();
            uint[] numArray2 = right.ToUInt32Array();
            uint[] numArray3 = new uint[Math.Max(numArray.Length, numArray2.Length)];
            uint num = (left._sign < 0) ? uint.MaxValue : 0;
            uint num2 = (right._sign < 0) ? uint.MaxValue : 0;
            for (int i = 0; i < numArray3.Length; i++) {
                uint num4 = (i < numArray.Length) ? numArray[i] : num;
                uint num5 = (i < numArray2.Length) ? numArray2[i] : num2;
                numArray3[i] = num4 & num5;
            }
            return new BigInteger(numArray3);
        }

        public static BigInteger operator |(BigInteger left, BigInteger right) {
            if (left.IsZero) {
                return right;
            }
            if (right.IsZero) {
                return left;
            }
            uint[] numArray = left.ToUInt32Array();
            uint[] numArray2 = right.ToUInt32Array();
            uint[] numArray3 = new uint[Math.Max(numArray.Length, numArray2.Length)];
            uint num = (left._sign < 0) ? uint.MaxValue : 0;
            uint num2 = (right._sign < 0) ? uint.MaxValue : 0;
            for (int i = 0; i < numArray3.Length; i++) {
                uint num4 = (i < numArray.Length) ? numArray[i] : num;
                uint num5 = (i < numArray2.Length) ? numArray2[i] : num2;
                numArray3[i] = num4 | num5;
            }
            return new BigInteger(numArray3);
        }

        public static BigInteger operator ^(BigInteger left, BigInteger right) {
            uint[] numArray = left.ToUInt32Array();
            uint[] numArray2 = right.ToUInt32Array();
            uint[] numArray3 = new uint[Math.Max(numArray.Length, numArray2.Length)];
            uint num = (left._sign < 0) ? uint.MaxValue : 0;
            uint num2 = (right._sign < 0) ? uint.MaxValue : 0;
            for (int i = 0; i < numArray3.Length; i++) {
                uint num4 = (i < numArray.Length) ? numArray[i] : num;
                uint num5 = (i < numArray2.Length) ? numArray2[i] : num2;
                numArray3[i] = num4 ^ num5;
            }
            return new BigInteger(numArray3);
        }

        public static BigInteger operator <<(BigInteger value, int shift) {
            uint[] numArray;
            int num3;
            if (shift == 0) {
                return value;
            }
            if (shift == -2147483648) {
                return (value >> 0x7fffffff) >> 1;
            }
            if (shift < 0) {
                return value >> -shift;
            }
            int num = shift / 0x20;
            int num2 = shift - (num * 0x20);
            bool negative = GetPartsForBitManipulation(ref value, out numArray, out num3);
            int num4 = (num3 + num) + 1;
            uint[] numArray2 = new uint[num4];
            if (num2 == 0) {
                for (int i = 0; i < num3; i++) {
                    numArray2[i + num] = numArray[i];
                }
            }
            else {
                int num6 = 0x20 - num2;
                uint num7 = 0;
                int index = 0;
                while (index < num3) {
                    uint num9 = numArray[index];
                    numArray2[index + num] = (num9 << num2) | num7;
                    num7 = num9 >> num6;
                    index++;
                }
                numArray2[index + num] = num7;
            }
            return new BigInteger(numArray2, negative);
        }

        public static BigInteger operator >>(BigInteger value, int shift) {
            uint[] numArray;
            int num3;
            if (shift == 0) {
                return value;
            }
            if (shift == -2147483648) {
                return (value << 0x7fffffff) << 1;
            }
            if (shift < 0) {
                return value << -shift;
            }
            int num = shift / 0x20;
            int num2 = shift - (num * 0x20);
            bool negative = GetPartsForBitManipulation(ref value, out numArray, out num3);
            if (negative) {
                if (shift >= (0x20 * num3)) {
                    return MinusOne;
                }
                uint[] destinationArray = new uint[num3];
                Array.Copy(numArray, 0, destinationArray, 0, num3);
                numArray = destinationArray;
                NumericsHelpers.DangerousMakeTwosComplement(numArray);
            }
            int num4 = num3 - num;
            if (num4 < 0) {
                num4 = 0;
            }
            uint[] d = new uint[num4];
            if (num2 == 0) {
                for (int i = num3 - 1; i >= num; i--) {
                    d[i - num] = numArray[i];
                }
            }
            else {
                int num6 = 0x20 - num2;
                uint num7 = 0;
                for (int j = num3 - 1; j >= num; j--) {
                    uint num9 = numArray[j];
                    if (negative && (j == (num3 - 1))) {
                        d[j - num] = (num9 >> num2) | (unchecked((uint)-1) << num6);
                    }
                    else {
                        d[j - num] = (num9 >> num2) | num7;
                    }
                    num7 = num9 << num6;
                }
            }
            if (negative) {
                NumericsHelpers.DangerousMakeTwosComplement(d);
            }
            return new BigInteger(d, negative);
        }

        public static BigInteger operator ~(BigInteger value) {
            return -(value + One);
        }

        public static BigInteger operator -(BigInteger value) {
            value._sign = -value._sign;
            return value;
        }

        public static BigInteger operator +(BigInteger value) {
            return value;
        }

        public static BigInteger operator ++(BigInteger value) {
            return (value + One);
        }

        public static BigInteger operator --(BigInteger value) {
            return (value - One);
        }

        public static BigInteger operator +(BigInteger left, BigInteger right) {
            if (right.IsZero) {
                return left;
            }
            if (left.IsZero) {
                return right;
            }
            int sign = 1;
            int num2 = 1;
            BigIntegerBuilder builder = new BigIntegerBuilder(left, ref sign);
            BigIntegerBuilder reg = new BigIntegerBuilder(right, ref num2);
            if (sign == num2) {
                builder.Add(ref reg);
            }
            else {
                builder.Sub(ref sign, ref reg);
            }
            return builder.GetInteger(sign);
        }

        public static BigInteger operator -(BigInteger left, BigInteger right) {
            if (right.IsZero) {
                return left;
            }
            if (left.IsZero) {
                return -right;
            }
            int sign = 1;
            int num2 = -1;
            BigIntegerBuilder builder = new BigIntegerBuilder(left, ref sign);
            BigIntegerBuilder reg = new BigIntegerBuilder(right, ref num2);
            if (sign == num2) {
                builder.Add(ref reg);
            }
            else {
                builder.Sub(ref sign, ref reg);
            }
            return builder.GetInteger(sign);
        }

        public static BigInteger operator *(BigInteger left, BigInteger right) {
            int sign = 1;
            BigIntegerBuilder builder = new BigIntegerBuilder(left, ref sign);
            BigIntegerBuilder regMul = new BigIntegerBuilder(right, ref sign);
            builder.Mul(ref regMul);
            return builder.GetInteger(sign);
        }

        public static BigInteger operator /(BigInteger dividend, BigInteger divisor) {
            int sign = 1;
            BigIntegerBuilder builder = new BigIntegerBuilder(dividend, ref sign);
            BigIntegerBuilder regDen = new BigIntegerBuilder(divisor, ref sign);
            builder.Div(ref regDen);
            return builder.GetInteger(sign);
        }

        public static BigInteger operator %(BigInteger dividend, BigInteger divisor) {
            int sign = 1;
            int num2 = 1;
            BigIntegerBuilder builder = new BigIntegerBuilder(dividend, ref sign);
            BigIntegerBuilder regDen = new BigIntegerBuilder(divisor, ref num2);
            builder.Mod(ref regDen);
            return builder.GetInteger(sign);
        }

        public static bool operator <(BigInteger left, BigInteger right) {
            return (left.CompareTo(right) < 0);
        }

        public static bool operator <=(BigInteger left, BigInteger right) {
            return (left.CompareTo(right) <= 0);
        }

        public static bool operator >(BigInteger left, BigInteger right) {
            return (left.CompareTo(right) > 0);
        }

        public static bool operator >=(BigInteger left, BigInteger right) {
            return (left.CompareTo(right) >= 0);
        }

        public static bool operator ==(BigInteger left, BigInteger right) {
            return left.Equals(right);
        }

        public static bool operator !=(BigInteger left, BigInteger right) {
            return !left.Equals(right);
        }

        public static bool operator <(BigInteger left, long right) {
            return (left.CompareTo(right) < 0);
        }

        public static bool operator <=(BigInteger left, long right) {
            return (left.CompareTo(right) <= 0);
        }

        public static bool operator >(BigInteger left, long right) {
            return (left.CompareTo(right) > 0);
        }

        public static bool operator >=(BigInteger left, long right) {
            return (left.CompareTo(right) >= 0);
        }

        public static bool operator ==(BigInteger left, long right) {
            return left.Equals(right);
        }

        public static bool operator !=(BigInteger left, long right) {
            return !left.Equals(right);
        }

        public static bool operator <(long left, BigInteger right) {
            return (right.CompareTo(left) > 0);
        }

        public static bool operator <=(long left, BigInteger right) {
            return (right.CompareTo(left) >= 0);
        }

        public static bool operator >(long left, BigInteger right) {
            return (right.CompareTo(left) < 0);
        }

        public static bool operator >=(long left, BigInteger right) {
            return (right.CompareTo(left) <= 0);
        }

        public static bool operator ==(long left, BigInteger right) {
            return right.Equals(left);
        }

        public static bool operator !=(long left, BigInteger right) {
            return !right.Equals(left);
        }

        [CLSCompliant(false)]
        public static bool operator <(BigInteger left, ulong right) {
            return (left.CompareTo(right) < 0);
        }

        [CLSCompliant(false)]
        public static bool operator <=(BigInteger left, ulong right) {
            return (left.CompareTo(right) <= 0);
        }

        [CLSCompliant(false)]
        public static bool operator >(BigInteger left, ulong right) {
            return (left.CompareTo(right) > 0);
        }

        [CLSCompliant(false)]
        public static bool operator >=(BigInteger left, ulong right) {
            return (left.CompareTo(right) >= 0);
        }

        [CLSCompliant(false)]
        public static bool operator ==(BigInteger left, ulong right) {
            return left.Equals(right);
        }

        [CLSCompliant(false)]
        public static bool operator !=(BigInteger left, ulong right) {
            return !left.Equals(right);
        }

        [CLSCompliant(false)]
        public static bool operator <(ulong left, BigInteger right) {
            return (right.CompareTo(left) > 0);
        }

        [CLSCompliant(false)]
        public static bool operator <=(ulong left, BigInteger right) {
            return (right.CompareTo(left) >= 0);
        }

        [CLSCompliant(false)]
        public static bool operator >(ulong left, BigInteger right) {
            return (right.CompareTo(left) < 0);
        }

        [CLSCompliant(false)]
        public static bool operator >=(ulong left, BigInteger right) {
            return (right.CompareTo(left) <= 0);
        }

        [CLSCompliant(false)]
        public static bool operator ==(ulong left, BigInteger right) {
            return right.Equals(left);
        }

        [CLSCompliant(false)]
        public static bool operator !=(ulong left, BigInteger right) {
            return !right.Equals(left);
        }

        private void SetBitsFromDouble(double value) {
            int num;
            int num2;
            ulong num3;
            bool flag;
            NumericsHelpers.GetDoubleParts(value, out num, out num2, out num3, out flag);
            if (num3 == 0L) {
                this = Zero;
            }
            else if (num2 <= 0) {
                if (num2 <= -64) {
                    this = Zero;
                }
                else {
                    this = num3 >> -num2;
                    if (num < 0) {
                        this._sign = -this._sign;
                    }
                }
            }
            else if (num2 <= 11) {
                this = num3 << num2;
                if (num < 0) {
                    this._sign = -this._sign;
                }
            }
            else {
                num3 = num3 << 11;
                num2 -= 11;
                int index = ((num2 - 1) / 0x20) + 1;
                int num5 = (index * 0x20) - num2;
                this._bits = new uint[index + 2];
                this._bits[index + 1] = (uint)(num3 >> (num5 + 0x20));
                this._bits[index] = (uint)(num3 >> num5);
                if (num5 > 0) {
                    this._bits[index - 1] = ((uint)num3) << (0x20 - num5);
                }
                this._sign = num;
            }
        }

        internal static int Length(uint[] rgu) {
            int length = rgu.Length;
            if (rgu[length - 1] != 0) {
                return length;
            }
            return (length - 1);
        }

        internal int _Sign {
            get {
                return this._sign;
            }
        }
        internal uint[] _Bits {
            get {
                return this._bits;
            }
        }
        internal static int BitLengthOfUInt(uint x) {
            int num = 0;
            while (x > 0) {
                x = x >> 1;
                num++;
            }
            return num;
        }

        private static bool GetPartsForBitManipulation(ref BigInteger x, out uint[] xd, out int xl) {
            if (x._bits == null) {
                if (x._sign < 0) {
                    xd = new uint[] { (uint)-x._sign };
                }
                else {
                    xd = new uint[] { (uint)x._sign };
                }
            }
            else {
                xd = x._bits;
            }
            xl = (x._bits == null) ? 1 : x._bits.Length;
            return (x._sign < 0);
        }

        private static void MulUpper(ref uint uHiRes, ref int cuRes, uint uHiMul, int cuMul) {
            ulong uu = (ulong)uHiRes * (ulong)uHiMul;
            uint hi = NumericsHelpers.GetHi(uu);
            if (hi != 0) {
                if ((NumericsHelpers.GetLo(uu) != 0) && (++hi == 0)) {
                    hi = 1;
                    cuRes++;
                }
                uHiRes = hi;
                cuRes += cuMul;
            }
            else {
                uHiRes = NumericsHelpers.GetLo(uu);
                cuRes += cuMul - 1;
            }
        }

        private static void MulLower(ref uint uHiRes, ref int cuRes, uint uHiMul, int cuMul) {
            ulong uu = (ulong)uHiRes * (ulong)uHiMul;
            uint hi = NumericsHelpers.GetHi(uu);
            if (hi != 0) {
                uHiRes = hi;
                cuRes += cuMul;
            }
            else {
                uHiRes = NumericsHelpers.GetLo(uu);
                cuRes += cuMul - 1;
            }
        }

        internal static int GetDiffLength(uint[] rgu1, uint[] rgu2, int cu) {
            int index = cu;
            while (--index >= 0) {
                if (rgu1[index] != rgu2[index]) {
                    return (index + 1);
                }
            }
            return 0;
        }

        static BigInteger() {
            s_bnMinInt = new BigInteger(-1, new uint[] { 0x80000000 });
            s_bnOneInt = new BigInteger(1);
            s_bnZeroInt = new BigInteger(0);
            s_bnMinusOneInt = new BigInteger(-1);
        }
    }
}

