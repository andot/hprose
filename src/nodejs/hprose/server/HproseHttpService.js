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
 * HproseHttpService.js                                   *
 *                                                        *
 * HproseHttpService for Node.js.                         *
 *                                                        *
 * LastModified: Dec 6, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var fs = require("fs");
var util = require("util");
var HproseService = require("./HproseService.js");

function HproseHttpService() {
    var m_crossDomain = false;
    var m_P3P = false;
    var m_get = true;
    var m_timeout = 120000;
    var m_crossDomainXmlFile = null;
    var m_crossDomainXmlContent = null;
    var m_clientAccessPolicyXmlFile = null;
    var m_clientAccessPolicyXmlContent = null;
    var m_lastModified = (new Date()).toUTCString();
    var m_etag = '"' + Math.floor(Math.random() * 2147483647).toString(16) + ":" + Math.floor(Math.random() * 2147483647).toString(16) + '"';

    var crossDomainXmlHandler = function(request, response) {
        if (request.url.toLowerCase() == "/crossdomain.xml") {
            if (request.headers["if-modified-since"] == m_lastModified &&
                request.headers["if-none-match"] == m_etag) {
                response.statusCode = 304;
            }
            else {
                response.setHeader("Last-Modified", m_lastModified);
                response.setHeader("Etag", m_etag);
                response.setHeader("Content-Type", "text/xml");
                response.setHeader("Content-Length", m_crossDomainXmlContent.length);
                response.write(m_crossDomainXmlContent);
            }
            response.end();
            return true;
        }
        return false;
    }

    var clientAccessPolicyXmlHandler = function(request, response) {
        if (request.url.toLowerCase() == "/clientaccesspolicy.xml") {
            if (request.headers["if-modified-since"] == m_lastModified &&
                request.headers["if-none-match"] == m_etag) {
                response.statusCode = 304;
            }
            else {
                response.setHeader("Last-Modified", m_lastModified);
                response.setHeader("Etag", m_etag);
                response.setHeader("Content-Type", "text/xml");
                response.setHeader("Content-Length", m_clientAccessPolicyXmlContent.length);
                response.write(m_clientAccessPolicyXmlContent);
            }
            response.end();
            return true;
        }
        return false;
    }

    HproseService.call(this);

    // protected methods
    this._sendHeader = function(request, response) {
        this.emit('sendHeader', request, response);
        response.setHeader('Content-Type', "text/plain");
        if (m_P3P) {
            response.setHeader('P3P', 
                'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi ' +
                'CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL ' +
                'UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"');
        }
        if (m_crossDomain) {
            var origin = request.headers["origin"];
            if (origin && origin != "null") {
                response.setHeader('Access-Control-Allow-Origin', origin);
                response.setHeader('Access-Control-Allow-Credentials', 'true');  
            }
            else {
                response.setHeader('Access-Control-Allow-Origin', '*');
            }
        }
    }

    // public methods
    this.isCrossDomainEnabled = function() {
        return m_crossDomain;
    }

    this.setCrossDomainEnabled = function(enable) {
        if (enable === undefined) enable = true;
        m_crossDomain = enable;
    }

    this.isP3PEnabled = function() {
        return m_P3P;
    }

    this.setP3PEnabled = function(enable) {
        if (enable === undefined) enable = true;
        m_P3P = enable;
    }

    this.isGetEnabled = function() {
        return m_get;
    }

    this.setGetEnabled = function(enable) {
        if (enable === undefined) enable = true;
        m_get = enable;
    }

    this.getTimeout = function() {
        return m_timeout;
    }
    
    this.setTimeout = function(timeout) {
        m_timeout = timeout;
    }
    
    this.getCrossDomainXmlFile = function() {
        return m_crossDomainXmlFile;
    }

    this.setCrossDomainXmlFile = function(value) {
        m_crossDomainXmlFile = value;
        m_crossDomainXmlContent = fs.readFileSync(m_crossDomainXmlFile);
    }

    this.getCrossDomainXmlContent = function() {
        return m_crossDomainXmlContent;
    }

    this.setCrossDomainXmlContent = function(value) {
        m_crossDomainXmlFile = null;
        if (typeof(value) == "string") value = new Buffer(value);
        m_crossDomainXmlContent = value;
    }

    this.getClientAccessPolicyXmlFile = function() {
        return m_clientAccessPolicyXmlFile;
    }

    this.setClientAccessPolicyXmlFile = function(value) {
        m_clientAccessPolicyXmlFile = value;
        m_clientAccessPolicyXmlContent = fs.readFileSync(m_clientAccessPolicyXmlFile);
    }

    this.getClientAccessPolicyXmlContent = function() {
        return m_clientAccessPolicyXmlContent;
    }

    this.setClientAccessPolicyXmlContent = function(value) {
        m_clientAccessPolicyXmlFile = null;
        if (typeof(value) == "string") value = new Buffer(value);
        m_clientAccessPolicyXmlContent = value;
    }

    this.handle = function(request, response) {
        request.socket.setTimeout(m_timeout);
        var bufferList = [];
        var bufferLength = 0;
        request.on("data", function(chunk) {
            bufferList.push(chunk);
            bufferLength += chunk.length;
        });
        request.on("end", function() {
            if (m_clientAccessPolicyXmlContent != null && clientAccessPolicyXmlHandler(request, response)) return;
            if (m_crossDomainXmlContent != null && crossDomainXmlHandler(request, response)) return;
            this._sendHeader(request, response);
            response.on("end", function (data) {
                response.setHeader("Content-Length", data.length);
                response.end(data);
            });
            if ((request.method == "GET") && m_get) {
                this._doFunctionList(response);
            }
            else if (request.method == "POST") {
                var data = Buffer.concat(bufferList, bufferLength);
                this._handle(data, request, response);
            }
        }.bind(this));
    }
}

util.inherits(HproseHttpService, HproseService);

module.exports = HproseHttpService;