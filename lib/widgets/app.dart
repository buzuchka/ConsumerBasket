import 'package:flutter/material.dart';

import 'package:consumer_basket/widgets/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black26,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            elevation: 0
          ),
          scaffoldBackgroundColor: Colors.white
        ),
        home: const SplashScreen()
    );
  }
}
