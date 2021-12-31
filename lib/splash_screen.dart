import 'dart:async';

import 'package:flutter/material.dart';

import 'helpers/path_helper.dart';
import 'helpers/repositories_helper.dart';

import 'basic_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  final Color _splashTextColor = Colors.white;

  late DateTime _startDateTime;
  late DateTime _endDateTime;

  final int _defaultSplashTime = 3; // minimum (desired) duration of splash screen on second

  startInitialization() async {
    _startDateTime = DateTime.now();
    _endDateTime = _startDateTime.add(Duration(seconds: _defaultSplashTime));

    await initialization();

    // Если инициализация выполнилась менее чем за _defaultSplashTime,
    // запускаем дополнительный таймер с оставшимся временем
    DateTime currentDateTime = DateTime.now();
    if(currentDateTime.isBefore(_endDateTime)) {
      int msecsDiff = _endDateTime.millisecondsSinceEpoch - currentDateTime.millisecondsSinceEpoch;
      return Future.delayed(Duration(
          milliseconds: msecsDiff),
          () { afterInitialization() ;});
    }

    afterInitialization();
  }

  initialization() async {
    // Инициализация БД
    await RepositoriesHelper.init();

    // Инициализация путей до папок приложения
    await PathHelper.init();
  }

  afterInitialization() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return const BasicScreen();
        })
    );
  }

  @override
  void initState() {
    super.initState();
    startInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Theme.of(context).primaryColor,
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: 200,
                      width: 200,
                      child: FittedBox(
                          child: Icon(
                              Icons.shopping_cart_outlined,
                              color: _splashTextColor
                          )
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:30),
                    child: Text(
                      "Consumer Basket",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: _splashTextColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:10),
                    child: Text(
                        "Version: 0.0.1",
                        style: TextStyle(
                          fontSize: 20,
                          color: _splashTextColor,
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:50),
                    child: CircularProgressIndicator(backgroundColor: _splashTextColor,),
                  ),
                ]
            )
        )
    );
  }
}
