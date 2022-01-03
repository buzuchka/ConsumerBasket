import 'package:decimal/decimal.dart';

import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase_template.dart';

// Элемент в списке (товар+количество)
class PurchaseTemplateItem extends AbstractRepositoryItem<PurchaseTemplateItem> {
  PurchaseTemplate? parent;
  GoodsItem? goodsItem;
  Decimal? quantity = Decimal.one;
  bool? isBought;

  Decimal? get lastUnitPrice => goodsItem?.lastPurchaseUnitPrice;
  Decimal? get approximatedTotalPrice {
    if(lastUnitPrice != null &&  quantity!= null){
      return lastUnitPrice! * quantity!;
    }
  }
}