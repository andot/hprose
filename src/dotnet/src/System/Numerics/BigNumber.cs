using System;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;

namespace System.Numerics {
#if !(dotNET10 || dotNET11 || dotNETCF10)
    internal static class BigNumber {
#else
    internal class BigNumber {
#endif
        internal static string FormatBigInteger(BigInteger value, string format, NumberFormatInfo info) {
            int num3;
            int num9;
            int digits = 0;
            char ch = ParseFormatSpecifier(format, out digits);
            switch (ch) {
                case 'x':
                case 'X':
                    return FormatBigIntegerToHexString(value, ch, digits, info);
            }
            bool flag = ((((ch == 'g') || (ch == 'G')) || ((ch == 'd') || (ch == 'D'))) || (ch == 'r')) || (ch == 'R');
            if (!flag) {
                throw new FormatException("Format specifier was invalid.");
            }
            if (value._bits == null) {
                switch (ch) {
                    case 'g':
                    case 'G':
                    case 'r':
                    case 'R':
                        if (digits > 0) {
                            format = string.Format(CultureInfo.InvariantCulture, "D{0}", new object[] { digits.ToString(CultureInfo.InvariantCulture) });
                        }
                        else {
                            format = "D";
                        }
                        break;
                }
                return value._sign.ToString(format, info);
            }
            int num2 = BigInteger.Length(value._bits);
            try {
                num3 = ((num2 * 10) / 9) + 2;
            }
            catch (OverflowException exception) {
                throw new FormatException("The value is too large to be represented by this format specifier.", exception);
            }
            uint[] numArray = new uint[num3];
            int num4 = 0;
            int index = num2;
            while (--index >= 0) {
                uint uLo = value._bits[index];
                for (int k = 0; k < num4; k++) {
                    ulong num8 = NumericsHelpers.MakeUlong(numArray[k], uLo);
                    numArray[k] = (uint)(num8 % ((ulong)0x3b9aca00L));
                    uLo = (uint)(num8 / ((ulong)0x3b9aca00L));
                }
                if (uLo != 0) {
                    numArray[num4++] = uLo % 0x3b9aca00;
                    uLo /= 0x3b9aca00;
                    if (uLo != 0) {
                        numArray[num4++] = uLo;
                    }
                }
            }
            try {
                num9 = num4 * 9;
            }
            catch (OverflowException exception2) {
                throw new FormatException("The value is too large to be represented by this format specifier.", exception2);
            }
            if (flag) {
                if ((digits > 0) && (digits > num9)) {
                    num9 = digits;
                }
                if (value._sign < 0) {
                    try {
                        num9 += info.NegativeSign.Length;
                    }
                    catch (OverflowException exception3) {
                        throw new FormatException("The value is too large to be represented by this format specifier.", exception3);
                    }
                }
            }
            char[] chArray = new char[num9];
            int startIndex = num9;
            for (int i = 0; i < (num4 - 1); i++) {
                uint num12 = numArray[i];
                int num13 = 9;
                while (--num13 >= 0) {
                    chArray[--startIndex] = (char)(0x30 + (num12 % 10));
                    num12 /= 10;
                }
            }
            for (uint j = numArray[num4 - 1]; j != 0; j /= 10) {
                chArray[--startIndex] = (char)(0x30 + (j % 10));
            }
            int num15 = num9 - startIndex;
            while ((digits > 0) && (digits > num15)) {
                chArray[--startIndex] = '0';
                digits--;
            }
            if (value._sign < 0) {
                string negativeSign = info.NegativeSign;
                for (int m = negativeSign.Length - 1; m > -1; m--) {
                    chArray[--startIndex] = negativeSign[m];
                }
            }
            return new string(chArray, startIndex, num9 - startIndex);
        }

        private static string FormatBigIntegerToHexString(BigInteger value, char format, int digits, NumberFormatInfo info) {
            StringBuilder builder = new StringBuilder();
            byte[] buffer = value.ToByteArray();
            string str = null;
            int index = buffer.Length - 1;
            if (index > -1) {
                bool flag = false;
                byte num2 = buffer[index];
                if (num2 > 0xf7) {
                    num2 = (byte)(num2 - 240);
                    flag = true;
                }
                if ((num2 < 8) || flag) {
                    str = string.Format(CultureInfo.InvariantCulture, "{0}1", new object[] { format });
                    builder.Append(num2.ToString(str, info));
                    index--;
                }
            }
            if (index > -1) {
                str = string.Format(CultureInfo.InvariantCulture, "{0}2", new object[] { format });
                while (index > -1) {
                    builder.Append(buffer[index--].ToString(str, info));
                }
            }
            if ((digits > 0) && (digits > builder.Length)) {
                builder.Insert(0, (value._sign >= 0) ? "0" : ((format == 'x') ? "f" : "F"), digits - builder.Length);
            }
            return builder.ToString();
        }

        internal static char ParseFormatSpecifier(string format, out int digits) {
            digits = -1;
            if (format == null || format.Length == 0) {
                return 'R';
            }
            int num = 0;
            char ch = format[num];
            if (((ch >= 'A') && (ch <= 'Z')) || ((ch >= 'a') && (ch <= 'z'))) {
                num++;
                int num2 = -1;
                if (((num < format.Length) && (format[num] >= '0')) && (format[num] <= '9')) {
                    num2 = format[num++] - '0';
                    while (((num < format.Length) && (format[num] >= '0')) && (format[num] <= '9')) {
                        num2 = (num2 * 10) + (format[num++] - '0');
                        if (num2 >= 10) {
                            break;
                        }
                    }
                }
                if ((num >= format.Length) || (format[num] == '\0')) {
                    digits = num2;
                    return ch;
                }
            }
            return '\0';
        }
    }
}

