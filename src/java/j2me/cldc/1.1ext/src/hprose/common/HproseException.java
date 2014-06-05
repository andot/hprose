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
 * HproseException.java                                   *
 *                                                        *
 * hprose exception for Java.                             *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.io.IOException;

public class HproseException extends IOException {

    private static final long serialVersionUID = -6146544906159301857L;

    public HproseException() {
        super();
    }

    public HproseException(String msg) {
        super(msg);
    }
}
