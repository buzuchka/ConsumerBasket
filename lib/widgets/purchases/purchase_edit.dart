import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/price_and_quantity.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/models/purchase.dart';
import 'package:consumer_basket/core/models/purchase_item.dart';
import 'package:consumer_basket/widgets/base/shop.dart';
import 'package:consumer_basket/widgets/purchases/purchase_item_edit.dart';
import 'package:consumer_basket/widgets/purchases/purchase_item_list_item.dart';
import 'package:consumer_basket/widgets/shops/shop_select.dart';

// Окно для просмотра и редактирования Покупки
class PurchaseEditScreen extends StatefulWidget {
  final Purchase purchase; // item to view and update

  const PurchaseEditScreen({Key? key, required this.purchase})
      : super(key: key);

  @override
  _PurchaseEditScreenState createState() => _PurchaseEditScreenState();
}

class _PurchaseEditScreenState extends State<PurchaseEditScreen> {
  bool _isItemDataChanged = false;

  static final DateFormat _viewDateFormat = DateFormat(Constants.viewDateFormatString);

  @override
  void initState() {
    super.initState();
  }

  void _refreshPurchaseItemList() {
    setState(() {});
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
              ]
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(Constants.spacing),
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
                      children:  [
                        Text(
                          'Date:',
                          style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.normal
                          )
                        ),
                        const SizedBox(height: Constants.spacing),
                        Text(
                          'Shop:',
                          style:  Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.normal
                          )
                        ),
                      ],
                    ),
                    const SizedBox(width: Constants.spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Text(
                              _viewDateFormat.format(widget.purchase.date),
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.primary
                             )
                            ),
                            onTap: () async {
                              await _selectDate(context);
                            },
                          ),
                          const SizedBox(height: Constants.spacing),
                          InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getShopWidget(
                                    widget.purchase.shop,
                                    Theme.of(context).textTheme.headline6!.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context).colorScheme.primary
                                    )
                                ),
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
                const SizedBox(height: Constants.spacing),
                Row(
                  children: [
                    Text(
                      'List of Goods:',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(width: Constants.spacing),
                    Text(
                      (widget.purchase.items.isEmpty)
                        ? 'Empty'
                        : '',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
                const SizedBox(height: Constants.spacing),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Constants.spacing),
                    shrinkWrap: true,
                    itemCount: widget.purchase.items.length,
                    itemBuilder: (_, int position) {
                      final currentItem = widget.purchase.items.values.elementAt(position);
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
                  ),
                ),
                const SizedBox(height: Constants.spacing),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Goods quantity:',
                      style: Theme.of(context).textTheme.bodyText1
                    ),
                    const SizedBox(width: Constants.spacing),
                    Text(
                      widget.purchase.items.length.toString(),
                      style: Theme.of(context).textTheme.bodyText2
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sum:',
                      style: Theme.of(context).textTheme.bodyText1
                    ),
                    const SizedBox(width: Constants.spacing),
                    Text(
                        makePriceString(widget.purchase.amount),
                        style: Theme.of(context).textTheme.bodyText2
                    )
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
        _isItemDataChanged = true;
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

  void _clear() {
  }

}
