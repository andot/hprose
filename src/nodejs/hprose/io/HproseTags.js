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
 * HproseTags.js                                          *
 *                                                        *
 * HproseTags for Node.js.                                *
 *                                                        *
 * LastModified: Oct 24, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseTags = {
    /* Serialize Tags */
    TagInteger: 'i'.charCodeAt(0),
    TagLong: 'l'.charCodeAt(0),
    TagDouble: 'd'.charCodeAt(0),
    TagNull: 'n'.charCodeAt(0),
    TagEmpty: 'e'.charCodeAt(0),
    TagTrue: 't'.charCodeAt(0),
    TagFalse: 'f'.charCodeAt(0),
    TagNaN: 'N'.charCodeAt(0),
    TagInfinity: 'I'.charCodeAt(0),
    TagDate: 'D'.charCodeAt(0),
    TagTime: 'T'.charCodeAt(0),
    TagUTC: 'Z'.charCodeAt(0),
    TagBytes: 'b'.charCodeAt(0),
    TagUTF8Char: 'u'.charCodeAt(0),
    TagString: 's'.charCodeAt(0),
    TagGuid: 'g'.charCodeAt(0),
    TagList: 'a'.charCodeAt(0),
    TagMap: 'm'.charCodeAt(0),
    TagClass: 'c'.charCodeAt(0),
    TagObject: 'o'.charCodeAt(0),
    TagRef: 'r'.charCodeAt(0),
    /* Serialize Marks */
    TagPos: '+'.charCodeAt(0),
    TagNeg: '-'.charCodeAt(0),
    TagSemicolon: ';'.charCodeAt(0),
    TagOpenbrace: '{'.charCodeAt(0),
    TagClosebrace: '}'.charCodeAt(0),
    TagQuote: '"'.charCodeAt(0),
    TagPoint: '.'.charCodeAt(0),
    /* Protocol Tags */
    TagFunctions: 'F'.charCodeAt(0),
    TagCall: 'C'.charCodeAt(0),
    TagResult: 'R'.charCodeAt(0),
    TagArgument: 'A'.charCodeAt(0),
    TagError: 'E'.charCodeAt(0),
    TagEnd: 'z'.charCodeAt(0)
}

module.exports = HproseTags;