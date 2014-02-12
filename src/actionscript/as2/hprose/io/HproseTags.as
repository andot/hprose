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
 * hprose tags enum for ActionScript 2.0.                 *
 *                                                        *
 * LastModified: Jul 30, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
class hprose.io.HproseTags {
    /* Serialize Tags */
    public static var TagInteger:String = 'i';
    public static var TagLong:String = 'l';
    public static var TagDouble:String = 'd';
    public static var TagNull:String = 'n';
    public static var TagEmpty:String = 'e';
    public static var TagTrue:String = 't';
    public static var TagFalse:String = 'f';
    public static var TagNaN:String = 'N';
    public static var TagInfinity:String = 'I';
    public static var TagDate:String = 'D';
    public static var TagTime:String = 'T';
    public static var TagUTC:String = 'Z';
/*  public static var TagBytes:String = 'b'; */ // Not support bytes in ActionScript 2.0.
    public static var TagUTF8Char:String = 'u';
    public static var TagString:String = 's';
    public static var TagGuid:String = 'g';
    public static var TagList:String = 'a';
    public static var TagMap:String = 'm';
    public static var TagClass:String = 'c';
    public static var TagObject:String = 'o';
    public static var TagRef:String = 'r';
    /* Serialize Marks */
    public static var TagPos:String = '+';
    public static var TagNeg:String = '-';
    public static var TagSemicolon:String = ';';
    public static var TagOpenbrace:String = '{';
    public static var TagClosebrace:String = '}';
    public static var TagQuote:String = '"';
    public static var TagPoint:String = '.';
    /* Protocol Tags */
    public static var TagFunctions:String = 'F';
    public static var TagCall:String = 'C';
    public static var TagResult:String = 'R';
    public static var TagArgument:String = 'A';
    public static var TagError:String = 'E';
    public static var TagEnd:String = 'z';
}