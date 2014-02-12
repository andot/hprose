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
 * HproseServiceEvent.cs                                  *
 *                                                        *
 * hprose service event for C#.                           *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
#if !ClientOnly
namespace Hprose.Server {
    public delegate void BeforeInvokeEvent(string name, object[] args, bool byRef);
    public delegate void AfterInvokeEvent(string name, object[] args, bool byRef, object result);
    public delegate void SendHeaderEvent();
    public delegate void SendErrorEvent(string error);
}
#endif