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
 * HproseInvocationHandler.cs                             *
 *                                                        *
 * hprose InvocationHandler class for C#.                 *
 *                                                        *
 * LastModified: Feb 18, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !(PocketPC || Smartphone || WindowsCE || WINDOWS_PHONE || Core)
using System;
using System.Numerics;
using System.Reflection;
using System.Threading;
using Hprose.IO;
using Hprose.Reflection;
using Hprose.Common;

namespace Hprose.Client {
    class HproseInvocationHandler : IInvocationHandler {
        private String ns;
        private HproseClient client;

        public HproseInvocationHandler(HproseClient client, String ns) {
            this.client = client;
            this.ns = ns;
        }

        private static Type[] GetTypes(ParameterInfo[] parameters) {
            int n = parameters.Length;
            Type[] types = new Type[n];
            for (int i = 0; i < n; i++) {
                types[i] = parameters[i].ParameterType;
            }
            return types;
        }

        public object Invoke(object proxy, MethodInfo method, object[] args) {
            ParameterInfo[] parameters = method.GetParameters();
            Type[] paramTypes = GetTypes(parameters);
            Type returnType = method.ReturnType;
            if (returnType == typeof(void)) {
                returnType = null;
            }
            int n = paramTypes.Length;
            string functionName = method.Name;
            if (ns != null) {
                functionName = ns + '_' + functionName;
            }
            bool byRef = false;
            foreach (Type param in paramTypes) {
                if (param.IsByRef) {
                    byRef = true;
                    break;
                }
            }
            if ((n > 0) && (paramTypes[n - 1] == typeof(HproseCallback))) {
                HproseCallback callback = (HproseCallback)args[n - 1];
                object[] tmpargs = new object[n - 1];
                Array.Copy(args, 0, tmpargs, 0, n - 1);
                client.Invoke(functionName, tmpargs, callback, byRef);
                return null;
            }
            if ((n > 0) && (paramTypes[n - 1] == typeof(HproseCallback1))) {
                HproseCallback1 callback = (HproseCallback1)args[n - 1];
                object[] tmpargs = new object[n - 1];
                Array.Copy(args, 0, tmpargs, 0, n - 1);
                client.Invoke(functionName, tmpargs, callback);
                return null;
            }
            if ((n > 1) && (paramTypes[n - 2] == typeof(HproseCallback)) &&
                           (paramTypes[n - 1] == typeof(Type))) {
                HproseCallback callback = (HproseCallback)args[n - 2];
                returnType = (Type)args[n - 1];
                object[] tmpargs = new object[n - 2];
                Array.Copy(args, 0, tmpargs, 0, n - 2);
                client.Invoke(functionName, tmpargs, callback, returnType, byRef);
                return null;
            }
            if ((n > 1) && (paramTypes[n - 2] == typeof(HproseCallback1)) &&
                           (paramTypes[n - 1] == typeof(Type))) {
                HproseCallback1 callback = (HproseCallback1)args[n - 2];
                returnType = (Type)args[n - 1];
                object[] tmpargs = new object[n - 2];
                Array.Copy(args, 0, tmpargs, 0, n - 2);
                client.Invoke(functionName, tmpargs, callback, returnType);
                return null;
            }
#if !(dotNET10 || dotNET11 || dotNETCF10)
            if ((n > 0) && (paramTypes[n - 1].IsGenericType &&
                           (paramTypes[n - 1].GetGenericTypeDefinition() == typeof(HproseCallback<>)))) {
                IInvokeHelper helper = Activator.CreateInstance(typeof(InvokeHelper<>).MakeGenericType(paramTypes[n - 1].GetGenericArguments())) as IInvokeHelper;
                Delegate callback = (Delegate)args[n - 1];
                object[] tmpargs = new object[n - 1];
                Array.Copy(args, 0, tmpargs, 0, n - 1);
                helper.Invoke(client, functionName, tmpargs, callback, byRef);
                return null;
            }
            if ((n > 0) && (paramTypes[n - 1].IsGenericType &&
                           (paramTypes[n - 1].GetGenericTypeDefinition() == typeof(HproseCallback1<>)))) {
                IInvokeHelper1 helper = Activator.CreateInstance(typeof(InvokeHelper1<>).MakeGenericType(paramTypes[n - 1].GetGenericArguments())) as IInvokeHelper1;
                Delegate callback = (Delegate)args[n - 1];
                object[] tmpargs = new object[n - 1];
                Array.Copy(args, 0, tmpargs, 0, n - 1);
                helper.Invoke(client, functionName, tmpargs, callback);
                return null;
            }
#endif
            object result = client.Invoke(functionName, args, returnType, byRef);
            if (result is Exception) {
                throw (Exception)result;
            }
            return result;
        }
    }
}
#endif