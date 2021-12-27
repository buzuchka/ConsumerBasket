import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';

// abstract class AbstractCollectionItem<ItemT extends AbstractCollectionItem<ItemT> >  {
//   AbstractCollection<ItemT>? collection;
//
//   final Logger _logger = Logger("CollectionItem<${ItemT.toString()}>");
//
//   Future<void> updateCollectionItem() async {
//     if(collection != null){
//       await collection!.updateItem(this as ItemT);
//     } else {
//       _logger.subModule("updateCollectionItem()").error("item does not have collection");
//     }
//   }
//
//   Future<void> removeCollectionItem() async {
//     if(collection != null){
//       await collection!.removeItem(this as ItemT);
//     } else {
//       _logger.subModule("removeCollectionItem()").error("item does not have collection");
//     }
//   }
//
//   // dynamic getId() {
//   //   _logger.subModule("getId()").error("abstract method is called");
//   // }
// }


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

  dynamic getItems() {
    _logger.subModule("getItems()").warning("abstract method default implementation is called");
  }

  Future<void> updateItem(ItemT item) async {
    await updateItemImpl(item);
    if(parent != null){
      await parent!.collectionItemUpdated(this, item);
    }else{
      _logger.subModule("updateItem()").warning("collection dose not have parent");
    }
  }

  Future<void> removeItem(ItemT item) async {
    var logger = _logger.subModule("removeItem()");
    // if(item.collection != this){
    //   logger.error("removing failed: item dose not belong to this collection");
    //   return;
    // }
    await removeItemImpl(item);
    // item.collection = null;
    if(parent != null){
      await parent!.collectionItemRemoved(this, item);
    }else{
      logger.warning("collection dose not have parent");
    }

  }

  Future<void> insertItem(ItemT item) async {
    var logger = _logger.subModule("insertItem()");
    // if(item.collection != null){
    //   logger.error("insertion failed: item already belongs to other collection");
    //   return;
    // }
    bool inserted = await insertItemImpl(item);
    if(!inserted){
      logger.error("insertion failed");
      return;
    }
    // item.collection = this;
    if(parent != null){
      await parent!.collectionItemInserted(this, item);
    }else{
      logger.warning("collection dose not have parent");
    }
  }

  Future<void> updateItemImpl(ItemT item) async {
    _logger.subModule("updateItemImpl()").error("abstract method default implementation is called");
  }

  Future<void> removeItemImpl(ItemT item) async {
    _logger.subModule("removeItemImpl()").error("abstract method default implementation is called");
  }

  Future<bool> insertItemImpl(ItemT item) async {
    _logger.subModule("insertItemImpl()").error("abstract method default implementation is called");
    return false;
  }
}


class RepositoryItemCollection<ItemT extends RepositoryItem<ItemT>> extends AbstractCollection<ItemT> {
  Map<int, ItemT> _itemById = {};

  final Logger _logger = Logger("RepositoryItemCollection<${ItemT.toString()}>");

  @override
  dynamic getItems() {
    return _itemById;
  }

  @override
  Future<void> updateItemImpl(ItemT item) async {
    // do nothing
  }

  @override
  Future<void> removeItemImpl(ItemT item) async {
    _itemById.remove(item.id);
  }

  @override
  Future<bool> insertItemImpl(ItemT item) async {
    var logger = _logger.subModule("insertItemImpl()");
    int? id = item.id;
    if(id == null){
      logger.error("item id is null");
      return false;
    }
    if(_itemById.containsKey(id)){
      logger.error("already contains item with id=$id");
      return false;
    }
    _itemById[id] = item;
    return true;
  }
}



