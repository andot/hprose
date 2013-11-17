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
 * hproseCommon.js                                        *
 *                                                        *
 * hprose common library for JavaScript.                  *
 *                                                        *
 * LastModified: Nov 17, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseResultMode = {
    Normal: 0,
    Serialized: 1,
    Raw: 2,
    RawWithEndTag: 3
}

function HproseException(message) {
    this.message = message;
};
HproseException.prototype = new Error;
HproseException.prototype.name = 'HproseException';

function HproseFilter() {
    this.inputFilter = function(value) { return value; }
    this.outputFilter = function(value) { return value; }
}

if (!('isArray' in Array)) {
    Array.isArray = function (arg) {
        return Object.prototype.toString.call(arg) === '[object Array]';
    }
}

(function (global) {
    var hasMap = 'Map' in global;
    var hasWeakMap = 'WeakMap' in global;
    var hasActiveXObject = 'ActiveXObject' in global;
    var hasObject_create = 'create' in Object;
    if (hasMap && hasWeakMap) return;
    if (hasActiveXObject) {
        if (!hasWeakMap) {
            global.WeakMap = function() {
                var dict =  new ActiveXObject("Scripting.Dictionary");
                this.get = function(key) {
                    if (dict.Exists(key)) {
                        return dict.Item(key);
                    }
                    else {
                        return undefined;
                    }
                }
                this.set = function(key, value) {
                    if (dict.Exists(key)) {
                        dict.Item(key) = value;
                    }
                    else {
                        dict.Add(key, value);
                    }
                }
                this.has = function(key) {
                    return dict.Exists(key);
                }
                this['delete'] = function(key) {
                    if (dict.Exists(key)) {
                        dict.Remove(key);
                        return true;
                    }
                    return false;
                }
                this.clear = function() {
                    dict.RemoveAll();
                }
            }
        }
        if (!hasMap) {
            global.Map = function() {
                var dict =  new ActiveXObject("Scripting.Dictionary");
                var size = 0;
                this.size = size;
                this.get = function(key) {
                    if (dict.Exists(key)) {
                        return dict.Item(key);
                    }
                    else {
                        return undefined;
                    }
                }
                this.set = function(key, value) {
                    if (dict.Exists(key)) {
                        dict.Item(key) = value;
                    }
                    else {
                        this.size = ++size;
                        dict.Add(key, value);
                    }
                }
                this.has = function(key) {
                    return dict.Exists(key);
                }
                this['delete'] = function(key) {
                    if (dict.Exists(key)) {
                        this.size = --size;
                        dict.Remove(key);
                        return true;
                    }
                    return false;
                }
                this.clear = function() {
                    dict.RemoveAll();
                    this.size = size = 0;
                }
            }
        }
    }
    else {
        var createNPO = function() {
            return hasObject_create ? Object.create(null) : {};
        }
        var namespaces = createNPO();
        var count = 0;
        var reDefineValueOf = function(obj) {
            var privates = createNPO();
            var baseValueOf = obj.valueOf;
            obj.valueOf = function(namespace, n) {
                if ((this === obj) &&
                    (n in namespaces) &&
                    (namespaces[n] === namespace)) {
                    if (!(n in privates)) privates[n] = createNPO();
                    return privates[n];
                }
                else {
                    baseValueOf.apply(this, arguments);
                }
            }
        }
        var ObjectMap = function() {
            var namespace = createNPO();
            var n = count++;
            var nullMap = createNPO();
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
            var map = createNPO();
            return {
                get: function(key) { return map[key]; },
                set: function(key, value) { map[key] = value; },
                has: function(key) { return key in map; },
                'delete': function(key) { return delete map[key]; },
                clear: function() { map = createNPO(); }
            }
        }
        if (!hasObject_create) {
            var StringMap = function() {
                var map = {};
                return {
                    get: function(key) { return map['str_' + key]; },
                    set: function(key, value) { map['str_' + key] = value; },
                    has: function(key) { return ('str_' + key) in map; },
                    'delete': function(key) { return delete map['str_' + key]; },
                    clear: function() { map = {}; }
                }
            }
        }
        var NoKeyMap = function() {
            var map = createNPO();
            return {
                get: function(key) { return map.value; },
                set: function(key, value) { map.value = value; },
                has: function(key) { return 'value' in map; },
                'delete': function(key) { return delete map.value; },
                clear: function() { map = createNPO(); }
            }
        }
        var unsupport = function() {
            throw new Error("the key is not a supported type.");
        }
        var doNothing = function() {}
        var UnknownMap = {
            get: unsupport,
            set: unsupport,
            has: unsupport,
            'delete': unsupport,
            clear: doNothing
        }
        if (!hasWeakMap) {
            global.WeakMap = function() {
                var map = {
                    'number': ScalarMap(),
                    'string': hasObject_create ? ScalarMap() : StringMap(),
                    'boolean': ScalarMap(),
                    'object': ObjectMap(),
                    'function': ObjectMap(),
                    'undefined': NoKeyMap(),
                    'null': NoKeyMap(), 
                    'unknown': UnknownMap
                };
                this.get = function(key) {
                    return map[typeof(key)].get(key);
                }
                this.set = function(key, value) {
                    map[typeof(key)].set(key, value);
                }
                this.has = function(key) {
                    return map[typeof(key)].has(key);
                }
                this['delete'] = function(key) {
                    return map[typeof(key)]['delete'](key);
                }
                this.clear = function() {
                    for (var key in map) map[key].clear();
                }
            }
        }
        if (!hasMap) {
            global.Map = function() {
                var map = {
                    'number': ScalarMap(),
                    'string': hasObject_create ? ScalarMap() : StringMap(),
                    'boolean': ScalarMap(),
                    'object': ObjectMap(),
                    'function': ObjectMap(),
                    'undefined': NoKeyMap(),
                    'null': NoKeyMap(), 
                    'unknown': UnknownMap
                };
                var size = 0;
                this.size = size;
                this.get = function(key) {
                    return map[typeof(key)].get(key);
                }
                this.set = function(key, value) {
                    if (!this.has(key)) this.size = ++size;
                    map[typeof(key)].set(key, value);
                }
                this.has = function(key) {
                    return map[typeof(key)].has(key);
                }
                this['delete'] = function(key) {
                    if (this.has(key)) {
                        this.size = --size;
                        return map[typeof(key)]['delete'](key);
                    }
                    return false;
                }
                this.clear = function() {
                    for (var key in map) map[key].clear();
                    this.size = size = 0;
                }
            }
        }
    }
})(this);
