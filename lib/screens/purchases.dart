import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/lists/purchase_list_item.dart';
import 'package:consumer_basket/models/purchase.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
            future: DatabaseHelper.purchasesRepository.getAll(),
            initialData: [],
            builder: (context, snapshot) {
              return (snapshot.connectionState != ConnectionState.waiting)
                  ? ListView.separated(
                padding: const EdgeInsets.all(10.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, int position) {
                  final currentPurchase = snapshot.data![position];
                  return InkWell(
                      child: PurchaseListItem(purchase: currentPurchase),
                      //onTap: () { _openUpdateGoodsItemDialog(context, currentPurchase); }
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
          onPressed: () {
            //_openAddGoodsItemDialog(context);
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
