import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/models/purchase_template.dart';

// Элемент списка Списки - Список
class PurchaseTemplateListItem extends StatelessWidget {
  final PurchaseTemplate purchaseTemplate;

  const PurchaseTemplateListItem({
    Key? key,
    required this.purchaseTemplate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.listItemNoPictureHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _getTitleWidget(context)),

        ],
      ),
    );
  }

  Widget _getTitleWidget(BuildContext context) {
    String text;
    if(purchaseTemplate.title == null) {
      text = 'Untitled';
    } else {
      text = purchaseTemplate.title!;
    }
    return Text(
        text,
        style: Theme.of(context).textTheme.headline6!.copyWith(
          fontWeight: FontWeight.normal
        )
    );
  }

  // Widget _getPriceWidget(BuildContext context) {
  //   String text;
  //   if(purchaseTemplate == null) {
  //     text = 'Untitled';
  //   } else {
  //     text = purchaseTemplate.title!;
  //   }
  //   return Text(
  //       text,
  //       style: Theme.of(context).textTheme.headline6!.copyWith(
  //           fontWeight: FontWeight.normal
  //       )
  //   );
  // }

}
