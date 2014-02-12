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
 * HproseFilter.as                                        *
 *                                                        *
 * hprose filter class for ActionScript 3.0.              *
 *                                                        *
 * LastModified: Nov 24, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common {
    import flash.utils.ByteArray;
    public class HproseFilter implements IHproseFilter {
        public function inputFilter(data: ByteArray):ByteArray {
            return data;
        }
        public function outputFilter(data: ByteArray):ByteArray {
            return data;
        }
    }
}