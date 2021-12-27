import 'package:flutter/material.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/lists/shop_list_item.dart';
import 'package:consumer_basket/models/shop.dart';

// Окно для выбора магазина
class SelectShopScreen extends StatefulWidget {
  Shop? shop;

  SelectShopScreen({Key? key, required this.shop})
      : super(key: key);

  @override
  _SelectShopScreenState createState() => _SelectShopScreenState();
}

class _SelectShopScreenState extends State<SelectShopScreen> {
  late Future<Map<int, Shop>> _allShopsFuture;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();

    _allShopsFuture = getShops();
  }

  Future<Map<int,Shop>> getShops() async {
    return await DatabaseHelper.shopsRepository.getAll();
  }

  void refreshShopList() {
    setState(() {
      _allShopsFuture = getShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select shop"),
        ),
        body: Container(
          //padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 500,
                  child:
                    FutureBuilder<Map<int, Shop>>(
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
                            itemCount: items.length,
                            itemBuilder: (_, int position) {
                              final currentShop = items.values.elementAt(position);
                              final bool isSelected = (position == _selectedIndex);
                              return InkWell(
                                child: Container (
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
                                  widget.shop = currentShop;
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
                ElevatedButton(
                  child: const Text('Add new shop'),
                  onPressed: () {}
                )
              ]),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, widget.shop);
        return true;
        //return widget.shop;
      },
    );
  }
}
