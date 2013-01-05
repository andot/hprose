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
 * HproseLoader.as                                        *
 *                                                        *
 * hprose class loader for ActionScript 3.0.              *
 *                                                        *
 * LastModified: Jun 26, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose {
    import hprose.client.HproseHttpClient;
    import hprose.client.HproseHttpInvoker;
    import hprose.client.HproseHttpRequest;
    import hprose.client.HproseHttpProxy;
    import hprose.client.HproseSuccessEvent;
    import hprose.client.HproseErrorEvent;
    import hprose.client.HproseResultMode;
    import hprose.client.HproseFilter;
    import hprose.client.IHproseFilter;
    import hprose.io.ClassManager;
    import hprose.io.HproseException;
    import hprose.io.HproseFormatter;
    import hprose.io.HproseReader;
    import hprose.io.HproseTags;
    import hprose.io.HproseWriter;
    import flash.display.Sprite;
    
    public class HproseLoader extends Sprite {
        public function export():void {
            hprose.client.HproseHttpClient;
            hprose.client.HproseHttpInvoker;
            hprose.client.HproseHttpRequest;
            hprose.client.HproseHttpProxy;
            hprose.client.HproseSuccessEvent;
            hprose.client.HproseErrorEvent;
            hprose.client.HproseResultMode;
            hprose.client.HproseFilter;
            hprose.client.IHproseFilter;
            hprose.io.ClassManager;
            hprose.io.HproseException;
            hprose.io.HproseFormatter;
            hprose.io.HproseReader;
            hprose.io.HproseTags;
            hprose.io.HproseWriter;
        }
    }
}