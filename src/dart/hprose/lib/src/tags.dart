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
 * tags.dart                                              *
 *                                                        *
 * hprose tags enum for Dart.                             *
 *                                                        *
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
part of hprose;

  /* Serialize Tags */
const int TagInteger     = 0x69; //  'i'
const int TagLong        = 0x6C; //  'l'
const int TagDouble      = 0x64; //  'd'
const int TagNull        = 0x6E; //  'n'
const int TagEmpty       = 0x65; //  'e'
const int TagTrue        = 0x74; //  't'
const int TagFalse       = 0x66; //  'f'
const int TagNaN         = 0x4E; //  'N'
const int TagInfinity    = 0x49; //  'I'
const int TagDate        = 0x44; //  'D'
const int TagTime        = 0x54; //  'T'
const int TagUTC         = 0x5A; //  'Z'
const int TagBytes       = 0x62; //  'b'
const int TagUTF8Char    = 0x75; //  'u'
const int TagString      = 0x73; //  's'
const int TagGuid        = 0x67; //  'g'
const int TagList        = 0x61; //  'a'
const int TagMap         = 0x6d; //  'm'
const int TagClass       = 0x63;//   'c'
const int TagObject      = 0x6F; //  'o'
const int TagRef         = 0x72; //  'r'
/* Serialize Marks */
const int TagPos         = 0x2B; //  '+'
const int TagNeg         = 0x2D; //  '-'
const int TagSemicolon   = 0x3B; //  ';'
const int TagOpenbrace   = 0x7B; //  '{'
const int TagClosebrace  = 0x7D; //  '}'
const int TagQuote       = 0x22; //  '"'
const int TagPoint       = 0x2E; //  '.'
/* Protocol Tags */
const int TagFunctions   = 0x46; //  'F'
const int TagCall        = 0x43; //  'C'
const int TagResult      = 0x52; //  'R'
const int TagArgument    = 0x41; //  'A'
const int TagError       = 0x45; //  'E'
const int TagEnd         = 0x7A; //  'z'
