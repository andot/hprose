var hprose = require("hprose");
var formatter = hprose.io.Formatter;
var client = new HproseHttpClient('http://127.0.0.1:8080/');
//client.setSimpleMode();
client.on('error', function(func, e) {
    console.log(func, e);
});
var proxy = client.useService();
var start = new Date().getTime();
var max = 10;
var n = 0;
for (var i = 0; i < max; i++) {
    proxy.hello(i, function(result) {
        console.log(result);
        n++;
        if (n == max) {
            var end = new Date().getTime();
            console.log(end - start);
        }
    });
}
var end = new Date().getTime();
console.log(end - start);
proxy.getMaps("name", "age", "birthday", function(result) {
    console.log(result.toString());
    console.log(formatter.unserialize(result));
    console.log(formatter.serialize(formatter.unserialize(result)).toString());
}, HproseResultMode.Serialized);

proxy.getMaps("name", "age", "age", function(result) {
    console.log(result);
});
