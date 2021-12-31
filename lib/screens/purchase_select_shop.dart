import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/lists/shop_list_item.dart';
import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/screens/shop_edit_screen.dart';

// Окно для выбора магазина
class SelectShopScreen extends StatefulWidget {
  const SelectShopScreen({Key? key}) : super(key: key);

  @override
  _SelectShopScreenState createState() => _SelectShopScreenState();
}

class _SelectShopScreenState extends State<SelectShopScreen> {
  late Future<Map<int, Shop>> _allShopsFuture;
  int? _selectedIndex;
  Shop? _selectedShop;

  @override
  void initState() {
    super.initState();

    _allShopsFuture = getShops();
  }

  Future<Map<int,Shop>> getShops() async {
    return await RepositoriesHelper.shopsRepository.getAll();
  }

  void _refreshShopList() {
    setState(() {
      _selectedIndex = null;
      _selectedShop = null;
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
                child: FutureBuilder<Map<int, Shop>>(
                  future: _allShopsFuture,
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
                          final currentShop = items.values.elementAt(position);
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
                              child: ShopListItem(shop: currentShop)
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = position;
                              });
                              _selectedShop = currentShop;
                            },
                            onDoubleTap: () async {
                              final isNeed2Rebuild = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopEditScreen(
                                        shop: currentShop
                                    ),
                                  )
                              );
                              if(isNeed2Rebuild) {
                                _refreshShopList();
                              }
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
        if(_selectedShop != null) {
          Navigator.pop(context, _selectedShop);
          return true;
        }
        Navigator.pop(context);
        return false;
      },
    );
  }
}
