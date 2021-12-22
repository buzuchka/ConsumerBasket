import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/screens/goods_item_edit.dart';
import 'package:consumer_basket/lists/goods_list_item.dart';
import 'package:consumer_basket/models/goods.dart';

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
        body: FutureBuilder<List>(
            future: DatabaseHelper.goodsRepository.getAll(),
            initialData: [],
            builder: (context, snapshot) {
              return (snapshot.connectionState != ConnectionState.waiting)
                  ? ListView.separated(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, int position) {
                        final currentGoodsItem = snapshot.data![position];
                        return InkWell(
                            child: GoodsListItem(goodsItem: currentGoodsItem),
                            onTap: () async {
                              final isNeed2Rebuild = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GoodsItemViewEditScreen(
                                        goodsItem: currentGoodsItem)),
                              );
                              if(isNeed2Rebuild) {
                                _rebuildScreen();
                              }
                            }
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                  )
                  : const Center(
                  child: SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.deepPurple,
                          color: Colors.grey,
                      )
                  )
              );
            }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            GoodsItem newGoodsItem = GoodsItem();
            await DatabaseHelper.goodsRepository.insert(newGoodsItem);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GoodsItemViewEditScreen(
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
