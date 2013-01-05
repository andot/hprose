#if (PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11) && !MONO
using System;
using System.Windows.Forms;

namespace System.Threading {
	public delegate void SendOrPostCallback(object state);
    public class SynchronizationContext {
        private static SynchronizationContext currentContext = new WindowsFormsSynchronizationContext();

        public SynchronizationContext() {
        }

        public virtual void Post(SendOrPostCallback d, object state) {
#if (dotNET10 || dotNET11 || dotNETCF10)
            ThreadPool.QueueUserWorkItem(new WaitCallback(d), state);
#else
            ThreadPool.QueueUserWorkItem(d.Invoke, state);
#endif
        }

        public virtual void Send(SendOrPostCallback d, object state) {
            d(state);
        }

        public static void SetSynchronizationContext(SynchronizationContext syncContext) {
            currentContext = syncContext;
        }

        public static SynchronizationContext Current {
            get {
                return currentContext;
            }
        }
    }
}
#endif