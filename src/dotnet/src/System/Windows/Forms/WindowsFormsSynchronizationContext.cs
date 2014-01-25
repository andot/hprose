#if (PocketPC || Smartphone || WindowsCE || dotNET10 || dotNET11) && !MONO
using System;
using System.Threading;

namespace System.Windows.Forms {
    public class WindowsFormsSynchronizationContext : SynchronizationContext {
        private readonly Control contextControl;

        public WindowsFormsSynchronizationContext() {
            contextControl = new Control();
#if !dotNETCF10
            IntPtr handle = contextControl.Handle;
#endif
        }

        public override void Post(SendOrPostCallback d, object state) {
#if !dotNETCF10
            contextControl.BeginInvoke(d, new object[] { state });
#else
            contextControl.Invoke(new EventHandler(new EventHandleCreate(d, state).EventHandler));
#endif
        }

        public override void Send(SendOrPostCallback d, object state) {
#if !dotNETCF10
            contextControl.Invoke(d, new object[] { state });
#else
            contextControl.Invoke(new EventHandler(new EventHandleCreate(d, state).EventHandler));
#endif
        }
#if dotNETCF10
        class EventHandleCreate {
            private SendOrPostCallback callback;
            private object obj;
            public EventHandleCreate(SendOrPostCallback d, object state) {
                callback = d;
                obj = state;
            }
            public void EventHandler(object sender, EventArgs e) {
                callback(obj);
            }
        }
#endif
    }
}
#endif