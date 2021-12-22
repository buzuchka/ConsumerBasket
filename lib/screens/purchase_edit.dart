import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/purchase.dart';

// Окно для добавления, просмотра и редактирования Покупки
class PurchaseEditScreen extends StatefulWidget {
  final Purchase purchase; // item to view and update

  const PurchaseEditScreen({
    Key? key,
    required this.purchase
  })
      : super(key: key);

  @override
  _PurchaseEditScreenState createState() => _PurchaseEditScreenState();
}

class _PurchaseEditScreenState extends State<PurchaseEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _titleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _titleTextController.text = (widget.purchase.date != null)
        ? widget.purchase.date!
        : '';
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            title: const Text("View Purchase")
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child:
                                    TextField(
                                        controller: _titleTextController,
                                        maxLines: 2,
                                        decoration: const InputDecoration(labelText: 'Date'),
                                        onChanged: (String value) {
                                          widget.purchase.date = _titleTextController.text;
                                          _updateGoodsItem2Database(widget.purchase);
                                        }
                                    )
                                ),
                                IconButton(
                                    icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(context).primaryColor,
                                        size: 30),
                                    onPressed: () async {
                                      await _showDeleteConfirmationDialog();
                                    }
                                ),
                              ],
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ]
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, _isItemDataChanged);
        return _isItemDataChanged;
      },
    );
  }

  _updateGoodsItem2Database(Purchase item) async {
    await item.saveToRepository();
    _isItemDataChanged = true;
  }

  _deleteGoodsItem2Database(Purchase item) async {
    await DatabaseHelper.purchasesRepository.delete(item);
    _isItemDataChanged = true;
  }

  _showDeleteConfirmationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
            'Purchase deletion',
            style: TextStyle(color: Colors.black, fontSize: 20.0)
        ),
        content: const Text(
            'Are you sure you want to delete the purchase? '
                'Tap \'Yes\' to delete \'No\' to cancel.'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Yes', style: TextStyle(fontSize: 18.0)),
            onPressed: () async {
              await _deleteGoodsItem2Database(widget.purchase);
              _clear();
              Navigator.pop(context); // this line dismisses the dialog
              Navigator.pop(context, _isItemDataChanged);
            },
          ),
          ElevatedButton(
            child: const Text('No', style: TextStyle(fontSize: 18.0)),
            onPressed: () {
              Navigator.pop(context); // this line dismisses the dialog
            },
          )
        ],
      ),
    );
  }

  void _clear() {
    _titleTextController.clear();
  }

}
