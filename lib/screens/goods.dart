import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/dialogs/goods_item_edit_dialog.dart';
import 'package:consumer_basket/models/goods.dart';

class GoodsScreen extends StatefulWidget {
  const GoodsScreen({Key? key}) : super(key: key);

  @override
  _GoodsScreenState createState() {
    return _GoodsScreenState();
  }
}

class _GoodsScreenState extends State<GoodsScreen> {

  @override
  void initState() {
    _getAllGoodsItemsFromDatabase();
    super.initState();
  }

  void _getAllGoodsItemsFromDatabase() async {
    await DatabaseHelper.query(GoodsItem.tableName);
    setState(() {});
  }

  void _openAddGoodsItemDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GoodsItemEditDialog(onDataChanged: () => setState(() {}));
        }
    );
  }

  void _openUpdateGoodsItemDialog(BuildContext context, GoodsItem goodsItem) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return GoodsItemEditDialog(
          goodsItem: goodsItem,
          onDataChanged: () => setState(() {})); }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
            future: DatabaseHelper.query(GoodsItem.tableName),
            initialData: [],
            builder: (context, snapshot) {
              return (snapshot.connectionState != ConnectionState.waiting)
                  ? ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (_, int position) {
                  final currentGoodsItem = GoodsItem.fromMap(snapshot.data![position]);
                  return Card(
                    child: ListTile(
                      title: Text(
                          "Goods Name: " + currentGoodsItem.title!),
                      onTap: () { _openUpdateGoodsItemDialog(context, currentGoodsItem); }
                    ),
                  );
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
            _openAddGoodsItemDialog(context);
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
