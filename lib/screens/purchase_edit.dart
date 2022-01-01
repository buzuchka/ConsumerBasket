import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/lists/purchase_item_list_item.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/screens/purchase_item_edit.dart';
import 'package:consumer_basket/screens/purchase_select_shop.dart';
import 'package:consumer_basket/widgets/shop.dart';

// Окно для добавления, просмотра и редактирования Покупки
class PurchaseEditScreen extends StatefulWidget {
  final Purchase purchase; // item to view and update

  const PurchaseEditScreen({Key? key, required this.purchase})
      : super(key: key);

  @override
  _PurchaseEditScreenState createState() => _PurchaseEditScreenState();
}

class _PurchaseEditScreenState extends State<PurchaseEditScreen> {
  late Future<List<PurchaseItem>> _allPurchaseItemsFuture;

  bool _isItemDataChanged = false;

  static final DateFormat _viewDateFormat = DateFormat("dd.MM.yyyy");
  static const double _fontSize = 20.0;
  static const double _spacing = 10.0;

  static const String _currencyStr = 'р.';

  @override
  void initState() {
    super.initState();

    _allPurchaseItemsFuture = widget.purchase.getPurchaseItems();
  }

  void _refreshPurchaseItemList() {
    setState(() {
      _allPurchaseItemsFuture = widget.purchase.getPurchaseItems();
    });
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getShopWidget(widget.purchase.shop, 20.0, textColor: Theme.of(context).primaryColor),
                              ],
                            ),
                            onTap: () async {
                              // SELECT SHOP
                              final selectedShop = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SelectShopScreen()
                                ),
                              );
                              if(selectedShop != null) {
                                widget.purchase.shop = selectedShop;
                                widget.purchase.saveToRepository();
                                _isItemDataChanged = true;
                                setState(() {});
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _spacing),
                Row(
                  children: [
                    const Text('List of Goods:'),
                    const SizedBox(width: _spacing),
                    FutureBuilder<List>(
                      future: _allPurchaseItemsFuture,
                      initialData: [],
                      builder:  (context, snapshot) {
                        String text;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          text = 'Loading...';
                        } else if (snapshot.hasError) {
                          text = 'Empty';
                        } else {
                          final List items = snapshot.data ?? [];
                          text = (items.isEmpty) ?  'Empty' : '';
                        }
                        return Text(text);
                      }
                    )
                  ],
                ),
                const SizedBox(height: _spacing),
                Expanded(
                  child: FutureBuilder<List<PurchaseItem>>(
                      future: _allPurchaseItemsFuture,
                      initialData: [],
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: SizedBox(
                                  width: 100.0,
                                  height: 100.0,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.deepPurple,
                                    color: Colors.grey,
                                  )
                              )
                          );
                        } else if(snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final List items = snapshot.data ?? [];
                          return ListView.separated(
                            padding: const EdgeInsets.all(10.0),
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (_, int position) {
                              final currentItem = items.elementAt(position);
                              return InkWell(
                                child: PurchaseItemListItem(item: currentItem),
                                onTap: () async {
                                  final isNeed2Rebuild = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PurchaseItemEditScreen(
                                            item: currentItem
                                        ),
                                    )
                                  );
                                  if(isNeed2Rebuild) {
                                    _refreshPurchaseItemList();
                                  }
                                }
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                          );
                        }
                      }
                  ),
                ),
                const SizedBox(height: _spacing),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Goods quantity:'),
                    const SizedBox(width: _spacing),
                    FutureBuilder<List>(
                        future: _allPurchaseItemsFuture,
                        initialData: [],
                        builder:  (context, snapshot) {
                          String text;
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            text = 'Loading...';
                          } else if (snapshot.hasError) {
                            text = '0';
                          } else {
                            final List items = snapshot.data ?? [];
                            text = (items.isEmpty) ?  '0' : items.length.toString();
                          }
                          return Text(text);
                        }
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Sum:'),
                    SizedBox(width: _spacing),
                    Text('1000 ${_currencyStr}')
                  ],
                )
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // CREATE NEW PURCHASE ITEM
            PurchaseItem newPurchaseItem = PurchaseItem();
            newPurchaseItem.parent = widget.purchase;
            await RepositoriesHelper.purchaseItemsRepository.insert(newPurchaseItem);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PurchaseItemEditScreen(
                      item: newPurchaseItem)
              ),
            );
            _refreshPurchaseItemList();
          },
          child: const Icon(Icons.add),
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
    await RepositoriesHelper.purchasesRepository.delete(widget.purchase);
    _isItemDataChanged = true;
  }

  void _clear() {}
}
