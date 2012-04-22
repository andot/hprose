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
 * HproseResultMode.as                                    *
 *                                                        *
 * HproseResultMode enum for ActionScript 3.0.            *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.client {
    public class HproseResultMode {
        public static const Normal:int = 0;
        public static const Serialized:int = 1;
        public static const Raw:int = 2;
        public static const RawWithEndTag:int = 3;
    }
}