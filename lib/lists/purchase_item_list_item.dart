import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/constants.dart';
import 'package:consumer_basket/helpers/price_and_quantity.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/widgets/image.dart';

// Элемент списка товаров в Покупке - единица покупки (товар+цена+количество)
class PurchaseItemListItem extends StatelessWidget {
  final PurchaseItem item;

  const PurchaseItemListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getGoodsItemImageWidget(),
          const SizedBox(width: Constants.spacing),
          Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _getGoodsItemTitleWidget(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _getPriceQuantityWidget()
                          ],
                        ),
                        _getTotalPriceWidget(),
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

  Widget _getTotalPriceWidget() {
    return Text(makeTotalPriceString(item.totalPrice));
  }

  Widget _getPriceQuantityWidget() {
    return Text(makePriceQuantityString(item.unitPrice, item.quantity));
  }

}
