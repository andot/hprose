#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.IO;

namespace System.IO.Compression {

    internal class HuffmanTree {
        private byte[] codeLengthArray;
        internal const int EndOfBlockCode = 0x100;
        private short[] left;
        internal const int MaxDistTreeElements = 0x20;
        internal const int MaxLiteralTreeElements = 0x120;
        internal const int NumberOfCodeLengthTreeElements = 0x13;
        private short[] right;
        private static HuffmanTree staticDistanceTree = new HuffmanTree(GetStaticDistanceTreeLength());
        private static HuffmanTree staticLiteralLengthTree = new HuffmanTree(GetStaticLiteralTreeLength());
        private short[] table;
        private int tableBits;
        private int tableMask;

        public HuffmanTree(byte[] codeLengths) {
            this.codeLengthArray = codeLengths;
            if (this.codeLengthArray.Length == 0x120) {
                this.tableBits = 9;
            }
            else {
                this.tableBits = 7;
            }
            this.tableMask = (((int)1) << this.tableBits) - 1;
            this.CreateTable();
        }

        private uint[] CalculateHuffmanCode() {
            uint[] numArray = new uint[0x11];
            byte[] codeLengthArray = this.codeLengthArray;
            for (int i = 0; i < codeLengthArray.Length; i++) {
                int index = codeLengthArray[i];
                numArray[index]++;
            }
            numArray[0] = 0;
            uint[] numArray2 = new uint[0x11];
            uint num2 = 0;
            for (int j = 1; j <= 0x10; j++) {
                numArray2[j] = (num2 + numArray[j - 1]) << 1;
            }
            uint[] numArray3 = new uint[0x120];
            for (int k = 0; k < this.codeLengthArray.Length; k++) {
                int length = this.codeLengthArray[k];
                if (length > 0) {
                    numArray3[k] = DecodeHelper.BitReverse(numArray2[length], length);
                    numArray2[length]++;
                }
            }
            return numArray3;
        }

        private void CreateTable() {
            uint[] numArray = this.CalculateHuffmanCode();
            this.table = new short[((int)1) << this.tableBits];
            this.left = new short[2 * this.codeLengthArray.Length];
            this.right = new short[2 * this.codeLengthArray.Length];
            short length = (short)this.codeLengthArray.Length;
            for (int i = 0; i < this.codeLengthArray.Length; i++) {
                int num3 = this.codeLengthArray[i];
                if (num3 > 0) {
                    int index = (int)numArray[i];
                    if (num3 <= this.tableBits) {
                        int num5 = ((int)1) << num3;
                        if (index >= num5) {
                            throw new InvalidDataException("Failed to construct a huffman tree using the length array. The stream might be corrupted.");
                        }
                        int num6 = ((int)1) << (this.tableBits - num3);
                        for (int j = 0; j < num6; j++) {
                            this.table[index] = (short)i;
                            index += num5;
                        }
                    }
                    else {
                        int num8 = num3 - this.tableBits;
                        int num9 = ((int)1) << this.tableBits;
                        int num10 = index & ((((int)1) << this.tableBits) - 1);
                        short[] table = this.table;
                        do {
                            short num11 = table[num10];
                            if (num11 == 0) {
                                table[num10] = (short)(-length);
                                num11 = (short)(-length);
                                length = (short)(length + 1);
                            }
                            if ((index & num9) == 0) {
                                table = this.left;
                            }
                            else {
                                table = this.right;
                            }
                            num10 = -num11;
                            num9 = num9 << 1;
                            num8--;
                        }
                        while (num8 != 0);
                        table[num10] = (short)i;
                    }
                }
            }
        }

        public int GetNextSymbol(InputBuffer input) {
            uint num = input.TryLoad16Bits();
            if (input.AvailableBits == 0) {
                return -1;
            }
            int index = this.table[(int)((IntPtr)(num & this.tableMask))];
            if (index < 0) {
                uint num3 = ((uint)1) << this.tableBits;
                do {
                    index = -index;
                    if ((num & num3) == 0) {
                        index = this.left[index];
                    }
                    else {
                        index = this.right[index];
                    }
                    num3 = num3 << 1;
                }
                while (index < 0);
            }
            if (this.codeLengthArray[index] > input.AvailableBits) {
                return -1;
            }
            input.SkipBits(this.codeLengthArray[index]);
            return index;
        }

        private static byte[] GetStaticDistanceTreeLength() {
            byte[] buffer = new byte[0x20];
            for (int i = 0; i < 0x20; i++) {
                buffer[i] = 5;
            }
            return buffer;
        }

        private static byte[] GetStaticLiteralTreeLength() {
            byte[] buffer = new byte[0x120];
            for (int i = 0; i <= 0x8f; i++) {
                buffer[i] = 8;
            }
            for (int j = 0x90; j <= 0xff; j++) {
                buffer[j] = 9;
            }
            for (int k = 0x100; k <= 0x117; k++) {
                buffer[k] = 7;
            }
            for (int m = 280; m <= 0x11f; m++) {
                buffer[m] = 8;
            }
            return buffer;
        }

        public static HuffmanTree StaticDistanceTree {
            get {
                return staticDistanceTree;
            }
        }

        public static HuffmanTree StaticLiteralLengthTree {
            get {
                return staticLiteralLengthTree;
            }
        }
    }
}
#endif