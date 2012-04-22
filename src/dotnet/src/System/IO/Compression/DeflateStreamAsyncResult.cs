#if (dotNET10 || dotNET11 || PocketPC || Smartphone || WindowsCE) && !dotNETCF35 && !MONO
using System;
using System.Threading;

namespace System.IO.Compression {

    internal class DeflateStreamAsyncResult : IAsyncResult {
        public byte[] buffer;
        public int count;
        public bool isWrite;
        private AsyncCallback m_AsyncCallback;
        private object m_AsyncState;
        private int m_Completed;
        internal bool m_CompletedSynchronously;
        private object m_Event;
        private int m_InvokedCallback;
        private object m_Result;
        public int offset;

        public DeflateStreamAsyncResult(object asyncObject, object asyncState, AsyncCallback asyncCallback, byte[] buffer, int offset, int count) {
            this.buffer = buffer;
            this.offset = offset;
            this.count = count;
            this.m_CompletedSynchronously = true;
            this.m_AsyncState = asyncState;
            this.m_AsyncCallback = asyncCallback;
        }

        internal void Close() {
            if (this.m_Event != null) {
                ((ManualResetEvent)this.m_Event).Close();
            }
        }

        private void Complete(object result) {
            this.m_Result = result;
            Interlocked.Increment(ref this.m_Completed);
            if (this.m_Event != null) {
                ((ManualResetEvent)this.m_Event).Set();
            }
            if ((Interlocked.Increment(ref this.m_InvokedCallback) == 1) && (this.m_AsyncCallback != null)) {
                this.m_AsyncCallback(this);
            }
        }

        private void Complete(bool completedSynchronously, object result) {
            this.m_CompletedSynchronously = completedSynchronously;
            this.Complete(result);
        }

        internal void InvokeCallback(object result) {
            this.Complete(result);
        }

        internal void InvokeCallback(bool completedSynchronously, object result) {
            this.Complete(completedSynchronously, result);
        }

        public object AsyncState {
            get {
                return this.m_AsyncState;
            }
        }

        public WaitHandle AsyncWaitHandle {
            get {
                int completed = this.m_Completed;
                if (this.m_Event == null) {
#if SILVERLIGHT
                    Interlocked.CompareExchange<object>(ref this.m_Event, new ManualResetEvent(completed != 0), null);
#else
                    Interlocked.CompareExchange(ref this.m_Event, new ManualResetEvent(completed != 0), null);
#endif
                }
                ManualResetEvent event2 = (ManualResetEvent)this.m_Event;
                if ((completed == 0) && (this.m_Completed != 0)) {
                    event2.Set();
                }
                return event2;
            }
        }

        public bool CompletedSynchronously {
            get {
                return this.m_CompletedSynchronously;
            }
        }

        public bool IsCompleted {
            get {
                return (this.m_Completed != 0);
            }
        }

        internal object Result {
            get {
                return this.m_Result;
            }
        }
    }
}
#endif