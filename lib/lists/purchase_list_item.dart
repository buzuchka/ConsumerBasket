import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/models/purchase.dart';

class PurchaseListItem extends StatelessWidget {
  final Purchase purchase;

  const PurchaseListItem({
    Key? key,
    required this.purchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Text(
              (purchase.shopId != null) ? purchase.shopId.toString() : 'Shop is undefined',
              maxLines: 2,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            purchase.date!,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Sum Here',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.green,
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
      ),
    );
  }
}
