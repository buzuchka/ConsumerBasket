import 'package:flutter/material.dart';

class Constants {
  static const String appTitleString = "Consumer Basket";
  static const String appVersionString = "0.0.1";

  static const String viewDateFormatString = "dd.MM.yyyy";
  static String currentCurrencyString = "р.";

  // Обычный размер картинки
  static const double pictureSize = 100.0;
  // Размер картинки в элементе списка
  static const double listItemPictureSize = pictureSize;

  // Высота элемента списка с картинкой
  static const double listItemPictureHeight = listItemPictureSize;
  // Высота элемента списка без картинки
  static const double listItemNoPictureHeight = 70.0;

  static const double spacing = 10.0;

  static const Color progressIndicatorSecondColor = Colors.grey;
  static const double progressIndicatorSize = 100.0;
}