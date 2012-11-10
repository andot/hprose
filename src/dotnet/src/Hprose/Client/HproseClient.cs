/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseClient.cs                                        *
 *                                                        *
 * hprose client class for C#.                            *
 *                                                        *
 * LastModified: Nov 6, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
using System;
using System.IO;
using System.Threading;
using Hprose.IO;
using Hprose.Common;
#if !(PocketPC || Smartphone || WindowsCE || WINDOWS_PHONE || Core)
using Hprose.Reflection;
#endif

namespace Hprose.Client {

    public abstract class HproseClient : IHproseInvoker {
        private static readonly object[] nullArgs = new object[0];
        public event HproseErrorEvent OnError = null;
        private static SynchronizationContext syncContext = null;
        public static SynchronizationContext SynchronizationContext {
            get {
                if (syncContext == null) {
                    syncContext = SynchronizationContext.Current;
                    if (syncContext == null) {
                        syncContext = new SynchronizationContext();
                    }
                }
                return syncContext;
            }
            set {
                syncContext = value;
            }
        }

        private abstract class AsyncInvokeContextBase {
            protected HproseClient client;
            protected string functionName;
            protected object[] arguments;
            protected HproseErrorEvent errorCallback;
            protected Type returnType;
            protected bool byRef;
            protected HproseResultMode resultMode;
            protected object result;
            private readonly SynchronizationContext syncContext = HproseClient.SynchronizationContext;
            internal AsyncInvokeContextBase(HproseClient client, string functionName, object[] arguments, HproseErrorEvent errorCallback, Type returnType, bool byRef, HproseResultMode resultMode) {
                this.client = client;
                this.functionName = functionName;
                this.arguments = arguments;
                this.errorCallback = errorCallback;
                this.returnType = returnType;
                this.byRef = byRef;
                this.resultMode = resultMode;
            }

            internal void GetOutputStream(IAsyncResult asyncResult) {
                Stream ostream = null;
                bool success = false;
                try {
                    ostream = client.EndGetOutputStream(asyncResult);
                    client.DoOutput(functionName, arguments, byRef, ostream);
                    success = true;
                }
                catch (Exception e) {
                    result = e;
                    syncContext.Post(new SendOrPostCallback(DoCallback), null);
                    return;
                }
                finally {
                    if (ostream != null) {
                        client.SendData(ostream, asyncResult.AsyncState, success);
                    }
                }
                client.BeginGetInputStream(new AsyncCallback(GetInputStream), asyncResult.AsyncState);
            }

            internal void GetInputStream(IAsyncResult asyncResult) {
                bool success = false;
                result = null;
                Stream istream = null;
                try {
                    istream = client.EndGetInputStream(asyncResult);
                    result = client.DoInput(arguments, returnType, resultMode, istream);
                    success = true;
                }
                catch (Exception e) {
                    result = e;
                }
                finally {
                    if (istream != null) {
                        client.EndInvoke(istream, asyncResult.AsyncState, success);
                    }
                } 
                syncContext.Post(new SendOrPostCallback(DoCallback), null);
            }
            protected abstract void DoCallback(object state);
        }

        private class AsyncInvokeContext : AsyncInvokeContextBase {
            private HproseCallback callback;
            internal AsyncInvokeContext(HproseClient client, string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorCallback, Type returnType, bool byRef, HproseResultMode resultMode):
            base(client, functionName, arguments, errorCallback, returnType, byRef, resultMode) {
                this.callback = callback;
            }

            protected override void DoCallback(object state) {
                if (result is Exception) {
                    if (errorCallback != null) {
                        errorCallback(functionName, (Exception)result);
                    }
                }
                else {
                    callback(result, arguments);
                }
            }
        }
        private class AsyncInvokeContext1 : AsyncInvokeContextBase {
            private HproseCallback1 callback;
            internal AsyncInvokeContext1(HproseClient client, string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorCallback, Type returnType, HproseResultMode resultMode) :
                base(client, functionName, arguments, errorCallback, returnType, false, resultMode) {
                this.callback = callback;
            }

            protected override void DoCallback(object state) {
                if (result is Exception) {
                    if (errorCallback != null) {
                        errorCallback(functionName, (Exception)result);
                    }
                }
                else {
                    callback(result);
                }
            }
        }
#if !(dotNET10 || dotNET11 || dotNETCF10)
        private class AsyncInvokeContext<T> : AsyncInvokeContextBase {
            private HproseCallback<T> callback;
            internal AsyncInvokeContext(HproseClient client, string functionName, object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorCallback, bool byRef) :
                base(client, functionName, arguments, errorCallback, typeof(T), byRef, HproseResultMode.Normal) {
                this.callback = callback;
            }

            protected override void DoCallback(object state) {
                if (result is Exception) {
                    if (errorCallback != null) {
                        errorCallback(functionName, (Exception)result);
                    }
                }
                else {
                    callback((T)result, arguments);
                }
            }
        }
        private class AsyncInvokeContext1<T> : AsyncInvokeContextBase {
            private HproseCallback1<T> callback;
            internal AsyncInvokeContext1(HproseClient client, string functionName, object[] arguments, HproseCallback1<T> callback, HproseErrorEvent errorCallback) :
                base(client, functionName, arguments, errorCallback, typeof(T), false, HproseResultMode.Normal) {
                this.callback = callback;
            }

            protected override void DoCallback(object state) {
                if (result is Exception) {
                    if (errorCallback != null) {
                        errorCallback(functionName, (Exception)result);
                    }
                }
                else {
                    callback((T)result);
                }
            }
        }
#endif
        private HproseMode mode;

        protected HproseClient() {
            mode = HproseMode.FieldMode;
        }

        protected HproseClient(string uri) {
            UseService(uri);
            mode = HproseMode.FieldMode;
        }

        protected HproseClient(HproseMode mode) {
            this.mode = mode;
        }

        protected HproseClient(string uri, HproseMode mode) {
            UseService(uri);
            this.mode = mode;
        }

        public abstract void UseService(string uri);

#if !(PocketPC || Smartphone || WindowsCE || WINDOWS_PHONE || Core)
        public object UseService(Type type) {
            return UseService(type, null);
        }

        public object UseService(string uri, Type type) {
            UseService(uri);
            return UseService(type, null);
        }

        public object UseService(Type[] types) {
            return UseService(types, null);
        }

        public object UseService(string uri, Type[] types) {
            UseService(uri);
            return UseService(types, null);
        }
        public object UseService(Type type, string ns) {
            HproseInvocationHandler handler = new HproseInvocationHandler(this, ns);
            if (type.IsInterface) {
                return Proxy.NewInstance(AppDomain.CurrentDomain, new Type[] { type }, handler);
            }
            else {
                return Proxy.NewInstance(AppDomain.CurrentDomain, type.GetInterfaces(), handler);
            }
        }

        public object UseService(string uri, Type type, string ns) {
            UseService(uri);
            return UseService(type, ns);
        }

        public object UseService(Type[] types, string ns) {
            HproseInvocationHandler handler = new HproseInvocationHandler(this, ns);
            return Proxy.NewInstance(AppDomain.CurrentDomain, types, handler);
        }

        public object UseService(string uri, Type[] types, string ns) {
            UseService(uri);
            return UseService(types, ns);
        }
#if !(dotNET10 || dotNET11 || dotNETCF10)
        public T UseService<T>() {
            return UseService<T>(null);
        }
        public T UseService<T>(string ns) {
            Type type = typeof(T);
            HproseInvocationHandler handler = new HproseInvocationHandler(this, ns);
            if (type.IsInterface) {
                return (T)Proxy.NewInstance(AppDomain.CurrentDomain, new Type[] { type }, handler);
            }
            else {
                return (T)Proxy.NewInstance(AppDomain.CurrentDomain, type.GetInterfaces(), handler);
            }
        }
        public T UseService<T>(string uri, string ns) {
            UseService(uri);
            return UseService<T>(ns);
        }
#endif
#endif
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
#if !(dotNET10 || dotNET11 || dotNETCF10)
        public T Invoke<T>(string functionName) {
            return (T)Invoke(functionName, nullArgs, typeof(T), false, HproseResultMode.Normal);
        }

        public T Invoke<T>(string functionName, object[] arguments) {
            return (T)Invoke(functionName, arguments, typeof(T), false, HproseResultMode.Normal);
        }

        public T Invoke<T>(string functionName, object[] arguments, bool byRef) {
            return (T)Invoke(functionName, arguments, typeof(T), byRef, HproseResultMode.Normal);
        }
#endif
        public object Invoke(string functionName) {
            return Invoke(functionName, nullArgs, (Type)null, false, HproseResultMode.Normal);
        }

        public object Invoke(string functionName, object[] arguments) {
            return Invoke(functionName, arguments, (Type)null, false, HproseResultMode.Normal);
        }

        public object Invoke(string functionName, object[] arguments, bool byRef) {
            return Invoke(functionName, arguments, (Type)null, byRef, HproseResultMode.Normal);
        }

        public object Invoke(string functionName, Type returnType) {
            return Invoke(functionName, nullArgs, returnType, false, HproseResultMode.Normal);
        }

        public object Invoke(string functionName, object[] arguments, Type returnType) {
            return Invoke(functionName, arguments, returnType, false, HproseResultMode.Normal);
        }

        public object Invoke(string functionName, object[] arguments, Type returnType, bool byRef) {
            return Invoke(functionName, arguments, returnType, byRef, HproseResultMode.Normal);
        }

        public object Invoke(string functionName, HproseResultMode resultMode) {
            return Invoke(functionName, nullArgs, (Type)null, false, resultMode);
        }

        public object Invoke(string functionName, object[] arguments, HproseResultMode resultMode) {
            return Invoke(functionName, arguments, (Type)null, false, resultMode);
        }

        public object Invoke(string functionName, object[] arguments, bool byRef, HproseResultMode resultMode) {
            return Invoke(functionName, arguments, (Type)null, byRef, resultMode);
        }

        private object Invoke(string functionName, object[] arguments, Type returnType, bool byRef, HproseResultMode resultMode) {
            object context = GetInvokeContext();
            Stream ostream = GetOutputStream(context);
            bool success = false;
            try {
                DoOutput(functionName, arguments, byRef, ostream);
                success = true;
            }
            finally {
                SendData(ostream, context, success);
            }
            object result = null;
            Stream istream = GetInputStream(context);
            success = false;
            try {
                result = DoInput(arguments, returnType, resultMode, istream);
                success = true;
            }
            finally {
                EndInvoke(istream, context, success);
            }
            if (result is HproseException) {
                throw (HproseException)result;
            }
            return result;
        }

#endif
        private object DoInput(object[] arguments, Type returnType, HproseResultMode resultMode, Stream istream) {
            int tag;
            object result = null;
            HproseReader hproseReader = new HproseReader(istream, mode);
            MemoryStream memstream = null;
            if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
                memstream = new MemoryStream();
            }
            while ((tag = hproseReader.CheckTags(
                    (char)HproseTags.TagResult + "" +
                    (char)HproseTags.TagArgument + "" +
                    (char)HproseTags.TagError + "" +
                    (char)HproseTags.TagEnd)) != HproseTags.TagEnd) {
                switch (tag) {
                    case HproseTags.TagResult:
                        if (resultMode == HproseResultMode.Normal) {
                            hproseReader.Reset();
                            result = hproseReader.Unserialize(returnType);
                        }
                        else if (resultMode == HproseResultMode.Serialized) {
                            result = hproseReader.ReadRaw();
                        }
                        else {
                            memstream.WriteByte(HproseTags.TagResult);
                            hproseReader.ReadRaw(memstream);
                        }
                        break;
                    case HproseTags.TagArgument:
                        if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
                            memstream.WriteByte(HproseTags.TagArgument);
                            hproseReader.ReadRaw(memstream);
                        }
                        else {
                            hproseReader.Reset();
                            Object[] args = (Object[])hproseReader.ReadList(HproseHelper.typeofObjectArray);
                            Array.Copy(args, 0, arguments, 0, arguments.Length);
                        }
                        break;
                    case HproseTags.TagError:
                        if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
                            memstream.WriteByte(HproseTags.TagError);
                            hproseReader.ReadRaw(memstream);
                        }
                        else {
                            hproseReader.Reset();
                            result = new HproseException((string)hproseReader.ReadString());
                        }
                        break;
                }
            }
            if (resultMode == HproseResultMode.RawWithEndTag || resultMode == HproseResultMode.Raw) {
                if (resultMode == HproseResultMode.RawWithEndTag) {
                    memstream.WriteByte(HproseTags.TagEnd);
                }
                memstream.Position = 0;
                result = memstream;
            }
            return result;
        }

        private void DoOutput(string functionName, object[] arguments, bool byRef, Stream ostream) {
            HproseWriter hproseWriter = new HproseWriter(ostream, mode);
            ostream.WriteByte(HproseTags.TagCall);
            hproseWriter.WriteString(functionName, false);
            if ((arguments != null) && (arguments.Length > 0 || byRef)) {
                hproseWriter.Reset();
                hproseWriter.WriteArray(arguments, false);
                if (byRef) {
                    hproseWriter.WriteBoolean(true);
                }
            }
            ostream.WriteByte(HproseTags.TagEnd);
        }

#if !(dotNET10 || dotNET11 || dotNETCF10)
        public void Invoke<T>(string functionName, HproseCallback<T> callback) {
            Invoke(functionName, nullArgs, callback, null, false);
        }

        public void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback) {
            Invoke(functionName, arguments, callback, null, false);
        }

        public void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback, bool byRef) {
            Invoke(functionName, arguments, callback, null, byRef);
        }

        public void Invoke<T>(string functionName, HproseCallback1<T> callback) {
            Invoke(functionName, nullArgs, callback, null);
        }

        public void Invoke<T>(string functionName, object[] arguments, HproseCallback1<T> callback) {
            Invoke(functionName, arguments, callback, null);
        }

        public void Invoke<T>(string functionName, HproseCallback<T> callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, nullArgs, callback, errorEvent, false);
        }

        public void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, arguments, callback, errorEvent, false);
        }

        public void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorEvent, bool byRef) {
            if (errorEvent == null) {
                errorEvent = OnError;
            }
            AsyncInvokeContext<T> context = new AsyncInvokeContext<T>(this, functionName, arguments, callback, errorEvent, byRef);
            try {
                BeginGetOutputStream(new AsyncCallback(context.GetOutputStream), GetInvokeContext());
            }
            catch (Exception e) {
                if (errorEvent != null) {
                    errorEvent(functionName, e);
                }
            }
        }

        public void Invoke<T>(string functionName, HproseCallback1<T> callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, nullArgs, callback, errorEvent);
        }

        public void Invoke<T>(string functionName, object[] arguments, HproseCallback1<T> callback, HproseErrorEvent errorEvent) {
            if (errorEvent == null) {
                errorEvent = OnError;
            }
            AsyncInvokeContext1<T> context = new AsyncInvokeContext1<T>(this, functionName, arguments, callback, errorEvent);
            try {
                BeginGetOutputStream(new AsyncCallback(context.GetOutputStream), GetInvokeContext());
            }
            catch (Exception e) {
                if (errorEvent != null) {
                    errorEvent(functionName, e);
                }
            }
        }

#endif
        public void Invoke(string functionName, HproseCallback callback) {
            Invoke(functionName, nullArgs, callback, null, null, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback) {
            Invoke(functionName, arguments, callback, null, null, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, bool byRef) {
            Invoke(functionName, arguments, callback, null, null, byRef, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback1 callback) {
            Invoke(functionName, nullArgs, callback, null, null, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback1 callback) {
            Invoke(functionName, arguments, callback, null, null, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, nullArgs, callback, errorEvent, null, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, arguments, callback, errorEvent, null, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, bool byRef) {
            Invoke(functionName, arguments, callback, errorEvent, null, byRef, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback1 callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, nullArgs, callback, errorEvent, null, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent) {
            Invoke(functionName, arguments, callback, errorEvent, null, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback callback, Type returnType) {
            Invoke(functionName, nullArgs, callback, null, returnType, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, Type returnType) {
            Invoke(functionName, arguments, callback, null, returnType, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, Type returnType, bool byRef) {
            Invoke(functionName, arguments, callback, null, returnType, byRef, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback1 callback, Type returnType) {
            Invoke(functionName, nullArgs, callback, null, returnType, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback1 callback, Type returnType) {
            Invoke(functionName, arguments, callback, null, returnType, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType) {
            Invoke(functionName, nullArgs, callback, errorEvent, returnType, false, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType) {
            Invoke(functionName, arguments, callback, errorEvent, returnType, false, HproseResultMode.Normal);
        }
        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType, bool byRef) {
            Invoke(functionName, arguments, callback, errorEvent, returnType, byRef, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback1 callback, HproseErrorEvent errorEvent, Type returnType) {
            Invoke(functionName, nullArgs, callback, errorEvent, returnType, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent, Type returnType) {
            Invoke(functionName, arguments, callback, errorEvent, returnType, HproseResultMode.Normal);
        }

        public void Invoke(string functionName, HproseCallback callback, HproseResultMode resultMode) {
            Invoke(functionName, nullArgs, callback, null, null, false, resultMode);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseResultMode resultMode) {
            Invoke(functionName, arguments, callback, null, null, false, resultMode);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, bool byRef, HproseResultMode resultMode) {
            Invoke(functionName, arguments, callback, null, null, byRef, resultMode);
        }

        public void Invoke(string functionName, HproseCallback1 callback, HproseResultMode resultMode) {
            Invoke(functionName, nullArgs, callback, null, null, resultMode);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseResultMode resultMode) {
            Invoke(functionName, arguments, callback, null, null, resultMode);
        }

        public void Invoke(string functionName, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode) {
            Invoke(functionName, nullArgs, callback, errorEvent, null, false, resultMode);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode) {
            Invoke(functionName, arguments, callback, errorEvent, null, false, resultMode);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, bool byRef, HproseResultMode resultMode) {
            Invoke(functionName, arguments, callback, errorEvent, null, byRef, resultMode);
        }

        public void Invoke(string functionName, HproseCallback1 callback, HproseErrorEvent errorEvent, HproseResultMode resultMode) {
            Invoke(functionName, nullArgs, callback, errorEvent, null, resultMode);
        }

        public void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent, HproseResultMode resultMode) {
            Invoke(functionName, arguments, callback, errorEvent, null, resultMode);
        }

        private void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType, bool byRef, HproseResultMode resultMode) {
            if (errorEvent == null) {
                errorEvent = OnError;
            }
            AsyncInvokeContext context = new AsyncInvokeContext(this, functionName, arguments, callback, errorEvent, returnType, byRef, resultMode);
            try {
                BeginGetOutputStream(new AsyncCallback(context.GetOutputStream), GetInvokeContext());
            }
            catch (Exception e) {
                if (errorEvent != null) {
                    errorEvent(functionName, e);
                }
            }
        }

        private void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent, Type returnType, HproseResultMode resultMode) {
            if (errorEvent == null) {
                errorEvent = OnError;
            }
            AsyncInvokeContext1 context = new AsyncInvokeContext1(this, functionName, arguments, callback, errorEvent, returnType, resultMode);
            try {
                BeginGetOutputStream(new AsyncCallback(context.GetOutputStream), GetInvokeContext());
            }
            catch (Exception e) {
                if (errorEvent != null) {
                    errorEvent(functionName, e);
                }
            }
        }

        protected abstract object GetInvokeContext();

        protected abstract void SendData(Stream ostream, object context, bool success);

        protected abstract void EndInvoke(Stream istream, object context, bool success);
#if !(SILVERLIGHT || WINDOWS_PHONE || Core)
        protected abstract Stream GetOutputStream(object context);

        protected abstract Stream GetInputStream(object context);
#endif
        protected abstract IAsyncResult BeginGetOutputStream(AsyncCallback callback, object context);

        protected abstract Stream EndGetOutputStream(IAsyncResult asyncResult);

        protected abstract IAsyncResult BeginGetInputStream(AsyncCallback callback, object context);

        protected abstract Stream EndGetInputStream(IAsyncResult asyncResult);
    }
}