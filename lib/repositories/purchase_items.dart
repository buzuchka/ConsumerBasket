import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';

class PurchaseItemsRepository extends DbRepository<PurchaseItem> {

  PurchaseItemsRepository(
      Database db,
      PurchasesRepository purchasesRepository,
      GoodsRepository goodsRepository) {
    super.init(
        db,"purchase_items",
            () => PurchaseItem(),
        [
          RelativeDbField<PurchaseItem, Purchase>(
            "purchase_id",
            purchasesRepository,
            (PurchaseItem item) => item.parent,
            (PurchaseItem item, Purchase? purchase) => item.parent = purchase,
            index: true,
          ),
          RelativeDbField<PurchaseItem, GoodsItem>(
            "goods_item_id",
            goodsRepository,
            (PurchaseItem item) => item.goodsItem,
            (PurchaseItem item, GoodsItem? goodsItem) => item.goodsItem = goodsItem,
            index: true,
          ),
          DbField<PurchaseItem,double?>(
            "price", "REAL",
            (PurchaseItem item) => item.price,
            (PurchaseItem item, double? price) => item.price = price,
          ),
          DbField<PurchaseItem,int?>(
            "quantity", "INTEGER",
            (PurchaseItem item) => item.quantity,
            (PurchaseItem item, int? quantity) => item.quantity = quantity,
          ),
        ]
    );
  }
}
