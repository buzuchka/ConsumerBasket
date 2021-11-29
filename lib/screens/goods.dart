import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/goods.dart';

class GoodsScreen extends StatefulWidget {
  const GoodsScreen({Key? key}) : super(key: key);

  @override
  _GoodsScreenState createState() {
    return _GoodsScreenState();
  }
}

class _GoodsScreenState extends State<GoodsScreen> {
  final TextEditingController _titleTextController = TextEditingController();

  @override
  void initState() {
    _getAllGoodsItemsFromDatabase();
    super.initState();
  }

  void _getAllGoodsItemsFromDatabase() async {
    await DatabaseHelper.query(GoodsItem.tableName);
    setState(() {});
  }

  void _addGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.insert(GoodsItem.tableName, item);
    setState(() {});
  }

  void _openAddGoodsItemDialog(BuildContext context) {
    GoodsItem _goodsItem = GoodsItem();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add GoodsItem',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    autofocus: true,
                    controller: _titleTextController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            _titleTextController.clear();
                            Navigator.of(context).pop();
                          }
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          child: const Text('Add'),
                          onPressed: () {
                            _goodsItem.title = _titleTextController.text;
                            _titleTextController.clear();
                            _addGoodsItem2Database(_goodsItem);
                            Navigator.of(context).pop();
                          }
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }
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
                  final item = snapshot.data![position];
                  //get your item data here ...
                  return Card(
                    child: ListTile(
                      title: Text(
                          "Goods Name: " + item.row[1]),
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
