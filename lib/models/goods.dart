import 'package:consumer_basket/models/abstract_model.dart';

const String columnIdName = '_id';
const String columnTitleName = 'title';

class GoodsItem extends Model {
  static String tableName = 'goods';

  int? id;
  String? title;

  GoodsItem();

  GoodsItem.Full(this.id, this.title);

  GoodsItem.Short(String _title){
    title = _title;
  }

  @override
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitleName: title,
    };
    if (id != null) {
      map[columnIdName] = id;
    }
    return map;
  }

  GoodsItem.fromMap(Map map) {
    id = map[columnIdName] as int?;
    title = map[columnTitleName] as String?;
  }
}
