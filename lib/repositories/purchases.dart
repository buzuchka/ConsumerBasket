import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/purchase.dart';

class PurchasesRepository extends BaseDbRepository<Purchase> {

  static const String _columnShopIdName = 'shop_id';
  static const String _columnDateTimeName = 'date_text';

  PurchasesRepository(Database dbReference){
    db = dbReference;
    table = "purchases";
    schema = """
      shop_id INTEGER,
      date_text TEXT(25),
      FOREIGN KEY (shop_id) REFERENCES shops (id)
      ON DELETE CASCADE ON UPDATE NO ACTION 
    """;
  }

  @override
  Future<Map<String, Object?>?> toMap(Purchase obj) async{
    var map = <String, Object?>{
      _columnShopIdName: obj.shopId,
      _columnDateTimeName: obj.date.toString(),
    };
    return map;
  }

  @override
  Future<Purchase?> fromMap(Map map) async{
    Purchase result = Purchase();
    result.shopId = map[_columnShopIdName] as int?;
    result.date = DateTime.parse(map[_columnDateTimeName] as String);
    return  result;
  }
}
