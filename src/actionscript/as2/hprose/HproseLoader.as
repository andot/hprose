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
 * hprose class loader for ActionScript 2.0.              *
 *                                                        *
 * LastModified: Nov 20, 2013                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
import hprose.common.Map;
import hprose.common.WeakMap;
import hprose.common.HproseException;
import hprose.common.IHproseFilter;
import hprose.common.HproseFilter;
import hprose.common.HproseResultMode;

import hprose.client.HproseHttpClient;
import hprose.client.HproseHttpInvoker;
import hprose.client.HproseHttpRequest;
import hprose.client.HproseSuccessEvent;
import hprose.client.HproseErrorEvent;
import hprose.client.HproseProgressEvent;

import hprose.io.HproseClassManager;
import hprose.io.HproseFormatter;
import hprose.io.HproseRawReader;
import hprose.io.HproseSimpleReader;
import hprose.io.HproseReader;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseStringOutputStream;
import hprose.io.HproseTags;
import hprose.io.HproseSimpleWriter;
import hprose.io.HproseWriter;

class hprose.HproseLoader extends MovieClip {
    public function export() {
        hprose.common.Map;
        hprose.common.WeakMap;
        hprose.common.HproseException;
        hprose.common.IHproseFilter;
        hprose.common.HproseFilter;
        hprose.common.HproseResultMode;

        hprose.client.HproseHttpClient;
        hprose.client.HproseHttpInvoker;
        hprose.client.HproseHttpRequest;
        hprose.client.HproseSuccessEvent;
        hprose.client.HproseErrorEvent;
        hprose.client.HproseProgressEvent;

        hprose.io.HproseClassManager;
        hprose.io.HproseFormatter;
        hprose.io.HproseRawReader;
        hprose.io.HproseSimpleReader;
        hprose.io.HproseReader;
        hprose.io.HproseStringInputStream;
        hprose.io.HproseStringOutputStream;
        hprose.io.HproseTags;
        hprose.io.HproseSimpleWriter;
        hprose.io.HproseWriter;
    }
}