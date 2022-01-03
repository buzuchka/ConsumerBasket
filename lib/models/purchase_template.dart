import 'package:decimal/decimal.dart';

import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/purchase_template_item.dart';

// Список (список элементов товар+количество)
class PurchaseTemplate extends AbstractRepositoryItem<PurchaseTemplate> {
  String? title;
  DateTime creationDate = DateTime.now();
  String? imagePath;
  Map<int, PurchaseTemplateItem> items = {};

  Decimal? get approximatedAmount {
    Decimal result = Decimal.zero;
    for(var item in items.values){
      if(item.lastUnitPrice == null){
        return null;
      }
      result += item.lastUnitPrice!;
    }
    return result;
  }
}
