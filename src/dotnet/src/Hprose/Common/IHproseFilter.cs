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
 * IHproseFilter.cs                                       *
 *                                                        *
 * hprose filter interface for C#.                        *
 *                                                        *
 * LastModified: Nov 27, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System.IO;

namespace Hprose.Common {
    public interface IHproseFilter {
        Stream InputFilter(Stream inStream);
        Stream OutputFilter(Stream outStream);
    }
}