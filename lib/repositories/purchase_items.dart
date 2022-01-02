import 'package:decimal/decimal.dart';
import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase.dart';
import 'package:consumer_basket/models/purchase_item.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/fields/price_and_quantity.dart';
import 'package:consumer_basket/helpers/logger.dart';

class PurchaseItemsRepository extends DbRepository<PurchaseItem> {

  static const String columnPurchaseId = "purchase_id";
  static const String columnGoodsItemId = "goods_item_id";
  static const String columnTotalPrice = "total_price";
  static const String columnUnitPrice = "unit_price";
  static const String columnQuantity = "quantity";


  PurchaseItemsRepository() {
    super.init(
        "purchase_items",
            () => PurchaseItem(),
        [
          RelativeDbField<PurchaseItem, Purchase>(
            relativeIdColumnName: columnPurchaseId,
            getter: (PurchaseItem item) => item.parent,
            setter: (PurchaseItem item, Purchase? purchase) => item.parent = purchase,
            index: true,
          ),
          RelativeDbField<PurchaseItem, GoodsItem>(
            relativeIdColumnName: columnGoodsItemId,
            getter: (PurchaseItem item) => item.goodsItem,
            setter: (PurchaseItem item, GoodsItem? goodsItem) => item.goodsItem = goodsItem,
            index: true,
          ),
          OptPriceDbField<PurchaseItem>(
              columnName: columnTotalPrice,
              getter: (PurchaseItem item) => item.totalPrice,
              setter: (PurchaseItem item, Decimal? price)  => item.totalPrice = price
          ),
          OptPriceDbField<PurchaseItem>(
            columnName: columnUnitPrice,
            getter: (PurchaseItem item) => item.unitPrice,
            setter: (PurchaseItem item, Decimal? price)  => item.unitPrice = price
          ),
          OptQuantityDbField<PurchaseItem>(
            columnName: columnQuantity,
            getter: (PurchaseItem item) => item.quantity,
            setter: (PurchaseItem item, Decimal? quantity) => item.quantity = quantity,
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
    var purchasesRepository = supervisor.getRepositoryByType<Purchase>()!;
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
