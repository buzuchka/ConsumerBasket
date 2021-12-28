import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
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


class LowCategoriesRepository extends DbRepository<LowCategory> {

  LowCategoriesRepository(Database db, MiddleCategoriesRepository middleCategoryRepository){
    super.init(
        db, "low_categories",
        () => LowCategory(),
        [
          DbField<LowCategory, String?>(
              "title", "TEXT",
              (LowCategory item) => item.title,
              (LowCategory item, String? title) => item.title = title,
          ),
          RelativeDbField<LowCategory, MiddleCategory>(
              "parent_category_id", middleCategoryRepository,
              (LowCategory item) => item.parentCategory,
              (LowCategory item, MiddleCategory? parentCategory) => item.parentCategory = parentCategory,
              index: true,
          )
        ]
    );
  }
}


class MiddleCategoriesRepository  extends DbRepository<MiddleCategory>{

  MiddleCategoriesRepository(Database db, HighCategoriesRepository highCategoryRepository){
    super.init(
        db, "middle_categories", 
        () => MiddleCategory(),
        [
          DbField<MiddleCategory, String?>(
            "title", "TEXT",
            (MiddleCategory item) => item.title,
            (MiddleCategory item, String? title) => item.title = title,
          ),
          RelativeDbField<MiddleCategory, HighCategory>(
            "parent_category_id", highCategoryRepository,
            (MiddleCategory item) => item.parentCategory,
            (MiddleCategory item, HighCategory? parentCategory) => item.parentCategory = parentCategory,
            index: true,
          )
        ]
    );
  }

  Future<Map<int,LowCategory>> getChildCategories(MiddleCategory middleCategory) async {
    return await getDependents(middleCategory);
  }
}


class HighCategoriesRepository  extends DbRepository<HighCategory>{
  
  HighCategoriesRepository(Database db){
    super.init(
        db, "high_categories",
        () => HighCategory(),
        [
          DbField<HighCategory, String?>(
            "title", "TEXT",
            (HighCategory item) => item.title,
            (HighCategory item, String? title) => item.title = title,
          )
        ]
    );
  }

  Future<Map<int,MiddleCategory>> getChildCategories(HighCategory highCategory) async {
    return await getDependents(highCategory);
  }
}
