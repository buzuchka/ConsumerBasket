import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/shop.dart';
import 'package:consumer_basket/widgets/base/image.dart';

// Элемент списка Магазины - Магазин
class ShopListItem extends StatelessWidget {
  final Shop shop;

  const ShopListItem({
    Key? key,
    required this.shop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.listItemPictureHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getImageWidget(
              shop.imagePath,
              Constants.listItemPictureSize,
              Constants.listItemPictureSize
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _getShopTitleWidget(context)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getShopTitleWidget(BuildContext context) {
    String text;
    if(shop.title != null) {
      text = shop.title!;
    } else {
      text = Language.of(context).untitledString;
    }

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.headline6!.copyWith(
          fontWeight: FontWeight.normal
      )
    );
  }

}
