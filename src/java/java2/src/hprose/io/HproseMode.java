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
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io;

public final class HproseMode {
    public static final HproseMode FieldMode = new HproseMode();
    public static final HproseMode PropertyMode = new HproseMode();
    private HproseMode() {
    }
}