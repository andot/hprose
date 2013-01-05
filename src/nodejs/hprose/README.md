Usage of Hprose for Node.js
---------------------------

Hprose for Node.js is very easy to use. You can create a hprose server like this:

    function hello(name) {
        return "Hello " + name + "!";
    }
    var HproseHttpServer = require("hprose").server.HproseHttpServer;
    var server = new HproseHttpServer();
    server.addFunction(hello);
    server.listen(8080);

To start it use:

    node --harmony server.js

--harmony is a v8 options, hprose use it to optimize serialization.
This is not required option, but it is recommended to use it.

In fact most nodejs service methods are asynchronous, you can publish asynchronous
function like this:

    function hello(name, callback) {
        setTimeout(function() {
            callback("Hello " + name + "!");
        }, 10);
    }
    var HproseHttpServer = require("hprose").server.HproseHttpServer;
    var server = new HproseHttpServer();
    server.addAsyncFunction(hello);
    server.listen(8080);

Then you can create a hprose client to invoke it like this:

    var HproseHttpClient = require("hprose").client.HproseHttpClient;
    var client = new HproseHttpClient('http://127.0.0.1:8080/');
    var proxy = client.useService();
    proxy.hello("world", function(result) {
        console.log(result);
    });

To start it use:

    node --harmony client.js
    
or

    node --harmony-proxies client.js

Without --harmony-proxies, you can't use

    proxy.hello("world", function(result) {
        console.log(result);
    });

to invoke remote service. but you can invoke it like this:

    client.invoke("hello", "world", function(result) {
        console.log(result);
    });
