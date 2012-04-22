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
 * algorithm.hpp                                          *
 *                                                        *
 * hprose algorithm unit for cpp.                         *
 *                                                        *
 * LastModified: May 26, 2010                             *
 * Author: Chen fei <cf@hprfc.com>                        *
 *                                                        *
\**********************************************************/

#ifndef HPROSE_ALGORITHM_INCLUDED
#define HPROSE_ALGORITHM_INCLUDED

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include <hprose/common/any.hpp>

#include <vector>

namespace hprose
{
    template<typename ValueType>
    int vector_index_of(const std::vector<any> & container, ValueType & value)
    {
        std::vector<any>::const_iterator iter = container.begin();
        while (iter != container.end())
        {
            if ((*iter).type() == typeid(ValueType))
            {
                if (any::cast<ValueType>(*iter) == value)
                {
                    return (int)(iter - container.begin());
                }
            }
            iter++;
        }
        return -1;
    }

    struct type_info_less
    {
        bool operator()(const std::type_info * left, const std::type_info * right) const
        {
            return left->before(*right) != 0;
        }
    };

} // namespace hprose

#endif
