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
 * HproseBufferOutputStream.js                            *
 *                                                        *
 * HproseBufferOutputStream for Node.js.                  *
 *                                                        *
 * LastModified: Oct 24, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

var util = require('util');

function HproseBufferOutputStream(data) {
    var buf = [];
    var array = [];
    var totalLength = 0;
    function pushArray() {
        if (array.length > 0) {
            totalLength += array.length;
            buf.push(new Buffer(array));
            array = [];
        }
    }
    function pushData(data) {
        pushArray();
        totalLength += data.length;
        buf.push(data);
    }
    this.write = function(data) {
        switch (typeof(data)) {
            case 'number':
                array.push(data);
                break;
            case 'string':
                if (data != '') {
                    pushData(new Buffer(data));
                }
                break;
            case 'object':
                if (util.isArray(data)) {
                    array = array.concat(data);
                }
                else if (Buffer.isBuffer(data)) {
                    pushData(data);
                }
                break;
        }
    }
    this.toBuffer = function() {
        pushArray();
        buf = [Buffer.concat(buf, totalLength)];
        return buf[0];
    }
    this.clear = function() {
        buf = [];
        array = [];
        totalLength = 0;
    }
    this.mark = function() {
        data = this.toBuffer();
    }
    this.reset = function() {
        this.clear();
        this.write(data);
    }
    this.write(data);
}

module.exports = HproseBufferOutputStream;