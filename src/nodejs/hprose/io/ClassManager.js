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
 * LastModified: Nov 7, 2013                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var classCache = Object.create(null);

if (typeof(WeakMap) === 'undefined') {
    var ClassManager = {
        register: function(cls, alias) {
            classCache[alias] = cls;
        },
        getClassAlias: function(cls) {
            for (var alias in classCache) {
                if (cls === classCache[alias]) return alias;
            }
            return undefined;
        }
    };
}
else {
    var aliasCache = new WeakMap();
    var ClassManager = {
        register: function(cls, alias) {
            aliasCache.set(cls, alias);
            classCache[alias] = cls;
        },
        getClassAlias: function(cls) {
            return aliasCache.get(cls);
        }
    };
}

ClassManager.getClass = function(alias) {
    return classCache[alias];
}

ClassManager.register(Object, 'Object');

module.exports = ClassManager;