import 'package:flutter/material.dart';
import 'package:consumer_basket/base/logger.dart';
import 'app.dart';

void main() {
  Logger().info("Start app");
  runApp(const MyApp());
  Logger().info("Finish app");
}
