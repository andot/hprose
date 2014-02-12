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
 * InvokeHelper.cs                                        *
 *                                                        *
 * hprose Invoke Helper class for C#.                     *
 *                                                        *
 * LastModified: Nov 13, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !(dotNET10 || dotNET11 || dotNETCF10)
using System;
namespace Hprose.Common {
    interface IInvokeHelper {
        void Invoke(IHproseInvoker client, string functionName, object[] args, Delegate callback, bool byRef);
    }

    class InvokeHelper<T> : IInvokeHelper {
        public void Invoke(IHproseInvoker client, string functionName, object[] args, Delegate callback, bool byRef) {
            client.Invoke<T>(functionName, args, (HproseCallback<T>)callback, byRef);
        }
    }
    interface IInvokeHelper1 {
        void Invoke(IHproseInvoker client, string functionName, object[] args, Delegate callback);
    }

    class InvokeHelper1<T> : IInvokeHelper1 {
        public void Invoke(IHproseInvoker client, string functionName, object[] args, Delegate callback) {
            client.Invoke<T>(functionName, args, (HproseCallback1<T>)callback);
        }
    }
}
#endif
