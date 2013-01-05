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
 * HproseResultMode.js                                    *
 *                                                        *
 * HproseResultMode for Node.js.                          *
 *                                                        *
 * LastModified: Oct 24, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseResultMode = {
    Normal: 0,
    Serialized: 1,
    Raw: 2,
    RawWithEndTag: 3
};

module.exports = HproseResultMode;