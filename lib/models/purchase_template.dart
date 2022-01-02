import 'package:intl/intl.dart';

import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/purchase_template_item.dart';

// Список (список элементов товар+количество)
class PurchaseTemplate extends AbstractRepositoryItem<PurchaseTemplate> {
  static final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  String? title;
  DateTime creationDate = DateTime.now();
  String? imagePath;
  Map<int, PurchaseTemplateItem> items = {};
}
