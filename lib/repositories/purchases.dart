import 'package:consumer_basket/repositories/shops.dart';
import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/repositories/db_field.dart';

class PurchasesRepository extends BaseDbRepository<Purchase> {

  PurchasesRepository(Database db, ShopsRepository shopsRepository){
    print("BINGO1");
    super.init(
      db,"purchases",
      () => Purchase(),
      [
        DbField<Purchase,String?>(
            "date_text", "TEXT",
            (Purchase item) => item.date.toString(),
            (Purchase item, String? date) {
              if(date != null) {
                item.date = DateTime.parse(date);
              }
            }
        ),
        RelativeDbField<Purchase, Shop>(
          "shop_id",
          shopsRepository,
          (Purchase item) => item.shop,
          (Purchase item, Shop? shop) => item.shop = shop,
          index: true,
        )
      ]
    );
    print("BINGO2");
  }
}
