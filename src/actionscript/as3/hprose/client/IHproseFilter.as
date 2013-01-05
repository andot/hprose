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
 * LastModified: Jun 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.client {
    import flash.utils.ByteArray;

    public interface IHproseFilter {
        function inputFilter(data: ByteArray):ByteArray;
        function outputFilter(data: ByteArray):ByteArray;
    }
}