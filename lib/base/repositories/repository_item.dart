import 'package:consumer_basket/base/repositories/abstract_repository.dart';
import 'package:consumer_basket/base/logger.dart';


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