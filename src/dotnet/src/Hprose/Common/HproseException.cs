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
 * HproseException.cs                                     *
 *                                                        *
 * hprose exception class for C#.                         *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;
using System.IO;

namespace Hprose.Common {
    public class HproseException : IOException {
        public HproseException()
            : base() {
        }
        public HproseException(string message)
            : base(message) {
        }
        public HproseException(string message, Exception innerException)
            : base(message, innerException) {
        }
    }
}