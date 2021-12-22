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

  static final DateFormat _viewDateFormat = DateFormat("dd.MM.yyyy");
  static const double _fontSize = 30.0;
  static const double _spacing = 10.0;

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
          title: const Text("View Purchase"),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () async {
                          await _deletePurchase2Database();
                          _clear();
                          Navigator.pop(context, _isItemDataChanged);
                        },
                        value: 1,
                      ),
                    ])
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Date:',
                          style: TextStyle(
                            fontSize: _fontSize,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Shop:',
                          style: TextStyle(
                            fontSize: _fontSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: _spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Text(
                              _viewDateFormat.format(widget.purchase.date),
                              style: TextStyle(
                                fontSize: _fontSize,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onTap: () async {
                              await _selectDate(context);
                            },
                          ),
                          const SizedBox(height: _spacing),
                          InkWell(
                            child: Text(
                              'dfdfdfdfdfdff',
                              style: const TextStyle(
                                fontSize: _fontSize,
                              ),
                            ),
                            onTap: () async {
                              await _selectDate(context);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _spacing),
                const Text('To be continued...')
              ]),
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

  void _clear() {}
}
