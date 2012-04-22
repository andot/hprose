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
 * cookie.cpp                                             *
 *                                                        *
 * hprose cookie unit for cpp.                            *
 *                                                        *
 * LastModified: May 31, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#include <hprose/client/cookie.hpp>

#include <ctime>
#include <vector>

#include <boost/thread/locks.hpp>
#include <boost/algorithm/string/replace.hpp>

namespace hprose
{
    static const char MonthNames[12][4] =
    {
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN", // 1-6
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"  // 7-12
    };

    static const int TimeZoneCount[26] =
    {
        1, 1, 4, 2, 2, 2, 2, 2, 2, 1, 1, 2, 4, // -12-0
        5, 6, 1, 1, 1, 1, 1, 2, 1, 1, 1, 3, 1  // 1-13
    };

    static const char TimeZoneNames[26][6][5] =
    {
        {"IDLW"}, // -12
        {"NT"},  // -11
        {"AHST", "CAT", "HST", "AHST"}, // -10
        {"YST", "HDT"}, // -9
        {"PST", "YDT"}, // -8
        {"MST", "PDT"}, // -7
        {"CST", "MDT"}, // -6
        {"EST", "CDT"}, // -5
        {"AST", "EDT"}, // -4
        {"ADT"}, // -3
        {"AT"}, // -2
        {"WAT", "BST"}, // -1
        {"UT", "UTC", "GMT", "WET"}, // 0
        {"CET", "FWT", "MET", "MEWT", "SWT"}, // 1
        {"EET", "MEST", "MESZ", "SST", "FST", "CEST"}, // 2
        {"BT"}, // 3
        {"ZP4"}, // 4
        {"ZP5"}, // 5
        {"ZP6"}, // 6
        {"WAST"}, // 7
        {"CCT", "WADT"}, // 8
        {"JST"}, // 9
        {"GST"}, // 10
        {"EADT"}, // 11
        {"IDLE", "NZST", "NZT"}, // 12
        {"NZDT"} // 13
    };

    bool parse_month(const std::string & value, int & month)
    {
        for (int i = 0; i < 12; i++)
        {
            if (MonthNames[i] == value)
            {
                month = i;
                return true;
            }
        }
        return false;
    }

    bool parse_timezone(const std::string & value, int & zone)
    {
        if ((value[0] == '+') || (value[0] == '-'))
        {
            if (value == "-0000")
            {
                zone = ctime::timezone();
            }
            else if (value.size() > 4)
            {
                int zh = atoi(value.substr(1, 2).c_str());
                int zm = atoi(value.substr(3, 2).c_str());
                zone = zh * 3600 + zm * 60;
                if (value[0] == '-')
                {
                    zone = zone * (-1);
                }
            }
            return true;
        }
        else
        {
            for (int i = 0; i < 26; i++)
            {
                for (int j = 0; j < TimeZoneCount[i]; j++)
                {
                    if (TimeZoneNames[i][j] == value)
                    {
                        zone = (i - 12) * 3600;
                        return true;
                    }
                }
            }
        }
        return false;
    }

    std::time_t parse_rfc_datetime(std::string value)
    {
        boost::replace_all(value, " -", " #");
        std::replace(value.begin(), value.end(), '-', ' ');
        boost::replace_all(value, " #", " -");
        std::tm t;
        memset(&t, 0, sizeof(std::tm));
        int x, zone = 0;
        std::string s;
        std::string::size_type pos;
        while (!value.empty())
        {
            pos = value.find(' ');
            if (pos != std::string::npos)
            {
                s = value.substr(0, pos);
                value.erase(0, pos + 1);
            }
            else
            {
                s = value;
                value.clear();
            }
            std::transform(s.begin(), s.end(), s.begin(), toupper);
            if (parse_timezone(s, zone)) continue;
            if ((x = atoi(s.c_str())) > 0)
            {
                if ((x < 32) && (!t.tm_mday))
                {
                    t.tm_mday = x;
                    continue;
                }
                else
                {
                    if ((!t.tm_year) && (t.tm_mon || (x > 12)))
                    {
                        if (x < 32)
                        {
                            t.tm_year = x + 100;
                        }
                        else if (x < 1000)
                        {
                            t.tm_year = x;
                        }
                        else
                        {
                            t.tm_year = x - 1900;
                        }
                        continue;
                    }
                }
            }
            std::string::size_type first, last;
            if ((first = s.find_first_of(':')) < (last = s.find_last_of(':')))
            {
                t.tm_hour = atoi(s.substr(0, first).c_str());
                t.tm_min = atoi(s.substr(first + 1, last).c_str());
                t.tm_sec = atoi(s.substr(last + 1).c_str());
                continue;
            }
            if (s == "DST")
            {
                t.tm_isdst = true;
                continue;
            }
            if (parse_month(s, x) && (!t.tm_mon))
            {
                t.tm_mon = x;
            }
        }
        if (!t.tm_year)
        {
            t.tm_year = 80;
        }
        if (t.tm_mon > 11)
        {
            t.tm_mon = 11;
        }
        if (!t.tm_mday)
        {
            t.tm_mday = 1;
        }
        t.tm_sec -= (zone + ctime::timezone());
        return mktime(&t);
    }

    inline bool cookie::expired() const
    {
        return expiry && (expiry < time(0));
    }

    inline bool cookie::good() const
    {
        return !value.empty();
    }

    inline std::string cookie::rawform() const
    {
        return name + "=" + value;
    }

    cookies::AllCookies cookies::container;
    boost::shared_mutex cookies::mutex;

    std::string cookies::get_cookie(const std::string & host, const std::string & path, bool secure)
    {
        boost::upgrade_lock<boost::shared_mutex> lock(mutex);
        std::string ret;
        for (AllCookies::iterator iter1 = container.begin(); iter1 != container.end(); ++iter1)
        {
            if (host.find(iter1->first) != std::string::npos)
            {
                std::vector<std::string> names;
                DomainCookies & map = iter1->second;
                for (DomainCookies::iterator iter2 = map.begin(); iter2 != map.end(); ++iter2)
                {
                    cookie & c = iter2->second;
                    if (path.find(c.path) == 0)
                    {
                        if (c.expired())
                        {
                            names.push_back(c.name);
                        }
                        else if (((!c.secure) || (secure && c.secure)) && c.good())
                        {
                            ret += ret.empty() ? c.rawform() : ("; " + c.rawform());
                        }
                    }
                }
                if (!names.empty())
                {
                    // boost::upgrade_to_unique_lock doesn't compile on C++0x mode(#2501)
                    // boost::upgrade_to_unique_lock<boost::shared_mutex> unique_lock(lock);
                    mutex.unlock_upgrade_and_lock();
                    for (size_t i = 0; i < names.size(); i++)
                    {
                        map.erase(names[i]);
                    }
                    mutex.unlock_and_lock_upgrade();
                }
            }
        }
        return ret;
    }

    void cookies::set_cookie(const std::string & host, std::string content)
    {
        std::string::size_type pos = content.find(';');
        if (pos != std::string::npos)
        {
            cookie c;
            std::string s = content.substr(0, pos);
            content.erase(0, pos + 2);
            pos = s.find('=');
            if (pos != std::string::npos)
            {
                c.name = s.substr(0, pos);
                c.value = s.substr(pos + 1);
                std::string key, value;
                while (true)
                {
                    bool eof = false;
                    pos = content.find(';');
                    if (pos == std::string::npos)
                    {
                        eof = true;
                        s = content;
                    }
                    else
                    {
                        s = content.substr(0, pos);
                        content.erase(0, pos + 2);
                    }
                    pos = s.find('=');
                    if (pos != std::string::npos)
                    {
                        key = s.substr(0, pos);
                        value = s.substr(pos + 1);
                    }
                    else
                    {
                        if (_strcmpi(s.c_str(), "secure") == 0)
                        {
                            c.secure = true;
                        }
                        continue;
                    }
                    if (_strcmpi(key.c_str(), "path") == 0)
                    {
                        if (!value.empty())
                        {
                            if (*value.begin() == '"')
                            {
                                value.erase(0, 1);
                            }
                            if (*value.rbegin() == '"')
                            {
                                value.erase(value.size() - 1);
                            }
                            c.path = value.empty() ? std::string("/") : value;
                        }
                    }
                    else if (_strcmpi(key.c_str(), "domain") == 0)
                    {
                        if (!value.empty())
                        {
                            std::transform(value.begin(), value.end(), value.begin(), tolower);
                            c.domain = value;
                        }
                    }
                    else if (_strcmpi(key.c_str(), "expires") == 0)
                    {
                        if (!value.empty())
                        {
                            c.expiry = parse_rfc_datetime(value);
                        }
                    }
                    if (eof) break;
                }
                if (c.path.empty())
                {
                    c.path = "/";
                }
                if (c.domain.empty())
                {
                    c.domain = host;
                }
                boost::unique_lock<boost::shared_mutex> lock(mutex);
                container[c.domain][c.name] = c;
            }
        }
    }

} // namespace hprose
