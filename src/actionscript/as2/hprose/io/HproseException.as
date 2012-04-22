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
 * HproseException.as                                     *
 *                                                        *
 * hprose exception for ActionScript 2.0.                 *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
dynamic class hprose.io.HproseException extends Error {
    public function HproseException(message:String) {
        super(message);
        this.name = "HproseException";
    }
}