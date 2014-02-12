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
 * LastModified: Feb 11, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

/*
 * Interfaces:
 * HproseHttpRequest.post(url, header, data, callback, timeout, filter);
 */

/* public class HproseHttpRequest
 * static encapsulation environment for HproseHttpRequest
 */

var HproseHttpRequest = (function(global) {
    // get flash path
    var scripts = document.getElementsByTagName("script");
    var s_flashpath = scripts[scripts.length - 1].getAttribute('flashpath') || '';
    scripts = null;

    // static private members
    var s_nativeXHR = (typeof(XMLHttpRequest) !== 'undefined');
    var s_localfile = (location.protocol == "file:");
    var s_corsSupport = (!s_localfile && s_nativeXHR && "withCredentials" in new XMLHttpRequest());
    var s_flashID = 'hprosehttprequest_as3';

    var s_flashSupport = false;

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

    function patchXHR(xhr) {
        // some older versions of Moz did not support the readyState property
        // and the onreadystate event so we patch it!
        if (xhr.readyState == null) {
            xhr.readyState = 0;
            xhr.addEventListener(
                "load",
                function () {
                    xhr.readyState = 4;
                    if (typeof(xhr.onreadystatechange) === "function") {
                        xhr.onreadystatechange();
                    }
                },
                false
            );
        }
        return xhr;
    }

    function createMSXMLHttp() {
        if (s_XMLHttpNameCache != null) {
            // Use the cache name first.
            return new ActiveXObject(s_XMLHttpNameCache);
        }
        var MSXML = ['MSXML2.XMLHTTP',
                     'MSXML2.XMLHTTP.6.0',
                     'MSXML2.XMLHTTP.5.0',
                     'MSXML2.XMLHTTP.4.0',
                     'MSXML2.XMLHTTP.3.0',
                     'MsXML2.XMLHTTP.2.6',
                     'Microsoft.XMLHTTP',
                     'Microsoft.XMLHTTP.1.0',
                     'Microsoft.XMLHTTP.1'];
        var n = MSXML.length;
        for(var i = 0; i < n; i++) {
            try {
                var xhr = new ActiveXObject(MSXML[i]);
                // Cache the XMLHttp ActiveX object name.
                s_XMLHttpNameCache = MSXML[i];
                return xhr;
            }
            catch(e) {}
        }
        throw new Error("Could not find an installed XML parser");
    }

    function createXHR() {
        if (s_nativeXHR) {
            return patchXHR(new XMLHttpRequest());
        }
        else {
            return createMSXMLHttp();
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
        else if (global.ActiveXObject) {
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

    function setFlash() {
        var flashStatus = checkFlash();
        s_flashSupport = flashStatus > 0;
        if (s_flashSupport) {
            var div = document.createElement('div');
            div.style.width = 0;
            div.style.height = 0;
            if (flashStatus == 1) {
                div.innerHTML = ['<object ',
                'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ',
                'type="application/x-shockwave-flash" ',
                'width="0" height="0" id="', s_flashID, '" name="', s_flashID, '">',
                '<param name="movie" value="', s_flashpath , 'hproseHttpRequest.swf" />',
                '<param name="allowScriptAccess" value="always" />',
                '<param name="quality" value="high" />',
                '<param name="wmode" value="opaque" />',
                '</object>'].join('');
            } else {
                div.innerHTML = '<embed id="' + s_flashID + '" ' +
                'src="' + s_flashpath + 'hproseHttpRequest.swf" ' +
                'type="application/x-shockwave-flash" ' +
                'width="0" height="0" name="' + s_flashID + '" ' +
                'allowScriptAccess="always" />';
            }
            document.body.appendChild(div);
        }
    }

    function setJsReady() {
        if (s_jsReady) return;
        s_jsReady = true;
        if (!s_localfile && !s_corsSupport) setFlash();
        while (s_jsTaskQueue.length > 0) {
            var task = s_jsTaskQueue.shift();
            if (typeof(task) == 'function') {
                task();
            }
        }
    }

    function detach() {
        if (document.addEventListener) {
            document.removeEventListener("DOMContentLoaded", completed, false);
            global.removeEventListener("load", completed, false);

        } else {
            document.detachEvent("onreadystatechange", completed);
            global.detachEvent("onload", completed);
        }
    }

    function completed() {
        if (document.addEventListener || event.type === "load" || document.readyState === "complete") {
            detach();
            setJsReady();
        }
    }

    function init() {
        if (document.readyState === "complete") {
            setTimeout(setJsReady, 1);
        }
        else if (document.addEventListener) {
            document.addEventListener("DOMContentLoaded", completed, false);
            global.addEventListener("load", completed, false);
            if (/WebKit/i.test(navigator.userAgent)) {
                var timer = setInterval( function() {
                    if (/loaded|complete/.test(document.readyState)) {
                        clearInterval(timer);
                        completed();
                    }
                }, 10);
            }
        }
        else if (document.attachEvent) {
            document.attachEvent("onreadystatechange", completed);
            global.attachEvent("onload", completed);
            var top = false;
            try {
                top = window.frameElement == null && document.documentElement;
            }
            catch(e) {}
            if (top && top.doScroll) {
                (function doScrollCheck() {
                    if (!s_jsReady) {
                        try {
                            top.doScroll("left");
                        }
                        catch(e) {
                            return setTimeout(doScrollCheck, 15);
                        }
                        detach();
                        setJsReady();
                    }
                })();
            }
        }
        else if (/MSIE/i.test(navigator.userAgent) &&
                /Windows CE/i.test(navigator.userAgent)) {
            setJsReady();
        }
        else {
            global.onload = setJsReady;
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

    function xhrpost(url, header, data, callbackid, timeout) {
        var xhr = createXHR();
        var timeoutId;
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = function () {};
                if (timeoutId !== undefined) {
                    global.clearTimeout(timeoutId);
                }
                if (xhr.status == 200) {
                    HproseHttpRequest.__callback(callbackid, xhr.responseText, true);
                }
                else {
                    var error = xhr.status + ':' +  xhr.statusText;
                    HproseHttpRequest.__callback(callbackid, HproseTags.TagError +
                                            HproseFormatter.serialize(error, true) +
                                            HproseTags.TagEnd);
                }
            }
        }
        xhr.open('POST', url, true);
        if (s_corsSupport) {
            xhr.withCredentials = 'true';
        }
        for (var name in header) {
            xhr.setRequestHeader(name, header[name]);
        }
        var timeoutHandler = function () {
            HproseHttpRequest.__callback(callbackid, HproseTags.TagError +
                                    HproseFormatter.serialize('timeout', true) +
                                    HproseTags.TagEnd);
        }
        if (xhr.timeout === undefined) {
            timeoutId = global.setTimeout(function() {
                xhr.onreadystatechange = function () {};
                xhr.abort();
                timeoutHandler();
            }, timeout);
        }
        else {
            xhr.timeout = timeout;
            xhr.ontimeout = timeoutHandler;
        }
        xhr.send(data);
    }

    function post(url, header, data, callbackid, timeout) {
        if (s_flashSupport && !s_localfile &&
           (url.substr(0, 7).toLowerCase() == "http://" ||
            url.substr(0, 8).toLowerCase() == "https://")) {
            flashpost(url, header, data, callbackid, timeout);
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
        s_request = (navigator.appName.indexOf("Microsoft") != -1) ?
                    global[s_flashID] : document[s_flashID];
        s_swfReady = true;
        global["__flash__removeCallback"] = function(instance, name) {
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

    init();

    return HproseHttpRequest;
})(this);