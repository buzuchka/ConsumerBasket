import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/helpers/price_and_quantity.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/purchase_template.dart';
import 'package:consumer_basket/core/models/purchase_template_item.dart';

import 'package:consumer_basket/widgets/purchase_templates/purchase_template_item_edit.dart';
import 'package:consumer_basket/widgets/purchase_templates/purchase_template_item_list_item.dart';

// Окно для просмотра и редактирования Списка
class PurchaseTemplateEditScreen extends StatefulWidget {
  final PurchaseTemplate purchaseTemplate; // item to view and update

  const PurchaseTemplateEditScreen({Key? key, required this.purchaseTemplate})
      : super(key: key);

  @override
  _PurchaseTemplateEditScreenState createState() => _PurchaseTemplateEditScreenState();
}

class _PurchaseTemplateEditScreenState extends State<PurchaseTemplateEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _titleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _titleTextController.text = (widget.purchaseTemplate.title != null)
        ? widget.purchaseTemplate.title!
        : '';
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextController.dispose();
  }

  void _refreshPurchaseItemList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Language.of(context).purchaseTemplateString),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(Language.of(context).deleteButtonName),
                        onTap: () async {
                          await _deletePurchaseTemplate2Database();
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: _titleTextController,
                          decoration: InputDecoration(
                              labelText: Language.of(context).titleString
                          ),
                          style: Theme.of(context).textTheme.headline6,
                          onChanged: (String value) {
                            widget.purchaseTemplate.title = value;
                            _updatePurchaseTemplate2Database();
                          }
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Constants.spacing),
                Row(
                  children: [
                    Text(
                      '${Language.of(context).listOfGoodsString}:',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(width: Constants.spacing),
                    Text(
                      (widget.purchaseTemplate.items.isEmpty)
                          ? Language.of(context).emptyString
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
                    itemCount: widget.purchaseTemplate.items.length,
                    itemBuilder: (_, int position) {
                      final currentItem = widget.purchaseTemplate.items.values.elementAt(position);
                      return InkWell(
                        child: PurchaseTemplateItemListItem(item: currentItem),
                        onTap: () async {
                          final isNeed2Rebuild = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PurchaseTemplateItemEditScreen(
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
                      "${Language.of(context).goodsQuantityString}:",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(width: Constants.spacing),
                    Text(
                        widget.purchaseTemplate.items.length.toString(),
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
                        "${Language.of(context).approximatedSumString}:",
                        style: Theme.of(context).textTheme.bodyText1
                    ),
                    const SizedBox(width: Constants.spacing),
                    Text(
                        makePriceString(widget.purchaseTemplate.approximatedAmount),
                        style: Theme.of(context).textTheme.bodyText2
                    )
                  ],
                )
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // CREATE NEW PURCHASE ITEM
            PurchaseTemplateItem newPurchaseTemplateItem = PurchaseTemplateItem();
            newPurchaseTemplateItem.parent = widget.purchaseTemplate;
            await RepositoriesHelper.purchaseTemplateItemsRepository.insert(newPurchaseTemplateItem);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PurchaseTemplateItemEditScreen(
                      item: newPurchaseTemplateItem
                  )
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

  _updatePurchaseTemplate2Database() async {
    await widget.purchaseTemplate.saveToRepository();
    _isItemDataChanged = true;
  }

  _deletePurchaseTemplate2Database() async {
    await RepositoriesHelper.purchaseTemplatesRepository.delete(widget.purchaseTemplate);
    _isItemDataChanged = true;
  }

  void _clear() {
  }

}
