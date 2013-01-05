var hprose = require("hprose");

function hello(name) {
    return "Hello " + name + "!";
}

function asyncHello(name, callback) {
    callback("Hello " + name + "!");
}

var HproseHttpServer = hprose.server.HproseHttpServer;
var server = new HproseHttpServer();
server.setCrossDomainEnabled(true);
server.addFunction(hello);
server.addAsyncFunction(asyncHello);
server.setCrossDomainXmlFile('./crossdomain.xml');
server.on('sendError', function(message) {
    console.log(message);
});
server.listen(8080);