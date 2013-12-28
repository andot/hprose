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
 * HproseReader.js                                        *
 *                                                        *
 * HproseReader for Node.js.                              *
 *                                                        *
 * LastModified: Dec 28, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseTags = require('./HproseTags.js');
var HproseSimpleReader = require('./HproseSimpleReader.js');

function HproseReader(stream) {
    HproseSimpleReader.call(this, stream);
    var ref = [];
    function readInt(tag) {
        var s = stream.readuntil(tag);
        if (s.length == 0) return 0;
        return parseInt(s);
    }
    var readDateWithoutTag = this.readDateWithoutTag;
    this.readDateWithoutTag = function() {
        return ref[ref.length] = readDateWithoutTag();
    }
    var readTimeWithoutTag = this.readTimeWithoutTag;
    this.readTimeWithoutTag = function() {
        return ref[ref.length] = readTimeWithoutTag();
    }
    var readBytesWithoutTag = this.readBytesWithoutTag;
    this.readBytesWithoutTag = function() {
        return ref[ref.length] = readBytesWithoutTag();
    }
    var readStringWithoutTag = this.readStringWithoutTag;
    this.readStringWithoutTag = function() {
        return ref[ref.length] = readStringWithoutTag();
    }
    var readGuidWithoutTag = this.readGuidWithoutTag;
    this.readGuidWithoutTag = function() {
        return ref[ref.length] = readGuidWithoutTag();
    }
    this.readListWithoutTag = function() {
        return this.readListEnd(ref[ref.length] = this.readListBegin());
    }
    this.readMapWithoutTag = function() {
        return this.readMapEnd(ref[ref.length] = this.readMapBegin());
    }
    this.readObjectWithoutTag = function() {
        var result = this.readObjectBegin();
        ref[ref.length] = result.obj;
        return this.readObjectEnd(result.obj, result.cls);
    }
    this.readRef = function() {
        return ref[readInt(HproseTags.TagSemicolon)];
    }
    var reset = this.reset;
    this.reset = function() {
        reset();
        ref.length = 0;
    }
}

module.exports = HproseReader;