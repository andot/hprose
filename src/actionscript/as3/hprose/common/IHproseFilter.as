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
 * IHproseFilter.as                                       *
 *                                                        *
 * hprose filter interface for ActionScript 3.0.          *
 *                                                        *
 * LastModified: Nov 24, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common {
    import flash.utils.ByteArray;

    public interface IHproseFilter {
        function inputFilter(data: ByteArray):ByteArray;
        function outputFilter(data: ByteArray):ByteArray;
    }
}