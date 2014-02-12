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
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

interface hprose.common.IHproseFilter {
    function inputFilter(data: String):String;
    function outputFilter(data: String):String;
}