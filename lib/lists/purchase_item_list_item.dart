import 'package:flutter/material.dart';

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
          const SizedBox(width: 20.0),
          Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _getGoodsItemTitleWidget(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _getUnitPriceWidget(),
                            const Text(" x "),
                            _getQuantityWidget(),
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
    double _size = 100.0;
    if(item.goodsItem != null) {
      return getImageWidget(item.goodsItem!.imagePath, _size, _size);
    }
    return getNoPhotoImageWidget(_size, _size);
  }

  Widget _getGoodsItemTitleWidget() {
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
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _getTotalPriceWidget() {
    String text;
    if(item.totalPrice != null) {
      text = createPriceString(item.totalPrice!.toString());
    } else {
      text = 'No total price';
    }
    return Text(text);
  }

  Widget _getUnitPriceWidget() {
    String text;
    if(item.unitPrice != null) {
      text = createPriceString(item.unitPrice!.toString());
    } else {
      text = 'No unit price';
    }
    return Text(text);
  }

  Widget _getQuantityWidget() {
    String text;
    if(item.quantity != null) {
      text = item.quantity!.toString();
    } else {
      text = 'No quantity';
    }

    return Text(text);
  }

}
