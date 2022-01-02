import 'package:flutter/material.dart';
import 'package:consumer_basket/helpers/logger.dart';
import 'app.dart';

void main() {
  Logger().info("Start app");
  runApp(const MyApp());
  Logger().info("Finish app");
}
