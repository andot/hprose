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
 * utf8.hpp                                               *
 *                                                        *
 * hprose utf8 unit for cpp.                              *
 *                                                        *
 * LastModified: Jun 5, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_UTF8_INCLUDED
#define HPROSE_UTF8_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/config.hpp>
#include <hprose/common/exception.hpp>

#ifdef BOOST_WINDOWS
#ifndef _WINDOWS_

// Don't include winsock.h
#ifndef _WINSOCKAPI_
#define _WINSOCKAPI_
#else
#define _WINSOCKAPI_EXIST
#endif

#include <windows.h>

#ifndef _WINSOCKAPI_EXIST
#undef  _WINSOCKAPI_
#endif

#endif
#endif

namespace hprose
{
    template<int v>
    struct UTFType
    {
        BOOST_STATIC_CONSTANT(int, value = v);
    };

    typedef UTFType<2> UTF16Type;
    typedef UTFType<4> UTF32Type;

    inline bool is_ascii(char c) { return (c & 0x80) == 0x00; }

    inline bool is_inseq(char c) { return (c & 0xc0) == 0x80; }

    inline bool is_2byte(char c) { return (c & 0xe0) == 0xc0; }

    inline bool is_3byte(char c) { return (c & 0xf0) == 0xe0; }

    inline bool is_4byte(char c) { return (c & 0xf8) == 0xf0; }

    inline bool is_5byte(char c) { return (c & 0xFC) == 0xF8; }

    inline bool is_6byte(char c) { return (c & 0xFE) == 0xFC; }

    template<typename InputIterator>
    size_t utf8_size(InputIterator first, InputIterator last, UTF16Type)
    {
        size_t len = 0;
        for (; first < last; ++first)
        {
            unsigned int c = *first;
            if (c < 0x80) // U+0000 - U+007F
            {
                len += 1;
            }
            else if (c < 0x0800) // U+0100 - U+07FF
            {
                len += 2;
            }
            else if (0xd800 != (0xf800 & c)) // U+0800 - U+D7FF, U+E000 - U+FFFF
            {
                len += 3;
            }
            else if (c < 0xdc00) // U+D800 - U+DBFF
            {
                ++first;
                if (first == last)
                {
                    HPROSE_THROW_EXCEPTION("Surrogate pair split between fragments");
                }
                c = *first;
                if (0xdc00 == (0xfc00 & c))
                {
                    len += 4;
                }
                else
                {
                    HPROSE_THROW_EXCEPTION("Got a high Surrogate but no low surrogate");
                }
            }
            else // U+DC00 - U+DFFF
            {
                HPROSE_THROW_EXCEPTION("got a low Surrogate but no high surrogate");
            }
        }
        return len;
    }

    template<typename InputIterator>
    size_t utf8_size(InputIterator first, InputIterator last, UTF32Type)
    {
        size_t len = 0;
        for (; first < last; ++first)
        {
            unsigned int c = *first;
            if (c < 0x80) // U+0000 - U+007F
            {
                len += 1;
            }
            else if (c < 0x0800) // U+0100 - U+07FF
            {
                len += 2;
            }
            else if (c < 0xd800) // U+0800 - U+D7FF
            {
                len += 3;
            }
            else if (c < 0xe000) // U+D800 - U+DFFF
            {
                HPROSE_THROW_EXCEPTION("Surrogate values are illegal");
            }
            else if (c < 0x10000) // U+E000 - U+FFFF
            {
                len += 3;
            }
            else if (c <  0x0010ffff)
            {
                len += 4;
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Not a UTF-32 string");
            }
        }
        return len;
    }

    template<typename Element, typename Traits, typename Allocator>
    inline size_t utf8_size(const std::basic_string<Element, Traits, Allocator> & data)
    {
        HPROSE_STATIC_ASSERT((sizeof(Element) == 2) || (sizeof(Element) == 4), "Require Unicode String");
        return utf8_size(data.begin(), data.end(), UTFType<sizeof(Element)>());
    }

    template<typename InputIterator>
    size_t utf8_length(InputIterator first, InputIterator last, UTF16Type)
    {
        size_t len = 0;
        for (; first < last; ++len)
        {
            if (is_ascii(*first))
            {
                first += 1;
            }
            else if (is_2byte(*first))
            {
                first+= 2;
            }
            else if (is_3byte(*first))
            {
                first += 3;
            }
            else if (is_4byte(*first))
            {
                first += 4;
                ++len;
            }
            else if (is_5byte(*first))
            {
                first += 5;
            }
            else if (is_6byte(*first))
            {
                first += 6;
            }
            else
            {
                break;
            }
        }
        if (first != last)
        {
            HPROSE_THROW_EXCEPTION("Not a UTF-8 string");
        }
        return len;
    }

    template<typename InputIterator>
    size_t utf8_length(InputIterator first, InputIterator last, UTF32Type)
    {
        size_t len = 0;
        for (; first < last; ++len)
        {
            if (is_ascii(*first))
            {
                first += 1;
            }
            else if (is_2byte(*first))
            {
                first+= 2;
            }
            else if (is_3byte(*first))
            {
                first += 3;
            }
            else if (is_4byte(*first))
            {
                first += 4;
            }
            else if (is_5byte(*first))
            {
                first += 5;
            }
            else if (is_6byte(*first))
            {
                first += 6;
            }
            else
            {
                break;
            }
        }
        if (first != last)
        {
            HPROSE_THROW_EXCEPTION("Not a UTF-8 string");
        }
        return len;
    }

    template<typename ValueType, typename OutputIterator>
    inline size_t utf8_encode(ValueType c, OutputIterator dest, UTF16Type)
    {
        OutputIterator start = dest;
        if (c < 0x80) // U+0000 - U+007F
        {
            *dest++ = (char)c;
        }
        else if (c < 0x0800) // U+0100 - U+07FF
        {
            *dest++ = 0xc0 | (char)(c >> 6);
            *dest++ = 0x80 | (char)(c & 0x3f);
        }
        else if (0xd800 != (0xf800 & c)) // U+0800 - U+D7FF, U+E000 - U+FFFF
        {
            *dest++ = 0xe0 | (char)(c >> 12);
            *dest++ = 0x80 | (char)(0x3f & (c >> 6));
            *dest++ = 0x80 | (char)(0x3f & c);
        }
        return dest - start;
    }

    template<typename ValueType, typename OutputIterator>
    inline size_t utf8_encode(ValueType c, OutputIterator dest, UTF32Type)
    {
        OutputIterator start = dest;
        if (c < 0x80) // U+0000 - U+007F
        {
            *dest++ = (char)c;
        }
        else if (c < 0x0800) // U+0100 - U+07FF
        {
            *dest++ = 0xc0 | (char)(c >> 6);
            *dest++ = 0x80 | (char)(c & 0x3f);
        }
        else if (c < 0xd800 || (c >= 0xe000 && c <=0xffff)) // U+0800 - U+D7FF, U+E000 - U+FFFF
        {
            *dest++ = 0xe0 | (char)(c >> 12);
            *dest++ = 0x80 | (char)(0x3f & (c >> 6));
            *dest++ = 0x80 | (char)(0x3f & c);
        }
        else if (c > 0xffff && c < 0x0010ffff) // 0001 0000-001F FFFF
        {
            *dest++ = 0xf0 | (char)(c >> 18);
            *dest++ = 0x80 | (char)(0x3f & (c >> 12));
            *dest++ = 0x80 | (char)(0x3f & (c >> 6));
            *dest++ = 0x80 | (char)(0x3f & c);
        }
        return dest - start;
    }

    template<typename InputIterator, typename OutputIterator>
    void utf8_encode(InputIterator first, InputIterator last, OutputIterator dest, UTF16Type)
    {
        while (first != last)
        {
            unsigned int c = *first++;
            if (size_t len = utf8_encode(c, dest, UTF16Type()))
            {
                dest += len;
                continue;
            }
            if (c < 0xdc00) // U+D800 - U+DBFF
            {
                if (first != last)
                {
                    unsigned int ucs4 = 0x10000 + ((0x03ff & c) << 10);
                    c = *first++;
                    if (0xdc00 == (0xfc00 & c)) // 0001 0000-001F FFFF
                    {
                        ucs4 |= (0x03ff & c);
                        *dest++ = 0xf0 | (char)(ucs4 >> 18);
                        *dest++ = 0x80 | (char)(0x3f & (ucs4 >> 12));
                        *dest++ = 0x80 | (char)(0x3f & (ucs4 >> 6));
                        *dest++ = 0x80 | (char)(0x3f & ucs4);
                    }
                    else
                    {
                        HPROSE_THROW_EXCEPTION("Got a high surrogate but no low surrogate");
                    }
                }
                else
                {
                    HPROSE_THROW_EXCEPTION("Surrogate pair split between fragments");
                }
            }
            else // U+DC00 - U+DFFF
            {
                HPROSE_THROW_EXCEPTION("Got a low surrogate but no high surrogate");
            }
        }
    }

    template<typename InputIterator, typename OutputIterator>
    void utf8_encode(InputIterator first, InputIterator last, OutputIterator dest, UTF32Type)
    {
        while (first != last)
        {
            unsigned int c = *first++;
            if (size_t len = utf8_encode(c, dest, UTF32Type()))
            {
                dest += len;
                continue;
            }
            if (c >= 0xd800 && c <= 0xdfff) // U+D800 - U+DFFF
            {
                HPROSE_THROW_EXCEPTION("Surrogate values are illegal");
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Not a UTF-32 string");
            }
        }
    }

    template<typename Element, typename Traits, typename Allocator>
    inline std::string utf8_encode(const std::basic_string<Element, Traits, Allocator> & data)
    {
        HPROSE_STATIC_ASSERT((sizeof(Element) == 2) || (sizeof(Element) == 4), "Require Unicode String");
        std::string ret;
        ret.resize(utf8_size(data));
        utf8_encode(data.begin(), data.end(), ret.begin(), UTFType<sizeof(Element)>());
        return ret;
    }

    template<typename InputIterator>
    unsigned short utf8_decode(InputIterator & first, UTF16Type)
    {
        char c = *first++;
        if (is_ascii(c))
        {
            return c;
        }
        unsigned int ucs4, min_ucs4;
        size_t state = 0;
        if (is_2byte(c))
        {
            ucs4 = ((unsigned int)c << 6) & 0x000007c0L;
            state = 1;
            min_ucs4 = 0x00000080;
        }
        else if (is_3byte(c))
        {
            ucs4 = ((unsigned int)c << 12) & 0x0000f000L;
            state = 2;
            min_ucs4 = 0x00000800;
        }
        else if (is_4byte(c))
        {
            ucs4 = ((unsigned int)c << 18) & 0x001f0000L;
            state = 3;
            min_ucs4 = 0x00010000;
        }
        else if (is_5byte(c))
        {
            ucs4 = ((unsigned int)c << 24) & 0x03000000L;
            state = 4;
            min_ucs4 = 0x00200000;
        }
        else if (is_6byte(c))
        {
            ucs4 = ((unsigned int)c << 30) & 0x40000000L;
            state = 5;
            min_ucs4 = 0x04000000;
        }
        else
        {
            HPROSE_THROW_EXCEPTION("Not a UTF-8 char");
        }
        while (state--)
        {
            c = *first++;
            if (is_inseq(c))
            {
                unsigned int shift = state * 6;
                ucs4 |= ((unsigned int)c & 0x3f) << shift;
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Not a UTF-8 char");
            }
        }
        if (ucs4 < min_ucs4)
        {
            return 0xfffd;
        }
        else if (ucs4 <= 0xd7ff)
        {
            return ucs4;
        }
        else if (ucs4 <= 0xdfff)
        {
            return 0xfffd;
        }
        else if (ucs4 == 0xfffe || ucs4 == 0xffff)
        {
            return 0xfffd;
        }
        else if (ucs4 >= 0x00010000)
        {
            return 0xfffd;
        }
        else
        {
            return ucs4;
        }
    }

    template<typename InputIterator>
    unsigned int utf8_decode(InputIterator & first, UTF32Type)
    {
        char c = *first++;
        if (is_ascii(c))
        {
            return c;
        }
        unsigned int ucs4, min_ucs4;
        size_t state = 0;
        if (is_2byte(c))
        {
            ucs4 = ((unsigned int)c << 6) & 0x000007c0L;
            state = 1;
            min_ucs4 = 0x00000080;
        }
        else if (is_3byte(c))
        {
            ucs4 = ((unsigned int)c << 12) & 0x0000f000L;
            state = 2;
            min_ucs4 = 0x00000800;
        }
        else if (is_4byte(c))
        {
            ucs4 = ((unsigned int)c << 18) & 0x001f0000L;
            state = 3;
            min_ucs4 = 0x00010000;
        }
        else if (is_5byte(c))
        {
            ucs4 = ((unsigned int)c << 24) & 0x03000000L;
            state = 4;
            min_ucs4 = 0x00200000;
        }
        else if (is_6byte(c))
        {
            ucs4 = ((unsigned int)c << 30) & 0x40000000L;
            state = 5;
            min_ucs4 = 0x04000000;
        }
        else
        {
            HPROSE_THROW_EXCEPTION("Not a UTF-8 char");
        }
        while (state--)
        {
            c = *first++;
            if (is_inseq(c))
            {
                unsigned int shift = state * 6;
                ucs4 |= ((unsigned int)c & 0x3f) << shift;
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Not a UTF-8 char");
            }
        }
        if (ucs4 < min_ucs4)
        {
            return 0xfffd;
        }
        else if (ucs4 <= 0xd7ff)
        {
            return ucs4;
        }
        else if (ucs4 <= 0xdfff)
        {
            return 0xfffd;
        }
        else if (ucs4 == 0xfffe || ucs4 == 0xffff)
        {
            return 0xfffd;
        }
        else if (ucs4 >= 0x00110000)
        {
            return 0xfffd;
        }
        else
        {
            return ucs4;
        }
    }

    template<typename InputIterator, typename OutputIterator>
    void utf8_decode(InputIterator first, InputIterator last, OutputIterator dest, UTF16Type)
    {
        while (first != last)
        {
            char c = *first++;
            if (is_ascii(c))
            {
                *dest++ = c;
                continue;
            }
            unsigned int ucs4, min_ucs4;
            size_t state = 0;
            if (is_2byte(c))
            {
                ucs4 = ((unsigned int)c << 6) & 0x000007c0L;
                state = 1;
                min_ucs4 = 0x00000080;
            }
            else if (is_3byte(c))
            {
                ucs4 = ((unsigned int)c << 12) & 0x0000f000L;
                state = 2;
                min_ucs4 = 0x00000800;
            }
            else if (is_4byte(c))
            {
                ucs4 = ((unsigned int)c << 18) & 0x001f0000L;
                state = 3;
                min_ucs4 = 0x00010000;
            }
            else if (is_5byte(c))
            {
                ucs4 = ((unsigned int)c << 24) & 0x03000000L;
                state = 4;
                min_ucs4 = 0x00200000;
            }
            else if (is_6byte(c))
            {
                ucs4 = ((unsigned int)c << 30) & 0x40000000L;
                state = 5;
                min_ucs4 = 0x04000000;
            }
            else
            {
                HPROSE_THROW_EXCEPTION("Not a UTF-8 char");
            }
            while (state--)
            {
                c = *first++;
                if (is_inseq(c))
                {
                    unsigned int shift = state * 6;
                    ucs4 |= ((unsigned int)c & 0x3f) << shift;
                }
                else
                {
                    HPROSE_THROW_EXCEPTION("Not a UTF-8 char");
                }
            }
            if (ucs4 < min_ucs4)
            {
                *dest++ = 0xfffd;
            }
            else if (ucs4 <= 0xd7ff)
            {
                *dest++ = ucs4;
            }
            else if (ucs4 <= 0xdfff)
            {
                *dest++ = 0xfffd;
            }
            else if (ucs4 == 0xfffe || ucs4 == 0xffff)
            {
                *dest++ = 0xfffd;
            }
            else if (ucs4 >= 0x00010000)
            {
                if (ucs4 >= 0x00110000)
                {
                    *dest++ = 0xfffd;
                }
                else
                {
                    ucs4 -= 0x00010000;
                    *dest++ = (ucs4 >> 10) | 0xd800u;
                    *dest++ = (ucs4 & 0x3ff) | 0xdc00u;
                }
            }
            else
            {
                *dest++ = ucs4;
            }
        }
    }

    template<typename InputIterator, typename OutputIterator>
    inline void utf8_decode(InputIterator first, InputIterator last, OutputIterator dest, UTF32Type)
    {
        while (first != last)
        {
            *dest++ = utf8_decode(first, UTF32Type());
        }
    }

    template<typename InputIterator>
    inline size_t utf16_size(InputIterator first, InputIterator last, UTF16Type)
    {
        return last - first;
    }

    template<typename InputIterator>
    inline size_t utf16_size(InputIterator first, InputIterator last, UTF32Type)
    {
        size_t size = 0;
        for (; first < last; ++size, ++first)
        {
            if (*first >= 0x10000 && *first < 0x110000)
            {
                ++size;
            }
        }
        return size;
    }

    template<typename Element, typename Traits, typename Allocator>
    inline size_t utf16_size(const std::basic_string<Element, Traits, Allocator> & data)
    {
        HPROSE_STATIC_ASSERT((sizeof(Element) == 2) || (sizeof(Element) == 4), "Require Unicode String");
        return utf16_size(data.begin(), data.end(), UTFType<sizeof(Element)>());
    }

#ifdef BOOST_WINDOWS
    inline wchar_t * ansi_to_unicode(const char * src, size_t src_len, wchar_t * dest)
    {
        if (!dest)
        {
            dest = (wchar_t *)calloc(src_len, sizeof(wchar_t));
        }
        if (dest)
        {
            MultiByteToWideChar(CP_ACP, 0, src, (int)src_len, dest, (int)src_len);
        }
        return dest;
    }

    inline char * unicode_to_ansi(const wchar_t * src, size_t src_len, char * dest)
    {
        if (!dest)
        {
            dest = (char *)calloc(src_len * 2, sizeof(char));
        }
        if (dest)
        {
            WideCharToMultiByte(CP_ACP, 0, src, -1, dest, (int)src_len * 2, NULL, NULL);
        }
        return dest;
    }

    inline std::wstring ansi_to_unicode(const std::string & data)
    {
        if (data.empty())
        {
            return L"";
        }
        wchar_t buf[256];
        size_t len = data.size() + 1;
        wchar_t * s = ansi_to_unicode(data.c_str(), len, (len > 256) ? 0 : buf);
        std::wstring ret(s);
        if (s != buf)
        {
            free(s);
        };
        return ret;
    }

    inline std::string unicode_to_ansi(const std::wstring & data)
    {
        if (data.empty())
        {
            return "";
        }
        char buf[512];
        size_t len = data.size() + 1;
        char * s = unicode_to_ansi(data.c_str(), len, (len > 256) ? 0 : buf);
        std::string ret(s);
        if (s != buf)
        {
            free(s);
        };
        return ret;
    }

    inline wchar_t ansi_to_unicode(char c)
    {
        wchar_t ret[2];
        ansi_to_unicode(&c, 1, ret);
        return ret[0];
    }

    inline char unicode_to_ansi(wchar_t c)
    {
        char ret[3];
        unicode_to_ansi(&c, 1, ret);
        return ret[0];
    }
#endif

} // namespace hprose

#endif
