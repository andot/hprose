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
 * HproseWriter.js                                        *
 *                                                        *
 * HproseWriter for Node.js.                              *
 *                                                        *
 * LastModified: Dec 28, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require('../common/HarmonyMaps.js');
var HproseTags = require('./HproseTags.js');
var HproseSimpleWriter = require('./HproseSimpleWriter.js');

function HproseWriter(stream) {
    HproseSimpleWriter.call(this, stream);
    var ref = new Map();
    var refcount = 0;
    var writeUTCDate = this.writeUTCDate;
    this.writeUTCDate = function(date) {
        ref.set(date, refcount++);
        writeUTCDate.call(this, date);
    }
    var writeDate = this.writeDate;
    this.writeDate = function(date) {
        ref.set(date, refcount++);
        writeDate.call(this, date);
    }
    var writeTime = this.writeTime;
    this.writeTime = function(time) {
        ref.set(time, refcount++);
        writeTime.call(this, time);
    }
    var writeBytes = this.writeBytes;
    this.writeBytes = function(bytes) {
        ref.set(bytes, refcount++);
        writeBytes.call(this, bytes);
    }
    var writeString = this.writeString;
    this.writeString = function(str) {
        ref.set(str, refcount++);
        writeString.call(this, str);
    }
    var writeList = this.writeList;
    this.writeList = function(list) {
        ref.set(list, refcount++);
        writeList.call(this, list);
    }
    var writeMap = this.writeMap;
    this.writeMap = function(map) {
        ref.set(map, refcount++);
        writeMap.call(this, map);
    }
    this.writeObject = function(obj) {
        var fields = this.writeObjectBegin(obj);
        ref.set(obj, refcount++);
        this.writeObjectEnd(obj, fields);
    }
    this.writeRef = function(obj) {
        var index = ref.get(obj);
        if (index !== undefined) {
            stream.write(HproseTags.TagRef);
            stream.write(index.toString());
            stream.write(HproseTags.TagSemicolon);
            return true;
        }
        return false;
    }
    var reset = this.reset;
    this.reset = function() {
        reset();
        ref = new Map();
        refcount = 0;
    }
}

module.exports = HproseWriter;