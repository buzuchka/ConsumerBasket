import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/lists/purchase_list_item.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/screens/purchase_edit.dart';

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
        body: FutureBuilder<Map>(
            future: DatabaseHelper.purchasesRepository.getAll(),
            initialData: {},
            builder: (context, snapshot) {
              return (snapshot.connectionState != ConnectionState.waiting)
                  ? ListView.separated(
                padding: const EdgeInsets.all(10.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, int position) {
                  final currentPurchase = snapshot.data!.values.elementAt(position);
                  return InkWell(
                      child: PurchaseListItem(purchase: currentPurchase),
                      onTap: () async {
                        final isNeed2Rebuild = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PurchaseEditScreen(
                                  purchase: currentPurchase)
                          ),
                        );
                        if(isNeed2Rebuild) {
                          _rebuildScreen();
                        }
                      }
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              )
                  : const Center(
                  child: SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.deepPurple,
                        color: Colors.grey,
                      )
                  )
              );
            }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Purchase newPurchase = Purchase();
            await DatabaseHelper.purchasesRepository.insert(newPurchase);
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
