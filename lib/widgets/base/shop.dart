import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/shop.dart';

import 'package:consumer_basket/widgets/base/image.dart';

Widget getShopWidget(
    BuildContext context,
    Shop? shop,
    TextStyle textStyle
    ) {
  double _imageSize = textStyle.fontSize! + 5.0;
  return Row(
    children: [
      Container(
        child: (shop == null)
            ? const SizedBox()
            : Row(
                children: [
                  getImageWidget(shop.imagePath, _imageSize, _imageSize),
                  const SizedBox(width: Constants.spacing/2),
                ]
              )
      ),
      Text(
        (shop == null)
            ? Language.of(context).notSelectedString
            : (shop.title != null)
            ? shop.title!
            : Language.of(context).untitledString,
        style: textStyle
      ),
    ],
  );
}