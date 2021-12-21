import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';

abstract class CollectionItem<ItemT>  {
  AbstractCollection<ItemT>? collection;

  final Logger _logger = Logger("CollectionItem<${ItemT.toString()}>");

  Future<void> updateCollectionItem() async {
    if(collection != null){
      await collection!.update(this as ItemT);
    } else {
      _logger.subModule("updateCollectionItem()").error("collection does not exist");
    }
  }

  Future<void> removeCollectionItem() async {
    if(collection != null){
      await collection!.remove(this as ItemT);
    } else {
      _logger.subModule("removeCollectionItem()").error("collection does not exist");
    }
  }

  dynamic getId() {
    _logger.subModule("getId()").error("abstract method is called");
  }
}


abstract class CollectionParent {

  Future<void> collectionNewItemInserted<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
  }

  Future<void> collectionItemUpdated<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
  }

  Future<void> collectionItemRemoved<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
  }
}


class CollectionSimpleRepoUpdater<ObjT> extends CollectionParent with RepositoryItem<ObjT> {

  Future<void> collectionNewItemInserted<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
    saveToRepository();
  }

  Future<void> collectionItemUpdated<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
    // do nothing
  }

  Future<void> collectionItemRemoved<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
    saveToRepository();
  }
}


abstract class AbstractCollection<ItemT> {

  String name = "Collection<${ItemT.toString()}>";


  final Logger _logger = Logger("AbstractCollection<${ItemT.toString()}>");

  Future<void> update(ItemT item) async {
    _logger.subModule("update()").error("abstract method is called");
  }

  Future<void> remove(ItemT item) async {
    _logger.subModule("remove()").error("abstract method is called");
  }
}




// class BaseTreeNode {
//
//   Future<void> childUpdated() async{
//     Logger("BaseTreeNode").subModule("update()").error("abstract method is called");
//   }
// }
//
// class TreeNode<ChildItemT extends CollectionItem> extends BaseTreeNode {
//   final Map<dynamic,ChildItemT> _items = {};
//
//   void add(ItemT){
//
//   }
//
//   @override
//   Future<void> remove(ChildItemT item) async{
//   }
// }
//

