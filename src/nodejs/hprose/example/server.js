var hprose = require("../hprose.js");

function hello(name) {
    return "Hello " + name + "!";
}
var HproseHttpServer = hprose.server.HproseHttpServer;
var server = new HproseHttpServer();
server.setCrossDomainEnabled(true);
server.addFunction(hello);
server.on('sendError', function(message) {
    console.log(message);
});
server.listen(8080);



