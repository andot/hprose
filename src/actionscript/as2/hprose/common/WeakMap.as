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
 * WeakMap.as                                             *
 *                                                        *
 * Harmony WeakMap for ActionScript 2.0.                  *
 *                                                        *
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

class hprose.common.WeakMap {
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
    private var ns:Object;
    private var n:Number;
    private function map(key) {
        if (key !== Object(key)) throw new Error("value is not a non-null object");
        var privates = key.valueOf(ns, n);
        if (privates !== key.valueOf()) return privates;
        reDefineValueOf(key);
        return key.valueOf(ns, n);
    }
    public function WeakMap() {
        ns = {};
        n = count++;
        namespaces[n] = ns;
    }
    public function get(key) {
        return map(key).value;
    }
    public function set(key, value) {
        map(key).value = value;
    }
    public function has(key) {
        return map(key).hasOwnProperty('value');
    }
    public function remove(key) {
        return delete map(key).value;
    }
    public function clear(key) {
        delete namespaces[n];
        n = count++;
        namespaces[n] = ns;
    }
}
