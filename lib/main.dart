import 'package:flutter/material.dart';

import 'package:consumer_basket/widgets/app.dart';


class Dummy {
  int val = 42;

  getLamda() {
    return () => val;
  }
}



void main() {
  Dummy d = Dummy();
  var lam = d.getLamda();
  print("lam: ${lam()}" );
  d.val = 146;
  print("lam: ${lam()}" );
  runApp(const MyApp());
}
