import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/widgets/shop.dart';

class PurchaseListItem extends StatelessWidget {
  final Purchase purchase;

  static final DateFormat viewDateFormat = DateFormat("dd.MM.yyyy");

  const PurchaseListItem({
    Key? key,
    required this.purchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (purchase.shop == null)
              ? const Text(
                  'Shop is undefined',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              :  getShopWidget(purchase.shop, 20, textFontSize: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          viewDateFormat.format(purchase.date).toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Sum Here',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
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
}
