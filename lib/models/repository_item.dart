import 'package:consumer_basket/repositories/abstract_repository.dart';

abstract class RepositoryItem<ItemT> {
  AbstractRepository<ItemT>? repository;

  Future<void> saveToRepository() async {
    if(repository != null){
      await repository!.update(this as ItemT);
    } else {
      print("Error: RepositoryItem<ItemT>::saveToRepository(): repository does not exist");
    }
  }
}