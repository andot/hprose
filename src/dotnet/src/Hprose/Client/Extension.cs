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
 * Extension.cs                                           *
 *                                                        *
 * hprose client extension class for C#.                  *
 *                                                        *
 * LastModified: Nov 12, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#if !(dotNET10 || dotNET11 || dotNETCF10)
#if (dotNET2 || dotNETCF20 || SL2)
#define NET_2_0
#endif
using System;
using System.IO;
using System.Threading;
using Hprose.IO;
using Hprose.Common;
using System.Reflection;

namespace Hprose.Client {
    public static class Extension {
        private static readonly object[] nullArgs = new object[0];
        public static Action GetAction(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate() {
                client.Invoke(methodName);
            };
        }
        public static Action<T1> GetAction<T1>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1) {
                client.Invoke(methodName, new object[] { a1 });
            };
        }
        public static Action<T1, T2> GetAction<T1, T2>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2) {
                client.Invoke(methodName, new object[] { a1, a2 });
            };
        }
        public static Action<T1, T2, T3> GetAction<T1, T2, T3>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3) {
                client.Invoke(methodName, new object[] { a1, a2, a3 });
            };
        }
        public static Action<T1, T2, T3, T4> GetAction<T1, T2, T3, T4>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4 });
            };
        }
        public static Action<T1, T2, T3, T4, T5> GetAction<T1, T2, T3, T4, T5>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6> GetAction<T1, T2, T3, T4, T5, T6>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7> GetAction<T1, T2, T3, T4, T5, T6, T7>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8> GetAction<T1, T2, T3, T4, T5, T6, T7, T8>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14, T15 a15) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 });
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16> GetAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14, T15 a15, T16 a16) {
                client.Invoke(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16 });
            };
        }
        public static Func<TResult> GetFunc<TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate() {
                return client.Invoke<TResult>(methodName);
            };
        }
        public static Func<T1, TResult> GetFunc<T1, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1) {
                return client.Invoke<TResult>(methodName, new object[] { a1 });
            };
        }
        public static Func<T1, T2, TResult> GetFunc<T1, T2, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2 });
            };
        }
        public static Func<T1, T2, T3, TResult> GetFunc<T1, T2, T3, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3 });
            };
        }
        public static Func<T1, T2, T3, T4, TResult> GetFunc<T1, T2, T3, T4, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, TResult> GetFunc<T1, T2, T3, T4, T5, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, TResult> GetFunc<T1, T2, T3, T4, T5, T6, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14, T15 a15) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 });
            };
        }
        public static Func<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, TResult> GetFunc<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, TResult>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14, T15 a15, T16 a16) {
                return client.Invoke<TResult>(methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16 });
            };
        }
        private static void AsyncInvoke<TCallback>(HproseClient client, string methodName, object[] args, TCallback callback) {
            if (callback is HproseCallback) {
                client.Invoke(methodName, args, callback as HproseCallback);
            }
            else if (callback is HproseCallback1) {
                client.Invoke(methodName, args, callback as HproseCallback1);
            }
            else {
#if Core
                TypeInfo type = callback.GetType().GetTypeInfo();
                if (type.IsGenericType) {
                    if (type.GetGenericTypeDefinition() == typeof(HproseCallback<>)) {
                        IInvokeHelper helper = Activator.CreateInstance(typeof(InvokeHelper<>).MakeGenericType(type.GenericTypeArguments)) as IInvokeHelper;
                        helper.Invoke(client, methodName, args, callback as Delegate, false);
                        return;
                    }
                    else if (type.GetGenericTypeDefinition() == typeof(HproseCallback1<>)) {
                        IInvokeHelper1 helper = Activator.CreateInstance(typeof(InvokeHelper1<>).MakeGenericType(type.GenericTypeArguments)) as IInvokeHelper1;
                        helper.Invoke(client, methodName, args, callback as Delegate);
                        return;
                    }
                }
#else
                Type type = callback.GetType();
                if (type.IsGenericType) {
                    if (type.GetGenericTypeDefinition() == typeof(HproseCallback<>)) {
                        IInvokeHelper helper = Activator.CreateInstance(typeof(InvokeHelper<>).MakeGenericType(type.GetGenericArguments())) as IInvokeHelper;
                        helper.Invoke(client, methodName, args, callback as Delegate, false);
                        return;
                    }
                    else if (type.GetGenericTypeDefinition() == typeof(HproseCallback1<>)) {
                        IInvokeHelper1 helper = Activator.CreateInstance(typeof(InvokeHelper1<>).MakeGenericType(type.GetGenericArguments())) as IInvokeHelper1;
                        helper.Invoke(client, methodName, args, callback as Delegate);
                        return;
                    }
                }
#endif
                throw new Exception("TCallback must be a Callback Delegate: HproseCallback, HproseCallback1, HproseCallback<T>, HproseCallback1<T>.");
            }
        }
        public static Action<TCallback> GetAsyncAction<TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(TCallback callback) {
                AsyncInvoke(client, methodName, nullArgs, callback);
            };
        }
        public static Action<T1, TCallback> GetAsyncAction<T1, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1 }, callback);
            };
        }
        public static Action<T1, T2, TCallback> GetAsyncAction<T1, T2, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2 }, callback);
            };
        }
        public static Action<T1, T2, T3, TCallback> GetAsyncAction<T1, T2, T3, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, TCallback> GetAsyncAction<T1, T2, T3, T4, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14 }, callback);
            };
        }
        public static Action<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, TCallback> GetAsyncAction<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, TCallback>(
#if !NET_2_0
        this
#endif
        HproseClient client, string methodName) {
            return delegate(T1 a1, T2 a2, T3 a3, T4 a4, T5 a5, T6 a6, T7 a7, T8 a8, T9 a9, T10 a10, T11 a11, T12 a12, T13 a13, T14 a14, T15 a15, TCallback callback) {
                AsyncInvoke(client, methodName, new object[] { a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 }, callback);
            };
        }
    }
}
#endif