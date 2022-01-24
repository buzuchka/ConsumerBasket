import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/models/goods.dart';

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
  final TextEditingController _filter = TextEditingController();

  Icon _searchIcon = const Icon(Icons.search);
  Widget _appBarTitle = const Text('');

  late Future<List<GoodsItem>> _goodsListFuture;

  _GoodsScreenState() {
    _filter.addListener(() {
      _rebuildScreen();
    });
  }

  @override
  void initState() {
    super.initState();

    _goodsListFuture = _getAllGoods();
  }

  void _rebuildScreen() {
    if(_filter.text.isEmpty) {
      _goodsListFuture = _getAllGoods();
    }
    else {
      _goodsListFuture = _getGoodsFiltered("${_filter.text}*");
    }
    setState(() {});
  }

  Future<List<GoodsItem>> _getAllGoods() async {
    return await RepositoriesHelper.goodsRepository.getAllOrdered();
  }

  Future<List<GoodsItem>> _getGoodsFiltered(String filterText) async {
    return await RepositoriesHelper.goodsRepository.getByFts4QueryOrdered(filterText);
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = const Icon(Icons.close);
        _appBarTitle = TextField(
          controller: _filter,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        _searchIcon = const Icon(Icons.search);
        _appBarTitle = const Text('');
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: [
          IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          ),
        ],
      ),
      body: getListFutureBuilder(
        _goodsListFuture,
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
          _filter.clear();
          //_rebuildScreen();
        },
        child: const Icon(Icons.add),
      )
    );
  }
}
