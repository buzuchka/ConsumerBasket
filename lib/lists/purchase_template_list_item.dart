import 'package:flutter/material.dart';

import 'package:consumer_basket/models/purchase_template.dart';

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
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _getTitleWidget())
        ],
      ),
    );
  }

  Widget _getTitleWidget() {
    if(purchaseTemplate.title == null) {
      return const Text(
          'Untitled',
          style: TextStyle(
            fontSize: 18
          )
      );
    }
    return Text(purchaseTemplate.title!);
  }

}
