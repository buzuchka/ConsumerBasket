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
  List<GoodsItem> _goodsItemList = [];

  final TextEditingController _titleTextController = TextEditingController();

  Widget _buildGoodItem(BuildContext context, int index) {
    return Card(
      child: Row(
        children: <Widget>[
          Icon(Icons.devices_other),
          Text(_goodsItemList[index].title ?? '',
               style: TextStyle(color: Colors.deepPurple))
        ],
      ),
    );
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DatabaseHelper.query(GoodsItem.tableName);
    _goodsItemList = _results.map((item) => GoodsItem.fromMap(item)).toList();
    setState(() { });
  }

  void _addGoodsItem2Database(GoodsItem item) async {
    var _currentId = await DatabaseHelper.insert(GoodsItem.tableName, item);
    setState(() {
      _goodsItemList.add(GoodsItem.Full(_currentId, item.title));
    });
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
      body: ListView.builder(
        itemBuilder: _buildGoodItem,
        itemCount: _goodsItemList.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _openAddGoodsItemDialog(context); },
        child: const Icon(Icons.add),
      )
    );
  }
}
