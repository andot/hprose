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
 * HproseHttpMethods.java                                 *
 *                                                        *
 * hprose http methods class for Java.                    *
 *                                                        *
 * LastModified: May 11, 2011                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.server;

import hprose.common.HproseMethods;
import java.lang.reflect.Type;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class HproseHttpMethods extends HproseMethods {

    @Override
    protected int getCount(Type[] paramTypes) {
        int i = paramTypes.length;
        if ((i > 0) && (paramTypes[i - 1] instanceof Class<?>)) {
            Class<?> paramType = (Class<?>) paramTypes[i - 1];
            if (paramType.equals(HttpContext.class) ||
                paramType.equals(HttpServletRequest.class) ||
                paramType.equals(HttpServletResponse.class) ||
                paramType.equals(HttpSession.class) ||
                paramType.equals(ServletContext.class) ||
                paramType.equals(ServletConfig.class)) {
                i--;
            }
        }
        return i;
    }
}
