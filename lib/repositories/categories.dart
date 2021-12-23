import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/common/logger.dart'
import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/categories.dart';





class LowCategoriesRepository extends BaseDbRepository<LowCategory> {
  final Logger _logger = Logger("LowCategoriesRepository");
  static const String _columnTitle = 'title';
  static const String _columnMiddleCategoryId = 'middle_category';
  MiddleCategoriesRepository middleCategoriesRepository;

  LowCategoriesRepository(
      Database dbReference,
      this.middleCategoriesRepository){
    db = dbReference;
    table = "low_level_categories";
    schema = """
      $_columnTitle TEXT,
      $_columnMiddleCategoryId INTEGER
    """;
  }

  @override
  Future<Map<String, Object?>?> toMap(LowCategory obj) async {
    var map = <String, Object?>{
      _columnTitle: obj.title,
      _columnMiddleCategoryId: obj.parentCategory?.id,
    };
    return map;
  }

  @override
  Future<LowCategory?> fromMap(Map map) async{
    LowCategory result = LowCategory();
    result.title = map[_columnTitle] as String?;
    int? id = map[_columnMiddleCategoryId] as int?;
    if (id != null){
      var middles = await middleCategoriesRepository.getAll();
      result.parentCategory = middles[id];
      if(result.parentCategory == null){
        _logger.subModule("fromMap()").error("bad reference to middle category");
      }
    }
    //result.parent_category = map[_columnImagePathName] as String?;
    return  result;
  }
}


class MiddleCategoriesRepository  extends BaseDbRepository<MiddleCategory>{

}

