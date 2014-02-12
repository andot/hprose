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
 * HproseHttpClient.js                                    *
 *                                                        *
 * HproseHttpClient for Node.js.                          *
 *                                                        *
 * LastModified: Nov 18, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

var util = require('util');
var http = require('http');
var https = require('https');
var parse = require('url').parse;

var HproseException = require('../common/HproseException.js');
var HproseClient = require('./HproseClient.js');

var s_cookieManager = {};

function setCookie(headers, host) {
    for (var name in headers) {
        var name = name.toLowerCase();
        var value = headers[name];
        if ((name == 'set-cookie') || (name == 'set-cookie2')) {
            var cookies = value.replace(/(^\s*)|(\s*$)/g, "").split(';');
            var cookie = {};
            value = cookies[0].replace(/(^\s*)|(\s*$)/g, "").split('=', 2);
            if (value[1] === undefined) value[1] = null;
            cookie['name'] = value[0];
            cookie['value'] = value[1];
            for (var i = 1; i < cookies.length; i++) {
                value = cookies[i].replace(/(^\s*)|(\s*$)/g, "").split('=', 2);
                if (value[1] === undefined) value[1] = null;
                cookie[value[0].toUpperCase()] = value[1];
            }
            // Tomcat can return SetCookie2 with path wrapped in "
            if (cookie['PATH']) {
                if (cookie['PATH'].charAt(0) == '"') {
                    cookie['PATH'] = cookie['PATH'].substr(1);
                }
                if (cookie['PATH'].charAt(cookie['PATH'].length - 1) == '"') {
                    cookie['PATH'] = cookie['PATH'].substr(0, cookie['PATH'].length - 1);
                }
            }
            else {
                cookie['PATH'] = '/'
            }
            if (cookie['EXPIRES']) {
                cookie['EXPIRES'] = Date.parse(cookie['EXPIRES']);
            }
            if (cookie['DOMAIN']) {
                cookie['DOMAIN'] = cookie['DOMAIN'].toLowerCase();
            }
            else {
                cookie['DOMAIN'] = host;
            }
            cookie['SECURE'] = (cookie['SECURE'] !== undefined);
            if (s_cookieManager[cookie['DOMAIN']] === undefined) {
                s_cookieManager[cookie['DOMAIN']] = {};
            }
            s_cookieManager[cookie['DOMAIN']][cookie['name']] = cookie;
        }
    }
}

function getCookie(host, path, secure) {
    var cookies = [];
    for (var domain in s_cookieManager) {
        if (host.indexOf(domain) > -1) {
            var names = [];
            for (var name in s_cookieManager[domain]) {
                var cookie = s_cookieManager[domain][name];
                if (cookie['EXPIRES'] && ((new Date()).getTime() > cookie['EXPIRES'])) {
                    names.push(name);
                }
                else if (path.indexOf(cookie['PATH']) === 0) {
                    if (((secure && cookie['SECURE']) ||
                         !cookie['SECURE']) && (cookie['value'] !== null)) {
                        cookies.push(cookie['name'] + '=' + cookie['value']);
                    }
                }
            }
            for (var i in names) {
                delete s_cookieManager[domain][names[i]];
            }
        }
    }
    if (cookies.length > 0) {
        return cookies.join('; ');
    }
    return '';
}

function HproseHttpClient(url) {
    if (this.constructor != HproseHttpClient) return new HproseHttpClient(url);
    HproseClient.call(this);
    var m_options;
    var m_http;
    var m_secure;
    var super_useService = this.useService;
    if (url) useService(url);

    function useService(url) {
        if (url === undefined) return super_useService();
        m_options = parse(url);
        if (m_options.protocol == 'http:') {
            m_http = http;
            m_secure = false;
        }
        else if (m_options.protocol == 'https:') {
            m_http = https;
            m_secure = true;
        }
        else {
            throw new HproseException("Unsupported protocol!");
        }
        m_options.method = "POST";
        m_options.headers = {"connection": "keep-alive"};
        return super_useService();
    }

    function setOption(option, value) {
        if (option != 'method' && option != 'headers') {
            m_options[option] = value;
        }
    }

    function setHeader(name, value) {
        var lname = name.toLowerCase();
        if (lname != 'content-type' &&
            lname != 'host') {
            if (value) {
                m_options.headers[lname] = value;
            }
            else {
                delete m_options.headers[lname];
            }
        }
    }

    this.on('senddata', function(invoker, data) {
        m_options.headers["content-length"] = data.length;
        var cookie = getCookie(m_options.host, m_options.path, m_secure);
        if (cookie != '') {
            m_options.headers['cookie'] = cookie;
        }
        var timeoutid;
        var request = m_http.request(m_options, function(response) {
            var bufferList = [];
            var bufferLength = 0;
            response.on("data", function(chunk) {
                bufferList.push(chunk);
                bufferLength += chunk.length;
            });
            response.on("end", function() {
                if (timeoutid) {
                    clearTimeout(timeoutid);
                    var data = Buffer.concat(bufferList, bufferLength);
                    if (response.statusCode == 200) {
                        invoker.emit('getdata', data);
                    }
                    else {
                        var e = new HproseException(response.statusCode + ':' +  data.toString());
                        invoker.emit('error', e);
                    }
                }
            });
            response.on('error', function(e) {
                clearTimeout(timeoutid);
                invoker.emit('error', e);
            });
            response.on('aborted', function() {
                if(timeoutid) {
                    clearTimeout(timeoutid);
                    invoker.emit('error', new HproseException('response aborted'));
                }
            });
            if (response.statusCode == 200) {
                setCookie(response.headers, m_options.host);
            }
        });

        timeoutid = setTimeout(function() {
            timeoutid = null;
            request.abort();
            invoker.emit('error', new HproseException("timeout"));
        }, this.getTimeout());

        request.on('error', function(e) {
            if (timeoutid) {
                clearTimeout(timeoutid);
                invoker.emit('error', e);
            }
        });
        request.end(data);
    });

    // public methods
    this.useService = useService;
    this.setOption = setOption;
    this.setHeader = setHeader;
}

util.inherits(HproseHttpClient, HproseClient);

module.exports = HproseHttpClient;