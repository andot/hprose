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
 * HproseMethod.cs                                        *
 *                                                        *
 * hprose remote method class for C#.                     *
 *                                                        *
 * LastModified: Nov 6, 2012                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;
using System.Reflection;

namespace Hprose.Common {
    class HproseMethod {
        public object obj;
        public MethodInfo method;
        public Type[] paramTypes;
        public HproseResultMode mode;
        public HproseMethod(MethodInfo method, object obj, HproseResultMode mode) {
            this.obj = obj;
            this.method = method;
            this.mode = mode;
            ParameterInfo[] parameters = method.GetParameters();
            this.paramTypes = new Type[parameters.Length];
            for (int i = 0; i < paramTypes.Length; i++) {
                this.paramTypes[i] = parameters[i].ParameterType;
            }
        }
        public HproseMethod(MethodInfo method, object obj)
            : this(method, obj, HproseResultMode.Normal) {
        }
        public HproseMethod(MethodInfo method)
            : this(method, null, HproseResultMode.Normal) {
        }
        public HproseMethod(string methodName, Type type, Type[] paramTypes, HproseResultMode mode) {
            this.obj = null;
#if dotNET45
            this.method = type.GetRuntimeMethod(methodName, paramTypes);
#else
            this.method = type.GetMethod(methodName, paramTypes);
#endif
            if (!method.IsStatic) {
                throw new MissingMethodException();
            }
            this.paramTypes = paramTypes;
            this.mode = mode;
        }
        public HproseMethod(string methodName, Type type, Type[] paramTypes)
            : this(methodName, type, paramTypes, HproseResultMode.Normal) {
        }
        public HproseMethod(string methodName, object obj, Type[] paramTypes, HproseResultMode mode) {
            this.obj = obj;
#if dotNET45
            this.method = obj.GetType().GetRuntimeMethod(methodName, paramTypes);
#else
            this.method = obj.GetType().GetMethod(methodName, paramTypes);
#endif
            if (method.IsStatic) {
                throw new MissingMethodException();
            }
            this.paramTypes = paramTypes;
            this.mode = mode;
        }
        public HproseMethod(string methodName, object obj, Type[] paramTypes)
            : this(methodName, obj, paramTypes, HproseResultMode.Normal) {
        }
    }
}