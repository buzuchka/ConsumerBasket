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
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select shop"),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 500,
                  child:
                    FutureBuilder<Map>(
                      future: DatabaseHelper.shopsRepository.getAll(),
                      initialData: {},
                      builder: (context, snapshot) {
                        return (snapshot.connectionState != ConnectionState.waiting)
                          ? ListView.separated(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (_, int position) {
                            final currentShop = snapshot.data!.values.elementAt(position);
                            return InkWell(
                              child: ShopListItem(shop: currentShop),
                              onTap: () {
                                setState(() {
                                  selectedIndex = position;
                                });
                                widget.shop = snapshot.data!.values.elementAt(position);
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
