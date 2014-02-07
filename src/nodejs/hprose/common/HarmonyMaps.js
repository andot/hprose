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
 * HarmonyMaps.js                                         *
 *                                                        *
 * Harmony Maps for Node.js.                              *
 *                                                        *
 * LastModified: Nov 18, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var hasMap = 'Map' in global;
var hasWeakMap = 'WeakMap' in global;

if (hasMap && hasWeakMap) return;

var namespaces = Object.create(null);
var count = 0;

var reDefineValueOf = function(obj) {
    var privates = Object.create(null);
    var baseValueOf = obj.valueOf;
    obj.valueOf = function(namespace, n) {
        if ((this === obj) &&
            (n in namespaces) &&
            (namespaces[n] === namespace)) {
            if (!(n in privates)) privates[n] = Object.create(null);
            return privates[n];
        }
        else {
            baseValueOf.apply(this, arguments);
        }
    }
}

if (!hasWeakMap) {
    global.WeakMap = function WeakMap() {
        var namespace = Object.create(null);
        var n = count++;
        namespaces[n] = namespace;
        var map = function(key) {
            if (key !== Object(key)) throw new Error("value is not a non-null object");
            var privates = key.valueOf(namespace, n);
            if (privates !== key.valueOf()) return privates;
            reDefineValueOf(key);
            return key.valueOf(namespace, n);
        }
        return Object.freeze(Object.create(WeakMap.prototype, {
            get: {
                value: function(key) { return map(key).value; },
                writable: true,
                configurable: true,
                enumerable: false
            },
            set: {
                value: function(key, value) { map(key).value = value; },
                writable: true,
                configurable: true,
                enumerable: false
            },
            has: {
                value: function(key) { return 'value' in map(key); },
                writable: true,
                configurable: true,
                enumerable: false
            },
            'delete': {
                value: function(key) { return delete map(key).value; },
                writable: true,
                configurable: true,
                enumerable: false
            },
            clear: {
                value: function() {
                    delete namespaces[n];
                    n = count++;
                    namespaces[n] = namespace;
                },
                writable: true,
                configurable: true,
                enumerable: false
            }
        }));
    }
}

if (!hasMap) {
    var ObjectMap = function() {
        var namespace = Object.create(null);
        var n = count++;
        var nullMap = Object.create(null);
        namespaces[n] = namespace;
        var map = function(key) {
            if (key === null) return nullMap;
            var privates = key.valueOf(namespace, n);
            if (privates !== key.valueOf()) return privates;
            reDefineValueOf(key);
            return key.valueOf(namespace, n);
        }
        return {
            get: function(key) { return map(key).value; },
            set: function(key, value) { map(key).value = value; },
            has: function(key) { return 'value' in map(key); },
            'delete': function(key) { return delete map(key).value; },
            clear: function() {
                delete namespaces[n];
                n = count++;
                namespaces[n] = namespace;
            }
        }
    }

    var ScalarMap = function() {
        var map = Object.create(null);
        return {
            get: function(key) { return map[key]; },
            set: function(key, value) { map[key] = value; },
            has: function(key) { return key in map; },
            'delete': function(key) { return delete map[key]; },
            clear: function() { map = Object.create(null); }
        }
    }

    var NoKeyMap = function() {
        var map = Object.create(null);
        return {
            get: function(key) { return map.value; },
            set: function(key, value) { map.value = value; },
            has: function(key) { return 'value' in map; },
            'delete': function(key) { return delete map.value; },
            clear: function() { map = Object.create(null); }
        }
    }

    global.Map = function Map() {
        var map = {
            'number': ScalarMap(),
            'string': ScalarMap(),
            'boolean': ScalarMap(),
            'object': ObjectMap(),
            'function': ObjectMap(),
            'unknown': ObjectMap(),
            'undefined': NoKeyMap(),
            'null': NoKeyMap()
        };
        var size = 0;
        return Object.freeze(Object.create(Map.prototype, {
            size: {
                get : function() { return size; },
                configurable: true,
                enumerable: false
            },
            get: {
                value: function(key) {
                    return map[typeof(key)].get(key);
                },
                writable: true,
                configurable: true,
                enumerable: false
            },
            set: {
                value: function(key, value) {
                    if (!this.has(key)) size++;
                    map[typeof(key)].set(key, value);
                },
                writable: true,
                configurable: true,
                enumerable: false
            },
            has: {
                value: function(key) {
                    return map[typeof(key)].has(key);
                },
                writable: true,
                configurable: true,
                enumerable: false
            },
            'delete': {
                value: function(key) {
                    if (this.has(key)) {
                        size--;
                        return map[typeof(key)]['delete'](key);
                    }
                    return false;
                },
                writable: true,
                configurable: true,
                enumerable: false
            },
            clear: {
                value: function() {
                    for (var key in map) map[key].clear();
                    size = 0;
                },
                writable: true,
                configurable: true,
                enumerable: false
            }
        }));
    }
}
