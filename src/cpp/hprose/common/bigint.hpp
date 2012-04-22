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
 * bigint.hpp                                             *
 *                                                        *
 * hprose big int unit for cpp.                           *
 *                                                        *
 * LastModified: Jun 2, 2010                              *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_BIGINT_INCLUDED
#define HPROSE_BIGINT_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <string>
#include <vector>

namespace hprose
{
    class bigint
    {
    public: // structors

        bigint()
        {
        }

        bigint(const unsigned int x)
        {
            data.push_back(x);
        }

        bigint(const std::string & s)
        {
            data.push_back(0);
            unsigned int i;
            for (i = 0; i < s.size(); i++)
            {
                if (!isdigit(s[i]))
                {
                    HPROSE_THROW_EXCEPTION("string contains non-decimal digit");
                }
            }
            std::string dec("0123456789");
            for (i = 0; i < s.size(); i++)
            {
                *this = (*this) * 10;
                bigint t((unsigned int)dec.find(s[i]));
                *this = (*this) + t;
            }
        }

        bigint(const bigint & x)
        {
            data = x.data;
        }

    public:

        static bigint divide(bigint dividend, bigint divisor, bigint * rem)
        {
            bigint zero(0);
            int count = 0;
            if (divisor == zero)
            {
                HPROSE_THROW_EXCEPTION("divisor == zero");
            }
            bigint quot(0);
            quot.resize(dividend.length());
            if (rem) rem->resize(dividend.length());
            while (divisor < dividend)
            {
                divisor <<= 1;
                count++;
            }
            if (divisor > dividend)
            {
                divisor >>= 1;
                count--;
            }
            if (count >= 0)
            {
                for(int i = 0; i <= count; i++)
                {
                    if (divisor <= dividend)
                    {
                        dividend -= divisor;
                        divisor  >>= 1;
                        quot <<= 1;
                        quot++;
                    }
                    else
                    {
                        divisor >>= 1;
                        quot <<= 1;
                    }
                }
            }
            if (rem)
            {
                *rem = dividend;
                rem->fixlen();
            }
            quot.fixlen();
            return quot;
        }

        static bigint powmod(bigint x, bigint y, bigint z)
        {
            bigint r(1);
            unsigned int tmp;
            size_t n = y.length();
            for (unsigned int i = 0; i < n - 1; i++)
            {
                tmp = y.data[i];

                for (unsigned int j = 0; j < 16; j++)
                {
                    if (tmp & 1) r = r * x % z;
                    tmp >>= 1;
                    x = x * x % z;
                }
            }
            tmp = y.data[n - 1];
            while (tmp)
            {
                if (tmp & 1) r = r * x % z;
                tmp >>= 1;
                x = x * x % z;
            }
            return r;
        }

    public:

        std::string to_bin() const
        {
            std::string retval;
            size_t n = length();
            retval.resize(n * 4);
            for (unsigned int i = 0; i < n; i++)
            {
                retval[(n - i) * 4 - 1] = (char)(data[i] & 0xff);
                retval[(n - i) * 4 - 2] = (char)((data[i] >> 8) & 0xff);
                retval[(n - i) * 4 - 3] = (char)((data[i] >> 16) & 0xff);
                retval[(n - i - 1) * 4] = (char)((data[i] >> 24) & 0xff);
            }
            return retval;
        }

        std::string to_string() const
        {
            std::string retval;
            bigint zero(0), one(1);
            if (*this == zero)
            {
                retval = "0";
            }
            else if (*this == one)
            {
                retval = "1";
            }
            else
            {
                std::string dec("0123456789");
                bigint t(*this);
                bigint r;
                while (t != zero)
                {
                    t = divide(t, bigint(10), &r);
                    retval.insert(retval.begin(), dec[r.data[0]]);
                }
            }
            return retval;
        }

        friend std::ostream & operator<<(std::ostream & os, const bigint & x)
        {
            return os << x.to_string();
        }

    public: // operators

        bool operator<(const bigint & x) const
        {
          if (length() < x.length()) return true;
          if (x.length() < length()) return false;
          for (size_t i = length() - 1; i > 0; i--)
          {
            if (data[i] < x.data[i]) return true;
            if (x.data[i] < data[i]) return false;
          }
          return (data[0] < x.data[0]);
        }

        bool operator<=(const bigint & x) const
        {
            return (*this < x) || (*this == x);
        }

        bool operator>(const bigint & x) const
        {
            return !(*this <= x);
        }

        bool operator>=(const bigint & x) const
        {
          return !(*this < x);
        }

        bool operator==(const bigint & x) const
        {
            return !((*this < x) || (x < *this));
        }

        bool operator!=(const bigint & x) const
        {
            return !(*this == x);
        }

        bigint operator+(bigint & x)
        {
            bigint r;
            unsigned int carry = 0;
            const size_t & max_size = std::max<size_t>(length(), x.length());
            resize(max_size + 1);
            x.resize(max_size + 1);
            r.resize(max_size + 1);
            for (unsigned int i = 0; i < length(); i++)
            {
                r.data[i] = data[i] + x.data[i] + carry;
                if (carry == 0)
                {
                  carry = ((r.data[i] < data[i] || r.data[i] < x.data[i]) ? 1 : 0);
                }
                else
                {
                  carry = ((r.data[i] <= data[i] || r.data[i] <= x.data[i]) ? 1 : 0);
                }
            }
            fixlen();
            x.fixlen();
            r.fixlen();
            return r;
        }

        bigint operator+(unsigned int i)
        {
            bigint t(i);
            return *this + t;
        }

        bigint & operator+=(bigint & x)
        {
            unsigned int carry = 0;
            unsigned int prevdigit;
            const size_t & max_size = std::max<size_t>(length(), x.length());
            resize(max_size + 1);
            x.resize(max_size + 1);
            for (unsigned int i = 0; i < length(); i++)
            {
                prevdigit = data[i];
                data[i] = data[i] + x.data[i] + carry;
                if (carry == 0)
                {
                  carry = ((data[i] < prevdigit || data[i] < x.data[i]) ? 1 : 0);
                }
                else
                {
                  carry = ((data[i] <= prevdigit || data[i] <=x.data[i]) ? 1 : 0);
                }
            }
            fixlen();
            x.fixlen();
          return *this;
        }

        bigint & operator++()
        {
            data.push_back(0);
            data.front()++;
            for (unsigned int i = 1; i < length(); i++)
            {
                if (data[i-1]) break;
                data[i]++;
            }
            fixlen();
            return *this;
        }

        bigint operator++(int)
        {
            bigint t(*this);
            ++*this;
            return t;
        }

        bigint operator-(bigint & x)
        {
            bigint r(0);
            unsigned int borrow = 0;
            const size_t & max_size = std::max<size_t>(length(), x.length());
            resize(max_size + 1);
            x.resize(max_size + 1);
            r.resize(max_size + 1);
            if (*this < x)
            {
                HPROSE_THROW_EXCEPTION("minuend < subtracter");
            }
            for (unsigned int i = 0; i < length(); i++)
            {
                r.data[i] = data[i] - x.data[i] - borrow;

                if (borrow == 0)
                {
                    borrow = (data[i] < x.data[i]) ? 1 : 0;
                }
                else
                {
                    borrow = (data[i] <= x.data[i]) ? 1 : 0;
                }
            }
            fixlen();
            x.fixlen();
            r.fixlen();
            return r;
        }

        bigint & operator-=(bigint & x)
        {
            unsigned int borrow = 0;
            unsigned int prevdigit;
            const size_t & max_size = std::max<size_t>(length(), x.length());
            resize(max_size + 1);
            x.resize(max_size + 1);
            if (*this < x)
            {
                HPROSE_THROW_EXCEPTION("minuend < subtracter");
            }
            for (unsigned int i = 0; i < length(); i++)
            {
                prevdigit = data[i];
                data[i] = data[i] - x.data[i] - borrow;

                if (borrow == 0)
                {
                    borrow = (prevdigit < x.data[i]) ? 1 : 0;
                }
                else
                {
                    borrow = (prevdigit <= x.data[i]) ? 1 : 0;
                }
            }
            fixlen();
            x.fixlen();
            return *this;
        }

        bigint & operator--()
        {
            data.front()--;
            for (unsigned int i = 1; i < length(); i++)
            {
                if (data[i-1] != 0x80000000) break;
                data[i]--;
            }
            fixlen();
            return *this;
        }

        bigint operator--(int)
        {
            bigint t(*this);
            --*this;
            return t;
        }

        bigint operator*(bigint x) const
        {
            bigint t(*this);
            bigint r(0), zero(0);
            do
            {
                if ((x.data.front() & 1) != 0) r += t;
                x >>= 1;
                t <<= 1;
            } while (x != zero);
            r.fixlen();
            return r;
        }

        bigint operator*(unsigned int i) const
        {
          return (*this) * bigint(i);
        }

        bigint operator/(const bigint & x) const
        {
            return divide(*this, x, NULL);
        }

        bigint operator%(const bigint & x) const
        {
            bigint r;
            divide(*this, x, &r);
            return r;
        }

        bigint & operator>>=(unsigned int bit)
        {
            unsigned int carry;
            data.push_back(0);
            for (unsigned int i = 0; i < bit; i++)
            {
                carry = data.back() & 1;
                data.back() >>= 1;
                for (int j = (int)length() - 1; j >= 0; j--)
                {
                    if (carry)
                    {
                        carry = data[j] & 1;
                        data[j] >>= 1;
                        data[j] |= 0x80000000;
                    }
                    else
                    {
                        carry = data[j] & 1;
                        data[j] >>= 1;
                    }
                }
            }
            fixlen();
            return *this;
        }

        bigint & operator<<=(unsigned int bit)
        {
            unsigned int carry;
            unsigned int push_back_size = bit/32 + 1;
            unsigned int i;
            for (i = 0; i < push_back_size + 1; i++)
            {
                data.push_back(0);
            }
            for (i = 0; i < bit; i++)
            {
                carry = data.front() & 0x80000000;
                data.front() <<= 1;
                for (unsigned int j = 1; j < length(); j++)
                {
                    if (carry)
                    {
                        carry = data[j] & 0x80000000;
                        data[j] <<= 1;
                        data[j] |= 1;
                    }
                    else
                    {
                        carry = data[j] & 0x80000000;
                        data[j] <<= 1;
                    }
                }
            }
            fixlen();
            return *this;
        }

    private:

        inline bool empty() const
        {
            return data.empty();
        }

        inline size_t length() const
        {
            return data.size();
        }

        inline void resize(size_t size)
        {
            data.resize(size);
        }

        void fixlen()
        {
            while ((data.size() > 1) && (data.back() == 0))
            {
                data.pop_back();
            }
        }

    private:

        std::vector<unsigned int> data;

    }; // class bigint

} // namespace hprose

#endif
