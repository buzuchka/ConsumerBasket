import 'package:consumer_basket/models/abstract_model.dart';

const String columnPurchaseIdName = 'purchase_id';
const String columnGoodsIdName = 'goods_id';
const String columnGoodsPriceName = 'goods_price';
const String columnGoodsCountName = 'goods_count';

class PurchaseItem extends Model {
  static String tableName = 'purchase_item';

  int? purchaseId;
  //int? goodsId;
  GoodsItem i;
  double? goodsPrice;
  int? goodsCount;



  PurchaseItem();

  PurchaseItem.Full(
      this.purchaseId,
      this.goodsId,
      this.goodsPrice,
      this.goodsCount);

  @override
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnPurchaseIdName: purchaseId,
      columnGoodsIdName: goodsId,
      columnGoodsPriceName: goodsPrice,
      columnGoodsCountName: goodsCount,
    };
    return map;
  }

  PurchaseItem.fromMap(Map map) {
    purchaseId = map[columnPurchaseIdName] as int?;
    goodsId = map[columnGoodsIdName] as int?;
    goodsPrice = map[columnGoodsPriceName] as double?;
    goodsCount = map[columnGoodsCountName] as int?;
  }
}
