import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase_template.dart';
import 'package:consumer_basket/models/purchase_template_item.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchase_templates.dart';

class PurchaseTemplateItemsRepository extends DbRepository<PurchaseTemplateItem> {

  static const String columnPurchaseId = "purchase_template_id";
  static const String columnGoodsItemId = "goods_item_id";
  static const String columnQuantity = "quantity";
  static const String columnIsBought = "is_bought";

  PurchaseTemplateItemsRepository() {
    super.init(
        "purchase_template_items",
            () => PurchaseTemplateItem(),
        [
          RelativeDbField<PurchaseTemplateItem, PurchaseTemplate>(
            relativeIdColumnName: columnPurchaseId,
            getter: (PurchaseTemplateItem item) => item.parent,
            setter: (PurchaseTemplateItem item, PurchaseTemplate? purchase) => item.parent = purchase,
            index: true,
          ),
          RelativeDbField<PurchaseTemplateItem, GoodsItem>(
            relativeIdColumnName: columnGoodsItemId,
            getter: (PurchaseTemplateItem item) => item.goodsItem,
            setter: (PurchaseTemplateItem item, GoodsItem? goodsItem) => item.goodsItem = goodsItem,
            index: true,
          ),
          DbField<PurchaseTemplateItem,int?>(
            columnName: columnQuantity,
            sqlType: "INTEGER",
            getter: (PurchaseTemplateItem item) => item.quantity,
            setter: (PurchaseTemplateItem item, int? quantity) => item.quantity = quantity,
          ),
          DbField<PurchaseTemplateItem,bool?>(
            columnName: columnIsBought,
            sqlType: "BOOLEAN",
            getter: (PurchaseTemplateItem item) => item.isBought,
            setter: (PurchaseTemplateItem item, bool? isBought) => item.isBought = isBought,
          ),
        ]
    );
  }

}
