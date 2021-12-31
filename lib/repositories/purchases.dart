import 'package:consumer_basket/models/purchase_item.dart';
import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/repositories/shops.dart';

class PurchasesRepository extends DbRepository<Purchase> {

  PurchasesRepository(ShopsRepository shopsRepository){
    super.init(
      "purchases",
      () => Purchase(),
      [
        DbField<Purchase,String?>(
          "date", "DATE",
          (Purchase item) => item.date.toString(),
          (Purchase item, String? date) {
            if(date != null) {
              item.date = DateTime.parse(date);
            }
          },
          index: true
        ),
        RelativeDbField<Purchase, Shop>(
          "shop_id",
          shopsRepository,
          (Purchase item) => item.shop,
          (Purchase item, Shop? shop) => item.shop = shop,
          index: true,
        ),
        DependentDbField<Purchase, PurchaseItem>(
          (Purchase item) => item.items
        )
      ]
    );
  }
}
