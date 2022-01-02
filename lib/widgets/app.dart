import 'package:flutter/material.dart';

import 'package:consumer_basket/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme(
            primary: Colors.deepPurple,
            primaryVariant: Colors.purple,
            secondary: Colors.pink.shade400,
            secondaryVariant: Colors.pink.shade800,
            surface: Colors.green,
            background: Colors.cyan,
            error: Colors.red,
            onPrimary: Colors.white,    //!
            onSecondary: Colors.white,  //!
            onSurface: Colors.amberAccent,
            onBackground: Colors.indigo,
            onError: Colors.indigoAccent,
            brightness: Brightness.light
          ),
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
