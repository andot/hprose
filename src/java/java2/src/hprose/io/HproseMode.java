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
 * HproseMode.java                                        *
 *                                                        *
 * hprose mode enum for Java.                             *
 *                                                        *
 * LastModified: Feb 2, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io;

public final class HproseMode {
    public static final HproseMode FieldMode = new HproseMode();
    public static final HproseMode PropertyMode = new HproseMode();
    public static final HproseMode MemberMode = new HproseMode();
    private HproseMode() {
    }
}