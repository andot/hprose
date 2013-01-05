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
 * hproseCommon.js                                        *
 *                                                        *
 * hprose common library for JavaScript.                  *
 *                                                        *
 * LastModified: Nov 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseResultMode = {
    Normal: 0,
    Serialized: 1,
    Raw: 2,
    RawWithEndTag: 3
}

function HproseException(message) {
    this.message = message;
};
HproseException.prototype = new Error;
HproseException.prototype.name = 'HproseException';

function HproseFilter() {
    this.inputFilter = function(value) { return value; };
    this.outputFilter = function(value) { return value; };
}