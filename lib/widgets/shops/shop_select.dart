import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/widgets/base/list_future_builder.dart';
import 'package:consumer_basket/widgets/shops/shop_edit.dart';
import 'package:consumer_basket/widgets/shops/shop_list_item.dart';

// Окно для выбора магазина
class SelectShopScreen extends StatefulWidget {
  const SelectShopScreen({Key? key}) : super(key: key);

  @override
  _SelectShopScreenState createState() => _SelectShopScreenState();
}

class _SelectShopScreenState extends State<SelectShopScreen> {
  late Future<List<Shop>> _allShopsFuture;

  @override
  void initState() {
    super.initState();

    _allShopsFuture = getShops();
  }

  Future<List<Shop>> getShops() async {
    return await RepositoriesHelper.shopsRepository.getAllOrdered();
  }

  void _refreshShopList() {
    setState(() {
      _allShopsFuture = getShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Shop"),
        ),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: getListFutureBuilder(
                    _allShopsFuture,
                    (Shop shop) => ShopListItem(shop: shop),
                    onTap: (BuildContext context, Shop selectedItem) async {
                      Navigator.pop(context, selectedItem);
                    },
                    onLongPress: (BuildContext context, Shop selectedItem) async {
                      final isNeed2Rebuild = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopEditScreen(
                                shop: selectedItem
                            ),
                          )
                      );

                      if(isNeed2Rebuild) {
                        _refreshShopList();
                      }
                    }
                )
              ),
            ]
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            Shop newShop = Shop();
            await RepositoriesHelper.shopsRepository.insert(newShop);
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShopEditScreen(
                      shop: newShop)
              ),
            );
            _refreshShopList();
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
