import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/models/goods.dart';

class GoodsListItem extends StatelessWidget {
  const GoodsListItem({
    Key? key,
    required this.goodsItem,
  }) : super(key: key);

  final GoodsItem goodsItem;

   Widget _getImageWidget() {
    if (goodsItem.imagePath != null) {
      return Image(
        image: FileImage(File(goodsItem.imagePath!)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
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
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (goodsItem.title != null) ? goodsItem.title! : 'Untitled',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
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
