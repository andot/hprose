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
 * HproseTags.as                                          *
 *                                                        *
 * hprose tags enum for ActionScript 3.0.                 *
 *                                                        *
 * LastModified: Jul 31, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.io {
    public final class HproseTags {
        /* Serialize Tags */
        public static const TagInteger:int = 'i'.charCodeAt(0);
        public static const TagLong:int = 'l'.charCodeAt(0);
        public static const TagDouble:int = 'd'.charCodeAt(0);
        public static const TagNull:int = 'n'.charCodeAt(0);
        public static const TagEmpty:int = 'e'.charCodeAt(0);
        public static const TagTrue:int = 't'.charCodeAt(0);
        public static const TagFalse:int = 'f'.charCodeAt(0);
        public static const TagNaN:int = 'N'.charCodeAt(0);
        public static const TagInfinity:int = 'I'.charCodeAt(0);
        public static const TagDate:int = 'D'.charCodeAt(0);
        public static const TagTime:int = 'T'.charCodeAt(0);
        public static const TagUTC:int = 'Z'.charCodeAt(0);
        public static const TagBytes:int = 'b'.charCodeAt(0);
        public static const TagUTF8Char:int = 'u'.charCodeAt(0);
        public static const TagString:int = 's'.charCodeAt(0);
        public static const TagGuid:int = 'g'.charCodeAt(0);
        public static const TagList:int = 'a'.charCodeAt(0);
        public static const TagMap:int = 'm'.charCodeAt(0);
        public static const TagClass:int = 'c'.charCodeAt(0);
        public static const TagObject:int = 'o'.charCodeAt(0);
        public static const TagRef:int = 'r'.charCodeAt(0);
        /* Serialize Marks */
        public static const TagPos:int = '+'.charCodeAt(0);
        public static const TagNeg:int = '-'.charCodeAt(0);
        public static const TagSemicolon:int = ';'.charCodeAt(0);
        public static const TagOpenbrace:int = '{'.charCodeAt(0);
        public static const TagClosebrace:int = '}'.charCodeAt(0);
        public static const TagQuote:int = '"'.charCodeAt(0);
        public static const TagPoint:int = '.'.charCodeAt(0);
        /* Protocol Tags */
        public static const TagFunctions:int = 'F'.charCodeAt(0);
        public static const TagCall:int = 'C'.charCodeAt(0);
        public static const TagResult:int = 'R'.charCodeAt(0);
        public static const TagArgument:int = 'A'.charCodeAt(0);
        public static const TagError:int = 'E'.charCodeAt(0);
        public static const TagEnd:int = 'z'.charCodeAt(0);
    }
}