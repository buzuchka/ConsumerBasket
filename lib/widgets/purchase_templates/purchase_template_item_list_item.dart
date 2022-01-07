import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/price_and_quantity.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/purchase_template_item.dart';

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
      text = Language.of(context).notSelectedString;
    } else if(item.goodsItem!.title == null) {
      text = Language.of(context).untitledString;
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
    return Text(makeTotalPriceString(
        item.approximatedTotalPrice,
        isApproximated: true)
    );
  }

  Widget _getPriceQuantityWidget() {
    return Text(makePriceQuantityString(item.lastUnitPrice, item.quantity));
  }

}
