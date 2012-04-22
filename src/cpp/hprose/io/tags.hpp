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
 * tags.hpp                                               *
 *                                                        *
 * hprose tags unit for cpp.                              *
 *                                                        *
 * LastModified: Jul 13, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_TAGS_INCLUDED
#define HPROSE_TAGS_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <string>

namespace hprose
{
    /* Serialize Tags */
    const char TagInteger     = 'i';
    const char TagLong        = 'l';
    const char TagDouble      = 'd';
    const char TagNull        = 'n';
    const char TagEmpty       = 'e';
    const char TagTrue        = 't';
    const char TagFalse       = 'f';
    const char TagNaN         = 'N';
    const char TagInfinity    = 'I';
    const char TagDate        = 'D';
    const char TagTime        = 'T';
    const char TagUTC         = 'Z';
    const char TagBytes       = 'b';
    const char TagUTF8Char    = 'u';
    const char TagString      = 's';
    const char TagGuid        = 'g';  
    const char TagList        = 'a';
    const char TagMap         = 'm';
    const char TagClass       = 'c';
    const char TagObject      = 'o';
    const char TagRef         = 'r';
    /* Serialize Marks */
    const char TagPos         = '+';
    const char TagNeg         = '-';
    const char TagSemicolon   = ';';
    const char TagOpenbrace   = '{';
    const char TagClosebrace  = '}';
    const char TagQuote       = '"';
    const char TagPoint       = '.';
    /* Protocol Tags */
    const char TagFunctions   = 'F';
    const char TagCall        = 'C';
    const char TagResult      = 'R';
    const char TagArgument    = 'A';
    const char TagError       = 'E';
    const char TagEnd         = 'z';

    /* Tags Composition */
    const char BoolTags[2]     = {TagTrue, TagFalse};
    const char LongTags[2]     = {TagInteger, TagLong};
    const char DoubleTags[5]   = {TagInteger, TagLong, TagDouble, TagNaN, TagInfinity};
    const char DateTags[2]     = {TagDate, TagRef};
    const char TimeTags[2]     = {TagTime, TagRef};
    const char DateTimeTags[3] = {TagDate, TagTime, TagRef};
    const char BytesTags[2]    = {TagBytes, TagRef};
    const char StringTags[2]   = {TagString, TagRef};
    const char ListTags[2]     = {TagList, TagRef};
    const char MapTags[2]      = {TagMap, TagRef};
    const char ObjectTags[3]   = {TagClass, TagObject, TagRef};
    const char ResultTags[4]   = {TagResult, TagArgument, TagError, TagEnd};
    
    inline std::string TagToString(char tag)
    {
        switch (tag)
        {
            case TagInteger:
                return "int";
            case TagLong:
                return "long";
            case TagDouble:
                return "double";
            case TagNull:
                return "null";
            case TagEmpty:
                return "empty";
            case TagTrue:
            case TagFalse:
                return "bool";
            case TagNaN:
                return "nan";
            case TagInfinity:
                return "infinity";
            case TagDate:
                return "date";
            case TagTime:
                return "time";
            case TagBytes:
                return "bytes";
            case TagUTF8Char:
                return "char";
            case TagString:
                return "string";
            case TagList:
                return "list";
            case TagMap:
                return "map";
            case TagClass:
                return "class";
            case TagObject:
                return "object";
            case TagRef:
                return "refrence";
            default:
                return "";
        }
    }

} // namespace hprose

#endif
