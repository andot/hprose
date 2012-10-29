Oh: Open Hprose
===============

*Hprose* is a High Performance Remote Object Service Engine. It is a modern,
lightweight, cross-language, cross-platform, object-oriented, high performance,
remote dynamic communication middleware. *Oh* means *Open Hprose*.

*Oh* is very easy to learn and use. and powerful. You only need a little time to
study, then you can use it to easily construct cross language cross platform
distributed application system.

Language support
----------------

*Oh* supports many programming languages, for example:

    * C++
    * .NET(C#, Visual Basic...)
    * Java
    * Delphi/Free Pascal
    * Objective-C
    * ActionScript
    * JavaScript
    * Node.js
    * Python
    * Ruby
    * PHP
    * ASP
    * Perl
    * ...

Through *Oh*, You can conveniently and efficiently intercommunicate between those
programming languages.

License
-------

*Oh* is free software, available with full source. it released under the MIT
License for non-commercial software. Commercial licenses are available for 
customers who wish to use *Hprose* for commercial software.

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
