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
 * LastModified: Nov 15, 2013                             *
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

if (!Array.isArray) {
    Array.isArray = function (arg) {
        return Object.prototype.toString.call(arg) === '[object Array]';
    }
}

if (!this.Map || !this.WeakMap) {
    (function (global) {
        "use strict";
        var s_get = "get";
        var s_set = "set";
        var s_has = "has";
        var s_delete = "delete";
        var s_clear = "clear";
        var s_value = "value";
        
        function reDefineValueOf(obj, namespace) {
            var privates = {};
            var baseValueOf = obj.valueOf;
            obj.valueOf = function valueOf(value) {
                return value !== namespace || this !== obj ?
                    baseValueOf.apply(this, arguments) : privates;
            }
            return privates;
        }
        function ObjectDict() {
            var namespace = {};
            var nullDict = {};
            function dict(key) {
                if (key === null) return nullDict;
                var privates = key.valueOf(namespace);
                return privates !== key.valueOf() ? privates : reDefineValueOf(key, namespace);
            }
            this[s_get] = function(key) { return dict(key).value; }
            this[s_set] = function(key, value) { dict(key).value = value; }
            this[s_has] = function(key) { return s_value in dict(key); }
            this[s_delete] = function(key) { return delete dict(key).value; }
            this[s_clear] = function() { namespace = {}; }
        }
        function ScalarDict() {
            var dict = {};
            this[s_get] = function(key) { return dict[key]; }
            this[s_set] = function(key, value) { dict[key] = value; }
            this[s_has] = function(key) { return key in dict; }
            this[s_delete] = function(key) { return delete dict[key]; }
            this[s_clear] = function() { dict = {}; }
        }
        function UndefinedDict() {
            var dict = {};
            this[s_get] = function(key) { return dict.value; }
            this[s_set] = function(key, value) { dict.value = value; }
            this[s_has] = function(key) { return s_value in dict; }
            this[s_delete] = function(key) { return delete dict.value; }
            this[s_clear] = function() { dict = {}; }
        }
        function UnknownDict() {
            function unsupport() {
                throw new Error("the key is not a supported type.");
            }
            this[s_get] = unsupport;
            this[s_set] = unsupport;
            this[s_has] = unsupport;
            this[s_delete] = unsupport;
            this[s_clear] = function() {}
        }
        function getDict() {
            return {
                    'number': new ScalarDict(),
                    'string': new ScalarDict(),
                    'boolean': new ScalarDict(),
                    'object': new ObjectDict(),
                    'function': new ObjectDict(),
                    'undefined': new UndefinedDict(),
                    'unknown': new UnknownDict()
                };
        }
        if (!global.WeakMap) {
            global.WeakMap = function WeakMap() {
                var dict = getDict();
                this[s_get] = function(key) {
                    return dict[typeof(key)][s_get](key);
                }
                this[s_set] = function(key, value) {
                    dict[typeof(key)][s_set](key, value);
                }
                this[s_has] = function(key) {
                    return dict[typeof(key)][s_has](key);
                }
                this[s_delete] = function(key) {
                    return dict[typeof(key)][s_delete](key);
                }
                this[s_clear] = function() {
                    for (var key in dict) dict[key][s_clear]();
                }
            }
        }
        if (!global.Map) {
            global.Map = function Map() {
                var dict = getDict();
                this.size = 0;
                this[s_get] = function(key) {
                    return dict[typeof(key)][s_get](key);
                }
                this[s_set] = function(key, value) {
                    if (!this[s_has](key)) this.size++;
                    dict[typeof(key)][s_set](key, value);
                }
                this[s_has] = function(key) {
                    return dict[typeof(key)][s_has](key);
                }
                this[s_delete] = function(key) {
                    if (this.has(key)) {
                        this.size--;
                        return dict[typeof(key)][s_delete](key);
                    }
                    return false;
                }
                this[s_clear] = function() {
                    for (var key in dict) dict[key][s_clear]();
                    this.size = 0;
                }
            }
        }
    })(this);
}
