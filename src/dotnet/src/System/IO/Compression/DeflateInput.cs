#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;

namespace System.IO.Compression {

    internal class DeflateInput {
        private byte[] buffer;
        private int count;
        private int startIndex;

        internal void ConsumeBytes(int n) {
            this.startIndex += n;
            this.count -= n;
        }

        internal byte[] Buffer {
            get {
                return this.buffer;
            }
            set {
                this.buffer = value;
            }
        }

        internal int Count {
            get {
                return this.count;
            }
            set {
                this.count = value;
            }
        }

        internal int StartIndex {
            get {
                return this.startIndex;
            }
            set {
                this.startIndex = value;
            }
        }
    }
}
#endif