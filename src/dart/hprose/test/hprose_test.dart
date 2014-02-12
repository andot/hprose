library hprose_tests;
import 'dart:typed_data';
import 'package:unittest/unittest.dart';
import 'package:hprose/hprose.dart' as hprose;

class User {
  String name;
  int age;
  bool _male;
  Function func;
  set male (bool value) => _male = value;
  bool get male => _male;
}

void main() {
  test('Serialize', () {
    expect(hprose.serialize(0).toString(), equals("0"));
    expect(hprose.serialize(1).toString(), equals("1"));
    expect(hprose.serialize(11).toString(), equals("i11;"));
    expect(hprose.serialize(1234567890987654321).toString(), equals("l1234567890987654321;"));
    expect(hprose.serialize(-42).toString(), equals("i-42;"));
    expect(hprose.serialize(3.14).toString(), equals("d3.14;"));
    expect(hprose.serialize(0.0).toString(), equals("d0.0;"));
    expect(hprose.serialize(double.NAN).toString(), equals("N"));
    expect(hprose.serialize(double.INFINITY).toString(), equals("I+"));
    expect(hprose.serialize(double.NEGATIVE_INFINITY).toString(), equals("I-"));
    expect(hprose.serialize(null).toString(), equals("n"));
    expect(hprose.serialize("").toString(), equals("e"));
    expect(hprose.serialize("c").toString(), equals("uc"));
    expect(hprose.serialize("我").toString(), equals("u我"));
    expect(hprose.serialize("我爱你").toString(), equals('s3"我爱你"'));
    expect(hprose.serialize([1,2,3,4,5]).toString(), equals("a5{12345}"));
    expect(hprose.serialize(["Jan", "Feb", "Mar", "Mar"]).toString(), equals('a4{s3"Jan"s3"Feb"s3"Mar"r3;}'));
    expect(hprose.serialize(["Jan", "Feb", "Mar", "Mar"], true).toString(), equals('a4{s3"Jan"s3"Feb"s3"Mar"s3"Mar"}'));
    Int32List int32List = new Int32List.fromList([1,2,3,4,5]);
    expect(hprose.serialize(int32List).toString(), equals('a5{12345}'));
    Uint8List uint8List = new Uint8List.fromList([48,49,50,51,52]);
    expect(hprose.serialize(uint8List).toString(), equals('b5"01234"'));
    Map map = {"name": "张三", "age": 28};
    expect(hprose.serialize(map).toString(), equals('m2{s4"name"s2"张三"s3"age"i28;}'));
    List<Map> mapList = [
      {"name": "张三", "age": 28},
      {"name": "李四", "age": 29},
      {"name": "王二麻子", "age": 30},
    ];
    expect(hprose.serialize(mapList).toString(), equals('a3{m2{s4"name"s2"张三"s3"age"i28;}m2{r2;s2"李四"r4;i29;}m2{r2;s4"王二麻子"r4;i30;}}'));
    expect(hprose.serialize(mapList, true).toString(), equals('a3{m2{s4"name"s2"张三"s3"age"i28;}m2{s4"name"s2"李四"s3"age"i29;}m2{s4"name"s4"王二麻子"s3"age"i30;}}'));
    User user = new User();
    user.name = "张三";
    user.age = 28;
    user.male = true;
    expect(hprose.serialize(user).toString(), equals('c4"User"3{s4"name"s3"age"s4"male"}o0{s2"张三"i28;t}'));
    User user2 = new User();
    user2.name = "李四";
    user2.age = 29;
    user2.male = true;
    User user3 = new User();
    user3.name = "王二麻子";
    user3.age = 30;
    user3.male = false;
    List<User> userList = [user, user2, user3, user];
    expect(hprose.serialize(userList).toString(), equals('a4{c4"User"3{s4"name"s3"age"s4"male"}o0{s2"张三"i28;t}o0{s2"李四"i29;t}o0{s4"王二麻子"i30;f}r4;}'));
    expect(hprose.serialize(userList, true).toString(), equals('a4{c4"User"3{s4"name"s3"age"s4"male"}o0{s2"张三"i28;t}o0{s2"李四"i29;t}o0{s4"王二麻子"i30;f}o0{s2"张三"i28;t}}'));
  });

  test('Unserialize', () {
    expect(hprose.unserialize(hprose.serialize(0)), equals(0));
    expect(hprose.unserialize(hprose.serialize(1)), equals(1));
    expect(hprose.unserialize(hprose.serialize(11)), equals(11));
    expect(hprose.unserialize(hprose.serialize(1234567890987654321)), equals(1234567890987654321));
    expect(hprose.unserialize(hprose.serialize(-42)), equals(-42));
    expect(hprose.unserialize(hprose.serialize(3.14)), equals(3.14));
    expect(hprose.unserialize(hprose.serialize(0.0)), equals(0.0));
    expect(hprose.unserialize(hprose.serialize(double.NAN)).isNaN, equals(true));
    expect(hprose.unserialize(hprose.serialize(double.INFINITY)), equals(double.INFINITY));
    expect(hprose.unserialize(hprose.serialize(double.NEGATIVE_INFINITY)), equals(double.NEGATIVE_INFINITY));
    expect(hprose.unserialize(hprose.serialize(null)), equals(null));
    expect(hprose.unserialize(hprose.serialize("")), equals(""));
    expect(hprose.unserialize(hprose.serialize("c")), equals("c"));
    expect(hprose.unserialize(hprose.serialize("我")), equals("我"));
    expect(hprose.unserialize(hprose.serialize("我爱你")), equals('我爱你'));
    expect(hprose.unserialize(hprose.serialize([1,2,3,4,5])), equals([1,2,3,4,5]));
    expect(hprose.unserialize(hprose.serialize(["Jan", "Feb", "Mar", "Mar"])), equals(["Jan", "Feb", "Mar", "Mar"]));
    expect(hprose.unserialize(hprose.serialize(["Jan", "Feb", "Mar", "Mar"], true)), equals(["Jan", "Feb", "Mar", "Mar"]));
    expect(hprose.unserialize(hprose.serialize(["Jan", "Feb", "Mar", "Mar"], true), true), equals(["Jan", "Feb", "Mar", "Mar"]));
    Int32List int32List = new Int32List.fromList([1,2,3,4,5]);
    expect(hprose.unserialize(hprose.serialize(int32List)), equals(int32List));
    Uint8List uint8List = new Uint8List.fromList([48,49,50,51,52]);
    expect(hprose.unserialize(hprose.serialize(uint8List)), equals(uint8List));
    Map map = {"name": "张三", "age": 28};
    expect(hprose.unserialize(hprose.serialize(map)), equals(map));
    List<Map> mapList = [
      {"name": "张三", "age": 28},
      {"name": "李四", "age": 29},
      {"name": "王二麻子", "age": 30},
    ];
    expect(hprose.unserialize(hprose.serialize(mapList)), equals(mapList));
    expect(hprose.unserialize(hprose.serialize(mapList, true)), equals(mapList));
    expect(hprose.unserialize(hprose.serialize(mapList, true), true), equals(mapList));
    User user = new User();
    user.name = "张三";
    user.age = 28;
    user.male = true;
    User user1 = hprose.unserialize(hprose.serialize(user));
    expect(user1.name, equals(user.name));
    expect(user1.age, equals(user.age));
    expect(user1.male, equals(user.male));
    User user2 = new User();
    user2.name = "李四";
    user2.age = 29;
    user2.male = true;
    User user3 = new User();
    user3.name = "王二麻子";
    user3.age = 30;
    user3.male = false;
    List<User> userList = [user, user2, user3, user];
    expect(hprose.serialize(hprose.unserialize(hprose.serialize(userList))).toString(), equals(hprose.serialize(userList).toString()));
    expect(hprose.serialize(hprose.unserialize(hprose.serialize(userList, true)), true).toString(), equals(hprose.serialize(userList, true).toString()));
    expect(hprose.serialize(hprose.unserialize(hprose.serialize(userList, true), true), true).toString(), equals(hprose.serialize(userList, true).toString()));
  });

}
