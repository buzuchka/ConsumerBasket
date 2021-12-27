import 'package:flutter/material.dart';
import 'package:consumer_basket/common/logger.dart';
import 'app.dart';
import 'package:consumer_basket/repositories/db_field.dart';

abstract class BaseClass {

  final Logger _logger = Logger("BaseClass");

  String a = "aa";

  void func<T>(List<T> val){
    print("Base::func()");
  }

  void log1(){
    _logger.info("log1");
  }
}


class OtherClaass {
  int b = 0;
  int? optb;
}



class ChildClass  extends BaseClass {

  Logger _logger = Logger("ChildClass");

  int Function(OtherClaass)? getB;

  @override
  void func<T>(List<T> val){
     print("ChildClass::func(): ${T.toString()}");
  }

  void log2(OtherClaass other){
    super.log1();
    _logger.info("log2");
    _logger.info("b = ${getB!(other)}");
  }
}

void main() {

  // Logger().warning("ololol");
  //
  // Logger("main()").warning("ololol");
  //
  // var logger = Logger("main()");
  // logger.info("message");
  //
  // logger.subModule("subFunc()").subModule("subSubFunc()").error("errror");

  ChildClass obj = ChildClass();
  BaseClass b = obj;

  Map <int, ChildClass> chs = {};
  chs[1] = obj;
  obj.a = 'a1';
  print("chs[1]!.a=${chs[1]!.a}");

  OtherClaass other = OtherClaass();
  other.b = 4242;




  var fieldB = DbField<OtherClaass,int>(
      "field_name",
      "integer",
      (OtherClaass obj) => obj.b,
      (OtherClaass obj, int b) => obj.b = b,
  );

  var fieldOptB = DbField<OtherClaass,int?>(
    "field_name",
    "integer",
        (OtherClaass obj) => obj.optb,
        (OtherClaass obj, int? optb) => obj.optb = optb,
  );

  fieldB.abstractSet(other, 123);
  print("b = ${fieldB.abstractGet(other)}");
  fieldB.abstractSet(other, null);
  print("b = ${fieldB.abstractGet(other)}");
  fieldB.abstractSet(other, 321);
  print("b = ${fieldB.abstractGet(other)}");


  fieldOptB.abstractSet(other, 123);
  print("optb = ${fieldOptB.abstractGet(other)}");
  fieldOptB.abstractSet(other, null);
  print("optb = ${fieldOptB.abstractGet(other)}");
  fieldOptB.abstractSet(other, 321);
  print("optb = ${fieldOptB.abstractGet(other)}");

  List<int> a = [];
  b.func(a);
  obj.log1();
  obj.getB = (OtherClaass o) => o.b;
  obj.log2(other);

  ChildClass? obj2;

  String? a_str = obj2?.a;

  print("a_str=$a_str");

  runApp(const MyApp());
}
