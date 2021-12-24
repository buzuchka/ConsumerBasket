import 'package:consumer_basket/common/logger.dart';

abstract class AbstractRepository<ItemT> {
  final Logger _logger = Logger("AbstractRepository<${ItemT.toString()}>");


  // returns items cache as id->value
  Future<Map<int,ItemT>> getAll() async {
    _logger.abstractMethodError("getAll()");
    return {};
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