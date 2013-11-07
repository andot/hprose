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
 * LastModified: Nov 7, 2013                              *
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
    function readRef() {
        return ref[readInt(HproseTags.TagSemicolon)];
    }
    var unserialize = this.unserialize;
    this.unserialize = function(tag) {
        if (tag === undefined) {
            tag = stream.getc();
        }
        if (tag == HproseTags.TagRef) {
            return readRef();
        }
        return unserialize.call(this, tag);
    }
    var readDate = this.readDate;
    this.readDate = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagDate,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var date = readDate();
        ref[ref.length] = date;
        return date;
    }
    var readTime = this.readTime;
    this.readTime = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagTime,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var time = readTime();
        ref[ref.length] = time;
        return time;
    }
    var readBytes = this.readBytes;
    this.readBytes = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagBytes,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var bytes = readBytes();
        ref[ref.length] = bytes;
        return bytes;
    }
    var readString = this.readString;
    this.readString = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagString,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var s = readString();
        ref[ref.length] = s;
        return s;
    }
    var readGuid = this.readGuid;
    this.readGuid = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagGuid,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var s = readGuid();
        ref[ref.length] = s;
        return s;
    }
    this.readList = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagList,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var list = this.readListBegin();
        ref[ref.length] = list;
        return this.readListEnd(list);
    }
    this.readMap = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagMap,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
        }
        var map = this.readMapBegin();
        ref[ref.length] = map;
        return this.readMapEnd(map);
    }
    this.readObject = function(includeTag) {
        if (includeTag) {
            var tag = this.checkTags([HproseTags.TagClass,
                                      HproseTags.TagObject,
                                      HproseTags.TagRef]);
            if (tag == HproseTags.TagRef) return readRef();
            if (tag == HproseTags.TagClass) {
                this.readClass();
                return this.readObject(true);
            }
        }
        var result = this.readObjectBegin();
        ref[ref.length] = result.obj;
        return this.readObjectEnd(result.obj, result.cls);
    }
    var reset = this.reset;
    this.reset = function() {
        reset();
        ref.length = 0;
    }
}

module.exports = HproseReader;