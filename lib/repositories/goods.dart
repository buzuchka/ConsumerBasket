import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/goods.dart';

class GoodsRepository extends BaseDbRepository<GoodsItem> {

  static const String _columnTitleName = 'title';
  static const String _columnImagePathName = 'image_path';

  GoodsRepository(Database dbReference){
    db = dbReference;
    table = "goods";
  }

  @override
  Map<String, Object?> toMap(GoodsItem obj){
    var map = <String, Object?>{
      _columnTitleName: obj.title,
      _columnImagePathName: obj.imagePath,
    };
    return map;
  }

  @override
  GoodsItem? fromMap(Map map){
    GoodsItem result = GoodsItem();
    result.title = map[_columnTitleName] as String?;
    result.imagePath = map[_columnImagePathName] as String?;
    return  result;
  }
}
