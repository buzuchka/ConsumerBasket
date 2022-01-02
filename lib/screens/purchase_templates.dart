import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/lists/purchase_template_list_item.dart';
import 'package:consumer_basket/models/purchase_template.dart';
import 'package:consumer_basket/screens/purchase_template_edit.dart';
import 'package:consumer_basket/widgets/list_future_builder.dart';

// Окно со списком всех Списков
class PurchaseTemplatesScreen extends StatefulWidget {
  const PurchaseTemplatesScreen({Key? key}) : super(key: key);

  @override
  _PurchaseTemplatesScreenState createState() {
    return _PurchaseTemplatesScreenState();
  }
}

class _PurchaseTemplatesScreenState extends State<PurchaseTemplatesScreen> {

  @override
  void initState() {
    super.initState();
  }

  void _rebuildScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: getListFutureBuilder(
              RepositoriesHelper.purchaseTemplatesRepository.getOrderedByDate(),
              (PurchaseTemplate purchaseTemplate) => PurchaseTemplateListItem(purchaseTemplate: purchaseTemplate),
              onTap: editItemOnTap(
                (PurchaseTemplate purchaseTemplate) => PurchaseTemplateEditScreen(purchaseTemplate:purchaseTemplate),
                () => _rebuildScreen()
              )
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            PurchaseTemplate newPurchaseTemplate = PurchaseTemplate();
            await RepositoriesHelper.purchaseTemplatesRepository.insert(newPurchaseTemplate);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PurchaseTemplateEditScreen(
                      purchaseTemplate: newPurchaseTemplate)
              ),
            );
            _rebuildScreen();
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
