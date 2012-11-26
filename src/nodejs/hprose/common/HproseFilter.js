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
 * HproseFilter.js                                        *
 *                                                        *
 * HproseFilter for Node.js.                              *
 *                                                        *
 * LastModified: Nov 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

function HproseFilter() {
    this.inputFilter = function(value) { return value; };
    this.outputFilter = function(value) { return value; };
}

module.exports = HproseFilter;