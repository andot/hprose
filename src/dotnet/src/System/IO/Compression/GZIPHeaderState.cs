#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;

namespace System.IO.Compression {

    internal enum GZIPHeaderState {
        ReadingID1,
        ReadingID2,
        ReadingCM,
        ReadingFLG,
        ReadingMMTime,
        ReadingXFL,
        ReadingOS,
        ReadingXLen1,
        ReadingXLen2,
        ReadingXLenData,
        ReadingFileName,
        ReadingComment,
        ReadingCRC16Part1,
        ReadingCRC16Part2,
        Done,
        ReadingCRC,
        ReadingFileSize
    }
}
#endif