import 'package:consumer_basket/helpers/price_and_quantity.dart';
import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/constants.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/widgets/list_item_picture.dart';

// Элемент списка Товары - Товар
class GoodsListItem extends StatelessWidget {
  final GoodsItem goodsItem;

  const GoodsListItem({
    Key? key,
    required this.goodsItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.listItemPictureHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListItemPicture(imageFilePath: goodsItem.imagePath),
          const SizedBox(width: Constants.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _getTitleWidget(context),
                      _getLastPriceWidget(context),
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

  Widget _getTitleWidget(BuildContext context) {
    String text;
    if(goodsItem.title != null) {
      text = goodsItem.title!;
    } else {
      text = 'Untitled';
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

  Widget _getLastPriceWidget(BuildContext context) {
    String text;
    var lastPrice = goodsItem.lastPurchaseUnitPrice;
    if(lastPrice != null) {
      text = createPriceString(lastPrice.toString());
    } else {
      text = 'price not found';
    }

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText2
    );
  }

}
