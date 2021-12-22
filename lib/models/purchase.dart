import 'package:intl/intl.dart';

import 'package:consumer_basket/models/repository_item.dart';

// Покупка
class Purchase extends RepositoryItem<Purchase> {
  static final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  int? shopId;
  DateTime date = DateTime.now();
  //List<PurchaseItem> purchaseItems = [];
}
