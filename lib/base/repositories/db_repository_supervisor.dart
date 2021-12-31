import 'package:consumer_basket/base/repositories/internal/db_repository_supervisor_impl.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';


class DbRepositorySupervisor {

  DbRepositorySupervisor(List<AbstractDbRepository> repositories) :
        _impl = DbRepositorySupervisorImpl(repositories);

  // opens database and updates schemas in db if required
  openDatabase(String databaseName) async {
    await _impl.openDb(databaseName);
  }

  final DbRepositorySupervisorImpl _impl;
}


