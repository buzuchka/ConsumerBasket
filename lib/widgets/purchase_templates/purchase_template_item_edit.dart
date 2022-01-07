import 'package:decimal/decimal.dart';

import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/purchase_template_item.dart';

import 'package:consumer_basket/widgets/goods/goods_item_select.dart';
import 'package:consumer_basket/widgets/goods/goods_list_item.dart';

// Окно для просмотра и редактирования элемента в Списке (товар+количество=purchase_template_item)
class PurchaseTemplateItemEditScreen extends StatefulWidget {
  final PurchaseTemplateItem item; // item to view and update

  const PurchaseTemplateItemEditScreen({Key? key, required this.item})
      : super(key: key);

  @override
  _PurchaseTemplateItemEditScreenState createState() => _PurchaseTemplateItemEditScreenState();
}

class _PurchaseTemplateItemEditScreenState extends State<PurchaseTemplateItemEditScreen> {
  final TextEditingController _quantityTextController = TextEditingController();

  bool _isItemDataChanged = false;

  @override
  void initState() {
    super.initState();

    _quantityTextController.text = (widget.item.quantity != null)
        ? widget.item.quantity.toString()
        : '';
  }

  @override
  void dispose() {
    super.dispose();
    _quantityTextController.dispose();
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
                      await _deletePurchaseTemplateItem2Database();
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
                  child: (widget.item.goodsItem == null)
                    ? GoodsListItem(goodsItem: widget.item.goodsItem!)
                    : Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.primary)
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
                        widget.item.quantity = Decimal.parse(value);
                        _updatePurchaseTemplateItem2Database();
                      }
                    )
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

  _updatePurchaseTemplateItem2Database() async {
    await widget.item.saveToRepository();
    _isItemDataChanged = true;
  }

  _deletePurchaseTemplateItem2Database() async {
    await RepositoriesHelper.purchaseTemplateItemsRepository.delete(widget.item);
    _isItemDataChanged = true;
  }

  void _clear() {}
}
