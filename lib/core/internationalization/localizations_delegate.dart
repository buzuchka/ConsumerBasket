import 'package:flutter/material.dart';

import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/internationalization/languages/language_en.dart';
import 'package:consumer_basket/core/internationalization/languages/language_ru.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Language> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<Language> load(Locale locale) => _load(locale);

  static Future<Language> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'ru':
        return LanguageRu();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Language> old) => false;
}