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
 * LastModified: Dec 7, 2013                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose {
    import hprose.common.HproseException;
    import hprose.common.HproseResultMode;
    import hprose.common.IHproseFilter;
    import hprose.common.HproseFilter;

    import hprose.client.HproseHttpClient;
    import hprose.client.HproseHttpInvoker;
    import hprose.client.HproseHttpRequest;
    import hprose.client.HproseHttpProxy;
    import hprose.client.HproseSuccessEvent;
    import hprose.client.HproseErrorEvent;

    import hprose.io.HproseClassManager;
    import hprose.io.HproseFormatter;
    import hprose.io.HproseRawReader;
    import hprose.io.HproseSimpleReader;
    import hprose.io.HproseReader;
    import hprose.io.HproseTags;
    import hprose.io.HproseSimpleWriter;
    import hprose.io.HproseWriter;
    import flash.display.Sprite;

    public class HproseLoader extends Sprite {
        public function export():void {
            hprose.common.HproseException;
            hprose.common.HproseResultMode;
            hprose.common.IHproseFilter;
            hprose.common.HproseFilter;
            hprose.client.HproseHttpClient;
            hprose.client.HproseHttpInvoker;
            hprose.client.HproseHttpRequest;
            hprose.client.HproseHttpProxy;
            hprose.client.HproseSuccessEvent;
            hprose.client.HproseErrorEvent;
            hprose.io.HproseClassManager;
            hprose.io.HproseFormatter;
            hprose.io.HproseRawReader;
            hprose.io.HproseSimpleReader;
            hprose.io.HproseReader;
            hprose.io.HproseTags;
            hprose.io.HproseSimpleWriter;
            hprose.io.HproseWriter;
        }
    }
}