import 'dart:async';

import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/path_helper.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';

import 'basic_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
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
    final Color _splashTextColor = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
        body: Container(
            color: Theme.of(context).colorScheme.primary,
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: 180,
                      width: 180,
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
                      Constants.appTitleString,
                      style: Theme.of(context).primaryTextTheme.headline4!.copyWith(
                          color: _splashTextColor,
                          fontWeight: FontWeight.bold)
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:10),
                    child: Text(
                        "Version: ${Constants.appVersionString}",
                        style: Theme.of(context).primaryTextTheme.headline6!.copyWith(
                            color: _splashTextColor,
                            fontWeight: FontWeight.normal
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        top:50
                    ),
                    child: CircularProgressIndicator(
                      backgroundColor: _splashTextColor,
                      color: Constants.progressIndicatorSecondColor,
                    ),
                  ),
                ]
            )
        )
    );
  }
}
