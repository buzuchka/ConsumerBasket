import 'package:flutter/material.dart';

import 'package:consumer_basket/core/internationalization/languages/language.dart';

import 'package:consumer_basket/widgets/goods/goods.dart';
import 'package:consumer_basket/widgets/purchases/purchases.dart';
import 'package:consumer_basket/widgets/purchase_templates/purchase_templates.dart';

class BasicScreen extends StatefulWidget {
  const BasicScreen({Key? key}) : super(key: key);

  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    PurchaseTemplatesScreen(),
    PurchasesScreen(),
    GoodsScreen(),
    //Icon(
    //  Icons.data_usage,
    //  size: 150,
    //),
    //Icon(
    //  Icons.perm_identity,
    //  size: 150,
    //),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final List<String> _pageNames = <String>[
      Language.of(context).purchaseTemplatesButtonName,
      Language.of(context).purchasesButtonName,
      Language.of(context).goodsButtonName
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageNames.elementAt(_selectedIndex)),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: Language.of(context).purchaseTemplatesButtonName
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.credit_card),
              label: Language.of(context).purchasesButtonName
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.devices_other),
              label: Language.of(context).goodsButtonName
          ),
          //BottomNavigationBarItem(
          //    icon: Icon(Icons.data_usage),
          //    label: 'Analytics'
          //),
          //BottomNavigationBarItem(
          //    icon: Icon(Icons.perm_identity),
          //    label: 'Profile'
          //)
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
