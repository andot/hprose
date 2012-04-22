#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.IO;

namespace System.IO.Compression {

    internal class GZipDecoder {
        private const int CommentFlag = 0x10;
        private const int CRCFlag = 2;
        private const int ExtraFieldsFlag = 4;
        private const int FileNameFlag = 8;
        private const int FileText = 1;
        private int gzip_header_flag;
        private int gzip_header_xlen;
        private uint gzipCrc32;
        private GZIPHeaderState gzipFooterSubstate;
        private GZIPHeaderState gzipHeaderSubstate;
        private uint gzipOutputStreamSize;
        private InputBuffer input;
        private int loopCounter;

        public GZipDecoder(InputBuffer input) {
            this.input = input;
            this.Reset();
        }

        public bool ReadGzipFooter() {
            this.input.SkipToByteBoundary();
            if (this.gzipFooterSubstate == GZIPHeaderState.ReadingCRC) {
                while (this.loopCounter < 4) {
                    int bits = this.input.GetBits(8);
                    if (bits < 0) {
                        return false;
                    }
                    this.gzipCrc32 |= (uint)(bits << (8 * this.loopCounter));
                    this.loopCounter++;
                }
                this.gzipFooterSubstate = GZIPHeaderState.ReadingFileSize;
                this.loopCounter = 0;
            }
            if (this.gzipFooterSubstate == GZIPHeaderState.ReadingFileSize) {
                if (this.loopCounter == 0) {
                    this.gzipOutputStreamSize = 0;
                }
                while (this.loopCounter < 4) {
                    int num2 = this.input.GetBits(8);
                    if (num2 < 0) {
                        return false;
                    }
                    this.gzipOutputStreamSize |= (uint)(num2 << (8 * this.loopCounter));
                    this.loopCounter++;
                }
            }
            return true;
        }

        public bool ReadGzipHeader() {
            int bits;
            switch (this.gzipHeaderSubstate) {
                case GZIPHeaderState.ReadingID1:
                    bits = this.input.GetBits(8);
                    if (bits >= 0) {
                        if (bits != 0x1f) {
                            throw new InvalidDataException("The magic number in GZip header is not correct. Make sure you are passing in a GZip stream.");
                        }
                        this.gzipHeaderSubstate = GZIPHeaderState.ReadingID2;
                        break;
                    }
                    return false;

                case GZIPHeaderState.ReadingID2:
                    break;

                case GZIPHeaderState.ReadingCM:
                    goto Label_00AF;

                case GZIPHeaderState.ReadingFLG:
                    goto Label_00DD;

                case GZIPHeaderState.ReadingMMTime:
                    goto Label_0105;

                case GZIPHeaderState.ReadingXFL:
                    goto Label_0141;

                case GZIPHeaderState.ReadingOS:
                    goto Label_015B;

                case GZIPHeaderState.ReadingXLen1:
                    goto Label_0175;

                case GZIPHeaderState.ReadingXLen2:
                    goto Label_01A3;

                case GZIPHeaderState.ReadingXLenData:
                    goto Label_01D5;

                case GZIPHeaderState.ReadingFileName:
                    goto Label_0217;

                case GZIPHeaderState.ReadingComment:
                    goto Label_0249;

                case GZIPHeaderState.ReadingCRC16Part1:
                    goto Label_027C;

                case GZIPHeaderState.ReadingCRC16Part2:
                    goto Label_02AB;

                case GZIPHeaderState.Done:
                    goto Label_02C6;

                default:
                    throw new InvalidDataException("Decoder is in some unknown state. This might be caused by corrupted data.");
            }
            bits = this.input.GetBits(8);
            if (bits < 0) {
                return false;
            }
            if (bits != 0x8b) {
                throw new InvalidDataException("The magic number in GZip header is not correct. Make sure you are passing in a GZip stream.");
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingCM;
        Label_00AF:
            bits = this.input.GetBits(8);
            if (bits < 0) {
                return false;
            }
            if (bits != 8) {
                throw new InvalidDataException("The compression mode specified in GZip header is unknown.");
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingFLG;
        Label_00DD:
            bits = this.input.GetBits(8);
            if (bits < 0) {
                return false;
            }
            this.gzip_header_flag = bits;
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingMMTime;
            this.loopCounter = 0;
        Label_0105:
            bits = 0;
            while (this.loopCounter < 4) {
                if (this.input.GetBits(8) < 0) {
                    return false;
                }
                this.loopCounter++;
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingXFL;
            this.loopCounter = 0;
        Label_0141:
            if (this.input.GetBits(8) < 0) {
                return false;
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingOS;
        Label_015B:
            if (this.input.GetBits(8) < 0) {
                return false;
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingXLen1;
        Label_0175:
            if ((this.gzip_header_flag & 4) == 0) {
                goto Label_0217;
            }
            bits = this.input.GetBits(8);
            if (bits < 0) {
                return false;
            }
            this.gzip_header_xlen = bits;
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingXLen2;
        Label_01A3:
            bits = this.input.GetBits(8);
            if (bits < 0) {
                return false;
            }
            this.gzip_header_xlen |= bits << 8;
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingXLenData;
            this.loopCounter = 0;
        Label_01D5:
            bits = 0;
            while (this.loopCounter < this.gzip_header_xlen) {
                if (this.input.GetBits(8) < 0) {
                    return false;
                }
                this.loopCounter++;
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingFileName;
            this.loopCounter = 0;
        Label_0217:
            if ((this.gzip_header_flag & 8) == 0) {
                this.gzipHeaderSubstate = GZIPHeaderState.ReadingComment;
            }
            else {
                do {
                    bits = this.input.GetBits(8);
                    if (bits < 0) {
                        return false;
                    }
                }
                while (bits != 0);
                this.gzipHeaderSubstate = GZIPHeaderState.ReadingComment;
            }
        Label_0249:
            if ((this.gzip_header_flag & 0x10) == 0) {
                this.gzipHeaderSubstate = GZIPHeaderState.ReadingCRC16Part1;
            }
            else {
                do {
                    bits = this.input.GetBits(8);
                    if (bits < 0) {
                        return false;
                    }
                }
                while (bits != 0);
                this.gzipHeaderSubstate = GZIPHeaderState.ReadingCRC16Part1;
            }
        Label_027C:
            if ((this.gzip_header_flag & 2) == 0) {
                this.gzipHeaderSubstate = GZIPHeaderState.Done;
                goto Label_02C6;
            }
            if (this.input.GetBits(8) < 0) {
                return false;
            }
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingCRC16Part2;
        Label_02AB:
            if (this.input.GetBits(8) < 0) {
                return false;
            }
            this.gzipHeaderSubstate = GZIPHeaderState.Done;
        Label_02C6:
            return true;
        }

        public void Reset() {
            this.gzipHeaderSubstate = GZIPHeaderState.ReadingID1;
            this.gzipFooterSubstate = GZIPHeaderState.ReadingCRC;
            this.gzipCrc32 = 0;
            this.gzipOutputStreamSize = 0;
        }

        public uint Crc32 {
            get {
                return this.gzipCrc32;
            }
        }

        public uint StreamSize {
            get {
                return this.gzipOutputStreamSize;
            }
        }
    }
}
#endif