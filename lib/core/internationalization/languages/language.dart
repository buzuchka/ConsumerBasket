import 'package:flutter/material.dart';

abstract class Language {

  static Language of(BuildContext context) {
    return Localizations.of<Language>(context, Language)!;
  }

  // Название приложения
  String get appName;

  // Версия
  String get versionText;

  // Название кнопки Списки в навигационной панели
  String get purchaseTemplatesButtonName;

  // Название кнопки Покупки в навигационной панели
  String get purchasesButtonName;

  // Название кнопки Товары в навигационной панели
  String get goodsButtonName;

}