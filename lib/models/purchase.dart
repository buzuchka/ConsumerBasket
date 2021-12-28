import 'package:intl/intl.dart';

import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/shop.dart';

// Покупка
class Purchase extends AbstractRepositoryItem<Purchase> {
  static final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  Shop? shop;
  DateTime date = DateTime.now();
  //List<PurchaseItem> purchaseItems = [];
}
