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
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.server;

import hprose.common.HproseMethods;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class HproseHttpMethods extends HproseMethods {

    protected int getCount(Class[] paramTypes) {
        int i = paramTypes.length;
        if (i > 0) {
            Class paramType = paramTypes[i - 1];
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
