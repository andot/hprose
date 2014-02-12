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
 * HproseHttpListenerMethods.cs                           *
 *                                                        *
 * hprose http listener remote methods class for C#.      *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !(dotNET10 || dotNET11 || ClientOnly)
using System;
using System.Net;
using System.Security.Principal;
using Hprose.Common;

namespace Hprose.Server {
    public class HproseHttpListenerMethods : HproseMethods {
        protected override int GetCount(Type[] paramTypes) {
            int i = paramTypes.Length;
            if (i > 0) {
                Type paramType = paramTypes[i - 1];
                if (paramType == typeof(HttpListenerContext) ||
                    paramType == typeof(HttpListenerRequest) ||
                    paramType == typeof(HttpListenerResponse) ||
                    paramType == typeof(IPrincipal)) {
                    i--;
                }
            }
            return i;
        }
    }
}
#endif