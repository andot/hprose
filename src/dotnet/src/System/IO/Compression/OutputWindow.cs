#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;

namespace System.IO.Compression {

    internal class OutputWindow {
        private int bytesUsed;
        private int end;
        private byte[] window = new byte[0x8000];
        private const int WindowMask = 0x7fff;
        private const int WindowSize = 0x8000;

        public int CopyFrom(InputBuffer input, int length) {
            int num;
            length = Math.Min(Math.Min(length, 0x8000 - this.bytesUsed), input.AvailableBytes);
            int num2 = 0x8000 - this.end;
            if (length > num2) {
                num = input.CopyTo(this.window, this.end, num2);
                if (num == num2) {
                    num += input.CopyTo(this.window, 0, length - num2);
                }
            }
            else {
                num = input.CopyTo(this.window, this.end, length);
            }
            this.end = (this.end + num) & 0x7fff;
            this.bytesUsed += num;
            return num;
        }

        public int CopyTo(byte[] output, int offset, int length) {
            int end;
            if (length > this.bytesUsed) {
                end = this.end;
                length = this.bytesUsed;
            }
            else {
                end = ((this.end - this.bytesUsed) + length) & 0x7fff;
            }
            int num2 = length;
            int num3 = length - end;
            if (num3 > 0) {
                Array.Copy(this.window, 0x8000 - num3, output, offset, num3);
                offset += num3;
                length = end;
            }
            Array.Copy(this.window, end - length, output, offset, length);
            this.bytesUsed -= num2;
            return num2;
        }

        public void Write(byte b) {
            this.window[this.end++] = b;
            this.end &= 0x7fff;
            this.bytesUsed++;
        }

        public void WriteLengthDistance(int length, int distance) {
            this.bytesUsed += length;
            int sourceIndex = (this.end - distance) & 0x7fff;
            int num2 = 0x8000 - length;
            if ((sourceIndex <= num2) && (this.end < num2)) {
                if (length > distance) {
                    while (length-- > 0) {
                        this.window[this.end++] = this.window[sourceIndex++];
                    }
                }
                else {
                    Array.Copy(this.window, sourceIndex, this.window, this.end, length);
                    this.end += length;
                }
            }
            else {
                while (length-- > 0) {
                    this.window[this.end++] = this.window[sourceIndex++];
                    this.end &= 0x7fff;
                    sourceIndex &= 0x7fff;
                }
            }
        }

        public int AvailableBytes {
            get {
                return this.bytesUsed;
            }
        }

        public int FreeBytes {
            get {
                return (0x8000 - this.bytesUsed);
            }
        }
    }
}
#endif