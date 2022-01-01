import 'package:flutter/material.dart';

import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/widgets/image.dart';

Widget getShopWidget(Shop? shop, double height, {double? textFontSize, Color? textColor}) {
  textFontSize ??= 20.0;
  textColor ??= Colors.black;
  return Row(
    children: [
      Container(
        child: (shop == null)
            ? const SizedBox()
            : getImageWidget(shop.imagePath, 20.0, 20.0),
      ),
      Text(
        (shop == null)
            ? 'Not selected'
            : (shop.title != null)
            ? shop.title!
            : 'Untitled',
        style: TextStyle(
          fontSize: textFontSize,
          color: textColor,
        ),
      ),
    ],
  );
}