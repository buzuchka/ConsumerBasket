import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/purchase.dart';

class PurchasesRepository extends BaseDbRepository<Purchase> {

  static const String _columnShopIdName = 'shop_id';
  static const String _columnDateTimeName = 'date_text';

  PurchasesRepository(Database dbReference){
    db = dbReference;
    table = "purchases";
  }

  @override
  Map<String, Object?> toMap(Purchase obj){
    var map = <String, Object?>{
      _columnShopIdName: obj.shopId,
      _columnDateTimeName: obj.date,
    };
    return map;
  }

  @override
  Purchase? fromMap(Map map){
    Purchase result = Purchase();
    result.shopId = map[_columnShopIdName] as int?;
    result.date = map[_columnDateTimeName] as String?;
    return  result;
  }
}
