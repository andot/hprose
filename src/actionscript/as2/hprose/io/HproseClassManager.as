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
 * HproseClassManager.as                                  *
 *                                                        *
 * hprose ClassManager for ActionScript 2.0.              *
 *                                                        *
 * LastModified: Nov 19, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

import hprose.common.WeakMap;

class hprose.io.HproseClassManager {
    private static var classCache:Object = {};
    private static var aliasCache:WeakMap = new WeakMap();

    public static function register(cls, alias:String) {
        aliasCache.set(cls, alias);
        classCache[alias] = cls;
    }

    public static function getClassAlias(obj):String {
        var cls = obj.constructor;
        var alias:String = aliasCache.get(cls);
        if (alias) return alias;
        alias = ((typeof(obj.getClassName) == 'function') ? obj.getClassName() : "Object");
        register(cls, alias);
        return alias;
    }

    private static function findClass(cn:Array, poslist:Array, i:Number, c:String):Function {
        if (i < poslist.length) {
            var pos:Number = poslist[i];
            cn[pos] = c;
            var cls:Function = findClass(cn, poslist, i + 1, '.');
            if (i + 1 < poslist.length) {
                if (cls == null) {
                    cls = findClass(cn, poslist, i + 1, '_');
                }
            }
            return cls;
        }
        return eval(cn.join(''));
    }

    public static function getClass(alias:String) {
        var cls = classCache[alias];
        if (cls) return cls;
        cls = eval(alias);
        if (cls) {
            register(cls, alias);
            return cls;
        }
        var poslist:Array = [];
        var pos:Number = alias.indexOf("_");
        while (pos > -1) {
            poslist[poslist.length] = pos;
            pos = alias.indexOf("_", pos + 1);
        }
        if (poslist.length > 0) {
            var cn:Array = alias.split('');
            cls = findClass(cn, poslist, 0, '.');
            if (cls == null) {
                cls = findClass(cn, poslist, 0, '_');
            }
        }
        if (cls == null) {
            cls = function () {
                this.getClassName = function():String {
                    return alias;
                }
            }
        }
        register(cls, alias);
        return cls;
    }
}