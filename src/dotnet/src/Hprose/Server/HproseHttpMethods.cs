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
 * HproseHttpMethods.cs                                   *
 *                                                        *
 * hprose http remote methods class for C#.               *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
#if !ClientOnly
using System;
using System.Web;
using System.Web.SessionState;
using Hprose.Common;

namespace Hprose.Server {
    public class HproseHttpMethods : HproseMethods {
        protected override int GetCount(Type[] paramTypes) {
            int i = paramTypes.Length;
            if (i > 0) {
                Type paramType = paramTypes[i - 1];
                if (paramType == typeof(HttpContext) ||
                    paramType == typeof(HttpRequest) ||
                    paramType == typeof(HttpResponse) ||
                    paramType == typeof(HttpServerUtility) ||
                    paramType == typeof(HttpApplicationState) ||
                    paramType == typeof(HttpSessionState)) {
                    i--;
                }
            }
            return i;
        }
    }
}
#endif