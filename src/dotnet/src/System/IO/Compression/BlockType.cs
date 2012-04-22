#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;

namespace System.IO.Compression {
    internal enum BlockType {
        Uncompressed,
        Static,
        Dynamic
    }
}
#endif