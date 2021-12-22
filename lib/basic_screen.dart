import 'package:flutter/material.dart';

import 'package:consumer_basket/screens/goods.dart';
import 'package:consumer_basket/screens/purchases.dart';

class BasicScreen extends StatefulWidget {
  const BasicScreen({Key? key}) : super(key: key);

  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Icon(
      Icons.list,
      size: 150,
    ),
    PurchasesScreen(),
    GoodsScreen(),
    Icon(
      Icons.data_usage,
      size: 150,
    ),
    Icon(
      Icons.perm_identity,
      size: 150,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumer Basket'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.black26,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Lists'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Purchases'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.devices_other),
              label: 'Goods'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.data_usage),
              label: 'Analytics'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity),
              label: 'Profile'
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
