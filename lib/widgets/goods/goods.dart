import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/widgets/base/list_future_builder.dart';
import 'package:consumer_basket/widgets/goods/goods_item_edit.dart';
import 'package:consumer_basket/widgets/goods/goods_list_item.dart';

// Окно со списком всех Товаров
class GoodsScreen extends StatefulWidget {
  const GoodsScreen({Key? key}) : super(key: key);

  @override
  _GoodsScreenState createState() {
    return _GoodsScreenState();
  }
}

class _GoodsScreenState extends State<GoodsScreen> {

  @override
  void initState() {
    super.initState();
  }

  void _rebuildScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getListFutureBuilder(
          RepositoriesHelper.goodsRepository.getAllOrdered(),
          (GoodsItem item) => GoodsListItem(goodsItem: item),
          onTap: editItemOnTap(
            (GoodsItem item) => GoodsItemEditScreen(goodsItem: item),
            () => _rebuildScreen(),
          )
        ),
        floatingActionButton: FloatingActionButton(
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
            _rebuildScreen();
          },
          child: const Icon(Icons.add),
        )
    );
  }
}
