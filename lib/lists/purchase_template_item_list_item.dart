import 'package:flutter/material.dart';

import 'package:consumer_basket/models/purchase_template_item.dart';
import 'package:consumer_basket/widgets/image.dart';

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
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getGoodsItemImageWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getGoodsItemTitleWidget(),
                        _getQuantityWidget(),
                      ],
                    ),
                  ),
                ],
              ),
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
