import 'package:consumer_basket/models/repository_item.dart';
import 'package:consumer_basket/models/purchase_item.dart';

// Покупка
class Purchase extends RepositoryItem<Purchase> {
  int? shopId;
  String? date;
  //List<PurchaseItem> purchaseItems = [];
}
