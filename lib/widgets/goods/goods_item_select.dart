import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/goods.dart';

import 'package:consumer_basket/widgets/base/list_future_builder.dart';
import 'package:consumer_basket/widgets/goods/goods_item_edit.dart';
import 'package:consumer_basket/widgets/goods/goods_list_item.dart';

// Окно выбора товара
class SelectGoodsItemScreen extends StatefulWidget {
  const SelectGoodsItemScreen({Key? key}) : super(key: key);

  @override
  _SelectGoodsItemScreenState createState() => _SelectGoodsItemScreenState();
}

class _SelectGoodsItemScreenState extends State<SelectGoodsItemScreen> {
  late Future<List<GoodsItem>> _allItemsFuture;

  @override
  void initState() {
    super.initState();

    _allItemsFuture = getGoods();
  }

  Future<List<GoodsItem>> getGoods() async {
    return await RepositoriesHelper.goodsRepository.getAllOrdered();
  }

  void _refreshItemsList() {
    setState(() {
      _allItemsFuture = getGoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Language.of(context).goodsString),
        ),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: getListFutureBuilder(
                    _allItemsFuture,
                    (GoodsItem goodsItem) => GoodsListItem(goodsItem: goodsItem),
                    onTap: (BuildContext context, GoodsItem selectedItem) async {
                      Navigator.pop(context, selectedItem);
                    }
                )
              ),
            ]
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            GoodsItem newGoodsItem = GoodsItem();
            await RepositoriesHelper.goodsRepository.insert(newGoodsItem);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GoodsItemEditScreen(
                    goodsItem: newGoodsItem)
              ),
            );
            _refreshItemsList();
          },
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
    );
  }
}
