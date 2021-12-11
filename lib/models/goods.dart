import 'package:consumer_basket/models/abstract_model.dart';

const String columnIdName = 'id';
const String columnTitleName = 'title';
const String columnImagePathName = 'image_path';

class GoodsItem extends Model {
  static String tableName = 'goods';

  int? id;
  String? title;
  String? imagePath;

  GoodsItem();

  GoodsItem.Full(this.id, this.title, this.imagePath);

  GoodsItem.Short(String _title){
    title = _title;
  }

  @override
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitleName: title,
      columnImagePathName: imagePath,
    };
    if (id != null) {
      map[columnIdName] = id;
    }
    return map;
  }

  GoodsItem.fromMap(Map map) {
    id = map[columnIdName] as int?;
    title = map[columnTitleName] as String?;
    imagePath = map[columnImagePathName] as String?;
  }
}
