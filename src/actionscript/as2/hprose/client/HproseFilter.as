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
 * LastModified: Jun 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
import hprose.client.IHproseFilter;

class hprose.client.HproseFilter implements IHproseFilter {
    public function inputFilter(data: String):String {
        return data;
    }
    public function outputFilter(data: String):String {
        return data;
    }
}