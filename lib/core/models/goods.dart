import 'package:decimal/decimal.dart';

import 'package:consumer_basket/core/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/core/models/purchase_item.dart';

class GoodsItem extends AbstractRepositoryItem<GoodsItem> {
  String? title;
  String? imagePath;
  String? note;
  Map<int,PurchaseItem> purchases = {};

  DateTime? get lastPurchaseDate => _lastPurchaseDate;
  Decimal? get lastPurchaseUnitPrice => _lastPurchase?.unitPrice;
  PurchaseItem? get lastPurchase => _lastPurchase;

  set lastPurchase (PurchaseItem? purch) {
    _lastPurchase = purch;
    if(purch!=null){
      _lastPurchaseDate = purch.date;
    } else {
      _lastPurchaseDate = null;
    }
  }

  PurchaseItem? _lastPurchase;
  DateTime? _lastPurchaseDate;
}
