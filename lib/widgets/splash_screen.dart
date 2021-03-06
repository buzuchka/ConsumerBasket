import 'dart:async';

import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/path_helper.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';

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
                  SizedBox(height: 120),
                  Column(
                    children: [
                      Row (
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: const AssetImage(PathHelper.launchIconFilePath),
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                            color: _splashTextColor,
                          ),
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left:30),
                                child: Text(
                                  'Costs',
                                  style: Theme.of(context).primaryTextTheme.headline4!.copyWith(
                                      color: _splashTextColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                )
                              ),
                              Text(
                                'Better',
                                style: Theme.of(context).primaryTextTheme.headline4!.copyWith(
                                    color: _splashTextColor,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ]
                      ),
                      Container(
                        margin: const EdgeInsets.only(top:20),
                        child: Text(
                            "${Language.of(context).versionString}: ${Constants.appVersionString}",
                            style: Theme.of(context).primaryTextTheme.headline6!.copyWith(
                                color: _splashTextColor,
                                fontWeight: FontWeight.normal
                            ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top:70),
                        child: CircularProgressIndicator(
                          backgroundColor: _splashTextColor,
                          color: Constants.progressIndicatorSecondColor,
                        ),
                      ),
                    ]
                  ),
                ]
            )
        )
    );
  }
}
