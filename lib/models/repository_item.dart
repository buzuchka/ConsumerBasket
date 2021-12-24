import 'package:consumer_basket/repositories/abstract_repository.dart';

import 'package:consumer_basket/common/logger.dart';



abstract class RepositoryItem<ItemT extends RepositoryItem<ItemT>> {
  AbstractRepository<ItemT>? repository;
  int? id;

  final Logger _logger = Logger("RepositoryItem<${ItemT.toString()}>");

  saveToRepository() async {
    var logger = _logger.subModule("saveToRepository()");
    if(repository != null){
      await repository!.update(this as ItemT);
      logger.info("successfully saved");
    } else {
      logger.error("repository does not exist");
    }
  }

  bool isValid({AbstractRepository<ItemT>? repository, Logger? logger}){
    return isValidRepositoryItem(this);
  }
}


abstract class RelativesRepositoryItem<
  ItemT extends RelativesRepositoryItem<ItemT, ParentT, ChildT>, ParentT, ChildT > extends RepositoryItem<ItemT> {

  ParentT? _parent;

  ParentT? get parent => _parent;

  set parent(ParentT? p) {
    if(repository != null){
      var relRep = repository! as AbstractRelativesRepository<ItemT, ParentT, ChildT>;
      relRep.setParent(this as ItemT, p);
    } else {
      parent = p;
    }
  }

  final Logger _logger = Logger("ParentsRepositoryItem<${ItemT.toString()}, ${ChildT.toString()}>");

  Future<Map<int,ChildT>> getChildren() async {
    var logger = _logger.subModule("getChildren()");
    if(repository != null){
      var relRep = repository as AbstractRelativesRepository<ItemT, ParentT, ChildT>;
      await relRep.getChildren(this as ItemT);
    } else {
      _logger.error("repository does not exist");
    }
    return {};
  }
}


bool isValidRepositoryItem<ItemT extends RepositoryItem<ItemT>>(
    ItemT? item, {AbstractRepository<ItemT>? repository, Logger? logger}){
  Logger? _logger = logger?.subModule("IsValidRepositoryItem");
  if(item == null){
    _logger?.error("item is null");
    return false;
  }
  if(item.id == null){
    _logger?.error("item id is null");
    return false;
  }
  if(item.repository == null){
    _logger?.error("item repository is null");
    return false;
  }
  if(repository != null && item.repository != repository){
    _logger?.error("unexpected repository");
    return false;
  }
  return true;
}