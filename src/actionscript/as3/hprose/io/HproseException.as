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
 * hprose exception for ActionScript 3.0.                 *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.io {
    import flash.errors.IOError;
    public dynamic class HproseException extends IOError {
        public function HproseException(message:String = "") {
            super(message);
            this.name = "HproseException";
        }
    }
}