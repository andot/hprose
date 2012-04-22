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
 * ClassManager.as                                        *
 *                                                        *
 * hprose ClassManager for ActionScript 3.0.              *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

package hprose.io {
    public final class ClassManager {
        private static const classCache1:Object = {};
        private static const classCache2:Object = {};
        
        public static function register(classReference:*, alias:String):void {
            classCache1[classReference] = alias;
            classCache2[alias] = classReference;
        }

        public static function getClassAlias(classReference:*):String {
            return classCache1[classReference];
        }

        public static function getClass(alias:String):* {
            return classCache2[alias];
        } 
    }
}