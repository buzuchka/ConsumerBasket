import 'package:flutter/material.dart';

import 'package:consumer_basket/base/logger.dart';

import 'package:consumer_basket/widgets/app.dart';

void main() {
  Logger().info("Start app");
  runApp(const MyApp());
  Logger().info("Finish app");
}
