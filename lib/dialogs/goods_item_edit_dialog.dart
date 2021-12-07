import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/goods.dart';

// Диалоговое окно для добавления и редактирования Товара
class GoodsItemEditDialog extends StatefulWidget {
  GoodsItem? goodsItem;
  VoidCallback onDataChanged;

  GoodsItemEditDialog({Key? key, required this.onDataChanged, this.goodsItem})
      : super(key: key);

  @override
  _GoodsItemEditDialogState createState() => _GoodsItemEditDialogState();
}

class _GoodsItemEditDialogState extends State<GoodsItemEditDialog> {
  GoodsItem newGoodsItem = GoodsItem();

  final TextEditingController _titleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    bool isUpdateMode = widget.goodsItem != null;
    _titleTextController.text = isUpdateMode ? widget.goodsItem!.title! : '';
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdateMode = widget.goodsItem != null;
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
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
              Row(
                //mainAxisSize: MainAxisSize.min,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                              image: AssetImage('assets/images/no_photo.jpg'),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover
                          ),
                          ElevatedButton(
                              child: const Text(
                                'Change\nimage',
                                maxLines: 2,
                                textAlign: TextAlign.center,),
                              onPressed: () {
                                // change image
                              })
                        ],
                      )
                  ),
                  //const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleTextController,
                            decoration: const InputDecoration(labelText: 'Item Name'),
                            onChanged: (String value) {
                              if (isUpdateMode) {
                                widget.goodsItem!.title = _titleTextController.text;
                                _updateGoodsItem2Database(widget.goodsItem!);
                              }
                            },
                          ),
                        ],
                      )
                  )
                ],
              ),
              //const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    Visibility(
                        visible: isUpdateMode,
                        child: ElevatedButton(
                            child: const Text('Delete'),
                            onPressed: () {
                              _close();
                              _deleteGoodsItem2Database(widget.goodsItem!);
                            })),
                    const SizedBox(width: 10),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                          visible: isUpdateMode,
                          child: ElevatedButton(
                              child: const Text('Close'),
                              onPressed: () {
                                _close();
                              })),
                      Visibility(
                          visible: !isUpdateMode,
                          child: ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                _close();
                              })),
                      Visibility(
                          visible: !isUpdateMode,
                          child: const SizedBox(width: 10)),
                      Visibility(
                          visible: !isUpdateMode,
                          child: ElevatedButton(
                              child: const Text('Add'),
                              onPressed: () {
                                newGoodsItem.title = _titleTextController.text;
                                _addGoodsItem2Database(newGoodsItem);
                                _close();
                              })),
                    ],
                  ),
                ],
              )
            ]
        ),
      ),
    );
  }

  void _addGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.insert(GoodsItem.tableName, item);
  }

  void _updateGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.update(GoodsItem.tableName, item);
  }

  void _deleteGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.delete(GoodsItem.tableName, item);
  }

  void _clear() {
    _titleTextController.clear();
  }

  void _close() {
    _clear();
    widget.onDataChanged.call();
    Navigator.of(context).pop();
  }
}
