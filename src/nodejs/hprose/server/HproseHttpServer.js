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
 * HproseHttpServer.js                                    *
 *                                                        *
 * HproseHttpServer for Node.js.                          *
 *                                                        *
 * LastModified: Nov 5, 2012                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require("util");
var http = require("http");
var HproseHttpService = require('./HproseHttpService.js');

function HproseHttpServer() {
    HproseHttpService.call(this);
    var server = http.createServer(this.handle.bind(this));
    this.listen = function(port, hostname, backlog, callback) {
        server.listen(port, hostname, backlog, callback);
    };
    this.close = function(callback) {
        server.close(callback);
    }
    server.on('clientError', function(exception) {
        this.emit('sendError', exception);
    }.bind(this));
}

util.inherits(HproseHttpServer, HproseHttpService);

module.exports = HproseHttpServer;