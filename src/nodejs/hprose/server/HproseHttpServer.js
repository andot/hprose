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
 * LastModified: Oct 27, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var util = require("util");
var http = require("http");
var HproseHttpService = require('./HproseHttpService.js');

function HproseHttpServer() {
    HproseHttpService.call(this);
    var server = http.createServer(this.handle.bind(this));
    var self = this;
    this.listen = function(port, hostname, backlog, callback) {
        server.listen(port, hostname, backlog, callback);
    };
    this.close = function(callback) {
        server.close(callback);
    }
    server.on('clientError', function(exception) {
        if (self.onSendError != null) {
            self.onSendError(error);
        }
        else {
            self.emit('sendError', error);
        }
    });
}

util.inherits(HproseHttpServer, HproseHttpService);

module.exports = HproseHttpServer;