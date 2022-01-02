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

  PurchaseTemplatesRepository purchaseTemplatesRepository;

  PurchaseTemplateItemsRepository(
      this.purchaseTemplatesRepository,
      GoodsRepository goodsRepository) {
    super.init(
        "purchase_template_items",
            () => PurchaseTemplateItem(),
        [
          RelativeDbField<PurchaseTemplateItem, PurchaseTemplate>(
            columnPurchaseId,
            purchaseTemplatesRepository,
            (PurchaseTemplateItem item) => item.parent,
            (PurchaseTemplateItem item, PurchaseTemplate? purchase) => item.parent = purchase,
            index: true,
          ),
          RelativeDbField<PurchaseTemplateItem, GoodsItem>(
            columnGoodsItemId,
            goodsRepository,
            (PurchaseTemplateItem item) => item.goodsItem,
            (PurchaseTemplateItem item, GoodsItem? goodsItem) => item.goodsItem = goodsItem,
            index: true,
          ),
          DbField<PurchaseTemplateItem,int?>(
            columnQuantity, "INTEGER",
            (PurchaseTemplateItem item) => item.quantity,
            (PurchaseTemplateItem item, int? quantity) => item.quantity = quantity,
          ),
          DbField<PurchaseTemplateItem,bool?>(
            columnIsBought, "BOOLEAN",
            (PurchaseTemplateItem item) => item.isBought,
            (PurchaseTemplateItem item, bool? isBought) => item.isBought = isBought,
          ),
        ]
    );
  }

}
