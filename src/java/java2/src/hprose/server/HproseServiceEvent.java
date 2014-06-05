/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseServiceEvent.java                                *
 *                                                        *
 * hprose service event interface for Java.               *
 *                                                        *
 * LastModified: Feb 1, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.server;

public interface HproseServiceEvent {
    void onBeforeInvoke(String name, Object[] args, boolean byRef);
    void onAfterInvoke(String name, Object[] args, boolean byRef, Object result);
    void onSendError(String error);
}
