import 'dart:async';

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
          return AlertDialog(
            title: Text("Add GoodsItem"),
            actions: <Widget>[
              ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop()
              ),
              ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    _addGoodsItem2Database(_goodsItem);
                    Navigator.of(context).pop();
                  }
              )
            ],
            content: TextField(
              autofocus: true,
              decoration: InputDecoration(labelText: 'Item Name'),
              onChanged: (value) { _goodsItem.title = value; },
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
        child: Icon(Icons.add),
      )
    );
  }
}
