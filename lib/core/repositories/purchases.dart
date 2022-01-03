import 'package:consumer_basket/core/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/core/base/repositories/db_repository.dart';
import 'package:consumer_basket/core/base/repositories/db_field.dart';
import 'package:consumer_basket/core/models/shop.dart';
import 'package:consumer_basket/core/models/purchase.dart';
import 'package:consumer_basket/core/models/purchase_item.dart';
import 'package:consumer_basket/core/repositories/fields/date.dart';
import 'package:consumer_basket/core/repositories/shops.dart';

class PurchasesRepository extends DbRepository<Purchase> {

  static const String columnDate = "date";

  PurchasesRepository(){
    super.init(
      "purchases",
      () => Purchase(),
      [
        DatetimeDbField<Purchase>(
          columnName: columnDate,
          getter: (Purchase item) => item.date,
          setter: (Purchase item, DateTime date) => item.date = date,
          index: true
        ),
        RelativeDbField<Purchase, Shop>(
          relativeIdColumnName: "shop_id",
          getter: (Purchase item) => item.shop,
          setter: (Purchase item, Shop? shop) => item.shop = shop,
          index: true,
        ),
        DependentMapField<Purchase, PurchaseItem>(
          mapGetter: (Purchase item) => item.items
        )
      ]
    );
  }

  Future<List<Purchase>> getOrderedByDate([Ordering? ordering]) async{
    return await getOrdered(columnDate, ordering: ordering);
  }
}
