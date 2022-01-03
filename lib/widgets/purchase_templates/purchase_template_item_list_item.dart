import 'package:consumer_basket/helpers/price_and_quantity.dart';
import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/constants.dart';
import 'package:consumer_basket/models/purchase_template_item.dart';
import 'package:consumer_basket/widgets/base/image.dart';

// Элемент списка товаров в Списке - единица списка (товар+количество)
class PurchaseTemplateItemListItem extends StatelessWidget {
  final PurchaseTemplateItem item;

  const PurchaseTemplateItemListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.listItemPictureHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getGoodsItemImageWidget(),
          const SizedBox(width: Constants.spacing),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getGoodsItemTitleWidget(context),
                        _getPriceQuantityWidget(context),
                        _getTotlaPriceWidget(context),
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

  Widget _getGoodsItemImageWidget() {
    double _size = Constants.listItemPictureHeight;
    if(item.goodsItem != null) {
      return getImageWidget(item.goodsItem!.imagePath, _size, _size);
    }
    return getNoPhotoImageWidget(_size, _size);
  }

  Widget _getGoodsItemTitleWidget(BuildContext context) {
    String text;
    if(item.goodsItem == null) {
      text = 'Not selected';
    } else if(item.goodsItem!.title == null) {
      text = 'Untitled';
    } else {
      text = item.goodsItem!.title!;
    }
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText1
    );
  }

  // Widget _getQuantityWidget(BuildContext context) {
  //   String text;
  //   if(item.quantity != null) {
  //     text = item.quantity!.toString();
  //   } else {
  //     text = 'No quantity';
  //   }
  //
  //   return Text(
  //       text,
  //       style: Theme.of(context).textTheme.bodyText2
  //   );
  // }

  Widget _getPriceQuantityWidget(BuildContext context) {
    // String text;
    // if(item.lastUnitPrice != null) {
    //   text = item.lastUnitPrice!.toString();
    // } else {
    //   text = 'Last price unknown';
    // }
    return Text(
        makePriceQuantityString(item.lastUnitPrice, item.quantity),
        style: Theme.of(context).textTheme.bodyText2
    );
  }

  Widget _getTotlaPriceWidget(BuildContext context) {
    return Text(
        makeTotalPriceString(item.approximatedTotalPrice, isApproximated:true),
        style: Theme.of(context).textTheme.bodyText2
    );
  }

}
