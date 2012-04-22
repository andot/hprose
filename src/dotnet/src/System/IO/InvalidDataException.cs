#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;

namespace System.IO {

    public sealed class InvalidDataException : SystemException {
        public InvalidDataException()
            : base("Found invalid data while decoding.") {
        }

        public InvalidDataException(string message)
            : base(message) {
        }

        public InvalidDataException(string message, Exception innerException)
            : base(message, innerException) {
        }
    }
}
#endif