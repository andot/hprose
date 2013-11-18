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
 * HproseClassManager.js                                  *
 *                                                        *
 * Hprose ClassManager for Node.js.                       *
 *                                                        *
 * LastModified: Nov 18, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

require('../common/HarmonyMaps.js');

var classCache = Object.create(null);
var aliasCache = new WeakMap();

var HproseClassManager = {
    register: function(cls, alias) {
        aliasCache.set(cls, alias);
        classCache[alias] = cls;
    },
    getClassAlias: function(cls) {
        return aliasCache.get(cls);
    },
    getClass: function(alias) {
        return classCache[alias];
    }
};

HproseClassManager.register(Object, 'Object');

module.exports = HproseClassManager;