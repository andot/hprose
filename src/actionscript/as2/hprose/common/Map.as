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
 * Map.as                                                 *
 *                                                        *
 * Harmony Map for ActionScript 2.0.                      *
 *                                                        *
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

class hprose.common.Map {
    private static var namespaces:Object = {};
    private static var count:Number = 0;
    private static function reDefineValueOf(obj) {
        var privates:Object = {};
        var baseValueOf:Function = obj.valueOf;
        obj.valueOf = function(ns, n) {
            if ((this === obj) &&
                (namespaces.hasOwnProperty(n)) &&
                (namespaces[n] === ns)) {
                    if (!(privates.hasOwnProperty(n))) privates[n] = {};
                    return privates[n];
            }
            else {
                baseValueOf.apply(this, arguments);
            }
        }
    }
    private static function ObjectMap() {
        var ns:Object = {};
        var n:Number = count++;
        var nullMap:Object = {};
        namespaces[n] = ns;
        var map:Function = function(key) {
            if (key === null) return nullMap;
            var privates = key.valueOf(ns, n);
            if (privates !== key.valueOf()) return privates;
            reDefineValueOf(key);
            return key.valueOf(ns, n);
        };
		return {
            get: function(key) { return map(key).value; },
            set: function(key, value) { map(key).value = value; },
            has: function(key) { return map(key).hasOwnProperty('value'); },
            remove: function(key) { return delete map(key).value; },
            clear: function() {
                delete namespaces[n];
                n = count++;
                namespaces[n] = ns;
            }
		}
    }
    private static function ScalarMap() {
        var map = {};
		return {
            get: function(key) { return map[key]; },
            set: function(key, value) { map[key] = value; },
            has: function(key) { return map.hasOwnProperty(key); },
            remove: function(key) { return delete map[key]; },
            clear: function() { map = {}; }
		}
    }
    private static function StringMap() {
        var map = {};
		return {
            get: function(key) { return map['str_' + key]; },
            set: function(key, value) { map['str_' + key] = value; },
            has: function(key) { return map.hasOwnProperty('str_' + key); },
            remove: function(key) { return delete map['str_' + key]; },
            clear: function() { map = {}; }
		}
    }
    private static function NoKeyMap() {
        var map = {};
		return {
            get: function(key) { return map.value; },
            set: function(key, value) { map.value = value; },
            has: function(key) { return map.hasOwnProperty('value'); },
            remove: function(key) { return delete map.value; },
            clear: function() { map = {}; }
		}
    }

    private var map:Object;
    private var m_size:Number;

    public function Map() {
        map = {};
		map['number'] = ScalarMap();
        map['boolean'] = ScalarMap();
        map['string'] = StringMap();
        map['object'] = ObjectMap();
        map['function'] = ObjectMap();
        map['movieclip'] = ObjectMap();
        map['undefined'] = NoKeyMap();
    }
    public function get size():Number {
        return m_size;
    }
    public function get(key) {
        return map[typeof(key)].get(key);
    }
    public function set(key, value) {
        if (!this.has(key)) m_size++;
        map[typeof(key)].set(key, value);
    }
    public function has(key) {
        return map[typeof(key)].has(key);
    }
    public function remove(key) {
        if (this.has(key)) {
            m_size--;
            return map[typeof(key)].remove(key);
        }
        return false;
    }
    public function clear(key) {
        for (var key in map) map[key].clear();
        m_size = 0;
    }
}
