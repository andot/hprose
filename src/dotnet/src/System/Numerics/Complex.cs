using System;
using System.Globalization;
using System.Runtime.InteropServices;

namespace System.Numerics {

    [StructLayout(LayoutKind.Sequential)]
    public struct Complex :
#if !(dotNET10 || dotNET11 || dotNETCF10)
    IEquatable<Complex>,
#endif
    IFormattable {
        private const double LOG_10_INV = 0.43429448190325;
        private double m_real;
        private double m_imaginary;
        public static readonly Complex Zero;
        public static readonly Complex One;
        public static readonly Complex ImaginaryOne;

        public double Real {
            get {
                return this.m_real;
            }
        }

        public double Imaginary {
            get {
                return this.m_imaginary;
            }
        }

        public double Magnitude {
            get {
                return Abs(this);
            }
        }

        public double Phase {
            get {
                return Math.Atan2(this.m_imaginary, this.m_real);
            }
        }

        public Complex(double real, double imaginary) {
            this.m_real = real;
            this.m_imaginary = imaginary;
        }

        public static Complex FromPolarCoordinates(double magnitude, double phase) {
            return new Complex(magnitude * Math.Cos(phase), magnitude * Math.Sin(phase));
        }

        public static Complex Negate(Complex value) {
            return -value;
        }

        public static Complex Add(Complex left, Complex right) {
            return (left + right);
        }

        public static Complex Subtract(Complex left, Complex right) {
            return (left - right);
        }

        public static Complex Multiply(Complex left, Complex right) {
            return (left * right);
        }

        public static Complex Divide(Complex dividend, Complex divisor) {
            return (dividend / divisor);
        }

        public static Complex operator -(Complex value) {
            return new Complex(-value.m_real, -value.m_imaginary);
        }

        public static Complex operator +(Complex left, Complex right) {
            return new Complex(left.m_real + right.m_real, left.m_imaginary + right.m_imaginary);
        }

        public static Complex operator -(Complex left, Complex right) {
            return new Complex(left.m_real - right.m_real, left.m_imaginary - right.m_imaginary);
        }

        public static Complex operator *(Complex left, Complex right) {
            double real = (left.m_real * right.m_real) - (left.m_imaginary * right.m_imaginary);
            return new Complex(real, (left.m_imaginary * right.m_real) + (left.m_real * right.m_imaginary));
        }

        public static Complex operator /(Complex left, Complex right) {
            double real = left.m_real;
            double imaginary = left.m_imaginary;
            double num3 = right.m_real;
            double num4 = right.m_imaginary;
            if (Math.Abs(num4) < Math.Abs(num3)) {
                return new Complex((real + (imaginary * (num4 / num3))) / (num3 + (num4 * (num4 / num3))), (imaginary - (real * (num4 / num3))) / (num3 + (num4 * (num4 / num3))));
            }
            return new Complex((imaginary + (real * (num3 / num4))) / (num4 + (num3 * (num3 / num4))), (-real + (imaginary * (num3 / num4))) / (num4 + (num3 * (num3 / num4))));
        }

        public static double Abs(Complex value) {
            if (double.IsInfinity(value.m_real) || double.IsInfinity(value.m_imaginary)) {
                return double.PositiveInfinity;
            }
            double num = Math.Abs(value.m_real);
            double num2 = Math.Abs(value.m_imaginary);
            if (num > num2) {
                double num3 = num2 / num;
                return (num * Math.Sqrt(1.0 + (num3 * num3)));
            }
            if (num2 == 0.0) {
                return num;
            }
            double num4 = num / num2;
            return (num2 * Math.Sqrt(1.0 + (num4 * num4)));
        }

        public static Complex Conjugate(Complex value) {
            return new Complex(value.m_real, -value.m_imaginary);
        }

        public static Complex Reciprocal(Complex value) {
            if ((value.m_real == 0.0) && (value.m_imaginary == 0.0)) {
                return Zero;
            }
            return (One / value);
        }

        public static bool operator ==(Complex left, Complex right) {
            return ((left.m_real == right.m_real) && (left.m_imaginary == right.m_imaginary));
        }

        public static bool operator !=(Complex left, Complex right) {
            if (left.m_real == right.m_real) {
                return !(left.m_imaginary == right.m_imaginary);
            }
            return true;
        }

        public override bool Equals(object obj) {
            return ((obj is Complex) && (this == ((Complex)obj)));
        }

        public bool Equals(Complex value) {
            return (this.m_real.Equals(value.m_real) && this.m_imaginary.Equals(value.m_imaginary));
        }

        public static implicit operator Complex(short value) {
            return new Complex((double)value, 0.0);
        }

        public static implicit operator Complex(int value) {
            return new Complex((double)value, 0.0);
        }

        public static implicit operator Complex(long value) {
            return new Complex((double)value, 0.0);
        }

        [CLSCompliant(false)]
        public static implicit operator Complex(ushort value) {
            return new Complex((double)value, 0.0);
        }

        [CLSCompliant(false)]
        public static implicit operator Complex(uint value) {
            return new Complex((double)value, 0.0);
        }

        [CLSCompliant(false)]
        public static implicit operator Complex(ulong value) {
            return new Complex((double)value, 0.0);
        }

        [CLSCompliant(false)]
        public static implicit operator Complex(sbyte value) {
            return new Complex((double)value, 0.0);
        }

        public static implicit operator Complex(byte value) {
            return new Complex((double)value, 0.0);
        }

        public static implicit operator Complex(float value) {
            return new Complex((double)value, 0.0);
        }

        public static implicit operator Complex(double value) {
            return new Complex(value, 0.0);
        }

        public static explicit operator Complex(BigInteger value) {
            return new Complex((double)value, 0.0);
        }

        public static explicit operator Complex(decimal value) {
            return new Complex((double)value, 0.0);
        }

        public override string ToString() {
            return string.Format(CultureInfo.CurrentCulture, "({0}, {1})", new object[] { this.m_real, this.m_imaginary });
        }

        public string ToString(string format) {
            return string.Format(CultureInfo.CurrentCulture, "({0}, {1})", new object[] { this.m_real.ToString(format, CultureInfo.CurrentCulture), this.m_imaginary.ToString(format, CultureInfo.CurrentCulture) });
        }

        public string ToString(IFormatProvider provider) {
            return string.Format(provider, "({0}, {1})", new object[] { this.m_real, this.m_imaginary });
        }

        public string ToString(string format, IFormatProvider provider) {
            return string.Format(provider, "({0}, {1})", new object[] { this.m_real.ToString(format, provider), this.m_imaginary.ToString(format, provider) });
        }

        public override int GetHashCode() {
            int num = 0x5f5e0fd;
            int num2 = this.m_real.GetHashCode() % num;
            int hashCode = this.m_imaginary.GetHashCode();
            return (num2 ^ hashCode);
        }

        public static Complex Sin(Complex value) {
            double real = value.m_real;
            double imaginary = value.m_imaginary;
            return new Complex(Math.Sin(real) * Math.Cosh(imaginary), Math.Cos(real) * Math.Sinh(imaginary));
        }

        public static Complex Sinh(Complex value) {
            double real = value.m_real;
            double imaginary = value.m_imaginary;
            return new Complex(Math.Sinh(real) * Math.Cos(imaginary), Math.Cosh(real) * Math.Sin(imaginary));
        }

        public static Complex Asin(Complex value) {
            return (-ImaginaryOne * Log((ImaginaryOne * value) + Sqrt(One - (value * value))));
        }

        public static Complex Cos(Complex value) {
            double real = value.m_real;
            double imaginary = value.m_imaginary;
            return new Complex(Math.Cos(real) * Math.Cosh(imaginary), -(Math.Sin(real) * Math.Sinh(imaginary)));
        }

        public static Complex Cosh(Complex value) {
            double real = value.m_real;
            double imaginary = value.m_imaginary;
            return new Complex(Math.Cosh(real) * Math.Cos(imaginary), Math.Sinh(real) * Math.Sin(imaginary));
        }

        public static Complex Acos(Complex value) {
            return (-ImaginaryOne * Log(value + (ImaginaryOne * Sqrt(One - (value * value)))));
        }

        public static Complex Tan(Complex value) {
            return (Sin(value) / Cos(value));
        }

        public static Complex Tanh(Complex value) {
            return (Sinh(value) / Cosh(value));
        }

        public static Complex Atan(Complex value) {
            Complex complex = new Complex(2.0, 0.0);
            return ((ImaginaryOne / complex) * (Log(One - (ImaginaryOne * value)) - Log(One + (ImaginaryOne * value))));
        }

        public static Complex Log(Complex value) {
            return new Complex(Math.Log(Abs(value)), Math.Atan2(value.m_imaginary, value.m_real));
        }

        public static Complex Log(Complex value, double baseValue) {
            return (Log(value) / Log(baseValue));
        }

        public static Complex Log10(Complex value) {
            return Scale(Log(value), 0.43429448190325);
        }

        public static Complex Exp(Complex value) {
            double num = Math.Exp(value.m_real);
            double real = num * Math.Cos(value.m_imaginary);
            return new Complex(real, num * Math.Sin(value.m_imaginary));
        }

        public static Complex Sqrt(Complex value) {
            return FromPolarCoordinates(Math.Sqrt(value.Magnitude), value.Phase / 2.0);
        }

        public static Complex Pow(Complex value, Complex power) {
            if (power == Zero) {
                return One;
            }
            if (value == Zero) {
                return Zero;
            }
            double real = value.m_real;
            double imaginary = value.m_imaginary;
            double y = power.m_real;
            double num4 = power.m_imaginary;
            double d = Abs(value);
            double num6 = Math.Atan2(imaginary, real);
            double num7 = (y * num6) + (num4 * Math.Log(d));
            double num8 = Math.Pow(d, y) * Math.Pow(2.7182818284590451, -num4 * num6);
            return new Complex(num8 * Math.Cos(num7), num8 * Math.Sin(num7));
        }

        public static Complex Pow(Complex value, double power) {
            return Pow(value, new Complex(power, 0.0));
        }

        private static Complex Scale(Complex value, double factor) {
            double real = factor * value.m_real;
            return new Complex(real, factor * value.m_imaginary);
        }

        static Complex() {
            Zero = new Complex(0.0, 0.0);
            One = new Complex(1.0, 0.0);
            ImaginaryOne = new Complex(0.0, 1.0);
        }
    }
}

