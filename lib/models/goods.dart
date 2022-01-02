import 'dart:collection';
import 'package:decimal/decimal.dart';

import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/purchase_item.dart';

class GoodsItem extends AbstractRepositoryItem<GoodsItem> {
  String? title;
  String? imagePath;
  Map<int,PurchaseItem> purchases = {};

  DateTime? get lastPurchaseDate => _lastPurchaseDate;
  Decimal? get lastPurchaseUnitPrice => _lastPurchaseUnitPrice;
  PurchaseItem? get lastPurchase => _lastPurchase;

  set lastPurchase (PurchaseItem? purch) {
    _lastPurchase = purch;
    if(purch!=null){
      _lastPurchaseDate = purch.date;
      _lastPurchaseUnitPrice = purch.unitPrice;
    } else {
      _lastPurchaseDate = null;
      _lastPurchaseUnitPrice = null;
    }
  }

  PurchaseItem? _lastPurchase;
  DateTime? _lastPurchaseDate;
  Decimal? _lastPurchaseUnitPrice;
}
