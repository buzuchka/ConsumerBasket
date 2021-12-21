import 'package:consumer_basket/models/abstract_model.dart';
import 'package:consumer_basket/models/purchase_item.dart';

const String columnIdName = 'id';
const String columnShopIdName = 'shop_id';
const String columnDateTimeName = 'date_text';

class Purchase extends Model {
  static String tableName = 'purchases';

  int? id;
  int? shopId;
  String? date;
  List<PurchaseItem> i;

  Purchase();

  Purchase.Full(this.id, this.shopId, this.date);

  @override
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnShopIdName: shopId,
      columnDateTimeName: date,
    };
    if (id != null) {
      map[columnIdName] = id;
    }
    return map;
  }

  Purchase.fromMap(Map map) {
    id = map[columnIdName] as int?;
    shopId = map[columnShopIdName] as int?;
    date = map[columnDateTimeName] as String?;
  }
}
