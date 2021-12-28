import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase.dart';

// Элемент в покупке (товар+цена+количество)
class PurchaseItem extends AbstractRepositoryItem<PurchaseItem> {
  Purchase? parent;
  GoodsItem? goodsItem;
  double? price;
  int? quantity;
}