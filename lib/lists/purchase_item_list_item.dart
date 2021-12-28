import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/models/purchase_item.dart';

class PurchaseItemListItem extends StatelessWidget {
  final PurchaseItem item;

  const PurchaseItemListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  Widget _getImageWidget() {
    if ((item.goodsItem != null) &&
        (item.goodsItem!.imagePath != null)) {
      return Image(
          image: FileImage(File(item.goodsItem!.imagePath!)),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    }
    else {
      return const AspectRatio(
          aspectRatio: 1.0,
          child: Image(
              image: AssetImage('assets/images/no_photo.jpg'),
              fit: BoxFit.cover)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _getImageWidget(),
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
                        Text(
                          (item.goodsItem != null && item.goodsItem!.title != null)
                              ? item.goodsItem!.title!
                              : 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          (item.price != null)
                              ? item.price!.toString()
                              : 'No price',
                        ),
                        Text(
                          (item.quantity != null)
                              ? item.quantity!.toString()
                              : 'No quantity',
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
