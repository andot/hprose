/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * exception.dart                                         *
 *                                                        *
 * hprose exception for Dart.                             *
 *                                                        *
 * LastModified: Feb 5, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose;

class HproseException implements Exception {
  final String message;

  const HproseException(this.message);

  String toString() => "HproseException: $message";
}

class IOException implements Exception {
  final String message;

  const IOException(this.message);

  String toString() => "IOException: $message";
}