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
 * ClassManager.js                                        *
 *                                                        *
 * Hprose ClassManager for Node.js.                       *
 *                                                        *
 * LastModified: Oct 29, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var classCache = Object.create(null);
var aliasCache = new WeakMap();

var ClassManager = {
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

ClassManager.register(Object, 'Object');

module.exports = ClassManager;