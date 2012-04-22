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
 * time.hpp                                               *
 *                                                        *
 * hprose time unit for cpp.                              *
 *                                                        *
 * LastModified: Jul 16, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_TIME_INCLUDED
#define HPROSE_TIME_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/config.hpp>
#include <hprose/common/exception.hpp>

#include <time.h>

namespace hprose
{
    class ctime
    {
    public: // structors

        ctime() throw()
          : time(0)
        {
        }

        ctime(time_t time) throw()
          : time(time)
        {
        }

        ctime(int year, int month, int day, int hour, int min, int sec, int dst = -1)
        {
            tm t;
            t.tm_year = year - 1900;
            t.tm_mon = month - 1;
            t.tm_mday = day;
            t.tm_hour = hour;
            t.tm_min = min;
            t.tm_sec = sec;
            t.tm_isdst = dst;
            time = mktime(&t);
        }

    public: // operators

        inline ctime & operator=(time_t time) throw()
        {
            this->time = time;
            return (*this);
        }

        inline ctime & operator+=(time_t span) throw()
        {
            time += span;
            return (*this);
        }

        inline ctime & operator-=(time_t span) throw()
        {
            time -= span;
            return (*this);
        }

        inline ctime operator+(time_t span) const throw()
        {
            return ctime(time + span);
        }

        inline ctime operator-(time_t span) const throw()
        {
            return ctime(time - span);
        }

        inline time_t operator-(ctime time) const throw()
        {
            return this->time - time.time;
        }

        inline bool operator==(ctime time) const throw()
        {
            return this->time == time.time;
        }

        inline bool operator!=(ctime time) const throw()
        {
            return this->time != time.time;
        }

        inline bool operator>(ctime time) const throw()
        {
            return this->time > time.time;
        }

        inline bool operator<(ctime time) const throw()
        {
            return this->time < time.time;
        }

        inline bool operator>=(ctime time) const throw()
        {
            return this->time >= time.time;
        }

        inline bool operator<=(ctime time) const throw()
        {
            return this->time <= time.time;
        }

    public: // apis

        inline static ctime now() throw()
        {
            return ctime(::time(0));
        }

        inline static int timezone()
        {
            static bool set;
            if (!set)
            {
                _tzset();
                set = true;
            }
        #if defined(_MSC_VER) && (_MSC_VER >= 1600)
            long timezone;
            _get_timezone(&timezone);
            return timezone;
        #else
            return ::timezone;        
        #endif
        }

        inline time_t get_time() const throw()
        {
            return time;
        }

        tm * get_gmt_tm(tm * ptm) const
        {
            if (ptm)
            {
            #if __STDC_WANT_LIB_EXT1__
                gmtime_s(&time, ptm);
            #elif __STDC_WANT_SECURE_LIB__
                gmtime_s(ptm, &time);
            #else
                *ptm = *gmtime(&time);
            #endif
                return ptm;
            }
            else
            {
            #if (__STDC_WANT_LIB_EXT1__ || __STDC_WANT_SECURE_LIB__)
                HPROSE_THROW_EXCEPTION("Points to the buffer can't be NULL!");
            #else
                return gmtime(&time);
            #endif
            }
        }

        tm * get_local_tm(tm * ptm) const
        {
            if (ptm)
            {
            #if __STDC_WANT_LIB_EXT1__
                localtime_s(&time, ptm);
            #elif __STDC_WANT_SECURE_LIB__
                localtime_s(ptm, &time);
            #else
                *ptm = *localtime(&time);
            #endif
                return ptm;
            }
            else
            {
            #if (__STDC_WANT_LIB_EXT1__ || __STDC_WANT_SECURE_LIB__)
                HPROSE_THROW_EXCEPTION("Points to the buffer can't be NULL!");
            #else
                return localtime(&time);
            #endif
            }
        }

        std::string get_asctime()
        {
            tm t;
            get_local_tm(&t);
        #if (__STDC_WANT_LIB_EXT1__ || __STDC_WANT_SECURE_LIB__)
            char buf[50];
            asctime_s(buf, 50, &t);
            return buf;
        #else
            return asctime(&t);
        #endif
        }

    private:

        time_t time;

    }; // ctime

}  // namespace hprose

#endif
