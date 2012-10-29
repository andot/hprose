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
 * LastModified: Oct 29, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseBufferInputStream = require('./HproseBufferInputStream.js');
var HproseBufferOutputStream = require('./HproseBufferOutputStream.js');
var HproseReader = require('./HproseReader.js');
var HproseWriter = (typeof(Map) === 'undefined') ? require('./HproseWriter.js') : require('./HproseWriter2.js');

var HproseFormatter = {
    serialize: function(variable) {
        var stream = new HproseBufferOutputStream();
        var hproseWriter = new HproseWriter(stream);
        hproseWriter.serialize(variable);
        return stream.toBuffer();
    },
    unserialize: function(variable_representation) {
        var stream = new HproseBufferInputStream(variable_representation);
        var hproseReader = new HproseReader(stream);
        return hproseReader.unserialize();
    }
}

module.exports = HproseFormatter;