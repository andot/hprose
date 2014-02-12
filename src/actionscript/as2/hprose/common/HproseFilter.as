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
 * hprose filter class for ActionScript 2.0.              *
 *                                                        *
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

import hprose.common.IHproseFilter;

class hprose.common.HproseFilter implements IHproseFilter {
    public function inputFilter(data: String):String {
        return data;
    }
    public function outputFilter(data: String):String {
        return data;
    }
}