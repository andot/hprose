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
 * HproseTags.cs                                          *
 *                                                        *
 * hprose tags class for C#.                              *
 *                                                        *
 * LastModified: Jul 12, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
using System;

namespace Hprose.IO {
    public sealed class HproseTags {
        /* Serialize Tags */
        public const int TagInteger = 'i';
        public const int TagLong = 'l';
        public const int TagDouble = 'd';
        public const int TagNull = 'n';
        public const int TagEmpty = 'e';
        public const int TagTrue = 't';
        public const int TagFalse = 'f';
        public const int TagNaN = 'N';
        public const int TagInfinity = 'I';
        public const int TagDate = 'D';
        public const int TagTime = 'T';
        public const int TagUTC = 'Z';
        public const int TagBytes = 'b';
        public const int TagUTF8Char = 'u';
        public const int TagString = 's';
        public const int TagGuid = 'g';
        public const int TagList = 'a';
        public const int TagMap = 'm';
        public const int TagClass = 'c';
        public const int TagObject = 'o';
        public const int TagRef = 'r';
        /* Serialize Marks */
        public const int TagPos = '+';
        public const int TagNeg = '-';
        public const int TagSemicolon = ';';
        public const int TagOpenbrace = '{';
        public const int TagClosebrace = '}';
        public const int TagQuote = '"';
        public const int TagPoint = '.';
        /* Protocol Tags */
        public const int TagFunctions = 'F';
        public const int TagCall = 'C';
        public const int TagResult = 'R';
        public const int TagArgument = 'A';
        public const int TagError = 'E';
        public const int TagEnd = 'z';
    }
}