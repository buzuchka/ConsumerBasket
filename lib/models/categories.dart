import 'package:consumer_basket/repositories/categories.dart';
import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';


class LowCategory extends AbstractRepositoryItem<LowCategory> {
  MiddleCategory? parentCategory;
  String? title;
}

class MiddleCategory extends  AbstractRepositoryItem<MiddleCategory> {
  HighCategory? parentCategory;
  String? title;

  Future<Map<int, LowCategory>> getChildCategories() async{
    if(repository != null){
      return await (repository as MiddleCategoriesRepository).getChildCategories(this);
    }
    return {};
  }
}

class HighCategory extends AbstractRepositoryItem<HighCategory> {
  String? title;
  
  Future<Map<int, MiddleCategory>> getChildCategories() async{
    if(repository != null){
      return await (repository as HighCategoriesRepository).getChildCategories(this);
    }
    return {};
  }
}
