import 'package:decimal/decimal.dart';

import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/models/shop.dart';

// Покупка
class Purchase extends AbstractRepositoryItem<Purchase> {
  Shop? shop;
  DateTime date = DateTime.now();
  Map<int, PurchaseItem> items = {};

  Decimal? get amount {
    Decimal result = Decimal.zero;
    for(var item in items.values){
      if(item.totalPrice == null) {
        return null;
      }
        result += item.totalPrice!;
    }
    return result;
  }
}
