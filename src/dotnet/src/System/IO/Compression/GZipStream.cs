#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.IO;

namespace System.IO.Compression {

    public class GZipStream : Stream, IDisposable {
        private DeflateStream deflateStream;

        public GZipStream(Stream stream, CompressionMode mode)
            : this(stream, mode, false) {
        }

        public GZipStream(Stream stream, CompressionMode mode, bool leaveOpen) {
            this.deflateStream = new DeflateStream(stream, mode, leaveOpen, true);
        }

        public override IAsyncResult BeginRead(byte[] array, int offset, int count, AsyncCallback asyncCallback, object asyncState) {
            if (this.deflateStream == null) {
                throw new InvalidOperationException("Can not access a closed Stream.");
            }
            return this.deflateStream.BeginRead(array, offset, count, asyncCallback, asyncState);
        }

        public override IAsyncResult BeginWrite(byte[] array, int offset, int count, AsyncCallback asyncCallback, object asyncState) {
            if (this.deflateStream == null) {
                throw new InvalidOperationException("Can not access a closed Stream.");
            }
            return this.deflateStream.BeginWrite(array, offset, count, asyncCallback, asyncState);
        }

        void IDisposable.Dispose() {
            if (this.deflateStream != null) {
                this.deflateStream.Close();
            }
            this.deflateStream = null;
        }

        public override int EndRead(IAsyncResult asyncResult) {
            if (this.deflateStream == null) {
                throw new InvalidOperationException("Can not access a closed Stream.");
            }
            return this.deflateStream.EndRead(asyncResult);
        }

        public override void EndWrite(IAsyncResult asyncResult) {
            if (this.deflateStream == null) {
                throw new InvalidOperationException("Can not access a closed Stream.");
            }
            this.deflateStream.EndWrite(asyncResult);
        }

        public override void Flush() {
            if (this.deflateStream == null) {
                throw new ObjectDisposedException(null, "Can not access a closed Stream.");
            }
            this.deflateStream.Flush();
        }

        public override int Read(byte[] array, int offset, int count) {
            if (this.deflateStream == null) {
                throw new ObjectDisposedException(null, "Can not access a closed Stream.");
            }
            return this.deflateStream.Read(array, offset, count);
        }

        public override long Seek(long offset, SeekOrigin origin) {
            throw new NotSupportedException("This operation is not supported.");
        }

        public override void SetLength(long value) {
            throw new NotSupportedException("This operation is not supported.");
        }

        public override void Write(byte[] array, int offset, int count) {
            if (this.deflateStream == null) {
                throw new ObjectDisposedException(null, "Can not access a closed Stream.");
            }
            this.deflateStream.Write(array, offset, count);
        }

        public Stream BaseStream {
            get {
                if (this.deflateStream != null) {
                    return this.deflateStream.BaseStream;
                }
                return null;
            }
        }

        public override bool CanRead {
            get {
                if (this.deflateStream == null) {
                    return false;
                }
                return this.deflateStream.CanRead;
            }
        }

        public override bool CanSeek {
            get {
                if (this.deflateStream == null) {
                    return false;
                }
                return this.deflateStream.CanSeek;
            }
        }

        public override bool CanWrite {
            get {
                if (this.deflateStream == null) {
                    return false;
                }
                return this.deflateStream.CanWrite;
            }
        }

        public override long Length {
            get {
                throw new NotSupportedException("This operation is not supported.");
            }
        }

        public override long Position {
            get {
                throw new NotSupportedException("This operation is not supported.");
            }
            set {
                throw new NotSupportedException("This operation is not supported.");
            }
        }
    }
}
#endif