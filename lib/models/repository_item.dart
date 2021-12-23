import 'package:consumer_basket/repositories/abstract_repository.dart';

import 'package:consumer_basket/common/logger.dart';



abstract class RepositoryItem<ItemT> {
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
}


abstract class RelativesRepositoryItem<ItemT, ParentT, ChildT> extends RepositoryItem<ItemT> {

  ParentT? parent;

  final Logger _logger = Logger("ParentsRepositoryItem<${ItemT.toString()}, ${ChildT.toString()}>");

  Future<Map<int,ChildT>> getChildren() async {
    var logger = _logger.subModule("getChildren()");
    if(repository != null){
      var parentsRepository = repository as AbstractRelativesRepository<ItemT, ParentT, ChildT>;
      await parentsRepository.getChildren(this as ItemT);
    } else {
      _logger.error("repository does not exist");
    }
    return {};
  }
}
