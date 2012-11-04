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
 * LastModified: Nov 4, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require("util");
var HproseService = require("./HproseService.js");
var HproseBufferInputStream = require('../io/HproseBufferInputStream.js');
var HproseBufferOutputStream = require('../io/HproseBufferOutputStream.js');
var HproseReader = require('../io/HproseReader.js');
var HproseWriter = (typeof(Map) === 'undefined') ? require('../io/HproseWriter.js') : require('../io/HproseWriter2.js');

function HproseHttpService() {
    var m_crossDomain = false;
    var m_P3P = false;
    var m_get = true;
    var self = this;
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

    this.handle = function(request, response) {
        var bufferList = [];
        var bufferLength = 0;
        request.on("data", function(chunk) {
            bufferList.push(chunk);
            bufferLength += chunk.length;
        });
        request.on("end", function() {
            var data = Buffer.concat(bufferList, bufferLength);
            var reader = new HproseReader(new HproseBufferInputStream(data));
            var writer = new HproseWriter(new HproseBufferOutputStream());
            self._sendHeader(request, response);
            if ((request.method == "GET") && m_get) {
                self._doFunctionList(writer);
            }
            else if (request.method == "POST") {
                self._handle(reader, writer, request);
            }
            response.end(writer.stream.toBuffer());
        });
    }
}

util.inherits(HproseHttpService, HproseService);

module.exports = HproseHttpService;