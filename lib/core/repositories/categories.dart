import 'package:consumer_basket/core/base/repositories/db_repository.dart';
import 'package:consumer_basket/core/base/repositories/db_field.dart';
import 'package:consumer_basket/core/models/categories.dart';

class LowCategoriesRepository extends DbRepository<LowCategory> {

  LowCategoriesRepository(){
    super.init(
        "low_categories",
        () => LowCategory(),
        [
          DbField<LowCategory, String?>(
              columnName: "title",
              sqlType: "TEXT",
              getter: (LowCategory item) => item.title,
              setter: (LowCategory item, String? title) => item.title = title,
          ),
          RelativeDbField<LowCategory, MiddleCategory>(
              relativeIdColumnName: "parent_category_id",
              getter: (LowCategory item) => item.parentCategory,
              setter: (LowCategory item, MiddleCategory? parentCategory) => item.parentCategory = parentCategory,
              index: true,
          )
        ]
    );
  }
}


class MiddleCategoriesRepository  extends DbRepository<MiddleCategory>{

  MiddleCategoriesRepository(){
    super.init(
        "middle_categories",
        () => MiddleCategory(),
        [
          DbField<MiddleCategory, String?>(
            columnName: "title",
            sqlType: "TEXT",
            getter: (MiddleCategory item) => item.title,
            setter: (MiddleCategory item, String? title) => item.title = title,
          ),
          RelativeDbField<MiddleCategory, HighCategory>(
            relativeIdColumnName: "parent_category_id",
            getter: (MiddleCategory item) => item.parentCategory,
            setter: (MiddleCategory item, HighCategory? parentCategory) => item.parentCategory = parentCategory,
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
  
  HighCategoriesRepository(){
    super.init(
        "high_categories",
        () => HighCategory(),
        [
          DbField<HighCategory, String?>(
            columnName: "title",
            sqlType: "TEXT",
            getter: (HighCategory item) => item.title,
            setter: (HighCategory item, String? title) => item.title = title,
          )
        ]
    );
  }

  Future<Map<int,MiddleCategory>> getChildCategories(HighCategory highCategory) async {
    return await getDependents(highCategory);
  }
}
