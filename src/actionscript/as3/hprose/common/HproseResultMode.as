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
 * LastModified: Nov 24, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common {
    public class HproseResultMode {
        public static const Normal:int = 0;
        public static const Serialized:int = 1;
        public static const Raw:int = 2;
        public static const RawWithEndTag:int = 3;
    }
}