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
 * class_manager.dart                                     *
 *                                                        *
 * hprose class manager for Dart.                         *
 *                                                        *
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose;

abstract class HproseClassManager {
  static final Map<ClassMirror, String> aliasCache = new Map<ClassMirror, String>();
  static final Map<String, ClassMirror> classCache = new Map<String, ClassMirror>();

  static void register(ClassMirror cm, String alias) {
    aliasCache[cm] = alias;
    classCache[alias] = cm;
  }

  static String getClassAlias(ClassMirror cm) {
    return aliasCache[cm];
  }

  static ClassMirror getClass(String alias) {
    return classCache[alias];
  }
}