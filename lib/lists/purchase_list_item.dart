import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/constants.dart';
import 'package:consumer_basket/helpers/price_and_quantity.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/widgets/shop.dart';

// Элемент списка Покупки - Покупка
class PurchaseListItem extends StatelessWidget {
  final Purchase purchase;

  static final DateFormat viewDateFormat = DateFormat(Constants.viewDateFormatString);

  const PurchaseListItem({
    Key? key,
    required this.purchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.listItemNoPictureHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getShopWidget(context),
          const SizedBox(width: Constants.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _getDateWidget(context),
                      _getSumWidget(context),
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

  Widget _getShopWidget(BuildContext context) {
    var textTheme = Theme.of(context).textTheme.headline6;
    if(purchase.shop == null) {
      return Text(
          'Shop is undefined',
          style: textTheme
      );
    }
    return getShopWidget(purchase.shop, textTheme!);
  }

  Widget _getDateWidget(BuildContext context) {
    return Text(
      viewDateFormat.format(purchase.date).toString(),
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText2
    );
  }

  Widget _getSumWidget(BuildContext context) {
    return Text(
      createPriceString(purchase.amount.toString()),
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText2!
        .copyWith(color: Theme.of(context).colorScheme.primary)
    );
  }

}
