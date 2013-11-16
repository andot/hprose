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
 * LastModified: Nov 16, 2013                             *
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
                this.size = 0;
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
                        this.size++;
                        dict.Add(key, value);
                    }
                }
                this.has = function(key) {
                    return dict.Exists(key);
                }
                this['delete'] = function(key) {
                    if (dict.Exists(key)) {
                        this.size--;
                        dict.Remove(key);
                        return true;
                    }
                    return false;
                }
                this.clear = function() {
                    dict.RemoveAll();
                    this.size = 0;
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
            obj.valueOf = function(namespace) {
                var n;
                if ((this === obj) &&
                    (typeof(namespace) === 'object') &&
                    ('n' in namespace) &&
                    ((n = namespace.n) in namespaces) &&
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
            return {
                namespace: { n: count++ },
                nullMap: createNPO(),
                map: function map(key) {
                    if (key === null) return this.nullMap;
                    var n = this.namespace.n;
                    if (!(n in namespaces)) namespaces[n] = this.namespace;
                    var privates = key.valueOf(this.namespace);
                    if (privates !== key.valueOf()) return privates;
                    reDefineValueOf(key);
                    return key.valueOf(this.namespace);
                },
                get: function(key) { return this.map(key).value; },
                set: function(key, value) { this.map(key).value = value; },
                has: function(key) { return 'value' in this.map(key); },
                'delete': function(key) { return delete this.map(key).value; },
                clear: function() {
                    delete namespaces[this.namespace.n];
                    this.namespace.n = count++;
                }
            }
        }
        var ScalarMap = function() {
            return {
                map: createNPO(),
                get: function(key) { return this.map[key]; },
                set: function(key, value) { this.map[key] = value; },
                has: function(key) { return key in this.map; },
                'delete': function(key) { return delete this.map[key]; },
                clear: function() { this.map = createNPO(); }
            }
        }
        if (!hasObject_create) {
            var StringMap = function() {
                return {
                    map: {},
                    get: function(key) { return this.map['str_' + key]; },
                    set: function(key, value) { this.map['str_' + key] = value; },
                    has: function(key) { return ('str_' + key) in this.map; },
                    'delete': function(key) { return delete this.map['str_' + key]; },
                    clear: function() { this.map = {}; }
                }
            }
        }
        var UndefinedMap = function() {
            return {
                map: createNPO(),
                get: function(key) { return this.map.value; },
                set: function(key, value) { this.map.value = value; },
                has: function(key) { return 'value' in this.map; },
                'delete': function(key) { return delete this.map.value; },
                clear: function() { this.map = createNPO(); }
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
                    'undefined': UndefinedMap(),
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
                    'undefined': UndefinedMap(),
                    'unknown': UnknownMap
                };
                this.size = 0;
                this.get = function(key) {
                    return map[typeof(key)].get(key);
                }
                this.set = function(key, value) {
                    if (!this.has(key)) this.size++;
                    map[typeof(key)].set(key, value);
                }
                this.has = function(key) {
                    return map[typeof(key)].has(key);
                }
                this['delete'] = function(key) {
                    if (this.has(key)) {
                        this.size--;
                        return map[typeof(key)]['delete'](key);
                    }
                    return false;
                }
                this.clear = function() {
                    for (var key in map) map[key].clear();
                    this.size = 0;
                }
            }
        }
    }
})(this);
