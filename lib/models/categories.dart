import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';


class LowCategory extends RelativesRepositoryItem<LowCategory, MiddleCategory, Object> {
  MiddleCategory? _parentCategory;

  // MiddleCategory? get parentCategory => _parentCategory;

  // // set parrent and save to the repository
  // setParentCategory(MiddleCategory? midCat) async {
  //
  //   if(_parentCategory != null){
  //     _parentCategory = null;
  //     _parentCategory!.removeChild(this);
  //   }
  //   _parentCategory = midCat;
  //   if(midCat != null){
  //     midCat.addChild(this);
  //   }
  //
  // }

  String? title;
}

class MiddleCategory extends  RelativesRepositoryItem<MiddleCategory, HighCategory, LowCategory> {
  Logger _logger = Logger("MiddleCategory");
  // HighCategory? parent_category;
  String? title;
  // Map<int,LowCategory> _child_categories = {};
  //
  // void addChild(LowCategory lowCat) {
  //   if(lowCat.parentCategory != this){
  //     lowCat.parentCategory = this;
  //   } else {
  //     if (lowCat.id != null){
  //
  //     } else {
  //
  //     }
  //   }
  // }
  // void removeChild(LowCategory lowCat) {
  //   if(lowCat.parentCategory == this){
  //     lowCat.parentCategory = null;
  //   } else {
  //     if (lowCat.id != null){
  //       _child_categories.remove(lowCat.id);
  //     } else {
  //       _logger.subModule("removeChild()").warning("low category has null id");
  //     }
  //   }
  // }

}

class HighCategory extends RelativesRepositoryItem<HighCategory, Object, MiddleCategory> {
  String? title;
  // Map<int,MiddleCategory> child_categories = {};
}
