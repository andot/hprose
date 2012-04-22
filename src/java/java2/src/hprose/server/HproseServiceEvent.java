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
 * HproseServiceEvent.java                                *
 *                                                        *
 * hprose service event interface for Java.               *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.server;

public interface HproseServiceEvent {
    void onBeforeInvoke(String name, Object[] args, boolean byRef);
    void onAfterInvoke(String name, Object[] args, boolean byRef, Object result);
    void onSendHeader();
    void onSendError(String error);
}
