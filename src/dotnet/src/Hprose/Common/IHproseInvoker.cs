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
 * IHproseInvoker.cs                                      *
 *                                                        *
 * hprose invoker interface for C#.                       *
 *                                                        *
 * LastModified: Nov 12, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;

namespace Hprose.Common {
    public interface IHproseInvoker {
#if !(dotNET10 || dotNET11 || dotNETCF10)
        T Invoke<T>(string functionName);
        T Invoke<T>(string functionName, object[] arguments);
        T Invoke<T>(string functionName, object[] arguments, bool byRef);
#endif
        object Invoke(string functionName);
        object Invoke(string functionName, object[] arguments);
        object Invoke(string functionName, object[] arguments, bool byRef);

        object Invoke(string functionName, Type returnType);
        object Invoke(string functionName, object[] arguments, Type returnType);
        object Invoke(string functionName, object[] arguments, Type returnType, bool byRef);

        object Invoke(string functionName, HproseResultMode resultMode);
        object Invoke(string functionName, object[] arguments, HproseResultMode resultMode);
        object Invoke(string functionName, object[] arguments, bool byRef, HproseResultMode resultMode);
#if !(dotNET10 || dotNET11 || dotNETCF10)
        void Invoke<T>(string functionName, HproseCallback<T> callback);
        void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback);
        void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback, bool byRef);
        void Invoke<T>(string functionName, HproseCallback1<T> callback);
        void Invoke<T>(string functionName, object[] arguments, HproseCallback1<T> callback);

        void Invoke<T>(string functionName, HproseCallback<T> callback, HproseErrorEvent errorEvent);
        void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorEvent);
        void Invoke<T>(string functionName, object[] arguments, HproseCallback<T> callback, HproseErrorEvent errorEvent, bool byRef);
        void Invoke<T>(string functionName, HproseCallback1<T> callback, HproseErrorEvent errorEvent);
        void Invoke<T>(string functionName, object[] arguments, HproseCallback1<T> callback, HproseErrorEvent errorEvent);
#endif
        void Invoke(string functionName, HproseCallback callback);
        void Invoke(string functionName, object[] arguments, HproseCallback callback);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, bool byRef);
        void Invoke(string functionName, HproseCallback1 callback);
        void Invoke(string functionName, object[] arguments, HproseCallback1 callback);

        void Invoke(string functionName, HproseCallback callback, HproseErrorEvent errorEvent);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, bool byRef);
        void Invoke(string functionName, HproseCallback1 callback, HproseErrorEvent errorEvent);
        void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent);

        void Invoke(string functionName, HproseCallback callback, Type returnType);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, Type returnType);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, Type returnType, bool byRef);
        void Invoke(string functionName, HproseCallback1 callback, Type returnType);
        void Invoke(string functionName, object[] arguments, HproseCallback1 callback, Type returnType);

        void Invoke(string functionName, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, Type returnType, bool byRef);
        void Invoke(string functionName, HproseCallback1 callback, HproseErrorEvent errorEvent, Type returnType);
        void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent, Type returnType);

        void Invoke(string functionName, HproseCallback callback, HproseResultMode resultMode);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseResultMode resultMode);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, bool byRef, HproseResultMode resultMode);
        void Invoke(string functionName, HproseCallback1 callback, HproseResultMode resultMode);
        void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseResultMode resultMode);

        void Invoke(string functionName, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
        void Invoke(string functionName, object[] arguments, HproseCallback callback, HproseErrorEvent errorEvent, bool byRef, HproseResultMode resultMode);
        void Invoke(string functionName, HproseCallback1 callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
        void Invoke(string functionName, object[] arguments, HproseCallback1 callback, HproseErrorEvent errorEvent, HproseResultMode resultMode);
    }
}