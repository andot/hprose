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

var ClassManager = {
    register: function(cls, alias) {
        classCache[alias] = cls;
    },
    getClassAlias: function(cls) {
        for (var alias in classCache) {
            if (cls === classCache[alias]) return alias;
        }
        return undefined;
    },
    getClass: function(alias) {
        return classCache[alias];
    }
};

ClassManager.register(Object, 'Object');

module.exports = ClassManager;