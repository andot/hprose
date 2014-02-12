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
 * HproseHttpProxy.as                                     *
 *                                                        *
 * hprose http proxy class for ActionScript 3.0.          *
 *                                                        *
 * LastModified: May 16, 2010                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.client {
    import flash.utils.Proxy;
    ﻿import flash.utils.flash_proxy;

    public dynamic class HproseHttpProxy extends Proxy {
        private var client:HproseHttpClient;
        private var ns:String;
        public function HproseHttpProxy(client:HproseHttpClient, ns:String) {
            this.client = client;
            this.ns = ns;
        }
        flash_proxy override function callProperty(name:*, ...rest):* {
            if (ns == '') {
                rest.unshift(name);
            }
            else {
                rest.unshift(ns + '_' + name);
            }
            return client.invoke.apply(client, rest);
        }
        flash_proxy override function getProperty(name:*):* {
            if (ns == '') {
                return new HproseHttpProxy(client, name);
            }
            else {
                return new HproseHttpProxy(client, ns + '_' + name);
            }
        }
    }
}