import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/goods.dart';

// Диалоговое окно для добавления и редактирования Товара
class GoodsItemEditDialog extends StatefulWidget {
  GoodsItem? goodsItem;
  VoidCallback onDataChanged;

  GoodsItemEditDialog({Key? key, required this.onDataChanged, this.goodsItem}) : super(key: key);

  @override
  _GoodsItemEditDialogState createState() => _GoodsItemEditDialogState(); // this.goodsItem
}

class _GoodsItemEditDialogState extends State<GoodsItemEditDialog> {
  GoodsItem newGoodsItem = GoodsItem();

  final TextEditingController _titleTextController = TextEditingController();

  //_GoodsItemEditDialogState(this.goodsItem);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      newGoodsItem.title = _titleTextController.text;
                      _titleTextController.clear();
                      _addGoodsItem2Database(newGoodsItem);
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

  void _addGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.insert(GoodsItem.tableName, item);
    widget.onDataChanged.call();
  }
}
