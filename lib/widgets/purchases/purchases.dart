import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/models/purchase.dart';
import 'package:consumer_basket/widgets/base/list_future_builder.dart';
import 'package:consumer_basket/widgets/purchases/purchase_edit.dart';
import 'package:consumer_basket/widgets/purchases/purchase_list_item.dart';

// Окно со списком всех покупок
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({Key? key}) : super(key: key);

  @override
  _PurchasesScreenState createState() {
    return _PurchasesScreenState();
  }
}

class _PurchasesScreenState extends State<PurchasesScreen> {

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
              RepositoriesHelper.purchasesRepository.getOrderedByDate(),
              (Purchase purchase) => PurchaseListItem(purchase: purchase),
              onTap: editItemOnTap(
                (Purchase purchase) => PurchaseEditScreen(purchase:purchase),
                () => _rebuildScreen()
              )
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Purchase newPurchase = Purchase();
            await RepositoriesHelper.purchasesRepository.insert(newPurchase);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PurchaseEditScreen(
                      purchase: newPurchase)
              ),
            );
            _rebuildScreen();
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
