Usage of Hprose for Node.js
---------------------------

Hprose for Node.js is very easy to use. You can create a hprose server like this:

<pre lang="javascript">
require("hprose");
function hello(name) {
    return "Hello " + name + "!";
}
var server = new HproseHttpServer();
server.addFunction(hello);
server.listen(8080);
</pre>

To start it use:

    node --harmony server.js

--harmony is a v8 options, hprose use it to optimize serialization.
This is not required option, but it is recommended to use it.

In fact most nodejs service methods are asynchronous, you can publish asynchronous
function like this:

<pre lang="javascript">
require("hprose");
function hello(name, callback) {
    setTimeout(function() {
        callback("Hello " + name + "!");
    }, 10);
}
var server = new HproseHttpServer();
server.addAsyncFunction(hello);
server.listen(8080);
</pre>

Then you can create a hprose client to invoke it like this:

<pre lang="javascript">
require("hprose");
var client = new HproseHttpClient('http://127.0.0.1:8080/');
var proxy = client.useService();
proxy.hello("world", function(result) {
    console.log(result);
});
</pre>

To start it use:

    node --harmony client.js
    
or

    node --harmony-proxies client.js

Without --harmony-proxies, you can't use

<pre lang="javascript">
proxy.hello("world", function(result) {
    console.log(result);
});
</pre>

to invoke remote service. but you can invoke it like this:

<pre lang="javascript">
client.invoke("hello", "world", function(result) {
    console.log(result);
});
</pre>
