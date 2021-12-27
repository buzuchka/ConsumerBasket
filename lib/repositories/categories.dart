import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/common/logger.dart'
import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/categories.dart';

class CategoriesRepositories {
  late LowCategoriesRepository lowCategories;
  late MiddleCategoriesRepository middleCategories;
  late HighCategoriesRepository highCategories;

  CategoriesRepositories(Database db) {
    highCategories = HighCategoriesRepository(db);
    middleCategories = MiddleCategoriesRepository(db, highCategories);
    lowCategories = LowCategoriesRepository(db, middleCategories);
  }

}


class LowCategoriesRepository extends BaseDbRepository<LowCategory> {

 
  LowCategoriesRepository(Database db, MiddleCategoriesRepository middleCategoryRepository){
    var titleField = DbField<LowCategory, String?>(
      "title", "TEXT",
      (LowCategory item) => item.title,
      (LowCategory item, String? title) => item.title = title,
    );

    var parentCategoryField = RelativeDbField<LowCategory, MiddleCategory?>(
      "parent_category_id", middleCategoryRepository,
      (LowCategory item) => item.parentCategory,
      (LowCategory item, MiddleCategory? parentCategory) => item.parentCategory = parentCategory,
      index: true,
    );
    
    super.init(
        db, "low_categories", 
        middleCategoryRepository,
        () => LowCategory(),
        [titleField, parentCategoryField]
    );
  }
}


class MiddleCategoriesRepository  extends BaseDbRepository<MiddleCategory>{

  MiddleCategoriesRepository(Database db, HighCategoriesRepository highCategoryRepository){
    var titleField = DbField<MiddleCategory, String?>(
      "title", "TEXT",
      (MiddleCategory item) => item.title,
      (MiddleCategory item, String? title) => item.title = title,
    );

    var parentCategoryField = RelativeDbField<MiddleCategory, HighCategory?>(
      "parent_category_id", highCategoryRepository,
      (MiddleCategory item) => item.parentCategory,
      (MiddleCategory item, HighCategory? parentCategory) => item.parentCategory = parentCategory,
      index: true,
    );

    super.init(
        db, "middle_categories", 
        () => MiddleCategory(),
        [titleField, parentCategoryField]
    );
  }

  Future<Map<int,LowCategory>> getCildCategories(MiddleCategory middleCategory) async {
    return await getDependents(middleCategory);
  }

}


class HighCategoriesRepository  extends BaseDbRepository<HighCategory>{
  
  HighCategoriesRepository(Database db){
    
    var titleField = DbField<HighCategory, String?>(
      "title", "TEXT",
      (HighCategory item) => item.title,
      (HighCategory item, String? title) => item.title = title,
    );
    
    super.init(
        db, "high_categories",
        () => MiddleCategory(),
        [titleField]
    );
  }

  Future<Map<int,MiddleCategory>> getCildCategories(HighCategory highCategory) async {
    return await getDependents(highCategory);
  }
}
