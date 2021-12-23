import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/goods.dart';

class GoodsRepository extends BaseDbRepository<GoodsItem> {

  static const String _columnTitle = 'title';
  static const String _columnImagePath = 'image_path';

  GoodsRepository(Database dbReference){
    db = dbReference;
    table = "goods";
    schema ="""
        $_columnTitle TEXT(50), 
        $_columnImagePath TEXT
    """;
  }

  @override
  Future<Map<String, Object?>?> toMap(GoodsItem obj) async{
    var map = <String, Object?>{
      _columnTitle: obj.title,
      _columnImagePath: obj.imagePath,
    };
    return map;
  }

  @override
  Future<GoodsItem?> fromMap(Map map) async{
    GoodsItem result = GoodsItem();
    result.title = map[_columnTitle] as String?;
    result.imagePath = map[_columnImagePath] as String?;
    return  result;
  }
}
