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
 * hproseHttpRequest.js                                   *
 *                                                        *
 * POST data to HTTP Server (using Flash).                *
 *                                                        *
 * LastModified: Nov 6, 2013                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

/*
 * Interfaces:
 * HproseHttpRequest.post(url, header, data, callback, timeout, filter);
 */

/* public class HproseHttpRequest
 * static encapsulation environment for HproseHttpRequest
 */

var HproseHttpRequest = (function() {
    // static private members
    
    var s_localfile = (location.protocol == "file:");

    /*
     * to save Flash Request
     */
    var s_request = null;

    /*
     * to save all request callback functions
     */
    var s_callbackList = [];

    /*
     * to save all request callback filters
     */
    var s_callbackFilters = [];
    /*
     * to save HproseHttpRequest tasks.
     */
    var s_jsTaskQueue = [];
    var s_swfTaskQueue = [];

    /*
     * to save js & swf status.
     */
    var s_jsReady = false;
    var s_swfReady = false;

    var s_XMLHttpNameCache = null;
    
    var s_hasXDomainRequest = (typeof(window.XDomainRequest) == 'object');

    function createXMLHttp() {
        if (-[1,] && window.XMLHttpRequest) {
            var objXMLHttp = new XMLHttpRequest();
            // some older versions of Moz did not support the readyState property
            // and the onreadystate event so we patch it!
            if (objXMLHttp.readyState == null) {
                objXMLHttp.readyState = 0;
                objXMLHttp.addEventListener(
                    "load",
                    function () {
                        objXMLHttp.readyState = 4;
                        if (typeof(objXMLHttp.onreadystatechange) == "function") {
                            objXMLHttp.onreadystatechange();
                        }
                    },
                    false
                );
            }
            return objXMLHttp;
        }
        else if (!s_localfile && window.XMLHttpRequest) {
            return new XMLHttpRequest();
        }
        else if (s_XMLHttpNameCache != null) {
            // Use the cache name first.
            return new ActiveXObject(s_XMLHttpNameCache);
        }
        else {
            var MSXML = ['MSXML2.XMLHTTP.6.0',
                         'MSXML2.XMLHTTP.5.0',
                         'MSXML2.XMLHTTP.4.0',
                         'MSXML2.XMLHTTP.3.0',
                         'MsXML2.XMLHTTP.2.6',
                         'MSXML2.XMLHTTP',
                         'Microsoft.XMLHTTP.1.0',
                         'Microsoft.XMLHTTP.1',
                         'Microsoft.XMLHTTP'];
            var n = MSXML.length;
            for(var i = 0; i < n; i++) {
                try {
                    objXMLHttp = new ActiveXObject(MSXML[i]);
                    // Cache the XMLHttp ActiveX object name.
                    s_XMLHttpNameCache = MSXML[i];
                    return objXMLHttp;
                }
                catch(e) {}
            }
            return null;
        }
    }

    function setJsReady() {
        var id = 'hprosehttprequest_as3';
        s_request = thisMovie(id);
        s_jsReady = true;
        while (s_jsTaskQueue.length > 0) {
            var task = s_jsTaskQueue.shift();
            if (typeof(task) == 'function') {
                task();
            }
        }
    }

    function checkFlash() {
        var flash = 'Shockwave Flash';
        var flashmime = 'application/x-shockwave-flash';
        var flashax = 'ShockwaveFlash.ShockwaveFlash';
        var plugins = navigator.plugins;
        var mimetypes = navigator.mimeTypes;
        var version = 0;
        var ie = false;
        if (plugins && plugins[flash]) {
            version = plugins[flash].description;
            if (version && !(mimetypes && mimetypes[flashmime] &&
                         !mimetypes[flashmime].enabledPlugin)) {
                version = version.replace(/^.*\s+(\S+\s+\S+$)/, "$1");
                version = parseInt(version.replace(/^(.*)\..*$/, "$1"));
            }
        }
        else if (window.ActiveXObject) {
            try {
                ie = true;
                var ax = new ActiveXObject(flashax);
                if (ax) {
                    version = ax.GetVariable("$version");
                    if (version) {
                        version = version.split(" ")[1].split(",");
                        version = parseInt(version[0]);
                    }
                }
            }
            catch(e) {}
        }
        if (version < 9) {
            return 0;
        }
        else if (ie) {
            return 1;
        }
        else {
            return 2;
        }
    }

    function thisMovie(movieName) {
        if (navigator.appName.indexOf("Microsoft") != -1) {
            return window[movieName];
        }
        else {
            return document[movieName];
        }
    }

    function init() {
        if (document.addEventListener) {
            document.addEventListener("DOMContentLoaded", setJsReady, false);
        }
        else if (/WebKit/i.test(navigator.userAgent)) {
            var timer = setInterval( function() {
                if (/loaded|complete/.test(document.readyState)) {
                    clearInterval(timer);
                    setJsReady();
                }
            }, 10);
        }
        else if (/MSIE/i.test(navigator.userAgent) &&
                /Windows CE/i.test(navigator.userAgent)) {
            setJsReady();
        }
        else if (/MSIE/i.test(navigator.userAgent) &&
                !/Nokia/i.test(navigator.userAgent) &&
                !/Opera/i.test(navigator.userAgent)) {
            document.write('<script id="__ie_onload" defer src="javascript:void(0)"></script>');
            var script = document.getElementById("__ie_onload");
            script.onreadystatechange = function() {
                if (this.readyState == 'complete') {
                    setJsReady();
                }
            }
        }
        else if (window.attachEvent) {
            window.attachEvent('onload', setJsReady);
        }
        else {
            window.onload = setJsReady;
        }
    }

    function flashpost(url, header, data, callbackid, timeout) {
        if (s_swfReady) {
            s_request.post(url, header, data, callbackid, timeout);
        }
        else {
            var task = function() {
                s_request.post(url, header, data, callbackid, timeout);
            };
            s_swfTaskQueue.push(task);
        }
    }

    function xdrpost(url, header, data, callbackid, timeout) {
        var xdr = new XDomainRequest();
        xdr.timeout = timeout;
        xdr.onerror = function() {
            HproseHttpRequest.__callback(callbackid, HproseTags.TagError +
                                         HproseFormatter.serialize("unknown error.", true) +
                                         HproseTags.TagEnd);
        };
        xdr.ontimeout = function() {
            HproseHttpRequest.__callback(callbackid, HproseTags.TagError +
                                         HproseFormatter.serialize("timeout", true) +
                                         HproseTags.TagEnd);
        };
        xdr.onload = function() {
            HproseHttpRequest.__callback(callbackid, xdr.responseText, true);
        };
        xdr.open('POST', url);
        xdr.send(data);
    }

    function xhrpost(url, header, data, callbackid, timeout) {
        var xmlhttp = createXMLHttp();
        var timeoutId;
        xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4) {
                xmlhttp.onreadystatechange = function () {};
                if (timeoutId !== undefined) {
                    window.clearTimeout(timeoutId);
                }
                if (xmlhttp.status == 200) {
                    HproseHttpRequest.__callback(callbackid, xmlhttp.responseText, true);
                }
                else {
                    var error = xmlhttp.status + ':' +  xmlhttp.statusText;
                    HproseHttpRequest.__callback(callbackid, HproseTags.TagError +
                                            HproseFormatter.serialize(error, true) +
                                            HproseTags.TagEnd);
                }
            }
        }
        xmlhttp.open('POST', url, true);
        if (!s_localfile && "withCredentials" in xmlhttp) {
            xmlhttp.withCredentials = 'true';
        }
        for (var name in header) {
            xmlhttp.setRequestHeader(name, header[name]);
        }
        var timeoutHandler = function () {
            HproseHttpRequest.__callback(callbackid, HproseTags.TagError +
                                    HproseFormatter.serialize('timeout', true) +
                                    HproseTags.TagEnd);
        }
        if (xmlhttp.timeout === undefined) {
            timeoutId = window.setTimeout(function() {
                xmlhttp.onreadystatechange = function () {};
                xmlhttp.abort();
                timeoutHandler();
            }, timeout);
        }
        else {
            xmlhttp.timeout = timeout;
            xmlhttp.ontimeout = timeoutHandler;
        }
        xmlhttp.send(data);
    }

    function post(url, header, data, callbackid, timeout) {
        if (url.substr(0, 7).toLowerCase() == "http://" ||
            url.substr(0, 8).toLowerCase() == "https://") {
            if (!s_localfile && s_request) {
                flashpost(url, header, data, callbackid, timeout);
            }
            else if (s_hasXDomainRequest) {
                try {
                    xdrpost(url, header, data, callbackid, timeout);
                }
                catch (e) {
                    xhrpost(url, header, data, callbackid, timeout);
                }
            }
            else {
                xhrpost(url, header, data, callbackid, timeout);
            }
        }
        else {
            xhrpost(url, header, data, callbackid, timeout);
        }
    }

    var HproseHttpRequest = {};

    HproseHttpRequest.post = function (url, header, data, callback, timeout, filter) {
        var callbackid = -1;
        if (callback) {
            callbackid = s_callbackList.length;
            s_callbackList[callbackid] = callback;
            s_callbackFilters[callbackid] = filter;
        }
        data = filter.outputFilter(data);
        if (s_jsReady) {
            post(url, header, data, callbackid, timeout);
        }
        else {
            var task = function() {
                post(url, header, data, callbackid, timeout);
            };
            s_jsTaskQueue.push(task);
        }
    }

    HproseHttpRequest.__callback = function(callbackid, data, needToFilter) {
        if (needToFilter) {
            data = s_callbackFilters[callbackid].inputFilter(data);
        }
        if (typeof(s_callbackList[callbackid]) == 'function') {
            s_callbackList[callbackid](data);
        }
        delete s_callbackList[callbackid];
        delete s_callbackFilters[callbackid];
    }

    HproseHttpRequest.__jsReady = function () {
        return s_jsReady;
    }

    HproseHttpRequest.__setSwfReady = function () {
        s_swfReady = true;
        window["__flash__removeCallback"] = function(instance, name) {
            try {
                if (instance) {
                    instance[name] = null;
                 }
            }
            catch (flashEx) { 
            }
        };
        while (s_swfTaskQueue.length > 0) {
            var task = s_swfTaskQueue.shift();
            if (typeof(task) == 'function') {
                task();
            }
        }
    }

    HproseHttpRequest.setFlash = function(path) {
        if (path === undefined) path = '';
        switch (checkFlash()) {
            case 1:
                document.write(['<object ',
                'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ',
                'type="application/x-shockwave-flash" ',
                'width="0" height="0" id="hprosehttprequest_as3">',
                '<param name="movie" value="', path , 'hproseHttpRequest.swf" />',
                '<param name="allowScriptAccess" value="always" />',
                '<param name="quality" value="high" />',
                '</object>'].join(''));
                break;
            case 2:
                document.write('<embed src="' + path + 'hproseHttpRequest.swf" ' +
                'type="application/x-shockwave-flash" ' +
                'width="0" height="0" name="hprosehttprequest_as3" ' +
                'allowScriptAccess="always" />');
                break;
        }
    }

    init();

    return HproseHttpRequest;
})();