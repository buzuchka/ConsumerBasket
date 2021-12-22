import 'package:consumer_basket/repositories/abstract_repository.dart';

import 'package:consumer_basket/common/logger.dart';



abstract class RepositoryItem<ItemT> {
  AbstractRepository<ItemT>? repository;
  int? id;

  final Logger _logger = Logger("RepositoryItem<${ItemT.toString()}>");

  Future<void> saveToRepository() async {
    var sublogger = _logger.subModule("saveToRepository()");
    if(repository != null){
      await repository!.update(this as ItemT);
      sublogger.info("successfully saved");
    } else {
      sublogger.error("repository does not exist");
    }
  }
}