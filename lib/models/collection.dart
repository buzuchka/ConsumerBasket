import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';

abstract class AbstractCollectionItem<ItemT>  {
  AbstractCollection<ItemT>? collection;

  final Logger _logger = Logger("CollectionItem<${ItemT.toString()}>");

  Future<void> updateCollectionItem() async {
    if(collection != null){
      await collection!.updateItem(this as ItemT);
    } else {
      _logger.subModule("updateCollectionItem()").error("item does not have collection");
    }
  }

  Future<void> removeCollectionItem() async {
    if(collection != null){
      await collection!.removeItem(this as ItemT);
    } else {
      _logger.subModule("removeCollectionItem()").error("item does not have collection");
    }
  }

  // dynamic getId() {
  //   _logger.subModule("getId()").error("abstract method is called");
  // }
}


abstract class AbstractCollectionParent {

  Future<void> collectionItemInserted<ItemT>(
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


class RepoCollectionParent<ObjT> extends AbstractCollectionParent with RepositoryItem<ObjT> {

  @override
  Future<void> collectionItemInserted<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
    await saveToRepository();
  }

  @override
  Future<void> collectionItemUpdated<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
    // do nothing
  }

  @override
  Future<void> collectionItemRemoved<ItemT>(
      AbstractCollection<ItemT> collection,
      ItemT item) async {
    await saveToRepository();
  }
}


abstract class AbstractCollection<ItemT> {

  String name = "Collection<${ItemT.toString()}>";
  AbstractCollectionParent? parent;

  final Logger _logger = Logger("AbstractCollection<${ItemT.toString()}>");


  Future<void> updateItem(ItemT item) async {

  }

  Future<void> removeItem(ItemT item) async {
    _logger.subModule("remove()").error("abstract method is called");
  }

  Future<void> updateItemImpl() async {
    _logger.subModule("updateItemImpl()").warning("method default implementation is called");
  }

  Future<void> removeItemImpl() async {
    _logger.subModule("removeItemImpl()").warning("method default implementation is called");
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

