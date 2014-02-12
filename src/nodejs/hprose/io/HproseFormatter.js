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
 * HproseFormatter.js                                     *
 *                                                        *
 * HproseFormatter for Node.js.                           *
 *                                                        *
 * LastModified: Nov 7, 2013                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

var HproseBufferInputStream = require('./HproseBufferInputStream.js');
var HproseBufferOutputStream = require('./HproseBufferOutputStream.js');
var HproseSimpleReader = require('./HproseSimpleReader.js');
var HproseSimpleWriter = require('./HproseSimpleWriter.js');
var HproseReader = require('./HproseReader.js');
var HproseWriter = require('./HproseWriter.js');

var HproseFormatter = {
    serialize: function(variable, simple) {
        var stream = new HproseBufferOutputStream();
        var hproseWriter = (simple ? new HproseSimpleWriter(stream) : new HproseWriter(stream));
        hproseWriter.serialize(variable);
        return stream.toBuffer();
    },
    unserialize: function(variable_representation, simple) {
        var stream = new HproseBufferInputStream(variable_representation);
        var hproseReader = (simple ? new HproseSimpleReader(stream) :  new HproseReader(stream));
        return hproseReader.unserialize();
    }
}

module.exports = HproseFormatter;