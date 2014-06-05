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
 * ResultMode.java                                        *
 *                                                        *
 * result mode enum for Java.                             *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

public final class HproseResultMode {
    public static final HproseResultMode Normal = new HproseResultMode();
    public static final HproseResultMode Serialized = new HproseResultMode();
    public static final HproseResultMode Raw = new HproseResultMode();
    public static final HproseResultMode RawWithEndTag = new HproseResultMode();
    private HproseResultMode() {
    }
}