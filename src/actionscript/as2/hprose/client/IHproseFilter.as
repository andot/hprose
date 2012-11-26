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
 * hprose filter interface for ActionScript 2.0.          *
 *                                                        *
 * LastModified: Jun 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

interface hprose.client.IHproseFilter {
    function inputFilter(data: String):String;
    function outputFilter(data: String):String;
}