import 'package:flutter/material.dart';

import 'package:decimal/decimal.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/logger.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/purchase_item.dart';

import 'package:consumer_basket/widgets/goods/goods_list_item.dart';
import 'package:consumer_basket/widgets/goods/goods_item_select.dart';

// Окно для просмотра и редактирования элемента в покупке (товар+количество+цена=purchase_item)
class PurchaseItemEditScreen extends StatefulWidget {
  final PurchaseItem item; // item to view and update

  const PurchaseItemEditScreen({Key? key, required this.item})
      : super(key: key);

  @override
  _PurchaseItemEditScreenState createState() => _PurchaseItemEditScreenState();
}

class _PurchaseItemEditScreenState extends State<PurchaseItemEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _quantityTextController = TextEditingController();
  final TextEditingController _totalPriceTextController = TextEditingController();
  final TextEditingController _unitPriceTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _updateQuantity();
    _updateTotalPrice();
    _updateUnitPrice();
  }

  _updateQuantity() {
    _quantityTextController.text = (widget.item.quantity != null)
        ? widget.item.quantity.toString()
        : '';
  }
  _updateTotalPrice() {
    _totalPriceTextController.text = (widget.item.totalPrice != null)
        ? widget.item.totalPrice.toString()
        : '';
  }

  _updateUnitPrice(){
    _unitPriceTextController.text = (widget.item.unitPrice != null)
        ? widget.item.unitPrice.toString()
        : '';
  }

  @override
  void dispose() {
    super.dispose();

    _quantityTextController.dispose();
    _totalPriceTextController.dispose();
    _unitPriceTextController.dispose();
  }

  void _rebuildScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Language.of(context).goodsItemString),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(Language.of(context).deleteButtonName),
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
          padding: const EdgeInsets.all(Constants.spacing),
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
                        height: Constants.listItemPictureHeight,
                        child: Center(
                          child: Text(Language.of(context).goodsItemIsNotSelectedString)
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

                    var lastPurchase = await RepositoriesHelper.purchaseItemsRepository.findLastPurchases(selectedGoodsItem, 1);
                    if(lastPurchase.isNotEmpty){
                      widget.item.totalPrice = lastPurchase.first.totalPrice;
                      _totalPriceTextController.text = widget.item.totalPrice.toString();
                    }
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
                      decoration: InputDecoration(
                          labelText: Language.of(context).quantityString
                      ),
                      onChanged: (String value) {
                        if(value.isEmpty){
                          widget.item.quantity = null;
                        }else{
                          widget.item.quantity = Decimal.parse(value);
                        }
                        _updateTotalPrice();
                        _updateUnitPrice();
                        _updatePurchaseItem2Database();
                        _rebuildScreen();
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
                          controller: _unitPriceTextController,
                          decoration: InputDecoration(
                            labelText: Language.of(context).unitPriceString,
                            suffixText: Constants.currentCurrencyString,
                          ),
                          onChanged: (String value) {
                            var logger = Logger("BIG PROBLEM");
                            if(value.isEmpty){
                              widget.item.unitPrice = null;
                            }else{
                              widget.item.unitPrice = Decimal.parse(value);
                            }
                            logger.debug("""\n
                              quantity = ${widget.item.quantity}
                              unitPrice = ${widget.item.unitPrice}
                              totalPrice = ${widget.item.totalPrice}                              
                            """);
                            _updateQuantity();
                            _updateTotalPrice();
                            _updatePurchaseItem2Database();
                            _rebuildScreen();
                          }
                      ),
                    ),
                  ]
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _totalPriceTextController,
                      decoration: InputDecoration(
                        labelText: Language.of(context).totalPriceString,
                        suffixText: Constants.currentCurrencyString
                      ),
                      onChanged: (String value) {
                        if(value.isEmpty){
                          widget.item.totalPrice = null;
                        }else{
                          widget.item.totalPrice = Decimal.parse(value);
                        }
                        _updateQuantity();
                        _updateUnitPrice();
                        _updatePurchaseItem2Database();
                        _rebuildScreen();
                      }
                    ),
                  ),
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
    await RepositoriesHelper.purchaseItemsRepository.delete(widget.item);
    _isItemDataChanged = true;
  }

  void _clear() {
    _quantityTextController.clear();
    _totalPriceTextController.clear();
    _unitPriceTextController.clear();
  }
}
