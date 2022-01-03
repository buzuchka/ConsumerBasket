import 'package:consumer_basket/core/base/repositories/abstract_repository.dart';
import 'package:consumer_basket/core/helpers/logger.dart';

abstract class AbstractRepositoryItem<ItemT extends AbstractRepositoryItem<ItemT>> {
  
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
    return isValidRepositoryItem(this, repository:repository, logger: logger);
  }
}

bool isValidRepositoryItem<ItemT extends AbstractRepositoryItem<ItemT>>(
    ItemT? item, {AbstractRepository<ItemT>? repository, Logger? logger}){
  Logger? _logger = logger?.subModule("IsValidRepositoryItem<${ItemT.toString()}>()");
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