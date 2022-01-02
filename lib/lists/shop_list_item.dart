import 'package:flutter/material.dart';

import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/widgets/list_item_picture.dart';

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
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListItemPicture(imageFilePath: shop.imagePath),
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
      text = 'Untitled';
    }

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText1
    );
  }

}
