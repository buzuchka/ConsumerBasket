import 'package:flutter/material.dart';

abstract class Language {

  static Language of(BuildContext context) {
    return Localizations.of<Language>(context, Language)!;
  }

  // Название приложения
  String get appName;

  // Версия
  String get versionString;

  // Название кнопки Списки в навигационной панели
  String get purchaseTemplatesButtonName;

  // Название кнопки Покупки в навигационной панели
  String get purchasesButtonName;

  // Название кнопки Товары в навигационной панели
  String get goodsButtonName;

  // Ошибка
  String get errorString;

  // Не выбран
  String get notSelectedString;

  // Без имени
  String get untitledString;

  // Товар
  String get goodsItemString;

  // Товары
  String get goodsString;

  // Название кнопки Удалить
  String get deleteButtonName;

  // Название
  String get titleString;

  // Примечание к товару
  String get goodsItemNoteName;

  // Цена не найдена
  String get priceNotFoundString;

  // Список
  String get purchaseTemplateString;

  // Ориентировочная сумма
  String get approximatedSumString;

  // Количество товаров
  String get goodsQuantityString;

  // Пусто
  String get emptyString;

  // Список товаров
  String get listOfGoodsString;

  // Товар не выбран
  String get goodsItemIsNotSelectedString;

  // Количество
  String get quantityString;

  // Покупка
  String get purchaseString;

  // Дата
  String get dateString;

  // Магазин
  String get shopString;

  // Сумма
  String get sumString;

  // Цена за единицу
  String get unitPriceString;

  // Цена за всё
  String get totalPriceString;

  // Магазин неизвестен
  String get shopIsUndefinedString;

  // Магазины
  String get shopsString;

  // Поиск
  String get searchString;

}