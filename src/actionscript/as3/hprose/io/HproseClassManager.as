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
 * hprose class manager for ActionScript 3.0.             *
 *                                                        *
 * LastModified: Nov 24, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

package hprose.io {
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    public final class HproseClassManager {
        private static const classCache1:Dictionary = new Dictionary();
        private static const classCache2:Object = {};

        public static function register(classReference:*, alias:String):void {
            classCache1[classReference] = alias;
            classCache2[alias] = classReference;
        }

        public static function getClassAlias(o:*):String {
            var classReference:* = o.constructor;
            var alias:String = classCache1[classReference];
            if (alias) {
                return alias;
            }
            alias = getQualifiedClassName(o);
            if (alias == 'Object') {
                if (o.getClassName) {
                    alias = o.getClassName();
                }
            }
            if (alias == 'flash.utils::Dictionary') {
                alias = 'Object';
            }
            alias = alias.replace(/\./g, '_').replace(/\:\:/g, '_');
            HproseClassManager.register(classReference, alias);
            return alias;
        }

        private static function findClass(cn:Array, poslist:Array, i:uint, c:String):Class {
            if (i < poslist.length) {
                var pos:uint = poslist[i];
                cn[pos] = c;
                var classReference:Class = findClass(cn, poslist, i + 1, '.');
                if (i + 1 < poslist.length) {
                    if (classReference == null) {
                        classReference = findClass(cn, poslist, i + 1, '_');
                    }
                }
                return classReference;
            }
            var alias:String = cn.join('');
            try {
                return getDefinitionByName(alias) as Class;
            }
            catch (e:ReferenceError) {};
            return null;
        }

        public static function getClass(alias:String):* {
            var classReference:* = classCache2[alias];
            if (classReference) {
                return classReference;
            }
            try {
                classReference = getDefinitionByName(alias) as Class;
                register(classReference, alias);
                return classReference;
            }
            catch (e:ReferenceError) {}
            var poslist:Array = [];
            var pos:int = alias.indexOf("_");
            while (pos > -1) {
                poslist[poslist.length] = pos;
                pos = alias.indexOf("_", pos + 1);
            }
            if (poslist.length > 0) {
                var cn:Array = alias.split('');
                classReference = findClass(cn, poslist, 0, '.');
                if (classReference == null) {
                    classReference = findClass(cn, poslist, 0, '_');
                }
            }
            if (classReference == null) {
                classReference = function ():void {
                    this.getClassName = function ():String {
                        return alias;
                    }
                }
            }
            register(classReference, alias);
            return classReference;
        }
    }
}