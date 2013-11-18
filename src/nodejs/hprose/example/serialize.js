var util = require("util");
require("hprose");
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(0)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(1)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(9)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(10)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(-1)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(100000)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(12345678909876)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(Math.PI)));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(new Date())));
console.log(HproseFormatter.serialize("Hello World!").toString());
console.log(HproseFormatter.serialize("你好中国!").toString());
console.log(HproseFormatter.unserialize(HproseFormatter.serialize("Hello World!")));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize("你好中国!")));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(new Buffer("你好"))).toString());
console.log(HproseFormatter.unserialize(new Buffer("l1234567890987654321234567890;")));
console.log(HproseFormatter.unserialize(HproseFormatter.serialize(NaN)));
console.log(HproseFormatter.serialize(NaN).toString());
console.log(HproseFormatter.serialize(Infinity).toString());
console.log(HproseFormatter.serialize(-Infinity).toString());
console.log(HproseFormatter.serialize(true).toString());
console.log(HproseFormatter.serialize(false).toString());
console.log(HproseFormatter.serialize(undefined).toString());
console.log(HproseFormatter.serialize(null).toString());
console.log(HproseFormatter.serialize("").toString());
console.log(HproseFormatter.serialize(new Buffer(0)).toString());
console.log(HproseFormatter.serialize([3,3,4,5]).toString());

var s = HproseFormatter.serialize({"name": "MaBingyao", "alias": "MaBingyao", "age": 32, "sex": "male"});
console.log(s.toString());
console.log(HproseFormatter.unserialize(s));
function User(name, age) {
    this.name = name;
    this.age = age;
}
HproseClassManager.register(User, "MyUser");
var user1 = new User("马秉尧", 32);
var user2 = new User("周静", 28);
s = HproseFormatter.serialize([user1, user2, user1, user2]);
console.log(s.toString());
console.log(HproseFormatter.unserialize(s));
var arr = ['name', 'sex', 'sex'];
s = HproseFormatter.serialize(arr);
console.log(s.toString());
console.log(HproseFormatter.unserialize(s));

// Test HarmonyMaps
var map = new Map();
console.log(map);
