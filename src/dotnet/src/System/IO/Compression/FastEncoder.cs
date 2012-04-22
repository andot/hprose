#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.IO;

namespace System.IO.Compression {

    internal class FastEncoder {
        private Match currentMatch;
        private uint gzipCrc32;
        private bool hasBlockHeader;
        private bool hasGzipHeader;
        private DeflateInput inputBuffer;
        private uint inputStreamSize;
        private FastEncoderWindow inputWindow;
        private bool needsEOB;
        private Output output;
        private bool usingGzip;

        public FastEncoder(bool doGZip) {
            this.usingGzip = doGZip;
            this.inputWindow = new FastEncoderWindow();
            this.inputBuffer = new DeflateInput();
            this.output = new Output();
            this.currentMatch = new Match();
        }

        public int Finish(byte[] outputBuffer) {
            this.output.UpdateBuffer(outputBuffer);
            if (this.needsEOB) {
                uint num = FastEncoderStatics.FastEncoderLiteralCodeInfo[0x100];
                int n = ((int)num) & 0x1f;
                this.output.WriteBits(n, num >> 5);
                this.output.FlushBits();
                if (this.usingGzip) {
                    this.output.WriteGzipFooter(this.gzipCrc32, this.inputStreamSize);
                }
            }
            return this.output.BytesWritten;
        }

        public int GetCompressedOutput(byte[] outputBuffer) {
            this.output.UpdateBuffer(outputBuffer);
            if (this.usingGzip && !this.hasGzipHeader) {
                this.output.WriteGzipHeader(3);
                this.hasGzipHeader = true;
            }
            if (!this.hasBlockHeader) {
                this.hasBlockHeader = true;
                this.output.WritePreamble();
            }
            do {
                int count = (this.inputBuffer.Count < this.inputWindow.FreeWindowSpace) ? this.inputBuffer.Count : this.inputWindow.FreeWindowSpace;
                if (count > 0) {
                    this.inputWindow.CopyBytes(this.inputBuffer.Buffer, this.inputBuffer.StartIndex, count);
                    if (this.usingGzip) {
                        this.gzipCrc32 = DecodeHelper.UpdateCrc32(this.gzipCrc32, this.inputBuffer.Buffer, this.inputBuffer.StartIndex, count);
                        uint num2 = this.inputStreamSize + ((uint)count);
                        if (num2 < this.inputStreamSize) {
                            throw new InvalidDataException("The gzip stream can't contain more than 4GB data.");
                        }
                        this.inputStreamSize = num2;
                    }
                    this.inputBuffer.ConsumeBytes(count);
                }
                while ((this.inputWindow.BytesAvailable > 0) && this.output.SafeToWriteTo()) {
                    this.inputWindow.GetNextSymbolOrMatch(this.currentMatch);
                    if (this.currentMatch.State == MatchState.HasSymbol) {
                        this.output.WriteChar(this.currentMatch.Symbol);
                    }
                    else {
                        if (this.currentMatch.State == MatchState.HasMatch) {
                            this.output.WriteMatch(this.currentMatch.Length, this.currentMatch.Position);
                            continue;
                        }
                        this.output.WriteChar(this.currentMatch.Symbol);
                        this.output.WriteMatch(this.currentMatch.Length, this.currentMatch.Position);
                    }
                }
            }
            while (this.output.SafeToWriteTo() && !this.NeedsInput());
            this.needsEOB = true;
            return this.output.BytesWritten;
        }

        public bool NeedsInput() {
            return ((this.inputBuffer.Count == 0) && (this.inputWindow.BytesAvailable == 0));
        }

        public void SetInput(byte[] input, int startIndex, int count) {
            this.inputBuffer.Buffer = input;
            this.inputBuffer.Count = count;
            this.inputBuffer.StartIndex = startIndex;
        }

        internal class Output {
            private uint bitBuf;
            private int bitCount;
            private static byte[] distLookup = new byte[0x200];
            private byte[] outputBuf;
            private int outputPos;

            static Output() {
                GenerateSlotTables();
            }

            internal void FlushBits() {
                while (this.bitCount >= 8) {
                    this.outputBuf[this.outputPos++] = (byte)this.bitBuf;
                    this.bitCount -= 8;
                    this.bitBuf = this.bitBuf >> 8;
                }
                if (this.bitCount > 0) {
                    this.outputBuf[this.outputPos++] = (byte)this.bitBuf;
                    this.bitCount = 0;
                }
            }

            internal static void GenerateSlotTables() {
                int num = 0;
                int index = 0;
                while (index < 0x10) {
                    for (int i = 0; i < (((int)1) << FastEncoderStatics.ExtraDistanceBits[index]); i++) {
                        distLookup[num++] = (byte)index;
                    }
                    index++;
                }
                num = num >> 7;
                while (index < 30) {
                    for (int j = 0; j < (((int)1) << (FastEncoderStatics.ExtraDistanceBits[index] - 7)); j++) {
                        distLookup[0x100 + num++] = (byte)index;
                    }
                    index++;
                }
            }

            internal int GetSlot(int pos) {
                return distLookup[(pos < 0x100) ? pos : (0x100 + (pos >> 7))];
            }

            internal bool SafeToWriteTo() {
                return ((this.outputBuf.Length - this.outputPos) > 0x10);
            }

            internal void UpdateBuffer(byte[] output) {
                this.outputBuf = output;
                this.outputPos = 0;
            }

            internal void WriteBits(int n, uint bits) {
                this.bitBuf |= bits << this.bitCount;
                this.bitCount += n;
                if (this.bitCount >= 0x10) {
                    this.outputBuf[this.outputPos++] = (byte)this.bitBuf;
                    this.outputBuf[this.outputPos++] = (byte)(this.bitBuf >> 8);
                    this.bitCount -= 0x10;
                    this.bitBuf = this.bitBuf >> 0x10;
                }
            }

            internal void WriteChar(byte b) {
                uint num = FastEncoderStatics.FastEncoderLiteralCodeInfo[b];
                this.WriteBits(((int)num) & 0x1f, num >> 5);
            }

            internal void WriteGzipFooter(uint gzipCrc32, uint inputStreamSize) {
                this.outputBuf[this.outputPos++] = (byte)(gzipCrc32 & 0xff);
                this.outputBuf[this.outputPos++] = (byte)((gzipCrc32 >> 8) & 0xff);
                this.outputBuf[this.outputPos++] = (byte)((gzipCrc32 >> 0x10) & 0xff);
                this.outputBuf[this.outputPos++] = (byte)((gzipCrc32 >> 0x18) & 0xff);
                this.outputBuf[this.outputPos++] = (byte)(inputStreamSize & 0xff);
                this.outputBuf[this.outputPos++] = (byte)((inputStreamSize >> 8) & 0xff);
                this.outputBuf[this.outputPos++] = (byte)((inputStreamSize >> 0x10) & 0xff);
                this.outputBuf[this.outputPos++] = (byte)((inputStreamSize >> 0x18) & 0xff);
            }

            internal void WriteGzipHeader(int compression_level) {
                this.outputBuf[this.outputPos++] = 0x1f;
                this.outputBuf[this.outputPos++] = 0x8b;
                this.outputBuf[this.outputPos++] = 8;
                this.outputBuf[this.outputPos++] = 0;
                this.outputBuf[this.outputPos++] = 0;
                this.outputBuf[this.outputPos++] = 0;
                this.outputBuf[this.outputPos++] = 0;
                this.outputBuf[this.outputPos++] = 0;
                if (compression_level == 10) {
                    this.outputBuf[this.outputPos++] = 2;
                }
                else {
                    this.outputBuf[this.outputPos++] = 4;
                }
                this.outputBuf[this.outputPos++] = 0;
            }

            internal void WriteMatch(int matchLen, int matchPos) {
                uint num = FastEncoderStatics.FastEncoderLiteralCodeInfo[0xfe + matchLen];
                int n = ((int)num) & 0x1f;
                if (n <= 0x10) {
                    this.WriteBits(n, num >> 5);
                }
                else {
                    this.WriteBits(0x10, (num >> 5) & 0xffff);
                    this.WriteBits(n - 0x10, num >> 0x15);
                }
                num = FastEncoderStatics.FastEncoderDistanceCodeInfo[this.GetSlot(matchPos)];
                this.WriteBits(((int)num) & 15, num >> 8);
                int num3 = ((int)(num >> 4)) & 15;
                if (num3 != 0) {
                    this.WriteBits(num3, ((uint)matchPos) & FastEncoderStatics.BitMask[num3]);
                }
            }

            internal void WritePreamble() {
                Array.Copy(FastEncoderStatics.FastEncoderTreeStructureData, 0, this.outputBuf, this.outputPos, FastEncoderStatics.FastEncoderTreeStructureData.Length);
                this.outputPos += FastEncoderStatics.FastEncoderTreeStructureData.Length;
                this.bitCount = 9;
                this.bitBuf = 0x22;
            }

            internal int BytesWritten {
                get {
                    return this.outputPos;
                }
            }

            internal int FreeBytes {
                get {
                    return (this.outputBuf.Length - this.outputPos);
                }
            }
        }
    }
}
#endif