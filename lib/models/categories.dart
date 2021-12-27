import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';


class LowCategory extends RepositoryItem<LowCategory> {
  MiddleCategory? parentCategory;
  String? title;

}

class MiddleCategory extends  RepositoryItem<MiddleCategory> {
  HighCategory? parentCategory;
  String? title;

  Future<Map<int, LowCategory>> getChildCategories() async{
    if(repository != null){
      return await (repository as MiddleCategoriesRepository).getChildCategories(this);
    }
    return {};
  }
}

class HighCategory extends RepositoryItem<HighCategory> {
  String? title;
  
  Future<Map<int, MiddleCategory>> getChildCategories() async{
    if(repository != null){
      return await (repository as HightCategoriesRepository).getChildCategories(this);
    }
    return {};
  }
}
