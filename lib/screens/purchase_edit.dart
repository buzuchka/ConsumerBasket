import 'dart:io';

import 'package:intl/intl.dart';

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

  static final DateFormat viewDateFormat = DateFormat("dd.MM.yyyy");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                    'Date:',
                                    style: TextStyle(
                                      fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        viewDateFormat.format(widget.purchase.date),
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    )
                                ),
                                IconButton(
                                    icon: Icon(
                                        Icons.calendar_today,
                                        color: Theme.of(context).primaryColor,
                                        size: 30),
                                    onPressed: () async {
                                      await _selectDate(context);
                                    }
                                ),
                                const SizedBox(width: 10,),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.purchase.date,
        firstDate: DateTime(1970),
        lastDate: DateTime(2100));
    if (picked != null && picked != widget.purchase.date) {
      setState(() {
        widget.purchase.date = picked;
        _updatePurchase2Database();
      });
    }
  }

  _updatePurchase2Database() async {
    await widget.purchase.saveToRepository();
    _isItemDataChanged = true;
  }

  _deletePurchase2Database() async {
    await DatabaseHelper.purchasesRepository.delete(widget.purchase);
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
              await _deletePurchase2Database();
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
  }

}
