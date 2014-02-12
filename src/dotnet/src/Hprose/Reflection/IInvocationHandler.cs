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
 * IInvocationHandler.cs                                  *
 *                                                        *
 * IInvocationHandler interface for C#.                   *
 *                                                        *
 * LastModified: Jul 14, 2010                             *
 * Authors: Ma Bingyao <andot@hprose.com>                 *
 *                                                        *
\**********************************************************/

#if !(PocketPC || Smartphone || WindowsCE || WINDOWS_PHONE || Core)
using System.Reflection;

namespace Hprose.Reflection {
    public interface IInvocationHandler {
        object Invoke(object proxy, MethodInfo method, object[] args);
    }
}
#endif