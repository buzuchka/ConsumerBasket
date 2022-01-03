import 'package:flutter/material.dart';

import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/widgets/base/image.dart';

Widget getShopWidget(Shop? shop, TextStyle textStyle) {
  double _imageSize = textStyle.fontSize! + 5.0;
  return Row(
    children: [
      Container(
        child: (shop == null)
            ? const SizedBox()
            : getImageWidget(shop.imagePath, _imageSize, _imageSize),
      ),
      Text(
        (shop == null)
            ? 'Not selected'
            : (shop.title != null)
            ? shop.title!
            : 'Untitled',
        style: textStyle
      ),
    ],
  );
}