import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/lists/goods_list_item.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/screens/goods_item_edit.dart';

// Окно для добавления товара в покупку
class SelectGoodsItemScreen extends StatefulWidget {
  const SelectGoodsItemScreen({Key? key}) : super(key: key);

  @override
  _SelectGoodsItemScreenState createState() => _SelectGoodsItemScreenState();
}

class _SelectGoodsItemScreenState extends State<SelectGoodsItemScreen> {
  late Future<Map<int, GoodsItem>> _allItemsFuture;
  int? _selectedIndex;
  GoodsItem? _selectedItem;

  @override
  void initState() {
    super.initState();

    _allItemsFuture = getGoods();
  }

  Future<Map<int,GoodsItem>> getGoods() async {
    return await DatabaseHelper.goodsRepository.getAll();
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
          title: const Text("Select goods item"),
        ),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<Map<int, GoodsItem>>(
                future: _allItemsFuture,
                initialData: {},
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
                    final Map items = snapshot.data ?? {};
                    return ListView.separated(
                      padding: const EdgeInsets.all(10.0),
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (_, int position) {
                        final currentItem = items.values.elementAt(position);
                        final bool isSelected = (position == _selectedIndex);
                        return InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: (isSelected)
                                ? Colors.deepPurpleAccent.withOpacity(0.05)
                                : Colors.white,
                              border: isSelected
                                ? Border.all(color: Colors.deepPurple.withOpacity(0.3))
                                : null
                            ),
                            child: GoodsListItem(goodsItem: currentItem)
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = position;
                            });
                            _selectedItem = currentItem;
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
            ]),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            GoodsItem newGoodsItem = GoodsItem();
            await DatabaseHelper.goodsRepository.insert(newGoodsItem);
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
        if(_selectedItem != null) {
          Navigator.pop(context, _selectedItem);
          return true;
        }
        Navigator.pop(context);
        return false;
      },
    );
  }
}
