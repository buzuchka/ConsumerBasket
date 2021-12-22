import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:sqflite/sqflite.dart';




class GoodsRepository extends BaseDbRepository<GoodsItem> {

  static const String _columnIdName = 'id';
  static const String _columnTitleName = 'title';
  static const String _columnImagePathName = 'image_path';

  GoodsRepository(Database dbReference){
    db = dbReference;
    table = "goods";
  }

  @override
  Map<String, Object?> toMap(GoodsItem goodsItem){
    var map = <String, Object?>{
      _columnTitleName: goodsItem.title,
      _columnImagePathName: goodsItem.imagePath,
    };
    if (goodsItem.id != null) {
      map[_columnIdName] = goodsItem.id;
    }
    return map;
  }

  @override
  GoodsItem? fromMap(Map map){
    GoodsItem result = GoodsItem();
    result.id = map[_columnIdName] as int?;
    result.title = map[_columnTitleName] as String?;
    result.imagePath = map[_columnImagePathName] as String?;
    result.repository = this;
    return  result;
  }

  @override
  dynamic getId(GoodsItem obj){
    return obj.id;
  }

  @override
  void setId(GoodsItem obj, dynamic id){
    obj.id = id;
  }
}
