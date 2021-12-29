import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/lists/goods_list_item.dart';
import 'package:consumer_basket/screens/purchase_select_goods_item.dart';

// Окно для создания, просмотра и редактирования элемента в покупке (товар+количество+цена=purchase_item)
class PurchaseItemEditScreen extends StatefulWidget {
  final PurchaseItem item; // item to view and update

  const PurchaseItemEditScreen({Key? key, required this.item})
      : super(key: key);

  @override
  _PurchaseItemEditScreenState createState() => _PurchaseItemEditScreenState();
}

class _PurchaseItemEditScreenState extends State<PurchaseItemEditScreen> {
  final TextEditingController _quantityTextController = TextEditingController();
  final TextEditingController _priceTextController = TextEditingController();

  bool _isItemDataChanged = false;

  static const double _spacing = 10.0;

  static const String _currencyStr = 'р.';

  @override
  void initState() {
    super.initState();

    _quantityTextController.text = (widget.item.quantity != null)
        ? widget.item.quantity.toString()
        : '';

    _priceTextController.text = (widget.item.price != null)
        ? widget.item.price.toString()
        : '';
  }

  @override
  void dispose() {
    super.dispose();
    _quantityTextController.dispose();
    _priceTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("View Purchase Item"),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () async {
                      await _deletePurchaseItem2Database();
                      _clear();
                      Navigator.pop(context, _isItemDataChanged);
                    },
                    value: 1,
                  ),
                ])
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                child: Container(
                  child: (widget.item.goodsItem != null)
                    ? GoodsListItem(goodsItem: widget.item.goodsItem!)
                    : Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor)
                        ),
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text('Goods Item is not selected')
                          ],
                        )
                      ),
                ),
                onTap: () async {
                  // SELECT GOODS ITEM
                  final selectedGoodsItem = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectGoodsItemScreen()
                    ),
                  );
                  if(selectedGoodsItem != null) {
                    widget.item.goodsItem = selectedGoodsItem;
                    widget.item.saveToRepository();
                    _isItemDataChanged = true;
                    setState(() {});
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityTextController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      onChanged: (String value) {
                        widget.item.quantity = int.parse(value);
                        _updatePurchaseItem2Database();
                      }
                    )
                  ),
                ]
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceTextController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      onChanged: (String value) {
                        widget.item.price = double.parse(value);
                        _updatePurchaseItem2Database();
                      }
                    ),
                  ),
                  const Text('apiece')
                ]
              ),
          ]),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, _isItemDataChanged);
        return _isItemDataChanged;
      },
    );
  }

  _updatePurchaseItem2Database() async {
    await widget.item.saveToRepository();
    _isItemDataChanged = true;
  }

  _deletePurchaseItem2Database() async {
    await DatabaseHelper.purchaseItemsRepository.delete(widget.item);
    _isItemDataChanged = true;
  }

  void _clear() {}
}
