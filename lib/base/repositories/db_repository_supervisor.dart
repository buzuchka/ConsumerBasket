import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/base/repositories/internal/db_repository_supervisor_impl.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';


class DbRepositorySupervisor {

  DbRepositorySupervisor(List<AbstractDbRepository> repositories) {
    _impl.init(this,repositories);
  }

  // opens database and updates schemas in db if required
  openDatabase(String databaseName) async {
    await _impl.openDb(databaseName);
  }

  // returns repository by item type
  AbstractDbRepository<ItemT>? getRepositoryByType<ItemT extends AbstractRepositoryItem<ItemT>>(){
    return _impl.getRepositoryByType<ItemT>();
  }

  // returns repository by item type name
  AbstractDbRepository? getRepositoryByTypeName(String itemTypeName){
    return _impl.getRepositoryByTypeName(itemTypeName);
  }

  final DbRepositorySupervisorImpl _impl = DbRepositorySupervisorImpl();
}


