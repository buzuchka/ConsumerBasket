import 'package:intl/intl.dart';

import 'package:decimal/decimal.dart';
import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/models/shop.dart';

// Покупка
class Purchase extends AbstractRepositoryItem<Purchase> {
  static final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  Shop? shop;
  DateTime date = DateTime.now();
  Map<int, PurchaseItem> items = {};

  Decimal get amount {
    Decimal result = Decimal.zero;
    for(var item in items.values){
      if(item.totalPrice != null) {
        result += item.totalPrice!;
      }
    }
    return result;
  }

  Future<List<PurchaseItem>> getPurchaseItems() async {
    if(repository != null) {
      var rep = repository as DbRepository<Purchase>;
      var map = await rep.getDependents<PurchaseItem>(this);
      return map.values.toList();
    }
    return [];
  }
}
