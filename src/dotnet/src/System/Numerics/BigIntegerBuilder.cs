using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace System.Numerics {

    [StructLayout(LayoutKind.Sequential)]
    internal struct BigIntegerBuilder {
        private const int kcbitUint = 0x20;
        private int _iuLast;
        private uint _uSmall;
        private uint[] _rgu;
        private bool _fWritable;

        public BigIntegerBuilder(ref BigIntegerBuilder reg) {
            this = reg;
            if (this._fWritable) {
                this._fWritable = false;
                if (this._iuLast == 0) {
                    this._rgu = null;
                }
                else {
                    reg._fWritable = false;
                }
            }
        }

        public BigIntegerBuilder(int cuAlloc) {
            this._iuLast = 0;
            this._uSmall = 0;
            if (cuAlloc > 1) {
                this._rgu = new uint[cuAlloc];
                this._fWritable = true;
            }
            else {
                this._rgu = null;
                this._fWritable = false;
            }
        }

        public BigIntegerBuilder(BigInteger bn) {
            this._fWritable = false;
            this._rgu = bn._Bits;
            if (this._rgu == null) {
                this._iuLast = 0;
                this._uSmall = NumericsHelpers.Abs(bn._Sign);
            }
            else {
                this._iuLast = this._rgu.Length - 1;
                this._uSmall = this._rgu[0];
                while ((this._iuLast > 0) && (this._rgu[this._iuLast] == 0)) {
                    this._iuLast--;
                }
            }
        }

        public BigIntegerBuilder(BigInteger bn, ref int sign) {
            this._fWritable = false;
            this._rgu = bn._Bits;
            int num = bn._Sign;
            int num2 = num >> 0x1f;
            sign = (sign ^ num2) - num2;
            if (this._rgu == null) {
                this._iuLast = 0;
                this._uSmall = (uint)((num ^ num2) - num2);
            }
            else {
                this._iuLast = this._rgu.Length - 1;
                this._uSmall = this._rgu[0];
                while ((this._iuLast > 0) && (this._rgu[this._iuLast] == 0)) {
                    this._iuLast--;
                }
            }
        }

        public BigInteger GetInteger(int sign) {
            uint[] numArray;
            this.GetIntegerParts(sign, out sign, out numArray);
            return new BigInteger(sign, numArray);
        }

        internal void GetIntegerParts(int signSrc, out int sign, out uint[] bits) {
            if (this._iuLast == 0) {
                if (this._uSmall <= 0x7fffffff) {
                    sign = (int)(signSrc * this._uSmall);
                    bits = null;
                    return;
                }
                if (this._rgu == null) {
                    this._rgu = new uint[] { this._uSmall };
                }
                else if (this._fWritable) {
                    this._rgu[0] = this._uSmall;
                }
                else if (this._rgu[0] != this._uSmall) {
                    this._rgu = new uint[] { this._uSmall };
                }
            }
            sign = signSrc;
            int num = (this._rgu.Length - this._iuLast) - 1;
            if (num <= 1) {
                if ((num == 0) || (this._rgu[this._iuLast + 1] == 0)) {
                    this._fWritable = false;
                    bits = this._rgu;
                    return;
                }
                if (this._fWritable) {
                    this._rgu[this._iuLast + 1] = 0;
                    this._fWritable = false;
                    bits = this._rgu;
                    return;
                }
            }
            bits = this._rgu;
#if !(dotNET10 || dotNET11 || dotNETCF10 || dotNETCF20)
            Array.Resize<uint>(ref bits, this._iuLast + 1);
#else
            Resize(ref bits, this._iuLast + 1);
#endif
            if (!this._fWritable) {
                this._rgu = bits;
            }
        }

        public void Set(uint u) {
            this._uSmall = u;
            this._iuLast = 0;
        }

        public void Set(ulong uu) {
            uint hi = NumericsHelpers.GetHi(uu);
            if (hi == 0) {
                this._uSmall = NumericsHelpers.GetLo(uu);
                this._iuLast = 0;
            }
            else {
                this.SetSizeLazy(2);
                this._rgu[0] = (uint)uu;
                this._rgu[1] = hi;
            }
        }

        public int Size {
            get {
                return (this._iuLast + 1);
            }
        }
        public uint High {
            get {
                if (this._iuLast != 0) {
                    return this._rgu[this._iuLast];
                }
                return this._uSmall;
            }
        }
        public void GetApproxParts(out int exp, out ulong man) {
            if (this._iuLast == 0) {
                man = this._uSmall;
                exp = 0;
            }
            else {
                int num2;
                int index = this._iuLast - 1;
                man = NumericsHelpers.MakeUlong(this._rgu[index + 1], this._rgu[index]);
                exp = index * 0x20;
                if ((index > 0) && ((num2 = NumericsHelpers.CbitHighZero(this._rgu[index + 1])) > 0)) {
                    man = (man << (num2 & 0x3f)) | (this._rgu[index - 1] >> (0x20 - num2));
                    exp -= num2;
                }
            }
        }

        private void Trim() {
            if ((this._iuLast > 0) && (this._rgu[this._iuLast] == 0)) {
                this._uSmall = this._rgu[0];
                while ((--this._iuLast > 0) && (this._rgu[this._iuLast] == 0)) {
                }
            }
        }

        private int CuNonZero {
            get {
                int num = 0;
                for (int i = this._iuLast; i >= 0; i--) {
                    if (this._rgu[i] != 0) {
                        num++;
                    }
                }
                return num;
            }
        }
        private void SetSizeLazy(int cu) {
            if (cu <= 1) {
                this._iuLast = 0;
            }
            else {
                if (!this._fWritable || (this._rgu.Length < cu)) {
                    this._rgu = new uint[cu];
                    this._fWritable = true;
                }
                this._iuLast = cu - 1;
            }
        }

        private void SetSizeClear(int cu) {
            if (cu <= 1) {
                this._iuLast = 0;
                this._uSmall = 0;
            }
            else {
                if (!this._fWritable || (this._rgu.Length < cu)) {
                    this._rgu = new uint[cu];
                    this._fWritable = true;
                }
                else {
                    Array.Clear(this._rgu, 0, cu);
                }
                this._iuLast = cu - 1;
            }
        }

        private void SetSizeKeep(int cu, int cuExtra) {
            if (cu <= 1) {
                if (this._iuLast > 0) {
                    this._uSmall = this._rgu[0];
                }
                this._iuLast = 0;
            }
            else {
                if (!this._fWritable || (this._rgu.Length < cu)) {
                    uint[] destinationArray = new uint[cu + cuExtra];
                    if (this._iuLast == 0) {
                        destinationArray[0] = this._uSmall;
                    }
                    else {
                        Array.Copy(this._rgu, 0, destinationArray, 0, Math.Min(cu, this._iuLast + 1));
                    }
                    this._rgu = destinationArray;
                    this._fWritable = true;
                }
                else if ((this._iuLast + 1) < cu) {
                    Array.Clear(this._rgu, this._iuLast + 1, (cu - this._iuLast) - 1);
                    if (this._iuLast == 0) {
                        this._rgu[0] = this._uSmall;
                    }
                }
                this._iuLast = cu - 1;
            }
        }

        public void EnsureWritable(int cu, int cuExtra) {
            if (!this._fWritable || (this._rgu.Length < cu)) {
                uint[] destinationArray = new uint[cu + cuExtra];
                if (this._iuLast > 0) {
                    if (this._iuLast >= cu) {
                        this._iuLast = cu - 1;
                    }
                    Array.Copy(this._rgu, 0, destinationArray, 0, (int)(this._iuLast + 1));
                }
                this._rgu = destinationArray;
                this._fWritable = true;
            }
        }

        public void EnsureWritable(int cuExtra) {
            if (!this._fWritable) {
                uint[] destinationArray = new uint[(this._iuLast + 1) + cuExtra];
                Array.Copy(this._rgu, 0, destinationArray, 0, (int)(this._iuLast + 1));
                this._rgu = destinationArray;
                this._fWritable = true;
            }
        }

        public void EnsureWritable() {
            this.EnsureWritable(0);
        }

        public void Load(ref BigIntegerBuilder reg) {
            this.Load(ref reg, 0);
        }

        public void Load(ref BigIntegerBuilder reg, int cuExtra) {
            if (reg._iuLast == 0) {
                this._uSmall = reg._uSmall;
                this._iuLast = 0;
            }
            else {
                if (!this._fWritable || (this._rgu.Length <= reg._iuLast)) {
                    this._rgu = new uint[(reg._iuLast + 1) + cuExtra];
                    this._fWritable = true;
                }
                this._iuLast = reg._iuLast;
                Array.Copy(reg._rgu, 0, this._rgu, 0, (int)(this._iuLast + 1));
            }
        }

        public void Add(uint u) {
            if (this._iuLast == 0) {
                if ((this._uSmall += u) < u) {
                    this.SetSizeLazy(2);
                    this._rgu[0] = this._uSmall;
                    this._rgu[1] = 1;
                }
            }
            else if (u != 0) {
                uint num = this._rgu[0] + u;
                if (num < u) {
                    this.EnsureWritable(1);
                    this.ApplyCarry(1);
                }
                else if (!this._fWritable) {
                    this.EnsureWritable();
                }
                this._rgu[0] = num;
            }
        }

        public void Add(ref BigIntegerBuilder reg) {
            if (reg._iuLast == 0) {
                this.Add(reg._uSmall);
            }
            else if (this._iuLast == 0) {
                uint u = this._uSmall;
                if (u == 0) {
                    this = new BigIntegerBuilder(ref reg);
                }
                else {
                    this.Load(ref reg, 1);
                    this.Add(u);
                }
            }
            else {
                this.EnsureWritable(Math.Max(this._iuLast, reg._iuLast) + 1, 1);
                int iu = reg._iuLast + 1;
                if (this._iuLast < reg._iuLast) {
                    iu = this._iuLast + 1;
                    Array.Copy(reg._rgu, (int)(this._iuLast + 1), this._rgu, (int)(this._iuLast + 1), (int)(reg._iuLast - this._iuLast));
                    this._iuLast = reg._iuLast;
                }
                uint uCarry = 0;
                for (int i = 0; i < iu; i++) {
                    uCarry = AddCarry(ref this._rgu[i], reg._rgu[i], uCarry);
                }
                if (uCarry != 0) {
                    this.ApplyCarry(iu);
                }
            }
        }

        public void Sub(ref int sign, uint u) {
            if (this._iuLast == 0) {
                if (u <= this._uSmall) {
                    this._uSmall -= u;
                }
                else {
                    this._uSmall = u - this._uSmall;
                    sign = -sign;
                }
            }
            else if (u != 0) {
                this.EnsureWritable();
                uint num = this._rgu[0];
                this._rgu[0] = num - u;
                if (num < u) {
                    this.ApplyBorrow(1);
                    this.Trim();
                }
            }
        }

        public void Sub(ref int sign, ref BigIntegerBuilder reg) {
            if (reg._iuLast == 0) {
                this.Sub(ref sign, reg._uSmall);
            }
            else if (this._iuLast == 0) {
                uint u = this._uSmall;
                if (u == 0) {
                    this = new BigIntegerBuilder(ref reg);
                }
                else {
                    this.Load(ref reg);
                    this.Sub(ref sign, u);
                }
                sign = -sign;
            }
            else if (this._iuLast < reg._iuLast) {
                this.SubRev(ref reg);
                sign = -sign;
            }
            else {
                int iuMin = reg._iuLast + 1;
                if (this._iuLast == reg._iuLast) {
                    this._iuLast = BigInteger.GetDiffLength(this._rgu, reg._rgu, this._iuLast + 1) - 1;
                    if (this._iuLast < 0) {
                        this._iuLast = 0;
                        this._uSmall = 0;
                        return;
                    }
                    uint num3 = this._rgu[this._iuLast];
                    uint num4 = reg._rgu[this._iuLast];
                    if (this._iuLast == 0) {
                        if (num3 < num4) {
                            this._uSmall = num4 - num3;
                            sign = -sign;
                            return;
                        }
                        this._uSmall = num3 - num4;
                        return;
                    }
                    if (num3 < num4) {
                        reg._iuLast = this._iuLast;
                        this.SubRev(ref reg);
                        reg._iuLast = iuMin - 1;
                        sign = -sign;
                        return;
                    }
                    iuMin = this._iuLast + 1;
                }
                this.EnsureWritable();
                uint uBorrow = 0;
                for (int i = 0; i < iuMin; i++) {
                    uBorrow = SubBorrow(ref this._rgu[i], reg._rgu[i], uBorrow);
                }
                if (uBorrow != 0) {
                    this.ApplyBorrow(iuMin);
                }
                this.Trim();
            }
        }

        private void SubRev(ref BigIntegerBuilder reg) {
            this.EnsureWritable(reg._iuLast + 1, 0);
            int iuMin = this._iuLast + 1;
            if (this._iuLast < reg._iuLast) {
                Array.Copy(reg._rgu, (int)(this._iuLast + 1), this._rgu, (int)(this._iuLast + 1), (int)(reg._iuLast - this._iuLast));
                this._iuLast = reg._iuLast;
            }
            uint uBorrow = 0;
            for (int i = 0; i < iuMin; i++) {
                uBorrow = SubRevBorrow(ref this._rgu[i], reg._rgu[i], uBorrow);
            }
            if (uBorrow != 0) {
                this.ApplyBorrow(iuMin);
            }
            this.Trim();
        }

        public void Mul(uint u) {
            if (u == 0) {
                this.Set((uint)0);
            }
            else if (u != 1) {
                if (this._iuLast == 0) {
                    this.Set((ulong)this._uSmall * (ulong)u);
                }
                else {
                    this.EnsureWritable(1);
                    uint uCarry = 0;
                    for (int i = 0; i <= this._iuLast; i++) {
                        uCarry = MulCarry(ref this._rgu[i], u, uCarry);
                    }
                    if (uCarry != 0) {
                        this.SetSizeKeep(this._iuLast + 2, 0);
                        this._rgu[this._iuLast] = uCarry;
                    }
                }
            }
        }

        public void Mul(ref BigIntegerBuilder regMul) {
            if (regMul._iuLast == 0) {
                this.Mul(regMul._uSmall);
            }
            else if (this._iuLast == 0) {
                uint u = this._uSmall;
                switch (u) {
                    case 1:
                        this = new BigIntegerBuilder(ref regMul);
                        return;

                    case 0:
                        return;
                }
                this.Load(ref regMul, 1);
                this.Mul(u);
            }
            else {
                int num2 = this._iuLast + 1;
                this.SetSizeKeep(num2 + regMul._iuLast, 1);
                int index = num2;
                while (--index >= 0) {
                    uint num4 = this._rgu[index];
                    this._rgu[index] = 0;
                    uint uCarry = 0;
                    for (int i = 0; i <= regMul._iuLast; i++) {
                        uCarry = AddMulCarry(ref this._rgu[index + i], regMul._rgu[i], num4, uCarry);
                    }
                    if (uCarry != 0) {
                        for (int j = (index + regMul._iuLast) + 1; (uCarry != 0) && (j <= this._iuLast); j++) {
                            uCarry = AddCarry(ref this._rgu[j], 0, uCarry);
                        }
                        if (uCarry != 0) {
                            this.SetSizeKeep(this._iuLast + 2, 0);
                            this._rgu[this._iuLast] = uCarry;
                        }
                    }
                }
            }
        }

        public void Mul(ref BigIntegerBuilder reg1, ref BigIntegerBuilder reg2) {
            if (reg1._iuLast == 0) {
                if (reg2._iuLast == 0) {
                    this.Set((ulong)reg1._uSmall * (ulong)reg2._uSmall);
                }
                else {
                    this.Load(ref reg2, 1);
                    this.Mul(reg1._uSmall);
                }
            }
            else if (reg2._iuLast == 0) {
                this.Load(ref reg1, 1);
                this.Mul(reg2._uSmall);
            }
            else {
                uint[] numArray;
                uint[] numArray2;
                int num;
                int num2;
                this.SetSizeClear((reg1._iuLast + reg2._iuLast) + 2);
                if (reg1.CuNonZero <= reg2.CuNonZero) {
                    numArray = reg1._rgu;
                    num = reg1._iuLast + 1;
                    numArray2 = reg2._rgu;
                    num2 = reg2._iuLast + 1;
                }
                else {
                    numArray = reg2._rgu;
                    num = reg2._iuLast + 1;
                    numArray2 = reg1._rgu;
                    num2 = reg1._iuLast + 1;
                }
                for (int i = 0; i < num; i++) {
                    uint num4 = numArray[i];
                    if (num4 != 0) {
                        uint uCarry = 0;
                        int index = i;
                        int num7 = 0;
                        while (num7 < num2) {
                            uCarry = AddMulCarry(ref this._rgu[index], num4, numArray2[num7], uCarry);
                            num7++;
                            index++;
                        }
                        while (uCarry != 0) {
                            uCarry = AddCarry(ref this._rgu[index++], 0, uCarry);
                        }
                    }
                }
                this.Trim();
            }
        }

        public uint DivMod(uint uDen) {
            if (uDen == 1) {
                return 0;
            }
            if (this._iuLast == 0) {
                uint num = this._uSmall;
                this._uSmall = num / uDen;
                return (num % uDen);
            }
            this.EnsureWritable();
            ulong num2 = 0L;
            for (int i = this._iuLast; i >= 0; i--) {
                num2 = NumericsHelpers.MakeUlong((uint)num2, this._rgu[i]);
                this._rgu[i] = (uint)(num2 / ((ulong)uDen));
                num2 = num2 % ((ulong)uDen);
            }
            this.Trim();
            return (uint)num2;
        }

        public static uint Mod(ref BigIntegerBuilder regNum, uint uDen) {
            if (uDen == 1) {
                return 0;
            }
            if (regNum._iuLast == 0) {
                return (regNum._uSmall % uDen);
            }
            ulong num = 0L;
            for (int i = regNum._iuLast; i >= 0; i--) {
                num = NumericsHelpers.MakeUlong((uint)num, regNum._rgu[i]) % ((ulong)uDen);
            }
            return (uint)num;
        }

        public void Mod(ref BigIntegerBuilder regDen) {
            if (regDen._iuLast == 0) {
                this.Set(Mod(ref this, regDen._uSmall));
            }
            else if (this._iuLast != 0) {
                BigIntegerBuilder regQuo = new BigIntegerBuilder();
                ModDivCore(ref this, ref regDen, false, ref regQuo);
            }
        }

        public void Div(ref BigIntegerBuilder regDen) {
            if (regDen._iuLast == 0) {
                this.DivMod(regDen._uSmall);
            }
            else if (this._iuLast == 0) {
                this._uSmall = 0;
            }
            else {
                BigIntegerBuilder regQuo = new BigIntegerBuilder();
                ModDivCore(ref this, ref regDen, true, ref regQuo);
#if !(dotNET10 || dotNET11 || dotNETCF10)
                NumericsHelpers.Swap<BigIntegerBuilder>(ref this, ref regQuo);
#else
                NumericsHelpers.Swap(ref this, ref regQuo);
#endif
            }
        }

        public void ModDiv(ref BigIntegerBuilder regDen, ref BigIntegerBuilder regQuo) {
            if (regDen._iuLast == 0) {
                regQuo.Set(this.DivMod(regDen._uSmall));
#if !(dotNET10 || dotNET11 || dotNETCF10)
                NumericsHelpers.Swap<BigIntegerBuilder>(ref this, ref regQuo);
#else
                NumericsHelpers.Swap(ref this, ref regQuo);
#endif
            }
            else if (this._iuLast != 0) {
                ModDivCore(ref this, ref regDen, true, ref regQuo);
            }
        }

        private static void ModDivCore(ref BigIntegerBuilder regNum, ref BigIntegerBuilder regDen, bool fQuo, ref BigIntegerBuilder regQuo) {
            regQuo.Set((uint)0);
            if (regNum._iuLast >= regDen._iuLast) {
                int num = regDen._iuLast + 1;
                int num2 = regNum._iuLast - regDen._iuLast;
                int cu = num2;
                int index = regNum._iuLast;
                while (true) {
                    if (index < num2) {
                        cu++;
                        break;
                    }
                    if (regDen._rgu[index - num2] != regNum._rgu[index]) {
                        if (regDen._rgu[index - num2] < regNum._rgu[index]) {
                            cu++;
                        }
                        break;
                    }
                    index--;
                }
                if (cu != 0) {
                    if (fQuo) {
                        regQuo.SetSizeLazy(cu);
                    }
                    uint u = regDen._rgu[num - 1];
                    uint num6 = regDen._rgu[num - 2];
                    int num7 = NumericsHelpers.CbitHighZero(u);
                    int num8 = 0x20 - num7;
                    if (num7 > 0) {
                        u = (u << num7) | (num6 >> num8);
                        num6 = num6 << num7;
                        if (num > 2) {
                            num6 |= regDen._rgu[num - 3] >> num8;
                        }
                    }
                    regNum.EnsureWritable();
                    int num9 = cu;
                    while (--num9 >= 0) {
                        uint uHi = ((num9 + num) <= regNum._iuLast) ? regNum._rgu[num9 + num] : 0;
                        ulong num11 = NumericsHelpers.MakeUlong(uHi, regNum._rgu[(num9 + num) - 1]);
                        uint uLo = regNum._rgu[(num9 + num) - 2];
                        if (num7 > 0) {
                            num11 = (num11 << num7) | (uLo >> num8);
                            uLo = uLo << num7;
                            if ((num9 + num) >= 3) {
                                uLo |= regNum._rgu[(num9 + num) - 3] >> num8;
                            }
                        }
                        ulong num13 = num11 / ((ulong)u);
                        ulong num14 = (uint)(num11 % ((ulong)u));
                        if (num13 > 0xffffffffL) {
                            num14 += (ulong)u * (num13 - 0xffffffffL);
                            num13 = 0xffffffffL;
                        }
                        while ((num14 <= 0xffffffffL) && ((num13 * num6) > NumericsHelpers.MakeUlong((uint)num14, uLo))) {
                            num13 -= (ulong)1L;
                            num14 += (ulong)u;
                        }
                        if (num13 > 0L) {
                            ulong num15 = 0L;
                            for (int i = 0; i < num; i++) {
                                num15 += regDen._rgu[i] * num13;
                                uint num17 = (uint)num15;
                                num15 = num15 >> 0x20;
                                if (regNum._rgu[num9 + i] < num17) {
                                    num15 += (ulong)1L;
                                }
                                regNum._rgu[num9 + i] -= num17;
                            }
                            if (uHi < num15) {
                                uint uCarry = 0;
                                for (int j = 0; j < num; j++) {
                                    uCarry = AddCarry(ref regNum._rgu[num9 + j], regDen._rgu[j], uCarry);
                                }
                                num13 -= (ulong)1L;
                            }
                            regNum._iuLast = (num9 + num) - 1;
                        }
                        if (fQuo) {
                            if (cu == 1) {
                                regQuo._uSmall = (uint)num13;
                            }
                            else {
                                regQuo._rgu[num9] = (uint)num13;
                            }
                        }
                    }
                    regNum._iuLast = num - 1;
                    regNum.Trim();
                }
            }
        }

        public void ShiftRight(int cbit) {
            if (cbit <= 0) {
                if (cbit < 0) {
                    this.ShiftLeft(-cbit);
                }
            }
            else {
                this.ShiftRight(cbit / 0x20, cbit % 0x20);
            }
        }

        public void ShiftRight(int cuShift, int cbitShift) {
            if ((cuShift | cbitShift) != 0) {
                if (cuShift > this._iuLast) {
                    this.Set((uint)0);
                }
                else if (this._iuLast == 0) {
                    this._uSmall = this._uSmall >> cbitShift;
                }
                else {
                    uint[] sourceArray = this._rgu;
                    int num = this._iuLast + 1;
                    this._iuLast -= cuShift;
                    if (this._iuLast == 0) {
                        this._uSmall = sourceArray[cuShift] >> cbitShift;
                    }
                    else {
                        if (!this._fWritable) {
                            this._rgu = new uint[this._iuLast + 1];
                            this._fWritable = true;
                        }
                        if (cbitShift > 0) {
                            int index = cuShift + 1;
                            for (int i = 0; index < num; i++) {
                                this._rgu[i] = (sourceArray[index - 1] >> cbitShift) | (sourceArray[index] << (0x20 - cbitShift));
                                index++;
                            }
                            this._rgu[this._iuLast] = sourceArray[num - 1] >> cbitShift;
                            this.Trim();
                        }
                        else {
                            Array.Copy(sourceArray, cuShift, this._rgu, 0, this._iuLast + 1);
                        }
                    }
                }
            }
        }

        public void ShiftLeft(int cbit) {
            if (cbit <= 0) {
                if (cbit < 0) {
                    this.ShiftRight(-cbit);
                }
            }
            else {
                this.ShiftLeft(cbit / 0x20, cbit % 0x20);
            }
        }

        public void ShiftLeft(int cuShift, int cbitShift) {
            int index = this._iuLast + cuShift;
            uint num2 = 0;
            if (cbitShift > 0) {
                num2 = this.High >> (0x20 - cbitShift);
                if (num2 != 0) {
                    index++;
                }
            }
            if (index == 0) {
                this._uSmall = this._uSmall << cbitShift;
            }
            else {
                uint[] sourceArray = this._rgu;
                bool flag = cuShift > 0;
                if (!this._fWritable || (this._rgu.Length <= index)) {
                    this._rgu = new uint[index + 1];
                    this._fWritable = true;
                    flag = false;
                }
                if (this._iuLast == 0) {
                    if (num2 != 0) {
                        this._rgu[cuShift + 1] = num2;
                    }
                    this._rgu[cuShift] = this._uSmall << cbitShift;
                }
                else if (cbitShift == 0) {
                    Array.Copy(sourceArray, 0, this._rgu, cuShift, this._iuLast + 1);
                }
                else {
                    int num3 = this._iuLast;
                    int num4 = this._iuLast + cuShift;
                    if (num4 < index) {
                        this._rgu[index] = num2;
                    }
                    while (num3 > 0) {
                        this._rgu[num4] = (sourceArray[num3] << cbitShift) | (sourceArray[num3 - 1] >> (0x20 - cbitShift));
                        num3--;
                        num4--;
                    }
                    this._rgu[cuShift] = sourceArray[0] << cbitShift;
                }
                this._iuLast = index;
                if (flag) {
                    Array.Clear(this._rgu, 0, cuShift);
                }
            }
        }

        private ulong GetHigh2(int cu) {
            if ((cu - 1) <= this._iuLast) {
                return NumericsHelpers.MakeUlong(this._rgu[cu - 1], this._rgu[cu - 2]);
            }
            if ((cu - 2) == this._iuLast) {
                return (ulong)this._rgu[cu - 2];
            }
            return 0L;
        }

        private void ApplyCarry(int iu) {
        Label_0000:
            if (iu > this._iuLast) {
                if ((this._iuLast + 1) == this._rgu.Length) {
#if !(dotNET10 || dotNET11 || dotNETCF10 || dotNETCF20)
                    Array.Resize<uint>(ref this._rgu, this._iuLast + 2);
#else
                    Resize(ref this._rgu, this._iuLast + 2);
#endif
                }
                this._rgu[++this._iuLast] = 1;
            }
            else if (++this._rgu[iu] <= 0) {
                iu++;
                goto Label_0000;
            }
        }

        private void ApplyBorrow(int iuMin) {
            for (int i = iuMin; i <= this._iuLast; i++) {
                uint num2 = this._rgu[i]--;
                if (num2 > 0) {
                    return;
                }
            }
        }

        private static uint AddCarry(ref uint u1, uint u2, uint uCarry) {
            ulong num = (ulong)u1 + (ulong)u2 + (ulong)uCarry;
            u1 = (uint)num;
            return (uint)(num >> 0x20);
        }

        private static uint SubBorrow(ref uint u1, uint u2, uint uBorrow) {
            ulong num = (ulong)u1 - (ulong)u2 - (ulong)uBorrow;
            u1 = (uint)num;
            return (uint)-((int)(num >> 0x20));
        }

        private static uint SubRevBorrow(ref uint u1, uint u2, uint uBorrow) {
            ulong num = (ulong)u2 - (ulong)u1 - (ulong)uBorrow;
            u1 = (uint)num;
            return (uint)-((int)(num >> 0x20));
        }

        private static uint MulCarry(ref uint u1, uint u2, uint uCarry) {
            ulong num = (ulong)u1 * (ulong)u2 + (ulong)uCarry;
            u1 = (uint)num;
            return (uint)(num >> 0x20);
        }

        private static uint AddMulCarry(ref uint uAdd, uint uMul1, uint uMul2, uint uCarry) {
            ulong num = (ulong)uMul1 * (ulong)uMul2 + (ulong)uAdd + (ulong)uCarry;
            uAdd = (uint)num;
            return (uint)(num >> 0x20);
        }

        public static void GCD(ref BigIntegerBuilder reg1, ref BigIntegerBuilder reg2) {
            if (((reg1._iuLast > 0) && (reg1._rgu[0] == 0)) || ((reg2._iuLast > 0) && (reg2._rgu[0] == 0))) {
                int num = reg1.MakeOdd();
                int num2 = reg2.MakeOdd();
                LehmerGcd(ref reg1, ref reg2);
                int cbit = Math.Min(num, num2);
                if (cbit > 0) {
                    reg1.ShiftLeft(cbit);
                }
            }
            else {
                LehmerGcd(ref reg1, ref reg2);
            }
        }

        private static void LehmerGcd(ref BigIntegerBuilder reg1, ref BigIntegerBuilder reg2) {
            int num2;
            uint num11;
            int sign = 1;
        Label_0002:
            num2 = reg1._iuLast + 1;
            int b = reg2._iuLast + 1;
            if (num2 < b) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                NumericsHelpers.Swap<BigIntegerBuilder>(ref reg1, ref reg2);
                NumericsHelpers.Swap<int>(ref num2, ref b);
#else
                NumericsHelpers.Swap(ref reg1, ref reg2);
                NumericsHelpers.Swap(ref num2, ref b);
#endif
            }
            if (b == 1) {
                if (num2 == 1) {
                    reg1._uSmall = NumericsHelpers.GCD(reg1._uSmall, reg2._uSmall);
                    return;
                }
                if (reg2._uSmall != 0) {
                    reg1.Set(NumericsHelpers.GCD(Mod(ref reg1, reg2._uSmall), reg2._uSmall));
                }
                return;
            }
            if (num2 == 2) {
                reg1.Set(NumericsHelpers.GCD(reg1.GetHigh2(2), reg2.GetHigh2(2)));
                return;
            }
            if (b <= (num2 - 2)) {
                reg1.Mod(ref reg2);
                goto Label_0002;
            }
            ulong a = reg1.GetHigh2(num2);
            ulong num5 = reg2.GetHigh2(num2);
            int num6 = NumericsHelpers.CbitHighZero((ulong)(a | num5));
            if (num6 > 0) {
                a = (a << num6) | (reg1._rgu[num2 - 3] >> (0x20 - num6));
                num5 = (num5 << num6) | (reg2._rgu[num2 - 3] >> (0x20 - num6));
            }
            if (a < num5) {
#if !(dotNET10 || dotNET11 || dotNETCF10)
                NumericsHelpers.Swap<ulong>(ref a, ref num5);
                NumericsHelpers.Swap<BigIntegerBuilder>(ref reg1, ref reg2);
#else
                NumericsHelpers.Swap(ref a, ref num5);
                NumericsHelpers.Swap(ref reg1, ref reg2);
#endif
            }
            if ((a == ulong.MaxValue) || (num5 == ulong.MaxValue)) {
                a = a >> 1;
                num5 = num5 >> 1;
            }
            if (a == num5) {
                reg1.Sub(ref sign, ref reg2);
                goto Label_0002;
            }
            if (NumericsHelpers.GetHi(num5) == 0) {
                reg1.Mod(ref reg2);
                goto Label_0002;
            }
            uint num7 = 1;
            uint num8 = 0;
            uint num9 = 0;
            uint num10 = 1;
        Label_0159:
            num11 = 1;
            ulong num12 = a - num5;
            while ((num12 >= num5) && (num11 < 0x20)) {
                num12 -= num5;
                num11++;
            }
            if (num12 >= num5) {
                ulong num13 = a / num5;
                if (num13 > 0xffffffffL) {
                    goto Label_029E;
                }
                num11 = (uint)num13;
                num12 = a - (num11 * num5);
            }
            ulong num14 = (ulong)num7 + (ulong)num11 * (ulong)num9;
            ulong num15 = (ulong)num8 + (ulong)num11 * (ulong)num10;
            if (((num14 <= 0x7fffffffL) && (num15 <= 0x7fffffffL)) && ((num12 >= num15) && ((num12 + num14) <= (num5 - num9)))) {
                num7 = (uint)num14;
                num8 = (uint)num15;
                a = num12;
                if (a > num8) {
                    num11 = 1;
                    num12 = num5 - a;
                    while ((num12 >= a) && (num11 < 0x20)) {
                        num12 -= a;
                        num11++;
                    }
                    if (num12 >= a) {
                        ulong num16 = num5 / a;
                        if (num16 > 0xffffffffL) {
                            goto Label_029E;
                        }
                        num11 = (uint)num16;
                        num12 = num5 - (num11 * a);
                    }
                    num14 = (ulong)num10 + (ulong)num11 * (ulong)num8;
                    num15 = (ulong)num9 + (ulong)num11 * (ulong)num7;
                    if (((num14 <= 0x7fffffffL) && (num15 <= 0x7fffffffL)) && ((num12 >= num15) && ((num12 + num14) <= (a - num8)))) {
                        num10 = (uint)num14;
                        num9 = (uint)num15;
                        num5 = num12;
                        if (num5 > num9) {
                            goto Label_0159;
                        }
                    }
                }
            }
        Label_029E:
            if (num8 == 0) {
                if ((a / ((ulong)2L)) >= num5) {
                    reg1.Mod(ref reg2);
                }
                else {
                    reg1.Sub(ref sign, ref reg2);
                }
            }
            else {
                reg1.SetSizeKeep(b, 0);
                reg2.SetSizeKeep(b, 0);
                int num17 = 0;
                int num18 = 0;
                for (int i = 0; i < b; i++) {
                    uint num20 = reg1._rgu[i];
                    uint num21 = reg2._rgu[i];
                    long num22 = (long)num20 * (long)num7 - (long)num21 * (long)num8 + (long)num17;
                    long num23 = (long)num21 * (long)num10 - (long)num20 * (long)num9 + (long)num18;
                    num17 = (int)(num22 >> 0x20);
                    num18 = (int)(num23 >> 0x20);
                    reg1._rgu[i] = (uint)num22;
                    reg2._rgu[i] = (uint)num23;
                }
                reg1.Trim();
                reg2.Trim();
            }
            goto Label_0002;
        }

        public int CbitLowZero() {
            if (this._iuLast == 0) {
                if (((this._uSmall & 1) == 0) && (this._uSmall != 0)) {
                    return NumericsHelpers.CbitLowZero(this._uSmall);
                }
                return 0;
            }
            int index = 0;
            while (this._rgu[index] == 0) {
                index++;
            }
            return (NumericsHelpers.CbitLowZero(this._rgu[index]) + (index * 0x20));
        }

        public int MakeOdd() {
            int cbit = this.CbitLowZero();
            if (cbit > 0) {
                this.ShiftRight(cbit);
            }
            return cbit;
        }
#if (dotNET10 || dotNET11 || dotNETCF10 || dotNETCF20)
        private static void Resize(ref uint[] array, int newSize) {
            if (newSize < 0) {
                throw new ArgumentOutOfRangeException("The number must be greater than or equal to zero.");
            }
            uint[] sourceArray = array;
            if (sourceArray == null) {
                array = new uint[newSize];
            }
            else if (sourceArray.Length != newSize) {
                uint[] destinationArray = new uint[newSize];
                Array.Copy(sourceArray, 0, destinationArray, 0, (sourceArray.Length > newSize) ? newSize : sourceArray.Length);
                array = destinationArray;
            }
        }
#endif
    }
}

