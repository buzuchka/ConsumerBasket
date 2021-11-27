import 'package:flutter/material.dart';

import 'basic_bottom_navigation_bar.dart';
import 'package:consumer_basket/common/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.init();

  runApp(new MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: BasicBottomNavigationBar()));
}
