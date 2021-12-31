import 'package:decimal/decimal.dart';
import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/fields/price.dart';
import 'package:consumer_basket/base/logger.dart';

class PurchaseItemsRepository extends DbRepository<PurchaseItem> {

  static const String columnPurchaseId = "purchase_id";
  static const String columnGoodsItemId = "goods_item_id";
  static const String columnPrice = "price";
  static const String columnQuantity = "quantity";

  PurchasesRepository purchasesRepository;

  PurchaseItemsRepository(
      this.purchasesRepository,
      GoodsRepository goodsRepository) {
    super.init(
        "purchase_items",
            () => PurchaseItem(),
        [
          RelativeDbField<PurchaseItem, Purchase>(
            columnPurchaseId,
            purchasesRepository,
            (PurchaseItem item) => item.parent,
            (PurchaseItem item, Purchase? purchase) => item.parent = purchase,
            index: true,
          ),
          RelativeDbField<PurchaseItem, GoodsItem>(
            columnGoodsItemId,
            goodsRepository,
            (PurchaseItem item) => item.goodsItem,
            (PurchaseItem item, GoodsItem? goodsItem) => item.goodsItem = goodsItem,
            index: true,
          ),
          PriceDbFieldOpt<PurchaseItem>(
            columnPrice,
            (PurchaseItem item) => item.price,
            (PurchaseItem item, Decimal? price)  => item.price = price
          ),
          DbField<PurchaseItem,int?>(
            columnQuantity, "INTEGER",
            (PurchaseItem item) => item.quantity,
            (PurchaseItem item, int? quantity) => item.quantity = quantity,
          ),
        ]
    );

  }

  Future<List<PurchaseItem>> findLastPurchases(GoodsItem goodsItem, int maxCount) async {
    int? goodsId = goodsItem.id;
    if(goodsId == null){
      _logger.subModule("findLastPurchases()").error("Goods item id is null");
      return [];
    }
    var purchasesTable =  purchasesRepository.tableName;
    var purchasesColumnDate = PurchasesRepository.columnDate;

    var result = await getByQueryOrdered("""
      SELECT $tableName.${DbRepository.columnIdName}
      FROM $tableName
      INNER JOIN  $purchasesTable
      ON $tableName.$columnPurchaseId = $purchasesTable.${DbRepository.columnIdName}
      WHERE $tableName.$columnGoodsItemId = $goodsId
      ORDER BY $purchasesTable.$purchasesColumnDate DESC
      LIMIT $maxCount
      ;
    """);

    return result;
  }

  Logger _logger = Logger("PurchaseItemsRepository");
}
