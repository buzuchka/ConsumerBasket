import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/purchase.dart';

class PurchasesRepository extends BaseDbRepository<Purchase> {

  static const String _columnShopId = 'shop_id';
  static const String _columnDateTime = 'date_text';

  PurchasesRepository(Database dbReference){
    db = dbReference;
    table = "purchases";
    schema = """
      $_columnShopId INTEGER,
      $_columnDateTime TEXT(25),
      FOREIGN KEY ($_columnShopId) REFERENCES shops (id)
      ON DELETE CASCADE ON UPDATE NO ACTION 
    """;
  }

  @override
  Future<Map<String, Object?>?> toMap(Purchase obj) async{
    var map = <String, Object?>{
      _columnShopId: obj.shopId,
      _columnDateTime: obj.date.toString(),
    };
    return map;
  }

  @override
  Future<Purchase?> fromMap(Map map) async{
    Purchase result = Purchase();
    result.shopId = map[_columnShopId] as int?;
    result.date = DateTime.parse(map[_columnDateTime] as String);
    return  result;
  }
}
