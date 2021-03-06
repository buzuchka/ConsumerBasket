import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/price_and_quantity.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/goods.dart';

import 'package:consumer_basket/widgets/base/image.dart';

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
          getImageWidget(
              goodsItem.imagePath,
              Constants.listItemPictureSize,
              Constants.listItemPictureSize
          ),
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

                    ],
                  ),
                ),
              ],
            ),
          ),
          Column (
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _getLastPriceWidget(context),
            ],
          )
        ],
      ),
    );
  }

  Widget _getTitleWidget(BuildContext context) {
    String text;
    if(goodsItem.title != null) {
      text = goodsItem.title!;
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

  Widget _getLastPriceWidget(BuildContext context) {
    String text;
    var lastPrice = goodsItem.lastPurchaseUnitPrice;
    if(lastPrice != null) {
      text = makePriceString(lastPrice);
    } else {
      text = Language.of(context).priceNotFoundString;
    }

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText2
    );
  }

}
