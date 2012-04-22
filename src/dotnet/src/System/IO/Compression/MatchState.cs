#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;

namespace System.IO.Compression {

    internal enum MatchState {
        HasMatch = 2,
        HasSymbol = 1,
        HasSymbolAndMatch = 3
    }
}
#endif