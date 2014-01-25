#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.IO;
using System.Runtime.InteropServices;

namespace System.IO.Compression {

    internal class Inflater {
        private int bfinal;
        private int blockLength;
        private byte[] blockLengthBuffer = new byte[4];
        private BlockType blockType;
        private int codeArraySize;
        private int codeLengthCodeCount;
        private HuffmanTree codeLengthTree;
        private byte[] codeLengthTreeCodeLength;
        private byte[] codeList;
        private static readonly byte[] codeOrder = new byte[] {
            0x10, 0x11, 0x12, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2,
            14, 1, 15
         };
        private uint crc32;
        private static readonly int[] distanceBasePosition = new int[] {
            1, 2, 3, 4, 5, 7, 9, 13, 0x11, 0x19, 0x21, 0x31, 0x41, 0x61, 0x81, 0xc1,
            0x101, 0x181, 0x201, 0x301, 0x401, 0x601, 0x801, 0xc01, 0x1001, 0x1801, 0x2001, 0x3001, 0x4001, 0x6001, 0, 0
         };
        private int distanceCode;
        private int distanceCodeCount;
        private HuffmanTree distanceTree;
        private int extraBits;
        private static readonly byte[] extraLengthBits = new byte[] {
            0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
            3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0
         };
        private GZipDecoder gZipDecoder;
        private InputBuffer input;
        private int length;
        private static readonly int[] lengthBase = new int[] {
            3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 0x11, 0x13, 0x17, 0x1b, 0x1f,
            0x23, 0x2b, 0x33, 0x3b, 0x43, 0x53, 0x63, 0x73, 0x83, 0xa3, 0xc3, 0xe3, 0x102
         };
        private int lengthCode;
        private int literalLengthCodeCount;
        private HuffmanTree literalLengthTree;
        private int loopCounter;
        private OutputWindow output;
        private InflaterState state;
        private static readonly byte[] staticDistanceTreeTable = new byte[] {
            0, 0x10, 8, 0x18, 4, 20, 12, 0x1c, 2, 0x12, 10, 0x1a, 6, 0x16, 14, 30,
            1, 0x11, 9, 0x19, 5, 0x15, 13, 0x1d, 3, 0x13, 11, 0x1b, 7, 0x17, 15, 0x1f
         };
        private uint streamSize;
        private bool using_gzip;

        public Inflater(bool doGZip) {
            this.using_gzip = doGZip;
            this.output = new OutputWindow();
            this.input = new InputBuffer();
            this.gZipDecoder = new GZipDecoder(this.input);
            this.codeList = new byte[320];
            this.codeLengthTreeCodeLength = new byte[0x13];
            this.Reset();
        }

        private bool Decode() {
            bool flag = false;
            bool flag2 = false;
            if (this.Finished()) {
                return true;
            }
            if (this.using_gzip) {
                if (this.state == InflaterState.ReadingGZIPHeader) {
                    if (!this.gZipDecoder.ReadGzipHeader()) {
                        return false;
                    }
                    this.state = InflaterState.ReadingBFinal;
                }
                else if ((this.state == InflaterState.StartReadingGZIPFooter) || (this.state == InflaterState.ReadingGZIPFooter)) {
                    if (!this.gZipDecoder.ReadGzipFooter()) {
                        return false;
                    }
                    this.state = InflaterState.VerifyingGZIPFooter;
                    return true;
                }
            }
            if (this.state == InflaterState.ReadingBFinal) {
                if (!this.input.EnsureBitsAvailable(1)) {
                    return false;
                }
                this.bfinal = this.input.GetBits(1);
                this.state = InflaterState.ReadingBType;
            }
            if (this.state == InflaterState.ReadingBType) {
                if (!this.input.EnsureBitsAvailable(2)) {
                    this.state = InflaterState.ReadingBType;
                    return false;
                }
                this.blockType = (BlockType)this.input.GetBits(2);
                if (this.blockType != BlockType.Dynamic) {
                    if (this.blockType != BlockType.Static) {
                        if (this.blockType != BlockType.Uncompressed) {
                            throw new InvalidDataException("Unknown block type. Stream might be corrupted.");
                        }
                        this.state = InflaterState.UncompressedAligning;
                    }
                    else {
                        this.literalLengthTree = HuffmanTree.StaticLiteralLengthTree;
                        this.distanceTree = HuffmanTree.StaticDistanceTree;
                        this.state = InflaterState.DecodeTop;
                    }
                }
                else {
                    this.state = InflaterState.ReadingNumLitCodes;
                }
            }
            if (this.blockType == BlockType.Dynamic) {
                if (this.state < InflaterState.DecodeTop) {
                    flag2 = this.DecodeDynamicBlockHeader();
                }
                else {
                    flag2 = this.DecodeBlock(out flag);
                }
            }
            else if (this.blockType == BlockType.Static) {
                flag2 = this.DecodeBlock(out flag);
            }
            else {
                if (this.blockType != BlockType.Uncompressed) {
                    throw new InvalidDataException("Unknown block type. Stream might be corrupted.");
                }
                flag2 = this.DecodeUncompressedBlock(out flag);
            }
            if (flag && (this.bfinal != 0)) {
                if (this.using_gzip) {
                    this.state = InflaterState.StartReadingGZIPFooter;
                    return flag2;
                }
                this.state = InflaterState.Done;
            }
            return flag2;
        }

        private bool DecodeBlock(out bool end_of_block_code_seen) {
            end_of_block_code_seen = false;
            int freeBytes = this.output.FreeBytes;
            while (freeBytes > 0x102) {
                int nextSymbol;
                int num4;
                switch (this.state) {
                    case InflaterState.DecodeTop:
                        nextSymbol = this.literalLengthTree.GetNextSymbol(this.input);
                        if (nextSymbol >= 0) {
                            break;
                        }
                        return false;

                    case InflaterState.HaveInitialLength:
                        goto Label_00C6;

                    case InflaterState.HaveFullLength:
                        goto Label_010B;

                    case InflaterState.HaveDistCode:
                        goto Label_016D;

                    default:
                        throw new InvalidDataException("Decoder is in some unknown state. This might be caused by corrupted data.");
                }
                if (nextSymbol < 0x100) {
                    this.output.Write((byte)nextSymbol);
                    freeBytes--;
                    continue;
                }
                if (nextSymbol == 0x100) {
                    end_of_block_code_seen = true;
                    this.state = InflaterState.ReadingBFinal;
                    return true;
                }
                nextSymbol -= 0x101;
                if (nextSymbol < 8) {
                    nextSymbol += 3;
                    this.extraBits = 0;
                }
                else if (nextSymbol == 0x1c) {
                    nextSymbol = 0x102;
                    this.extraBits = 0;
                }
                else {
                    this.extraBits = extraLengthBits[nextSymbol];
                }
                this.length = nextSymbol;
            Label_00C6:
                if (this.extraBits > 0) {
                    this.state = InflaterState.HaveInitialLength;
                    int bits = this.input.GetBits(this.extraBits);
                    if (bits < 0) {
                        return false;
                    }
                    this.length = lengthBase[this.length] + bits;
                }
                this.state = InflaterState.HaveFullLength;
            Label_010B:
                if (this.blockType == BlockType.Dynamic) {
                    this.distanceCode = this.distanceTree.GetNextSymbol(this.input);
                }
                else {
                    this.distanceCode = this.input.GetBits(5);
                    if (this.distanceCode >= 0) {
                        this.distanceCode = staticDistanceTreeTable[this.distanceCode];
                    }
                }
                if (this.distanceCode < 0) {
                    return false;
                }
                this.state = InflaterState.HaveDistCode;
            Label_016D:
                if (this.distanceCode > 3) {
                    this.extraBits = (this.distanceCode - 2) >> 1;
                    int num5 = this.input.GetBits(this.extraBits);
                    if (num5 < 0) {
                        return false;
                    }
                    num4 = distanceBasePosition[this.distanceCode] + num5;
                }
                else {
                    num4 = this.distanceCode + 1;
                }
                this.output.WriteLengthDistance(this.length, num4);
                freeBytes -= this.length;
                this.state = InflaterState.DecodeTop;
            }
            return true;
        }

        private bool DecodeDynamicBlockHeader() {
            switch (this.state) {
                case InflaterState.ReadingNumLitCodes:
                    this.literalLengthCodeCount = this.input.GetBits(5);
                    if (this.literalLengthCodeCount >= 0) {
                        this.literalLengthCodeCount += 0x101;
                        this.state = InflaterState.ReadingNumDistCodes;
                        break;
                    }
                    return false;

                case InflaterState.ReadingNumDistCodes:
                    break;

                case InflaterState.ReadingNumCodeLengthCodes:
                    goto Label_0096;

                case InflaterState.ReadingCodeLengthCodes:
                    goto Label_0107;

                case InflaterState.ReadingTreeCodesBefore:
                case InflaterState.ReadingTreeCodesAfter:
                    goto Label_0315;

                default:
                    throw new InvalidDataException("Decoder is in some unknown state. This might be caused by corrupted data.");
            }
            this.distanceCodeCount = this.input.GetBits(5);
            if (this.distanceCodeCount < 0) {
                return false;
            }
            this.distanceCodeCount++;
            this.state = InflaterState.ReadingNumCodeLengthCodes;
        Label_0096:
            this.codeLengthCodeCount = this.input.GetBits(4);
            if (this.codeLengthCodeCount < 0) {
                return false;
            }
            this.codeLengthCodeCount += 4;
            this.loopCounter = 0;
            this.state = InflaterState.ReadingCodeLengthCodes;
        Label_0107:
            while (this.loopCounter < this.codeLengthCodeCount) {
                int bits = this.input.GetBits(3);
                if (bits < 0) {
                    return false;
                }
                this.codeLengthTreeCodeLength[codeOrder[this.loopCounter]] = (byte)bits;
                this.loopCounter++;
            }
            for (int i = this.codeLengthCodeCount; i < codeOrder.Length; i++) {
                this.codeLengthTreeCodeLength[codeOrder[i]] = 0;
            }
            this.codeLengthTree = new HuffmanTree(this.codeLengthTreeCodeLength);
            this.codeArraySize = this.literalLengthCodeCount + this.distanceCodeCount;
            this.loopCounter = 0;
            this.state = InflaterState.ReadingTreeCodesBefore;
        Label_0315:
            while (this.loopCounter < this.codeArraySize) {
                if ((this.state == InflaterState.ReadingTreeCodesBefore) && ((this.lengthCode = this.codeLengthTree.GetNextSymbol(this.input)) < 0)) {
                    return false;
                }
                if (this.lengthCode <= 15) {
                    this.codeList[this.loopCounter++] = (byte)this.lengthCode;
                }
                else {
                    int num3;
                    if (!this.input.EnsureBitsAvailable(7)) {
                        this.state = InflaterState.ReadingTreeCodesAfter;
                        return false;
                    }
                    if (this.lengthCode == 0x10) {
                        if (this.loopCounter == 0) {
                            throw new InvalidDataException();
                        }
                        byte num4 = this.codeList[this.loopCounter - 1];
                        num3 = this.input.GetBits(2) + 3;
                        if ((this.loopCounter + num3) > this.codeArraySize) {
                            throw new InvalidDataException();
                        }
                        for (int j = 0; j < num3; j++) {
                            this.codeList[this.loopCounter++] = num4;
                        }
                    }
                    else if (this.lengthCode == 0x11) {
                        num3 = this.input.GetBits(3) + 3;
                        if ((this.loopCounter + num3) > this.codeArraySize) {
                            throw new InvalidDataException();
                        }
                        for (int k = 0; k < num3; k++) {
                            this.codeList[this.loopCounter++] = 0;
                        }
                    }
                    else {
                        num3 = this.input.GetBits(7) + 11;
                        if ((this.loopCounter + num3) > this.codeArraySize) {
                            throw new InvalidDataException();
                        }
                        for (int m = 0; m < num3; m++) {
                            this.codeList[this.loopCounter++] = 0;
                        }
                    }
                }
                this.state = InflaterState.ReadingTreeCodesBefore;
            }
            byte[] destinationArray = new byte[0x120];
            byte[] buffer2 = new byte[0x20];
            Array.Copy(this.codeList, 0, destinationArray, 0, this.literalLengthCodeCount);
            Array.Copy(this.codeList, this.literalLengthCodeCount, buffer2, 0, this.distanceCodeCount);
            if (destinationArray[0x100] == 0) {
                throw new InvalidDataException();
            }
            this.literalLengthTree = new HuffmanTree(destinationArray);
            this.distanceTree = new HuffmanTree(buffer2);
            this.state = InflaterState.DecodeTop;
            return true;
        }

        private bool DecodeUncompressedBlock(out bool end_of_block) {
            end_of_block = false;
            while (true) {
                switch (this.state) {
                    case InflaterState.UncompressedAligning:
                        this.input.SkipToByteBoundary();
                        this.state = InflaterState.UncompressedByte1;
                        break;

                    case InflaterState.UncompressedByte1:
                    case InflaterState.UncompressedByte2:
                    case InflaterState.UncompressedByte3:
                    case InflaterState.UncompressedByte4:
                        break;

                    case InflaterState.DecodingUncompressed: {
                            int num3 = this.output.CopyFrom(this.input, this.blockLength);
                            this.blockLength -= num3;
                            if (this.blockLength != 0) {
                                return (this.output.FreeBytes == 0);
                            }
                            this.state = InflaterState.ReadingBFinal;
                            end_of_block = true;
                            return true;
                        }
                    default:
                        throw new InvalidDataException("Decoder is in some unknown state. This might be caused by corrupted data.");
                }
                int bits = this.input.GetBits(8);
                if (bits < 0) {
                    return false;
                }
                this.blockLengthBuffer[((int)this.state) - 0x10] = (byte)bits;
                if (this.state == InflaterState.UncompressedByte4) {
                    this.blockLength = this.blockLengthBuffer[0] + (this.blockLengthBuffer[1] * 0x100);
                    int num2 = this.blockLengthBuffer[2] + (this.blockLengthBuffer[3] * 0x100);
                    if (((ushort)this.blockLength) != ((ushort)~num2)) {
                        throw new InvalidDataException("Block length does not match with its complement.");
                    }
                }
                this.state += 1;
            }
        }

        public bool Finished() {
            if (this.state != InflaterState.Done) {
                return (this.state == InflaterState.VerifyingGZIPFooter);
            }
            return true;
        }

        public int Inflate(byte[] bytes, int offset, int length) {
            int num = 0;
            do {
                int num2 = this.output.CopyTo(bytes, offset, length);
                if (num2 > 0) {
                    if (this.using_gzip) {
                        this.crc32 = DecodeHelper.UpdateCrc32(this.crc32, bytes, offset, num2);
                        uint num3 = this.streamSize + ((uint)num2);
                        if (num3 < this.streamSize) {
                            throw new InvalidDataException("The gzip stream can't contain more than 4GB data.");
                        }
                        this.streamSize = num3;
                    }
                    offset += num2;
                    num += num2;
                    length -= num2;
                }
            }
            while (((length != 0) && !this.Finished()) && this.Decode());
            if ((this.state == InflaterState.VerifyingGZIPFooter) && (this.output.AvailableBytes == 0)) {
                if (this.crc32 != this.gZipDecoder.Crc32) {
                    throw new InvalidDataException("The CRC in GZip footer does not match the CRC calculated from the decompressed data.");
                }
                if (this.streamSize != this.gZipDecoder.StreamSize) {
                    throw new InvalidDataException("The stream size in GZip footer does not match the real stream size.");
                }
            }
            return num;
        }

        public bool NeedsInput() {
            return this.input.NeedsInput();
        }

        public void Reset() {
            if (this.using_gzip) {
                this.gZipDecoder.Reset();
                this.state = InflaterState.ReadingGZIPHeader;
                this.streamSize = 0;
                this.crc32 = 0;
            }
            else {
                this.state = InflaterState.ReadingBFinal;
            }
        }

        public void SetInput(byte[] inputBytes, int offset, int length) {
            this.input.SetInput(inputBytes, offset, length);
        }

        public int AvailableOutput {
            get {
                return this.output.AvailableBytes;
            }
        }
    }
}
#endif