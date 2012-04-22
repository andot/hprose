#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace System.IO.Compression {

    internal class FastEncoderWindow {
        private int bufEnd;
        private int bufPos = 0x2000;
        private const int FastEncoderHashMask = 0x7ff;
        private const int FastEncoderHashShift = 4;
        private const int FastEncoderHashtableSize = 0x800;
        private const int FastEncoderMatch3DistThreshold = 0x4000;
        private const int FastEncoderWindowMask = 0x1fff;
        private const int FastEncoderWindowSize = 0x2000;
        private const int GoodLength = 4;
        private const int LazyMatchThreshold = 6;
        private ushort[] lookup = new ushort[0x800];
        internal const int MaxMatch = 0x102;
        internal const int MinMatch = 3;
        private const int NiceLength = 0x20;
        private ushort[] prev = new ushort[0x2102];
        private const int SearchDepth = 0x20;
        private byte[] window = new byte[0x4106];

        public FastEncoderWindow() {
            this.bufEnd = this.bufPos;
        }

        public void CopyBytes(byte[] inputBuffer, int startIndex, int count) {
            Array.Copy(inputBuffer, startIndex, this.window, this.bufEnd, count);
            this.bufEnd += count;
        }

        private int FindMatch(int search, out int matchPos, int searchDepth, int niceLength) {
            int num = 0;
            int num2 = 0;
            int num3 = this.bufPos - 0x2000;
            byte num4 = this.window[this.bufPos];
            while (search > num3) {
                if (this.window[search + num] == num4) {
                    int num5 = 0;
                    while (num5 < 0x102) {
                        if (this.window[this.bufPos + num5] != this.window[search + num5]) {
                            break;
                        }
                        num5++;
                    }
                    if (num5 > num) {
                        num = num5;
                        num2 = search;
                        if (num5 > 0x20) {
                            break;
                        }
                        num4 = this.window[this.bufPos + num5];
                    }
                }
                if (--searchDepth == 0) {
                    break;
                }
                search = this.prev[search & 0x1fff];
            }
            matchPos = (this.bufPos - num2) - 1;
            if ((num == 3) && (matchPos >= 0x4000)) {
                return 0;
            }
            return num;
        }

        internal bool GetNextSymbolOrMatch(Match match) {
            int num2;
            uint hash = this.HashValue(0, this.window[this.bufPos]);
            hash = this.HashValue(hash, this.window[this.bufPos + 1]);
            int matchPos = 0;
            if ((this.bufEnd - this.bufPos) <= 3) {
                num2 = 0;
            }
            else {
                int search = (int)this.InsertString(ref hash);
                if (search != 0) {
                    num2 = this.FindMatch(search, out matchPos, 0x20, 0x20);
                    if ((this.bufPos + num2) > this.bufEnd) {
                        num2 = this.bufEnd - this.bufPos;
                    }
                }
                else {
                    num2 = 0;
                }
            }
            if (num2 < 3) {
                match.State = MatchState.HasSymbol;
                match.Symbol = this.window[this.bufPos];
                this.bufPos++;
            }
            else {
                this.bufPos++;
                if (num2 <= 6) {
                    int num5;
                    int num6 = 0;
                    int num7 = (int)this.InsertString(ref hash);
                    if (num7 != 0) {
                        num5 = this.FindMatch(num7, out num6, (num2 < 4) ? 0x20 : 8, 0x20);
                        if ((this.bufPos + num5) > this.bufEnd) {
                            num5 = this.bufEnd - this.bufPos;
                        }
                    }
                    else {
                        num5 = 0;
                    }
                    if (num5 > num2) {
                        match.State = MatchState.HasSymbolAndMatch;
                        match.Symbol = this.window[this.bufPos - 1];
                        match.Position = num6;
                        match.Length = num5;
                        this.bufPos++;
                        num2 = num5;
                        this.InsertStrings(ref hash, num2);
                    }
                    else {
                        match.State = MatchState.HasMatch;
                        match.Position = matchPos;
                        match.Length = num2;
                        num2--;
                        this.bufPos++;
                        this.InsertStrings(ref hash, num2);
                    }
                }
                else {
                    match.State = MatchState.HasMatch;
                    match.Position = matchPos;
                    match.Length = num2;
                    this.InsertStrings(ref hash, num2);
                }
            }
            if (this.bufPos == 0x4000) {
                this.MoveWindows();
            }
            return true;
        }

        private uint HashValue(uint hash, byte b) {
            return ((hash << 4) ^ b);
        }

        private uint InsertString(ref uint hash) {
            hash = this.HashValue(hash, this.window[this.bufPos + 2]);
            uint num = this.lookup[hash & 0x7ff];
            this.lookup[hash & 0x7ff] = (ushort)this.bufPos;
            this.prev[this.bufPos & 0x1fff] = (ushort)num;
            return num;
        }

        private void InsertStrings(ref uint hash, int matchLen) {
            if ((this.bufEnd - this.bufPos) <= matchLen) {
                this.bufPos += matchLen - 1;
            }
            else {
                while (--matchLen > 0) {
                    this.InsertString(ref hash);
                    this.bufPos++;
                }
            }
        }

        public void MoveWindows() {
            int num;
            Array.Copy(this.window, this.bufPos - 0x2000, this.window, 0, 0x2000);
            for (num = 0; num < 0x800; num++) {
                int num2 = this.lookup[num] - 0x2000;
                if (num2 <= 0) {
                    this.lookup[num] = 0;
                }
                else {
                    this.lookup[num] = (ushort)num2;
                }
            }
            for (num = 0; num < 0x2000; num++) {
                long num3 = this.prev[num] - 0x2000L;
                if (num3 <= 0L) {
                    this.prev[num] = 0;
                }
                else {
                    this.prev[num] = (ushort)num3;
                }
            }
            this.bufPos = 0x2000;
            this.bufEnd = this.bufPos;
        }

        public int BytesAvailable {
            get {
                return (this.bufEnd - this.bufPos);
            }
        }

        public int FreeWindowSpace {
            get {
                return (0x4000 - this.bufEnd);
            }
        }
    }
}
#endif