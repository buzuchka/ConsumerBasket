import 'package:consumer_basket/common/logger.dart';

typedef Hook<ItemT> = Future<void> Function(ItemT);

abstract class AbstractRepository<ItemT> {
  final Logger _logger = Logger("AbstractRepository<${ItemT.toString()}>");

  // returns items as id->value (get form cache or get from db and create cache)
  Future<Map<int,ItemT>> getAll() async {
    _logger.abstractMethodError("getAll()");
    return {};
  }

  // returns items cache if it exists
  Map<int,ItemT>? getAllCache() {
    _logger.abstractMethodError("getAllCach()");
  }

  // returns true if success
  Future<bool> update(ItemT item) async {
    _logger.abstractMethodError("update()");
    return false;
  }

  // returns inserted id or 0 if not inserted
  Future<int> insert(ItemT item) async {
    _logger.abstractMethodError("insert()");
    return 0;
  }

  // returns true if deleted
  Future<bool> delete(ItemT item) async {
    _logger.abstractMethodError("delete()");
    return false;
  }

}


abstract class AbstractRelativesRepository<ItemT, ParentT, ChildT> {

  final Logger _aLogger = Logger("AbstractRelativesRepository<${ItemT.toString()},${ChildT.toString()}>");

  Future<Map<int,ChildT>> getChildren(ItemT item) async {
    _aLogger.abstractMethodError("getChildren()");
    return {};
  }

  Future<Map<int,ItemT>> getItemsByParent(ParentT parent) async{
    _aLogger.abstractMethodError("getItemsByParent()");
    return {};
  }

  // internal
  void setParent(ItemT item, ParentT? parent) {
    _aLogger.abstractMethodError("setParent()");
  }
}